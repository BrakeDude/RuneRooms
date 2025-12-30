local LevelGen = {}
local game = Game()
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

function LevelGen:PlaceRoom()
	local level = game:GetLevel()
	if
		game:IsGreedMode()
		or game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH)
		or level:GetAbsoluteStage() >= LevelStage.STAGE4_1
	then
		RuneRooms:SetRoomSpawnChance(0)
		return
	end
	local seed = level:GetDungeonPlacementSeed()
	local rng = RNG(seed)
	if RuneRooms:GetRoomSpawnChance() <= rng:RandomFloat() then
		local outcome = WeightedOutcomePicker()
		for roomID, weight in pairs(RuneRooms.Constants.RUNE_ROOMS_IDS) do
			outcome:AddOutcomeFloat(roomID, weight)
		end
		local roomID = outcome:PickOutcome(rng)
		local roomconf = RoomConfig.GetRoomByStageTypeAndVariant(StbType.SPECIAL_ROOMS, RoomType.ROOM_CHEST, roomID, 0)
		local options = level:FindValidRoomPlacementLocations(roomconf, -1, false, false)
		for _, gridIndex in pairs(options) do
			local canPlace = true
			local neighbors = level:GetNeighboringRooms(gridIndex, roomconf.Shape)
			local shuffled = RuneRooms.Helpers:Shuffle(neighbors, rng)
			for doorSlot, neighborDesc in pairs(shuffled) do
				if neighborDesc.Data and neighborDesc.Data.Type ~= RoomType.ROOM_DEFAULT then
					canPlace = false
				end
				if canPlace then
					local room = level:TryPlaceRoom(roomconf, gridIndex, -1, seed, false, false)
					if room then
						RuneRooms:SetRoomSpawnChance(0)
						return
					end
				end
			end
		end
	elseif level:GetAbsoluteStage() ~= LevelStage.STAGE1_1 then
		RuneRooms:AddToRoomSpawnChance(0.1)
	end
end
RuneRooms:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.IMPORTANT, LevelGen.PlaceRoom)
