-- EquipmentUI.lua - Equipment UI System
-- Copy vào StarterPlayer/StarterPlayerScripts/EquipmentUI (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local EquipmentModule = require(ReplicatedStorage.Modules.Equipment.EquipmentModule)

local EquipmentUI = {}
EquipmentUI.IsOpen = false
EquipmentUI.CurrentLoadout = nil

-- ========================================
-- CREATE UI
-- ========================================

function EquipmentUI.CreateUI()
	-- Main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EquipmentUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- Main Frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 700, 0, 550)
	mainFrame.Position = UDim2.new(0.5, -350, 0.5, -275)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	mainFrame.BorderSizePixel = 2
	mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
	mainFrame.Visible = false
	mainFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = mainFrame

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	title.Text = "⚔️ Equipment"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 24
	title.Parent = mainFrame

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 10)
	titleCorner.Parent = title

	-- Equipment Slots Container
	local slotsContainer = Instance.new("Frame")
	slotsContainer.Name = "SlotsContainer"
	slotsContainer.Size = UDim2.new(1, -20, 1, -100)
	slotsContainer.Position = UDim2.new(0, 10, 0, 50)
	slotsContainer.BackgroundTransparency = 1
	slotsContainer.Parent = mainFrame

	-- Create slots
	EquipmentUI.CreateSlots(slotsContainer)

	-- Stats Display
	local statsFrame = Instance.new("Frame")
	statsFrame.Name = "StatsFrame"
	statsFrame.Size = UDim2.new(0.45, 0, 1, 0)
	statsFrame.Position = UDim2.new(0.55, 0, 0, 0)
	statsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	statsFrame.BorderSizePixel = 0
	statsFrame.Parent = slotsContainer

	local statsCorner = Instance.new("UICorner")
	statsCorner.CornerRadius = UDim.new(0, 8)
	statsCorner.Parent = statsFrame

	local statsTitle = Instance.new("TextLabel")
	statsTitle.Size = UDim2.new(1, -10, 0, 30)
	statsTitle.Position = UDim2.new(0, 5, 0, 5)
	statsTitle.BackgroundTransparency = 1
	statsTitle.Text = "📊 Total Equipment Stats"
	statsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	statsTitle.Font = Enum.Font.GothamBold
	statsTitle.TextSize = 18
	statsTitle.TextXAlignment = Enum.TextXAlignment.Left
	statsTitle.Parent = statsFrame

	local statsScroll = Instance.new("ScrollingFrame")
	statsScroll.Name = "StatsScroll"
	statsScroll.Size = UDim2.new(1, -10, 1, -45)
	statsScroll.Position = UDim2.new(0, 5, 0, 40)
	statsScroll.BackgroundTransparency = 1
	statsScroll.BorderSizePixel = 0
	statsScroll.ScrollBarThickness = 6
	statsScroll.Parent = statsFrame

	local statsList = Instance.new("UIListLayout")
	statsList.Padding = UDim.new(0, 3)
	statsList.Parent = statsScroll

	-- Close Button
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 100, 0, 30)
	closeButton.Position = UDim2.new(1, -110, 1, -40)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.Text = "Close"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 16
	closeButton.Parent = mainFrame

	closeButton.MouseButton1Click:Connect(function()
		EquipmentUI.Close()
	end)

	return screenGui
end

-- ========================================
-- CREATE EQUIPMENT SLOTS
-- ========================================

function EquipmentUI.CreateSlots(parent)
	local slots = {
		{Name = "Weapon", Position = UDim2.new(0.05, 0, 0.1, 0), Icon = "⚔️"},
		{Name = "Armor", Position = UDim2.new(0.05, 0, 0.35, 0), Icon = "🛡️"},
		{Name = "Helmet", Position = UDim2.new(0.25, 0, 0.1, 0), Icon = "🎩"},
		{Name = "Boots", Position = UDim2.new(0.25, 0, 0.35, 0), Icon = "👞"},
		{Name = "Accessory1", Position = UDim2.new(0.05, 0, 0.6, 0), Icon = "💍"},
		{Name = "Accessory2", Position = UDim2.new(0.25, 0, 0.6, 0), Icon = "💍"},
		{Name = "Talisman", Position = UDim2.new(0.15, 0, 0.85, 0), Icon = "📿"}
	}

	for _, slotData in ipairs(slots) do
		EquipmentUI.CreateSlot(parent, slotData.Name, slotData.Position, slotData.Icon)
	end
end

function EquipmentUI.CreateSlot(parent, slotName, position, icon)
	local slot = Instance.new("Frame")
	slot.Name = slotName
	slot.Size = UDim2.new(0, 120, 0, 120)
	slot.Position = position
	slot.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	slot.BorderSizePixel = 2
	slot.BorderColor3 = Color3.fromRGB(80, 80, 80)
	slot.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = slot

	-- Slot Label
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.Text = icon .. " " .. slotName
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.Parent = slot

	-- Empty icon
	local emptyIcon = Instance.new("TextLabel")
	emptyIcon.Name = "EmptyIcon"
	emptyIcon.Size = UDim2.new(1, 0, 1, -20)
	emptyIcon.Position = UDim2.new(0, 0, 0, 20)
	emptyIcon.BackgroundTransparency = 1
	emptyIcon.Text = icon
	emptyIcon.TextColor3 = Color3.fromRGB(100, 100, 100)
	emptyIcon.Font = Enum.Font.GothamBold
	emptyIcon.TextSize = 40
	emptyIcon.Parent = slot

	-- Equipment display (hidden initially)
	local equipDisplay = Instance.new("Frame")
	equipDisplay.Name = "EquipDisplay"
	equipDisplay.Size = UDim2.new(1, 0, 1, -20)
	equipDisplay.Position = UDim2.new(0, 0, 0, 20)
	equipDisplay.BackgroundTransparency = 1
	equipDisplay.Visible = false
	equipDisplay.Parent = slot

	local equipIcon = Instance.new("TextLabel")
	equipIcon.Size = UDim2.new(1, 0, 0.6, 0)
	equipIcon.BackgroundTransparency = 1
	equipIcon.Text = icon
	equipIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
	equipIcon.Font = Enum.Font.GothamBold
	equipIcon.TextSize = 36
	equipIcon.Parent = equipDisplay

	local equipName = Instance.new("TextLabel")
	equipName.Name = "EquipName"
	equipName.Size = UDim2.new(1, -4, 0.4, 0)
	equipName.Position = UDim2.new(0, 2, 0.6, 0)
	equipName.BackgroundTransparency = 1
	equipName.Text = ""
	equipName.TextColor3 = Color3.fromRGB(255, 255, 255)
	equipName.Font = Enum.Font.Gotham
	equipName.TextSize = 11
	equipName.TextWrapped = true
	equipName.Parent = equipDisplay

	-- Unequip button
	local unequipBtn = Instance.new("TextButton")
	unequipBtn.Name = "UnequipBtn"
	unequipBtn.Size = UDim2.new(0.8, 0, 0, 20)
	unequipBtn.Position = UDim2.new(0.1, 0, 1, -25)
	unequipBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	unequipBtn.Text = "Unequip"
	unequipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	unequipBtn.Font = Enum.Font.GothamBold
	unequipBtn.TextSize = 10
	unequipBtn.Visible = false
	unequipBtn.Parent = slot

	unequipBtn.MouseButton1Click:Connect(function()
		EquipmentUI.UnequipSlot(slotName)
	end)

	return slot
end

-- ========================================
-- UPDATE LOADOUT
-- ========================================

function EquipmentUI.UpdateLoadout(loadoutData)
	EquipmentUI.CurrentLoadout = loadoutData

	local screenGui = playerGui:FindFirstChild("EquipmentUI")
	if not screenGui then return end

	local mainFrame = screenGui:FindFirstChild("MainFrame")
	if not mainFrame then return end

	local slotsContainer = mainFrame:FindFirstChild("SlotsContainer")
	if not slotsContainer then return end

	-- Update each slot
	for slotName, equipmentData in pairs(loadoutData) do
		local slotFrame = slotsContainer:FindFirstChild(slotName)
		if slotFrame then
			EquipmentUI.UpdateSlot(slotFrame, equipmentData)
		end
	end

	-- Update stats
	EquipmentUI.UpdateStats(loadoutData)
end

function EquipmentUI.UpdateSlot(slotFrame, equipmentData)
	local emptyIcon = slotFrame:FindFirstChild("EmptyIcon")
	local equipDisplay = slotFrame:FindFirstChild("EquipDisplay")
	local unequipBtn = slotFrame:FindFirstChild("UnequipBtn")

	if equipmentData then
		-- Show equipment
		if emptyIcon then emptyIcon.Visible = false end
		if equipDisplay then
			equipDisplay.Visible = true
			local equipName = equipDisplay:FindFirstChild("EquipName")
			if equipName then
				equipName.Text = equipmentData.Name
				equipName.TextColor3 = equipmentData.Tier and equipmentData.Tier.Color or Color3.fromRGB(255, 255, 255)
			end
		end
		if unequipBtn then unequipBtn.Visible = true end

		-- Update border color
		slotFrame.BorderColor3 = equipmentData.Tier and equipmentData.Tier.Color or Color3.fromRGB(100, 100, 100)
	else
		-- Show empty
		if emptyIcon then emptyIcon.Visible = true end
		if equipDisplay then equipDisplay.Visible = false end
		if unequipBtn then unequipBtn.Visible = false end
		slotFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
	end
end

-- ========================================
-- UPDATE STATS
-- ========================================

function EquipmentUI.UpdateStats(loadoutData)
	local screenGui = playerGui:FindFirstChild("EquipmentUI")
	if not screenGui then return end

	local statsScroll = screenGui:FindFirstChild("MainFrame")
		and screenGui.MainFrame:FindFirstChild("SlotsContainer")
		and screenGui.MainFrame.SlotsContainer:FindFirstChild("StatsFrame")
		and screenGui.MainFrame.SlotsContainer.StatsFrame:FindFirstChild("StatsScroll")

	if not statsScroll then return end

	-- Clear existing stats
	for _, child in ipairs(statsScroll:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	-- Calculate total stats
	local totalStats = {
		HP = 0,
		MP = 0,
		MagicDamage = 0,
		PhysicalDamage = 0,
		SoulDamage = 0,
		Defense = 0,
		MagicDefense = 0,
		Speed = 0,
		CritRate = 0,
		CritDamage = 0,
		Lifesteal = 0
	}

	for _, equipmentData in pairs(loadoutData) do
		if equipmentData and equipmentData.Stats then
			for stat, value in pairs(equipmentData.Stats) do
				if totalStats[stat] then
					totalStats[stat] = totalStats[stat] + value
				end
			end
		end
	end

	-- Display stats
	for statName, value in pairs(totalStats) do
		if value > 0 then
			local statLabel = Instance.new("TextLabel")
			statLabel.Size = UDim2.new(1, 0, 0, 25)
			statLabel.BackgroundTransparency = 1
			statLabel.Text = statName .. ": +" .. tostring(value)
			statLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
			statLabel.Font = Enum.Font.Gotham
			statLabel.TextSize = 14
			statLabel.TextXAlignment = Enum.TextXAlignment.Left
			statLabel.Parent = statsScroll
		end
	end

	statsScroll.CanvasSize = UDim2.new(0, 0, 0, statsScroll.UIListLayout.AbsoluteContentSize.Y)
end

-- ========================================
-- UNEQUIP SLOT
-- ========================================

function EquipmentUI.UnequipSlot(slotName)
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("UnequipItem")

	if remoteEvent then
		remoteEvent:FireServer(slotName)
	end
end

-- ========================================
-- OPEN/CLOSE
-- ========================================

function EquipmentUI.Open()
	EquipmentUI.IsOpen = true

	local screenGui = playerGui:FindFirstChild("EquipmentUI")
	if screenGui then
		local mainFrame = screenGui:FindFirstChild("MainFrame")
		if mainFrame then
			mainFrame.Visible = true
			EquipmentUI.RequestLoadout()
		end
	end
end

function EquipmentUI.Close()
	EquipmentUI.IsOpen = false

	local screenGui = playerGui:FindFirstChild("EquipmentUI")
	if screenGui then
		local mainFrame = screenGui:FindFirstChild("MainFrame")
		if mainFrame then
			mainFrame.Visible = false
		end
	end
end

function EquipmentUI.Toggle()
	if EquipmentUI.IsOpen then
		EquipmentUI.Close()
	else
		EquipmentUI.Open()
	end
end

-- ========================================
-- REQUEST LOADOUT
-- ========================================

function EquipmentUI.RequestLoadout()
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("GetEquipment")

	if remoteEvent then
		remoteEvent:FireServer()
	end
end

-- ========================================
-- SHOW NOTIFICATION
-- ========================================

function EquipmentUI.ShowNotification(message)
	local screenGui = playerGui:FindFirstChild("EquipmentUI")
	if not screenGui then return end

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 300, 0, 50)
	notif.Position = UDim2.new(0.5, -150, 0.1, 0)
	notif.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	notif.ZIndex = 100
	notif.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = notif

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = message
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.Parent = notif

	task.delay(3, function()
		for i = 0, 1, 0.1 do
			notif.BackgroundTransparency = i
			label.TextTransparency = i
			task.wait(0.05)
		end
		notif:Destroy()
	end)
end

-- ========================================
-- SETUP REMOTE EVENTS
-- ========================================

function EquipmentUI.SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	if not remoteEvents then
		warn("RemoteEvents folder not found!")
		return
	end

	-- Sync Equipment
	local syncEquipment = remoteEvents:WaitForChild("SyncEquipment", 10)
	if syncEquipment then
		syncEquipment.OnClientEvent:Connect(function(loadoutData)
			EquipmentUI.UpdateLoadout(loadoutData)
		end)
	end

	-- Equip Response
	local equipResponse = remoteEvents:WaitForChild("EquipResponse", 10)
	if equipResponse then
		equipResponse.OnClientEvent:Connect(function(success, message)
			EquipmentUI.ShowNotification(message)
			if success then
				EquipmentUI.RequestLoadout()
			end
		end)
	end
end

-- ========================================
-- INPUT HANDLING
-- ========================================

function EquipmentUI.SetupInput()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.KeyCode == Enum.KeyCode.E then
			EquipmentUI.Toggle()
		elseif input.KeyCode == Enum.KeyCode.Escape and EquipmentUI.IsOpen then
			EquipmentUI.Close()
		end
	end)
end

-- ========================================
-- INITIALIZE
-- ========================================

function EquipmentUI.Initialize()
	print("⚔️ EquipmentUI initializing...")

	-- Create UI
	EquipmentUI.CreateUI()

	-- Setup remote events
	EquipmentUI.SetupRemoteEvents()

	-- Setup input
	EquipmentUI.SetupInput()

	print("✅ EquipmentUI ready! Press 'E' to open")
end

-- Auto-initialize
EquipmentUI.Initialize()

return EquipmentUI
