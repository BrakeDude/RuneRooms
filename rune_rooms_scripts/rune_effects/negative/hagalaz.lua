local HagalazNegative = {}

local REPLACE_CHANCE = 0.3

local function ReplaceGridEntities()
	local rocks = TSIL.GridEntities.GetGridEntities(GridEntityType.GRID_ROCK, GridEntityType.GRID_ROCKB, GridEntityType.GRID_ROCKT, GridEntityType.GRID_ROCK_SS)
    local poops = TSIL.Utils.Tables.Filter(TSIL.GridSpecific.GetPoops(), function(_, poop)
        return poop:GetVariant() < TSIL.Enums.PoopGridEntityVariant.GIGA_TOP_LEFT
        and poop:GetVariant() ~= TSIL.Enums.PoopGridEntityVariant.WHITE and poop:GetVariant() ~= TSIL.Enums.PoopGridEntityVariant.RED
    end)
	local doors = TSIL.GridEntities.GetGridEntities(GridEntityType.GRID_DOOR)

    TSIL.Utils.Tables.ForEach(poops, function(_, poop)
        if poop.State >= 1000 then
            return
        end
        for _, door in ipairs(doors) do
			if poop.Position:Distance(door.Position) <= 120 then
				return
			end
		end

        local rng = RNG(poop.Desc.SpawnSeed)

		if rng:RandomFloat() >= REPLACE_CHANCE then
			return
		end
		TSIL.GridEntities.SpawnGridEntity(GridEntityType.GRID_POOP, TSIL.Enums.PoopGridEntityVariant.RED, poop:GetGridIndex(), true)
	end)

	TSIL.Utils.Tables.ForEach(rocks, function(_, rock)
        if rock.State == 2 then
            return
        end
        for _, door in ipairs(doors) do
			if rock.Position:Distance(door.Position) <= 120 then
				return
			end
		end

        local rng = RNG(rock.Desc.SpawnSeed)

		if rng:RandomFloat() >= REPLACE_CHANCE then
			return
		end

		TSIL.GridEntities.SpawnGridEntity(GridEntityType.GRID_ROCK_SPIKED, 0, rock:GetGridIndex(), true)
	end)
end

local function ReplaceFirePlaces()
	local fires = TSIL.Entities.GetEntities(EntityType.ENTITY_FIREPLACE)
	TSIL.Utils.Tables.ForEach(fires, function(_, fire)
		if fire.Variant % 2 == 0 and fire.Variant < 4 then
            local rng = RNG(fire.InitSeed)
            if rng:RandomFloat() >= REPLACE_CHANCE then
                return
            end
            fire:ToNPC():Morph(fire.Type, fire.Variant + 1, fire.SubType, 0)
        end
	end)
end

function HagalazNegative:OnNewRoom()
	if not RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.HAGALAZ) then
		return
	end

	ReplaceGridEntities()
    ReplaceFirePlaces()
end
RuneRooms:AddCallback(TSIL.Enums.CustomCallback.POST_NEW_ROOM_REORDERED, HagalazNegative.OnNewRoom)

function HagalazNegative:OnHagalazNegativeActivation()
	ReplaceGridEntities()
    ReplaceFirePlaces()
end
RuneRooms:AddCallback(
	RuneRooms.Enums.CustomCallback.POST_GAIN_RUNE_CURSE,
	HagalazNegative.OnHagalazNegativeActivation,
	RuneRooms.Enums.RuneEffect.HAGALAZ
)
