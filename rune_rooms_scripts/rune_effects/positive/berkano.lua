local BerkanoPositive = {}


---@param npc EntityNPC
function BerkanoPositive:OnNPCDeath(npc)
    if not RuneRooms:IsRuneBlessingActive(RuneRooms.Enums.RuneEffect.BERKANO) then return end

    local players = TSIL.Players.GetPlayers()
    local rng = TSIL.RNG.NewRNG(npc.InitSeed)

    TSIL.Utils.Tables.ForEach(players, function (_, player)
        if rng:RandomFloat() > 0.5 then
            player:AddBlueFlies(1, npc.Position, npc)
        else
            player:AddBlueSpider(npc.Position)
        end
    end)
end
RuneRooms:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    BerkanoPositive.OnNPCDeath
)