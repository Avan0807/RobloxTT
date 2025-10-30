-- ============================================
-- HỎA LIỆT QUYỀN - CLIENT
-- Tung quyền lửa cận chiến, hit trúng tạo shock nổ 2m AOE
-- Key: T
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("HoaLietQuyenRemote")

local canCast = true
local cooldownTime = 4

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.T and canCast then
		canCast = false

		local camera = workspace.CurrentCamera
		local direction = camera.CFrame.LookVector

		skillRemote:FireServer(direction)

		print("🔥 HỎA LIỆT QUYỀN!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Hỏa Liệt Quyền loaded! Press T")
