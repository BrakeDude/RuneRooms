local function Machine(slot, player, uses, rng)
	local DICE_MACHINE = Epiphany.Slot.DICE_MACHINE
	local sprite = slot:GetSprite()
	if sprite:IsPlaying("OutOfPrizes") or DICE_MACHINE:isDead(sprite) then
		return true
	end
	if sprite:IsPlaying("Wiggle") and sprite:GetFrame() == 28 then
		uses = uses - 1
	end
	if sprite:IsOverlayFinished("CoinInsert") then
		sprite:RemoveOverlay()
		sprite:Play("Wiggle", true)
		SFXManager():Play(Isaac.GetSoundIdByName("Dice Machine Spinning"))
	end
	if not DICE_MACHINE:isSpriteBusy(sprite) then
		sprite:PlayOverlay("CoinInsert", true)
		SFXManager():Play(SoundEffect.SOUND_COIN_SLOT)
	end
	return uses
end

---@param slot EntitySlot
---@param uses any
---@return boolean
local function MachineWave8(slot, uses)
    local sprite = slot:GetSprite()
    if sprite:IsPlaying("OutOfPrizes") or sprite:IsPlaying("Death") or sprite:IsPlaying("Broken") then
		return true
	end
    if slot:GetState() ~= SlotState.REWARD then
        Epiphany:DisableEIDForThisMachine(slot)
        sprite:PlayOverlay("CoinInsert")
        Epiphany.sfxman:Play(SoundEffect.SOUND_COIN_SLOT)
        slot:SetState(SlotState.REWARD)
        uses = uses - 1
    end
    return uses
end

Gebo:AddCallback(REPENTOGON and ModCallbacks.MC_POST_MODS_LOADED or ModCallbacks.MC_POST_GAME_STARTED, function()
	if Epiphany then
		if not Gebo.IsGeboSlot({ Type = 6, Variant = Epiphany.Slot.DICE_MACHINE.ID, SubType = -1 }) then
			if Epiphany.WAVE_NUMBER ~= "7" then
                Gebo.AddMachineBeggar(Epiphany.Slot.DICE_MACHINE.ID, MachineWave8, nil, 6, -1)
                Gebo.ChangeRepentogonTag(Epiphany.Slot.DICE_MACHINE.ID, true, 6, -1)
            else
                Gebo.AddMachineBeggar(Epiphany.Slot.DICE_MACHINE.ID, Machine, nil, 6, -1)
            end
		end
	end
end)
