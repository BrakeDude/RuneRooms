local GeboEssence = {}

--TODO: Attacks for the other slots

local MAX_FREE_USES = 5
local COIN_SLOTS = {
    [TSIL.Enums.SlotVariant.SLOT_MACHINE] = true,
    [TSIL.Enums.SlotVariant.FORTUNE_TELLING_MACHINE] = true,
    [TSIL.Enums.SlotVariant.SHELL_GAME] = true,
    [TSIL.Enums.SlotVariant.BEGGAR] = true,
    [TSIL.Enums.SlotVariant.DONATION_MACHINE] = true,
    [TSIL.Enums.SlotVariant.RESTOCK_MACHINE] = true,
    [TSIL.Enums.SlotVariant.GREED_DONATION_MACHINE] = true,
    [TSIL.Enums.SlotVariant.BATTERY_BEGGAR] = true,
    [TSIL.Enums.SlotVariant.ROTTEN_BEGGAR] = true,
}
local KEY_SLOTS = {
    [TSIL.Enums.SlotVariant.KEY_BEGGAR] = true
}
local BOMB_SLOTS = {
    [TSIL.Enums.SlotVariant.BOMB_BEGGAR] = true
}
local NICKEL_SLOTS = {
    [TSIL.Enums.SlotVariant.CRANE_GAME] = true
}
local BEGGARS = {
    TSIL.Enums.SlotVariant.BEGGAR,
    TSIL.Enums.SlotVariant.DEVIL_BEGGAR,
    TSIL.Enums.SlotVariant.SHELL_GAME,
    TSIL.Enums.SlotVariant.KEY_BEGGAR,
    TSIL.Enums.SlotVariant.BOMB_BEGGAR,
    TSIL.Enums.SlotVariant.BATTERY_BEGGAR,
    TSIL.Enums.SlotVariant.HELL_GAME,
    TSIL.Enums.SlotVariant.ROTTEN_BEGGAR,
}
local BEGGAR_ATTACK = {
    Interval = 35,
    IntervalOffset = 6,
    Chance = 0.7,
    Damage = 4,
    Scale = 0.75,
    MinSpeed = 9,
    MaxSpeed = 11,
    MinFallingSpeed = -10,
    MaxFallingSpeed = -5,
    FallingAccel = 1.1
}
local SLOT_ATTACK = {
    Interval = 20,
    IntervalOffset = 5,
    Damage = 2,
    MinSpeed = 14,
    MaxSpeed = 17,
    FallingAccel = 0.3
}
local BLOOD_DONATION_ATTACK = {
    Interval = 4,
    IntervalOffset = 2,
    Damage = 2,
    MinSpeed = 3,
    MaxSpeed = 6,
    MinFallingSpeed = -20,
    MaxFallingSpeed = -15,
    FallingAccel = 1.5,
    MinScale = 0.8,
    MaxScale = 1.2
}
local FORTUNE_MACHINE_ATTACK = {
    Interval = 10,
    IntervalOffset = 4,
}
local GeboItem = RuneRooms.Enums.Item.GEBO_ESSENCE

TSIL.SaveManager.AddPersistentVariable(
    RuneRooms,
    RuneRooms.Enums.SaveKey.FREE_SLOT_USES_PER_PLAYER,
    {},
    TSIL.Enums.VariablePersistenceMode.RESET_RUN
)


---Returns the number of free slot uses a player has.
---@param player EntityPlayer
---@return integer
function RuneRooms:GetGeboEssenceSlotFreeUses(player)
    local playerIndex = TSIL.Players.GetPlayerIndex(player)
    local freeSlotUsesPerPlayer = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.FREE_SLOT_USES_PER_PLAYER
    )

    local freeSlotUses = freeSlotUsesPerPlayer[playerIndex]

    if not freeSlotUses then
        return 0
    else
        return freeSlotUses
    end
end


---Decreases the number of free slot uses a player has.
---@param player EntityPlayer
function RuneRooms:DecreaseGeboEssenceSlotFreeUses(player)
    local playerIndex = TSIL.Players.GetPlayerIndex(player)
    local freeSlotUsesPerPlayer = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.FREE_SLOT_USES_PER_PLAYER
    )

    local freeSlotUses = freeSlotUsesPerPlayer[playerIndex]

    if not freeSlotUses or freeSlotUses == 0 then return end

    freeSlotUsesPerPlayer[playerIndex] = freeSlotUses - 1
end


function GeboEssence:OnNewLevel()
    local players = TSIL.Players.GetPlayersByCollectible(GeboItem)
    local freeSlotUsesPerPlayer = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.FREE_SLOT_USES_PER_PLAYER
    )

    TSIL.Utils.Tables.ForEach(players, function (_, player)
        local playerIndex = TSIL.Players.GetPlayerIndex(player)
        freeSlotUsesPerPlayer[playerIndex] = MAX_FREE_USES
    end)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    GeboEssence.OnNewLevel
)


function GeboEssence:OnGeboEssencePickup(player)
    local freeSlotUsesPerPlayer = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.FREE_SLOT_USES_PER_PLAYER
    )

    local playerIndex = TSIL.Players.GetPlayerIndex(player)
    freeSlotUsesPerPlayer[playerIndex] = MAX_FREE_USES
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_PLAYER_COLLECTIBLE_ADDED,
    GeboEssence.OnGeboEssencePickup
)


---@param entity Entity
---@param source EntityRef
function GeboEssence:OnPlayerDamage(entity, _, _, source)
    local player = entity:ToPlayer()
    if not player:HasCollectible(GeboItem) then return end
    if RuneRooms:GetGeboEssenceSlotFreeUses(player) == 0 then return end

    if source.Type == EntityType.ENTITY_SLOT
    and (
        source.Variant == TSIL.Enums.SlotVariant.BLOOD_DONATION_MACHINE
        or source.Variant == TSIL.Enums.SlotVariant.DEVIL_BEGGAR
        or source.Variant == TSIL.Enums.SlotVariant.CONFESSIONAL
        or source.Variant == TSIL.Enums.SlotVariant.HELL_GAME
    ) then
        RuneRooms:DecreaseGeboEssenceSlotFreeUses(player)
        player:SetMinDamageCooldown(30)
        return false
    end
end
RuneRooms:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    GeboEssence.OnPlayerDamage,
    EntityType.ENTITY_PLAYER
)


---@param slot Entity
local function CanUseSlot(slot)
    local sprite = slot:GetSprite()
    if sprite:IsPlaying("Idle") then
        return true
    end

    local isFinished
    if slot.Variant == TSIL.Enums.SlotVariant.DONATION_MACHINE
    or slot.Variant == TSIL.Enums.SlotVariant.GREED_DONATION_MACHINE then
        isFinished = sprite:IsOverlayFinished()
    else
        isFinished = sprite:IsFinished()
    end

    if (
        sprite:GetAnimation() == "Prize"
        or sprite:GetAnimation() == "PayNothing"
    ) and isFinished then
        return true
    end

    return false
end


---@param slot Entity
---@param player EntityPlayer
function GeboEssence:PreSlotCollision(slot, player)
    if not CanUseSlot(slot) then return end

    if not player:HasCollectible(GeboItem) then return end
    if RuneRooms:GetGeboEssenceSlotFreeUses(player) == 0 then return end

    if COIN_SLOTS[slot.Variant] then
        if player:GetNumCoins() < 1 then return end
        player:AddCoins(1)
        RuneRooms:DecreaseGeboEssenceSlotFreeUses(player)
    elseif KEY_SLOTS[slot.Variant] then
        if player:GetNumKeys() < 1 then return end
        player:AddKeys(1)
        RuneRooms:DecreaseGeboEssenceSlotFreeUses(player)
    elseif BOMB_SLOTS[slot.Variant] then
        if player:GetNumBombs() < 1 then return end
        player:AddBombs(1)
        RuneRooms:DecreaseGeboEssenceSlotFreeUses(player)
    elseif NICKEL_SLOTS[slot.Variant] then
        if player:GetNumCoins() < 5 then return end
        player:AddCoins(5)
        RuneRooms:DecreaseGeboEssenceSlotFreeUses(player)
    end
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.PRE_SLOT_COLLISION,
    GeboEssence.PreSlotCollision
)


---@param slot Entity
---@param attackInterval integer
---@param maxIntervalOffset integer
---@return boolean
local function CanSlotAttack(slot, attackInterval, maxIntervalOffset)
    if not PlayerManager.AnyoneHasCollectible(GeboItem) then
        return false
    end

    local room = Game():GetRoom()
    if room:IsClear() then
        return false
    end

    local initRNG = TSIL.RNG.NewRNG(slot.InitSeed)
    local frameOffset = initRNG:RandomInt(attackInterval)
    local intervalOffset = initRNG:RandomInt(maxIntervalOffset)
    if (slot.FrameCount + frameOffset) % (attackInterval + intervalOffset) ~= 0 then
        return false
    end

    return CanUseSlot(slot)
end


---@param position Vector
---@return EntityNPC?
local function GetClosestEnemy(position)
    local npcs = TSIL.EntitySpecific.GetNPCs()

    if #npcs == 0 then return end

    npcs = TSIL.Utils.Tables.Filter(npcs, function (_, npc)
        return npc:IsActiveEnemy(true) and npc:IsVulnerableEnemy() and not npc:IsInvincible()
        and not npc:HasEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_FRIENDLY_BALL)
    end)

    if #npcs == 0 then return end

    table.sort(npcs, function (a, b)
        return a.Position:DistanceSquared(position) < b.Position:DistanceSquared(position)
    end)

    return npcs[1]
end


---@param slot Entity
function GeboEssence:OnBeggarUpdate(slot)
    if not CanSlotAttack(slot, BEGGAR_ATTACK.Interval, BEGGAR_ATTACK.IntervalOffset) then return end

    local target = GetClosestEnemy(slot.Position)
    if not target then return end

    local rng = slot:GetDropRNG()
    if rng:RandomFloat() >= BEGGAR_ATTACK.Chance then return end

    local speed = TSIL.Random.GetRandomFloat(BEGGAR_ATTACK.MinSpeed, BEGGAR_ATTACK.MaxSpeed, rng)
    local spawningVel = (target.Position - slot.Position):Resized(speed)

    local tear = TSIL.EntitySpecific.SpawnTear(
        TearVariant.ROCK,
        0,
        slot.Position,
        spawningVel,
        slot
    )
    tear.FallingSpeed = TSIL.Random.GetRandomFloat(BEGGAR_ATTACK.MinFallingSpeed, BEGGAR_ATTACK.MaxFallingSpeed, rng)
    tear.FallingAcceleration = BEGGAR_ATTACK.FallingAccel
    tear.CollisionDamage = BEGGAR_ATTACK.Damage
    tear.Scale = BEGGAR_ATTACK.Scale

    SFXManager():Play(SoundEffect.SOUND_SHELLGAME)
end
for _, beggarVariant in ipairs(BEGGARS) do
    RuneRooms:AddCallback(
        TSIL.Enums.CustomCallback.POST_SLOT_UPDATE,
        GeboEssence.OnBeggarUpdate,
        beggarVariant
    )
end


---@param slot Entity
function GeboEssence:OnSlotMachineUpdate(slot)
    if not CanSlotAttack(slot, SLOT_ATTACK.Interval, SLOT_ATTACK.IntervalOffset) then return end

    local rng = slot:GetDropRNG()
    local attackDir = Vector.FromAngle(rng:RandomInt(360))

    local target = GetClosestEnemy(slot.Position)
    if target then
        attackDir = (target.Position - slot.Position):Normalized()
    end

    local speed = TSIL.Random.GetRandomFloat(SLOT_ATTACK.MinSpeed, SLOT_ATTACK.MaxSpeed, rng)
    local spawningVel = attackDir:Resized(speed)

    local tear = TSIL.EntitySpecific.SpawnTear(
        TearVariant.COIN,
        0,
        slot.Position,
        spawningVel,
        slot
    )

    tear.CollisionDamage = SLOT_ATTACK.Damage
    tear.FallingAcceleration = SLOT_ATTACK.FallingAccel
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_SLOT_UPDATE,
    GeboEssence.OnSlotMachineUpdate,
    TSIL.Enums.SlotVariant.SLOT_MACHINE
)


---@param slot Entity
function GeboEssence:OnBloodDonationMachineUpdate(slot)
    if not CanSlotAttack(slot, BLOOD_DONATION_ATTACK.Interval, BLOOD_DONATION_ATTACK.IntervalOffset) then return end

    local rng = slot:GetDropRNG()

    local angle = rng:RandomInt(360)
    local speed = TSIL.Random.GetRandomFloat(BLOOD_DONATION_ATTACK.MinSpeed, BLOOD_DONATION_ATTACK.MaxSpeed, rng)
    local spawningVel = Vector.FromAngle(angle):Resized(speed)

    local tear = TSIL.EntitySpecific.SpawnTear(
        TearVariant.BLOOD,
        0,
        slot.Position,
        spawningVel,
        slot
    )

    tear.CollisionDamage = BLOOD_DONATION_ATTACK.Damage
    tear.FallingSpeed = TSIL.Random.GetRandomFloat(
        BLOOD_DONATION_ATTACK.MinFallingSpeed,
        BLOOD_DONATION_ATTACK.MaxFallingSpeed,
        rng
    )
    tear.FallingAcceleration = BLOOD_DONATION_ATTACK.FallingAccel
    tear.Scale = TSIL.Random.GetRandomFloat(
        BLOOD_DONATION_ATTACK.MinScale,
        BLOOD_DONATION_ATTACK.MaxScale,
        rng
    )
    RuneRooms:AddCustomTearFlag(tear, RuneRooms.Enums.TearFlag.BLOOD_CREEP)
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_SLOT_UPDATE,
    GeboEssence.OnBloodDonationMachineUpdate,
    TSIL.Enums.SlotVariant.BLOOD_DONATION_MACHINE
)


---@param slot Entity
function GeboEssence:OnFortuneTellingMachineUpdate(slot)
    if not CanSlotAttack(slot, FORTUNE_MACHINE_ATTACK.Interval, FORTUNE_MACHINE_ATTACK.IntervalOffset) then return end

    local rng = slot:GetDropRNG()
    local spawnPos = RuneRooms.Helpers:GetRandomPositionInRoom(false, true, rng)

    TSIL.EntitySpecific.SpawnEffect(
        EffectVariant.CRACK_THE_SKY,
        0,
        spawnPos,
        Vector.Zero,
        Isaac.GetPlayer()   --IDK if this makes it scale with the player's damage or does some constant damage
    )
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_SLOT_UPDATE,
    GeboEssence.OnFortuneTellingMachineUpdate,
    TSIL.Enums.SlotVariant.FORTUNE_TELLING_MACHINE
)