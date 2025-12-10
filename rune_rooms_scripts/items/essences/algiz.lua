local AlgizEssence = {}

local SHIELD_DURATION = 30 * 3
local SOUL_HEART_CHANCE = 0.07

local AlgizItem = RuneRooms.Enums.Item.ALGIZ_ESSENCE

TSIL.SaveManager.AddPersistentVariable(
    RuneRooms,
    RuneRooms.Enums.SaveKey.HAS_PLAYER_TAKEN_DMG,
    {},
    TSIL.Enums.VariablePersistenceMode.RESET_ROOM
)

---@param player EntityPlayer
---@param firstTime boolean
function AlgizEssence:OnAlgizPickup(player, _, firstTime)
    if player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B and not firstTime then return end

    player:AddBoneHearts(1)
    player:AddHearts(2)
end
RuneRooms:AddCallback(
    TSIL.Enums.CustomCallback.POST_PLAYER_COLLECTIBLE_ADDED,
    AlgizEssence.OnAlgizPickup,
    {
        nil,
        nil,
        AlgizItem
    }
)


function AlgizEssence:OnNewRoom()
    local players = TSIL.Players.GetPlayersByCollectible(AlgizItem)

    TSIL.Utils.Tables.ForEach(players, function (_, player)
        RuneRooms:AddShieldInvincibility(player, SHIELD_DURATION)
    end)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    AlgizEssence.OnNewRoom
)


---@param player EntityPlayer
---@return boolean
local function HasPlayerTakenDamage(player)
    local playerIndex = TSIL.Players.GetPlayerIndex(player)
    local playersTakenDamage = TSIL.SaveManager.GetPersistentVariable(
        RuneRooms,
        RuneRooms.Enums.SaveKey.HAS_PLAYER_TAKEN_DMG
    )

    local hasTakenDamage = playersTakenDamage[playerIndex] ~= nil
    playersTakenDamage[playerIndex] = true

    return hasTakenDamage
end

local avoidRecursion = false

---@param entity Entity
---@param damageFlags DamageFlag
---@param source EntityRef
---@param countdown integer
function AlgizEssence:OnPlayerDamage(entity, _, damageFlags, source, countdown)
    if avoidRecursion then return end

    local player = entity:ToPlayer()

    if HasPlayerTakenDamage(player) then return end
    if not player:HasCollectible(AlgizItem) then return end

    avoidRecursion = true
    player:TakeDamage(1, damageFlags | DamageFlag.DAMAGE_NO_MODIFIERS, source, countdown)
    avoidRecursion = false

    return false
end
RuneRooms:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    AlgizEssence.OnPlayerDamage,
    EntityType.ENTITY_PLAYER
)


---@param npc EntityNPC
function AlgizEssence:OnNPCDeath(npc)
    if not npc:IsActiveEnemy(true) then return end
    if not PlayerManager.AnyoneHasCollectible(AlgizItem) then return end

    local rng = TSIL.RNG.NewRNG(npc.InitSeed)
    if rng:RandomFloat() >= SOUL_HEART_CHANCE then return end

    TSIL.EntitySpecific.SpawnPickup(
        PickupVariant.PICKUP_HEART,
        HeartSubType.HEART_SOUL,
        npc.Position
    )
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    AlgizEssence.OnNPCDeath
)