local LevelGen = {}
---Adds a new rune room. The room id must be unique and it has to be a chest.
---
---This function must be called before MC_PRE_LEVEL_PLACE_ROOM callback fires, otherwise the room won't be loaded.
---@param id integer
---@param weight number
function RuneRooms.API:AddRuneRoom(id, weight)
	RuneRooms.Constants.RUNE_ROOMS_IDS[id] = weight
end

TSIL.SaveManager.AddPersistentVariable(
	RuneRooms,
	RuneRooms.Enums.SaveKey.RUNE_ROOM_SPAWN_CHANCE,
	0,
	TSIL.Enums.VariablePersistenceMode.RESET_RUN
)

function LevelGen:ReplaceRoom(levelGeneratorRoom, roomConfigRoom, seed)
	if RuneRooms.Helpers:RoomsUnlocked() then
		if roomConfigRoom.Type == RoomType.ROOM_CHEST then
			local rng = RuneRooms.Helpers:GetStageRNG()
			if rng:RandomFloat() >= RuneRooms:GetRuneRoomSpawnChance() then
				return
			end
			local outcome = WeightedOutcomePicker()
			for roomID, weight in pairs(RuneRooms.Constants.RUNE_ROOMS_IDS) do
				outcome:AddOutcomeFloat(roomID, weight)
			end
			local roomID = outcome:PickOutcome(rng)
			local roomconf =
				RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.SPECIAL_ROOMS, RoomType.ROOM_CHEST, roomID, 0)
			return roomconf
		end
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, LevelGen.ReplaceRoom)
