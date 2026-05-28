---@diagnostic disable: undefined-field

---@return GridSpriteMode
function RuneRooms:GetRocksSpriteMode()
	return RuneRooms:GetDefaultFileSave("RocksSpriteMode")
end

---@return GridSpriteMode
function RuneRooms:GetPitsSpriteMode()
	return RuneRooms:GetDefaultFileSave("PitsSpriteMode")
end

---@return boolean
function RuneRooms:ShowIcon()
	return RuneRooms:GetDefaultFileSave("ShowHudIcon")
end

local prefix = "RuneRooms"
local settingsPrefix = prefix .. "Settings"

local function InitImGuiMenu()
	if not ImGui.ElementExists("RestoredMods") then
		ImGui.CreateMenu("RestoredMods", "Restored Mods")
	end

	if not ImGui.ElementExists(prefix) then
		ImGui.AddElement("RestoredMods", prefix, ImGuiElement.Menu, "Rune Rooms")
	end

	if not ImGui.ElementExists(settingsPrefix) then
		ImGui.AddElement(prefix, settingsPrefix, ImGuiElement.MenuItem, "\u{f013} Settings")
	end

	if not ImGui.ElementExists(prefix .. "Window") then
		ImGui.CreateWindow(prefix .. "Window", "Rune Rooms Settings")
		ImGui.LinkWindowToElement(prefix .. "Window", settingsPrefix)
		ImGui.SetWindowSize(prefix .. "Window", 800, 350)
	end
end

local function UpdateImGuiMenu(IsDataInitialized)
	if IsDataInitialized then
		if ImGui.ElementExists(settingsPrefix .. "NoWay") then
			ImGui.RemoveElement(settingsPrefix .. "NoWay")
		end

		if RuneRooms:RoomsUnlocked() then
			ImGui.AddCheckbox(prefix .. "Window", settingsPrefix .. "ShowHudIcon", "Show HUD icon", function(value)
				RuneRooms:AddDefaultFileSave("ShowHudIcon", value)
			end, true)

			ImGui.AddCallback(settingsPrefix .. "ShowHudIcon", ImGuiCallback.Render, function()
				ImGui.UpdateData(
					settingsPrefix .. "ShowHudIcon",
					ImGuiData.Value,
					RuneRooms:ShowIcon()
				)
			end)
			ImGui.SetTooltip(settingsPrefix .. "ShowHudIcon", "Shows chance of rune room spawning")
		end

		ImGui.AddCombobox(
			prefix .. "Window",
			settingsPrefix .. "RocksSpriteMode",
			"Rocks sprite mode",
			function(index, value)
				RuneRooms:AddDefaultFileSave("RocksSpriteMode", index + 1)
			end,
			{ "Detect", "Vanilla", "Fiend Folio" },
			0,
			false
		)

		ImGui.AddCallback(settingsPrefix .. "RocksSpriteMode", ImGuiCallback.Render, function()
			ImGui.UpdateData(settingsPrefix .. "RocksSpriteMode", ImGuiData.Value, RuneRooms:GetRocksSpriteMode())
		end)
		ImGui.SetTooltip(settingsPrefix .. "RocksSpriteMode", "Which rock sprites to render in room rooms")

		ImGui.AddCombobox(
			prefix .. "Window",
			settingsPrefix .. "PitsSpriteMode",
			"Pits sprite mode",
			function(index, value)
				RuneRooms:AddDefaultFileSave("PitsSpriteMode", index + 1)
			end,
			{ "Detect", "Vanilla", "Fiend Folio" },
			0,
			false
		)

		ImGui.AddCallback(settingsPrefix .. "PitsSpriteMode", ImGuiCallback.Render, function()
			ImGui.UpdateData(settingsPrefix .. "PitsSpriteMode", ImGuiData.Value, RuneRooms:GetRocksSpriteMode())
		end)
		ImGui.SetTooltip(settingsPrefix .. "PitsSpriteMode", "Which pit sprites to render in room rooms")
	else
		if ImGui.ElementExists(settingsPrefix .. "ShowHudIcon") then
			ImGui.RemoveCallback(settingsPrefix .. "ShowHudIcon", ImGuiCallback.Render)
			ImGui.RemoveElement(settingsPrefix .. "ShowHudIcon")
		end

		if ImGui.ElementExists(settingsPrefix .. "RocksSpriteMode") then
			ImGui.RemoveCallback(settingsPrefix .. "RocksSpriteMode", ImGuiCallback.Render)
			ImGui.RemoveElement(settingsPrefix .. "RocksSpriteMode")
		end

		if ImGui.ElementExists(settingsPrefix .. "PitsSpriteMode") then
			ImGui.RemoveCallback(settingsPrefix .. "PitsSpriteMode", ImGuiCallback.Render)
			ImGui.RemoveElement(settingsPrefix .. "PitsSpriteMode")
		end

		if not ImGui.ElementExists(settingsPrefix .. "NoWay") then
			ImGui.AddText(
				prefix .. "Window",
				"Options will be available after loading the game.",
				true,
				settingsPrefix .. "NoWay"
			)
		end
	end
end

local function Init()
	InitImGuiMenu()
	UpdateImGuiMenu(false)

	local InGame = false

	local function UpdateImGuiOnRender()
		if not Isaac.IsInGame() and InGame then
			UpdateImGuiMenu(false)
			InGame = false
		elseif Isaac.IsInGame() and not InGame then
			UpdateImGuiMenu(true)
			InGame = true
		end
	end
	RuneRooms:AddPriorityCallback(ModCallbacks.MC_POST_RENDER, CallbackPriority.LATE, UpdateImGuiOnRender)
	RuneRooms:AddPriorityCallback(ModCallbacks.MC_MAIN_MENU_RENDER, CallbackPriority.LATE, UpdateImGuiOnRender)
end

local function OnModsLoad()
	if RuneRooms:RoomsUnlocked() then
		Init()
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, OnModsLoad)

local function OnUnlock()
	Init()
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_ACHIEVEMENT_UNLOCK, OnUnlock, RuneRooms.Enums.Achievement.RUNE_ROOMS)
