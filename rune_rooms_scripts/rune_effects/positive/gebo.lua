local GeboPositive = {}

local SLOT_SPAWN_CHANCE = 0.4
local POSSIBLE_SLOTS = {
    SlotVariant.SLOT_MACHINE,
	SlotVariant.BLOOD_DONATION_MACHINE,
	SlotVariant.FORTUNE_TELLING_MACHINE,
	SlotVariant.BEGGAR,
	SlotVariant.DEVIL_BEGGAR,
	SlotVariant.SHELL_GAME,
	SlotVariant.KEY_MASTER,
	SlotVariant.DONATION_MACHINE,
	SlotVariant.BOMB_BUM,
	SlotVariant.SHOP_RESTOCK_MACHINE,
	SlotVariant.GREED_DONATION_MACHINE,
	SlotVariant.MOMS_DRESSING_TABLE,
	SlotVariant.BATTERY_BUM,
	SlotVariant.HELL_GAME,
	SlotVariant.CRANE_GAME,
	SlotVariant.CONFESSIONAL,
	SlotVariant.ROTTEN_BEGGAR,
}

local ACHIEVEMENT_PER_SLOT = {
    [SlotVariant.HELL_GAME] = Achievement.HELL_GAME,
	[SlotVariant.CRANE_GAME] = Achievement.CRANE_GAME,
	[SlotVariant.CONFESSIONAL] = Achievement.CONFESSIONAL,
	[SlotVariant.ROTTEN_BEGGAR] = Achievement.ROTTEN_BEGGAR,
}
---@type table<SlotVariant, fun(): boolean>
local CAN_SPAWN_PER_SLOT = {}


---Adds a slot that may spawn with the positive Gebo rune room effect
---@param slotVariant SlotVariant | integer
---@param canSpawn fun(): boolean @ Default: Can always spawn
function RuneRooms.API:AddPossibleSlotToSpawn(slotVariant, canSpawn)
    POSSIBLE_SLOTS[#POSSIBLE_SLOTS+1] = slotVariant
    CAN_SPAWN_PER_SLOT[slotVariant] = canSpawn
end


TSIL.SaveManager.AddPersistentVariable(
    RuneRooms,
    RuneRooms.Enums.SaveKey.ROOMS_SPAWNED_SLOT,
    {},
    TSIL.Enums.VariablePersistenceMode.RESET_LEVEL
)


function GeboPositive:OnNewRoom()
    if not RuneRooms:IsRuneBlessingActive(RuneRooms.Enums.RuneEffect.GEBO) then return end

    local roomDesc = TSIL.Rooms.GetRoomDescriptor()
    local roomData = roomDesc.Data

    if roomData.Type ~= RoomType.ROOM_DEFAULT then return end

    local roomIndex = roomDesc.ListIndex
    local roomsSpawnedSlot = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.ROOMS_SPAWNED_SLOT
    )

    if roomsSpawnedSlot[roomIndex] then return end
    roomsSpawnedSlot[roomIndex] = true

    local rng = TSIL.RNG.NewRNG(roomDesc.SpawnSeed)

    if rng:RandomFloat() >= SLOT_SPAWN_CHANCE then return end

    local slotsToSpawn = TSIL.Utils.Tables.Filter(POSSIBLE_SLOTS, function (_, slotVariant)
        local achievement = ACHIEVEMENT_PER_SLOT[slotVariant]
        if not achievement then
            local canSpawn = CAN_SPAWN_PER_SLOT[slotVariant]
            if not canSpawn then
                return true
            end

            return canSpawn()
        end

        return RuneRooms.PGD:Unlocked(achievement)
    end)
    local slotVariant = TSIL.Random.GetRandomElementsFromTable(slotsToSpawn, 1, rng)[1]

    local room = RuneRooms.Room()
    local centerPos = room:GetCenterPos()
    local freePos = room:FindFreePickupSpawnPosition(centerPos, 0, true)

    TSIL.Entities.Spawn(
        EntityType.ENTITY_SLOT,
        slotVariant,
        0,
        freePos
    )
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    GeboPositive.OnNewRoom
)