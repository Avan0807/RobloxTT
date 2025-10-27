-- BaseUI.lua - Base Class for All UI Components
-- Author: Claude Code
-- Description: Provides common functionality for all UI components to reduce code duplication

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- BASE UI CLASS
-- ============================================

local BaseUI = {}
BaseUI.__index = BaseUI

--[[
	Creates a new UI instance
	@param config table - Configuration table with:
		- Name: string - Name of the UI
		- ToggleKey: KeyCode - Key to toggle UI (optional)
		- CloseOnEscape: boolean - Close UI when Escape is pressed (default: true)
		- StartVisible: boolean - Start with UI visible (default: false)
		- RemoteEvents: table - List of remote event names to setup
]]
function BaseUI.new(config)
	local self = setmetatable({}, BaseUI)

	-- Core properties
	self.Name = config.Name or "BaseUI"
	self.IsOpen = config.StartVisible or false
	self.ToggleKey = config.ToggleKey
	self.CloseOnEscape = config.CloseOnEscape ~= false -- Default true
	self.RemoteEventNames = config.RemoteEvents or {}

	-- UI Components
	self.ScreenGui = nil
	self.MainFrame = nil
	self.RemoteEvents = {}

	-- Notification settings
	self.NotificationDuration = config.NotificationDuration or 3
	self.NotificationPosition = config.NotificationPosition or UDim2.new(0.5, -175, 0.1, 0)

	return self
end

-- ============================================
-- CORE UI METHODS
-- ============================================

function BaseUI:Initialize()
	print("🎨 " .. self.Name .. " initializing...")

	-- Create UI
	self:CreateUI()

	-- Setup remote events
	self:SetupRemoteEvents()

	-- Setup input handling
	self:SetupInput()

	-- Post-initialization hook (for subclasses to override)
	if self.OnInitialized then
		self:OnInitialized()
	end

	print("✅ " .. self.Name .. " ready!" .. (self.ToggleKey and " Press '" .. self.ToggleKey.Name .. "' to open" or ""))

	return self
end

function BaseUI:CreateUI()
	-- Create ScreenGui
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = self.Name
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.ScreenGui.Parent = playerGui

	-- Create main frame (subclasses should override CreateMainFrame)
	if self.CreateMainFrame then
		self.MainFrame = self:CreateMainFrame(self.ScreenGui)
	end

	return self.ScreenGui
end

function BaseUI:Open()
	self.IsOpen = true

	if self.MainFrame then
		self.MainFrame.Visible = true
	end

	-- Hook for subclasses
	if self.OnOpen then
		self:OnOpen()
	end
end

function BaseUI:Close()
	self.IsOpen = false

	if self.MainFrame then
		self.MainFrame.Visible = false
	end

	-- Hook for subclasses
	if self.OnClose then
		self:OnClose()
	end
end

function BaseUI:Toggle()
	if self.IsOpen then
		self:Close()
	else
		self:Open()
	end
end

-- ============================================
-- UI HELPER METHODS
-- ============================================

function BaseUI:CreateFrame(config)
	local frame = Instance.new("Frame")
	frame.Name = config.Name or "Frame"
	frame.Size = config.Size or UDim2.new(0, 100, 0, 100)
	frame.Position = config.Position or UDim2.new(0, 0, 0, 0)
	frame.BackgroundColor3 = config.BackgroundColor3 or Color3.fromRGB(30, 30, 30)
	frame.BackgroundTransparency = config.BackgroundTransparency or 0
	frame.BorderSizePixel = config.BorderSizePixel or 2
	frame.BorderColor3 = config.BorderColor3 or Color3.fromRGB(100, 100, 100)
	frame.Visible = config.Visible ~= false
	frame.Parent = config.Parent

	if config.CornerRadius then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, config.CornerRadius)
		corner.Parent = frame
	end

	return frame
end

function BaseUI:CreateButton(config)
	local button = Instance.new("TextButton")
	button.Name = config.Name or "Button"
	button.Size = config.Size or UDim2.new(0, 100, 0, 40)
	button.Position = config.Position or UDim2.new(0, 0, 0, 0)
	button.BackgroundColor3 = config.BackgroundColor3 or Color3.fromRGB(50, 150, 200)
	button.Text = config.Text or "Button"
	button.TextColor3 = config.TextColor3 or Color3.fromRGB(255, 255, 255)
	button.Font = config.Font or Enum.Font.GothamBold
	button.TextSize = config.TextSize or 16
	button.TextScaled = config.TextScaled or false
	button.Parent = config.Parent

	if config.CornerRadius then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, config.CornerRadius)
		corner.Parent = button
	end

	if config.OnClick then
		button.MouseButton1Click:Connect(function()
			config.OnClick()
		end)
	end

	-- Add hover effect
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(
				math.min(255, button.BackgroundColor3.R * 255 * 1.2),
				math.min(255, button.BackgroundColor3.G * 255 * 1.2),
				math.min(255, button.BackgroundColor3.B * 255 * 1.2)
			)
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {
			BackgroundColor3 = config.BackgroundColor3 or Color3.fromRGB(50, 150, 200)
		}):Play()
	end)

	return button
end

function BaseUI:CreateLabel(config)
	local label = Instance.new("TextLabel")
	label.Name = config.Name or "Label"
	label.Size = config.Size or UDim2.new(0, 100, 0, 30)
	label.Position = config.Position or UDim2.new(0, 0, 0, 0)
	label.BackgroundColor3 = config.BackgroundColor3 or Color3.fromRGB(50, 50, 50)
	label.BackgroundTransparency = config.BackgroundTransparency or 0
	label.Text = config.Text or ""
	label.TextColor3 = config.TextColor3 or Color3.fromRGB(255, 255, 255)
	label.Font = config.Font or Enum.Font.Gotham
	label.TextSize = config.TextSize or 14
	label.TextScaled = config.TextScaled or false
	label.TextXAlignment = config.TextXAlignment or Enum.TextXAlignment.Center
	label.TextYAlignment = config.TextYAlignment or Enum.TextYAlignment.Center
	label.TextWrapped = config.TextWrapped or false
	label.Parent = config.Parent

	if config.CornerRadius then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, config.CornerRadius)
		corner.Parent = label
	end

	return label
end

-- ============================================
-- NOTIFICATION SYSTEM
-- ============================================

function BaseUI:ShowNotification(message, duration, color)
	if not self.ScreenGui then return end

	duration = duration or self.NotificationDuration
	color = color or Color3.fromRGB(50, 50, 50)

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 350, 0, 60)
	notif.Position = self.NotificationPosition
	notif.BackgroundColor3 = color
	notif.BorderSizePixel = 0
	notif.ZIndex = 100
	notif.Parent = self.ScreenGui

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

	-- Slide in animation
	notif.Position = self.NotificationPosition + UDim2.new(0, 0, -0.1, 0)
	TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = self.NotificationPosition
	}):Play()

	-- Fade out and destroy
	task.delay(duration, function()
		for i = 0, 1, 0.1 do
			notif.BackgroundTransparency = i
			label.TextTransparency = i
			task.wait(0.05)
		end
		notif:Destroy()
	end)
end

function BaseUI:ShowSuccess(message)
	self:ShowNotification(message, nil, Color3.fromRGB(50, 200, 50))
end

function BaseUI:ShowError(message)
	self:ShowNotification(message, nil, Color3.fromRGB(200, 50, 50))
end

function BaseUI:ShowWarning(message)
	self:ShowNotification(message, nil, Color3.fromRGB(200, 150, 50))
end

-- ============================================
-- REMOTE EVENTS SETUP
-- ============================================

function BaseUI:SetupRemoteEvents()
	local remoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 10)
	if not remoteEvents then
		warn(self.Name .. ": RemoteEvents folder not found!")
		return
	end

	-- Setup each remote event specified in config
	for _, eventName in ipairs(self.RemoteEventNames) do
		local remoteEvent = remoteEvents:WaitForChild(eventName, 10)
		if remoteEvent then
			self.RemoteEvents[eventName] = remoteEvent

			-- If there's a handler method, connect it
			local handlerName = "On" .. eventName
			if self[handlerName] then
				remoteEvent.OnClientEvent:Connect(function(...)
					self[handlerName](self, ...)
				end)
			end
		else
			warn(self.Name .. ": RemoteEvent '" .. eventName .. "' not found!")
		end
	end
end

function BaseUI:FireServer(eventName, ...)
	local event = self.RemoteEvents[eventName]
	if event then
		event:FireServer(...)
	else
		warn(self.Name .. ": RemoteEvent '" .. eventName .. "' not setup!")
	end
end

-- ============================================
-- INPUT HANDLING
-- ============================================

function BaseUI:SetupInput()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		-- Toggle key
		if self.ToggleKey and input.KeyCode == self.ToggleKey then
			self:Toggle()
		-- Escape key
		elseif self.CloseOnEscape and input.KeyCode == Enum.KeyCode.Escape and self.IsOpen then
			self:Close()
		end
	end)
end

-- ============================================
-- UTILITY METHODS
-- ============================================

function BaseUI:Destroy()
	if self.ScreenGui then
		self.ScreenGui:Destroy()
		self.ScreenGui = nil
	end

	if self.OnDestroy then
		self:OnDestroy()
	end
end

function BaseUI:GetPlayerData()
	local dataValue = player:FindFirstChild("PlayerData")
	if dataValue then
		local HttpService = game:GetService("HttpService")
		return HttpService:JSONDecode(dataValue.Value)
	end
	return nil
end

return BaseUI
