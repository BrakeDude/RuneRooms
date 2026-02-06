local PerthroPositive = {}


TSIL.SaveManager.AddPersistentVariable(
    RuneRooms,
    RuneRooms.Enums.SaveKey.ROOMS_USED_ISAACS_SOUL,
    {},
    TSIL.Enums.VariablePersistenceMode.RESET_LEVEL
)


function PerthroPositive:OnNewRoom()
    if not RuneRooms:IsRuneBlessingActive(RuneRooms.Enums.RuneEffect.PERTHRO) then return end

    local roomDesc = TSIL.Rooms.GetRoomDescriptor()
    local roomIndex = roomDesc.ListIndex
    local roomsUsedIsaacsSoul = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.ROOMS_USED_ISAACS_SOUL
    )

    if roomsUsedIsaacsSoul[roomIndex] then return end
    roomsUsedIsaacsSoul[roomIndex] = true
    local player = Isaac.GetPlayer(0)
    player:UseCard(Card.CARD_SOUL_ISAAC, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    PerthroPositive.OnNewRoom
)