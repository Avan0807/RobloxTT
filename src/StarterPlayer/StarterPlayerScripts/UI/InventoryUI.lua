-- InventoryUI.lua - Inventory UI (Refactored with OOP)
-- Author: Claude Code
-- Description: Inventory management UI using BaseUI architecture

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for modules
local BaseUI = require(ReplicatedStorage.Modules.UI.BaseUI)
local ButtonManager = require(ReplicatedStorage.Modules.UI.ButtonManager)
local UIManager = require(ReplicatedStorage.Modules.UI.UIManager)
local InventoryModule = require(ReplicatedStorage.Modules.Inventory.InventoryModule)
local LootModule = require(ReplicatedStorage.Modules.Loot.LootModule)

-- ============================================
-- INVENTORY UI CLASS
-- ============================================

local InventoryUI = setmetatable({}, {__index = BaseUI})
InventoryUI.__index = InventoryUI

function InventoryUI.new()
	local self = BaseUI.new({
		Name = "InventoryUI",
		ToggleKey = Enum.KeyCode.I,
		CloseOnEscape = true,
		StartVisible = false,
		RemoteEvents = {
			"SyncInventory",
			"ItemUsed",
			"LootNotification",
			"GetInventory",
			"UseItem",
			"SortInventory"
		}
	})

	setmetatable(self, InventoryUI)

	-- Custom properties
	self.CurrentInventory = nil

	return self
end

-- ============================================
-- UI CREATION (Override BaseUI)
-- ============================================

function InventoryUI:CreateMainFrame(parent)
	local mainFrame = self:CreateFrame({
		Parent = parent,
		Name = "MainFrame",
		Size = UDim2.new(0, 600, 0, 500),
		Position = UDim2.new(0.5, -300, 0.5, -250),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel = 2,
		BorderColor3 = Color3.fromRGB(100, 100, 100),
		Visible = false,
		CornerRadius = 10
	})

	-- Title
	local title = self:CreateLabel({
		Parent = mainFrame,
		Name = "Title",
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.new(0, 0, 0, 0),
		Text = "📦 Inventory",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		CornerRadius = 10
	})

	-- Gold Display
	local goldLabel = self:CreateLabel({
		Parent = mainFrame,
		Name = "GoldLabel",
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.new(0, 10, 0, 50),
		Text = "💰 Tiên Ngọc: 0",
		TextColor3 = Color3.fromRGB(255, 215, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left
	})

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
	ButtonManager.CreateCloseButton(mainFrame, function()
		self:Close()
	end)

	-- Sort Button
	ButtonManager.CreatePrimaryButton(mainFrame, "Sort", UDim2.new(0, 10, 1, -40), function()
		self:SortInventory()
	end)

	return mainFrame
end

-- ============================================
-- ITEM SLOT CREATION
-- ============================================

function InventoryUI:CreateItemSlot(itemData)
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
		iconText.Text = string.sub(itemData.Name, 1, 2)
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
		self:UseItem(itemData)
	end)

	-- Tooltip on hover
	button.MouseEnter:Connect(function()
		self:ShowTooltip(itemData, slot)
	end)

	button.MouseLeave:Connect(function()
		self:HideTooltip()
	end)

	return slot
end

-- ============================================
-- TOOLTIP SYSTEM
-- ============================================

function InventoryUI:ShowTooltip(itemData, slotFrame)
	if not self.ScreenGui then return end

	self:HideTooltip()

	local tooltip = Instance.new("Frame")
	tooltip.Name = "Tooltip"
	tooltip.Size = UDim2.new(0, 200, 0, 100)
	tooltip.Position = UDim2.new(0, slotFrame.AbsolutePosition.X + 90, 0, slotFrame.AbsolutePosition.Y)
	tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	tooltip.BorderSizePixel = 2
	tooltip.BorderColor3 = itemData.Rarity and itemData.Rarity.Color or Color3.fromRGB(100, 100, 100)
	tooltip.ZIndex = 10
	tooltip.Parent = self.ScreenGui

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

function InventoryUI:HideTooltip()
	if not self.ScreenGui then return end

	local tooltip = self.ScreenGui:FindFirstChild("Tooltip")
	if tooltip then
		tooltip:Destroy()
	end
end

-- ============================================
-- DATA UPDATES
-- ============================================

function InventoryUI:UpdateInventory(inventoryData)
	self.CurrentInventory = inventoryData

	if not self.MainFrame then return end

	-- Update gold
	local goldLabel = self.MainFrame:FindFirstChild("GoldLabel")
	if goldLabel then
		goldLabel.Text = "💰 Tiên Ngọc: " .. (inventoryData.Gold or 0)
	end

	-- Clear existing items
	local grid = self.MainFrame:FindFirstChild("InventoryGrid")
	if grid then
		for _, child in ipairs(grid:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end

		-- Add items
		for _, itemData in ipairs(inventoryData.Items or {}) do
			local slot = self:CreateItemSlot(itemData)
			slot.Parent = grid
		end
	end
end

-- ============================================
-- ACTIONS
-- ============================================

function InventoryUI:UseItem(itemData)
	if itemData.Type ~= "Pill" then
		self:ShowError("Cannot use this item!")
		return
	end

	self:FireServer("UseItem", itemData.Name)
end

function InventoryUI:SortInventory()
	self:FireServer("SortInventory")
end

function InventoryUI:RequestInventory()
	self:FireServer("GetInventory")
end

-- ============================================
-- REMOTE EVENT HANDLERS
-- ============================================

function InventoryUI:OnSyncInventory(inventoryData)
	self:UpdateInventory(inventoryData)
end

function InventoryUI:OnItemUsed(success, message)
	if success then
		self:ShowSuccess(message)
		self:RequestInventory()
	else
		self:ShowError(message)
	end
end

function InventoryUI:OnLootNotification(message)
	self:ShowNotification(message)
end

-- ============================================
-- HOOKS (Override BaseUI)
-- ============================================

function InventoryUI:OnOpen()
	self:RequestInventory()
end

function InventoryUI:OnInitialized()
	-- Any additional initialization
end

-- ============================================
-- INITIALIZATION
-- ============================================

local inventoryUI = InventoryUI.new()
inventoryUI:Initialize()

-- Register with UIManager
UIManager.Register("Inventory", inventoryUI)

return inventoryUI
