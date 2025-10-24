-- ThienKiepUI.lua - Thiên Kiếp UI
-- Copy vào StarterPlayer/StarterPlayerScripts/ThienKiepUI (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ThienKiepModule = require(ReplicatedStorage.Modules.ThienKiep.ThienKiepModule)

-- ========================================
-- UI VARIABLES
-- ========================================

local thienKiepUI
local isOpen = false

local activeThienKiep = nil
local playerData = nil

-- ========================================
-- CREATE UI
-- ========================================

local function CreateUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ThienKiepUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Main Frame (Hidden by default)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 600, 0, 500)
	mainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	mainFrame.BorderSizePixel = 0
	mainFrame.Visible = false
	mainFrame.Parent = screenGui

	-- Corner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = mainFrame

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 50)
	title.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
	title.BorderSizePixel = 0
	title.Font = Enum.Font.GothamBold
	title.Text = "⚡ THIÊN KIẾP (Heavenly Tribulation)"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 22
	title.Parent = mainFrame

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 10)
	titleCorner.Parent = title

	-- Close Button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -45, 0, 5)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 20
	closeButton.Parent = mainFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 5)
	closeCorner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		ToggleUI()
	end)

	-- Status
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, -20, 0, 30)
	statusLabel.Position = UDim2.new(0, 10, 0, 60)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.Text = "Status: Ready"
	statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	statusLabel.TextSize = 16
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Parent = mainFrame

	-- Divider
	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.Size = UDim2.new(1, -20, 0, 2)
	divider.Position = UDim2.new(0, 10, 0, 100)
	divider.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
	divider.BorderSizePixel = 0
	divider.Parent = mainFrame

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "DescLabel"
	descLabel.Size = UDim2.new(1, -20, 0, 300)
	descLabel.Position = UDim2.new(0, 10, 0, 110)
	descLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	descLabel.BorderSizePixel = 0
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = "No Thiên Kiếp available"
	descLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	descLabel.TextSize = 14
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.TextWrapped = true
	descLabel.Parent = mainFrame

	local descCorner = Instance.new("UICorner")
	descCorner.CornerRadius = UDim.new(0, 5)
	descCorner.Parent = descLabel

	local descPadding = Instance.new("UIPadding")
	descPadding.PaddingLeft = UDim.new(0, 10)
	descPadding.PaddingRight = UDim.new(0, 10)
	descPadding.PaddingTop = UDim.new(0, 10)
	descPadding.PaddingBottom = UDim.new(0, 10)
	descPadding.Parent = descLabel

	-- Start Button
	local startButton = Instance.new("TextButton")
	startButton.Name = "StartButton"
	startButton.Size = UDim2.new(0, 250, 0, 50)
	startButton.Position = UDim2.new(0.5, -125, 1, -70)
	startButton.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
	startButton.Font = Enum.Font.GothamBold
	startButton.Text = "⚡ START THIÊN KIẾP"
	startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	startButton.TextSize = 18
	startButton.Parent = mainFrame

	local startCorner = Instance.new("UICorner")
	startCorner.CornerRadius = UDim.new(0, 8)
	startCorner.Parent = startButton

	startButton.MouseButton1Click:Connect(function()
		-- Send to server
		local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
			and ReplicatedStorage.RemoteEvents:FindFirstChild("StartThienKiep")

		if remoteEvent then
			remoteEvent:FireServer()
			ToggleUI()
		end
	end)

	-- Active Tribulation Display (Top-right corner)
	local activeFrame = Instance.new("Frame")
	activeFrame.Name = "ActiveFrame"
	activeFrame.Size = UDim2.new(0, 300, 0, 120)
	activeFrame.Position = UDim2.new(1, -310, 0, 10)
	activeFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	activeFrame.BorderSizePixel = 0
	activeFrame.Visible = false
	activeFrame.Parent = screenGui

	local activeCorner = Instance.new("UICorner")
	activeCorner.CornerRadius = UDim.new(0, 10)
	activeCorner.Parent = activeFrame

	local activeTitle = Instance.new("TextLabel")
	activeTitle.Name = "ActiveTitle"
	activeTitle.Size = UDim2.new(1, 0, 0, 30)
	activeTitle.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
	activeTitle.BorderSizePixel = 0
	activeTitle.Font = Enum.Font.GothamBold
	activeTitle.Text = "⚡ THIÊN KIẾP ACTIVE"
	activeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	activeTitle.TextSize = 16
	activeTitle.Parent = activeFrame

	local activeTitleCorner = Instance.new("UICorner")
	activeTitleCorner.CornerRadius = UDim.new(0, 10)
	activeTitleCorner.Parent = activeTitle

	local activeInfo = Instance.new("TextLabel")
	activeInfo.Name = "ActiveInfo"
	activeInfo.Size = UDim2.new(1, -20, 0, 80)
	activeInfo.Position = UDim2.new(0, 10, 0, 35)
	activeInfo.BackgroundTransparency = 1
	activeInfo.Font = Enum.Font.Gotham
	activeInfo.Text = "Boss: None\nTime: 0s"
	activeInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
	activeInfo.TextSize = 14
	activeInfo.TextXAlignment = Enum.TextXAlignment.Left
	activeInfo.TextYAlignment = Enum.TextYAlignment.Top
	activeInfo.Parent = activeFrame

	return screenGui
end

-- ========================================
-- UPDATE UI
-- ========================================

local function UpdateUI()
	if not thienKiepUI or not thienKiepUI.MainFrame then return end

	-- Check if player can attempt Thiên Kiếp
	if not playerData then
		thienKiepUI.MainFrame.StatusLabel.Text = "Status: Loading..."
		thienKiepUI.MainFrame.DescLabel.Text = "Loading player data..."
		thienKiepUI.MainFrame.StartButton.Visible = false
		return
	end

	local canAttempt, result = ThienKiepModule.CanAttemptThienKiep(playerData)

	if canAttempt then
		local kiep = result

		-- Update status
		thienKiepUI.MainFrame.StatusLabel.Text = "Status: ✅ Ready for Thiên Kiếp"
		thienKiepUI.MainFrame.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)

		-- Update description
		local desc = ThienKiepModule.GetDescription(kiep)
		thienKiepUI.MainFrame.DescLabel.Text = desc

		-- Show button
		thienKiepUI.MainFrame.StartButton.Visible = true
	else
		-- Cannot attempt
		thienKiepUI.MainFrame.StatusLabel.Text = "Status: ❌ Not Ready"
		thienKiepUI.MainFrame.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)

		-- Show reason
		thienKiepUI.MainFrame.DescLabel.Text = result

		-- Hide button
		thienKiepUI.MainFrame.StartButton.Visible = false
	end

	-- Update active tribulation
	if activeThienKiep and activeThienKiep.Active then
		thienKiepUI.ActiveFrame.Visible = true

		local elapsed = os.time() - activeThienKiep.StartTime
		local minutes = math.floor(elapsed / 60)
		local seconds = elapsed % 60

		thienKiepUI.ActiveFrame.ActiveInfo.Text = string.format(
			"Boss: %s\nTime: %d:%02d\nDefeat to breakthrough!",
			activeThienKiep.Kiep.Boss.Name,
			minutes,
			seconds
		)
	else
		thienKiepUI.ActiveFrame.Visible = false
	end
end

-- ========================================
-- TOGGLE UI
-- ========================================

function ToggleUI()
	if not thienKiepUI then
		thienKiepUI = CreateUI()
	end

	isOpen = not isOpen
	thienKiepUI.MainFrame.Visible = isOpen

	if isOpen then
		UpdateUI()
	end
end

-- ========================================
-- SYNC FROM SERVER
-- ========================================

local function OnSyncPlayerData(data)
	if data then
		playerData = data
		UpdateUI()
	end
end

local function OnSyncThienKiep(data)
	activeThienKiep = data
	UpdateUI()
end

-- ========================================
-- LISTEN FOR REMOTE EVENTS
-- ========================================

local function SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	if not remoteEvents then
		warn("RemoteEvents folder not found!")
		return
	end

	-- Sync Player Data
	local syncPlayer = remoteEvents:FindFirstChild("SyncPlayerData")
	if syncPlayer then
		syncPlayer.OnClientEvent:Connect(OnSyncPlayerData)
	end

	-- Sync Thiên Kiếp
	local syncThienKiep = remoteEvents:FindFirstChild("SyncThienKiep")
	if syncThienKiep then
		syncThienKiep.OnClientEvent:Connect(OnSyncThienKiep)
	end

	-- Notifications
	local notifEvent = remoteEvents:FindFirstChild("ThienKiepNotification")
	if notifEvent then
		notifEvent.OnClientEvent:Connect(function(message)
			print(message)
		end)
	end
end

-- ========================================
-- INPUT HANDLER
-- ========================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.T then
		ToggleUI()
	end
end)

-- ========================================
-- UPDATE LOOP
-- ========================================

task.spawn(function()
	while true do
		task.wait(1)
		if activeThienKiep and activeThienKiep.Active then
			UpdateUI()
		end
	end
end)

-- ========================================
-- INITIALIZE
-- ========================================

print("⚡ ThienKiepUI loaded! Press 'T' to open")

-- Setup remote events
SetupRemoteEvents()

-- Create active tribulation display immediately
thienKiepUI = CreateUI()
