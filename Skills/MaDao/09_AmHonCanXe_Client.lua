-- ============================================
-- ÂM HỒN CẮN XÉ - CLIENT
-- Combo 2 hit: lần 1 gây damage thường, lần 2 hút linh hồn địch (stun 0.5s)
-- Key: K (press twice)
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("AmHonCanXeRemote")

local canCast = true
local cooldownTime = 7
local comboCount = 0
local comboWindow = 1.5

local function resetCombo()
	comboCount = 0
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.K and canCast then
		comboCount = comboCount + 1

		local camera = workspace.CurrentCamera
		local direction = camera.CFrame.LookVector

		skillRemote:FireServer(comboCount, direction)

		print("👻 ÂM HỒN CẮN XÉ - HIT " .. comboCount)

		if comboCount == 1 then
			canCast = false
			task.delay(comboWindow, function()
				if comboCount < 2 then
					resetCombo()
					canCast = true
				end
			end)
		elseif comboCount >= 2 then
			resetCombo()
			task.wait(cooldownTime)
			canCast = true
		end
	end
end)

print("✅ Âm Hồn Cắn Xé loaded! Press K x2")
