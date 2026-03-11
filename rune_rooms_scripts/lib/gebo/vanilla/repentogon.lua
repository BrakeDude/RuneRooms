local SlotLocal = {}
if not REPENTOGON then return end

Gebo.AddMachineBeggar(SlotVariant.DONATION_MACHINE)
Gebo.AddMachineBeggar(SlotVariant.GREED_DONATION_MACHINE)

for i = 1,18 do
    Gebo.ChangeRepentogonTag(i, true)
end

local machineSFX = {
    [SlotVariant.SLOT_MACHINE] = SoundEffect.SOUND_COIN_SLOT,
    [SlotVariant.BLOOD_DONATION_MACHINE] = SoundEffect.SOUND_BLOODBANK_TOUCHED,
    [SlotVariant.FORTUNE_TELLING_MACHINE] = SoundEffect.SOUND_COIN_SLOT,
    [SlotVariant.BEGGAR] = SoundEffect.SOUND_SCAMPER,
    [SlotVariant.DEVIL_BEGGAR] = SoundEffect.SOUND_TEARIMPACTS,
    [SlotVariant.KEY_MASTER] = SoundEffect.SOUND_KEY_DROP0,
    [SlotVariant.BOMB_BUM] = SoundEffect.SOUND_SCAMPER,
    [SlotVariant.BATTERY_BUM] = SoundEffect.SOUND_SCAMPER,
    [SlotVariant.ROTTEN_BEGGAR] = SoundEffect.SOUND_SCAMPER,
    [SlotVariant.CRANE_GAME] = SoundEffect.SOUND_COIN_SLOT,
    [SlotVariant.CONFESSIONAL] = SoundEffect.SOUND_NULL,
}

function SlotLocal:UpdateSlot(slot)
    local data = Gebo.GetData(slot)
    if data.GeboUses and data.GeboUses > 0 then
        local sprite = slot:GetSprite()
        if slot:GetState() == 1 then
            sprite:Play("Initiate", false)
            if slot.Variant == SlotVariant.CONFESSIONAL then
                sprite:PlayOverlay("HeartInsert", true)
            end
            SFXManager():Play(machineSFX[slot.Variant], 1, 0)
            slot:SetTimeout(30)
            slot:SetState(2)
            data.GeboUses = data.GeboUses - 1
        end
    end
end
Gebo:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, SlotLocal.UpdateSlot, SlotVariant.SLOT_MACHINE)
Gebo:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, SlotLocal.UpdateSlot, SlotVariant.BLOOD_DONATION_MACHINE)
Gebo:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, SlotLocal.UpdateSlot, SlotVariant.FORTUNE_TELLING_MACHINE)
Gebo:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, SlotLocal.UpdateSlot, SlotVariant.CRANE_GAME)
Gebo:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, SlotLocal.UpdateSlot, SlotVariant.CONFESSIONAL)

function SlotLocal:UpdateDono(slot)
    local data = Gebo.GetData(slot)
    if data.GeboUses and data.GeboUses > 0 then
        local sprite = slot:GetSprite()
        if slot:GetState() == 3 then
            return
        end
        if slot:GetState() == 1 then
            slot:SetState(2)
            slot:SetTimeout(5)
            sprite:PlayOverlay("CoinInsert", true)
        end
        if sprite:IsOverlayEventTriggered("CoinInsert") then
            data.GeboUses = data.GeboUses - 1
        end
        if sprite:IsOverlayFinished("CoinInsert") then
            slot:SetState(1)
        end
    end
end
Gebo:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, SlotLocal.UpdateDono, SlotVariant.DONATION_MACHINE)
Gebo:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, SlotLocal.UpdateDono, SlotVariant.GREED_DONATION_MACHINE)
Gebo:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, SlotLocal.UpdateDono, SlotVariant.SHOP_RESTOCK_MACHINE)

function SlotLocal:UpdateBeggar(slot)
    local data = Gebo.GetData(slot)
    local sprite = slot:GetSprite()
    if data.GeboUses and data.GeboUses > 0 then
        if slot:GetState() == 4 then
            return
        end
        if slot:GetState() == 1 and sprite:IsPlaying("Idle") then
            SFXManager():Play(machineSFX[slot.Variant], 1, 0)
            slot:SetTimeout(30)
            local rng = slot:GetDropRNG()
            if rng:RandomInt(3) == 0 then
                slot:SetState(2)
                sprite:Play("PayPrize", false)
            else
                sprite:Play("PayNothing", false)
            end
            data.GeboUses = data.GeboUses - 1
        end
        if sprite:IsFinished("PayNothing") then
            sprite:Play("Idle", false)
        end
    end
end
Gebo:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, SlotLocal.UpdateBeggar, SlotVariant.BEGGAR)
Gebo:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, SlotLocal.UpdateBeggar, SlotVariant.DEVIL_BEGGAR)
Gebo:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, SlotLocal.UpdateBeggar, SlotVariant.KEY_MASTER)
Gebo:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, SlotLocal.UpdateBeggar, SlotVariant.BOMB_BUM)
Gebo:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, SlotLocal.UpdateBeggar, SlotVariant.BATTERY_BUM)
Gebo:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, SlotLocal.UpdateBeggar, SlotVariant.ROTTEN_BEGGAR)