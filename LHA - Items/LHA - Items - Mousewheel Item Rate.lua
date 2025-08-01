--ITEM RATE MOUSEWHEEL BY LEWIS HAINES AUDIO.
-- BIG THANKS TO JAKE BASTEN FOR HELP WITH THE MATHS - www.jakebasten.co.uk

	--CHANGE THIS TO MODIFY RATE CHANGE INTENSITY
	scalingAmount = 0.05

	--GET ACTION CONTEXT & ESTABLISH MINIMUM RATE
	local is_new,filename,sectionID,cmdID,mode,resolution,val = reaper.get_action_context() 
	pitchRateMinimum = 0.001

	--GET MOUSE DIRECTION
	if val == 0 or not is_new then return end
	if val > 0 then 
	  rateMod = scalingAmount
	elseif val < 0 then                                                                    
	  rateMod = -1*scalingAmount                                                    -- gets mousewheel input and accounts for direction
	else return end

	--SELECT ITEM UNDER CURSOR
	reaper.Main_OnCommand(40528, 0)
	 
	--GETS SELECTED MEDIA ITEM AND TAKE
	selItem = reaper.GetSelectedMediaItem(0,0)                                   --checks if media item is selected, terminates if not
	if selItem then
	  selTake = reaper.GetMediaItemTake(selItem, 0)
	else return end

	--GETS MEDIA ITEM AND TAKE INFO
	curLength = reaper.GetMediaItemInfo_Value(selItem, "D_LENGTH")
	curRate = reaper.GetMediaItemTakeInfo_Value(selTake, "D_PLAYRATE")
	itpPitch = reaper.GetMediaItemTakeInfo_Value(selTake, "B_PPITCH")
	
	--TURNS OFF PRESERVE PITCH ON ITEM
	if itpPitch == 1 then
	 reaper.SetMediaItemTakeInfo_Value(selTake, "B_PPITCH", 0)               --if preserve pitch is on, turns it off
	 end
	 
	--RATE & LENGTH CALCULATION
	if curRate >= pitchRateMinimum or rateMod < 0 then
	  newRate = curRate * (1 - rateMod)
	  newLength = curLength / (1 - rateMod)
	 end
 
	--CHANGE ITEM RATE
	reaper.SetMediaItemTakeInfo_Value(selTake, "D_PLAYRATE", newRate)
	reaper.SetMediaItemInfo_Value(selItem, "D_LENGTH", newLength)
	reaper.UpdateArrange()

reaper.defer(function() end)
