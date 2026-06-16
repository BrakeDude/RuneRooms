local function MagicChalkOrRuneTablet()
	return RunicTablet or Isaac.GetItemIdByName("Magic Chalk") > 0
end

RuneRooms:AddModCompat(function()
	return MagicChalkOrRuneTablet()
end, function()
	RuneRooms:AddInternalPriorityCallback(
		RuneRooms.Enums.CustomCallback.RUN_RUNE_EXTRA,
		-1,
		function(_, fehu, player, useflags, rng, time, div)
			if RuneRooms.Helpers:HasMagicChalkOrRunicTablet(player) then
				RuneRooms.AntibirthRunes.FEHU:UseFehu(fehu, player, useflags, rng, time, div)
				return true
			end
		end,
		RuneRooms.Enums.Runes.FEHU,
		300,
		1
	)
	RuneRooms:AddInternalPriorityCallback(
		RuneRooms.Enums.CustomCallback.RUN_RUNE_EXTRA,
		-1,
		function(_, gebo, player, useflags, rng)
			if RuneRooms.Helpers:HasMagicChalkOrRunicTablet(player) then
				local slots = RuneRooms.AntibirthRunes.GEBO.GetSlots()
				if rng:RandomInt(2) == 0 and #slots > 0 then
					local slot = slots[rng:RandomInt(#slots) + 1]
					if Gebo.IsGeboSlot(slot) then
						local rng = slot:GetDropRNG()
						local newslot = Isaac.Spawn(
							slot.Type,
							slot.Variant,
							slot.SubType,
							RuneRooms.Room():FindFreeTilePosition(slot.Position, 9999),
							Vector.Zero,
							nil
						)
						if Gebo.GetGeboSlot(slot).REPENTOGON then
							Gebo.GetData(newslot).GeboUses = Gebo.GetGeboSlot(slot).Plays
						else
							Gebo.GetData(newslot).Gebo =
								{ Uses = Gebo.GetGeboSlot(slot).Plays, rng = rng, Player = player }
						end
						RuneRooms.SFX:Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false)
					end
				end
				return true
			end
		end,
		RuneRooms.Enums.Runes.GEBO
	)
	RuneRooms:AddInternalPriorityCallback(
		RuneRooms.Enums.CustomCallback.RUN_RUNE_EXTRA,
		-1,
		function(_, sowilo, player, useflags, rng)
			if RuneRooms.Helpers:HasMagicChalkOrRunicTablet(player) then
				player:UseActiveItem(
					CollectibleType.COLLECTIBLE_MEGA_BEAN,
					UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER
				)
				return true
			end
		end,
		RuneRooms.Enums.Runes.KENAZ
	)
	RuneRooms:AddInternalPriorityCallback(
		RuneRooms.Enums.CustomCallback.RUN_RUNE_MAIN,
		-1,
		function(_, othala, player, useflags, rng, extra)
			if RuneRooms.Helpers:HasMagicChalkOrRunicTablet(player) then
				RuneRooms.AntibirthRunes.OTHALA:UseOthala(othala, player, useflags, rng, extra)
				return true
			end
		end,
		RuneRooms.Enums.Runes.OTHALA,
		2
	)
	RuneRooms:AddInternalPriorityCallback(
		RuneRooms.Enums.CustomCallback.RUN_RUNE_EXTRA,
		-1,
		function(_, sowilo, player, useflags, rng)
			if RuneRooms.Helpers:HasMagicChalkOrRunicTablet(player) then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_DADS_KEY, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
				return true
			end
		end,
		RuneRooms.Enums.Runes.INGWAZ
	)
	RuneRooms:AddInternalPriorityCallback(
		RuneRooms.Enums.CustomCallback.RUN_RUNE_MAIN,
		-1,
		function(_, sowilo, player, useflags, rng)
			if RuneRooms.Helpers:HasMagicChalkOrRunicTablet(player) then
				player:UseActiveItem(
					CollectibleType.COLLECTIBLE_FORGET_ME_NOW,
					UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER
				)
				return true
			end
		end,
		RuneRooms.Enums.Runes.SOWILO
	)
	if RunicTablet then
		for _, rune in pairs(RuneRooms.Enums.Runes) do
			-- Disable double activation
			RunicTablet.Collectible.RunicTablet.CUSTOM_EFFECTS[rune] = true
			-- Register our own hud sprite
			RunicTablet.Collectible.RunicTablet.HUDSprites[rune] = Sprite("gfx/Rune3.anm2", true)
			if rune > Card.NUM_CARDS then
				RunicTablet.Collectible.RunicTablet.HUDSprites[rune].Offset = Vector(3, 0)
			end
		end
		local minAntiRuneId, maxAntiRuneId
		for _, id in pairs(RuneRooms.Enums.Runes) do
			minAntiRuneId = minAntiRuneId == nil and id or math.min(minAntiRuneId, id)
			maxAntiRuneId = maxAntiRuneId == nil and id or math.max(maxAntiRuneId, id)
		end
		local t = RunicTablet.Collectible.RunicTablet
		-- Re-register with our runes take into accout
		HudHelper.RegisterHUDElement({
			Name = "RR_RUNICTABLET",
			Priority = HudHelper.Priority.HIGH,
			Condition = function(player)
				if not player:HasCollectible(t.ID) then
					return false
				end
				local config = RunicTablet.Util:GetCardConfig(player:GetCard(0))
				return config and config.ID > 0 and config:IsRune()
			end,
			OnRender = function(player, _, layout, position, alpha, scale)
				local id = player:GetCard(0)
				local sprite = t:GetHUDSprite(id)
				local sin = (1 + math.sin(RunicTablet.Enum.Obj.Game:GetFrameCount() * 0.2)) / 2

				sprite:Play("HUD", true)
				sprite.Offset = (id >= minAntiRuneId and id <= maxAntiRuneId) and Vector.Zero
					or ((id > Card.NUM_CARDS) and t.HUD_OFFSET_MODDED or t.HUD_OFFSET)
				sprite.Color = Color(1, 1, 1, 1, sin * 0.17, sin * 0.07, sin * 0.27)
				sprite:Render(position)
			end,
		}, HudHelper.HUDType.POCKET)
	end
end)

RuneRooms:AddModCompat(function()
	return EID and MagicChalkOrRuneTablet()
end, function()
	local magicChalkID = Isaac.GetItemIdByName("Magic Chalk")
	local function HodlingTab()
		return EID.Config["ItemReminderEnabled"]
			and EID.holdTabCounter >= 30
			and EID.TabDescThisFrame == false
			and EID.holdTabPlayer ~= nil
	end

	local descriptions = {
		modifiers = {
			[RuneRooms.Enums.Runes.FEHU] = function(descObj, player, language)
				descObj.Description = descObj.Description:gsub("5", "{{ColorShinyPurple}}10{{CR}}")
				descObj.Description = descObj.Description:gsub("half", "all")
				descObj.Description =
					descObj.Description:gsub("к половине монстров", "ко всем монстрам")
				return descObj
			end,
			[RuneRooms.Enums.Runes.OTHALA] = function(descObj, player, lang)
				if lang == "ru" then
					descObj.Description = descObj.Description:gsub(
						"1 случайную копию предмета, который",
						"{{ColorShinyPurple}}2{{CR}} случайные копии предметов, которые"
					)
				elseif lang == "spa" then
					descObj.Description = descObj.Description:gsub("copia de un objeto", "copias de objetos")
					descObj.Description = descObj.Description:gsub("una", "{{ColorShinyPurple}}dos{{CR}}")
					descObj.Description = descObj.Description:gsub("existente", "existentes")
				elseif lang == "en_us" then
					descObj.Description = descObj.Description:gsub("copy of item", "copies of items")
					descObj.Description = descObj.Description:gsub("1", "{{ColorShinyPurple}}2{{CR}}")
				end
				return descObj
			end,
		},
		appends = {
			[RuneRooms.Enums.Runes.GEBO] = {
				en_us = "Creates random copy of slot or beggar in room",
				spa = "Crea una copia aleatoria de una máquina o mendigo",
				ru = "Создает случайную копию машины или попрошайки в комнате",
			},
			[RuneRooms.Enums.Runes.INGWAZ] = {
				en_us = "Activates {{Collectible175}} Dad's Key effect",
				spa = "Activa el efecto de {{Collectible175}} La Llave de Papá",
				ru = "Актиирует эффект {{Collectible175}} Папиного ключа",
			},
			[RuneRooms.Enums.Runes.KENAZ] = {
				en_us = "Activates {{Collectible351}} Mega Bean effect",
				spa = "Activa el efecto del {{Collectible351}} Mega Frijol",
				ru = "Активирует эффект {{Collectible351}} Мега боба",
			},
		},
		replaces = {
			[RuneRooms.Enums.Runes.SOWILO] = {
				en_us = "Rerolls and restarts the entire floor",
				spa = "Reinicia y cambia el piso actual#Se consume tras usarlo",
				ru = "Текущий уровень перезапускается и генерируется заново",
			},
		},
	}

	for rune, desc in pairs(RuneRooms.Constants.Descriptions.Runes) do
		if RunicTablet then
			for i = #RunicTablet.Compat.EID.MODIFIERS, 1, -1 do
				if RunicTablet.Compat.EID.MODIFIERS[i][1] == "RR_RUNICTABLET_APPEND_" .. rune then
					table.remove(RunicTablet.Compat.EID.MODIFIERS, i)
				end
			end
			local runic_modifier_name = "KK_"
				.. string.gsub(string.upper(RunicTablet.Name), " ", "")
				.. "_"
				.. "RR_RUNICTABLET_APPEND_"
				.. rune
			EID:removeDescriptionModifier(runic_modifier_name)
		end
		EID:addDescriptionModifier("RunicTabletCompatRune_" .. rune, function(descObj)
			return descObj
				and descObj.ObjType == EntityType.ENTITY_PICKUP
				and descObj.ObjVariant == PickupVariant.PICKUP_TAROTCARD
				and descObj.ObjSubType == rune
		end, function(descObj)
			local language = EID:getLanguage()
			local player
			if HodlingTab() then
				player = EID.holdTabPlayer
			elseif descObj and descObj.Entity then
				player = Game():GetNearestPlayer(descObj.Entity.Position)
			end
			if player and RuneRooms.Helpers:HasMagicChalkOrRunicTablet(player) then
				if descriptions.replaces and descriptions.replaces[rune] then
					local original
					if desc[language] and desc[language].description then
						original = desc[language].description
					end
					if original == nil and desc["en_us"] and desc["en_us"].description then
						original = desc["en_us"].description
					end
					local replace = descriptions.replaces[rune][language] or descriptions.replaces[rune]["en_us"]
					if original ~= nil and replace ~= nil then
						descObj.Description = descObj.Description:gsub(original, replace)
					end
				end
				if descriptions.modifiers and descriptions.modifiers[rune] then
					descObj = descriptions.modifiers[rune](descObj, player, language)
				end
				if descriptions.appends and descriptions.appends[rune] then
					local append = descriptions.appends[rune][language] or descriptions.appends[rune]["en_us"]
					if append ~= nil then
						local id = RuneRooms.Helpers:HasRunicTablet(player)
								and RunicTablet.Collectible.RunicTablet.ID
							or magicChalkID
						descObj.Description = descObj.Description .. "#{{Collectible" .. id .. "}} " .. append
					end
				end
			end
			return descObj
		end)
	end
end)
