-- TanSatService.lua - Server Tàn Sát Management
-- Copy vào ServerScriptService/TanSatService (Script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TanSatModule = require(ReplicatedStorage.Modules.TanSat.TanSatModule)

local TanSatService = {}

-- ========================================
-- TRACK KILL
-- ========================================

function TanSatService.TrackKill(player, enemyType, enemyLevel)
	-- Get player data
	local playerData = TanSatService.GetPlayerData(player)
	if not playerData then
		warn("Player data not found for", player.Name)
		return
	end

	-- Initialize SatKhi if not exists
	if not playerData.SatKhi then
		playerData.SatKhi = {
			TotalKills = 0,
			LastKillTime = 0
		}
	end

	-- Get previous tier
	local oldTier = TanSatModule.GetCurrentTier(playerData.SatKhi.TotalKills)

	-- Increment kill count
	playerData.SatKhi.TotalKills = playerData.SatKhi.TotalKills + 1
	playerData.SatKhi.LastKillTime = os.time()

	-- Get new tier
	local newTier = TanSatModule.GetCurrentTier(playerData.SatKhi.TotalKills)

	-- Check if tier upgraded
	if newTier.Name ~= oldTier.Name then
		TanSatService.OnTierUpgrade(player, newTier)
	end

	-- Add linh hồn to Hồn Phiên (if Ma Đạo)
	if playerData.CultivationType == "MaDao" then
		local linhHonValue, linhHonData = TanSatModule.GetLinhHonValue(enemyType, enemyLevel)
		TanSatService.AddLinhHon(player, linhHonValue, linhHonData)
	end

	-- Sync to client
	TanSatService.SyncSatKhi(player)

	-- Check for hunters spawn
	if TanSatModule.ShouldSpawnHunters(playerData.SatKhi.TotalKills) then
		TanSatService.SpawnHunters(player)
	end
end

-- ========================================
-- ON TIER UPGRADE
-- ========================================

function TanSatService.OnTierUpgrade(player, newTier)
	-- Announce to player
	local message = "🔥 Tàn Sát Tier Up! → " .. newTier.Name

	if newTier.Penalty then
		message = message .. "\n⚠️ Warning: Now hunted by NPCs!"
	end

	TanSatService.NotifyPlayer(player, message)

	-- Check penalties
	if newTier.Penalty and newTier.Penalty.CityBanned then
		TanSatService.NotifyPlayer(player, "⛔ You are now banned from entering cities!")
	end

	if newTier.Penalty and newTier.Penalty.Bounty then
		TanSatService.NotifyPlayer(player, "💰 Bounty placed on your head: " .. newTier.Penalty.Bounty .. " Tiên Ngọc")
	end

	print("Player", player.Name, "reached Tàn Sát tier:", newTier.Name)
end

-- ========================================
-- ADD LINH HỒN
-- ========================================

function TanSatService.AddLinhHon(player, amount, linhHonData)
	local playerData = TanSatService.GetPlayerData(player)
	if not playerData or not playerData.HonPhien then
		return
	end

	-- Add to Hồn Phiên
	playerData.HonPhien.Souls = (playerData.HonPhien.Souls or 0) + amount

	-- Cap at capacity
	local capacity = playerData.HonPhien.Capacity or 10
	if playerData.HonPhien.Souls > capacity then
		playerData.HonPhien.Souls = capacity
	end

	-- Notify
	local message = "+" .. amount .. " " .. linhHonData.Name
	TanSatService.ShowLinhHonGain(player, message, linhHonData.Color)
end

-- ========================================
-- SHOW LINH HỒN GAIN
-- ========================================

function TanSatService.ShowLinhHonGain(player, message, color)
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("ShowLinhHonGain")

	if remoteEvent then
		remoteEvent:FireClient(player, message, color)
	end
end

-- ========================================
-- SPAWN HUNTERS
-- ========================================

function TanSatService.SpawnHunters(player)
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local playerData = TanSatService.GetPlayerData(player)
	if not playerData or not playerData.SatKhi then
		return
	end

	local difficulty = TanSatModule.GetHunterDifficulty(playerData.SatKhi.TotalKills)
	local hunterCount = 1

	if difficulty == "Hard" then
		hunterCount = 3
	elseif difficulty == "Extreme" then
		hunterCount = 5
	end

	-- Notify player
	TanSatService.NotifyPlayer(player, "⚔️ NPC Hunters are after you! (" .. hunterCount .. " hunters)")

	-- TODO: Actually spawn hunter NPCs
	-- This would integrate with EnemyService
	print("Spawning", hunterCount, "hunters for", player.Name)
end

-- ========================================
-- GET PLAYER DATA
-- ========================================

function TanSatService.GetPlayerData(player)
	local PlayerDataService = script.Parent:FindFirstChild("PlayerDataService")
	if PlayerDataService then
		local module = require(PlayerDataService)
		return module.GetPlayerData and module.GetPlayerData(player)
	end
	return nil
end

-- ========================================
-- SYNC SÁT KHÍ TO CLIENT
-- ========================================

function TanSatService.SyncSatKhi(player)
	local playerData = TanSatService.GetPlayerData(player)
	if not playerData or not playerData.SatKhi then
		return
	end

	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("SyncSatKhi")

	if remoteEvent then
		local tier = TanSatModule.GetCurrentTier(playerData.SatKhi.TotalKills)
		local progress = TanSatModule.GetTierProgress(playerData.SatKhi.TotalKills)

		remoteEvent:FireClient(player, {
			TotalKills = playerData.SatKhi.TotalKills,
			CurrentTier = tier,
			Progress = progress,
			Bonus = TanSatModule.CalculateSoulDamageBonus(playerData.SatKhi.TotalKills)
		})
	end
end

-- ========================================
-- NOTIFY PLAYER
-- ========================================

function TanSatService.NotifyPlayer(player, message)
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("TanSatNotification")

	if remoteEvent then
		remoteEvent:FireClient(player, message)
	end
end

-- ========================================
-- SETUP REMOTE EVENTS
-- ========================================

function TanSatService.SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if not remoteEvents then
		remoteEvents = Instance.new("Folder")
		remoteEvents.Name = "RemoteEvents"
		remoteEvents.Parent = ReplicatedStorage
	end

	-- Get Sát Khí
	local getSatKhi = remoteEvents:FindFirstChild("GetSatKhi")
	if not getSatKhi then
		getSatKhi = Instance.new("RemoteEvent")
		getSatKhi.Name = "GetSatKhi"
		getSatKhi.Parent = remoteEvents
	end

	getSatKhi.OnServerEvent:Connect(function(player)
		TanSatService.SyncSatKhi(player)
	end)

	-- Sync Sát Khí
	if not remoteEvents:FindFirstChild("SyncSatKhi") then
		local sync = Instance.new("RemoteEvent")
		sync.Name = "SyncSatKhi"
		sync.Parent = remoteEvents
	end

	-- Tàn Sát Notification
	if not remoteEvents:FindFirstChild("TanSatNotification") then
		local notif = Instance.new("RemoteEvent")
		notif.Name = "TanSatNotification"
		notif.Parent = remoteEvents
	end

	-- Show Linh Hồn Gain
	if not remoteEvents:FindFirstChild("ShowLinhHonGain") then
		local show = Instance.new("RemoteEvent")
		show.Name = "ShowLinhHonGain"
		show.Parent = remoteEvents
	end
end

-- ========================================
-- PLAYER JOIN
-- ========================================

function TanSatService.OnPlayerJoin(player)
	-- Initialize Sát Khí
	local playerData = TanSatService.GetPlayerData(player)
	if playerData and not playerData.SatKhi then
		playerData.SatKhi = {
			TotalKills = 0,
			LastKillTime = 0
		}
	end

	-- Sync to client
	task.wait(3)
	TanSatService.SyncSatKhi(player)
end

-- ========================================
-- INITIALIZE
-- ========================================

function TanSatService.Initialize()
	print("🔥 TanSatService initializing...")

	-- Setup remote events
	TanSatService.SetupRemoteEvents()

	-- Connect player events
	game.Players.PlayerAdded:Connect(TanSatService.OnPlayerJoin)

	-- Handle existing players
	for _, player in ipairs(game.Players:GetPlayers()) do
		task.spawn(function()
			TanSatService.OnPlayerJoin(player)
		end)
	end

	print("✅ TanSatService ready!")
end

-- Auto-initialize
TanSatService.Initialize()

-- Export
return {
	TrackKill = TanSatService.TrackKill,
	GetPlayerData = TanSatService.GetPlayerData,
	SyncSatKhi = TanSatService.SyncSatKhi
}
