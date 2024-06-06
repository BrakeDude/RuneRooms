local AnsuzEssence = {}

local REVEAL_ROOM_CHANCE = 1
local FULL_DISPLAY_FLAGS = 5
local AnsuzItem = RuneRooms.Enums.Item.ANSUZ_ESSENCE


function AnsuzEssence:OnAnsuzPickup()
    local level = Game():GetLevel()

    level:ApplyCompassEffect(false)
    level:ApplyBlueMapEffect()
    level:ApplyMapEffect()

    level:UpdateVisibility()
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_PLAYER_COLLECTIBLE_ADDED,
    AnsuzEssence.OnAnsuzPickup,
    {
        nil,
        nil,
        AnsuzItem
    }
)


---@param player EntityPlayer
local function AnsuzNewLevelEffect(player)
    local level = Game():GetLevel()
    local rng = player:GetCollectibleRNG(AnsuzItem)

    local effect = rng:RandomInt(3)

    if effect == 0 then
        --Compass
        level:ApplyCompassEffect(false)
    elseif effect == 1 then
        --Blue map
        level:ApplyBlueMapEffect()
    elseif effect == 2 then
        --Treasure map
        level:ApplyMapEffect()
    end

    level:UpdateVisibility()
end


function AnsuzEssence:OnNewLevel()
    local players = TSIL.Players.GetPlayersByCollectible(AnsuzItem)

    TSIL.Utils.Tables.ForEach(players, function (_, player)
        AnsuzNewLevelEffect(player)
    end)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    AnsuzEssence.OnNewLevel
)


---@param npc EntityNPC
function AnsuzEssence:OnNPCDeath(npc)
    if not TSIL.Players.DoesAnyPlayerHasItem(AnsuzItem) then return end

    local rng = TSIL.RNG.NewRNG(npc.InitSeed)
    if rng:RandomFloat() >= REVEAL_ROOM_CHANCE then return end

    local notFullyVisibleRooms = {}

    for _, room in ipairs(MinimapAPI:GetLevel()) do
        ---@type integer
        local displayFlags = room:GetDisplayFlags()
        if displayFlags ~= FULL_DISPLAY_FLAGS then
            notFullyVisibleRooms[#notFullyVisibleRooms+1] = room
        end
    end

    if #notFullyVisibleRooms == 0 then return end

    local room = TSIL.Random.GetRandomElementsFromTable(notFullyVisibleRooms, 1, rng)[1]
    room.DisplayFlags = FULL_DISPLAY_FLAGS
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    AnsuzEssence.OnNPCDeath
)