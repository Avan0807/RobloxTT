-- ============================================
-- TỬ ẢNH HOÁN THÂN - CLIENT
-- Đổi chỗ với bóng ma cách xa tối đa 12m (iframe 0.4s)
-- Key: L
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("TuAnhHoanThanRemote")

local canCast = true
local cooldownTime = 10

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.L and canCast then
		canCast = false

		local mouse = player:GetMouse()
		local targetPosition = mouse.Hit.Position

		-- Limit to 12m
		local direction = (targetPosition - humanoidRootPart.Position).Unit
		local distance = math.min((targetPosition - humanoidRootPart.Position).Magnitude, 12)
		local finalTarget = humanoidRootPart.Position + (direction * distance)

		skillRemote:FireServer(finalTarget)

		print("🌀 TỬ ẢNH HOÁN THÂN!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Tử Ảnh Hoán Thân loaded! Press L")
