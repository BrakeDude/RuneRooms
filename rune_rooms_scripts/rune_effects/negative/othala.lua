local OthalaNegative = {}


---@param player EntityPlayer
local function RerollHighestQualityItem(player)
    local roomDesc = TSIL.Rooms.GetRoomDescriptor()
    local rng = TSIL.RNG.NewRNG(roomDesc.SpawnSeed)

    local playerInventory = TSIL.Players.GetPlayerInventory(player, TSIL.Enums.InventoryType.COLLECTIBLE)
    if #playerInventory == 0 then return end

    local itemsPerQuality = {}
    local highestQuality = -1

    local itemConfig = RuneRooms.ItemConfig
    TSIL.Utils.Tables.ForEach(playerInventory, function (_, inventoryItem)
        local itemInfo = itemConfig:GetCollectible(inventoryItem.Id)

        local quality = itemInfo.Quality
        if quality > highestQuality then
            highestQuality = quality
        end

        if not itemsPerQuality[quality] then
            itemsPerQuality[quality] = {}
        end

        local itemsForQuality = itemsPerQuality[quality]
        itemsForQuality[#itemsForQuality+1] = inventoryItem.Id
    end)

    local highestQualityItems = itemsPerQuality[highestQuality]
    local itemToReroll = TSIL.Random.GetRandomElementsFromTable(highestQualityItems, 1, rng)[1]
    player:RemoveCollectible(itemToReroll)

    local collectibles = TSIL.Collectibles.GetCollectibles()
    local possibleCollectibles = TSIL.Utils.Tables.Filter(collectibles, function (_, itemInfo)
        return itemInfo:IsAvailable()                                       --Can't reroll into a locked item
        and not itemInfo:HasTags(TSIL.Enums.ItemConfigTag.QUEST)            --Can't reroll into a quest item
        and itemInfo.ID ~= itemToReroll                                     --Can't reroll into the same item
        and (itemInfo.Quality == 0 or itemInfo.Quality < highestQuality)    --Has to reroll into a lower quality
        and itemInfo.Type ~= ItemType.ITEM_ACTIVE                           --Can't reroll into an active item
    end)

    local newCollectible = TSIL.Random.GetRandomElementsFromTable(possibleCollectibles, 1, rng)[1]
    player:AddCollectible(newCollectible.ID)
end


function OthalaNegative:OnOthalaNegativeActivation()
    local players = PlayerManager.GetPlayers()
    TSIL.Utils.Tables.ForEach(players, function (_, player)
        RerollHighestQualityItem(player)
    end)
end
RuneRooms:AddCallback(
    RuneRooms.Enums.CustomCallback.POST_GAIN_RUNE_CURSE,
    OthalaNegative.OnOthalaNegativeActivation,
    RuneRooms.Enums.RuneEffect.OTHALA
)