local BerkanoNegative = {}


---Forbids an enemy from spawning enemy flies and spiders on death with the
---negative Berkano rune room effect.
---@param entity Entity
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
    if not RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.BERKANO) or not npc:ToNPC()
    or npc.Type == EntityType.ENTITY_SHOPKEEPER then return end
    local xml = XMLData.GetEntryFromEntity(npc, true, true)
    if xml.tags then
        for str in xml.tags:gmatch("%S+") do
            if str == "fly" then
                return
            end
        end
    end
    local cantSpawnEnemies = TSIL.Entities.GetEntityData(
        RuneRooms,
        npc,
        "CantSpawnBerkanoEnemies"
    )
    if cantSpawnEnemies then return end

    local rng = RNG(npc.InitSeed)

    local numEnemies = math.min(1 , math.ceil(npc.MaxHitPoints / 5))
    local level = Game():GetLevel()
    local parent = nil
    for _ = 1, numEnemies, 1 do
        local type = EntityType.ENTITY_ARMYFLY

        local distance = TSIL.Random.GetRandomFloat(0, 15, rng)
        local angle = rng:RandomInt(0, 360)
        local posOffset = Vector.FromAngle(angle):Resized(distance)

        local enemy = TSIL.Entities.Spawn(
            type,
            0,
            0,
            npc.Position + posOffset,
            Vector.Zero,
            parent
        ):ToNPC()
        enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        local newHP = enemy.MaxHitPoints + math.min(4, level:GetStage()) + 0.8 * RuneRooms.Helpers:Clamp(level:GetStage() - 5, 0, 5)
        enemy.MaxHitPoints = newHP
        enemy.HitPoints = newHP
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