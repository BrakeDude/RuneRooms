--#region save functions

---Returns complete save data
---@return table
function RuneRooms:GameSave()
	return RuneRooms.Libs.SaveManager.GetPersistentSave() ---@type table
end

-- Returns a save that lasts the duration of the entire run. Exclusive to players and familiars.
---@param ent? Entity @If an entity is provided, returns an entity specific save within the run save. Otherwise, returns arbitrary data in the save not attached to an entity.
---@param noHourglass false|boolean? @If true, it'll look in a separate game save that is not affected by the Glowing Hourglass.
---@param allowSoulSave? boolean @If true, if the `ent` is The Soul attached to The Forgotten, will return a differently indexed save, as opposed to a shared save between the two.
---@return table
function RuneRooms:RunSave(ent, noHourglass, allowSoulSave)
    return RuneRooms.Libs.SaveManager.GetRunSave(ent, noHourglass, allowSoulSave)
end

-- Returns a save that lasts the duration of the current floor. Exclusive to players and familiars.
---@param ent? Entity  @If an entity is provided, returns an entity specific save within the floor save. Otherwise, returns arbitrary data in the save not attached to an entity.
---@param noHourglass false|boolean? @If true, it'll look in a separate game save that is not affected by the Glowing Hourglass.
---@param allowSoulSave? boolean @If true, if the `ent` is The Soul attached to The Forgotten, will return a differently indexed save, as opposed to a shared save between the two.
---@return table
function RuneRooms:FloorSave(ent, noHourglass, allowSoulSave)
    return RuneRooms.Libs.SaveManager.GetFloorSave(ent, noHourglass, allowSoulSave)
end

-- Returns a save that lasts the duration of the current floor, but data is separated per-room. NOTE: If your data is a pickup, use GetPickupData/GetRerollPersistentData instead
---@param ent? Entity | integer @If an entity is provided, returns an entity specific save within the roomFloor save, which is a floor-lasting save that has unique data per-room. If a grid index is provided, returns a grid index specific save. Otherwise, returns arbitrary data in the save not attached to an entity.
---@param noHourglass false|boolean? @If true, it'll look in a separate game save that is not affected by the Glowing Hourglass.
---@param listIndex? integer @Returns data for the provided `listIndex` instead of the index of the current room.
---@param allowSoulSave? boolean @If true, if the `ent` is The Soul attached to The Forgotten, will return a differently indexed save, as opposed to a shared save between the two.
---@return table
function RuneRooms:RoomSave(ent, noHourglass, listIndex, allowSoulSave)
    return RuneRooms.Libs.SaveManager.GetRoomSave(ent, noHourglass, listIndex, allowSoulSave)
end

---Returns a save that lasts the duration of the current room, being reset once you exit the room.
---@param ent? Entity | integer  @If an entity is provided, returns an entity specific save within the room save. If a grid index is provided, returns a grid index specific save. Otherwise, returns arbitrary data in the save not attached to an entity.
---@param noHourglass false|boolean? @If true, it'll look in a separate game save that is not affected by the Glowing Hourglass.
---@param allowSoulSave? boolean @If true, if the `ent` is The Soul attached to The Forgotten, will return a differently indexed save, as opposed to a shared save between the two.
---@return table
function RuneRooms:TempSave(ent, noHourglass, allowSoulSave)
    return RuneRooms.Libs.SaveManager.GetTempSave(ent, noHourglass, allowSoulSave)
end

--#endregion

--#region Pickup specific saves

--- Gets given pickup's persistent data table or creates an empty one if it doesn't exist.
--- Use this if you intend to add persistent data to a pickup.
---@param pickup EntityPickup
---@param reroll false|boolean? Gets given pickup's reroll persistent data table or creates an empty one if it doesn't exist. @default false
---@param noHourglass false|boolean? @If true, it'll look in a separate game save that is not affected by the Glowing Hourglass.
---@return table
function RuneRooms:PickupSave(pickup, reroll, noHourglass)
    if reroll then
        return RuneRooms.Libs.SaveManager.GetRerollPickupSave(pickup, noHourglass)
    else
        return RuneRooms.Libs.SaveManager.GetNoRerollPickupSave(pickup, noHourglass)
    end
end

--- Gets given pickup's persistent data table.
--- Unlike PickupSave, this function may return nil,
--- and doesn't create a persistent table.
--- Use this if you intend to read, but not add any persistent data.
---@param pickup EntityPickup
---@param reroll false|boolean? Gets given pickup's reroll persistent data table or creates an empty one if it doesn't exist. @default false
---@param noHourglass false|boolean? @If true, it'll look in a separate game save that is not affected by the Glowing Hourglass.
---@return table?
function RuneRooms:TryGetPickupSave(pickup, reroll, noHourglass)
    if reroll then
        return RuneRooms.Libs.SaveManager.TryGetRerollPickupSave(pickup, noHourglass)
    else
        return RuneRooms.Libs.SaveManager.TryGetNoRerollPickupSave(pickup, noHourglass)
    end
end

--#endregion

function RuneRooms:AddDefaultFileSave(key, value)
    RuneRooms:GameSave()[key] = value
end

function RuneRooms:GetDefaultFileSave(key)
    if RuneRooms.Libs.SaveManager.Utility.IsDataInitialized() then
        return RuneRooms:GameSave()[key]
    end
end

local runData = {
    ["RuneRoomSpawnChance"] = 0,
    ["RuneRoomEntered"] = false,
    ["RunesUsedInRun"] = 0,
    ["PersistentRuneCurses"] = 0,
}

RuneRooms.Libs.SaveManager.Utility.AddDefaultRunData(RuneRooms.Libs.SaveManager.DefaultSaveKeys.GLOBAL, runData)

RuneRooms:AddCallback(RuneRooms.Libs.SaveManager.SaveCallbacks.PRE_DATA_LOAD, function(_, data, luaMod)
	if not luaMod then
        local settings = {
            ["RocksSpriteMode"] = RuneRooms.Enums.GridSpriteMode.DEFAULT,
            ["PitsSpriteMode"] = RuneRooms.Enums.GridSpriteMode.DEFAULT,
            ["ShowHudIcon"] = true,
		}
		for k,v in pairs(settings) do
			if data.file.other[k] == nil then
				data.file.other[k] = v
			end
		end
		return data
	end
end)