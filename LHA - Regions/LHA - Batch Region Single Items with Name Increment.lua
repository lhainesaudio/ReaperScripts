-- init

-- get desired region name

function region_name_prompt()
  local region_name_entered = ""

  local b_valid_name_entered, entered_name_value = reaper.GetUserInputs(region_name_entered, 1, "Enter region name:, extrawidth - 500", "")
  if entered_name_value == '' then
   return null
  end
  if b_valid_name_entered then
    return entered_name_value
  else
    return null
  end
end
      
  
function create_region(region_start_pos, region_end_pos, region_name, regionNumber, trackColour)
  reaper.AddProjectMarker2(0, true, region_start_point, region_end_point, region_name, regionNumber, trackColour)
end
      
function main()
  
  local itemCount = reaper.CountSelectedMediaItems(0)
  if itemCount == 0 then 
    reaper.ShowConsoleMsg("LHA_BatchRegionItems - Please select one or more items")
    return
  end
  
   local new_region_name = region_name_prompt()
   if new_region_name == null then
      reaper.ShowConsoleMsg("LHA_BatchRegionItems - Please input a name")
    return
   end
  
    for i = 1, reaper.CountSelectedMediaItems(0) do
      local item = reaper.GetSelectedMediaItem(0, i-1)
      if item ~= 0 then
        local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        local item_end = item_pos + item_len
        local track = reaper.GetMediaItem_Track(item)
        if i < 10 then
            formatted_name = string.format("%s_%i%i", new_region_name, 0, i) -- format name with increment
           else
            formatted_name = string.format("%s_%i", new_region_name, i) -- format name with increment
        end
       reaper.AddProjectMarker2(0, true,item_pos, item_end, formatted_name, itemCount, reaper.GetTrackColor(track))
    end
  end
  reaper.Undo_OnStateChangeEx("Create regions from selected items with name increment", -1, -1)
end
     
reaper.defer(main)
