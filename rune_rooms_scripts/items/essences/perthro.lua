local PerthroEssence = {}

local PerthroItem = RuneRooms.Enums.Item.PERTHRO_ESSENCE

local function GetEssencePerthroData(collectible)
	local collectibleInfo = RuneRooms:PickupSave(collectible, true)
	if not collectibleInfo.EssencePerthroData then
		collectibleInfo.EssencePerthroData = {
			CycleChance = 25,
			RerolledAfter4Pip = false
		}
	end
	return collectibleInfo.EssencePerthroData
end

---@param collectible EntityPickup
---@param collectibleInfo table
local function TryAddItemCycling(collectible, collectibleInfo)
	if collectible.SubType == CollectibleType.COLLECTIBLE_NULL then
		return false
	end
	local rng = collectible:GetDropRNG()
	local room = RuneRooms.Room()
	local itemPool = RuneRooms.ItemPool
	local itemPoolType = room:GetItemPool(rng:Next())
	if itemPoolType < 0 then
		if RuneRooms.Game:IsGreedMode() then
			itemPoolType = ItemPoolType.POOL_GREED_TREASURE
		else
			itemPoolType = ItemPoolType.POOL_TREASURE
		end
	end

	local chance = collectibleInfo.CycleChance
	if rng:RandomInt(1, 100) <= chance then
		local newItem =
			itemPool:GetCollectible(itemPoolType, true, collectible.InitSeed, CollectibleType.COLLECTIBLE_BREAKFAST)

		collectible:AddCollectibleCycle(newItem)
		collectibleInfo.CycleChance = 25
		return true
	else
		collectibleInfo.CycleChance = chance + 25
		return false
	end
end

local function TryAddItemsCycling()
	local collectibles = TSIL.EntitySpecific.GetPickups(PickupVariant.PICKUP_COLLECTIBLE)

	for _, collectible in ipairs(collectibles) do
		TryAddItemCycling(collectible, GetEssencePerthroData(collectible))
	end
end

---@param collectible EntityPickup
function PerthroEssence:OnCollectibleInit(collectible)
	if not PlayerManager.AnyoneHasCollectible(PerthroItem) then
		return
	end
	local collectibleInfo = RuneRooms:PickupSave(collectible, true)
	if not collectibleInfo.EssencePerthroData then
		GetEssencePerthroData(collectible)
		
		TryAddItemCycling(collectible, collectibleInfo)
	end
end
RuneRooms:AddCallback(
	TSIL.Enums.CustomCallback.POST_PICKUP_INIT_FIRST,
	PerthroEssence.OnCollectibleInit,
	PickupVariant.PICKUP_COLLECTIBLE
)

---@param collectible EntityPickup
function PerthroEssence:OnCollectibleUpdate(collectible)

	local collectibleInfo = GetEssencePerthroData(collectible)

	local hasActivated4Pip = RuneRooms:FloorSave().Activated4Pip

	if
		hasActivated4Pip
		and collectibleInfo
		and not collectibleInfo.RerolledAfter4Pip
	then
		TryAddItemCycling(collectible, collectibleInfo)
		collectibleInfo.RerolledAfter4Pip = true
	end
end
RuneRooms:AddCallback(
	ModCallbacks.MC_POST_PICKUP_UPDATE,
	PerthroEssence.OnCollectibleUpdate,
	PickupVariant.PICKUP_COLLECTIBLE
)

---@param player EntityPlayer
function PerthroEssence:OnD6Use(_, _, player)
	if not player:HasCollectible(PerthroItem) then
		return
	end

	TryAddItemsCycling()
end
RuneRooms:AddCallback(ModCallbacks.MC_USE_ITEM, PerthroEssence.OnD6Use, CollectibleType.COLLECTIBLE_D6)

---@param player EntityPlayer
function PerthroEssence:OnFourPipDiceFloorActivation(player)
	if not player:HasCollectible(PerthroItem) then
		return
	end
	TryAddItemsCycling()

	RuneRooms:FloorSave().Activated4Pip = true
end
RuneRooms:AddCallback(
	TSIL.Enums.CustomCallback.POST_DICE_ROOM_ACTIVATED,
	PerthroEssence.OnFourPipDiceFloorActivation,
	TSIL.Enums.DiceFloorSubType.FOUR_PIP
)
