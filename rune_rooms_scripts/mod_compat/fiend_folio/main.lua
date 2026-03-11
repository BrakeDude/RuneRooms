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
        [3700] = 1,
        [3701] = 1,
        [3702] = 1,
        [3703] = 1,
        [3704] = 1,
        [3705] = 1,
        [3706] = 1,
        [3707] = 1,
        [3708] = 1,
        [3709] = 1,
        [3710] = 1,
        [3711] = 1,
        [3712] = 1,
        [3713] = 1,
        [3714] = 1,
        [3715] = 1,
        [3716] = 1,
    }

    for id, weight in pairs(FFRuneRooms) do
        RuneRooms.API:AddRuneRoom(id, weight)
    end
end)