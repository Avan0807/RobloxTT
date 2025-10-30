-- ============================================
-- HỦY DIỆT LINH THỂ - CLIENT (ULTIMATE)
-- Hấp toàn bộ linh hồn quanh 15m, gây sát thương theo tổng linh hồn đã hút
-- Key: V (hold to absorb, release to detonate)
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent

local skillRemote = ReplicatedStorage:WaitForChild("HuyDietLinhTheRemote")

local canCast = true
local cooldownTime = 45
local isAbsorbing = false
local absorbTime = 0
local maxAbsorbTime = 3

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.V and canCast and not isAbsorbing then
		isAbsorbing = true
		canCast = false
		absorbTime = 0

		-- Start absorbing
		skillRemote:FireServer("start_absorb")
		print("💀 HỦY DIỆT LINH THỂ - ABSORBING SOULS...")

		-- Count absorb time
		local startTime = tick()
		local heartbeat
		heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
			if not isAbsorbing then
				heartbeat:Disconnect()
				return
			end

			absorbTime = tick() - startTime
			absorbTime = math.min(absorbTime, maxAbsorbTime)

			if math.floor(absorbTime * 10) % 5 == 0 then
				print("💀 Absorbing: " .. math.floor(absorbTime * 100 / maxAbsorbTime) .. "%")
			end
		end)
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.V and isAbsorbing then
		isAbsorbing = false

		local absorbPercent = absorbTime / maxAbsorbTime

		-- Release souls
		skillRemote:FireServer("release", absorbPercent)

		print("💀💥 HỦY DIỆT LINH THỂ - SOULS DETONATED! Power: " .. math.floor(absorbPercent * 100) .. "%")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ ULTIMATE: Hủy Diệt Linh Thể loaded! Hold V")
