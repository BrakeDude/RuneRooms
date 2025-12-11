local EhwazPositive = {}

local CLOSE_CHANCE = 0.5
local TO_CLOSE_DURATION = 2 * 30 -- 2 seconds at 30 fps
--Taken from the eternal chest closing animation
local CLOSING_ANIMATION_FRAMES = {
	{ anim = "Opened", scaleX = 100, scaleY = 100 },
	{ anim = "Opened", scaleX = 105, scaleY = 95 },
	{ anim = "Opened", scaleX = 110, scaleY = 90 },
	{ anim = "Opened", scaleX = 95, scaleY = 105 },
	{ anim = "Idle", scaleX = 80, scaleY = 120 },
	{ anim = "Idle", scaleX = 100, scaleY = 100 },
	{ anim = "Idle", scaleX = 120, scaleY = 80 },
	{ anim = "Idle", scaleX = 100, scaleY = 100 },
	{ anim = "Idle", scaleX = 80, scaleY = 120 },
	{ anim = "Idle", scaleX = 90, scaleY = 110 },
	{ anim = "Idle", scaleX = 100, scaleY = 100 },
	{ anim = "Idle", scaleX = 100, scaleY = 100 },
	{ anim = "Idle", scaleX = 100, scaleY = 100 },
	{ anim = "Idle", scaleX = 100, scaleY = 100 },
	{ anim = "Idle", scaleX = 100, scaleY = 100 },
	{ anim = "Idle", scaleX = 100, scaleY = 100 },
	{ anim = "Idle", scaleX = 100, scaleY = 100 },
	{ anim = "Idle", scaleX = 100, scaleY = 100 },
	{ anim = "Idle", scaleX = 100, scaleY = 100 },
	{ anim = "Idle", scaleX = 100, scaleY = 100 },
}
--Taken from https://bindingofisaacrebirth.fandom.com/wiki/Chests#Mega_Chest
local MIN_MEGA_CHEST_KEYS = 1
local MAX_MEGA_CHEST_KEYS = 7

---@param chest EntityPickup
function RuneRooms:WillChestClose(chest)
	return chest:GetData().CloseChest == true
end

---@param chest EntityPickup
local function PlayClosingAnimation(chest)
	local closingAnimFrame = TSIL.Entities.GetEntityData(RuneRooms, chest, "ClosingAnimationTimer")

	local sprite = chest:GetSprite()
	local frameInfo = CLOSING_ANIMATION_FRAMES[closingAnimFrame]
	sprite:Play(frameInfo.anim, true)
	local scale = Vector(frameInfo.scaleX / 100, frameInfo.scaleY / 100)
	sprite.Scale = scale

	closingAnimFrame = closingAnimFrame + 1
	if closingAnimFrame > #CLOSING_ANIMATION_FRAMES then
		closingAnimFrame = nil

		chest:GetData().CloseChest = nil

		sprite:Play("Idle", true)
	end

	TSIL.Entities.SetEntityData(RuneRooms, chest, "ClosingAnimationTimer", closingAnimFrame)
end

---@param chest EntityPickup
local function TryClose(chest)
	local closingAnimFrame = TSIL.Entities.GetEntityData(RuneRooms, chest, "ClosingAnimationTimer")

	if closingAnimFrame then
		PlayClosingAnimation(chest)
	end
end

---@param chest EntityPickup
local function OnChestUpdate(chest)
	if chest.Variant == PickupVariant.PICKUP_ETERNALCHEST then
		return
	end
	TryClose(chest)
end

---@param pickup EntityPickup
function EhwazPositive:OnPickupUpdate(pickup)
	if not TSIL.Pickups.IsChest(pickup) then
		return
	end
	OnChestUpdate(pickup)
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, EhwazPositive.OnPickupUpdate)

---@param chest EntityPickup
function EhwazPositive:PreChestOpened(chest)
	if chest.Variant == PickupVariant.PICKUP_ETERNALCHEST then
		return
	end
	if chest:GetData().CloseChest then
		return false
	end
end
RuneRooms:AddPriorityCallback(ModCallbacks.MC_PRE_OPEN_CHEST, CallbackPriority.EARLY, EhwazPositive.PreChestOpened)

---@param chest EntityPickup
function EhwazPositive:OnChestOpened(chest)
	if chest.Variant == PickupVariant.PICKUP_ETERNALCHEST or chest:GetData().CloseChest then
		return
	end
	if not RuneRooms:IsPositiveEffectActive(RuneRooms.Enums.RuneEffect.INGWAZ) then
		return
	end
	local rng = chest:GetDropRNG()

	if rng:RandomFloat() >= CLOSE_CHANCE then
		return
	end

	Isaac.CreateTimer(function()
		SFXManager():Play(SoundEffect.SOUND_CHEST_DROP)
		TSIL.Entities.SetEntityData(RuneRooms, chest, "ClosingAnimationTimer", 1)
	end, TO_CLOSE_DURATION, 1, false)
	chest:GetData().CloseChest = true
	if chest.Variant == PickupVariant.PICKUP_MEGACHEST then
		local newSubtype = TSIL.Random.GetRandomInt(MIN_MEGA_CHEST_KEYS, MAX_MEGA_CHEST_KEYS, rng)
		chest.SubType = newSubtype
	else
		chest.SubType = 1
	end
end
RuneRooms:AddPriorityCallback(ModCallbacks.MC_POST_OPEN_CHEST, CallbackPriority.EARLY, EhwazPositive.OnChestOpened)
