--[[
 * ReaScript Name: Batch Region Layered Items
 * Description: Creates regions 
 * Author: Lewis Haines Audio
 * Website: https://www.lewishainesaudio.co.uk
 * Repository URL: https://github.com/lhainesaudio/ReaperScripts
 * Licence: GPL v3
 
 CREDITS
 * Special Thanks To: X-Raym
 * X-Raym Website: https://www.extremraym.com/
--]]

-- FUNCTIONS ----------------------------------------------------
function GetDesiredName()

  local region_name_entered = ""
  local b_valid_name_entered, entered_name_value = reaper.GetUserInputs(region_name_entered, 1, "Enter region name:, extrawidth - 500", "")

  if entered_name_value == '' then
    reaper.ShowConsoleMsg("LHA Batch Region Items - Please input a name")
    return null
  end
  
  if b_valid_name_entered then
    return entered_name_value
  else
    return null
  end

end

-- From Function in X-Raym (Group Items according to their order in selection per track.lua)
function GroupItems()

  columns = {}
  positions = {}
  local column = 0
  
  for i = 0, count_sel_items do
  
    
    -- Get Columns of Selected Items
    columns = {} -- Original minimum positions and list of items for each columns
    positions = {} -- Minimum positions of items snap for each columns
    local column = 0
    
    for i = 0, count_sel_items - 1 do
    
      local item = reaper.GetSelectedMediaItem(0,i)
      local track = reaper.GetMediaItemTrack( item )
      local track_id = reaper.GetMediaTrackInfo_Value( track, "IP_TRACKNUMBER")
    
      if track_id ~= last_track_id then column = 0 end -- reset column counter
      column = column + 1 -- increment column
    
      local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      local item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
      local item_possnap = item_pos + item_snap
    
      if not columns[column] then
        columns[column] = {min_possnap = item_possnap, items = {} }
      else
        columns[column].min_possnap = math.min( columns[column].min_possnap, item_possnap )
      end
      positions[column] = columns[column].min_possnap
      table.insert(columns[column].items, item)
    
      last_track_id = track_id
      
      end
    
      -- Group items
      for i, column in ipairs( columns ) do
        reaper.SelectAllMediaItems(0, false)
        for j, item in ipairs( column.items ) do
          reaper.SetMediaItemSelected(item, true )
          if colorize then
            reaper.Main_OnCommand(40706, 0) -- set items to one random color
          end
          reaper.Main_OnCommand(40032, 0) -- Item grouping; Group items
        end
      end
    
      -- Reselect
      for i, column in ipairs( columns ) do
        for j, item in ipairs( column.items ) do
         reaper.SetMediaItemSelected(item, true )
      end
    end
  end
end

-- Get Groups Infos From Selected Items
-- From function in X-Raym (Create text items on first selected track from selected item groups.lua)
function GetGroupsFromSelectedItems()

  -- Count Sel Items (maybe it is already in GLobal variable)
  if not count_sel_items then
    count_sel_items = reaper.CountSelectedMediaItems(0)
  end

  groups = {} -- Table to store groups infos (min item and min pos)
  unselect = {} -- Table to store items to unselect after

  -- Loop in Sel Items
  for i = 0, count_sel_items - 1 do

    local item = reaper.GetSelectedMediaItem(0, i)

    -- Check Group
    local group = reaper.GetMediaItemInfo_Value(item, "I_GROUPID")
    if group > 0 then

      local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      local item_end = reaper.GetMediaItemInfo_Value(item, "D_LENGTH") + item_pos

      -- If group is new, then create one
      if not groups[group] then

        groups[group]={}

        groups[group].item = item -- Min item of the group
        groups[group].pos = item_pos -- Min item pos of the selected items in the group

      else -- if group exists in table, check item pos against min group item pos

        if item_pos < groups[group].pos then -- unselect previous item and set new one as reference
          groups[group].item = item
          groups[group].pos = item_pos
        end

      end -- If group don't exist

    end -- END IF GROUP (no else)

  end -- END LOOP sel items

end -- End of KeepSelOnlyFirstItemInGroups()

-- Insert infos about groups in the groups table
-- From function in X-Raym (Create text items on first selected track from selected item groups.lua)
function InsertGroupInfos()

  -- Count Items
  if not count_items then
    count_items = reaper.CountMediaItems(0)
  end

  -- Loop in All Items
  for i = 0, count_items - 1 do

    local item = reaper.GetMediaItem(0, i)
    local group = reaper.GetMediaItemInfo_Value(item, "I_GROUPID")

    -- If Item is in Group
    if group > 0 and groups[group] then

      local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      local item_end = reaper.GetMediaItemInfo_Value(item, "D_LENGTH") + item_pos

      -- Group Color
      if not groups[group].color then
        item_color = reaper.GetMediaItemInfo_Value(item, "I_CUSTOMCOLOR")

        if item_color > 0 then
          groups[group].color = item_color
        end
      end

      -- Group Min Pos
      if groups[group].min_pos then

        if item_pos < groups[group].min_pos then
          groups[group].min_pos = item_pos
        end

      else
        groups[group].min_pos = item_pos -- Min item pos of the group
      end

      -- Group Max End
      if groups[group].max_end then

        if item_end > groups[group].max_end then
          groups[group].max_end = item_end
        end

      else
        groups[group].max_end = item_end
      end

    end -- if groups

  end -- if items

end -- InsertGroupInfos()


function CreateRegionsFromGroups(region_name)
  
  local increment = 1
  
  for i, group in pairs(groups) do
        
    region_pos, region_end = group.min_pos, group.max_end
        
    if increment < 10 then
      formatted_name = string.format("%s_%i%i", region_name, 0, increment) -- format name with increment
    else
      formatted_name = string.format("%s_%i", region_name, increment) -- format name with increment
    end
       
    reaper.AddProjectMarker2(0, true, region_pos, region_end, formatted_name, count_sel_items, 0)
    increment = increment + 1  
  end
end


-- MAIN FUNCTION ------------------------------------------------
function main()

  local desired_name = GetDesiredName()
  
  if desired_name ~= false then
  
    GroupItems()
    GetGroupsFromSelectedItems()
    InsertGroupInfos()
    
    CreateRegionsFromGroups(desired_name)
  end
end

function Init()
  
  count_sel_items = reaper.CountSelectedMediaItems(0)
  count_sel_tracks = reaper.CountSelectedTracks(0)
  
  createTrackAtTop =  reaper.NamedCommandLookup("_SWS_CREATETRK1")
  selectItemsOnTrack = reaper.NamedCommandLookup("__SWS_TOGITEMSEL")
  
  if count_sel_items > 1 then
  
    reaper.PreventUIRefresh(1)
    
    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
    
    main()
    
    reaper.Undo_EndBlock("Batch Region Layered Items", -1) -- End of the undo block. Leave it at the bottom of your main function.
    
    reaper.UpdateArrange()
    
    reaper.PreventUIRefresh(-1)
  end
end

Init()
