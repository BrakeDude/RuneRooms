local HagalazPositive = {}

---@param gridEntity GridEntity
---@return boolean
local function CanBeDestroyed(gridEntity)
	return gridEntity:IsBreakableRock() or gridEntity:ToPoop() ~= nil or gridEntity:ToTNT() ~= nil
end

function HagalazPositive:OnNewRoom()
	if not RuneRooms:IsRuneBlessingActive(RuneRooms.Enums.RuneEffect.HAGALAZ) then
		return
	end

	local gridEntities = TSIL.GridEntities.GetGridEntities()
	local rocks = TSIL.Utils.Tables.Filter(gridEntities, function(_, gridEntity)
		return CanBeDestroyed(gridEntity)
	end)
	
    TSIL.Utils.Tables.ForEach(rocks, function(_, rock)
        rock:Destroy()
    end)

    local stoneEnemiesTypes = {EntityType.ENTITY_STONEY, EntityType.ENTITY_CONSTANT_STONE_SHOOTER, EntityType.ENTITY_STONEHEAD, EntityType.ENTITY_STONE_EYE}
    TSIL.Utils.Tables.ForEach(stoneEnemiesTypes, function(_, stoneType)
        for _, entity in ipairs(Isaac.FindByType(stoneType)) do
            if not entity:IsDead() then
                entity:Kill()
            end
        end
    end)
	
end
RuneRooms:AddCallback(TSIL.Enums.CustomCallback.POST_NEW_ROOM_REORDERED, HagalazPositive.OnNewRoom)
