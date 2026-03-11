local prizeVariant = {
    [1] = PickupVariant.PICKUP_COIN,
    [2] = PickupVariant.PICKUP_COIN,
    [3] = PickupVariant.PICKUP_HEART,
    [4] = PickupVariant.PICKUP_HEART,
    [5] = PickupVariant.PICKUP_COLLECTIBLE,
}

local function SpawnPrize(type, variant, subtype, pos, rng)
    local vel = Gebo.GetSpawnPickupVelocity(pos, rng, 1)
    Isaac.Spawn(type, variant, subtype, pos, vel, nil)
end

local function Beggar(slot, player, uses, rng)
    if uses > 0 or uses == -1 then
        local sprite = slot:GetSprite()
        if sprite:IsPlaying("Idle") then
            SFXManager():Play(SoundEffect.SOUND_SCAMPER, 1, 0, false)
            if rng:RandomFloat() <= 0.3 then
                sprite:Play("PayPrize", true)
            else
                sprite:Play("PayNothing", true)
            end
        end
        if sprite:IsFinished("PayNothing") then
            sprite:Play("Idle", true)
            uses = uses - 1
        end
        if sprite:IsFinished("PayPrize") then
            sprite:Play("Prize", true)
        end
        if sprite:IsFinished("Prize") then
            if Gebo.GetData(slot).Teleport then
                sprite:Play("Teleport", true)
            else
                sprite:Play("Idle", true)
                uses = uses - 1
            end
        end
        if sprite:IsEventTriggered("Prize") then
            SFXManager():Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false)
            local var = prizeVariant[rng:RandomInt(#prizeVariant)+1]
            if var == PickupVariant.PICKUP_COLLECTIBLE then
                local itemPool = Game():GetItemPool()
                local poolItem = itemPool:GetCollectible(ItemPoolType.POOL_BOMB_BUM, true, slot.DropSeed)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, var, poolItem, Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 40)), Vector.Zero, nil)
                Gebo.GetData(slot).Teleport = true
            else
                SpawnPrize(EntityType.ENTITY_PICKUP, var, 0, slot.Position, rng)
                if var == PickupVariant.PICKUP_COIN then
                    local extra = rng:RandomInt(3)
                    while extra > 0 do
                        SpawnPrize(EntityType.ENTITY_PICKUP, var, 0, slot.Position, rng)
                        extra = extra - 1
                    end
                end
            end
        end
        if sprite:IsFinished("Teleport") then
            slot:Remove()
            return true
        end
    end
    return uses
end

Gebo.AddMachineBeggar(9, Beggar, 6)