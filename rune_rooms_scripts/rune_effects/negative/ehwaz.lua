local EhwazNegative = {}

local TRAPDOOR_REPLACE_CHANCE = 0.3
local REPLACEABLE_GRID_TYPES = {
    GridEntityType.GRID_PILLAR,
    GridEntityType.GRID_POOP,
    GridEntityType.GRID_ROCK,
    GridEntityType.GRID_ROCKB,
    GridEntityType.GRID_ROCKT,
    GridEntityType.GRID_ROCK_ALT,
    GridEntityType.GRID_ROCK_BOMB,
    GridEntityType.GRID_ROCK_GOLD,
    GridEntityType.GRID_ROCK_SPIKED,
    GridEntityType.GRID_ROCK_SS,
}


local function ReplaceGridEntities()
    local gridEntities = TSIL.GridEntities.GetGridEntities(table.unpack(REPLACEABLE_GRID_TYPES))

    TSIL.Utils.Tables.ForEach(gridEntities, function (_, gridEntity)
        local rng = TSIL.RNG.NewRNG(gridEntity.Desc.SpawnSeed)

        if rng:RandomFloat() >= TRAPDOOR_REPLACE_CHANCE then return end

        TSIL.GridEntities.SpawnGridEntity(
            GridEntityType.GRID_TRAPDOOR,
            TSIL.Enums.TrapdoorVariant.NORMAL,
            gridEntity:GetGridIndex(),
            true
        )
    end)
end


function EhwazNegative:OnNewRoom()
    if not RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.EHWAZ) then return end

    ReplaceGridEntities()
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_NEW_ROOM_REORDERED,
    EhwazNegative.OnNewRoom
)


function EhwazNegative:OnEhwazNegativeActivation()
    ReplaceGridEntities()
end
RuneRooms:AddCallback(
    RuneRooms.Enums.CustomCallback.POST_GAIN_RUNE_CURSE,
    EhwazNegative.OnEhwazNegativeActivation,
    RuneRooms.Enums.RuneEffect.EHWAZ
)