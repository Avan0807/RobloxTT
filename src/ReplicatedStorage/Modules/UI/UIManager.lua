-- UIManager.lua - Global UI Management System
-- Author: Claude Code
-- Description: Manages all UI components, handles switching between UIs, and provides global UI utilities

local UIManager = {}
UIManager.UIs = {}
UIManager.CurrentOpenUI = nil

-- ============================================
-- UI REGISTRATION
-- ============================================

--[[
	Registers a UI component with the manager
	@param name string - Unique name for the UI
	@param uiInstance table - Instance of the UI (should extend BaseUI)
]]
function UIManager.Register(name, uiInstance)
	if UIManager.UIs[name] then
		warn("UIManager: UI with name '" .. name .. "' already registered!")
		return false
	end

	UIManager.UIs[name] = uiInstance
	print("UIManager: Registered '" .. name .. "'")

	-- Hook into UI's open/close to track current open UI
	if uiInstance.Open then
		local originalOpen = uiInstance.Open
		uiInstance.Open = function(self)
			-- Close other UIs if needed (optional)
			-- UIManager.CloseAll()

			UIManager.CurrentOpenUI = name
			originalOpen(self)
		end
	end

	if uiInstance.Close then
		local originalClose = uiInstance.Close
		uiInstance.Close = function(self)
			if UIManager.CurrentOpenUI == name then
				UIManager.CurrentOpenUI = nil
			end
			originalClose(self)
		end
	end

	return true
end

-- ============================================
-- UI ACCESS
-- ============================================

function UIManager.Get(name)
	local ui = UIManager.UIs[name]
	if not ui then
		warn("UIManager: UI '" .. name .. "' not found!")
	end
	return ui
end

function UIManager.Open(name)
	local ui = UIManager.Get(name)
	if ui and ui.Open then
		ui:Open()
	end
end

function UIManager.Close(name)
	local ui = UIManager.Get(name)
	if ui and ui.Close then
		ui:Close()
	end
end

function UIManager.Toggle(name)
	local ui = UIManager.Get(name)
	if ui and ui.Toggle then
		ui:Toggle()
	end
end

-- ============================================
-- BULK OPERATIONS
-- ============================================

function UIManager.CloseAll()
	for name, ui in pairs(UIManager.UIs) do
		if ui.IsOpen and ui.Close then
			ui:Close()
		end
	end
	UIManager.CurrentOpenUI = nil
end

function UIManager.OpenOnly(name)
	UIManager.CloseAll()
	UIManager.Open(name)
end

-- ============================================
-- GLOBAL NOTIFICATIONS
-- ============================================

--[[
	Shows a notification in the currently open UI, or creates a standalone notification
	@param message string - Message to display
	@param type string - "success", "error", "warning", or nil for default
	@param duration number - Duration in seconds (optional)
]]
function UIManager.ShowNotification(message, notifType, duration)
	-- Try to show in current open UI first
	if UIManager.CurrentOpenUI then
		local ui = UIManager.UIs[UIManager.CurrentOpenUI]
		if ui then
			if notifType == "success" and ui.ShowSuccess then
				ui:ShowSuccess(message)
				return
			elseif notifType == "error" and ui.ShowError then
				ui:ShowError(message)
				return
			elseif notifType == "warning" and ui.ShowWarning then
				ui:ShowWarning(message)
				return
			elseif ui.ShowNotification then
				ui:ShowNotification(message, duration)
				return
			end
		end
	end

	-- Fallback: Create standalone notification
	UIManager.CreateStandaloneNotification(message, notifType, duration)
end

function UIManager.CreateStandaloneNotification(message, notifType, duration)
	local Players = game:GetService("Players")
	local TweenService = game:GetService("TweenService")
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	duration = duration or 3

	-- Determine color based on type
	local color = Color3.fromRGB(50, 50, 50)
	if notifType == "success" then
		color = Color3.fromRGB(50, 200, 50)
	elseif notifType == "error" then
		color = Color3.fromRGB(200, 50, 50)
	elseif notifType == "warning" then
		color = Color3.fromRGB(200, 150, 50)
	end

	-- Find or create notifications container
	local screenGui = playerGui:FindFirstChild("GlobalNotifications")
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "GlobalNotifications"
		screenGui.ResetOnSpawn = false
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.Parent = playerGui
	end

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 350, 0, 60)
	notif.Position = UDim2.new(0.5, -175, 0.1, 0)
	notif.BackgroundColor3 = color
	notif.BorderSizePixel = 0
	notif.ZIndex = 200
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

	-- Slide in animation
	notif.Position = UDim2.new(0.5, -175, -0.1, 0)
	TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -175, 0.1, 0)
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

-- ============================================
-- UI STATE
-- ============================================

function UIManager.IsAnyUIOpen()
	return UIManager.CurrentOpenUI ~= nil
end

function UIManager.GetCurrentOpenUI()
	return UIManager.CurrentOpenUI
end

function UIManager.GetAllRegistered()
	local names = {}
	for name, _ in pairs(UIManager.UIs) do
		table.insert(names, name)
	end
	return names
end

-- ============================================
-- DEBUGGING
-- ============================================

function UIManager.PrintStatus()
	print("=== UIManager Status ===")
	print("Total registered UIs:", #UIManager.GetAllRegistered())
	print("Currently open:", UIManager.CurrentOpenUI or "None")
	print("Registered UIs:")
	for name, ui in pairs(UIManager.UIs) do
		print("  -", name, "| Open:", ui.IsOpen or false)
	end
	print("=====================")
end

return UIManager
