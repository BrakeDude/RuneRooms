local SowiloRune = {}

---@param sowilo Card | integer
---@param player EntityPlayer
---@param useflags UseFlag | integer
function SowiloRune:UseSowilo(sowilo, player, useflags)
	local rng = player:GetCardRNG(sowilo)
	RuneRooms.Helpers:PlayGiantBook("Sowilo", RuneRooms.Enums.SoundEffect.RUNE_SOWILO, player, rng)

	if RuneRooms.Helpers:HasMagicChalk(player) then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	else
		player:UseActiveItem(CollectibleType.COLLECTIBLE_D7, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_USE_CARD, SowiloRune.UseSowilo, RuneRooms.Enums.Runes.SOWILO)