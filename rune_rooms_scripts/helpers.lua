RuneRooms.Helpers = {}

---Helper function to check if a room is a rune room
---@param gridIndex integer? @Default: current room index
---@return boolean
function RuneRooms.Helpers:IsRuneRoom(gridIndex)
	local roomData = TSIL.Rooms.GetRoomData(gridIndex)

	if not roomData then
		return false
	end

	if roomData.Type ~= RoomType.ROOM_CHEST then
		return false
	end
	return RuneRooms.Constants.RUNE_ROOMS_IDS[roomData.Variant] ~= nil
end

do
	local scheduledFunctions = {}

	---Runs a function in a given number of render frames
	---@param funct function
	---@param frames integer
	function RuneRooms.Helpers:RunInNRenderFrames(funct, frames)
		scheduledFunctions[#scheduledFunctions + 1] = {
			funct = funct,
			frames = frames,
		}
	end

	RuneRooms:AddCallback(ModCallbacks.MC_POST_RENDER, function()
		local temp = {}

		TSIL.Utils.Tables.ForEach(scheduledFunctions, function(_, scheduledFunction)
			scheduledFunction.frames = scheduledFunction.frames - 1

			if scheduledFunction.frames <= 0 then
				scheduledFunction.funct()
			else
				temp[#temp + 1] = scheduledFunction
			end
		end)

		scheduledFunctions = temp
	end)

	RuneRooms:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
		scheduledFunctions = {}
	end)
end

---Returns an rng object that's unique for each stage.
---@return RNG
function RuneRooms.Helpers:GetStageRNG()
	local level = Game():GetLevel()
	local seeds = Game():GetSeeds()
	local stageSeed = seeds:GetStageSeed(level:GetStage())

	return TSIL.RNG.NewRNG(stageSeed)
end

---Returns an rng object that's unique for each room in the level.
---@param gridIndex integer? @Default: current room index
---@return RNG
function RuneRooms.Helpers:GetRoomRNG(gridIndex)
	local stageRNG = RuneRooms.Helpers:GetStageRNG()

	local roomDescriptor = TSIL.Rooms.GetRoomDescriptor(gridIndex)
	local listIndex = roomDescriptor.ListIndex

	for _ = 1, listIndex, 1 do
		stageRNG:Next()
	end

	return TSIL.RNG.NewRNG(stageRNG:Next())
end

---Returns an unique index for custom "grid entities". This assumes that no two
---"grid entities" can occupy the same grid index.
---@param entity Entity
---@return string
function RuneRooms.Helpers:GetCustomGridIndex(entity)
	local room = Game():GetRoom()
	local gridIndex = room:GetGridIndex(entity.Position)

	local roomDesc = TSIL.Rooms.GetRoomDescriptor()
	local roomListIndex = roomDesc.ListIndex

	return roomListIndex .. "-" .. gridIndex
end

---Helper function to add tear stats in a user friendly way.
---@param fireDelay number
---@param value number
---@return number
function RuneRooms.Helpers:AddTears(fireDelay, value)
	local currentTears = 30 / (fireDelay + 1)
	local newTears = currentTears + value

	return math.max((30 / newTears) - 1, -0.99)
end

---Helper function to get a random position in a room.
---@param allowPits boolean
---@param doOffset boolean Whether to randomly offset the position or be grid aligned
---@param rng RNG
function RuneRooms.Helpers:GetRandomPositionInRoom(allowPits, doOffset, rng)
	local room = Game():GetRoom()

	local gridIndexes = TSIL.GridIndexes.GetAllGridIndexes(true)
	local emptyGridIndexes = TSIL.Utils.Tables.Filter(gridIndexes, function(_, gridIndex)
		local coll = room:GetGridCollision(gridIndex)
		return coll == GridCollisionClass.COLLISION_NONE or (coll == GridCollisionClass.COLLISION_PIT and allowPits)
	end)
	local gridIndex = TSIL.Random.GetRandomElementsFromTable(emptyGridIndexes, 1, rng)[1]

	local basePos = room:GetGridPosition(gridIndex)

	if doOffset then
		local xOffset = TSIL.Random.GetRandomFloat(-20, 20, rng)
		local yOffset = TSIL.Random.GetRandomFloat(-20, 20, rng)
		return Vector(basePos.X + xOffset, basePos.Y + yOffset)
	else
		return basePos
	end
end

---@param player EntityPlayer
---@return boolean
function RuneRooms.Helpers:HasMagicChalk(player)
	local magicchalk = Isaac.GetItemIdByName("Magic Chalk")
	return magicchalk > 0 and player:HasCollectible(magicchalk)
end

---@param gfx string
---@param sfx SoundEffect | integer
---@param player EntityPlayer
---@param rng RNG?
function RuneRooms.Helpers:PlayGiantBook(gfx, sfx, player, rng)
	ItemOverlay.Show(Isaac.GetGiantBookIdByName(gfx), 0, player)
	RuneRooms.Helpers:PlaySound(sfx, rng)
end

---@param sound SoundEffect | integer
---@param rng RNG?
function RuneRooms.Helpers:PlaySound(sound, rng)
	if not rng then
		rng = RNG()
		rng:SetSeed(math.max(1, Isaac.GetFrameCount()), 35)
	end
	if Options.AnnouncerVoiceMode == 2 or Options.AnnouncerVoiceMode == 0 and rng:RandomInt(4) == 0 then
		SFXManager():Play(sound, 1, 0)
	end
end

---@param list table
---@param rng RNG | integer?
---@return table
function RuneRooms.Helpers:Shuffle(list, rng)
	if rng == nil or type(rng) == "number" then
		rng = TSIL.RNG.NewRNG(rng)
	end
	local size, shuffled = #list, TSIL.Utils.Tables.Copy(list)
	for i = size, 2, -1 do
		local j = rng:RandomInt(1, i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end
	return shuffled
end

---@return boolean | nil
function RuneRooms.Helpers:IsInMirrorDimension()
	local room = Game():GetRoom()
	return room:IsMirrorWorld() or StageAPI and StageAPI.IsMirrorDimension()
end

---@param oldTable table
---@param newTable table
---@return table
function RuneRooms.Helpers:MergeTables(oldTable, newTable)
	local tab = TSIL.Utils.Tables.Copy(oldTable)
	local iter = TSIL.Utils.Tables.IsArray(newTable) and ipairs or pairs
	for k, v in iter(newTable) do
		tab[#tab + 1] = v
	end
	return tab
end

---@param list table
---@return number
function RuneRooms.Helpers:TableSize(list)
	local size = 0
	for _ in pairs(list) do
		size = size + 1
	end
	return size
end

---@param list table
---@param condition function
---@return table
function RuneRooms.Helpers:TableQuickSort(list, condition)
	if RuneRooms.Helpers:TableSize(list) <= 1 then
		return list
	end

	local key, value = next(list)

	local left = {}
	local right = {}

	for k, v in pairs(list) do
		if k ~= key then
			if condition(v, value) then
				left[k] = v
			else
				right[k] = v
			end
		end
	end

	local sortLeft = RuneRooms.Helpers:TableQuickSort(left, condition)
	local sortRight = RuneRooms.Helpers:TableQuickSort(right, condition)

	local result = {}
	for _, tab in ipairs({ sortLeft, { [key] = value }, sortRight }) do
		for key, value in pairs(tab) do
			result[key] = value
		end
	end
	return result
end

---@param n number
---@return boolean
function RuneRooms.Helpers:IsInteger(n)
	return type(n) == "number" and n == math.floor(n)
end

function RuneRooms.Helpers:Clamp(n, min, max)
	if n < min then
		return min
	elseif n > max then
		return max
	else
		return n
	end
end