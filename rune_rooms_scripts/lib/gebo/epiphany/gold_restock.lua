local function Machine(slot, player, uses, rng)
    local GOLD_RESTOCK = Epiphany.Slot.TURNOVER_RESTOCK
    local sprite = slot:GetSprite()
    if sprite:IsOverlayFinished("CoinInsert") then
        sprite:Play("Wiggle")
        sprite:RemoveOverlay("CoinInsert")
    end
    if not GOLD_RESTOCK:isSpriteBusy(sprite) then
        local run_save = Epiphany:RunSave()
        run_save["TURNOVER_RESTOCK_DATA"] = (run_save["TURNOVER_RESTOCK_DATA"] or {})
        local slot_string = tostring(slot.InitSeed)
        if run_save["TURNOVER_RESTOCK_DATA"][slot_string] == nil then
            run_save["TURNOVER_RESTOCK_DATA"][slot_string] = {}
            run_save["TURNOVER_RESTOCK_DATA"][slot_string].payouts = 0
        end
        local payouts = run_save["TURNOVER_RESTOCK_DATA"][slot_string].payouts
        payouts = payouts + 1

        player:AddCoins(-5)
        sprite:PlayOverlay("CoinInsert", true)
        Epiphany.sfxman:Play(SoundEffect.SOUND_COIN_SLOT)

        run_save["TURNOVER_RESTOCK_DATA"][slot_string].payouts = payouts
	end
    if sprite:IsPlaying("Death") or sprite:IsPlaying("Broken") then
        return true
    end
    if sprite:IsFinished("WiggleEnd") then
        uses = uses - 1
    end
    return uses
end

Gebo:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	if Epiphany then
        if not Gebo.IsGeboSlot({Type = 6, Variant = Epiphany.Slot.TURNOVER_RESTOCK.ID, SubType = -1}) then
		    Gebo.AddMachineBeggar(Epiphany.Slot.TURNOVER_RESTOCK.ID, Machine, 2, 6, -1)
        end
	end
end)