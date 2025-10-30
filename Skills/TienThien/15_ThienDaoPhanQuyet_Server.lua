-- ============================================
-- THIÊN ĐẠO PHÁN QUYẾT - SERVER (ULTIMATE)
-- Triệu hồi cột ánh sáng 100% map nhỏ, địch trong vùng bị đánh 3 lần liên tiếp
-- Damage scale theo MP
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("ThienDaoPhanQuyetRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "ThienDaoPhanQuyetRemote"
	skillRemote.Parent = ReplicatedStorage
end

local function createLightPillar(position, radius)
	-- Warning circle
	local warning = Instance.new("Part")
	warning.Name = "DivineWarning"
	warning.Shape = Enum.PartType.Cylinder
	warning.Size = Vector3.new(0.5, radius * 2, radius * 2)
	warning.Position = position + Vector3.new(0, 0.2, 0)
	warning.Orientation = Vector3.new(0, 0, 90)
	warning.Transparency = 0.6
	warning.CanCollide = false
	warning.Anchored = true
	warning.Material = Enum.Material.Neon
	warning.BrickColor = BrickColor.new("New Yeller")
	warning.Parent = workspace

	local attachment = VFXUtils.CreateAttachment(warning)
	VFXUtils.CreateLight(attachment, Color3.fromRGB(255, 255, 200), 15, 30)

	return warning
end

local function createDivinePillar(position, radius)
	-- Massive light pillar from sky
	local skyHeight = 200

	local pillar = Instance.new("Part")
	pillar.Name = "DivinePillar"
	pillar.Shape = Enum.PartType.Cylinder
	pillar.Size = Vector3.new(skyHeight, radius * 2, radius * 2)
	pillar.Position = position + Vector3.new(0, skyHeight / 2, 0)
	pillar.Orientation = Vector3.new(90, 0, 0)
	pillar.Transparency = 0.3
	pillar.CanCollide = false
	pillar.Anchored = true
	pillar.Material = Enum.Material.Neon
	pillar.BrickColor = BrickColor.new("Institutional white")
	pillar.Parent = workspace

	local attachment = VFXUtils.CreateAttachment(pillar)

	-- Divine light particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Star,
		Lifetime = NumberRange.new(1, 2),
		Rate = 300,
		Speed = NumberRange.new(10, 30),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 3),
			NumberSequenceKeypoint.new(0.5, 4),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Light,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LightEmission = 1
	})

	-- Magic runes
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Magic,
		Lifetime = NumberRange.new(1.5, 2.5),
		Rate = 200,
		Speed = NumberRange.new(5, 15),
		SpreadAngle = Vector2.new(30, 30),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(50, 100),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Light,
		LightEmission = 1
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(255, 255, 255), 30, 80)

	return pillar
end

local function castThienDaoPhanQuyet(player, targetPosition)
	local character = player.Character
	if not character then return end

	local radius = 30 -- Large AOE

	-- Phase 1: Warning (1 second)
	local warning = createLightPillar(targetPosition, radius)

	print("☀️ " .. player.Name .. " is calling Thiên Đạo Phán Quyết... 1s warning!")

	task.wait(1)

	warning:Destroy()

	-- Phase 2: Divine Judgment
	local pillar = createDivinePillar(targetPosition, radius)

	-- 3 consecutive hits
	local baseDamage = 80 -- TODO: Scale with MP
	local hitDelay = 0.5

	for hit = 1, 3 do
		task.delay(hit * hitDelay, function()
			-- Damage all enemies in radius
			VFXUtils.DamageInRadius(targetPosition, radius, baseDamage, {character})

			-- Knockdown effect
			local hitParts = workspace:GetPartBoundsInRadius(targetPosition, radius)
			for _, part in ipairs(hitParts) do
				local targetChar = part.Parent
				local humanoid = targetChar and targetChar:FindFirstChild("Humanoid")

				if humanoid and targetChar ~= character then
					VFXUtils.ApplyKnockback(targetChar, Vector3.new(0, 1, 0), 20)
				end
			end

			-- Explosion
			VFXUtils.CreateExplosion(targetPosition, {
				Color = VFXUtils.Colors.Light,
				Size = 10,
				ParticleCount = 150,
				LightColor = Color3.fromRGB(255, 255, 255)
			})

			print("☀️ DIVINE JUDGMENT Hit " .. hit .. "/3 - Damage: " .. baseDamage)
		end)
	end

	-- Remove pillar after 3 seconds
	Debris:AddItem(pillar, 3)

	print("☀️☀️☀️ " .. player.Name .. " unleashed THIÊN ĐẠO PHÁN QUYẾT!")
end

skillRemote.OnServerEvent:Connect(function(player, targetPosition)
	if typeof(targetPosition) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	castThienDaoPhanQuyet(player, targetPosition)
end)

print("✅ ULTIMATE: Thiên Đạo Phán Quyết Server loaded!")
