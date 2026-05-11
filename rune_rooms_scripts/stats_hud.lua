local HudStat = {}

local HudSprite = Sprite("gfx/ui/hudstats2.anm2", true)
HudSprite.Color = Color(1, 1, 1, 0.5)
HudSprite:SetFrame("Idle", 8)
local font = Font()
font:Load("font/luaminioutlined.fnt")

local coords = Vector(0, 170)
local fontalpha = 0
local previousChance

--- Some code is from Planetarum Chance mod

local function TextAcceleration(frame) --Overfit distance profile for difference text slide in
	frame = frame - 14
	if frame > 0 then
		return 0
	end
	return -(15.1 / (13 * 13)) * frame * frame
end

local function OnlyBlueBabies()
	local count = TSIL.Utils.Tables.Count(PlayerManager.GetPlayers(), function(_, player)
		return player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B
	end)
end

function HudStat:LoadNewGame(isContunue)
	previousChance = nil
end
RuneRooms:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, HudStat.LoadNewGame)

local function UpdatePos()
	coords = Vector(0, 170)

	local shifts = 0
	local hasDuality = PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_DUALITY)

	for _, pType in ipairs({PlayerType.PLAYER_BETHANY, PlayerType.PLAYER_BETHANY_B, PlayerType.PLAYER_BLUEBABY_B}) do
		if PlayerManager.AnyoneIsPlayerType(pType) then
			shifts = shifts + 1
		end
	end
	
	if shifts > 0 then
		coords = coords + Vector(0, (11 * shifts) - 2)
	end

	if Game():GetHUD():GetPlayerHUD(0):GetLayout() == PlayerHUDLayout.JACOB_AND_ESAU then
		coords = coords + Vector(0, 30)
	end

	if hasDuality then
		coords = coords - Vector(0, 12)
	end

    if Game().Difficulty == Difficulty.DIFFICULTY_HARD or Game():AchievementUnlocksDisallowed() then
        coords = coords + Vector(0, 16)
    end

    if Options.StatHUDPlanetarium == true and Isaac.GetPersistentGameData():Unlocked(Achievement.PLANETARIUMS) then
        coords = coords + Vector(0, 12)
    end

    coords = coords + Options.HUDOffset * Vector(20, 12)
end

function HudStat:Render()
    if not RuneRooms:RoomsUnlocked() and not RuneRooms.Helpers:IsDebugEnabled()
	or Game():IsGreedMode() then
        return
    end

	UpdatePos()

    local currentChance = RuneRooms.API:GetRoomSpawnChance() * 100

	if not RuneRooms.API:CanSpawnRuneRoom() then
		currentChance = 0
	end

	if previousChance == nil then
		previousChance = currentChance
	end

	local textCoords = coords + Game().ScreenShakeOffset
	local valueOutput = string.format("%.1f%%", currentChance)

	font:DrawString(valueOutput, textCoords.X + 16, textCoords.Y + 1, KColor(1, 1, 1, 0.5), 0, true)
	HudSprite:Render(coords, Vector(0, 0), Vector(0, 0))

	--differential popup
	if fontalpha and fontalpha > 0 then
		local alpha = RuneRooms.Helpers:Clamp(fontalpha, 0, 0.5)
		
		local difference = currentChance - previousChance
		local differenceOutput = string.format("%.1f%%", difference)
		local slide = TextAcceleration((2.9 - fontalpha) / (2 * 0.01))
		if difference > 0 then --positive difference
			font:DrawString("+" .. differenceOutput, textCoords.X + 46 + slide, textCoords.Y + 1, KColor(0, 1, 0, alpha), 0, true)
		elseif difference < 0 then --negative difference
			font:DrawString(differenceOutput, textCoords.X + 46 + slide, textCoords.Y + 1, KColor(1, 0, 0, alpha), 0, true)
		end
		fontalpha = fontalpha - 0.01
		if fontalpha <= 0 then
			previousChance = currentChance
		end
	elseif previousChance ~= currentChance then
		fontalpha = 2.9
	end
end
RuneRooms:AddCallback(ModCallbacks.MC_HUD_RENDER, HudStat.Render)