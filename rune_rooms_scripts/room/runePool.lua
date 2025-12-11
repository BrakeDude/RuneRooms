local RunePool = {}
local itemPool = Game():GetItemPool()

function RunePool:PreGetCollectible(pool, decrease, seed)
    if RuneRooms.Helpers:IsRuneRoom() and not PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CHAOS) then
        local newItem = itemPool:PickCollectible(RuneRooms.Enums.ItemPool.RUNE_ROOM_POOL, decrease, RNG(seed))
        if newItem ~= nil then
            return newItem.itemID
        end
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_PRE_GET_COLLECTIBLE,
    RunePool.PreGetCollectible
)

function RunePool:SetRoomPool()
    if RuneRooms.Helpers:IsRuneRoom() then
        Game():GetRoom():SetItemPool(RuneRooms.Enums.ItemPool.RUNE_ROOM_POOL)
    end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, RunePool.SetRoomPool)