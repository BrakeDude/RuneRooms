local DagazEssence = {}

local BURNING_RADIUS = 100
local BURNING_DURATION = 30 * 3
local DagazItem = RuneRooms.Enums.Item.DAGAZ_ESSENCE

function DagazEssence:OnDagazPickup(_, _, first)
	if not first then
		return
	end
	RuneRooms:RunSave().RemoveCursesNextFloor = true

	local level = RuneRooms.Level
	level:RemoveCurses(level:GetCurses())
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, DagazEssence.OnDagazPickup, DagazItem)

function DagazEssence:OnCurseEval()
	local removeCurses = RuneRooms:RunSave().RemoveCursesNextFloor

	if removeCurses then
		RuneRooms:RunSave().RemoveCursesNextFloor = nil
		return 0
	end
end
RuneRooms:AddPriorityCallback(ModCallbacks.MC_POST_CURSE_EVAL, CallbackPriority.LATE + 100, DagazEssence.OnCurseEval)

---@param player EntityPlayer
function DagazEssence:OnPeffectUpdate(player)
	if not player:HasCollectible(DagazItem) then
		return
	end

	local haloCount = TSIL.Utils.Tables.Count(
		Isaac.FindByType(
			EntityType.ENTITY_EFFECT,
			EffectVariant.HALO,
			RuneRooms.Enums.EffectSubType.ESSENCE_OF_DAGAZ_HALO
		),
		function(_, effect)
			local halo = effect:ToEffect()
			return halo and halo.Parent and GetPtrHash(player) == GetPtrHash(halo.Parent)
		end
	)
	if haloCount == 0 then
		local halo = TSIL.EntitySpecific.SpawnEffect(
			EffectVariant.HALO,
			RuneRooms.Enums.EffectSubType.ESSENCE_OF_DAGAZ_HALO,
			player.Position,
			Vector.Zero,
			player
		)
		halo:FollowParent(player)
		halo.Parent = player
	end

	local closeEnemies =
		Isaac.FindInCapsule(Capsule(player.Position, player.Position, BURNING_RADIUS), EntityPartition.ENEMY)
	TSIL.Utils.Tables.ForEach(closeEnemies, function(_, enemy)
		if not enemy:ToNPC() then
			return
		end

		enemy:AddBurn(EntityRef(player), BURNING_DURATION, player.Damage)
		TSIL.Entities.SetEntityData(RuneRooms, enemy, "IsBurningFromDagazEffect", true)
	end)
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, DagazEssence.OnPeffectUpdate)

---@param halo EntityEffect
function DagazEssence:HaloUpdate(halo)
	if halo.SubType == RuneRooms.Enums.EffectSubType.ESSENCE_OF_DAGAZ_HALO then
		if
			not halo.Parent
			or halo.Parent.Type ~= EntityType.ENTITY_PLAYER
			or not halo.Parent:Exists()
			or halo.Parent:IsDead()
			or not halo.Parent:ToPlayer():HasCollectible(DagazItem)
		then
			halo:Remove()
			return
		end
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, DagazEssence.HaloUpdate, EffectVariant.HALO)

---@param npc EntityNPC
function DagazEssence:OnNPCUpdate(npc)
	local isBurningFromDagazEffect = TSIL.Entities.GetEntityData(RuneRooms, npc, "IsBurningFromDagazEffect") == true

	if isBurningFromDagazEffect and not npc:HasEntityFlags(EntityFlag.FLAG_BURN) then
		TSIL.Entities.SetEntityData(RuneRooms, npc, "IsBurningFromDagazEffect", false)
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_NPC_UPDATE, DagazEssence.OnNPCUpdate)

---@param npc EntityNPC
function DagazEssence:OnNPCDeath(npc)
	local isBurningFromDagazEffect = TSIL.Entities.GetEntityData(RuneRooms, npc, "IsBurningFromDagazEffect") == true

	if isBurningFromDagazEffect then
		TSIL.EntitySpecific.SpawnEffect(EffectVariant.CRACK_THE_SKY, 0, npc.Position, Vector.Zero) -- Unfourtunately spawning as effect always sets damage to 2
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, DagazEssence.OnNPCDeath)
