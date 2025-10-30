-- ============================================
-- BĂNG TỎA TRẢM - CLIENT
-- Đóng băng địch 1.2s, nếu địch bị hit thêm lần nữa sẽ vỡ băng gây 150% dmg
-- Key: R
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("BangToaTramRemote")

local canCast = true
local cooldownTime = 6

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.R and canCast then
		canCast = false

		local mouse = player:GetMouse()
		local targetPosition = mouse.Hit.Position

		skillRemote:FireServer(targetPosition)

		print("❄️ BĂNG TỎA TRẢM!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Băng Tỏa Trảm loaded! Press R")
