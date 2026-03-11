local function CraneTrigger(slot, player, uses, rng)
	if uses > 0 then
		local sprite = slot:GetSprite()
		if sprite:GetAnimation() == "Death" or sprite:GetAnimation() == "Broken" then
			return true
		end
		if sprite:IsOverlayFinished("CoinInsert") then
			sprite:RemoveOverlay("CoinInsert")
		end
		if sprite:IsPlaying("Idle") then
			sprite:Play("Initiate", true)
			sprite:PlayOverlay("CoinInsert")
		end
		if sprite:IsFinished("Initiate") then
			sprite:Play("Wiggle", true)
			SFXManager():Play(SoundEffect.SOUND_COIN_SLOT,1,0,false,1)
		end
		if sprite:IsFinished("Prize") then
			uses = uses - 1
			if rng:RandomFloat() <= 0.1 then
				sprite:Play("Death")
			else
				slot:Remove()
				local newslot = Isaac.Spawn(6,16,0,slot.Position, Vector.Zero, nil)
				newslot:GetSprite():Play("Regenerate",true)
				newslot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				local newData = Gebo.GetData(newslot)
				newData.Gebo = {Uses = uses, rng = rng, Player = player}
			end
			
		end
		if sprite:IsFinished("Regenerate") then
			sprite:Play("Idle",true)
		end
		if sprite:IsFinished("NoPrize") then
			uses = uses - 1
			sprite:Play("Idle", true)
		end
	end
	return uses
end

Gebo.AddMachineBeggar(16, CraneTrigger)