-- ============================================
-- CHẤN THIÊN QUYỀN - SERVER (CÔNG PHÁP THƯỢNG PHẨM)
-- Ultimate charge punch, tạo shockwave xuyên 40m, knockup mọi địch
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("ChanThienQuyenRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "ChanThienQuyenRemote"
	skillRemote.Parent = ReplicatedStorage
end

local chargingPlayers = {}

local PUNCH_COLORS = {
	Color3.fromRGB(255, 200, 0),
	Color3.fromRGB(255, 150, 0),
	Color3.fromRGB(255, 100, 0)
}

local function createChargingEffect(character, chargeLevel)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end

	local size = 3 + (chargeLevel * 3)

	local chargeOrb = Instance.new("Part")
	chargeOrb.Name = "ChargeOrb"
	chargeOrb.Shape = Enum.PartType.Ball
	chargeOrb.Size = Vector3.new(size, size, size)
	chargeOrb.Transparency = 0.4
	chargeOrb.CanCollide = false
	chargeOrb.Anchored = false
	chargeOrb.Material = Enum.Material.Neon
	chargeOrb.BrickColor = BrickColor.new("Deep orange")
	chargeOrb.Parent = workspace

	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart
	weld.Part1 = chargeOrb
	weld.C0 = CFrame.new(2, 0, -2)  -- In front of player
	weld.Parent = chargeOrb

	local attachment = VFXUtils.CreateAttachment(chargeOrb)

	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Star,
		Lifetime = NumberRange.new(0.4, 0.7),
		Rate = 100 + (chargeLevel * 50),
		Speed = NumberRange.new(5, 15),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new(2),
		Color = PUNCH_COLORS,
		LightEmission = 1
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(255, 150, 0), 15 + (chargeLevel * 5), 25)

	return chargeOrb
end

local function createPiercingShockwave(origin, direction, chargePercent)
	local size = 8 + (chargePercent * 8)

	local shockwave = VFXUtils.CreateProjectile({
		Name = "HeavenShattering Punch",
		Shape = Enum.PartType.Block,
		Size = Vector3.new(size, size, 4),
		Position = origin + Vector3.new(0, 2, 0),
		Transparency = 0.3,
		BrickColor = BrickColor.new("Deep orange"),
		Velocity = direction * (120 + chargePercent * 30)
	})

	shockwave.CanCollide = false  -- Pierce through

	local attachment = VFXUtils.CreateAttachment(shockwave)

	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Magic,
		Lifetime = NumberRange.new(0.5, 1),
		Rate = 150,
		Speed = NumberRange.new(10, 25),
		SpreadAngle = Vector2.new(80, 80),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 3),
			NumberSequenceKeypoint.new(0.5, 4),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = PUNCH_COLORS,
		LightEmission = 1
	})

	VFXUtils.CreateTrail(shockwave, {
		Lifetime = 1.5,
		Color = PUNCH_COLORS,
		WidthScale = NumberSequence.new(size),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(1, 1)
		})
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(255, 150, 0), 20, 35)

	return shockwave
end

skillRemote.OnServerEvent:Connect(function(player, action, ...)
	local character = player.Character
	if not character then return end

	if action == "start_charge" then
		-- Create charging effect
		local chargeOrb = createChargingEffect(character, 0)
		chargingPlayers[player.UserId] = chargeOrb

	elseif action == "release" then
		local direction, chargePercent = ...
		if typeof(direction) ~= "Vector3" or typeof(chargePercent) ~= "number" then
			warn("⚠️ Invalid data")
			return
		end

		-- Remove charge orb
		if chargingPlayers[player.UserId] then
			chargingPlayers[player.UserId]:Destroy()
			chargingPlayers[player.UserId] = nil
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then return end

		local origin = humanoidRootPart.Position

		-- Create piercing shockwave
		local shockwave = createPiercingShockwave(origin, direction, chargePercent)

		local baseDamage = 70
		local finalDamage = baseDamage * (1 + chargePercent * 1.5)
		local damagedEnemies = {}

		-- Pierce through enemies
		local touchConnection
		touchConnection = shockwave.Touched:Connect(function(hit)
			if hit and not hit:IsDescendantOf(character) then
				local targetChar = hit.Parent
				local humanoid = targetChar and targetChar:FindFirstChild("Humanoid")

				if humanoid and not damagedEnemies[targetChar] then
					damagedEnemies[targetChar] = true

					-- Damage
					humanoid:TakeDamage(finalDamage)

					-- Knockup effect
					VFXUtils.ApplyKnockback(targetChar, Vector3.new(0, 1, 0), 80 + (chargePercent * 40))
					VFXUtils.ApplyKnockback(targetChar, direction, 60)

					-- Effect on hit
					VFXUtils.CreateExplosion(hit.Position, {
						Color = PUNCH_COLORS,
						Size = 5 + (chargePercent * 3),
						ParticleCount = 80
					})

					print("👊💥 Chấn Thiên Quyền hit " .. targetChar.Name .. "! Damage: " .. math.floor(finalDamage))
				end
			end
		end)

		-- Destroy after traveling 40m or 3 seconds
		task.delay(3, function()
			if shockwave and shockwave.Parent then
				touchConnection:Disconnect()

				-- Final explosion
				VFXUtils.CreateExplosion(shockwave.Position, {
					Color = PUNCH_COLORS,
					Size = 10 + (chargePercent * 5),
					ParticleCount = 150
				})

				shockwave:Destroy()
			end
		end)

		Debris:AddItem(shockwave, 3)

		print("👊💥 " .. player.Name .. " unleashed CHẤN THIÊN QUYỀN! Charge: " .. math.floor(chargePercent * 100) .. "%")
	end
end)

print("✅ Chấn Thiên Quyền Server loaded!")
