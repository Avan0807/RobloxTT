-- ============================================
-- VẠN MA HÓA THÂN - CLIENT (ULTIMATE)
-- Biến hình Ma Thần 10s, mỗi cú đánh phóng ra ảo ảnh gây 60% dmg
-- có iframe 0.6s khi biến hình
-- Key: B
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent

local skillRemote = ReplicatedStorage:WaitForChild("VanMaHoaThanRemote")

local canCast = true
local cooldownTime = 40

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.B and canCast then
		canCast = false

		skillRemote:FireServer()

		print("👹 VẠN MA HÓA THÂN - DEMON GOD TRANSFORMATION!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ ULTIMATE: Vạn Ma Hóa Thân loaded! Press B")
