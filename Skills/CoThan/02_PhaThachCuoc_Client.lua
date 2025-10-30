-- ============================================
-- PHÁ THẠCH CƯỚC - CLIENT
-- Đá mạnh ra trước, nếu trúng tường/địa hình → gây thêm 200% damage
-- Key: R
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("PhaThachCuocRemote")

local canCast = true
local cooldownTime = 4

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.R and canCast then
		canCast = false

		local camera = workspace.CurrentCamera
		local direction = camera.CFrame.LookVector

		skillRemote:FireServer(direction)

		print("🦵 PHÁ THẠCH CƯỚC!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Phá Thạch Cước loaded! Press R")
