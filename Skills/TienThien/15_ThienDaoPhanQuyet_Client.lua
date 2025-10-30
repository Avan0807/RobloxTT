-- ============================================
-- THIÊN ĐẠO PHÁN QUYẾT - CLIENT (ULTIMATE)
-- Triệu hồi cột ánh sáng 100% map nhỏ, địch trong vùng bị đánh 3 lần liên tiếp
-- Damage scale theo MP
-- Key: V (Ultimate)
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local skillRemote = ReplicatedStorage:WaitForChild("ThienDaoPhanQuyetRemote")

local canCast = true
local cooldownTime = 60

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.V and canCast then
		canCast = false

		local mouse = player:GetMouse()
		local targetPosition = mouse.Hit.Position

		skillRemote:FireServer(targetPosition)

		print("☀️☀️☀️ THIÊN ĐẠO PHÁN QUYẾT - ULTIMATE ACTIVATED!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ ULTIMATE: Thiên Đạo Phán Quyết loaded! Press V")
