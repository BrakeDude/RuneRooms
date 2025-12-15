local function Beggar(slot, player, uses, rng)
    local sprite, data = slot:GetSprite(), slot:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
	if sprite:IsPlaying('Idle') then
		data.lastCollider = player
        SFXManager():Play(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)
        sprite:LoadGraphics()
		sprite:Play('TransferDaGoods', true)
		local savedata = FiendFolio.savedata.run
		savedata.contrabandProgress = savedata.contrabandProgress
		savedata.contrabandProgress = 2
    end
    return true
end

Gebo:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if FiendFolio then
        if not Gebo.IsGeboSlot({6, FiendFolio.FF.FakeBeggar.Var, -1}) then
            Gebo.AddMachineBeggar(FiendFolio.FF.FakeBeggar.Var, Beggar, 1, 6, -1)     
        end
    end
end)