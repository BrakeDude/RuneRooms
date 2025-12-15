local GeboRune = {}

---@param gebo Card | integer
---@param player EntityPlayer
---@param useflags UseFlag | integer
function GeboRune:UseGebo(gebo, player, useflags)
	local rng = player:GetCardRNG(gebo)
	RuneRooms.Helpers:PlayGiantBook("Gebo", RuneRooms.Enums.SoundEffect.RUNE_GEBO, player, rng)
	local slots = {}
	for _, slot in ripairs(Isaac.GetRoomEntities()) do
		if Gebo.IsGeboSlot(slot) then
			table.insert(slots, slot)
		end
	end
	for _, slot in ipairs(slots) do
		if slot:GetSprite():GetAnimation() ~= "Broken" and slot:GetSprite():GetAnimation() ~= "Death" then
			if Gebo.GetGeboSlot(slot).REPENTOGON then
				if not Gebo.GetData(slot).GeboUses then
					Gebo.GetData(slot).GeboUses = 0
				end
				Gebo.GetData(slot).GeboUses = Gebo.GetData(slot).GeboUses + Gebo.GetGeboSlot(slot).Plays
			else
				if not Gebo.GetData(slot).Gebo then
					local rng = slot:GetDropRNG()
					Gebo.GetData(slot).Gebo = { Uses = Gebo.GetGeboSlot(slot).Plays, rng = rng, Player = player }
				else
					Gebo.GetData(slot).Gebo.Uses = Gebo.GetData(slot).Gebo.Uses + Gebo.GetGeboSlot(slot).Plays
				end
			end
		end
	end
	if RuneRooms.Helpers:HasMagicChalk(player) and rng:RandomInt(2) == 0 and #slots > 0 then
		local slot = slots[rng:RandomInt(#slots) + 1]
		if Gebo.IsGeboSlot(slot) then
			local rng = slot:GetDropRNG()
			local newslot = Isaac.Spawn(
				slot.Type,
				slot.Variant,
				slot.SubType,
				Game():GetRoom():FindFreeTilePosition(slot.Position, 9999),
				Vector.Zero,
				nil
			)
			if Gebo.GetGeboSlot(slot).REPENTOGON then
				Gebo.GetData(newslot).GeboUses = Gebo.GetGeboSlot(slot).Plays
			else
				Gebo.GetData(newslot).Gebo = { Uses = Gebo.GetGeboSlot(slot).Plays, rng = rng, Player = player }
			end
			SFXManager():Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false)
		end
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_USE_CARD, GeboRune.UseGebo, RuneRooms.Enums.Runes.GEBO)