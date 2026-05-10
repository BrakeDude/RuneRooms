local StatsHud = {}

-- Some code from Planetarium Chance mod
 
local function TextAcceleration(frame) --Overfit distance profile for difference text slide in
	frame = frame - 14
	if frame > 0 then
		return 0
	end
	return -(15.1 / (13 * 13)) * frame * frame
end

function StatsHud:Render()
    if not RuneRooms:RoomsUnlocked() or Game():IsGreedMode() then
        return
    end


end
RuneRooms:AddCallback(ModCallbacks.MC_HUD_RENDER, StatsHud.Render)