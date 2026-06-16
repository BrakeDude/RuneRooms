local RunePad = {}

local RUNE_PAD_SPRITE_SHEET = "gfx/grid/grid_rune_pad_"

---@param runePad Entity
local function GetRunePadData(runePad)
    local padsData = RuneRooms:FloorSave(runePad)

    if padsData.activated == nil then
        padsData.activated = false
    end

    return padsData
end


local function AreAllRunePadsActivated()
    local runePads = Isaac.FindByType(
        EntityType.ENTITY_GENERIC_PROP,
        RuneRooms.Enums.GenericPropVariant.RUNE_PAD
    )

    return TSIL.Utils.Tables.All(runePads, function (_, runePad)
        local data = GetRunePadData(runePad)
        return data.activated
    end)
end


local function ActivateGiantRuneCrystals()
    local runeCrystals = Isaac.FindByType(
        EntityType.ENTITY_GENERIC_PROP,
        RuneRooms.Enums.GenericPropVariant.GIANT_RUNE_CRYSTAL
    )

    TSIL.Utils.Tables.ForEach(runeCrystals, function (_, runeCrystal)
        RuneRooms:ActivateGiantCrystal(runeCrystal)
    end)
end


---@param runePad Entity
function RunePad:OnRunePadInit(runePad)
    runePad.DepthOffset = -80
    runePad.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

    local runeEffect = RuneRooms:GetRuneEffectForFloor()
    local sprite = runePad:GetSprite()
    local spriteSheet = RUNE_PAD_SPRITE_SHEET .. RuneRooms.Constants.RUNE_NAMES[runeEffect] .. ".png"
    for i = 0, sprite:GetLayerCount()-1, 1 do
        sprite:ReplaceSpritesheet(i, spriteSheet)
    end
    sprite:LoadGraphics()

    local data = GetRunePadData(runePad)
    local anim = "IdleOff"
    if data.activated then
        anim = "IdleOn"
    end
    sprite:Play(anim, true)
end
RuneRooms:AddCallback(
    RuneRooms.Enums.CustomCallback.POST_GENERIC_PROP_INIT,
    RunePad.OnRunePadInit,
    RuneRooms.Enums.GenericPropVariant.RUNE_PAD
)


---@param runePad Entity
function RunePad:OnRunePadUpdate(runePad)
    local data = GetRunePadData(runePad)
    local sprite = runePad:GetSprite()

    if not data.activated and sprite:IsPlaying("IdleOff") then
        local room = RuneRooms.Room()
        local closestPlayer = RuneRooms.Game:GetNearestPlayer(runePad.Position)

        local padGridIndex = room:GetGridIndex(runePad.Position)
        local playerGridIndex = room:GetGridIndex(closestPlayer.Position)

        if padGridIndex == playerGridIndex then
            sprite:Play("TurnOn", true)
        end
    end

    if sprite:IsFinished("TurnOn") then
        RuneRooms.SFX:Play(RuneRooms.Enums.SoundEffect.RUNE_PAD_ACTIVATION)
        data.activated = true
        sprite:Play("IdleOn", true)

        if AreAllRunePadsActivated() then
            ActivateGiantRuneCrystals()
        end
    end
end
RuneRooms:AddCallback(
    RuneRooms.Enums.CustomCallback.POST_GENERIC_PROP_UPDATE,
    RunePad.OnRunePadUpdate,
    RuneRooms.Enums.GenericPropVariant.RUNE_PAD
)