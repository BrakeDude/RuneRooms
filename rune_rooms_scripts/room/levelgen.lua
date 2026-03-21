local LevelGen = {}
local game = Game()
local placingroom = false
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

TSIL.SaveManager.AddPersistentVariable(
	RuneRooms,
	RuneRooms.Enums.SaveKey.RUNE_ROOM_ENTERED_IN_RUN,
	false,
	TSIL.Enums.VariablePersistenceMode.RESET_RUN
)

local function RunSpawnChanceCallbacks()
	local callbacks = Isaac.GetCallbacks(RuneRooms.Enums.CustomCallback.RUNE_ROOM_SPAWN_CHANCE)
	local chance = TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.RUNE_ROOM_SPAWN_CHANCE)
	for _, callback in ipairs(callbacks) do
		local ret = callback.Function(callback.Mod, chance * 100)
		if type(ret) == "number" then
			chance = chance + ret / 100
		end
	end
	return TSIL.Utils.Math.Clamp(chance, 0, 1)
end

function RuneRooms.API:GetRoomSpawnChance()
	return RunSpawnChanceCallbacks()
end

function RuneRooms.API:SetRoomSpawnChance(value)
	TSIL.SaveManager.SetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.RUNE_ROOM_SPAWN_CHANCE, value)
end

function RuneRooms.API:AddToRoomSpawnChance(value)
	local currentChance = RuneRooms.API:GetRoomSpawnChance()
	RuneRooms.API:SetRoomSpawnChance(currentChance + value)
end

---@param gridIndex number
---@return Vector
local function GridIndexToVector(gridIndex)
	return Vector(gridIndex % 13, math.floor(gridIndex / 13))
end

RuneRooms:AddCallback(RuneRooms.Enums.CustomCallback.RUNE_ROOM_SPAWN_CHANCE, function()
	if RuneRooms.Helpers:IsDebugEnabled() then
		return 100
	end
end)

function LevelGen:PlaceRoom()
	if
		game:IsGreedMode()
		or game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH)
		or (not RuneRooms:RoomsUnlocked() or Isaac.GetPlayer(0):GetNumKeys() < 2)
			and not RuneRooms.Helpers:IsDebugEnabled()
	then
		return
	end
	local level = game:GetLevel()
	local levelStage = level:GetAbsoluteStage()
	local levelType = level:GetStageType()

	if StageAPI and StageAPI.InNewStage() then
		local stage = StageAPI.GetCurrentStage()
		levelStage = stage.LevelgenStage.Stage
		levelType = stage.LevelgenStage.StageType
	end

	if levelStage >= LevelStage.STAGE4_3 then
		return
	end
	if levelType >= StageType.STAGETYPE_REPENTANCE then
		levelStage = levelStage + 1
	end
	if levelStage % 2 == 0 or RuneRooms.Helpers:IsDebugEnabled() then
		local seed = level:GetDungeonPlacementSeed()
		local rng = RNG(seed)
		local chance = RunSpawnChanceCallbacks()
		if rng:RandomFloat() <= chance then
			--[[local outcome = WeightedOutcomePicker()
			for roomID, weight in pairs(RuneRooms.Constants.RUNE_ROOMS_IDS) do
				outcome:AddOutcomeFloat(roomID, weight)
			end
			local roomID = outcome:PickOutcome(rng)]]
			local roomconf
			local antisoftlock = 0
			repeat
				roomconf = RoomConfig.GetRandomRoom(math.max(1, rng:GetSeed()), false, StbType.SPECIAL_ROOMS, RoomType.ROOM_CHEST, RoomShape.ROOMSHAPE_1x1, 0, -1, 0, 10)
				antisoftlock = antisoftlock + 1
				rng:Next()
			until roomconf ~= nil and RuneRooms.Helpers:IsRuneRoomDescriptor(roomconf) or antisoftlock > 100
			--RoomConfig.GetRoomByStageTypeAndVariant(StbType.SPECIAL_ROOMS, RoomType.ROOM_CHEST, roomID, 0)
			if roomconf == nil then
				print("None")
				return
			end
			local options = level:FindValidRoomPlacementLocations(roomconf, -1, false, false)
			local startGridIndex = level:GetStartingRoomIndex()
			local startGridVector = GridIndexToVector(startGridIndex)
			table.sort(options, function(a, b)
				return startGridVector:Distance(GridIndexToVector(a)) < startGridVector:Distance(GridIndexToVector(b))
			end)

			for _, gridIndex in ipairs(options) do
				local canPlace = true
				local neighbors = level:GetNeighboringRooms(gridIndex, roomconf.Shape)
				local sorted = RuneRooms.Helpers:TableQuickSort(neighbors, function(a, b)
					return startGridVector:Distance(GridIndexToVector(a.GridIndex))
						< startGridVector:Distance(GridIndexToVector(b.GridIndex))
				end)
				for doorSlot, neighborDesc in pairs(sorted) do
					if neighborDesc.Data and neighborDesc.Data.Type ~= RoomType.ROOM_DEFAULT then
						canPlace = false
					end
					if canPlace then
						placingroom = true
						local room = level:TryPlaceRoom(roomconf, gridIndex, -1, seed, false, false)
						placingroom = false
						if room then
							local t = {
								Shape = room.Data.Shape,
								PermanentIcons = { RuneRooms.Constants.RUNE_ROOM_ICON },
								Position = MinimapAPI:GridIndexToVector(room.SafeGridIndex),
								Descriptor = room,
								Type = room.Data.Type,
							}
							MinimapAPI:AddRoom(t)
							return
						end
					end
				end
			end
		end
	end
end
RuneRooms:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.IMPORTANT, LevelGen.PlaceRoom)

---@param slot LevelGeneratorRoom
---@param roomConfig RoomConfigRoom
---@param seed integer
---@return RoomConfigRoom?
function LevelGen:NoNaturalRoom(slot, roomConfig, seed)
	if placingroom then
		return
	end
	if
		roomConfig.Type == RoomType.ROOM_CHEST
		and roomConfig.Type == RoomType.ROOM_NULL
		and RuneRooms.Constants.RUNE_ROOMS_IDS[roomConfig.Variant] ~= nil
	then
		local rng = RNG(math.max(1, seed))
		local roomconf
		local newType = RoomType.ROOM_CHEST
		local stb = StbType.SPECIAL_ROOMS
		if roomConfig.Type == RoomType.ROOM_NULL then
			newType = RoomType.ROOM_DEFAULT
			stb = roomConfig.StageID
		end
		repeat
			roomconf = RoomConfig.GetRandomRoom(
				math.max(1, rng:GetSeed()),
				false,
				stb,
				newType,
				RoomShape.ROOMSHAPE_1x1,
				0,
				-1,
				0,
				10
			)
			rng:Next()
		until roomconf ~= nil
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, LevelGen.NoNaturalRoom)

function LevelGen:NewRoom()
	local room = game:GetRoom()
	local runeRoomWasEntered =
		TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.RUNE_ROOM_ENTERED_IN_RUN)
	if room:IsFirstVisit() and room:GetType() == RoomType.ROOM_SUPERSECRET and not runeRoomWasEntered then
		RuneRooms.API:AddToRoomSpawnChance(0.15)
	end
	if RuneRooms.Helpers:IsRuneRoom() then
		TSIL.SaveManager.SetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.RUNE_ROOM_ENTERED_IN_RUN, true)
		RuneRooms.API:SetRoomSpawnChance(1 / 15)
		if RuneRooms.Helpers:IsInMirrorDimension() then
			local props =
				Isaac.FindByType(EntityType.ENTITY_GENERIC_PROP, RuneRooms.Enums.GenericPropVariant.GIANT_RUNE_CRYSTAL)
			local pads = Isaac.FindByType(EntityType.ENTITY_GENERIC_PROP, RuneRooms.Enums.GenericPropVariant.RUNE_PAD)
			local toDelete = RuneRooms.Helpers:MergeTables(props, pads)
			for _, prop in ipairs(toDelete) do
				prop:Remove()
			end
		end
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, LevelGen.NewRoom)
