-- MobileSkillButtons.lua - Mobile skill buttons for combat
-- Copy vào StarterPlayerScripts/MobileSkillButtons (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Chỉ hiện trên Mobile
if not UserInputService.TouchEnabled then
	return -- PC dùng Hồn Phiên UI
end

-- ========================================
-- CREATE SKILL UI
-- ========================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileSkillButtons"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ========================================
-- SKILL BUTTONS CONTAINER (Top Right)
-- ========================================

local skillContainer = Instance.new("Frame")
skillContainer.Name = "SkillContainer"
skillContainer.Size = UDim2.new(0, 350, 0, 100)
skillContainer.Position = UDim2.new(1, -360, 0, 10)
skillContainer.BackgroundTransparency = 1
skillContainer.Parent = screenGui

-- ========================================
-- HỒNG PHIÊN SPECIAL SKILLS (Quick Access)
-- ========================================

local quickSkills = {
	{
		ID = "hon_hai_man_thien",
		Name = "Hồn Hải",
		Icon = "🌊",
		Color = Color3.fromRGB(150, 0, 200),
		Cooldown = 30
	},
	{
		ID = "thi_hon",
		Name = "Thị Hồn",
		Icon = "❤️",
		Color = Color3.fromRGB(255, 0, 100),
		Cooldown = 60
	},
	{
		ID = "ma_vuc_trien_khai",
		Name = "Ma Vực",
		Icon = "🌑",
		Color = Color3.fromRGB(80, 0, 120),
		Cooldown = 120
	},
	{
		ID = "ma_hoang_hoa_than",
		Name = "Hóa Thân",
		Icon = "👹",
		Color = Color3.fromRGB(200, 0, 0),
		Cooldown = 300
	}
}

local skillButtons = {}
local skillCooldowns = {}

-- ========================================
-- CREATE SKILL BUTTONS
-- ========================================

for i, skill in ipairs(quickSkills) do
	local button = Instance.new("TextButton")
	button.Name = skill.ID
	button.Size = UDim2.new(0, 80, 0, 80)
	button.Position = UDim2.new(0, (i - 1) * 85, 0, 0)
	button.BackgroundColor3 = skill.Color
	button.BorderSizePixel = 0
	button.Text = skill.Icon
	button.TextSize = 35
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Parent = skillContainer

	-- Corner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = button

	-- Stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 2
	stroke.Transparency = 0.7
	stroke.Parent = button

	-- Skill name label
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 20)
	nameLabel.Position = UDim2.new(0, 0, 1, -20)
	nameLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.BackgroundTransparency = 0.5
	nameLabel.BorderSizePixel = 0
	nameLabel.Text = skill.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 12
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = button

	-- Cooldown overlay
	local cooldownOverlay = Instance.new("Frame")
	cooldownOverlay.Name = "Cooldown"
	cooldownOverlay.Size = UDim2.new(1, 0, 0, 0)
	cooldownOverlay.Position = UDim2.new(0, 0, 1, 0)
	cooldownOverlay.AnchorPoint = Vector2.new(0, 1)
	cooldownOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	cooldownOverlay.BackgroundTransparency = 0.7
	cooldownOverlay.BorderSizePixel = 0
	cooldownOverlay.Visible = false
	cooldownOverlay.ZIndex = 2
	cooldownOverlay.Parent = button

	local cooldownCorner = Instance.new("UICorner")
	cooldownCorner.CornerRadius = UDim.new(0, 12)
	cooldownCorner.Parent = cooldownOverlay

	-- Cooldown text
	local cooldownText = Instance.new("TextLabel")
	cooldownText.Name = "CooldownText"
	cooldownText.Size = UDim2.new(1, 0, 1, 0)
	cooldownText.BackgroundTransparency = 1
	cooldownText.Text = "0s"
	cooldownText.TextColor3 = Color3.fromRGB(255, 255, 255)
	cooldownText.TextSize = 20
	cooldownText.Font = Enum.Font.GothamBold
	cooldownText.ZIndex = 3
	cooldownText.Parent = button

	-- Button click
	button.MouseButton1Click:Connect(function()
		UseSkill(skill.ID, button)
	end)

	skillButtons[skill.ID] = button
end

-- ========================================
-- USE SKILL
-- ========================================

function UseSkill(skillID, button)
	-- Check cooldown
	if skillCooldowns[skillID] and os.time() < skillCooldowns[skillID] then
		local remaining = skillCooldowns[skillID] - os.time()
		print("⏰ Skill on cooldown! " .. math.ceil(remaining) .. "s remaining")
		return
	end

	-- Fire to server
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("UseHonPhienSkill")

	if remoteEvent then
		remoteEvent:FireServer(skillID)

		-- Visual feedback
		button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		task.wait(0.1)

		-- Find original color
		for _, skill in ipairs(quickSkills) do
			if skill.ID == skillID then
				button.BackgroundColor3 = skill.Color

				-- Start cooldown
				skillCooldowns[skillID] = os.time() + skill.Cooldown
				UpdateCooldown(skillID, button, skill.Cooldown)
				break
			end
		end
	end
end

-- ========================================
-- UPDATE COOLDOWN DISPLAY
-- ========================================

function UpdateCooldown(skillID, button, maxCooldown)
	local cooldownOverlay = button:FindFirstChild("Cooldown")
	local cooldownText = button:FindFirstChild("CooldownText")

	if not cooldownOverlay or not cooldownText then return end

	cooldownOverlay.Visible = true

	task.spawn(function()
		while skillCooldowns[skillID] and os.time() < skillCooldowns[skillID] do
			local remaining = skillCooldowns[skillID] - os.time()
			local progress = remaining / maxCooldown

			-- Update overlay height
			cooldownOverlay.Size = UDim2.new(1, 0, progress, 0)

			-- Update text
			if remaining > 60 then
				cooldownText.Text = math.ceil(remaining / 60) .. "m"
			else
				cooldownText.Text = math.ceil(remaining) .. "s"
			end

			task.wait(0.1)
		end

		-- Cooldown done
		cooldownOverlay.Visible = false
		cooldownText.Text = ""
		skillCooldowns[skillID] = nil

		-- Flash effect
		for i = 1, 3 do
			button.BackgroundTransparency = 0.5
			task.wait(0.1)
			button.BackgroundTransparency = 0
			task.wait(0.1)
		end
	end)
end

-- ========================================
-- TẾ LỄ QUICK ACCESS (Bottom of screen)
-- ========================================

local teLeContainer = Instance.new("Frame")
teLeContainer.Name = "TeLeContainer"
teLeContainer.Size = UDim2.new(0, 300, 0, 60)
teLeContainer.Position = UDim2.new(0.5, -150, 1, -220)
teLeContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
teLeContainer.BackgroundTransparency = 0.3
teLeContainer.BorderSizePixel = 0
teLeContainer.Parent = screenGui

local teLeCorner = Instance.new("UICorner")
teLeCorner.CornerRadius = UDim.new(0, 10)
teLeCorner.Parent = teLeContainer

-- Tế Lễ title
local teLeTitle = Instance.new("TextLabel")
teLeTitle.Size = UDim2.new(1, 0, 0, 20)
teLeTitle.Position = UDim2.new(0, 0, 0, 5)
teLeTitle.BackgroundTransparency = 1
teLeTitle.Text = "🔥 TẾ LỄ QUICK ACCESS"
teLeTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
teLeTitle.TextSize = 12
teLeTitle.Font = Enum.Font.GothamBold
teLeTitle.Parent = teLeContainer

-- Tế Lễ buttons
local teLeButtons = {
	{Index = 1, Name = "+50% DMG", Cost = 100, Icon = "⚔️"},
	{Index = 2, Name = "Boss", Cost = 500, Icon = "👻"},
	{Index = 3, Name = "2x Stats", Cost = 1000, Icon = "💪"},
}

for i, teLe in ipairs(teLeButtons) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 90, 0, 30)
	btn.Position = UDim2.new(0, 5 + (i - 1) * 95, 0, 27)
	btn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
	btn.BorderSizePixel = 0
	btn.Text = teLe.Icon .. " " .. teLe.Cost
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.Parent = teLeContainer

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		-- Fire to server
		local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
			and ReplicatedStorage.RemoteEvents:FindFirstChild("UseTeLeBuff")

		if remoteEvent then
			remoteEvent:FireServer(teLe.Index)

			-- Visual feedback
			btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			task.wait(0.1)
			btn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
		end
	end)
end

-- ========================================
-- SOUL COUNTER (Quick view)
-- ========================================

local soulCounter = Instance.new("Frame")
soulCounter.Name = "SoulCounter"
soulCounter.Size = UDim2.new(0, 150, 0, 40)
soulCounter.Position = UDim2.new(0.5, -75, 1, -280)
soulCounter.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
soulCounter.BorderSizePixel = 0
soulCounter.Parent = screenGui

local soulCorner = Instance.new("UICorner")
soulCorner.CornerRadius = UDim.new(0, 10)
soulCorner.Parent = soulCounter

local soulLabel = Instance.new("TextLabel")
soulLabel.Size = UDim2.new(1, -10, 1, 0)
soulLabel.Position = UDim2.new(0, 5, 0, 0)
soulLabel.BackgroundTransparency = 1
soulLabel.Text = "💀 Souls: 0"
soulLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
soulLabel.TextSize = 18
soulLabel.Font = Enum.Font.GothamBold
soulLabel.Parent = soulCounter

-- Update soul count
task.spawn(function()
	while wait(1) do
		local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
			and ReplicatedStorage.RemoteEvents:FindFirstChild("SyncHonPhienData")

		if remoteEvent then
			-- This should be updated by server sync
			-- For now, just placeholder
		end
	end
end)

-- Listen for soul updates
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if remoteEvents then
	local syncEvent = remoteEvents:FindFirstChild("SyncHonPhienData")
	if syncEvent then
		syncEvent.OnClientEvent:Connect(function(data)
			if data and data.Souls then
				soulLabel.Text = "💀 Souls: " .. data.Souls
			end
		end)
	end
end

-- ========================================
-- HIDE SKILLS FOR NON-MA ĐẠO
-- ========================================

local function CheckMaDao()
	-- Wait for player data sync
	task.wait(2)

	local syncEvent = remoteEvents and remoteEvents:FindFirstChild("SyncPlayerData")
	if syncEvent then
		syncEvent.OnClientEvent:Connect(function(data)
			if data and data.CultivationType then
				local isMaDao = (data.CultivationType == "MaDao")

				skillContainer.Visible = isMaDao
				teLeContainer.Visible = isMaDao
				soulCounter.Visible = isMaDao
			end
		end)
	end
end

CheckMaDao()

-- ========================================
-- TOGGLE SKILLS (Double tap soul counter)
-- ========================================

local lastTap = 0
soulCounter.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		local now = tick()
		if now - lastTap < 0.3 then
			-- Double tap - toggle skills
			skillContainer.Visible = not skillContainer.Visible
			teLeContainer.Visible = not teLeContainer.Visible
		end
		lastTap = now
	end
end)

print("✅ MobileSkillButtons loaded (4 skills + 3 Tế Lễ)")
