local SowiloEssence = {}

local FRIENDLY_ENEMY_RESPAWN_CHANCE = 0.5
local SowiloItem = RuneRooms.Enums.Item.SOWILO_ESSENCE

---@param npc EntityNPC
---@return boolean
local function CanSpawnFriendlyVersion(npc)
    return not npc:IsBoss()     --Can't spawn a friendly boss
    and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_FRIENDLY_BALL) --Can't be friendly
end

local function CheckForLastEnemyKilled(npc)
    if not CanSpawnFriendlyVersion(npc) then return end

    local rng = TSIL.RNG.NewRNG(npc.InitSeed)

    if rng:RandomFloat() >= FRIENDLY_ENEMY_RESPAWN_CHANCE then return end

    local enemyInfo = {
        type = npc.Type,
        variant = npc.Variant,
        subtype = npc.SubType,
        position = npc.Position
    }

    RuneRooms:TempSave().LastKilledEnemy = enemyInfo
end

---@param entity Entity
---@param damage number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function SowiloEssence:FriendlyNPCDeath(entity, damage, flags, source, countdown)
    if entity and entity:ToNPC() and entity:HasMortalDamage() and not entity:IsBoss() then
        if source and source.Entity and source.Entity.Type == EntityType.ENTITY_PLAYER then
            local player = source.Entity:ToPlayer()
            if player:HasCollectible(SowiloItem) and npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_FRIENDLY_BALL) then
                player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, UseFlag.USE_NOANIM)
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
        lastKilledEnemy.position
    )
    enemy:AddEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_PERSISTENT)

    roomData.LastKilledEnemy = nil
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR,
    SowiloEssence.OnRoomClear
)

function SowiloEssence:OnNewRoom()
    local runData = RuneRooms:RunSave()

    if runData.FriendlyEnemyToRespawn and runData.FriendlyEnemyToRespawn.type then
        local room = Game():GetRoom()
        local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)

        local enemy = TSIL.Entities.Spawn(
            runData.FriendlyEnemyToRespawn.type,
            runData.FriendlyEnemyToRespawn.variant,
            runData.FriendlyEnemyToRespawn.subtype,
            pos
        )
        enemy:AddEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_PERSISTENT)

        if room:IsClear() then
            TSIL.Doors.OpenAllDoors(false)
        end

        runData.FriendlyEnemyToRespawn = nil
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    SowiloEssence.OnNewRoom
)