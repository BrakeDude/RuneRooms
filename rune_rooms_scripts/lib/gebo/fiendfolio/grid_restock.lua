local function Machine(slot, player, uses, rng)
    local sprite, d = slot:GetSprite(), slot:GetData()
	local data = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
    if sprite:IsPlaying('Broken') or sprite:IsPlaying('Death') then
        return true
    end
    if sprite:IsFinished('BombInsert') then
        uses = uses - 1
    end
    if slot.Type == 6 and slot.Variant == 880 then
        if slot:GetData().State == 1 and slot:GetData().Countdown == 0 then
          slot:GetData().State = 2
        end
      end
    return uses
end

Gebo:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if FiendFolio then
        if not Gebo.IsGeboSlot({6, 880, -1}) then
            Gebo.AddMachineBeggar(880, Machine, 5, 6, -1)     
        end
    end
end)