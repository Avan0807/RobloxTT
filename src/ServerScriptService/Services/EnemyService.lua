-- EnemyService.lua - Quản lý Enemy AI
-- Copy vào ServerScriptService/EnemyService (Script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

-- Load modules
local EnemyTemplate = require(ReplicatedStorage.Data.EnemyTemplate)

-- ========================================
-- ENEMY SERVICE
-- ========================================

local EnemyService = {
	ActiveEnemies = {},
	SpawnPoints = {},
	LastUpdate = tick(),
	LastSpawn = tick()
}

-- ========================================
-- ENEMY AI SETTINGS
-- ========================================

local AI_SETTINGS = {
	UpdateInterval = 0.1, -- Update AI every 0.1s
	DetectionRange = 60, -- Detect players within 60 studs
	AttackRange = 5, -- Attack when within 5 studs
	ChaseSpeed = 16, -- Walking speed
	ReturnDistance = 100, -- Return to spawn if too far
	RespawnTime = 30, -- Respawn after 30 seconds
	MaxEnemiesPerMap = 20 -- Max enemies per map
}

-- ========================================
-- CREATE ENEMY MODEL
-- ========================================

local function CreateEnemyModel(enemyData, position)
	-- Create basic humanoid model
	local model = Instance.new("Model")
	model.Name = enemyData.Name

	-- Torso
	local torso = Instance.new("Part")
	torso.Name = "HumanoidRootPart"
	torso.Size = Vector3.new(2, 2, 1)
	torso.Position = position
	torso.Anchored = false
	torso.Color = enemyData.Color or Color3.fromRGB(255, 100, 100)
	torso.Material = Enum.Material.SmoothPlastic
	torso.Parent = model

	-- Head
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(2, 1, 1)
	head.Position = position + Vector3.new(0, 1.5, 0)
	head.Anchored = false
	head.Color = enemyData.Color or Color3.fromRGB(255, 100, 100)
	head.Material = Enum.Material.SmoothPlastic
	head.Shape = Enum.PartType.Ball
	head.Parent = model

	-- Weld head to torso
	local weld = Instance.new("Weld")
	weld.Part0 = torso
	weld.Part1 = head
	weld.C0 = CFrame.new(0, 1.5, 0)
	weld.Parent = head

	-- Humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = enemyData.Stats.MaxHP
	humanoid.Health = enemyData.Stats.MaxHP
	humanoid.WalkSpeed = AI_SETTINGS.ChaseSpeed
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Subject
	humanoid.Parent = model

	-- Health bar
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "HealthBar"
	billboard.Size = UDim2.new(4, 0, 0.5, 0)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local healthBarBg = Instance.new("Frame")
	healthBarBg.Size = UDim2.new(1, 0, 1, 0)
	healthBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	healthBarBg.BorderSizePixel = 0
	healthBarBg.Parent = billboard

	local healthBar = Instance.new("Frame")
	healthBar.Name = "Bar"
	healthBar.Size = UDim2.new(1, 0, 1, 0)
	healthBar.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	healthBar.BorderSizePixel = 0
	healthBar.Parent = healthBarBg

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.8, 0)
	nameLabel.Position = UDim2.new(0, 0, -0.8, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = enemyData.Name .. " Lv" .. enemyData.Level
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.Parent = billboard

	-- Tag as Enemy
	CollectionService:AddTag(model, "Enemy")

	model.Parent = workspace.Enemies

	return model
end

-- ========================================
-- SPAWN ENEMY
-- ========================================

function EnemyService.SpawnEnemy(enemyName, mapName, position)
	-- Get enemy data
	local enemyData = EnemyTemplate[mapName]
	if not enemyData then
		warn("Map not found:", mapName)
		return nil
	end

	local template = nil
	for _, enemy in ipairs(enemyData) do
		if enemy.Name == enemyName then
			template = enemy
			break
		end
	end

	if not template then
		warn("Enemy not found:", enemyName)
		return nil
	end

	-- Create model
	local model = CreateEnemyModel(template, position)

	-- Create enemy data
	local enemy = {
		Model = model,
		Humanoid = model:FindFirstChild("Humanoid"),
		HumanoidRootPart = model:FindFirstChild("HumanoidRootPart"),
		Template = template,
		SpawnPosition = position,
		State = "Idle", -- Idle, Chasing, Attacking, Returning
		Target = nil,
		LastAttack = 0,
		IsBoss = template.IsBoss or false,
		MapName = mapName
	}

	-- Add to active enemies
	table.insert(EnemyService.ActiveEnemies, enemy)

	-- Listen for death
	enemy.Humanoid.Died:Connect(function()
		EnemyService.OnEnemyDied(enemy)
	end)

	print("✅ Spawned:", template.Name, "at", mapName)

	return enemy
end

-- ========================================
-- ENEMY AI UPDATE
-- ========================================

local function UpdateEnemyAI(enemy)
	if not enemy.Model or not enemy.Model.Parent then
		return false -- Enemy destroyed
	end

	if enemy.Humanoid.Health <= 0 then
		return false -- Enemy dead
	end

	local hrp = enemy.HumanoidRootPart
	if not hrp then return false end

	local position = hrp.Position

	-- Find closest player
	local closestPlayer = nil
	local closestDistance = AI_SETTINGS.DetectionRange

	-- Get SpawnProtectionService if available
	local SpawnProtectionService = _G.Services and _G.Services.SpawnProtectionService

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			-- Check if player has spawn protection
			if SpawnProtectionService and SpawnProtectionService.IsProtected(player) then
				-- Skip protected players
				continue
			end

			local playerHrp = character.HumanoidRootPart
			local distance = (playerHrp.Position - position).Magnitude

			if distance < closestDistance then
				closestDistance = distance
				closestPlayer = player
			end
		end
	end

	-- State machine
	if closestPlayer then
		local playerHrp = closestPlayer.Character.HumanoidRootPart

		if closestDistance <= AI_SETTINGS.AttackRange then
			-- ATTACK STATE
			enemy.State = "Attacking"
			enemy.Target = closestPlayer

			-- Stop moving
			enemy.Humanoid:MoveTo(position)

			-- Attack cooldown
			local currentTime = tick()
			if currentTime - enemy.LastAttack >= (enemy.Template.AttackSpeed or 2) then
				enemy.LastAttack = currentTime
				EnemyService.AttackPlayer(enemy, closestPlayer)
			end

		else
			-- CHASE STATE
			enemy.State = "Chasing"
			enemy.Target = closestPlayer

			-- Move toward player
			enemy.Humanoid:MoveTo(playerHrp.Position)
		end

	else
		-- No player in range
		local distanceFromSpawn = (position - enemy.SpawnPosition).Magnitude

		if distanceFromSpawn > 10 then
			-- RETURN STATE
			enemy.State = "Returning"
			enemy.Target = nil
			enemy.Humanoid:MoveTo(enemy.SpawnPosition)
		else
			-- IDLE STATE
			enemy.State = "Idle"
			enemy.Target = nil
			enemy.Humanoid:MoveTo(position)
		end
	end

	-- Update health bar
	local billboard = enemy.Model:FindFirstChild("Head"):FindFirstChild("HealthBar")
	if billboard then
		local bar = billboard:FindFirstChild("Frame"):FindFirstChild("Bar")
		if bar then
			local healthPercent = enemy.Humanoid.Health / enemy.Humanoid.MaxHealth
			bar.Size = UDim2.new(healthPercent, 0, 1, 0)
		end
	end

	return true
end

-- ========================================
-- ATTACK PLAYER
-- ========================================

function EnemyService.AttackPlayer(enemy, player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	-- Calculate damage
	local damage = enemy.Template.Stats.PhysicalDamage or 50

	-- Apply damage
	humanoid:TakeDamage(damage)

	print(string.format("👹 %s attacked %s for %d damage",
		enemy.Template.Name, player.Name, damage))
end

-- ========================================
-- ON ENEMY DIED
-- ========================================

function EnemyService.OnEnemyDied(enemy)
	print("💀", enemy.Template.Name, "died!")

	-- Drop rewards (TODO: implement loot system)

	-- Schedule respawn
	task.delay(AI_SETTINGS.RespawnTime, function()
		-- Remove from active list
		for i, e in ipairs(EnemyService.ActiveEnemies) do
			if e == enemy then
				table.remove(EnemyService.ActiveEnemies, i)
				break
			end
		end

		-- Destroy model
		if enemy.Model then
			enemy.Model:Destroy()
		end

		-- Respawn
		EnemyService.SpawnEnemy(
			enemy.Template.Name,
			enemy.MapName,
			enemy.SpawnPosition
		)
	end)
end

-- ========================================
-- AUTO SPAWN ENEMIES FOR MAP
-- ========================================

function EnemyService.AutoSpawnForMap(mapName, mapFolder)
	local enemies = EnemyTemplate[mapName]
	if not enemies then
		warn("No enemies defined for map:", mapName)
		return
	end

	-- Find spawn points in map
	local spawnFolder = mapFolder:FindFirstChild("EnemySpawns")
	if not spawnFolder then
		warn("No EnemySpawns folder in map:", mapName)
		return
	end

	-- Spawn enemies at each spawn point
	for _, spawnPoint in ipairs(spawnFolder:GetChildren()) do
		if spawnPoint:IsA("BasePart") then
			-- Get enemy index from spawn point name (e.g., "Spawn1", "Spawn2")
			local index = tonumber(string.match(spawnPoint.Name, "%d+")) or 1
			local enemyTemplate = enemies[math.min(index, #enemies)]

			if enemyTemplate then
				EnemyService.SpawnEnemy(
					enemyTemplate.Name,
					mapName,
					spawnPoint.Position + Vector3.new(0, 3, 0)
				)
			end
		end
	end

	print("✅ Auto-spawned enemies for", mapName)
end

-- ========================================
-- UPDATE LOOP
-- ========================================

RunService.Heartbeat:Connect(function()
	local currentTime = tick()

	-- Update AI at intervals
	if currentTime - EnemyService.LastUpdate < AI_SETTINGS.UpdateInterval then
		return
	end

	EnemyService.LastUpdate = currentTime

	-- Update all active enemies
	for i = #EnemyService.ActiveEnemies, 1, -1 do
		local enemy = EnemyService.ActiveEnemies[i]
		local stillActive = UpdateEnemyAI(enemy)

		if not stillActive then
			table.remove(EnemyService.ActiveEnemies, i)
		end
	end
end)

-- ========================================
-- CREATE ENEMIES FOLDER
-- ========================================

if not workspace:FindFirstChild("Enemies") then
	local folder = Instance.new("Folder")
	folder.Name = "Enemies"
	folder.Parent = workspace
end

print("✅ EnemyService loaded (AI enabled)")

return EnemyService
