-- ============================================
-- THỦY LƯU TỐC BỘ - CLIENT
-- Buff tốc độ di chuyển 25%, jump cao hơn trong 5s
-- Key: G
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent

local skillRemote = ReplicatedStorage:WaitForChild("ThuyLuuTocBoRemote")

local canCast = true
local cooldownTime = 10

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.G and canCast then
		canCast = false

		skillRemote:FireServer()

		print("💧 THỦY LƯU TỐC BỘ!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Thủy Lưu Tốc Bộ loaded! Press G")
