local RuneEffects = {}

local RuneCurses = RuneRooms.Constants.RUNE_CURSES
local RuneBlessings = RuneRooms.Constants.RUNE_BLESSINGS

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
    local forcedEffect = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.FORCED_RUNE_EFFECT
    )

    if forcedEffect >= 0 then
        return forcedEffect
    end

    if not SortedEffects then
        SortedEffects = {}

        for _, value in pairs(RuneRooms.Enums.RuneEffect) do
            SortedEffects[#SortedEffects+1] = value
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
    local curses = Game():GetLevel():GetCurses()
    return TSIL.Utils.Flags.HasFlags(curses, lookup[runeEffect])
end

---@param runeEffect RuneEffect
---@param isBlessing boolean?
local function ActivateRuneCurseBlessing(runeEffect, isBlessing)
    local exists, lookup = EffectExists(runeEffect, isBlessing)
    if not exists then
        return
    end

    local hadEffectPreviously = IsRuneCurseBlessingActive(runeEffect, isBlessing)

    local level = Game():GetLevel()
    print(runeEffect)
    print(lookup[runeEffect])
    level:AddCurse(lookup[runeEffect], false)

    if not isBlessing then
        local negativeEffects = TSIL.SaveManager.GetPersistentVariable(
            RuneRooms,
            RuneRooms.Enums.SaveKey.PERSISTENT_RUNE_CURSES
        )

        TSIL.SaveManager.SetPersistentVariable(
            RuneRooms,
            RuneRooms.Enums.SaveKey.PERSISTENT_RUNE_CURSES,
            TSIL.Utils.Flags.AddFlags(negativeEffects, lookup[runeEffect])
        )
    end

    if not hadEffectPreviously then
        Isaac.RunCallbackWithParam(
            isBlessing and RuneRooms.Enums.CustomCallback.POST_GAIN_POSITIVE_RUNE_EFFECT or RuneRooms.Enums.CustomCallback.POST_GAIN_NEGATIVE_RUNE_EFFECT,
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

    local level = Game():GetLevel()
    level:RemoveCurses(lookup[runeEffect])

    if not isBlessing then
        local negativeEffects = TSIL.SaveManager.GetPersistentVariable(
            RuneRooms,
            RuneRooms.Enums.SaveKey.PERSISTENT_RUNE_CURSES
        )

        TSIL.SaveManager.SetPersistentVariable(
            RuneRooms,
            RuneRooms.Enums.SaveKey.PERSISTENT_RUNE_CURSES,
            TSIL.Utils.Flags.RemoveFlags(negativeEffects, lookup[runeEffect])
        )
    end
end

---@param runeEffect RuneEffect
function RuneRooms:ActivateRuneCurse(runeEffect)
    ActivateRuneCurseBlessing(runeEffect)
end

---@param runeEffect RuneEffect
function RuneRooms:ActivateRuneBlessing(runeEffect)
    ActivateRuneCurseBlessing(runeEffect, true)
end

---@param runeEffect RuneEffect
function RuneRooms:DeactivateRuneCurse(runeEffect)
    DeactivateRuneCurseBlessing(runeEffect)
end

---@param runeEffect RuneEffect
function RuneRooms:DeactivateRuneBlessing(runeEffect)
    DeactivateRuneCurseBlessing(runeEffect, true)
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

function RuneEffects:OnActivateGoodCommand(_, runeName)
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

    if not effect then
        print("Failed to find " .. runeName .. " rune.")
        return true
    end

    RuneRooms:ActivateRuneBlessing(effect)
    print("Succesfully activated positive " .. runeName .. " effect")

    return true
end
RuneRooms:AddCallback(
    RuneRooms.Enums.CustomCallback.ON_CUSTOM_CMD,
    RuneEffects.OnActivateGoodCommand,
    "setgood"
)

function RuneEffects:OnDeactivateGoodCommand(_, runeName)
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

    if not effect then
        print("Failed to find " .. runeName .. " rune.")
        return true
    end

    if RuneRooms:IsRuneBlessingActive(effect) then
        RuneRooms:DeactivateRuneBlessing(effect)
        print("Succesfully deactivated positive " .. runeName .. " effect")
    else
        print("Positive " .. runeName .." effect wasn't activated")
    end

    return true
end
RuneRooms:AddCallback(
    RuneRooms.Enums.CustomCallback.ON_CUSTOM_CMD,
    RuneEffects.OnDeactivateGoodCommand,
    "unsetgood"
)


function RuneEffects:OnActivateBadCommand(_, runeName)
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

    if not effect then
        print("Failed to find " .. runeName .. " rune.")
        return true
    end

    RuneRooms:ActivateRuneCurse(effect)
    print("Succesfully activated negative " .. runeName .. " effect")

    return true
end
RuneRooms:AddCallback(
    RuneRooms.Enums.CustomCallback.ON_CUSTOM_CMD,
    RuneEffects.OnActivateBadCommand,
    "setbad"
)

function RuneEffects:OnDeactivateBadCommand(_, runeName)
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

    if not effect then
        print("Failed to find " .. runeName .. " rune.")
        return true
    end

    if RuneRooms:IsRuneCurseActive(effect) then
        RuneRooms:DeactivateRuneCurse(effect)
        print("Succesfully deactivated negative " .. runeName .. " effect")
    else
        print("Negative " .. runeName .." effect wasn't activated")
    end

    return true
end
RuneRooms:AddCallback(
    RuneRooms.Enums.CustomCallback.ON_CUSTOM_CMD,
    RuneEffects.OnDeactivateBadCommand,
    "unsetbad"
)


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

    TSIL.SaveManager.SetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.FORCED_RUNE_EFFECT,
        effect
    )

    return true
end
RuneRooms:AddCallback(
    RuneRooms.Enums.CustomCallback.ON_CUSTOM_CMD,
    RuneEffects.OnForceRuneEffect,
    "seteffect"
)