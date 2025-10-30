-- ============================================
-- HỒN PHIÊN PHÓNG XUẤT - CLIENT
-- Thả 20 linh hồn ra tấn công diện rộng, sau 5s tự quay về hồi HP
-- Key: G
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent

local skillRemote = ReplicatedStorage:WaitForChild("HonPhienPhongXuatRemote")

local canCast = true
local cooldownTime = 12

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.G and canCast then
		canCast = false

		skillRemote:FireServer()

		print("👻💫 HỒN PHIÊN PHÓNG XUẤT!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Hồn Phiên Phóng Xuất loaded! Press G")
