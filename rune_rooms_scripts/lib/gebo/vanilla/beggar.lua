local prizeVariant = {
    [1] = PickupVariant.PICKUP_HEART,
    [2] = PickupVariant.PICKUP_HEART,
    [3] = PickupVariant.PICKUP_BOMB,
    [4] = PickupVariant.PICKUP_BOMB,
    [5] = PickupVariant.PICKUP_KEY,
    [6] = PickupVariant.PICKUP_KEY,
    [7] = PickupVariant.PICKUP_TAROTCARD,
    [8] = PickupVariant.PICKUP_TAROTCARD,
    [9] = PickupVariant.PICKUP_COLLECTIBLE, 
}

local food = {
    CollectibleType.COLLECTIBLE_BREAKFAST,
    CollectibleType.COLLECTIBLE_LUNCH,
    CollectibleType.COLLECTIBLE_DINNER,
    CollectibleType.COLLECTIBLE_DESSERT,
    CollectibleType.COLLECTIBLE_ROTTEN_MEAT,
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
                if rng:RandomFloat() <= 0.5 then
                    local col = food[rng:RandomInt(#food)+1]
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, var, col, Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 40)), Vector.Zero, nil)
                    itemPool:RemoveCollectible(col)
                else
                    local poolItem = itemPool:GetCollectible(ItemPoolType.POOL_BEGGAR, true, slot.DropSeed)
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, var, poolItem, Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 40)), Vector.Zero, nil)
                end
                Gebo.GetData(slot).Teleport = true
            else
                SpawnPrize(EntityType.ENTITY_PICKUP, var, 0, slot.Position, rng)
            end
        end
        if sprite:IsFinished("Teleport") then
            slot:Remove()
            return true
        end
    end
    return uses
end

Gebo.AddMachineBeggar(4, Beggar, 6)