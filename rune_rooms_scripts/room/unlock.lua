local RuneRoomsUnlock = {}
local PersistentData = RuneRooms.PGD
local itemConfig = RuneRooms.ItemConfig

function RuneRooms:GetRunesUsedCount()
    return RuneRooms:RunSave().RunesUsedInRun
end

function RuneRooms:SetRunesUsedCount(value)
   RuneRooms:RunSave().RunesUsedInRun = value
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