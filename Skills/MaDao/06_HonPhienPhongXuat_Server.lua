-- ============================================
-- HỒN PHIÊN PHÓNG XUẤT - SERVER
-- Thả 20 linh hồn ra tấn công diện rộng, sau 5s tự quay về hồi HP
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("HonPhienPhongXuatRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "HonPhienPhongXuatRemote"
	skillRemote.Parent = ReplicatedStorage
end

local function createSoulOrb(origin, index)
	local soul = VFXUtils.CreateProjectile({
		Name = "SoulOrb_" .. index,
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(1, 1, 1),
		Position = origin,
		Transparency = 0.5,
		BrickColor = BrickColor.new("Alder"),
		Anchored = false
	})

	-- Random direction
	local angle = (index / 20) * math.pi * 2
	local randomDir = Vector3.new(
		math.cos(angle),
		math.random(-1, 1) * 0.5,
		math.sin(angle)
	).Unit

	local bodyVelocity = soul:FindFirstChildOfClass("BodyVelocity")
	if bodyVelocity then
		bodyVelocity.Velocity = randomDir * 25
	end

	local attachment = VFXUtils.CreateAttachment(soul)

	-- Soul particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Star,
		Lifetime = NumberRange.new(0.3, 0.6),
		Rate = 40,
		Speed = NumberRange.new(2, 5),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new(0.8),
		Color = VFXUtils.Colors.Dark,
		LightEmission = 0.8
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(150, 100, 200), 4, 8)

	return soul
end

local function performHonPhienPhongXuat(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not humanoidRootPart then return end

	local origin = humanoidRootPart.Position + Vector3.new(0, 2, 0)
	local souls = {}
	local damagedEnemies = {}
	local totalDamageDealt = 0

	-- Release 20 souls
	for i = 1, 20 do
		task.delay(i * 0.05, function()
			local soul = createSoulOrb(origin, i)
			table.insert(souls, soul)

			-- Damage enemies
			local touchConnection
			touchConnection = soul.Touched:Connect(function(hit)
				if hit and not hit:IsDescendantOf(character) then
					local targetChar = hit.Parent
					local targetHumanoid = targetChar and targetChar:FindFirstChild("Humanoid")

					if targetHumanoid and not damagedEnemies[targetChar] then
						damagedEnemies[targetChar] = true
						local damage = 10
						targetHumanoid:TakeDamage(damage)
						totalDamageDealt = totalDamageDealt + damage

						VFXUtils.CreateExplosion(soul.Position, {
							Color = VFXUtils.Colors.Dark,
							Size = 1.5,
							ParticleCount = 20
						})
					end
				end
			end)

			-- Return to player after 5s
			task.delay(5, function()
				if soul and soul.Parent and humanoidRootPart.Parent then
					touchConnection:Disconnect()

					local returning = true
					local heartbeat
					heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
						if not soul or not soul.Parent or not humanoidRootPart.Parent then
							if heartbeat then heartbeat:Disconnect() end
							if soul then soul:Destroy() end
							return
						end

						local bodyVelocity = soul:FindFirstChildOfClass("BodyVelocity")
						if bodyVelocity then
							local direction = (humanoidRootPart.Position - soul.Position).Unit
							bodyVelocity.Velocity = direction * 40

							-- Check if close enough
							if (humanoidRootPart.Position - soul.Position).Magnitude < 3 then
								-- Heal player
								local healAmount = 3
								humanoid.Health = math.min(humanoid.Health + healAmount, humanoid.MaxHealth)

								heartbeat:Disconnect()
								soul:Destroy()
							end
						end
					end)
				end
			end)

			Debris:AddItem(soul, 7)
		end)
	end

	print("👻💫 " .. player.Name .. " released 20 souls!")
end

skillRemote.OnServerEvent:Connect(function(player)
	performHonPhienPhongXuat(player)
end)

print("✅ Hồn Phiên Phóng Xuất Server loaded!")
