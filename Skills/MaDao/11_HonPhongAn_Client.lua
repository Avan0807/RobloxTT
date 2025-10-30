-- ============================================
-- HỒN PHONG ẤN - CLIENT (CÔNG PHÁP THƯỢNG PHẨM)
-- Đánh dấu linh hồn, nếu địch chết trong 6s → bị giam linh hồn, không thể hồi sinh
-- Key: Z
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local skillRemote = ReplicatedStorage:WaitForChild("HonPhongAnRemote")

local canCast = true
local cooldownTime = 20

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.Z and canCast then
		canCast = false

		local mouse = player:GetMouse()
		local target = mouse.Target

		-- Try to find target character
		local targetChar = target and target.Parent
		if targetChar and targetChar:FindFirstChild("Humanoid") then
			skillRemote:FireServer(targetChar)
			print("🔒 HỒN PHONG ẤN - SOUL SEALED!")
		else
			print("⚠️ No valid target!")
			canCast = true
			return
		end

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Hồn Phong Ấn loaded! Press Z (target enemy)")
