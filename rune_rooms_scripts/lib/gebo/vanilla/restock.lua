local function RestockMachine(slot, player, uses, rng)
	if uses > 0 then
		local sprite = slot:GetSprite()
		---@cast sprite Sprite
		if sprite:GetAnimation() == "Death" or sprite:GetAnimation() == "Broken" then
			return true
		end
		if sprite:IsPlaying("Idle") and not sprite:IsOverlayPlaying("CoinInsert") then
			sprite:PlayOverlay("CoinInsert",true)
		end
		if sprite:GetOverlayAnimation() == "CoinInsert" and sprite:GetOverlayFrame() == 6 then
			SFXManager():Play(SoundEffect.SOUND_COIN_SLOT,1,0,false,1)
			sprite:Play("Prize",true)
			uses = uses - 1
		end
		if sprite:IsFinished("Prize") then
			if rng:RandomFloat() <= 0.3 then
				sprite:Play("WiggleEnd", true)
				sprite:Stop()
			else
				sprite:Play("Idle", true)
			end
		end
	end
	return uses
end

Gebo.AddMachineBeggar(10, RestockMachine)