-- ============================================
-- VÔ GIAN MA VỰC - CLIENT (CÔNG PHÁP THƯỢNG PHẨM)
-- Mở domain 10m, địch bên trong bị giảm 50% regen và tầm nhìn
-- Key: C
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local skillRemote = ReplicatedStorage:WaitForChild("VoGianMaVucRemote")

local canCast = true
local cooldownTime = 30

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.C and canCast then
		canCast = false

		local mouse = player:GetMouse()
		local targetPosition = mouse.Hit.Position

		skillRemote:FireServer(targetPosition)

		print("⚫🌀 VÔ GIAN MA VỰC - DOMAIN EXPANSION!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Vô Gian Ma Vực loaded! Press C")
