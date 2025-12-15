local function Beggar(slot, player, uses, rng)
    local sprite, d = slot:GetSprite(), slot:GetData()
	    
    if sprite:IsPlaying('Idle') then
        SFXManager():Play(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)
        d.lastCollider = player
        if math.random(3) == 1 then
            sprite:Play("PayNothing")
        else
            sprite:Play("PayPrize")
        end
    end
    if sprite:IsPlaying("Teleport") then
        return true
    end
    if sprite:IsEventTriggered("Prize") or sprite:IsFinished("PayNothing") then
        uses = uses - 1
    end
    return uses
end

Gebo:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if FiendFolio then
        if not Gebo.IsGeboSlot({6, FiendFolio.FF.CosplayBeggar.Var, -1}) then
            Gebo.AddMachineBeggar(FiendFolio.FF.CosplayBeggar.Var, Beggar, 6, 6, -1)     
        end
    end
end)