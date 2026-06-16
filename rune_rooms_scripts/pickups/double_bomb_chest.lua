local DoubleBombChest = {}


---@param chest EntityPickup
local function OpenChest(chest)
    chest:Morph(
        EntityType.ENTITY_PICKUP,
        PickupVariant.PICKUP_BOMBCHEST,
        ChestSubType.CHEST_CLOSED,
        true,
        true
    )
    chest.Wait = 20

    local sprite = chest:GetSprite()
    sprite:SetFrame(8)
end


---@param bomb EntityBomb
function DoubleBombChest:OnBombExplode(bomb)
    local radius = TSIL.Bombs.GetBombRadiusFromDamage(bomb.ExplosionDamage)
    local closeEntities = Isaac.FindInRadius(bomb.Position, radius)

    local doubleBombChests = TSIL.Utils.Tables.Filter(closeEntities, function (_, entity)
        return entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == RuneRooms.Enums.PickupVariant.DOUBLE_BOMB_CHEST
    end)

    TSIL.Utils.Tables.ForEach(doubleBombChests, function (_, chest)
        OpenChest(chest:ToPickup())
    end)
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_BOMB_EXPLODED,
    DoubleBombChest.OnBombExplode
)


---@param chest EntityPickup
function DoubleBombChest:OnDoubleBombChestUpdate(chest)
    local sprite = chest:GetSprite()
    if sprite:IsEventTriggered("DropSound") then
        RuneRooms.SFX:Play(SoundEffect.SOUND_CHEST_DROP)
    end

    chest.Velocity = chest.Velocity / 1.1
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_PICKUP_UPDATE,
    DoubleBombChest.OnDoubleBombChestUpdate,
    RuneRooms.Enums.PickupVariant.DOUBLE_BOMB_CHEST
)