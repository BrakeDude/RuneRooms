local Minimap = {}

local RUNE_ROOM_ICON_ANM2 = "gfx/ui/rune_room_icon.anm2"

local RuneRoomIconSprite = Sprite()
RuneRoomIconSprite:Load(RUNE_ROOM_ICON_ANM2, true)

MinimapAPI:AddIcon(RuneRooms.Constants.RUNE_ROOM_ICON, RuneRoomIconSprite, "Idle", 0)

function Minimap:UpdateIcon()
	RuneRooms.Helpers:RunInNRenderFrames(function()
		for _, room in ipairs(MinimapAPI:GetLevel()) do
			---@type RoomDescriptor?
			local roomDesc = room.Descriptor
			if roomDesc then
				local isRuneRoom = RuneRooms.API:IsRuneRoomConfig(roomDesc.Data)

				if
					isRuneRoom
					and room.PermanentIcons[1] ~= RuneRooms.Constants.RUNE_ROOM_ICON
				then
					room.PermanentIcons = { RuneRooms.Constants.RUNE_ROOM_ICON }
				end
			end
		end
	end, 1)
end
RuneRooms:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.LATE, Minimap.UpdateIcon)
RuneRooms:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.LATE, Minimap.UpdateIcon)
