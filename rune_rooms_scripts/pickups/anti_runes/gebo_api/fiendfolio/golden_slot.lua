local function Machine(slot, player, uses, rng)
    local sprite, d = slot:GetSprite(), slot:GetData()
	local data = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
	
    if sprite:IsPlaying('Broken') or sprite:IsPlaying('Death') or sprite:IsPlaying('TeleportOut') then
        return true
    end

    if sprite:IsEventTriggered('Prize') or sprite:IsFinished("WiggleEnd") then
        uses = uses - 1
    end

    if d.state == "idle" then
        
        d.state = "worldRevolving"
        d.player = player
        SFXManager():Play(SoundEffect.SOUND_ULTRA_GREED_PULL_SLOT, 1, 0, false, 1.5)
        d.StateFrame = 0
        d.payoutTimer = 25 + slot:GetDropRNG():RandomInt(20)
        if data.payout then
            sprite:Play("Initiate" .. data.payout, true)
        else
            sprite:Play("Initiate", true)
        end
        
    end
    return uses
end

Gebo:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if FiendFolio then
        if not Gebo.IsGeboSlot({6, FiendFolio.FF.GoldenSlotMachine.Var, -1}) then
            Gebo.AddMachineBeggar(FiendFolio.FF.GoldenSlotMachine.Var, Machine, 5, 6, -1)     
        end
    end
end)