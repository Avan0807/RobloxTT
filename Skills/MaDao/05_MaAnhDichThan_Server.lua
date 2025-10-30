-- ============================================
-- MA ẢNH DỊCH THÂN - SERVER
-- Lướt 6m, để lại bóng tự nổ gây 150% dmg (iframe 0.3s)
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("MaAnhDichThanRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "MaAnhDichThanRemote"
	skillRemote.Parent = ReplicatedStorage
end

local function createExplodingShadow(position, casterChar)
	local shadow = Instance.new("Part")
	shadow.Name = "ExplodingShadow"
	shadow.Size = Vector3.new(2, 5, 1)
	shadow.Position = position
	shadow.Transparency = 0.4
	shadow.CanCollide = false
	shadow.Anchored = true
	shadow.Material = Enum.Material.Neon
	shadow.BrickColor = BrickColor.new("Really black")
	shadow.Parent = workspace

	local attachment = VFXUtils.CreateAttachment(shadow)

	-- Shadow particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Smoke,
		Lifetime = NumberRange.new(0.5, 1),
		Rate = 50,
		Speed = NumberRange.new(1, 4),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.5),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Dark,
		LightEmission = 0.5
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(100, 0, 150), 6, 12)

	-- Auto-explode after 1 second
	task.delay(1, function()
		if shadow.Parent then
			-- Explosion
			VFXUtils.CreateExplosion(shadow.Position, {
				Color = VFXUtils.Colors.Dark,
				Size = 5,
				ParticleCount = 80,
				LightColor = Color3.fromRGB(150, 0, 200)
			})

			-- Damage
			VFXUtils.DamageInRadius(shadow.Position, 6, 45, {casterChar})  -- 150% of 30 base

			print("👤💥 Shadow exploded!")
			shadow:Destroy()
		end
	end)

	Debris:AddItem(shadow, 1.5)
end

local function performMaAnhDichThan(player, oldPosition, direction)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	-- Create shadow at old position
	createExplodingShadow(oldPosition, character)

	-- Dash 6m
	local newPosition = oldPosition + (direction * 6)
	humanoidRootPart.CFrame = CFrame.new(newPosition)

	-- Iframe 0.3s
	local originalCanCollide = humanoidRootPart.CanCollide
	humanoidRootPart.CanCollide = false

	-- Dash effect
	VFXUtils.CreateExplosion(newPosition, {
		Color = VFXUtils.Colors.Dark,
		Size = 2,
		ParticleCount = 30
	})

	task.wait(0.3)
	humanoidRootPart.CanCollide = originalCanCollide

	print("👤 " .. player.Name .. " dashed with Ma Ảnh Dịch Thân!")
end

skillRemote.OnServerEvent:Connect(function(player, oldPosition, direction)
	if typeof(oldPosition) ~= "Vector3" or typeof(direction) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	performMaAnhDichThan(player, oldPosition, direction)
end)

print("✅ Ma Ảnh Dịch Thân Server loaded!")
