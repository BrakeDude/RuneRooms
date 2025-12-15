local IngwazRune = {}

---@param ingwaz Card | integer
---@param player EntityPlayer
---@param useflags UseFlag | integer
function IngwazRune:UseIngwaz(ingwaz, player, useflags)
	local entities = Isaac.GetRoomEntities()
	local rng = player:GetCardRNG(ingwaz)
	RuneRooms.Helpers:PlayGiantBook("Ingwaz", RuneRooms.Enums.SoundEffect.RUNE_INGWAZ, player, rng)
	local addInvFrames = false
	for i = 1, #entities do
		if entities[i]:ToPickup() then
			local pickup = entities[i]:ToPickup()
			if TSIL.Pickups.IsChest(pickup) then
				pickup:TryOpenChest(player)
			else
			end
			if RepentancePlusMod then
				if pickup.Variant == RepentancePlusMod.CustomPickups.FLESH_CHEST then
					RepentancePlusMod.openFleshChest(pickup)
				elseif pickup.Variant == RepentancePlusMod.CustomPickups.SCARLET_CHEST then
					RepentancePlusMod.openScarletChest(pickup)
				elseif pickup.Variant == RepentancePlusMod.CustomPickups.BLACK_CHEST then
					RepentancePlusMod.openBlackChest(pickup)
				end
			end
			if RareChests then
				if pickup.Variant == CARDBOARD_CHEST then
					RareChests.openCardboardChest(pickup, player)
				elseif pickup.Variant == FILE_CABINET then
					RareChests.openFileCabinet(pickup, player)
				elseif pickup.Variant == SLOT_CHEST then
					RareChests.openCursedChest(pickup, player)
				elseif pickup.Variant == TOMB_CHEST then
					RareChests.openTombChest(pickup)
				elseif pickup.Variant == DEVIL_CHEST then
					RareChests.openDevilChest(pickup, player)
				elseif pickup.Variant == CURSED_CHEST then
					if not addInvFrames then
						addInvFrames = true
						player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, false, 1, true)
					end
					RareChests.openCursedChest(pickup, player)
				elseif pickup.Variant == BLOOD_CHEST then
					RareChests.openBloodChest(pickup)
				elseif pickup.Variant == PENITENT_CHEST then
					RareChests.openPenitentChest(pickup)
				end
			end
		end
	end

	if RuneRooms.Helpers:HasMagicChalk(player) then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_DADS_KEY, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_USE_CARD, IngwazRune.UseIngwaz, RuneRooms.Enums.Runes.INGWAZ)
