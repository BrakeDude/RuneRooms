RuneRooms.Enums = {}

RuneRooms.Enums.Item = {
    ALGIZ_ESSENCE   = Isaac.GetItemIdByName("Essence of Algiz"),
    ANSUZ_ESSENCE   = Isaac.GetItemIdByName("Essence of Ansuz"),
    BERKANO_ESSENCE = Isaac.GetItemIdByName("Essence of Berkano"),
    DAGAZ_ESSENCE   = Isaac.GetItemIdByName("Essence of Dagaz"),
    EHWAZ_ESSENCE   = Isaac.GetItemIdByName("Essence of Ehwaz"),
    FEHU_ESSENCE    = Isaac.GetItemIdByName("Essence of Fehu"),
    GEBO_ESSENCE    = Isaac.GetItemIdByName("Essence of Gebo"),
    HAGALAZ_ESSENCE = Isaac.GetItemIdByName("Essence of Hagalaz"),
    INGWAZ_ESSENCE  = Isaac.GetItemIdByName("Essence of Ingwaz"),
    JERA_ESSENCE    = Isaac.GetItemIdByName("Essence of Jera"),
    KENAZ_ESSENCE   = Isaac.GetItemIdByName("Essence of Kenaz"),
    OTHALA_ESSENCE  = Isaac.GetItemIdByName("Essence of Othala"),
    PERTHRO_ESSENCE = Isaac.GetItemIdByName("Essence of Perthro"),
    SOWILO_ESSENCE  = Isaac.GetItemIdByName("Essence of Sowilo"),
}


---@enum RuneEffect
RuneRooms.Enums.RuneEffect = {
    ALGIZ   = 1<<0,
    ANSUZ   = 1<<1,
    BERKANO = 1<<2,
    DAGAZ   = 1<<3,
    EHWAZ   = 1<<4,
    FEHU    = 1<<5,
    GEBO    = 1<<6,
    HAGALAZ = 1<<7,
    INGWAZ  = 1<<8,
    JERA    = 1<<9,
    KENAZ   = 1<<10,
    OTHALA  = 1<<11,
    PERTHRO = 1<<12,
    SOWILO  = 1<<13,
}

RuneRooms.Enums.RuneCurse = {
    CURSE_OF_ALGIZ   = 1 << 0,
    CURSE_OF_ANSUZ   = 1 << 1,
    CURSE_OF_BERKANO = 1 << 2,
    CURSE_OF_DAGAZ   = 1 << 3,
    CURSE_OF_EHWAZ   = 1 << 4,
    CURSE_OF_FEHU    = 1 << 5,
    CURSE_OF_GEBO    = 1 << 6,
    CURSE_OF_HAGALAZ = 1 << 7,
    CURSE_OF_INGWAZ  = 1 << 8,
    CURSE_OF_JERA    = 1 << 9,
    CURSE_OF_KENAZ   = 1 << 10,
    CURSE_OF_OTHALA  = 1 << 11,
    CURSE_OF_PERTHRO = 1 << 12,
    CURSE_OF_SOWILO  = 1 << 13,
}

RuneRooms.Enums.RuneBlessing = {
    BLESSING_OF_ALGIZ   = 1 << 0,
    BLESSING_OF_ANSUZ   = 1 << 1,
    BLESSING_OF_BERKANO = 1 << 2,
    BLESSING_OF_DAGAZ   = 1 << 3,
    BLESSING_OF_EHWAZ   = 1 << 4,
    BLESSING_OF_FEHU    = 1 << 5,
    BLESSING_OF_GEBO    = 1 << 6,
    BLESSING_OF_HAGALAZ = 1 << 7,
    BLESSING_OF_INGWAZ  = 1 << 8,
    BLESSING_OF_JERA    = 1 << 9,
    BLESSING_OF_KENAZ   = 1 << 10,
    BLESSING_OF_OTHALA  = 1 << 11,
    BLESSING_OF_PERTHRO = 1 << 12,
    BLESSING_OF_SOWILO  = 1 << 13,
}



RuneRooms.Enums.PickupVariant = {
    DOUBLE_LOCKED_CHEST = Isaac.GetEntityVariantByName("Double Locked Chest"),
    DOUBLE_BOMB_CHEST   = Isaac.GetEntityVariantByName("Double Bomb Chest"),
}


RuneRooms.Enums.EffectVariant = {
    SMOKE_CLOUD             = Isaac.GetEntityVariantByName("Rune Rooms Smoke Screen"),
    EID_DESCRIPTION_HOLDER  = Isaac.GetEntityVariantByName("EID Description Holder")
}

RuneRooms.Enums.EffectSubType = {
    ESSENCE_OF_DAGAZ_HALO = Isaac.GetEntitySubTypeByName("Essence of Dagaz Halo")
}

RuneRooms.Enums.Runes = {
    GEBO = Isaac.GetCardIdByName("Gebo"),
    KENAZ = Isaac.GetCardIdByName("Kenaz"),
    FEHU = Isaac.GetCardIdByName("Fehu"),
    OTHALA = Isaac.GetCardIdByName("Othala"),
    SOWILO = Isaac.GetCardIdByName("Sowilo"),
    INGWAZ = Isaac.GetCardIdByName("Ingwaz"),
}

RuneRooms.Enums.GenericPropVariant = {
    GIANT_RUNE_CRYSTAL  = Isaac.GetEntityVariantByName("Giant Rune Crystal"),
    RUNE_PAD            = Isaac.GetEntityVariantByName("Rune Pad"),
}


RuneRooms.Enums.SaveKey = {
    MINIMAPI_DATA                   = "MINIMAPI_DATA",
    DSS_MENU_OPTIONS                = "DSS_MENU_OPTIONS",

    ROCKS_SPRITE_MODE               = "ROCKS_SPRITE_MODE",
    PITS_SPRITE_MODE                = "PITS_SPRITE_MODE",

    NEGATIVE_DAGAZ_CURSE            = "NEGATIVE_DAGAZ_CURSE",
    FORCED_RUNE_EFFECT              = "FORCED_RUNE_EFFECT",
    PERSISTENT_RUNE_CURSES          = "PERSISTENT_RUNE_CURSES",
    LEVEL_RUNE_BLESSINGS            = "LEVEL_RUNE_BLESSINGS",

    SHIELD_DURATION_PER_PLAYER      = "SHIELD_DURATION_PER_PLAYER",

    POSITIVE_FEHU_RNG_PER_PLAYER    = "POSITIVE_FEHU_RNG_PER_PLAYER",
    NEGATIVE_FEHU_RNG_PER_PLAYER    = "NEGATIVE_FEHU_RNG_PER_PLAYER",
    REPLACED_DOUBLE_CLOSED_CHESTS   = "REPLACED_DOUBLE_CLOSED_CHESTS",
    ROOMS_USED_ISAACS_SOUL          = "ROOMS_USED_ISAACS_SOUL",
    LOWEST_HEALTH_ENEMY             = "LOWEST_HEALTH_ENEMY",
    ROOMS_SPAWNED_SLOT              = "ROOMS_SPAWNED_SLOT",
    FREE_SLOT_USES_PER_PLAYER       = "FREE_SLOT_USES_PER_PLAYER",
 
    COUNT_RUNES_USED_IN_RUN         = "COUNT_RUNES_USED_IN_RUN",
    RUNE_ROOM_SPAWN_CHANCE          = "RUNE_ROOM_SPAWN_CHANCE",
    RUNE_ROOM_ENTERED_IN_RUN        = "RUNE_ROOM_ENTERED_IN_RUN",
}


---@enum RuneRoomsCustomCallback
RuneRooms.Enums.CustomCallback = {
    --Called whenever a command that starts with "rune" is run in the console.
    --
    --Return true so the handler knows a command has been found and doesn't print the error message.
	--
	--Params:
	--
	-- * command - string
    -- * ... params - string
	--
	--Optional args:
	--
	-- * command - string
    ON_CUSTOM_CMD = "ON_CUSTOM_CMD",

    --Called whenever a positive rune effect is added.
	--
	--Params:
	--
	-- * runeEffect - RuneEffect
	--
	--Optional args:
	--
	-- * runeEffect - RuneEffect
    POST_GAIN_RUNE_BLESSING = "POST_GAIN_RUNE_BLESSING",

    --Called whenever a negative rune effect is added.
	--
	--Params:
	--
	-- * runeEffect - RuneEffect
	--
	--Optional args:
	--
	-- * runeEffect - RuneEffect
    POST_GAIN_RUNE_CURSE = "POST_GAIN_RUNE_CURSE",

    --Called either from the `MC_NEW_ROOM` callback or the `MC_POST_UPDATE` callback,
    --the first frame a generic prop is available.
    --
    --Params:
    --
    -- * genericProp - Entity
    --
    --Optional args:
    --
    -- * genericPropVariant - GenericPropVariant
    POST_GENERIC_PROP_INIT = "POST_GENERIC_PROP_INIT",

    --Called from the `MC_POST_UPDATE` callback for each generic prop in the room.
    --
    --Params:
    --
    -- * genericProp - Entity
    --
    --Optional args:
    --
    -- * genericPropVariant - GenericPropVariant
    POST_GENERIC_PROP_UPDATE = "POST_GENERIC_PROP_UPDATE",

    --Called whenever a custom tear flag is added to a tear.
    --
    --Params:
    --
    -- * tear - EntityTear
    -- * tearFlag - CustomTearFlag
    --
    --Optional args:
    --
    -- * tearFlag - CustomTearFlag
    POST_CUSTOM_TEAR_FLAG_ADDED = "POST_CUSTOM_TEAR_FLAG_ADDED",

    --Called whenever a custom tear flag is removed from a tear.
    --
    --Params:
    --
    -- * tear - EntityTear
    -- * tearFlag - CustomTearFlag
    --
    --Optional args:
    --
    -- * tearFlag - CustomTearFlag
    POST_CUSTOM_TEAR_FLAG_REMOVED = "POST_CUSTOM_TEAR_FLAG_REMOVED",

    ---Called before the rune door sprite is replaced. Return a spritesheet
    ---to replace the regular one.
    --
    --Params:
    --
    -- * door - GridEntityDoor
    PRE_GET_RUNE_DOOR_SPRITE = "PRE_GET_RUNE_DOOR_SPRITE",

    ---Called before the rune room pits sprite is replaced. Return a spritesheet
    ---to replace the regular one.
    PRE_GET_RUNE_PIT_SPRITE = "PRE_GET_RUNE_PIT_SPRITE",

    ---Called before the rune room grids sprite are replaced. Return a spritesheet
    ---to replace the regular one.
    --
    --Params:
    --
    -- * gridType - GridEntityType
    PRE_GET_RUNE_GRID_SPRITE = "PRE_GET_RUNE_GRID_SPRITE",

    ---Called after a giant rune crystal is destroyed.
    --
    --Params:
    --
    -- * giantRuneCrystal - Entity
    POST_GIANT_RUNE_CRYSTAL_DESTROYED = "POST_GIANT_RUNE_CRYSTAL_DESTROYED",

    ---Called before spawning rune room. Return a new spawn chance.
    --
    --Params:
    --
    -- * chance - number
    RUNE_ROOM_SPAWN_CHANCE = "RUNE_ROOM_SPAWN_CHANCE",

    --- Called when opening chests using Ingwaz rune.
    --
    --Params:
    -- * pickup - EntityPickup
    -- * player - EntityPlayer
    INGWAZ_OPEN_CHEST = "INGWAZ_OPEN_CHEST",

    
	RUN_RUNE_MAIN = "RUN_RUNE_MAIN",
	RUN_RUNE_EXTRA = "RUN_RUNE_EXTRA",
}


RuneRooms.Enums.SoundEffect = {
    RUNE_CRYSTAL_EXPLOSION = Isaac.GetSoundIdByName("Rune Crystal Explosion"),
    RUNE_PAD_ACTIVATION = Isaac.GetSoundIdByName("Rune Pad Activation"),
    RUNE_GEBO = Isaac.GetSoundIdByName("Gebo"),
    RUNE_KENAZ = Isaac.GetSoundIdByName("Kenaz"),
    RUNE_FEHU = Isaac.GetSoundIdByName("Fehu"),
    RUNE_OTHALA = Isaac.GetSoundIdByName("Othala"),
    RUNE_SOWILO = Isaac.GetSoundIdByName("Sowilo"),
    RUNE_INGWAZ = Isaac.GetSoundIdByName("Ingwaz"),
}


RuneRooms.Enums.Music = {
    RUNE_ROOM = Isaac.GetMusicIdByName("Rune Room")
}

RuneRooms.Enums.Achievement = {
    RUNE_ROOMS = Isaac.GetAchievementIdByName("Rune Rooms")
}

RuneRooms.Enums.ItemPool = {
    RUNE_ROOM_POOL = Isaac.GetPoolIdByName("Rune Room")
}


---@enum CustomTearFlag
RuneRooms.Enums.TearFlag = {
    --Turns hit enemies into gold (midas effect)
    MIDAS = 1 << 0,

    --Leaves blood creep on impact
    BLOOD_CREEP = 1 << 1,
}


---@enum GridSpriteMode
RuneRooms.Enums.GridSpriteMode = {
    DEFAULT = 1,
    FORCE_VANILLA = 2,
    FORCE_FF = 3
}