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

local function MachineWave8(slot, uses, player)
    local sprite = slot:GetSprite()
    if sprite:IsPlaying("OutOfPrizes") or sprite:IsPlaying("Death") or sprite:IsPlaying("Broken") then
		return true
	end
    if slot:GetState() == SlotState.IDLE then
        if not slot:GetData().EP_PainOMaticPlayer then
            slot:GetData().EP_PainOMaticPlayer = player or Epiphany.Game:GetNearestPlayer(slot.Position)
        end
        Epiphany:DisableEIDForThisMachine(slot)
        sprite:Play("Initiate")
        Epiphany.sfxman:Play(SoundEffect.SOUND_COIN_SLOT)
        slot:SetState(SlotState.REWARD)
        uses = uses - 1
    end
    return uses
end

Gebo:AddCallback(REPENTOGON and ModCallbacks.MC_POST_MODS_LOADED or ModCallbacks.MC_POST_GAME_STARTED, function()
	if Epiphany then
		if not Gebo.IsGeboSlot({ Type = 6, Variant = Epiphany.Slot.PAIN_O_MATIC.ID, SubType = -1 }) then
			if Epiphany.WAVE_NUMBER ~= "7" then
				Gebo.AddMachineBeggar(Epiphany.Slot.PAIN_O_MATIC.ID, MachineWave8, nil, 6, -1)
				Gebo.ChangeRepentogonTag(Epiphany.Slot.PAIN_O_MATIC.ID, true, 6, -1)
			else
				Gebo.AddMachineBeggar(Epiphany.Slot.PAIN_O_MATIC.ID, Machine, nil, 6, -1)
			end
		end
	end
end)