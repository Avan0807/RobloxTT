-- QuestUI.lua - Quest UI System
-- Copy vào StarterPlayer/StarterPlayerScripts/QuestUI (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local QuestModule = require(ReplicatedStorage.Modules.Quest.QuestModule)

local QuestUI = {}
QuestUI.IsOpen = false
QuestUI.ActiveQuests = {}
QuestUI.CompletedQuests = {}

-- ========================================
-- CREATE UI
-- ========================================

function QuestUI.CreateUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "QuestUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- Quest Tracker (Always visible)
	QuestUI.CreateQuestTracker(screenGui)

	-- Quest Log (Toggle with Q key)
	QuestUI.CreateQuestLog(screenGui)

	return screenGui
end

-- ========================================
-- CREATE QUEST TRACKER
-- ========================================

function QuestUI.CreateQuestTracker(parent)
	local tracker = Instance.new("Frame")
	tracker.Name = "QuestTracker"
	tracker.Size = UDim2.new(0, 300, 0, 400)
	tracker.Position = UDim2.new(1, -310, 0, 10)
	tracker.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	tracker.BackgroundTransparency = 0.3
	tracker.BorderSizePixel = 0
	tracker.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = tracker

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -10, 0, 30)
	title.Position = UDim2.new(0, 5, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = "📋 Active Quests"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = tracker

	-- Quest List
	local questList = Instance.new("ScrollingFrame")
	questList.Name = "QuestList"
	questList.Size = UDim2.new(1, -10, 1, -45)
	questList.Position = UDim2.new(0, 5, 0, 40)
	questList.BackgroundTransparency = 1
	questList.BorderSizePixel = 0
	questList.ScrollBarThickness = 6
	questList.Parent = tracker

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 5)
	listLayout.Parent = questList

	return tracker
end

-- ========================================
-- CREATE QUEST LOG
-- ========================================

function QuestUI.CreateQuestLog(parent)
	local logFrame = Instance.new("Frame")
	logFrame.Name = "QuestLog"
	logFrame.Size = UDim2.new(0, 700, 0, 500)
	logFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
	logFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	logFrame.BorderSizePixel = 2
	logFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
	logFrame.Visible = false
	logFrame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = logFrame

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	title.Text = "📋 Quest Log"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 24
	title.Parent = logFrame

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 10)
	titleCorner.Parent = title

	-- Tabs
	QuestUI.CreateTabs(logFrame)

	-- Available Quests
	local availableScroll = Instance.new("ScrollingFrame")
	availableScroll.Name = "AvailableQuests"
	availableScroll.Size = UDim2.new(1, -20, 1, -120)
	availableScroll.Position = UDim2.new(0, 10, 0, 100)
	availableScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	availableScroll.BorderSizePixel = 0
	availableScroll.ScrollBarThickness = 8
	availableScroll.Parent = logFrame

	local availableLayout = Instance.new("UIListLayout")
	availableLayout.Padding = UDim.new(0, 5)
	availableLayout.Parent = availableScroll

	-- Active Quests
	local activeScroll = Instance.new("ScrollingFrame")
	activeScroll.Name = "ActiveQuests"
	activeScroll.Size = UDim2.new(1, -20, 1, -120)
	activeScroll.Position = UDim2.new(0, 10, 0, 100)
	activeScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	activeScroll.BorderSizePixel = 0
	activeScroll.ScrollBarThickness = 8
	activeScroll.Visible = false
	activeScroll.Parent = logFrame

	local activeLayout = Instance.new("UIListLayout")
	activeLayout.Padding = UDim.new(0, 5)
	activeLayout.Parent = activeScroll

	-- Close Button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 100, 0, 30)
	closeBtn.Position = UDim2.new(1, -110, 1, -40)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeBtn.Text = "Close"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 16
	closeBtn.Parent = logFrame

	closeBtn.MouseButton1Click:Connect(function()
		QuestUI.Close()
	end)

	return logFrame
end

-- ========================================
-- CREATE TABS
-- ========================================

function QuestUI.CreateTabs(parent)
	local tabs = {"Available", "Active"}

	for i, tabName in ipairs(tabs) do
		local tab = Instance.new("TextButton")
		tab.Name = tabName .. "Tab"
		tab.Size = UDim2.new(0, 200, 0, 35)
		tab.Position = UDim2.new(0, 10 + (i-1) * 210, 0, 55)
		tab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		tab.Text = tabName .. " Quests"
		tab.TextColor3 = Color3.fromRGB(255, 255, 255)
		tab.Font = Enum.Font.GothamBold
		tab.TextSize = 16
		tab.Parent = parent

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = tab

		tab.MouseButton1Click:Connect(function()
			QuestUI.SelectTab(tabName)
		end)
	end
end

-- ========================================
-- SELECT TAB
-- ========================================

function QuestUI.SelectTab(tabName)
	local screenGui = playerGui:FindFirstChild("QuestUI")
	if not screenGui then return end

	local logFrame = screenGui:FindFirstChild("QuestLog")
	if not logFrame then return end

	-- Update tab colors
	for _, child in ipairs(logFrame:GetChildren()) do
		if child:IsA("TextButton") and child.Name:match("Tab$") then
			if child.Name == tabName .. "Tab" then
				child.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
			else
				child.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			end
		end
	end

	-- Show/hide quest lists
	local availableScroll = logFrame:FindFirstChild("AvailableQuests")
	local activeScroll = logFrame:FindFirstChild("ActiveQuests")

	if tabName == "Available" then
		if availableScroll then availableScroll.Visible = true end
		if activeScroll then activeScroll.Visible = false end
		QuestUI.RefreshAvailableQuests()
	else
		if availableScroll then availableScroll.Visible = false end
		if activeScroll then activeScroll.Visible = true end
		QuestUI.RefreshActiveQuests()
	end
end

-- ========================================
-- CREATE QUEST CARD
-- ========================================

function QuestUI.CreateQuestCard(questData, isAvailable)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -10, 0, 120)
	card.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	card.BorderSizePixel = 2
	card.BorderColor3 = questData.Difficulty and questData.Difficulty.Color or Color3.fromRGB(100, 100, 100)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = card

	-- Quest Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.7, 0, 0, 25)
	nameLabel.Position = UDim2.new(0, 10, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = questData.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 16
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = card

	-- Difficulty
	local diffLabel = Instance.new("TextLabel")
	diffLabel.Size = UDim2.new(0.3, -10, 0, 25)
	diffLabel.Position = UDim2.new(0.7, 0, 0, 5)
	diffLabel.BackgroundTransparency = 1
	diffLabel.Text = questData.Difficulty and questData.Difficulty.Name or "Normal"
	diffLabel.TextColor3 = questData.Difficulty and questData.Difficulty.Color or Color3.fromRGB(200, 200, 200)
	diffLabel.Font = Enum.Font.GothamBold
	diffLabel.TextSize = 14
	diffLabel.TextXAlignment = Enum.TextXAlignment.Right
	diffLabel.Parent = card

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -20, 0, 30)
	descLabel.Position = UDim2.new(0, 10, 0, 30)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = questData.Description
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 13
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextWrapped = true
	descLabel.Parent = card

	-- Progress
	if questData.Progress then
		local progressLabel = Instance.new("TextLabel")
		progressLabel.Size = UDim2.new(1, -20, 0, 20)
		progressLabel.Position = UDim2.new(0, 10, 0, 65)
		progressLabel.BackgroundTransparency = 1
		progressLabel.Text = "Progress: " .. questData.Progress.Current .. " / " .. questData.Progress.Goal
		progressLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		progressLabel.Font = Enum.Font.GothamBold
		progressLabel.TextSize = 12
		progressLabel.TextXAlignment = Enum.TextXAlignment.Left
		progressLabel.Parent = card

		-- Progress Bar
		local progressBar = Instance.new("Frame")
		progressBar.Size = UDim2.new(0.6, 0, 0, 8)
		progressBar.Position = UDim2.new(0, 10, 0, 90)
		progressBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		progressBar.BorderSizePixel = 0
		progressBar.Parent = card

		local progressFill = Instance.new("Frame")
		local percent = questData.Progress.Current / questData.Progress.Goal
		progressFill.Size = UDim2.new(percent, 0, 1, 0)
		progressFill.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
		progressFill.BorderSizePixel = 0
		progressFill.Parent = progressBar
	end

	-- Rewards
	local rewardsText = QuestModule.GetRewardsText(questData)
	local rewardsLabel = Instance.new("TextLabel")
	rewardsLabel.Size = UDim2.new(1, -20, 0, 20)
	rewardsLabel.Position = UDim2.new(0, 10, 1, -25)
	rewardsLabel.BackgroundTransparency = 1
	rewardsLabel.Text = "🎁 " .. rewardsText
	rewardsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	rewardsLabel.Font = Enum.Font.Gotham
	rewardsLabel.TextSize = 11
	rewardsLabel.TextXAlignment = Enum.TextXAlignment.Left
	rewardsLabel.Parent = card

	-- Buttons
	if isAvailable then
		local acceptBtn = Instance.new("TextButton")
		acceptBtn.Size = UDim2.new(0, 80, 0, 30)
		acceptBtn.Position = UDim2.new(1, -90, 0, 5)
		acceptBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		acceptBtn.Text = "Accept"
		acceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		acceptBtn.Font = Enum.Font.GothamBold
		acceptBtn.TextSize = 14
		acceptBtn.Parent = card

		acceptBtn.MouseButton1Click:Connect(function()
			QuestUI.AcceptQuest(questData.QuestID)
		end)
	else
		local abandonBtn = Instance.new("TextButton")
		abandonBtn.Size = UDim2.new(0, 80, 0, 30)
		abandonBtn.Position = UDim2.new(1, -90, 0, 5)
		abandonBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		abandonBtn.Text = "Abandon"
		abandonBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		abandonBtn.Font = Enum.Font.GothamBold
		abandonBtn.TextSize = 14
		abandonBtn.Parent = card

		abandonBtn.MouseButton1Click:Connect(function()
			QuestUI.AbandonQuest(questData.QuestID)
		end)
	end

	return card
end

-- ========================================
-- REFRESH QUEST TRACKER
-- ========================================

function QuestUI.RefreshTracker()
	local screenGui = playerGui:FindFirstChild("QuestUI")
	if not screenGui then return end

	local tracker = screenGui:FindFirstChild("QuestTracker")
	if not tracker then return end

	local questList = tracker:FindFirstChild("QuestList")
	if not questList then return end

	-- Clear existing
	for _, child in ipairs(questList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Add active quests (max 5 in tracker)
	local count = 0
	for _, questData in ipairs(QuestUI.ActiveQuests) do
		if count >= 5 then break end

		local miniCard = Instance.new("Frame")
		miniCard.Size = UDim2.new(1, 0, 0, 60)
		miniCard.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		miniCard.BackgroundTransparency = 0.3
		miniCard.BorderSizePixel = 0
		miniCard.Parent = questList

		local questName = Instance.new("TextLabel")
		questName.Size = UDim2.new(1, -5, 0, 20)
		questName.Position = UDim2.new(0, 5, 0, 5)
		questName.BackgroundTransparency = 1
		questName.Text = questData.Name
		questName.TextColor3 = Color3.fromRGB(255, 255, 255)
		questName.Font = Enum.Font.GothamBold
		questName.TextSize = 12
		questName.TextXAlignment = Enum.TextXAlignment.Left
		questName.TextTruncate = Enum.TextTruncate.AtEnd
		questName.Parent = miniCard

		local progress = Instance.new("TextLabel")
		progress.Size = UDim2.new(1, -5, 0, 18)
		progress.Position = UDim2.new(0, 5, 0, 25)
		progress.BackgroundTransparency = 1
		progress.Text = questData.Progress.Current .. " / " .. questData.Progress.Goal
		progress.TextColor3 = Color3.fromRGB(100, 255, 100)
		progress.Font = Enum.Font.Gotham
		progress.TextSize = 11
		progress.TextXAlignment = Enum.TextXAlignment.Left
		progress.Parent = miniCard

		-- Progress bar
		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1, -10, 0, 6)
		bar.Position = UDim2.new(0, 5, 0, 48)
		bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		bar.BorderSizePixel = 0
		bar.Parent = miniCard

		local fill = Instance.new("Frame")
		local percent = questData.Progress.Current / questData.Progress.Goal
		fill.Size = UDim2.new(percent, 0, 1, 0)
		fill.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
		fill.BorderSizePixel = 0
		fill.Parent = bar

		count = count + 1
	end

	questList.CanvasSize = UDim2.new(0, 0, 0, questList.UIListLayout.AbsoluteContentSize.Y)
end

-- ========================================
-- REFRESH AVAILABLE QUESTS
-- ========================================

function QuestUI.RefreshAvailableQuests()
	local screenGui = playerGui:FindFirstChild("QuestUI")
	if not screenGui then return end

	local scroll = screenGui:FindFirstChild("QuestLog")
		and screenGui.QuestLog:FindFirstChild("AvailableQuests")

	if not scroll then return end

	-- Clear
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Add all available quests
	local allQuests = QuestModule.Quests
	for _, questData in ipairs(allQuests) do
		local card = QuestUI.CreateQuestCard(questData, true)
		card.Parent = scroll
	end

	scroll.CanvasSize = UDim2.new(0, 0, 0, scroll.UIListLayout.AbsoluteContentSize.Y + 10)
end

-- ========================================
-- REFRESH ACTIVE QUESTS
-- ========================================

function QuestUI.RefreshActiveQuests()
	local screenGui = playerGui:FindFirstChild("QuestUI")
	if not screenGui then return end

	local scroll = screenGui:FindFirstChild("QuestLog")
		and screenGui.QuestLog:FindFirstChild("ActiveQuests")

	if not scroll then return end

	-- Clear
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Add active quests
	for _, questData in ipairs(QuestUI.ActiveQuests) do
		local card = QuestUI.CreateQuestCard(questData, false)
		card.Parent = scroll
	end

	scroll.CanvasSize = UDim2.new(0, 0, 0, scroll.UIListLayout.AbsoluteContentSize.Y + 10)
end

-- ========================================
-- ACCEPT QUEST
-- ========================================

function QuestUI.AcceptQuest(questID)
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("AcceptQuest")

	if remoteEvent then
		remoteEvent:FireServer(questID)
	end
end

-- ========================================
-- ABANDON QUEST
-- ========================================

function QuestUI.AbandonQuest(questID)
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("AbandonQuest")

	if remoteEvent then
		remoteEvent:FireServer(questID)
	end
end

-- ========================================
-- UPDATE QUESTS
-- ========================================

function QuestUI.UpdateQuests(questData)
	QuestUI.ActiveQuests = questData.Active or {}
	QuestUI.CompletedQuests = questData.Completed or {}

	QuestUI.RefreshTracker()

	-- If quest log is open, refresh it too
	if QuestUI.IsOpen then
		QuestUI.RefreshActiveQuests()
	end
end

-- ========================================
-- OPEN/CLOSE
-- ========================================

function QuestUI.Open()
	QuestUI.IsOpen = true

	local screenGui = playerGui:FindFirstChild("QuestUI")
	if screenGui then
		local logFrame = screenGui:FindFirstChild("QuestLog")
		if logFrame then
			logFrame.Visible = true
			QuestUI.SelectTab("Available")
			QuestUI.RequestQuests()
		end
	end
end

function QuestUI.Close()
	QuestUI.IsOpen = false

	local screenGui = playerGui:FindFirstChild("QuestUI")
	if screenGui then
		local logFrame = screenGui:FindFirstChild("QuestLog")
		if logFrame then
			logFrame.Visible = false
		end
	end
end

function QuestUI.Toggle()
	if QuestUI.IsOpen then
		QuestUI.Close()
	else
		QuestUI.Open()
	end
end

-- ========================================
-- REQUEST QUESTS
-- ========================================

function QuestUI.RequestQuests()
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("GetQuests")

	if remoteEvent then
		remoteEvent:FireServer()
	end
end

-- ========================================
-- SHOW NOTIFICATION
-- ========================================

function QuestUI.ShowNotification(message)
	local screenGui = playerGui:FindFirstChild("QuestUI")
	if not screenGui then return end

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 350, 0, 60)
	notif.Position = UDim2.new(0.5, -175, 0.85, 0)
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

	task.delay(4, function()
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

function QuestUI.SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	if not remoteEvents then
		warn("RemoteEvents folder not found!")
		return
	end

	-- Sync Quests
	local syncQuests = remoteEvents:WaitForChild("SyncQuests", 10)
	if syncQuests then
		syncQuests.OnClientEvent:Connect(function(questData)
			QuestUI.UpdateQuests(questData)
		end)
	end

	-- Quest Notification
	local questNotif = remoteEvents:WaitForChild("QuestNotification", 10)
	if questNotif then
		questNotif.OnClientEvent:Connect(function(message)
			QuestUI.ShowNotification(message)
		end)
	end
end

-- ========================================
-- INPUT HANDLING
-- ========================================

function QuestUI.SetupInput()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.KeyCode == Enum.KeyCode.Q then
			QuestUI.Toggle()
		elseif input.KeyCode == Enum.KeyCode.Escape and QuestUI.IsOpen then
			QuestUI.Close()
		end
	end)
end

-- ========================================
-- INITIALIZE
-- ========================================

function QuestUI.Initialize()
	print("📋 QuestUI initializing...")

	-- Create UI
	QuestUI.CreateUI()

	-- Setup remote events
	QuestUI.SetupRemoteEvents()

	-- Setup input
	QuestUI.SetupInput()

	-- Request initial quests
	task.wait(2)
	QuestUI.RequestQuests()

	print("✅ QuestUI ready! Press 'Q' to open quest log")
end

-- Auto-initialize
QuestUI.Initialize()

return QuestUI
