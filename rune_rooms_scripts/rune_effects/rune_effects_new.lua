local RuneEffects = {}

local RuneCurses = RuneRooms.Constants.RUNE_CURSES
local RuneBlessings = RuneRooms.Constants.RUNE_BLESSINGS

TSIL.SaveManager.AddPersistentVariable(
	RuneRooms,
	RuneRooms.Enums.SaveKey.LEVEL_RUNE_BLESSINGS,
	0,
	TSIL.Enums.VariablePersistenceMode.RESET_LEVEL
)

TSIL.SaveManager.AddPersistentVariable(
	RuneRooms,
	RuneRooms.Enums.SaveKey.PERSISTENT_RUNE_CURSES,
	0,
	TSIL.Enums.VariablePersistenceMode.RESET_RUN
)

TSIL.SaveManager.AddPersistentVariable(
	RuneRooms,
	RuneRooms.Enums.SaveKey.FORCED_RUNE_EFFECT,
	-1,
	TSIL.Enums.VariablePersistenceMode.RESET_LEVEL
)

---Returns the rune effect for the current floor
---@return RuneEffect
function RuneRooms:GetRuneEffectForFloor()
	local forcedEffect = TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.FORCED_RUNE_EFFECT)

	if forcedEffect >= 0 then
		return forcedEffect
	end

	if not SortedEffects then
		SortedEffects = {}

		for _, value in pairs(RuneRooms.Enums.RuneEffect) do
			SortedEffects[#SortedEffects + 1] = value
		end

		table.sort(SortedEffects)
	end

	local EffectsPicker = WeightedOutcomePicker()

	for _, value in ipairs(SortedEffects) do
		EffectsPicker:AddOutcomeFloat(value, 1)
	end

	local rng = RuneRooms.Helpers:GetStageRNG()

	return EffectsPicker:PickOutcome(rng)
end

---@param runeEffect RuneEffect
---@param isBlessing boolean?
---@return boolean, table
local function EffectExists(runeEffect, isBlessing)
	isBlessing = isBlessing or false
	local lookup = isBlessing and RuneBlessings or RuneCurses
	return RuneRooms.Helpers:IsInteger(runeEffect) and lookup[runeEffect] ~= nil, lookup
end

---@param runeEffect RuneEffect
---@param isBlessing boolean?
---@return boolean
local function IsRuneCurseBlessingActive(runeEffect, isBlessing)
	local exists, lookup = EffectExists(runeEffect, isBlessing)
	if not exists then
		return false
	end
	local curseBlessing =
		TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.PERSISTENT_RUNE_CURSES)

	if isBlessing then
		curseBlessing = TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.LEVEL_RUNE_BLESSINGS)
	end
	return TSIL.Utils.Flags.HasFlags(curseBlessing, runeEffect)
end

---@param runeEffect RuneEffect
---@param isBlessing boolean?
local function ActivateRuneCurseBlessing(runeEffect, isBlessing)
	local exists, lookup = EffectExists(runeEffect, isBlessing)
	if not exists then
		return
	end

	local hadEffectPreviously = IsRuneCurseBlessingActive(runeEffect, isBlessing)

	local saveKey = RuneRooms.Enums.SaveKey.PERSISTENT_RUNE_CURSES

	if isBlessing then
		saveKey = RuneRooms.Enums.SaveKey.LEVEL_RUNE_BLESSINGS
	end

	local effects = TSIL.SaveManager.GetPersistentVariable(RuneRooms, saveKey)

	TSIL.SaveManager.SetPersistentVariable(RuneRooms, effects, TSIL.Utils.Flags.AddFlags(effects, runeEffect))

	if not hadEffectPreviously then
		Isaac.RunCallbackWithParam(
			isBlessing and RuneRooms.Enums.CustomCallback.POST_GAIN_POSITIVE_RUNE_EFFECT
				or RuneRooms.Enums.CustomCallback.POST_GAIN_NEGATIVE_RUNE_EFFECT,
			runeEffect,
			runeEffect
		)
	end
end

---@param runeEffect RuneEffect
---@param isBlessing boolean?
local function DeactivateRuneCurseBlessing(runeEffect, isBlessing)
	local exists, lookup = EffectExists(runeEffect, isBlessing)
	if not exists then
		return
	end

	local saveKey = RuneRooms.Enums.SaveKey.PERSISTENT_RUNE_CURSES

	if isBlessing then
		saveKey = RuneRooms.Enums.SaveKey.LEVEL_RUNE_BLESSINGS
	end

	local effects = TSIL.SaveManager.GetPersistentVariable(RuneRooms, saveKey)

	TSIL.SaveManager.SetPersistentVariable(RuneRooms, effects, TSIL.Utils.Flags.RemoveFlags(effects, runeEffect))
end

---@param ... RuneEffect
function RuneRooms:ActivateRuneCurses(...)
	local args = { ... }
	for _, runeEffect in ipairs(args) do
		ActivateRuneCurseBlessing(runeEffect)
	end
end

---@param ... RuneEffect
function RuneRooms:ActivateRuneBlessings(...)
	local args = { ... }
	for _, runeEffect in ipairs(args) do
		ActivateRuneCurseBlessing(runeEffect, true)
	end
end

---@param ... RuneEffect
function RuneRooms:DeactivateRuneCurses(...)
	local args = { ... }
	for _, runeEffect in ipairs(args) do
		DeactivateRuneCurseBlessing(runeEffect)
	end
end

---@param ... RuneEffect
function RuneRooms:DeactivateRuneBlessings(...)
	local args = { ... }
	for _, runeEffect in ipairs(args) do
		DeactivateRuneCurseBlessing(runeEffect, true)
	end
end

---@param runeEffect RuneEffect
---@return boolean
function RuneRooms:IsRuneCurseActive(runeEffect)
	return IsRuneCurseBlessingActive(runeEffect)
end

---@param runeEffect RuneEffect
---@return boolean
function RuneRooms:IsRuneBlessingActive(runeEffect)
	return IsRuneCurseBlessingActive(runeEffect, true)
end

---@return boolean
local function AnyCurseBlessingActive(isBlessing)
	for _, effect in pairs(RuneRooms.Enums.RuneEffect) do
		if IsRuneCurseBlessingActive(effect, isBlessing) then
			return true
		end
	end
	return false
end

---@param isBlessing boolean?
---@return integer
local function GetAllCursesBlessingMask()
	local curses = 0
	for _, curse in pairs(RuneRooms.Enums.RuneEffect) do
		curses = curses | curse
	end
	return curses
end

function RuneEffects:OnActivateGoodCommand(_, ...)
	local args = { ... }
	if #args == 0 then
		print("You need to provide a rune name(s) as argument(s)")
		return true
	end
	if #args == 1 and args[1] == "all" then
		local mask = GetAllCursesBlessingMask()
		TSIL.SaveManager.SetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.LEVEL_RUNE_BLESSINGS, mask)
		print("Succesfully activated all good rune effects")
		return true
	end

	for _, runeName in ipairs(args) do
		local effect
		for runeEffect, name in pairs(RuneRooms.Constants.RUNE_NAMES) do
			if runeName == name then
				effect = runeEffect
			end
		end

		if not effect then
			print("Failed to find " .. runeName .. " effect")
		elseif not IsRuneCurseBlessingActive(effect, true) then
			ActivateRuneCurseBlessing(effect, true)
			print("Succesfully activated positive " .. runeName .. " effect")
		else
			print("Positive " .. runeName .. " effect already active")
		end
	end

	return true
end
RuneRooms:AddCallback(RuneRooms.Enums.CustomCallback.ON_CUSTOM_CMD, RuneEffects.OnActivateGoodCommand, "setgood")

function RuneEffects:OnDeactivateGoodCommand(_, ...)
	local args = { ... }
	if #args == 0 then
		print("You need to provide a rune name(s) as argument(s)")
		return true
	end

	if #args == 1 and args[1] == "all" then
		if AnyCurseBlessingActive(true) then
			local mask = GetAllCursesBlessingMask()
			TSIL.SaveManager.SetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.LEVEL_RUNE_BLESSINGS, mask)
			print("Succesfully deactivated all positive effects")
		else
			print("No positive effect was activated")
		end
		return true
	end

	for _, runeName in ipairs(args) do
		local effect
		for runeEffect, name in pairs(RuneRooms.Constants.RUNE_NAMES) do
			if runeName == name then
				effect = runeEffect
			end
		end

		if not effect then
			print("Failed to find " .. runeName .. " rune")
		elseif IsRuneCurseBlessingActive(effect, true) then
			DeactivateRuneCurseBlessing(effect, true)
			print("Succesfully deactivated positive " .. runeName .. " effect")
		else
			print("Positive " .. runeName .. " effect wasn't activated")
		end
	end
	return true
end
RuneRooms:AddCallback(RuneRooms.Enums.CustomCallback.ON_CUSTOM_CMD, RuneEffects.OnDeactivateGoodCommand, "unsetgood")

function RuneEffects:OnActivateBadCommand(_, ...)
	local args = { ... }
	if #args == 0 then
		print("You need to provide a rune name(s) as argument(s).")
		return true
	end
	if #args == 1 and args[1] == "all" then
		local mask = GetAllCursesBlessingMask()
		TSIL.SaveManager.SetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.PERSISTENT_RUNE_CURSES, mask)
		print("Succesfully activated all bad rune effects")
		return true
	end

	for _, runeName in ipairs(args) do
		local effect
		for runeEffect, name in pairs(RuneRooms.Constants.RUNE_NAMES) do
			if runeName == name then
				effect = runeEffect
			end
		end

		if not effect then
			print("Failed to find " .. runeName .. " effect")
		elseif not IsRuneCurseBlessingActive(effect) then
			ActivateRuneCurseBlessing(effect)
			print("Succesfully activated negative " .. runeName .. " effect")
		else
			print("Negative " .. runeName .. " effect already active")
		end
	end

	return true
end
RuneRooms:AddCallback(RuneRooms.Enums.CustomCallback.ON_CUSTOM_CMD, RuneEffects.OnActivateBadCommand, "setbad")

function RuneEffects:OnDeactivateBadCommand(_, ...)
	local args = { ... }
	if #args == 0 then
		print("You need to provide a rune name(s) as argument(s).")
		return true
	end

	if #args == 1 and args[1] == "all" then
		if AnyCurseBlessingActive() then
			local mask = GetAllCursesBlessingMask()
			TSIL.SaveManager.SetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.PERSISTENT_RUNE_CURSES, mask)
			print("Succesfully deactivated all negative rune effects")
		else
			print("No negative effect was activated")
		end
		return true
	end

	for _, runeName in ipairs(args) do
		local effect
		for runeEffect, name in pairs(RuneRooms.Constants.RUNE_NAMES) do
			if runeName == name then
				effect = runeEffect
			end
		end

		if not effect then
			print("Failed to find " .. runeName .. " rune")
		elseif IsRuneCurseBlessingActive(effect) then
			DeactivateRuneCurseBlessing(effect)
			print("Succesfully deactivated negative " .. runeName .. " effect")
		else
			print("Negative " .. runeName .. " effect wasn't activated")
		end
	end

	return true
end
RuneRooms:AddCallback(RuneRooms.Enums.CustomCallback.ON_CUSTOM_CMD, RuneEffects.OnDeactivateBadCommand, "unsetbad")

function RuneEffects:OnForceRuneEffect(_, runeName)
	if not runeName then
		print("You need to provide a rune name as argument #1.")
		return true
	end

	local effect
	for runeEffect, name in pairs(RuneRooms.Constants.RUNE_NAMES) do
		if runeName == name then
			effect = runeEffect
		end
	end

	if runeName == "none" then
		effect = -1
	end

	if not effect then
		print("Failed to find " .. runeName .. " rune.")
		return true
	end

	if effect == -1 then
		print("Succesfully set rune effect for the floor to default")
	else
		print("Succesfully set rune effect for the floor to " .. runeName)
	end

	TSIL.SaveManager.SetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.FORCED_RUNE_EFFECT, effect)

	return true
end
RuneRooms:AddCallback(RuneRooms.Enums.CustomCallback.ON_CUSTOM_CMD, RuneEffects.OnForceRuneEffect, "seteffect")
