local FehuPositive = {}

---This is just a random offset so other rngs using the game seed look different
---Completely useless but I had to
local RNG_OFFSET = 149
local MIDAS_TEAR_CHANCE = 0.1

---@param player EntityPlayer
---@return RNG
local function GetPositiveFehuRNG(player)
    local playerData = RuneRooms:RunSave(player)

    local rng = RNG()
    if not playerData.PositiveFehuRNGSeed then
        local startSeed = Game():GetSeeds():GetStartSeed()
        rng = TSIL.RNG.NewRNG(startSeed)
        for _ = 1, RNG_OFFSET do
            rng:Next()
        end
    else
        rng:SetSeed(playerData.PositiveFehuRNGSeed, 35)
    end

    return rng
end

local GOLDEN_COLOR = Color(0.9, 0.8, 0, 1, 0.8, 0.7, 0)

---@param player EntityPlayer
---@param params TearParams
function FehuPositive:TearMidas(player, params)
    if RuneRooms:IsRuneBlessingActive(RuneRooms.Enums.RuneEffect.FEHU) then
        local rng = GetPositiveFehuRNG(player)
        local playerData = RuneRooms:RunSave(player)
        local chance = rng:RandomFloat()
        playerData.PositiveFehuRNGSeed = rng:GetSeed()
        if chance < MIDAS_TEAR_CHANCE then
            params.TearFlags = params.TearFlags | TearFlags.TEAR_MIDAS
            params.TearColor = GOLDEN_COLOR
        end
    end
end
RuneRooms:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, FehuPositive.TearMidas)