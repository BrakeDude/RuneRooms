RuneRooms.Helpers = {}


---Helper function to check if a room is a rune room
---@param gridIndex integer? @Default: current room index
---@return boolean
function RuneRooms.Helpers:IsRuneRoom(gridIndex)
    local roomData = TSIL.Rooms.GetRoomData(gridIndex)

    if not roomData then return false end

    if roomData.Type ~= RoomType.ROOM_CHEST then return false end
    return RuneRooms.Constants.RUNE_ROOMS_IDS[roomData.Variant] ~= nil
end


do
    local scheduledFunctions = {}

    ---Runs a function in a given number of render frames
    ---@param funct function
    ---@param frames integer
    function RuneRooms.Helpers:RunInNRenderFrames(funct, frames, id)
        local add = true
        if id ~= nil then
            TSIL.Utils.Tables.ForEach(scheduledFunctions, function (_, scheduledFunction)
                if scheduledFunction.id and type(scheduledFunction.id) == type(id) and scheduledFunction.id == id then
                    add = false
                end
            end) 
        end
        if add then
            scheduledFunctions[#scheduledFunctions+1] = {
                funct = funct,
                frames = frames,
                id = id
            }
        end
    end

    RuneRooms:AddCallback(ModCallbacks.MC_POST_RENDER, function ()
        local temp = {}

        TSIL.Utils.Tables.ForEach(scheduledFunctions, function (_, scheduledFunction)
            scheduledFunction.frames = scheduledFunction.frames - 1

            if scheduledFunction.frames <= 0 then
                scheduledFunction.funct()
            else
                temp[#temp+1] = scheduledFunction
            end
        end)

        scheduledFunctions = temp
    end)

    RuneRooms:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function ()
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
    local emptyGridIndexes = TSIL.Utils.Tables.Filter(gridIndexes, function (_, gridIndex)
        local coll = room:GetGridCollision(gridIndex)
        return coll == GridCollisionClass.COLLISION_NONE
        or (coll == GridCollisionClass.COLLISION_PIT and allowPits)
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