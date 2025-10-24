-- MobileControls.lua - Joystick + Dodge Button cho Mobile
-- Copy vào StarterPlayerScripts/MobileControls (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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

-- Joystick Base (Outer Ring)
local joystickBase = Instance.new("Frame")
joystickBase.Name = "JoystickBase"
joystickBase.Size = UDim2.new(0, 160, 0, 160)
joystickBase.Position = UDim2.new(0, 70, 1, -190)
joystickBase.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
joystickBase.BackgroundTransparency = 0.4
joystickBase.BorderSizePixel = 0
joystickBase.Parent = screenGui

local baseCorner = Instance.new("UICorner")
baseCorner.CornerRadius = UDim.new(1, 0)
baseCorner.Parent = joystickBase

-- Outer Ring Stroke
local outerStroke = Instance.new("UIStroke")
outerStroke.Color = Color3.fromRGB(100, 150, 255)
outerStroke.Thickness = 3
outerStroke.Transparency = 0.3
outerStroke.Parent = joystickBase

-- Inner Ring (Movement Area)
local innerRing = Instance.new("Frame")
innerRing.Name = "InnerRing"
innerRing.Size = UDim2.new(0, 120, 0, 120)
innerRing.Position = UDim2.new(0.5, -60, 0.5, -60)
innerRing.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
innerRing.BackgroundTransparency = 0.6
innerRing.BorderSizePixel = 0
innerRing.Parent = joystickBase

local innerCorner = Instance.new("UICorner")
innerCorner.CornerRadius = UDim.new(1, 0)
innerCorner.Parent = innerRing

local innerStroke = Instance.new("UIStroke")
innerStroke.Color = Color3.fromRGB(80, 120, 200)
innerStroke.Thickness = 2
innerStroke.Transparency = 0.5
innerStroke.Parent = innerRing

-- Center Dot
local centerDot = Instance.new("Frame")
centerDot.Name = "CenterDot"
centerDot.Size = UDim2.new(0, 8, 0, 8)
centerDot.Position = UDim2.new(0.5, -4, 0.5, -4)
centerDot.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
centerDot.BackgroundTransparency = 0.3
centerDot.BorderSizePixel = 0
centerDot.Parent = joystickBase

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = centerDot

-- Direction Indicators (8 directions)
local directions = {
	{Rot = 0, Pos = Vector2.new(0.5, 0.1)},     -- Up
	{Rot = 45, Pos = Vector2.new(0.8, 0.2)},    -- Up-Right
	{Rot = 90, Pos = Vector2.new(0.9, 0.5)},    -- Right
	{Rot = 135, Pos = Vector2.new(0.8, 0.8)},   -- Down-Right
	{Rot = 180, Pos = Vector2.new(0.5, 0.9)},   -- Down
	{Rot = 225, Pos = Vector2.new(0.2, 0.8)},   -- Down-Left
	{Rot = 270, Pos = Vector2.new(0.1, 0.5)},   -- Left
	{Rot = 315, Pos = Vector2.new(0.2, 0.2)}    -- Up-Left
}

for i, dir in ipairs(directions) do
	local indicator = Instance.new("Frame")
	indicator.Name = "DirectionIndicator" .. i
	indicator.Size = UDim2.new(0, 3, 0, 15)
	indicator.Position = UDim2.new(dir.Pos.X, -1.5, dir.Pos.Y, -7.5)
	indicator.AnchorPoint = Vector2.new(0.5, 0.5)
	indicator.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
	indicator.BackgroundTransparency = 0.6
	indicator.BorderSizePixel = 0
	indicator.Rotation = dir.Rot
	indicator.Parent = joystickBase

	local indCorner = Instance.new("UICorner")
	indCorner.CornerRadius = UDim.new(1, 0)
	indCorner.Parent = indicator
end

-- Joystick Stick (Main Control)
local joystickStick = Instance.new("Frame")
joystickStick.Name = "JoystickStick"
joystickStick.Size = UDim2.new(0, 70, 0, 70)
joystickStick.Position = UDim2.new(0.5, -35, 0.5, -35)
joystickStick.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
joystickStick.BackgroundTransparency = 0.2
joystickStick.BorderSizePixel = 0
joystickStick.ZIndex = 2
joystickStick.Parent = joystickBase

local stickCorner = Instance.new("UICorner")
stickCorner.CornerRadius = UDim.new(1, 0)
stickCorner.Parent = joystickStick

-- Stick Gradient
local stickGradient = Instance.new("UIGradient")
stickGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 200, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 120, 200))
}
stickGradient.Rotation = 90
stickGradient.Parent = joystickStick

-- Stick Stroke
local stickStroke = Instance.new("UIStroke")
stickStroke.Color = Color3.fromRGB(255, 255, 255)
stickStroke.Thickness = 3
stickStroke.Transparency = 0.5
stickStroke.Parent = joystickStick

-- Direction Arrow on Stick
local arrow = Instance.new("ImageLabel")
arrow.Name = "Arrow"
arrow.Size = UDim2.new(0, 30, 0, 30)
arrow.Position = UDim2.new(0.5, -15, 0.3, -15)
arrow.BackgroundTransparency = 1
arrow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png" -- Triangle shape
arrow.ImageColor3 = Color3.fromRGB(255, 255, 255)
arrow.ImageTransparency = 0.3
arrow.Rotation = 0
arrow.Parent = joystickStick

-- Touch Effect Ring
local touchRing = Instance.new("Frame")
touchRing.Name = "TouchRing"
touchRing.Size = UDim2.new(1, 10, 1, 10)
touchRing.Position = UDim2.new(0.5, -40, 0.5, -40)
touchRing.AnchorPoint = Vector2.new(0.5, 0.5)
touchRing.BackgroundTransparency = 1
touchRing.BorderSizePixel = 0
touchRing.ZIndex = 1
touchRing.Visible = false
touchRing.Parent = joystickBase

local touchRingStroke = Instance.new("UIStroke")
touchRingStroke.Color = Color3.fromRGB(150, 200, 255)
touchRingStroke.Thickness = 4
touchRingStroke.Transparency = 0
touchRingStroke.Parent = touchRing

local touchRingCorner = Instance.new("UICorner")
touchRingCorner.CornerRadius = UDim.new(1, 0)
touchRingCorner.Parent = touchRing

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

	-- Update stick position with smooth movement
	joystickStick.Position = UDim2.new(0.5, delta.X, 0.5, delta.Y)

	-- Calculate normalized direction (-1 to 1)
	MobileControls.MoveDirection = delta / maxRadius
	MobileControls.JoystickDelta = delta

	-- Rotate arrow to point in movement direction
	if magnitude > 5 then
		local angle = math.deg(math.atan2(delta.Y, delta.X))
		arrow.Rotation = angle + 90 -- +90 because arrow points up by default

		-- Highlight direction indicators based on angle
		for i, dir in ipairs(directions) do
			local indicator = joystickBase:FindFirstChild("DirectionIndicator" .. i)
			if indicator then
				local angleDiff = math.abs(angle - (dir.Rot - 90))
				if angleDiff > 180 then
					angleDiff = 360 - angleDiff
				end

				-- Highlight if within 30 degrees
				if angleDiff < 30 then
					indicator.BackgroundTransparency = 0.2
					indicator.Size = UDim2.new(0, 4, 0, 18)
				else
					indicator.BackgroundTransparency = 0.6
					indicator.Size = UDim2.new(0, 3, 0, 15)
				end
			end
		end

		-- Scale stick based on distance from center
		local scale = 1 + (magnitude / maxRadius) * 0.15
		joystickStick.Size = UDim2.new(0, 70 * scale, 0, 70 * scale)
		joystickStick.Position = UDim2.new(0.5, delta.X - 35 * scale, 0.5, delta.Y - 35 * scale)
	else
		-- Reset when near center
		arrow.Rotation = 0
		joystickStick.Size = UDim2.new(0, 70, 0, 70)
		for i = 1, #directions do
			local indicator = joystickBase:FindFirstChild("DirectionIndicator" .. i)
			if indicator then
				indicator.BackgroundTransparency = 0.6
				indicator.Size = UDim2.new(0, 3, 0, 15)
			end
		end
	end

	-- Pulse touch ring
	touchRing.Visible = true
	local ringScale = 1 + (magnitude / maxRadius) * 0.3
	touchRing.Size = UDim2.new(1, 10 * ringScale, 1, 10 * ringScale)
	touchRingStroke.Transparency = 0.3 + (magnitude / maxRadius) * 0.5
end

local function ResetJoystick()
	MobileControls.JoystickActive = false
	MobileControls.MoveDirection = Vector2.new(0, 0)
	MobileControls.JoystickDelta = Vector2.new(0, 0)
	MobileControls.TouchId = nil

	-- Smooth return to center with tween
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local centerTween = TweenService:Create(joystickStick, tweenInfo, {
		Position = UDim2.new(0.5, -35, 0.5, -35),
		Size = UDim2.new(0, 70, 0, 70)
	})
	centerTween:Play()

	-- Reset arrow rotation
	local arrowTween = TweenService:Create(arrow, tweenInfo, {
		Rotation = 0
	})
	arrowTween:Play()

	-- Hide touch ring
	touchRing.Visible = false

	-- Reset direction indicators
	for i = 1, #directions do
		local indicator = joystickBase:FindFirstChild("DirectionIndicator" .. i)
		if indicator then
			indicator.BackgroundTransparency = 0.6
			indicator.Size = UDim2.new(0, 3, 0, 15)
		end
	end
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
