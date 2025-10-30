-- ============================================
-- VÂN KIẾM HỒI TÔNG - CLIENT
-- Tung kiếm bay rồi recall về gây damage trên đường bay về (double-hit mechanic)
-- Key: H
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("VanKiemHoiTongRemote")

local canCast = true
local cooldownTime = 7

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.H and canCast then
		canCast = false

		local camera = workspace.CurrentCamera
		local direction = camera.CFrame.LookVector

		skillRemote:FireServer(direction)

		print("⚔️ VÂN KIẾM HỒI TÔNG!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Vân Kiếm Hồi Tông loaded! Press H")
