local OthalaRune = {}

---@param othala Card | integer
---@param player EntityPlayer
---@param useflags UseFlag | integer
function OthalaRune:UseOthala(othala, player, useflags, rng, extra)
	local randomItems = {}
	local itemConfig = Isaac.GetItemConfig()
	local history = player:GetHistory()

	local itemsTable = history:GetCollectiblesHistory()
	if #itemsTable > 0 then
		for _ = 1, extra do
			local index, item, collectConfig
			repeat
				index = rng:RandomInt(1, #itemsTable)
				item = itemsTable[index]:GetItemID()
				collectConfig = itemConfig:GetCollectible(item)
				if collectConfig.Type == ItemType.ITEM_ACTIVE or collectConfig:HasTags(ItemConfig.TAG_QUEST) then
					table.remove(itemsTable, index)
				else
					table.insert(randomItems, item)
					break
				end
			until #itemsTable == 0
		end
	end
	while #randomItems > 0 do
		player:AnimateCollectible(randomItems[1], "UseItem", "PlayerPickup")
		player:QueueItem(Isaac.GetItemConfig():GetCollectible(randomItems[1]))
		SFXManager():Play(SoundEffect.SOUND_POWERUP1, 1, 0)
		table.remove(randomItems, 1)
	end
	return true
end
RuneRooms:AddInternalCallback(
	RuneRooms.Enums.CustomCallback.RUN_RUNE_MAIN,
	OthalaRune.UseOthala,
	RuneRooms.Enums.Runes.OTHALA,
	1
)

return OthalaRune
