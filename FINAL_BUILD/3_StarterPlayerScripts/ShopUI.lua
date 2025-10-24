-- ShopUI.lua - Shop UI System
-- Copy vào StarterPlayer/StarterPlayerScripts/ShopUI (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ShopModule = require(ReplicatedStorage.Modules.Shop.ShopModule)

local ShopUI = {}
ShopUI.IsOpen = false
ShopUI.CurrentCategory = "Pills"
ShopUI.ShopData = nil

-- ========================================
-- CREATE UI
-- ========================================

function ShopUI.CreateUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ShopUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- Main Frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 800, 0, 600)
	mainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
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
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	title.Text = "🛒 Shop - Cửa Hàng Tu Luyện"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 24
	title.Parent = mainFrame

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 10)
	titleCorner.Parent = title

	-- Category Tabs
	ShopUI.CreateCategoryTabs(mainFrame)

	-- Items Grid
	local itemsScroll = Instance.new("ScrollingFrame")
	itemsScroll.Name = "ItemsScroll"
	itemsScroll.Size = UDim2.new(1, -20, 1, -140)
	itemsScroll.Position = UDim2.new(0, 10, 0, 100)
	itemsScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	itemsScroll.BorderSizePixel = 0
	itemsScroll.ScrollBarThickness = 8
	itemsScroll.Parent = mainFrame

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 180, 0, 220)
	gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = itemsScroll

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
		ShopUI.Close()
	end)

	return screenGui
end

-- ========================================
-- CREATE CATEGORY TABS
-- ========================================

function ShopUI.CreateCategoryTabs(parent)
	local categories = {
		{Name = "Pills", Icon = "💊"},
		{Name = "Equipment", Icon = "⚔️"},
		{Name = "Materials", Icon = "🔮"},
		{Name = "Special", Icon = "⭐"}
	}

	for i, cat in ipairs(categories) do
		local tab = Instance.new("TextButton")
		tab.Name = cat.Name .. "Tab"
		tab.Size = UDim2.new(0, 180, 0, 35)
		tab.Position = UDim2.new(0, 10 + (i-1) * 190, 0, 55)
		tab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		tab.Text = cat.Icon .. " " .. cat.Name
		tab.TextColor3 = Color3.fromRGB(255, 255, 255)
		tab.Font = Enum.Font.GothamBold
		tab.TextSize = 16
		tab.Parent = parent

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = tab

		tab.MouseButton1Click:Connect(function()
			ShopUI.SelectCategory(cat.Name)
		end)
	end
end

-- ========================================
-- SELECT CATEGORY
-- ========================================

function ShopUI.SelectCategory(category)
	ShopUI.CurrentCategory = category

	-- Update tab visuals
	local screenGui = playerGui:FindFirstChild("ShopUI")
	if screenGui and screenGui:FindFirstChild("MainFrame") then
		for _, child in ipairs(screenGui.MainFrame:GetChildren()) do
			if child:IsA("TextButton") and child.Name:match("Tab$") then
				if child.Name == category .. "Tab" then
					child.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
				else
					child.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				end
			end
		end
	end

	-- Refresh items
	ShopUI.RefreshItems()
end

-- ========================================
-- CREATE ITEM CARD
-- ========================================

function ShopUI.CreateItemCard(itemData)
	local card = Instance.new("Frame")
	card.Name = itemData.ItemName
	card.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	card.BorderSizePixel = 2
	card.BorderColor3 = Color3.fromRGB(100, 100, 100)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = card

	-- Item Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -10, 0, 30)
	nameLabel.Position = UDim2.new(0, 5, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = itemData.ItemName
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 14
	nameLabel.TextWrapped = true
	nameLabel.Parent = card

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -10, 0, 40)
	descLabel.Position = UDim2.new(0, 5, 0, 40)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = itemData.Description or ""
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 11
	descLabel.TextWrapped = true
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.Parent = card

	-- Price
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(1, -10, 0, 25)
	priceLabel.Position = UDim2.new(0, 5, 0, 85)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Text = "💰 " .. itemData.Price .. " Tiên Ngọc"
	priceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	priceLabel.Font = Enum.Font.GothamBold
	priceLabel.TextSize = 13
	priceLabel.Parent = card

	-- Stock
	if itemData.Stock and itemData.Stock ~= -1 then
		local stockLabel = Instance.new("TextLabel")
		stockLabel.Size = UDim2.new(1, -10, 0, 20)
		stockLabel.Position = UDim2.new(0, 5, 0, 115)
		stockLabel.BackgroundTransparency = 1
		stockLabel.Text = "Stock: " .. itemData.Stock
		stockLabel.TextColor3 = itemData.Stock > 0 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
		stockLabel.Font = Enum.Font.Gotham
		stockLabel.TextSize = 11
		stockLabel.Parent = card
	end

	-- Buy Button
	local buyButton = Instance.new("TextButton")
	buyButton.Size = UDim2.new(0.45, 0, 0, 35)
	buyButton.Position = UDim2.new(0.05, 0, 1, -45)
	buyButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	buyButton.Text = "Buy"
	buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyButton.Font = Enum.Font.GothamBold
	buyButton.TextSize = 14
	buyButton.Parent = card

	buyButton.MouseButton1Click:Connect(function()
		ShopUI.BuyItem(itemData.ItemName, 1)
	end)

	-- Sell Button
	if itemData.SellPrice and itemData.SellPrice > 0 then
		local sellButton = Instance.new("TextButton")
		sellButton.Size = UDim2.new(0.45, 0, 0, 35)
		sellButton.Position = UDim2.new(0.5, 0, 1, -45)
		sellButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
		sellButton.Text = "Sell\n" .. itemData.SellPrice
		sellButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		sellButton.Font = Enum.Font.GothamBold
		sellButton.TextSize = 12
		sellButton.Parent = card

		sellButton.MouseButton1Click:Connect(function()
			ShopUI.SellItem(itemData.ItemName, 1)
		end)
	end

	return card
end

-- ========================================
-- REFRESH ITEMS
-- ========================================

function ShopUI.RefreshItems()
	local screenGui = playerGui:FindFirstChild("ShopUI")
	if not screenGui then return end

	local itemsScroll = screenGui:FindFirstChild("MainFrame")
		and screenGui.MainFrame:FindFirstChild("ItemsScroll")

	if not itemsScroll then return end

	-- Clear existing items
	for _, child in ipairs(itemsScroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Get shop for current category
	local shop = ShopModule.GetShop(ShopUI.CurrentCategory)

	if shop then
		for _, itemData in ipairs(shop) do
			local card = ShopUI.CreateItemCard(itemData)
			card.Parent = itemsScroll
		end
	end

	-- Update canvas size
	task.wait()
	if itemsScroll:FindFirstChild("UIGridLayout") then
		itemsScroll.CanvasSize = UDim2.new(0, 0, 0, itemsScroll.UIGridLayout.AbsoluteContentSize.Y + 10)
	end
end

-- ========================================
-- BUY ITEM
-- ========================================

function ShopUI.BuyItem(itemName, quantity)
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("BuyItem")

	if remoteEvent then
		remoteEvent:FireServer(itemName, quantity)
	end
end

-- ========================================
-- SELL ITEM
-- ========================================

function ShopUI.SellItem(itemName, quantity)
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("SellItem")

	if remoteEvent then
		remoteEvent:FireServer(itemName, quantity)
	end
end

-- ========================================
-- OPEN/CLOSE
-- ========================================

function ShopUI.Open()
	ShopUI.IsOpen = true

	local screenGui = playerGui:FindFirstChild("ShopUI")
	if screenGui then
		local mainFrame = screenGui:FindFirstChild("MainFrame")
		if mainFrame then
			mainFrame.Visible = true
			ShopUI.SelectCategory("Pills")
			ShopUI.RequestShop()
		end
	end
end

function ShopUI.Close()
	ShopUI.IsOpen = false

	local screenGui = playerGui:FindFirstChild("ShopUI")
	if screenGui then
		local mainFrame = screenGui:FindFirstChild("MainFrame")
		if mainFrame then
			mainFrame.Visible = false
		end
	end
end

function ShopUI.Toggle()
	if ShopUI.IsOpen then
		ShopUI.Close()
	else
		ShopUI.Open()
	end
end

-- ========================================
-- REQUEST SHOP
-- ========================================

function ShopUI.RequestShop()
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("GetShop")

	if remoteEvent then
		remoteEvent:FireServer()
	end
end

-- ========================================
-- SHOW NOTIFICATION
-- ========================================

function ShopUI.ShowNotification(message)
	local screenGui = playerGui:FindFirstChild("ShopUI")
	if not screenGui then return end

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 350, 0, 60)
	notif.Position = UDim2.new(0.5, -175, 0.1, 0)
	notif.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	notif.ZIndex = 100
	notif.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = notif

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, -20)
	label.Position = UDim2.new(0, 10, 0, 10)
	label.BackgroundTransparency = 1
	label.Text = message
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.TextWrapped = true
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

function ShopUI.SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	if not remoteEvents then
		warn("RemoteEvents folder not found!")
		return
	end

	-- Shop Notification
	local shopNotif = remoteEvents:WaitForChild("ShopNotification", 10)
	if shopNotif then
		shopNotif.OnClientEvent:Connect(function(message)
			ShopUI.ShowNotification(message)
		end)
	end

	-- Sync Shop
	local syncShop = remoteEvents:WaitForChild("SyncShop", 10)
	if syncShop then
		syncShop.OnClientEvent:Connect(function(shopData)
			ShopUI.ShopData = shopData
			ShopUI.RefreshItems()
		end)
	end
end

-- ========================================
-- INPUT HANDLING
-- ========================================

function ShopUI.SetupInput()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.KeyCode == Enum.KeyCode.B then
			ShopUI.Toggle()
		elseif input.KeyCode == Enum.KeyCode.Escape and ShopUI.IsOpen then
			ShopUI.Close()
		end
	end)
end

-- ========================================
-- INITIALIZE
-- ========================================

function ShopUI.Initialize()
	print("🛒 ShopUI initializing...")

	-- Create UI
	ShopUI.CreateUI()

	-- Setup remote events
	ShopUI.SetupRemoteEvents()

	-- Setup input
	ShopUI.SetupInput()

	print("✅ ShopUI ready! Press 'B' to open shop")
end

-- Auto-initialize
ShopUI.Initialize()

return ShopUI
