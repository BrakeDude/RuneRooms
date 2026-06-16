local NegativeAlgiz = {}

local INVINCIBILITY_DURATION = 3 * 30 -- 3 seconds (at 30 fps)

---@param entity Entity
function NegativeAlgiz:OnEntityDamage(entity)
    if not RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.ALGIZ) then return end

    if entity.Type == EntityType.ENTITY_PLAYER then return end

    local room = RuneRooms.Room()
    local frameCount = room:GetFrameCount()

    if frameCount <= INVINCIBILITY_DURATION then
        entity:SetColor(
            Color(1, 1, 1, 1, 0.4, 0.4, 0.4),
            10,
            1,
            true,
            true
        )
        return false
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    NegativeAlgiz.OnEntityDamage
)