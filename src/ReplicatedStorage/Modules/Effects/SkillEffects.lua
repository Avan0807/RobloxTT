-- SkillEffects.lua - Công Pháp (Cultivation Skills) Effects
-- Pre-built skill effects cho 3 hệ tu luyện: Tiên Thiên, Cổ Thần, Ma Đạo

local EffectLibrary = require(script.Parent.EffectLibrary)
local SkillEffects = {}

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- ========================================
-- TIÊN THIÊN (Magic) SKILLS
-- ========================================

-- Lôi Pháp (Lightning Strike)
function SkillEffects.LightningStrike(caster, target, damage)
	if not target or not target:FindFirstChild("Humanoid") then return end

	-- Multiple lightning strikes
	for i = 1, 5 do
		task.wait(0.2)

		local targetPos = target.PrimaryPart.Position + Vector3.new(
			math.random(-5, 5),
			10,
			math.random(-5, 5)
		)

		EffectLibrary.Lightning(targetPos, target.PrimaryPart.Position)

		-- Deal damage
		target.Humanoid:TakeDamage(damage / 5)
	end

	-- Final mega strike
	task.wait(0.5)
	EffectLibrary.Lightning(target.PrimaryPart.Position + Vector3.new(0, 20, 0), target.PrimaryPart.Position)
	EffectLibrary.Explosion(target.PrimaryPart.Position, 10, Color3.fromRGB(200, 200, 255))

	target.Humanoid:TakeDamage(damage * 0.5) -- Bonus damage

	print("⚡ Lightning Strike dealt", damage, "total damage!")
end

-- Băng Phong Trận (Ice Storm)
function SkillEffects.IceStorm(caster, position, radius, duration)
	radius = radius or 15
	duration = duration or 5

	print("❄️ Ice Storm summoned!")

	-- Create storm center
	local center = Instance.new("Part")
	center.Anchored = true
	center.CanCollide = false
	center.Transparency = 1
	center.Size = Vector3.new(1, 1, 1)
	center.Position = position
	center.Parent = workspace

	-- Ice aura
	EffectLibrary.Aura(center, Color3.fromRGB(150, 200, 255), duration)

	-- Spawn ice crystals periodically
	local elapsed = 0
	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		elapsed = elapsed + dt

		-- Spawn ice every 0.5s
		if elapsed % 0.5 < dt then
			-- Random position in radius
			local angle = math.random() * math.pi * 2
			local distance = math.random() * radius
			local icePos = position + Vector3.new(
				math.cos(angle) * distance,
				5,
				math.sin(angle) * distance
			)

			EffectLibrary.Ice(icePos, 3)

			-- Damage enemies in area
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= caster.Character then
					local dist = (obj.PrimaryPart.Position - position).Magnitude
					if dist <= radius then
						obj.Humanoid:TakeDamage(10) -- Tick damage
						-- Slow effect (TODO: implement)
					end
				end
			end
		end

		if elapsed >= duration then
			connection:Disconnect()
			center:Destroy()
		end
	end)
end

-- Hỏa Cầu Thuật (Fireball)
function SkillEffects.Fireball(caster, direction, damage)
	local character = caster.Character
	if not character then return end

	local rootPart = character.HumanoidRootPart

	-- Create fireball
	local fireball = Instance.new("Part")
	fireball.Shape = Enum.PartType.Ball
	fireball.Size = Vector3.new(3, 3, 3)
	fireball.Position = rootPart.Position + Vector3.new(0, 2, 0)
	fireball.BrickColor = BrickColor.new("Bright orange")
	fireball.Material = Enum.Material.Neon
	fireball.CanCollide = false
	fireball.Parent = workspace

	-- Fire effect
	EffectLibrary.Fire(fireball.Position, 0.1)

	-- Trail
	local attachment = Instance.new("Attachment", fireball)
	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0))
	trail.Lifetime = 0.5
	trail.Parent = fireball

	-- Movement
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = direction * 80
	bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
	bodyVelocity.Parent = fireball

	-- Hit detection
	fireball.Touched:Connect(function(hit)
		if hit.Parent:FindFirstChild("Humanoid") and hit.Parent ~= character then
			-- Deal damage
			hit.Parent.Humanoid:TakeDamage(damage)

			-- Explosion
			EffectLibrary.Explosion(fireball.Position, 8, Color3.fromRGB(255, 100, 0))
			EffectLibrary.Fire(fireball.Position, 2)

			fireball:Destroy()
		end
	end)

	-- Auto-destroy after 5 seconds
	Debris:AddItem(fireball, 5)

	print("🔥 Fireball launched!")
end

-- ========================================
-- CỔ THẦN (Physical/Body) SKILLS
-- ========================================

-- Bá Thể Kim Thân (Golden Body - Defense buff)
function SkillEffects.GoldenBody(caster, duration)
	duration = duration or 10

	local character = caster.Character
	if not character then return end

	print("🛡️ Golden Body activated!")

	-- Visual effect - golden aura
	EffectLibrary.Aura(character.HumanoidRootPart, Color3.fromRGB(255, 200, 0), duration)

	-- Change character color to gold
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			local originalColor = part.Color
			part.Color = Color3.fromRGB(255, 215, 0)

			-- Restore after duration
			task.delay(duration, function()
				if part and part.Parent then
					part.Color = originalColor
				end
			end)
		end
	end

	-- TODO: Actually increase defense in stats
	-- Example: caster.Defense = caster.Defense * 2

	print("✅ Defense doubled for", duration, "seconds!")
end

-- Bát Hoang Quyền (Eight Desolate Fist - Area punch)
function SkillEffects.EightDesolateFist(caster, damage)
	local character = caster.Character
	if not character then return end

	local rootPart = character.HumanoidRootPart

	print("👊 Eight Desolate Fist!")

	-- 8 punches in 8 directions
	for i = 1, 8 do
		local angle = (i / 8) * math.pi * 2
		local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
		local targetPos = rootPart.Position + (direction * 10)

		-- Punch effect
		task.wait(0.1)
		EffectLibrary.Wind(targetPos, direction)
		EffectLibrary.Explosion(targetPos, 5, Color3.fromRGB(255, 200, 100))

		-- Damage in cone
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= character then
				local toEnemy = (obj.PrimaryPart.Position - rootPart.Position)
				local dot = toEnemy.Unit:Dot(direction)

				if dot > 0.7 and toEnemy.Magnitude <= 10 then -- 45 degree cone
					obj.Humanoid:TakeDamage(damage / 8)

					-- Knockback
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Velocity = direction * 50 + Vector3.new(0, 20, 0)
					bodyVelocity.MaxForce = Vector3.new(50000, 50000, 50000)
					bodyVelocity.Parent = obj.PrimaryPart

					Debris:AddItem(bodyVelocity, 0.2)
				end
			end
		end
	end

	-- Final ground pound
	task.wait(0.3)
	EffectLibrary.Explosion(rootPart.Position, 15, Color3.fromRGB(200, 150, 100))
end

-- ========================================
-- MA ĐẠO (Soul/Dark) SKILLS
-- ========================================

-- Hút Hồn (Soul Drain)
function SkillEffects.SoulDrain(caster, target, damage)
	if not target or not target:FindFirstChild("Humanoid") then return end

	local character = caster.Character
	if not character then return end

	print("💀 Soul Drain!")

	-- Soul particles from target to caster
	local duration = 3
	local tickRate = 0.3
	local elapsed = 0

	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		elapsed = elapsed + dt

		-- Create soul particle
		if elapsed % tickRate < dt then
			EffectLibrary.Soul(target.PrimaryPart.Position)

			-- Beam from target to caster
			local beam = Instance.new("Part")
			beam.Anchored = true
			beam.CanCollide = false
			beam.Transparency = 0.5
			beam.Size = Vector3.new(0.5, 0.5, (target.PrimaryPart.Position - character.HumanoidRootPart.Position).Magnitude)
			beam.CFrame = CFrame.new(
				(target.PrimaryPart.Position + character.HumanoidRootPart.Position) / 2,
				target.PrimaryPart.Position
			)
			beam.BrickColor = BrickColor.new("Royal purple")
			beam.Material = Enum.Material.Neon
			beam.Parent = workspace

			Debris:AddItem(beam, 0.2)

			-- Deal damage and heal
			local tickDamage = damage / (duration / tickRate)
			target.Humanoid:TakeDamage(tickDamage)

			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.Health = math.min(humanoid.Health + tickDamage, humanoid.MaxHealth)
			end
		end

		if elapsed >= duration then
			connection:Disconnect()

			-- Final soul absorption
			EffectLibrary.Soul(character.HumanoidRootPart.Position)
			EffectLibrary.Heal(character.HumanoidRootPart.Position)
		end
	end)
end

-- Huyết Ma Trảm (Blood Demon Slash)
function SkillEffects.BloodDemonSlash(caster, target, damage)
	if not target or not target:FindFirstChild("Humanoid") then return end

	local character = caster.Character
	if not character then return end

	print("🩸 Blood Demon Slash!")

	-- Dash to target
	local rootPart = character.HumanoidRootPart
	local direction = (target.PrimaryPart.Position - rootPart.Position).Unit

	-- Create blood trail
	for i = 1, 10 do
		task.wait(0.05)
		EffectLibrary.Blood(rootPart.Position + Vector3.new(0, 2, 0))
	end

	-- Teleport to target
	rootPart.CFrame = CFrame.new(target.PrimaryPart.Position - (direction * 5), target.PrimaryPart.Position)

	-- Multiple slashes
	for i = 1, 5 do
		task.wait(0.1)

		local slashStart = target.PrimaryPart.Position + Vector3.new(math.random(-3, 3), math.random(0, 5), math.random(-3, 3))
		local slashEnd = target.PrimaryPart.Position + Vector3.new(math.random(-3, 3), math.random(0, 5), math.random(-3, 3))

		EffectLibrary.Slash(slashStart, slashEnd, Color3.fromRGB(150, 0, 0))
		EffectLibrary.Blood(target.PrimaryPart.Position + Vector3.new(0, 2, 0))

		-- Deal damage
		target.Humanoid:TakeDamage(damage / 5)
	end

	-- Final explosion of blood
	task.wait(0.3)
	EffectLibrary.Explosion(target.PrimaryPart.Position, 8, Color3.fromRGB(150, 0, 0))

	-- Lifesteal
	local totalHealing = damage * 0.5
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.Health = math.min(humanoid.Health + totalHealing, humanoid.MaxHealth)
		EffectLibrary.Heal(rootPart.Position)
	end

	print("💉 Healed", math.floor(totalHealing), "HP from lifesteal!")
end

-- Tàn Sát Hồn Phách (Massacre Soul Shatter)
function SkillEffects.MassacreSoulShatter(caster, position, radius, damage)
	radius = radius or 20

	print("💀 MASSACRE SOUL SHATTER!")

	-- Dark explosion
	EffectLibrary.Explosion(position, radius, Color3.fromRGB(100, 0, 100))

	-- Souls flying everywhere
	for i = 1, 20 do
		local randomPos = position + Vector3.new(
			math.random(-radius, radius),
			math.random(0, radius),
			math.random(-radius, radius)
		)
		EffectLibrary.Soul(randomPos)
	end

	-- Blood rain
	for i = 1, 30 do
		task.wait(0.05)
		local randomPos = position + Vector3.new(
			math.random(-radius, radius),
			10,
			math.random(-radius, radius)
		)
		EffectLibrary.Blood(randomPos)
	end

	-- Damage all enemies in radius
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= caster.Character then
			local distance = (obj.PrimaryPart.Position - position).Magnitude
			if distance <= radius then
				-- Deal massive damage
				obj.Humanoid:TakeDamage(damage)

				-- Soul explosion at each enemy
				EffectLibrary.Soul(obj.PrimaryPart.Position)
				EffectLibrary.Blood(obj.PrimaryPart.Position + Vector3.new(0, 2, 0))

				print("☠️ Dealt", damage, "damage to", obj.Name)
			end
		end
	end

	-- Heal caster for each kill
	-- TODO: Count kills and heal accordingly
end

-- ========================================
-- UTILITY SKILLS
-- ========================================

-- Tăng Tốc (Speed Boost)
function SkillEffects.SpeedBoost(caster, duration, multiplier)
	duration = duration or 5
	multiplier = multiplier or 2

	local character = caster.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	print("⚡ Speed Boost x" .. multiplier .. "!")

	-- Visual effect
	EffectLibrary.Aura(character.HumanoidRootPart, Color3.fromRGB(255, 255, 100), duration)

	-- Speed up
	local originalSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = originalSpeed * multiplier

	-- Trail effect while moving
	local trail = Instance.new("Trail")
	local att0 = Instance.new("Attachment", character.HumanoidRootPart)
	local att1 = Instance.new("Attachment", character.HumanoidRootPart)
	att1.Position = Vector3.new(0, -2, 0)

	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
	trail.Lifetime = 1
	trail.Parent = character.HumanoidRootPart

	-- Restore speed after duration
	task.delay(duration, function()
		if humanoid and humanoid.Parent then
			humanoid.WalkSpeed = originalSpeed
			trail:Destroy()
			print("⏱️ Speed boost ended")
		end
	end)
end

-- Teleport
function SkillEffects.Teleport(caster, targetPosition)
	local character = caster.Character
	if not character then return end

	local rootPart = character.HumanoidRootPart
	local startPos = rootPart.Position

	print("🌀 Teleport!")

	-- Disappear effect
	EffectLibrary.Soul(startPos)
	EffectLibrary.Explosion(startPos, 5, Color3.fromRGB(150, 0, 200))

	-- Teleport
	task.wait(0.3)
	rootPart.CFrame = CFrame.new(targetPosition)

	-- Appear effect
	EffectLibrary.Soul(targetPosition)
	EffectLibrary.Explosion(targetPosition, 5, Color3.fromRGB(150, 0, 200))
end

print("✅ SkillEffects loaded")
return SkillEffects
