local BerkanoEssence = {}

local FAMILIAR_SPAWN_CHANCE = 0.1
local BerkanoItem = RuneRooms.Enums.Item.BERKANO_ESSENCE

TSIL.SaveManager.AddPersistentVariable(
    RuneRooms,
    RuneRooms.Enums.SaveKey.BERKANO_FAMILIAR_POSITIONS,
    {},
    TSIL.Enums.VariablePersistenceMode.RESET_ROOM
)

---@param player EntityPlayer
function BerkanoEssence:OnFireDelayCache(player)
    local numItems = player:GetCollectibleNum(BerkanoItem)
    player.MaxFireDelay = RuneRooms.Helpers:AddTears(player.MaxFireDelay, numItems * 0.3)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    BerkanoEssence.OnFireDelayCache,
    CacheFlag.CACHE_FIREDELAY
)


---@param npc EntityNPC
local function SpawnBoneOrbital(npc)
    local players = TSIL.Players.GetPlayersByCollectible(BerkanoItem)
    TSIL.Utils.Tables.ForEach(players, function (_, player)
        local familiar = TSIL.EntitySpecific.SpawnFamiliar(
            FamiliarVariant.BONE_ORBITAL,
            0,
            npc.Position,
            Vector.Zero,
            player
        )
        familiar.Parent = player
    end)
end


---@param npc EntityNPC
---@param rng RNG
local function SpawnRandomFamiliar(npc, rng)
    local collectibles = TSIL.Collectibles.GetCollectiblesWithTag(TSIL.Enums.ItemConfigTag.MONSTER_MANUAL)
    collectibles = TSIL.Utils.Tables.Filter(collectibles, function (_, collectible)
        return not collectible.PersistentEffect and collectible:IsAvailable()
    end)

    local players = TSIL.Players.GetPlayersByCollectible(BerkanoItem)
    TSIL.Utils.Tables.ForEach(players, function (_, player)
        local collectible = TSIL.Random.GetRandomElementsFromTable(collectibles, 1, rng)[1]

        local effects = player:GetEffects()
        effects:AddCollectibleEffect(collectible.ID, false)

        local familiarPositions = TSIL.SaveManager.GetPersistentVariable(
            RuneRooms,
            RuneRooms.Enums.SaveKey.BERKANO_FAMILIAR_POSITIONS
        )
        familiarPositions[#familiarPositions+1] = npc.Position
    end)
end


---@param npc EntityNPC
function BerkanoEssence:OnNPCDeath(npc)
    if not PlayerManager.AnyoneHasCollectible(BerkanoItem) then return end

    local rng = TSIL.RNG.NewRNG(npc.InitSeed)

    if rng:RandomFloat() >= FAMILIAR_SPAWN_CHANCE then return end

    if npc.MaxHitPoints <= 10 then
        SpawnBoneOrbital(npc)
    else
        SpawnRandomFamiliar(npc, rng)
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    BerkanoEssence.OnNPCDeath
)


---@param familiar EntityFamiliar
function BerkanoEssence:OnFamiliarInit(familiar)
    local familiarPositions = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.BERKANO_FAMILIAR_POSITIONS
    )
    if #familiarPositions == 0 then return end

    local pos = table.remove(familiarPositions, 1)
    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    TSIL.Entities.SetEntityData(
        RuneRooms,
        familiar,
        "MoveFamiliarToPos",
        pos
    )
end
RuneRooms:AddCallback(
    ModCallbacks.MC_FAMILIAR_INIT,
    BerkanoEssence.OnFamiliarInit
)


---@param familiar EntityFamiliar
function BerkanoEssence:OnFamiliarUpdate(familiar)
    local moveToPos = TSIL.Entities.GetEntityData(
        RuneRooms,
        familiar,
        "MoveFamiliarToPos"
    )

    if moveToPos then
        familiar.Position = moveToPos
        TSIL.Entities.SetEntityData(
            RuneRooms,
            familiar,
            "MoveFamiliarToPos",
            nil
        )
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_FAMILIAR_UPDATE,
    BerkanoEssence.OnFamiliarUpdate
)