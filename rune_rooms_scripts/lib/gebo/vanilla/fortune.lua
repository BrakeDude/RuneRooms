local LuckyFootChances = {
    [1] = {
        Explosion = 0.0175,
        Fortune = 0.65,
        Trinket = 0.10696,
        Card = 0.10696,
        CrystalBall = 0.01162,
    },
    [2] = {
        Explosion = 0.027,
        Fortune = 0.46,
        Trinket = 0.105,
        Card = 0.105,
        CrystalBall = 0.018,
    },
}

local function SpawnPrize(type, variant, subtype, pos, rng)
    local vel = Gebo.GetSpawnPickupVelocity(pos, rng, 1)
    Isaac.Spawn(type, variant, subtype, pos, vel, nil)
end

local function FortuneMachine(slot, player, uses, rng)
	if uses > 0 then
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
			sprite:Play("Prize", true)
		end
		if sprite:IsEventTriggered("Prize") then
			uses = uses - 1
			local chance = player:HasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT) and LuckyFootChances[2] or LuckyFootChances[1]
			if rng:RandomFloat() <= chance.Explosion then
				Isaac.Explode(slot.Position, nil, 0)
            end
			if rng:RandomFloat() <= chance.CrystalBall then
				Isaac.Explode(slot.Position, nil, 0)
				slot:Remove()
				local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_CRYSTAL_BALL, slot.Position, Vector.Zero, nil):ToPickup()
				item:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				item:GetSprite():SetOverlayFrame("Alternates",1)
                return true
            end
			if rng:RandomFloat() <= chance.Fortune then
                Game():ShowFortune()
			else
				SFXManager():Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false)
				if rng:RandomFloat() <= chance.Trinket then
					SpawnPrize(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, slot.Position, rng)
				elseif rng:RandomFloat() <= chance.Card then
					SpawnPrize(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, 0, slot.Position, rng)
				else
					SpawnPrize(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, slot.Position, rng)
				end
			end
		end
		if sprite:WasEventTriggered("Explosion") then
			Isaac.Explode(slot.Position, nil, 0)
		end
		if sprite:GetAnimation() == "Death" and sprite:GetFrame() == 5 then
			sprite:Play("Broken", true)
		end
		if sprite:IsFinished("Broken") then
			return true
		end
	end
	return uses
end

Gebo.AddMachineBeggar(3, FortuneMachine)