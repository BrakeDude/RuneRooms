local AnsuzPositive = {}
local game = RuneRooms.Game

function AnsuzPositive:ReveilMapAndGenerateSecretRooms()
	if not RuneRooms:IsRuneBlessingActive(RuneRooms.Enums.RuneEffect.ANSUZ) then
		return
	end

	local level = RuneRooms.Level

	level:ApplyMapEffect()
	level:ApplyCompassEffect(true)
	level:ApplyBlueMapEffect()

	if game:IsGreedMode() or game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH) then
		return
	end

	local seed = level:GetDungeonPlacementSeed()
	local stb = Isaac.GetCurrentStageConfigId()
	local rng = RNG(seed)
	local roomconfsecret = RoomConfig.GetRandomRoom(seed, false, stb, RoomType.ROOM_SECRET, RoomShape.ROOMSHAPE_1x1)
	local roomconfsupersecret =
		RoomConfig.GetRandomRoom(seed, false, stb, RoomType.ROOM_SUPERSECRET, RoomShape.ROOMSHAPE_1x1)
	local optionssecret = level:FindValidRoomPlacementLocations(roomconfsecret, -1)
	local optionssupersecret = level:FindValidRoomPlacementLocations(roomconfsupersecret, -1)
	local room
	repeat
		local option = optionssecret[rng:RandomInt(1, #optionssecret)]
		room = level:TryPlaceRoom(roomconfsecret, option, -1, seed, false, false)
	until #optionssecret == 0 or room ~= nil
    repeat
		local option = optionssecret[rng:RandomInt(1, #optionssupersecret)]
		room = level:TryPlaceRoom(roomconfsecret, option, -1, seed, false, false)
	until #optionssupersecret == 0 or room ~= nil
end
RuneRooms:AddCallback(
	RuneRooms.Enums.CustomCallback.POST_GAIN_RUNE_BLESSING,
	AnsuzPositive.ReveilMapAndGenerateSecretRooms
)
