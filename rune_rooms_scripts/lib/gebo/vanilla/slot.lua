local SlotChances = {
    [1] = {
        [1] = {
            Explosion = 0.02,
            Nothing = 0.54,
            Bomb = 0.047,
            Key = 0.031,
            Heart = 0.091,
            Pill = 0.047,
            Coin = 0.114,
            TwoCoins = 0.057,
            Dollar = 0.0047,
            BlackFly = 0.031,
            PrettyFly = 0.0156,
        },
        [2] = {
            Explosion = 0.02,
            Nothing = 0.374,
            Bomb = 0.065,
            Key = 0.044,
            Heart = 0.131,
            Pill = 0.065,
            Coin = 0.16,
            TwoCoins = 0.08,
            Dollar = 0.0065,
            BlackFly = 0.044,
            PrettyFly = 0.0218,
        },
    },
    [2] = {
        [1] = {
            Explosion = 0.02,
            Nothing = 0.76,
            Bomb = 0.023,
            Key = 0.016,
            Heart = 0.047,
            Pill = 0.023,
            Coin = 0.057,
            TwoCoins = 0.029,
            Dollar = 0.0023,
            BlackFly = 0.016,
            PrettyFly = 0.0078,
        },
        [2] = {
            Explosion = 0.02,
            Nothing = 0.672,
            Bomb = 0.033,
            Key = 0.022,
            Heart = 0.065,
            Pill = 0.033,
            Coin = 0.08,
            TwoCoins = 0.04,
            Dollar = 0.0033,
            BlackFly = 0.022,
            PrettyFly = 0.0109,
        },
    },
}

local function SpawnPrize(type, variant, subtype, pos, rng)
    local vel = Gebo.GetSpawnPickupVelocity(pos, rng, 1)
    Isaac.Spawn(type, variant, subtype, pos, vel, nil)
end

local function SlotMachine(slot, player, uses, rng)
	if uses > 0 then
        local diff = Game().Difficulty % 2 + 1
        local lucky = player:HasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT) and 2 or 1
        local chance = SlotChances[diff][lucky]
		local sprite = slot:GetSprite()
		if sprite:GetAnimation() == "Death" or sprite:GetAnimation() == "Broken" then
			return true
		end
		if sprite:IsPlaying("Idle") or sprite:IsFinished("Prize") then
			sprite:Play("Initiate", true)
            SFXManager():Play(SoundEffect.SOUND_COIN_SLOT,1,0,false,1)
		end
		if sprite:IsFinished("Initiate") then
			sprite:Play("Wiggle", true)
		end
		if sprite:GetAnimation() == "Wiggle" and sprite:GetFrame() == 17 then
			sprite:Play("WiggleEnd", true)
		end
        if sprite:IsFinished("WiggleEnd") then
			sprite:Play("Prize", true)
            sprite:SetFrame(3)
		end
		if sprite:WasEventTriggered("Prize") then
			uses = uses - 1
            sprite:Stop()
            sprite:SetLayerFrame(1, rng:RandomInt(7))
            sprite:SetLayerFrame(2, rng:RandomInt(7))
            sprite:SetLayerFrame(3, rng:RandomInt(7))
			if rng:RandomFloat() <= chance.Explosion then
				Isaac.Explode(slot.Position, nil, 0)
                sprite:Play("Death", true)
            end
			if rng:RandomFloat() <= chance.Dollar then
                sprite:SetLayerFrame(1, 1)
                sprite:SetLayerFrame(2, 1)
                sprite:SetLayerFrame(3, 1)
                Isaac.Explode(slot.Position, nil, 0)
				slot:Remove()
				local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_DOLLAR, slot.Position, Vector.Zero, nil):ToPickup()
				item:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				item:GetSprite():SetOverlayFrame("Alternates",3)
                return true
            end
			if rng:RandomFloat() > chance.Nothing then
                if rng:RandomFloat() <= chance.BlackFly then
                    SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN, 1, 0, false)
                    Isaac.Spawn(EntityType.ENTITY_FLY, 0, 0, slot.Position, Vector.Zero, nil)
                    sprite:SetLayerFrame(1, 0)
                    sprite:SetLayerFrame(2, 0)
                    sprite:SetLayerFrame(3, 0)
                else
                    if rng:RandomFloat() <= chance.PrettyFly then
                        player:UsePill(PillEffect.PILLEFFECT_PRETTY_FLY, PillColor.PILL_NULL, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
                        sprite:SetLayerFrame(1, 0)
                        sprite:SetLayerFrame(2, 0)
                        sprite:SetLayerFrame(3, 0)
                    else
                        SFXManager():Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false)
                        if rng:RandomFloat() <= chance.Bomb then
                            SpawnPrize(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 0, slot.Position, rng)
                            sprite:SetLayerFrame(1, 2)
                            sprite:SetLayerFrame(2, 2)
                            sprite:SetLayerFrame(3, 2)
                        elseif rng:RandomFloat() <= chance.Key then
                            SpawnPrize(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 0, slot.Position, rng)
                            sprite:SetLayerFrame(1, 4)
                            sprite:SetLayerFrame(2, 4)
                            sprite:SetLayerFrame(3, 4)
                        elseif rng:RandomFloat() <= chance.Heart then
                            SpawnPrize(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 0, slot.Position, rng)
                            sprite:SetLayerFrame(1, 6)
                            sprite:SetLayerFrame(2, 6)
                            sprite:SetLayerFrame(3, 6)
                        elseif rng:RandomFloat() <= chance.Pill then
                            SpawnPrize(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, slot.Position, rng)
                            sprite:SetLayerFrame(1, 5)
                            sprite:SetLayerFrame(2, 5)
                            sprite:SetLayerFrame(3, 5)
                        else
                            if rng:RandomFloat() <= chance.TwoCoins then
                                SpawnPrize(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, slot.Position, rng)
                            end
                            SpawnPrize(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, slot.Position, rng)
                            sprite:SetLayerFrame(1, 3)
                            sprite:SetLayerFrame(2, 3)
                            sprite:SetLayerFrame(3, 3)
                        end
                    end
                end
			else
                SFXManager():Play(SoundEffect.SOUND_SCAMPER, 1, 0, false)
            end
            sprite:Update()
		end
		if sprite:WasEventTriggered("Explosion") then
			Isaac.Explode(slot.Position, nil, 0)
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

Gebo.AddMachineBeggar(1, SlotMachine)