-- ============================================
-- THÁI HƯ PHONG GIỚI - CLIENT (CÔNG PHÁP THƯỢNG PHẨM)
-- Tạo domain 10m giảm 50% cooldown cho bản thân, tăng cast speed 30% (10s)
-- Key: Z
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent

local skillRemote = ReplicatedStorage:WaitForChild("ThaiHuPhongGioiRemote")

local canCast = true
local cooldownTime = 30

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.Z and canCast then
		canCast = false

		skillRemote:FireServer()

		print("🌟 THÁI HƯ PHONG GIỚI - DOMAIN ACTIVATED!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Thái Hư Phong Giới loaded! Press Z")
