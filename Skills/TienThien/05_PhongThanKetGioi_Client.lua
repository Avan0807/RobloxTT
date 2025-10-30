-- ============================================
-- PHONG THẦN KẾT GIỚI - CLIENT
-- Tạo vòng xoáy gió đẩy lùi và giảm tốc 30% trong 3s
-- Key: Y
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = script.Parent

local skillRemote = ReplicatedStorage:WaitForChild("PhongThanKetGioiRemote")

local canCast = true
local cooldownTime = 8

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.Y and canCast then
		canCast = false

		local mouse = player:GetMouse()
		local targetPosition = mouse.Hit.Position

		skillRemote:FireServer(targetPosition)

		print("🌪️ PHONG THẦN KẾT GIỚI!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Phong Thần Kết Giới loaded! Press Y")
