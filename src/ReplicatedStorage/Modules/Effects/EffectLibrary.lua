-- EffectLibrary.lua - Reusable Visual Effects Library
-- Tạo particles, trails, beams, và các effects khác

local EffectLibrary = {}

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- ========================================
-- HELPER: Create Particle
-- ========================================

function EffectLibrary.CreateParticle(config)
	local particle = Instance.new("ParticleEmitter")

	-- Basic properties
	particle.Texture = config.Texture or "rbxasset://textures/particles/smoke_main.dds"
	particle.Color = config.Color or ColorSequence.new(Color3.new(1, 1, 1))
	particle.Size = config.Size or NumberSequence.new(1)
	particle.Transparency = config.Transparency or NumberSequence.new(0)

	-- Emission
	particle.Rate = config.Rate or 20
	particle.Lifetime = config.Lifetime or NumberRange.new(1, 2)
	particle.Speed = config.Speed or NumberRange.new(5)
	particle.SpreadAngle = config.SpreadAngle or Vector2.new(0, 0)

	-- Physics
	particle.Acceleration = config.Acceleration or Vector3.new(0, 0, 0)
	particle.Drag = config.Drag or 0
	particle.VelocityInheritance = config.VelocityInheritance or 0

	-- Rotation
	particle.Rotation = config.Rotation or NumberRange.new(0)
	particle.RotSpeed = config.RotSpeed or NumberRange.new(0)

	-- Other
	particle.LightEmission = config.LightEmission or 0
	particle.LightInfluence = config.LightInfluence or 0
	particle.ZOffset = config.ZOffset or 0

	return particle
end

-- ========================================
-- LIGHTNING EFFECT (Lôi Điện)
-- ========================================

function EffectLibrary.Lightning(position, target)
	-- Create attachment point
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position
	part.Parent = workspace

	-- Lightning particles
	local lightning = EffectLibrary.CreateParticle({
		Texture = "rbxassetid://1084983440", -- Lightning texture
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 150)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 150, 255))
		}),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		}),
		Rate = 50,
		Lifetime = NumberRange.new(0.2, 0.5),
		Speed = NumberRange.new(10, 20),
		SpreadAngle = Vector2.new(30, 30),
		LightEmission = 1
	})
	lightning.Parent = part

	-- Emit burst
	lightning:Emit(20)

	-- Light
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(150, 200, 255)
	light.Brightness = 5
	light.Range = 15
	light.Parent = part

	-- Beam to target (if provided)
	if target then
		local targetPart = Instance.new("Part")
		targetPart.Anchored = true
		targetPart.CanCollide = false
		targetPart.Transparency = 1
		targetPart.Size = Vector3.new(1, 1, 1)
		targetPart.Position = target
		targetPart.Parent = workspace

		local att0 = Instance.new("Attachment", part)
		local att1 = Instance.new("Attachment", targetPart)

		local beam = Instance.new("Beam")
		beam.Attachment0 = att0
		beam.Attachment1 = att1
		beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 200))
		beam.Width0 = 1
		beam.Width1 = 1
		beam.Texture = "rbxassetid://1084983440"
		beam.TextureSpeed = 3
		beam.LightEmission = 1
		beam.FaceCamera = true
		beam.Parent = part

		Debris:AddItem(targetPart, 0.3)
	end

	-- Cleanup
	Debris:AddItem(part, 0.5)

	-- Sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://821439273" -- Thunder sound
	sound.Volume = 0.5
	sound.Parent = part
	sound:Play()
end

-- ========================================
-- FIRE EFFECT (Hỏa Diệm)
-- ========================================

function EffectLibrary.Fire(position, duration)
	duration = duration or 2

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(3, 3, 3)
	part.Position = position
	part.Parent = workspace

	-- Fire particles
	local fire = EffectLibrary.CreateParticle({
		Texture = "rbxasset://textures/particles/fire_main.dds",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 50, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 0))
		}),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 2),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		}),
		Rate = 50,
		Lifetime = NumberRange.new(0.5, 1),
		Speed = NumberRange.new(5, 10),
		Acceleration = Vector3.new(0, 10, 0),
		SpreadAngle = Vector2.new(20, 20),
		LightEmission = 1
	})
	fire.Parent = part

	-- Smoke
	local smoke = EffectLibrary.CreateParticle({
		Texture = "rbxasset://textures/particles/smoke_main.dds",
		Color = ColorSequence.new(Color3.fromRGB(50, 50, 50)),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 3)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.7),
			NumberSequenceKeypoint.new(1, 1)
		}),
		Rate = 20,
		Lifetime = NumberRange.new(1, 2),
		Speed = NumberRange.new(2, 5),
		Acceleration = Vector3.new(0, 5, 0),
		SpreadAngle = Vector2.new(10, 10)
	})
	smoke.Parent = part

	-- Light
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 100, 0)
	light.Brightness = 3
	light.Range = 20
	light.Parent = part

	-- Cleanup
	Debris:AddItem(part, duration)

	-- Sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://181004943" -- Fire sound
	sound.Volume = 0.4
	sound.Looped = true
	sound.Parent = part
	sound:Play()
end

-- ========================================
-- ICE EFFECT (Băng Phong)
-- ========================================

function EffectLibrary.Ice(position, size)
	size = size or 3

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(size, size, size)
	part.Position = position
	part.Parent = workspace

	-- Ice crystals
	local ice = EffectLibrary.CreateParticle({
		Texture = "rbxassetid://241685484", -- Crystal texture
		Color = ColorSequence.new(Color3.fromRGB(150, 200, 255)),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 1),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		}),
		Rate = 30,
		Lifetime = NumberRange.new(1, 2),
		Speed = NumberRange.new(5, 10),
		SpreadAngle = Vector2.new(180, 180),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-100, 100),
		LightEmission = 0.5
	})
	ice.Parent = part
	ice:Emit(50)

	-- Light
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(150, 200, 255)
	light.Brightness = 2
	light.Range = 15
	light.Parent = part

	-- Cleanup
	Debris:AddItem(part, 2)

	-- Sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://151776391" -- Ice sound
	sound.Volume = 0.5
	sound.Parent = part
	sound:Play()
end

-- ========================================
-- BLOOD EFFECT (Ma Đạo - Máu)
-- ========================================

function EffectLibrary.Blood(position)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position
	part.Parent = workspace

	-- Blood particles
	local blood = EffectLibrary.CreateParticle({
		Texture = "rbxasset://textures/particles/smoke_main.dds",
		Color = ColorSequence.new(Color3.fromRGB(150, 0, 0)),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		}),
		Rate = 100,
		Lifetime = NumberRange.new(0.5, 1),
		Speed = NumberRange.new(10, 20),
		SpreadAngle = Vector2.new(180, 180),
		Acceleration = Vector3.new(0, -30, 0)
	})
	blood.Parent = part
	blood:Emit(30)

	Debris:AddItem(part, 1)

	-- Sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://1571597070" -- Slash sound
	sound.Volume = 0.5
	sound.Parent = part
	sound:Play()
end

-- ========================================
-- SOUL EFFECT (Ma Đạo - Hồn)
-- ========================================

function EffectLibrary.Soul(position)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(2, 2, 2)
	part.Position = position
	part.Parent = workspace

	-- Soul particles
	local soul = EffectLibrary.CreateParticle({
		Texture = "rbxassetid://1084969997", -- Sparkle texture
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 0, 150)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 0, 200)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 0, 100))
		}),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 1),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		}),
		Rate = 40,
		Lifetime = NumberRange.new(1, 2),
		Speed = NumberRange.new(5),
		SpreadAngle = Vector2.new(360, 360),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-50, 50),
		LightEmission = 1
	})
	soul.Parent = part

	-- Spiral motion (create rotating attachment)
	local att = Instance.new("Attachment", part)
	soul.Parent = att

	-- Rotate
	local rotateSpeed = 360 -- degrees per second
	local elapsed = 0
	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		elapsed = elapsed + dt
		att.CFrame = CFrame.Angles(0, math.rad(rotateSpeed * elapsed), 0)

		if elapsed > 2 then
			connection:Disconnect()
		end
	end)

	Debris:AddItem(part, 2)

	-- Sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://535690488" -- Eerie sound
	sound.Volume = 0.3
	sound.Parent = part
	sound:Play()
end

-- ========================================
-- WIND EFFECT (Phong)
-- ========================================

function EffectLibrary.Wind(position, direction)
	direction = direction or Vector3.new(1, 0, 0)

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position
	part.Parent = workspace

	-- Wind particles
	local wind = EffectLibrary.CreateParticle({
		Texture = "rbxasset://textures/particles/smoke_main.dds",
		Color = ColorSequence.new(Color3.fromRGB(200, 200, 200)),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 2)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.7),
			NumberSequenceKeypoint.new(1, 1)
		}),
		Rate = 30,
		Lifetime = NumberRange.new(0.5, 1),
		Speed = NumberRange.new(20, 30),
		SpreadAngle = Vector2.new(10, 10),
		Acceleration = direction * 50
	})
	wind.Parent = part
	wind:Emit(20)

	Debris:AddItem(part, 1)

	-- Sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://966888625" -- Wind sound
	sound.Volume = 0.4
	sound.Parent = part
	sound:Play()
end

-- ========================================
-- EXPLOSION EFFECT
-- ========================================

function EffectLibrary.Explosion(position, size, color)
	size = size or 10
	color = color or Color3.fromRGB(255, 150, 0)

	-- Explosion instance
	local explosion = Instance.new("Explosion")
	explosion.Position = position
	explosion.BlastRadius = size
	explosion.BlastPressure = 0 -- No knockback
	explosion.DestroyJointRadiusPercent = 0 -- Don't break joints
	explosion.Parent = workspace

	-- Custom particle ring
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position
	part.Parent = workspace

	local ring = EffectLibrary.CreateParticle({
		Texture = "rbxassetid://1084969997",
		Color = ColorSequence.new(color),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, size),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		}),
		Rate = 100,
		Lifetime = NumberRange.new(0.5),
		Speed = NumberRange.new(size),
		SpreadAngle = Vector2.new(180, 180),
		LightEmission = 1
	})
	ring.Parent = part
	ring:Emit(50)

	-- Light
	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = 10
	light.Range = size * 2
	light.Parent = part

	-- Fade light
	TweenService:Create(light, TweenInfo.new(0.5), {Brightness = 0}):Play()

	Debris:AddItem(part, 1)
end

-- ========================================
-- SLASH EFFECT (for swords)
-- ========================================

function EffectLibrary.Slash(startPosition, endPosition, color)
	color = color or Color3.fromRGB(255, 255, 255)

	-- Create beam
	local part1 = Instance.new("Part")
	part1.Anchored = true
	part1.CanCollide = false
	part1.Transparency = 1
	part1.Size = Vector3.new(1, 1, 1)
	part1.Position = startPosition
	part1.Parent = workspace

	local part2 = Instance.new("Part")
	part2.Anchored = true
	part2.CanCollide = false
	part2.Transparency = 1
	part2.Size = Vector3.new(1, 1, 1)
	part2.Position = endPosition
	part2.Parent = workspace

	local att0 = Instance.new("Attachment", part1)
	local att1 = Instance.new("Attachment", part2)

	local beam = Instance.new("Beam")
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	beam.Color = ColorSequence.new(color)
	beam.Width0 = 2
	beam.Width1 = 2
	beam.Texture = "rbxassetid://1084991215" -- Slash texture
	beam.LightEmission = 1
	beam.FaceCamera = true
	beam.Parent = part1

	-- Fade out
	TweenService:Create(beam, TweenInfo.new(0.3), {
		Width0 = 0,
		Width1 = 0,
		Transparency = NumberSequence.new(1)
	}):Play()

	Debris:AddItem(part1, 0.5)
	Debris:AddItem(part2, 0.5)

	-- Sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://1842132986" -- Slash sound
	sound.Volume = 0.5
	sound.Parent = part1
	sound:Play()
end

-- ========================================
-- HEAL EFFECT
-- ========================================

function EffectLibrary.Heal(position)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(3, 3, 3)
	part.Position = position
	part.Parent = workspace

	-- Healing particles
	local heal = EffectLibrary.CreateParticle({
		Texture = "rbxassetid://1084969997",
		Color = ColorSequence.new(Color3.fromRGB(0, 255, 100)),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		}),
		Rate = 50,
		Lifetime = NumberRange.new(1, 2),
		Speed = NumberRange.new(5),
		Acceleration = Vector3.new(0, 10, 0),
		SpreadAngle = Vector2.new(360, 360),
		LightEmission = 1
	})
	heal.Parent = part
	heal:Emit(30)

	Debris:AddItem(part, 2)

	-- Sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://1843450697" -- Heal sound
	sound.Volume = 0.5
	sound.Parent = part
	sound:Play()
end

-- ========================================
-- BUFF AURA (Continuous effect)
-- ========================================

function EffectLibrary.Aura(parent, color, duration)
	color = color or Color3.fromRGB(255, 200, 0)
	duration = duration or 5

	if not parent then return end

	-- Create aura part
	local aura = Instance.new("Part")
	aura.Anchored = true
	aura.CanCollide = false
	aura.Transparency = 1
	aura.Size = Vector3.new(5, 5, 5)
	aura.Parent = parent

	-- Keep position synced
	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function()
		if parent and parent.Parent then
			aura.Position = parent.Position
		else
			connection:Disconnect()
			aura:Destroy()
		end
	end)

	-- Aura particles
	local particles = EffectLibrary.CreateParticle({
		Texture = "rbxassetid://1084969997",
		Color = ColorSequence.new(color),
		Size = NumberSequence.new(1),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		}),
		Rate = 20,
		Lifetime = NumberRange.new(1),
		Speed = NumberRange.new(2),
		SpreadAngle = Vector2.new(360, 360),
		LightEmission = 1
	})
	particles.Parent = aura

	-- Remove after duration
	task.delay(duration, function()
		connection:Disconnect()
		particles.Enabled = false
		Debris:AddItem(aura, 2)
	end)

	return aura
end

print("✅ EffectLibrary loaded")
return EffectLibrary
