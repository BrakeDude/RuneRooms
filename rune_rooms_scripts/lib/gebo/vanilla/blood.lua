local function IsBloodBagUnlocked()
	local id = CollectibleType.COLLECTIBLE_BLOOD_BAG
	local itemConfig = Isaac.GetItemConfig()
	local configItem = itemConfig:GetCollectible(id)
	local hasAchievement = configItem.AchievementID >= 0

	if not hasAchievement then return true end

	-- Oh BOY here we FUCKING go (Credit to Wofsauge)
	local numItems = itemConfig:GetCollectibles().Size - 1
	local itempool = Game():GetItemPool()

	for i = 1, numItems do
		if ItemConfig.Config.IsValidCollectible(i) and i ~= id then
			itempool:AddRoomBlacklist(i)
		end
	end

	local foundItem = false
	for pool = ItemPoolType.POOL_TREASURE, ItemPoolType.POOL_ROTTEN_BEGGAR do
		for i = 1, 10 do
			local item = itempool:GetCollectible(pool, false)
			if item == id then
				foundItem = true
				break
			end
		end

		if foundItem then break end
	end

	itempool:ResetRoomBlacklist()
	return foundItem
end

local rewardCollectible = {
    [1] = CollectibleType.COLLECTIBLE_BLOOD_BAG,
    [2] = CollectibleType.COLLECTIBLE_IV_BAG
}

local function IsKeeper(player)
    return player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_KEEPER
end

local function SpawnPrize(type, variant, subtype, pos, rng)
    local vel = Gebo.GetSpawnPickupVelocity(pos, rng, 1)
    Isaac.Spawn(type, variant, subtype, pos, vel, nil)
end

local function BloodMachine(slot, player, uses, rng)
	if uses > 0 then
		local sprite = slot:GetSprite()
		
		if sprite:GetAnimation() == "Death" or sprite:GetAnimation() == "Broken" then
			return true
		end
		if sprite:IsPlaying("Idle") then
			sprite:Play("Initiate", true)
			SFXManager():Play(SoundEffect.SOUND_BLOODBANK_TOUCHED,1,0,false,1)
		end
		if sprite:IsFinished("Initiate") then
			sprite:Play("Wiggle", true)
		end
		if sprite:GetAnimation() == "Wiggle" and sprite:GetFrame() == 17 then
			sprite:Play("Prize", true)
		end
		if sprite:IsEventTriggered("Prize") then
			uses = uses - 1
			if rng:RandomFloat() <= 0.04 then
				Isaac.Explode(slot.Position, nil, 0)
                sprite:Play("Death", true)
            else
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 3, slot.Position, Vector.Zero, nil).DepthOffset = 5
                if rng:RandomFloat() <= 0.08 then
                    slot:Remove()
                    Isaac.Explode(slot.Position, nil, 0)
                    local reward = rewardCollectible[2]
                    if IsBloodBagUnlocked() then
                        reward = rewardCollectible[rng:RandomInt(6) % 2 + 1]
                    end
                    local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, reward, slot.Position, Vector.Zero, nil):ToPickup()
                    item:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    item:GetSprite():SetOverlayFrame("Alternates",2)
                    return true
                end
				SFXManager():Play(SoundEffect.SOUND_BLOODBANK_SPAWN, 1, 0, false)
                if IsKeeper(player) and rng:RandomFloat() <= 0.15 or not IsKeeper(player) then
                    if rng:RandomFloat() <= 0.02 then
                        SpawnPrize(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_CHILDS_HEART, slot.Position, rng)
                        Game():GetItemPool():RemoveTrinket(TrinketType.TRINKET_CHILDS_HEART)
                    else
                        if rng:RandomFloat() <= 0.2 and Game().Difficulty % 2 == 0 then
                            SpawnPrize(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, slot.Position, rng)
                        end
                        SpawnPrize(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, slot.Position, rng)
                    end
                end
            end
		end
        if sprite:IsFinished("Prize") then
            sprite:Play("Idle", true)
        end
		if sprite:GetAnimation() == "Death" and sprite:GetFrame() == 5 then
			sprite:Play("Broken", true)
		end
		if sprite:IsPlaying("Broken") then
			return true
		end
	end
	return uses
end

Gebo.AddMachineBeggar(2, BloodMachine, 4)