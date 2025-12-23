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

function RuneRooms:GetRoomSpawnChance()
	return TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.RUNE_ROOM_SPAWN_CHANCE)
end

function RuneRooms:SetRoomSpawnChance(value)
	TSIL.SaveManager.SetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.RUNE_ROOM_SPAWN_CHANCE, value)
end

function RuneRooms:AddToRoomSpawnChance(value)
	local currentChance = RuneRooms:GetRoomSpawnChance()
	RuneRooms:SetRoomSpawnChance(currentChance + value)
end

---@param levelGeneratorRoom LevelGeneratorRoom
---@param roomConfigRoom RoomConfigRoom
---@param seed integer
---@return RoomConfigRoom
function LevelGen:ReplaceRoom(levelGeneratorRoom, roomConfigRoom, seed)
	local rng = RNG(seed)
	if rng:RandomFloat() <= RuneRooms:GetRoomSpawnChance() then
		if levelGeneratorRoom:IsDeadEnd()
		and roomConfigRoom.Shape == RoomShape.ROOMSHAPE_1x1
		and roomConfigRoom.Type == RoomType.ROOM_DEFAULT then
			local outcome = WeightedOutcomePicker()
			for roomID, weight in pairs(RuneRooms.Constants.RUNE_ROOMS_IDS) do
				outcome:AddOutcomeFloat(roomID, weight)
			end
			local roomID = outcome:PickOutcome(rng)
			local roomconf = RoomConfig.GetRoomByStageTypeAndVariant(StbType.SPECIAL_ROOMS, RoomType.ROOM_CHEST, roomID, 0)
			RuneRooms:SetRoomSpawnChance(-0.1)
			return roomconf
		end
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, LevelGen.ReplaceRoom)

RuneRooms:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	RuneRooms:AddToRoomSpawnChance(0.1)
end)