local game = Game()
RuneRooms.Game = game
RuneRooms.Level = game:GetLevel()
RuneRooms.SFX = SFXManager()
RuneRooms.PGD = Isaac.GetPersistentGameData()
RuneRooms.ItemConfig = Isaac.GetItemConfig()
RuneRooms.ItemPool = game:GetItemPool()
RuneRooms.HUD = game:GetHUD()

RuneRooms.Room = function()
    return game:GetRoom()
end