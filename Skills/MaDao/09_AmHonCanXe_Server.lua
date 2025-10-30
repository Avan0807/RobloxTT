-- ============================================
-- ÂM HỒN CẮN XÉ - SERVER
-- Combo 2 hit: lần 1 gây damage thường, lần 2 hút linh hồn địch (stun 0.5s)
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("AmHonCanXeRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "AmHonCanXeRemote"
	skillRemote.Parent = ReplicatedStorage
end

local function createSoulSlash(origin, direction, comboNumber)
	local slash = VFXUtils.CreateProjectile({
		Name = "SoulBite_" .. comboNumber,
		Shape = Enum.PartType.Block,
		Size = Vector3.new(3, 4, 1.5),
		Position = origin + Vector3.new(0, 2, 0),
		Transparency = 0.4,
		BrickColor = BrickColor.new("Dark indigo"),
		Velocity = direction * 60
	})

	local attachment = VFXUtils.CreateAttachment(slash)

	local colors = comboNumber == 1 and VFXUtils.Colors.Dark or {
		Color3.fromRGB(200, 0, 200),
		Color3.fromRGB(150, 0, 150),
		Color3.fromRGB(100, 0, 100)
	}

	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Magic,
		Lifetime = NumberRange.new(0.4, 0.7),
		Rate = 70,
		Speed = NumberRange.new(5, 12),
		SpreadAngle = Vector2.new(40, 40),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2),
			NumberSequenceKeypoint.new(0.5, 2.5),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = colors,
		LightEmission = 0.9
	})

	VFXUtils.CreateTrail(slash, {
		Lifetime = 0.6,
		Color = colors,
		WidthScale = NumberSequence.new(2)
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(150, 0, 200), 7, 12)

	return slash
end

local function performAmHonCanXe(player, comboNumber, direction)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not humanoidRootPart then return end

	local origin = humanoidRootPart.Position
	local slash = createSoulSlash(origin, direction, comboNumber)

	local damages = {25, 35}  -- Hit 2 deals more damage

	local touchConnection
	touchConnection = slash.Touched:Connect(function(hit)
		if hit and not hit:IsDescendantOf(character) then
			local targetChar = hit.Parent
			local targetHumanoid = targetChar and targetChar:FindFirstChild("Humanoid")

			if targetHumanoid then
				-- Damage
				targetHumanoid:TakeDamage(damages[comboNumber])

				if comboNumber == 2 then
					-- Soul drain effect + Stun 0.5s
					local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
					if targetRoot then
						-- Stun (freeze)
						local originalWalkSpeed = targetHumanoid.WalkSpeed
						targetHumanoid.WalkSpeed = 0

						-- Soul drain visual
						for i = 1, 10 do
							local soulParticle = Instance.new("Part")
							soulParticle.Size = Vector3.new(0.5, 0.5, 0.5)
							soulParticle.Shape = Enum.PartType.Ball
							soulParticle.Position = targetRoot.Position + Vector3.new(math.random(-2, 2), math.random(0, 3), math.random(-2, 2))
							soulParticle.Transparency = 0.3
							soulParticle.CanCollide = false
							soulParticle.Material = Enum.Material.Neon
							soulParticle.BrickColor = BrickColor.new("Alder")
							soulParticle.Parent = workspace

							local bodyVelocity = Instance.new("BodyVelocity")
							bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
							bodyVelocity.Velocity = (humanoidRootPart.Position - soulParticle.Position).Unit * 30
							bodyVelocity.Parent = soulParticle

							Debris:AddItem(soulParticle, 1)
						end

						-- Heal caster
						humanoid.Health = math.min(humanoid.Health + 15, humanoid.MaxHealth)

						-- Unstun after 0.5s
						task.delay(0.5, function()
							targetHumanoid.WalkSpeed = originalWalkSpeed
						end)

						print("👻💫 Âm Hồn Cắn Xé HIT 2! Soul drained + Stunned 0.5s")
					end
				else
					print("👻 Âm Hồn Cắn Xé Hit 1 - Damage: " .. damages[1])
				end

				VFXUtils.CreateExplosion(slash.Position, {
					Color = comboNumber == 2 and {Color3.fromRGB(200, 0, 200)} or VFXUtils.Colors.Dark,
					Size = 3,
					ParticleCount = 50
				})

				touchConnection:Disconnect()
				slash:Destroy()
			end
		end
	end)

	Debris:AddItem(slash, 2)
end

skillRemote.OnServerEvent:Connect(function(player, comboNumber, direction)
	if typeof(comboNumber) ~= "number" or typeof(direction) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	performAmHonCanXe(player, comboNumber, direction)
end)

print("✅ Âm Hồn Cắn Xé Server loaded!")
