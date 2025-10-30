-- SpawnProtectionService.lua - Player Spawn Protection
-- Gives players invincibility and prevents enemy aggro when they first spawn

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SpawnProtectionService = {}

-- ========================================
-- SETTINGS
-- ========================================

SpawnProtectionService.Settings = {
	-- Spawn protection duration (seconds)
	ProtectionDuration = 10,

	-- Visual effect color
	ShieldColor = Color3.fromRGB(100, 200, 255),

	-- Safe zone radius around spawn (studs)
	SafeZoneRadius = 30,

	-- Prevent damage while protected
	PreventDamage = true,

	-- Show shield visual effect
	ShowShieldEffect = true
}

-- Track protected players
SpawnProtectionService.ProtectedPlayers = {}

-- ========================================
-- APPLY SPAWN PROTECTION
-- ========================================

function SpawnProtectionService.ApplyProtection(player)
	if not player or not player.Character then return end

	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Mark player as protected
	SpawnProtectionService.ProtectedPlayers[player] = {
		StartTime = tick(),
		EndTime = tick() + SpawnProtectionService.Settings.ProtectionDuration,
		Character = character
	}

	print("🛡️ Spawn protection applied to", player.Name, "for", SpawnProtectionService.Settings.ProtectionDuration, "seconds")

	-- Create shield visual effect
	if SpawnProtectionService.Settings.ShowShieldEffect then
		SpawnProtectionService.CreateShieldEffect(character)
	end

	-- Notify player
	SpawnProtectionService.NotifyPlayer(player, "🛡️ Spawn Protection: " .. SpawnProtectionService.Settings.ProtectionDuration .. "s")

	-- Remove protection after duration
	task.delay(SpawnProtectionService.Settings.ProtectionDuration, function()
		SpawnProtectionService.RemoveProtection(player)
	end)
end

-- ========================================
-- REMOVE SPAWN PROTECTION
-- ========================================

function SpawnProtectionService.RemoveProtection(player)
	if not SpawnProtectionService.ProtectedPlayers[player] then return end

	SpawnProtectionService.ProtectedPlayers[player] = nil

	if player and player.Character then
		-- Remove shield effect
		local shield = player.Character:FindFirstChild("SpawnShield")
		if shield then
			-- Fade out animation
			local tweenService = game:GetService("TweenService")
			local tween = tweenService:Create(
				shield,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Transparency = 1}
			)
			tween:Play()

			task.wait(0.5)
			shield:Destroy()
		end
	end

	print("🛡️ Spawn protection removed from", player.Name)
	SpawnProtectionService.NotifyPlayer(player, "⚠️ Spawn protection ended!")
end

-- ========================================
-- CHECK IF PLAYER IS PROTECTED
-- ========================================

function SpawnProtectionService.IsProtected(player)
	local protection = SpawnProtectionService.ProtectedPlayers[player]
	if not protection then return false end

	-- Check if protection expired
	if tick() > protection.EndTime then
		SpawnProtectionService.RemoveProtection(player)
		return false
	end

	return true
end

-- ========================================
-- CREATE SHIELD VISUAL EFFECT
-- ========================================

function SpawnProtectionService.CreateShieldEffect(character)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- Remove old shield if exists
	local oldShield = character:FindFirstChild("SpawnShield")
	if oldShield then oldShield:Destroy() end

	-- Create shield sphere
	local shield = Instance.new("Part")
	shield.Name = "SpawnShield"
	shield.Shape = Enum.PartType.Ball
	shield.Size = Vector3.new(10, 10, 10)
	shield.Material = Enum.Material.ForceField
	shield.Color = SpawnProtectionService.Settings.ShieldColor
	shield.Transparency = 0.7
	shield.CanCollide = false
	shield.Anchored = true
	shield.Parent = character

	-- Position shield
	shield.CFrame = rootPart.CFrame

	-- Add glow effect
	local light = Instance.new("PointLight")
	light.Color = SpawnProtectionService.Settings.ShieldColor
	light.Brightness = 2
	light.Range = 15
	light.Parent = shield

	-- Add particle effect
	local particles = Instance.new("ParticleEmitter")
	particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particles.Rate = 30
	particles.Lifetime = NumberRange.new(1, 2)
	particles.Speed = NumberRange.new(2, 4)
	particles.Color = ColorSequence.new(SpawnProtectionService.Settings.ShieldColor)
	particles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	particles.Parent = shield

	-- Update shield position continuously
	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function()
		if not shield or not shield.Parent or not rootPart or not rootPart.Parent then
			if connection then connection:Disconnect() end
			if shield then shield:Destroy() end
			return
		end

		shield.CFrame = rootPart.CFrame

		-- Pulsing animation
		local pulse = math.sin(tick() * 3) * 0.5 + 0.5
		shield.Transparency = 0.5 + (pulse * 0.3)
	end)
end

-- ========================================
-- NOTIFY PLAYER
-- ========================================

function SpawnProtectionService.NotifyPlayer(player, message)
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if not remoteEvents then return end

	local notification = remoteEvents:FindFirstChild("SpawnProtectionNotification")
	if not notification then
		notification = Instance.new("RemoteEvent")
		notification.Name = "SpawnProtectionNotification"
		notification.Parent = remoteEvents
	end

	notification:FireClient(player, message)
end

-- ========================================
-- DAMAGE PREVENTION
-- ========================================

function SpawnProtectionService.SetupDamageProtection()
	-- Hook into Humanoid.HealthChanged to prevent damage
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid", 5)
			if not humanoid then return end

			-- Store original health
			local lastHealth = humanoid.Health

			humanoid.HealthChanged:Connect(function(newHealth)
				-- Check if player is protected
				if SpawnProtectionService.IsProtected(player) and SpawnProtectionService.Settings.PreventDamage then
					-- Check if health decreased (took damage)
					if newHealth < lastHealth then
						-- Restore health
						humanoid.Health = lastHealth

						-- Visual feedback
						SpawnProtectionService.NotifyPlayer(player, "🛡️ Protected!")
					end
				end

				lastHealth = newHealth
			end)
		end)
	end)
end

-- ========================================
-- SAFE ZONE VISUALIZATION (Optional)
-- ========================================

function SpawnProtectionService.CreateSafeZoneVisual(spawnLocation)
	-- Create transparent cylinder to show safe zone
	local safeZone = Instance.new("Part")
	safeZone.Name = "SafeZone"
	safeZone.Shape = Enum.PartType.Cylinder
	safeZone.Size = Vector3.new(2, SpawnProtectionService.Settings.SafeZoneRadius * 2, SpawnProtectionService.Settings.SafeZoneRadius * 2)
	safeZone.CFrame = spawnLocation.CFrame * CFrame.Angles(0, 0, math.rad(90))
	safeZone.Color = SpawnProtectionService.Settings.ShieldColor
	safeZone.Material = Enum.Material.Neon
	safeZone.Transparency = 0.9
	safeZone.CanCollide = false
	safeZone.Anchored = true
	safeZone.Parent = spawnLocation

	-- Pulsing animation
	task.spawn(function()
		while safeZone and safeZone.Parent do
			local pulse = math.sin(tick() * 2) * 0.1 + 0.85
			safeZone.Transparency = pulse
			task.wait(0.1)
		end
	end)

	return safeZone
end

-- ========================================
-- INITIALIZE
-- ========================================

function SpawnProtectionService.Initialize()
	print("🛡️ SpawnProtectionService initializing...")

	-- Setup damage protection
	SpawnProtectionService.SetupDamageProtection()

	-- Apply protection when players spawn
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			-- Wait a bit for character to fully load
			task.wait(0.5)

			SpawnProtectionService.ApplyProtection(player)
		end)
	end)

	-- Apply to existing players
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			task.wait(0.5)
			SpawnProtectionService.ApplyProtection(player)
		end
	end

	-- Create safe zone visuals at spawn locations
	task.spawn(function()
		task.wait(2) -- Wait for maps to load

		local workspace = game:GetService("Workspace")

		-- Find spawn locations
		for _, map in ipairs(workspace:GetChildren()) do
			local spawnLocation = map:FindFirstChild("PlayerSpawn", true)
			if spawnLocation and spawnLocation:IsA("SpawnLocation") then
				SpawnProtectionService.CreateSafeZoneVisual(spawnLocation)
			end
		end
	end)

	print("✅ SpawnProtectionService ready!")
	print("🛡️ Players will have " .. SpawnProtectionService.Settings.ProtectionDuration .. "s spawn protection")
end

-- Auto-initialize
SpawnProtectionService.Initialize()

return SpawnProtectionService
