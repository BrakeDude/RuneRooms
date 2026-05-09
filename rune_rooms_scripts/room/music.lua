local RuneRoomMusic = {}

function RuneRoomMusic:Play(id, volume, isFade)
    if RuneRooms.API:IsRuneRoom() then
        return {RuneRooms.Enums.Music.RUNE_ROOM, volume}
    end
end
RuneRooms:AddCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, RuneRoomMusic.Play)