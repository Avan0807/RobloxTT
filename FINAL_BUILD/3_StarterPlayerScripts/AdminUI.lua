-- AdminUI.lua - Admin Control Panel
-- Copy vào StarterPlayer/StarterPlayerScripts/AdminUI (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local AdminModule = require(ReplicatedStorage.Modules.Admin.AdminModule)

-- ========================================
-- UI VARIABLES
-- ========================================

local adminUI
local isOpen = false
local isAdmin = false

-- ========================================
-- CHECK IF ADMIN
-- ========================================

local function CheckAdmin()
	isAdmin = AdminModule.IsAdmin(player)
	return isAdmin
end

-- ========================================
-- CREATE UI
-- ========================================

local function CreateUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AdminUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Main Frame (Hidden by default)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 900, 0, 600)
	mainFrame.Position = UDim2.new(0.5, -450, 0.5, -300)
	mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	mainFrame.BorderSizePixel = 0
	mainFrame.Visible = false
	mainFrame.Parent = screenGui

	-- Corner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame

	-- Title Bar
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 50)
	titleBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = mainFrame

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 12)
	titleCorner.Parent = titleBar

	-- Title Text
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -100, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Text = "🔧 ADMIN CONTROL PANEL"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 24
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = titleBar

	-- Close Button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 45, 0, 45)
	closeButton.Position = UDim2.new(1, -47, 0, 2.5)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 22
	closeButton.Parent = titleBar

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		ToggleUI()
	end)

	-- Side Menu (Tabs)
	local sideMenu = Instance.new("Frame")
	sideMenu.Name = "SideMenu"
	sideMenu.Size = UDim2.new(0, 200, 1, -50)
	sideMenu.Position = UDim2.new(0, 0, 0, 50)
	sideMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	sideMenu.BorderSizePixel = 0
	sideMenu.Parent = mainFrame

	local sideCorner = Instance.new("UICorner")
	sideCorner.CornerRadius = UDim.new(0, 0)
	sideCorner.Parent = sideMenu

	local menuLayout = Instance.new("UIListLayout")
	menuLayout.Padding = UDim.new(0, 5)
	menuLayout.Parent = sideMenu

	-- Content Area
	local contentArea = Instance.new("Frame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.new(1, -210, 1, -60)
	contentArea.Position = UDim2.new(0, 205, 0, 55)
	contentArea.BackgroundTransparency = 1
	contentArea.Parent = mainFrame

	-- Output Console (Bottom)
	local console = Instance.new("Frame")
	console.Name = "Console"
	console.Size = UDim2.new(1, -20, 0, 120)
	console.Position = UDim2.new(0, 10, 1, -130)
	console.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	console.BorderSizePixel = 0
	console.Parent = mainFrame

	local consoleCorner = Instance.new("UICorner")
	consoleCorner.CornerRadius = UDim.new(0, 8)
	consoleCorner.Parent = console

	local consoleTitle = Instance.new("TextLabel")
	consoleTitle.Name = "ConsoleTitle"
	consoleTitle.Size = UDim2.new(1, -10, 0, 25)
	consoleTitle.Position = UDim2.new(0, 5, 0, 0)
	consoleTitle.BackgroundTransparency = 1
	consoleTitle.Font = Enum.Font.GothamBold
	consoleTitle.Text = "📋 Output Console"
	consoleTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
	consoleTitle.TextSize = 14
	consoleTitle.TextXAlignment = Enum.TextXAlignment.Left
	consoleTitle.Parent = console

	local consoleOutput = Instance.new("TextLabel")
	consoleOutput.Name = "Output"
	consoleOutput.Size = UDim2.new(1, -10, 1, -30)
	consoleOutput.Position = UDim2.new(0, 5, 0, 28)
	consoleOutput.BackgroundTransparency = 1
	consoleOutput.Font = Enum.Font.Code
	consoleOutput.Text = "Ready..."
	consoleOutput.TextColor3 = Color3.fromRGB(100, 255, 100)
	consoleOutput.TextSize = 13
	consoleOutput.TextXAlignment = Enum.TextXAlignment.Left
	consoleOutput.TextYAlignment = Enum.TextYAlignment.Top
	consoleOutput.TextWrapped = true
	consoleOutput.Parent = console

	return screenGui
end

-- ========================================
-- CREATE TAB BUTTON
-- ========================================

local currentTab = nil

local function CreateTabButton(name, icon, parent)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(1, -10, 0, 45)
	button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	button.Font = Enum.Font.GothamBold
	button.Text = icon .. " " .. name
	button.TextColor3 = Color3.fromRGB(200, 200, 200)
	button.TextSize = 15
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	button.MouseButton1Click:Connect(function()
		-- Deselect all tabs
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("TextButton") then
				child.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				child.TextColor3 = Color3.fromRGB(200, 200, 200)
			end
		end

		-- Select this tab
		button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		button.TextColor3 = Color3.fromRGB(255, 255, 255)

		-- Show content
		ShowTab(name)
	end)

	return button
end

-- ========================================
-- SHOW TAB
-- ========================================

function ShowTab(tabName)
	local contentArea = adminUI.MainFrame.ContentArea

	-- Clear content
	for _, child in ipairs(contentArea:GetChildren()) do
		child:Destroy()
	end

	currentTab = tabName

	if tabName == "Presets" then
		CreatePresetsTab(contentArea)
	elseif tabName == "Cultivation" then
		CreateCultivationTab(contentArea)
	elseif tabName == "Ma Đạo" then
		CreateMaDaoTab(contentArea)
	elseif tabName == "Items" then
		CreateItemsTab(contentArea)
	elseif tabName == "Combat" then
		CreateCombatTab(contentArea)
	elseif tabName == "Player" then
		CreatePlayerTab(contentArea)
	elseif tabName == "Commands" then
		CreateCommandsTab(contentArea)
	end
end

-- ========================================
-- CREATE PRESETS TAB
-- ========================================

function CreatePresetsTab(parent)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -140)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 8
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.Parent = scroll

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)

	-- Create preset buttons
	for i, preset in ipairs(AdminModule.Presets) do
		local presetFrame = Instance.new("Frame")
		presetFrame.Size = UDim2.new(1, -10, 0, 100)
		presetFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		presetFrame.BorderSizePixel = 0
		presetFrame.Parent = scroll

		local presetCorner = Instance.new("UICorner")
		presetCorner.CornerRadius = UDim.new(0, 10)
		presetCorner.Parent = presetFrame

		local presetTitle = Instance.new("TextLabel")
		presetTitle.Size = UDim2.new(1, -20, 0, 30)
		presetTitle.Position = UDim2.new(0, 10, 0, 10)
		presetTitle.BackgroundTransparency = 1
		presetTitle.Font = Enum.Font.GothamBold
		presetTitle.Text = preset.Name
		presetTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
		presetTitle.TextSize = 18
		presetTitle.TextXAlignment = Enum.TextXAlignment.Left
		presetTitle.Parent = presetFrame

		local presetDesc = Instance.new("TextLabel")
		presetDesc.Size = UDim2.new(1, -20, 0, 30)
		presetDesc.Position = UDim2.new(0, 10, 0, 40)
		presetDesc.BackgroundTransparency = 1
		presetDesc.Font = Enum.Font.Gotham
		presetDesc.Text = #preset.Commands .. " commands"
		presetDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
		presetDesc.TextSize = 14
		presetDesc.TextXAlignment = Enum.TextXAlignment.Left
		presetDesc.Parent = presetFrame

		local applyButton = Instance.new("TextButton")
		applyButton.Size = UDim2.new(0, 150, 0, 35)
		applyButton.Position = UDim2.new(1, -160, 0, 55)
		applyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
		applyButton.Font = Enum.Font.GothamBold
		applyButton.Text = "⚡ APPLY"
		applyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		applyButton.TextSize = 16
		applyButton.Parent = presetFrame

		local applyCorner = Instance.new("UICorner")
		applyCorner.CornerRadius = UDim.new(0, 8)
		applyCorner.Parent = applyButton

		applyButton.MouseButton1Click:Connect(function()
			ExecutePreset(i)
		end)
	end
end

-- ========================================
-- CREATE CULTIVATION TAB
-- ========================================

function CreateCultivationTab(parent)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -140)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 8
	scroll.CanvasSize = UDim2.new(0, 0, 0, 400)
	scroll.Parent = parent

	-- Path Selection
	CreateLabel(scroll, "Cultivation Path", 10)
	CreateButtonRow(scroll, {"TienThien", "CoThan", "MaDao"}, function(path)
		ExecuteCommand("setPath", {path})
	end, 50)

	-- Realm Selection
	CreateLabel(scroll, "Set Realm", 110)
	local realms = {"LuyenKhi", "TrucCo", "KimDan", "NguyenAnh", "HoaThan", "LuyenHu", "HopThe", "DaiThua", "DoKiep"}
	CreateButtonRow(scroll, realms, function(realm)
		ExecuteCommand("setRealm", {realm, "5"})
	end, 150)

	-- Tu Vi
	CreateLabel(scroll, "Add Tu Vi", 310)
	CreateButtonRow(scroll, {"10K", "100K", "1M", "10M"}, function(amount)
		local tuvi = {["10K"] = 10000, ["100K"] = 100000, ["1M"] = 1000000, ["10M"] = 10000000}
		ExecuteCommand("addTuVi", {tostring(tuvi[amount])})
	end, 350)
end

-- ========================================
-- CREATE MA ĐẠO TAB
-- ========================================

function CreateMaDaoTab(parent)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -140)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 8
	scroll.CanvasSize = UDim2.new(0, 0, 0, 400)
	scroll.Parent = parent

	-- Souls
	CreateLabel(scroll, "Add Souls", 10)
	CreateButtonRow(scroll, {"1K", "10K", "50K", "100K"}, function(amount)
		local souls = {["1K"] = 1000, ["10K"] = 10000, ["50K"] = 50000, ["100K"] = 100000}
		ExecuteCommand("addSouls", {tostring(souls[amount])})
	end, 50)

	-- Kills
	CreateLabel(scroll, "Add Kills", 110)
	CreateButtonRow(scroll, {"100", "1K", "10K", "100K"}, function(amount)
		local kills = {["100"] = 100, ["1K"] = 1000, ["10K"] = 10000, ["100K"] = 100000}
		ExecuteCommand("addKills", {tostring(kills[amount])})
	end, 150)

	-- Tier
	CreateLabel(scroll, "Set Tàn Sát Tier", 210)
	CreateButtonRow(scroll, {"Tier 1", "Tier 2", "Tier 3", "Tier 4", "Tier 5"}, function(tier)
		local tierNum = tonumber(tier:match("%d+"))
		ExecuteCommand("setTier", {tostring(tierNum)})
	end, 250)
end

-- ========================================
-- CREATE ITEMS TAB
-- ========================================

function CreateItemsTab(parent)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -140)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 8
	scroll.CanvasSize = UDim2.new(0, 0, 0, 300)
	scroll.Parent = parent

	-- Gold
	CreateLabel(scroll, "Add Gold", 10)
	CreateButtonRow(scroll, {"10K", "100K", "1M", "99M"}, function(amount)
		local gold = {["10K"] = 10000, ["100K"] = 100000, ["1M"] = 1000000, ["99M"] = 99999999}
		ExecuteCommand("giveGold", {tostring(gold[amount])})
	end, 50)

	-- Quick Items
	CreateLabel(scroll, "Give Items", 110)
	CreateButtonRow(scroll, {"Kim Đan", "Trúc Cơ Đan", "Clear Inv"}, function(item)
		if item == "Clear Inv" then
			ExecuteCommand("clearInventory", {})
		else
			ExecuteCommand("giveItem", {item})
		end
	end, 150)
end

-- ========================================
-- CREATE COMBAT TAB
-- ========================================

function CreateCombatTab(parent)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -140)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 8
	scroll.CanvasSize = UDim2.new(0, 0, 0, 300)
	scroll.Parent = parent

	-- Spawn Enemies
	CreateLabel(scroll, "Spawn Enemies", 10)
	CreateButtonRow(scroll, {"Normal", "Elite", "Boss"}, function(type)
		ExecuteCommand("spawnEnemy", {type, "10"})
	end, 50)

	-- Combat Actions
	CreateLabel(scroll, "Combat Actions", 110)
	CreateButtonRow(scroll, {"Kill All", "Heal", "God Mode"}, function(action)
		if action == "Kill All" then
			ExecuteCommand("killAll", {})
		elseif action == "Heal" then
			ExecuteCommand("heal", {})
		elseif action == "God Mode" then
			ExecuteCommand("god", {})
		end
	end, 150)
end

-- ========================================
-- CREATE PLAYER TAB
-- ========================================

function CreatePlayerTab(parent)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -140)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 8
	scroll.CanvasSize = UDim2.new(0, 0, 0, 300)
	scroll.Parent = parent

	-- Speed
	CreateLabel(scroll, "Walk Speed", 10)
	CreateButtonRow(scroll, {"16 (Normal)", "50", "100", "200"}, function(speed)
		local spd = tonumber(speed:match("%d+"))
		ExecuteCommand("speed", {tostring(spd)})
	end, 50)

	-- Utility
	CreateLabel(scroll, "Utility", 110)
	CreateButtonRow(scroll, {"TP Spawn", "Info", "Save", "Reset"}, function(action)
		if action == "TP Spawn" then
			ExecuteCommand("tp", {"0", "50", "0"})
		elseif action == "Info" then
			ExecuteCommand("info", {})
		elseif action == "Save" then
			ExecuteCommand("save", {})
		elseif action == "Reset" then
			ExecuteCommand("reset", {})
		end
	end, 150)
end

-- ========================================
-- CREATE COMMANDS TAB
-- ========================================

function CreateCommandsTab(parent)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -140)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 8
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.Parent = scroll

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)

	-- List all commands
	for _, cmd in ipairs(AdminModule.Commands) do
		local cmdFrame = Instance.new("Frame")
		cmdFrame.Size = UDim2.new(1, -10, 0, 60)
		cmdFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		cmdFrame.BorderSizePixel = 0
		cmdFrame.Parent = scroll

		local cmdCorner = Instance.new("UICorner")
		cmdCorner.CornerRadius = UDim.new(0, 8)
		cmdCorner.Parent = cmdFrame

		local cmdName = Instance.new("TextLabel")
		cmdName.Size = UDim2.new(0.4, 0, 0, 25)
		cmdName.Position = UDim2.new(0, 10, 0, 5)
		cmdName.BackgroundTransparency = 1
		cmdName.Font = Enum.Font.GothamBold
		cmdName.Text = "/" .. cmd.Name
		cmdName.TextColor3 = Color3.fromRGB(255, 200, 0)
		cmdName.TextSize = 14
		cmdName.TextXAlignment = Enum.TextXAlignment.Left
		cmdName.Parent = cmdFrame

		local cmdDesc = Instance.new("TextLabel")
		cmdDesc.Size = UDim2.new(1, -20, 0, 25)
		cmdDesc.Position = UDim2.new(0, 10, 0, 30)
		cmdDesc.BackgroundTransparency = 1
		cmdDesc.Font = Enum.Font.Gotham
		cmdDesc.Text = cmd.Description .. " | Ex: /" .. cmd.Example
		cmdDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
		cmdDesc.TextSize = 12
		cmdDesc.TextXAlignment = Enum.TextXAlignment.Left
		cmdDesc.Parent = cmdFrame
	end
end

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

function CreateLabel(parent, text, yPos)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 30)
	label.Position = UDim2.new(0, 10, 0, yPos)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

function CreateButtonRow(parent, buttons, callback, yPos)
	local buttonWidth = (680 - (#buttons * 10)) / #buttons

	for i, btnText in ipairs(buttons) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(0, buttonWidth, 0, 40)
		button.Position = UDim2.new(0, 10 + (i - 1) * (buttonWidth + 10), 0, yPos)
		button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		button.Font = Enum.Font.GothamBold
		button.Text = btnText
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 14
		button.Parent = parent

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = button

		button.MouseButton1Click:Connect(function()
			callback(btnText)
		end)
	end
end

-- ========================================
-- EXECUTE COMMAND
-- ========================================

function ExecuteCommand(commandName, args)
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("ExecuteAdminCommand")

	if remoteEvent then
		remoteEvent:FireServer(commandName, args)
	end
end

-- ========================================
-- EXECUTE PRESET
-- ========================================

function ExecutePreset(presetIndex)
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("ExecuteAdminPreset")

	if remoteEvent then
		remoteEvent:FireServer(presetIndex)
	end
end

-- ========================================
-- UPDATE CONSOLE
-- ========================================

function UpdateConsole(success, message)
	if not adminUI or not adminUI.MainFrame then return end

	local console = adminUI.MainFrame.Console.Output

	if success then
		console.TextColor3 = Color3.fromRGB(100, 255, 100)
		console.Text = "✅ " .. message
	else
		console.TextColor3 = Color3.fromRGB(255, 100, 100)
		console.Text = "❌ " .. message
	end
end

-- ========================================
-- TOGGLE UI
-- ========================================

function ToggleUI()
	if not CheckAdmin() then
		print("You are not an admin!")
		return
	end

	if not adminUI then
		adminUI = CreateUI()

		-- Create tabs
		local sideMenu = adminUI.MainFrame.SideMenu
		CreateTabButton("Presets", "⚡", sideMenu)
		CreateTabButton("Cultivation", "🧘", sideMenu)
		CreateTabButton("Ma Đạo", "👹", sideMenu)
		CreateTabButton("Items", "💎", sideMenu)
		CreateTabButton("Combat", "⚔️", sideMenu)
		CreateTabButton("Player", "👤", sideMenu)
		CreateTabButton("Commands", "📝", sideMenu)

		-- Show first tab
		ShowTab("Presets")
	end

	isOpen = not isOpen
	adminUI.MainFrame.Visible = isOpen
end

-- ========================================
-- LISTEN FOR RESPONSES
-- ========================================

local function SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	if not remoteEvents then return end

	local response = remoteEvents:FindFirstChild("AdminCommandResponse")
	if response then
		response.OnClientEvent:Connect(UpdateConsole)
	end
end

-- ========================================
-- INPUT HANDLER
-- ========================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	-- Press F1 to open admin panel
	if input.KeyCode == Enum.KeyCode.F1 then
		ToggleUI()
	end
end)

-- ========================================
-- INITIALIZE
-- ========================================

if CheckAdmin() then
	print("🔧 AdminUI loaded! Press F1 to open Admin Panel")
	SetupRemoteEvents()
else
	print("Not an admin - AdminUI disabled")
end
