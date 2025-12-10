local HagalazEssence = {}

local FIREPLACE_VARIANTS_TO_SAFE_VARIANTS = {
    [TSIL.Enums.FireplaceVariant.RED] = TSIL.Enums.FireplaceVariant.NORMAL,
    [TSIL.Enums.FireplaceVariant.PURPLE] = TSIL.Enums.FireplaceVariant.BLUE
}
local TINTED_ROCK_REPLACE_CHANCE = 0.05
local HagalazItem = RuneRooms.Enums.Item.HAGALAZ_ESSENCE

---@param player EntityPlayer
function HagalazEssence:OnRangeCache(player)
    local numItems = player:GetCollectibleNum(HagalazItem)
    player.TearRange = player.TearRange + numItems * (3 * 40)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    HagalazEssence.OnRangeCache,
    CacheFlag.CACHE_RANGE
)


local function RetractSpikes()
    local player = Isaac.GetPlayer()
    local trinketSituation = TSIL.Players.TemporarilyRemoveTrinkets(player)

    player:AddTrinket(TrinketType.TRINKET_FLAT_FILE)

    TSIL.Rooms.UpdateRoom()

    player:TryRemoveTrinket(TrinketType.TRINKET_FLAT_FILE)

    TSIL.Players.GiveTrinketsBack(player, trinketSituation)
end


local function ReplaceRocks()
    local rocks = TSIL.GridSpecific.GetRocks()

    TSIL.Utils.Tables.ForEach(rocks, function (_, rock)
        local rng = TSIL.RNG.NewRNG(rock.Desc.SpawnSeed)

        if rng:RandomFloat() >= TINTED_ROCK_REPLACE_CHANCE then return end

        TSIL.GridEntities.SpawnGridEntity(
            GridEntityType.GRID_ROCKT,
            0,
            rock:GetGridIndex(),
            true
        )
    end)
end


function HagalazEssence:OnHagalazEssencePickup()
    RetractSpikes()

    ReplaceRocks()
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_PLAYER_COLLECTIBLE_ADDED,
    HagalazEssence.OnHagalazEssencePickup,
    {
        nil,
        nil,
        RuneRooms.Enums.Item.HAGALAZ_ESSENCE
    }
)


function HagalazEssence:OnNewRoom()
    if not PlayerManager.AnyoneHasCollectible(HagalazItem) then return end

    RetractSpikes()

    ReplaceRocks()
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    HagalazEssence.OnNewRoom
)


---@param type EntityType
---@param variant integer
---@param subtype integer
---@param seed integer
function HagalazEssence:PreEntitySpawn(type, variant, subtype, _, _, _, seed)
    if not PlayerManager.AnyoneHasCollectible(HagalazItem) then return end

    if type ~= EntityType.ENTITY_FIREPLACE then return end

    local newVariant = FIREPLACE_VARIANTS_TO_SAFE_VARIANTS[variant]
    if newVariant then
        return {
            type,
            newVariant,
            subtype,
            seed
        }
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_PRE_ENTITY_SPAWN,
    HagalazEssence.PreEntitySpawn
)