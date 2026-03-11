local pickupInSlot = {"Coin", "Bomb", "Key"}

local function Machine(slot, player, uses, rng)
    local GLITCH = Epiphany.Slot.GLITCH
    local sprite = slot:GetSprite()
    if not (GLITCH:isSpriteBusy(sprite) or slot:GetData().ExtraActivations and slot:GetData().ExtraActivations > 0) then      
        sprite:PlayOverlay(pickupInSlot[rng:RandomInt(3) + 1].."Insert", true)

		slot:GetData().ExtraActivations = rng:RandomInt(GLITCH.MAX_EXTRA_ACTIVATIONS - GLITCH.MIN_EXTRA_ACTIVATIONS) + GLITCH.MIN_EXTRA_ACTIVATIONS
		SFXManager():Play(GLITCH.SFX_INSERT)

		slot:GetData().LastTouchedPlayer = player
	end
    if sprite:IsPlaying("OutOfPrizes") or GLITCH:isDead(sprite) then
        return true
    end
    if sprite:IsPlaying("Wiggle") and sprite:GetFrame() == 28 and not (slot:GetData().ExtraActivations and slot:GetData().ExtraActivations > 0) then
        uses = uses - 1
    end
    return uses
end

Gebo:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	if Epiphany then
        if not Gebo.IsGeboSlot({Type = 6, Variant = Epiphany.Slot.GLITCH.ID, SubType = -1}) then
		    Gebo.AddMachineBeggar(Epiphany.Slot.GLITCH.ID, Machine, nil, 6, -1)
        end
	end
end)