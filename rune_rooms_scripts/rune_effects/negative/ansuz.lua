local AnsuzNegative = {}
local MinimapAPICallbacks = require("scripts.minimapapi.callbacks")

local function GetRandomRoomWithEnemies(roomType)
	local level = Game():GetLevel()
	local seed = level:GetDungeonPlacementSeed()
	local rng = RNG(seed)
	local roomconfig
	local allow = false
	repeat
        allow = false
		roomconfig = RoomConfig.GetRandomRoom(rng:GetSeed(), false, StbType.SPECIAL_ROOMS, roomType)
		for i = 0, roomconfig.Spawns.Size - 1 do
			local spawn = roomconfig.Spawns:Get(i)
			for j = 0, spawn.Entries.Size - 1 do
				local entry = spawn.Entries:Get(j)
				if entry.Type > 6 and entry.Type < 1000 and entry.Type ~= EntityType.ENTITY_GENERIC_PROP
                and entry.Type ~= EntityType.ENTITY_SHOPKEEPER and entry.Type ~= EntityType.ENTITY_DUMMY
                and entry.Type ~= EntityType.ENTITY_FIREPLACE then
					allow = true
					goto continue
				end
			end
		end
        ::continue::
        rng:Next()
	until roomconfig ~= nil and allow == true
    return roomconfig
end

---@param slot LevelGeneratorRoom
---@param roomConfig RoomConfigRoom
---@param seed integer
function AnsuzNegative:ReplaceRoomWithEnemiesOnly(slot, roomConfig, seed)
    if RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.ANSUZ) then
        if roomConfig.Type == RoomType.ROOM_SECRET or roomConfig.Type == RoomType.ROOM_SUPERSECRET then
            local newConfig = GetRandomRoomWithEnemies(roomConfig.Type)
            return newConfig
        end
    end
end
RuneRooms:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, AnsuzNegative.ReplaceRoomWithEnemiesOnly)

function AnsuzNegative:RemovePickups()
	if not RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.ANSUZ) then return end
	local room = Game():GetRoom()
    
    if (room:GetType() == RoomType.ROOM_SECRET or room:GetType() == RoomType.ROOM_SUPERSECRET)
    and room:IsFirstVisit() then
        for _, entryType in ipairs({EntityType.ENTITY_PICKUP, EntityType.ENTITY_SHOPKEEPER, EntityType.ENTITY_SLOT, EntityType.ENTITY_FIREPLACE}) do
            for _, entry in ipairs(Isaac.FindByType(entryType)) do
                entry:Remove()
            end
        end
    end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, AnsuzNegative.RemovePickups)

---@param runeEffect RuneEffect
function AnsuzNegative:ReplaceCurrentLevelRooms(runeEffect)
    local level = Game():GetLevel()
    local rooms = level:GetRooms()
    for i = 0, rooms.Size - 1 do
        local room = rooms:Get(i)
        if (room.Data.Type == RoomType.ROOM_SECRET or room.Data.Type == RoomType.ROOM_SUPERSECRET) and
        room.VisitedCount == 0 then
            local newRoomConfig = GetRandomRoomWithEnemies(room.Data.Type)
            room.Data = newRoomConfig
        end
    end
end
RuneRooms:AddCallback(RuneRooms.Enums.CustomCallback.POST_GAIN_RUNE_CURSE, AnsuzNegative.ReplaceCurrentLevelRooms, RuneRooms.Enums.RuneEffect.ANSUZ)

function AnsuzNegative:NoRewardInSecretRooms()
	if RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.ANSUZ) then
		return true
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, AnsuzNegative.NoRewardInSecretRooms)


-- From MinimapAPI code of April Fools challenge
---@param room MinimapAPI.Room
---@param playerPos Vector
---@return Vector?
function AnsuzNegative:RandomMinimapPosition(room, playerPos)
    if not RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.ANSUZ) then return end
    local cache = MinimapAPI.Cache
    local level = Game():GetLevel()
    local currentroom = cache.RoomDescriptor
	if currentroom.GridIndex < 0 then
		return Vector(-32768,-32768)
    else
        local randomRoom = level:GetRooms():Get(level:GetRoomByIdx(level:GetRandomRoomIndex(false, cache.RoomDescriptor.DecorationSeed), MinimapAPI.CurrentDimension).ListIndex)
        return MinimapAPI:GridIndexToVector(randomRoom.GridIndex) + MinimapAPI.RoomShapeGridPivots[randomRoom.Data.Shape]
    end
end
RuneRooms:AddCallback(MinimapAPICallbacks.PLAYER_POS_CHANGED, AnsuzNegative.RandomMinimapPosition)