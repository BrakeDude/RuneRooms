local GeboNegative = {}


---@param slot Entity
local function DestroySlot(slot)
    TSIL.EntitySpecific.SpawnEffect(
        EffectVariant.BOMB_EXPLOSION,
        0,
        slot.Position
    )

    RuneRooms.Game:BombExplosionEffects(
        slot.Position,
        0,
        nil,
        nil,
        nil,
        0.0001
    )

    RuneRooms.SFX:Stop(SoundEffect.SOUND_EXPLOSION_WEAK)

    local pickups = TSIL.EntitySpecific.GetPickups()
    TSIL.Utils.Tables.ForEach(pickups, function (_, pickup)
        if pickup.FrameCount == 0 then
            pickup:Remove()
        end
    end)
end


---@param slot Entity
function GeboNegative:OnSlotInit(slot)
    if not RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.GEBO) then return end

    DestroySlot(slot)
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_SLOT_INIT,
    GeboNegative.OnSlotInit
)


function GeboNegative:OnGeboNegativeActivation()
    local slots = Isaac.FindByType(EntityType.ENTITY_SLOT)

    TSIL.Utils.Tables.ForEach(slots, function (_, slot)
        DestroySlot(slot)
    end)
end
RuneRooms:AddCallback(
    RuneRooms.Enums.CustomCallback.POST_GAIN_RUNE_CURSE,
    GeboNegative.OnGeboNegativeActivation,
    RuneRooms.Enums.RuneEffect.GEBO
)