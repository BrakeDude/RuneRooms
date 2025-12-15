
local function Beggar(slot, player, uses, rng)
    local sprite = slot:GetSprite()
    if sprite:GetAnimation() == "Idle" then
        sprite:Play(FasterAnimationsMod and "PayPrize_fast" or "PayPrize")
        slot:GetData().isBetterPayout = player:HasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT)
        SFXManager():Play(SoundEffect.SOUND_SCAMPER)
	end
    if sprite:IsPlaying("Teleport") then
        return true
    end
    if sprite:IsEventTriggered("Prize") then
        uses = uses - 1
    end
    return uses
end

Gebo:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	if RepentancePlusMod then
        if not Gebo.IsGeboSlot({Type = 6, Variant = RepentancePlusMod.CustomSlots.SLOT_STARGAZER, SubType = -1}) then
		    Gebo.AddMachineBeggar(RepentancePlusMod.CustomSlots.SLOT_STARGAZER, Beggar, 3, 6, -1)
        end
	end
end)