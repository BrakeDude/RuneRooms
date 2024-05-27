local Minimap = {}

local RUNE_ROOM_ICON_ANM2 = "gfx/ui/rune_room_icon.anm2"


local RuneRoomIconSprite = Sprite()
RuneRoomIconSprite:Load(RUNE_ROOM_ICON_ANM2, true)

MinimapAPI:AddIcon(
    RuneRooms.Constants.RUNE_ROOM_ICON,
    RuneRoomIconSprite,
    "Idle",
    0
)


function Minimap:OnNewLevel()
    RuneRooms.Helpers:RunInNRenderFrames(function ()
        for _, room in ipairs(MinimapAPI:GetLevel()) do
            ---@type RoomDescriptor?
            local roomDesc = room.Descriptor
            if roomDesc then
                local roomData = roomDesc.Data
                local isRuneRoomID = RuneRooms.Constants.RUNE_ROOMS_IDS[roomData.Variant] ~= nil

                if roomData.Type == RoomType.ROOM_CHEST and isRuneRoomID then
                    room.PermanentIcons = {RuneRooms.Constants.RUNE_ROOM_ICON}
                end
            end
        end
    end, 20, "RUNE_ROOM_MINIMAP")
end
RuneRooms:AddPriorityCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    CallbackPriority.LATE,
    Minimap.OnNewLevel
)