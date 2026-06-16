---@class ModReference
RuneRooms = RegisterMod("Rune Rooms", 1)
RuneRooms.API = {}
RuneRooms.Version = "v2.0"

local tsilFolder = "rune_rooms_loi"
local LOCAL_TSIL = require(tsilFolder .. ".TSIL")
LOCAL_TSIL.Init(tsilFolder)

include("rune_rooms_scripts.globals")

include("rune_rooms_scripts.enums")
include("rune_rooms_scripts.constants")
include("rune_rooms_scripts.helpers")

if StageAPI then
	StageAPI.UnregisterCallbacks(RuneRooms.Constants.MOD_ID)
end

RuneRooms.Libs = {}
RuneRooms.Libs.SaveManager = include("rune_rooms_scripts.lib.save_manager")
RuneRooms.Libs.SaveManager.Init(RuneRooms)

include("rune_rooms_scripts.lib.hud_helper")
include("rune_rooms_scripts.lib.foundhudhelper")

include("rune_rooms_scripts.saving_system")

include("rune_rooms_scripts.lib.imgui")
include("rune_rooms_scripts.lib.minimap_api")
include("rune_rooms_scripts.lib.gebo.main")

include("rune_rooms_scripts.mod_compat.main")

include("rune_rooms_scripts.custom_callbacks.main")
include("rune_rooms_scripts.pickups.main")

include("rune_rooms_scripts.room.main")

include("rune_rooms_scripts.rune_effects.main")
include("rune_rooms_scripts.grid.main")
include("rune_rooms_scripts.items.main")
--[[include("rune_rooms_scripts.effects.main")
include("rune_rooms_scripts.item_pools.main")



include("rune_rooms_scripts.tear_effects.main")]]
include("rune_rooms_scripts.stats_hud")

print("Rune Rooms " .. RuneRooms.Version .. ' loaded. Use "rune help" to get information about commands.')

local function CMDHelp()
	print("rune help - Shows this message.")
	print("rune seteffect [rune_effects] - Changes the rune effect for the current floor.")
	print("rune setgood [rune_effects] - Activates the good effect of a rune for the current level.")
	print("rune unsetgood [rune_effects] - Deactivates the good effect of a rune.")
	print("rune setbad [rune_effects] - Activates the bad effect of a rune for the current run.")
	print("rune unsetbad [rune_effects] - Deactivates the bad effect of a rune.")
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
			local found = Isaac.RunCallbackWithParam(
				RuneRooms.Enums.CustomCallback.ON_CUSTOM_CMD,
				tokens[1],
				table.unpack(tokens)
			)

			if not found then
				print("Command " .. tokens[1] .. " not found.")
				print('Type "rune help" to get information about commands.')
			end
		end
	end
end)

RuneRooms:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	local value = RuneRooms.Helpers:IsDebugEnabled()
	for _, cmd in pairs({ "debug 10", "debug 8" }) do
		local str = Isaac.ExecuteCommand(cmd)
		local enabled = str:gmatch("Enabled")()
		if enabled == nil and value or enabled ~= nil and not value then
			Isaac.ExecuteCommand(cmd)
		end
	end
end)

RuneRooms:AddCallback(RuneRooms.Enums.CustomCallback.ON_CUSTOM_CMD, function(_, _, toggle)
	local value
	local isEnabled = false
	if toggle == "enable" then
		if isEnabled then
			print("Rune Rooms debug mode already activated")
			return true
		end
		RuneRooms.Helpers:SetDebugEnabled(true)
		print("Rune Rooms debug mode activated")
		value = true
	elseif toggle == "disable" then
		if not isEnabled then
			print("Rune Rooms debug mode already deactivated")
			return true
		end
		RuneRooms.Helpers:SetDebugEnabled(false)
		print("Rune Rooms debug mode deactivated")
		value = false
	end

	if value == nil then
		return
	end

	if not Isaac.IsInGame() then
		return true
	end
	for _, cmd in pairs({ "debug 10", "debug 8" }) do
		local str = Isaac.ExecuteCommand(cmd)
		local enabled = str:gmatch("Enabled")()
		if enabled == nil and value or enabled ~= nil and not value then
			Isaac.ExecuteCommand(cmd)
		end
	end
	if value == true then
		for _, player in ipairs(PlayerManager.GetPlayers()) do
			player:AddKeys(99)
			player:AddBombs(99)
			player:AddKeys(99)
			player:AddCollectible(CollectibleType.COLLECTIBLE_MIND)
			player:AddCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE)
			player:AddCollectible(CollectibleType.COLLECTIBLE_FATE)
			player:AddCollectible(CollectibleType.COLLECTIBLE_WOODEN_SPOON)
			player:AddCollectible(CollectibleType.COLLECTIBLE_WOODEN_SPOON)
		end
	end
	return true
end, "debug")

Console.RegisterCommand(
	"rune",
	"Debug command for rune effects",
	"Usage: rune [command] [argument_1] .. [argument_n]",
	true,
	AutocompleteType.CUSTOM
)

local commands = {
	["setgood"] = "Activates the good effect of a rune for the current level",
	["setbad"] = "Activates the bad effect of a rune for the current run",
	["unsetgood"] = "Deactivates the good effect of a rune",
	["unsetbad"] = "Deactivate bad rune effects",
	["seteffect"] = "Deactivates the bad effect of a rune",
	["ehwazmode"] = "Changes how the positive effect of ehwaz works",
}

RuneRooms:AddCallback(ModCallbacks.MC_CONSOLE_AUTOCOMPLETE, function(_, cmd, args)
	local returnTable = {}
	for command, desc in pairs(commands) do
		table.insert(returnTable, { command, desc })
	end
	return returnTable
end, "rune")

--ripairs stuff from revel
function ripairs_it(t, i)
	i = i - 1
	local v = t[i]
	if v == nil then
		return v
	end
	return i, v
end

function ripairs(t)
	return ripairs_it, t, #t + 1
end

RuneRooms:AddCallback(RuneRooms.Enums.CustomCallback.ON_CUSTOM_CMD, CMDHelp, "help")

return
