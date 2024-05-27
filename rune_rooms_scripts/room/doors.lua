local RuneDoors = {}

local RUNE_DOOR_SPRITE = "gfx/grid/door_rune_room.png"


---@param roomType RoomType
local function IsSecretRoom(roomType)
    return roomType == RoomType.ROOM_SECRET or roomType == RoomType.ROOM_SUPERSECRET
end


---@param door GridEntityDoor
local function CanReplaceDoorSprite(door)
    local room = Game():GetRoom()
    local roomType = room:GetType()
    local targetRoomType = door.TargetRoomType

    --Don't replace hole doors
    if IsSecretRoom(roomType) or IsSecretRoom(targetRoomType) then
        return false
    end

    --If we are in a rune room and the target is a default room, change the door
    if RuneRooms.Helpers:IsRuneRoom() and targetRoomType == RoomType.ROOM_DEFAULT then
        return true
    end

    --If the target is a rune room, replace
    return RuneRooms.Helpers:IsRuneRoom(door.TargetRoomIndex)
end


---@param door GridEntityDoor
local function ReplaceDoorSprite(door)
    local sprite = door:GetSprite()

    local spriteSheet = RUNE_DOOR_SPRITE

    local newSpriteSheet = Isaac.RunCallback(
        RuneRooms.Enums.CustomCallback.PRE_GET_RUNE_DOOR_SPRITE,
        door
    )

    if type(newSpriteSheet) == "string" then
        spriteSheet = newSpriteSheet
    end

    for i = 0, sprite:GetLayerCount()-1, 1 do
        sprite:ReplaceSpritesheet(i, spriteSheet)
    end

    sprite:LoadGraphics()
end


---@param door GridEntityDoor
local function TryReplaceDoorSprite(door)
    if CanReplaceDoorSprite(door) then
        ReplaceDoorSprite(door)
    end
end


function RuneRooms:ReplaceRuneDoorSprites()
    local doors = TSIL.Doors.GetDoors()

    TSIL.Utils.Tables.ForEach(doors, function (_, door)
        TryReplaceDoorSprite(door)
    end)
end

function RuneDoors:OnNewRoom()
    RuneRooms:ReplaceRuneDoorSprites()
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_NEW_ROOM_REORDERED,
    RuneDoors.OnNewRoom
)