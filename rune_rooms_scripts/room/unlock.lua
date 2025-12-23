local RuneRoomsUnlock = {}
local PersistentData = Isaac.GetPersistentGameData()
local game = Game()
local itemConfig = Isaac.GetItemConfig()

TSIL.SaveManager.AddPersistentVariable(
	RuneRooms,
	RuneRooms.Enums.SaveKey.COUNT_RUNES_USED_IN_RUN,
	0,
	TSIL.Enums.VariablePersistenceMode.RESET_RUN
)

function RuneRooms:GetRunesUsedCount()
    return TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
	    RuneRooms.Enums.SaveKey.COUNT_RUNES_USED_IN_RUN
    )
end

function RuneRooms:SetRunesUsedCount(value)
    return TSIL.SaveManager.SetPersistentVariable(
        RuneRooms,
	    RuneRooms.Enums.SaveKey.COUNT_RUNES_USED_IN_RUN,
        value
    )
end

---@return boolean
function RuneRooms:RoomsUnlocked()
	return PersistentData:Unlocked(RuneRooms.Enums.Achievement.RUNE_ROOMS)
end

---@return boolean
function RuneRooms:UnlockRooms()
	return PersistentData:TryUnlock(RuneRooms.Enums.Achievement.RUNE_ROOMS)
end

---@param card Card | integer
---@param player EntityPlayer
---@param flags UseFlag | integer
function RuneRoomsUnlock:UseRune(card, player, flags)
    if not RuneRooms:RoomsUnlocked() then
        local config = itemConfig:GetCard(card)
        if config and config:IsRune() then
            local currentUses = RuneRooms:GetRunesUsedCount()
            local add = card == Card.RUNE_SHARD and 0.5 or 1
            local totalUses = currentUses + add
            if totalUses >= 30 then
                RuneRooms:UnlockRooms()
            end
            RuneRooms:SetRunesUsedCount(totalUses)
        end
    end
end
RuneRooms:AddCallback(ModCallbacks.MC_USE_CARD, RuneRoomsUnlock.UseRune)