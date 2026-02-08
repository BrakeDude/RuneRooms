local BerkanoNegative = {}


---Forbids an enemy from spawning enemy flies and spiders on death with the
---negative Berkano rune room effect.
---@param entity any
function RuneRooms.API:ForbidEnemyFromSpawningBugsOnDeath(entity)
    TSIL.Entities.SetEntityData(
        RuneRooms,
        entity,
        "CantSpawnBerkanoEnemies",
        true
    )
end


---@param npc EntityNPC
function BerkanoNegative:OnNPCDeath(npc)
    if not RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.BERKANO) then return end

    local cantSpawnEnemies = TSIL.Entities.GetEntityData(
        RuneRooms,
        npc,
        "CantSpawnBerkanoEnemies"
    )
    if cantSpawnEnemies then return end

    local rng = RNG(npc.InitSeed)

    local numEnemies = rng:RandomInt(1, 2)
    for _ = 1, numEnemies, 1 do
        local type = EntityType.ENTITY_FLY

        local distance = TSIL.Random.GetRandomFloat(0, 15)
        local angle = rng:RandomInt(0, 360)
        local posOffset = Vector.FromAngle(angle):Resized(distance)

        local enemy = TSIL.Entities.Spawn(
            type,
            0,
            0,
            npc.Position + posOffset
        )
        enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

        TSIL.Entities.SetEntityData(
            RuneRooms,
            enemy,
            "CantSpawnBerkanoEnemies",
            true
        )
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    BerkanoNegative.OnNPCDeath
)