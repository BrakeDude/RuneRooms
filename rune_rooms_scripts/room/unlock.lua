local RuneRoomsUnlock = {}
local PersitentData = Isaac.GetPersistentGameData()
local game = Game()
local itemConfig = Isaac.GetItemConfig()

TSIL.SaveManager.AddPersistentVariable(
	RuneRooms,
	RuneRooms.Enums.SaveKey.COUNT_RUNES_USED_IN_RUN,
	0,
	TSIL.Enums.VariablePersistenceMode.RESET_RUN
)

function RuneRoomsUnlock:SecretRoomEnter()
    local room = game:GetRoom()
    if room:IsFirstVisit() and room:GetType() == RoomType.ROOM_SUPERSECRET then
        RuneRooms.Helpers:AddRuneRoomsSpawnChance(0.1)
        if not RuneRooms.Helpers:RoomsUnlocked() and RuneRooms.Helpers:GetRuneRoomSpawnChance() >= 1 then
            RuneRooms.Helpers:UnlockRooms()
        end
    end
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, RuneRoomsUnlock.SecretRoomEnter)

---@param card Card | integer
---@param player EntityPlayer
---@param flags UseFlag | integer
function RuneRoomsUnlock:UseRune(card, player, flags)
    if RuneRooms.Helpers:RoomsUnlocked() then
        local config = itemConfig:GetCard(card)
        if config and config:IsRune() then
            
        end
    end
end
RuneRooms:AddCallback(ModCallbacks.MC_USE_CARD, RuneRoomsUnlock.UseRune)