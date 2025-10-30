-- MobileControls.lua - Virtual Joystick + Attack Buttons cho Mobile
-- Tự động detect PC/Mobile và chỉ hiện trên mobile

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MobileControls = {}
MobileControls.IsMobile = false
MobileControls.Enabled = false

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ========================================
-- DETECT MOBILE
-- ========================================

function MobileControls.DetectMobile()
	-- Check if on mobile/tablet
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		return true
	end
	return false
end

MobileControls.IsMobile = MobileControls.DetectMobile()

-- ========================================
-- CREATE UI CONTAINER
-- ========================================

function MobileControls.CreateUI()
	-- Container for all mobile controls
	local mobileUI = Instance.new("ScreenGui")
	mobileUI.Name = "MobileControls"
	mobileUI.ResetOnSpawn = false
	mobileUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	mobileUI.Parent = playerGui

	return mobileUI
end

-- ========================================
-- VIRTUAL JOYSTICK (Movement)
-- ========================================

function MobileControls.CreateJoystick(parent)
	-- Joystick container
	local joystickFrame = Instance.new("Frame")
	joystickFrame.Name = "Joystick"
	joystickFrame.Size = UDim2.new(0, 150, 0, 150)
	joystickFrame.Position = UDim2.new(0, 50, 1, -200)
	joystickFrame.AnchorPoint = Vector2.new(0, 0.5)
	joystickFrame.BackgroundTransparency = 1
	joystickFrame.Parent = parent

	-- Outer circle (boundary)
	local outerCircle = Instance.new("ImageLabel")
	outerCircle.Name = "Outer"
	outerCircle.Size = UDim2.new(1, 0, 1, 0)
	outerCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
	outerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	outerCircle.BackgroundTransparency = 1
	outerCircle.Image = "rbxasset://textures/ui/Controls/TouchDPad/Base.png"
	outerCircle.ImageTransparency = 0.3
	outerCircle.ImageColor3 = Color3.fromRGB(255, 255, 255)
	outerCircle.Parent = joystickFrame

	-- Inner circle (stick)
	local innerCircle = Instance.new("ImageLabel")
	innerCircle.Name = "Inner"
	innerCircle.Size = UDim2.new(0, 60, 0, 60)
	innerCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
	innerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	innerCircle.BackgroundTransparency = 1
	innerCircle.Image = "rbxasset://textures/ui/Controls/TouchDPad/Button.png"
	innerCircle.ImageColor3 = Color3.fromRGB(255, 255, 255)
	innerCircle.Parent = joystickFrame

	-- Joystick state
	local joystickData = {
		Active = false,
		InitialPosition = innerCircle.Position,
		MaxDistance = 45, -- Max distance from center
		InputPosition = Vector2.new(0, 0),
		Direction = Vector2.new(0, 0)
	}

	-- Touch input
	innerCircle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			joystickData.Active = true
		end
	end)

	innerCircle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			joystickData.Active = false
			innerCircle.Position = joystickData.InitialPosition
			joystickData.Direction = Vector2.new(0, 0)
		end
	end)

	-- Update joystick position
	RunService.RenderStepped:Connect(function()
		if joystickData.Active then
			local mousePos = UserInputService:GetMouseLocation()
			local joystickCenter = outerCircle.AbsolutePosition + outerCircle.AbsoluteSize / 2

			-- Calculate offset from center
			local offset = Vector2.new(
				mousePos.X - joystickCenter.X,
				mousePos.Y - joystickCenter.Y
			)

			-- Clamp to max distance
			local distance = offset.Magnitude
			if distance > joystickData.MaxDistance then
				offset = offset.Unit * joystickData.MaxDistance
			end

			-- Update stick position
			innerCircle.Position = UDim2.new(
				0.5, offset.X,
				0.5, offset.Y
			)

			-- Calculate direction (-1 to 1)
			joystickData.Direction = Vector2.new(
				offset.X / joystickData.MaxDistance,
				offset.Y / joystickData.MaxDistance
			)
		end
	end)

	return joystickData
end

-- ========================================
-- ATTACK BUTTON
-- ========================================

function MobileControls.CreateAttackButton(parent, position, callback)
	local button = Instance.new("ImageButton")
	button.Name = "AttackButton"
	button.Size = UDim2.new(0, 80, 0, 80)
	button.Position = position
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	button.BackgroundTransparency = 0.3
	button.BorderSizePixel = 0
	button.Image = ""
	button.Parent = parent

	-- Round corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = button

	-- Icon (fist/sword icon)
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(1, 0, 1, 0)
	icon.BackgroundTransparency = 1
	icon.Text = "⚔️"
	icon.TextScaled = true
	icon.Font = Enum.Font.GothamBold
	icon.TextColor3 = Color3.fromRGB(255, 255, 255)
	icon.Parent = button

	-- Press effect
	button.MouseButton1Down:Connect(function()
		button.Size = UDim2.new(0, 70, 0, 70)
	end)

	button.MouseButton1Up:Connect(function()
		button.Size = UDim2.new(0, 80, 0, 80)
		if callback then
			callback()
		end
	end)

	return button
end

-- ========================================
-- SKILL BUTTONS (Q, E, R, etc.)
-- ========================================

function MobileControls.CreateSkillButtons(parent)
	local skillButtons = {}

	local skills = {
		{Key = "Q", Position = UDim2.new(1, -100, 1, -100), Icon = "💥", Cooldown = 5},
		{Key = "E", Position = UDim2.new(1, -100, 1, -200), Icon = "⚡", Cooldown = 10},
		{Key = "R", Position = UDim2.new(1, -100, 1, -300), Icon = "🔥", Cooldown = 15},
		{Key = "F", Position = UDim2.new(1, -200, 1, -100), Icon = "🛡️", Cooldown = 20}
	}

	for _, skillData in ipairs(skills) do
		-- Button container
		local button = Instance.new("ImageButton")
		button.Name = "Skill" .. skillData.Key
		button.Size = UDim2.new(0, 70, 0, 70)
		button.Position = skillData.Position
		button.AnchorPoint = Vector2.new(0.5, 0.5)
		button.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
		button.BackgroundTransparency = 0.3
		button.BorderSizePixel = 0
		button.Parent = parent

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = button

		-- Icon
		local icon = Instance.new("TextLabel")
		icon.Size = UDim2.new(0.7, 0, 0.7, 0)
		icon.Position = UDim2.new(0.5, 0, 0.5, 0)
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.BackgroundTransparency = 1
		icon.Text = skillData.Icon
		icon.TextScaled = true
		icon.Parent = button

		-- Cooldown overlay
		local cooldownOverlay = Instance.new("Frame")
		cooldownOverlay.Name = "Cooldown"
		cooldownOverlay.Size = UDim2.new(1, 0, 0, 0)
		cooldownOverlay.Position = UDim2.new(0, 0, 1, 0)
		cooldownOverlay.AnchorPoint = Vector2.new(0, 1)
		cooldownOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		cooldownOverlay.BackgroundTransparency = 0.5
		cooldownOverlay.BorderSizePixel = 0
		cooldownOverlay.ZIndex = 2
		cooldownOverlay.Parent = button

		-- Cooldown text
		local cooldownText = Instance.new("TextLabel")
		cooldownText.Size = UDim2.new(1, 0, 1, 0)
		cooldownText.BackgroundTransparency = 1
		cooldownText.Text = ""
		cooldownText.TextScaled = true
		cooldownText.Font = Enum.Font.GothamBold
		cooldownText.TextColor3 = Color3.fromRGB(255, 255, 255)
		cooldownText.ZIndex = 3
		cooldownText.Parent = button

		-- Key label (corner)
		local keyLabel = Instance.new("TextLabel")
		keyLabel.Size = UDim2.new(0.3, 0, 0.3, 0)
		keyLabel.Position = UDim2.new(0, 2, 0, 2)
		keyLabel.BackgroundTransparency = 1
		keyLabel.Text = skillData.Key
		keyLabel.TextScaled = true
		keyLabel.Font = Enum.Font.GothamBold
		keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		keyLabel.TextStrokeTransparency = 0.5
		keyLabel.Parent = button

		-- Button data
		local buttonData = {
			Button = button,
			Key = skillData.Key,
			CooldownOverlay = cooldownOverlay,
			CooldownText = cooldownText,
			MaxCooldown = skillData.Cooldown,
			CurrentCooldown = 0,
			IsOnCooldown = false
		}

		-- Button click handler - Fire UseSkill event
		button.MouseButton1Click:Connect(function()
			if not buttonData.IsOnCooldown then
				-- Fire skill to server
				local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
				if remoteEvents then
					local useSkill = remoteEvents:FindFirstChild("UseSkill")
					if useSkill then
						-- Convert Q/E/R/F to slot numbers 1/2/3/4
						local skillSlot = 1
						if skillData.Key == "Q" then skillSlot = 1
						elseif skillData.Key == "E" then skillSlot = 2
						elseif skillData.Key == "R" then skillSlot = 3
						elseif skillData.Key == "F" then skillSlot = 4
						end

						useSkill:FireServer(skillSlot)
						print("📱 Mobile skill used:", skillData.Key, "-> Slot", skillSlot)

						-- Start cooldown
						MobileControls.StartCooldown(buttonData)
					end
				end
			else
				print("⏳ Skill on cooldown!")
			end
		end)

		skillButtons[skillData.Key] = buttonData
	end

	return skillButtons
end

-- ========================================
-- COOLDOWN MANAGEMENT
-- ========================================

function MobileControls.StartCooldown(skillButton)
	if skillButton.IsOnCooldown then return end

	skillButton.IsOnCooldown = true
	skillButton.CurrentCooldown = skillButton.MaxCooldown

	-- Animate cooldown
	local connection
	connection = RunService.RenderStepped:Connect(function(dt)
		skillButton.CurrentCooldown = skillButton.CurrentCooldown - dt

		if skillButton.CurrentCooldown <= 0 then
			-- Cooldown finished
			skillButton.IsOnCooldown = false
			skillButton.CooldownOverlay.Size = UDim2.new(1, 0, 0, 0)
			skillButton.CooldownText.Text = ""
			connection:Disconnect()
		else
			-- Update cooldown display
			local percent = skillButton.CurrentCooldown / skillButton.MaxCooldown
			skillButton.CooldownOverlay.Size = UDim2.new(1, 0, percent, 0)
			skillButton.CooldownText.Text = math.ceil(skillButton.CurrentCooldown)
		end
	end)
end

-- ========================================
-- INITIALIZE MOBILE CONTROLS
-- ========================================

function MobileControls.Initialize()
	if not MobileControls.IsMobile then
		print("⚠️ Not on mobile device, skipping mobile controls")
		return
	end

	print("📱 Initializing mobile controls...")

	-- Create UI
	local mobileUI = MobileControls.CreateUI()

	-- Create joystick
	local joystick = MobileControls.CreateJoystick(mobileUI)

	-- Create attack button
	local attackButton = MobileControls.CreateAttackButton(
		mobileUI,
		UDim2.new(1, -100, 1, -100),
		function()
			print("⚔️ Attack!")
			-- TODO: Fire attack event
		end
	)

	-- Create skill buttons
	local skillButtons = MobileControls.CreateSkillButtons(mobileUI)

	-- Bind skill buttons
	for key, skillButton in pairs(skillButtons) do
		skillButton.Button.MouseButton1Click:Connect(function()
			if not skillButton.IsOnCooldown then
				print("🔥 Skill", key, "activated!")
				MobileControls.StartCooldown(skillButton)

				-- TODO: Fire skill event
				-- RemoteEvents.UseSkill:FireServer(key)
			else
				print("⏱️ Skill on cooldown:", math.ceil(skillButton.CurrentCooldown), "seconds")
			end
		end)
	end

	-- Apply joystick movement to character
	RunService.RenderStepped:Connect(function()
		local character = player.Character
		if not character then return end

		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then return end

		-- Move character based on joystick direction
		if joystick.Direction.Magnitude > 0.1 then
			local camera = workspace.CurrentCamera
			local cameraCFrame = camera.CFrame

			-- Convert joystick direction to world space
			local moveDirection = Vector3.new(
				joystick.Direction.X,
				0,
				-joystick.Direction.Y -- Y is inverted
			)

			-- Rotate by camera direction
			moveDirection = cameraCFrame:VectorToWorldSpace(moveDirection)
			moveDirection = Vector3.new(moveDirection.X, 0, moveDirection.Z).Unit

			-- Move character
			humanoid:Move(moveDirection, false)
		end
	end)

	MobileControls.Enabled = true
	print("✅ Mobile controls initialized!")
end

-- ========================================
-- AUTO-INITIALIZE
-- ========================================

if MobileControls.IsMobile then
	-- Wait for character
	player.CharacterAdded:Connect(function()
		task.wait(1) -- Wait for character to load
		MobileControls.Initialize()
	end)

	-- Initialize if character already exists
	if player.Character then
		task.wait(1)
		MobileControls.Initialize()
	end
end

return MobileControls
