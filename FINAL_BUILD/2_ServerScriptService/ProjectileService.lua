-- ProjectileService.lua - Server-Side Projectile Management
-- Copy vào ServerScriptService/ProjectileService (Script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Wait for modules
local ProjectileModule = require(ReplicatedStorage.Modules.Combat.ProjectileModule)
local DodgeSystem = require(ReplicatedStorage.Modules.Combat.DodgeSystem)
local SkillsModule = require(ReplicatedStorage.Modules.Skills.SkillsModule)

-- RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local FireSkillEvent = RemoteEvents:FindFirstChild("FireSkill") or Instance.new("RemoteEvent")
FireSkillEvent.Name = "FireSkill"
FireSkillEvent.Parent = RemoteEvents

local CreateProjectileEvent = RemoteEvents:FindFirstChild("CreateProjectile") or Instance.new("RemoteEvent")
CreateProjectileEvent.Name = "CreateProjectile"
CreateProjectileEvent.Parent = RemoteEvents

local ShowDamageEvent = RemoteEvents:FindFirstChild("ShowDamage") or Instance.new("RemoteEvent")
ShowDamageEvent.Name = "ShowDamage"
ShowDamageEvent.Parent = RemoteEvents

-- ========================================
-- PROJECTILE SERVICE
-- ========================================

local ProjectileService = {
	ActiveProjectiles = {},
	LastCleanup = tick()
}

-- ========================================
-- GET PLAYER DATA
-- ========================================

local function GetPlayerData(player)
	local dataValue = player:FindFirstChild("PlayerData")
	if dataValue then
		return game:GetService("HttpService"):JSONDecode(dataValue.Value)
	end
	return nil
end

-- ========================================
-- CALCULATE DAMAGE
-- ========================================

local function CalculateDamage(attackerData, skill, targetHumanoid)
	if not attackerData or not attackerData.Stats then
		return 0, false
	end

	local stats = attackerData.Stats
	local baseDamage = 0

	-- Select damage type based on skill
	if skill.DamageType == "Magic" then
		baseDamage = stats.MagicDamage or 100
	elseif skill.DamageType == "Physical" then
		baseDamage = stats.PhysicalDamage or 100
	elseif skill.DamageType == "Soul" then
		baseDamage = stats.SoulDamage or 100
	else
		baseDamage = stats.MagicDamage or 100
	end

	-- Apply skill multiplier
	local damage = baseDamage * (skill.DamageMultiplier or 1.0)

	-- Check for crit
	local isCrit = false
	local critRate = stats.CritRate or 0.1
	if math.random() < critRate then
		isCrit = true
		local critDamage = stats.CritDamage or 1.5
		damage = damage * critDamage
	end

	return math.floor(damage), isCrit
end

-- ========================================
-- APPLY DAMAGE
-- ========================================

local function ApplyDamage(attacker, target, damage, isCrit, attackerData)
	local targetHumanoid = target:FindFirstChild("Humanoid")
	if not targetHumanoid or targetHumanoid.Health <= 0 then
		return
	end

	-- Check if target is dodging (i-frames)
	local targetPlayer = Players:GetPlayerFromCharacter(target)
	if targetPlayer and DodgeSystem.IsInvincible(targetPlayer) then
		print("🛡️ Dodge! Target is invincible")
		-- Show "DODGE!" text
		local hrp = target:FindFirstChild("HumanoidRootPart")
		if hrp then
			ShowDamageEvent:FireAllClients(hrp.Position, "DODGE!", false)
		end
		return
	end

	-- Apply damage
	targetHumanoid:TakeDamage(damage)

	-- Lifesteal
	if attackerData and attackerData.Stats and attackerData.Stats.Lifesteal > 0 then
		local lifestealAmount = damage * attackerData.Stats.Lifesteal
		local attackerChar = attacker.Character
		if attackerChar then
			local attackerHumanoid = attackerChar:FindFirstChild("Humanoid")
			if attackerHumanoid then
				attackerHumanoid.Health = math.min(
					attackerHumanoid.Health + lifestealAmount,
					attackerHumanoid.MaxHealth
				)
			end
		end
	end

	-- Show damage number
	local hrp = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
	if hrp then
		ShowDamageEvent:FireAllClients(hrp.Position, damage, isCrit)
	end

	print(string.format("💥 %s dealt %d damage to %s (Crit: %s)",
		attacker.Name, damage, target.Name, tostring(isCrit)))

	-- Check if target died - add soul for Ma Đạo
	if targetHumanoid.Health <= 0 and attackerData.CultivationType == "MaDao" then
		if attackerData.HonPhien and attackerData.HonPhien.Equipped then
			local HonPhienModule = require(ReplicatedStorage.Modules.MaDao.HonPhienModule)
			HonPhienModule.OnKill(attackerData, target)

			-- Update player data
			local dataValue = attacker:FindFirstChild("PlayerData")
			if dataValue then
				dataValue.Value = game:GetService("HttpService"):JSONEncode(attackerData)
			end
		end
	end
end

-- ========================================
-- HANDLE PROJECTILE HIT
-- ========================================

local function OnProjectileHit(projectileData, hitModel, hitHumanoid)
	local attacker = projectileData.Owner
	local attackerData = GetPlayerData(attacker)
	local skill = projectileData.Skill

	-- Calculate damage
	local damage, isCrit = CalculateDamage(attackerData, skill, hitHumanoid)

	-- Apply damage
	ApplyDamage(attacker, hitModel, damage, isCrit, attackerData)
end

-- ========================================
-- HANDLE PROJECTILE AOE HIT
-- ========================================

local function OnProjectileAOEHit(projectileData, targets)
	local attacker = projectileData.Owner
	local attackerData = GetPlayerData(attacker)
	local skill = projectileData.Skill

	for _, target in ipairs(targets) do
		local humanoid = target:FindFirstChild("Humanoid")
		if humanoid and humanoid.Health > 0 then
			-- AOE damage is typically reduced
			local damage, isCrit = CalculateDamage(attackerData, skill, humanoid)
			damage = math.floor(damage * 0.7) -- 70% damage for AOE

			ApplyDamage(attacker, target, damage, isCrit, attackerData)
		end
	end
end

-- ========================================
-- CREATE PROJECTILE
-- ========================================

function ProjectileService.CreateProjectile(player, skill, startPosition, direction)
	-- Validate player
	local playerData = GetPlayerData(player)
	if not playerData then
		warn("No player data for", player.Name)
		return
	end

	-- Get projectile type from skill
	local projectileType = skill.ProjectileType or "MagicBolt"

	-- Calculate damage for this projectile
	local damage, _ = CalculateDamage(playerData, skill, nil)

	-- Create projectile on server
	local projectileData = ProjectileModule.CreateProjectile(
		projectileType,
		startPosition,
		direction,
		player,
		damage,
		skill
	)

	if projectileData then
		-- Add to active projectiles
		table.insert(ProjectileService.ActiveProjectiles, projectileData)

		-- Network to all clients (so they see the projectile)
		CreateProjectileEvent:FireAllClients(
			projectileType,
			startPosition,
			direction,
			player.UserId,
			skill.Name
		)

		print(string.format("🔥 %s fired %s (%s projectile)",
			player.Name, skill.Name, projectileType))

		return true
	end

	return false
end

-- ========================================
-- UPDATE PROJECTILES
-- ========================================

function ProjectileService.UpdateProjectiles(deltaTime)
	for i = #ProjectileService.ActiveProjectiles, 1, -1 do
		local projectileData = ProjectileService.ActiveProjectiles[i]

		-- Update projectile position and check hits
		local stillActive = ProjectileModule.UpdateProjectile(projectileData, deltaTime)

		-- Check if hit something
		local hit, hitModel, hitHumanoid = ProjectileModule.CheckHit(projectileData)

		if hit then
			-- Handle hit
			OnProjectileHit(projectileData, hitModel, hitHumanoid)

			-- Check for AOE explosion
			if projectileData.Template.AOERadius > 0 then
				local targets = ProjectileModule.GetTargetsInRadius(
					projectileData.Part.Position,
					projectileData.Template.AOERadius,
					projectileData.Owner
				)
				OnProjectileAOEHit(projectileData, targets)

				-- Create explosion effect
				ProjectileModule.CreateExplosion(projectileData)
			end

			-- Destroy projectile unless it's piercing
			if not projectileData.Template.Piercing then
				ProjectileModule.DestroyProjectile(projectileData)
				table.remove(ProjectileService.ActiveProjectiles, i)
			end
		elseif not stillActive then
			-- Projectile expired (lifetime ended)
			ProjectileModule.DestroyProjectile(projectileData)
			table.remove(ProjectileService.ActiveProjectiles, i)
		end
	end
end

-- ========================================
-- CLEANUP OLD PROJECTILES
-- ========================================

function ProjectileService.Cleanup()
	local currentTime = tick()

	-- Clean up every 5 seconds
	if currentTime - ProjectileService.LastCleanup < 5 then
		return
	end

	ProjectileService.LastCleanup = currentTime

	-- Remove any orphaned projectiles
	for i = #ProjectileService.ActiveProjectiles, 1, -1 do
		local projectileData = ProjectileService.ActiveProjectiles[i]
		if not projectileData.Part or not projectileData.Part.Parent then
			table.remove(ProjectileService.ActiveProjectiles, i)
		end
	end
end

-- ========================================
-- REMOTE EVENT: FIRE SKILL
-- ========================================

FireSkillEvent.OnServerEvent:Connect(function(player, skillName, aimDirection)
	-- Validate player
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local hrp = character.HumanoidRootPart
	local playerData = GetPlayerData(player)
	if not playerData then
		return
	end

	-- Get skill data
	local skill = SkillsModule.GetSkillByName(skillName, playerData.CultivationType)
	if not skill then
		warn("Skill not found:", skillName)
		return
	end

	-- Check if player can use skill (mana, cooldown, etc.)
	local canUse, reason = SkillsModule.CanUseSkill(skill, playerData.Stats, 0)
	if not canUse then
		warn("Cannot use skill:", reason)
		return
	end

	-- Consume mana
	if skill.ManaCost and skill.ManaCost > 0 then
		playerData.Stats.MP = math.max(0, playerData.Stats.MP - skill.ManaCost)

		-- Update player data
		local dataValue = player:FindFirstChild("PlayerData")
		if dataValue then
			dataValue.Value = game:GetService("HttpService"):JSONEncode(playerData)
		end
	end

	-- Calculate start position (slightly in front of player)
	local startPosition = hrp.Position + aimDirection * 3 + Vector3.new(0, 1.5, 0)

	-- Create projectile
	ProjectileService.CreateProjectile(player, skill, startPosition, aimDirection)
end)

-- ========================================
-- UPDATE LOOP
-- ========================================

RunService.Heartbeat:Connect(function(deltaTime)
	ProjectileService.UpdateProjectiles(deltaTime)
	ProjectileService.Cleanup()
end)

-- ========================================
-- INITIALIZE DODGE SYSTEM FOR PLAYERS
-- ========================================

Players.PlayerAdded:Connect(function(player)
	DodgeSystem.InitPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
	DodgeSystem.RemovePlayer(player)
end)

-- Handle dodge remote event
local DodgeEvent = RemoteEvents:FindFirstChild("Dodge") or Instance.new("RemoteEvent")
DodgeEvent.Name = "Dodge"
DodgeEvent.Parent = RemoteEvents

DodgeEvent.OnServerEvent:Connect(function(player, direction)
	local success, message = DodgeSystem.Dodge(player, direction)
	if not success then
		warn(player.Name, "dodge failed:", message)
	else
		print("✨", player.Name, "dodged!")
	end
end)

-- Update stamina for all players
RunService.Heartbeat:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		DodgeSystem.UpdateStamina(player)
	end
end)

print("✅ ProjectileService loaded (Server-side skillshots + dodge)")
