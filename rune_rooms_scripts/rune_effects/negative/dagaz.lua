local DagazNegative = {}

local curseLookup = {
	LevelCurse.CURSE_OF_BLIND,
	LevelCurse.CURSE_OF_DARKNESS,
	LevelCurse.CURSE_OF_LABYRINTH,
	LevelCurse.CURSE_OF_THE_LOST,
	LevelCurse.CURSE_OF_THE_UNKNOWN,
	LevelCurse.CURSE_OF_MAZE,
	LevelCurse.CURSE_OF_BLIND,
}

local function SelectCurse(curses)
    local level = RuneRooms.Level
    curses = curses or level:GetCurses()
    local seed = level:GetDungeonPlacementSeed()
    local rng = RNG(seed)
    local selectedExtraCurse = 0
    repeat
        selectedExtraCurse = curseLookup[rng:RandomInt(1, #curseLookup)]
    until not TSIL.Utils.Flags.HasFlags(curses, selectedExtraCurse)
	RuneRooms:FloorSave().NegativeDagazCurse = selectedExtraCurse
    return selectedExtraCurse
end

---@param curses integer
---@return integer?
function DagazNegative:PickCurse(curses)
	if
		RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.DAGAZ)
		and not TSIL.Utils.Flags.HasFlags(
			curses,
			table.unpack(curseLookup)
		)
	then
        local curse = SelectCurse(curses)
		return TSIL.Utils.Flags.AddFlags(curses, curse)
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, DagazNegative.PickCurse)

function DagazNegative:AddExtraCurse()
	local curse = SelectCurse()
    local level = RuneRooms.Level
    local curses = level:GetCurses()
    level:AddCurse(curse, curses == 0)
end
RuneRooms:AddCallback(RuneRooms.Enums.CustomCallback.POST_GAIN_RUNE_CURSE, DagazNegative.AddExtraCurse, RuneRooms.Enums.RuneEffect.DAGAZ)

function DagazNegative:ForceCurses()
	if RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.DAGAZ) then
        local curse = RuneRooms:FloorSave().NegativeDagazCurse or 0
        local level = RuneRooms.Level
        local curses = level:GetCurses()
        if curse ~= 0 and not TSIL.Utils.Flags.HasFlags(curses, curse) then
            level:AddCurse(curse, curses == 0)
        end
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_UPDATE, DagazNegative.ForceCurses)
