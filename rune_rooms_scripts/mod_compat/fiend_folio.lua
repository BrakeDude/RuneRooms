RuneRooms:AddModCompat("FiendFolio", function ()
    local PIT_SPRITE_FF = "gfx/grid/grid_pit_rune.png"
    local GRIDS_SPRITE_FF = "gfx/grid/rocks_rune.png"

    RuneRooms:AddCallback(
        RuneRooms.Enums.CustomCallback.PRE_GET_RUNE_PIT_SPRITE,
        function ()
            return PIT_SPRITE_FF
        end
    )

    RuneRooms:AddCallback(
        RuneRooms.Enums.CustomCallback.PRE_GET_RUNE_GRID_SPRITE,
        function ()
            return GRIDS_SPRITE_FF
        end
    )

    local FFRuneRooms = {
        
    }

    for id, weight in pairs(FFRuneRooms) do
        RuneRooms.API:AddRuneRoom(id, weight)
    end
end)