-- ============================================
-- HẤP HỒN TRẢM - SERVER
-- Đòn cận chiến hút HP tương ứng 5% damage gây ra
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("HapHonTramRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "HapHonTramRemote"
	skillRemote.Parent = ReplicatedStorage
end

local function createLifeDrainSlash(origin, direction)
	local slash = VFXUtils.CreateProjectile({
		Name = "LifeDrainSlash",
		Shape = Enum.PartType.Block,
		Size = Vector3.new(3, 4, 1),
		Position = origin + Vector3.new(0, 2, 0),
		Transparency = 0.4,
		BrickColor = BrickColor.new("Crimson"),
		Velocity = direction * 50
	})

	local attachment = VFXUtils.CreateAttachment(slash)

	-- Blood particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Smoke,
		Lifetime = NumberRange.new(0.4, 0.7),
		Rate = 70,
		Speed = NumberRange.new(3, 8),
		SpreadAngle = Vector2.new(40, 40),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.5),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Blood,
		LightEmission = 0.6
	})

	VFXUtils.CreateTrail(slash, {
		Lifetime = 0.6,
		Color = VFXUtils.Colors.Blood,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		})
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(200, 0, 0), 7, 12)

	return slash
end

local function performHapHonTram(player, direction)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not humanoidRootPart then return end

	local origin = humanoidRootPart.Position
	local slash = createLifeDrainSlash(origin, direction)

	local baseDamage = 35
	local lifestealPercent = 0.05

	local touchConnection
	touchConnection = slash.Touched:Connect(function(hit)
		if hit and not hit:IsDescendantOf(character) then
			local targetHumanoid = hit.Parent:FindFirstChild("Humanoid")
			if targetHumanoid then
				-- Damage
				targetHumanoid:TakeDamage(baseDamage)

				-- Lifesteal: 5% of damage dealt
				local healAmount = baseDamage * lifestealPercent
				humanoid.Health = math.min(humanoid.Health + healAmount, humanoid.MaxHealth)

				-- Effect
				VFXUtils.CreateExplosion(slash.Position, {
					Color = VFXUtils.Colors.Blood,
					Size = 3,
					ParticleCount = 50
				})

				-- Heal particles fly to player
				for i = 1, 5 do
					local healOrb = Instance.new("Part")
					healOrb.Size = Vector3.new(0.5, 0.5, 0.5)
					healOrb.Shape = Enum.PartType.Ball
					healOrb.Position = slash.Position
					healOrb.Transparency = 0.3
					healOrb.CanCollide = false
					healOrb.Material = Enum.Material.Neon
					healOrb.BrickColor = BrickColor.new("Bright red")
					healOrb.Parent = workspace

					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					bodyVelocity.Velocity = (humanoidRootPart.Position - healOrb.Position).Unit * 40
					bodyVelocity.Parent = healOrb

					Debris:AddItem(healOrb, 1)
				end

				print("💉 Hấp Hồn Trảm hit! Damage: " .. baseDamage .. ", Healed: " .. math.floor(healAmount))
			end

			touchConnection:Disconnect()
			slash:Destroy()
		end
	end)

	Debris:AddItem(slash, 2)
end

skillRemote.OnServerEvent:Connect(function(player, direction)
	if typeof(direction) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	performHapHonTram(player, direction)
end)

print("✅ Hấp Hồn Trảm Server loaded!")
