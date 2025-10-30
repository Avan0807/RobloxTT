-- ============================================
-- BÁT HOANG BẤT DIỆT - CLIENT (CÔNG PHÁP THƯỢNG PHẨM)
-- Trong 5s, miễn khống chế và không bị stagger, nhưng giảm 30% dmg gây ra
-- Key: C
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent

local skillRemote = ReplicatedStorage:WaitForChild("BatHoangBatDietRemote")

local canCast = true
local cooldownTime = 20

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.C and canCast then
		canCast = false

		skillRemote:FireServer()

		print("🛡️ BÁT HOANG BẤT DIỆT - UNSTOPPABLE!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Bát Hoang Bất Diệt loaded! Press C")
