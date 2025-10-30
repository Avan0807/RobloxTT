-- ============================================
-- KIM CANG CHƯỞNG - CLIENT
-- Charge 0.5s, tạo sóng chấn xuyên qua địch, knockdown
-- Key: T (hold 0.5s)
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent

local skillRemote = ReplicatedStorage:WaitForChild("KimCangChuongRemote")

local canCast = true
local cooldownTime = 6
local isCharging = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.T and canCast and not isCharging then
		isCharging = true
		canCast = false

		-- Start charging
		skillRemote:FireServer("start_charge")
		print("💎 KIM CANG CHƯỞNG - CHARGING...")

		-- Auto release after 0.5s
		task.wait(0.5)

		if isCharging then
			isCharging = false

			local camera = workspace.CurrentCamera
			local direction = camera.CFrame.LookVector

			skillRemote:FireServer("release", direction)
			print("💎💥 KIM CANG CHƯỞNG - RELEASED!")
		end

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Kim Cang Chưởng loaded! Hold T")
