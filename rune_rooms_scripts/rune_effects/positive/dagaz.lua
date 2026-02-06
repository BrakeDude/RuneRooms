local DagazPositive = {}


---@param npc EntityNPC
function DagazPositive:OnNPCInit(npc)
    if not RuneRooms:IsRuneBlessingActive(RuneRooms.Enums.RuneEffect.DAGAZ) then return end

    if npc:IsChampion() then
        local newNPC = TSIL.Entities.Spawn(
            npc.Type,
            npc.Variant,
            npc.SubType,
            npc.Position,
            npc.Velocity,
            npc.SpawnerEntity
        )
        newNPC.Parent = npc.Parent
        --This shouldn't be necessary but just in case
        for key, value in pairs(npc:GetData()) do
            newNPC:GetData()[key] = value
        end
        npc:Remove()
    end
end
RuneRooms:AddPriorityCallback(
    ModCallbacks.MC_POST_NPC_INIT,
    CallbackPriority.IMPORTANT,
    DagazPositive.OnNPCInit
)