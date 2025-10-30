-- ============================================
-- CỔ ẢNH ĐOẠT HỒN - CLIENT (CÔNG PHÁP THƯỢNG PHẨM)
-- Lướt qua kẻ địch tốc độ cao (iframe 0.4s), đánh 2 hit chéo
-- Key: V
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("CoAnhDoatHonRemote")

local canCast = true
local cooldownTime = 15

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.V and canCast then
		canCast = false

		local mouse = player:GetMouse()
		local targetPosition = mouse.Hit.Position

		skillRemote:FireServer(targetPosition)

		print("⚔️ CỔ ẢNH ĐOẠT HỒN!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Cổ Ảnh Đoạt Hồn loaded! Press V")
