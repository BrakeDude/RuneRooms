local prizeVariant = {
    [1] = PickupVariant.PICKUP_TAROTCARD,
    [2] = PickupVariant.PICKUP_TAROTCARD,
    [3] = PickupVariant.PICKUP_TAROTCARD,
    [4] = PickupVariant.PICKUP_PILL,
    [5] = PickupVariant.PICKUP_PILL,
    [6] = PickupVariant.PICKUP_PILL,
    [7] = PickupVariant.PICKUP_TRINKET,
    [8] = PickupVariant.PICKUP_TRINKET,
    [9] = PickupVariant.PICKUP_COLLECTIBLE, 
}

local function SpawnPrize(type, variant, subtype, pos, rng)
    if type == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_TRINKET then
        subtype = Game():GetItemPool():GetTrinket()
    end
    local vel = Gebo.GetSpawnPickupVelocity(pos, rng, 1)
    Isaac.Spawn(type, variant, subtype, pos, vel, nil)
end

local function Beggar(slot, player, uses, rng)
    if uses > 0 or uses == -1 then
        local sprite = slot:GetSprite()
        if sprite:IsPlaying("Idle") then
            SFXManager():Play(SoundEffect.SOUND_TEARIMPACTS, 1, 0, false)
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
                local poolItem = itemPool:GetCollectible(ItemPoolType.POOL_DEMON_BEGGAR, true, slot.DropSeed)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, var, poolItem, Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 40)), Vector.Zero, nil)
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

Gebo.AddMachineBeggar(5, Beggar, 6)