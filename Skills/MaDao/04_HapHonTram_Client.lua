-- ============================================
-- HẤP HỒN TRẢM - CLIENT
-- Đòn cận chiến hút HP tương ứng 5% damage gây ra
-- Key: F
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("HapHonTramRemote")

local canCast = true
local cooldownTime = 3

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.F and canCast then
		canCast = false

		local camera = workspace.CurrentCamera
		local direction = camera.CFrame.LookVector

		skillRemote:FireServer(direction)

		print("💉 HẤP HỒN TRẢM!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Hấp Hồn Trảm loaded! Press F")
