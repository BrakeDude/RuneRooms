local SowiloEssence = {}

local FRIENDLY_ENEMY_RESPAWN_CHANCE = 0.5
local SowiloItem = RuneRooms.Enums.Item.SOWILO_ESSENCE

---@param npc EntityNPC
---@return boolean
local function CanSpawnFriendlyVersion(npc)
    return not npc:IsBoss()     --Can't spawn a friendly boss
    and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_FRIENDLY_BALL) --Can't be friendly
end

---@param npc EntityNPC
local function CheckForLastEnemyKilled(npc)
    if not CanSpawnFriendlyVersion(npc) then return end

    local rng = TSIL.RNG.NewRNG(npc.InitSeed)

    if rng:RandomFloat() >= FRIENDLY_ENEMY_RESPAWN_CHANCE then return end

    local enemyInfo = {
        type = npc.Type,
        variant = npc.Variant,
        subtype = npc.SubType,
        positionX = npc.Position.X,
        positionY = npc.Position.Y
    }

    RuneRooms:TempSave().LastKilledEnemy = enemyInfo
end

---@param rng RNG
---@return Vector
local function GetRandomVelocity(rng)
    local angle = rng:RandomInt(360)
    local speed = TSIL.Random.GetRandomFloat(5, 7, rng)
    return Vector.FromAngle(angle):Resized(speed)
end

---@param entity Entity
---@param damage number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function SowiloEssence:FriendlyNPCDeath(entity, damage, flags, source, countdown)
    if not PlayerManager.AnyoneHasCollectible(SowiloItem) then return end
    if entity and entity:ToNPC() and entity:HasMortalDamage() and not entity:IsBoss() then
        if entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
            SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
            Game():ShakeScreen(15)
            for _, otherEntity in ipairs(Isaac.GetRoomEntities()) do
                local npc = otherEntity:ToNPC()
                if npc and npc:IsActiveEnemy() and npc:IsVulnerableEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 0, npc.Position, Vector.Zero, npc)
                    poof.Color = Color(0.1, 0.1, 0.1)
                    for _ = 1, 4, 1 do
                        local speed = GetRandomVelocity(entity:GetDropRNG())
                        local bloodParticle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, npc.Position, speed, npc)
                        bloodParticle.Color = Color(0.1, 0.1, 0.1)
                    end
                    npc:TakeDamage(entity.MaxHitPoints * PlayerManager.GetNumCollectibles(SowiloItem), 0, EntityRef(entity), 0)
                end
            end
        end
    end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, SowiloEssence.FriendlyNPCDeath)

---@param npc EntityNPC
function SowiloEssence:OnNPCDeath(npc)
    CheckForLastEnemyKilled(npc)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    SowiloEssence.OnNPCDeath
)

function SowiloEssence:OnRoomClear()
    if not PlayerManager.AnyoneHasCollectible(SowiloItem) then return end

    local roomData = RuneRooms:TempSave()
    local lastKilledEnemy = roomData.LastKilledEnemy
    if not lastKilledEnemy or not lastKilledEnemy.type then return end

    local enemy = TSIL.Entities.Spawn(
        lastKilledEnemy.type,
        lastKilledEnemy.variant,
        lastKilledEnemy.subtype,
        Vector(lastKilledEnemy.positionX, lastKilledEnemy.positionY)
    )
    enemy:AddEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_PERSISTENT)

    roomData.LastKilledEnemy = nil
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR,
    SowiloEssence.OnRoomClear
)