local FehuRune = {}

---@param fehu Card | integer
---@param player EntityPlayer
---@param useflags UseFlag | integer
function FehuRune:UseFehu(fehu, player, useflags)
	local rng = player:GetCardRNG(fehu)
	RuneRooms.Helpers:PlayGiantBook("Fehu", RuneRooms.Enums.SoundEffect.RUNE_FEHU, player, rng)
	local entities = {}
	for _, e in pairs(Isaac.GetRoomEntities()) do
		if
			e:IsActiveEnemy(false)
			and e:IsEnemy()
			and e:IsVulnerableEnemy()
			and not EntityRef(e).IsCharmed
			and not EntityRef(e).IsFriendly
		then
			table.insert(entities, e)
		end
	end
	local div = RuneRooms.Helpers:HasMagicChalk(player) and 1 or 2
	entities = RuneRooms.Helpers:Shuffle(entities, rng)
	for i = 1, math.ceil(#entities / div) do
		entities[i]:AddMidasFreeze(EntityRef(player), 300 / div)
	end
	Game():GetRoom():TurnGold()
end
RuneRooms:AddCallback(ModCallbacks.MC_USE_CARD, FehuRune.UseFehu, RuneRooms.Enums.Runes.FEHU)