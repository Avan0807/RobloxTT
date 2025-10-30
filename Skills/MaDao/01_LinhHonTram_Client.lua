-- ============================================
-- LINH HỒN TRẢM - CLIENT
-- Slash linh hồn, gây 200% Soul Dmg, xuyên 25% giáp
-- Key: E
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("LinhHonTramRemote")

local canCast = true
local cooldownTime = 4

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.E and canCast then
		canCast = false

		local camera = workspace.CurrentCamera
		local direction = camera.CFrame.LookVector

		skillRemote:FireServer(direction)

		print("👻 LINH HỒN TRẢM!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Linh Hồn Trảm loaded! Press E")
