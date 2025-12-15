local OthalaRune = {}

---@param othala Card | integer
---@param player EntityPlayer
---@param useflags UseFlag | integer
function OthalaRune:UseOthala(othala, player, useflags)
	local data = player:GetData()
	local rng = player:GetCardRNG(othala)
	RuneRooms.Helpers:PlayGiantBook("Othala", RuneRooms.Enums.SoundEffect.RUNE_OTHALA, player, rng)
	
	local itemConfig = Isaac.GetItemConfig()
	local history = player:GetHistory()

	local itemsTable = history:GetCollectiblesHistory()
	if #itemsTable == 0 then return end
	local index, item, collectConfig
	local itemsToGet = RuneRooms.Helpers:HasMagicChalk(player) and 2 or 1
	for _ = 1, itemsToGet do
		repeat
			index = rng:RandomInt(1, #itemsTable)
			item = itemsTable[index]:GetItemID()
			collectConfig = itemConfig:GetCollectible(item)
			if
				collectConfig.Hidden
				or collectConfig.Type == ItemType.ITEM_ACTIVE
				or collectConfig:HasTags(ItemConfig.TAG_QUEST)
			then
				table.remove(itemsTable, index)
				index = nil
			end
		until index or #itemsTable == 0
		if index then
			player:AnimateCollectible(item, "UseItem", "PlayerPickup")
			player:QueueItem(Isaac.GetItemConfig():GetCollectible(item))
			SFXManager():Play(SoundEffect.SOUND_POWERUP1, 1, 0)
		end
		index = nil
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_USE_CARD, OthalaRune.UseOthala, RuneRooms.Enums.Runes.OTHALA)