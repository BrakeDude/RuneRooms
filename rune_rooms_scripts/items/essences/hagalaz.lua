local HagalazEssence = {}

local TINTED_ROCK_REPLACE_CHANCE = 0.05
local HagalazItem = RuneRooms.Enums.Item.HAGALAZ_ESSENCE

local function RetractSpikes()
	local player = Isaac.GetPlayer()
	local trinketSituation = TSIL.Players.TemporarilyRemoveTrinkets(player)

	player:AddTrinket(TrinketType.TRINKET_FLAT_FILE)

	TSIL.Rooms.UpdateRoom()

	player:TryRemoveTrinket(TrinketType.TRINKET_FLAT_FILE)

	TSIL.Players.GiveTrinketsBack(player, trinketSituation)
end

local function ReplaceRocks()
	local rocks = TSIL.GridSpecific.GetRocks()

	TSIL.Utils.Tables.ForEach(rocks, function(_, rock)
		local rng = TSIL.RNG.NewRNG(rock.Desc.SpawnSeed)

		if rng:RandomFloat() >= TINTED_ROCK_REPLACE_CHANCE then
			return
		end
		rock:SetType(GridEntityType.GRID_ROCKT)
		rock:GetSprite():Play("tinted", true)
	end)
end

function HagalazEssence:OnHagalazEssencePickup()
	RetractSpikes()

	ReplaceRocks()
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, HagalazEssence.OnHagalazEssencePickup, HagalazItem)

function HagalazEssence:OnNewRoom()
	if not PlayerManager.AnyoneHasCollectible(HagalazItem) then
		return
	end

	RetractSpikes()

	ReplaceRocks()
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, HagalazEssence.OnNewRoom)

---@param npc EntityNPC
function HagalazEssence:NoShootFire(npc)
	if
		not PlayerManager.AnyoneHasCollectible(HagalazItem)
		or npc.SpawnerEntity and npc.SpawnerEntity.Type == EntityType.ENTITY_PLAYER
	then
		return
	end
	local sprite = npc:GetSprite()
	if sprite:IsOverlayPlaying("Shoot") then
		sprite:StopOverlay()
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_NPC_UPDATE, HagalazEssence.NoShootFire, EntityType.ENTITY_FIREPLACE)

---@param player EntityPlayer
---@param damage number
---@param flags DamageFlag | integer
---@param source EntityRef
---@param countdown integer
---@return boolean?
function HagalazEssence:NoDamageFromEternalFly(player, damage, flags, source, countdown)
	if source.Entity then
		print(source.Entity.Type)
	end
	print(flags)
	if
		player:HasCollectible(HagalazItem)
		and (
			source.Entity
				and (source.Entity.Type == EntityType.ENTITY_ETERNALFLY or source.Entity:ToProjectile() and source.Entity.SpawnerType == EntityType.ENTITY_POLTY)
			or flags & DamageFlag.DAMAGE_TNT > 0
		)
	then
		return false
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, HagalazEssence.NoDamageFromEternalFly)

---@param grid GridEntity
---@param entity Entity
---@param damage number
---@param flags DamageFlag | integer
---@return boolean?
function HagalazEssence:NoPlayerRedPoopDamage(grid, entity, damage, flags)
	if entity and entity:ToPlayer() and grid:GetVariant() == GridPoopVariant.RED then
		local player = entity:ToPlayer()
		if player:HasCollectible(HagalazItem) then
			return false
		end
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_GRID_HURT_DAMAGE, HagalazEssence.NoPlayerRedPoopDamage, GridEntityType.GRID_POOP)

---@param grid GridEntityRock
---@return boolean?
function HagalazEssence:NoNearExplosion(grid, gridType, immediate, source)
	local players = Isaac.FindInCapsule(Capsule(grid.Position, grid.Position, 60), EntityPartition.PLAYER)
	for _, player in ipairs(players) do
		if player:ToPlayer():HasCollectible(HagalazItem) then
			grid:SetType(GridEntityType.GRID_ROCK)
			grid.State = 1
			grid:Destroy()
			break
		end
	end
end
RuneRooms:AddCallback(
	ModCallbacks.MC_POST_GRID_ROCK_DESTROY,
	HagalazEssence.NoNearExplosion,
	GridEntityType.GRID_ROCK_BOMB
)
