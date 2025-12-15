
local function Beggar(slot, player, uses, rng)
    local sprite = slot:GetSprite()
    if sprite:GetAnimation() == "Idle" then
        sprite:Play("PayPrize")
        slot:GetData().swineBeggarPayee = player
        SFXManager():Play(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1.2)
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
	if CiiruleanItems then
        if not Gebo.IsGeboSlot({Type = 6, Variant = CiiruleanItems.SLOTS.SWINE_BEGGAR, SubType = -1}) then
		    Gebo.AddMachineBeggar(CiiruleanItems.SLOTS.SWINE_BEGGAR, Beggar, 3, 6, -1)
        end
        if not Gebo.IsGeboSlot({Type = 6, Variant = CiiruleanItems.SLOTS.DEMON_SWINE, SubType = -1}) then
		    Gebo.AddMachineBeggar(CiiruleanItems.SLOTS.DEMON_SWINE, Beggar, 3, 6, -1)
        end
        if not Gebo.IsGeboSlot({Type = 6, Variant = CiiruleanItems.SLOTS.ANGEL_SWINE, SubType = -1}) then
		    Gebo.AddMachineBeggar(CiiruleanItems.SLOTS.ANGEL_SWINE, Beggar, 3, 6, -1)
        end
	end
end)