-- MobileControls.lua - Joystick + Dodge Button cho Mobile
-- Copy vào StarterPlayerScripts/MobileControls (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Chỉ hiện trên Mobile
if not UserInputService.TouchEnabled then
	return -- PC không cần joystick
end

-- ========================================
-- MOBILE CONTROLS SETUP
-- ========================================

local MobileControls = {
	JoystickActive = false,
	JoystickCenter = Vector2.new(0, 0),
	JoystickDelta = Vector2.new(0, 0),
	MoveDirection = Vector2.new(0, 0),
	TouchId = nil
}

-- ========================================
-- CREATE UI
-- ========================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileControls"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Joystick Base
local joystickBase = Instance.new("Frame")
joystickBase.Name = "JoystickBase"
joystickBase.Size = UDim2.new(0, 150, 0, 150)
joystickBase.Position = UDim2.new(0, 80, 1, -180)
joystickBase.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
joystickBase.BackgroundTransparency = 0.5
joystickBase.BorderSizePixel = 0
joystickBase.Parent = screenGui

local baseCorner = Instance.new("UICorner")
baseCorner.CornerRadius = UDim.new(1, 0)
baseCorner.Parent = joystickBase

-- Joystick Stick
local joystickStick = Instance.new("Frame")
joystickStick.Name = "JoystickStick"
joystickStick.Size = UDim2.new(0, 60, 0, 60)
joystickStick.Position = UDim2.new(0.5, -30, 0.5, -30)
joystickStick.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
joystickStick.BackgroundTransparency = 0.3
joystickStick.BorderSizePixel = 0
joystickStick.Parent = joystickBase

local stickCorner = Instance.new("UICorner")
stickCorner.CornerRadius = UDim.new(1, 0)
stickCorner.Parent = joystickStick

-- Dodge Button
local dodgeButton = Instance.new("TextButton")
dodgeButton.Name = "DodgeButton"
dodgeButton.Size = UDim2.new(0, 80, 0, 80)
dodgeButton.Position = UDim2.new(0, 250, 1, -180)
dodgeButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
dodgeButton.Text = "DODGE"
dodgeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dodgeButton.TextScaled = true
dodgeButton.Font = Enum.Font.SourceSansBold
dodgeButton.BorderSizePixel = 0
dodgeButton.Parent = screenGui

local dodgeCorner = Instance.new("UICorner")
dodgeCorner.CornerRadius = UDim.new(1, 0)
dodgeCorner.Parent = dodgeButton

-- Stamina Bar
local staminaBarBg = Instance.new("Frame")
staminaBarBg.Name = "StaminaBarBg"
staminaBarBg.Size = UDim2.new(0, 200, 0, 15)
staminaBarBg.Position = UDim2.new(0.5, -100, 1, -50)
staminaBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
staminaBarBg.BorderSizePixel = 0
staminaBarBg.Parent = screenGui

local staminaBar = Instance.new("Frame")
staminaBar.Name = "StaminaBar"
staminaBar.Size = UDim2.new(1, 0, 1, 0)
staminaBar.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
staminaBar.BorderSizePixel = 0
staminaBar.Parent = staminaBarBg

local staminaLabel = Instance.new("TextLabel")
staminaLabel.Size = UDim2.new(1, 0, 1, 0)
staminaLabel.BackgroundTransparency = 1
staminaLabel.Text = "Stamina: 100/100"
staminaLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
staminaLabel.TextScaled = true
staminaLabel.Font = Enum.Font.SourceSansBold
staminaLabel.ZIndex = 2
staminaLabel.Parent = staminaBarBg

-- ========================================
-- JOYSTICK LOGIC
-- ========================================

local function UpdateJoystick(touchPosition)
	if not MobileControls.JoystickActive then
		return
	end

	local center = joystickBase.AbsolutePosition + joystickBase.AbsoluteSize / 2
	local delta = touchPosition - center

	local maxRadius = joystickBase.AbsoluteSize.X / 2 - joystickStick.AbsoluteSize.X / 2

	-- Clamp to circle
	local magnitude = delta.Magnitude
	if magnitude > maxRadius then
		delta = delta.Unit * maxRadius
	end

	-- Update stick position
	joystickStick.Position = UDim2.new(0.5, delta.X, 0.5, delta.Y)

	-- Calculate normalized direction (-1 to 1)
	MobileControls.MoveDirection = delta / maxRadius
	MobileControls.JoystickDelta = delta
end

local function ResetJoystick()
	MobileControls.JoystickActive = false
	MobileControls.MoveDirection = Vector2.new(0, 0)
	MobileControls.JoystickDelta = Vector2.new(0, 0)
	MobileControls.TouchId = nil

	-- Reset stick to center
	joystickStick.Position = UDim2.new(0.5, -30, 0.5, -30)
end

-- ========================================
-- INPUT HANDLING
-- ========================================

UserInputService.TouchStarted:Connect(function(touch, gameProcessed)
	if gameProcessed then return end

	local touchPos = touch.Position

	-- Check if touch is on joystick
	local basePos = joystickBase.AbsolutePosition
	local baseSize = joystickBase.AbsoluteSize

	if touchPos.X >= basePos.X and touchPos.X <= basePos.X + baseSize.X and
	   touchPos.Y >= basePos.Y and touchPos.Y <= basePos.Y + baseSize.Y then

		MobileControls.JoystickActive = true
		MobileControls.TouchId = touch.UserInputState
		UpdateJoystick(touchPos)
	end
end)

UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
	if MobileControls.JoystickActive and touch.UserInputState == MobileControls.TouchId then
		UpdateJoystick(touch.Position)
	end
end)

UserInputService.TouchEnded:Connect(function(touch, gameProcessed)
	if touch.UserInputState == MobileControls.TouchId then
		ResetJoystick()
	end
end)

-- ========================================
-- DODGE BUTTON
-- ========================================

dodgeButton.MouseButton1Click:Connect(function()
	-- Fire dodge event
	local RemoteEvents = game.ReplicatedStorage:WaitForChild("RemoteEvents")
	local DodgeEvent = RemoteEvents:FindFirstChild("Dodge")
	if DodgeEvent then
		-- Dodge in movement direction, or forward if not moving
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local direction
			if MobileControls.MoveDirection.Magnitude > 0.1 then
				-- Convert 2D joystick to 3D direction
				local camera = workspace.CurrentCamera
				local cameraCFrame = camera.CFrame

				local forward = cameraCFrame.LookVector
				local right = cameraCFrame.RightVector

				direction = (forward * -MobileControls.MoveDirection.Y + right * MobileControls.MoveDirection.X).Unit
			else
				-- Default forward
				direction = character.HumanoidRootPart.CFrame.LookVector
			end

			DodgeEvent:FireServer(direction)
		end
	end
end)

-- ========================================
-- APPLY MOVEMENT
-- ========================================

RunService.RenderStepped:Connect(function()
	if MobileControls.MoveDirection.Magnitude > 0.1 then
		local character = player.Character
		if character and character:FindFirstChild("Humanoid") then
			local humanoid = character.Humanoid

			-- Convert joystick direction to world direction
			local camera = workspace.CurrentCamera
			local cameraCFrame = camera.CFrame

			local forward = cameraCFrame.LookVector
			local right = cameraCFrame.RightVector

			local moveDirection = (forward * -MobileControls.MoveDirection.Y + right * MobileControls.MoveDirection.X).Unit

			-- Move character
			humanoid:Move(moveDirection, false)
		end
	end
end)

-- ========================================
-- UPDATE STAMINA DISPLAY
-- ========================================

spawn(function()
	while wait(0.1) do
		local DodgeSystem = require(game.ReplicatedStorage.Modules.Combat.DodgeSystem)
		local stamina, maxStamina, cooldown = DodgeSystem.GetStaminaInfo(player)

		staminaBar.Size = UDim2.new(stamina / maxStamina, 0, 1, 0)
		staminaLabel.Text = string.format("Stamina: %d/%d", math.floor(stamina), maxStamina)

		if cooldown > 0 then
			dodgeButton.Text = string.format("%.1fs", cooldown)
			dodgeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		else
			dodgeButton.Text = "DODGE"
			dodgeButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
		end
	end
end)

print("✅ MobileControls loaded (Joystick + Dodge)")
return MobileControls
