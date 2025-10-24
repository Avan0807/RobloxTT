-- ProjectileModule.lua - Hệ Thống Projectile/Skillshot
-- Copy vào ReplicatedStorage/Modules/Combat/ProjectileModule (ModuleScript)

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local ProjectileModule = {}

-- ========================================
-- PROJECTILE TEMPLATE
-- ========================================

ProjectileModule.ProjectileTypes = {
	-- Magic projectile (Tiên Thiên)
	MagicBolt = {
		Size = Vector3.new(1, 1, 3),
		Color = Color3.fromRGB(100, 200, 255),
		Speed = 80, -- studs/second
		Lifetime = 3, -- seconds
		Piercing = false, -- Xuyên qua nhiều mục tiêu
		AOERadius = 0, -- Nổ AOE khi trúng
		Trail = true,
		ParticleEffect = "Magic"
	},

	-- Fireball (Tiên Thiên)
	Fireball = {
		Size = Vector3.new(2, 2, 2),
		Color = Color3.fromRGB(255, 140, 0),
		Speed = 60,
		Lifetime = 4,
		Piercing = false,
		AOERadius = 8, -- Nổ vùng 8 studs
		Trail = true,
		ParticleEffect = "Fire"
	},

	-- Lightning bolt (Tiên Thiên)
	Lightning = {
		Size = Vector3.new(0.5, 0.5, 10),
		Color = Color3.fromRGB(255, 255, 150),
		Speed = 150, -- Rất nhanh
		Lifetime = 2,
		Piercing = true, -- Xuyên qua
		AOERadius = 0,
		Trail = true,
		ParticleEffect = "Lightning"
	},

	-- Physical punch wave (Cổ Thần)
	PunchWave = {
		Size = Vector3.new(3, 3, 1),
		Color = Color3.fromRGB(255, 200, 100),
		Speed = 70,
		Lifetime = 2,
		Piercing = false,
		AOERadius = 5,
		Trail = false,
		ParticleEffect = "Shockwave"
	},

	-- Soul projectile (Ma Đạo)
	SoulBolt = {
		Size = Vector3.new(1.5, 1.5, 1.5),
		Color = Color3.fromRGB(150, 0, 150),
		Speed = 65,
		Lifetime = 3,
		Piercing = false,
		AOERadius = 0,
		Trail = true,
		ParticleEffect = "Soul"
	}
}

-- ========================================
-- CREATE PROJECTILE
-- ========================================

function ProjectileModule.CreateProjectile(projectileType, startPosition, direction, owner, damage, skill)
	local template = ProjectileModule.ProjectileTypes[projectileType]
	if not template then
		warn("Invalid projectile type:", projectileType)
		return nil
	end

	-- Create projectile part
	local projectile = Instance.new("Part")
	projectile.Name = projectileType
	projectile.Size = template.Size
	projectile.Color = template.Color
	projectile.Material = Enum.Material.Neon
	projectile.CanCollide = false
	projectile.Anchored = true
	projectile.CFrame = CFrame.new(startPosition, startPosition + direction)
	projectile.Parent = workspace

	-- Make it glow
	local light = Instance.new("PointLight")
	light.Brightness = 3
	light.Range = 15
	light.Color = template.Color
	light.Parent = projectile

	-- Trail effect
	if template.Trail then
		local attachment0 = Instance.new("Attachment")
		attachment0.Parent = projectile

		local attachment1 = Instance.new("Attachment")
		attachment1.Position = Vector3.new(0, 0, -template.Size.Z)
		attachment1.Parent = projectile

		local trail = Instance.new("Trail")
		trail.Attachment0 = attachment0
		trail.Attachment1 = attachment1
		trail.Lifetime = 0.5
		trail.Color = ColorSequence.new(template.Color)
		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		})
		trail.WidthScale = NumberSequence.new(1)
		trail.Parent = projectile
	end

	-- Particle effect
	ProjectileModule.AddParticleEffect(projectile, template.ParticleEffect)

	-- Projectile data
	local projectileData = {
		Part = projectile,
		Template = template,
		Direction = direction.Unit,
		Speed = template.Speed,
		Lifetime = template.Lifetime,
		StartTime = tick(),
		Owner = owner,
		Damage = damage,
		Skill = skill,
		HitTargets = {} -- Track who was hit (for piercing)
	}

	return projectileData
end

-- ========================================
-- PARTICLE EFFECTS
-- ========================================

function ProjectileModule.AddParticleEffect(part, effectType)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Parent = part

	if effectType == "Magic" then
		emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		emitter.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255))
		emitter.Rate = 50
		emitter.Lifetime = NumberRange.new(0.3, 0.6)
		emitter.Speed = NumberRange.new(2, 5)
		emitter.SpreadAngle = Vector2.new(30, 30)

	elseif effectType == "Fire" then
		emitter.Texture = "rbxasset://textures/particles/fire_main.dds"
		emitter.Color = ColorSequence.new(Color3.fromRGB(255, 140, 0))
		emitter.Rate = 80
		emitter.Lifetime = NumberRange.new(0.5, 1)
		emitter.Speed = NumberRange.new(3, 6)

	elseif effectType == "Lightning" then
		emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 150))
		emitter.Rate = 100
		emitter.Lifetime = NumberRange.new(0.1, 0.3)
		emitter.Speed = NumberRange.new(5, 10)

	elseif effectType == "Shockwave" then
		emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
		emitter.Color = ColorSequence.new(Color3.fromRGB(255, 200, 100))
		emitter.Rate = 40
		emitter.Lifetime = NumberRange.new(0.5, 0.8)
		emitter.Speed = NumberRange.new(2, 4)

	elseif effectType == "Soul" then
		emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		emitter.Color = ColorSequence.new(Color3.fromRGB(150, 0, 150))
		emitter.Rate = 60
		emitter.Lifetime = NumberRange.new(0.4, 0.7)
		emitter.Speed = NumberRange.new(2, 5)
	end

	emitter.Size = NumberSequence.new(0.5)
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
end

-- ========================================
-- UPDATE PROJECTILE (Call every frame)
-- ========================================

function ProjectileModule.UpdateProjectile(projectileData, deltaTime)
	if not projectileData.Part or not projectileData.Part.Parent then
		return false -- Destroyed
	end

	-- Check lifetime
	local elapsed = tick() - projectileData.StartTime
	if elapsed >= projectileData.Lifetime then
		ProjectileModule.DestroyProjectile(projectileData)
		return false
	end

	-- Move projectile
	local movement = projectileData.Direction * projectileData.Speed * deltaTime
	projectileData.Part.CFrame = projectileData.Part.CFrame + movement

	-- Check for hits
	local hit = ProjectileModule.CheckHit(projectileData)
	if hit then
		-- Hit something!
		if projectileData.Template.Piercing then
			-- Continue through
			return true
		else
			-- Stop and explode/destroy
			if projectileData.Template.AOERadius > 0 then
				ProjectileModule.ExplodeAOE(projectileData)
			end
			ProjectileModule.DestroyProjectile(projectileData)
			return false
		end
	end

	return true -- Continue
end

-- ========================================
-- HIT DETECTION
-- ========================================

function ProjectileModule.CheckHit(projectileData)
	local position = projectileData.Part.Position
	local size = projectileData.Template.Size

	-- Check for hits in a small radius
	local params = OverlapParams.new()
	params.FilterDescendantsInstances = {projectileData.Part, projectileData.Owner.Character}
	params.FilterType = Enum.RaycastFilterType.Exclude

	local parts = workspace:GetPartBoundsInRadius(position, math.max(size.X, size.Y, size.Z) / 2, params)

	for _, part in ipairs(parts) do
		local model = part.Parent
		local humanoid = model:FindFirstChild("Humanoid")

		if humanoid and model ~= projectileData.Owner.Character then
			-- Check if already hit (for piercing)
			if not projectileData.HitTargets[model] then
				projectileData.HitTargets[model] = true

				-- Apply damage (will be handled by server)
				ProjectileModule.OnHit(projectileData, model, humanoid)

				return true
			end
		end
	end

	return false
end

-- ========================================
-- ON HIT
-- ========================================

function ProjectileModule.OnHit(projectileData, targetModel, targetHumanoid)
	-- This will be called on server to apply damage
	-- Create hit effect
	ProjectileModule.CreateHitEffect(projectileData.Part.Position, projectileData.Template.Color)

	print("💥 Projectile hit:", targetModel.Name)
end

-- ========================================
-- AOE EXPLOSION
-- ========================================

function ProjectileModule.ExplodeAOE(projectileData)
	local position = projectileData.Part.Position
	local radius = projectileData.Template.AOERadius

	-- Create explosion visual
	ProjectileModule.CreateExplosionEffect(position, radius, projectileData.Template.Color)

	-- Find all enemies in radius
	local params = OverlapParams.new()
	params.FilterDescendantsInstances = {projectileData.Owner.Character}
	params.FilterType = Enum.RaycastFilterType.Exclude

	local parts = workspace:GetPartBoundsInRadius(position, radius, params)
	local hitModels = {}

	for _, part in ipairs(parts) do
		local model = part.Parent
		if model and not hitModels[model] then
			local humanoid = model:FindFirstChild("Humanoid")
			if humanoid and model ~= projectileData.Owner.Character then
				hitModels[model] = humanoid
				ProjectileModule.OnHit(projectileData, model, humanoid)
			end
		end
	end

	print("💥 AOE explosion hit", #hitModels, "targets")
end

-- ========================================
-- VISUAL EFFECTS
-- ========================================

function ProjectileModule.CreateHitEffect(position, color)
	local effect = Instance.new("Part")
	effect.Size = Vector3.new(2, 2, 2)
	effect.Position = position
	effect.Anchored = true
	effect.CanCollide = false
	effect.Material = Enum.Material.Neon
	effect.Color = color
	effect.Transparency = 0.5
	effect.Shape = Enum.PartType.Ball
	effect.Parent = workspace

	-- Fade out
	TweenService:Create(effect, TweenInfo.new(0.5), {
		Size = Vector3.new(0.5, 0.5, 0.5),
		Transparency = 1
	}):Play()

	Debris:AddItem(effect, 1)
end

function ProjectileModule.CreateExplosionEffect(position, radius, color)
	-- Explosion sphere
	local explosion = Instance.new("Part")
	explosion.Size = Vector3.new(0.5, 0.5, 0.5)
	explosion.Position = position
	explosion.Anchored = true
	explosion.CanCollide = false
	explosion.Material = Enum.Material.Neon
	explosion.Color = color
	explosion.Transparency = 0.3
	explosion.Shape = Enum.PartType.Ball
	explosion.Parent = workspace

	-- Expand
	TweenService:Create(explosion, TweenInfo.new(0.5), {
		Size = Vector3.new(radius * 2, radius * 2, radius * 2),
		Transparency = 1
	}):Play()

	-- Particles
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	emitter.Color = ColorSequence.new(color)
	emitter.Rate = 200
	emitter.Lifetime = NumberRange.new(0.5, 1)
	emitter.Speed = NumberRange.new(10, 20)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Parent = explosion
	emitter.Enabled = true

	wait(0.1)
	emitter.Enabled = false

	Debris:AddItem(explosion, 2)
end

-- ========================================
-- DESTROY PROJECTILE
-- ========================================

function ProjectileModule.DestroyProjectile(projectileData)
	if projectileData.Part then
		projectileData.Part:Destroy()
	end
end

print("✅ ProjectileModule loaded (Skillshot System)")
return ProjectileModule
