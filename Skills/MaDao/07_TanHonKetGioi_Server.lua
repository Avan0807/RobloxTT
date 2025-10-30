-- ============================================
-- TÀN HỒN KẾT GIỚI - SERVER
-- Vùng 8m hút HP/giây từ địch (địch có thể dodge ra ngoài)
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("TanHonKetGioiRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "TanHonKetGioiRemote"
	skillRemote.Parent = ReplicatedStorage
end

local function createDrainZone(position, casterChar, casterHumanoid)
	local zone = Instance.new("Part")
	zone.Name = "SoulDrainZone"
	zone.Shape = Enum.PartType.Cylinder
	zone.Size = Vector3.new(0.5, 16, 16)
	zone.Position = position + Vector3.new(0, 0.3, 0)
	zone.Orientation = Vector3.new(0, 0, 90)
	zone.Transparency = 0.7
	zone.CanCollide = false
	zone.Anchored = true
	zone.Material = Enum.Material.Neon
	zone.BrickColor = BrickColor.new("Royal purple")
	zone.Parent = workspace

	local attachment = VFXUtils.CreateAttachment(zone)

	-- Drain particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Smoke,
		Lifetime = NumberRange.new(2, 3),
		Rate = 80,
		Speed = NumberRange.new(3, 8),
		SpreadAngle = Vector2.new(30, 30),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(50, 100),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 2),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Dark,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LightEmission = 0.7
	})

	-- Soul wisps
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Star,
		Lifetime = NumberRange.new(1.5, 2.5),
		Rate = 50,
		Speed = NumberRange.new(2, 5),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new(1),
		Color = {Color3.fromRGB(150, 0, 200), Color3.fromRGB(100, 0, 150)},
		LightEmission = 1
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(150, 0, 200), 10, 20)

	-- Drain enemies every 0.5s for 6 seconds
	local duration = 6
	local startTime = tick()
	local damagePerTick = 8

	local heartbeat
	heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
		if tick() - startTime >= duration then
			heartbeat:Disconnect()
			zone:Destroy()
			return
		end

		-- Every 0.5s
		if (tick() - startTime) % 0.5 < 0.016 then
			local hitParts = workspace:GetPartBoundsInRadius(position, 8)
			for _, part in ipairs(hitParts) do
				local targetChar = part.Parent
				local targetHumanoid = targetChar and targetChar:FindFirstChild("Humanoid")

				if targetHumanoid and targetChar ~= casterChar then
					-- Drain HP
					targetHumanoid:TakeDamage(damagePerTick)

					-- Heal caster
					if casterHumanoid then
						casterHumanoid.Health = math.min(casterHumanoid.Health + damagePerTick * 0.3, casterHumanoid.MaxHealth)
					end

					-- Visual: HP drain particles
					local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
					if targetRoot then
						for i = 1, 3 do
							local drainParticle = Instance.new("Part")
							drainParticle.Size = Vector3.new(0.3, 0.3, 0.3)
							drainParticle.Shape = Enum.PartType.Ball
							drainParticle.Position = targetRoot.Position + Vector3.new(math.random(-2, 2), math.random(0, 3), math.random(-2, 2))
							drainParticle.Transparency = 0.4
							drainParticle.CanCollide = false
							drainParticle.Material = Enum.Material.Neon
							drainParticle.BrickColor = BrickColor.new("Bright red")
							drainParticle.Parent = workspace

							local bodyVelocity = Instance.new("BodyVelocity")
							bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
							bodyVelocity.Velocity = (position - drainParticle.Position).Unit * 20
							bodyVelocity.Parent = drainParticle

							Debris:AddItem(drainParticle, 1)
						end
					end
				end
			end
		end
	end)

	Debris:AddItem(zone, duration)
end

local function castTanHonKetGioi(player, targetPosition)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")

	createDrainZone(targetPosition, character, humanoid)

	print("⚫ " .. player.Name .. " created Tàn Hồn Kết Giới! Draining enemies...")
end

skillRemote.OnServerEvent:Connect(function(player, targetPosition)
	if typeof(targetPosition) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	castTanHonKetGioi(player, targetPosition)
end)

print("✅ Tàn Hồn Kết Giới Server loaded!")
