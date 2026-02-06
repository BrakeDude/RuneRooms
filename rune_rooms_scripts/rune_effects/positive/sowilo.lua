local SowiloPositive = {}


TSIL.SaveManager.AddPersistentVariable(
    RuneRooms,
    RuneRooms.Enums.SaveKey.LOWEST_HEALTH_ENEMY,
    nil,
    TSIL.Enums.VariablePersistenceMode.RESET_ROOM
)


---@param npc EntityNPC
---@return boolean
local function CanSpawnFriendlyVersion(npc)
    return not npc:IsBoss()     --Can't spawn a friendly boss
    and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_FRIENDLY_BALL) --Can't be friendly
end


---@param npc EntityNPC
local function SetLowestHealthEnemy(npc)
    local npcInfo = {
        hp = npc.MaxHitPoints,
        type = npc.Type,
        variant = npc.Variant,
        subtype = npc.SubType,
        position = npc.Position
    }

    TSIL.SaveManager.SetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.LOWEST_HEALTH_ENEMY,
        npcInfo,
        true
    )
end


---@param npc EntityNPC
function SowiloPositive:OnNPCDeath(npc)
    if not CanSpawnFriendlyVersion(npc) then return end

    local lowestHealthEnemy = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.LOWEST_HEALTH_ENEMY
    )

    if not lowestHealthEnemy then
        SetLowestHealthEnemy(npc)
    elseif lowestHealthEnemy.hp >= npc.HitPoints then
        SetLowestHealthEnemy(npc)
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    SowiloPositive.OnNPCDeath
)


function SowiloPositive:OnRoomClear()
    local lowestHealthEnemy = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.LOWEST_HEALTH_ENEMY
    )

    if lowestHealthEnemy and RuneRooms:IsRuneBlessingActive(RuneRooms.Enums.RuneEffect.SOWILO) then
        local friendlyEnemy = TSIL.Entities.Spawn(
            lowestHealthEnemy.type,
            lowestHealthEnemy.variant,
            lowestHealthEnemy.subtype,
            lowestHealthEnemy.position
        )
        friendlyEnemy:AddEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_PERSISTENT)
    end

    TSIL.SaveManager.SetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.LOWEST_HEALTH_ENEMY,
        nil,
        true
    )
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_ROOM_CLEAR_CHANGED,
    SowiloPositive.OnRoomClear,
    true
)