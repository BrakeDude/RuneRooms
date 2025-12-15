local IngwazRune = {}

---@param ingwaz Card | integer
---@param player EntityPlayer
---@param useflags UseFlag | integer
function IngwazRune:UseIngwaz(ingwaz, player, useflags)
	local entities = Isaac.GetRoomEntities()
	local rng = player:GetCardRNG(ingwaz)
	RuneRooms.Helpers:PlayGiantBook("Ingwaz", RuneRooms.Enums.SoundEffect.RUNE_INGWAZ, player, rng)
	for i = 1, #entities do
        if entities[i]:ToPickup() then
			local pickup = entities[i]:ToPickup()
			if TSIL.Pickups.IsChest(pickup) then
				pickup:TryOpenChest(player)
            else

			end
			if RepentancePlusMod then
				if entities[i].Variant == RepentancePlusMod.CustomPickups.FLESH_CHEST then
					RepentancePlusMod.openFleshChest(entities[i])
				elseif entities[i].Variant == RepentancePlusMod.CustomPickups.SCARLET_CHEST then
					RepentancePlusMod.openScarletChest(entities[i])
				elseif entities[i].Variant == RepentancePlusMod.CustomPickups.BLACK_CHEST then
					RepentancePlusMod.openBlackChest(entities[i])
				end
			end
            if RareChests then
                if entites[i].Variant == CARDBOARD_CHEST then
                    RareChests.openCardboardChest(pickup, player)
                elseif entites[i].Variant == FILE_CABINET then
                    RareChests.openFileCabinet(pickup, player)
                elseif entites[i].Variant == SLOT_CHEST then

                elseif entites[i].Variant == TOMB_CHEST then
                    RareChests.openTombChest(pickup)
                elseif entites[i].Variant == DEVIL_CHEST then
                    RareChests.openDevilChest(pickup, player)
                elseif entites[i].Variant == CURSED_CHEST then
                     RareChests.openCursedChest(pickup, player)
                elseif entites[i].Variant == BLOOD_CHEST then
                elseif entites[i].Variant == PENITENT_CHEST then

                end
            end
		end
	end

	if RuneRooms.Helpers:HasMagicChalk(player) then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_DADS_KEY, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_USE_CARD, IngwazRune.UseIngwaz, RuneRooms.Enums.Runes.INGWAZ)
