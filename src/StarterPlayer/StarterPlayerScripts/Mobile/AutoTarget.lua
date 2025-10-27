-- AutoTarget.lua - Auto-targeting System cho Mobile
-- Tự động tìm và target enemy gần nhất

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local AutoTarget = {}

local player = Players.LocalPlayer
local currentTarget = nil
local targetHighlight = nil

-- ========================================
-- CONFIG
-- ========================================

AutoTarget.Config = {
	Enabled = true,
	MaxDistance = 50, -- Max distance to target (studs)
	AutoAim = true, -- Auto rotate camera to target
	ShowHighlight = true, -- Show target highlight
	TargetKey = Enum.KeyCode.T, -- PC: Press T to toggle target
	UpdateInterval = 0.2 -- Update target every 0.2 seconds
}

-- ========================================
-- FIND NEAREST ENEMY
-- ========================================

function AutoTarget.FindNearestEnemy()
	local character = player.Character
	if not character then return nil end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return nil end

	local nearestEnemy = nil
	local shortestDistance = AutoTarget.Config.MaxDistance

	-- Search for enemies in workspace
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
			-- Check if it's an enemy (not self, not other players)
			local isEnemy = obj ~= character and not Players:GetPlayerFromCharacter(obj)

			if isEnemy then
				local enemyRoot = obj:FindFirstChild("HumanoidRootPart")
				if enemyRoot then
					local distance = (rootPart.Position - enemyRoot.Position).Magnitude

					if distance < shortestDistance then
						-- Check if alive
						local humanoid = obj:FindFirstChild("Humanoid")
						if humanoid and humanoid.Health > 0 then
							nearestEnemy = obj
							shortestDistance = distance
						end
					end
				end
			end
		end
	end

	return nearestEnemy
end

-- ========================================
-- SET TARGET
-- ========================================

function AutoTarget.SetTarget(target)
	-- Remove old highlight
	if targetHighlight then
		targetHighlight:Destroy()
		targetHighlight = nil
	end

	currentTarget = target

	-- Add highlight to new target
	if target and AutoTarget.Config.ShowHighlight then
		targetHighlight = Instance.new("Highlight")
		targetHighlight.Adornee = target
		targetHighlight.FillColor = Color3.fromRGB(255, 100, 100)
		targetHighlight.FillTransparency = 0.5
		targetHighlight.OutlineColor = Color3.fromRGB(255, 0, 0)
		targetHighlight.OutlineTransparency = 0
		targetHighlight.Parent = target
	end
end

-- ========================================
-- GET CURRENT TARGET
-- ========================================

function AutoTarget.GetTarget()
	-- Check if target still valid
	if currentTarget then
		local humanoid = currentTarget:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health <= 0 or not currentTarget.Parent then
			-- Target dead or destroyed, clear it
			AutoTarget.SetTarget(nil)
			return nil
		end
	end

	return currentTarget
end

-- ========================================
-- AUTO AIM CAMERA
-- ========================================

function AutoTarget.UpdateAutoAim()
	if not AutoTarget.Config.AutoAim then return end

	local target = AutoTarget.GetTarget()
	if not target then return end

	local character = player.Character
	if not character then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local targetRoot = target:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end

	-- Calculate direction to target
	local direction = (targetRoot.Position - rootPart.Position).Unit

	-- Rotate character to face target
	rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + direction)
end

-- ========================================
-- UPDATE TARGET (Auto-find nearest)
-- ========================================

function AutoTarget.UpdateTarget()
	-- If no target or target too far, find new one
	local target = AutoTarget.GetTarget()

	if not target then
		-- Find nearest
		local nearest = AutoTarget.FindNearestEnemy()
		if nearest then
			AutoTarget.SetTarget(nearest)
			print("🎯 Auto-targeted:", nearest.Name)
		end
	else
		-- Check if still in range
		local character = player.Character
		if character then
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			local targetRoot = target:FindFirstChild("HumanoidRootPart")

			if rootPart and targetRoot then
				local distance = (rootPart.Position - targetRoot.Position).Magnitude

				if distance > AutoTarget.Config.MaxDistance then
					-- Target too far, find new one
					print("⚠️ Target too far, searching for new target...")
					AutoTarget.SetTarget(nil)

					local nearest = AutoTarget.FindNearestEnemy()
					if nearest then
						AutoTarget.SetTarget(nearest)
					end
				end
			end
		end
	end
end

-- ========================================
-- TOGGLE TARGET (For PC)
-- ========================================

function AutoTarget.ToggleTarget()
	local target = AutoTarget.GetTarget()

	if target then
		-- Clear current target
		AutoTarget.SetTarget(nil)
		print("❌ Target cleared")
	else
		-- Find new target
		local nearest = AutoTarget.FindNearestEnemy()
		if nearest then
			AutoTarget.SetTarget(nearest)
			print("🎯 Targeted:", nearest.Name)
		else
			print("⚠️ No enemies in range")
		end
	end
end

-- ========================================
-- MANUAL TARGET (Click on enemy)
-- ========================================

function AutoTarget.TargetClick(target)
	if target and target:FindFirstChild("Humanoid") then
		AutoTarget.SetTarget(target)
		print("🎯 Manually targeted:", target.Name)
	end
end

-- ========================================
-- GET TARGET POSITION
-- ========================================

function AutoTarget.GetTargetPosition()
	local target = AutoTarget.GetTarget()
	if target then
		local targetRoot = target:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			return targetRoot.Position
		end
	end
	return nil
end

-- ========================================
-- INITIALIZE
-- ========================================

function AutoTarget.Initialize()
	print("🎯 AutoTarget system initialized")

	-- Auto-update target periodically
	task.spawn(function()
		while true do
			task.wait(AutoTarget.Config.UpdateInterval)

			if AutoTarget.Config.Enabled then
				AutoTarget.UpdateTarget()
			end
		end
	end)

	-- Auto-aim update (every frame)
	RunService.RenderStepped:Connect(function()
		if AutoTarget.Config.Enabled and AutoTarget.Config.AutoAim then
			AutoTarget.UpdateAutoAim()
		end
	end)

	-- PC: Toggle target with T key
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.KeyCode == AutoTarget.Config.TargetKey then
			AutoTarget.ToggleTarget()
		end
	end)

	-- Mobile: Click on enemy to target
	local mouse = player:GetMouse()
	mouse.Button1Down:Connect(function()
		local target = mouse.Target
		if target and target.Parent then
			local model = target.Parent
			if model:FindFirstChild("Humanoid") then
				-- Check if enemy
				if model ~= player.Character and not Players:GetPlayerFromCharacter(model) then
					AutoTarget.TargetClick(model)
				end
			end
		end
	end)
end

-- Auto-initialize
AutoTarget.Initialize()

return AutoTarget
