-- ============================================
-- TỬ LÔI GIÁNG - CLIENT
-- Gọi sét định vị trúng mục tiêu, delay 1s, cho phép địch dodge
-- Key: J
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local skillRemote = ReplicatedStorage:WaitForChild("TuLoiGiangRemote")

local canCast = true
local cooldownTime = 8

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.J and canCast then
		canCast = false

		local mouse = player:GetMouse()
		local targetPosition = mouse.Hit.Position

		skillRemote:FireServer(targetPosition)

		print("⚡ TỬ LÔI GIÁNG!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Tử Lôi Giáng loaded! Press J")
