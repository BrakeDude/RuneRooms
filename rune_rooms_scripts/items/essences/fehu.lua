local FehuEssence = {}

local MIDAS_TEAR_CHANCE = 0.05
local MIDAS_TEAR_CHANCE_PER_LUCK = 0.05
local MAX_MIDAS_TEAR_CHANCE = 0.20
local FehuItem = RuneRooms.Enums.Item.FEHU_ESSENCE

local GOLDEN_COLOR = Color(0.9, 0.8, 0, 1, 0.8, 0.7, 0)

---@param player EntityPlayer
---@param params TearParams
function FehuEssence:TearMidas(player, params)
    if player:HasCollectible(FehuItem) then
        local rng = player:GetCollectibleRNG(FehuItem)
        local chance = MIDAS_TEAR_CHANCE + RuneRooms.Helpers:GetTrueLuck(player) * MIDAS_TEAR_CHANCE_PER_LUCK
        chance = math.max(MAX_MIDAS_TEAR_CHANCE, chance)
        if rng:RandomFloat() < chance then 
            params.TearFlags = params.TearFlags | TearFlags.TEAR_MIDAS
            params.TearColor = GOLDEN_COLOR
        end
    end
end
RuneRooms:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, FehuEssence.TearMidas)