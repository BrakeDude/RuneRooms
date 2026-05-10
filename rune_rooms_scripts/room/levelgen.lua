local LevelGen = {}
local game = Game()
local placingroom = false
local rooms = {}
---@cast rooms RoomConfigRoom[]


---Returns a valid Rune Room config
---@param rng RNG RuneRooms uses a new rng created by the seed of level:GetDungeonPlacementSeed()
---@return RoomConfigRoom | nil
function RuneRooms.API:GetRandomRoom(rng)
	local outcomes = WeightedOutcomePicker()
	for i, room in ipairs(rooms) do
		outcomes:AddOutcomeFloat(i, room.Weight)
	end
	local i = outcomes:PickOutcome(rng)
	if rooms[i] then
		return rooms[i]
	end
end

---@param gridIndex integer? @Default: current room index
---@return boolean
function RuneRooms.API:IsRuneRoom(gridIndex)
	local roomData = TSIL.Rooms.GetRoomData(gridIndex)

	return RuneRooms.API:IsRuneRoomConfig(roomData)
end

---@param roomData RoomConfigRoom
---@return boolean
function RuneRooms.API:IsRuneRoomConfig(roomData)
	if not roomData then
		return false
	end

	return roomData.Type == RoomType.ROOM_CHEST and roomData.Subtype == RuneRooms.Constants.RUNE_ROOM_SUBTYPE
end

local function LoadRoomsToTable(set)
	for _, room in ipairs(set) do
		if RuneRooms.API:IsRuneRoomConfig(room) then
			table.insert(rooms, room)
		end
	end
end

function RuneRooms.API:AddRuneRooms(name)
	local stb = RoomConfig.LoadStb(StbType.SPECIAL_ROOMS, 0, name)
	LoadRoomsToTable(stb)
end

function RuneRooms.API:AddLuaRuneRooms(luaRooms)
	local set = RoomConfig.AddRooms(StbType.SPECIAL_ROOMS, 0, luaRooms)
	LoadRoomsToTable(set)
end

local function RunSpawnChanceCallbacks()
	local callbacks = Isaac.GetCallbacks(RuneRooms.Enums.CustomCallback.RUNE_ROOM_SPAWN_CHANCE)
	local chance = RuneRooms:RunSave().RuneRoomSpawnChance
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
	RuneRooms:RunSave().RuneRoomSpawnChance = value
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

local function GetCurrentLevelStage()
	local level = game:GetLevel()
	local levelStage = level:GetAbsoluteStage()
	local levelType = level:GetStageType()

	if StageAPI and StageAPI.InNewStage() then
		local stage = StageAPI.GetCurrentStage()
		levelStage = stage.LevelgenStage.Stage
		levelType = stage.LevelgenStage.StageType
	end

	if levelType >= StageType.STAGETYPE_REPENTANCE then
		levelStage = levelStage + 1
	end

	return levelStage
end

function RuneRooms.API:CanSpawnRuneRoom()
	local levelStage = GetCurrentLevelStage()
	return not game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH)
	and (Isaac.GetPlayer(0):GetNumKeys() >= 2 or RuneRooms.Helpers:IsDebugEnabled())
	and levelStage < LevelStage.STAGE4_3
end

function LevelGen:PlaceRoom()
	if
		game:IsGreedMode() or not RuneRooms:RoomsUnlocked()
		or not RuneRooms.API:CanSpawnRuneRoom()
	then
		return
	end
	local levelStage = GetCurrentLevelStage()

	if levelStage % 2 == 0 then
		local level = game:GetLevel()
		local seed = level:GetDungeonPlacementSeed()
		local rng = RNG(seed)
		local chance = RunSpawnChanceCallbacks()
		if rng:RandomFloat() <= chance then
			local roomconf = RuneRooms.API:GetRandomRoom(rng)

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
		RuneRooms.API:IsRuneRoomConfig(roomConfig)
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
	local runData = RuneRooms:RunSave()
	if room:IsFirstVisit() and room:GetType() == RoomType.ROOM_SUPERSECRET and not runData.RuneRoomEntered then
		RuneRooms.API:AddToRoomSpawnChance(0.15)
	end
	if RuneRooms.API:IsRuneRoom() then
		runData.RuneRoomEntered = true
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
