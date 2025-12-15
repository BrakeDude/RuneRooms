local function Machine(slot, player, uses, rng)
    local sprite, data = slot:GetSprite(), slot:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
	
    if sprite:IsPlaying('Broken') or sprite:IsPlaying('Death') then
        return true
    end

    if sprite:IsEventTriggered('Prize') or sprite:IsEventTriggered('Card') then
        uses = uses - 1
    end

    if (sprite:IsPlaying('Idle') or sprite:IsPlaying('IdleCard')) then
			d.bumpedTeller = player
            SFXManager():Play(SoundEffect.SOUND_COIN_SLOT, 0.8, 0, false, 1)
			if sprite:IsPlaying('Idle') then
            sprite:Play('Initiate', true)	
			elseif sprite:IsPlaying('IdleCard') then
            sprite:Play('InitiateCard', true)	
			end
			d.prizeQueue = "None"
    end
    return uses
end

Gebo:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if FiendFolio then
        if not Gebo.IsGeboSlot({6, FiendFolio.FF.RobotTeller.Var, -1}) then
            Gebo.AddMachineBeggar(FiendFolio.FF.RobotTeller.Var, Machine, 5, 6, -1)     
        end
    end
end)