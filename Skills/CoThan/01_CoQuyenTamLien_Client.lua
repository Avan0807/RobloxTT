-- ============================================
-- CỔ QUYỀN TAM LIÊN - CLIENT
-- 3 cú combo punch (light > heavy > ground slam). Hit thứ ba knockback nhẹ
-- Key: E (press 3 times)
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent

local skillRemote = ReplicatedStorage:WaitForChild("CoQuyenTamLienRemote")

local canCast = true
local cooldownTime = 3
local comboCount = 0
local comboWindow = 1.2

local function resetCombo()
	comboCount = 0
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.E and canCast then
		comboCount = comboCount + 1

		local camera = workspace.CurrentCamera
		local direction = camera.CFrame.LookVector

		skillRemote:FireServer(comboCount, direction)

		print("👊 CỔ QUYỀN TAM LIÊN - HIT " .. comboCount)

		if comboCount == 1 then
			canCast = false
			task.delay(comboWindow, function()
				if comboCount < 3 then
					resetCombo()
					canCast = true
				end
			end)
		elseif comboCount >= 3 then
			resetCombo()
			task.wait(cooldownTime)
			canCast = true
		end
	end
end)

print("✅ Cổ Quyền Tam Liên loaded! Press E x3")
