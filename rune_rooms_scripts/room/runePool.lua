local RunePool = {}
local itemPool = RuneRooms.ItemPool

function RunePool:PreGetCollectible(pool, decrease, seed)
    if RuneRooms.API:IsRuneRoom() and not PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CHAOS) then
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
    if RuneRooms.API:IsRuneRoom() then
        RuneRooms.Room():SetItemPool(RuneRooms.Enums.ItemPool.RUNE_ROOM_POOL)
    end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, RunePool.SetRoomPool)