local pickupInSlot = { "Coin", "Bomb", "Key" }

local function Machine(slot, player, uses, rng)
	local GLITCH = Epiphany.Slot.GLITCH
	local sprite = slot:GetSprite()
	if sprite:IsPlaying("OutOfPrizes") or GLITCH:isDead(sprite) then
		return true
	end
	if not (GLITCH:isSpriteBusy(sprite) or slot:GetData().ExtraActivations and slot:GetData().ExtraActivations > 0) then
		sprite:PlayOverlay(pickupInSlot[rng:RandomInt(3) + 1] .. "Insert", true)

		slot:GetData().ExtraActivations = rng:RandomInt(GLITCH.MAX_EXTRA_ACTIVATIONS - GLITCH.MIN_EXTRA_ACTIVATIONS)
			+ GLITCH.MIN_EXTRA_ACTIVATIONS
		SFXManager():Play(GLITCH.SFX_INSERT)

		slot:GetData().LastTouchedPlayer = player or Isaac.GetPlayer(0)
		uses = uses - 1
	end
	return uses
end

local function MachineWave8(slot, uses, player)
	local sprite = slot:GetSprite()
	if sprite:IsPlaying("OutOfPrizes") or sprite:IsPlaying("Death") or sprite:IsPlaying("Broken") then
		return true
	end
	local data = slot:GetData()
	if slot:GetState() == SlotState.IDLE and (not data.EP_ExtraActivations or data.EP_ExtraActivations <= 0) then
		local GLITCH = Epiphany.Slot.GLITCH
		local rng = slot:GetDropRNG()
		data.EP_ExtraActivations = rng:RandomInt(GLITCH.MAX_EXTRA_ACTIVATIONS - GLITCH.MIN_EXTRA_ACTIVATIONS)
			+ GLITCH.MIN_EXTRA_ACTIVATIONS
		Epiphany.sfxman:Play(GLITCH.SFX_INSERT)

		sprite:PlayOverlay(pickupInSlot[rng:RandomInt(3) + 1] .. "Insert", true)
		data.EP_GlitchSlotPlayer = player or Isaac.GetPlayer(0)
		sprite.PlaybackSpeed = 1
		slot:SetState(SlotState.REWARD)
		uses = uses - 1
	end
	return uses
end

Gebo:AddCallback(REPENTOGON and ModCallbacks.MC_POST_MODS_LOADED or ModCallbacks.MC_POST_GAME_STARTED, function()
	if Epiphany then
		if not Gebo.IsGeboSlot({ Type = 6, Variant = Epiphany.Slot.GLITCH.ID, SubType = -1 }) then
			if Epiphany.WAVE_NUMBER ~= "7" then
				Gebo.AddMachineBeggar(Epiphany.Slot.GLITCH.ID, MachineWave8, nil, 6, -1)
				Gebo.ChangeRepentogonTag(Epiphany.Slot.GLITCH.ID, true, 6, -1)
			else
				Gebo.AddMachineBeggar(Epiphany.Slot.GLITCH.ID, Machine, nil, 6, -1)
			end
		end
	end
end)
