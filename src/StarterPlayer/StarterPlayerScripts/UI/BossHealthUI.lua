-- BossHealthUI.lua - Boss Health Bar Display (Client)
-- Shows boss health bar at top of screen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local BossHealthUI = {}
BossHealthUI.ActiveBossUI = nil

-- ========================================
-- CREATE BOSS HEALTH BAR
-- ========================================

function BossHealthUI.CreateBossHealthBar()
	-- Main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BossHealthUI"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 100
	screenGui.Parent = playerGui

	-- Container Frame (hidden by default)
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.new(0, 600, 0, 100)
	container.Position = UDim2.new(0.5, -300, 0, -120) -- Start off-screen
	container.BackgroundTransparency = 1
	container.Parent = screenGui

	-- Background with gradient
	local background = Instance.new("Frame")
	background.Name = "Background"
	background.Size = UDim2.new(1, 0, 1, 0)
	background.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	background.BorderSizePixel = 0
	background.Parent = container

	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0, 12)
	bgCorner.Parent = background

	local bgGradient = Instance.new("UIGradient")
	bgGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 20, 50)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 10, 30))
	})
	bgGradient.Rotation = 45
	bgGradient.Parent = background

	-- Border glow
	local border = Instance.new("UIStroke")
	border.Color = Color3.fromRGB(200, 100, 255)
	border.Thickness = 2
	border.Transparency = 0.3
	border.Parent = background

	-- Boss Icon/Crown
	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 60, 0, 60)
	icon.Position = UDim2.new(0, 10, 0.5, -30)
	icon.BackgroundTransparency = 1
	icon.Text = "👑"
	icon.TextSize = 40
	icon.Font = Enum.Font.SourceSansBold
	icon.Parent = background

	-- Boss Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "BossName"
	nameLabel.Size = UDim2.new(1, -160, 0, 30)
	nameLabel.Position = UDim2.new(0, 80, 0, 10)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = "Boss Name"
	nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	nameLabel.TextSize = 24
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.Parent = background

	-- Health Bar Background
	local healthBg = Instance.new("Frame")
	healthBg.Name = "HealthBarBg"
	healthBg.Size = UDim2.new(1, -160, 0, 30)
	healthBg.Position = UDim2.new(0, 80, 0, 50)
	healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	healthBg.BorderSizePixel = 0
	healthBg.Parent = background

	local healthBgCorner = Instance.new("UICorner")
	healthBgCorner.CornerRadius = UDim.new(0, 6)
	healthBgCorner.Parent = healthBg

	-- Health Bar (Fill)
	local healthBar = Instance.new("Frame")
	healthBar.Name = "HealthBar"
	healthBar.Size = UDim2.new(1, 0, 1, 0)
	healthBar.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
	healthBar.BorderSizePixel = 0
	healthBar.Parent = healthBg

	local healthBarCorner = Instance.new("UICorner")
	healthBarCorner.CornerRadius = UDim.new(0, 6)
	healthBarCorner.Parent = healthBar

	-- Health bar gradient
	local healthGradient = Instance.new("UIGradient")
	healthGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 100)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 30, 30))
	})
	healthGradient.Parent = healthBar

	-- Health Text (HP numbers)
	local healthText = Instance.new("TextLabel")
	healthText.Name = "HealthText"
	healthText.Size = UDim2.new(1, 0, 1, 0)
	healthText.BackgroundTransparency = 1
	healthText.Text = "100,000 / 100,000"
	healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
	healthText.TextSize = 18
	healthText.Font = Enum.Font.GothamBold
	healthText.TextStrokeTransparency = 0.3
	healthText.ZIndex = 2
	healthText.Parent = healthBg

	-- Phase indicator
	local phaseLabel = Instance.new("TextLabel")
	phaseLabel.Name = "PhaseLabel"
	phaseLabel.Size = UDim2.new(0, 80, 0, 25)
	phaseLabel.Position = UDim2.new(1, -90, 0, 12)
	phaseLabel.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
	phaseLabel.BorderSizePixel = 0
	phaseLabel.Text = "Phase 1"
	phaseLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	phaseLabel.TextSize = 14
	phaseLabel.Font = Enum.Font.GothamBold
	phaseLabel.Visible = false
	phaseLabel.Parent = background

	local phaseCorner = Instance.new("UICorner")
	phaseCorner.CornerRadius = UDim.new(0, 6)
	phaseCorner.Parent = phaseLabel

	return screenGui
end

-- ========================================
-- SHOW BOSS UI
-- ========================================

function BossHealthUI.ShowBoss(bossName, currentHP, maxHP, phase)
	-- Remove old UI if exists
	if BossHealthUI.ActiveBossUI then
		BossHealthUI.HideBoss()
	end

	-- Create new UI
	BossHealthUI.ActiveBossUI = BossHealthUI.CreateBossHealthBar()

	local container = BossHealthUI.ActiveBossUI:FindFirstChild("Container")
	if not container then return end

	local background = container:FindFirstChild("Background")
	if not background then return end

	-- Set boss name
	local nameLabel = background:FindFirstChild("BossName")
	if nameLabel then
		nameLabel.Text = "👑 " .. bossName .. " 👑"
	end

	-- Set health
	BossHealthUI.UpdateHealth(currentHP, maxHP)

	-- Set phase if provided
	if phase and phase > 0 then
		local phaseLabel = background:FindFirstChild("PhaseLabel")
		if phaseLabel then
			phaseLabel.Text = "Phase " .. phase
			phaseLabel.Visible = true
		end
	end

	-- Animate in
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tween = TweenService:Create(container, tweenInfo, {
		Position = UDim2.new(0.5, -300, 0, 20)
	})
	tween:Play()
end

-- ========================================
-- UPDATE HEALTH
-- ========================================

function BossHealthUI.UpdateHealth(currentHP, maxHP)
	if not BossHealthUI.ActiveBossUI then return end

	local container = BossHealthUI.ActiveBossUI:FindFirstChild("Container")
	if not container then return end

	local background = container:FindFirstChild("Background")
	if not background then return end

	local healthBg = background:FindFirstChild("HealthBarBg")
	if not healthBg then return end

	local healthBar = healthBg:FindFirstChild("HealthBar")
	local healthText = healthBg:FindFirstChild("HealthText")

	if healthBar then
		local percent = math.clamp(currentHP / maxHP, 0, 1)

		-- Animate health bar
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(healthBar, tweenInfo, {
			Size = UDim2.new(percent, 0, 1, 0)
		})
		tween:Play()

		-- Change color based on HP %
		if percent <= 0.25 then
			-- Critical HP - Red
			healthBar.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
		elseif percent <= 0.5 then
			-- Low HP - Orange
			healthBar.BackgroundColor3 = Color3.fromRGB(255, 140, 50)
		else
			-- Normal HP - Red
			healthBar.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
		end
	end

	if healthText then
		-- Format numbers with commas
		local function formatNumber(num)
			local formatted = tostring(math.floor(num))
			while true do
				formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
				if k == 0 then break end
			end
			return formatted
		end

		healthText.Text = formatNumber(currentHP) .. " / " .. formatNumber(maxHP)
	end
end

-- ========================================
-- UPDATE PHASE
-- ========================================

function BossHealthUI.UpdatePhase(phase)
	if not BossHealthUI.ActiveBossUI then return end

	local container = BossHealthUI.ActiveBossUI:FindFirstChild("Container")
	if not container then return end

	local background = container:FindFirstChild("Background")
	if not background then return end

	local phaseLabel = background:FindFirstChild("PhaseLabel")
	if phaseLabel then
		phaseLabel.Text = "Phase " .. phase
		phaseLabel.Visible = true

		-- Flash animation
		local originalColor = phaseLabel.BackgroundColor3
		phaseLabel.BackgroundColor3 = Color3.fromRGB(255, 200, 50)

		task.wait(0.2)
		phaseLabel.BackgroundColor3 = originalColor
	end
end

-- ========================================
-- HIDE BOSS UI
-- ========================================

function BossHealthUI.HideBoss()
	if not BossHealthUI.ActiveBossUI then return end

	local container = BossHealthUI.ActiveBossUI:FindFirstChild("Container")
	if container then
		-- Animate out
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		local tween = TweenService:Create(container, tweenInfo, {
			Position = UDim2.new(0.5, -300, 0, -120)
		})
		tween:Play()

		-- Destroy after animation
		task.wait(0.5)
	end

	BossHealthUI.ActiveBossUI:Destroy()
	BossHealthUI.ActiveBossUI = nil
end

-- ========================================
-- SETUP REMOTE EVENTS
-- ========================================

function BossHealthUI.SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	if not remoteEvents then
		warn("⚠️ RemoteEvents folder not found")
		return
	end

	-- Show Boss UI
	local showBoss = remoteEvents:WaitForChild("ShowBossUI", 5)
	if showBoss then
		showBoss.OnClientEvent:Connect(function(bossName, currentHP, maxHP, phase)
			BossHealthUI.ShowBoss(bossName, currentHP, maxHP, phase)
		end)
	end

	-- Update Boss HP
	local updateBossHP = remoteEvents:WaitForChild("UpdateBossHP", 5)
	if updateBossHP then
		updateBossHP.OnClientEvent:Connect(function(currentHP, maxHP)
			BossHealthUI.UpdateHealth(currentHP, maxHP)
		end)
	end

	-- Update Boss Phase
	local updatePhase = remoteEvents:WaitForChild("UpdateBossPhase", 5)
	if updatePhase then
		updatePhase.OnClientEvent:Connect(function(phase)
			BossHealthUI.UpdatePhase(phase)
		end)
	end

	-- Hide Boss UI
	local hideBoss = remoteEvents:WaitForChild("HideBossUI", 5)
	if hideBoss then
		hideBoss.OnClientEvent:Connect(function()
			BossHealthUI.HideBoss()
		end)
	end
end

-- ========================================
-- INITIALIZE
-- ========================================

print("🎨 BossHealthUI initializing...")
BossHealthUI.SetupRemoteEvents()
print("✅ BossHealthUI ready!")

return BossHealthUI
