---@diagnostic disable: undefined-field

TSIL.SaveManager.AddPersistentVariable(
    RuneRooms,
    RuneRooms.Enums.SaveKey.DSS_MENU_OPTIONS,
    {},
    TSIL.Enums.VariablePersistenceMode.NONE
)

TSIL.SaveManager.AddPersistentVariable(
    RuneRooms,
    RuneRooms.Enums.SaveKey.ROCKS_SPRITE_MODE,
    RuneRooms.Enums.GridSpriteMode.DEFAULT,
    TSIL.Enums.VariablePersistenceMode.NONE
)

TSIL.SaveManager.AddPersistentVariable(
    RuneRooms,
    RuneRooms.Enums.SaveKey.PITS_SPRITE_MODE,
    RuneRooms.Enums.GridSpriteMode.DEFAULT,
    TSIL.Enums.VariablePersistenceMode.NONE
)

TSIL.SaveManager.AddPersistentVariable(
    RuneRooms,
    RuneRooms.Enums.SaveKey.RUNE_ROOM_SPAWN_CHANCE,
    0.3,
    TSIL.Enums.VariablePersistenceMode.NONE
)

TSIL.SaveManager.AddPersistentVariable(
    RuneRooms,
    RuneRooms.Enums.SaveKey.VANILLA_GIANTBOOK_CUSTOM_API_OPTION,
    1,
    TSIL.Enums.VariablePersistenceMode.NONE
)

---@return GridSpriteMode
function RuneRooms:GetRocksSpriteMode()
    return TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.ROCKS_SPRITE_MODE
    )
end

---@return GridSpriteMode
function RuneRooms:GetPitsSpriteMode()
    return TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.PITS_SPRITE_MODE
    )
end

function RuneRooms:GetRuneRoomSpawnChance()
    return TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.RUNE_ROOM_SPAWN_CHANCE
    )
end

function RuneRooms:GetCustomVanillaGiantbookAPI()
    return TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.VANILLA_GIANTBOOK_CUSTOM_API_OPTION
    )
end

--
-- MenuProvider
--

-- Change this variable to match your mod. The standard is "Dead Sea Scrolls (Mod Name)"
local DSSModName = "Dead Sea Scrolls (Rune Rooms)"

-- Every MenuProvider function below must have its own implementation in your mod, in order to
-- handle menu save data.

local function GetDSSMenuOptions()
    return TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.DSS_MENU_OPTIONS
    )
end

local MenuProvider = {}

function MenuProvider.SaveSaveData()
end

function MenuProvider.GetPaletteSetting()
    return GetDSSMenuOptions().MenuPalette
end

function MenuProvider.SavePaletteSetting(var)
    GetDSSMenuOptions().MenuPalette = var
end

function MenuProvider.GetHudOffsetSetting()
    if not REPENTANCE then
        return GetDSSMenuOptions().HudOffset
    else
        return Options.HUDOffset * 10
    end
end

function MenuProvider.SaveHudOffsetSetting(var)
    if not REPENTANCE then
        GetDSSMenuOptions().HudOffset = var
    end
end

function MenuProvider.GetGamepadToggleSetting()
    return GetDSSMenuOptions().GamepadToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
    GetDSSMenuOptions().GamepadToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
    return GetDSSMenuOptions().MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
    GetDSSMenuOptions().MenuKeybind = var
end

function MenuProvider.GetMenuHintSetting()
    return GetDSSMenuOptions().MenuHint
end

function MenuProvider.SaveMenuHintSetting(var)
    GetDSSMenuOptions().MenuHint = var
end

function MenuProvider.GetMenuBuzzerSetting()
    return GetDSSMenuOptions().MenuBuzzer
end

function MenuProvider.SaveMenuBuzzerSetting(var)
    GetDSSMenuOptions().MenuBuzzer = var
end

function MenuProvider.GetMenusNotified()
    return GetDSSMenuOptions().MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
    GetDSSMenuOptions().MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
    return GetDSSMenuOptions().MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
    GetDSSMenuOptions().MenusPoppedUp = var
end

local dssmenucore = include("rune_rooms_scripts.lib.dss_menu_core")

-- This function returns a table that some useful functions and defaults are stored on.
local dssmod = dssmenucore.init(DSSModName, MenuProvider)


-- Adding a Menu

-- Creating a menu like any other DSS menu is a simple process. You need a "Directory", which
-- defines all of the pages ("items") that can be accessed on your menu, and a "DirectoryKey", which
-- defines the state of the menu.
local exampledirectory = {
    -- The keys in this table are used to determine button destinations.
    main = {
        -- "title" is the big line of text that shows up at the top of the page!
        title = 'rune rooms',
        -- "buttons" is a list of objects that will be displayed on this page. The meat of the menu!
        buttons = {
            -- The simplest button has just a "str" tag, which just displays a line of text.

            -- The "action" tag can do one of three pre-defined actions:
            -- 1) "resume" closes the menu, like the resume game button on the pause menu. Generally
            --    a good idea to have a button for this on your main page!
            -- 2) "back" backs out to the previous menu item, as if you had sent the menu back
            --    input.
            -- 3) "openmenu" opens a different dss menu, using the "menu" tag of the button as the
            --    name.
            { str = 'resume game', action = 'resume' },

            -- The "dest" option, if specified, means that pressing the button will send you to that
            -- page of your menu.
            -- If using the "openmenu" action, "dest" will pick which item of that menu you are sent
            -- to.
            { str = 'settings',    dest = 'settings' },

            -- A few default buttons are provided in the table returned from the `init` function.
            -- They are buttons that handle generic menu features, like changelogs, palette, and the
            -- menu opening keybind. They will only be visible in your menu if your menu is the only
            -- mod menu active. Otherwise, they will show up in the outermost Dead Sea Scrolls menu
            -- that lets you pick which mod menu to open. This one leads to the changelogs menu,
            -- which contains changelogs defined by all mods.
            dssmod.changelogsButton,
        },
        -- A tooltip can be set either on an item or a button, and will display in the corner of the
        -- menu while a button is selected or the item is visible with no tooltip selected from a
        -- button. The object returned from the `init` function contains a default tooltip that
        -- describes how to open the menu, at "menuOpenToolTip". It's generally a good idea to use
        -- that one as a default!
        tooltip = dssmod.menuOpenToolTip
    },
    settings = {
        title = 'settings',
        buttons = {
            -- These buttons are all generic menu handling buttons, provided in the table returned
            -- from the `init` function. They will only show up if your menu is the only mod menu
            -- active. You should generally include them somewhere in your menu, so that players can
            -- change the palette or menu keybind even if your mod is the only menu mod active. You
            -- can position them however you like, though!
            dssmod.gamepadToggleButton,
            dssmod.menuKeybindButton,
            dssmod.paletteButton,
            dssmod.menuHintButton,
            dssmod.menuBuzzerButton,

            {
                str = 'rocks sprite mode',

                choices = { 'detect', 'vanilla', 'fiend folio' },

                setting = 1,

                variable = 'RocksSpriteMode',

                load = function()
                    return RuneRooms:GetRocksSpriteMode()
                end,

                store = function(var)
                    TSIL.SaveManager.SetPersistentVariable(
                        RuneRooms,
                        RuneRooms.Enums.SaveKey.ROCKS_SPRITE_MODE,
                        var
                    )
                end,

                tooltip = { strset = { 'what sprite', 'rocks have', 'in rune rooms' } }
            },

            {
                str = 'pits sprite mode',

                choices = { 'detect', 'vanilla', 'fiend folio' },

                setting = 1,

                variable = 'PitsSpriteMode',

                load = function()
                    return RuneRooms:GetPitsSpriteMode()
                end,

                store = function(var)
                    TSIL.SaveManager.SetPersistentVariable(
                        RuneRooms,
                        RuneRooms.Enums.SaveKey.PITS_SPRITE_MODE,
                        var
                    )
                end,

                tooltip = { strset = { 'what sprite', 'pits have', 'in rune rooms' } }
            },

            {
                str = 'rune room chance',
                -- If "min" and "max" are set without "slider", you've got yourself a number option!
                -- It will allow you to scroll through the entire range of numbers from "min" to
                -- "max", incrementing by "increment".
                min = 0,
                max = 100,
                increment = 1,
                -- You can also specify a prefix or suffix that will be applied to the number, which
                -- is especially useful for percentages!
                suf = '%',
                setting = 30,
                variable = "RuneRoomSpawnChance",
                load = function()
                    return math.floor(RuneRooms:GetRuneRoomSpawnChance() * 100)
                end,
                store = function(var)
                    TSIL.SaveManager.SetPersistentVariable(
                        RuneRooms,
                        RuneRooms.Enums.SaveKey.RUNE_ROOM_SPAWN_CHANCE,
                        var / 100
                    )
                end,
                tooltip = { strset = { "how often", "rune rooms", "replace vaults" } },
            },

            {
                str = 'giantbook api',

                choices = { 'giantbook api', 'screen api', 'none' },

                setting = 1,

                variable = 'GiantbookAPI',

                load = function()
                    return RuneRooms:GetCustomVanillaGiantbookAPI()
                end,

                store = function(var)
                    TSIL.SaveManager.SetPersistentVariable(
                        RuneRooms,
                        RuneRooms.Enums.SaveKey.VANILLA_GIANTBOOK_CUSTOM_API_OPTION,
                        var
                    )
                end,

                tooltip = { strset = { 'what giantbook', 'api to use', '(without repentogon)' } }
            },
        }
    }
}

local exampledirectorykey = {
    -- This is the initial item of the menu, generally you want to set it to your main item
    Item = exampledirectory.main,
    -- The main item of the menu is the item that gets opened first when opening your mod's menu.
    Main = 'main',
    -- These are default state variables for the menu; they're important to have in here, but you
    -- don't need to change them at all.
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

--#region AgentCucco pause manager for DSS

include("rune_rooms_scripts.lib.imgui")

local OldTimer
local OldTimerBossRush
local OldTimerHush
local OverwrittenPause = false
local AddedPauseCallback = false
local function OverridePause(self, player, hook, action)
	if not AddedPauseCallback then return nil end

	if OverwrittenPause then
		OverwrittenPause = false
		AddedPauseCallback = false
		return
	end

	if action == ButtonAction.ACTION_SHOOTRIGHT then
		OverwrittenPause = true
		for _, ember in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.FALLING_EMBER, -1)) do
			if ember:Exists() then
				ember:Remove()
			end
		end
		if REPENTANCE then
			for _, rain in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.RAIN_DROP, -1)) do
				if rain:Exists() then
					rain:Remove()
				end
			end
		end
		return true
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_INPUT_ACTION, OverridePause, InputHook.IS_ACTION_PRESSED)

local function FreezeGame(unfreeze)
	if unfreeze then
		OldTimer = nil
        OldTimerBossRush = nil
        OldTimerHush = nil
        if not AddedPauseCallback then
			AddedPauseCallback = true
		end
	else
		if not OldTimer then
			OldTimer = Game().TimeCounter
		end
        if not OldTimerBossRush then
            OldTimerBossRush = Game().BossRushParTime
		end
        if not OldTimerHush then
			OldTimerHush = Game().BlueWombParTime
		end
		
        Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE, UseFlag.USE_NOANIM)
		
		Game().TimeCounter = OldTimer
		Game().BossRushParTime = OldTimerBossRush
		Game().BlueWombParTime = OldTimerHush
	end
end

local function RunDSSMenu(tbl)
    FreezeGame()
    dssmod.runMenu(tbl)
end

local function CloseDSSMenu(tbl, fullClose, noAnimate)
    FreezeGame(true)
    dssmod.closeMenu(tbl, fullClose, noAnimate)
end

--#endregion

DeadSeaScrollsMenu.AddMenu("Rune Rooms", {
    -- The Run, Close, and Open functions define the core loop of your menu. Once your menu is
    -- opened, all the work is shifted off to your mod running these functions, so each mod can have
    -- its own independently functioning menu. The `init` function returns a table with defaults
    -- defined for each function, as "runMenu", "openMenu", and "closeMenu". Using these defaults
    -- will get you the same menu you see in Bertran and most other mods that use DSS. But, if you
    -- did want a completely custom menu, this would be the way to do it!

    -- This function runs every render frame while your menu is open, it handles everything!
    -- Drawing, inputs, etc.
    Run = RunDSSMenu,
    -- This function runs when the menu is opened, and generally initializes the menu.
    Open = dssmod.openMenu,
    -- This function runs when the menu is closed, and generally handles storing of save data /
    -- general shut down.
    Close = CloseDSSMenu,
    -- If UseSubMenu is set to true, when other mods with UseSubMenu set to false / nil are enabled,
    -- your menu will be hidden behind an "Other Mods" button.
    -- A good idea to use to help keep menus clean if you don't expect players to use your menu very
    -- often!
    UseSubMenu = false,
    Directory = exampledirectory,
    DirectoryKey = exampledirectorykey
})

-- There are a lot more features that DSS supports not covered here, like sprite insertion and
-- scroller menus, that you'll have to look at other mods for reference to use. But, this should be
-- everything you need to create a simple menu for configuration or other simple use cases!