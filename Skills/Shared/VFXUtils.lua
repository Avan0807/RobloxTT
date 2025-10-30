-- ============================================
-- SHARED VFX UTILITIES
-- Các hàm tiện ích chung cho tất cả skills
-- ============================================

local Debris = game:GetService("Debris")

local VFXUtils = {}

-- ===========================
-- COLOR PRESETS
-- ===========================
VFXUtils.Colors = {
	Fire = {
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(255, 255, 100),
		Color3.fromRGB(255, 150, 0),
		Color3.fromRGB(255, 50, 0),
		Color3.fromRGB(50, 0, 0)
	},
	Ice = {
		Color3.fromRGB(200, 240, 255),
		Color3.fromRGB(150, 220, 255),
		Color3.fromRGB(100, 200, 255),
		Color3.fromRGB(50, 150, 255),
		Color3.fromRGB(30, 100, 200)
	},
	Lightning = {
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(200, 220, 255),
		Color3.fromRGB(150, 180, 255),
		Color3.fromRGB(100, 150, 255)
	},
	Wind = {
		Color3.fromRGB(220, 255, 220),
		Color3.fromRGB(180, 255, 200),
		Color3.fromRGB(140, 240, 180),
		Color3.fromRGB(100, 220, 160)
	},
	Earth = {
		Color3.fromRGB(160, 120, 80),
		Color3.fromRGB(140, 100, 60),
		Color3.fromRGB(120, 80, 40),
		Color3.fromRGB(100, 60, 30)
	},
	Light = {
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(255, 255, 200),
		Color3.fromRGB(255, 240, 150),
		Color3.fromRGB(255, 220, 100)
	},
	Dark = {
		Color3.fromRGB(150, 0, 200),
		Color3.fromRGB(120, 0, 180),
		Color3.fromRGB(100, 0, 150),
		Color3.fromRGB(80, 0, 120),
		Color3.fromRGB(50, 0, 80)
	},
	Blood = {
		Color3.fromRGB(200, 0, 0),
		Color3.fromRGB(150, 0, 0),
		Color3.fromRGB(100, 0, 0),
		Color3.fromRGB(80, 0, 0)
	}
}

-- ===========================
-- TEXTURE IDS (ROBLOX ASSET LIBRARY)
-- ===========================
VFXUtils.Textures = {
	Fire = "rbxassetid://6101261905",
	Spark = "rbxassetid://6523322082",
	Smoke = "rbxassetid://6865222957",
	Cloud = "rbxassetid://6865222957",
	Star = "rbxassetid://6253449729",
	Circle = "rbxassetid://6073894204",
	Ring = "rbxassetid://3270017".."149",
	Flash = "rbxassetid://6523286326",
	Lightning = "rbxassetid://6515798019",
	Magic = "rbxassetid://6172264595"
}

-- ===========================
-- CREATE ATTACHMENT WITH PARTICLES
-- ===========================
function VFXUtils.CreateAttachment(parent, name)
	local attachment = Instance.new("Attachment")
	attachment.Name = name or "VFXAttachment"
	attachment.Parent = parent
	return attachment
end

-- ===========================
-- CREATE PARTICLE EMITTER
-- ===========================
function VFXUtils.CreateParticle(config)
	local particle = Instance.new("ParticleEmitter")

	-- Required
	particle.Parent = config.Parent
	particle.Texture = config.Texture or VFXUtils.Textures.Fire

	-- Lifetime and Rate
	particle.Lifetime = config.Lifetime or NumberRange.new(0.5, 1)
	particle.Rate = config.Rate or 20

	-- Speed and Spread
	particle.Speed = config.Speed or NumberRange.new(2, 5)
	particle.SpreadAngle = config.SpreadAngle or Vector2.new(30, 30)

	-- Rotation
	particle.Rotation = config.Rotation or NumberRange.new(0, 360)
	particle.RotSpeed = config.RotSpeed or NumberRange.new(-50, 50)

	-- Color
	if config.Color then
		particle.Color = VFXUtils.CreateColorSequence(config.Color)
	end

	-- Size
	if config.Size then
		particle.Size = config.Size
	end

	-- Transparency
	if config.Transparency then
		particle.Transparency = config.Transparency
	end

	-- Light properties
	particle.LightEmission = config.LightEmission or 0.5
	particle.LightInfluence = config.LightInfluence or 0

	-- VFX Editor attributes
	particle:SetAttribute("EmitCount", config.EmitCount or particle.Rate)
	particle:SetAttribute("_vfxEditorScale", 1)

	return particle
end

-- ===========================
-- CREATE COLOR SEQUENCE FROM ARRAY
-- ===========================
function VFXUtils.CreateColorSequence(colors)
	local keypoints = {}
	for i, color in ipairs(colors) do
		local time = (i - 1) / (#colors - 1)
		table.insert(keypoints, ColorSequenceKeypoint.new(time, color))
	end
	return ColorSequence.new(keypoints)
end

-- ===========================
-- CREATE POINT LIGHT
-- ===========================
function VFXUtils.CreateLight(parent, color, brightness, range)
	local light = Instance.new("PointLight")
	light.Parent = parent
	light.Color = color or Color3.fromRGB(255, 255, 255)
	light.Brightness = brightness or 5
	light.Range = range or 15
	return light
end

-- ===========================
-- CREATE PROJECTILE PART
-- ===========================
function VFXUtils.CreateProjectile(config)
	local part = Instance.new("Part")
	part.Name = config.Name or "Projectile"
	part.Shape = config.Shape or Enum.PartType.Ball
	part.Size = config.Size or Vector3.new(2, 2, 2)
	part.Position = config.Position or Vector3.new(0, 10, 0)
	part.Transparency = config.Transparency or 0.8
	part.CanCollide = false
	part.Anchored = config.Anchored or false
	part.Material = config.Material or Enum.Material.Neon
	part.BrickColor = config.BrickColor or BrickColor.new("Bright blue")
	part.Parent = workspace

	-- Add BodyVelocity if needed
	if not config.Anchored then
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
		bodyVelocity.Velocity = config.Velocity or Vector3.new(0, 0, 0)
		bodyVelocity.Parent = part
	end

	return part
end

-- ===========================
-- CREATE EXPLOSION EFFECT
-- ===========================
function VFXUtils.CreateExplosion(position, config)
	config = config or {}

	local explosionPart = Instance.new("Part")
	explosionPart.Name = "Explosion"
	explosionPart.Size = Vector3.new(1, 1, 1)
	explosionPart.Position = position
	explosionPart.Transparency = 1
	explosionPart.Anchored = true
	explosionPart.CanCollide = false
	explosionPart.Parent = workspace

	local attachment = VFXUtils.CreateAttachment(explosionPart)

	-- Burst particle
	local burst = VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = config.Texture or VFXUtils.Textures.Fire,
		Rate = 0,
		Lifetime = NumberRange.new(0.4, 0.7),
		Speed = NumberRange.new(15, 30),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, config.Size or 3),
			NumberSequenceKeypoint.new(0.5, (config.Size or 3) * 1.5),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = config.Color or VFXUtils.Colors.Fire,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LightEmission = 1,
		EmitCount = config.ParticleCount or 50
	})

	burst:Emit(config.ParticleCount or 50)

	-- Light flash
	local light = VFXUtils.CreateLight(attachment, config.LightColor or Color3.fromRGB(255, 150, 0), 10, 25)

	-- Auto cleanup
	Debris:AddItem(explosionPart, 2)

	return explosionPart
end

-- ===========================
-- CREATE TRAIL
-- ===========================
function VFXUtils.CreateTrail(parent, config)
	config = config or {}

	local attachment0 = Instance.new("Attachment")
	attachment0.Name = "TrailAttachment0"
	attachment0.Parent = parent

	local attachment1 = Instance.new("Attachment")
	attachment1.Name = "TrailAttachment1"
	attachment1.Parent = parent

	local trail = Instance.new("Trail")
	trail.Parent = parent
	trail.Attachment0 = attachment0
	trail.Attachment1 = attachment1

	trail.Lifetime = config.Lifetime or 0.5
	trail.MinLength = config.MinLength or 0
	trail.WidthScale = config.WidthScale or NumberSequence.new(1)

	if config.Color then
		trail.Color = VFXUtils.CreateColorSequence(config.Color)
	end

	if config.Transparency then
		trail.Transparency = config.Transparency
	end

	trail.LightEmission = config.LightEmission or 0.5
	trail.Texture = config.Texture or VFXUtils.Textures.Flash

	return trail
end

-- ===========================
-- APPLY DAMAGE IN RADIUS
-- ===========================
function VFXUtils.DamageInRadius(position, radius, damage, ignoreList)
	ignoreList = ignoreList or {}

	local hitParts = workspace:GetPartBoundsInRadius(position, radius)
	local damagedCharacters = {}

	for _, part in ipairs(hitParts) do
		local character = part.Parent
		local humanoid = character and character:FindFirstChild("Humanoid")

		if humanoid and not damagedCharacters[character] then
			-- Check if in ignore list
			local shouldIgnore = false
			for _, ignoreChar in ipairs(ignoreList) do
				if character == ignoreChar then
					shouldIgnore = true
					break
				end
			end

			if not shouldIgnore then
				humanoid:TakeDamage(damage)
				damagedCharacters[character] = true
			end
		end
	end

	return damagedCharacters
end

-- ===========================
-- APPLY KNOCKBACK
-- ===========================
function VFXUtils.ApplyKnockback(character, direction, force)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = direction.Unit * force
	bodyVelocity.Parent = humanoidRootPart

	Debris:AddItem(bodyVelocity, 0.2)
end

return VFXUtils
