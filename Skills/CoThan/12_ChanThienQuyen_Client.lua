-- ============================================
-- CHẤN THIÊN QUYỀN - CLIENT (CÔNG PHÁP THƯỢNG PHẨM)
-- Ultimate charge punch, tạo shockwave xuyên 40m, knockup mọi địch
-- Key: X (hold to charge)
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent

local skillRemote = ReplicatedStorage:WaitForChild("ChanThienQuyenRemote")

local canCast = true
local cooldownTime = 25
local isCharging = false
local chargeTime = 0
local maxChargeTime = 3

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.X and canCast and not isCharging then
		isCharging = true
		canCast = false
		chargeTime = 0

		-- Start charging
		skillRemote:FireServer("start_charge")
		print("👊 CHẤN THIÊN QUYỀN - CHARGING...")

		-- Count charge time
		local startTime = tick()
		local heartbeat
		heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
			if not isCharging then
				heartbeat:Disconnect()
				return
			end

			chargeTime = tick() - startTime
			chargeTime = math.min(chargeTime, maxChargeTime)

			-- Visual feedback
			if math.floor(chargeTime) ~= math.floor(chargeTime - 0.016) then
				print("⚡ Charge: " .. math.floor(chargeTime * 100 / maxChargeTime) .. "%")
			end
		end)
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.X and isCharging then
		isCharging = false

		local camera = workspace.CurrentCamera
		local direction = camera.CFrame.LookVector
		local chargePercent = chargeTime / maxChargeTime

		-- Release punch
		skillRemote:FireServer("release", direction, chargePercent)

		print("👊💥 CHẤN THIÊN QUYỀN RELEASED! Charge: " .. math.floor(chargePercent * 100) .. "%")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Chấn Thiên Quyền loaded! Hold X to charge")
