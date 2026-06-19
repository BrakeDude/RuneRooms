local OthalaPositive = {}


---@param player EntityPlayer
local function AddRandomItemForRoom(player)
    local roomDesc = TSIL.Rooms.GetRoomDescriptor()
    local rng = TSIL.RNG.NewRNG(roomDesc.SpawnSeed)

    local history = player:GetHistory()
    local items = history:GetCollectiblesHistory()
    if #items == 0 then return end

    local randomItem = items[rng:RandomInt(1, #items)]
    local item = randomItem:GetItemID()

    player:SetInnateCollectibleCount(item, 1, "RUNE_ROOMS_OTHALA_BLESSING")
end


local function AddRandomItemToPlayers()
    local players = PlayerManager.GetPlayers()
    TSIL.Utils.Tables.ForEach(players, function (_, player)
        AddRandomItemForRoom(player)
    end)
end


function OthalaPositive:OnNewRoom()
    if not RuneRooms:IsRuneBlessingActive(RuneRooms.Enums.RuneEffect.OTHALA) then return end
    player:ClearInnateItemGroup("RUNE_ROOMS_OTHALA_BLESSING")
    AddRandomItemToPlayers()
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    OthalaPositive.OnNewRoom
)


function OthalaPositive:OnOthalaPositiveActivation()
    AddRandomItemToPlayers()
end
RuneRooms:AddCallback(
    RuneRooms.Enums.CustomCallback.POST_GAIN_RUNE_BLESSING,
    OthalaPositive.OnOthalaPositiveActivation,
    RuneRooms.Enums.RuneEffect.OTHALA
)