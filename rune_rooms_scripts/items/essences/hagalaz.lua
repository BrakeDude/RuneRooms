local HagalazEssence = {}

local TINTED_ROCK_REPLACE_CHANCE = 0.05
local FOOL_ROCK_REPLACE_CHANCE = 0.07
local HagalazItem = RuneRooms.Enums.Item.HAGALAZ_ESSENCE

local function RetractSpikes()
	if Game():GetRoom():GetType() == RoomType.ROOM_SACRIFICE then return end
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

		if rng:RandomFloat() <= TINTED_ROCK_REPLACE_CHANCE then
			rock:SetType(GridEntityType.GRID_ROCKT)
			rock:GetSprite():Play("tinted", true)
			return
		end

		if rng:RandomFloat() <= FOOL_ROCK_REPLACE_CHANCE then
			rock:SetType(GridEntityType.GRID_ROCK_GOLD)
			rock:GetSprite():Play("foolsgold", true)
			return
		end
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

---@param npc EntityNPC
function HagalazEssence:GrimmaceNoShoot(npc)
	if PlayerManager.AnyoneHasCollectible(HagalazItem) then
		npc.ProjectileCooldown = 84
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_NPC_UPDATE, HagalazEssence.GrimmaceNoShoot, EntityType.ENTITY_STONEHEAD)



---@param player EntityPlayer
---@param damage number
---@param flags DamageFlag | integer
---@param source EntityRef
---@param countdown integer
---@return boolean?
function HagalazEssence:NoDamageFromEternalFly(player, damage, flags, source, countdown)
	if
		player:HasCollectible(HagalazItem)
		and (
			source.Entity
				and (source.Entity.Type == EntityType.ENTITY_ETERNALFLY or source.Entity:ToProjectile() and source.Entity.SpawnerType == EntityType.ENTITY_POLTY
			or source.Entity.Type == EntityType.ENTITY_FIREPLACE and source.Entity.Variant ~= 4)
			or flags & DamageFlag.DAMAGE_TNT > 0
			-- Mushroom exploding, no clue if there is a better way to identify it.
			or source and source.Variant == 10000
			or source and source.Type == EntityType.ENTITY_STONEHEAD
		)
	then
		return false
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, HagalazEssence.NoDamageFromEternalFly)

---@param npc EntityNPC
function HagalazEssence:KillGapingMaw(npc)
	if PlayerManager.AnyoneHasCollectible(HagalazItem) then
		npc.State = NpcState.STATE_DEATH
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_NPC_INIT, HagalazEssence.KillGapingMaw, EntityType.ENTITY_GAPING_MAW)
RuneRooms:AddCallback(ModCallbacks.MC_POST_NPC_INIT, HagalazEssence.KillGapingMaw, EntityType.ENTITY_BROKEN_GAPING_MAW)
RuneRooms:AddCallback(ModCallbacks.MC_POST_NPC_INIT, HagalazEssence.KillGapingMaw, EntityType.ENTITY_QUAKE_GRIMACE)

function HagalazEssence:NerfHost(type, variant, subType)
	if type == EntityType.ENTITY_HOST and PlayerManager.AnyoneHasCollectible(HagalazItem) then
		if (variant == 0 or variant == 3 and not ReworkedFoes) and subType == 0 then
			return {type, 1, 0}
		elseif variant == 3 and subType == 0 then
			return {type, variant, 40}
		end
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, HagalazEssence.NerfHost)

--[[
---@param npc EntityNPC
function HagalazEssence:ExplodeTuffTwin(npc)
	if npc.Variant == 2 and PlayerManager.AnyoneHasCollectible(HagalazItem) then
		Isaac.CreateTimer(function ()
			Game():BombExplosionEffects(npc.Position, 1)
		end, 30, 1, false)
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_NPC_INIT, HagalazEssence.ExplodeTuffTwin, EntityType.ENTITY_LARRYJR)]]

---@param grid GridEntity
---@param entity Entity
---@param damage number
---@param flags DamageFlag | integer
---@return boolean?
function HagalazEssence:NoPlayerRedPoopDamage(grid, entity, damage, flags)
	if flags & DamageFlag.DAMAGE_POOP == 0 then return end
	if not entity then return end
	local player = entity:ToPlayer()
	if player and grid:GetVariant() == GridPoopVariant.RED then
		if player:HasCollectible(HagalazItem) then
			return false
		end
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_GRID_HURT_DAMAGE, HagalazEssence.NoPlayerRedPoopDamage, GridEntityType.GRID_POOP)

---@param web GridEntityWeb
function RuneRooms:DestroyCobWeb(web)
	if PlayerManager.AnyoneHasCollectible(HagalazItem) then
		for _, player in ipairs(PlayerManager.GetPlayers()) do
			if player:HasCollectible(HagalazItem) then
				local room = Game():GetRoom()
				if web:GetGridIndex() == room:GetGridIndex(player.Position) then
					web:Destroy()
				end
			end
		end
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_WEB_UPDATE, RuneRooms.DestroyCobWeb, GridEntityType.GRID_SPIDERWEB)


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