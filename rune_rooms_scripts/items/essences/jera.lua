local JeraEssence = {}

local PICKUP_RESPAWN_CHANCE = 0.20
local PICKUP_RESPAWN_CHANCE_PER_LUCK = 0.01
local PICKUP_RESPAWN_CHANCE_MAX = 0.50
local PICKUP_VARIANT_CHANCE = 1
local NO_RESPAWN_PICKUPS = {
    [PickupVariant.PICKUP_BROKEN_SHOVEL] = true,
    [PickupVariant.PICKUP_BED] = true,
    [PickupVariant.PICKUP_COLLECTIBLE] = true,
    [PickupVariant.PICKUP_ETERNALCHEST] = true,
    [PickupVariant.PICKUP_MOMSCHEST] = true,
    [PickupVariant.PICKUP_PILL] = true,
    [PickupVariant.PICKUP_SHOPITEM] = true,
    [PickupVariant.PICKUP_TAROTCARD] = true,
    [PickupVariant.PICKUP_THROWABLEBOMB] = true,
    [PickupVariant.PICKUP_TRINKET] = true,
    [PickupVariant.PICKUP_TROPHY] = true
}

local JeraItem = RuneRooms.Enums.Item.JERA_ESSENCE


---Forbids a pickup from respawning with the Essence of Jera effect.
---@param pickupVariant PickupVariant | integer
function RuneRooms.API:ForbidPickupFromRespawning(pickupVariant)
    NO_RESPAWN_PICKUPS[pickupVariant] = true
end

---@param pickup EntityPickup
function JeraEssence:OnPickupCollect(pickup)
    if not PlayerManager.AnyoneHasCollectible(JeraItem) then return end
    if NO_RESPAWN_PICKUPS[pickup.Variant] then return end

    local collectibleNum = PlayerManager.GetNumCollectibles(JeraItem)
    local luckBonus = 0
    for _, player in ipairs(PlayerManager.GetPlayers()) do
        if player:HasCollectible(JeraItem) then
            luckBonus = luckBonus + player.Luck
        end
    end

    local rng = TSIL.RNG.NewRNG(pickup.InitSeed)
    local pickupChance = math.min(PICKUP_RESPAWN_CHANCE + (PICKUP_RESPAWN_CHANCE_PER_LUCK * luckBonus), PICKUP_RESPAWN_CHANCE_MAX)
    for _ = 1, collectibleNum do
        if rng:RandomFloat() <= pickupChance then

            local newSubtype = pickup.SubType
            if rng:RandomFloat() < PICKUP_VARIANT_CHANCE then
                --A subtype of 0 makes it so a random variant spawns
                newSubtype = 0
            end

            local spawnPos = RuneRooms.Helpers:GetRandomPositionInRoom(false, false, rng)
            TSIL.EntitySpecific.SpawnPickup(
                pickup.Variant,
                newSubtype,
                spawnPos
            )
        end
    end
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_PICKUP_COLLECT,
    JeraEssence.OnPickupCollect
)


---@param chest EntityPickup
function JeraEssence:OnChestOpen(chest)
    if not PlayerManager.AnyoneHasCollectible(JeraItem) then return end
    if NO_RESPAWN_PICKUPS[chest.Variant] then return end

    local rng = TSIL.RNG.NewRNG(chest.InitSeed)
    if rng:RandomFloat() >= PICKUP_RESPAWN_CHANCE then return end

    if RuneRooms:WillChestClose(chest) then return end

    local spawnPos = RuneRooms.Helpers:GetRandomPositionInRoom(false, false, rng)
    TSIL.EntitySpecific.SpawnPickup(
        chest.Variant,
        ChestSubType.CHEST_CLOSED,
        spawnPos
    )
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_OPEN_CHEST,
    JeraEssence.OnChestOpen
)