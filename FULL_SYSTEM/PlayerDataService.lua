-- PlayerDataService.lua - Quản Lý Dữ Liệu Player (Server)
-- Copy vào ServerScriptService/Services/PlayerDataService (Script)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Wait for modules
local PlayerDataTemplate = require(ReplicatedStorage.Modules.PlayerData.PlayerDataTemplate)
local RealmCalculator = require(ReplicatedStorage.Modules.Stats.RealmCalculator)
local CultivationModule = require(ReplicatedStorage.Modules.Cultivation.CultivationModule)

-- RemoteEvents folder
local RemoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not RemoteEventsFolder then
	RemoteEventsFolder = Instance.new("Folder")
	RemoteEventsFolder.Name = "RemoteEvents"
	RemoteEventsFolder.Parent = ReplicatedStorage
end

-- Create RemoteEvents
local function CreateRemoteEvent(name)
	local existing = RemoteEventsFolder:FindFirstChild(name)
	if existing then
		return existing
	end

	local event = Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = RemoteEventsFolder
	return event
end

local LevelUpEvent = CreateRemoteEvent("LevelUp")
local BreakthroughEvent = CreateRemoteEvent("Breakthrough")
local StartMeditationEvent = CreateRemoteEvent("StartMeditation")
local UseSkillEvent = CreateRemoteEvent("UseSkill")
local DamageEnemyEvent = CreateRemoteEvent("DamageEnemy")
local ShowDamageEvent = CreateRemoteEvent("ShowDamage")

-- ========================================
-- DATA STORAGE
-- ========================================

local PlayerDataService = {}
PlayerDataService.PlayerDataCache = {} -- {[UserId] = PlayerData}

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

function PlayerDataService.GetPlayerData(player)
	return PlayerDataService.PlayerDataCache[player.UserId]
end

function PlayerDataService.SavePlayerData(player)
	local playerData = PlayerDataService.GetPlayerData(player)
	if not playerData then return end

	-- Convert to JSON and store in player
	local success, err = pcall(function()
		local json = HttpService:JSONEncode(playerData)
		local dataValue = player:FindFirstChild("PlayerData")
		if dataValue then
			dataValue.Value = json
		end
	end)

	if not success then
		warn("Failed to save player data:", err)
	end
end

function PlayerDataService.UpdatePlayerStats(player)
	local playerData = PlayerDataService.GetPlayerData(player)
	if not playerData then return end

	-- Recalculate stats
	playerData.Stats = RealmCalculator.CalculateStats(playerData)

	-- Save
	PlayerDataService.SavePlayerData(player)
end

-- ========================================
-- PLAYER JOIN/LEAVE
-- ========================================

Players.PlayerAdded:Connect(function(player)
	print("👤", player.Name, "joined!")

	-- TODO: Load from DataStore
	-- For now, create new data
	local cultivationType = "TienThien" -- Default, should let player choose

	-- Create player data
	local playerData = PlayerDataTemplate.CreateNew(cultivationType)
	playerData.UserId = player.UserId
	playerData.DisplayName = player.Name

	-- Calculate initial stats
	playerData.Stats = RealmCalculator.CalculateStats(playerData)

	-- Give some starting pills for testing
	playerData.DanDuoc.TuKhiDan = 500
	playerData.DanDuoc.TieuHoanDan = 100
	playerData.DanDuoc.TienNgoc = 1000
	playerData.TuViPoints = 1000 -- Starting Tu Vi

	-- Store in cache
	PlayerDataService.PlayerDataCache[player.UserId] = playerData

	-- Create StringValue to sync to client
	local dataValue = Instance.new("StringValue")
	dataValue.Name = "PlayerData"
	dataValue.Value = HttpService:JSONEncode(playerData)
	dataValue.Parent = player

	-- Setup character
	player.CharacterAdded:Connect(function(character)
		wait(1)
		PlayerDataService.SetupCharacter(player, character)
	end)

	print("✅", player.Name, "data loaded!")
end)

Players.PlayerRemoving:Connect(function(player)
	-- TODO: Save to DataStore
	PlayerDataService.PlayerDataCache[player.UserId] = nil
	print("👋", player.Name, "left!")
end)

-- ========================================
-- CHARACTER SETUP
-- ========================================

function PlayerDataService.SetupCharacter(player, character)
	local playerData = PlayerDataService.GetPlayerData(player)
	if not playerData then return end

	local humanoid = character:WaitForChild("Humanoid")
	local hrp = character:WaitForChild("HumanoidRootPart")

	-- Set health from stats
	humanoid.MaxHealth = playerData.Stats.MaxHP
	humanoid.Health = playerData.Stats.HP

	-- Set walk speed from stats
	humanoid.WalkSpeed = playerData.Stats.Speed

	print("✅", player.Name, "character setup complete!")
end

-- ========================================
-- LEVEL UP
-- ========================================

LevelUpEvent.OnServerEvent:Connect(function(player)
	local playerData = PlayerDataService.GetPlayerData(player)
	if not playerData then return end

	local success, message = CultivationModule.LevelUp(playerData)

	if success then
		print("⬆️", player.Name, "leveled up:", message)

		-- Update stats
		PlayerDataService.UpdatePlayerStats(player)

		-- Update character health
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			local humanoid = player.Character.Humanoid
			humanoid.MaxHealth = playerData.Stats.MaxHP
			humanoid.Health = playerData.Stats.HP
		end
	else
		warn("❌", player.Name, "level up failed:", message)
	end
end)

-- ========================================
-- BREAKTHROUGH
-- ========================================

BreakthroughEvent.OnServerEvent:Connect(function(player)
	local playerData = PlayerDataService.GetPlayerData(player)
	if not playerData then return end

	local success, message = CultivationModule.Breakthrough(playerData)

	if success then
		print("⭐", player.Name, "breakthrough:", message)

		-- Update stats
		PlayerDataService.UpdatePlayerStats(player)

		-- Update character
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			local humanoid = player.Character.Humanoid
			humanoid.MaxHealth = playerData.Stats.MaxHP
			humanoid.Health = playerData.Stats.HP
		end

		-- TODO: Spawn Thiên Kiếp Boss battle
	else
		warn("❌", player.Name, "breakthrough failed:", message)
	end
end)

-- ========================================
-- MEDITATION
-- ========================================

local meditatingPlayers = {} -- {[UserId] = true}

StartMeditationEvent.OnServerEvent:Connect(function(player)
	local playerData = PlayerDataService.GetPlayerData(player)
	if not playerData then return end

	if meditatingPlayers[player.UserId] then
		-- Stop meditation
		meditatingPlayers[player.UserId] = nil
		print("🧘", player.Name, "stopped meditating")
	else
		-- Start meditation
		meditatingPlayers[player.UserId] = true
		print("🧘", player.Name, "started meditating")
	end
end)

-- Meditation loop (give Tu Vi Points every minute)
spawn(function()
	while true do
		wait(60) -- Every minute

		for userId, _ in pairs(meditatingPlayers) do
			local player = Players:GetPlayerByUserId(userId)
			if player then
				local playerData = PlayerDataService.GetPlayerData(player)
				if playerData then
					local tuViGain = RealmCalculator.GetTuViPerMinute(playerData)
					CultivationModule.AddTuViPoints(playerData, tuViGain)
					PlayerDataService.SavePlayerData(player)
					print("🧘", player.Name, "gained", tuViGain, "Tu Vi")
				end
			end
		end
	end
end)

print("✅ PlayerDataService loaded!")
return PlayerDataService
