local DoubleLockedChest = {}


---@param collider Entity
---@return boolean
local function ColliderTryOpenChest(collider)
    local player = collider:ToPlayer()

    if not player then return false end

    if player:GetNumKeys() == 0 then return false end

    player:AddKeys(-1)
    return true
end


---@param chest EntityPickup
local function OpenChest(chest)
    chest:Morph(
        EntityType.ENTITY_PICKUP,
        PickupVariant.PICKUP_LOCKEDCHEST,
        ChestSubType.CHEST_CLOSED,
        true,
        true
    )
    chest.Wait = 20

    local sprite = chest:GetSprite()
    sprite:SetFrame(8)
    RuneRooms.SFX:Play(SoundEffect.SOUND_UNLOCK00)
end


---@param chest EntityPickup
---@param collider Entity
function DoubleLockedChest:OnDoubleLockedChestCollision(chest, collider)
    if ColliderTryOpenChest(collider) then
        OpenChest(chest)
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_PRE_PICKUP_COLLISION,
    DoubleLockedChest.OnDoubleLockedChestCollision,
    RuneRooms.Enums.PickupVariant.DOUBLE_LOCKED_CHEST
)


---@param chest EntityPickup
function DoubleLockedChest:OnDoubleLockedChestUpdate(chest)
    local sprite = chest:GetSprite()
    if sprite:IsEventTriggered("DropSound") then
        RuneRooms.SFX:Play(SoundEffect.SOUND_CHEST_DROP)
    end

    chest.Velocity = chest.Velocity / 1.1
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_PICKUP_UPDATE,
    DoubleLockedChest.OnDoubleLockedChestUpdate,
    RuneRooms.Enums.PickupVariant.DOUBLE_LOCKED_CHEST
)