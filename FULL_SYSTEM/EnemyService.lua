-- EnemyService.lua - Spawn và Quản Lý Enemies (Server)
-- Copy vào ServerScriptService/Services/EnemyService (Script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Wait for modules
local EnemyTemplate = require(ReplicatedStorage.Modules.Combat.EnemyTemplate)
local HonPhienModule = require(ReplicatedStorage.Modules.MaDao.HonPhienModule)

-- Get PlayerDataService
local PlayerDataService = require(script.Parent.PlayerDataService)

-- RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local UseSkillEvent = RemoteEvents:WaitForChild("UseSkill")
local ShowDamageEvent = RemoteEvents:WaitForChild("ShowDamage")

local EnemyService = {}
EnemyService.ActiveEnemies = {} -- All living enemies

-- ========================================
-- CREATE ENEMY MODEL
-- ========================================

local function CreateEnemyModel(enemyData, template, position)
	local model = Instance.new("Model")
	model.Name = enemyData.Name

	-- Body
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = template.Size
	body.Color = template.Color
	body.Position = position
	body.Anchored = false
	body.CanCollide = true
	body.Material = Enum.Material.SmoothPlastic
	body.Parent = model

	-- Humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = enemyData.Stats.MaxHP
	humanoid.Health = enemyData.Stats.HP
	humanoid.WalkSpeed = enemyData.Stats.Speed
	humanoid.Parent = model

	-- HumanoidRootPart
	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"
	hrp.Size = Vector3.new(2, 2, 1)
	hrp.Transparency = 1
	hrp.CanCollide = false
	hrp.Position = position
	hrp.Parent = model

	-- Weld
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hrp
	weld.Part1 = body
	weld.Parent = body

	-- Nametag
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = hrp

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = enemyData.Name .. " [Lv." .. enemyData.Level .. "]"
	nameLabel.TextColor3 = enemyData.IsBoss and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 100, 100)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.Parent = billboard

	local healthBar = Instance.new("Frame")
	healthBar.Name = "HealthBar"
	healthBar.Size = UDim2.new(1, 0, 0.3, 0)
	healthBar.Position = UDim2.new(0, 0, 0.6, 0)
	healthBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	healthBar.Parent = billboard

	local healthFill = Instance.new("Frame")
	healthFill.Name = "Fill"
	healthFill.Size = UDim2.new(1, 0, 1, 0)
	healthFill.BackgroundColor3 = enemyData.IsBoss and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(255, 0, 0)
	healthFill.BorderSizePixel = 0
	healthFill.Parent = healthBar

	model.PrimaryPart = hrp
	model.Parent = Workspace

	return model
end

-- ========================================
-- SPAWN ENEMIES
-- ========================================

function EnemyService.SpawnEnemy(template, position)
	local enemyData = EnemyTemplate.CreateEnemy(template, position)
	local model = CreateEnemyModel(enemyData, template, position)

	enemyData.Model = model
	enemyData.Humanoid = model:FindFirstChild("Humanoid")

	table.insert(EnemyService.ActiveEnemies, enemyData)

	print("👹 Spawned:", enemyData.Name, "at", position)
	return enemyData
end

function EnemyService.SpawnEnemiesInMap(mapName)
	local mapFolder = Workspace:FindFirstChild(mapName)
	if not mapFolder then
		warn("Map not found:", mapName)
		return
	end

	local spawnArea = mapFolder:FindFirstChild("SpawnArea")
	if not spawnArea then
		warn("SpawnArea not found")
		return
	end

	local templates = EnemyTemplate[mapName]
	if not templates then
		warn("No templates for map:", mapName)
		return
	end

	-- Spawn 3 of each type
	for _, template in ipairs(templates) do
		local count = template.IsBoss and 1 or 3

		for i = 1, count do
			local randomX = math.random(-40, 40)
			local randomZ = math.random(-40, 40)
			local position = spawnArea.Position + Vector3.new(randomX, 5, randomZ)
			EnemyService.SpawnEnemy(template, position)
			wait(0.5)
		end
	end

	print("✅ Spawned enemies in:", mapName)
end

-- ========================================
-- ENEMY AI
-- ========================================

function EnemyService.UpdateEnemies()
	for i = #EnemyService.ActiveEnemies, 1, -1 do
		local enemy = EnemyService.ActiveEnemies[i]

		if not enemy.Model or not enemy.Model.Parent then
			table.remove(EnemyService.ActiveEnemies, i)
			continue
		end

		-- Update health bar
		local healthBar = enemy.Model.PrimaryPart:FindFirstChild("BillboardGui")
		if healthBar then
			local fill = healthBar:FindFirstChild("HealthBar"):FindFirstChild("Fill")
			local healthPercent = enemy.Stats.HP / enemy.Stats.MaxHP
			fill.Size = UDim2.new(healthPercent, 0, 1, 0)
		end

		-- Simple AI
		if enemy.State ~= "Dead" then
			local hrp = enemy.Model.PrimaryPart
			local closestPlayer, closestDistance = nil, math.huge

			for _, player in ipairs(game.Players:GetPlayers()) do
				if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					local distance = (player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
					if distance < closestDistance and distance < enemy.Stats.DetectionRange then
						closestPlayer = player
						closestDistance = distance
					end
				end
			end

			if closestPlayer then
				enemy.State = "Chasing"
				enemy.Humanoid:MoveTo(closestPlayer.Character.HumanoidRootPart.Position)

				-- Attack if in range
				if closestDistance <= enemy.Stats.AttackRange then
					local currentTime = tick()
					if currentTime - enemy.LastAttackTime >= enemy.Stats.AttackCooldown then
						enemy.LastAttackTime = currentTime
						-- Deal damage to player
						local playerData = PlayerDataService.GetPlayerData(closestPlayer)
						if playerData then
							local damage = enemy.Stats.PhysicalDamage or 50
							playerData.Stats.HP = math.max(0, playerData.Stats.HP - damage)

							-- Update character health
							if closestPlayer.Character and closestPlayer.Character:FindFirstChild("Humanoid") then
								closestPlayer.Character.Humanoid.Health = playerData.Stats.HP
							end
						end
					end
				end
			else
				enemy.State = "Idle"
			end
		end
	end
end

-- ========================================
-- HANDLE SKILL USAGE
-- ========================================

UseSkillEvent.OnServerEvent:Connect(function(player, targetModel, skillName)
	-- Find enemy
	local enemyData = nil
	for _, enemy in ipairs(EnemyService.ActiveEnemies) do
		if enemy.Model == targetModel then
			enemyData = enemy
			break
		end
	end

	if not enemyData then return end

	-- Get player data
	local playerData = PlayerDataService.GetPlayerData(player)
	if not playerData then return end

	-- Find skill
	local SkillsModule = require(ReplicatedStorage.Modules.Skills.SkillsModule)
	local skills = SkillsModule.GetSkills(playerData.CultivationType)
	local skill = nil
	for _, s in ipairs(skills) do
		if s.Name == skillName then
			skill = s
			break
		end
	end

	if not skill then return end

	-- Calculate damage
	local honPhienSouls = 0
	if playerData.CultivationType == "MaDao" and playerData.HonPhien.Equipped then
		honPhienSouls = playerData.HonPhien.CurrentSouls
	end

	local damage = SkillsModule.CalculateSkillDamage(skill, playerData.Stats, honPhienSouls)

	-- Random crit
	local isCrit = math.random() < playerData.Stats.CritRate
	if isCrit then
		damage = math.floor(damage * playerData.Stats.CritDamage)
	end

	-- Apply defense
	local defense = enemyData.Stats.Defense or 0
	local reductionPercent = defense / (defense + 100)
	damage = math.floor(damage * (1 - reductionPercent))
	damage = math.max(1, damage)

	-- Apply damage
	enemyData.Stats.HP = math.max(0, enemyData.Stats.HP - damage)
	if enemyData.Humanoid then
		enemyData.Humanoid.Health = enemyData.Stats.HP
	end

	-- Show damage to client
	if targetModel.PrimaryPart then
		ShowDamageEvent:FireClient(player, targetModel.PrimaryPart.Position, damage, isCrit)
	end

	print("⚔️", player.Name, "dealt", damage, "to", enemyData.Name)

	-- If dead
	if enemyData.Stats.HP <= 0 then
		enemyData.State = "Dead"

		-- Give rewards
		playerData.TuViPoints = playerData.TuViPoints + enemyData.ExpReward

		-- Drop loot
		for itemName, dropData in pairs(enemyData.Drops) do
			local roll = math.random()
			if roll <= dropData.chance then
				local amount = math.random(dropData.min, dropData.max)
				if playerData.DanDuoc[itemName] then
					playerData.DanDuoc[itemName] = playerData.DanDuoc[itemName] + amount
				end
			end
		end

		-- Ma Đạo: Add souls to Hồn Phiên
		if playerData.CultivationType == "MaDao" and playerData.HonPhien.Equipped then
			local soulGain = HonPhienModule.GetSoulGainFromEnemy(enemyData.IsBoss and "Boss" or "Normal")
			HonPhienModule.AddSouls(playerData, soulGain)
		end

		-- Save
		PlayerDataService.SavePlayerData(player)

		print("💀", enemyData.Name, "died! Exp:", enemyData.ExpReward)

		-- Remove model
		wait(2)
		if enemyData.Model then
			enemyData.Model:Destroy()
		end
	end
end)

-- ========================================
-- MAIN LOOP
-- ========================================

RunService.Heartbeat:Connect(function()
	EnemyService.UpdateEnemies()
end)

-- Initialize
wait(3)
EnemyService.SpawnEnemiesInMap("RungLinhThu")

print("✅ EnemyService loaded!")
return EnemyService
