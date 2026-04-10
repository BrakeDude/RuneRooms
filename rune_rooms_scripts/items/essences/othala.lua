local OthalaEssence = {}

local ITEM_DUPLICATION_CHANCE = 0.2
local OthalaItem = RuneRooms.Enums.Item.OTHALA_ESSENCE
local itemPool = Game():GetItemPool()

local AvoidRecursion = {}

---@param item CollectibleType
---@param charge integer
---@param firstTime boolean
---@param slot ActiveSlot
---@param varData integer
---@param player EntityPlayer
function OthalaEssence:OnItemPickup(item, charge, firstTime, slot, varData, player)
    if item == OthalaItem or TSIL.Collectibles.CollectibleHasFlag(item, ItemConfig.TAG_QUEST)
    or not firstTime or not TSIL.Collectibles.IsPassiveCollectible(item) or not player:HasCollectible(OthalaItem) then
		return
	end
    local index = TSIL.Players.GetPlayerIndex(player)
	if AvoidRecursion[index] == item then
		AvoidRecursion[index] = nil
		return
	end

	local rng = player:GetCollectibleRNG(OthalaItem)
	if rng:RandomFloat() >= ITEM_DUPLICATION_CHANCE then
		return
	end

	AvoidRecursion[index] = item
	player:AddCollectible(item)
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, OthalaEssence.OnItemPickup)
