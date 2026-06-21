local HagalazPositive = {}

local function Dust(position)
	for i = 1, math.random(9, 10) do
		Isaac.Spawn(
			EntityType.ENTITY_EFFECT,
			EffectVariant.DUST_CLOUD,
			0,
			position,
			RandomVector():Normalized() * math.random(0.4, 1.3),
			nil
		)
	end
end

local function DoThing(entData, filter, func)
	local entities = Isaac.FindByType(type(entData) == "table" and table.unpack(entData) or entData)
	if filter then
		entities = TSIL.Utils.Tables.Filter(entities, function(_, entity)
			return filter(entity)
		end)
	end
	for _, entity in ipairs(entities) do
		func(entity)
	end
end

---@param gridEntity GridEntity
---@return boolean
local function CanBeDestroyed(gridEntity)
	return gridEntity:IsBreakableRock() or gridEntity:ToPoop() ~= nil or gridEntity:ToTNT() ~= nil
end

function HagalazPositive:OnNewRoom()
	if not RuneRooms:IsRuneBlessingActive(RuneRooms.Enums.RuneEffect.HAGALAZ) then
		return
	end

	Isaac.CreateTimer(function()
		local gridEntities = TSIL.GridEntities.GetGridEntities()
		local rocks = TSIL.Utils.Tables.Filter(gridEntities, function(_, gridEntity)
			return CanBeDestroyed(gridEntity)
		end)

		TSIL.Utils.Tables.ForEach(rocks, function(_, rock)
			rock:Destroy()
		end)

		DoThing(EntityType.ENTITY_HOST, function(entity)
			--return entity.Variant ~= 1
		end, function(entity)
			entity = entity:ToNPC()
			entity:Morph(entity.Type, 1, entity.SubType, entity:GetChampionColorIdx())
			Dust(entity.Position)
		end)

		TSIL.Utils.Tables.ForEach(
			{ { EntityType.ENTITY_KNIGHT, 0 }, EntityType.ENTITY_FLOATING_KNIGHT, EntityType.ENTITY_BONE_KNIGHT },
			function(_, Type)
				DoThing(Type, nil, function(entity)
					entity = entity:ToNPC()
					entity:Morph(EntityType.ENTITY_BRAIN, 0, 0, -1)
					Dust(entity.Position)
				end)
			end
		)

		TSIL.Utils.Tables.ForEach(
			{ { EntityType.ENTITY_KNIGHT, 2 }, { EntityType.ENTITY_KNIGHT, 4 } },
			function(_, Type)
				DoThing(Type, nil, function(_, entity)
					entity = entity:ToNPC()
					entity:Morph(EntityType.ENTITY_PON, 0, 0, -1)
					Dust(entity.Position)
				end)
			end
		)

		TSIL.Utils.Tables.ForEach({
			EntityType.ENTITY_STONEY,
			EntityType.ENTITY_CONSTANT_STONE_SHOOTER,
			EntityType.ENTITY_STONEHEAD,
			EntityType.ENTITY_STONE_EYE,
			EntityType.ENTITY_BRIMSTONE_HEAD,
			EntityType.ENTITY_GAPING_MAW,
			EntityType.ENTITY_BROKEN_GAPING_MAW,
			EntityType.ENTITY_FLOATING_HOST,
			EntityType.ENTITY_QUAKE_GRIMACE,
			EntityType.ENTITY_POKY,
			EntityType.ENTITY_WALL_HUGGER,
			EntityType.ENTITY_GRUDGE,
			EntityType.ENTITY_BALL_AND_CHAIN,
			EntityType.ENTITY_SPIKEBALL,
			{ EntityType.ENTITY_SINGE , 1},
			{ EntityType.ENTITY_KNIGHT, 3 },
			EntityType.ENTITY_BOMB_GRIMACE,
			{ EntityType.ENTITY_ROCK_SPIDER, 1 },
			{ EntityType.ENTITY_ROCK_SPIDER, 2 },
		}, function(_, Type)
			DoThing(Type, nil, function(_, entity)
				entity:Kill()
			end)
		end)

		TSIL.Utils.Tables.ForEach({
			{ EntityType.ENTITY_LARRYJR, 2 },
			{ EntityType.ENTITY_LARRYJR, 3 },
		}, function(_, Type)
			DoThing(Type, nil, function(i, entity)
				if entity.HitPoints > 20 then
					entity.HitPoints = 20
				end
			end)
		end)
	end, 3, 1, false)
end
RuneRooms:AddCallback(TSIL.Enums.CustomCallback.POST_NEW_ROOM_REORDERED, HagalazPositive.OnNewRoom)
