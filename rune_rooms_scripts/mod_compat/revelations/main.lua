RuneRooms:AddModCompat("REVEL", function ()
    local RUNE_DOOR_GLACIER_SPRITE = "gfx/grid/door_rune_room_glacier.png"
    local RUNE_DOOR_TOMB_SPRITE = "gfx/grid/door_rune_room_glacier.png"

    RuneRooms:AddCallback(
        RuneRooms.Enums.CustomCallback.PRE_GET_RUNE_DOOR_SPRITE,
        function ()
            local currentStage = StageAPI.GetCurrentStage()
            if not currentStage then return end

            local currentStageName = currentStage.Name

            if RuneRooms.Helpers:IsRuneRoom() then
                return
            end

            if currentStageName == "Glacier" then
                return RUNE_DOOR_GLACIER_SPRITE
            elseif currentStageName == "Tomb" then
                return RUNE_DOOR_TOMB_SPRITE
            end
        end
    )
end)