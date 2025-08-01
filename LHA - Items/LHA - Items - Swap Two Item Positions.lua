--[[

Author: Lewis Haines
Description: Swaps the position of two selected media items
Versions: REAPER v7.39
License: GPL v3

]]--

----------[VARIABLES]----------

failed = "Please select only two items"
selItemAmt = reaper.CountSelectedMediaItems()
item1 = reaper.GetSelectedMediaItem(0, 0)
item2 = reaper.GetSelectedMediaItem(0, 1)
canRun = false

----------[FUNCTIONS]----------

function msg(m)
  reaper.ShowConsoleMsg(m .. "\n")
end

function getItemPositions(item)
  
  local itemPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  local itemLen = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
  local itemTrack = reaper.GetMediaItemTrack(item)
  
  if itemPos and itemLen then
    return itemPos, itemLen, itemTrack
  end

end

function setItemPositions(item, pos, len, track)

  reaper.SetMediaItemInfo_Value(item, "D_POSITION", pos, 1)
  reaper.SetMediaItemInfo_Value(item, "D_LENGTH", len, 1)
  reaper.MoveMediaItemToTrack(item, track, 1)

end

function main()

  item1Pos, item1Len, item1Track = getItemPositions(item1)
  item2Pos, item2Len, item2Track = getItemPositions(item2)
  setItemPositions(item1, item2Pos, item2Len, item2Track)
  setItemPositions(item2, item1Pos, item1Len, item1Track)
  
end

if selItemAmt == 2 then main() else reaper.ShowMessageBox(failed, "LHA - Error", 0) end
reaper.Undo_BeginBlock(0)

