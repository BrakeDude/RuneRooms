local Backdrop = {}

local FLOOR_ANM2 = "gfx/backdrop/rune_floor.anm2"
local WALLS_ANM2 = "gfx/backdrop/rune_walls.anm2"

local PIT_SPRITE = "gfx/grid/grid_pit_mausoleum.png"
local PIT_SPRITE_FF = "gfx/grid/grid_pit_rune.png"
local GRIDS_SPRITE = "gfx/grid/rocks_mausoleum.png"
local GRIDS_SPRITE_FF = "gfx/grid/rocks_rune.png"
local GRID_TYPES_SPRITE_REPLACE = {
    [GridEntityType.GRID_PILLAR] = true,
    [GridEntityType.GRID_ROCK] = true,
    [GridEntityType.GRID_ROCKB] = true,
    [GridEntityType.GRID_ROCKT] = true,
    [GridEntityType.GRID_ROCK_ALT] = true,
    [GridEntityType.GRID_ROCK_BOMB] = true,
    [GridEntityType.GRID_ROCK_GOLD] = true,
    [GridEntityType.GRID_ROCK_SPIKED] = true,
    [GridEntityType.GRID_ROCK_SS] = true,
}

local CRYSTAL_PILLARS_ANM2 = "gfx/backdrop/crystal_pillar.anm2"
local CRYSTAL_PILLARS_ORIENTATION_PER_GRID_INDEX = {
    [0] = { flipX = false, flipY = false },
    [14] = { flipX = true, flipY = false },
    [120] = { flipX = false, flipY = true },
    [134] = { flipX = true, flipY = true }
}

local WALL_DETAILS_ANM2 = "gfx/backdrop/wall_details.anm2"
local WALL_DETAILS2_ANM2 = "gfx/backdrop/wall_details_2.anm2"
local NUM_HORIZONTAL_DETAIL_ANIMS = 7
local NUM_VERTICAL_DETAIL_ANIMS = 4
local HORIZONTAL_DETAIL_GRID_INDEXES = { 2, 3, 4, 5, 6, 8, 9, 10, 11, 12 }
local VERTICAL_DETAIL_GRID_INDEXES = { 30, 45, 75, 90 }

local CRYSTAL_OVERLAY_ANM2 = "gfx/backdrop/crystal_overlay.anm2"
local NUM_HORIZONTAL_OVERLAY_ANIMS = 3
local NUM_VERTICAL_OVERLAY_ANIMS = 2
local HORIZONTAL_OVERLAY_GRID_INDEXES = { 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 }
local VERTICAL_OVERLAY_GRID_INDEXES = { 30, 45, 60, 75, 90 }

local CRYSTAL_SHINE_ANM2 = "gfx/backdrop/crystal_shine.anm2"

local function SpawnFloor()
    local spanwPos = TSIL.GridEntities.GetTopLeftWall().Position + Vector(20, 20)
    local floor = TSIL.EntitySpecific.SpawnEffect(
        EffectVariant.BACKDROP_DECORATION,
        0,
        spanwPos
    )

    local sprite = floor:GetSprite()
    sprite:Load(FLOOR_ANM2, true)
    sprite:Play("1", true)

    floor:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
end

local function SpawnWall()
    local spanwPos = TSIL.GridEntities.GetTopLeftWall().Position + Vector(20, 20)
    local wall = TSIL.EntitySpecific.SpawnEffect(
        EffectVariant.BACKDROP_DECORATION,
        0,
        spanwPos
    )

    local sprite = wall:GetSprite()
    sprite:Load(WALLS_ANM2, true)
    sprite:Play("1", true)

    wall:AddEntityFlags(EntityFlag.FLAG_RENDER_WALL)
end


---Spawns an effect that acts as a wall detail
---@param pos Vector
---@param anm2 string
---@param anim string
---@param flipX boolean
---@param flipY boolean
---@param rng RNG
---@return EntityEffect
local function SpawnGenericWallDetail(pos, anm2, anim, flipX, flipY, rng)
    local detail = TSIL.EntitySpecific.SpawnEffect(
        EffectVariant.BACKDROP_DECORATION,
        0,
        pos
    )
    detail:AddEntityFlags(EntityFlag.FLAG_RENDER_WALL | EntityFlag.FLAG_RENDER_FLOOR |
    EntityFlag.FLAG_NO_REMOVE_ON_TEX_RENDER)
    detail.DepthOffset = detail.DepthOffset - 10000

    local sprite = detail:GetSprite()
    sprite:Load(anm2, true)
    sprite:Play(anim, true)

    local lastFrame = TSIL.Sprites.GetLastFrameOfAnimation(sprite)
    local randomFrame = TSIL.Random.GetRandomInt(0, lastFrame, rng)
    sprite:SetFrame(randomFrame)

    sprite.FlipX = flipX
    sprite.FlipY = flipY

    return detail
end


---@param rng RNG
local function SpawnCrystalPillars(rng)
    local room = Game():GetRoom()
    local runeEffect = RuneRooms:GetRuneEffectForFloor()

    TSIL.Utils.Tables.ForEach(CRYSTAL_PILLARS_ORIENTATION_PER_GRID_INDEX, function(gridIndex, orientation)
        --I know that they're integers, you know that they're integers, but the lua server doesn't
        if type(gridIndex) == "string" then return end

        local pillar = SpawnGenericWallDetail(
            room:GetGridPosition(gridIndex),
            CRYSTAL_PILLARS_ANM2,
            "Idle",
            orientation.flipX,
            orientation.flipY,
            rng
        )
        pillar:GetSprite():PlayOverlay(RuneRooms.Constants.RUNE_NAMES[runeEffect])
    end)
end


---@param anm2 string
---@param rng RNG
local function SpawnHorizontalWallDetails(anm2, rng)
    local room = Game():GetRoom()
    local center = room:GetCenterPos()

    TSIL.Utils.Tables.ForEach(HORIZONTAL_DETAIL_GRID_INDEXES, function(_, gridIndex)
        if rng:RandomFloat() >= 0.5 then return end

        local spawnPos = room:GetGridPosition(gridIndex)

        local detail = SpawnGenericWallDetail(
            spawnPos,
            anm2,
            "h" .. TSIL.Random.GetRandomInt(1, NUM_HORIZONTAL_DETAIL_ANIMS, rng),
            spawnPos.X > center.X,
            false,
            rng
        )
        TSIL.Entities.SetEntityData(
            RuneRooms,
            detail,
            "CanShine",
            true
        )
    end)

    local flippedGridIndexes = TSIL.Utils.Tables.Map(HORIZONTAL_DETAIL_GRID_INDEXES, function(_, gridIndex)
        return gridIndex + 120
    end)
    TSIL.Utils.Tables.ForEach(flippedGridIndexes, function(_, gridIndex)
        if rng:RandomFloat() >= 0.5 then return end

        local spawnPos = room:GetGridPosition(gridIndex)

        local detail = SpawnGenericWallDetail(
            spawnPos,
            anm2,
            "h" .. TSIL.Random.GetRandomInt(1, NUM_HORIZONTAL_DETAIL_ANIMS, rng),
            spawnPos.X > center.X,
            true,
            rng
        )
        TSIL.Entities.SetEntityData(
            RuneRooms,
            detail,
            "CanShine",
            true
        )
    end)
end


---@param anm2 string
---@param rng RNG
local function SpawnVerticalWallDetails(anm2, rng)
    local room = Game():GetRoom()
    local center = room:GetCenterPos()

    TSIL.Utils.Tables.ForEach(VERTICAL_DETAIL_GRID_INDEXES, function(_, gridIndex)
        if rng:RandomFloat() >= 0.5 then return end

        local spawnPos = room:GetGridPosition(gridIndex)

        local detail = SpawnGenericWallDetail(
            spawnPos,
            anm2,
            "v" .. TSIL.Random.GetRandomInt(1, NUM_VERTICAL_DETAIL_ANIMS, rng),
            false,
            spawnPos.Y > center.Y,
            rng
        )
        TSIL.Entities.SetEntityData(
            RuneRooms,
            detail,
            "CanShine",
            true
        )
    end)

    local flippedGridIndexes = TSIL.Utils.Tables.Map(VERTICAL_DETAIL_GRID_INDEXES, function(_, gridIndex)
        return gridIndex + 14
    end)
    TSIL.Utils.Tables.ForEach(flippedGridIndexes, function(_, gridIndex)
        if rng:RandomFloat() >= 0.5 then return end

        local spawnPos = room:GetGridPosition(gridIndex)

        local detail = SpawnGenericWallDetail(
            spawnPos,
            anm2,
            "v" .. TSIL.Random.GetRandomInt(1, NUM_VERTICAL_DETAIL_ANIMS, rng),
            true,
            spawnPos.Y > center.Y,
            rng
        )
        TSIL.Entities.SetEntityData(
            RuneRooms,
            detail,
            "CanShine",
            true
        )
    end)
end


---@param rng RNG
local function SpawnWallDetails(rng)
    SpawnHorizontalWallDetails(WALL_DETAILS_ANM2, rng)
    SpawnHorizontalWallDetails(WALL_DETAILS2_ANM2, rng)

    SpawnVerticalWallDetails(WALL_DETAILS_ANM2, rng)
    SpawnVerticalWallDetails(WALL_DETAILS2_ANM2, rng)
end


---@param rng RNG
local function SpawnHorizontalOverlays(rng)
    local room = Game():GetRoom()

    TSIL.Utils.Tables.ForEach(HORIZONTAL_OVERLAY_GRID_INDEXES, function(_, gridIndex)
        if rng:RandomFloat() >= 0.1 then return end

        local spawnPos = room:GetGridPosition(gridIndex)

        local overlay = TSIL.EntitySpecific.SpawnEffect(
            EffectVariant.BACKDROP_DECORATION,
            0,
            spawnPos
        )
        overlay.DepthOffset = overlay.DepthOffset + 10000

        local sprite = overlay:GetSprite()
        sprite:Load(CRYSTAL_OVERLAY_ANM2, true)
        local animToPlay = "h" .. TSIL.Random.GetRandomInt(1, NUM_HORIZONTAL_OVERLAY_ANIMS, rng)
        sprite:Play(animToPlay, true)

        local lastFrame = TSIL.Sprites.GetLastFrameOfAnimation(sprite)
        local randomFrame = TSIL.Random.GetRandomInt(0, lastFrame, rng)
        sprite:SetFrame(randomFrame)

        sprite.FlipX = rng:RandomFloat() > 0.5
        sprite.FlipY = false
    end)

    local flippedGridIndexes = TSIL.Utils.Tables.Map(HORIZONTAL_OVERLAY_GRID_INDEXES, function(_, gridIndex)
        return gridIndex + 120
    end)
    TSIL.Utils.Tables.ForEach(flippedGridIndexes, function(_, gridIndex)
        if rng:RandomFloat() >= 0.1 then return end

        local spawnPos = room:GetGridPosition(gridIndex)

        local overlay = TSIL.EntitySpecific.SpawnEffect(
            EffectVariant.BACKDROP_DECORATION,
            0,
            spawnPos
        )
        overlay.DepthOffset = overlay.DepthOffset + 10000

        local sprite = overlay:GetSprite()
        sprite:Load(CRYSTAL_OVERLAY_ANM2, true)
        local animToPlay = "h" .. TSIL.Random.GetRandomInt(1, NUM_HORIZONTAL_OVERLAY_ANIMS, rng)
        sprite:Play(animToPlay, true)

        local lastFrame = TSIL.Sprites.GetLastFrameOfAnimation(sprite)
        local randomFrame = TSIL.Random.GetRandomInt(0, lastFrame, rng)
        sprite:SetFrame(randomFrame)

        sprite.FlipX = rng:RandomFloat() > 0.5
        sprite.FlipY = true
    end)
end


---@param rng RNG
local function SpawnVerticalOverlays(rng)
    local room = Game():GetRoom()

    TSIL.Utils.Tables.ForEach(VERTICAL_OVERLAY_GRID_INDEXES, function(_, gridIndex)
        if rng:RandomFloat() >= 0.1 then return end

        local spawnPos = room:GetGridPosition(gridIndex)

        local overlay = TSIL.EntitySpecific.SpawnEffect(
            EffectVariant.BACKDROP_DECORATION,
            0,
            spawnPos
        )
        overlay.DepthOffset = overlay.DepthOffset + 10000

        local sprite = overlay:GetSprite()
        sprite:Load(CRYSTAL_OVERLAY_ANM2, true)
        local animToPlay = "v" .. TSIL.Random.GetRandomInt(1, NUM_VERTICAL_OVERLAY_ANIMS, rng)
        sprite:Play(animToPlay, true)

        local lastFrame = TSIL.Sprites.GetLastFrameOfAnimation(sprite)
        local randomFrame = TSIL.Random.GetRandomInt(0, lastFrame, rng)
        sprite:SetFrame(randomFrame)

        sprite.FlipX = false
        sprite.FlipY = rng:RandomFloat() > 0.5
    end)

    local flippedGridIndexes = TSIL.Utils.Tables.Map(VERTICAL_OVERLAY_GRID_INDEXES, function(_, gridIndex)
        return gridIndex + 14
    end)
    TSIL.Utils.Tables.ForEach(flippedGridIndexes, function(_, gridIndex)
        if rng:RandomFloat() >= 0.1 then return end

        local spawnPos = room:GetGridPosition(gridIndex)

        local overlay = TSIL.EntitySpecific.SpawnEffect(
            EffectVariant.BACKDROP_DECORATION,
            0,
            spawnPos
        )
        overlay.DepthOffset = overlay.DepthOffset + 10000

        local sprite = overlay:GetSprite()
        sprite:Load(CRYSTAL_OVERLAY_ANM2, true)
        local animToPlay = "v" .. TSIL.Random.GetRandomInt(1, NUM_VERTICAL_OVERLAY_ANIMS, rng)
        sprite:Play(animToPlay, true)

        local lastFrame = TSIL.Sprites.GetLastFrameOfAnimation(sprite)
        local randomFrame = TSIL.Random.GetRandomInt(0, lastFrame, rng)
        sprite:SetFrame(randomFrame)

        sprite.FlipX = true
        sprite.FlipY = rng:RandomFloat() > 0.5
    end)
end


local function SpawnCrystalOverlays(rng)
    SpawnHorizontalOverlays(rng)

    SpawnVerticalOverlays(rng)
end


---@param gridEntityType GridEntityType
---@return string
local function GetGridSpriteSheet(gridEntityType)
    local pitsSpriteMode = RuneRooms:GetRocksSpriteMode()

    if pitsSpriteMode == RuneRooms.Enums.GridSpriteMode.FORCE_FF then
        return GRIDS_SPRITE_FF
    elseif pitsSpriteMode == RuneRooms.Enums.GridSpriteMode.FORCE_VANILLA then
        return GRIDS_SPRITE
    else
        local defaultSpriteSheet = GRIDS_SPRITE

        local newSpriteSheet = Isaac.RunCallback(
            RuneRooms.Enums.CustomCallback.PRE_GET_RUNE_GRID_SPRITE,
            gridEntityType
        )

        if type(newSpriteSheet) == "string" then
            return newSpriteSheet
        end

        return defaultSpriteSheet
    end
end


---@return string
local function GetPitSpriteSheet()
    local pitsSpriteMode = RuneRooms:GetPitsSpriteMode()

    if pitsSpriteMode == RuneRooms.Enums.GridSpriteMode.FORCE_FF then
        return PIT_SPRITE_FF
    elseif pitsSpriteMode == RuneRooms.Enums.GridSpriteMode.FORCE_VANILLA then
        return PIT_SPRITE
    else
        local defaultSpriteSheet = PIT_SPRITE

        local newSpriteSheet = Isaac.RunCallback(RuneRooms.Enums.CustomCallback.PRE_GET_RUNE_PIT_SPRITE)

        if type(newSpriteSheet) == "string" then
            return newSpriteSheet
        end

        return defaultSpriteSheet
    end
end


local function ReplaceStageAPIGfx()
    for gridType, _ in pairs(GRID_TYPES_SPRITE_REPLACE) do
        local gridSpriteSheet = GetGridSpriteSheet(gridType)
        StageAPI.GridGfx:SetGrid(gridSpriteSheet, gridType)
    end

    local pitSpriteSheet = GetPitSpriteSheet()

    StageAPI.GridGfx:SetPits(pitSpriteSheet)

    local roomGfx = StageAPI.RoomGfx(StageAPI.RoomGfx.Backdrops, StageAPI.GridGfx)
    StageAPI.ChangeRoomGfx(roomGfx)
end


function Backdrop:OnNewRoom()
    if not RuneRooms.Helpers:IsRuneRoom() then return end

    local roomDesc = TSIL.Rooms.GetRoomDescriptor()
    local rng = TSIL.RNG.NewRNG(roomDesc.DecorationSeed)

    if not REPENTOGON then
        SpawnFloor()
        SpawnWall()
    else
        local backDropID = Isaac.GetBackdropIdByName("Rune Backdrop")
        Game():GetRoom():SetBackdropType(backDropID, 1)
    end

    SpawnCrystalPillars(rng)

    SpawnWallDetails(rng)

    SpawnCrystalOverlays(rng)

    if StageAPI then
        ReplaceStageAPIGfx()
    end
end

RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    Backdrop.OnNewRoom
)


---@param pit GridEntityPit
local function ReplacePitSprite(pit)
    if StageAPI then return end

    local spriteSheet = GetPitSpriteSheet()

    local sprite = pit:GetSprite()
    sprite:ReplaceSpritesheet(0, spriteSheet)
    sprite:LoadGraphics()
end


---@param gridEntity GridEntity
local function TryReplaceGridEntitySprite(gridEntity)
    if StageAPI then return end

    if not GRID_TYPES_SPRITE_REPLACE[gridEntity:GetType()] then return end

    local spriteSheet = GetGridSpriteSheet(gridEntity:GetType())

    local sprite = gridEntity:GetSprite()
    sprite:ReplaceSpritesheet(0, spriteSheet)
    sprite:LoadGraphics()
end


---@param gridEntity GridEntity
function Backdrop:OnGridEntityInit(gridEntity)
    if not RuneRooms.Helpers:IsRuneRoom() then return end

    if gridEntity:GetType() == GridEntityType.GRID_PIT then
        ReplacePitSprite(gridEntity:ToPit())
    elseif gridEntity:GetType() == GridEntityType.GRID_DECORATION then
        TSIL.GridEntities.RemoveGridEntity(gridEntity, false)
    else
        TryReplaceGridEntitySprite(gridEntity)
    end
end

RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_GRID_ENTITY_INIT,
    Backdrop.OnGridEntityInit
)


---@param effect EntityEffect
function Backdrop:OnWallDetailUpdate(effect)
    local canShine = TSIL.Entities.GetEntityData(
        RuneRooms,
        effect,
        "CanShine"
    )
    if not canShine then return end

    local sprite = effect:GetSprite()
    if sprite:GetFrame() % 30 ~= 0 then return end

    local rng = effect:GetDropRNG()
    if rng:RandomFloat() >= 0.3 then return end

    local distance = TSIL.Random.GetRandomFloat(0, 20, rng)
    local angle = TSIL.Random.GetRandomInt(0, 360, rng)
    local posOffset = Vector.FromAngle(angle):Resized(distance)

    local shine = TSIL.EntitySpecific.SpawnEffect(
        EffectVariant.IMPACT,
        0,
        effect.Position + posOffset
    )
    local shineSprite = shine:GetSprite()

    shineSprite:Load(CRYSTAL_SHINE_ANM2, true)
    local animToPlay = "Idle1"
    if rng:RandomFloat() < 0.1 then
        animToPlay = "Idle2"
    end
    shineSprite:Play(animToPlay)
    shineSprite.Rotation = TSIL.Random.GetRandomInt(0, 360, rng)
    shineSprite.Color = Color(1, 1, 1, TSIL.Random.GetRandomFloat(0.3, 0.7, rng))
end

RuneRooms:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    Backdrop.OnWallDetailUpdate,
    EffectVariant.BACKDROP_DECORATION
)
