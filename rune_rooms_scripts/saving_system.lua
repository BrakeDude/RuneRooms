function RuneRooms:GameSave()
	return RuneRooms.Libs.SaveManager.GetPersistentSave()
end

function RuneRooms:RunSave(ent, noHourglass, allowSoulSave)
    return RuneRooms.Libs.SaveManager.GetRunSave(ent, noHourglass, allowSoulSave)
end

function RuneRooms:FloorSave(ent, noHourglass, allowSoulSave)
    return RuneRooms.Libs.SaveManager.GetFloorSave(ent, noHourglass, allowSoulSave)
end

function RuneRooms:RoomFloorSave(ent, noHourglass, listIndex, allowSoulSave)
    return RuneRooms.Libs.SaveManager.GetRoomSave(ent, noHourglass, listIndex, allowSoulSave)
end

function RuneRooms:RoomSave(ent, noHourglass, allowSoulSave)
    return RuneRooms.Libs.SaveManager.GetTempSave(ent, noHourglass, allowSoulSave)
end

function RuneRooms:PickupSave(ent, reroll, noHourglass)
    if reroll then
        return RuneRooms.Libs.SaveManager.GetRerollPickupSave(ent, noHourglass)
    else
        return RuneRooms.Libs.SaveManager.GetNoRerollPickupSave(ent, noHourglass)
    end
end

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


RuneRooms:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function(_, isSaving)
    if isSaving then
        local runSave = RuneRooms:RunSave()
        runSave.HiddenItemManager = RuneRooms.Libs.HiddenItemManager:GetSaveData()
    end
end)

RuneRooms:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isLoading)
    if isLoading then
        local runSave = RuneRooms:RunSave()
        RuneRooms.Libs.HiddenItemManager:LoadData(runSave.HiddenItemManager)
    end
end)

RuneRooms:AddCallback(RuneRooms.Libs.SaveManager.SaveCallbacks.PRE_DATA_LOAD, function(_, data, luaMod)
	if not luaMod then
        local settings = {
            ["RocksSpriteMode"] = RuneRooms.Enums.GridSpriteMode.DEFAULT,
            ["PitsSpriteMode"] = RuneRooms.Enums.GridSpriteMode.DEFAULT,
		}
		for k,v in pairs(settings) do
			if data.file.other[k] == nil then
				data.file.other[k] = v
			end
		end
		return data
	end
end)