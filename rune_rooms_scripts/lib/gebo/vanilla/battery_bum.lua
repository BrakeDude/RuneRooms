Gebo.AddSaveData("BatteryBumPrizeVariant", {
    [1] = "Charge",
    [2] = "Charge",
    [3] = PickupVariant.PICKUP_LIL_BATTERY,
    [4] = PickupVariant.PICKUP_LIL_BATTERY,
    [5] = PickupVariant.PICKUP_COLLECTIBLE,
    [6] = PickupVariant.PICKUP_TRINKET,
})

local function SpawnPrize(type, variant, subtype, pos, rng)
    local vel = Gebo.GetSpawnPickupVelocity(pos, rng, 1)
    local battery = Isaac.Spawn(type, variant, subtype, pos, vel, nil):ToPickup()
    if battery.SubType == 4 then
        battery:Morph(type, variant, BatterySubType.BATTERY_NORMAL)
    end
end

local function GetFullCharge(player, slot)
    return player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
end

local function Beggar(slot, player, uses, rng)
    if uses > 0 or uses == -1 then
        local sprite = slot:GetSprite()
        if sprite:IsPlaying("Idle") then
            SFXManager():Play(SoundEffect.SOUND_SCAMPER, 1, 0, false)
            if rng:RandomFloat() <= 0.4 then
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
            local prizeVariant = Gebo.GetSaveDataByKey("BatteryBumPrizeVariant")
            local var = prizeVariant[rng:RandomInt(#prizeVariant)+1]
            if var == PickupVariant.PICKUP_COLLECTIBLE then
                SFXManager():Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false)
                local itemPool = Game():GetItemPool()
                local poolItem = itemPool:GetCollectible(ItemPoolType.POOL_BATTERY_BUM, true, slot.DropSeed)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, var, poolItem, Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 40)), Vector.Zero, nil)
                Gebo.GetData(slot).Teleport = true
            elseif var == PickupVariant.PICKUP_TRINKET then
                SpawnPrize(EntityType.ENTITY_PICKUP, var, TrinketType.TRINKET_AAA_BATTERY, slot.Position, rng)
                Game():GetItemPool():RemoveTrinket(TrinketType.TRINKET_AAA_BATTERY)
                table.remove(prizeVariant, 6)
                Gebo.SetSaveDataByKey("BatteryBumPrizeVariant", prizeVariant)
                SFXManager():Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false)
            elseif var == "Charge" then
                SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE, 1, 0, false)
                player:AnimateHappy()
                local addCharge = rng:RandomInt(3) + 1
                local prev = addCharge
                local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, player.Position, Vector.Zero, nil):ToEffect()
                eff.DepthOffset = 30
                eff.SpriteOffset = Vector(0, -20)
                for i = 0, 2 do
                    if addCharge > 0 then
                        local colConfig = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(i))
                        if colConfig and colConfig.ChargeType ~= 2 and colConfig.MaxCharges > 0 and GetFullCharge(player, i) < colConfig.MaxCharges * 2 then
                            if colConfig.ChargeType == 1 then
                                if GetFullCharge(player, i) < colConfig.MaxCharges then
                                    if addCharge > 1 then
                                        player:SetActiveCharge(colConfig.MaxCharges * 2, i)
                                        addCharge = addCharge - 2
                                    else
                                        player:SetActiveCharge(colConfig.MaxCharges, i)
                                        addCharge = addCharge - 1
                                    end
                                else
                                    player:SetActiveCharge(colConfig.MaxCharges * 2, i)
                                    addCharge = addCharge - 1
                                end
                                Game():GetHUD():FlashChargeBar(player, i)
                            else
                                local charge = GetFullCharge(player, i)
                                if charge < colConfig.MaxCharges * 2 then
                                    player:SetActiveCharge(charge + addCharge, i)
                                    addCharge = math.max(0, addCharge - (colConfig.MaxCharges * 2 - charge))
                                    Game():GetHUD():FlashChargeBar(player, i)
                                end
                            end
                        end
                    end
                end
                if addCharge == prev then Game():GetHUD():FlashChargeBar(player, ActiveSlot.SLOT_PRIMARY) end
            else
                SpawnPrize(EntityType.ENTITY_PICKUP, var, 0, slot.Position, rng)
                SFXManager():Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false)
            end
        end
        if sprite:IsFinished("Teleport") then
            slot:Remove()
            return true
        end
    end
    return uses
end

Gebo.AddMachineBeggar(13, Beggar, 6)