local KenazPositive = {}


local SMOKE_DURATION = 3 * 30
local POISON_DURATION = 3 * 30

local function SpawnSmokeCreen()
    local room = RuneRooms.Room()
    local centerPos = room:GetCenterPos()

    local smokeScreen = TSIL.EntitySpecific.SpawnEffect(
        RuneRooms.Enums.EffectVariant.SMOKE_CLOUD,
        0,
        centerPos
    )
    smokeScreen.Timeout = SMOKE_DURATION
end


---@param npc EntityNPC
local function IsEnemyPoisonable(npc)
    return npc:IsActiveEnemy(true) and npc:IsVulnerableEnemy() and not npc:IsInvincible() and not
    npc:HasEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_FRIENDLY_BALL)
end


---@return EntityNPC[]
local function GetAllVulnerableEnemies()
    local npcs = TSIL.EntitySpecific.GetNPCs()

    return TSIL.Utils.Tables.Filter(npcs, function (_, npc)
        return IsEnemyPoisonable(npc)
    end)
end


---@param enemies EntityNPC[]
local function PoisonEntities(enemies)
    local players = PlayerManager.GetPlayers()
    local player = RuneRooms.Helpers:TableQuickSort(players, function(a,b) return a.Damage > b.Damage end)[1]
    local damage = player.Damage * 2

    TSIL.Utils.Tables.ForEach(enemies, function (_, enemy)
        enemy:AddPoison(EntityRef(player), POISON_DURATION, damage)
    end)
end


local function PoisonEnemies()
    local enemies = GetAllVulnerableEnemies()

    PoisonEntities(enemies)
end


function KenazPositive:OnNewRoom()
    if not RuneRooms:IsRuneBlessingActive(RuneRooms.Enums.RuneEffect.KENAZ) then return end

    local room = RuneRooms.Room()
    if room:IsClear() then return end

    SpawnSmokeCreen()

    PoisonEnemies()
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    KenazPositive.OnNewRoom
)