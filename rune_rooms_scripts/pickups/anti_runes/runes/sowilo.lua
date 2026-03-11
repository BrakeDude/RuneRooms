local SowiloRune = {}

---@param sowilo Card | integer
---@param player EntityPlayer
---@param useflags UseFlag | integer
function SowiloRune:UseSowilo(sowilo, player, useflags, rng)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_D7, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	return true
end
RuneRooms:AddInternalCallback(
	RuneRooms.Enums.CustomCallback.RUN_RUNE_MAIN,
	SowiloRune.UseSowilo,
	RuneRooms.Enums.Runes.SOWILO
)

return SowiloRune
