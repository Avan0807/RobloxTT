-- SpawnProtectionUI.lua - Client UI for Spawn Protection
-- Shows protection timer and notifications

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local SpawnProtectionUI = {}

-- ========================================
-- CREATE NOTIFICATION
-- ========================================

function SpawnProtectionUI.CreateNotification()
	-- Main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SpawnProtectionUI"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 50
	screenGui.Parent = playerGui

	-- Notification Frame (center of screen)
	local notification = Instance.new("Frame")
	notification.Name = "Notification"
	notification.Size = UDim2.new(0, 400, 0, 80)
	notification.Position = UDim2.new(0.5, -200, 0.15, 0)
	notification.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	notification.BorderSizePixel = 0
	notification.Visible = false
	notification.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = notification

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(100, 200, 255)
	stroke.Thickness = 2
	stroke.Transparency = 0.5
	stroke.Parent = notification

	-- Shield Icon
	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 60, 0, 60)
	icon.Position = UDim2.new(0, 10, 0.5, -30)
	icon.BackgroundTransparency = 1
	icon.Text = "🛡️"
	icon.TextSize = 40
	icon.Font = Enum.Font.SourceSansBold
	icon.Parent = notification

	-- Message Text
	local message = Instance.new("TextLabel")
	message.Name = "Message"
	message.Size = UDim2.new(1, -80, 0, 40)
	message.Position = UDim2.new(0, 75, 0, 10)
	message.BackgroundTransparency = 1
	message.Text = "SPAWN PROTECTION"
	message.TextColor3 = Color3.fromRGB(100, 200, 255)
	message.TextSize = 20
	message.Font = Enum.Font.GothamBold
	message.TextXAlignment = Enum.TextXAlignment.Left
	message.TextStrokeTransparency = 0.5
	message.Parent = notification

	-- Timer Text
	local timer = Instance.new("TextLabel")
	timer.Name = "Timer"
	timer.Size = UDim2.new(1, -80, 0, 30)
	timer.Position = UDim2.new(0, 75, 0, 45)
	timer.BackgroundTransparency = 1
	timer.Text = "Enemies cannot attack you: 10s"
	timer.TextColor3 = Color3.fromRGB(200, 200, 200)
	timer.TextSize = 16
	timer.Font = Enum.Font.Gotham
	timer.TextXAlignment = Enum.TextXAlignment.Left
	timer.Parent = notification

	return screenGui
end

-- ========================================
-- SHOW NOTIFICATION
-- ========================================

function SpawnProtectionUI.ShowNotification(message, duration)
	local ui = playerGui:FindFirstChild("SpawnProtectionUI")
	if not ui then
		ui = SpawnProtectionUI.CreateNotification()
	end

	local notification = ui:FindFirstChild("Notification")
	if not notification then return end

	local messageLabel = notification:FindFirstChild("Message")
	local timerLabel = notification:FindFirstChild("Timer")

	if messageLabel then
		messageLabel.Text = message or "SPAWN PROTECTION"
	end

	-- Show notification
	notification.Visible = true

	-- Animate in
	notification.Position = UDim2.new(0.5, -200, 0.1, 0)
	local tweenService = game:GetService("TweenService")
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tween = tweenService:Create(notification, tweenInfo, {
		Position = UDim2.new(0.5, -200, 0.15, 0)
	})
	tween:Play()

	-- If duration is provided, start countdown
	if duration and timerLabel then
		local endTime = tick() + duration

		task.spawn(function()
			while tick() < endTime and notification.Visible do
				local remaining = math.ceil(endTime - tick())
				timerLabel.Text = "Enemies cannot attack you: " .. remaining .. "s"

				-- Flash effect when almost done
				if remaining <= 3 then
					timerLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
				else
					timerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				end

				task.wait(0.1)
			end

			-- Hide notification
			SpawnProtectionUI.HideNotification()
		end)
	end
end

-- ========================================
-- HIDE NOTIFICATION
-- ========================================

function SpawnProtectionUI.HideNotification()
	local ui = playerGui:FindFirstChild("SpawnProtectionUI")
	if not ui then return end

	local notification = ui:FindFirstChild("Notification")
	if not notification then return end

	-- Animate out
	local tweenService = game:GetService("TweenService")
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local tween = tweenService:Create(notification, tweenInfo, {
		Position = UDim2.new(0.5, -200, 0.05, 0),
		BackgroundTransparency = 1
	})
	tween:Play()

	task.wait(0.3)
	notification.Visible = false
	notification.BackgroundTransparency = 0
end

-- ========================================
-- SHOW QUICK MESSAGE
-- ========================================

function SpawnProtectionUI.ShowQuickMessage(text)
	local ui = playerGui:FindFirstChild("SpawnProtectionUI")
	if not ui then
		ui = SpawnProtectionUI.CreateNotification()
	end

	local notification = ui:FindFirstChild("Notification")
	if not notification then return end

	local timerLabel = notification:FindFirstChild("Timer")
	if timerLabel then
		timerLabel.Text = text
	end

	notification.Visible = true

	-- Auto hide after 2 seconds
	task.delay(2, function()
		SpawnProtectionUI.HideNotification()
	end)
end

-- ========================================
-- SETUP REMOTE EVENTS
-- ========================================

function SpawnProtectionUI.SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	if not remoteEvents then
		warn("⚠️ RemoteEvents folder not found")
		return
	end

	-- Spawn Protection Notification
	local notification = remoteEvents:FindFirstChild("SpawnProtectionNotification")
	if notification then
		notification.OnClientEvent:Connect(function(message)
			-- Parse message to check if it's start or end
			if string.find(message, "Spawn Protection:") then
				-- Extract duration from message
				local duration = tonumber(string.match(message, "(%d+)s"))
				if duration then
					SpawnProtectionUI.ShowNotification("SPAWN PROTECTION", duration)
				end
			elseif string.find(message, "protection ended") then
				SpawnProtectionUI.HideNotification()
			elseif string.find(message, "Protected!") then
				SpawnProtectionUI.ShowQuickMessage("🛡️ Attack blocked by protection!")
			end
		end)
	end
end

-- ========================================
-- INITIALIZE
-- ========================================

print("🛡️ SpawnProtectionUI initializing...")
SpawnProtectionUI.SetupRemoteEvents()
print("✅ SpawnProtectionUI ready!")

return SpawnProtectionUI
