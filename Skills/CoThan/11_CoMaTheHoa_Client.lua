-- ============================================
-- CỔ MA THỂ HÓA - CLIENT (CÔNG PHÁP THƯỢNG PHẨM)
-- Biến thân 15s, đòn melee có range gấp đôi, +100% phản damage
-- Key: Z
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent

local skillRemote = ReplicatedStorage:WaitForChild("CoMaTheHoaRemote")

local canCast = true
local cooldownTime = 30

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.Z and canCast then
		canCast = false

		skillRemote:FireServer()

		print("👹 CỔ MA THỂ HÓA - DEMON TRANSFORMATION!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Cổ Ma Thể Hóa loaded! Press Z")
