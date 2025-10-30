-- ============================================
-- NGŨ HÀNH HỢP NHẤT - CLIENT (CÔNG PHÁP THƯỢNG PHẨM)
-- Biến 5 nguyên tố thành cầu năng lượng, nổ theo hướng charge (burst 400% dmg)
-- Key: C (hold to charge, release to fire)
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("NguHanhHopNhatRemote")

local canCast = true
local cooldownTime = 20
local isCharging = false
local chargeTime = 0
local maxChargeTime = 2

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.C and canCast and not isCharging then
		isCharging = true
		chargeTime = 0

		-- Start charging
		skillRemote:FireServer("start_charge")

		print("🌟 NGŨ HÀNH HỢP NHẤT - CHARGING...")

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
		end)
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.C and isCharging then
		isCharging = false
		canCast = false

		local camera = workspace.CurrentCamera
		local direction = camera.CFrame.LookVector

		-- Release charge
		local chargePercent = chargeTime / maxChargeTime
		skillRemote:FireServer("release", direction, chargePercent)

		print("🌟💥 NGŨ HÀNH HỢP NHẤT - RELEASED! Charge: " .. math.floor(chargePercent * 100) .. "%")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ Ngũ Hành Hợp Nhất loaded! Hold C to charge, release to fire")
