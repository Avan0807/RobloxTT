-- ============================================
-- MA TÂM GIẢI PHÓNG - CLIENT
-- Buff bản thân: +25% lifesteal trong 8s
-- Key: J
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent

local skillRemote = ReplicatedStorage:WaitForChild("MaTamGiaiPhongRemote")

local canCast = true
local cooldownTime = 12

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.J and canCast then
		canCast = false

		skillRemote:FireServer()

		print("🩸 MA TÂM GIẢI PHÓNG - LIFESTEAL ACTIVATED!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Ma Tâm Giải Phóng loaded! Press J")
