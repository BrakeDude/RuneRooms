# Rune Rooms

Rune rooms is a mod for The Binding of Isaac: Repentance that adds a new kind of room: Rune Rooms.

These rooms have a chance to replace vault rooms. Inside them you'll find a huge runic crystal that may be activated by pressing the pads in the room for a positive effect.

# For mod developers

Rune rooms adds a bunch of helper functions and callbacks to help other mods be compatible.

## Callbacks

### ON_CUSTOM_CMD
Called whenever a command that starts with "rune" is run in the console.

Return true so the handler knows a command has been found and doesn't print the error message.

| Function args | Optional args |
|---------------|---------------|
| string command | string command |
| string ... params | |

### POST_GAIN_POSITIVE_RUNE_EFFECT
Called whenever a positive rune effect is added.

| Function args | Optional args |
|---------------|---------------|
| RuneEffect runeEffect | RuneEffect runeEffect |

### POST_GAIN_NEGATIVE_RUNE_EFFECT
Called whenever a negative rune effect is added.

| Function args | Optional args |
|---------------|---------------|
| RuneEffect runeEffect | RuneEffect runeEffect |

### POST_GENERIC_PROP_INIT
Called either from the `MC_NEW_ROOM` callback or the `MC_POST_UPDATE` callback, the first frame a generic prop is available.

| Function args | Optional args |
|---------------|---------------|
| Entity genericProp | integer genericPropVariant |

### POST_GENERIC_PROP_UPDATE
Called from the `MC_POST_UPDATE` callback for each generic prop in the room.

| Function args | Optional args |
|---------------|---------------|
| Entity genericProp | integer genericPropVariant |

### POST_CUSTOM_TEAR_FLAG_ADDED
Called whenever a custom tear flag is added to a tear.

| Function args | Optional args |
|---------------|---------------|
| EntityTear tear | CustomTearFlag tearFlag |
| CustomTearFlag tearFlag | |

### POST_CUSTOM_TEAR_FLAG_REMOVED
Called whenever a custom tear flag is removed from a tear.

| Function args | Optional args |
|---------------|---------------|
| EntityTear tear | CustomTearFlag tearFlag |
| CustomTearFlag tearFlag | |

### PRE_GET_RUNE_DOOR_SPRITE
Called before the rune door sprite is replaced. Return a spritesheet to replace the regular one.

| Function args | Optional args |
|---------------|---------------|
| GridEntityDoor door | |

### PRE_GET_RUNE_PIT_SPRITE
Called before the rune room pits sprite is replaced. Return a spritesheet to replace the regular one.

### PRE_GET_RUNE_GRID_SPRITE
Called before the rune room grids sprite are replaced. Return a spritesheet to replace the regular one.

| Function args | Optional args |
|---------------|---------------|
| GridEntityType gridType | |

## API functions

`void RuneRooms.API:AddCoinSubtypeToReroll(CoinSubType|integer coinSubtype, number chance)`

Adds a coin subtype Essence of Fehu might reroll other coins into.

For reference, these are the vanilla coins:
```lua
{chance = 50, value = CoinSubType.COIN_DOUBLEPACK},
{chance = 30, value = CoinSubType.COIN_NICKEL},
{chance = 10, value = CoinSubType.COIN_DIME},
{chance = 5,  value = CoinSubType.COIN_LUCKYPENNY}
```

`void RuneRooms.API:AddCollectiblesToRuneItemPool(PoolItems[] collectibles)`

Adds any number of collectibles to the rune item pool.

`void RuneRooms.API:AddPossibleSlotToSpawn(integer slotVariant, fun(): boolean canSpawn)`

Adds a slot that may spawn with the positive Gebo rune room effect. If `canSpawn` is set to nil, the slot will always be able to spawn.

`void RuneRooms.API:AddRuneRoom(integer id, number weight)`

Adds a new rune room. The id must be unique, and the room has to be a chest room.

This function has to be called before the first `MC_NEW_LEVEL` callback is run, otherwise the rune rooms will already be loaded.

`void RuneRooms.API:ForbidEnemyFromSpawningBugsOnDeath(Entity entity)`

Prevents an entity from spawning enemy flies and spiders on death by the effect of the negative Berkano rune effect.

`void RuneRooms.API:ForbidPickupFromRespawning(PickupVariant pickupVariant)`

Prevents a pickup variant from respawning when being collected by the effect of Essence of Jera.


## General functions

`void RuneRooms:ActivateGiantCrystal(Entity giantCrystal)`

Activates the given giant crystal, which triggers the positive effect for the floor.

`void RuneRooms:ActivateNegativeEffect(RuneEffect runeEffect)`

Activates the negative effect of a rune.

`void RuneRooms:ActivatePositiveEffect(RuneEffect runeEffect)`

Activates the negative effect of a rune.

`void RuneRooms:AddCustomTearFlag(EntityTear tear, CustomTearFlag|integer tearFlag)`

Adds a custom tear flag to a tear.

`void RuneRooms:AddShieldInvincibility(EntityPlayer player, integer duration)`

Adds a shield similar to the one given by Book of Shadows. The duration must be given in frames.

`void RuneRooms:DealDamageToGiantCrystal(Entity giantCrystal)`

Deals one damage to a giant crystal. Will destroy it if the crystal is at one hp. Does nothing if the crystal is already activated.

`void RuneRooms:DecreaseGeboEssenceSlotFreeUses(EntityPlayer player)`

Decreases the number of free slot uses a player has by one. Use it to add compatibility with custom slots.

`CustomTearFlag RuneRooms:GetCustomTearFlags(EntityTear tear)`

Returns the custom tear flags a tear has.

`integer RuneRooms:GetGeboEssenceSlotFreeUses(EntityPlayer player)`

Helper function to check how many free slot uses a player has. Use it to add compatibility with custom slots.

`RuneEffect RuneRooms:GetRuneEffectForFloor()`

Returns the rune effect this floor has.

`boolean RuneRooms:HasCustomTearFlag(EntityTear tear, CustomTearFlag|integer tearFlag)`

Checks if a tear has a given custom tear flag.

`boolean RuneRooms:HasShieldInvincibility(EntityPlayer player)`

Checks if a player has the shield given by `RuneRooms:AddShieldInvincibility`.

`boolean RuneRooms:IsNegativeEffectActive(RuneEffect runeEffect)`

Checks if the negative effect of a given rune is active.

`boolean RuneRooms:IsPositiveEffectActive(RuneEffect runeEffect)`

Checks if the positive effect of a given rune is active.

`void RuneRooms:RemoveCustomTearFlag(EntityTear tear, CustomTearFlag|integer)`

Removes the given custom tear flags from a tear.

`void RuneRooms:ReplaceRuneDoorSprites()`

Checks all doors in the current room and replaces their sprites if they should have the rune room door sprite.

`void RuneRooms:WillChestClose(EntityType chest)`

Helper function to check if a chest will close by the positive ingwaz rune effect.