local function Machine(slot, player, uses, rng)
    local PAIN_O_MATIC = Epiphany.Slot.PAIN_O_MATIC
    local sprite = slot:GetSprite()
    if PAIN_O_MATIC:isDead(sprite) then
        return true
    end
    if sprite:IsPlaying("Wiggle") and sprite:GetFrame() == 17 then
        uses = uses - 1
    end
    if sprite:IsFinished("Initiate") then
        sprite:Play("Wiggle", true)
    end
    if sprite:IsPlaying("Idle") then
        Epiphany:DisableEIDForThisMachine(slot)
        slot:GetData().FreeActivation = false
        sprite:Play("Initiate", true)
        SFXManager():Play(SoundEffect.SOUND_COIN_SLOT)
        slot:GetData().ActivePlayer = player
	end
    return uses
end

Gebo:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	if Epiphany then
        if not Gebo.IsGeboSlot({Type = 6, Variant = Epiphany.Slot.PAIN_O_MATIC.ID, SubType = -1}) then
		    Gebo.AddMachineBeggar(Epiphany.Slot.PAIN_O_MATIC.ID, Machine, nil, 6, -1)
        end
	end
end)