RuneRooms.Constants = {}

RuneRooms.Constants.MOD_ID = "RuneRooms"
RuneRooms.Constants.MINIMAPI_VERSION = RuneRooms.Constants.MOD_ID

RuneRooms.Constants.RUNE_NAMES = {
    [RuneRooms.Enums.RuneEffect.ALGIZ]      = "algiz",
    [RuneRooms.Enums.RuneEffect.ANSUZ]      = "ansuz",
    [RuneRooms.Enums.RuneEffect.BERKANO]    = "berkano",
    [RuneRooms.Enums.RuneEffect.DAGAZ]      = "dagaz",
    [RuneRooms.Enums.RuneEffect.EHWAZ]      = "ehwaz",
    [RuneRooms.Enums.RuneEffect.FEHU]       = "fehu",
    [RuneRooms.Enums.RuneEffect.GEBO]       = "gebo",
    [RuneRooms.Enums.RuneEffect.HAGALAZ]    = "hagalaz",
    [RuneRooms.Enums.RuneEffect.INGWAZ]     = "ingwaz",
    [RuneRooms.Enums.RuneEffect.JERA]       = "jera",
    [RuneRooms.Enums.RuneEffect.KENAZ]      = "kenaz",
    [RuneRooms.Enums.RuneEffect.OTHALA]     = "othala",
    [RuneRooms.Enums.RuneEffect.PERTHRO]    = "perthro",
    [RuneRooms.Enums.RuneEffect.SOWILO]     = "sowilo"
}

RuneRooms.Constants.ESSENCE_ITEM_PER_RUNE = {
    [RuneRooms.Enums.RuneEffect.ALGIZ]      = RuneRooms.Enums.Item.ALGIZ_ESSENCE,
    [RuneRooms.Enums.RuneEffect.ANSUZ]      = RuneRooms.Enums.Item.ANSUZ_ESSENCE,
    [RuneRooms.Enums.RuneEffect.BERKANO]    = RuneRooms.Enums.Item.BERKANO_ESSENCE,
    [RuneRooms.Enums.RuneEffect.DAGAZ]      = RuneRooms.Enums.Item.DAGAZ_ESSENCE,
    [RuneRooms.Enums.RuneEffect.EHWAZ]      = RuneRooms.Enums.Item.EHWAZ_ESSENCE,
    [RuneRooms.Enums.RuneEffect.FEHU]       = RuneRooms.Enums.Item.FEHU_ESSENCE,
    [RuneRooms.Enums.RuneEffect.GEBO]       = RuneRooms.Enums.Item.GEBO_ESSENCE,
    [RuneRooms.Enums.RuneEffect.HAGALAZ]    = RuneRooms.Enums.Item.HAGALAZ_ESSENCE,
    [RuneRooms.Enums.RuneEffect.INGWAZ]     = RuneRooms.Enums.Item.INGWAZ_ESSENCE,
    [RuneRooms.Enums.RuneEffect.JERA]       = RuneRooms.Enums.Item.JERA_ESSENCE,
    [RuneRooms.Enums.RuneEffect.KENAZ]      = RuneRooms.Enums.Item.KENAZ_ESSENCE,
    [RuneRooms.Enums.RuneEffect.OTHALA]     = RuneRooms.Enums.Item.OTHALA_ESSENCE,
    [RuneRooms.Enums.RuneEffect.PERTHRO]    = RuneRooms.Enums.Item.PERTHRO_ESSENCE,
    [RuneRooms.Enums.RuneEffect.SOWILO]     = RuneRooms.Enums.Item.SOWILO_ESSENCE,
}

RuneRooms.Constants.RUNE_ROOMS_IDS = {
    [3670] = 1,
    [3671] = 1,
    [3672] = 1,
    [3673] = 1,
    [3674] = 1,
    [3675] = 1,
    [3676] = 1,
    [3677] = 1,
    [3678] = 0.75,
    [3679] = 0.75,
    [3680] = 1,
    [3681] = 0.1,
    [3682] = 0.1,
    [3683] = 1,
    [3684] = 0.75,
    [3685] = 1,
    [3686] = 1,
    [3687] = 1,
    [3688] = 1,
    [3689] = 1,
    [3690] = 1,
}
---@type {chance: number, value: RoomConfig_Room}[]
RuneRooms.Constants.RUNE_ROOMS_DATAS = {}

RuneRooms.Constants.RUNE_ROOM_ICON = "RuneRoomIcon"

RuneRooms.Constants.RUNE_EFFECT_ICON_FRAME = {
    [RuneRooms.Enums.RuneEffect.HAGALAZ]    = 0,
    [RuneRooms.Enums.RuneEffect.JERA]       = 1,
    [RuneRooms.Enums.RuneEffect.EHWAZ]      = 2,
    [RuneRooms.Enums.RuneEffect.DAGAZ]      = 3,
    [RuneRooms.Enums.RuneEffect.ANSUZ]      = 4,
    [RuneRooms.Enums.RuneEffect.PERTHRO]    = 5,
    [RuneRooms.Enums.RuneEffect.BERKANO]    = 6,
    [RuneRooms.Enums.RuneEffect.ALGIZ]      = 7,
    [RuneRooms.Enums.RuneEffect.GEBO]       = 8,
    [RuneRooms.Enums.RuneEffect.KENAZ]      = 9,
    [RuneRooms.Enums.RuneEffect.FEHU]       = 10,
    [RuneRooms.Enums.RuneEffect.OTHALA]     = 11,
    [RuneRooms.Enums.RuneEffect.INGWAZ]     = 12,
    [RuneRooms.Enums.RuneEffect.SOWILO]     = 13,
}