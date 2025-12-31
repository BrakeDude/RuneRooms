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

TSIL.SaveManager.AddPersistentVariable(
	RuneRooms,
	RuneRooms.Enums.SaveKey.RUNE_ROOM_ENTERED_IN_RUN,
	false,
	TSIL.Enums.VariablePersistenceMode.RESET_RUN
)

function RuneRooms.API:GetRoomSpawnChance()
	return TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.RUNE_ROOM_SPAWN_CHANCE)
end

function RuneRooms.API:SetRoomSpawnChance(value)
	TSIL.SaveManager.SetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.RUNE_ROOM_SPAWN_CHANCE, value)
end

function RuneRooms.API:AddToRoomSpawnChance(value)
	local currentChance = RuneRooms.API:GetRoomSpawnChance()
	RuneRooms.API:SetRoomSpawnChance(currentChance + value)
end

local function RunSpawnChanceCallbacks()
	local callbacks = Isaac.GetCallbacks(RuneRooms.Enums.CustomCallback.RUNE_ROOM_SPAWN_CHANCE)
	local chance = RuneRooms.API:GetRoomSpawnChance()
	for _, callback in ipairs(callbacks) do
		local ret = callback.Function(callback.Mod, chance)
		if type(ret) == "number" then
			chance = chance + ret
		end
	end
	return TSIL.Utils.Math.Clamp(chance, 0, 1)
end

function LevelGen:PlaceRoom()
	local level = game:GetLevel()
	local levelStage = level:GetAbsoluteStage()
	if levelStage >= LevelStage.STAGE4_3 or game:IsGreedMode()
	or game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH) then
	--or not RuneRooms:RoomsUnlocked() or Isaac.GetPlayer(0):GetNumKeys() < 2 then
		return
	end
	if level:GetStageType() >= StageType.STAGETYPE_REPENTANCE then
		levelStage = levelStage + 1
	end
	if
		levelStage % 2 == 0
	then
		local seed = level:GetDungeonPlacementSeed()
		local rng = RNG(seed)
		local chance = RunSpawnChanceCallbacks()
		if rng:RandomFloat() <= chance then
			local outcome = WeightedOutcomePicker()
			for roomID, weight in pairs(RuneRooms.Constants.RUNE_ROOMS_IDS) do
				outcome:AddOutcomeFloat(roomID, weight)
			end
			local roomID = outcome:PickOutcome(rng)
			local roomconf =
				RoomConfig.GetRoomByStageTypeAndVariant(StbType.SPECIAL_ROOMS, RoomType.ROOM_CHEST, roomID, 0)
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
							return
						end
					end
				end
			end
		end
	end
end
RuneRooms:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.IMPORTANT, LevelGen.PlaceRoom)

function LevelGen:ChanceIncrease()
	local room = game:GetRoom()
	local runeRoomWasEntered =
		TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.RUNE_ROOM_ENTERED_IN_RUN)
	if room:IsFirstVisit() and room:GetType() == RoomType.ROOM_SUPERSECRET and not runeRoomWasEntered then
		RuneRooms.API:AddToRoomSpawnChance(0.15)
	end
	if RuneRooms.Helpers:IsRuneRoom() then
		TSIL.SaveManager.SetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.RUNE_ROOM_ENTERED_IN_RUN, true)
		RuneRooms.API:SetRoomSpawnChance(1 / 15)
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, LevelGen.ChanceIncrease)
