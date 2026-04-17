local AlgizEssence = {}

local SHIELD_DURATION = 30 * 3
local SOUL_HEART_CHANCE = 0.07

local AlgizItem = RuneRooms.Enums.Item.ALGIZ_ESSENCE

---@param collectible CollectibleType | integer
---@param firstTime boolean
---@param player EntityPlayer
function AlgizEssence:OnAlgizPickup(collectible, _, firstTime, _, _, player)
    if not firstTime then return end

    player:AddBoneHearts(1)
    player:AddHearts(2)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_ADD_COLLECTIBLE,
    AlgizEssence.OnAlgizPickup,
    AlgizItem
)


function AlgizEssence:OnNewRoom()
    local players = TSIL.Players.GetPlayersByCollectible(AlgizItem)

    TSIL.Utils.Tables.ForEach(players, function (_, player)
        if not Game():GetRoom():IsClear() then
            player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true, SHIELD_DURATION, true)
        end
    end)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    AlgizEssence.OnNewRoom
)


---@param player EntityPlayer
---@return boolean
local function HasPlayerTakenDamage(player)
    local playerData = RuneRooms:TempSave(player)

    local hasTakenDamage = playerData.hasTakenDamage ~= nil
    playerData.hasTakenDamage = true

    return hasTakenDamage
end

---@param entity Entity
---@param damageFlags DamageFlag
---@param source EntityRef
---@param countdown integer
function AlgizEssence:OnPlayerDamage(entity, _, damageFlags, source, countdown)

    local player = entity:ToPlayer() ---@cast player EntityPlayer

    if HasPlayerTakenDamage(player) then return end
    if not player:HasCollectible(AlgizItem) then return end

    return {
                Damage = 1,
                DamageFlags = damageFlags | DamageFlag.DAMAGE_NO_MODIFIERS,
                DamageCountdown = countdown
            }

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

    local heart = TSIL.EntitySpecific.SpawnPickup(
        PickupVariant.PICKUP_HEART,
        HeartSubType.HEART_HALF_SOUL,
        npc.Position
    )
    heart.Timeout = 60
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    AlgizEssence.OnNPCDeath
)