TSIL.Utils.Tables.ForEach(RuneRooms.Constants.RUNE_NAMES, function (_, name)
    include("rune_rooms_scripts.rune_effects.negative." .. name)
    include("rune_rooms_scripts.rune_effects.positive." .. name)
end)

include("rune_rooms_scripts.rune_effects.rune_effects")
if MinimapAPI then
    include("rune_rooms_scripts.rune_effects.minimap")
end