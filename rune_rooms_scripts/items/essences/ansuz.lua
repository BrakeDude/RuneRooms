local AnsuzEssence = {}

local REVEAL_ROOM_CHANCE = 1
local FULL_DISPLAY_FLAGS = 5
local AnsuzItem = RuneRooms.Enums.Item.ANSUZ_ESSENCE

function AnsuzEssence:OnAnsuzPickup()
	local level = Game():GetLevel()

	level:ApplyCompassEffect(false)
	level:ApplyBlueMapEffect()
	level:ApplyMapEffect()

	level:UpdateVisibility()
end
RuneRooms:AddCallback(TSIL.Enums.CustomCallback.POST_PLAYER_COLLECTIBLE_ADDED, AnsuzEssence.OnAnsuzPickup, {
	nil,
	nil,
	AnsuzItem,
})

---@param player EntityPlayer
local function AnsuzNewLevelEffect(player)
	local level = Game():GetLevel()
	local rng = player:GetCollectibleRNG(AnsuzItem)

	local effect = rng:RandomInt(3)

	if effect == 0 then
		--Compass
		level:ApplyCompassEffect(false)
	elseif effect == 1 then
		--Blue map
		level:ApplyBlueMapEffect()
	elseif effect == 2 then
		--Treasure map
		level:ApplyMapEffect()
	end

	level:UpdateVisibility()
end

---@param gridIndex number
---@return Vector
local function GridIndexToVector(gridIndex)
	return Vector(gridIndex % 13, math.floor(gridIndex / 13))
end

local function IsAltPathDownpoorWithMirror()
	local level = Game():GetLevel()
	local levelStage = level:GetAbsoluteStage()
	local levelType = level:GetStageType()

	if StageAPI and StageAPI.InNewStage() then
		local stage = StageAPI.GetCurrentStage()
		levelStage = stage.LevelgenStage.Stage
		levelType = stage.LevelgenStage.StageType
	end

	return levelType >= StageType.STAGETYPE_REPENTANCE
		and (
			levelStage == LevelStage.STAGE1_1 and level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH > 0
			or levelStage == LevelStage.STAGE1_2
		)
end

local function PlaceRoom(options, bossGridVector, roomconf, seed, failCond)
    local level = Game():GetLevel()
	for _, gridIndex in ipairs(options) do
		local canPlace = true
		local neighbors = level:GetNeighboringRooms(gridIndex, roomconf.Shape)
		local sorted = RuneRooms.Helpers:TableQuickSort(neighbors, function(a, b)
			return bossGridVector:Distance(GridIndexToVector(a.GridIndex))
				< bossGridVector:Distance(GridIndexToVector(b.GridIndex))
		end)
		for doorSlot, neighborDesc in pairs(sorted) do
			if failCond(neighborDesc) then
				canPlace = false
			end
			if canPlace then
				local room = level:TryPlaceRoom(roomconf, gridIndex, -1, seed, false, false)
				if room then
                    if IsAltPathDownpoorWithMirror() then
                        level:TryPlaceRoom(roomconf, gridIndex, 1, seed, false, false)
                    end
					MinimapAPI:LoadDefaultMap()
					return true
				end
			end
		end
	end
    return false
end

function AnsuzEssence:OnNewLevel()
	if not PlayerManager.AnyoneHasCollectible(AnsuzItem) then
		return
	end
	local level = Game():GetLevel()
	local seed = level:GetDungeonPlacementSeed()
	local rng = RNG(seed)
	local roomconf
	local antisoftlock = 0

	repeat
		roomconf = RoomConfig.GetRandomRoom(
			math.max(1, rng:GetSeed()),
			false,
			StbType.SPECIAL_ROOMS,
			RoomType.ROOM_SUPERSECRET,
			RoomShape.ROOMSHAPE_1x1,
			0,
			-1,
			0,
			10
		)
		antisoftlock = antisoftlock + 1
		rng:Next()
	until roomconf ~= nil or antisoftlock > 100
	if roomconf == nil then
		print("None")
		return
	end
	local options = level:FindValidRoomPlacementLocations(roomconf, -1, false, false)
	local bossGridIndex = 0
	local rooms = level:GetRooms()
	for i = 0, rooms.Size - 1 do
		local room = rooms:Get(i)
		if room.Data.Type == RoomType.ROOM_BOSS then
			bossGridIndex = room.GridIndex
			break
		end
	end

	local bossGridVector = GridIndexToVector(bossGridIndex)
	table.sort(options, function(a, b)
		return bossGridVector:Distance(GridIndexToVector(a)) < bossGridVector:Distance(GridIndexToVector(b))
	end)

	for _, gridIndex in ipairs(options) do
		local canPlace = true
		local neighbors = level:GetNeighboringRooms(gridIndex, roomconf.Shape)
		local sorted = RuneRooms.Helpers:TableQuickSort(neighbors, function(a, b)
			return bossGridVector:Distance(GridIndexToVector(a.GridIndex))
				< bossGridVector:Distance(GridIndexToVector(b.GridIndex))
		end)

        if PlaceRoom(options, bossGridVector, roomconf, seed, function(desc) 
            return desc.Data and desc.Data.Type ~= RoomType.ROOM_DEFAULT
        end) then
            return
        end
        PlaceRoom(options, bossGridVector, roomconf, seed, function(desc) 
            return desc.Data and (
					desc.Data.Type == RoomType.ROOM_SECRET
					or desc.Data.Type == RoomType.ROOM_SUPERSECRET
					or desc.Data.Type == RoomType.ROOM_ULTRASECRET
				)
        end)
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, AnsuzEssence.OnNewLevel)

function AnsuzEssence:RevealOnRoomClear()
	if not PlayerManager.AnyoneHasCollectible(AnsuzItem) then
		return
	end

	local player = TSIL.Players.GetPlayersByCollectible(AnsuzItem)[1]

	local rng = player:GetCollectibleRNG(AnsuzItem)

	local notFullyVisibleRooms = {}

	for _, room in ipairs(MinimapAPI:GetLevel()) do
		---@type integer
		local displayFlags = room:GetDisplayFlags()
		if displayFlags ~= FULL_DISPLAY_FLAGS then
			notFullyVisibleRooms[#notFullyVisibleRooms + 1] = room
		end
	end

	if #notFullyVisibleRooms == 0 then
		return
	end

	local room = TSIL.Random.GetRandomElementsFromTable(notFullyVisibleRooms, 1, rng)[1]
	room.DisplayFlags = FULL_DISPLAY_FLAGS
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR, AnsuzEssence.RevealOnRoomClear)
