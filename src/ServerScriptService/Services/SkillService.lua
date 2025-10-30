-- SkillService.lua - Handle Player Skills
-- Processes skill usage from client

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SkillService = {}

-- Track skill cooldowns per player
SkillService.Cooldowns = {}  -- {[player] = {[skillSlot] = endTime}}

-- ========================================
-- SKILL DEFINITIONS (Temporary - for testing)
-- ========================================

SkillService.Skills = {
	[1] = {
		Name = "Skill 1 (Q)",
		Cooldown = 2,
		Effect = "Test skill Q - Deal damage"
	},
	[2] = {
		Name = "Skill 2 (E)",
		Cooldown = 5,
		Effect = "Test skill E - AOE attack"
	},
	[3] = {
		Name = "Skill 3 (R)",
		Cooldown = 10,
		Effect = "Test skill R - Ultimate"
	},
	[4] = {
		Name = "Skill 4 (F)",
		Cooldown = 15,
		Effect = "Test skill F - Defensive"
	}
}

-- ========================================
-- USE SKILL
-- ========================================

function SkillService.UseSkill(player, skillSlot)
	if not player or not player.Character then
		return false, "Character not found"
	end

	-- Check if valid skill
	local skill = SkillService.Skills[skillSlot]
	if not skill then
		return false, "Invalid skill slot"
	end

	-- Check cooldown
	if not SkillService.Cooldowns[player] then
		SkillService.Cooldowns[player] = {}
	end

	local currentTime = tick()
	local cooldownEnd = SkillService.Cooldowns[player][skillSlot] or 0

	if currentTime < cooldownEnd then
		local remaining = math.ceil(cooldownEnd - currentTime)
		return false, "Cooldown: " .. remaining .. "s"
	end

	-- Execute skill (temporary test implementation)
	SkillService.ExecuteSkill(player, skillSlot, skill)

	-- Set cooldown
	SkillService.Cooldowns[player][skillSlot] = currentTime + skill.Cooldown

	return true, "Used " .. skill.Name
end

-- ========================================
-- EXECUTE SKILL (Temporary test version)
-- ========================================

function SkillService.ExecuteSkill(player, skillSlot, skill)
	local character = player.Character
	if not character or not character.PrimaryPart then return end

	print("🔥", player.Name, "used", skill.Name)

	-- Visual effect at player position
	local position = character.PrimaryPart.Position

	-- Create simple visual effect
	local effect = Instance.new("Part")
	effect.Shape = Enum.PartType.Ball
	effect.Size = Vector3.new(5, 5, 5)
	effect.Position = position + Vector3.new(0, 3, 0)
	effect.Anchored = true
	effect.CanCollide = false
	effect.Material = Enum.Material.Neon
	effect.Parent = workspace

	-- Different colors for different skills
	if skillSlot == 1 then
		effect.Color = Color3.fromRGB(255, 100, 100) -- Red
	elseif skillSlot == 2 then
		effect.Color = Color3.fromRGB(100, 100, 255) -- Blue
	elseif skillSlot == 3 then
		effect.Color = Color3.fromRGB(255, 255, 100) -- Yellow
	elseif skillSlot == 4 then
		effect.Color = Color3.fromRGB(100, 255, 100) -- Green
	end

	-- Add light
	local light = Instance.new("PointLight")
	light.Brightness = 5
	light.Range = 20
	light.Color = effect.Color
	light.Parent = effect

	-- Expand and fade animation
	task.spawn(function()
		for i = 1, 10 do
			effect.Size = effect.Size + Vector3.new(1, 1, 1)
			effect.Transparency = i / 10
			task.wait(0.05)
		end
		effect:Destroy()
	end)

	-- Damage nearby enemies (simple version)
	local damage = 50 * skillSlot  -- Higher skills do more damage

	for _, enemy in ipairs(workspace:GetChildren()) do
		if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Name ~= player.Name then
			local enemyPos = enemy.PrimaryPart and enemy.PrimaryPart.Position
			if enemyPos and (enemyPos - position).Magnitude < 15 then
				local humanoid = enemy:FindFirstChild("Humanoid")
				if humanoid and humanoid.Health > 0 then
					humanoid:TakeDamage(damage)
					print("💥", skill.Name, "hit", enemy.Name, "for", damage, "damage")
				end
			end
		end
	end

	-- Send notification to player
	SkillService.NotifyPlayer(player, "🔥 " .. skill.Name .. " - " .. skill.Effect)
end

-- ========================================
-- NOTIFY PLAYER
-- ========================================

function SkillService.NotifyPlayer(player, message)
	-- You can create a RemoteEvent for skill notifications if you want
	print("[SKILL]", player.Name, ":", message)
end

-- ========================================
-- SETUP REMOTE EVENTS
-- ========================================

function SkillService.SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if not remoteEvents then
		warn("⚠️ RemoteEvents folder not found")
		return
	end

	-- UseSkill event
	local useSkill = remoteEvents:FindFirstChild("UseSkill")
	if useSkill then
		useSkill.OnServerEvent:Connect(function(player, skillSlot)
			local success, message = SkillService.UseSkill(player, skillSlot)

			if success then
				print("✅", player.Name, "->", message)
			else
				warn("❌", player.Name, "->", message)
			end
		end)
	else
		warn("⚠️ UseSkill RemoteEvent not found")
	end
end

-- ========================================
-- CLEANUP ON PLAYER LEAVE
-- ========================================

function SkillService.SetupCleanup()
	Players.PlayerRemoving:Connect(function(player)
		SkillService.Cooldowns[player] = nil
	end)
end

-- ========================================
-- INITIALIZE
-- ========================================

function SkillService.Initialize()
	print("⚔️ SkillService initializing...")

	SkillService.SetupRemoteEvents()
	SkillService.SetupCleanup()

	print("✅ SkillService ready!")
	print("🎮 Skills available:")
	for slot, skill in pairs(SkillService.Skills) do
		print("  Slot", slot, ":", skill.Name, "-", skill.Effect)
	end
end

-- Auto-initialize
SkillService.Initialize()

return SkillService
