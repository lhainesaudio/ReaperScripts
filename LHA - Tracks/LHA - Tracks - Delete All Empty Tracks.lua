--[[

Author: Lewis Haines
Description: Deletes all empty non-folder tracks within a project
Version: Reaper v3.79
License: GPL v3

]]--

----------[VARIABLES]----------

trackCount = reaper.CountTracks(0)
errorNoTracks = "No tracks in project"
errorNoEmpty = "No empty non-folder tracks to remove"
tracksToRemove = {}

----------[FUNCTIONS]----------

function main()

 for i=0, trackCount-1 do
  selTrack = reaper.GetTrack(0, i)
  trackItemCount = reaper.CountTrackMediaItems(selTrack)
  trackIsFolder = reaper.GetMediaTrackInfo_Value(selTrack, "I_FOLDERDEPTH")
  if trackItemCount == 0 and trackIsFolder ~= 1 then
    table.insert(tracksToRemove, selTrack)
  end
end

if #(tracksToRemove) ~= 0 then
  for j=1, #(tracksToRemove) do
    reaper.DeleteTrack(tracksToRemove[j])
  end
else reaper.ShowMessageBox(errorNoEmpty, "LHA - Error", 0)
end

end

if trackCount ~= 0 then main() else reaper.ShowMessageBox(errorNoTracks, "LHA - Error", 0) end
reaper.Undo_BeginBlock(0)

  
