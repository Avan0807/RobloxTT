-- SkillshotCombatUI.lua - Combat UI for Skillshot System
-- Copy vào StarterPlayerScripts/SkillshotCombatUI (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for modules
local SkillsModule = require(ReplicatedStorage.Modules.Skills.SkillsModule)
local DodgeSystem = require(ReplicatedStorage.Modules.Combat.DodgeSystem)
local AimingSystem = require(player.PlayerScripts:WaitForChild("AimingSystem"))

-- RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local FireSkillEvent = RemoteEvents:WaitForChild("FireSkill")
local ShowDamageEvent = RemoteEvents:WaitForChild("ShowDamage")
local DodgeEvent = RemoteEvents:WaitForChild("Dodge")

-- ========================================
-- UI CREATION
-- ========================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SkillshotCombatUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Skills Bar
local skillsBar = Instance.new("Frame")
skillsBar.Name = "SkillsBar"
skillsBar.Size = UDim2.new(0, 500, 0, 100)
skillsBar.Position = UDim2.new(0.5, -250, 1, -120)
skillsBar.BackgroundTransparency = 1
skillsBar.Parent = screenGui

-- Mana Bar
local manaBarBg = Instance.new("Frame")
manaBarBg.Name = "ManaBarBg"
manaBarBg.Size = UDim2.new(0, 300, 0, 20)
manaBarBg.Position = UDim2.new(0.5, -150, 1, -150)
manaBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
manaBarBg.BorderSizePixel = 0
manaBarBg.Parent = screenGui

local manaBarCorner = Instance.new("UICorner")
manaBarCorner.CornerRadius = UDim.new(0, 5)
manaBarCorner.Parent = manaBarBg

local manaBar = Instance.new("Frame")
manaBar.Name = "ManaBar"
manaBar.Size = UDim2.new(1, 0, 1, 0)
manaBar.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
manaBar.BorderSizePixel = 0
manaBar.Parent = manaBarBg

local manaBarCorner2 = Instance.new("UICorner")
manaBarCorner2.CornerRadius = UDim.new(0, 5)
manaBarCorner2.Parent = manaBar

local manaLabel = Instance.new("TextLabel")
manaLabel.Size = UDim2.new(1, 0, 1, 0)
manaLabel.BackgroundTransparency = 1
manaLabel.Text = "MP: 1000/1000"
manaLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
manaLabel.TextScaled = true
manaLabel.Font = Enum.Font.SourceSansBold
manaLabel.ZIndex = 2
manaLabel.Parent = manaBarBg

-- Dodge Cooldown Indicator (for PC)
local dodgeIndicator = Instance.new("Frame")
dodgeIndicator.Name = "DodgeIndicator"
dodgeIndicator.Size = UDim2.new(0, 80, 0, 80)
dodgeIndicator.Position = UDim2.new(0, 30, 1, -200)
dodgeIndicator.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
dodgeIndicator.BorderSizePixel = 3
dodgeIndicator.BorderColor3 = Color3.fromRGB(255, 255, 255)
dodgeIndicator.Parent = screenGui

-- Hide on mobile (mobile has its own dodge button)
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	dodgeIndicator.Visible = false
end

local dodgeCorner = Instance.new("UICorner")
dodgeCorner.CornerRadius = UDim.new(1, 0)
dodgeCorner.Parent = dodgeIndicator

local dodgeText = Instance.new("TextLabel")
dodgeText.Name = "DodgeText"
dodgeText.Size = UDim2.new(1, 0, 0.5, 0)
dodgeText.BackgroundTransparency = 1
dodgeText.Text = "DASH"
dodgeText.TextColor3 = Color3.fromRGB(255, 255, 255)
dodgeText.TextScaled = true
dodgeText.Font = Enum.Font.SourceSansBold
dodgeText.Parent = dodgeIndicator

local dodgeKey = Instance.new("TextLabel")
dodgeKey.Size = UDim2.new(1, 0, 0.5, 0)
dodgeKey.Position = UDim2.new(0, 0, 0.5, 0)
dodgeKey.BackgroundTransparency = 1
dodgeKey.Text = "[SPACE]"
dodgeKey.TextColor3 = Color3.fromRGB(200, 200, 200)
dodgeKey.TextScaled = true
dodgeKey.Font = Enum.Font.SourceSans
dodgeKey.Parent = dodgeIndicator

local dodgeCooldownOverlay = Instance.new("Frame")
dodgeCooldownOverlay.Name = "Cooldown"
dodgeCooldownOverlay.Size = UDim2.new(1, 0, 0, 0)
dodgeCooldownOverlay.Position = UDim2.new(0, 0, 1, 0)
dodgeCooldownOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
dodgeCooldownOverlay.BackgroundTransparency = 0.5
dodgeCooldownOverlay.BorderSizePixel = 0
dodgeCooldownOverlay.ZIndex = 2
dodgeCooldownOverlay.Parent = dodgeIndicator

local dodgeCooldownText = Instance.new("TextLabel")
dodgeCooldownText.Name = "CooldownText"
dodgeCooldownText.Size = UDim2.new(1, 0, 1, 0)
dodgeCooldownText.BackgroundTransparency = 1
dodgeCooldownText.Text = ""
dodgeCooldownText.TextColor3 = Color3.fromRGB(255, 255, 255)
dodgeCooldownText.TextSize = 32
dodgeCooldownText.Font = Enum.Font.SourceSansBold
dodgeCooldownText.ZIndex = 3
dodgeCooldownText.Parent = dodgeIndicator

-- Stamina Bar (for PC)
local staminaBarBg = Instance.new("Frame")
staminaBarBg.Name = "StaminaBarBg"
staminaBarBg.Size = UDim2.new(0, 80, 0, 10)
staminaBarBg.Position = UDim2.new(0, 30, 1, -115)
staminaBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
staminaBarBg.BorderSizePixel = 0
staminaBarBg.Parent = screenGui

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	staminaBarBg.Visible = false
end

local staminaBar = Instance.new("Frame")
staminaBar.Name = "StaminaBar"
staminaBar.Size = UDim2.new(1, 0, 1, 0)
staminaBar.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
staminaBar.BorderSizePixel = 0
staminaBar.Parent = staminaBarBg

-- Crosshair for aiming
local crosshair = Instance.new("Frame")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.new(0, 20, 0, 20)
crosshair.Position = UDim2.new(0.5, -10, 0.5, -10)
crosshair.BackgroundTransparency = 1
crosshair.Parent = screenGui

local crosshairH = Instance.new("Frame")
crosshairH.Size = UDim2.new(1, 0, 0, 2)
crosshairH.Position = UDim2.new(0, 0, 0.5, -1)
crosshairH.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
crosshairH.BorderSizePixel = 0
crosshairH.Parent = crosshair

local crosshairV = Instance.new("Frame")
crosshairV.Size = UDim2.new(0, 2, 1, 0)
crosshairV.Position = UDim2.new(0.5, -1, 0, 0)
crosshairV.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
crosshairV.BorderSizePixel = 0
crosshairV.Parent = crosshair

-- ========================================
-- VARIABLES
-- ========================================

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
	button.Size = UDim2.new(0, 85, 0, 85)
	button.Position = UDim2.new(0, (index - 1) * 100, 0, 5)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.BorderSizePixel = 3
	button.BorderColor3 = Color3.fromRGB(100, 100, 100)
	button.Text = ""
	button.Parent = skillsBar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button

	-- Key display
	local keyLabel = Instance.new("TextLabel")
	keyLabel.Size = UDim2.new(0, 30, 0, 30)
	keyLabel.Position = UDim2.new(0, 5, 0, 5)
	keyLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	keyLabel.Text = skill.Key
	keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyLabel.TextSize = 18
	keyLabel.Font = Enum.Font.SourceSansBold
	keyLabel.Parent = button

	local keyCorner = Instance.new("UICorner")
	keyCorner.CornerRadius = UDim.new(0, 5)
	keyCorner.Parent = keyLabel

	-- Skill name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -10, 0, 20)
	nameLabel.Position = UDim2.new(0, 5, 0, 40)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = skill.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	nameLabel.TextSize = 11
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextWrapped = true
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = button

	-- Mana cost
	local manaLabel = Instance.new("TextLabel")
	manaLabel.Size = UDim2.new(1, -10, 0, 15)
	manaLabel.Position = UDim2.new(0, 5, 1, -20)
	manaLabel.BackgroundTransparency = 1
	manaLabel.Text = "MP: " .. (skill.ManaCost or 0)
	manaLabel.TextColor3 = Color3.fromRGB(100, 100, 255)
	manaLabel.TextSize = 10
	manaLabel.Font = Enum.Font.SourceSans
	manaLabel.TextXAlignment = Enum.TextXAlignment.Left
	manaLabel.Parent = button

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

	local cooldownCorner = Instance.new("UICorner")
	cooldownCorner.CornerRadius = UDim.new(0, 10)
	cooldownCorner.Parent = cooldownOverlay

	-- Cooldown text
	local cooldownText = Instance.new("TextLabel")
	cooldownText.Name = "CooldownText"
	cooldownText.Size = UDim2.new(1, 0, 1, 0)
	cooldownText.BackgroundTransparency = 1
	cooldownText.Text = ""
	cooldownText.TextColor3 = Color3.fromRGB(255, 255, 255)
	cooldownText.TextSize = 36
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

	if damage == "DODGE!" then
		label.TextColor3 = Color3.fromRGB(100, 200, 255)
		label.Text = "⚡ DODGE!"
	elseif isCrit then
		label.TextColor3 = Color3.fromRGB(255, 215, 0)
	else
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.TextStrokeTransparency = 0.5
	label.Parent = billboard

	billboard.Adornee = workspace.Terrain
	billboard.CFrame = CFrame.new(position)

	-- Animate
	TweenService:Create(label, TweenInfo.new(1.5), {
		TextTransparency = 1,
		Position = UDim2.new(0, 0, -1, 0)
	}):Play()

	game:GetService("Debris"):AddItem(billboard, 2)
end

-- ========================================
-- SKILL USAGE
-- ========================================

local function UseSkill(skillIndex)
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

	-- Get aim direction from AimingSystem
	local aimDirection = AimingSystem.CurrentAimDirection

	-- Fire skill
	FireSkillEvent:FireServer(skill.Name, aimDirection)

	-- Set cooldown
	skillCooldowns[skill.Key] = tick()

	print("🔥 Fired:", skill.Name)
end

-- ========================================
-- DODGE HANDLING
-- ========================================

local function PerformDodge()
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return
	end

	-- Get dodge direction based on movement or aim
	local direction

	-- Check if moving
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid.MoveDirection.Magnitude > 0.1 then
		-- Dodge in movement direction
		direction = humanoid.MoveDirection
	else
		-- Dodge in aim direction
		direction = AimingSystem.CurrentAimDirection
	end

	-- Fire dodge event
	DodgeEvent:FireServer(direction)
	print("✨ Dodging!")
end

-- ========================================
-- INPUT HANDLING
-- ========================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	-- Skills
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
	-- Dodge
	elseif input.KeyCode == Enum.KeyCode.Space then
		PerformDodge()
	end
end)

-- ========================================
-- UPDATE LOOP
-- ========================================

RunService.RenderStepped:Connect(function()
	local playerData = GetPlayerData()
	if not playerData or not playerData.Stats then
		return
	end

	local stats = playerData.Stats

	-- Update mana bar
	local manaPercent = stats.MP / stats.MaxMP
	manaBar.Size = UDim2.new(manaPercent, 0, 1, 0)
	manaLabel.Text = string.format("MP: %d/%d", stats.MP, stats.MaxMP)

	-- Update skill cooldowns
	local currentTime = tick()
	for i, skill in ipairs(availableSkills) do
		if i <= 5 and skillButtons[i] then
			local button = skillButtons[i]
			local cooldownRemaining = math.max(0, skill.Cooldown - (currentTime - (skillCooldowns[skill.Key] or 0)))
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

	-- Update dodge indicator
	local stamina, maxStamina, cooldown = DodgeSystem.GetStaminaInfo(player)

	-- Update stamina bar
	staminaBar.Size = UDim2.new(stamina / maxStamina, 0, 1, 0)

	-- Update dodge cooldown
	if cooldown > 0 then
		local percent = cooldown / DodgeSystem.DODGE_COOLDOWN
		dodgeCooldownOverlay.Size = UDim2.new(1, 0, percent, 0)
		dodgeCooldownText.Text = string.format("%.1f", cooldown)
		dodgeIndicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	elseif stamina < DodgeSystem.STAMINA_COST then
		-- Not enough stamina
		dodgeCooldownOverlay.Size = UDim2.new(1, 0, 0, 0)
		dodgeCooldownText.Text = ""
		dodgeIndicator.BackgroundColor3 = Color3.fromRGB(150, 100, 100)
	else
		-- Ready to dodge
		dodgeCooldownOverlay.Size = UDim2.new(1, 0, 0, 0)
		dodgeCooldownText.Text = ""
		dodgeIndicator.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
	end
end)

-- ========================================
-- LISTEN FOR DAMAGE EVENTS
-- ========================================

ShowDamageEvent.OnClientEvent:Connect(function(position, damage, isCrit)
	ShowDamageNumber(position, damage, isCrit)
end)

-- ========================================
-- INITIALIZATION
-- ========================================

wait(2)
UpdateSkillsUI()

print("✅ SkillshotCombatUI loaded!")
