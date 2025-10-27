-- ButtonManager.lua - Manages Button Interactions and Effects
-- Author: Claude Code
-- Description: Centralized button creation and management to prevent duplicate logic

local TweenService = game:GetService("TweenService")

local ButtonManager = {}

-- ============================================
-- BUTTON CREATION
-- ============================================

--[[
	Creates a styled button with automatic hover effects and click debouncing
	@param config table - Configuration:
		- Parent: Instance - Parent container
		- Name: string - Button name
		- Size: UDim2 - Button size
		- Position: UDim2 - Button position
		- Text: string - Button text
		- TextColor3: Color3 - Text color
		- BackgroundColor3: Color3 - Background color
		- Font: Enum.Font - Font
		- TextSize: number - Text size
		- TextScaled: boolean - Scale text
		- CornerRadius: number - Corner radius
		- OnClick: function - Click handler
		- Debounce: number - Debounce time in seconds (default: 0.5)
		- HoverEffect: boolean - Enable hover effect (default: true)
		- ClickEffect: boolean - Enable click effect (default: true)
]]
function ButtonManager.CreateButton(config)
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
	button.BorderSizePixel = 0
	button.Parent = config.Parent

	-- Corner radius
	if config.CornerRadius then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, config.CornerRadius)
		corner.Parent = button
	end

	-- Store original color
	local originalColor = config.BackgroundColor3 or Color3.fromRGB(50, 150, 200)
	local hoverColor = ButtonManager.LightenColor(originalColor, 1.2)
	local clickColor = ButtonManager.DarkenColor(originalColor, 0.8)

	-- Debounce setup
	local debounceTime = config.Debounce or 0.5
	local lastClickTime = 0

	-- Hover effect
	if config.HoverEffect ~= false then
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				BackgroundColor3 = hoverColor
			}):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				BackgroundColor3 = originalColor
			}):Play()
		end)
	end

	-- Click effect and handler
	if config.OnClick then
		button.MouseButton1Click:Connect(function()
			-- Debounce check
			local currentTime = tick()
			if currentTime - lastClickTime < debounceTime then
				return
			end
			lastClickTime = currentTime

			-- Click animation
			if config.ClickEffect ~= false then
				local originalSize = button.Size
				TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
					Size = originalSize * 0.95,
					BackgroundColor3 = clickColor
				}):Play()

				task.wait(0.1)

				TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
					Size = originalSize,
					BackgroundColor3 = originalColor
				}):Play()
			end

			-- Execute click handler
			config.OnClick()
		end)
	end

	return button
end

-- ============================================
-- SPECIAL BUTTON TYPES
-- ============================================

function ButtonManager.CreateCloseButton(parent, onClose)
	return ButtonManager.CreateButton({
		Parent = parent,
		Name = "CloseButton",
		Size = UDim2.new(0, 100, 0, 30),
		Position = UDim2.new(1, -110, 1, -40),
		Text = "Close",
		BackgroundColor3 = Color3.fromRGB(200, 50, 50),
		CornerRadius = 8,
		OnClick = onClose
	})
end

function ButtonManager.CreatePrimaryButton(parent, text, position, onClick)
	return ButtonManager.CreateButton({
		Parent = parent,
		Name = text .. "Button",
		Size = UDim2.new(0, 120, 0, 40),
		Position = position,
		Text = text,
		BackgroundColor3 = Color3.fromRGB(50, 150, 200),
		CornerRadius = 8,
		OnClick = onClick
	})
end

function ButtonManager.CreateSuccessButton(parent, text, position, onClick)
	return ButtonManager.CreateButton({
		Parent = parent,
		Name = text .. "Button",
		Size = UDim2.new(0, 120, 0, 40),
		Position = position,
		Text = text,
		BackgroundColor3 = Color3.fromRGB(50, 200, 50),
		CornerRadius = 8,
		OnClick = onClick
	})
end

function ButtonManager.CreateDangerButton(parent, text, position, onClick)
	return ButtonManager.CreateButton({
		Parent = parent,
		Name = text .. "Button",
		Size = UDim2.new(0, 120, 0, 40),
		Position = position,
		Text = text,
		BackgroundColor3 = Color3.fromRGB(200, 50, 50),
		CornerRadius = 8,
		OnClick = onClick
	})
end

function ButtonManager.CreateWarningButton(parent, text, position, onClick)
	return ButtonManager.CreateButton({
		Parent = parent,
		Name = text .. "Button",
		Size = UDim2.new(0, 120, 0, 40),
		Position = position,
		Text = text,
		BackgroundColor3 = Color3.fromRGB(200, 150, 50),
		CornerRadius = 8,
		OnClick = onClick
	})
end

-- ============================================
-- TAB BUTTONS
-- ============================================

function ButtonManager.CreateTabButton(parent, text, position, onSelect, isSelected)
	local button = ButtonManager.CreateButton({
		Parent = parent,
		Name = text .. "Tab",
		Size = UDim2.new(0, 180, 0, 35),
		Position = position,
		Text = text,
		BackgroundColor3 = isSelected and Color3.fromRGB(100, 150, 200) or Color3.fromRGB(60, 60, 60),
		CornerRadius = 6,
		OnClick = onSelect,
		HoverEffect = not isSelected
	})

	return button
end

function ButtonManager.UpdateTabButton(button, isSelected)
	if not button then return end

	TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		BackgroundColor3 = isSelected and Color3.fromRGB(100, 150, 200) or Color3.fromRGB(60, 60, 60)
	}):Play()
end

-- ============================================
-- COLOR UTILITIES
-- ============================================

function ButtonManager.LightenColor(color, factor)
	return Color3.fromRGB(
		math.min(255, color.R * 255 * factor),
		math.min(255, color.G * 255 * factor),
		math.min(255, color.B * 255 * factor)
	)
end

function ButtonManager.DarkenColor(color, factor)
	return Color3.fromRGB(
		math.max(0, color.R * 255 * factor),
		math.max(0, color.G * 255 * factor),
		math.max(0, color.B * 255 * factor)
	)
end

-- ============================================
-- BUTTON STATE MANAGEMENT
-- ============================================

function ButtonManager.EnableButton(button)
	if not button then return end

	button.Active = true
	TweenService:Create(button, TweenInfo.new(0.2), {
		BackgroundTransparency = 0,
		TextTransparency = 0
	}):Play()
end

function ButtonManager.DisableButton(button, reason)
	if not button then return end

	button.Active = false
	TweenService:Create(button, TweenInfo.new(0.2), {
		BackgroundTransparency = 0.5,
		TextTransparency = 0.5
	}):Play()

	if reason then
		-- Could show tooltip here
		print("Button disabled: " .. reason)
	end
end

-- ============================================
-- BUTTON GROUPS
-- ============================================

--[[
	Creates a group of mutually exclusive buttons (like tabs)
	@param parent Instance - Parent container
	@param buttons table - Array of button configs
	@param onSelect function(index) - Callback when button is selected
	@return table - Array of created buttons
]]
function ButtonManager.CreateButtonGroup(parent, buttons, onSelect)
	local createdButtons = {}
	local selectedIndex = 1

	for i, buttonConfig in ipairs(buttons) do
		local button = ButtonManager.CreateTabButton(
			parent,
			buttonConfig.Text,
			buttonConfig.Position,
			function()
				-- Update all buttons in group
				for j, btn in ipairs(createdButtons) do
					ButtonManager.UpdateTabButton(btn, j == i)
				end
				selectedIndex = i

				-- Call callback
				if onSelect then
					onSelect(i, buttonConfig)
				end
			end,
			i == 1 -- First button selected by default
		)

		table.insert(createdButtons, button)
	end

	return createdButtons
end

return ButtonManager
