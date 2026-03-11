local IngwazRune = {}

local chests = {
    [PickupVariant.PICKUP_CHEST] = true,
    [PickupVariant.PICKUP_BOMBCHEST] = true,
    [PickupVariant.PICKUP_SPIKEDCHEST] = true,
    [PickupVariant.PICKUP_ETERNALCHEST] = true,
    [PickupVariant.PICKUP_MIMICCHEST] = true,
    [PickupVariant.PICKUP_OLDCHEST] = true,
    [PickupVariant.PICKUP_WOODENCHEST] = true,
    [PickupVariant.PICKUP_MEGACHEST] = true,
    [PickupVariant.PICKUP_HAUNTEDCHEST] = true,
    [PickupVariant.PICKUP_LOCKEDCHEST] = true,
    [PickupVariant.PICKUP_REDCHEST] = true,
    [PickupVariant.PICKUP_MOMSCHEST] = true,
}

local function IsChest(pickup)
	return chests[pickup.Variant] ~= nil
end

---@param ingwaz Card | integer
---@param player EntityPlayer
---@param useflags UseFlag | integer
function IngwazRune:UseIngwaz(ingwaz, player, useflags, rng)
	local entities = Isaac.GetRoomEntities()
	local isInvinsible = false
	player:AddCollectible(CollectibleType.COLLECTIBLE_MOMS_KEY, 0, false)
	for i = 1, #entities do
		if entities[i]:ToPickup() then
			local pickup = entities[i]:ToPickup()
			if IsChest(pickup) then
				pickup:TryOpenChest(player)
			else
			end
			local callbacks = Isaac.GetCallbacks(RuneRooms.Enums.CustomCallback.INGWAZ_OPEN_CHEST)
			for _, callback in ipairs(callbacks) do
				if callback.Param and callback.Param == pickup.Variant then
					local ret = callback.Function(pickup, player, isInvinsible)
					if type(ret) == "boolean" and ret == true then
						isInvinsible = ret
					end
				end
			end
		end
	end
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_MOMS_KEY, true)
	return true
end
RuneRooms:AddInternalCallback(
	RuneRooms.Enums.CustomCallback.RUN_RUNE_MAIN,
	IngwazRune.UseIngwaz,
	RuneRooms.Enums.Runes.INGWAZ
)

return IngwazRune