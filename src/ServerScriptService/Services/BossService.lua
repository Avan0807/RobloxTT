-- BossService.lua - Server Boss Management
-- Copy vào ServerScriptService/BossService (Script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BossModule = require(ReplicatedStorage.Modules.Boss.BossModule)

local BossService = {}
BossService.ActiveBosses = {} -- {bossModel = bossData}
BossService.RespawnTimers = {} -- {bossID = respawnTime}

-- ========================================
-- SPAWN BOSS
-- ========================================

function BossService.SpawnBoss(bossID, position)
	local bossData = BossModule.GetBoss(bossID)
	if not bossData then
		warn("Boss not found:", bossID)
		return nil
	end

	-- Create boss model
	local bossModel = BossService.CreateBossModel(bossData, position)
	if not bossModel then
		warn("Failed to create boss model")
		return nil
	end

	-- Setup boss
	bossModel:SetAttribute("BossID", bossID)
	bossModel:SetAttribute("CurrentHP", bossData.Stats.HP)
	bossModel:SetAttribute("MaxHP", bossData.Stats.HP)
	bossModel:SetAttribute("CurrentPhase", 0)
	bossModel.Parent = workspace

	-- Store boss data
	BossService.ActiveBosses[bossModel] = {
		BossID = bossID,
		Data = bossData,
		SpawnTime = os.time(),
		LastAbilityTime = {}
	}

	-- Start AI
	BossService.StartBossAI(bossModel)

	-- Announce if world boss
	if bossData.IsWorldBoss then
		BossService.AnnounceWorldBoss(bossData.Name)
	end

	print("✅ Boss spawned:", bossData.Name)
	return bossModel
end

-- ========================================
-- CREATE BOSS MODEL
-- ========================================

function BossService.CreateBossModel(bossData, position)
	-- Create model
	local model = Instance.new("Model")
	model.Name = bossData.Name

	-- Create main part
	local mainPart = Instance.new("Part")
	mainPart.Name = "HumanoidRootPart"
	mainPart.Size = bossData.Size
	mainPart.Position = position
	mainPart.Anchored = false
	mainPart.Color = bossData.Color
	mainPart.Material = Enum.Material.Neon
	mainPart.Parent = model

	-- Create humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = bossData.Stats.HP
	humanoid.Health = bossData.Stats.HP
	humanoid.WalkSpeed = bossData.Stats.Speed
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.Parent = model

	-- Visual effects
	local highlight = Instance.new("Highlight")
	highlight.FillColor = bossData.Color
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.5
	highlight.Parent = model

	-- Name tag
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 300, 0, 100)
	billboard.StudsOffset = Vector3.new(0, bossData.Size.Y/2 + 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = mainPart

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = "👑 " .. bossData.Name .. " 👑"
	nameLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.Parent = billboard

	-- Health bar
	local healthBarBG = Instance.new("Frame")
	healthBarBG.Size = UDim2.new(0.9, 0, 0.15, 0)
	healthBarBG.Position = UDim2.new(0.05, 0, 0.5, 0)
	healthBarBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	healthBarBG.BorderSizePixel = 0
	healthBarBG.Parent = billboard

	local healthBarFill = Instance.new("Frame")
	healthBarFill.Name = "HealthBar"
	healthBarFill.Size = UDim2.new(1, 0, 1, 0)
	healthBarFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	healthBarFill.BorderSizePixel = 0
	healthBarFill.Parent = healthBarBG

	local healthText = Instance.new("TextLabel")
	healthText.Name = "HealthText"
	healthText.Size = UDim2.new(1, 0, 0.35, 0)
	healthText.Position = UDim2.new(0, 0, 0.65, 0)
	healthText.BackgroundTransparency = 1
	healthText.Text = bossData.Stats.HP .. " / " .. bossData.Stats.HP
	healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
	healthText.TextStrokeTransparency = 0
	healthText.Font = Enum.Font.Gotham
	healthText.TextScaled = true
	healthText.Parent = billboard

	model.PrimaryPart = mainPart
	return model
end

-- ========================================
-- START BOSS AI
-- ========================================

function BossService.StartBossAI(bossModel)
	task.spawn(function()
		while bossModel and bossModel.Parent do
			task.wait(0.5)

			local bossInfo = BossService.ActiveBosses[bossModel]
			if not bossInfo then break end

			local humanoid = bossModel:FindFirstChild("Humanoid")
			if not humanoid or humanoid.Health <= 0 then
				BossService.OnBossDeath(bossModel)
				break
			end

			-- Update HP
			local currentHP = humanoid.Health
			bossModel:SetAttribute("CurrentHP", currentHP)

			-- Update health bar
			BossService.UpdateHealthBar(bossModel, currentHP)

			-- Check phase transitions
			BossService.CheckPhaseTransition(bossModel, currentHP)

			-- Find target
			local target = BossService.FindNearestPlayer(bossModel)

			if target then
				-- Move towards target
				local targetPos = target.Position
				local bossPos = bossModel.PrimaryPart.Position
				local distance = (targetPos - bossPos).Magnitude

				if distance > 10 then
					humanoid:MoveTo(targetPos)
				end

				-- Use abilities
				BossService.UseAbilities(bossModel, target, distance)
			end
		end
	end)
end

-- ========================================
-- UPDATE HEALTH BAR
-- ========================================

function BossService.UpdateHealthBar(bossModel, currentHP)
	local maxHP = bossModel:GetAttribute("MaxHP")
	local percent = currentHP / maxHP

	local billboard = bossModel.PrimaryPart:FindFirstChild("BillboardGui")
	if billboard then
		local healthBar = billboard:FindFirstChild("Frame")
			and billboard.Frame:FindFirstChild("HealthBar")

		if healthBar then
			healthBar.Size = UDim2.new(percent, 0, 1, 0)
		end

		local healthText = billboard:FindFirstChild("HealthText")
		if healthText then
			healthText.Text = math.floor(currentHP) .. " / " .. maxHP
		end
	end
end

-- ========================================
-- CHECK PHASE TRANSITION
-- ========================================

function BossService.CheckPhaseTransition(bossModel, currentHP)
	local bossInfo = BossService.ActiveBosses[bossModel]
	if not bossInfo then return end

	local maxHP = bossModel:GetAttribute("MaxHP")
	local hpPercent = currentHP / maxHP
	local currentPhase = bossModel:GetAttribute("CurrentPhase")

	local bossData = bossInfo.Data
	if not bossData.Phases then return end

	-- Check each phase
	for i, phase in ipairs(bossData.Phases) do
		if hpPercent <= phase.HPPercent and currentPhase < i then
			-- Trigger phase transition
			bossModel:SetAttribute("CurrentPhase", i)

			-- Announce phase
			if phase.Message then
				BossService.AnnounceBossPhase(bossData.Name, phase.Message)
			end

			-- Update stats
			local humanoid = bossModel:FindFirstChild("Humanoid")
			if humanoid and phase.SpeedMultiplier then
				humanoid.WalkSpeed = bossData.Stats.Speed * phase.SpeedMultiplier
			end

			print("Boss entered phase", i, ":", phase.Name)
			break
		end
	end
end

-- ========================================
-- FIND NEAREST PLAYER
-- ========================================

function BossService.FindNearestPlayer(bossModel)
	local bossPos = bossModel.PrimaryPart.Position
	local nearestPlayer = nil
	local nearestDistance = math.huge

	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local playerPos = player.Character.HumanoidRootPart.Position
			local distance = (playerPos - bossPos).Magnitude

			if distance < nearestDistance and distance < 100 then
				nearestDistance = distance
				nearestPlayer = player.Character.HumanoidRootPart
			end
		end
	end

	return nearestPlayer
end

-- ========================================
-- USE ABILITIES
-- ========================================

function BossService.UseAbilities(bossModel, target, distance)
	local bossInfo = BossService.ActiveBosses[bossModel]
	if not bossInfo then return end

	local bossData = bossInfo.Data
	if not bossData.Abilities then return end

	local currentTime = os.time()

	for _, ability in ipairs(bossData.Abilities) do
		local lastUse = bossInfo.LastAbilityTime[ability.Name] or 0

		if currentTime - lastUse >= ability.Cooldown then
			if distance <= ability.Range then
				-- Use ability
				BossService.ExecuteAbility(bossModel, ability, target)
				bossInfo.LastAbilityTime[ability.Name] = currentTime
				break -- One ability at a time
			end
		end
	end
end

-- ========================================
-- EXECUTE ABILITY
-- ========================================

function BossService.ExecuteAbility(bossModel, ability, target)
	print("Boss using ability:", ability.Name)

	-- Simple damage implementation
	if ability.Damage and target.Parent then
		local humanoid = target.Parent:FindFirstChild("Humanoid")
		if humanoid then
			humanoid:TakeDamage(ability.Damage)

			-- Show damage
			BossService.ShowDamageNumber(target.Position, ability.Damage)
		end
	end

	-- Special ability effects can be added here
	-- For now, just basic damage
end

-- ========================================
-- SHOW DAMAGE NUMBER
-- ========================================

function BossService.ShowDamageNumber(position, damage)
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("ShowDamage")

	if remoteEvent then
		remoteEvent:FireAllClients(position, damage, "Boss")
	end
end

-- ========================================
-- ON BOSS DEATH
-- ========================================

function BossService.OnBossDeath(bossModel)
	local bossInfo = BossService.ActiveBosses[bossModel]
	if not bossInfo then return end

	local bossData = bossInfo.Data

	print("Boss defeated:", bossData.Name)

	-- Generate loot
	local loot = BossModule.GenerateLoot(bossData)

	-- Drop loot
	if loot and #loot > 0 then
		local LootService = script.Parent:FindFirstChild("LootService")
		if LootService then
			local module = require(LootService)
			for _, lootItem in ipairs(loot) do
				-- Drop loot at boss position
				if module.CreateLootDrop then
					module.CreateLootDrop(bossModel.PrimaryPart.Position, bossData.Level)
				end
			end
		end
	end

	-- Announce death
	BossService.AnnounceBossDeath(bossData.Name)

	-- Start respawn timer
	BossService.StartRespawnTimer(bossData.BossID, bossData.RespawnTime, bossModel.PrimaryPart.Position)

	-- Remove boss
	BossService.ActiveBosses[bossModel] = nil
	bossModel:Destroy()
end

-- ========================================
-- START RESPAWN TIMER
-- ========================================

function BossService.StartRespawnTimer(bossID, respawnTime, position)
	task.spawn(function()
		print("Boss will respawn in", respawnTime, "seconds")
		task.wait(respawnTime)

		-- Respawn boss
		BossService.SpawnBoss(bossID, position)
	end)
end

-- ========================================
-- ANNOUNCE WORLD BOSS
-- ========================================

function BossService.AnnounceWorldBoss(bossName)
	local message = "🔥 WORLD BOSS: " .. bossName .. " has spawned! 🔥"

	for _, player in ipairs(game.Players:GetPlayers()) do
		BossService.NotifyPlayer(player, message)
	end
end

function BossService.AnnounceBossPhase(bossName, message)
	for _, player in ipairs(game.Players:GetPlayers()) do
		BossService.NotifyPlayer(player, "⚠️ " .. message)
	end
end

function BossService.AnnounceBossDeath(bossName)
	local message = "✅ " .. bossName .. " has been defeated!"

	for _, player in ipairs(game.Players:GetPlayers()) do
		BossService.NotifyPlayer(player, message)
	end
end

-- ========================================
-- NOTIFY PLAYER
-- ========================================

function BossService.NotifyPlayer(player, message)
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("BossNotification")

	if remoteEvent then
		remoteEvent:FireClient(player, message)
	end
end

-- ========================================
-- SPAWN ALL BOSSES
-- ========================================

function BossService.SpawnAllBosses()
	-- Spawn beginner boss
	BossService.SpawnBoss("boss_linh_thu_vuong", Vector3.new(100, 5, 100))

	-- Spawn mid-tier boss
	BossService.SpawnBoss("boss_thien_mon_ma_vuong", Vector3.new(500, 5, 500))

	-- Spawn world boss
	BossService.SpawnBoss("boss_thien_ma_de_ton", Vector3.new(0, 50, 0))
end

-- ========================================
-- INITIALIZE
-- ========================================

function BossService.Initialize()
	print("👑 BossService initializing...")

	-- Create RemoteEvents folder if needed
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if not remoteEvents then
		remoteEvents = Instance.new("Folder")
		remoteEvents.Name = "RemoteEvents"
		remoteEvents.Parent = ReplicatedStorage
	end

	-- Create BossNotification event
	if not remoteEvents:FindFirstChild("BossNotification") then
		local notif = Instance.new("RemoteEvent")
		notif.Name = "BossNotification"
		notif.Parent = remoteEvents
	end

	-- Spawn bosses after delay
	task.wait(5)
	BossService.SpawnAllBosses()

	print("✅ BossService ready!")
end

-- Auto-initialize
BossService.Initialize()

return BossService
