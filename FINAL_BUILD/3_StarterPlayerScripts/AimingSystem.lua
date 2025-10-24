-- AimingSystem.lua - PC Mouse + Mobile Touch Aiming
-- Copy vào StarterPlayerScripts/AimingSystem (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- ========================================
-- VARIABLES
-- ========================================

local AimingSystem = {
	CurrentAimDirection = Vector3.new(0, 0, -1), -- Default forward
	AimMode = "Mouse", -- "Mouse" or "Touch"
	TouchStartPos = nil,
	IsTouching = false,
	AimIndicator = nil,
	MaxAimDistance = 50 -- Max range for aim indicator
}

-- ========================================
-- CREATE AIM INDICATOR UI
-- ========================================

local function CreateAimIndicator()
	-- 3D aim indicator in world
	local indicator = Instance.new("Part")
	indicator.Name = "AimIndicator"
	indicator.Size = Vector3.new(2, 0.5, 2)
	indicator.Color = Color3.fromRGB(255, 100, 100)
	indicator.Material = Enum.Material.Neon
	indicator.Transparency = 0.5
	indicator.CanCollide = false
	indicator.Anchored = true
	indicator.Shape = Enum.PartType.Cylinder
	indicator.Parent = workspace

	-- Arrow mesh
	local arrow = Instance.new("SpecialMesh")
	arrow.MeshType = Enum.MeshType.FileMesh
	arrow.MeshId = "rbxassetid://6847078101" -- Arrow mesh
	arrow.Scale = Vector3.new(1, 1, 1)
	arrow.Parent = indicator

	AimingSystem.AimIndicator = indicator
end

-- ========================================
-- UPDATE AIM (PC - MOUSE)
-- ========================================

local function UpdateMouseAim()
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local hrp = character.HumanoidRootPart
	local mouse = player:GetMouse()

	-- Get mouse position in 3D world
	local mouseRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	-- Raycast to ground/objects
	local rayResult = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 1000, raycastParams)

	local aimTarget
	if rayResult then
		aimTarget = rayResult.Position
	else
		-- Default to forward
		aimTarget = hrp.Position + (hrp.CFrame.LookVector * 50)
	end

	-- Calculate direction (ignore Y axis for horizontal aiming)
	local direction = (aimTarget - hrp.Position)
	direction = Vector3.new(direction.X, 0, direction.Z).Unit

	AimingSystem.CurrentAimDirection = direction

	-- Update indicator position
	if AimingSystem.AimIndicator then
		local indicatorPos = hrp.Position + (direction * 10) + Vector3.new(0, 2, 0)
		AimingSystem.AimIndicator.CFrame = CFrame.new(indicatorPos, indicatorPos + direction) * CFrame.Angles(0, 0, math.rad(90))
	end
end

-- ========================================
-- UPDATE AIM (MOBILE - TOUCH)
-- ========================================

local function UpdateTouchAim()
	if not AimingSystem.IsTouching or not AimingSystem.TouchStartPos then
		-- Use character forward direction
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			AimingSystem.CurrentAimDirection = character.HumanoidRootPart.CFrame.LookVector
		end
		return
	end

	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local hrp = character.HumanoidRootPart

	-- Touch aim direction (from touch start to current touch)
	local touchPos = UserInputService:GetMouseLocation()
	local deltaX = touchPos.X - AimingSystem.TouchStartPos.X
	local deltaZ = touchPos.Y - AimingSystem.TouchStartPos.Y

	if deltaX == 0 and deltaZ == 0 then
		-- No movement, use forward
		AimingSystem.CurrentAimDirection = hrp.CFrame.LookVector
		return
	end

	-- Convert screen delta to world direction
	local direction = Vector3.new(deltaX, 0, -deltaZ).Unit

	AimingSystem.CurrentAimDirection = direction

	-- Update indicator
	if AimingSystem.AimIndicator then
		local indicatorPos = hrp.Position + (direction * 10) + Vector3.new(0, 2, 0)
		AimingSystem.AimIndicator.CFrame = CFrame.new(indicatorPos, indicatorPos + direction) * CFrame.Angles(0, 0, math.rad(90))
	end
end

-- ========================================
-- DETECT INPUT TYPE
-- ========================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.UserInputType == Enum.UserInputType.Touch then
		AimingSystem.AimMode = "Touch"
		AimingSystem.IsTouching = true
		AimingSystem.TouchStartPos = input.Position
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.Touch then
		AimingSystem.IsTouching = false
		AimingSystem.TouchStartPos = nil
	end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		AimingSystem.AimMode = "Mouse"
	end
end)

-- ========================================
-- MAIN UPDATE LOOP
-- ========================================

RunService.RenderStepped:Connect(function()
	if AimingSystem.AimMode == "Mouse" then
		UpdateMouseAim()
	elseif AimingSystem.AimMode == "Touch" then
		UpdateTouchAim()
	end
end)

-- ========================================
-- GET CURRENT AIM
-- ========================================

function AimingSystem.GetAimDirection()
	return AimingSystem.CurrentAimDirection
end

function AimingSystem.GetAimPosition(range)
	range = range or 50
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return Vector3.new(0, 0, 0)
	end

	local hrp = character.HumanoidRootPart
	return hrp.Position + (AimingSystem.CurrentAimDirection * range)
end

-- ========================================
-- TOGGLE AIM INDICATOR
-- ========================================

function AimingSystem.ShowIndicator(show)
	if AimingSystem.AimIndicator then
		AimingSystem.AimIndicator.Transparency = show and 0.5 or 1
	end
end

-- ========================================
-- INITIALIZE
-- ========================================

CreateAimIndicator()
AimingSystem.ShowIndicator(true)

-- Make accessible globally
_G.AimingSystem = AimingSystem

print("✅ AimingSystem loaded (PC + Mobile)")
return AimingSystem
