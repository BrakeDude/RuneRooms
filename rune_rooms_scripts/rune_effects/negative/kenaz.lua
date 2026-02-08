local KenazNegative = {}

local SMOKE_CLOUD_DURATION = 10 * 30


---@param npc EntityNPC
function KenazNegative:OnNPCDeath(npc)
    if not RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.KENAZ) then return end

    local effect = TSIL.EntitySpecific.SpawnEffect(
        EffectVariant.SMOKE_CLOUD,
        0,
        npc.Position
    )

    effect.Timeout = SMOKE_CLOUD_DURATION
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    KenazNegative.OnNPCDeath
)