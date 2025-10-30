-- ============================================
-- HƯ KHÔNG DỊCH CHUYỂN - CLIENT (CÔNG PHÁP THƯỢNG PHẨM)
-- Blink xuyên qua địch, gây AOE khi xuất hiện (iframe 0.5s)
-- Key: X
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("HuKhongDichChuyenRemote")

local canCast = true
local cooldownTime = 15

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.X and canCast then
		canCast = false

		local camera = workspace.CurrentCamera
		local direction = camera.CFrame.LookVector
		local oldPosition = humanoidRootPart.Position

		skillRemote:FireServer(oldPosition, direction)

		print("✨ HƯ KHÔNG DỊCH CHUYỂN!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Hư Không Dịch Chuyển loaded! Press X")
