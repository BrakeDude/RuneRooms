local PerthroEssence = {}

local MAX_GET_ITEM_ATTEMPTS = 400

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


---@param item CollectibleType
---@return integer
local function GetItemQuality(item)
    local itemConfig = Isaac.GetItemConfig()
    local itemInfo = itemConfig:GetCollectible(item)
    return itemInfo.Quality
end


---@param collectible EntityPickup
---@param collectibleInfo any
local function TryRerollIntoHigherQuality(collectible, collectibleInfo)
    local currentItem = collectible.SubType
    local previousItem = collectibleInfo.PreviousItem

    if currentItem == CollectibleType.COLLECTIBLE_NULL
    or previousItem == CollectibleType.COLLECTIBLE_NULL then
        return
    end

    local currentQuality = GetItemQuality(currentItem)
    local previousQuality = GetItemQuality(previousItem)

    if currentQuality >= previousQuality then return end

    local itemPool = Game():GetItemPool()

    local room = Game():GetRoom()
    local roomType = room:GetType()
    local itemPoolType = itemPool:GetPoolForRoom(roomType, room:GetSpawnSeed())
    if itemPoolType == -1 then
        if TSIL.Run.IsGreedMode() then
            itemPoolType = ItemPoolType.POOL_GREED_TREASURE
        else
            itemPoolType = ItemPoolType.POOL_TREASURE
        end
    end

    local rng = TSIL.RNG.NewRNG(collectible.InitSeed)

    for _ = 1, MAX_GET_ITEM_ATTEMPTS, 1 do
        local newItem = itemPool:GetCollectible(
            itemPoolType,
            false,
            rng:Next(),
            CollectibleType.COLLECTIBLE_NULL
        )

        if newItem == CollectibleType.COLLECTIBLE_NULL then
            break
        end

        local newQuality = GetItemQuality(newItem)

        if newQuality >= previousQuality then
            itemPool:RemoveCollectible(newItem)

            collectible:Morph(
                EntityType.ENTITY_PICKUP,
                PickupVariant.PICKUP_COLLECTIBLE,
                newItem,
                false,
                true
            )
            break
        end
    end
end


local function TryRerollAllCollectibles()
    local collectibleInfos = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.COLLECTIBLE_INFOS_PERTHRO
    )

    local collectibles = TSIL.EntitySpecific.GetPickups(PickupVariant.PICKUP_COLLECTIBLE)

    for _, collectible in ipairs(collectibles) do
        local collectibleIndex = TSIL.Pickups.GetPickupIndex(collectible)

        local collectibleInfo = collectibleInfos[collectibleIndex]

        if collectibleInfo ~= nil then
            TryRerollIntoHigherQuality(collectible, collectibleInfo)
        end
    end
end


---@param collectible EntityPickup
function PerthroEssence:OnCollectibleUpdate(collectible)
    local collectibleIndex = TSIL.Pickups.GetPickupIndex(collectible)

    local collectibleInfos = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.COLLECTIBLE_INFOS_PERTHRO
    )

    local hasActivated4Pip = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.ACTIVATED_4_PIP_DICE_ROOM
    )

    if hasActivated4Pip
    and collectibleInfos[collectibleIndex]
    and not collectibleInfos[collectibleIndex].RerolledAfter4Pip then
        TryRerollIntoHigherQuality(collectible, collectibleInfos[collectibleIndex])
    end

    collectibleInfos[collectibleIndex] = {
        PreviousItem = collectible.SubType,
        RerolledAfter4Pip = true
    }
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_PICKUP_UPDATE,
    PerthroEssence.OnCollectibleUpdate,
    PickupVariant.PICKUP_COLLECTIBLE
)


---@param player EntityPlayer
function PerthroEssence:OnD6Use(_, _, player)
    if not player:HasCollectible(PerthroItem) then return end

    TryRerollAllCollectibles()
end
RuneRooms:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    PerthroEssence.OnD6Use,
    CollectibleType.COLLECTIBLE_D6
)


---@param player EntityPlayer
function PerthroEssence:OnFourPipDiceFloorActivation(player)
    if not player:HasCollectible(PerthroItem) then return end

    TryRerollAllCollectibles()

    local collectibles = TSIL.EntitySpecific.GetPickups(PickupVariant.PICKUP_COLLECTIBLE)
    local collectibleIndexes = {}

    for _, collectible in ipairs(collectibles) do
        local collectibleIndex = TSIL.Pickups.GetPickupIndex(collectible)
        collectibleIndexes[collectibleIndex] = true
    end

    local collectibleInfos = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.COLLECTIBLE_INFOS_PERTHRO
    )
    for collectibleIndex, collectibleInfo in pairs(collectibleInfos) do
        if not collectibleIndexes[collectibleIndex] then
            collectibleInfo.RerolledAfter4Pip = false
        end
    end

    TSIL.SaveManager.SetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.ACTIVATED_4_PIP_DICE_ROOM,
        true
    )
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_DICE_ROOM_ACTIVATED,
    PerthroEssence.OnFourPipDiceFloorActivation,
    TSIL.Enums.DiceFloorSubType.FOUR_PIP
)