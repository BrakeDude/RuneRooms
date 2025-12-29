---@class ModReference
RuneRooms = RegisterMod("Rune Rooms", 1)

local myFolder = "rune_rooms_loi"
local LOCAL_TSIL = require(myFolder .. ".TSIL")
LOCAL_TSIL.Init(myFolder)

include("rune_rooms_scripts.enums")
include("rune_rooms_scripts.constants")
include("rune_rooms_scripts.helpers")
RuneRooms.API = {}
RuneRooms.Version = "v1.4"

if StageAPI then
	StageAPI.UnregisterCallbacks(RuneRooms.Constants.MOD_ID)
end

RuneRooms.Libs = {}
include("rune_rooms_scripts.lib.hidden_item_manager")
include("rune_rooms_scripts.lib.dss_menu")
include("rune_rooms_scripts.lib.minimap_api")

include("rune_rooms_scripts.mod_compat.main")

include("rune_rooms_scripts.custom_callbacks.main")
include("rune_rooms_scripts.pickups.main")

include("rune_rooms_scripts.room.main")

include("rune_rooms_scripts.rune_effects.main")
--[[include("rune_rooms_scripts.effects.main")
include("rune_rooms_scripts.grid.main")
include("rune_rooms_scripts.item_pools.main")
include("rune_rooms_scripts.items.main")
include("rune_rooms_scripts.player_effects.main")


include("rune_rooms_scripts.tear_effects.main")]]

print("Rune Rooms " .. RuneRooms.Version .. ' loaded. Use "rune help" to get information about commands.')

local function CMDHelp()
	print("rune help - Shows this message.")
	print("rune seteffect [rune_effect] - Changes the rune effect for the current floor.")
	print("rune good [rune_effect] - Activates the good effect of a rune for the current level.")
	print("rune bad [rune_effect] - Activates the bad effect of a rune for the current level.")
	print("rune ehwazmode [mode] - Changes how the positive effect of ehwaz works")

	return true
end

RuneRooms:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, cmd, params)
	if cmd == "rune" then
		local tokens = TSIL.Utils.String.Split(params, " ")
		tokens = TSIL.Utils.Tables.Map(tokens, function(_, token)
			return string.lower(token)
		end)

		if #tokens == 0 then
			CMDHelp()
		else
			local found =
				Isaac.RunCallbackWithParam(RuneRooms.Enums.CustomCallback.ON_CUSTOM_CMD, tokens[1], table.unpack(tokens))

			if not found then
				print("Command " .. tokens[1] .. " not found.")
				print('Type "rune help" to get information about commands.')
			end
		end
	end
end)

--ripairs stuff from revel
function ripairs_it(t,i)
    i=i-1
    local v=t[i]
    if v==nil then return v end
    return i,v
end

function ripairs(t)
    return ripairs_it, t, #t+1
end

RuneRooms:AddCallback(RuneRooms.Enums.CustomCallback.ON_CUSTOM_CMD, CMDHelp, "help")

return
