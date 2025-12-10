local RunePool = {}
local itemPool = Game():GetItemPool()

function RunePool:PreGetCollectible(pool, decrease, seed)
    if RuneRooms.Helpers:IsRuneRoom() then 
        local newItem = itemPool:GetCollectible(RuneRooms.Enums.ItemPool.RUNE_ROOM_POOL, decrease, seed)

        if newItem ~= CollectibleType.COLLECTIBLE_NULL then
            return newItem
        end
    end
end
--[[RuneRooms:AddCallback(
    ModCallbacks.MC_PRE_GET_COLLECTIBLE,
    RunePool.PreGetCollectible
)]]

function RunePool:SetRoomPool()
    if RuneRooms.Helpers:IsRuneRoom() then
        Game():GetRoom():SetItemPool(RuneRooms.Enums.ItemPool.RUNE_ROOM_POOL)
    end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, RunePool.SetRoomPool)