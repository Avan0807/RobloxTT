-- ============================================
-- DIỆT HỒN LIÊN KÍCH - CLIENT (CÔNG PHÁP THƯỢNG PHẨM)
-- Combo 5 hit cực nhanh, mỗi hit +10% lifesteal, kết thúc gây 400% dmg
-- Key: X (auto 5-hit combo)
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("DietHonLienKichRemote")

local canCast = true
local cooldownTime = 18

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.X and canCast then
		canCast = false

		local camera = workspace.CurrentCamera
		local direction = camera.CFrame.LookVector

		skillRemote:FireServer(direction)

		print("👻⚔️⚔️⚔️⚔️⚔️ DIỆT HỒN LIÊN KÍCH!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Diệt Hồn Liên Kích loaded! Press X")
