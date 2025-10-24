-- TanSatUI.lua - Tàn Sát UI System
-- Copy vào StarterPlayer/StarterPlayerScripts/TanSatUI (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TanSatModule = require(ReplicatedStorage.Modules.TanSat.TanSatModule)

local TanSatUI = {}
TanSatUI.CurrentData = nil

-- ========================================
-- CREATE UI
-- ========================================

function TanSatUI.CreateUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TanSatUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- Sát Khí Tracker (Top Left)
	local tracker = Instance.new("Frame")
	tracker.Name = "SatKhiTracker"
	tracker.Size = UDim2.new(0, 300, 0, 120)
	tracker.Position = UDim2.new(0, 10, 0, 10)
	tracker.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	tracker.BackgroundTransparency = 0.3
	tracker.BorderSizePixel = 0
	tracker.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = tracker

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -10, 0, 25)
	title.Position = UDim2.new(0, 5, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = "🔥 Tàn Sát"
	title.TextColor3 = Color3.fromRGB(255, 100, 100)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = tracker

	-- Tier Name
	local tierName = Instance.new("TextLabel")
	tierName.Name = "TierName"
	tierName.Size = UDim2.new(1, -10, 0, 22)
	tierName.Position = UDim2.new(0, 5, 0, 30)
	tierName.BackgroundTransparency = 1
	tierName.Text = "Tân Thủ Sát Nhân"
	tierName.TextColor3 = Color3.fromRGB(200, 200, 200)
	tierName.Font = Enum.Font.GothamBold
	tierName.TextSize = 16
	tierName.TextXAlignment = Enum.TextXAlignment.Left
	tierName.Parent = tracker

	-- Kill Count
	local killCount = Instance.new("TextLabel")
	killCount.Name = "KillCount"
	killCount.Size = UDim2.new(1, -10, 0, 20)
	killCount.Position = UDim2.new(0, 5, 0, 52)
	killCount.BackgroundTransparency = 1
	killCount.Text = "Kills: 0"
	killCount.TextColor3 = Color3.fromRGB(255, 200, 100)
	killCount.Font = Enum.Font.Gotham
	killCount.TextSize = 14
	killCount.TextXAlignment = Enum.TextXAlignment.Left
	killCount.Parent = tracker

	-- Bonus Display
	local bonus = Instance.new("TextLabel")
	bonus.Name = "Bonus"
	bonus.Size = UDim2.new(1, -10, 0, 20)
	bonus.Position = UDim2.new(0, 5, 0, 72)
	bonus.BackgroundTransparency = 1
	bonus.Text = "Soul Dmg Bonus: +0%"
	bonus.TextColor3 = Color3.fromRGB(150, 255, 150)
	bonus.Font = Enum.Font.GothamBold
	bonus.TextSize = 13
	bonus.TextXAlignment = Enum.TextXAlignment.Left
	bonus.Parent = tracker

	-- Progress Bar
	local progressBG = Instance.new("Frame")
	progressBG.Size = UDim2.new(1, -10, 0, 8)
	progressBG.Position = UDim2.new(0, 5, 0, 100)
	progressBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	progressBG.BorderSizePixel = 0
	progressBG.Parent = tracker

	local progressFill = Instance.new("Frame")
	progressFill.Name = "ProgressFill"
	progressFill.Size = UDim2.new(0, 0, 1, 0)
	progressFill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressBG

	-- Linh Hồn Gain Notification Area
	local notifArea = Instance.new("Frame")
	notifArea.Name = "LinhHonNotifArea"
	notifArea.Size = UDim2.new(0, 250, 0, 150)
	notifArea.Position = UDim2.new(0, 10, 0, 140)
	notifArea.BackgroundTransparency = 1
	notifArea.Parent = screenGui

	return screenGui
end

-- ========================================
-- UPDATE TRACKER
-- ========================================

function TanSatUI.UpdateTracker(satKhiData)
	TanSatUI.CurrentData = satKhiData

	local screenGui = playerGui:FindFirstChild("TanSatUI")
	if not screenGui then return end

	local tracker = screenGui:FindFirstChild("SatKhiTracker")
	if not tracker then return end

	-- Update tier name
	local tierName = tracker:FindFirstChild("TierName")
	if tierName and satKhiData.CurrentTier then
		tierName.Text = satKhiData.CurrentTier.Name
		tierName.TextColor3 = satKhiData.CurrentTier.Color
	end

	-- Update kill count
	local killCount = tracker:FindFirstChild("KillCount")
	if killCount then
		killCount.Text = "Kills: " .. (satKhiData.TotalKills or 0)
	end

	-- Update bonus
	local bonus = tracker:FindFirstChild("Bonus")
	if bonus then
		local bonusPercent = math.floor((satKhiData.Bonus or 0) * 100)
		bonus.Text = "Soul Dmg Bonus: +" .. bonusPercent .. "%"
	end

	-- Update progress bar
	local progressFill = tracker:FindFirstChild("Frame")
		and tracker.Frame:FindFirstChild("ProgressFill")

	if progressFill and satKhiData.Progress then
		if satKhiData.Progress.MaxTier then
			progressFill.Size = UDim2.new(1, 0, 1, 0)
		else
			progressFill.Size = UDim2.new(satKhiData.Progress.Percent, 0, 1, 0)
		end
	end

	-- Check for penalties
	if satKhiData.CurrentTier and satKhiData.CurrentTier.Penalty then
		TanSatUI.ShowPenaltyWarning(satKhiData.CurrentTier.Penalty)
	end
end

-- ========================================
-- SHOW PENALTY WARNING
-- ========================================

function TanSatUI.ShowPenaltyWarning(penalty)
	local screenGui = playerGui:FindFirstChild("TanSatUI")
	if not screenGui then return end

	local tracker = screenGui:FindFirstChild("SatKhiTracker")
	if not tracker then return end

	-- Check if warning already exists
	if tracker:FindFirstChild("PenaltyWarning") then
		return
	end

	-- Create warning icon
	local warning = Instance.new("TextLabel")
	warning.Name = "PenaltyWarning"
	warning.Size = UDim2.new(0, 30, 0, 30)
	warning.Position = UDim2.new(1, -40, 0, 5)
	warning.BackgroundTransparency = 1
	warning.Text = "⚠️"
	warning.TextColor3 = Color3.fromRGB(255, 0, 0)
	warning.Font = Enum.Font.GothamBold
	warning.TextSize = 24
	warning.ZIndex = 2
	warning.Parent = tracker

	-- Pulse animation
	task.spawn(function()
		while warning and warning.Parent do
			for i = 0, 1, 0.1 do
				if warning and warning.Parent then
					warning.TextTransparency = i * 0.5
					task.wait(0.05)
				end
			end
			for i = 1, 0, -0.1 do
				if warning and warning.Parent then
					warning.TextTransparency = i * 0.5
					task.wait(0.05)
				end
			end
		end
	end)
end

-- ========================================
-- SHOW LINH HỒN GAIN
-- ========================================

function TanSatUI.ShowLinhHonGain(message, color)
	local screenGui = playerGui:FindFirstChild("TanSatUI")
	if not screenGui then return end

	local notifArea = screenGui:FindFirstChild("LinhHonNotifArea")
	if not notifArea then return end

	-- Create notification
	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(1, 0, 0, 30)
	notif.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	notif.BackgroundTransparency = 0.3
	notif.BorderSizePixel = 0
	notif.Parent = notifArea

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = notif

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 1, 0)
	label.Position = UDim2.new(0, 5, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = message
	label.TextColor3 = color
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextStrokeTransparency = 0
	label.Parent = notif

	-- Slide up animation
	local startY = notif.Position.Y.Offset

	-- Shift existing notifications up
	for _, child in ipairs(notifArea:GetChildren()) do
		if child ~= notif and child:IsA("Frame") then
			child:TweenPosition(
				UDim2.new(0, 0, 0, child.Position.Y.Offset - 35),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.3,
				true
			)
		end
	end

	-- Position at bottom
	notif.Position = UDim2.new(0, 0, 0, 0)

	-- Fade out and destroy
	task.delay(3, function()
		for i = 0, 1, 0.1 do
			notif.BackgroundTransparency = 0.3 + (i * 0.7)
			label.TextTransparency = i
			task.wait(0.05)
		end
		notif:Destroy()
	end)
end

-- ========================================
-- SHOW NOTIFICATION
-- ========================================

function TanSatUI.ShowNotification(message)
	local screenGui = playerGui:FindFirstChild("TanSatUI")
	if not screenGui then return end

	-- Create notification
	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 400, 0, 80)
	notif.Position = UDim2.new(0.5, -200, 0.3, 0)
	notif.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	notif.BorderSizePixel = 2
	notif.BorderColor3 = Color3.fromRGB(255, 100, 100)
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
	label.TextSize = 18
	label.TextWrapped = true
	label.Parent = notif

	-- Slide in
	notif.Position = UDim2.new(0.5, -200, -0.1, 0)
	notif:TweenPosition(
		UDim2.new(0.5, -200, 0.3, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Back,
		0.5,
		true
	)

	-- Fade out
	task.delay(5, function()
		for i = 0, 1, 0.1 do
			notif.BackgroundTransparency = i
			label.TextTransparency = i
			task.wait(0.05)
		end
		notif:Destroy()
	end)
end

-- ========================================
-- REQUEST UPDATE
-- ========================================

function TanSatUI.RequestUpdate()
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("GetSatKhi")

	if remoteEvent then
		remoteEvent:FireServer()
	end
end

-- ========================================
-- SETUP REMOTE EVENTS
-- ========================================

function TanSatUI.SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	if not remoteEvents then
		warn("RemoteEvents folder not found!")
		return
	end

	-- Sync Sát Khí
	local syncSatKhi = remoteEvents:WaitForChild("SyncSatKhi", 10)
	if syncSatKhi then
		syncSatKhi.OnClientEvent:Connect(function(satKhiData)
			TanSatUI.UpdateTracker(satKhiData)
		end)
	end

	-- Show Linh Hồn Gain
	local showLinhHon = remoteEvents:WaitForChild("ShowLinhHonGain", 10)
	if showLinhHon then
		showLinhHon.OnClientEvent:Connect(function(message, color)
			TanSatUI.ShowLinhHonGain(message, color)
		end)
	end

	-- Tàn Sát Notification
	local tanSatNotif = remoteEvents:WaitForChild("TanSatNotification", 10)
	if tanSatNotif then
		tanSatNotif.OnClientEvent:Connect(function(message)
			TanSatUI.ShowNotification(message)
		end)
	end
end

-- ========================================
-- INITIALIZE
-- ========================================

function TanSatUI.Initialize()
	print("🔥 TanSatUI initializing...")

	-- Create UI
	TanSatUI.CreateUI()

	-- Setup remote events
	TanSatUI.SetupRemoteEvents()

	-- Request initial data
	task.wait(3)
	TanSatUI.RequestUpdate()

	print("✅ TanSatUI ready!")
end

-- Auto-initialize
TanSatUI.Initialize()

return TanSatUI
