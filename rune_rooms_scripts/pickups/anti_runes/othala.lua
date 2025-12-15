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
	local index, item, collectConfig
	local itemsToGet = RuneRooms.Helpers:HasMagicChalk(player) and 2 or 1
	for _ = 1, itemsToGet do
		repeat
			index = rng:RandomInt(1, rng:RandomInt(1, #itemsTable))
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
			if not data.OthalaClone then
				data.OthalaClone = {}
			end
			table.insert(data.OthalaClone, item)
		end
		index = nil
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_USE_CARD, OthalaRune.UseOthala, RuneRooms.Enums.Runes.OTHALA)

---@param player EntityPlayer
---@return boolean
local function PickingUp(player)
	local s = player:GetSprite()
	if s:GetAnimation():sub(1, 8) == "PickWalk" then
		return true
	end
	return false
end

function OthalaRune:OthalaDuplicatePickup(player)
	local data = player:GetData()
	if data.OthalaClone then
		if not PickingUp(player) and not player.QueuedItem.Item then
			player:AnimateCollectible(data.OthalaClone[1], "UseItem", "PlayerPickup")
			SFXManager():Play(SoundEffect.SOUND_POWERUP1, 1, 0)
			player:QueueItem(Isaac.GetItemConfig():GetCollectible(data.OthalaClone[1]))
			table.remove(data.OthalaClone, 1)
		end
		if #data.OthalaClone == 0 then
			data.OthalaClone = nil
		end
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, OthalaRune.OthalaDuplicatePickup)