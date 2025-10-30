-- ============================================
-- HỦY DIỆT LINH THỂ - SERVER (ULTIMATE)
-- Hấp toàn bộ linh hồn quanh 15m, gây sát thương theo tổng linh hồn đã hút
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("HuyDietLinhTheRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "HuyDietLinhTheRemote"
	skillRemote.Parent = ReplicatedStorage
end

local absorbingPlayers = {}

local function createAbsorbVortex(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end

	local vortex = Instance.new("Part")
	vortex.Name = "SoulVortex"
	vortex.Shape = Enum.PartType.Ball
	vortex.Size = Vector3.new(5, 5, 5)
	vortex.Position = humanoidRootPart.Position + Vector3.new(0, 3, 0)
	vortex.Transparency = 0.5
	vortex.CanCollide = false
	vortex.Anchored = false
	vortex.Material = Enum.Material.Neon
	vortex.BrickColor = BrickColor.new("Royal purple")
	vortex.Parent = workspace

	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart
	weld.Part1 = vortex
	weld.C0 = CFrame.new(0, 3, 0)
	weld.Parent = vortex

	local attachment = VFXUtils.CreateAttachment(vortex)

	-- Vortex particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Magic,
		Lifetime = NumberRange.new(1, 2),
		Rate = 120,
		Speed = NumberRange.new(10, 25),
		SpreadAngle = Vector2.new(180, 180),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(200, 400),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2),
			NumberSequenceKeypoint.new(0.5, 3),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Dark,
		LightEmission = 1
	})

	-- Soul wisps being absorbed
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Star,
		Lifetime = NumberRange.new(0.8, 1.5),
		Rate = 80,
		Speed = NumberRange.new(15, 30),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new(1.5),
		Color = {Color3.fromRGB(150, 100, 200), Color3.fromRGB(100, 50, 150)},
		LightEmission = 1
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(150, 0, 200), 15, 30)

	return vortex
end

skillRemote.OnServerEvent:Connect(function(player, action, ...)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if action == "start_absorb" then
		-- Start absorbing souls
		local vortex = createAbsorbVortex(character)

		absorbingPlayers[player.UserId] = {
			character = character,
			vortex = vortex,
			startTime = tick(),
			soulsAbsorbed = 0
		}

		-- Absorb souls from nearby enemies
		local absorbing = true
		local heartbeat
		heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
			if not absorbingPlayers[player.UserId] then
				heartbeat:Disconnect()
				return
			end

			if not humanoidRootPart or not humanoidRootPart.Parent then
				heartbeat:Disconnect()
				return
			end

			-- Pull souls from enemies in 15m radius
			local hitParts = workspace:GetPartBoundsInRadius(humanoidRootPart.Position, 15)
			for _, part in ipairs(hitParts) do
				local targetChar = part.Parent
				local targetHumanoid = targetChar and targetChar:FindFirstChild("Humanoid")

				if targetHumanoid and targetChar ~= character then
					-- Drain soul essence (small continuous damage)
					targetHumanoid:TakeDamage(0.5)
					absorbingPlayers[player.UserId].soulsAbsorbed = absorbingPlayers[player.UserId].soulsAbsorbed + 0.5

					-- Visual: Soul particles flying to caster
					local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
					if targetRoot and math.random() < 0.1 then
						local soulParticle = Instance.new("Part")
						soulParticle.Size = Vector3.new(0.5, 0.5, 0.5)
						soulParticle.Shape = Enum.PartType.Ball
						soulParticle.Position = targetRoot.Position + Vector3.new(0, 2, 0)
						soulParticle.Transparency = 0.3
						soulParticle.CanCollide = false
						soulParticle.Material = Enum.Material.Neon
						soulParticle.BrickColor = BrickColor.new("Alder")
						soulParticle.Parent = workspace

						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
						bodyVelocity.Velocity = (humanoidRootPart.Position + Vector3.new(0, 3, 0) - soulParticle.Position).Unit * 40
						bodyVelocity.Parent = soulParticle

						Debris:AddItem(soulParticle, 1)
					end
				end
			end
		end)

		print("💀 " .. player.Name .. " is absorbing souls...")

	elseif action == "release" then
		local absorbPercent = ...
		if typeof(absorbPercent) ~= "number" then
			warn("⚠️ Invalid data")
			return
		end

		local data = absorbingPlayers[player.UserId]
		if not data then return end

		-- Remove vortex
		if data.vortex then
			data.vortex:Destroy()
		end

		-- Calculate final damage
		local baseDamage = 100
		local soulBonus = data.soulsAbsorbed * 2
		local chargeBonus = absorbPercent * 50
		local finalDamage = baseDamage + soulBonus + chargeBonus

		local explosionRadius = 15 + (absorbPercent * 10)

		-- Massive soul explosion
		if humanoidRootPart then
			for i = 1, 5 do
				task.delay(i * 0.1, function()
					VFXUtils.CreateExplosion(humanoidRootPart.Position, {
						Color = VFXUtils.Colors.Dark,
						Size = 10 + (i * 3),
						ParticleCount = 150,
						LightColor = Color3.fromRGB(150, 0, 200)
					})
				end)
			end

			-- Damage all enemies
			VFXUtils.DamageInRadius(humanoidRootPart.Position, explosionRadius, finalDamage, {character})

			-- Knockback
			local hitParts = workspace:GetPartBoundsInRadius(humanoidRootPart.Position, explosionRadius)
			for _, part in ipairs(hitParts) do
				local targetChar = part.Parent
				if targetChar and targetChar ~= character then
					local direction = (part.Position - humanoidRootPart.Position).Unit
					VFXUtils.ApplyKnockback(targetChar, direction, 100)
				end
			end

			print("💀💥💥💥 " .. player.Name .. " DETONATED SOULS!")
			print("   Total Damage: " .. math.floor(finalDamage))
			print("   Souls Absorbed: " .. math.floor(data.soulsAbsorbed))
		end

		absorbingPlayers[player.UserId] = nil
	end
end)

print("✅ ULTIMATE: Hủy Diệt Linh Thể Server loaded!")
