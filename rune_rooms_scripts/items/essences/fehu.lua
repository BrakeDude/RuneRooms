local FehuEssence = {}

local MIDAS_TEAR_CHANCE = 0.05
local MIDAS_TEAR_CHANCE_PER_LUCK = 0.05
local MAX_MIDAS_TEAR_CHANCE = 0.20
local PENNY_REPLACE_CHANCE = 0.25
---@type {chance: number, value: CoinSubType}[]
local POSSIBLE_COINS = {
    {chance = 50, value = CoinSubType.COIN_DOUBLEPACK},
    {chance = 30, value = CoinSubType.COIN_NICKEL},
    {chance = 10, value = CoinSubType.COIN_DIME},
    {chance = 5, value = CoinSubType.COIN_LUCKYPENNY}
}
local FehuItem = RuneRooms.Enums.Item.FEHU_ESSENCE


---Adds a coin subtype Essence of Fehu might reroll other coins into.
---
---For reference, these are the vanilla coins:
---```lua
---{chance = 50, value = CoinSubType.COIN_DOUBLEPACK},
---{chance = 30, value = CoinSubType.COIN_NICKEL},
---{chance = 10, value = CoinSubType.COIN_DIME},
---{chance = 5,  value = CoinSubType.COIN_LUCKYPENNY}
---```
---@param coinSubType CoinSubType | integer
---@param chance number
function RuneRooms.API:AddCoinSubtypeToReroll(coinSubType, chance)
    POSSIBLE_COINS[#POSSIBLE_COINS+1] = {chance = chance, value = coinSubType}
end

---@param tear EntityTear
function FehuEssence:OnTearInit(tear)
    local player = TSIL.Players.GetPlayerFromEntity(tear)
    if not player then return end
    if not player:HasCollectible(FehuItem) then return end

    local rng = player:GetCollectibleRNG(FehuItem)
    local chance = MIDAS_TEAR_CHANCE + player.Luck * MIDAS_TEAR_CHANCE_PER_LUCK
    chance = math.max(MAX_MIDAS_TEAR_CHANCE, chance)
    if rng:RandomFloat() >= chance then return end

    RuneRooms:AddCustomTearFlag(tear, RuneRooms.Enums.TearFlag.MIDAS)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_TEAR_INIT,
    FehuEssence.OnTearInit
)


---@param type EntityType
---@param variant integer
---@param subtype integer
---@param seed any
function FehuEssence:PreEntitySpawn(type, variant, subtype, _, _, _, seed)
    if not PlayerManager.AnyoneHasCollectible(FehuItem) then return end

    if type ~= EntityType.ENTITY_PICKUP then return end
    if variant ~= PickupVariant.PICKUP_COIN then return end
    if subtype ~= CoinSubType.COIN_PENNY then return end

    local rng = TSIL.RNG.NewRNG(seed)
    if rng:RandomFloat() >= PENNY_REPLACE_CHANCE then return end

    local outcome = WeightedOutcomePicker()
    for _, coin in ipairs(POSSIBLE_COINS) do
        outcome:AddOutcomeWeight(coin.value, coin.chance)
    end
    local newSubtype = outcome:PickOutcome(rng)
    return {type, variant, newSubtype, rng:Next()}
end
RuneRooms:AddCallback(
    ModCallbacks.MC_PRE_ENTITY_SPAWN,
    FehuEssence.PreEntitySpawn
)