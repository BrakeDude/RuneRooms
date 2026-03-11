Gebo.AddSaveData("RottenBumPrizeVariant", 
{
    [1] = PickupVariant.PICKUP_HEART,
    [2] = PickupVariant.PICKUP_HEART,
    [3] = PickupVariant.PICKUP_HEART,
    [4] = "Fly",
    [5] = "Fly",
    [6] = "Spider",
    [7] = "Spider",
    [8] = "Fart",
    [9] = "Fart",
    [10] = PickupVariant.PICKUP_COLLECTIBLE, 
    [11] = PickupVariant.PICKUP_TRINKET, 
})

Gebo.AddSaveData("RottenBumTrinkets",{
    TrinketType.TRINKET_FISH_HEAD,
    TrinketType.TRINKET_FISH_TAIL,
    TrinketType.TRINKET_ROTTEN_PENNY,
    TrinketType.TRINKET_BOBS_BLADDER,
})

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
            local prizeVariant = Gebo.GetSaveDataByKey("RottenBumPrizeVariant")
            local var = prizeVariant[rng:RandomInt(#prizeVariant)+1]
            if var ~= "Fart" then SFXManager():Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false) end
            if var == PickupVariant.PICKUP_COLLECTIBLE then
                local itemPool = Game():GetItemPool()
                local poolItem = itemPool:GetCollectible(ItemPoolType.POOL_ROTTEN_BEGGAR, true, slot.DropSeed)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, var, poolItem, Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 40)), Vector.Zero, nil)
                Gebo.GetData(slot).Teleport = true
            elseif var == PickupVariant.PICKUP_TRINKET then
                local trinkets = Gebo.GetSaveDataByKey("RottenBumTrinkets")
                local i = rng:RandomInt(#trinkets) + 1
                SpawnPrize(EntityType.ENTITY_PICKUP, var, trinkets[i], slot.Position, rng)
                Game():GetItemPool():RemoveTrinket(trinkets[i])
                table.remove(trinkets, i)
                Gebo.SetSaveDataByKey("RottenBumTrinkets", trinkets)
                if #trinkets == 0 then
                    table.remove(prizeVariant, #prizeVariant)
                    Gebo.SetSaveDataByKey("RottenBumPrizeVariant", prizeVariant)
                end
            elseif var == "Fly" then
                player:AddBlueFlies(rng:RandomInt(3)+1, slot.Position, nil)
            elseif var == "Spider" then
                for i = 1, rng:RandomInt(3) + 1 do
                    local vel = Gebo.GetSpawnPickupVelocity(slot.Position, rng, 1)
                    vel.X = vel.X * rng:RandomInt(13)
                    vel.Y = vel.Y * (rng:RandomInt(15) + 1)
                    player:ThrowBlueSpider(slot.Position, slot.Position + vel)
                end
            elseif var == "Fart" then
                Game():Fart(slot.Position, 0)
            else
                local heart = {HeartSubType.HEART_ROTTEN, HeartSubType.HEART_BONE}
                SpawnPrize(EntityType.ENTITY_PICKUP, var, heart[rng:RandomInt(2) + 1], slot.Position, rng)
            end
        end
        if sprite:IsFinished("Teleport") then
            slot:Remove()
            return true
        end
    end
    return uses
end

Gebo.AddMachineBeggar(18, Beggar, 6)