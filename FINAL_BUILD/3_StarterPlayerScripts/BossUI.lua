-- BossUI.lua - Boss UI System
-- Copy vào StarterPlayer/StarterPlayerScripts/BossUI (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local BossUI = {}
BossUI.CurrentBoss = nil

-- ========================================
-- CREATE UI
-- ========================================

function BossUI.CreateUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BossUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- Boss Health Bar (Top center)
	local bossBar = Instance.new("Frame")
	bossBar.Name = "BossHealthBar"
	bossBar.Size = UDim2.new(0, 600, 0, 80)
	bossBar.Position = UDim2.new(0.5, -300, 0, 10)
	bossBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	bossBar.BackgroundTransparency = 0.3
	bossBar.BorderSizePixel = 0
	bossBar.Visible = false
	bossBar.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = bossBar

	-- Boss Name
	local bossName = Instance.new("TextLabel")
	bossName.Name = "BossName"
	bossName.Size = UDim2.new(1, -20, 0, 25)
	bossName.Position = UDim2.new(0, 10, 0, 5)
	bossName.BackgroundTransparency = 1
	bossName.Text = "👑 Boss Name 👑"
	bossName.TextColor3 = Color3.fromRGB(255, 200, 0)
	bossName.TextStrokeTransparency = 0
	bossName.Font = Enum.Font.GothamBold
	bossName.TextSize = 20
	bossName.Parent = bossBar

	-- Health Bar Background
	local healthBG = Instance.new("Frame")
	healthBG.Size = UDim2.new(0.95, 0, 0, 30)
	healthBG.Position = UDim2.new(0.025, 0, 0, 40)
	healthBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	healthBG.BorderSizePixel = 0
	healthBG.Parent = bossBar

	local healthCorner = Instance.new("UICorner")
	healthCorner.CornerRadius = UDim.new(0, 8)
	healthCorner.Parent = healthBG

	-- Health Bar Fill
	local healthFill = Instance.new("Frame")
	healthFill.Name = "HealthFill"
	healthFill.Size = UDim2.new(1, 0, 1, 0)
	healthFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	healthFill.BorderSizePixel = 0
	healthFill.Parent = healthBG

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 8)
	fillCorner.Parent = healthFill

	-- Health Text
	local healthText = Instance.new("TextLabel")
	healthText.Name = "HealthText"
	healthText.Size = UDim2.new(1, 0, 1, 0)
	healthText.BackgroundTransparency = 1
	healthText.Text = "100,000 / 100,000"
	healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
	healthText.TextStrokeTransparency = 0
	healthText.Font = Enum.Font.GothamBold
	healthText.TextSize = 16
	healthText.ZIndex = 2
	healthText.Parent = healthBG

	-- Notification Area
	local notifArea = Instance.new("Frame")
	notifArea.Name = "NotificationArea"
	notifArea.Size = UDim2.new(0, 400, 0, 100)
	notifArea.Position = UDim2.new(0.5, -200, 0.3, 0)
	notifArea.BackgroundTransparency = 1
	notifArea.Parent = screenGui

	return screenGui
end

-- ========================================
-- SHOW BOSS HEALTH BAR
-- ========================================

function BossUI.ShowBossBar(bossModel)
	BossUI.CurrentBoss = bossModel

	local screenGui = playerGui:FindFirstChild("BossUI")
	if not screenGui then return end

	local bossBar = screenGui:FindFirstChild("BossHealthBar")
	if not bossBar then return end

	-- Show bar
	bossBar.Visible = true

	-- Set boss name
	local bossName = bossBar:FindFirstChild("BossName")
	if bossName then
		bossName.Text = "👑 " .. bossModel.Name .. " 👑"
	end

	-- Start updating health
	BossUI.UpdateBossHealth()
end

-- ========================================
-- HIDE BOSS HEALTH BAR
-- ========================================

function BossUI.HideBossBar()
	BossUI.CurrentBoss = nil

	local screenGui = playerGui:FindFirstChild("BossUI")
	if not screenGui then return end

	local bossBar = screenGui:FindFirstChild("BossHealthBar")
	if bossBar then
		bossBar.Visible = false
	end
end

-- ========================================
-- UPDATE BOSS HEALTH
-- ========================================

function BossUI.UpdateBossHealth()
	task.spawn(function()
		while BossUI.CurrentBoss and BossUI.CurrentBoss.Parent do
			task.wait(0.1)

			local currentHP = BossUI.CurrentBoss:GetAttribute("CurrentHP")
			local maxHP = BossUI.CurrentBoss:GetAttribute("MaxHP")

			if not currentHP or not maxHP then
				BossUI.HideBossBar()
				break
			end

			local screenGui = playerGui:FindFirstChild("BossUI")
			if not screenGui then break end

			local bossBar = screenGui:FindFirstChild("BossHealthBar")
			if not bossBar then break end

			-- Update health fill
			local healthFill = bossBar:FindFirstChild("Frame")
				and bossBar.Frame:FindFirstChild("HealthFill")

			if healthFill then
				local percent = currentHP / maxHP
				healthFill.Size = UDim2.new(percent, 0, 1, 0)

				-- Color based on HP
				if percent > 0.5 then
					healthFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
				elseif percent > 0.25 then
					healthFill.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
				else
					healthFill.BackgroundColor3 = Color3.fromRGB(200, 0, 200)
				end
			end

			-- Update health text
			local healthText = bossBar:FindFirstChild("Frame")
				and bossBar.Frame:FindFirstChild("HealthText")

			if healthText then
				healthText.Text = math.floor(currentHP) .. " / " .. maxHP
			end
		end

		-- Boss defeated or removed
		BossUI.HideBossBar()
	end)
end

-- ========================================
-- SHOW NOTIFICATION
-- ========================================

function BossUI.ShowNotification(message)
	local screenGui = playerGui:FindFirstChild("BossUI")
	if not screenGui then return end

	local notifArea = screenGui:FindFirstChild("NotificationArea")
	if not notifArea then return end

	-- Create notification
	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(1, 0, 0, 80)
	notif.Position = UDim2.new(0, 0, 0, 0)
	notif.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	notif.BackgroundTransparency = 0.2
	notif.BorderSizePixel = 2
	notif.BorderColor3 = Color3.fromRGB(255, 200, 0)
	notif.ZIndex = 100
	notif.Parent = notifArea

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = notif

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, -20)
	label.Position = UDim2.new(0, 10, 0, 10)
	label.BackgroundTransparency = 1
	label.Text = message
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextSize = 24
	label.TextWrapped = true
	label.Parent = notif

	-- Animate in
	notif.Position = UDim2.new(0, 0, -0.1, 0)
	notif:TweenPosition(
		UDim2.new(0, 0, 0, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Back,
		0.5,
		true
	)

	-- Fade out after delay
	task.delay(5, function()
		for i = 0, 1, 0.1 do
			notif.BackgroundTransparency = 0.2 + (i * 0.8)
			label.TextTransparency = i
			task.wait(0.05)
		end
		notif:Destroy()
	end)
end

-- ========================================
-- DETECT NEARBY BOSS
-- ========================================

function BossUI.DetectNearbyBoss()
	task.spawn(function()
		while task.wait(1) do
			local character = player.Character
			if not character or not character:FindFirstChild("HumanoidRootPart") then
				continue
			end

			local playerPos = character.HumanoidRootPart.Position
			local nearestBoss = nil
			local nearestDistance = math.huge

			-- Find nearest boss
			for _, model in ipairs(workspace:GetChildren()) do
				if model:IsA("Model") and model:GetAttribute("BossID") then
					local bossRoot = model:FindFirstChild("HumanoidRootPart")
					if bossRoot then
						local distance = (bossRoot.Position - playerPos).Magnitude

						if distance < 150 and distance < nearestDistance then
							nearestDistance = distance
							nearestBoss = model
						end
					end
				end
			end

			-- Update UI
			if nearestBoss and nearestBoss ~= BossUI.CurrentBoss then
				BossUI.ShowBossBar(nearestBoss)
			elseif not nearestBoss and BossUI.CurrentBoss then
				BossUI.HideBossBar()
			end
		end
	end)
end

-- ========================================
-- SETUP REMOTE EVENTS
-- ========================================

function BossUI.SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	if not remoteEvents then
		warn("RemoteEvents folder not found!")
		return
	end

	-- Boss Notification
	local bossNotif = remoteEvents:WaitForChild("BossNotification", 10)
	if bossNotif then
		bossNotif.OnClientEvent:Connect(function(message)
			BossUI.ShowNotification(message)
		end)
	end
end

-- ========================================
-- INITIALIZE
-- ========================================

function BossUI.Initialize()
	print("👑 BossUI initializing...")

	-- Create UI
	BossUI.CreateUI()

	-- Setup remote events
	BossUI.SetupRemoteEvents()

	-- Start detecting bosses
	BossUI.DetectNearbyBoss()

	print("✅ BossUI ready!")
end

-- Auto-initialize
BossUI.Initialize()

return BossUI
