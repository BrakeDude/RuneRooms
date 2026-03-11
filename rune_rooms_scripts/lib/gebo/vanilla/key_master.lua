Gebo.AddSaveData("KeyMasterPrizeVariant",  {
    [1] = PickupVariant.PICKUP_CHEST,
    [2] = PickupVariant.PICKUP_LOCKEDCHEST,
    [3] = PickupVariant.PICKUP_REDCHEST,
    [4] = PickupVariant.PICKUP_BOMBCHEST,
    [5] = PickupVariant.PICKUP_MIMICCHEST,
    [6] = PickupVariant.PICKUP_HAUNTEDCHEST,
    [7] = PickupVariant.PICKUP_SPIKEDCHEST,
    [8] = PickupVariant.PICKUP_WOODENCHEST,
    [9] = PickupVariant.PICKUP_ETERNALCHEST,
    [10] = PickupVariant.PICKUP_COLLECTIBLE,
    [11] = PickupVariant.PICKUP_TRINKET,
})

local function SpawnPrize(type, variant, subtype, pos, rng)
    local isTrinket = variant == PickupVariant.PICKUP_TRINKET
    local vel = Gebo.GetSpawnPickupVelocity(pos, rng, 1)
    if not isTrinket then
        vel:Resize(20 + rng:RandomInt(10) + rng:RandomFloat())
    end
    Isaac.Spawn(type, variant, subtype, pos, vel, nil)
end

local function Beggar(slot, player, uses, rng)
    if uses > 0 or uses == -1 then
        local sprite = slot:GetSprite()
        if sprite:IsPlaying("Idle") then
            SFXManager():Play(SoundEffect.SOUND_KEY_DROP0, 1, 0, false)
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
            local prizeVariant = Gebo.GetSaveDataByKey("KeyMasterPrizeVariant")
            local var = prizeVariant[rng:RandomInt(#prizeVariant)+1]
            if var == PickupVariant.PICKUP_COLLECTIBLE then
                local itemPool = Game():GetItemPool()
                local poolItem = itemPool:GetCollectible(ItemPoolType.POOL_KEY_MASTER, true, slot.DropSeed)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, var, poolItem, Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 40)), Vector.Zero, nil)
                Gebo.GetData(slot).Teleport = true
            elseif var == PickupVariant.PICKUP_TRINKET then
                SpawnPrize(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_PAPER_CLIP, slot.Position, rng)
                Game():GetItemPool():RemoveTrinket(TrinketType.TRINKET_PAPER_CLIP)
                Gebo.GetData(slot).Teleport = true
                table.remove(prizeVariant, 11)
                Gebo.SetSaveDataByKey("KeyMasterPrizeVariant", prizeVariant)
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

Gebo.AddMachineBeggar(7, Beggar, 6)