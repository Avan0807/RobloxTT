-- ============================================
-- LONG HỐNG QUYỀN - CLIENT
-- Hét ra khí xung chặn đòn địch, gây stagger nhẹ
-- Key: G
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent

local skillRemote = ReplicatedStorage:WaitForChild("LongHongQuyenRemote")

local canCast = true
local cooldownTime = 7

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.G and canCast then
		canCast = false

		skillRemote:FireServer()

		print("🐉 LONG HỐNG QUYỀN!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Long Hống Quyền loaded! Press G")
