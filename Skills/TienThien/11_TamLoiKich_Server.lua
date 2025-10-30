-- ============================================
-- TAM LÔI KÍCH - SERVER (CÔNG PHÁP THƯỢNG PHẨM)
-- Chuỗi combo 3 cú sét tốc độ cao, mỗi hit gây stagger mạnh
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("TamLoiKichRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "TamLoiKichRemote"
	skillRemote.Parent = ReplicatedStorage
end

local function createLightningBolt(origin, direction, comboNumber)
	local bolt = VFXUtils.CreateProjectile({
		Name = "LightningBolt_" .. comboNumber,
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(2, 2, 5),
		Position = origin + Vector3.new(0, 2, 0),
		Transparency = 0.3,
		BrickColor = BrickColor.new("Electric blue"),
		Velocity = direction * (100 + comboNumber * 20)
	})

	local attachment = VFXUtils.CreateAttachment(bolt)

	-- Lightning effect - gets more intense with each hit
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Lightning,
		Lifetime = NumberRange.new(0.2, 0.4),
		Rate = 80 + (comboNumber * 20),
		Speed = NumberRange.new(5, 15),
		SpreadAngle = Vector2.new(40, 40),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2 + comboNumber * 0.5),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Lightning,
		LightEmission = 1
	})

	VFXUtils.CreateTrail(bolt, {
		Lifetime = 0.5,
		Color = VFXUtils.Colors.Lightning,
		WidthScale = NumberSequence.new(1 + comboNumber * 0.3)
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(200, 220, 255), 8 + comboNumber * 2, 15)

	return bolt
end

local function performTamLoiKich(player, comboNumber, direction)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local origin = humanoidRootPart.Position
	local bolt = createLightningBolt(origin, direction, comboNumber)

	local baseDamage = 25
	local comboDamage = baseDamage + (comboNumber * 10)

	local touchConnection
	touchConnection = bolt.Touched:Connect(function(hit)
		if hit and not hit:IsDescendantOf(character) then
			local targetChar = hit.Parent
			local humanoid = targetChar and targetChar:FindFirstChild("Humanoid")

			if humanoid then
				humanoid:TakeDamage(comboDamage)

				-- Stagger effect (knockback)
				VFXUtils.ApplyKnockback(targetChar, direction, 30 + (comboNumber * 10))

				print("⚡ TAM LÔI KÍCH Hit " .. comboNumber .. " - Damage: " .. comboDamage)
			end

			-- Explosion
			VFXUtils.CreateExplosion(bolt.Position, {
				Color = VFXUtils.Colors.Lightning,
				Size = 3 + comboNumber,
				ParticleCount = 40 + (comboNumber * 20)
			})

			touchConnection:Disconnect()
			bolt:Destroy()
		end
	end)

	Debris:AddItem(bolt, 2)
end

skillRemote.OnServerEvent:Connect(function(player, comboNumber, direction)
	if typeof(comboNumber) ~= "number" or typeof(direction) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	performTamLoiKich(player, comboNumber, direction)
end)

print("✅ Tam Lôi Kích Server loaded!")
