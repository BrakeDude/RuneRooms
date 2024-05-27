local LevelGen = {}

local REPENTOGON_RUNE_ROOMS_IDS = {}
for roomID, weight in pairs(RuneRooms.Constants.RUNE_ROOMS_IDS) do
    REPENTOGON_RUNE_ROOMS_IDS[#REPENTOGON_RUNE_ROOMS_IDS+1] = {
        chance = weight,
        value = roomID
    }
end
---Adds a new rune room. The room id must be unique and it has to be a chest.
---
---This function must be called before the first MC_NEW_LEVEL callback fires, otherwise the room won't be loaded.
---@param id integer
---@param weight number
function RuneRooms.API:AddRuneRoom(id, weight)
    RuneRooms.Constants.RUNE_ROOMS_IDS[id] = weight
    if REPENTOGON then
        REPENTOGON_RUNE_ROOMS_IDS[#REPENTOGON_RUNE_ROOMS_IDS+1] = {
            chance = weight,
            value = id
        }
    end
end


local function GetRuneRoomData(roomID)
    Isaac.ExecuteCommand("goto s.chest." .. roomID)

    return TSIL.Rooms.GetRoomData(GridRooms.ROOM_DEBUG_IDX)
end


---@return integer?
local function GetVaultRoom()
    local level = Game():GetLevel()
    local rooms = level:GetRooms()

    for i = 0, rooms.Size-1, 1 do
        local room = rooms:Get(i)
        if room.Data.Type == RoomType.ROOM_CHEST then
            return room.GridIndex
        end
    end

    return nil
end


---@param rng RNG
local function GetRandomRuneRoomData(rng)
    local newData = TSIL.Random.GetRandomElementFromWeightedList(rng, RuneRooms.Constants.RUNE_ROOMS_DATAS)

    return newData
end


---@param index integer
---@param roomData RoomConfig_Room
local function ReplaceRoom(index, roomData)
    local level = Game():GetLevel()

    local writeableRoom = level:GetRoomByIdx(index, -1)
    writeableRoom.Data = roomData
end

if REPENTOGON then
    function LevelGen:ReplaceRoom(levelGeneratorRoom, roomConfigRoom, seed)
        if roomConfigRoom.Type == RoomType.ROOM_CHEST then
            local rng = RuneRooms.Helpers:GetStageRNG()
            if rng:RandomFloat() >= RuneRooms:GetRuneRoomSpawnChance() then return end
            local roomID = TSIL.Random.GetRandomElementFromWeightedList(rng, REPENTOGON_RUNE_ROOMS_IDS)
            local roomconf = RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.SPECIAL_ROOMS, RoomType.ROOM_CHEST, roomID, 0)
            return roomconf
        end
    end
    RuneRooms:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, LevelGen.ReplaceRoom)
else
    function LevelGen:OnNewLevel()
        local rng = RuneRooms.Helpers:GetStageRNG()

        if rng:RandomFloat() >= RuneRooms:GetRuneRoomSpawnChance() then return end

        local vaultRoomIndex = GetVaultRoom()
        if not vaultRoomIndex then return end

        if RuneRooms.Helpers:IsRuneRoom(vaultRoomIndex) then return end

        local newData = GetRandomRuneRoomData(rng)

        ReplaceRoom(vaultRoomIndex, newData)

        RuneRooms.Helpers:RunInNRenderFrames(RuneRooms.ReplaceRuneDoorSprites, 20, "RUNE_ROOM_DOOR")
    end
    RuneRooms:AddCallback(
        TSIL.Enums.CustomCallback.POST_NEW_LEVEL_REORDERED,
        LevelGen.OnNewLevel
    )


    function LevelGen:OnRoomLoad()
        for roomID, weight in pairs(RuneRooms.Constants.RUNE_ROOMS_IDS) do
            local data = GetRuneRoomData(roomID)
            RuneRooms.Constants.RUNE_ROOMS_DATAS[#RuneRooms.Constants.RUNE_ROOMS_DATAS+1] = {
                chance = weight,
                value = data
            }
        end
    end
    RuneRooms:AddCallback(
        RuneRooms.Enums.CustomCallback.ROOM_LOAD,
        LevelGen.OnRoomLoad
    )
end