local Music = {}


function Music:OnNewRoom()
    if not RuneRooms.Helpers:IsRuneRoom() then return end

    RuneRooms.Helpers:RunInNRenderFrames(function ()
        MusicManager():Play(RuneRooms.Enums.Music.RUNE_ROOM, Options.MusicVolume)
        MusicManager():UpdateVolume()
    end, 2, "RUNE_ROOM_MUSIC")
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    Music.OnNewRoom
)