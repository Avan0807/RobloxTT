-- ThienKiepService.lua - Server Thiên Kiếp Management
-- Copy vào ServerScriptService/ThienKiepService (Script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ThienKiepModule = require(ReplicatedStorage.Modules.ThienKiep.ThienKiepModule)

local ThienKiepService = {}
ThienKiepService.ActiveThienKiep = {} -- {player = {kiepData, bossModel}}

-- ========================================
-- START THIÊN KIẾP
-- ========================================

function ThienKiepService.StartThienKiep(player)
	local playerData = ThienKiepService.GetPlayerData(player)
	if not playerData then
		return false, "Player data not found!"
	end

	-- Check if can attempt
	local canAttempt, result = ThienKiepModule.CanAttemptThienKiep(playerData)
	if not canAttempt then
		return false, result
	end

	local kiep = result

	-- Check if already in tribulation
	if ThienKiepService.ActiveThienKiep[player] then
		return false, "Already in Thiên Kiếp!"
	end

	-- Spawn boss
	local boss = ThienKiepService.SpawnThienKiepBoss(player, kiep)
	if not boss then
		return false, "Failed to spawn Thiên Kiếp boss!"
	end

	-- Store active tribulation
	ThienKiepService.ActiveThienKiep[player] = {
		Kiep = kiep,
		Boss = boss,
		StartTime = os.time()
	}

	-- Notify player
	ThienKiepService.NotifyPlayer(player, "⚡ THIÊN KIẾP HAS BEGUN! Defeat " .. kiep.Boss.Name .. "!")

	-- Sync to client
	ThienKiepService.SyncThienKiep(player)

	return true, "Thiên Kiếp started!"
end

-- ========================================
-- SPAWN THIÊN KIẾP BOSS
-- ========================================

function ThienKiepService.SpawnThienKiepBoss(player, kiep)
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return nil
	end

	local spawnPosition = player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 20)

	-- Create boss model
	local boss = Instance.new("Model")
	boss.Name = kiep.Boss.Name

	-- Create humanoid root part
	local rootPart = Instance.new("Part")
	rootPart.Name = "HumanoidRootPart"
	rootPart.Size = kiep.Boss.Size
	rootPart.Position = spawnPosition
	rootPart.Anchored = false
	rootPart.CanCollide = true
	rootPart.Color = kiep.Boss.Color
	rootPart.Material = Enum.Material.Neon
	rootPart.Parent = boss

	-- Add glow effect
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 2
	pointLight.Range = 30
	pointLight.Color = kiep.Boss.Color
	pointLight.Parent = rootPart

	-- Create humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = kiep.Boss.Health
	humanoid.Health = kiep.Boss.Health
	humanoid.WalkSpeed = kiep.Boss.Speed
	humanoid.Parent = boss

	-- Health bar
	local healthBar = Instance.new("BillboardGui")
	healthBar.Name = "HealthBar"
	healthBar.Size = UDim2.new(0, 200, 0, 30)
	healthBar.StudsOffset = Vector3.new(0, 5, 0)
	healthBar.Adornee = rootPart
	healthBar.Parent = boss

	local healthFrame = Instance.new("Frame")
	healthFrame.Size = UDim2.new(1, 0, 1, 0)
	healthFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	healthFrame.BorderSizePixel = 0
	healthFrame.Parent = healthBar

	local healthFill = Instance.new("Frame")
	healthFill.Name = "HealthFill"
	healthFill.Size = UDim2.new(1, 0, 1, 0)
	healthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	healthFill.BorderSizePixel = 0
	healthFill.Parent = healthFrame

	local healthText = Instance.new("TextLabel")
	healthText.Name = "HealthText"
	healthText.Size = UDim2.new(1, 0, 1, 0)
	healthText.BackgroundTransparency = 1
	healthText.Font = Enum.Font.GothamBold
	healthText.Text = kiep.Boss.Name .. "\n" .. kiep.Boss.Health .. " / " .. kiep.Boss.Health
	healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
	healthText.TextSize = 14
	healthText.TextStrokeTransparency = 0.5
	healthText.Parent = healthFrame

	boss.Parent = workspace

	-- Boss AI
	ThienKiepService.StartBossAI(player, boss, kiep)

	-- Monitor boss health
	ThienKiepService.MonitorBossHealth(player, boss, kiep)

	return boss
end

-- ========================================
-- START BOSS AI
-- ========================================

function ThienKiepService.StartBossAI(player, boss, kiep)
	task.spawn(function()
		local humanoid = boss:FindFirstChild("Humanoid")
		if not humanoid then return end

		local lastAbilityTime = {}

		while boss.Parent and humanoid.Health > 0 do
			task.wait(1)

			if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
				break
			end

			local playerRoot = player.Character.HumanoidRootPart
			local bossRoot = boss:FindFirstChild("HumanoidRootPart")

			if not bossRoot then break end

			local distance = (playerRoot.Position - bossRoot.Position).Magnitude

			-- Move towards player
			if distance > 10 then
				humanoid:MoveTo(playerRoot.Position)
			end

			-- Use abilities
			local healthPercent = humanoid.Health / humanoid.MaxHealth
			local currentPhase = ThienKiepModule.GetCurrentPhase(kiep.Boss, healthPercent)

			if currentPhase and currentPhase.Abilities then
				for _, ability in ipairs(currentPhase.Abilities) do
					local lastUse = lastAbilityTime[ability.Name] or 0

					if os.time() - lastUse >= ability.Cooldown then
						ThienKiepService.UseAbility(player, boss, ability)
						lastAbilityTime[ability.Name] = os.time()
					end
				end
			elseif kiep.Boss.Abilities then
				-- No phases, just use base abilities
				for _, ability in ipairs(kiep.Boss.Abilities) do
					local lastUse = lastAbilityTime[ability.Name] or 0

					if os.time() - lastUse >= ability.Cooldown then
						ThienKiepService.UseAbility(player, boss, ability)
						lastAbilityTime[ability.Name] = os.time()
					end
				end
			end
		end
	end)
end

-- ========================================
-- USE ABILITY
-- ========================================

function ThienKiepService.UseAbility(player, boss, ability)
	if not player.Character or not boss:FindFirstChild("HumanoidRootPart") then
		return
	end

	local bossRoot = boss.HumanoidRootPart
	local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")

	-- Lightning strike effect
	ThienKiepService.CreateLightningEffect(bossRoot.Position, playerRoot and playerRoot.Position or bossRoot.Position)

	-- Deal damage
	if ability.AOEDamage and ability.Range then
		-- AOE damage
		ThienKiepService.DealAOEDamage(bossRoot.Position, ability.AOEDamage, ability.Range, player)
	elseif ability.Damage and playerRoot then
		-- Single target
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid:TakeDamage(ability.Damage)
		end
	end

	-- Notify
	ThienKiepService.NotifyPlayer(player, "⚡ " .. ability.Name .. "!")
end

-- ========================================
-- DEAL AOE DAMAGE
-- ========================================

function ThienKiepService.DealAOEDamage(position, damage, range, targetPlayer)
	if not targetPlayer.Character then return end

	local playerRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not playerRoot then return end

	local distance = (playerRoot.Position - position).Magnitude

	if distance <= range then
		local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid:TakeDamage(damage)
		end
	end

	-- Visual effect
	ThienKiepService.CreateAOEEffect(position, range)
end

-- ========================================
-- CREATE LIGHTNING EFFECT
-- ========================================

function ThienKiepService.CreateLightningEffect(startPos, endPos)
	local lightning = Instance.new("Part")
	lightning.Name = "Lightning"
	lightning.Size = Vector3.new(0.5, (startPos - endPos).Magnitude, 0.5)
	lightning.Position = (startPos + endPos) / 2
	lightning.CFrame = CFrame.lookAt((startPos + endPos) / 2, endPos)
	lightning.Anchored = true
	lightning.CanCollide = false
	lightning.Material = Enum.Material.Neon
	lightning.Color = Color3.fromRGB(150, 200, 255)
	lightning.Transparency = 0.3
	lightning.Parent = workspace

	-- Fade out
	task.spawn(function()
		for i = 0.3, 1, 0.1 do
			lightning.Transparency = i
			task.wait(0.05)
		end
		lightning:Destroy()
	end)
end

-- ========================================
-- CREATE AOE EFFECT
-- ========================================

function ThienKiepService.CreateAOEEffect(position, range)
	local effect = Instance.new("Part")
	effect.Shape = Enum.PartType.Ball
	effect.Size = Vector3.new(range * 2, range * 2, range * 2)
	effect.Position = position
	effect.Anchored = true
	effect.CanCollide = false
	effect.Material = Enum.Material.Neon
	effect.Color = Color3.fromRGB(150, 200, 255)
	effect.Transparency = 0.5
	effect.Parent = workspace

	-- Fade out
	task.spawn(function()
		for i = 0.5, 1, 0.05 do
			effect.Transparency = i
			effect.Size = effect.Size * 0.95
			task.wait(0.05)
		end
		effect:Destroy()
	end)
end

-- ========================================
-- MONITOR BOSS HEALTH
-- ========================================

function ThienKiepService.MonitorBossHealth(player, boss, kiep)
	local humanoid = boss:FindFirstChild("Humanoid")
	if not humanoid then return end

	local healthBar = boss:FindFirstChild("HealthBar")

	-- Update health bar
	humanoid.HealthChanged:Connect(function(health)
		if healthBar then
			local healthFill = healthBar:FindFirstChild("Frame") and healthBar.Frame:FindFirstChild("HealthFill")
			local healthText = healthBar:FindFirstChild("Frame") and healthBar.Frame:FindFirstChild("HealthText")

			if healthFill then
				healthFill.Size = UDim2.new(health / humanoid.MaxHealth, 0, 1, 0)
			end

			if healthText then
				healthText.Text = kiep.Boss.Name .. "\n" .. math.floor(health) .. " / " .. humanoid.MaxHealth
			end
		end
	end)

	-- Boss died
	humanoid.Died:Connect(function()
		task.wait(1)
		ThienKiepService.OnBossDefeated(player, kiep)
		boss:Destroy()
	end)
end

-- ========================================
-- ON BOSS DEFEATED
-- ========================================

function ThienKiepService.OnBossDefeated(player, kiep)
	local playerData = ThienKiepService.GetPlayerData(player)
	if not playerData then return end

	-- Apply success rewards
	ThienKiepModule.ApplySuccessRewards(playerData, kiep)

	-- Give items
	if kiep.Rewards.Items then
		local inventory = ThienKiepService.GetInventory(player)
		if inventory then
			local InventoryModule = require(ReplicatedStorage.Modules.Inventory.InventoryModule)
			local LootModule = require(ReplicatedStorage.Modules.Loot.LootModule)

			for _, itemReward in ipairs(kiep.Rewards.Items) do
				local itemData = LootModule.GetItemData(itemReward.Name)
				if itemData then
					InventoryModule.AddItem(inventory, itemData, itemReward.Amount)
				end
			end

			ThienKiepService.SyncInventory(player)
		end
	end

	-- Clear active tribulation
	ThienKiepService.ActiveThienKiep[player] = nil

	-- Notify
	ThienKiepService.NotifyPlayer(player, "🎉 THIÊN KIẾP SUCCESS! Breakthrough to " .. kiep.TargetRealm .. "!")

	-- Sync
	ThienKiepService.SyncPlayerData(player)
	ThienKiepService.SyncThienKiep(player)
end

-- ========================================
-- ON PLAYER DEATH (During Thiên Kiếp)
-- ========================================

function ThienKiepService.OnThienKiepFailure(player)
	local active = ThienKiepService.ActiveThienKiep[player]
	if not active then return end

	local playerData = ThienKiepService.GetPlayerData(player)
	if not playerData then return end

	-- Apply failure penalty
	local died = ThienKiepModule.ApplyFailurePenalty(playerData, active.Kiep.FailurePenalty)

	-- Destroy boss
	if active.Boss and active.Boss.Parent then
		active.Boss:Destroy()
	end

	-- Clear active tribulation
	ThienKiepService.ActiveThienKiep[player] = nil

	-- Notify
	if died then
		ThienKiepService.NotifyPlayer(player, "💀 THIÊN KIẾP FAILURE! You have died...")
	else
		ThienKiepService.NotifyPlayer(player, "⚠️ THIÊN KIẾP FAILURE! Penalties applied.")
	end

	-- Sync
	ThienKiepService.SyncPlayerData(player)
	ThienKiepService.SyncThienKiep(player)
end

-- ========================================
-- GET PLAYER DATA
-- ========================================

function ThienKiepService.GetPlayerData(player)
	local PlayerDataService = script.Parent:FindFirstChild("PlayerDataService")
	if PlayerDataService then
		local module = require(PlayerDataService)
		return module.GetPlayerData and module.GetPlayerData(player)
	end
	return nil
end

-- ========================================
-- GET INVENTORY
-- ========================================

function ThienKiepService.GetInventory(player)
	local InventoryService = script.Parent:FindFirstChild("InventoryService")
	if InventoryService then
		local module = require(InventoryService)
		return module.GetInventory and module.GetInventory(player)
	end
	return nil
end

-- ========================================
-- SYNC INVENTORY
-- ========================================

function ThienKiepService.SyncInventory(player)
	local InventoryService = script.Parent:FindFirstChild("InventoryService")
	if InventoryService then
		local module = require(InventoryService)
		if module.SyncInventory then
			module.SyncInventory(player)
		end
	end
end

-- ========================================
-- SYNC PLAYER DATA
-- ========================================

function ThienKiepService.SyncPlayerData(player)
	local PlayerDataService = script.Parent:FindFirstChild("PlayerDataService")
	if PlayerDataService then
		local module = require(PlayerDataService)
		if module.SyncPlayerData then
			module.SyncPlayerData(player)
		end
	end
end

-- ========================================
-- SYNC THIÊN KIẾP
-- ========================================

function ThienKiepService.SyncThienKiep(player)
	local active = ThienKiepService.ActiveThienKiep[player]

	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("SyncThienKiep")

	if remoteEvent then
		if active then
			remoteEvent:FireClient(player, {
				Active = true,
				Kiep = active.Kiep,
				StartTime = active.StartTime
			})
		else
			remoteEvent:FireClient(player, {Active = false})
		end
	end
end

-- ========================================
-- NOTIFY PLAYER
-- ========================================

function ThienKiepService.NotifyPlayer(player, message)
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("ThienKiepNotification")

	if remoteEvent then
		remoteEvent:FireClient(player, message)
	end
end

-- ========================================
-- SETUP REMOTE EVENTS
-- ========================================

function ThienKiepService.SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if not remoteEvents then
		remoteEvents = Instance.new("Folder")
		remoteEvents.Name = "RemoteEvents"
		remoteEvents.Parent = ReplicatedStorage
	end

	-- Start Thiên Kiếp
	local startThienKiep = remoteEvents:FindFirstChild("StartThienKiep")
	if not startThienKiep then
		startThienKiep = Instance.new("RemoteEvent")
		startThienKiep.Name = "StartThienKiep"
		startThienKiep.Parent = remoteEvents
	end

	startThienKiep.OnServerEvent:Connect(function(player)
		local success, msg = ThienKiepService.StartThienKiep(player)

		local notif = remoteEvents:FindFirstChild("ThienKiepNotification")
		if not notif then
			notif = Instance.new("RemoteEvent")
			notif.Name = "ThienKiepNotification"
			notif.Parent = remoteEvents
		end

		notif:FireClient(player, msg)
	end)

	-- Sync Thiên Kiếp
	if not remoteEvents:FindFirstChild("SyncThienKiep") then
		local sync = Instance.new("RemoteEvent")
		sync.Name = "SyncThienKiep"
		sync.Parent = remoteEvents
	end
end

-- ========================================
-- PLAYER DEATH HANDLER
-- ========================================

function ThienKiepService.OnPlayerDeath(player)
	-- Check if in Thiên Kiếp
	if ThienKiepService.ActiveThienKiep[player] then
		ThienKiepService.OnThienKiepFailure(player)
	end
end

-- ========================================
-- INITIALIZE
-- ========================================

function ThienKiepService.Initialize()
	print("⚡ ThienKiepService initializing...")

	-- Setup remote events
	ThienKiepService.SetupRemoteEvents()

	-- Monitor player deaths
	game.Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid")
			humanoid.Died:Connect(function()
				ThienKiepService.OnPlayerDeath(player)
			end)
		end)
	end)

	print("✅ ThienKiepService ready!")
end

-- Auto-initialize
ThienKiepService.Initialize()

return ThienKiepService
