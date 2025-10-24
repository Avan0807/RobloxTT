-- StatsUI.lua - Hiển Thị Stats Player
-- Copy vào StarterPlayerScripts/StatsUI (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ========================================
-- UI CREATION
-- ========================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatsUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "StatsFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 300)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "📊 CHỈ SỐ"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Stats Container
local statsContainer = Instance.new("ScrollingFrame")
statsContainer.Name = "StatsContainer"
statsContainer.Size = UDim2.new(1, -10, 1, -50)
statsContainer.Position = UDim2.new(0, 5, 0, 45)
statsContainer.BackgroundTransparency = 1
statsContainer.BorderSizePixel = 0
statsContainer.ScrollBarThickness = 6
statsContainer.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = statsContainer

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

local function CreateStatLabel(name, value, color)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -10, 0, 25)
	frame.BackgroundTransparency = 1

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name .. ":"
	nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.SourceSans
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = frame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Name = "Value"
	valueLabel.Size = UDim2.new(0.5, 0, 1, 0)
	valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(value)
	valueLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	valueLabel.TextScaled = true
	valueLabel.Font = Enum.Font.SourceSansBold
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = frame

	return frame
end

local statLabels = {}

local function CreateStatsUI()
	-- Clear existing
	for _, child in ipairs(statsContainer:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	statLabels = {}

	-- HP
	statLabels.HP = CreateStatLabel("HP", "0/0", Color3.fromRGB(255, 100, 100))
	statLabels.HP.Parent = statsContainer

	-- MP
	statLabels.MP = CreateStatLabel("MP", "0/0", Color3.fromRGB(100, 100, 255))
	statLabels.MP.Parent = statsContainer

	-- Magic Damage
	statLabels.MagicDamage = CreateStatLabel("⚡ Magic Dmg", "0", Color3.fromRGB(150, 200, 255))
	statLabels.MagicDamage.Parent = statsContainer

	-- Physical Damage
	statLabels.PhysicalDamage = CreateStatLabel("💪 Phys Dmg", "0", Color3.fromRGB(255, 200, 100))
	statLabels.PhysicalDamage.Parent = statsContainer

	-- Soul Damage
	statLabels.SoulDamage = CreateStatLabel("🩸 Soul Dmg", "0", Color3.fromRGB(200, 100, 200))
	statLabels.SoulDamage.Parent = statsContainer

	-- Defense
	statLabels.Defense = CreateStatLabel("🛡️ Defense", "0", Color3.fromRGB(200, 200, 100))
	statLabels.Defense.Parent = statsContainer

	-- Magic Defense
	statLabels.MagicDefense = CreateStatLabel("✨ Magic Def", "0", Color3.fromRGB(150, 150, 200))
	statLabels.MagicDefense.Parent = statsContainer

	-- Speed
	statLabels.Speed = CreateStatLabel("⚡ Speed", "0", Color3.fromRGB(255, 255, 100))
	statLabels.Speed.Parent = statsContainer

	-- Crit Rate
	statLabels.CritRate = CreateStatLabel("💥 Crit Rate", "0%", Color3.fromRGB(255, 150, 50))
	statLabels.CritRate.Parent = statsContainer

	-- Crit Damage
	statLabels.CritDamage = CreateStatLabel("💢 Crit Dmg", "0%", Color3.fromRGB(255, 100, 50))
	statLabels.CritDamage.Parent = statsContainer

	-- Lifesteal
	statLabels.Lifesteal = CreateStatLabel("🩸 Lifesteal", "0%", Color3.fromRGB(200, 50, 50))
	statLabels.Lifesteal.Parent = statsContainer

	-- Update canvas size
	statsContainer.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end

local function GetPlayerData()
	local dataValue = player:WaitForChild("PlayerData", 10)
	if dataValue then
		return game:GetService("HttpService"):JSONDecode(dataValue.Value)
	end
	return nil
end

local function UpdateStats()
	local playerData = GetPlayerData()
	if not playerData or not playerData.Stats then
		return
	end

	local stats = playerData.Stats

	-- Update HP
	if statLabels.HP then
		statLabels.HP.Value.Text = string.format("%d / %d", stats.HP or 0, stats.MaxHP or 0)
	end

	-- Update MP
	if statLabels.MP then
		statLabels.MP.Value.Text = string.format("%d / %d", stats.MP or 0, stats.MaxMP or 0)
	end

	-- Update damages
	if statLabels.MagicDamage then
		statLabels.MagicDamage.Value.Text = tostring(stats.MagicDamage or 0)
	end
	if statLabels.PhysicalDamage then
		statLabels.PhysicalDamage.Value.Text = tostring(stats.PhysicalDamage or 0)
	end
	if statLabels.SoulDamage then
		statLabels.SoulDamage.Value.Text = tostring(stats.SoulDamage or 0)
	end

	-- Update defenses
	if statLabels.Defense then
		statLabels.Defense.Value.Text = tostring(stats.Defense or 0)
	end
	if statLabels.MagicDefense then
		statLabels.MagicDefense.Value.Text = tostring(stats.MagicDefense or 0)
	end

	-- Update speed
	if statLabels.Speed then
		statLabels.Speed.Value.Text = tostring(stats.Speed or 0)
	end

	-- Update crit
	if statLabels.CritRate then
		statLabels.CritRate.Value.Text = string.format("%.1f%%", (stats.CritRate or 0) * 100)
	end
	if statLabels.CritDamage then
		statLabels.CritDamage.Value.Text = string.format("%.0f%%", (stats.CritDamage or 1) * 100)
	end

	-- Update lifesteal
	if statLabels.Lifesteal then
		statLabels.Lifesteal.Value.Text = string.format("%.0f%%", (stats.Lifesteal or 0) * 100)
	end
end

-- ========================================
-- INITIALIZATION
-- ========================================

CreateStatsUI()
wait(2)
UpdateStats()

-- Update every 2 seconds
spawn(function()
	while wait(2) do
		UpdateStats()
	end
end)

print("✅ StatsUI loaded!")
