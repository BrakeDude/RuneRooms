local HudStat = {}

local HudSprite = Sprite("gfx/ui/hudstats2.anm2", true)
HudSprite.Color = Color(1, 1, 1, 0.5)
HudSprite.Offset = Vector(-8, -8)

local element = FoundHUDHelper:Register(RuneRooms, HudSprite, -10)
element.Sprite:Stop(true)
element.Sprite:SetFrame("Idle", 8)
local previousChance

function HudStat:Render()
	element.Visible = ((RuneRooms:RoomsUnlocked() or RuneRooms.Helpers:IsDebugEnabled()) and not RuneRooms.Game:IsGreedMode()) and RuneRooms:GetDefaultFileSave("ShowHudIcon")

	local currentChance = RuneRooms.API:GetRoomSpawnChance() * 100

	if not RuneRooms.API:CanSpawnRuneRoom() then
		currentChance = 0
	end
	element.PrimaryText = FoundHUDHelper:GetFormattedPercentage(currentChance)
	previousChance = previousChance or currentChance

	if previousChance ~= currentChance then
		local diff = currentChance - previousChance
		local color = diff > 0 and FoundHUDHelper.COLOR_STAT_CHANGE_POSITIVE or FoundHUDHelper.COLOR_STAT_CHANGE_NEGATIVE
		local index = FoundHUDHelper:GetIndex(element)
		FoundHUDHelper:DisplayStatChange(index, FoundHUDHelper:GetFormattedPercentage(diff, true), color)
		previousChance = currentChance
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_HUD_RENDER, HudStat.Render)