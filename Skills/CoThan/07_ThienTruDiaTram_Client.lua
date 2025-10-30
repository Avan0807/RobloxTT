-- ============================================
-- THIÊN TRỤ ĐỊA TRẢM - CLIENT
-- Nhảy lên đập đất, tạo shockwave 5m
-- Key: H
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent

local skillRemote = ReplicatedStorage:WaitForChild("ThienTruDiaTramRemote")

local canCast = true
local cooldownTime = 8

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.H and canCast then
		canCast = false

		skillRemote:FireServer()

		print("🌍 THIÊN TRỤ ĐỊA TRẢM!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Thiên Trụ Địa Trảm loaded! Press H")
