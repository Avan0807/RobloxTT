-- ============================================
-- TỬ LÔI GIÁNG - SERVER
-- Gọi sét định vị trúng mục tiêu, delay 1s, cho phép địch dodge
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("TuLoiGiangRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "TuLoiGiangRemote"
	skillRemote.Parent = ReplicatedStorage
end

local function createWarningCircle(position)
	local circle = Instance.new("Part")
	circle.Name = "LightningWarning"
	circle.Shape = Enum.PartType.Cylinder
	circle.Size = Vector3.new(0.2, 8, 8)
	circle.Position = position + Vector3.new(0, 0.1, 0)
	circle.Orientation = Vector3.new(0, 0, 90)
	circle.Transparency = 0.5
	circle.CanCollide = false
	circle.Anchored = true
	circle.Material = Enum.Material.Neon
	circle.BrickColor = BrickColor.new("Electric blue")
	circle.Parent = workspace

	-- Pulsing effect
	local attachment = VFXUtils.CreateAttachment(circle)
	VFXUtils.CreateLight(attachment, Color3.fromRGB(150, 180, 255), 8, 15)

	return circle
end

local function createLightningStrike(position)
	-- Lightning beam from sky
	local startPos = position + Vector3.new(0, 100, 0)

	local lightning = Instance.new("Part")
	lightning.Name = "LightningStrike"
	lightning.Shape = Enum.PartType.Cylinder
	lightning.Size = Vector3.new(100, 3, 3)
	lightning.Position = (startPos + position) / 2
	lightning.Orientation = Vector3.new(90, 0, 0)
	lightning.Transparency = 0.2
	lightning.CanCollide = false
	lightning.Anchored = true
	lightning.Material = Enum.Material.Neon
	lightning.BrickColor = BrickColor.new("Electric blue")
	lightning.Parent = workspace

	local attachment = VFXUtils.CreateAttachment(lightning)

	-- Lightning particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Lightning,
		Lifetime = NumberRange.new(0.2, 0.4),
		Rate = 200,
		Speed = NumberRange.new(10, 20),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 3),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Lightning,
		LightEmission = 1,
		EmitCount = 200
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(200, 220, 255), 15, 30)

	Debris:AddItem(lightning, 0.5)

	return lightning
end

local function callLightning(player, targetPosition)
	-- Phase 1: Warning
	local warning = createWarningCircle(targetPosition)

	print("⚡ " .. player.Name .. " called Tử Lôi Giáng! 1s delay...")

	-- Phase 2: Strike after 1s
	task.delay(1, function()
		warning:Destroy()

		-- Create lightning
		createLightningStrike(targetPosition)

		-- Damage in radius
		VFXUtils.DamageInRadius(targetPosition, 8, 50)

		-- Explosion effect
		VFXUtils.CreateExplosion(targetPosition, {
			Color = VFXUtils.Colors.Lightning,
			Size = 5,
			ParticleCount = 100,
			LightColor = Color3.fromRGB(200, 220, 255)
		})

		print("⚡💥 Lightning struck!")
	end)

	Debris:AddItem(warning, 1)
end

skillRemote.OnServerEvent:Connect(function(player, targetPosition)
	if typeof(targetPosition) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	callLightning(player, targetPosition)
end)

print("✅ Tử Lôi Giáng Server loaded!")
