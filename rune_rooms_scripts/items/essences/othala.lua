local OthalaEssence = {}

local ITEM_DUPLICATION_CHANCE = 0.2
local OthalaItem = RuneRooms.Enums.Item.OTHALA_ESSENCE
local itemPool = Game():GetItemPool()

---@param player EntityPlayer
---@param firstTime boolean
function OthalaEssence:OnOthalaEssencePickup(player, _, firstTime)
    if player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B and not firstTime then return end

    local rng = player:GetCollectibleRNG(OthalaItem)
    local item = itemPool:GetCollectible(RuneRooms.Enums.ItemPool.RUNE_ROOM_POOL, true, rng:GetSeed())

    if item == CollectibleType.COLLECTIBLE_NULL then return end

    local room = Game():GetRoom()
    local pos = room:FindFreePickupSpawnPosition(player.Position, 1, true)

    TSIL.EntitySpecific.SpawnPickup(
        PickupVariant.PICKUP_COLLECTIBLE,
        item,
        pos
    )
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_PLAYER_COLLECTIBLE_ADDED,
    OthalaEssence.OnOthalaEssencePickup,
    {
        nil,
        nil,
        OthalaItem
    }
)


local AvoidRecursion = {}


---@param item CollectibleType
---@param charge integer
---@param firstTime boolean
---@param slot ActiveSlot
---@param varData integer
---@param player EntityPlayer
function OthalaEssence:OnItemPickup(item, charge, firstTime, slot, varData, player)
    local index = TSIL.Players.GetPlayerIndex(player)
    if AvoidRecursion[index] == item then
        AvoidRecursion[index] = nil
        return
    end

    if not player:HasCollectible(OthalaItem) then return end
    if player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B and not firstTime then return end
    if TSIL.Collectibles.CollectibleHasFlag(item, ItemConfig.TAG_QUEST) then return end
    if not TSIL.Collectibles.IsPassiveCollectible(item) then return end
    if item == OthalaItem then return end

    local rng = player:GetCollectibleRNG(OthalaItem)
    if rng:RandomFloat() >= ITEM_DUPLICATION_CHANCE then return end

    AvoidRecursion[index] = item
    player:AddCollectible(item)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_ADD_COLLECTIBLE,
    OthalaEssence.OnItemPickup
)