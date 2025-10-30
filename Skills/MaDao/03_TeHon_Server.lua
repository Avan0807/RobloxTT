-- ============================================
-- TẾ HỒN - SERVER
-- Sacrifice 10% HP để hồi 20% năng lượng + tăng 15% speed 5s
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("TeHonRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "TeHonRemote"
	skillRemote.Parent = ReplicatedStorage
end

local SACRIFICE_COLORS = {
	Color3.fromRGB(150, 0, 0),
	Color3.fromRGB(100, 0, 0),
	Color3.fromRGB(80, 0, 0)
}

local function performTeHon(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not humanoidRootPart then return end

	-- Sacrifice 10% HP
	local sacrificeCost = humanoid.MaxHealth * 0.1
	humanoid:TakeDamage(sacrificeCost)

	-- Sacrifice effect
	VFXUtils.CreateExplosion(humanoidRootPart.Position, {
		Color = SACRIFICE_COLORS,
		Size = 5,
		ParticleCount = 80,
		LightColor = Color3.fromRGB(150, 0, 0)
	})

	-- Buff speed 15% for 5s
	local originalSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = originalSpeed * 1.15

	-- Create buff aura
	local aura = Instance.new("Part")
	aura.Name = "SacrificeAura"
	aura.Shape = Enum.PartType.Ball
	aura.Size = Vector3.new(4, 4, 4)
	aura.Transparency = 0.7
	aura.CanCollide = false
	aura.Anchored = false
	aura.Material = Enum.Material.Neon
	aura.BrickColor = BrickColor.new("Crimson")
	aura.Parent = workspace

	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart
	weld.Part1 = aura
	weld.Parent = aura

	local attachment = VFXUtils.CreateAttachment(aura)

	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Smoke,
		Lifetime = NumberRange.new(0.6, 1),
		Rate = 50,
		Speed = NumberRange.new(2, 5),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new(1.2),
		Color = SACRIFICE_COLORS,
		LightEmission = 0.7
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(150, 0, 0), 8, 15)

	print("🩸 " .. player.Name .. " sacrificed HP! Speed +15% for 5s")

	-- Revert after 5s
	task.delay(5, function()
		humanoid.WalkSpeed = originalSpeed
		aura:Destroy()
		print("🩸 " .. player.Name .. "'s sacrifice buff ended")
	end)

	game.Debris:AddItem(aura, 5)
end

skillRemote.OnServerEvent:Connect(function(player)
	performTeHon(player)
end)

print("✅ Tế Hồn Server loaded!")
