local AnsuzEssence = {}

local REVEAL_ROOM_CHANCE = 1
local FULL_DISPLAY_FLAGS = MinimapAPI and 5 or 7
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

local function GetDisplayFlags(room)
	local df = room.DisplayFlags or 0
	if room.Data.Type == RoomType.ROOM_ULTRASECRET and room.DisplayFlags == 0 then -- if red self is hidden and DFs not set
		if room.VisitedCount < 1 then
			df = 0
		end
	end
	return df
end

---@param npc EntityNPC
function AnsuzEssence:OnNPCDeath(npc)
    if not TSIL.Players.DoesAnyPlayerHasItem(AnsuzItem) then return end

    local rng = TSIL.RNG.NewRNG(npc.InitSeed)
    if rng:RandomFloat() >= REVEAL_ROOM_CHANCE then return end

    local notFullyVisibleRooms = {}
    if MinimapAPI then
        for _, room in ipairs(MinimapAPI:GetLevel()) do
            ---@type integer
            local displayFlags = room:GetDisplayFlags()
            if displayFlags ~= FULL_DISPLAY_FLAGS then
                notFullyVisibleRooms[#notFullyVisibleRooms+1] = room
            end
        end
    else
        local rooms = Game():GetLevel():GetRooms()
        for i = 0, rooms.Size-1 do
            local room = rooms:Get(i)
            if GetDisplayFlags(room) ~= FULL_DISPLAY_FLAGS then
                notFullyVisibleRooms[#notFullyVisibleRooms+1] = room
            end
        end
    end
    
    if #notFullyVisibleRooms == 0 then return end
    local room = TSIL.Random.GetRandomElementsFromTable(notFullyVisibleRooms, 1, rng)[1]
    print(room.DisplayFlags)
    room.DisplayFlags = FULL_DISPLAY_FLAGS
    if not MinimapAPI then
        Game():GetLevel():UpdateVisibility()
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    AnsuzEssence.OnNPCDeath
)