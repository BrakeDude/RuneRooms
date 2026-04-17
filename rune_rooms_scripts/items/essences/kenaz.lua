local KenazEssence = {}

local POISONOUS_AURA_RADIUS = 100
local POISON_DURATION = 30 * 3
local POISON_CLOUD_DURATION = 30 * 15
local POISON_CLOUD_STAT_RADIUS = 40
local POISON_CLOUD_STATS = {
    Damage = 3,
    Tears = 3
}

local KenazItem = RuneRooms.Enums.Item.KENAZ_ESSENCE

---@param firstTime boolean
---@param player EntityPlayer
function KenazEssence:OnKenazPickup(_, _, firstTime, _, _, player)
    if not firstTime then return end
    player:AddRottenHearts(1)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_ADD_COLLECTIBLE,
    KenazEssence.OnKenazPickup,
    KenazItem
)


---@param player EntityPlayer
local function PoisonCloseEnemies(player)
    local closeEnemies = Isaac.FindInRadius(player.Position, POISONOUS_AURA_RADIUS, EntityPartition.ENEMY)
    TSIL.Utils.Tables.ForEach(closeEnemies, function (_, enemy)
        if not enemy:ToNPC() then return end

        enemy:AddPoison(EntityRef(player), POISON_DURATION, player.Damage)
        TSIL.Entities.SetEntityData(
            RuneRooms,
            enemy,
            "IsPoisonedFromKenazEffect",
            true
        )
    end)
end


---@param player EntityPlayer
local function GetStatsFromPoisonClouds(player)
    local closePoisonClouds = TSIL.EntitySpecific.GetEffects(EffectVariant.SMOKE_CLOUD, 0)
    local cloudNearby = TSIL.Utils.Tables.Some(closePoisonClouds, function (cloud)
        local distanceSqr = player.Position:DistanceSquared(cloud.Position)

        return distanceSqr <= POISON_CLOUD_STAT_RADIUS ^ 2
    end)

    local playerData = RuneRooms:TempSave(player)
    local wasCloseToCloud = playerData.wasCloseToCloud
    playerData.wasCloseToCloud = cloudNearby

    if wasCloseToCloud == nil or wasCloseToCloud ~= cloudNearby then
        ---@diagnostic disable-next-line: param-type-mismatch
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
    end
end


---@param player EntityPlayer
function KenazEssence:OnPeffectUpdate(player)
    if not player:HasCollectible(KenazItem) then return end

    PoisonCloseEnemies(player)

    GetStatsFromPoisonClouds(player)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    KenazEssence.OnPeffectUpdate
)


---@param npc EntityNPC
function KenazEssence:OnNPCUpdate(npc)
    local isPoisonedFromKenazEffect = TSIL.Entities.GetEntityData(
        RuneRooms,
        npc,
        "IsPoisonedFromKenazEffect"
    ) == true

    if isPoisonedFromKenazEffect and not npc:HasEntityFlags(EntityFlag.FLAG_POISON) then
        TSIL.Entities.SetEntityData(
            RuneRooms,
            npc,
            "IsPoisonedFromKenazEffect",
            false
        )
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_NPC_UPDATE,
    KenazEssence.OnNPCUpdate
)


---@param npc EntityNPC
function KenazEssence:OnNPCDeath(npc)
    local isPoisonedFromKenazEffect = TSIL.Entities.GetEntityData(
        RuneRooms,
        npc,
        "IsPoisonedFromKenazEffect"
    ) == true

    if isPoisonedFromKenazEffect then
        --We can use any player here
        local player = Isaac.GetPlayer()

        local cloud = TSIL.EntitySpecific.SpawnEffect(
            EffectVariant.SMOKE_CLOUD,
            0,
            npc.Position,
            Vector.Zero,
            player
        )
        cloud.Timeout = POISON_CLOUD_DURATION
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    KenazEssence.OnNPCDeath
)


---@param player EntityPlayer
---@param cacheFlags CacheFlag
function KenazEssence:OnCacheEval(player, cacheFlags)
    if not player:HasCollectible(KenazItem) then return end

    local playerData = RuneRooms:TempSave(player)
    local wasCloseToCloud = playerData.wasCloseToCloud

    if not wasCloseToCloud then return end

    if TSIL.Utils.Flags.HasFlags(cacheFlags, CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage + POISON_CLOUD_STATS.Damage
    elseif TSIL.Utils.Flags.HasFlags(cacheFlags, CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = RuneRooms.Helpers:AddTears(player.MaxFireDelay, POISON_CLOUD_STATS.Tears)
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    KenazEssence.OnCacheEval
)