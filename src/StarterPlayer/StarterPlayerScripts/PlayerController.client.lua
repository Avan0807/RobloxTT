-- PlayerController.lua - Main Player Input Controller
-- Handles keyboard/mouse input for PC and binds to skills

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local PlayerController = {}

-- ========================================
-- SETTINGS
-- ========================================

PlayerController.Settings = {
	-- Skill keybinds
	SkillKeys = {
		Skill1 = Enum.KeyCode.Q,
		Skill2 = Enum.KeyCode.E,
		Skill3 = Enum.KeyCode.R,
		Skill4 = Enum.KeyCode.F,
	},

	-- Other keybinds
	OtherKeys = {
		Dash = Enum.KeyCode.LeftShift,
		Target = Enum.KeyCode.T,
		Inventory = Enum.KeyCode.I,
		Shop = Enum.KeyCode.P,
		Stats = Enum.KeyCode.C,
	},

	-- Dash settings
	DashDistance = 20,
	DashCooldown = 3,
}

-- Track cooldowns
PlayerController.Cooldowns = {
	Skills = {},
	Dash = 0,
}

-- ========================================
-- USE SKILL
-- ========================================

function PlayerController.UseSkill(skillSlot)
	-- Check cooldown
	local currentTime = tick()
	local lastUse = PlayerController.Cooldowns.Skills[skillSlot] or 0

	if currentTime - lastUse < 1 then
		print("⏳ Skill on cooldown!")
		return
	end

	print("🔥 Using skill:", skillSlot)

	-- Fire remote event to server
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if remoteEvents then
		local useSkill = remoteEvents:FindFirstChild("UseSkill")
		if useSkill then
			useSkill:FireServer(skillSlot)
			PlayerController.Cooldowns.Skills[skillSlot] = currentTime
		end
	end
end

-- ========================================
-- DASH
-- ========================================

function PlayerController.Dash()
	local currentTime = tick()

	-- Check cooldown
	if currentTime - PlayerController.Cooldowns.Dash < PlayerController.Settings.DashCooldown then
		print("⏳ Dash on cooldown!")
		return
	end

	if not character or not character.PrimaryPart then return end

	-- Get movement direction
	local moveDirection = humanoid.MoveDirection
	if moveDirection.Magnitude == 0 then
		-- Dash forward if not moving
		moveDirection = character.PrimaryPart.CFrame.LookVector
	end

	-- Dash
	local rootPart = character.PrimaryPart
	local dashVelocity = Instance.new("BodyVelocity")
	dashVelocity.MaxForce = Vector3.new(100000, 0, 100000)
	dashVelocity.Velocity = moveDirection * PlayerController.Settings.DashDistance * 5
	dashVelocity.Parent = rootPart

	-- Visual effect
	local trail = Instance.new("Trail")
	local attachment0 = Instance.new("Attachment")
	local attachment1 = Instance.new("Attachment")
	attachment0.Parent = rootPart
	attachment1.Parent = rootPart
	attachment1.Position = Vector3.new(0, -2, 0)
	trail.Attachment0 = attachment0
	trail.Attachment1 = attachment1
	trail.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255))
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail.Lifetime = 0.5
	trail.Parent = rootPart

	-- Clean up
	task.wait(0.2)
	dashVelocity:Destroy()

	task.wait(0.5)
	trail.Enabled = false
	task.wait(0.5)
	trail:Destroy()
	attachment0:Destroy()
	attachment1:Destroy()

	PlayerController.Cooldowns.Dash = currentTime
	print("💨 Dash!")
end

-- ========================================
-- TOGGLE INVENTORY
-- ========================================

function PlayerController.ToggleInventory()
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if not remoteEvents then return end

	local getInventory = remoteEvents:FindFirstChild("GetInventory")
	if getInventory then
		getInventory:FireServer()
	end
end

-- ========================================
-- TOGGLE SHOP
-- ========================================

function PlayerController.ToggleShop()
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if not remoteEvents then return end

	local getShop = remoteEvents:FindFirstChild("GetShop")
	if getShop then
		getShop:FireServer()
	end
end

-- ========================================
-- SETUP INPUT
-- ========================================

function PlayerController.SetupInput()
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		-- Ignore if typing in chat or other UI
		if gameProcessedEvent then return end

		-- Skills
		if input.KeyCode == PlayerController.Settings.SkillKeys.Skill1 then
			PlayerController.UseSkill(1)

		elseif input.KeyCode == PlayerController.Settings.SkillKeys.Skill2 then
			PlayerController.UseSkill(2)

		elseif input.KeyCode == PlayerController.Settings.SkillKeys.Skill3 then
			PlayerController.UseSkill(3)

		elseif input.KeyCode == PlayerController.Settings.SkillKeys.Skill4 then
			PlayerController.UseSkill(4)

		-- Dash
		elseif input.KeyCode == PlayerController.Settings.OtherKeys.Dash then
			PlayerController.Dash()

		-- Inventory
		elseif input.KeyCode == PlayerController.Settings.OtherKeys.Inventory then
			PlayerController.ToggleInventory()

		-- Shop
		elseif input.KeyCode == PlayerController.Settings.OtherKeys.Shop then
			PlayerController.ToggleShop()

		end
	end)

	print("✅ PlayerController: Input setup complete!")
	print("🎮 Controls:")
	print("  Q/E/R/F - Skills")
	print("  Shift - Dash")
	print("  I - Inventory")
	print("  P - Shop")
end

-- ========================================
-- INITIALIZE
-- ========================================

-- Wait for character to load
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
end)

-- Setup input
PlayerController.SetupInput()

print("🎮 PlayerController initialized!")

return PlayerController
