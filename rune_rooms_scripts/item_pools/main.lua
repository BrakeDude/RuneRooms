---Adds any number of collectibles to the rune item pool.
---@param collectibles PoolItems[]
function RuneRooms.API:AddCollectiblesToRuneItemPool(collectibles)
    Game():GetItemPool():AddCollectible(RuneRooms.Enums.ItemPool.RUNE_ROOM_POOL, collectibles)
end