local BerkanoEssence = {}

local FAMILIAR_SPAWN_CHANCE = 0.1
local BerkanoItem = RuneRooms.Enums.Item.BERKANO_ESSENCE
local LOCUST_LIFE_SPAWN = 3600

TSIL.SaveManager.AddPersistentVariable(
	RuneRooms,
	RuneRooms.Enums.SaveKey.BERKANO_FAMILIAR_CREATION,
	{},
	TSIL.Enums.VariablePersistenceMode.RESET_RUN
)

---@param entity Entity
local function RemoveWithPoof(entity)
	if entity:Exists() then
		TSIL.EntitySpecific.SpawnEffect(EffectVariant.POOF01, 0, entity.Position)
		entity:Remove()
	end
end

local function AddTempLocusts()

	local entityCreations =
		TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.BERKANO_FAMILIAR_CREATION)
	local entitesToRemove = TSIL.Utils.Tables.Filter(
		Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ABYSS_LOCUST),
		function(_, entitiy)
			return entitiy.FrameCount == 0
		end
	)
	local time = Game().TimeCounter
	entityCreations[time] = entityCreations[time] or {}
	for _, entity in ipairs(entitesToRemove) do
        if not entityCreations[time][entity.SubType] then
            entityCreations[time][entity.SubType] = 0
        end
		entityCreations[time][entity.SubType] = entityCreations[time][entity.SubType] + 1
	end
	TSIL.SaveManager.SetPersistentVariable(
		RuneRooms,
		RuneRooms.Enums.SaveKey.BERKANO_FAMILIAR_CREATION,
		entityCreations
	)
	Isaac.CreateTimer(function()
		for _, entity in ipairs(entitesToRemove) do
			RemoveWithPoof(entity)
		end
        entityCreations[time] = nil
	end, LOCUST_LIFE_SPAWN, 1, true)
end

function BerkanoEssence:OnStartGame(isContinue)
	if isContinue then
		local entityCreations =
			TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.BERKANO_FAMILIAR_CREATION)
        for time, entities in pairs(entityCreations) do
            local newTime = LOCUST_LIFE_SPAWN - (Game().TimeCounter  - time)
            Isaac.CreateTimer(function()
                for entSubType, num in pairs(entities) do
                    local subNum = 0
                    for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ABYSS_LOCUST, entSubType)) do
                        if subNum > num then
                            break
                        end
						if ent:Exists() then
                        	ent:Remove()
						end
                        subNum = subNum + 1
                    end
                    entityCreations[time][entSubType] = nil
                end
                if #entityCreations[time] == 0 then
                    entityCreations[time] = nil
                end
                TSIL.SaveManager.SetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.BERKANO_FAMILIAR_CREATION, entityCreations)
            end, newTime, 1, true)
        end
	end
end
RuneRooms:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.LATE, BerkanoEssence.OnStartGame)

---@param collectible CollectibleType | integer
---@param firstTime boolean
---@param player EntityPlayer
function BerkanoEssence:OnBerkanoPickup(collectible, _, firstTime, _, _, player)
	if not firstTime then
		return
	end
	if collectible == BerkanoItem then
		for i = 1, 3 do
			player:AddLocust(CollectibleType.COLLECTIBLE_1UP, player.Position)
		end
	elseif player:HasCollectible(BerkanoItem) then
		player:AddLocust(collectible, player.Position)
		AddTempLocusts()
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, BerkanoEssence.OnBerkanoPickup)
