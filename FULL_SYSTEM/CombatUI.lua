-- CombatUI.lua - Combat, Target, Skills, Damage Numbers
-- Copy vào StarterPlayerScripts/CombatUI (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

-- Wait for modules
local SkillsModule = require(ReplicatedStorage.Modules.Skills.SkillsModule)
local HonPhienModule = require(ReplicatedStorage.Modules.MaDao.HonPhienModule)

-- RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local UseSkillEvent = RemoteEvents:WaitForChild("UseSkill")
local DamageEnemyEvent = RemoteEvents:WaitForChild("DamageEnemy")

-- ========================================
-- UI CREATION
-- ========================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CombatUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Target Frame
local targetFrame = Instance.new("Frame")
targetFrame.Name = "TargetFrame"
targetFrame.Size = UDim2.new(0, 350, 0, 90)
targetFrame.Position = UDim2.new(0.5, -175, 0, 120)
targetFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
targetFrame.BackgroundTransparency = 0.3
targetFrame.BorderSizePixel = 3
targetFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
targetFrame.Visible = false
targetFrame.Parent = screenGui

local targetCorner = Instance.new("UICorner")
targetCorner.CornerRadius = UDim.new(0, 10)
targetCorner.Parent = targetFrame

local targetName = Instance.new("TextLabel")
targetName.Name = "TargetName"
targetName.Size = UDim2.new(1, 0, 0, 35)
targetName.BackgroundTransparency = 1
targetName.Text = "Enemy Name [Lv.1]"
targetName.TextColor3 = Color3.fromRGB(255, 255, 255)
targetName.TextScaled = true
targetName.Font = Enum.Font.SourceSansBold
targetName.Parent = targetFrame

local targetHealthBg = Instance.new("Frame")
targetHealthBg.Name = "HealthBarBg"
targetHealthBg.Size = UDim2.new(0.9, 0, 0, 25)
targetHealthBg.Position = UDim2.new(0.05, 0, 0, 45)
targetHealthBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
targetHealthBg.BorderSizePixel = 0
targetHealthBg.Parent = targetFrame

local targetHealthFill = Instance.new("Frame")
targetHealthFill.Name = "Fill"
targetHealthFill.Size = UDim2.new(1, 0, 1, 0)
targetHealthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
targetHealthFill.BorderSizePixel = 0
targetHealthFill.Parent = targetHealthBg

local targetHealthText = Instance.new("TextLabel")
targetHealthText.Size = UDim2.new(1, 0, 1, 0)
targetHealthText.BackgroundTransparency = 1
targetHealthText.Text = "100%"
targetHealthText.TextColor3 = Color3.fromRGB(255, 255, 255)
targetHealthText.TextScaled = true
targetHealthText.Font = Enum.Font.SourceSansBold
targetHealthText.ZIndex = 2
targetHealthText.Parent = targetHealthBg

-- Skills Bar
local skillsBar = Instance.new("Frame")
skillsBar.Name = "SkillsBar"
skillsBar.Size = UDim2.new(0, 500, 0, 90)
skillsBar.Position = UDim2.new(0.5, -250, 1, -110)
skillsBar.BackgroundTransparency = 1
skillsBar.Parent = screenGui

-- Hồn Phiên Display (for Ma Đạo)
local honPhienFrame = Instance.new("Frame")
honPhienFrame.Name = "HonPhienFrame"
honPhienFrame.Size = UDim2.new(0, 250, 0, 60)
honPhienFrame.Position = UDim2.new(0.5, -125, 0, 230)
honPhienFrame.BackgroundColor3 = Color3.fromRGB(40, 0, 40)
honPhienFrame.BackgroundTransparency = 0.3
honPhienFrame.Visible = false
honPhienFrame.Parent = screenGui

local honPhienCorner = Instance.new("UICorner")
honPhienCorner.CornerRadius = UDim.new(0, 8)
honPhienCorner.Parent = honPhienFrame

local honPhienLabel = Instance.new("TextLabel")
honPhienLabel.Name = "HonPhienLabel"
honPhienLabel.Size = UDim2.new(1, 0, 0.5, 0)
honPhienLabel.BackgroundTransparency = 1
honPhienLabel.Text = "🩸 HỒN PHIÊN"
honPhienLabel.TextColor3 = Color3.fromRGB(200, 100, 200)
honPhienLabel.TextScaled = true
honPhienLabel.Font = Enum.Font.SourceSansBold
honPhienLabel.Parent = honPhienFrame

local honPhienSouls = Instance.new("TextLabel")
honPhienSouls.Name = "Souls"
honPhienSouls.Size = UDim2.new(1, 0, 0.5, 0)
honPhienSouls.Position = UDim2.new(0, 0, 0.5, 0)
honPhienSouls.BackgroundTransparency = 1
honPhienSouls.Text = "0 / 10 Souls"
honPhienSouls.TextColor3 = Color3.fromRGB(255, 200, 255)
honPhienSouls.TextScaled = true
honPhienSouls.Font = Enum.Font.SourceSans
honPhienSouls.Parent = honPhienFrame

-- ========================================
-- VARIABLES
-- ========================================

local currentTarget = nil
local availableSkills = {}
local skillCooldowns = {}
local skillButtons = {}

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

local function GetPlayerData()
	local dataValue = player:WaitForChild("PlayerData", 10)
	if dataValue then
		return game:GetService("HttpService"):JSONDecode(dataValue.Value)
	end
	return nil
end

local function CreateSkillButton(skill, index)
	local button = Instance.new("TextButton")
	button.Name = "Skill" .. skill.Key
	button.Size = UDim2.new(0, 80, 0, 80)
	button.Position = UDim2.new(0, (index - 1) * 95, 0, 5)
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.BorderSizePixel = 2
	button.BorderColor3 = Color3.fromRGB(100, 100, 100)
	button.Text = skill.Key
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 24
	button.Font = Enum.Font.SourceSansBold
	button.Parent = skillsBar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	-- Skill name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0, 160, 0, 20)
	nameLabel.Position = UDim2.new(0, -40, 1, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = skill.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 12
	nameLabel.Font = Enum.Font.SourceSans
	nameLabel.TextWrapped = true
	nameLabel.Parent = button

	-- Cooldown overlay
	local cooldownOverlay = Instance.new("Frame")
	cooldownOverlay.Name = "Cooldown"
	cooldownOverlay.Size = UDim2.new(1, 0, 0, 0)
	cooldownOverlay.Position = UDim2.new(0, 0, 1, 0)
	cooldownOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	cooldownOverlay.BackgroundTransparency = 0.5
	cooldownOverlay.BorderSizePixel = 0
	cooldownOverlay.ZIndex = 2
	cooldownOverlay.Parent = button

	-- Cooldown text
	local cooldownText = Instance.new("TextLabel")
	cooldownText.Name = "CooldownText"
	cooldownText.Size = UDim2.new(1, 0, 1, 0)
	cooldownText.BackgroundTransparency = 1
	cooldownText.Text = ""
	cooldownText.TextColor3 = Color3.fromRGB(255, 255, 255)
	cooldownText.TextSize = 32
	cooldownText.Font = Enum.Font.SourceSansBold
	cooldownText.ZIndex = 3
	cooldownText.Parent = button

	return button
end

local function UpdateSkillsUI()
	local playerData = GetPlayerData()
	if not playerData then return end

	-- Get available skills
	availableSkills = SkillsModule.GetAvailableSkills(playerData)

	-- Clear old buttons
	for _, button in ipairs(skillButtons) do
		button:Destroy()
	end
	skillButtons = {}

	-- Create new buttons
	for i, skill in ipairs(availableSkills) do
		if i <= 5 then -- Max 5 skills displayed
			local button = CreateSkillButton(skill, i)
			table.insert(skillButtons, button)

			-- Init cooldown
			if not skillCooldowns[skill.Key] then
				skillCooldowns[skill.Key] = 0
			end
		end
	end

	-- Show Hồn Phiên frame for Ma Đạo
	if playerData.CultivationType == "MaDao" and playerData.HonPhien.Equipped then
		honPhienFrame.Visible = true
		honPhienSouls.Text = string.format("%d / %d Souls",
			playerData.HonPhien.CurrentSouls,
			playerData.HonPhien.MaxSouls)
	else
		honPhienFrame.Visible = false
	end
end

local function ShowDamageNumber(position, damage, isCrit)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.StudsOffset = Vector3.new(math.random(-2, 2), 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = workspace

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = tostring(damage)
	label.TextColor3 = isCrit and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.TextStrokeTransparency = 0.5
	label.Parent = billboard

	billboard.Adornee = workspace.Terrain
	billboard.Position = position

	-- Animate
	TweenService:Create(label, TweenInfo.new(1.5), {
		TextTransparency = 1,
		Position = UDim2.new(0, 0, -1, 0)
	}):Play()

	game:GetService("Debris"):AddItem(billboard, 2)
end

-- ========================================
-- TARGETING
-- ========================================

mouse.Button1Down:Connect(function()
	local target = mouse.Target
	if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
		local model = target.Parent
		if model.Name ~= player.Name then
			currentTarget = model
			targetFrame.Visible = true
			targetName.Text = model.Name
			print("🎯 Targeted:", model.Name)
		end
	end
end)

-- ========================================
-- SKILL USAGE
-- ========================================

local function UseSkill(skillIndex)
	if not currentTarget or not currentTarget.Parent then
		print("❌ No target")
		return
	end

	local playerData = GetPlayerData()
	if not playerData then return end

	local skill = availableSkills[skillIndex]
	if not skill then return end

	-- Check cooldown
	local canUse, reason = SkillsModule.CanUseSkill(skill, playerData.Stats, skillCooldowns[skill.Key])
	if not canUse then
		print("❌", reason)
		return
	end

	-- Check range
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local targetHRP = currentTarget:FindFirstChild("HumanoidRootPart") or currentTarget:FindFirstChild("Body")
	if not targetHRP then return end

	local distance = (char.HumanoidRootPart.Position - targetHRP.Position).Magnitude
	if distance > skill.Range then
		print("❌ Too far! (Range:", skill.Range, ")")
		return
	end

	-- Send to server
	UseSkillEvent:FireServer(currentTarget, skill.Name)

	-- Set cooldown
	skillCooldowns[skill.Key] = tick()

	print("⚔️ Used:", skill.Name)
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.Q then
		UseSkill(1)
	elseif input.KeyCode == Enum.KeyCode.E then
		UseSkill(2)
	elseif input.KeyCode == Enum.KeyCode.R then
		UseSkill(3)
	elseif input.KeyCode == Enum.KeyCode.F then
		UseSkill(4)
	elseif input.KeyCode == Enum.KeyCode.G then
		UseSkill(5)
	end
end)

-- ========================================
-- UPDATE LOOP
-- ========================================

RunService.RenderStepped:Connect(function()
	-- Update target health
	if currentTarget and currentTarget.Parent then
		local humanoid = currentTarget:FindFirstChild("Humanoid")
		if humanoid then
			local healthPercent = humanoid.Health / humanoid.MaxHealth
			targetHealthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
			targetHealthText.Text = string.format("%.0f%%", healthPercent * 100)
		end
	else
		targetFrame.Visible = false
		currentTarget = nil
	end

	-- Update skill cooldowns
	local currentTime = tick()
	for i, skill in ipairs(availableSkills) do
		if i <= 5 and skillButtons[i] then
			local button = skillButtons[i]
			local cooldownRemaining = math.max(0, skill.Cooldown - (currentTime - skillCooldowns[skill.Key]))
			local cooldownOverlay = button:FindFirstChild("Cooldown")
			local cooldownText = button:FindFirstChild("CooldownText")

			if cooldownRemaining > 0 then
				local percent = cooldownRemaining / skill.Cooldown
				cooldownOverlay.Size = UDim2.new(1, 0, percent, 0)
				cooldownText.Text = string.format("%.1f", cooldownRemaining)
			else
				cooldownOverlay.Size = UDim2.new(1, 0, 0, 0)
				cooldownText.Text = ""
			end
		end
	end

	-- Update Hồn Phiên
	if honPhienFrame.Visible then
		local playerData = GetPlayerData()
		if playerData and playerData.HonPhien then
			honPhienSouls.Text = string.format("%d / %d Souls",
				playerData.HonPhien.CurrentSouls,
				playerData.HonPhien.MaxSouls)
		end
	end
end)

-- ========================================
-- LISTEN FOR DAMAGE EVENTS
-- ========================================

RemoteEvents:WaitForChild("ShowDamage").OnClientEvent:Connect(function(position, damage, isCrit)
	ShowDamageNumber(position, damage, isCrit)
end)

-- ========================================
-- INITIALIZATION
-- ========================================

wait(2)
UpdateSkillsUI()

print("✅ CombatUI loaded!")
