local function Beggar(slot, player, uses, rng)
    local sprite, data = slot:GetSprite(), slot:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
	
    if sprite:IsPlaying("Bombed") or sprite:IsPlaying("Teleport") then
        return true
    end
    if sprite:IsEventTriggered("Prize") or sprite:IsFinished("PayNothing") or sprite:IsFinished('PayRedHeart') or sprite:IsFinished('PaySoulHeart') or sprite:IsFinished('PayCoin') then
        uses = uses - 1
    end
	if sprite:IsPlaying('Idle') then
		if not d.chanceBonus then
			d.chanceBonus = 0--16
		end
		data.lastCollider = player
        sprite:LoadGraphics()
		if player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
			sprite:Play('PayCoin', true)
			SFXManager():Play(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)
			--d.chanceBonus = d.chanceBonus +16
		else
            sprite:Play('PayRedHeart', true)
            SFXManager():Play(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)
		end
	end
    return uses
end

Gebo:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if FiendFolio then
        if not Gebo.IsGeboSlot({6, FiendFolio.FF.CosplayBeggar.Var, -1}) then
            Gebo.AddMachineBeggar(FiendFolio.FF.EvilBeggar.Var, Beggar, 1, 6, -1)     
        end
    end
end)