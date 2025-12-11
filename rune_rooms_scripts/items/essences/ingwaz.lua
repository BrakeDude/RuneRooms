local IngwazEssence = {}

local EXTRA_KEY_CHANCE = 0.33
local PICKUP_MIN_SPAWN_SPEED = 5
local PICKUP_MAX_SPAWN_SPEED = 7

local IngwazItem = RuneRooms.Enums.Item.INGWAZ_ESSENCE


---@param rng RNG
---@return Vector
local function GetRandomPickupVelocity(rng)
    local angle = rng:RandomInt(360)
    local speed = TSIL.Random.GetRandomFloat(PICKUP_MIN_SPAWN_SPEED, PICKUP_MAX_SPAWN_SPEED, rng)
    return Vector.FromAngle(angle):Resized(speed)
end


---@type {chance: number, value: fun(position: Vector, rng: RNG)}[]
local POSSIBLE_EXTRA_PICKUPS = {
    -- 1-3 coins
    {chance = 25, value = function (position, rng)
        local coinNum = rng:RandomInt(3) + 1

        for _ = 1, coinNum, 1 do
            TSIL.EntitySpecific.SpawnPickup(
                PickupVariant.PICKUP_COIN,
                0,
                position,
                GetRandomPickupVelocity(rng)
            )
        end
    end},
    
    -- 1 heart
    {chance = 20, value = function (position, rng)
        TSIL.EntitySpecific.SpawnPickup(
            PickupVariant.PICKUP_HEART,
            0,
            position,
            GetRandomPickupVelocity(rng)
        )
    end},

    -- 1 key
    {chance = 10, value = function (position, rng)
        TSIL.EntitySpecific.SpawnPickup(
            PickupVariant.PICKUP_KEY,
            0,
            position,
            GetRandomPickupVelocity(rng)
        )
    end},

    -- 1 bomb
    {chance = 20, value = function (position, rng)
        TSIL.EntitySpecific.SpawnPickup(
            PickupVariant.PICKUP_BOMB,
            0,
            position,
            GetRandomPickupVelocity(rng)
        )
    end},

    -- 1 pill
    {chance = 5, value = function (position, rng)
        TSIL.EntitySpecific.SpawnPickup(
            PickupVariant.PICKUP_PILL,
            0,
            position,
            GetRandomPickupVelocity(rng)
        )
    end},

    -- 1 card or rune
    {chance = 5, value = function (position, rng)
        local itemPool = Game():GetItemPool()
        local card = itemPool:GetCard(
            rng:Next(),
            true,
            true,
            false
        )

        TSIL.EntitySpecific.SpawnPickup(
            PickupVariant.PICKUP_TAROTCARD,
            card,
            position,
            GetRandomPickupVelocity(rng)
        )
    end},

    -- 1 rune
    {chance = 5, value = function (position, rng)
        local itemPool = Game():GetItemPool()
        local card = itemPool:GetCard(
            rng:Next(),
            false,
            true,
            true
        )

        TSIL.EntitySpecific.SpawnPickup(
            PickupVariant.PICKUP_TAROTCARD,
            card,
            position,
            GetRandomPickupVelocity(rng)
        )
    end},

    -- 1 trinket
    {chance = 5, value = function (position, rng)
        TSIL.EntitySpecific.SpawnPickup(
            PickupVariant.PICKUP_TRINKET,
            0,
            position,
            GetRandomPickupVelocity(rng)
        )
    end},

    -- 1 lil' battery
    {chance = 5, value = function (position, rng)
        TSIL.EntitySpecific.SpawnPickup(
            PickupVariant.PICKUP_LIL_BATTERY,
            0,
            position,
            GetRandomPickupVelocity(rng)
        )
    end},
}

function IngwazEssence:PreEntitySpawn(type, variant, _, _, _, _, seed)
    if not PlayerManager.AnyoneHasCollectible(IngwazItem) then return end

    if type ~= EntityType.ENTITY_PICKUP then return end

    if variant == PickupVariant.PICKUP_LOCKEDCHEST then
        return {
            EntityType.ENTITY_PICKUP,
            PickupVariant.PICKUP_ETERNALCHEST,
            ChestSubType.CHEST_CLOSED,
            seed
        }
    elseif variant == PickupVariant.PICKUP_MIMICCHEST then
        return {
            EntityType.ENTITY_PICKUP,
            PickupVariant.PICKUP_CHEST,
            ChestSubType.CHEST_CLOSED,
            seed
        }
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_PRE_ENTITY_SPAWN,
    IngwazEssence.PreEntitySpawn
)


---@param rng RNG
---@param position Vector
local function SpawnExtraKey(rng, position)
    if rng:RandomFloat() >= EXTRA_KEY_CHANCE then return end

    TSIL.EntitySpecific.SpawnPickup(
        PickupVariant.PICKUP_KEY,
        KeySubType.KEY_NORMAL,
        position,
        GetRandomPickupVelocity(rng)
    )
end


---@param rng RNG
---@param position Vector
local function SpawnExtraPickups(rng, position)
    local pickupToSpawn = TSIL.Random.GetRandomElementFromWeightedList(rng, POSSIBLE_EXTRA_PICKUPS)

    pickupToSpawn(position, rng)
end


---@param chest EntityPickup
function IngwazEssence:OnChestOpened(chest)
    if not PlayerManager.AnyoneHasCollectible(IngwazItem) then return end

    local rng = chest:GetDropRNG()

    --Rusted key effect
    SpawnExtraKey(rng, chest.Position)

    --Gilded key effect
    if chest.Variant == chest.Variant then
        SpawnExtraPickups(rng, chest.Position)
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_OPEN_CHEST,
    IngwazEssence.OnChestOpened
)


---@param gridEntity GridEntity
function IngwazEssence:OnTintedRockBreak(gridEntity)
    if not PlayerManager.AnyoneHasCollectible(IngwazItem) then return end

    local rng = gridEntity:GetRNG()

    SpawnExtraKey(rng, gridEntity.Position)
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_GRID_ENTITY_BROKEN,
    IngwazEssence.OnTintedRockBreak,
    GridEntityType.GRID_ROCKT
)


---@param gridEntity GridEntity
function IngwazEssence:OnSuperTintedRockBreak(gridEntity)
    if not PlayerManager.AnyoneHasCollectible(IngwazItem) then return end

    local rng = gridEntity:GetRNG()

    SpawnExtraKey(rng, gridEntity.Position)

    SpawnExtraPickups(rng, gridEntity.Position)
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_GRID_ENTITY_BROKEN,
    IngwazEssence.OnSuperTintedRockBreak,
    GridEntityType.GRID_ROCK_SS
)


---@param slot Entity
function IngwazEssence:OnSlotBreak(slot)
    if not PlayerManager.AnyoneHasCollectible(IngwazItem) then return end

    local rng = slot:GetDropRNG()

    SpawnExtraKey(rng, slot.Position)
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_SLOT_DESTROYED,
    IngwazEssence.OnSlotBreak
)