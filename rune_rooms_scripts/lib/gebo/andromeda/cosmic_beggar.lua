local function Beggar(slot, player, uses, rng)
    local sprite = slot:GetSprite()
    if sprite:GetAnimation() == "Idle" then
        local randNum = rng:RandomInt(3)
			
        if sprite:IsPlaying("Idle") then 
            SFXManager():Play(SoundEffect.SOUND_SCAMPER)
            
            if randNum == 0 then
                sprite:Play("PayPrize")
                player:GetData().isPayoutTarget = true
            else
                sprite:Play("PayNothing")
            end
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
	if ANDROMEDA then
        if not Gebo.IsGeboSlot({Type = 6, Variant = Isaac.GetEntityVariantByName("Wisp Wizard"), SubType = -1}) then
		    Gebo.AddMachineBeggar(Isaac.GetEntityVariantByName("Wisp Wizard"), Beggar, 6, 6, -1)
        end
	end
end)