-- ============================================
-- NGŨ HÀNH TRẢM - CLIENT
-- Phóng 5 tia nguyên tố hình quạt
-- Key: E
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("NguHanhTramRemote")

local canCast = true
local cooldownTime = 3

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.E and canCast then
		canCast = false

		local camera = workspace.CurrentCamera
		local direction = camera.CFrame.LookVector
		local origin = humanoidRootPart.Position

		-- Gửi lên server
		skillRemote:FireServer(origin, direction)

		print("⚡ NGŨ HÀNH TRẢM!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Ngũ Hành Trảm loaded! Press E")
