if REPENTOGON then
    TSIL.SaveManager.LoadFromDisk()

    if not ImGui.ElementExists("runeRoomsMenu") then
        ImGui.CreateMenu('runeRoomsMenu', 'Room Runes')
    end

    if ImGui.ElementExists("runeRoomsSettings") then
        ImGui.RemoveElement("runeRoomsSettings")
    end

    ImGui.AddElement("runeRoomsMenu", "runeRoomsSettings", ImGuiElement.MenuItem, "\u{f013} Settings")
    if not ImGui.ElementExists("runeRoomsWindow") then
        ImGui.CreateWindow("runeRoomsWindow", "Rune Rooms")
    end
    ImGui.SetWindowSize('runeRoomsWindow', 560, 250)
    ImGui.LinkWindowToElement("runeRoomsWindow", "runeRoomsSettings")
    ImGui.AddText("runeRoomsWindow", "Rune Room sprites", false)
    ImGui.AddCombobox("runeRoomsWindow", "runeRoomsRockSprites", "Rocks", function (index, val)
        TSIL.SaveManager.SetPersistentVariable(
                        RuneRooms,
                        RuneRooms.Enums.SaveKey.ROCKS_SPRITE_MODE,
                        index + 1
                    )
        TSIL.SaveManager.SaveToDisk()
        end, {
            "Detect",
            "Vanilla",
            "Fiend Folio",
        },
        0,
        false
    )
    ImGui.AddCombobox("runeRoomsWindow", "runeRoomsPitSprites", "Pits", function (index, val)
        TSIL.SaveManager.SetPersistentVariable(
                        RuneRooms,
                        RuneRooms.Enums.SaveKey.PITS_SPRITE_MODE,
                        index + 1
                    )
        TSIL.SaveManager.SaveToDisk()
        end, {
            "Detect",
            "Vanilla",
            "Fiend Folio",
        },
        0,
        false
    )
    ImGui.AddText("runeRoomsWindow", "", false)
    ImGui.AddSliderInteger("runeRoomsWindow", "runeRoomsSpawnChance", "Spawn Chance", function (val)
        TSIL.SaveManager.SetPersistentVariable(
                        RuneRooms,
                        RuneRooms.Enums.SaveKey.RUNE_ROOM_SPAWN_CHANCE,
                        val / 100
                    )
        TSIL.SaveManager.SaveToDisk()
        end,
        30,
        0,
        100
    )
    ImGui.AddCallback("runeRoomsMenu", ImGuiCallback.Render, function()
        ImGui.UpdateData("runeRoomsRockSprites", ImGuiData.Value, RuneRooms:GetRocksSpriteMode() - 1)
        ImGui.UpdateData("runeRoomsPitSprites", ImGuiData.Value, RuneRooms:GetPitsSpriteMode() - 1)
        ImGui.UpdateData("runeRoomsSpawnChance", ImGuiData.Value, math.floor(RuneRooms:GetRuneRoomSpawnChance() * 100))
    end)
end