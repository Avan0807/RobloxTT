-- ============================================
-- LÔI ẢNH DỊCH THÂN - CLIENT
-- Dịch chuyển 8m về hướng chuột, để lại bóng sét đánh ngược lại (iframe 0.4s)
-- Key: Shift + W
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("LoiAnhDichThanRemote")

local canCast = true
local cooldownTime = 5

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.LeftShift and canCast then
		canCast = false

		local camera = workspace.CurrentCamera
		local direction = camera.CFrame.LookVector
		local oldPosition = humanoidRootPart.Position

		-- Gửi lên server
		skillRemote:FireServer(oldPosition, direction)

		print("⚡ LÔI ẢNH DỊCH THÂN!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Lôi Ảnh Dịch Thân loaded! Press Shift")
