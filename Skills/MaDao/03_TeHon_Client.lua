-- ============================================
-- TẾ HỒN - CLIENT
-- Sacrifice 10% HP để hồi 20% năng lượng + tăng 15% speed 5s
-- Key: T
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent

local skillRemote = ReplicatedStorage:WaitForChild("TeHonRemote")

local canCast = true
local cooldownTime = 10

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.T and canCast then
		canCast = false

		skillRemote:FireServer()

		print("🩸 TẾ HỒN - BLOOD SACRIFICE!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Tế Hồn loaded! Press T")
