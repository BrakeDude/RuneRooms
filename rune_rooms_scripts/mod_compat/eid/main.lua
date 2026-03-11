local Descriptions = RuneRooms.Constants.Descriptions
local runeSprites = Sprite("gfx/ui/eid_rune_icon.anm2",true)

---@param runeEffect RuneEffect
local function GetPositiveRuneEffectDescription(runeEffect)
    local language = EID:getLanguage()
    local runeEffectDesc = Descriptions.PositiveRuneEffect[runeEffect][language]

    if not runeEffectDesc then
        runeEffectDesc = Descriptions.PositiveRuneEffect[runeEffect].en_us
    end

    return runeEffectDesc
end


---@param runeEffect RuneEffect
local function GetNegativeRuneEffectDescription(runeEffect)
    local language = EID:getLanguage()
    local runeEffectDesc = Descriptions.NegativeRuneEffect[runeEffect][language]

    if not runeEffectDesc then
        runeEffectDesc = Descriptions.NegativeRuneEffect[runeEffect].en_us
    end

    return runeEffectDesc
end

---@param giantCrystal Entity
local function SpawnNegativeEffectDescriptionHolder(giantCrystal)
    local runeEffect = RuneRooms:GetRuneEffectForFloor()

    local runeEffectDesc = GetNegativeRuneEffectDescription(runeEffect)
    if not runeEffectDesc then return end

    local eidHolder = TSIL.EntitySpecific.SpawnEffect(
        RuneRooms.Enums.EffectVariant.EID_DESCRIPTION_HOLDER,
        0,
        giantCrystal.Position
    )

    eidHolder:GetData().EID_Description = {
        Name = runeEffectDesc.name,
        Description = runeEffectDesc.description
    }
end


RuneRooms:AddModCompat("EID", function ()
    EID.effectList[tostring(RuneRooms.Enums.EffectVariant.EID_DESCRIPTION_HOLDER)] = true

    -- Collectibles
    for collectible, translations in pairs(Descriptions.Collectibles) do
        for language, description in pairs(translations) do
            EID:addCollectible(collectible, description.description, description.name, language)
        end
    end

    -- Runes
    for rune, translations in pairs(Descriptions.Runes) do
        for language, description in pairs(translations) do
            EID:addCard(rune, description.description, description.name, language)
        end
        EID:addIcon("Card"..rune, "Runes", 0, 12, 12, 0, 0, runeSprites)
        EID:AddIconToObject(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, rune, "Card"..rune)
    end

    --[[RuneRooms:AddCallback(
        RuneRooms.Enums.CustomCallback.POST_GENERIC_PROP_INIT,
        function (_, giantCrystal)
            if RuneRooms:IsGiantRuneCrystalBroken(giantCrystal) then
                SpawnNegativeEffectDescriptionHolder(giantCrystal)
            else
                local runeEffect = RuneRooms:GetRuneEffectForFloor()

                local runeEffectDesc = GetPositiveRuneEffectDescription(runeEffect)
                if not runeEffectDesc then return end

                giantCrystal:GetData().EID_Description = {
                    Name = runeEffectDesc.name,
                    Description = runeEffectDesc.description
                }
            end
        end,
        RuneRooms.Enums.GenericPropVariant.GIANT_RUNE_CRYSTAL
    )

    RuneRooms:AddCallback(
        RuneRooms.Enums.CustomCallback.POST_GIANT_RUNE_CRYSTAL_DESTROYED,
        function (_, giantCrystal)
            SpawnNegativeEffectDescriptionHolder(giantCrystal)
        end
    )]]
end)