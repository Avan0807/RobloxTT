-- ============================================
-- THIÊN QUANG PHẢN KÍCH - CLIENT
-- Parry phép: nếu đỡ được skill địch → phản lại 200% sát thương
-- Key: F (hold to activate)
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent

local skillRemote = ReplicatedStorage:WaitForChild("ThienQuangPhanKichRemote")

local canCast = true
local cooldownTime = 12
local isParrying = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.F and canCast and not isParrying then
		canCast = false
		isParrying = true

		skillRemote:FireServer(true)

		print("🛡️ THIÊN QUANG PHẢN KÍCH - PARRY ACTIVE!")

		-- Parry window: 0.6s
		task.wait(0.6)
		isParrying = false
		skillRemote:FireServer(false)

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Thiên Quang Phản Kích loaded! Press F")
