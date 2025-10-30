-- ============================================
-- NGŨ HÀNH HỢP NHẤT - SERVER (CÔNG PHÁP THƯỢNG PHẨM)
-- Biến 5 nguyên tố thành cầu năng lượng, nổ theo hướng charge (burst 400% dmg)
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("NguHanhHopNhatRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "NguHanhHopNhatRemote"
	skillRemote.Parent = ReplicatedStorage
end

local chargingPlayers = {}

local ALL_ELEMENTS = {
	VFXUtils.Colors.Fire,
	VFXUtils.Colors.Ice,
	VFXUtils.Colors.Lightning,
	VFXUtils.Colors.Wind,
	VFXUtils.Colors.Earth
}

local function createChargingSphere(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end

	local sphere = Instance.new("Part")
	sphere.Name = "ElementSphere"
	sphere.Shape = Enum.PartType.Ball
	sphere.Size = Vector3.new(2, 2, 2)
	sphere.Position = humanoidRootPart.Position + Vector3.new(0, 3, 0)
	sphere.Transparency = 0.3
	sphere.CanCollide = false
	sphere.Anchored = false
	sphere.Material = Enum.Material.Neon
	sphere.BrickColor = BrickColor.new("White")
	sphere.Parent = workspace

	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart
	weld.Part1 = sphere
	weld.C0 = CFrame.new(0, 3, 0)
	weld.Parent = sphere

	local attachment = VFXUtils.CreateAttachment(sphere)

	-- All 5 elements swirling
	for i, colors in ipairs(ALL_ELEMENTS) do
		VFXUtils.CreateParticle({
			Parent = attachment,
			Texture = VFXUtils.Textures.Magic,
			Lifetime = NumberRange.new(0.5, 1),
			Rate = 40,
			Speed = NumberRange.new(3, 8),
			SpreadAngle = Vector2.new(180, 180),
			Rotation = NumberRange.new(0, 360),
			RotSpeed = NumberRange.new(100, 200),
			Size = NumberSequence.new(1),
			Color = colors,
			LightEmission = 1
		})
	end

	VFXUtils.CreateLight(attachment, Color3.fromRGB(255, 255, 255), 10, 20)

	return sphere
end

local function createElementOrb(origin, direction, chargePercent)
	local size = 3 + (chargePercent * 5)

	local orb = VFXUtils.CreateProjectile({
		Name = "ElementOrb",
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(size, size, size),
		Position = origin + Vector3.new(0, 2, 0),
		Transparency = 0.2,
		BrickColor = BrickColor.new("White"),
		Velocity = direction * (80 + chargePercent * 40)
	})

	local attachment = VFXUtils.CreateAttachment(orb)

	-- All elements combined
	for _, colors in ipairs(ALL_ELEMENTS) do
		VFXUtils.CreateParticle({
			Parent = attachment,
			Texture = VFXUtils.Textures.Magic,
			Lifetime = NumberRange.new(0.4, 0.8),
			Rate = 80,
			Speed = NumberRange.new(5, 12),
			SpreadAngle = Vector2.new(50, 50),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 2),
				NumberSequenceKeypoint.new(0.5, 3),
				NumberSequenceKeypoint.new(1, 0)
			}),
			Color = colors,
			LightEmission = 1
		})
	end

	VFXUtils.CreateTrail(orb, {
		Lifetime = 1,
		Color = {Color3.fromRGB(255, 255, 255)},
		WidthScale = NumberSequence.new(size / 2)
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(255, 255, 255), 15, 25)

	return orb
end

skillRemote.OnServerEvent:Connect(function(player, action, ...)
	local character = player.Character
	if not character then return end

	if action == "start_charge" then
		-- Start charging
		local sphere = createChargingSphere(character)
		chargingPlayers[player.UserId] = sphere

		print("🌟 " .. player.Name .. " is charging Ngũ Hành Hợp Nhất...")

	elseif action == "release" then
		local direction, chargePercent = ...
		if typeof(direction) ~= "Vector3" or typeof(chargePercent) ~= "number" then
			warn("⚠️ Invalid data")
			return
		end

		-- Remove charging sphere
		if chargingPlayers[player.UserId] then
			chargingPlayers[player.UserId]:Destroy()
			chargingPlayers[player.UserId] = nil
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then return end

		local origin = humanoidRootPart.Position

		-- Create and fire orb
		local orb = createElementOrb(origin, direction, chargePercent)

		local baseDamage = 60
		local finalDamage = baseDamage * (1 + chargePercent * 3) -- Up to 400% at full charge

		local touchConnection
		touchConnection = orb.Touched:Connect(function(hit)
			if hit and not hit:IsDescendantOf(character) then
				-- Massive explosion
				local explosionSize = 8 + (chargePercent * 8)

				VFXUtils.DamageInRadius(orb.Position, explosionSize, finalDamage, {character})

				-- Multi-element explosion
				for i, colors in ipairs(ALL_ELEMENTS) do
					task.delay(i * 0.05, function()
						VFXUtils.CreateExplosion(orb.Position, {
							Color = colors,
							Size = explosionSize,
							ParticleCount = 100 + (chargePercent * 50)
						})
					end)
				end

				print("🌟💥 " .. player.Name .. " unleashed Ngũ Hành Hợp Nhất! Damage: " .. finalDamage)

				touchConnection:Disconnect()
				orb:Destroy()
			end
		end)

		Debris:AddItem(orb, 5)
	end
end)

print("✅ Ngũ Hành Hợp Nhất Server loaded!")
