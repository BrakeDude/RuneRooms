--[[
    Available Languages:
        -English: "en_us"
        -Russian: "ru"
        -French: "fr"
        -Portuguese: "pt"
        -Spanish: "spa"
        -Polish: "pl"
        -Bulgarian: "bul"
        -Turkish: "turkish"

    How to add more descriptions:
        1- Add a new entry in the corresponding list, like this:
            [enums.X.X] = {

            },
        2- Inside those curly braces { } add an entry for each language description, like this:
            [enums.X.X] = {
                language_code = 
                    {
                        name = "name",
                        description = "description",
                    },
            },
        3- To add more languages to an item, just add more language entries, like this:
            [enums.X.X] = {
                language_code = {
                        name = "name",
                        description = "description",
                },
                language_code_2 = {
                        name = "name 2",
                        description = "description 2",
                },
            },
    
    The language_code is the thing between quotes in the language list.
    To check what enum value correspond to the item, check the enums.lua file.
    Don't forget to add all the commas!
]]

local Descriptions = {}
local Item = RuneRooms.Enums.Item
local RuneEffect = RuneRooms.Enums.RuneEffect
local Runes = RuneRooms.Enums.Runes

Descriptions.Collectibles = {
    [Item.ALGIZ_ESSENCE] = {
        en_us = {
            name = "Essence of Algiz",
            description = "{{BoneHeart}} +1 bone heart "
                .. "# Gives a 3 sec shield when entering a room, and reduces first hit to half a heart"
                .. "# Enemies have a small chance to drop a {{HalfSoulHeart}} half soul heart on death",
        },
        spa = {
            name = "Esencia de Algiz",
            description = "{{Blank}}{{BoneHeart}} +1 corazón de hueso "
                .. "# Otorga un escudo durante 3 segundos al entrar en una habitación, y reduce el primer golpe a medio corazón"
                .. "# Los enemigos tienen una pequeña probabilidad de generar {{HalfSoulHeart}} medio corazón de alma al morir",
        },
    },
    [Item.ANSUZ_ESSENCE] = {
        en_us = {
            name = "Essence of Ansuz",
            description = "{{Bomb}} +2 bombs"
                .. "# Reveals the full map on pickup"
                .. "# On further floors, randomly gives {{Collectible21}} The Compass, {{Collectible54}} Treasure Map or {{Collectible246}} Blue Map effect"
                .. "# Killing an enemy has a small chance of revealing a room in the minimap",
        },
        spa = {
            name = "Esencia de Ansuz",
            description = "{{Bomb}} +2 bombas"
                .. "# Revela el mapa completo al obtenerlo"
                .. "# En los demas pisos, otorga aleatoriamente el efecto de {{Collectible21}} La Brújula, {{Collectible54}} Mapa del Tesoro or {{Collectible246}} Mapa Azul"
                .. "# Matar a un enemigo tiene una pequeña posibilidad de revelar una habitación"
        },
    },
    [Item.BERKANO_ESSENCE] = {
        en_us = {
            name = "Essence of Berkano",
            description = "{{Tears}} +0.3 tears"
                .. "# Enemies have a small chance to spawn a temporary familiar when diying"
                .. "# Enemies with less than 10 HP will spawn a bone orbital instead",
        },
        spa = {
            name = "Esencia de Berkano",
            description = "{{Tears}} +0.3 lágrimas"
                .. "# Los enemigos tienen una pequeña posibilidad de generar un familiar temporal al morir"
                .. "# Los enemigos con menos de 10 PS generan un orbital de hueso en su lugar"
        },
    },
    [Item.DAGAZ_ESSENCE] = {
        en_us = {
            name = "Essence of Dagaz",
            description = "{{Heart}} +1 full heart"
                .. "# {{SoulHeart}} +1 soul heart"
                .. "# Prevents curses for the current and next floor"
                .. "# Enemies nearby to Isaac {{Burning}} burn. Enemies that die while burning spawn a beam of light",
        },
        spa = {
            name = "Esencia de Dagaz",
            description = "{{Heart}} +1 corazón rojo"
                .. "{{SoulHeart}} +1 corazón de alma"
                .. "# Elimina las maldiciones en este piso y el siguiente"
                .. "# Los enemigos cercanos a Isaac {{Burning}} arden. Si mueren mientrar arden, generan un rayo celestial"
        },
    },
    [Item.EHWAZ_ESSENCE] = {
        en_us = {
            name = "Essence of Ehwaz",
            description = "{{Shotspeed}} +0.3 shoot speed"
                .. "# Spawns a crawlspace trapdoor in the starting room of all floors"
                .. "# Small chance to open a red door when clearing up a room",
        },
        spa = {
            name = "Esencia de Ehwaz",
            description = "{{Shotspeed}} +0.3 velocidad de disparo"
                .. "# Genera una trampilla a un crawlspace en la habitacion inicial de todos los pisos"
                .. "# Limpiar una habitacion tiene una pequeña posibilidad de generar una habitación roja"
        },
    },
    [Item.FEHU_ESSENCE] = {
        en_us = {
            name = "Essence of Fehu",
            description = "{{Luck}} +1 luck"
                .. "# Chance to fire a midas tear that turns enemies golden"
                .. "# {{Coin}} Pennies have a higher chance of getting rerolled into a variant",
        },
        spa = {
            name = "Esencia de Fehu",
            description = "{{Luck}} +1 suerte"
                .. "# Posibiliad de disparar lágrimas de Midas, que convierten a los enemigos en oro"
                .. "# {{Coin}} Las monedas tienen mas probabilidad de convertirse en una variante"
        },
    },
    [Item.GEBO_ESSENCE] = {
        en_us = {
            name = "Essence of Gebo",
            description = "{{Coin}} +5 coins"
                .. "# {{Bomb}} +2 bombs"
                .. "# {{Key}} +1 key"
                .. "# The first 5 slot or beggar uses in each floor are free"
                .. "# Slots and beggars will attack enemies in uncleared rooms",
        },
        spa = {
            name = "Esencia de Gebo",
            description = "{{Coin}} +5 monedas"
            .. "# {{Bomb}} +2 bombas"
            .. "# {{Key}} +1 llave"
            .. "# Los 5 primeros usos de máquinas en cada piso son gratis"
            .. "# Las máquinas atacan a los enemigos",
        },
    },
    [Item.HAGALAZ_ESSENCE] = {
        en_us = {
            name = "Essence of Hagalaz",
            description = "{{Range}} +3 range"
                .. "# Retracts spikes and spiked rocks"
                .. "# Red and purple fireplaces get replaced by their non shooting counterparts"
                .. "# Tinted rocks have a higher spawn rate",
        },
        spa = {
            name = "Esencia de Hagalaz",
            description = "{{Range}} +3 rango"
                .. "# Retrae los pinchos y las piedras con pinchos"
                .. "# Las hogueras rojas y moradas son reemplazadas por sus versiones pacíficas"
                .. "# Las piedras marcadas tienen una mayor posibilidad de aparecer"
        },
    },
    [Item.INGWAZ_ESSENCE] = {
        en_us = {
            name = "Essence of Ingwaz",
            description = "{{Key}} +5 keys"
                .. "# Destroying slots, tinted rocks and opening chests rewards extra keys and pickups"
                .. "# Mimic chests no longer appear, and locked chests are replaced by eternal chests",
        },
        spa = {
            name = "Esencia de Ingwaz",
            description = "{{Key}} +5 llaves"
                .. "# Destruir máquinas, piedras marcadas y abrir cofres otorga llaves y objetos extra"
                .. "# Los cofres mímicos no pueden aparecer, y los cofres dorados son reemplazados por cofres eternos"
        },
    },
    [Item.JERA_ESSENCE] = {
        en_us = {
            name = "Essence of Jera",
            description = "{{Speed}} +0.15 speed"
                .. "# All pickups have a chance of respawning somewhere in the room when being collected"
                .. "# Respawned pickups have a chance of becoming a different variant",
        },
        spa = {
            name = "Esencia de Jera",
            description = "{{Speed}} +0.15 velocidad"
                .. "# Todos los objetos tienen una posibilidad de reaparecer en la habitacion al tocarlos"
                .. "# Los objetos reaparecidos tienen la posibilidad de ser otra variante"
        },
    },
    [Item.KENAZ_ESSENCE] = {
        en_us = {
            name = "Essence of Kenaz",
            description = "{{RottenHeart}} +1 rotten heart"
                .. "# Nearby enemies get {{Poison}} poisoned. Enemies that die from this poison spawn a poisonous cloud"
                .. "# {{ArrowUp}} Standing inside a poison cloud grants Isaac {{DamageSmall}} +2 damage and {{TearsSmall}} +1 tears",
        },
        spa = {
            name = "Esencia de Kenaz",
            description = "{{RottenHeart}} +1 corazón podrido"
                .. "# Los enemigos cercanos son {{Poison}} envenenados. Los enemigos que mueran por este veneno, generan una nube venenosa"
                .. "# {{ArrowUp}} Si Isaac se encuentra en una nube venenosa, obtiene {{DamageSmall}} +2 daño y {{TearsSmall}} +1 lágrimas"
        },
    },
    [Item.OTHALA_ESSENCE] = {
        en_us = {
            name = "Essence of Othala",
            description = "{{Collectible}} Spawns an item from the Rune Room pool on pickup"
                .. "# Everytime Isaac picks up an item, there's a small chance that Isaac receives a duplicate",
        },
        spa = {
            name = "Esencia de Othala",
            description = "{{Collectible}} Genera un item de la pool de la Habitación Rúnica"
                .. "# Cada vez que Isaac obtiene un item, hay una pequeña posibilidad de conseguir una copia"
        },
    },
    [Item.PERTHRO_ESSENCE] = {
        en_us = {
            name = "Essence of Perthro",
            description = "{{Damage}} +0.5 damage"
                .. "# Rerolling an item guarantees that it'll be the same quality or higher",
        },
        spa = {
            name = "Esencia de Perthro",
            description = "{{Damage}} +0.5 daño"
                .. "# Rerolear un item garantiza que será de la misma calidad o mayor"
        },
    },
    [Item.SOWILO_ESSENCE] = {
        en_us = {
            name = "Essence of Sowilo",
            description = "{{BlackHeart}} +1 black heart"
                .. "# The last enemy killed in each room respawns as a permanently charmed version"
                .. "# Whenever a friendly enemy dies, it triggers the {{Collectible35}} Necronomicon effect"
                .. "# Friendly enemies that die, have a small chance to respawn in the next room",
        },
        spa = {
            name = "Esencia de Sowilo",
            description = "{{BlackHeart}} +1 corazón negro"
                .. "# El último enemigo asesinado en cada habitación reaparece como una versión amistosa"
                .. "# Cuando un enemigo amistoso muere, activa el effecto de {{Collectible35}} Necronomicon"
                .. "# Los enemigos amistosos muertos tienen una posibilidad de reaparecer en la siguiente habitación"
        },
    },
}


Descriptions.PositiveRuneEffect = {
    [RuneEffect.ALGIZ] = {
        en_us = {
            name = "Algiz",
            description = "{{ArrowUp}} Grants a 7 sec shield in each room"
        },
        spa = {
            name = "Algiz",
            description = "{{ArrowUp}} Otorga un escudo durante 7 segundos en cada habitación"
        },
    },
    [RuneEffect.ANSUZ] = {
        en_us = {
            name = "Ansuz",
            description = "{{ArrowUp}} Grants the {{Collectible590}} Mercurius effect"
        },
        spa = {
            name = "Ansuz",
            description = "{{ArrowUp}} Otorga el efecto de {{Collectible590}} Mercurius"
        },
    },
    [RuneEffect.BERKANO] = {
        en_us = {
            name = "Berkano",
            description = "{{ArrowUp}} Killing enemies spawns blue flies and spiders"
        },
        spa = {
            name = "Berkano",
            description = "{{ArrowUp}} Matar enemigos genera moscas y arañas azules"
        },
    },
    [RuneEffect.DAGAZ] = {
        en_us = {
            name = "Dagaz",
            description = "{{ArrowUp}} Prevents champion enemies from spawning"
        },
        spa = {
            name = "Dagaz",
            description = "{{ArrowUp}} Previene que se generen campeones"
        },
    },
    [RuneEffect.EHWAZ] = {
        en_us = {
            name = "Ehwaz",
            description = "{{ArrowUp}} Spawns a trapdoor to the Great Gideon special crawlspace"
        },
        spa = {
            name = "Ehwaz",
            description = "{{ArrowUp}} Genera una trampilla al crawlspace special de Gran Gideon"
        },
    },
    [RuneEffect.FEHU] = {
        en_us = {
            name = "Fehu",
            description = "{{ArrowUp}} Grants midas tears that turn enemies golden"
        },
        spa = {
            name = "Fehu",
            description = "{{ArrowUp}} Otorga lágrimas de Midas que convierten a los enemigos en oro"
        },
    },
    [RuneEffect.GEBO] = {
        en_us = {
            name = "Gebo",
            description = "{{ArrowUp}} Has a chance of spawning a slot in each room"
        },
        spa = {
            name = "Gebo",
            description = "{{ArrowUp}} Pequeña posibilidad de generar una máquina en cada habitación"
        },
    },
    [RuneEffect.HAGALAZ] = {
        en_us = {
            name = "Hagalaz",
            description = "{{ArrowUp}} Destroys all rocks in each room"
        },
        spa = {
            name = "Hagalaz",
            description = "{{ArrowUp}} Destruye todas las rocas en cada habitación"
        },
    },
    [RuneEffect.INGWAZ] = {
        en_us = {
            name = "Ingwaz",
            description = "{{ArrowUp}} Most chests work like eternal chests"
        },
        spa = {
            name = "Ingwaz",
            description = "{{ArrowUp}} La mayoría de cofres funcionan como cofres eternos"
        },
    },
    [RuneEffect.JERA] = {
        en_us = {
            name = "Jera",
            description = "{{ArrowUp}} Grants the {{Collectible241}} Contract from Below effect"
        },
        spa = {
            name = "Jera",
            description = "{{ArrowUp}} Otorga el efecto del {{Collectible241}} Contrato de Abajo"
        },
    },
    [RuneEffect.KENAZ] = {
        en_us = {
            name = "Kenaz",
            description = "{{ArrowUp}} When entering an uncleared room, poisons all enemies"
        },
        spa = {
            name = "Kenaz",
            description = "{{ArrowUp}} Al entrar en una habitación con enemigos, los envenena"
        },
    },
    [RuneEffect.OTHALA] = {
        en_us = {
            name = "Othala",
            description = "{{ArrowUp}} Grants a temporary copy of a random item for each room"
        },
        spa = {
            name = "Othala",
            description = "{{ArrowUp}} Otorga una copia temporal de un item en cada habitación"
        },
    },
    [RuneEffect.PERTHRO] = {
        en_us = {
            name = "Perthro",
            description = "{{ArrowUp}} Items switch between two possibilities"
        },
        spa = {
            name = "Perthro",
            description = "{{ArrowUp}} Todos los items cambian entre dos posibilidades"
        },
    },
    [RuneEffect.SOWILO] = {
        en_us = {
            name = "Sowilo",
            description = "{{ArrowUp}} Spawns a friendly version of the lowest hp enemy when clearing a room"
        },
        spa = {
            name = "Sowilo",
            description = "{{ArrowUp}} Genera una versión amistosa del enemigo con menos salud al limpiar una habitación"
        },
    },
}


Descriptions.NegativeRuneEffect = {
    [RuneEffect.ALGIZ] = {
        en_us = {
            name = "Algiz",
            description = "{{ArrowDown}} Enemies are invincible for 3 seconds in each room",
        },
        spa = {
            name = "Algiz",
            description = "{{ArrowDown}} Los enemigos son invencibles durante 3 segundos en cada habitación"
        },
    },
    [RuneEffect.ANSUZ] = {
        en_us = {
            name = "Ansuz",
            description = "{{ArrowDown}} Grants the Amnesia effect",
        },
        spa = {
            name = "Ansuz",
            description = "{{ArrowDown}} Otorga el efecto de Amnesia"
        },
    },
    [RuneEffect.BERKANO] = {
        en_us = {
            name = "Berkano",
            description = "{{ArrowDown}} Killing enemies spawns enemy flies and spiders",
        },
        spa = {
            name = "Berkano",
            description = "{{ArrowDown}} Matar enemigos genera moscas y arañas enemigas"
        },
    },
    [RuneEffect.DAGAZ] = {
        en_us = {
            name = "Dagaz",
            description = "{{ArrowDown}} Increases the amount of champion enemies",
        },
        spa = {
            name = "Dagaz",
            description = "{{ArrowDown}} Aumenta el número de campeones"
        },
    },
    [RuneEffect.EHWAZ] = {
        en_us = {
            name = "Ehwaz",
            description = "{{ArrowDown}} Replaces some rocks with trapdoors",
        },
        spa = {
            name = "Ehwaz",
            description = "{{ArrowDown}} Reemplaza algunas piedras con trampillas"
        },
    },
    [RuneEffect.FEHU] = {
        en_us = {
            name = "Fehu",
            description = "{{ArrowDown}} Isaac loses money when taking damage",
        },
        spa = {
            name = "Fehu",
            description = "{{ArrowDown}} Isaac pierde dinero al recibir daño"
        },
    },
    [RuneEffect.GEBO] = {
        en_us = {
            name = "Gebo",
            description = "{{ArrowDown}} Destroys all machines without spawning any rewards",
        },
        spa = {
            name = "Gebo",
            description = "{{ArrowDown}} Destruye todas las máquinas sin generar objetos",
        },
    },
    [RuneEffect.HAGALAZ] = {
        en_us = {
            name = "Hagalaz",
            description = "{{ArrowDown}} Chance of replacing regular rocks with their spiked variant",
        },
        spa = {
            name = "Hagalaz",
            description = "{{ArrowDown}} Posibilidad de reemplazar rocas con su versión con pinchos",
        },
    },
    [RuneEffect.INGWAZ] = {
        en_us = {
            name = "Ingwaz",
            description = "{{ArrowDown}} Regular and red chests get replaced with spiked chests. Locked and bomb chests take 2 keys and bombs to open respectively",
        },
        spa = {
            name = "Ingwaz",
            description = "{{ArrowDown}} Los cofres normales y rojos son reemplazados con cofres de pinchos. Los cofres dorados y de piedra necesitan 2 llaves y bombas para abrir respectivamente",
        },
    },
    [RuneEffect.JERA] = {
        en_us = {
            name = "Jera",
            description = "{{ArrowDown}} All pickups have despawn after a certain time",
        },
        spa = {
            name = "Jera",
            description = "{{ArrowDown}} Todos los objectos desaparecen tras un tiempo",
        },
    },
    [RuneEffect.KENAZ] = {
        en_us = {
            name = "Kenaz",
            description = "{{ArrowDown}} Enemies spawn poisonous clouds when they die",
        },
        spa = {
            name = "Kenaz",
            description = "{{ArrowDown}} Los enemigos generan nubes venenosas al morir",
        },
    },
    [RuneEffect.OTHALA] = {
        en_us = {
            name = "Othala",
            description = "{{ArrowDown}} Rerolls the highest quality item Isaac has into a lower quality one",
        },
        spa = {
            name = "Othala",
            description = "{{ArrowDown}} Rerrolea el objeto de mayor calidad que tiene Isaac en uno con menor calidad",
        },
    },
    [RuneEffect.PERTHRO] = {
        en_us = {
            name = "Perthro",
            description = "{{ArrowDown}} Replaces items with trinkets",
        },
        spa = {
            name = "Perthro",
            description = "{{ArrowDown}} Reemplaza los items con baratijas",
        },
    },
    [RuneEffect.SOWILO] = {
        en_us = {
            name = "Sowilo",
            description = "{{ArrowDown}} Clearing a room respawns all the enemies",
        },
        spa = {
            name = "Sowilo",
            description = "{{ArrowDown}} Al limpiar una habitación, todos los enemigos reaparecen",
        },
    },
}

Descriptions.Runes = {
    [Runes.FEHU] = {
        en_us = {
            name = "Fehu",
            description = "Applies the Midas Touch effect to half the monsters in a room for 5 seconds"
        },
        spa = {
            name = "Fehu",
            description = "Aplica el efecto de Toque de Midas a la mitad de los monstruos en una habitación por 5 segundos"
        },
        ru = {
            name = "Феху",
            description = "Применяет эффект Прикосновения Мидаса к половине монстров в комнате на 5 секунд"
        },
    },
    [Runes.GEBO] = {
        en_us = {
            name = "Gebo",
            description = "Interacts with any machine or beggar in the room. Plays beggars 6 times, plays blood machines 4 times, plays other machines 5 times. Machines and beggars have an increased chance to pay out or explode, even paying out at only one play"
        },
        spa = {
            name = "Gebo",
            description = "Interactúa con cualquier máquina o mendigo en la habitación. Usa mendigos 6 veces, usa donadores de sangre 4 veces, usa otras máquinas 5 veces. Las máquinas y los mendigos tienen una mayor probabilidad de pagar o explotar, incluso pagando en una sola jugada"
        },
        ru = {
            name = "Гебо",
            description = "Взаимодействует с любыми машиной или попрошайкой в ​​комнате. Попрошайки - 6 раз, донорские машины - 4 раза, остальные - 5 раз. Машины и попрошайки имеют повышенный шанс на награды или взорваться, даже если заплатят только за одну игру"
        },
    },
    [Runes.INGWAZ] = {
        en_us = {
            name = "Ingwaz",
            description = "Unlocks every chest in the room"
        },
        spa = {
            name = "Ingwaz",
            description = "Abre todos los cofres de una sala"
        },
        ru = {
            name = "Гебо",
            description = "Открывает все сундуки в комнате"
        },
    },
    [Runes.KENAZ] = {
        en_us = {
            name = "Kenaz",
            description = "Poisons all enemies in the room"
        },
        spa = {
            name = "Kenaz",
            description = "Envenena a todos los enemigos en la sala"
        },
        ru = {
            name = "Кеназ",
            description = "Отравляет всех врагов в комнате"
        },
    },
    [Runes.OTHALA] = {
        en_us = {
            name = "Othala",
            description = "Gives another copy of a random item that you already have"
        },
        spa = {
            name = "Othala",
            description = "Te da una copia de un objeto ya existente en tu inventario"
        },
        ru = {
            name = "Отала",
            description = "Дает ещё одну копию случайного имеющегося артефакта"
        },
    },
    [Runes.SOWILO] = {
        en_us = {
            name = "Sowilo",
            description = "Respawn all enemies of the room"
            .."#Allows you to farm room clear rewards"
            .."#!!! If used in a greed fight, it can reroll the room into a Shop"
        },
        spa = {
            name = "Sowilo",
            description = "Revive a los enemigos de una sala limpia"
            .."#Permite conseguir más recompensas"
            .."#!!! Si se usa en una pelea contra Greed, puede cambiar la sala a una tienda"
        },
        ru = {
            name = "Совило",
            description = "Восстанавливает ранее убитых врагов в комнате"
            .."#Позволяет повторно получить награду за зачистку комнаты"
            .."#!!! Если использовать в борьбе с жадностью, можно превратить комнату в магазин"
        },
    },
}


---@param runeEffect RuneEffect
local function GetPositiveRuneEffectDescription(runeEffect)
    local language = EID:getLanguage()
    local runeEffectDesc = Descriptions.PositiveRuneEffect[runeEffect][language]

    if not runeEffectDesc then
        runeEffectDesc = Descriptions.PositiveRuneEffect[runeEffect].en_us
    end

    return runeEffectDesc
end


---@param runeEffect RuneEffect
local function GetNegativeRuneEffectDescription(runeEffect)
    local language = EID:getLanguage()
    local runeEffectDesc = Descriptions.NegativeRuneEffect[runeEffect][language]

    if not runeEffectDesc then
        runeEffectDesc = Descriptions.NegativeRuneEffect[runeEffect].en_us
    end

    return runeEffectDesc
end

---@param giantCrystal Entity
local function SpawnNegativeEffectDescriptionHolder(giantCrystal)
    local runeEffect = RuneRooms:GetRuneEffectForFloor()

    local runeEffectDesc = GetNegativeRuneEffectDescription(runeEffect)
    if not runeEffectDesc then return end

    local eidHolder = TSIL.EntitySpecific.SpawnEffect(
        RuneRooms.Enums.EffectVariant.EID_DESCRIPTION_HOLDER,
        0,
        giantCrystal.Position
    )

    eidHolder:GetData().EID_Description = {
        Name = runeEffectDesc.name,
        Description = runeEffectDesc.description
    }
end


RuneRooms:AddModCompat("EID", function ()
    EID.effectList[tostring(RuneRooms.Enums.EffectVariant.EID_DESCRIPTION_HOLDER)] = true

    -- Collectibles
    for collectible, translations in pairs(Descriptions.Collectibles) do
        for language, description in pairs(translations) do
            EID:addCollectible(collectible, description.description, description.name, language)
        end
    end

    -- Runes
    for rune, translations in pairs(Descriptions.Runes) do
        for language, description in pairs(translations) do
            EID:addCard(rune, description.description, description.name, language)
        end
    end

    --[[RuneRooms:AddCallback(
        RuneRooms.Enums.CustomCallback.POST_GENERIC_PROP_INIT,
        function (_, giantCrystal)
            if RuneRooms:IsGiantRuneCrystalBroken(giantCrystal) then
                SpawnNegativeEffectDescriptionHolder(giantCrystal)
            else
                local runeEffect = RuneRooms:GetRuneEffectForFloor()

                local runeEffectDesc = GetPositiveRuneEffectDescription(runeEffect)
                if not runeEffectDesc then return end

                giantCrystal:GetData().EID_Description = {
                    Name = runeEffectDesc.name,
                    Description = runeEffectDesc.description
                }
            end
        end,
        RuneRooms.Enums.GenericPropVariant.GIANT_RUNE_CRYSTAL
    )

    RuneRooms:AddCallback(
        RuneRooms.Enums.CustomCallback.POST_GIANT_RUNE_CRYSTAL_DESTROYED,
        function (_, giantCrystal)
            SpawnNegativeEffectDescriptionHolder(giantCrystal)
        end
    )]]
end)