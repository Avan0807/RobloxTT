-- HonPhienAdvancedUI.lua - Hồn Phiên Advanced UI
-- Copy vào StarterPlayer/StarterPlayerScripts/HonPhienAdvancedUI (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local HonPhienAdvanced = require(ReplicatedStorage.Modules.HonPhien.HonPhienAdvanced)

-- ========================================
-- UI VARIABLES
-- ========================================

local honPhienUI
local isOpen = false

local currentSouls = 0
local activeBuff = nil
local skillCooldowns = {}

-- ========================================
-- CREATE UI
-- ========================================

local function CreateUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HonPhienAdvancedUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Main Frame (Hidden by default)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 700, 0, 500)
	mainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	mainFrame.BorderSizePixel = 0
	mainFrame.Visible = false
	mainFrame.Parent = screenGui

	-- Corner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = mainFrame

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 50)
	title.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
	title.BorderSizePixel = 0
	title.Font = Enum.Font.GothamBold
	title.Text = "👻 HỒN PHIÊN ADVANCED"
	title.TextColor3 = Color3.fromRGB(255, 200, 255)
	title.TextSize = 24
	title.Parent = mainFrame

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 10)
	titleCorner.Parent = title

	-- Close Button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -45, 0, 5)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 20
	closeButton.Parent = mainFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 5)
	closeCorner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		ToggleUI()
	end)

	-- Soul Counter
	local soulCounter = Instance.new("TextLabel")
	soulCounter.Name = "SoulCounter"
	soulCounter.Size = UDim2.new(1, -20, 0, 30)
	soulCounter.Position = UDim2.new(0, 10, 0, 60)
	soulCounter.BackgroundTransparency = 1
	soulCounter.Font = Enum.Font.GothamBold
	soulCounter.Text = "💀 Linh Hồn: 0"
	soulCounter.TextColor3 = Color3.fromRGB(200, 100, 255)
	soulCounter.TextSize = 18
	soulCounter.TextXAlignment = Enum.TextXAlignment.Left
	soulCounter.Parent = mainFrame

	-- Passive Buff Display
	local passiveBuff = Instance.new("TextLabel")
	passiveBuff.Name = "PassiveBuff"
	passiveBuff.Size = UDim2.new(1, -20, 0, 25)
	passiveBuff.Position = UDim2.new(0, 10, 0, 95)
	passiveBuff.BackgroundTransparency = 1
	passiveBuff.Font = Enum.Font.Gotham
	passiveBuff.Text = "📈 Passive Buff: +0%"
	passiveBuff.TextColor3 = Color3.fromRGB(150, 255, 150)
	passiveBuff.TextSize = 14
	passiveBuff.TextXAlignment = Enum.TextXAlignment.Left
	passiveBuff.Parent = mainFrame

	-- Active Buff Display
	local activeBuff = Instance.new("TextLabel")
	activeBuff.Name = "ActiveBuff"
	activeBuff.Size = UDim2.new(1, -20, 0, 25)
	activeBuff.Position = UDim2.new(0, 10, 0, 120)
	activeBuff.BackgroundTransparency = 1
	activeBuff.Font = Enum.Font.Gotham
	activeBuff.Text = "⏰ Active Buff: None"
	activeBuff.TextColor3 = Color3.fromRGB(255, 200, 100)
	activeBuff.TextSize = 14
	activeBuff.TextXAlignment = Enum.TextXAlignment.Left
	activeBuff.Parent = mainFrame

	-- Divider 1
	local divider1 = Instance.new("Frame")
	divider1.Name = "Divider1"
	divider1.Size = UDim2.new(1, -20, 0, 2)
	divider1.Position = UDim2.new(0, 10, 0, 150)
	divider1.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
	divider1.BorderSizePixel = 0
	divider1.Parent = mainFrame

	-- Tế Lễ Buffs Section
	local teLeTitle = Instance.new("TextLabel")
	teLeTitle.Name = "TeLeTitle"
	teLeTitle.Size = UDim2.new(1, -20, 0, 30)
	teLeTitle.Position = UDim2.new(0, 10, 0, 160)
	teLeTitle.BackgroundTransparency = 1
	teLeTitle.Font = Enum.Font.GothamBold
	teLeTitle.Text = "🔥 TẾ LỄ BUFFS (Sacrifice Souls)"
	teLeTitle.TextColor3 = Color3.fromRGB(255, 150, 0)
	teLeTitle.TextSize = 16
	teLeTitle.TextXAlignment = Enum.TextXAlignment.Left
	teLeTitle.Parent = mainFrame

	-- Tế Lễ ScrollFrame
	local teLeScroll = Instance.new("ScrollingFrame")
	teLeScroll.Name = "TeLeScroll"
	teLeScroll.Size = UDim2.new(1, -20, 0, 100)
	teLeScroll.Position = UDim2.new(0, 10, 0, 195)
	teLeScroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	teLeScroll.BorderSizePixel = 0
	teLeScroll.ScrollBarThickness = 6
	teLeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	teLeScroll.Parent = mainFrame

	local teLeCorner = Instance.new("UICorner")
	teLeCorner.CornerRadius = UDim.new(0, 5)
	teLeCorner.Parent = teLeScroll

	local teLeLayout = Instance.new("UIListLayout")
	teLeLayout.Padding = UDim.new(0, 5)
	teLeLayout.Parent = teLeScroll

	-- Divider 2
	local divider2 = Instance.new("Frame")
	divider2.Name = "Divider2"
	divider2.Size = UDim2.new(1, -20, 0, 2)
	divider2.Position = UDim2.new(0, 10, 0, 305)
	divider2.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
	divider2.BorderSizePixel = 0
	divider2.Parent = mainFrame

	-- Special Skills Section
	local skillTitle = Instance.new("TextLabel")
	skillTitle.Name = "SkillTitle"
	skillTitle.Size = UDim2.new(1, -20, 0, 30)
	skillTitle.Position = UDim2.new(0, 10, 0, 315)
	skillTitle.BackgroundTransparency = 1
	skillTitle.Font = Enum.Font.GothamBold
	skillTitle.Text = "⚡ SPECIAL SKILLS"
	skillTitle.TextColor3 = Color3.fromRGB(255, 100, 255)
	skillTitle.TextSize = 16
	skillTitle.TextXAlignment = Enum.TextXAlignment.Left
	skillTitle.Parent = mainFrame

	-- Skills ScrollFrame
	local skillScroll = Instance.new("ScrollingFrame")
	skillScroll.Name = "SkillScroll"
	skillScroll.Size = UDim2.new(1, -20, 0, 140)
	skillScroll.Position = UDim2.new(0, 10, 0, 350)
	skillScroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	skillScroll.BorderSizePixel = 0
	skillScroll.ScrollBarThickness = 6
	skillScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	skillScroll.Parent = mainFrame

	local skillCorner = Instance.new("UICorner")
	skillCorner.CornerRadius = UDim.new(0, 5)
	skillCorner.Parent = skillScroll

	local skillLayout = Instance.new("UIListLayout")
	skillLayout.Padding = UDim.new(0, 5)
	skillLayout.Parent = skillScroll

	return screenGui
end

-- ========================================
-- CREATE TẾ LỄ BUFF BUTTON
-- ========================================

local function CreateTeLeButton(buffIndex, buff)
	local button = Instance.new("TextButton")
	button.Name = "TeLeBuff_" .. buffIndex
	button.Size = UDim2.new(1, -10, 0, 35)
	button.BackgroundColor3 = Color3.fromRGB(50, 0, 80)
	button.Font = Enum.Font.Gotham
	button.Text = buff.Name .. " | Cost: " .. buff.SoulCost .. " 💀"
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 14
	button.Parent = honPhienUI.MainFrame.TeLeScroll

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = button

	button.MouseButton1Click:Connect(function()
		-- Send to server
		local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
			and ReplicatedStorage.RemoteEvents:FindFirstChild("UseTeLeBuff")

		if remoteEvent then
			remoteEvent:FireServer(buffIndex)
		end
	end)

	return button
end

-- ========================================
-- CREATE SKILL BUTTON
-- ========================================

local function CreateSkillButton(skill)
	local button = Instance.new("TextButton")
	button.Name = "Skill_" .. skill.SkillID
	button.Size = UDim2.new(1, -10, 0, 45)
	button.BackgroundColor3 = Color3.fromRGB(80, 0, 50)
	button.Font = Enum.Font.Gotham
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 13
	button.TextWrapped = true
	button.Parent = honPhienUI.MainFrame.SkillScroll

	-- Title
	local titleText = skill.Name
	if skill.SoulCost then
		if skill.SoulCost == "All" then
			titleText = titleText .. " | Cost: ALL SOULS"
		else
			titleText = titleText .. " | Cost: " .. skill.SoulCost .. " 💀"
		end
	end
	titleText = titleText .. " | CD: " .. skill.Cooldown .. "s"

	button.Text = titleText .. "\n" .. skill.Description

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = button

	button.MouseButton1Click:Connect(function()
		-- Check cooldown
		if skillCooldowns[skill.SkillID] and os.time() < skillCooldowns[skill.SkillID] then
			local remaining = skillCooldowns[skill.SkillID] - os.time()
			print("⏰ Skill on cooldown! " .. math.ceil(remaining) .. "s remaining")
			return
		end

		-- Send to server
		local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
			and ReplicatedStorage.RemoteEvents:FindFirstChild("UseHonPhienSkill")

		if remoteEvent then
			remoteEvent:FireServer(skill.SkillID)
		end
	end)

	return button
end

-- ========================================
-- POPULATE TẾ LỄ BUFFS
-- ========================================

local function PopulateTeLeBuffs()
	-- Clear existing
	for _, child in ipairs(honPhienUI.MainFrame.TeLeScroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	-- Create buttons
	for i, buff in ipairs(HonPhienAdvanced.TeLeBuffs) do
		CreateTeLeButton(i, buff)
	end

	-- Update canvas size
	honPhienUI.MainFrame.TeLeScroll.CanvasSize = UDim2.new(0, 0, 0, #HonPhienAdvanced.TeLeBuffs * 40)
end

-- ========================================
-- POPULATE SPECIAL SKILLS
-- ========================================

local function PopulateSkills()
	-- Clear existing
	for _, child in ipairs(honPhienUI.MainFrame.SkillScroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	-- Get player data (simplified - should be synced from server)
	-- For now, show all skills
	for _, skill in ipairs(HonPhienAdvanced.SpecialSkills) do
		CreateSkillButton(skill)
	end

	-- Update canvas size
	honPhienUI.MainFrame.SkillScroll.CanvasSize = UDim2.new(0, 0, 0, #HonPhienAdvanced.SpecialSkills * 50)
end

-- ========================================
-- UPDATE DISPLAYS
-- ========================================

local function UpdateDisplays()
	if not honPhienUI or not honPhienUI.MainFrame then return end

	-- Update soul counter
	honPhienUI.MainFrame.SoulCounter.Text = "💀 Linh Hồn: " .. currentSouls

	-- Update passive buff
	local passiveBuff = HonPhienAdvanced.GetPassiveBuff(currentSouls)
	honPhienUI.MainFrame.PassiveBuff.Text = "📈 Passive Buff: +" .. math.floor(passiveBuff * 100) .. "% Stats"

	-- Update active buff
	if activeBuff then
		local remaining = math.ceil(activeBuff.EndTime - os.time())
		if remaining > 0 then
			honPhienUI.MainFrame.ActiveBuff.Text = "⏰ Active: " .. activeBuff.Name .. " (" .. remaining .. "s)"
		else
			activeBuff = nil
			honPhienUI.MainFrame.ActiveBuff.Text = "⏰ Active Buff: None"
		end
	else
		honPhienUI.MainFrame.ActiveBuff.Text = "⏰ Active Buff: None"
	end
end

-- ========================================
-- TOGGLE UI
-- ========================================

function ToggleUI()
	if not honPhienUI then
		honPhienUI = CreateUI()
		PopulateTeLeBuffs()
		PopulateSkills()
	end

	isOpen = not isOpen
	honPhienUI.MainFrame.Visible = isOpen

	if isOpen then
		UpdateDisplays()
	end
end

-- ========================================
-- SYNC FROM SERVER
-- ========================================

local function OnSyncHonPhien(data)
	if data.Souls then
		currentSouls = data.Souls
	end

	if data.ActiveBuff then
		activeBuff = data.ActiveBuff
	end

	if data.Cooldowns then
		skillCooldowns = data.Cooldowns
	end

	UpdateDisplays()
end

-- ========================================
-- LISTEN FOR REMOTE EVENTS
-- ========================================

local function SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	if not remoteEvents then
		warn("RemoteEvents folder not found!")
		return
	end

	-- Sync Hồn Phiên Data
	local syncEvent = remoteEvents:FindFirstChild("SyncHonPhienData")
	if syncEvent then
		syncEvent.OnClientEvent:Connect(OnSyncHonPhien)
	end

	-- Sync Buffs
	local syncBuffs = remoteEvents:FindFirstChild("SyncHonPhienBuffs")
	if syncBuffs then
		syncBuffs.OnClientEvent:Connect(function(buffs)
			if buffs and #buffs > 0 then
				activeBuff = buffs[1] -- Take first buff
			else
				activeBuff = nil
			end
			UpdateDisplays()
		end)
	end

	-- Notifications
	local notifEvent = remoteEvents:FindFirstChild("HonPhienNotification")
	if notifEvent then
		notifEvent.OnClientEvent:Connect(function(message)
			print(message)
		end)
	end
end

-- ========================================
-- INPUT HANDLER
-- ========================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.H then
		ToggleUI()
	end
end)

-- ========================================
-- UPDATE LOOP
-- ========================================

task.spawn(function()
	while true do
		task.wait(1)
		if isOpen then
			UpdateDisplays()
		end
	end
end)

-- ========================================
-- INITIALIZE
-- ========================================

print("👻 HonPhienAdvancedUI loaded! Press 'H' to open")

-- Setup remote events
SetupRemoteEvents()
