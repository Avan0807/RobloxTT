-- ============================================
-- MA ẢNH DỊCH THÂN - CLIENT
-- Lướt 6m, để lại bóng tự nổ gây 150% dmg (iframe 0.3s)
-- Key: Shift
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("MaAnhDichThanRemote")

local canCast = true
local cooldownTime = 6

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.LeftShift and canCast then
		canCast = false

		local camera = workspace.CurrentCamera
		local direction = camera.CFrame.LookVector
		local oldPosition = humanoidRootPart.Position

		skillRemote:FireServer(oldPosition, direction)

		print("👤 MA ẢNH DỊCH THÂN!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Ma Ảnh Dịch Thân loaded! Press Shift")
