local MinimapAPILocal = {}

if not MinimapAPI then
    require("scripts.minimapapi.init")
end


TSIL.SaveManager.AddPersistentVariable(
    RuneRooms,
    RuneRooms.Enums.SaveKey.MINIMAPI_DATA,
    {},
    TSIL.Enums.VariablePersistenceMode.NONE
)


local function IsRuneRoomsMinimapiLoaded()
    return MinimapAPI.BranchVersion == RuneRooms.Constants.MINIMAPI_VERSION
end


if IsRuneRoomsMinimapiLoaded() then
    MinimapAPI.DisableSaving = true
end


function MinimapAPILocal:OnGameStart(isContinue)
    if IsRuneRoomsMinimapiLoaded() then
        local minimapiData = TSIL.SaveManager.GetPersistentVariable(
            RuneRooms,
            RuneRooms.Enums.SaveKey.MINIMAPI_DATA
        )

        if minimapiData.Config then
            MinimapAPI:LoadSaveTable(minimapiData, isContinue)
        end
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    MinimapAPILocal.OnGameStart
)


function MinimapAPILocal:OnGameExit(menuExit)
    --if IsRuneRoomsMinimapiLoaded() then
        local minimapiData = MinimapAPI:GetSaveTable(menuExit)

        TSIL.SaveManager.SetPersistentVariable(
            RuneRooms,
            RuneRooms.Enums.SaveKey.MINIMAPI_DATA,
            minimapiData
        )
    --end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_PRE_GAME_EXIT,
    MinimapAPILocal.OnGameExit
)