local JeraPositive = {}


---@param player EntityPlayer
function JeraPositive:OnPeffectUpdate(player)
    if not RuneRooms:IsRuneBlessingActive(RuneRooms.Enums.RuneEffect.JERA) then
        if player:GetInnateCollectibleCount(CollectibleType.COLLECTIBLE_CONTRACT_FROM_BELOW, "RUNE_ROOMS_JERA_BLESSING") > 0 then
            player:ClearInnateItemGroup("RUNE_ROOMS_JERA_BLESSING")
        end
        return
    end
    if player:GetInnateCollectibleCount(CollectibleType.COLLECTIBLE_CONTRACT_FROM_BELOW, "RUNE_ROOMS_JERA_BLESSING") == 0 then
        player:SetInnateCollectibleCount(CollectibleType.COLLECTIBLE_CONTRACT_FROM_BELOW, 1, "RUNE_ROOMS_JERA_BLESSING", false)
    end
end
--[[RuneRooms:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    JeraPositive.OnPeffectUpdate
)]]

---@param rng RNG
---@param spawnPos Vector
function JeraPositive:DupePickups(rng, spawnPos)
    if not RuneRooms:IsRuneBlessingActive(RuneRooms.Enums.RuneEffect.JERA) then return end

    for _, pickup in ipairs(Isaac.FindByType(5)) do
        
        if pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then
            
        end
    end
end
RuneRooms:AddPriorityCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    math.huge,
    JeraPositive.DupePickups
)