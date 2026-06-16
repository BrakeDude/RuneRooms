local FehuRune = {}

---@param fehu Card | integer
---@param player EntityPlayer
---@param useflags UseFlag | integer
function FehuRune:UseFehu(fehu, player, useflags, rng, time, div)
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
	entities = RuneRooms.Helpers:Shuffle(entities, rng)
	for i = 1, math.ceil(#entities / div) do
		entities[i]:AddMidasFreeze(EntityRef(player), time)
	end
	return true
end
RuneRooms:AddInternalCallback(RuneRooms.Enums.CustomCallback.RUN_RUNE_MAIN, function()
	RuneRooms.Room():TurnGold()
	return true
end, RuneRooms.Enums.Runes.FEHU)

RuneRooms:AddInternalCallback(
	RuneRooms.Enums.CustomCallback.RUN_RUNE_EXTRA,
	FehuRune.UseFehu,
	RuneRooms.Enums.Runes.FEHU, 150, 2
)

return FehuRune