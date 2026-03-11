local Runes = {}
local pathPrefix = "rune_rooms_scripts.pickups.anti_runes.runes."

local lowestRuneId, highestRuneId
for _, id in pairs(RuneRooms.Enums.Runes) do
	lowestRuneId = lowestRuneId == nil and id or math.min(lowestRuneId, id)
	highestRuneId = highestRuneId == nil and id or math.max(highestRuneId, id)
end

local internalCallbacks = {}

function RuneRooms:AddInternalPriorityCallback(id, priority, func, rune, ...)
	if not internalCallbacks[id] then
		internalCallbacks[id] = {}
	end
	local index = 1
	local callbacks = internalCallbacks[id]
	for i = #callbacks, 1, -1 do
		local callback = callbacks[i]
		if priority >= callback.Priority then
			index = i + 1
			break
		end
	end
	table.insert(callbacks, index, {
		Priority = priority,
		Function = func,
		CallbackID = id,
		Rune = rune,
		Params = { ... },
	})
end

local function GetInternalCallbacks(id)
	return internalCallbacks[id] or {}
end

function RuneRooms:AddInternalCallback(id, func, rune, ...)
	RuneRooms:AddInternalPriorityCallback(id, 0, func, rune, ...)
end

RuneRooms.AntibirthRunes = {}
RuneRooms.AntibirthRunes.FEHU = include(pathPrefix .. "fehu")
RuneRooms.AntibirthRunes.GEBO = include(pathPrefix .. "gebo")
RuneRooms.AntibirthRunes.INGWAZ = include(pathPrefix .. "ingwaz")
RuneRooms.AntibirthRunes.KENAZ = include(pathPrefix .. "kenaz")
RuneRooms.AntibirthRunes.OTHALA = include(pathPrefix .. "othala")
RuneRooms.AntibirthRunes.SOWILO = include(pathPrefix .. "sowilo")

local function RunCallbacks(id, rune, player, useflags, rng)
	for _, callback in ipairs(GetInternalCallbacks(id)) do
		if callback.Rune == rune then
			local ret = callback.Function(_, rune, player, useflags, rng, table.unpack(callback.Params))
			if ret ~= nil then
				break
			end
		end
	end
end

function Runes:UseRune(rune, player, useflags)
	if rune < lowestRuneId or rune > highestRuneId then
		return
	end
	local rng = player:GetCardRNG(rune)
	RuneRooms.Helpers:PlayGiantBook(
		RuneRooms.Constants.RuneNames[rune],
		Isaac.GetSoundIdByName(RuneRooms.Constants.RuneNames[rune]),
		player,
		rng
	)
	RunCallbacks(RuneRooms.Enums.CustomCallback.RUN_RUNE_MAIN, rune, player, useflags, rng)
	RunCallbacks(RuneRooms.Enums.CustomCallback.RUN_RUNE_EXTRA, rune, player, useflags, rng)
end
RuneRooms:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseRune)
