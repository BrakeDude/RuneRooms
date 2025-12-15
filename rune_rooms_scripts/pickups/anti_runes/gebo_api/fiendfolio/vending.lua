local function Machine(slot, player, uses, rng)
    local sprite, d = slot:GetSprite(), slot:GetData()
	local data = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
    if sprite:IsPlaying('Broken') or sprite:IsPlaying('Death') then
        return true
    end
    if sprite:IsEventTriggered("Prize") then
        uses = uses - 1
    end
    if d.price and d.state == "idle" then
        d.state = "paid"
        d.paymentAnims = nil
        d.player = player
        SFXManager():Play(SoundEffect.SOUND_COIN_SLOT, 1, 0, false, 1)
    end
    return uses
end

Gebo:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if FiendFolio then
        if not Gebo.IsGeboSlot({6, FiendFolio.FF.VendingMachineFF.Var, -1}) then
            Gebo.AddMachineBeggar(FiendFolio.FF.VendingMachineFF.Var, Machine, 1, 6, -1)     
        end
        if not Gebo.IsGeboSlot({6, FiendFolio.FF.VendingMachine.Var, -1}) then
            Gebo.AddMachineBeggar(FiendFolio.FF.VendingMachine.Var, Machine, 2, 6, -1)     
        end
    end
end)