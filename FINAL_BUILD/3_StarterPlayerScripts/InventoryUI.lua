-- InventoryUI.lua - Inventory UI System
-- Copy vào StarterPlayer/StarterPlayerScripts/InventoryUI (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local InventoryModule = require(ReplicatedStorage.Modules.Inventory.InventoryModule)
local LootModule = require(ReplicatedStorage.Modules.Loot.LootModule)

local InventoryUI = {}
InventoryUI.IsOpen = false
InventoryUI.CurrentInventory = nil

-- ========================================
-- CREATE UI
-- ========================================

function InventoryUI.CreateUI()
	-- Main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "InventoryUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- Main Frame (Hidden by default)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 600, 0, 500)
	mainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	mainFrame.BorderSizePixel = 2
	mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
	mainFrame.Visible = false
	mainFrame.Parent = screenGui

	-- Corner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = mainFrame

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	title.Text = "📦 Inventory"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 24
	title.Parent = mainFrame

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 10)
	titleCorner.Parent = title

	-- Gold Display
	local goldLabel = Instance.new("TextLabel")
	goldLabel.Name = "GoldLabel"
	goldLabel.Size = UDim2.new(1, -20, 0, 30)
	goldLabel.Position = UDim2.new(0, 10, 0, 50)
	goldLabel.BackgroundTransparency = 1
	goldLabel.Text = "💰 Tiên Ngọc: 0"
	goldLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	goldLabel.Font = Enum.Font.GothamBold
	goldLabel.TextSize = 18
	goldLabel.TextXAlignment = Enum.TextXAlignment.Left
	goldLabel.Parent = mainFrame

	-- Inventory Grid
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "InventoryGrid"
	scrollFrame.Size = UDim2.new(1, -20, 1, -120)
	scrollFrame.Position = UDim2.new(0, 10, 0, 90)
	scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.Parent = mainFrame

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 80, 0, 80)
	gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = scrollFrame

	-- Close Button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 100, 0, 30)
	closeButton.Position = UDim2.new(1, -110, 1, -40)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.Text = "Close"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 16
	closeButton.Parent = mainFrame

	closeButton.MouseButton1Click:Connect(function()
		InventoryUI.Close()
	end)

	-- Sort Button
	local sortButton = Instance.new("TextButton")
	sortButton.Name = "SortButton"
	sortButton.Size = UDim2.new(0, 100, 0, 30)
	sortButton.Position = UDim2.new(0, 10, 1, -40)
	sortButton.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
	sortButton.Text = "Sort"
	sortButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	sortButton.Font = Enum.Font.GothamBold
	sortButton.TextSize = 16
	sortButton.Parent = mainFrame

	sortButton.MouseButton1Click:Connect(function()
		InventoryUI.SortInventory()
	end)

	return screenGui
end

-- ========================================
-- CREATE ITEM SLOT
-- ========================================

function InventoryUI.CreateItemSlot(itemData)
	local slot = Instance.new("Frame")
	slot.Name = itemData.Name
	slot.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	slot.BorderSizePixel = 2
	slot.BorderColor3 = itemData.Rarity and itemData.Rarity.Color or Color3.fromRGB(100, 100, 100)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = slot

	-- Item Icon (placeholder)
	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.new(0.7, 0, 0.7, 0)
	icon.Position = UDim2.new(0.15, 0, 0.05, 0)
	icon.BackgroundTransparency = 1
	icon.Image = itemData.Icon or ""
	icon.Parent = slot

	-- If no icon, show text
	if itemData.Icon == "rbxassetid://0" or itemData.Icon == "" then
		local iconText = Instance.new("TextLabel")
		iconText.Size = UDim2.new(1, 0, 0.7, 0)
		iconText.Position = UDim2.new(0, 0, 0.05, 0)
		iconText.BackgroundTransparency = 1
		iconText.Text = string.sub(itemData.Name, 1, 2) -- First 2 chars
		iconText.TextColor3 = itemData.Rarity and itemData.Rarity.Color or Color3.fromRGB(255, 255, 255)
		iconText.Font = Enum.Font.GothamBold
		iconText.TextScaled = true
		iconText.Parent = slot
	end

	-- Amount
	local amount = Instance.new("TextLabel")
	amount.Size = UDim2.new(1, 0, 0.25, 0)
	amount.Position = UDim2.new(0, 0, 0.75, 0)
	amount.BackgroundTransparency = 1
	amount.Text = "x" .. (itemData.Amount or 1)
	amount.TextColor3 = Color3.fromRGB(255, 255, 255)
	amount.Font = Enum.Font.GothamBold
	amount.TextScaled = true
	amount.TextStrokeTransparency = 0
	amount.Parent = slot

	-- Click to use
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.Parent = slot

	button.MouseButton1Click:Connect(function()
		InventoryUI.UseItem(itemData)
	end)

	-- Tooltip on hover
	button.MouseEnter:Connect(function()
		InventoryUI.ShowTooltip(itemData, slot)
	end)

	button.MouseLeave:Connect(function()
		InventoryUI.HideTooltip()
	end)

	return slot
end

-- ========================================
-- SHOW TOOLTIP
-- ========================================

function InventoryUI.ShowTooltip(itemData, slotFrame)
	local screenGui = playerGui:FindFirstChild("InventoryUI")
	if not screenGui then return end

	-- Remove existing tooltip
	InventoryUI.HideTooltip()

	-- Create tooltip
	local tooltip = Instance.new("Frame")
	tooltip.Name = "Tooltip"
	tooltip.Size = UDim2.new(0, 200, 0, 100)
	tooltip.Position = UDim2.new(0, slotFrame.AbsolutePosition.X + 90, 0, slotFrame.AbsolutePosition.Y)
	tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	tooltip.BorderSizePixel = 2
	tooltip.BorderColor3 = itemData.Rarity and itemData.Rarity.Color or Color3.fromRGB(100, 100, 100)
	tooltip.ZIndex = 10
	tooltip.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = tooltip

	-- Item Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -10, 0, 25)
	nameLabel.Position = UDim2.new(0, 5, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = itemData.Name
	nameLabel.TextColor3 = itemData.Rarity and itemData.Rarity.Color or Color3.fromRGB(255, 255, 255)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 16
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = tooltip

	-- Rarity
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(1, -10, 0, 20)
	rarityLabel.Position = UDim2.new(0, 5, 0, 30)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = itemData.Rarity and itemData.Rarity.Name or "Common"
	rarityLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	rarityLabel.Font = Enum.Font.Gotham
	rarityLabel.TextSize = 12
	rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
	rarityLabel.Parent = tooltip

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -10, 0, 40)
	descLabel.Position = UDim2.new(0, 5, 0, 55)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = itemData.Description or "No description"
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 12
	descLabel.TextWrapped = true
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.Parent = tooltip
end

function InventoryUI.HideTooltip()
	local screenGui = playerGui:FindFirstChild("InventoryUI")
	if not screenGui then return end

	local tooltip = screenGui:FindFirstChild("Tooltip")
	if tooltip then
		tooltip:Destroy()
	end
end

-- ========================================
-- UPDATE INVENTORY
-- ========================================

function InventoryUI.UpdateInventory(inventoryData)
	InventoryUI.CurrentInventory = inventoryData

	local screenGui = playerGui:FindFirstChild("InventoryUI")
	if not screenGui then return end

	local mainFrame = screenGui:FindFirstChild("MainFrame")
	if not mainFrame then return end

	-- Update gold
	local goldLabel = mainFrame:FindFirstChild("GoldLabel")
	if goldLabel then
		goldLabel.Text = "💰 Tiên Ngọc: " .. (inventoryData.Gold or 0)
	end

	-- Clear existing items
	local grid = mainFrame:FindFirstChild("InventoryGrid")
	if grid then
		for _, child in ipairs(grid:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end

		-- Add items
		for _, itemData in ipairs(inventoryData.Items or {}) do
			local slot = InventoryUI.CreateItemSlot(itemData)
			slot.Parent = grid
		end
	end
end

-- ========================================
-- OPEN/CLOSE
-- ========================================

function InventoryUI.Open()
	InventoryUI.IsOpen = true

	local screenGui = playerGui:FindFirstChild("InventoryUI")
	if screenGui then
		local mainFrame = screenGui:FindFirstChild("MainFrame")
		if mainFrame then
			mainFrame.Visible = true

			-- Request inventory from server
			InventoryUI.RequestInventory()
		end
	end
end

function InventoryUI.Close()
	InventoryUI.IsOpen = false

	local screenGui = playerGui:FindFirstChild("InventoryUI")
	if screenGui then
		local mainFrame = screenGui:FindFirstChild("MainFrame")
		if mainFrame then
			mainFrame.Visible = false
		end
	end
end

function InventoryUI.Toggle()
	if InventoryUI.IsOpen then
		InventoryUI.Close()
	else
		InventoryUI.Open()
	end
end

-- ========================================
-- REQUEST INVENTORY
-- ========================================

function InventoryUI.RequestInventory()
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("GetInventory")

	if remoteEvent then
		remoteEvent:FireServer()
	end
end

-- ========================================
-- USE ITEM
-- ========================================

function InventoryUI.UseItem(itemData)
	if itemData.Type ~= "Pill" then
		InventoryUI.ShowNotification("Cannot use this item!")
		return
	end

	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("UseItem")

	if remoteEvent then
		remoteEvent:FireServer(itemData.Name)
	end
end

-- ========================================
-- SORT INVENTORY
-- ========================================

function InventoryUI.SortInventory()
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("SortInventory")

	if remoteEvent then
		remoteEvent:FireServer()
	end
end

-- ========================================
-- SHOW NOTIFICATION
-- ========================================

function InventoryUI.ShowNotification(message)
	local screenGui = playerGui:FindFirstChild("InventoryUI")
	if not screenGui then return end

	-- Create notification
	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 300, 0, 50)
	notif.Position = UDim2.new(0.5, -150, 0.1, 0)
	notif.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	notif.BorderSizePixel = 0
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

	-- Fade out and destroy
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

function InventoryUI.SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	if not remoteEvents then
		warn("RemoteEvents folder not found!")
		return
	end

	-- Sync Inventory
	local syncInventory = remoteEvents:WaitForChild("SyncInventory", 10)
	if syncInventory then
		syncInventory.OnClientEvent:Connect(function(inventoryData)
			InventoryUI.UpdateInventory(inventoryData)
		end)
	end

	-- Item Used Response
	local itemUsed = remoteEvents:WaitForChild("ItemUsed", 10)
	if itemUsed then
		itemUsed.OnClientEvent:Connect(function(success, message)
			InventoryUI.ShowNotification(message)
			if success then
				InventoryUI.RequestInventory() -- Refresh
			end
		end)
	end

	-- Loot Notification
	local lootNotif = remoteEvents:FindFirstChild("LootNotification")
	if lootNotif then
		lootNotif.OnClientEvent:Connect(function(message)
			InventoryUI.ShowNotification(message)
		end)
	end
end

-- ========================================
-- INPUT HANDLING
-- ========================================

function InventoryUI.SetupInput()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.KeyCode == Enum.KeyCode.I then
			InventoryUI.Toggle()
		elseif input.KeyCode == Enum.KeyCode.Escape and InventoryUI.IsOpen then
			InventoryUI.Close()
		end
	end)
end

-- ========================================
-- INITIALIZE
-- ========================================

function InventoryUI.Initialize()
	print("📦 InventoryUI initializing...")

	-- Create UI
	InventoryUI.CreateUI()

	-- Setup remote events
	InventoryUI.SetupRemoteEvents()

	-- Setup input
	InventoryUI.SetupInput()

	print("✅ InventoryUI ready! Press 'I' to open")
end

-- Auto-initialize
InventoryUI.Initialize()

return InventoryUI
