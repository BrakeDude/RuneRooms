local GiantRuneCrystal = {}

local RUNE_SYMBOL_SPRITESHEET = "gfx/grid/rune_symbol_"

local RUNE_PARTICLES = {
    MinNum = 10,
    MaxNum = 20,
    MinPosOffset = 0,
    MaxPosOffset = 10,
    MinSpeed = 5,
    MaxSpeed = 7,
    Color = Color(1, 1, 1, 0.7, 0.1, 0, 0.2)
}
local RUNE_SHARDS = {
    MinNum = 1,
    MaxNum = 2,
    MinSpeed = 6,
    MaxSpeed = 8
}
local CRYSTAL_EXPLOSION_DARKEN = {
    Intensity = 0.8,
    Duration = 8 * 30,
}
local CRYSTAL_EXPLOSION_SHOCKWAVE = {
    Amplitude = 0.04,
    Speed = 0.013,
    Duration = 4 * 30
}


TSIL.SaveManager.AddPersistentVariable(
    RuneRooms,
    RuneRooms.Enums.SaveKey.GIANT_CRYSTAL_DATA,
    {},
    TSIL.Enums.VariablePersistenceMode.RESET_LEVEL
)


---@param giantCrystal Entity
local function GetGiantCrystalData(giantCrystal)
    local crystalsData = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.GIANT_CRYSTAL_DATA
    )
    local crystalIndex = RuneRooms.Helpers:GetCustomGridIndex(giantCrystal)

    if not crystalsData[crystalIndex] then
        crystalsData[crystalIndex] = {
            breakState = 1,
            activated = false
        }
    end

    return crystalsData[crystalIndex]
end


---@param giantCrystal Entity
---@return boolean
function RuneRooms:IsGiantRuneCrystalBroken(giantCrystal)
    local data = GetGiantCrystalData(giantCrystal)
    return data.breakState >= 5
end


---@param position Vector
---@param multiplier number
local function SpawnRuneParticles(position, multiplier)
    local rng = TSIL.RNG.NewRNG()

    local numParticles = TSIL.Random.GetRandomInt(RUNE_PARTICLES.MinNum, RUNE_PARTICLES.MinNum, rng)
    numParticles = math.floor(numParticles * multiplier)

    for _ = 1, numParticles, 1 do
        local angle = rng:RandomInt(360)

        local offsetDistance = TSIL.Random.GetRandomFloat(RUNE_PARTICLES.MinPosOffset, RUNE_PARTICLES.MaxPosOffset, rng)
        local posOffset = Vector.FromAngle(angle):Resized(offsetDistance)
        local spawningPos = position + posOffset

        local speed = TSIL.Random.GetRandomFloat(RUNE_PARTICLES.MinSpeed, RUNE_PARTICLES.MaxSpeed, rng)
        local spawningVel = Vector.FromAngle(angle):Resized(speed)

        local particle = TSIL.EntitySpecific.SpawnEffect(
            EffectVariant.TOOTH_PARTICLE,
            0,
            spawningPos,
            spawningVel
        )
        particle.Color = RUNE_PARTICLES.Color
    end
end

---@param giantCrystal Entity
local function SpawnRuneShards(giantCrystal)
    local rng = giantCrystal:GetDropRNG()

    local numShards = TSIL.Random.GetRandomInt(
        RUNE_SHARDS.MinNum,
        RUNE_SHARDS.MaxNum,
        rng
    )

    for _ = 1, numShards, 1 do
        local angle = rng:RandomInt(360)
        local speed = TSIL.Random.GetRandomFloat(
            RUNE_SHARDS.MinSpeed,
            RUNE_SHARDS.MaxSpeed,
            rng
        )
        local velocity = Vector.FromAngle(angle):Resized(speed)

        TSIL.EntitySpecific.SpawnPickup(
            PickupVariant.PICKUP_TAROTCARD,
            Card.RUNE_SHARD,
            giantCrystal.Position,
            velocity
        )
    end
end


---@param giantCrystal Entity
function RuneRooms:DealDamageToGiantCrystal(giantCrystal)
    local data = GetGiantCrystalData(giantCrystal)
    if data.activated then return end
    if data.breakState >= 5 then return end
    data.breakState = data.breakState + 2

    local sprite = giantCrystal:GetSprite()

    if data.breakState < 5 then
        local frame = sprite:GetFrame()
        sprite:Play("State" .. data.breakState .. "Symbol", true)
        sprite:SetFrame(frame)

        SFXManager():Play(RuneRooms.Enums.SoundEffect.RUNE_CRYSTAL_EXPLOSION)

        SpawnRuneParticles(giantCrystal.Position, 1)

        SpawnRuneShards(giantCrystal)
    else
        data.breakState = 5
        sprite:Play("State5", true)
        giantCrystal.SortingLayer = SortingLayer.SORTING_BACKGROUND
        giantCrystal.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

        SFXManager():Play(SoundEffect.SOUND_MIRROR_BREAK)
        Game():Darken(
            CRYSTAL_EXPLOSION_DARKEN.Intensity,
            CRYSTAL_EXPLOSION_DARKEN.Duration
        )
        Game():MakeShockwave(
            giantCrystal.Position,
            CRYSTAL_EXPLOSION_SHOCKWAVE.Amplitude,
            CRYSTAL_EXPLOSION_SHOCKWAVE.Speed,
            CRYSTAL_EXPLOSION_SHOCKWAVE.Duration
        )
        Game():ShakeScreen(20)

        SpawnRuneParticles(giantCrystal.Position, 4)

        local runeEffect = RuneRooms:GetRuneEffectForFloor()
        RuneRooms:ActivateNegativeEffect(runeEffect)

        local essence = RuneRooms.Constants.ESSENCE_ITEM_PER_RUNE[runeEffect]
        TSIL.EntitySpecific.SpawnPickup(
            PickupVariant.PICKUP_COLLECTIBLE,
            essence,
            giantCrystal.Position
        )

        Isaac.RunCallback(
            RuneRooms.Enums.CustomCallback.POST_GIANT_RUNE_CRYSTAL_DESTROYED,
            giantCrystal
        )
    end
end


---@param giantCrystal Entity
function RuneRooms:ActivateGiantCrystal(giantCrystal)
    local data = GetGiantCrystalData(giantCrystal)

    if data.breakState >= 5 then return end
    if data.activated then return end

    data.activated = true
    local sprite = giantCrystal:GetSprite()
    sprite:Play("ActivateStart", true)

end


---@param giantCrystal Entity
function GiantRuneCrystal:OnGiantCrystalInit(giantCrystal)
    local data = GetGiantCrystalData(giantCrystal)
    local runeEffect = RuneRooms:GetRuneEffectForFloor()

    local sprite = giantCrystal:GetSprite()
    local runeSpriteSheet = RUNE_SYMBOL_SPRITESHEET .. RuneRooms.Constants.RUNE_NAMES[runeEffect] .. ".png"
    sprite:ReplaceSpritesheet(2, runeSpriteSheet)
    sprite:LoadGraphics()

    if data.activated then
        sprite:Play("ActivateLoop", true)
    elseif data.breakState < 5 then
        sprite:Play("State" .. data.breakState .. "Symbol", true)
    else
        sprite:Play("State5", true)
        giantCrystal.SortingLayer = SortingLayer.SORTING_BACKGROUND
        giantCrystal.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    end
end
RuneRooms:AddCallback(
    RuneRooms.Enums.CustomCallback.POST_GENERIC_PROP_INIT,
    GiantRuneCrystal.OnGiantCrystalInit,
    RuneRooms.Enums.GenericPropVariant.GIANT_RUNE_CRYSTAL
)


---@param giantCrystal Entity
function GiantRuneCrystal:OnGiantCrystalUpdate(giantCrystal)
    local sprite = giantCrystal:GetSprite()

    if sprite:IsFinished("ActivateStart") then
        sprite:Play("ActivateLoop", true)

        local runeEffect = RuneRooms:GetRuneEffectForFloor()
        RuneRooms:ActivatePositiveEffect(runeEffect)
        Game():ShakeScreen(20)
    end
end
RuneRooms:AddCallback(
    RuneRooms.Enums.CustomCallback.POST_GENERIC_PROP_UPDATE,
    GiantRuneCrystal.OnGiantCrystalUpdate,
    RuneRooms.Enums.GenericPropVariant.GIANT_RUNE_CRYSTAL
)

---@param entity Entity
---@param damage number
---@param flags DamageFlag | number
---@param source EntityRef
---@param cd number
---@return boolean | nil?
function GiantRuneCrystal:OnExplosionDamage(entity, damage, flags, source, cd)
    if entity.Variant == RuneRooms.Enums.GenericPropVariant.GIANT_RUNE_CRYSTAL then
        if (flags & DamageFlag.DAMAGE_EXPLOSION > 0 or flags & DamageFlag.DAMAGE_CRUSH > 0) then
            RuneRooms:DealDamageToGiantCrystal(entity)
        end
        return false
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    GiantRuneCrystal.OnExplosionDamage,
    EntityType.ENTITY_GENERIC_PROP
)