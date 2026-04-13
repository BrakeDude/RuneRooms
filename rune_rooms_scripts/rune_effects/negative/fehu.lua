local FehuNegative = {}

---This is just a random offset so other rngs using the game seed look different
---Completely useless but I had to
local RNG_OFFSET = 573
local LOST_COINS_CHANCE = 0.3
local MIN_COINS_LOST = 1
local MAX_COINS_LOST = 3

---@param player EntityPlayer
---@return RNG
local function GetNegativeFehuRNG(player)
    local playerData = RuneRooms:RunSave(player)

    local rng = RNG()
    if not playerData.NegativeFehuRNGSeed then
        local startSeed = Game():GetSeeds():GetStartSeed()
        rng = TSIL.RNG.NewRNG(startSeed)
        for _ = 1, RNG_OFFSET do
            rng:Next()
        end
    else
        rng:SetSeed(playerData.NegativeFehuRNGSeed, 35)
    end

    return rng
end


---@param entity Entity
function FehuNegative:OnPlayerDamage(entity)
    if not RuneRooms:IsRuneCurseActive(RuneRooms.Enums.RuneEffect.FEHU) then return end

    local player = entity:ToPlayer()
    if not player then return end

    local rng = GetNegativeFehuRNG(player)
    local chance = rng:RandomFloat()
    local playerData = RuneRooms:RunSave(player)
    playerData.NegativeFehuRNGSeed = rng:GetSeed()
    if chance >= LOST_COINS_CHANCE then return end

    local coinsLost = TSIL.Random.GetRandomInt(MIN_COINS_LOST, MAX_COINS_LOST, rng)
    playerData.NegativeFehuRNGSeed = rng:GetSeed()
    player:AddCoins(-coinsLost)

    SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    FehuNegative.OnPlayerDamage,
    EntityType.ENTITY_PLAYER
)