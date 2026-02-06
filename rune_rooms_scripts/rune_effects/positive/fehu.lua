local FehuPositive = {}

---This is just a random offset so other rngs using the game seed look different
---Completely useless but I had to
local RNG_OFFSET = 149
local MIDAS_TEAR_CHANCE = 0.1

TSIL.SaveManager.AddPersistentVariable(
    RuneRooms,
    RuneRooms.Enums.SaveKey.POSITIVE_FEHU_RNG_PER_PLAYER,
    {},
    TSIL.Enums.VariablePersistenceMode.RESET_RUN
)


---@param player EntityPlayer
---@return RNG
local function GetPositiveFehuRNG(player)
    local rngPerPlayer = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.POSITIVE_FEHU_RNG_PER_PLAYER
    )
    local playerIndex = TSIL.Players.GetPlayerIndex(player)

    local rng = rngPerPlayer[playerIndex]
    if not rng then
        local startSeed = Game():GetSeeds():GetStartSeed()
        rng = TSIL.RNG.NewRNG(startSeed)
        for _ = 1, RNG_OFFSET do
            rng:Next()
        end
        rngPerPlayer[playerIndex] = rng
    end

    return rng
end


---@param tear EntityTear
function FehuPositive:OnTearInit(tear)
    if not RuneRooms:IsRuneBlessingActive(RuneRooms.Enums.RuneEffect.FEHU) then return end

    local player = TSIL.Players.GetPlayerFromEntity(tear)
    if not player then return end

    local rng = GetPositiveFehuRNG(player)
    if rng:RandomFloat() >= MIDAS_TEAR_CHANCE then return end

    RuneRooms:AddCustomTearFlag(tear, RuneRooms.Enums.TearFlag.MIDAS)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_TEAR_INIT,
    FehuPositive.OnTearInit
)