-- ============================================
-- OAN HỒN ĐUỔI BÓNG - CLIENT
-- Triệu hồi 3 hồn bóng đuổi địch 4s (tracking nhẹ)
-- Key: R
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local skillRemote = ReplicatedStorage:WaitForChild("OanHonDuoiBongRemote")

local canCast = true
local cooldownTime = 8

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.R and canCast then
		canCast = false

		local mouse = player:GetMouse()
		local targetPosition = mouse.Hit.Position

		skillRemote:FireServer(targetPosition)

		print("👻👻👻 OAN HỒN ĐUỔI BÓNG!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Oan Hồn Đuổi Bóng loaded! Press R")
