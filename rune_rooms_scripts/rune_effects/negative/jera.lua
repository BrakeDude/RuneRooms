local JeraNegative = {}

local PICKUP_TIMEOUT = 5 * 30
local DISAPPEARING_PICKUP_VARIANTS = {
    [PickupVariant.PICKUP_BOMB] = true,
    [PickupVariant.PICKUP_COIN] = true,
    [PickupVariant.PICKUP_HEART] = true,
    [PickupVariant.PICKUP_KEY] = true,
    [PickupVariant.PICKUP_LIL_BATTERY] = true,
    [PickupVariant.PICKUP_POOP] = true,
}


---@param pickup EntityPickup
function JeraNegative:OnPickupInit(pickup)
    if not RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.JERA) then return end

    if DISAPPEARING_PICKUP_VARIANTS[pickup.Variant] then
        pickup.Timeout = PICKUP_TIMEOUT
    end
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_PICKUP_INIT_LATE,
    JeraNegative.OnPickupInit
)