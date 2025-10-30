-- ============================================
-- TAM LÔI KÍCH - CLIENT (CÔNG PHÁP THƯỢNG PHẨM)
-- Chuỗi combo 3 cú sét tốc độ cao, mỗi hit gây stagger mạnh, có thể cancel animation
-- Key: Q (press 3 times)
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("TamLoiKichRemote")

local canCast = true
local cooldownTime = 10
local comboCount = 0
local comboWindow = 1.5

local function resetCombo()
	comboCount = 0
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.Q and canCast then
		comboCount = comboCount + 1

		local camera = workspace.CurrentCamera
		local direction = camera.CFrame.LookVector

		skillRemote:FireServer(comboCount, direction)

		print("⚡⚡⚡ TAM LÔI KÍCH - HIT " .. comboCount)

		if comboCount == 1 then
			-- Start combo window
			canCast = false
			task.delay(comboWindow, function()
				if comboCount < 3 then
					resetCombo()
					canCast = true
				end
			end)
		elseif comboCount >= 3 then
			-- Combo complete
			resetCombo()
			task.wait(cooldownTime)
			canCast = true
		end
	end
end)

print("✅ Tam Lôi Kích loaded! Press Q x3")
