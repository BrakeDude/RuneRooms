local BerkanoEssence = {}

local BerkanoItem = RuneRooms.Enums.Item.BERKANO_ESSENCE
local LOCUST_LIFE_SPAWN = 3600

---@param entity Entity
local function RemoveWithPoof(entity)
	if entity:Exists() then
		TSIL.EntitySpecific.SpawnEffect(EffectVariant.POOF01, 0, entity.Position)
		entity:Remove()
	end
end

local function AddTempLocusts()
	local entitiesToRemove = TSIL.Utils.Tables.Filter(
		Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ABYSS_LOCUST),
		function(_, entitiy)
			return entitiy.FrameCount == 0
		end
	)

	for _, entity in ipairs(entitiesToRemove) do
		RuneRooms:RunSave(entity).TempLocustTimer = LOCUST_LIFE_SPAWN
	end
end

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

---@param locust EntityFamiliar
function BerkanoEssence:TempLocustLifeSpan(locust)
	local locustData = RuneRooms:RunSave(locust)
	if locustData.TempLocustTimer then
		locustData.TempLocustTimer = locustData.TempLocustTimer - 1
		if locustData.TempLocustTimer <= 0 then
			RemoveWithPoof(locust)
		end
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, BerkanoEssence.TempLocustLifeSpan, FamiliarVariant.ABYSS_LOCUST)