-- ============================================
-- TRẢM PHONG BỘ - CLIENT
-- Dash 10m (iframe 0.3s), đòn tiếp theo gây 1.5x dmg
-- Key: Shift
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("TramPhongBoRemote")

local canCast = true
local cooldownTime = 5

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.LeftShift and canCast then
		canCast = false

		local camera = workspace.CurrentCamera
		local direction = camera.CFrame.LookVector

		skillRemote:FireServer(direction)

		print("💨 TRẢM PHONG BỘ - DASH!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Trảm Phong Bộ loaded! Press Shift")
