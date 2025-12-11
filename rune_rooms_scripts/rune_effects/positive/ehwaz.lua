local EhwazPositive = {}

local crawlspaceMode = "replace"


local function SpawnDyingGideon(position)
    local gideon = TSIL.EntitySpecific.SpawnNPC(
        EntityType.ENTITY_GIDEON,
        0,
        0,
        position
    )
    gideon.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
    gideon.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    gideon:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    gideon:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
    gideon.Visible = false

    TSIL.Entities.SetEntityData(
        RuneRooms,
        gideon,
        "IsSpecialGideon",
        true
    )

    local chaosCard = TSIL.EntitySpecific.SpawnTear(
        TearVariant.CHAOS_CARD,
        0,
        position
    )
    chaosCard.Visible = false
end


---@param npc EntityNPC
function EhwazPositive:OnGideonRender(npc)
    local isSpecialGideon = TSIL.Entities.GetEntityData(
        RuneRooms,
        npc,
        "IsSpecialGideon"
    )
    if not isSpecialGideon then return end

    local bloodExplosions = TSIL.EntitySpecific.GetEffects(EffectVariant.BLOOD_EXPLOSION)
    TSIL.Utils.Tables.ForEach(bloodExplosions, function (_, bloodExplosion)
        if bloodExplosion.FrameCount == 0 then
            bloodExplosion.Visible = false
            bloodExplosion:Remove()
        end
    end)

    local sprite = npc:GetSprite()
    local anim = sprite:GetAnimation()

    if anim ~= "Death" then return end

    local lastFrame = TSIL.Sprites.GetLastFrameOfAnimation(sprite)
    local frame = sprite:GetFrame()

    if lastFrame == frame then return end
    sprite:SetLastFrame()
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NPC_RENDER,
    EhwazPositive.OnGideonRender,
    EntityType.ENTITY_GIDEON
)


---@param npc EntityNPC
function EhwazPositive:OnGideonDeath(npc)
    local isSpecialGideon = TSIL.Entities.GetEntityData(
        RuneRooms,
        npc,
        "IsSpecialGideon"
    )
    if not isSpecialGideon then return end

    SFXManager():Stop(SoundEffect.SOUND_MONSTER_ROAR_2)
    SFXManager():Stop(SoundEffect.SOUND_ROCK_CRUMBLE)
    SFXManager():Stop(SoundEffect.SOUND_EXPLOSION_STRONG)
    TSIL.Utils.Functions.RunInFrames(function ()
        SFXManager():Stop(SoundEffect.SOUND_EXPLOSION_STRONG)
    end, 2)

    local explosions = TSIL.EntitySpecific.GetEffects(EffectVariant.BOMB_EXPLOSION)
    TSIL.Utils.Tables.ForEach(explosions, function (_, explosion)
        if explosion.FrameCount == 0 then
            explosion:Remove()
        end
    end)

    local rockParticles = TSIL.EntitySpecific.GetEffects(EffectVariant.ROCK_PARTICLE)
    TSIL.Utils.Tables.ForEach(rockParticles, function (_, rockParticle)
        if rockParticle.FrameCount == 0 then
            rockParticle:Remove()
        end
    end)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    EhwazPositive.OnGideonDeath,
    EntityType.ENTITY_GIDEON
)

function EhwazPositive:OnEhwazPositiveActivation()
    if crawlspaceMode == "temporary" then
        Isaac.ExecuteCommand("goto s.itemdungeon.1000")
        Game():StartRoomTransition(GridRooms.ROOM_DEBUG_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.PIXELATION)
    elseif crawlspaceMode == "gideon" then
        local room = Game():GetRoom()
        local centerPos = room:GetCenterPos()
        local spawnPos = centerPos + Vector(0, 80)

        SpawnDyingGideon(spawnPos)
    elseif crawlspaceMode == "replace" then
        local level = Game():GetLevel()

        local writeableRoom = level:GetRoomByIdx(GridRooms.ROOM_DUNGEON_IDX, -1)
        local gideonDungeonRoomData = RoomConfig.GetRoomByStageTypeAndVariant(StbType.SPECIAL_ROOMS, RoomType.ROOM_DUNGEON, 1000)
        writeableRoom.Data = gideonDungeonRoomData

        local room = Game():GetRoom()
        local centerPos = room:GetCenterPos()
        local spawnPos = centerPos + Vector(0, 80)

        TSIL.GridEntities.SpawnGridEntity(
            GridEntityType.GRID_STAIRS,
            TSIL.Enums.StairsVariant.NORMAL,
            spawnPos,
            true
        )
    end
end
RuneRooms:AddCallback(
    RuneRooms.Enums.CustomCallback.POST_GAIN_POSITIVE_RUNE_EFFECT,
    EhwazPositive.OnEhwazPositiveActivation,
    RuneRooms.Enums.RuneEffect.EHWAZ
)


function EhwazPositive:OnChangeModeCommand(_, newMode)
    local modes = {temporary = true, gideon = true, replace = true}

    if not newMode or not modes[newMode] then
        print("Not a correct mode. Possible modes:")
        print("-temporary: Enters a temporary gideon's dungeon that can't be reentered.")
        print("-gideon: Spawns a gideon and instantly kills it to spawn the entrance.")
        print("-replace: Replaces the floor's crawlspace with gideon's dungeon.")

        return true
    end

    crawlspaceMode = newMode
    print("Succesfully changed mode to " .. newMode)

    return true
end
RuneRooms:AddCallback(
    RuneRooms.Enums.CustomCallback.ON_CUSTOM_CMD,
    EhwazPositive.OnChangeModeCommand,
    "ehwazmode"
)