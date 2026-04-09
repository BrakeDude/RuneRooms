local GeboEssence = {}

local MAX_FREE_USES = 5
local GeboItem = RuneRooms.Enums.Item.GEBO_ESSENCE

TSIL.SaveManager.AddPersistentVariable(
	RuneRooms,
	RuneRooms.Enums.SaveKey.FREE_SLOT_USES_PER_PLAYER,
	{},
	TSIL.Enums.VariablePersistenceMode.RESET_RUN
)

---Returns the number of free slot uses a player has.
---@param player EntityPlayer
---@return integer
function RuneRooms:GetGeboEssenceSlotFreeUses(player)
	local playerIndex = TSIL.Players.GetPlayerIndex(player)
	local freeSlotUsesPerPlayer =
		TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.FREE_SLOT_USES_PER_PLAYER)

	local freeSlotUses = freeSlotUsesPerPlayer[playerIndex]

	if not freeSlotUses then
		return 0
	else
		return freeSlotUses
	end
end

---Decreases the number of free slot uses a player has.
---@param player EntityPlayer
---@param num integer?
function RuneRooms:DecreaseGeboEssenceSlotFreeUses(player, num)
	num = num or 1
	local playerIndex = TSIL.Players.GetPlayerIndex(player)
	local freeSlotUsesPerPlayer =
		TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.FREE_SLOT_USES_PER_PLAYER)

	local freeSlotUses = freeSlotUsesPerPlayer[playerIndex]

	if not freeSlotUses or freeSlotUses == 0 then
		return
	end

	freeSlotUsesPerPlayer[playerIndex] = math.max(freeSlotUses - num, 0)
end

function GeboEssence:OnNewLevel()
	local players = PlayerManager.GetPlayers()
	local freeSlotUsesPerPlayer = {}

	TSIL.Utils.Tables.ForEach(players, function(_, player)
		local playerIndex = TSIL.Players.GetPlayerIndex(player)
		freeSlotUsesPerPlayer[playerIndex] = MAX_FREE_USES
	end)

	TSIL.SaveManager.SetPersistentVariable(
		RuneRooms,
		RuneRooms.Enums.SaveKey.FREE_SLOT_USES_PER_PLAYER,
		freeSlotUsesPerPlayer
	)
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, GeboEssence.OnNewLevel)

function GeboEssence:OnGeboEssencePickup(_, _, firstTime, _, _, player)
	if not firstTime then
		return
	end

	local freeSlotUsesPerPlayer =
		TSIL.SaveManager.GetPersistentVariable(RuneRooms, RuneRooms.Enums.SaveKey.FREE_SLOT_USES_PER_PLAYER)

	local playerIndex = TSIL.Players.GetPlayerIndex(player)
	freeSlotUsesPerPlayer[playerIndex] = MAX_FREE_USES
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, GeboEssence.OnGeboEssencePickup, GeboItem)

---@param slot EntitySlot
---@param collider Entity
---@param low boolean
function GeboEssence:PreSlotCollision(slot, collider, low)
	if
		Gebo.IsGeboSlot(slot)
		and slot.Variant ~= SlotVariant.DONATION_MACHINE
		and slot.Variant ~= SlotVariant.GREED_DONATION_MACHINE
		and collider
		and collider:ToPlayer()
	then
		local player = collider:ToPlayer()
		if
			player:HasCollectible(GeboItem)
			and RuneRooms:GetGeboEssenceSlotFreeUses(player) > 0
			and not slot:GetData().TouchedDelay
		then
			slot:GetData().TouchedDelay = true
			Isaac.CreateTimer(function()
				slot:GetData().TouchedDelay = false
			end, 5, 1, false)
			if Gebo.GetGeboSlot(slot).REPENTOGON then
				if not Gebo.GetData(slot).GeboUses then
					Gebo.GetData(slot).GeboUses = 0
				end
				if Gebo.GetData(slot).GeboUses == 0 then
					RuneRooms:DecreaseGeboEssenceSlotFreeUses(player)
					Gebo.GetData(slot).GeboUses = Gebo.GetData(slot).GeboUses + 1
					return { SkipCollisionEffects = true }
				end
			elseif Gebo.GetData(slot).Gebo == nil then
				local rng = slot:GetDropRNG()
				Gebo.GetData(slot).Gebo = { Uses = Gebo.GetGeboSlot(slot).Plays, rng = rng, Player = player }
				RuneRooms:DecreaseGeboEssenceSlotFreeUses(player)
				return { SkipCollisionEffects = true }
			end
		end
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_PRE_SLOT_COLLISION, GeboEssence.PreSlotCollision)
