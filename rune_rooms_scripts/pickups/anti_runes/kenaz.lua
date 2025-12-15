local KenazRune = {}

---@param kenaz Card | integer
---@param player EntityPlayer
---@param useflags UseFlag | integer
function KenazRune:UseKenaz(kenaz, player, useflags)
	local rng = player:GetCardRNG(kenaz)
	RuneRooms.Helpers:PlayGiantBook("Kenaz", RuneRooms.Enums.SoundEffect.RUNE_KENAZ, player, rng)
	player:AddCollectible(CollectibleType.COLLECTIBLE_TOXIC_SHOCK, 0, false, 0, 0)
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_TOXIC_SHOCK, true, 0, true)
	if RuneRooms.Helpers:HasMagicChalk(player) then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_MEGA_BEAN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_USE_CARD, KenazRune.UseKenaz, RuneRooms.Enums.Runes.KENAZ)