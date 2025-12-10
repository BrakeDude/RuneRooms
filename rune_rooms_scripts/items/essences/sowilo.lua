local SowiloEssence = {}

local FRIENDLY_ENEMY_RESPAWN_CHANCE = 0.4
local SowiloItem = RuneRooms.Enums.Item.SOWILO_ESSENCE

TSIL.SaveManager.AddPersistentVariable(
    RuneRooms,
    RuneRooms.Enums.SaveKey.LAST_KILLED_ENEMY,
    {},
    TSIL.Enums.VariablePersistenceMode.RESET_ROOM
)
TSIL.SaveManager.AddPersistentVariable(
    RuneRooms,
    RuneRooms.Enums.SaveKey.DEAD_FRIENDLY_ENEMY,
    {},
    TSIL.Enums.VariablePersistenceMode.RESET_RUN
)


---@param npc EntityNPC
---@return boolean
local function CanSpawnFriendlyVersion(npc)
    return not npc:IsBoss()     --Can't spawn a friendly boss
    and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_FRIENDLY_BALL) --Can't be friendly
end

---@param npc EntityNPC
local function CheckFriendlyEnemyDeath(npc)
    if not PlayerManager.AnyoneHasCollectible(SowiloItem) then return end

    if not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_FRIENDLY_BALL) then return end

    local player = Isaac.GetPlayer()
    player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, UseFlag.USE_NOANIM)

    local rng = TSIL.RNG.NewRNG(npc.InitSeed)

    if rng:RandomFloat() >= FRIENDLY_ENEMY_RESPAWN_CHANCE then return end
    local enemyInfo = {
        type = npc.Type,
        variant = npc.Variant,
        subtype = npc.SubType
    }
    TSIL.SaveManager.SetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.DEAD_FRIENDLY_ENEMY,
        enemyInfo
    )
end


local function CheckForLastEnemyKilled(npc)
    if not CanSpawnFriendlyVersion(npc) then return end

    local enemyInfo = {
        type = npc.Type,
        variant = npc.Variant,
        subtype = npc.SubType,
        position = npc.Position
    }

    TSIL.SaveManager.SetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.LAST_KILLED_ENEMY,
        enemyInfo
    )
end


---@param npc EntityNPC
function SowiloEssence:OnNPCDeath(npc)
    CheckFriendlyEnemyDeath(npc)

    CheckForLastEnemyKilled(npc)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    SowiloEssence.OnNPCDeath
)


function SowiloEssence:OnRoomClear()
    if not PlayerManager.AnyoneHasCollectible(SowiloItem) then return end

    local lastKilledEnemy = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.LAST_KILLED_ENEMY
    )
    if not lastKilledEnemy.type then return end

    local enemy = TSIL.Entities.Spawn(
        lastKilledEnemy.type,
        lastKilledEnemy.variant,
        lastKilledEnemy.subtype,
        lastKilledEnemy.position
    )
    enemy:AddEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_PERSISTENT)

    TSIL.SaveManager.SetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.LAST_KILLED_ENEMY,
        {}
    )
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_ROOM_CLEAR_CHANGED,
    SowiloEssence.OnRoomClear,
    true
)


function SowiloEssence:OnNewRoom()
    local friendlyEnemyToRespawn = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.DEAD_FRIENDLY_ENEMY
    )

    if friendlyEnemyToRespawn.type then
        local room = Game():GetRoom()
        local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)

        local enemy = TSIL.Entities.Spawn(
            friendlyEnemyToRespawn.type,
            friendlyEnemyToRespawn.variant,
            friendlyEnemyToRespawn.subtype,
            pos
        )
        enemy:AddEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_PERSISTENT)

        if room:IsClear() then
            TSIL.Doors.OpenAllDoors(false)
        end

        TSIL.SaveManager.SetPersistentVariable(
            RuneRooms,
            RuneRooms.Enums.SaveKey.DEAD_FRIENDLY_ENEMY,
            {}
        )
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    SowiloEssence.OnNewRoom
)