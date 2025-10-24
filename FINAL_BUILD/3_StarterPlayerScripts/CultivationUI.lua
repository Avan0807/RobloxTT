-- CultivationUI.lua - UI Chính Cho Hệ Thống Tu Luyện
-- Copy vào StarterPlayerScripts/CultivationUI (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for modules
local RealmCalculator = require(ReplicatedStorage.Modules.Stats.RealmCalculator)
local CultivationModule = require(ReplicatedStorage.Modules.Cultivation.CultivationModule)

-- RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local LevelUpEvent = RemoteEvents:WaitForChild("LevelUp")
local BreakthroughEvent = RemoteEvents:WaitForChild("Breakthrough")
local MeditateEvent = RemoteEvents:WaitForChild("StartMeditation")

-- ========================================
-- UI CREATION
-- ========================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CultivationUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(1, -420, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
mainFrame.Parent = screenGui

-- Corner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "🌟 TU LUYỆN"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Cultivation Type Label
local cultTypeLabel = Instance.new("TextLabel")
cultTypeLabel.Name = "CultTypeLabel"
cultTypeLabel.Size = UDim2.new(1, -20, 0, 30)
cultTypeLabel.Position = UDim2.new(0, 10, 0, 60)
cultTypeLabel.BackgroundTransparency = 1
cultTypeLabel.Text = "Hệ: Tiên Thiên"
cultTypeLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
cultTypeLabel.TextScaled = true
cultTypeLabel.Font = Enum.Font.SourceSansBold
cultTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
cultTypeLabel.Parent = mainFrame

-- Realm Display
local realmLabel = Instance.new("TextLabel")
realmLabel.Name = "RealmLabel"
realmLabel.Size = UDim2.new(1, -20, 0, 40)
realmLabel.Position = UDim2.new(0, 10, 0, 100)
realmLabel.BackgroundTransparency = 1
realmLabel.Text = "Ngưng Khí Tầng 1"
realmLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
realmLabel.TextScaled = true
realmLabel.Font = Enum.Font.SourceSansBold
realmLabel.Parent = mainFrame

-- Tu Vi Display
local tuViLabel = Instance.new("TextLabel")
tuViLabel.Name = "TuViLabel"
tuViLabel.Size = UDim2.new(1, -20, 0, 25)
tuViLabel.Position = UDim2.new(0, 10, 0, 150)
tuViLabel.BackgroundTransparency = 1
tuViLabel.Text = "Tu Vi: 0 / 1000"
tuViLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
tuViLabel.TextScaled = true
tuViLabel.Font = Enum.Font.SourceSans
tuViLabel.TextXAlignment = Enum.TextXAlignment.Left
tuViLabel.Parent = mainFrame

-- Tu Vi Progress Bar
local tuViBarBg = Instance.new("Frame")
tuViBarBg.Name = "TuViBarBg"
tuViBarBg.Size = UDim2.new(1, -20, 0, 20)
tuViBarBg.Position = UDim2.new(0, 10, 0, 180)
tuViBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
tuViBarBg.BorderSizePixel = 0
tuViBarBg.Parent = mainFrame

local tuViBarCorner = Instance.new("UICorner")
tuViBarCorner.CornerRadius = UDim.new(0, 5)
tuViBarCorner.Parent = tuViBarBg

local tuViBar = Instance.new("Frame")
tuViBar.Name = "TuViBar"
tuViBar.Size = UDim2.new(0, 0, 1, 0)
tuViBar.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
tuViBar.BorderSizePixel = 0
tuViBar.Parent = tuViBarBg

local tuViBarCorner2 = Instance.new("UICorner")
tuViBarCorner2.CornerRadius = UDim.new(0, 5)
tuViBarCorner2.Parent = tuViBar

-- Level Up Button
local levelUpBtn = Instance.new("TextButton")
levelUpBtn.Name = "LevelUpBtn"
levelUpBtn.Size = UDim2.new(1, -20, 0, 50)
levelUpBtn.Position = UDim2.new(0, 10, 0, 220)
levelUpBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
levelUpBtn.Text = "⬆️ LEVEL UP"
levelUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
levelUpBtn.TextScaled = true
levelUpBtn.Font = Enum.Font.SourceSansBold
levelUpBtn.Parent = mainFrame

local levelUpCorner = Instance.new("UICorner")
levelUpCorner.CornerRadius = UDim.new(0, 8)
levelUpCorner.Parent = levelUpBtn

-- Breakthrough Button
local breakthroughBtn = Instance.new("TextButton")
breakthroughBtn.Name = "BreakthroughBtn"
breakthroughBtn.Size = UDim2.new(1, -20, 0, 50)
breakthroughBtn.Position = UDim2.new(0, 10, 0, 280)
breakthroughBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
breakthroughBtn.Text = "⭐ ĐỘT PHÁ"
breakthroughBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
breakthroughBtn.TextScaled = true
breakthroughBtn.Font = Enum.Font.SourceSansBold
breakthroughBtn.Parent = mainFrame

local breakthroughCorner = Instance.new("UICorner")
breakthroughCorner.CornerRadius = UDim.new(0, 8)
breakthroughCorner.Parent = breakthroughBtn

-- Meditate Button
local meditateBtn = Instance.new("TextButton")
meditateBtn.Name = "MeditateBtn"
meditateBtn.Size = UDim2.new(1, -20, 0, 50)
meditateBtn.Position = UDim2.new(0, 10, 0, 340)
meditateBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
meditateBtn.Text = "🧘 THIỀN ĐỊNH (AFK)"
meditateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
meditateBtn.TextScaled = true
meditateBtn.Font = Enum.Font.SourceSansBold
meditateBtn.Parent = mainFrame

local meditateCorner = Instance.new("UICorner")
meditateCorner.CornerRadius = UDim.new(0, 8)
meditateCorner.Parent = meditateBtn

-- Requirements Display
local reqLabel = Instance.new("TextLabel")
reqLabel.Name = "RequirementsLabel"
reqLabel.Size = UDim2.new(1, -20, 0, 90)
reqLabel.Position = UDim2.new(0, 10, 0, 400)
reqLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
reqLabel.BackgroundTransparency = 0.5
reqLabel.Text = "Yêu cầu Level Up:\n- Tu Vi: 1000\n- Pills: ..."
reqLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
reqLabel.TextSize = 14
reqLabel.Font = Enum.Font.SourceSans
reqLabel.TextWrapped = true
reqLabel.TextYAlignment = Enum.TextYAlignment.Top
reqLabel.Parent = mainFrame

local reqCorner = Instance.new("UICorner")
reqCorner.CornerRadius = UDim.new(0, 8)
reqCorner.Parent = reqLabel

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

local function UpdateUI()
	local playerData = GetPlayerData()
	if not playerData then
		warn("Cannot get player data")
		return
	end

	-- Update cult type
	local cultTypeNames = {
		TienThien = "⚡ Tiên Thiên",
		CoThan = "💪 Cổ Thần",
		MaDao = "🩸 Ma Đạo"
	}
	cultTypeLabel.Text = "Hệ: " .. (cultTypeNames[playerData.CultivationType] or playerData.CultivationType)

	-- Update realm
	local realmName = RealmCalculator.GetRealmDisplayName(playerData)
	realmLabel.Text = realmName

	-- Update Tu Vi
	local requirements = CultivationModule.GetNextLevelRequirements(playerData)
	local requiredTuVi = requirements.TuViRequired or 1000
	local currentTuVi = playerData.TuViPoints

	tuViLabel.Text = string.format("Tu Vi: %d / %d", currentTuVi, requiredTuVi)

	-- Update progress bar
	local progress = math.min(currentTuVi / requiredTuVi, 1)
	tuViBar:TweenSize(UDim2.new(progress, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)

	-- Update requirements text
	if requirements.Type == "Breakthrough" then
		reqLabel.Text = "🌟 ĐỦ ĐIỀU KIỆN ĐỘT PHÁ!\nNhấn nút Đột Phá để lên Cảnh Giới mới!"
		reqLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
		levelUpBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		breakthroughBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	else
		-- Build requirements text
		local reqText = "Yêu cầu Level Up:\n"
		reqText = reqText .. string.format("- Tu Vi: %d (Còn thiếu: %d)\n", requiredTuVi, math.max(0, requiredTuVi - currentTuVi))

		if requirements.Pills then
			reqText = reqText .. "- Pills: "
			local pillsList = {}
			for pillName, amount in pairs(requirements.Pills) do
				table.insert(pillsList, amount .. " " .. pillName)
			end
			reqText = reqText .. table.concat(pillsList, ", ")
		end

		reqLabel.Text = reqText
		reqLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

		-- Enable/disable level up button
		local canLevelUp = CultivationModule.CanLevelUp(playerData)
		if canLevelUp then
			levelUpBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		else
			levelUpBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		end

		breakthroughBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	end
end

-- ========================================
-- BUTTON HANDLERS
-- ========================================

levelUpBtn.MouseButton1Click:Connect(function()
	LevelUpEvent:FireServer()
	wait(0.5)
	UpdateUI()
end)

breakthroughBtn.MouseButton1Click:Connect(function()
	BreakthroughEvent:FireServer()
	wait(0.5)
	UpdateUI()
end)

meditateBtn.MouseButton1Click:Connect(function()
	-- Toggle meditation
	MeditateEvent:FireServer()
end)

-- ========================================
-- INITIALIZATION
-- ========================================

wait(2)
UpdateUI()

-- Update UI every 2 seconds
spawn(function()
	while wait(2) do
		UpdateUI()
	end
end)

print("✅ CultivationUI loaded!")
