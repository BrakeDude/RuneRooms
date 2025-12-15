local majorversion = 1
local minorversion = 1
local isRepentogon = true
local APIFolder = "rune_rooms_scripts.pickups.anti_runes.gebo_api"

local function Init()
	Gebo = RegisterMod("Gebo API", 1)
	Gebo.MajorVersion = majorversion
	Gebo.MinorVersion = minorversion
	Gebo.RepentogonEnabled = true
	Gebo.SaveData = {
		Data = {},
		HourglassBackup = {},
	}
	local DefaultSaveData = {}
	local doingHourglass = false
	if not GeboSlots then
		GeboSlots = {}
	end

	function Gebo.GetData(entity)
		if entity and entity.GetData then
			local data = entity:GetData()
			if not data.GeboData then
				data.GeboData = {}
			end
			return data.GeboData
		end
		return nil
	end

	function Gebo.IsGeboSlot(_slot)
		for _, slot in ipairs(GeboSlots) do
			if
				slot.Type == _slot.Type
				and slot.Variant == _slot.Variant
				and (slot.SubType == _slot.SubType or slot.SubType == -1)
			then
				return true
			end
		end
		return false
	end

	function Gebo.GetGeboSlot(_slot)
		for _, slot in ipairs(GeboSlots) do
			if
				slot.Type == _slot.Type
				and slot.Variant == _slot.Variant
				and (slot.SubType == _slot.SubType or slot.SubType == -1)
			then
				return slot
			end
		end
	end

	function Gebo.AddMachineBeggar(variant, func, plays, _type, subtype)
		_type = _type or 6
		subtype = subtype or 0
		plays = plays or 5
		table.insert(GeboSlots, { Type = _type, Variant = variant, SubType = subtype, Function = func, Plays = plays })
	end

	function Gebo.ChangeRepentogonTag(variant, add, _type, subtype)
		_type = _type or 6
		subtype = subtype or 0
		for key, slot in ipairs(GeboSlots) do
			if slot.Type == _type and slot.Variant == variant and slot.SubType == subtype then
				GeboSlots[key].REPENTOGON = add
			end
		end
	end

	function Gebo.UpdateMachineBeggar(variant, func, plays, _type, subtype)
		if type(variant) ~= "number" then
			return
		end
		_type = _type or 6
		subtype = subtype or 0
		plays = plays or 5
		for key, slot in ipairs(GeboSlots) do
			if slot.Type == _type and slot.Variant == variant and slot.SubType == subtype then
				GeboSlots[key].Type = _type
				GeboSlots[key].Variant = variant
				GeboSlots[key].SubType = subtype
				GeboSlots[key].Plays = plays
				if func ~= nil and type(func) == "function" then
					GeboSlots[key].Function = func
				end
			end
		end
	end

	function Gebo.AddSaveData(name, data, overwriteDefault)
		Gebo.SaveData.Data[name] = data
		if not DefaultSaveData[name] or overwriteDefault then
			DefaultSaveData[name] = data
		end
	end

	function Gebo.GetSaveData()
		return Gebo.SaveData
	end

	function Gebo.LoadSaveData(data, overwriteDefaul)
		if type(data) == "table" and type(data.Data) == "table" and type(data.HourglassBackup) == "table" then
			Gebo.SaveData = data
			if overwriteDefaul then
				DefaultSaveData = data
			end
		else
			Gebo.SaveData = { Data = {}, HourglassBackup = {} }
		end
	end

	function Gebo.ResetSaveData()
		Gebo.SaveData.Data = DefaultSaveData
		Gebo.SaveData.HourglassBackup = {}
	end

	function Gebo.GetSaveDataByKey(key)
		return Gebo.SaveData.Data[key]
	end

	function Gebo.SetSaveDataByKey(key, data)
		Gebo.SaveData.Data[key] = data
	end

	function Gebo.GetSpawnPickupVelocity(position, rng, begType)
		if type(begType) ~= "number" then
			begType = 0
		end
		if begType < 0 then
			begType = 0
		elseif begType > 1 then
			begType = 1
		else
			begType = math.floor(begType)
		end
		if type(rng) == "number" then
			local seed = rng
			rng = RNG()
			seed = math.floor(seed)
			rng:SetSeed(math.max(1, seed), 35)
		elseif getmetatable(rng).__type ~= "RNG" then
			rng = RNG()
			rng:SetSeed(math.max(1, Isaac.GetFrameCount()), 35)
		end
		return EntityPickup.GetRandomPickupVelocity(position, rng, begType)
	end

	local geboVanillaSlotScripts = {
		"repentogon",
	}

	local geboModdedSlotScripts = {
		"retribution.swine_beggar",
		"retribution.apon_machine",
		"fiendfolio.cosplay_beggar",
		"fiendfolio.evil_beggar",
		"fiendfolio.robot_fortune_teller",
		"fiendfolio.zodiac_beggar",
		"fiendfolio.golden_slot",
		"fiendfolio.vending",
		"fiendfolio.grid_restock",
		"fiendfolio.fake_beggar",
		"andromeda.cosmic_beggar",
		"repentanceplus.stargazer",
		"epiphany.dice_machine",
		"epiphany.glitch_slot",
		"epiphany.gold_restock",
		"epiphany.pain-o-matic",
	}

	do
		for _, script in pairs(geboVanillaSlotScripts) do
			include(APIFolder .. ".vanilla." .. script)
		end
		for _, script in pairs(geboModdedSlotScripts) do
			include(APIFolder .. "." .. script)
		end
	end

	local function GeboEffect()
		for _, slot in ipairs(Isaac.GetRoomEntities()) do
			if Gebo.IsGeboSlot(slot) then
				local data = Gebo.GetData(slot)
				local slotData = Gebo.GetGeboSlot(slot)
				if data.Gebo ~= nil then
					if type(slotData.Function) == "function" then
						if not data.PrevCollide then
							data.PrevCollide = slot.EntityCollisionClass
							slot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
						end
						local dead = slotData.Function(slot, data.Gebo.Player, data.Gebo.Uses, data.Gebo.rng)

						if
							dead == nil
							or type(dead) == "boolean" and dead == true
							or type(dead) == "number" and dead <= 0
						then
							data.Gebo = nil
						elseif type(dead) == "number" and dead > 0 then
							data.Gebo.Uses = dead
						end
					end
				elseif data.PrevCollide then
					slot.EntityCollisionClass = data.PrevCollide
					data.PrevCollide = nil
				end
			end
		end
	end
	Gebo:AddCallback(ModCallbacks.MC_POST_UPDATE, GeboEffect)

	local function GeboHourGlassNewRoom()
		if not doingHourglass then
			Gebo.SaveData.HourglassBackup = Gebo.SaveData.Data
		else
			local prevData = Gebo.SaveData.Data
			Gebo.SaveData.Data = Gebo.SaveData.HourglassBackup
			Gebo.SaveData.HourglassBackup = prevData
			doingHourglass = false
		end
	end
	Gebo:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, GeboHourGlassNewRoom)

	local function GeboHourGlassUse()
		doingHourglass = true
	end
	Gebo:AddPriorityCallback(
		ModCallbacks.MC_USE_ITEM,
		-1000,
		GeboHourGlassUse,
		CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS
	)

	local function GeboHourGlassLoad(_, load)
		if not load then
			Gebo.ResetSaveData()
		end
	end
	Gebo:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, -1000, GeboHourGlassLoad)
end
if isRepentogon and not REPENTOGON then
		print("This version of GeboAPI is for REPENTOGON only. Enable REPENTOGON to use this version.")
elseif Gebo then
	if Gebo.MajorVersion < majorversion or Gebo.MajorVersion == majorversion and Gebo.MinorVersion < minorversion then
		print(
			"Newer version of ["
				.. Gebo.Name
				.. "] was found. Updating V"
				.. Gebo.MajorVersion
				.. "."
				.. Gebo.MinorVersion
				.. " to V"
				.. majorversion
				.. "."
				.. minorversion
				.. "..."
		)
		local data = Gebo.GetSaveData()
		Gebo = nil
		Init()
		Gebo.LoadSaveData(data, true)
		print("[" .. Gebo.Name .. "] V" .. Gebo.MajorVersion .. "." .. Gebo.MinorVersion .. " successfully updated.")
    else
        local data = Gebo.GetSaveData()
		Gebo = nil
		Init()
		Gebo.LoadSaveData(data, true)
		print("[" .. Gebo.Name .. "] V" .. Gebo.MajorVersion .. "." .. Gebo.MinorVersion .. " successfully reloaded.")
    end
elseif not Gebo then
	Init()
    print("[" .. Gebo.Name .. "] V" .. Gebo.MajorVersion .. "." .. Gebo.MinorVersion .. " successfully loaded.")
end
