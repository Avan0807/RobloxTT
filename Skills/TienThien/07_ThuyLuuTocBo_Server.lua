-- ============================================
-- THỦY LƯU TỐC BỘ - SERVER
-- Buff tốc độ di chuyển 25%, jump cao hơn trong 5s
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("ThuyLuuTocBoRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "ThuyLuuTocBoRemote"
	skillRemote.Parent = ReplicatedStorage
end

local WATER_COLORS = {
	Color3.fromRGB(100, 200, 255),
	Color3.fromRGB(80, 180, 255),
	Color3.fromRGB(60, 160, 255)
}

local function createWaterAura(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end

	local aura = Instance.new("Part")
	aura.Name = "WaterAura"
	aura.Shape = Enum.PartType.Ball
	aura.Size = Vector3.new(5, 5, 5)
	aura.Position = humanoidRootPart.Position
	aura.Transparency = 0.7
	aura.CanCollide = false
	aura.Anchored = false
	aura.Material = Enum.Material.Neon
	aura.BrickColor = BrickColor.new("Cyan")
	aura.Parent = workspace

	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart
	weld.Part1 = aura
	weld.C0 = CFrame.new(0, 0, 0)
	weld.Parent = aura

	local attachment = VFXUtils.CreateAttachment(aura)

	-- Water particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Spark,
		Lifetime = NumberRange.new(0.5, 1),
		Rate = 40,
		Speed = NumberRange.new(3, 6),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.CreateColorSequence(WATER_COLORS),
		LightEmission = 0.8
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(100, 200, 255), 5, 12)

	return aura
end

local function buffThuyLuuTocBo(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Save original stats
	local originalWalkSpeed = humanoid.WalkSpeed
	local originalJumpPower = humanoid.JumpPower or humanoid.JumpHeight

	-- Buff 25% speed
	humanoid.WalkSpeed = originalWalkSpeed * 1.25

	-- Buff jump
	if humanoid.UseJumpPower then
		humanoid.JumpPower = originalJumpPower * 1.3
	else
		humanoid.JumpHeight = originalJumpPower * 1.3
	end

	-- Create aura
	local aura = createWaterAura(character)

	print("💧 " .. player.Name .. " activated Thủy Lưu Tốc Bộ! Speed boosted!")

	-- Restore after 5s
	task.delay(5, function()
		humanoid.WalkSpeed = originalWalkSpeed

		if humanoid.UseJumpPower then
			humanoid.JumpPower = originalJumpPower
		else
			humanoid.JumpHeight = originalJumpPower
		end

		if aura then
			aura:Destroy()
		end

		print("💧 " .. player.Name .. "'s buff expired")
	end)
end

skillRemote.OnServerEvent:Connect(function(player)
	buffThuyLuuTocBo(player)
end)

print("✅ Thủy Lưu Tốc Bộ Server loaded!")
