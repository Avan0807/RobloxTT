-- HonPhienAdvancedService.lua - Server Hồn Phiên Advanced Management
-- Copy vào ServerScriptService/HonPhienAdvancedService (Script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HonPhienAdvanced = require(ReplicatedStorage.Modules.HonPhien.HonPhienAdvanced)

local HonPhienService = {}
HonPhienService.ActiveBuffs = {} -- {player = {buffData}}
HonPhienService.ActiveSkills = {} -- {player = {skillData}}
HonPhienService.Cooldowns = {} -- {player = {skillID = endTime}}

-- ========================================
-- USE TẾ LỄ BUFF
-- ========================================

function HonPhienService.UseTeLeBuff(player, buffIndex)
	local playerData = HonPhienService.GetPlayerData(player)
	if not playerData or playerData.CultivationType ~= "MaDao" then
		return false, "Only Ma Đạo can use this!"
	end

	local currentSouls = playerData.HonPhien and playerData.HonPhien.Souls or 0

	-- Check if can use
	local canUse, msg = HonPhienAdvanced.CanUseTeLe(currentSouls, buffIndex)
	if not canUse then
		return false, msg
	end

	-- Get buff data
	local buff = HonPhienAdvanced.TeLeBuffs[buffIndex]

	-- Deduct souls
	playerData.HonPhien.Souls = playerData.HonPhien.Souls - buff.SoulCost

	-- Activate buff
	local buffData = HonPhienAdvanced.ActivateTeLe(buffIndex)

	-- Store active buff
	if not HonPhienService.ActiveBuffs[player] then
		HonPhienService.ActiveBuffs[player] = {}
	end
	table.insert(HonPhienService.ActiveBuffs[player], buffData)

	-- Handle special effects
	if buff.Effects.SummonBoss then
		HonPhienService.SummonOanHon(player)
	end

	if buff.Effects.SummonArmy then
		HonPhienService.SummonSoulArmy(player, buff.Effects.ArmySize)
	end

	-- Notify player
	HonPhienService.NotifyPlayer(player, "✅ Activated: " .. buff.Name)

	-- Sync
	HonPhienService.SyncBuffs(player)

	-- Start buff timer
	HonPhienService.StartBuffTimer(player, buffData)

	return true, "Buff activated!"
end

-- ========================================
-- USE SPECIAL SKILL
-- ========================================

function HonPhienService.UseSpecialSkill(player, skillID)
	local playerData = HonPhienService.GetPlayerData(player)
	if not playerData or playerData.CultivationType ~= "MaDao" then
		return false, "Only Ma Đạo can use this!"
	end

	-- Check cooldown
	if HonPhienService.IsOnCooldown(player, skillID) then
		local remaining = HonPhienService.GetCooldownRemaining(player, skillID)
		return false, "On cooldown! " .. math.ceil(remaining) .. "s remaining"
	end

	-- Check if can use
	local canUse, msg = HonPhienAdvanced.CanUseSkill(skillID, playerData)
	if not canUse then
		return false, msg
	end

	local skill = HonPhienAdvanced.GetSkill(skillID)
	if not skill then
		return false, "Skill not found!"
	end

	-- Deduct souls
	if skill.SoulCost and skill.SoulCost ~= "All" then
		playerData.HonPhien.Souls = playerData.HonPhien.Souls - skill.SoulCost
	elseif skill.SoulCost == "All" then
		-- Store current souls for damage calculation
		local currentSouls = playerData.HonPhien.Souls
		playerData.HonPhien.Souls = 0

		-- Execute skill with all souls
		HonPhienService.ExecuteSkill(player, skillID, currentSouls)
	end

	-- Set cooldown
	HonPhienService.SetCooldown(player, skillID, skill.Cooldown)

	-- Execute skill
	if skill.SoulCost ~= "All" then
		HonPhienService.ExecuteSkill(player, skillID, 0)
	end

	-- Notify
	HonPhienService.NotifyPlayer(player, "⚡ Used: " .. skill.Name)

	return true, "Skill used!"
end

-- ========================================
-- EXECUTE SKILL
-- ========================================

function HonPhienService.ExecuteSkill(player, skillID, soulCount)
	local skill = HonPhienAdvanced.GetSkill(skillID)
	if not skill then return end

	-- Different execution based on skill type
	if skillID == "hon_hai_man_thien" then
		-- AOE damage based on souls
		local damage = HonPhienAdvanced.CalculateSkillDamage(skillID, soulCount)
		HonPhienService.DealAOEDamage(player, damage, skill.Effects.AOERange)

	elseif skillID == "thi_hon" then
		-- Heal to full
		HonPhienService.HealPlayer(player, skill.Effects.HealPercent)

	elseif skillID == "ma_vuc_trien_khai" then
		-- Create Ma Vực
		HonPhienService.CreateMaVuc(player, skill)

	elseif skillID == "linh_hon_phong_an" then
		-- Seal enemy soul (handled in combat)
		HonPhienService.ActivateSealMode(player, skill)

	elseif skillID == "ma_hoang_hoa_than" then
		-- Transform
		HonPhienService.TransformPlayer(player, skill)

	elseif skillID == "hon_phien_gioi" then
		-- Ultimate skill
		HonPhienService.CreateHonPhienGioi(player, skill)
	end
end

-- ========================================
-- DEAL AOE DAMAGE
-- ========================================

function HonPhienService.DealAOEDamage(player, damage, range)
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local position = player.Character.HumanoidRootPart.Position

	-- Find all enemies in range
	for _, enemy in ipairs(workspace:GetChildren()) do
		if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy ~= player.Character then
			local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
			if enemyRoot then
				local distance = (enemyRoot.Position - position).Magnitude

				if distance <= range then
					-- Deal damage
					local humanoid = enemy:FindFirstChild("Humanoid")
					if humanoid then
						humanoid:TakeDamage(damage)

						-- Show damage number
						HonPhienService.ShowDamage(enemyRoot.Position, damage)
					end
				end
			end
		end
	end

	-- Visual effect
	HonPhienService.CreateAOEEffect(position, range)
end

-- ========================================
-- HEAL PLAYER
-- ========================================

function HonPhienService.HealPlayer(player, healPercent)
	if not player.Character then return end

	local humanoid = player.Character:FindFirstChild("Humanoid")
	if humanoid then
		local healAmount = humanoid.MaxHealth * healPercent
		humanoid.Health = math.min(humanoid.Health + healAmount, humanoid.MaxHealth)

		HonPhienService.ShowDamage(player.Character.HumanoidRootPart.Position, "+" .. math.floor(healAmount), Color3.fromRGB(100, 255, 100))
	end
end

-- ========================================
-- CREATE MA VỰC
-- ========================================

function HonPhienService.CreateMaVuc(player, skill)
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local position = player.Character.HumanoidRootPart.Position
	local range = skill.Effects.DomainRange
	local duration = skill.Duration
	local debuff = skill.Effects.EnemyDebuff
	local soulDrain = skill.Effects.SoulDrainRate

	-- Create Ma Vực zone
	local maVuc = Instance.new("Part")
	maVuc.Name = "MaVuc_" .. player.Name
	maVuc.Shape = Enum.PartType.Ball
	maVuc.Size = Vector3.new(range * 2, range * 2, range * 2)
	maVuc.Position = position
	maVuc.Anchored = true
	maVuc.CanCollide = false
	maVuc.Material = Enum.Material.ForceField
	maVuc.Color = Color3.fromRGB(50, 0, 80)
	maVuc.Transparency = 0.7
	maVuc.Parent = workspace

	-- Add dark aura
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 3
	pointLight.Range = range
	pointLight.Color = Color3.fromRGB(100, 0, 150)
	pointLight.Parent = maVuc

	-- Particle effect
	local particles = Instance.new("ParticleEmitter")
	particles.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particles.Color = ColorSequence.new(Color3.fromRGB(80, 0, 120))
	particles.Size = NumberSequence.new(5)
	particles.Transparency = NumberSequence.new(0.5)
	particles.Lifetime = NumberRange.new(2, 4)
	particles.Rate = 50
	particles.Speed = NumberRange.new(5, 10)
	particles.SpreadAngle = Vector2.new(360, 360)
	particles.Parent = maVuc

	-- Ma Vực logic loop
	task.spawn(function()
		local startTime = os.time()

		while os.time() - startTime < duration do
			task.wait(1)

			-- Find all enemies in range
			for _, enemy in ipairs(workspace:GetChildren()) do
				if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy ~= player.Character then
					local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
					if enemyRoot then
						local distance = (enemyRoot.Position - maVuc.Position).Magnitude

						if distance <= range then
							local humanoid = enemy:FindFirstChild("Humanoid")

							if humanoid and humanoid.Health > 0 then
								-- Apply debuff (damage over time)
								local damage = humanoid.MaxHealth * debuff / duration
								humanoid:TakeDamage(damage)

								-- Drain souls (add to player)
								local playerData = HonPhienService.GetPlayerData(player)
								if playerData and playerData.CultivationType == "MaDao" then
									if not playerData.HonPhien then
										playerData.HonPhien = {Souls = 0}
									end
									playerData.HonPhien.Souls = playerData.HonPhien.Souls + soulDrain

									-- Sync player data
									HonPhienService.SyncPlayerData(player)
								end

								-- Visual feedback
								HonPhienService.ShowDamage(enemyRoot.Position, "-" .. math.floor(damage), Color3.fromRGB(150, 0, 200))
							end
						end
					end
				end
			end
		end

		-- Cleanup
		particles.Enabled = false
		task.wait(2)
		maVuc:Destroy()

		HonPhienService.NotifyPlayer(player, "⏰ Ma Vực expired")
	end)

	HonPhienService.NotifyPlayer(player, "🌑 Ma Vực Created! Enemies weakened in " .. range .. "m radius!")
end

-- ========================================
-- ACTIVATE SEAL MODE (Linh Hồn Phong Ấn)
-- ========================================

function HonPhienService.ActivateSealMode(player, skill)
	-- Creates a mode where next attack can execute enemies below 30% HP
	if not HonPhienService.ActiveSkills[player] then
		HonPhienService.ActiveSkills[player] = {}
	end

	local sealData = {
		SkillID = "linh_hon_phong_an",
		Name = "Soul Seal Mode",
		ExecuteThreshold = skill.Effects.InstantKillThreshold,
		EndTime = os.time() + 10, -- 10 second window
		Active = true
	}

	table.insert(HonPhienService.ActiveSkills[player], sealData)

	HonPhienService.NotifyPlayer(player, "💀 Soul Seal Mode! Next attack can execute enemies below 30% HP!")

	-- Expire after duration
	task.spawn(function()
		task.wait(10)

		if HonPhienService.ActiveSkills[player] then
			for i, skill in ipairs(HonPhienService.ActiveSkills[player]) do
				if skill.SkillID == "linh_hon_phong_an" then
					table.remove(HonPhienService.ActiveSkills[player], i)
					break
				end
			end
		end

		HonPhienService.NotifyPlayer(player, "⏰ Soul Seal Mode expired")
	end)
end

-- ========================================
-- TRANSFORM PLAYER (Ma Hoàng Hóa Thân)
-- ========================================

function HonPhienService.TransformPlayer(player, skill)
	if not player.Character then return end

	local duration = skill.Duration
	local multiplier = skill.Effects.AllStatsMultiplier

	-- Store transform state
	if not HonPhienService.ActiveSkills[player] then
		HonPhienService.ActiveSkills[player] = {}
	end

	local transformData = {
		SkillID = "ma_hoang_hoa_than",
		Name = "Demon King Transformation",
		StatsMultiplier = multiplier,
		EndTime = os.time() + duration,
		Active = true
	}

	table.insert(HonPhienService.ActiveSkills[player], transformData)

	-- Apply visual transformation
	local humanoid = player.Character:FindFirstChild("Humanoid")
	if humanoid then
		-- Increase size
		for _, part in ipairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.Size = part.Size * 1.5
			end
		end

		-- Add dark aura
		local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local aura = Instance.new("ParticleEmitter")
			aura.Name = "DemonAura"
			aura.Texture = "rbxasset://textures/particles/smoke_main.dds"
			aura.Color = ColorSequence.new(Color3.fromRGB(150, 0, 200))
			aura.Size = NumberSequence.new(3)
			aura.Transparency = NumberSequence.new(0.5)
			aura.Lifetime = NumberRange.new(1, 2)
			aura.Rate = 100
			aura.Speed = NumberRange.new(5, 10)
			aura.SpreadAngle = Vector2.new(360, 360)
			aura.Parent = rootPart
		end
	end

	HonPhienService.NotifyPlayer(player, "👹 DEMON KING TRANSFORMATION! 10x Stats for " .. duration .. "s!")

	-- Revert after duration
	task.spawn(function()
		task.wait(duration)

		-- Revert size
		for _, part in ipairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.Size = part.Size / 1.5
			end
		end

		-- Remove aura
		local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local aura = rootPart:FindFirstChild("DemonAura")
			if aura then
				aura:Destroy()
			end
		end

		-- Remove transform state
		if HonPhienService.ActiveSkills[player] then
			for i, skill in ipairs(HonPhienService.ActiveSkills[player]) do
				if skill.SkillID == "ma_hoang_hoa_than" then
					table.remove(HonPhienService.ActiveSkills[player], i)
					break
				end
			end
		end

		HonPhienService.NotifyPlayer(player, "⏰ Transformation ended")
	end)
end

-- ========================================
-- CREATE HỒN PHIÊN GIỚI (Ultimate Skill)
-- ========================================

function HonPhienService.CreateHonPhienGioi(player, skill)
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local position = player.Character.HumanoidRootPart.Position
	local range = skill.Effects.WorldRange
	local duration = skill.Duration

	-- Create ultimate domain
	local domain = Instance.new("Part")
	domain.Name = "HonPhienGioi_" .. player.Name
	domain.Shape = Enum.PartType.Ball
	domain.Size = Vector3.new(range * 2, range * 2, range * 2)
	domain.Position = position
	domain.Anchored = true
	domain.CanCollide = false
	domain.Material = Enum.Material.ForceField
	domain.Color = Color3.fromRGB(100, 0, 150)
	domain.Transparency = 0.5
	domain.Parent = workspace

	-- Massive dark aura
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 5
	pointLight.Range = range
	pointLight.Color = Color3.fromRGB(150, 0, 200)
	pointLight.Parent = domain

	-- Epic particles
	local particles = Instance.new("ParticleEmitter")
	particles.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particles.Color = ColorSequence.new(Color3.fromRGB(150, 0, 200))
	particles.Size = NumberSequence.new(10)
	particles.Transparency = NumberSequence.new(0.3)
	particles.Lifetime = NumberRange.new(3, 6)
	particles.Rate = 100
	particles.Speed = NumberRange.new(10, 20)
	particles.SpreadAngle = Vector2.new(360, 360)
	particles.Parent = domain

	HonPhienService.NotifyPlayer(player, "🌌 HỒN PHIÊN GIỚI! Ultimate Domain activated!")

	-- Domain effects loop
	task.spawn(function()
		local startTime = os.time()

		while os.time() - startTime < duration do
			task.wait(1)

			-- Drain HP from all enemies, spawn soul minions
			for _, enemy in ipairs(workspace:GetChildren()) do
				if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy ~= player.Character then
					local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
					if enemyRoot then
						local distance = (enemyRoot.Position - domain.Position).Magnitude

						if distance <= range then
							local humanoid = enemy:FindFirstChild("Humanoid")

							if humanoid and humanoid.Health > 0 then
								-- Drain 5% HP per second
								local damage = humanoid.MaxHealth * skill.Effects.EnemyHPDrain
								humanoid:TakeDamage(damage)

								-- Add souls to player
								local playerData = HonPhienService.GetPlayerData(player)
								if playerData and playerData.CultivationType == "MaDao" then
									if not playerData.HonPhien then
										playerData.HonPhien = {Souls = 0}
									end
									playerData.HonPhien.Souls = playerData.HonPhien.Souls + 50

									HonPhienService.SyncPlayerData(player)
								end

								-- Visual
								HonPhienService.ShowDamage(enemyRoot.Position, "-" .. math.floor(damage), Color3.fromRGB(200, 0, 255))
							end
						end
					end
				end
			end
		end

		-- Cleanup
		particles.Enabled = false
		task.wait(2)
		domain:Destroy()

		HonPhienService.NotifyPlayer(player, "⏰ Hồn Phiên Giới ended")
	end)
end

-- ========================================
-- SYNC PLAYER DATA
-- ========================================

function HonPhienService.SyncPlayerData(player)
	local PlayerDataService = script.Parent:FindFirstChild("PlayerDataService")
	if PlayerDataService then
		local module = require(PlayerDataService)
		if module.SyncPlayerData then
			module.SyncPlayerData(player)
		end
	end
end

-- ========================================
-- SHOW DAMAGE
-- ========================================

function HonPhienService.ShowDamage(position, damage, color)
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("ShowDamage")

	if remoteEvent then
		remoteEvent:FireAllClients(position, damage, color or Color3.fromRGB(200, 0, 200))
	end
end

-- ========================================
-- CREATE AOE EFFECT
-- ========================================

function HonPhienService.CreateAOEEffect(position, range)
	-- Visual effect for AOE
	local effect = Instance.new("Part")
	effect.Shape = Enum.PartType.Ball
	effect.Size = Vector3.new(range * 2, range * 2, range * 2)
	effect.Position = position
	effect.Anchored = true
	effect.CanCollide = false
	effect.Material = Enum.Material.Neon
	effect.Color = Color3.fromRGB(200, 0, 200)
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
-- SUMMON OAN HỒN
-- ========================================

function HonPhienService.SummonOanHon(player)
	-- Summon a boss minion to fight for player
	print("Summoning Oan Hồn for", player.Name)
	HonPhienService.NotifyPlayer(player, "👻 Oan Hồn summoned!")
end

-- ========================================
-- SUMMON SOUL ARMY
-- ========================================

function HonPhienService.SummonSoulArmy(player, armySize)
	print("Summoning Soul Army for", player.Name, "- Size:", armySize)
	HonPhienService.NotifyPlayer(player, "💀 Soul Army summoned!")
end

-- ========================================
-- COOLDOWN MANAGEMENT
-- ========================================

function HonPhienService.SetCooldown(player, skillID, duration)
	if not HonPhienService.Cooldowns[player] then
		HonPhienService.Cooldowns[player] = {}
	end

	HonPhienService.Cooldowns[player][skillID] = os.time() + duration
end

function HonPhienService.IsOnCooldown(player, skillID)
	if not HonPhienService.Cooldowns[player] then
		return false
	end

	local endTime = HonPhienService.Cooldowns[player][skillID]
	if not endTime then
		return false
	end

	return os.time() < endTime
end

function HonPhienService.GetCooldownRemaining(player, skillID)
	if not HonPhienService.IsOnCooldown(player, skillID) then
		return 0
	end

	local endTime = HonPhienService.Cooldowns[player][skillID]
	return endTime - os.time()
end

-- ========================================
-- BUFF TIMER
-- ========================================

function HonPhienService.StartBuffTimer(player, buffData)
	task.spawn(function()
		task.wait(buffData.Duration)

		-- Remove buff
		if HonPhienService.ActiveBuffs[player] then
			for i, buff in ipairs(HonPhienService.ActiveBuffs[player]) do
				if buff.Name == buffData.Name and buff.StartTime == buffData.StartTime then
					table.remove(HonPhienService.ActiveBuffs[player], i)
					break
				end
			end
		end

		-- Notify
		HonPhienService.NotifyPlayer(player, "⏰ Buff expired: " .. buffData.Name)

		-- Sync
		HonPhienService.SyncBuffs(player)
	end)
end

-- ========================================
-- GET PLAYER DATA
-- ========================================

function HonPhienService.GetPlayerData(player)
	local PlayerDataService = script.Parent:FindFirstChild("PlayerDataService")
	if PlayerDataService then
		local module = require(PlayerDataService)
		return module.GetPlayerData and module.GetPlayerData(player)
	end
	return nil
end

-- ========================================
-- SYNC BUFFS
-- ========================================

function HonPhienService.SyncBuffs(player)
	local buffs = HonPhienService.ActiveBuffs[player] or {}

	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("SyncHonPhienBuffs")

	if remoteEvent then
		remoteEvent:FireClient(player, buffs)
	end
end

-- ========================================
-- NOTIFY PLAYER
-- ========================================

function HonPhienService.NotifyPlayer(player, message)
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("HonPhienNotification")

	if remoteEvent then
		remoteEvent:FireClient(player, message)
	end
end

-- ========================================
-- SETUP REMOTE EVENTS
-- ========================================

function HonPhienService.SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if not remoteEvents then
		remoteEvents = Instance.new("Folder")
		remoteEvents.Name = "RemoteEvents"
		remoteEvents.Parent = ReplicatedStorage
	end

	-- Use Tế Lễ Buff
	local useTeLe = remoteEvents:FindFirstChild("UseTeLeBuff")
	if not useTeLe then
		useTeLe = Instance.new("RemoteEvent")
		useTeLe.Name = "UseTeLeBuff"
		useTeLe.Parent = remoteEvents
	end

	useTeLe.OnServerEvent:Connect(function(player, buffIndex)
		local success, msg = HonPhienService.UseTeLeBuff(player, buffIndex)

		local response = remoteEvents:FindFirstChild("HonPhienNotification")
		if not response then
			response = Instance.new("RemoteEvent")
			response.Name = "HonPhienNotification"
			response.Parent = remoteEvents
		end

		response:FireClient(player, msg)
	end)

	-- Use Special Skill
	local useSkill = remoteEvents:FindFirstChild("UseHonPhienSkill")
	if not useSkill then
		useSkill = Instance.new("RemoteEvent")
		useSkill.Name = "UseHonPhienSkill"
		useSkill.Parent = remoteEvents
	end

	useSkill.OnServerEvent:Connect(function(player, skillID)
		local success, msg = HonPhienService.UseSpecialSkill(player, skillID)

		local response = remoteEvents:FindFirstChild("HonPhienNotification")
		if response then
			response:FireClient(player, msg)
		end
	end)

	-- Sync Buffs
	if not remoteEvents:FindFirstChild("SyncHonPhienBuffs") then
		local sync = Instance.new("RemoteEvent")
		sync.Name = "SyncHonPhienBuffs"
		sync.Parent = remoteEvents
	end
end

-- ========================================
-- INITIALIZE
-- ========================================

function HonPhienService.Initialize()
	print("👻 HonPhienAdvancedService initializing...")

	-- Setup remote events
	HonPhienService.SetupRemoteEvents()

	print("✅ HonPhienAdvancedService ready!")
end

-- Auto-initialize
HonPhienService.Initialize()

return HonPhienService
