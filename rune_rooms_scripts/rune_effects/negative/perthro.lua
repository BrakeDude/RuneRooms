local PerthroNegative = {}

function PerthroNegative:PreEntitySpawn(type, variant, subtype, _, _, _, seed)
	if not RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.PERTHRO) then
		return
	end

	if type ~= EntityType.ENTITY_PICKUP then
		return
	end
	if variant ~= PickupVariant.PICKUP_COLLECTIBLE then
		return
	end

	local isQuestItem = TSIL.Collectibles.CollectibleHasFlag(subtype, TSIL.Enums.ItemConfigTag.QUEST)
	local isRuneEssence = TSIL.Utils.Tables.IsIn(RuneRooms.Enums.Item, subtype)

	if isQuestItem or isRuneEssence then
		return
	end

	return {
		type,
		PickupVariant.PICKUP_TRINKET,
		TrinketType.TRINKET_NULL,
		seed,
	}
end
--[[RuneRooms:AddCallback(
    ModCallbacks.MC_PRE_ENTITY_SPAWN,
    PerthroNegative.PreEntitySpawn
)]]

---@param pickup EntityPickup
function PerthroNegative:OnCollectibleInit(pickup)
	if not RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.PERTHRO) then
		return
	end

	local isQuestItem = TSIL.Collectibles.CollectibleHasFlag(pickup.SubType, TSIL.Enums.ItemConfigTag.QUEST)
	local isRuneEssence = TSIL.Utils.Tables.IsIn(RuneRooms.Enums.Item, pickup.SubType)

	if isQuestItem or isRuneEssence then
		return
	end

	local rng = RNG(pickup.InitSeed)
	if rng:RandomInt(2) == 0 then
		pickup:Morph(pickup.Type, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_NULL, true)
	end
end
RuneRooms:AddCallback(
	ModCallbacks.MC_POST_PICKUP_INIT,
	PerthroNegative.OnCollectibleInit,
	PickupVariant.PICKUP_COLLECTIBLE
)
