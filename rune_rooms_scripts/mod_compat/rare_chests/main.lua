RuneRooms:AddModCompat("RareChests", function()
	RuneRooms:AddCallback(
		RuneRooms.Enums.CustomCallback.INGWAZ_OPEN_CHEST,
		RareChests.openCardboardChest,
		CARDBOARD_CHEST
	)
	RuneRooms:AddCallback(
		RuneRooms.Enums.CustomCallback.INGWAZ_OPEN_CHEST,
		RareChests.openFileCabinet,
		FILE_CABINET
	)
	RuneRooms:AddCallback(RuneRooms.Enums.CustomCallback.INGWAZ_OPEN_CHEST, RareChests.openCursedChest, SLOT_CHEST)
	RuneRooms:AddCallback(RuneRooms.Enums.CustomCallback.INGWAZ_OPEN_CHEST, RareChests.openTombChest, TOMB_CHEST)
	RuneRooms:AddCallback(RuneRooms.Enums.CustomCallback.INGWAZ_OPEN_CHEST, RareChests.openDevilChest, DEVIL_CHEST)
	RuneRooms:AddCallback(RuneRooms.Enums.CustomCallback.INGWAZ_OPEN_CHEST, function(pickup, player, isInvincible)
		if not isInvincible then
			player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, false, 1, true)
		end
		RareChests.openCursedChest(pickup, player)
        return isInvincible
	end, CURSED_CHEST)
    RuneRooms:AddCallback(RuneRooms.Enums.CustomCallback.INGWAZ_OPEN_CHEST, RareChests.openBloodChest, BLOOD_CHEST)
    RuneRooms:AddCallback(RuneRooms.Enums.CustomCallback.INGWAZ_OPEN_CHEST, RareChests.openPenitentChest, PENITENT_CHEST)
end)
