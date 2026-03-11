
local function Machine(slot, player, uses, rng)
    local sprite = slot:GetSprite()
    if sprite:IsPlaying("Idle") then
        sprite:Play("Initiate")
        SFXManager():Play(SoundEffect.SOUND_COIN_SLOT)
	end
    if sprite:IsPlaying("Teleport") or sprite:IsPlaying("Death") or sprite:IsPlaying("Broken") then
        return true
    end
    if sprite:IsEventTriggered("Prize") or sprite:IsFinished("WiggleEnd") then
        uses = uses - 1
    end
    return uses
end

Gebo:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	if CiiruleanItems then
        if not Gebo.IsGeboSlot({Type = 6, Variant = CiiruleanItems.SLOTS.BUTAPON, SubType = -1}) then
		    Gebo.AddMachineBeggar(CiiruleanItems.SLOTS.BUTAPON, Machine, 5, 6, -1)
        end
        if not Gebo.IsGeboSlot({Type = 6, Variant = CiiruleanItems.SLOTS.GASHAPON, SubType = -1}) then
		    Gebo.AddMachineBeggar(CiiruleanItems.SLOTS.GASHAPON, Machine, 5, 6, -1)
        end
	end
end)