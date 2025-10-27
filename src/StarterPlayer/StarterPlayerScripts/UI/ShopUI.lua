-- ShopUI.lua - Shop UI (Refactored with OOP)
-- Author: Claude Code

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseUI = require(ReplicatedStorage.Modules.UI.BaseUI)
local ButtonManager = require(ReplicatedStorage.Modules.UI.ButtonManager)
local UIManager = require(ReplicatedStorage.Modules.UI.UIManager)
local ShopModule = require(ReplicatedStorage.Modules.Shop.ShopModule)

-- ============================================
-- SHOP UI CLASS
-- ============================================

local ShopUI = setmetatable({}, {__index = BaseUI})
ShopUI.__index = ShopUI

function ShopUI.new()
	local self = BaseUI.new({
		Name = "ShopUI",
		ToggleKey = Enum.KeyCode.B,
		CloseOnEscape = true,
		StartVisible = false,
		RemoteEvents = {
			"GetShop",
			"SyncShop",
			"BuyItem",
			"SellItem",
			"ShopNotification"
		}
	})

	setmetatable(self, ShopUI)

	self.CurrentCategory = "Pills"
	self.ShopData = nil
	self.CategoryButtons = {}

	return self
end

-- ============================================
-- UI CREATION
-- ============================================

function ShopUI:CreateMainFrame(parent)
	local mainFrame = self:CreateFrame({
		Parent = parent,
		Name = "MainFrame",
		Size = UDim2.new(0, 800, 0, 600),
		Position = UDim2.new(0.5, -400, 0.5, -300),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel = 2,
		BorderColor3 = Color3.fromRGB(100, 100, 100),
		Visible = false,
		CornerRadius = 10
	})

	-- Title
	self:CreateLabel({
		Parent = mainFrame,
		Name = "Title",
		Size = UDim2.new(1, 0, 0, 40),
		Text = "🛒 Shop - Cửa Hàng Tu Luyện",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		CornerRadius = 10
	})

	-- Category Tabs
	self:CreateCategoryTabs(mainFrame)

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
	ButtonManager.CreateCloseButton(mainFrame, function()
		self:Close()
	end)

	return mainFrame
end

function ShopUI:CreateCategoryTabs(parent)
	local categories = {
		{Name = "Pills", Icon = "💊"},
		{Name = "Equipment", Icon = "⚔️"},
		{Name = "Materials", Icon = "🔮"},
		{Name = "Special", Icon = "⭐"}
	}

	for i, cat in ipairs(categories) do
		local tab = ButtonManager.CreateTabButton(
			parent,
			cat.Icon .. " " .. cat.Name,
			UDim2.new(0, 10 + (i-1) * 190, 0, 55),
			function()
				self:SelectCategory(cat.Name)
			end,
			i == 1
		)
		self.CategoryButtons[cat.Name] = tab
	end
end

-- ============================================
-- CATEGORY MANAGEMENT
-- ============================================

function ShopUI:SelectCategory(category)
	self.CurrentCategory = category

	-- Update all tab buttons
	for name, button in pairs(self.CategoryButtons) do
		ButtonManager.UpdateTabButton(button, name == category)
	end

	self:RefreshItems()
end

-- ============================================
-- ITEM MANAGEMENT
-- ============================================

function ShopUI:CreateItemCard(itemData)
	local card = self:CreateFrame({
		Parent = nil,
		Name = itemData.ItemName,
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		BorderSizePixel = 2,
		BorderColor3 = Color3.fromRGB(100, 100, 100),
		CornerRadius = 8
	})

	-- Item Name
	self:CreateLabel({
		Parent = card,
		Size = UDim2.new(1, -10, 0, 30),
		Position = UDim2.new(0, 5, 0, 5),
		Text = itemData.ItemName,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextWrapped = true
	})

	-- Description
	self:CreateLabel({
		Parent = card,
		Size = UDim2.new(1, -10, 0, 40),
		Position = UDim2.new(0, 5, 0, 40),
		Text = itemData.Description or "",
		TextColor3 = Color3.fromRGB(180, 180, 180),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top
	})

	-- Price
	self:CreateLabel({
		Parent = card,
		Size = UDim2.new(1, -10, 0, 25),
		Position = UDim2.new(0, 5, 0, 85),
		Text = "💰 " .. itemData.Price .. " Tiên Ngọc",
		TextColor3 = Color3.fromRGB(255, 215, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 13
	})

	-- Buy Button
	ButtonManager.CreateSuccessButton(card, "Buy", UDim2.new(0.05, 0, 1, -45), function()
		self:BuyItem(itemData.ItemName, 1)
	end)

	-- Sell Button
	if itemData.SellPrice and itemData.SellPrice > 0 then
		ButtonManager.CreateWarningButton(card, "Sell\n" .. itemData.SellPrice, UDim2.new(0.5, 0, 1, -45), function()
			self:SellItem(itemData.ItemName, 1)
		end)
	end

	return card
end

function ShopUI:RefreshItems()
	if not self.MainFrame then return end

	local itemsScroll = self.MainFrame:FindFirstChild("ItemsScroll")
	if not itemsScroll then return end

	-- Clear existing
	for _, child in ipairs(itemsScroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Get shop items
	local shop = ShopModule.GetShop(self.CurrentCategory)
	if shop then
		for _, itemData in ipairs(shop) do
			local card = self:CreateItemCard(itemData)
			card.Parent = itemsScroll
		end
	end

	-- Update canvas size
	task.wait()
	if itemsScroll:FindFirstChild("UIGridLayout") then
		itemsScroll.CanvasSize = UDim2.new(0, 0, 0, itemsScroll.UIGridLayout.AbsoluteContentSize.Y + 10)
	end
end

-- ============================================
-- ACTIONS
-- ============================================

function ShopUI:BuyItem(itemName, quantity)
	self:FireServer("BuyItem", itemName, quantity)
end

function ShopUI:SellItem(itemName, quantity)
	self:FireServer("SellItem", itemName, quantity)
end

-- ============================================
-- REMOTE EVENT HANDLERS
-- ============================================

function ShopUI:OnSyncShop(shopData)
	self.ShopData = shopData
	self:RefreshItems()
end

function ShopUI:OnShopNotification(message)
	self:ShowNotification(message)
end

-- ============================================
-- HOOKS
-- ============================================

function ShopUI:OnOpen()
	self:SelectCategory("Pills")
	self:FireServer("GetShop")
end

-- ============================================
-- INITIALIZATION
-- ============================================

local shopUI = ShopUI.new()
shopUI:Initialize()

UIManager.Register("Shop", shopUI)

return shopUI
