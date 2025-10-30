-- ============================================
-- TÀN HỒN KẾT GIỚI - CLIENT
-- Vùng 8m hút HP/giây từ địch (địch có thể dodge ra ngoài)
-- Key: H
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local skillRemote = ReplicatedStorage:WaitForChild("TanHonKetGioiRemote")

local canCast = true
local cooldownTime = 15

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.H and canCast then
		canCast = false

		local mouse = player:GetMouse()
		local targetPosition = mouse.Hit.Position

		skillRemote:FireServer(targetPosition)

		print("⚫ TÀN HỒN KẾT GIỚI!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Tàn Hồn Kết Giới loaded! Press H")
