local function Beggar(slot, player, uses, rng)
    local sprite, data = slot:GetSprite(), slot:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
	if sprite:IsOverlayFinished('PayNothing') or sprite:IsOverlayPlaying('Prize') and (sprite:IsEventTriggered('Prize') or sprite:GetOverlayFrame() == 27) then
        uses = uses - 1
    end
    if sprite:IsOverlayPlaying('Teleport') then
        return true
    end
    if sprite:IsOverlayPlaying('Idle') then
        if d.coinsRecieved == nil then
            d.coinsRecieved = 0
        end
        data.lastCollider = player
        d.pity = d.pity or 0
        d.coinsRecieved = d.coinsRecieved + 1
        d.pity = d.pity + 1
        SFXManager():Play(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)
        sprite:LoadGraphics()
        local r = slot:GetDropRNG()
        local randoChance = r:RandomInt(2)
        if randoChance == 0 or d.pity >= 3 then
            if d.coinsRecieved >= 50 then
                local i = r:RandomInt(3)
                if i == 0 then
                    d.coinsRecieved = 100
                end
            elseif d.coinsRecieved >= 20 then
                local i = r:RandomInt(6)
                if i == 0 then
                    d.coinsRecieved = 100
                end
            elseif d.coinsRecieved >= 3 then
                local i = r:RandomInt(30)
                if i == 0 then
                    d.coinsRecieved = 100
                end
            end
            sprite:PlayOverlay('PayPrize', true)
        else
            if d.coinsRecieved == 100 or d.pity == 6 then
                sprite:PlayOverlay('PayPrize', true)
            else
                sprite:PlayOverlay('PayNothing', true)
            end
        end
    end
    return uses
end

Gebo:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if FiendFolio then
        if not Gebo.IsGeboSlot({6, FiendFolio.FF.ZodiacBeggar.Var, -1}) then
            Gebo.AddMachineBeggar(FiendFolio.FF.ZodiacBeggar.Var, Beggar, 6, 6, -1)     
        end
    end
end)