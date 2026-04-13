local SowiloPositive = {}

---@param npc EntityNPC
---@return boolean
local function CanSpawnFriendlyVersion(npc)
    return not npc:IsBoss()     --Can't spawn a friendly boss
    ---@diagnostic disable-next-line: param-type-mismatch
    and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_FRIENDLY_BALL) --Can't be friendly
end


---@param npc EntityNPC
local function SetLowestHealthEnemy(npc)
    local npcInfo = {
        hp = npc.MaxHitPoints,
        type = npc.Type,
        variant = npc.Variant,
        subtype = npc.SubType,
        positionX = npc.Position.X,
        positionY = npc.Position.Y
    }
    RuneRooms:TempSave().SowiloPositiveLowestHealthEnemy = npcInfo
end


---@param npc EntityNPC
function SowiloPositive:OnNPCDeath(npc)
    if not CanSpawnFriendlyVersion(npc) then return end

    local lowestHealthEnemy =  RuneRooms:TempSave().SowiloPositiveLowestHealthEnemy

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
    local lowestHealthEnemy = RuneRooms:TempSave().SowiloPositiveLowestHealthEnemy

    if lowestHealthEnemy and RuneRooms:IsRuneBlessingActive(RuneRooms.Enums.RuneEffect.SOWILO) then
        local friendlyEnemy = TSIL.Entities.Spawn(
            lowestHealthEnemy.type,
            lowestHealthEnemy.variant,
            lowestHealthEnemy.subtype,
            Vector(lowestHealthEnemy.positionX, lowestHealthEnemy.positionY)
        )
        friendlyEnemy:AddEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_PERSISTENT)
    end

    RuneRooms:TempSave().SowiloPositiveLowestHealthEnemy = nil
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_ROOM_CLEAR_CHANGED,
    SowiloPositive.OnRoomClear,
    true
)