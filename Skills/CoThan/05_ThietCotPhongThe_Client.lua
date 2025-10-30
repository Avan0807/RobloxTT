-- ============================================
-- THIẾT CỐT PHÒNG THỂ - CLIENT
-- Giảm 50% sát thương trong 2s, cho phép counter
-- Key: F
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent

local skillRemote = ReplicatedStorage:WaitForChild("ThietCotPhongTheRemote")

local canCast = true
local cooldownTime = 10
local isDefending = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.F and canCast and not isDefending then
		canCast = false
		isDefending = true

		skillRemote:FireServer(true)
		print("🛡️ THIẾT CỐT PHÒNG THỂ - DEFENDING!")

		-- Defense lasts 2s
		task.wait(2)
		isDefending = false
		skillRemote:FireServer(false)

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Thiết Cốt Phòng Thể loaded! Press F")
