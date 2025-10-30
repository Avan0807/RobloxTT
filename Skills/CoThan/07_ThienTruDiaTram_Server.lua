-- ============================================
-- THIÊN TRỤ ĐỊA TRẢM - SERVER
-- Nhảy lên đập đất, tạo shockwave 5m
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("ThienTruDiaTramRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "ThienTruDiaTramRemote"
	skillRemote.Parent = ReplicatedStorage
end

local EARTH_COLORS = {
	Color3.fromRGB(139, 90, 43),
	Color3.fromRGB(120, 75, 35),
	Color3.fromRGB(100, 60, 25)
}

local function createGroundCrack(position)
	-- Ground crack effect
	local crack = Instance.new("Part")
	crack.Name = "GroundCrack"
	crack.Shape = Enum.PartType.Cylinder
	crack.Size = Vector3.new(0.5, 10, 10)
	crack.Position = position + Vector3.new(0, 0.2, 0)
	crack.Orientation = Vector3.new(0, 0, 90)
	crack.Transparency = 0.4
	crack.CanCollide = false
	crack.Anchored = true
	crack.Material = Enum.Material.Rock
	crack.BrickColor = BrickColor.new("Brown")
	crack.Parent = workspace

	-- Expand crack
	local expandTween = TweenService:Create(
		crack,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = Vector3.new(0.5, 20, 20), Transparency = 1}
	)
	expandTween:Play()

	Debris:AddItem(crack, 1)

	return crack
end

local function createShockwave(position)
	-- Create expanding ring
	for i = 1, 3 do
		task.delay(i * 0.1, function()
			local ring = Instance.new("Part")
			ring.Name = "Shockwave"
			ring.Shape = Enum.PartType.Cylinder
			ring.Size = Vector3.new(0.5, 3, 3)
			ring.Position = position + Vector3.new(0, 0.3, 0)
			ring.Orientation = Vector3.new(0, 0, 90)
			ring.Transparency = 0.5
			ring.CanCollide = false
			ring.Anchored = true
			ring.Material = Enum.Material.Neon
			ring.BrickColor = BrickColor.new("Deep orange")
			ring.Parent = workspace

			local attachment = VFXUtils.CreateAttachment(ring)

			-- Debris particles
			VFXUtils.CreateParticle({
				Parent = attachment,
				Texture = VFXUtils.Textures.Smoke,
				Lifetime = NumberRange.new(0.5, 0.8),
				Rate = 0,
				Speed = NumberRange.new(10, 20),
				SpreadAngle = Vector2.new(180, 30),
				Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1.5),
					NumberSequenceKeypoint.new(1, 0)
				}),
				Color = EARTH_COLORS,
				LightEmission = 0.3,
				EmitCount = 40
			}):Emit(40)

			-- Expand ring
			local expandTween = TweenService:Create(
				ring,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Size = Vector3.new(0.5, 15 + (i * 5), 15 + (i * 5)), Transparency = 1}
			)
			expandTween:Play()

			Debris:AddItem(ring, 1)
		end)
	end
end

local function performThienTruDiaTram(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not humanoidRootPart then return end

	local startPos = humanoidRootPart.Position
	local jumpHeight = 15

	-- Phase 1: Jump up
	humanoidRootPart.Velocity = Vector3.new(0, 60, 0)

	print("🌍 " .. player.Name .. " jumping...")

	-- Wait until reaching peak or 0.5s
	task.wait(0.5)

	-- Phase 2: Slam down
	local groundPos = startPos

	-- Check ground level using raycast
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {character}
	local ray = workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, -100, 0), rayParams)

	if ray then
		groundPos = ray.Position
	end

	-- Force to ground
	humanoidRootPart.CFrame = CFrame.new(groundPos + Vector3.new(0, 3, 0))
	humanoidRootPart.Velocity = Vector3.new(0, -100, 0)

	-- Wait for impact
	task.wait(0.1)

	-- Create impact effects
	createGroundCrack(groundPos)
	createShockwave(groundPos)

	-- Explosion
	VFXUtils.CreateExplosion(groundPos, {
		Color = EARTH_COLORS,
		Size = 8,
		ParticleCount = 100,
		LightColor = Color3.fromRGB(139, 90, 43)
	})

	-- Damage in radius
	VFXUtils.DamageInRadius(groundPos, 10, 50, {character})

	-- Knockup enemies
	local hitParts = workspace:GetPartBoundsInRadius(groundPos, 10)
	for _, part in ipairs(hitParts) do
		local targetChar = part.Parent
		local humanoid = targetChar and targetChar:FindFirstChild("Humanoid")

		if humanoid and targetChar ~= character then
			VFXUtils.ApplyKnockback(targetChar, Vector3.new(0, 1, 0), 50)

			local direction = (part.Position - groundPos).Unit
			VFXUtils.ApplyKnockback(targetChar, direction, 30)
		end
	end

	print("🌍💥 " .. player.Name .. " GROUND SLAMMED!")
end

skillRemote.OnServerEvent:Connect(function(player)
	performThienTruDiaTram(player)
end)

print("✅ Thiên Trụ Địa Trảm Server loaded!")
