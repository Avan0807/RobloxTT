-- ============================================
-- CỔ MA THỂ HÓA - SERVER (CÔNG PHÁP THƯỢNG PHẨM)
-- Biến thân 15s, đòn melee có range gấp đôi, +100% phản damage
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("CoMaTheHoaRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "CoMaTheHoaRemote"
	skillRemote.Parent = ReplicatedStorage
end

local transformedPlayers = {}

local DEMON_COLORS = {
	Color3.fromRGB(100, 0, 0),
	Color3.fromRGB(150, 0, 0),
	Color3.fromRGB(200, 0, 0)
}

local function createDemonForm(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end

	-- Demon aura
	local aura = Instance.new("Part")
	aura.Name = "DemonAura"
	aura.Shape = Enum.PartType.Ball
	aura.Size = Vector3.new(8, 8, 8)
	aura.Transparency = 0.6
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

	-- Demon particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Fire,
		Lifetime = NumberRange.new(1, 1.5),
		Rate = 80,
		Speed = NumberRange.new(5, 12),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2),
			NumberSequenceKeypoint.new(0.5, 3),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = DEMON_COLORS,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LightEmission = 0.8
	})

	-- Dark smoke
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Smoke,
		Lifetime = NumberRange.new(1.5, 2),
		Rate = 40,
		Speed = NumberRange.new(2, 6),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = {Color3.fromRGB(50, 0, 0), Color3.fromRGB(30, 0, 0)},
		LightEmission = 0.3
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(200, 0, 0), 15, 30)

	return aura
end

local function transformCoMaTheHoa(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Transformation effect
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if humanoidRootPart then
		VFXUtils.CreateExplosion(humanoidRootPart.Position, {
			Color = DEMON_COLORS,
			Size = 10,
			ParticleCount = 200,
			LightColor = Color3.fromRGB(200, 0, 0)
		})
	end

	-- Create demon aura
	local aura = createDemonForm(character)

	-- Buff stats
	local originalWalkSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = originalWalkSpeed * 1.2

	-- Mark as transformed
	transformedPlayers[player.UserId] = {
		character = character,
		aura = aura,
		startTime = tick(),
		meleeRangeMultiplier = 2.0,  -- Double melee range
		reflectMultiplier = 2.0      -- +100% reflect damage
	}

	print("👹 " .. player.Name .. " transformed into ANCIENT DEMON! 15s duration")
	print("   - Melee range: x2")
	print("   - Reflect damage: +100%")

	-- Revert after 15s
	task.delay(15, function()
		humanoid.WalkSpeed = originalWalkSpeed

		if aura then
			aura:Destroy()
		end

		transformedPlayers[player.UserId] = nil

		-- Revert effect
		if humanoidRootPart then
			VFXUtils.CreateExplosion(humanoidRootPart.Position, {
				Color = DEMON_COLORS,
				Size = 8,
				ParticleCount = 100
			})
		end

		print("👹 " .. player.Name .. "'s transformation ended")
	end)

	game.Debris:AddItem(aura, 15)
end

-- Function to check if player is transformed
function IsCoMaTransformed(player)
	local data = transformedPlayers[player.UserId]
	if data then
		return true, data.meleeRangeMultiplier, data.reflectMultiplier
	end
	return false, 1.0, 1.0
end

skillRemote.OnServerEvent:Connect(function(player)
	transformCoMaTheHoa(player)
end)

print("✅ Cổ Ma Thể Hóa Server loaded!")
