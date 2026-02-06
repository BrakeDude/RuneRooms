local PositiveAlgiz = {}


function PositiveAlgiz:OnNewRoom()
    if not RuneRooms:IsRuneBlessingActive(RuneRooms.Enums.RuneEffect.ALGIZ) then return end
    if not Game():GetRoom():IsFirstVisit() then return end

    local players = PlayerManager.GetPlayers()

    for _, player in ipairs(players) do
        player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true, 150, true)
    end
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_NEW_ROOM_REORDERED,
    PositiveAlgiz.OnNewRoom
)