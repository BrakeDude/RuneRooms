local PerthroEssence = {}

local PerthroItem = RuneRooms.Enums.Item.PERTHRO_ESSENCE

TSIL.SaveManager.AddPersistentVariable(
	RuneRooms,
	RuneRooms.Enums.SaveKey.COLLECTIBLE_INFOS_PERTHRO,
	{},
	TSIL.Enums.VariablePersistenceMode.RESET_LEVEL
)
TSIL.SaveManager.AddPersistentVariable(
	RuneRooms,
	RuneRooms.Enums.SaveKey.ACTIVATED_4_PIP_DICE_ROOM,
	false,
	TSIL.Enums.VariablePersistenceMode.RESET_LEVEL
)

---@param collectible EntityPickup
---@param collectibleInfo table
local function TryAddItemCycling(collectible, collectibleInfo)
	if collectible.SubType == CollectibleType.COLLECTIBLE_NULL then
		return false
	end
	local rng = collectible:GetDropRNG()
	local room = Game():GetRoom()
	local itemPool = Game():GetItemPool()
	local itemPoolType = room:GetItemPool(rng:Next())

	local chance = collectibleInfo.CycleChance or 25
	print("ID: " .. collectible.SubType .. ", Chance: " .. chance)
	if rng:RandomInt(1, 100) <= chance then
		print("ID: " .. collectible.SubType .. " Success.")
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
	local collectibleInfos =
		TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.COLLECTIBLE_INFOS_PERTHRO)

	local collectibles = TSIL.EntitySpecific.GetPickups(PickupVariant.PICKUP_COLLECTIBLE)

	for _, collectible in ipairs(collectibles) do
		local collectibleIndex = TSIL.Pickups.GetPickupIndex(collectible)

		local collectibleInfo = collectibleInfos[collectibleIndex]

		if collectibleInfo ~= nil then
			TryAddItemCycling(collectible, collectibleInfo)
		end
	end
end

---@param collectible EntityPickup
function PerthroEssence:OnCollectibleInit(collectible)
	if not PlayerManager.AnyoneHasCollectible(PerthroItem) then
		return
	end
	local collectibleInfos =
		TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.COLLECTIBLE_INFOS_PERTHRO)
	local collectibleIndex = TSIL.Pickups.GetPickupIndex(collectible)
	if not collectibleInfos[collectibleIndex] then
		collectibleInfos[collectibleIndex] = {
			RerolledAfter4Pip = true,
			CyclingChance = 25,
		}
        TryAddItemCycling(collectible, collectibleInfos[collectibleIndex])
	end
end
RuneRooms:AddCallback(
	TSIL.Enums.CustomCallback.POST_PICKUP_INIT_FIRST,
	PerthroEssence.OnCollectibleInit,
	PickupVariant.PICKUP_COLLECTIBLE
)

---@param collectible EntityPickup
function PerthroEssence:OnCollectibleUpdate(collectible)
	local collectibleIndex = TSIL.Pickups.GetPickupIndex(collectible)

	local collectibleInfos =
		TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.COLLECTIBLE_INFOS_PERTHRO)

	local hasActivated4Pip =
		TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.ACTIVATED_4_PIP_DICE_ROOM)

	if
		hasActivated4Pip
		and collectibleInfos[collectibleIndex]
		and not collectibleInfos[collectibleIndex].RerolledAfter4Pip
	then
		TryAddItemCycling(collectible, collectibleInfos[collectibleIndex])
	end
	if collectibleInfos[collectibleIndex] then
		collectibleInfos[collectibleIndex].RerolledAfter4Pip = true
	else
		collectibleInfos[collectibleIndex] = {
			RerolledAfter4Pip = true,
			CyclingChance = 25,
		}
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

	local collectibles = TSIL.EntitySpecific.GetPickups(PickupVariant.PICKUP_COLLECTIBLE)
	local collectibleIndexes = {}

	for _, collectible in ipairs(collectibles) do
		local collectibleIndex = TSIL.Pickups.GetPickupIndex(collectible)
		collectibleIndexes[collectibleIndex] = true
	end

	local collectibleInfos =
		TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.COLLECTIBLE_INFOS_PERTHRO)
	for collectibleIndex, collectibleInfo in pairs(collectibleInfos) do
		if not collectibleIndexes[collectibleIndex] then
			collectibleInfo.RerolledAfter4Pip = false
			collectibleInfo.CycleChance = 25
		end
	end

	TSIL.SaveManager.SetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.ACTIVATED_4_PIP_DICE_ROOM, true)
end
RuneRooms:AddCallback(
	TSIL.Enums.CustomCallback.POST_DICE_ROOM_ACTIVATED,
	PerthroEssence.OnFourPipDiceFloorActivation,
	TSIL.Enums.DiceFloorSubType.FOUR_PIP
)
