local OthalaEssence = {}

local ITEM_DUPLICATION_CHANCE = 			0.2
local ITEM_DUPLICATION_CAP = 				0.75
local ITEM_DUPLICATION_CHANCE_PER_LUCK =	0.025

local OthalaItem = RuneRooms.Enums.Item.OTHALA_ESSENCE

---@param pickup EntityPickup
---@param collider Entity
---@param low boolean
function OthalaEssence:OnPedestalCollision(pickup, collider, low)
	if not PlayerManager.AnyoneHasCollectible(OthalaItem) then return end
	if pickup.SubType == 0 then return end
	local pData = RuneRooms:PickupSave(pickup, true)
	if pData.RR_OthalaCollectible then return end
	if pData.RR_OthalaChecked then return end
	local player = collider:ToPlayer()
	if player and player:HasCollectible(OthalaItem) and player:CanPickupItem() then
		local ID, pos = pickup.SubType, pickup.Position
		Isaac.CreateTimer(function ()
			if not pickup:Exists() then
				OthalaEssence:MarkChecked(pickup)
				if OthalaEssence:RollChance(player) then
					OthalaEssence:MakeOthalaPedestal(ID, pos)
				end
			elseif pickup.SubType == 0 then
				OthalaEssence:MarkChecked(pickup)
				if OthalaEssence:RollChance(player) then
					OthalaEssence:MakeOthalaPedestal(ID, pos, pickup)
				end
			end
		end, 1, 1, true)
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, OthalaEssence.OnPedestalCollision, PickupVariant.PICKUP_COLLECTIBLE)

--- Reroll support for the visuals of the pedestal
---@param pickup EntityPickup
function OthalaEssence:OnPedestalInit(pickup)
	local pData = RuneRooms:TryGetPickupSave(pickup, true)
	if pData and pData.RR_OthalaCollectible then
		pickup.Color = Color(1, 0, 1, 0.5)
		pickup.Timeout = 999999999
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, OthalaEssence.OnPedestalInit, PickupVariant.PICKUP_COLLECTIBLE)

---@param player EntityPlayer
---@return boolean
function OthalaEssence:RollChance(player)
	local luckBonus = player.Luck * ITEM_DUPLICATION_CHANCE_PER_LUCK
	local chance = math.min(ITEM_DUPLICATION_CHANCE + luckBonus, ITEM_DUPLICATION_CAP)
	local rng = player:GetCollectibleRNG(OthalaItem)
	return rng:RandomFloat() < chance
end

function OthalaEssence:MarkChecked(pickup)
	local pData = RuneRooms:PickupSave(pickup, true)
	pData.RR_OthalaChecked = true
end

---@param ID CollectibleType
---@param pos Vector
---@param pickup EntityPickup | nil
function OthalaEssence:MakeOthalaPedestal(ID, pos, pickup)
	if pickup then
		pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ID)
	else
		pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ID, pos, Vector.Zero, nil):ToPickup() ---@cast pickup EntityPickup
	end
	pickup.Color = Color(1, 0, 1, 0.5)
	pickup.Timeout = 999999999
	local pData = RuneRooms:PickupSave(pickup, true)
	pData.RR_OthalaCollectible = true
end