-- MobileUIButtons.lua - Mobile buttons cho các UIs
-- Copy vào StarterPlayerScripts/MobileUIButtons (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Chỉ hiện trên Mobile
if not UserInputService.TouchEnabled then
	return -- PC dùng keyboard shortcuts
end

-- ========================================
-- CREATE MOBILE UI
-- ========================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileUIButtons"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ========================================
-- BUTTON CONFIGURATION
-- ========================================

local buttons = {
	-- Right side buttons (UIs)
	{
		Name = "Inventory",
		Icon = "🎒",
		Key = "I",
		Position = UDim2.new(1, -70, 0.3, 0),
		Color = Color3.fromRGB(100, 150, 200),
		Action = function()
			local inventoryUI = playerGui:FindFirstChild("InventoryUI")
			if inventoryUI and inventoryUI:FindFirstChild("MainFrame") then
				inventoryUI.MainFrame.Visible = not inventoryUI.MainFrame.Visible
			end
		end
	},
	{
		Name = "Equipment",
		Icon = "⚔️",
		Key = "E",
		Position = UDim2.new(1, -70, 0.4, 0),
		Color = Color3.fromRGB(200, 100, 100),
		Action = function()
			local equipUI = playerGui:FindFirstChild("EquipmentUI")
			if equipUI and equipUI:FindFirstChild("MainFrame") then
				equipUI.MainFrame.Visible = not equipUI.MainFrame.Visible
			end
		end
	},
	{
		Name = "Shop",
		Icon = "🛒",
		Key = "B",
		Position = UDim2.new(1, -70, 0.5, 0),
		Color = Color3.fromRGB(200, 200, 100),
		Action = function()
			local shopUI = playerGui:FindFirstChild("ShopUI")
			if shopUI and shopUI:FindFirstChild("MainFrame") then
				shopUI.MainFrame.Visible = not shopUI.MainFrame.Visible
			end
		end
	},
	{
		Name = "Quest",
		Icon = "📜",
		Key = "Q",
		Position = UDim2.new(1, -70, 0.6, 0),
		Color = Color3.fromRGB(150, 100, 200),
		Action = function()
			local questUI = playerGui:FindFirstChild("QuestUI")
			if questUI and questUI:FindFirstChild("MainFrame") then
				questUI.MainFrame.Visible = not questUI.MainFrame.Visible
			end
		end
	},

	-- Ma Đạo buttons
	{
		Name = "HonPhien",
		Icon = "👻",
		Key = "H",
		Position = UDim2.new(1, -70, 0.7, 0),
		Color = Color3.fromRGB(200, 0, 200),
		Action = function()
			local honPhienUI = playerGui:FindFirstChild("HonPhienAdvancedUI")
			if honPhienUI and honPhienUI:FindFirstChild("MainFrame") then
				honPhienUI.MainFrame.Visible = not honPhienUI.MainFrame.Visible
			end
		end
	},
	{
		Name = "ThienKiep",
		Icon = "⚡",
		Key = "T",
		Position = UDim2.new(1, -70, 0.8, 0),
		Color = Color3.fromRGB(150, 0, 255),
		Action = function()
			local thienKiepUI = playerGui:FindFirstChild("ThienKiepUI")
			if thienKiepUI and thienKiepUI:FindFirstChild("MainFrame") then
				thienKiepUI.MainFrame.Visible = not thienKiepUI.MainFrame.Visible
			end
		end
	},

	-- Admin button (bottom right)
	{
		Name = "Admin",
		Icon = "🔧",
		Key = "F1",
		Position = UDim2.new(1, -70, 1, -200),
		Color = Color3.fromRGB(255, 50, 50),
		Action = function()
			-- Check if admin
			local AdminModule = ReplicatedStorage:FindFirstChild("Modules")
				and ReplicatedStorage.Modules:FindFirstChild("Admin")
				and ReplicatedStorage.Modules.Admin:FindFirstChild("AdminModule")

			if AdminModule then
				local adminMod = require(AdminModule)
				if adminMod.IsAdmin(player) then
					local adminUI = playerGui:FindFirstChild("AdminUI")
					if adminUI and adminUI:FindFirstChild("MainFrame") then
						adminUI.MainFrame.Visible = not adminUI.MainFrame.Visible
					end
				end
			end
		end
	}
}

-- ========================================
-- CREATE BUTTONS
-- ========================================

for _, btnConfig in ipairs(buttons) do
	local button = Instance.new("TextButton")
	button.Name = btnConfig.Name .. "Button"
	button.Size = UDim2.new(0, 60, 0, 60)
	button.Position = btnConfig.Position
	button.AnchorPoint = Vector2.new(0, 0)
	button.BackgroundColor3 = btnConfig.Color
	button.BorderSizePixel = 0
	button.Text = btnConfig.Icon
	button.TextSize = 30
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Parent = screenGui

	-- Corner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = button

	-- Shadow effect
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(0, 0, 0)
	uiStroke.Thickness = 2
	uiStroke.Transparency = 0.5
	uiStroke.Parent = button

	-- Key indicator (small text)
	local keyLabel = Instance.new("TextLabel")
	keyLabel.Size = UDim2.new(0, 30, 0, 15)
	keyLabel.Position = UDim2.new(1, -32, 1, -17)
	keyLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	keyLabel.BackgroundTransparency = 0.5
	keyLabel.BorderSizePixel = 0
	keyLabel.Text = btnConfig.Key
	keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyLabel.TextSize = 10
	keyLabel.Font = Enum.Font.Code
	keyLabel.Parent = button

	local keyCorner = Instance.new("UICorner")
	keyCorner.CornerRadius = UDim.new(0, 4)
	keyCorner.Parent = keyLabel

	-- Button click
	button.MouseButton1Click:Connect(function()
		btnConfig.Action()

		-- Visual feedback
		button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		task.wait(0.1)
		button.BackgroundColor3 = btnConfig.Color
	end)
end

-- ========================================
-- HIDE ADMIN BUTTON IF NOT ADMIN
-- ========================================

task.spawn(function()
	local AdminModule = ReplicatedStorage:FindFirstChild("Modules")
		and ReplicatedStorage.Modules:FindFirstChild("Admin")
		and ReplicatedStorage.Modules.Admin:FindFirstChild("AdminModule")

	if AdminModule then
		local adminMod = require(AdminModule)
		if not adminMod.IsAdmin(player) then
			-- Hide admin button
			local adminButton = screenGui:FindFirstChild("AdminButton")
			if adminButton then
				adminButton.Visible = false
			end
		end
	end
end)

-- ========================================
-- TOGGLE ALL BUTTONS (Hold to show/hide)
-- ========================================

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 40, 0, 40)
toggleButton.Position = UDim2.new(1, -50, 0.1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
toggleButton.BackgroundTransparency = 0.5
toggleButton.Text = "☰"
toggleButton.TextSize = 25
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.BorderSizePixel = 0
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleButton

local buttonsVisible = true

toggleButton.MouseButton1Click:Connect(function()
	buttonsVisible = not buttonsVisible

	for _, child in ipairs(screenGui:GetChildren()) do
		if child:IsA("TextButton") and child ~= toggleButton then
			child.Visible = buttonsVisible
		end
	end

	if buttonsVisible then
		toggleButton.Text = "☰"
		toggleButton.BackgroundTransparency = 0.5
	else
		toggleButton.Text = "✕"
		toggleButton.BackgroundTransparency = 0.3
	end
end)

print("✅ MobileUIButtons loaded (7 UI shortcuts)")
