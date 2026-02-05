--[[TSIL.Utils.Tables.ForEach(RuneRooms.Constants.RUNE_NAMES, function (_, name)
    include("rune_rooms_scripts.rune_effects.negative." .. name)
    include("rune_rooms_scripts.rune_effects.positive." .. name)
end)]]

include("rune_rooms_scripts.rune_effects.rune_effects_new")
include("rune_rooms_scripts.rune_effects.minimap")

local RuneEffects = {}

---@param curses LevelCurse | integer
---@return LevelCurse | integer?
function RuneEffects:AddRuneCursesOnNewFloor(curses)
	local PersistentRuneCurses = TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.PERSISTENT_RUNE_CURSES)
    return curses | PersistentRuneCurses
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, RuneEffects.AddRuneCursesOnNewFloor)
