-- MobileUIScaler.lua - Auto-scale UIs for mobile
-- Copy vào StarterPlayerScripts/MobileUIScaler (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ========================================
-- DETECT DEVICE TYPE
-- ========================================

local function GetDeviceType()
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		-- Mobile (phone/tablet)
		local screenSize = playerGui.AbsoluteSize
		if screenSize.X < 600 then
			return "Phone"
		else
			return "Tablet"
		end
	elseif UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
		return "PC"
	else
		return "Console"
	end
end

local deviceType = GetDeviceType()
print("📱 Device type: " .. deviceType)

-- Only run on mobile
if deviceType == "PC" or deviceType == "Console" then
	return
end

-- ========================================
-- SCALING CONFIGURATION
-- ========================================

local ScaleConfig = {
	Phone = {
		UIScale = 0.7,           -- 70% of original size
		FontScale = 0.85,        -- 85% of font size
		ButtonScale = 0.8,       -- 80% of button size
		MaxWidth = 450,          -- Max UI width
		MaxHeight = 500          -- Max UI height
	},
	Tablet = {
		UIScale = 0.85,
		FontScale = 0.95,
		ButtonScale = 0.9,
		MaxWidth = 650,
		MaxHeight = 650
	}
}

local config = ScaleConfig[deviceType] or ScaleConfig.Phone

-- ========================================
-- UI LIST TO SCALE
-- ========================================

local uisToScale = {
	"InventoryUI",
	"EquipmentUI",
	"ShopUI",
	"QuestUI",
	"HonPhienAdvancedUI",
	"ThienKiepUI",
	"AdminUI"
}

-- ========================================
-- SCALE UI FUNCTION
-- ========================================

local function ScaleUI(uiName)
	local ui = playerGui:FindFirstChild(uiName)
	if not ui then return end

	local mainFrame = ui:FindFirstChild("MainFrame")
	if not mainFrame then return end

	-- Scale size
	local originalSize = mainFrame.Size
	local width = math.min(originalSize.X.Offset * config.UIScale, config.MaxWidth)
	local height = math.min(originalSize.Y.Offset * config.UIScale, config.MaxHeight)

	mainFrame.Size = UDim2.new(0, width, 0, height)
	mainFrame.Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2)

	-- Scale all text elements
	for _, descendant in ipairs(mainFrame:GetDescendants()) do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
			if descendant.TextSize then
				descendant.TextSize = math.floor(descendant.TextSize * config.FontScale)
			end
		end

		-- Scale buttons
		if descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
			if descendant.Size.X.Offset > 0 then
				local btnWidth = descendant.Size.X.Offset * config.ButtonScale
				local btnHeight = descendant.Size.Y.Offset * config.ButtonScale
				descendant.Size = UDim2.new(descendant.Size.X.Scale, btnWidth, descendant.Size.Y.Scale, btnHeight)
			end
		end
	end

	print("✅ Scaled " .. uiName .. " for " .. deviceType)
end

-- ========================================
-- SCALE ALL UIs
-- ========================================

-- Wait for UIs to load
task.wait(2)

for _, uiName in ipairs(uisToScale) do
	ScaleUI(uiName)
end

-- ========================================
-- SPECIAL: ADMIN UI MOBILE LAYOUT
-- ========================================

if deviceType == "Phone" then
	local adminUI = playerGui:FindFirstChild("AdminUI")
	if adminUI and adminUI:FindFirstChild("MainFrame") then
		local mainFrame = adminUI.MainFrame

		-- Make admin UI fullscreen on phone
		mainFrame.Size = UDim2.new(1, -20, 1, -20)
		mainFrame.Position = UDim2.new(0, 10, 0, 10)

		-- Hide side menu, show tabs as dropdown
		local sideMenu = mainFrame:FindFirstChild("SideMenu")
		if sideMenu then
			sideMenu.Size = UDim2.new(0, 150, 1, -50) -- Narrower
		end

		-- Adjust content area
		local contentArea = mainFrame:FindFirstChild("ContentArea")
		if contentArea then
			contentArea.Size = UDim2.new(1, -160, 1, -180)
			contentArea.Position = UDim2.new(0, 155, 0, 55)
		end

		-- Smaller console
		local console = mainFrame:FindFirstChild("Console")
		if console then
			console.Size = UDim2.new(1, -20, 0, 80)
		end
	end
end

-- ========================================
-- ADD CLOSE BUTTON REMINDERS
-- ========================================

-- Mobile users might not know how to close UIs
local function AddMobileHint(ui)
	if not ui or not ui:FindFirstChild("MainFrame") then return end

	local mainFrame = ui.MainFrame
	local closeButton = mainFrame:FindFirstChild("CloseButton")

	if closeButton then
		-- Make close button bigger on mobile
		closeButton.Size = UDim2.new(0, 50, 0, 50)

		-- Add hint
		local hint = Instance.new("TextLabel")
		hint.Size = UDim2.new(0, 100, 0, 20)
		hint.Position = UDim2.new(1, -110, 0, -25)
		hint.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
		hint.Text = "← Close"
		hint.TextColor3 = Color3.fromRGB(255, 255, 255)
		hint.TextSize = 12
		hint.Font = Enum.Font.GothamBold
		hint.Parent = mainFrame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 5)
		corner.Parent = hint

		-- Auto-hide hint after 3 seconds
		task.delay(3, function()
			hint:Destroy()
		end)
	end
end

-- Add hints to all UIs
for _, uiName in ipairs(uisToScale) do
	local ui = playerGui:FindFirstChild(uiName)
	if ui then
		-- Add hint when UI opens
		local mainFrame = ui:FindFirstChild("MainFrame")
		if mainFrame then
			mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
				if mainFrame.Visible then
					AddMobileHint(ui)
				end
			end)
		end
	end
end

-- ========================================
-- ORIENTATION CHANGE HANDLER
-- ========================================

local camera = workspace.CurrentCamera
camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	-- Re-detect device type
	deviceType = GetDeviceType()
	config = ScaleConfig[deviceType] or ScaleConfig.Phone

	-- Re-scale all UIs
	task.wait(0.1)
	for _, uiName in ipairs(uisToScale) do
		ScaleUI(uiName)
	end

	print("📱 Screen rotated, re-scaled UIs for " .. deviceType)
end)

print("✅ MobileUIScaler loaded for " .. deviceType)
