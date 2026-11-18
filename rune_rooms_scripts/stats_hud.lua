local HudStat = {}

local font = Font("font/luaminioutlined.fnt")

local HudSprite = Sprite("gfx/ui/hudstats2.anm2", true)
HudSprite.Color = Color(1, 1, 1, 0.5)
--HudSprite.Offset = Vector(-8, -8)
HudSprite:Stop(true)
HudSprite:SetFrame("Idle", 8)

local initialOffest = Vector(0, 10)
local offsetX, offsetY = 0, 0
local previousChance = 0
local currentChance = 0

local textColor = KColor(1, 1, 1, 0.5)

--[[local element = FoundHUDHelper:Register(RuneRooms, HudSprite, -10)
element.Sprite:Stop(true)
element.Sprite:SetFrame("Idle", 8)


function HudStat:OldRender()
	element.Visible = (
		(RuneRooms:RoomsUnlocked() or RuneRooms.Helpers:IsDebugEnabled()) and not RuneRooms.Game:IsGreedMode()
	) and RuneRooms:ShowIcon()

	local currentChance = RuneRooms.API:GetRoomSpawnChance() * 100

	if not RuneRooms.API:CanSpawnRuneRoom() then
		currentChance = 0
	end
	element.PrimaryText = FoundHUDHelper:GetFormattedPercentage(currentChance)
	previousChance = previousChance or currentChance

	if previousChance ~= currentChance then
		local diff = currentChance - previousChance
		local color = diff > 0 and FoundHUDHelper.COLOR_STAT_CHANGE_POSITIVE
			or FoundHUDHelper.COLOR_STAT_CHANGE_NEGATIVE
		local index = FoundHUDHelper:GetIndex(element)
		FoundHUDHelper:DisplayStatChange(index, FoundHUDHelper:GetFormattedPercentage(diff, true), color)
		previousChance = currentChance
	end
end]]

function HudStat:UpdateChance()
	previousChance = previousChance or currentChance
	if not RuneRooms.API:CanSpawnRuneRoom() then
		currentChance = 0
	else
		currentChance = RuneRooms.API:GetRoomSpawnChance() * 100
	end

	local xOffset, yOffset = 0, 0

	if RuneRooms.Game.Difficulty > 0 or RuneRooms.Game.Challenge > 0 then
		yOffset = 16
	end
	if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_DUALITY) then
		yOffset = yOffset + 2
	end
	if #HudHelper.GetHUDPlayers() > 1 then
		yOffset = yOffset + 4
	end
	HudSprite.Offset.X, HudSprite.Offset.Y = initialOffest.X + xOffset, initialOffest.Y + yOffset
end
--RuneRooms:AddCallback(ModCallbacks.MC_POST_UPDATE, HudStat.UpdateChance)

function HudStat:Render()
	if
		not (
			((RuneRooms:RoomsUnlocked() or RuneRooms.Helpers:IsDebugEnabled()) and not RuneRooms.Game:IsGreedMode())
			and RuneRooms:ShowIcon()
		)
	then
		return
	end

	local players = HudHelper.GetHUDPlayers()
	if #players == 0 then
		HudHelper.PopulateHUDPlayers()
	end
	HudStat:UpdateChance()
	local pos = HudHelper.RenderHUDIcon(HudSprite, HudHelper.IconType.STAT)
	if pos ~= nil then
		font:DrawString(string.format("%.1f%%", currentChance), pos.X + HudSprite.Offset.X + 16, pos.Y + HudSprite.Offset.Y + 1, textColor)
	end
end

RuneRooms:AddCallback(ModCallbacks.MC_HUD_RENDER, HudStat.Render)
