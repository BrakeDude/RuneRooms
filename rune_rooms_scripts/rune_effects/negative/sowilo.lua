local SowiloNegative = {}


---@param entry RoomConfig_Entry
local function CanSpawnEntry(entry)
    return entry.Type > 9 and entry.Type < 960
end


local function GridCoordsToPos(x, y)
    local newX = (x + 2) * 40
    local newY = (y + 4) * 40

    return Vector(newX, newY)
end


function SowiloNegative:OnRoomClear()
    if not RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.SOWILO) then return end

    TSIL.Doors.CloseAllDoors(true)

    local room = Game():GetRoom()
    local roomDesc = TSIL.Rooms.GetRoomDescriptor()
    local roomData = roomDesc.Data

    if roomData.Type ~= RoomType.ROOM_DEFAULT then return end

    local rng = TSIL.RNG.NewRNG(roomDesc.SpawnSeed)
    local spawns = roomData.Spawns
    for i = 0, spawns.Size-1, 1 do
        local spawn = spawns:Get(i)
        local entry = spawn:PickEntry(rng:Next())

        if CanSpawnEntry(entry) then
            local position = GridCoordsToPos(spawn.X, spawn.Y)
            local gridColl = room:GetGridCollisionAtPos(position)

            if gridColl == GridCollisionClass.COLLISION_NONE then
                TSIL.Entities.Spawn(
                    entry.Type,
                    entry.Variant,
                    entry.Subtype,
                    position
                )
            end
        end
    end
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_ROOM_CLEAR_CHANGED,
    SowiloNegative.OnRoomClear,
    true
)