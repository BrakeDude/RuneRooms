include("rune_rooms_scripts.tear_effects.blood_creep")

---Adds a custom tear flag to a tear.
---@param tear EntityTear
---@param tearFlag CustomTearFlag | integer
function RuneRooms:AddCustomTearFlag(tear, tearFlag)
    local currentFlags = TSIL.Entities.GetEntityData(
        RuneRooms,
        tear,
        "CustomTearFlags"
    )

    if not currentFlags then currentFlags = 0 end

    if not TSIL.Utils.Flags.HasFlags(currentFlags, tearFlag) then
        Isaac.RunCallbackWithParam(
            RuneRooms.Enums.CustomCallback.POST_CUSTOM_TEAR_FLAG_ADDED,
            tearFlag,
            tear,
            tearFlag
        )
    end

    local newFlags = TSIL.Utils.Flags.AddFlags(currentFlags, tearFlag)
    TSIL.Entities.SetEntityData(
        RuneRooms,
        tear,
        "CustomTearFlags",
        newFlags
    )
end


---Removes a custom tear flag from a tear
---@param tear any
---@param tearFlag any
function RuneRooms:RemoveCustomTearFlag(tear, tearFlag)
    local currentFlags = TSIL.Entities.GetEntityData(
        RuneRooms,
        tear,
        "CustomTearFlags"
    )

    if not currentFlags then return end

    if TSIL.Utils.Flags.HasFlags(currentFlags, tearFlag) then
        Isaac.RunCallbackWithParam(
            RuneRooms.Enums.CustomCallback.POST_CUSTOM_TEAR_FLAG_REMOVED,
            tearFlag,
            tear,
            tearFlag
        )
    end

    TSIL.Entities.SetEntityData(
        RuneRooms,
        tear,
        "CustomTearFlags",
        TSIL.Utils.Flags.RemoveFlags(currentFlags, tearFlag)
    )
end


---Gets the custom tear flags a tear has.
---@param tear EntityTear
---@return integer
function RuneRooms:GetCustomTearFlags(tear)
    local currentFlags = TSIL.Entities.GetEntityData(
        RuneRooms,
        tear,
        "CustomTearFlags"
    )

    if not currentFlags then return 0 end

    return currentFlags
end


---Checks if a tear has the given custom tear flags.
---@param tear EntityTear
---@param tearFlag CustomTearFlag | integer
function RuneRooms:HasCustomTearFlag(tear, tearFlag)
    local currentFlags = TSIL.Entities.GetEntityData(
        RuneRooms,
        tear,
        "CustomTearFlags"
    )

    if not currentFlags then return false end

    return TSIL.Utils.Flags.HasFlags(currentFlags, tearFlag)
end