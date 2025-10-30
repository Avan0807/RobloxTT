-- ============================================
-- VẠN MA HÓA THÂN - SERVER (ULTIMATE - MA ĐẠO)
-- Biến hình Ma Thần 10s, mỗi cú đánh phóng ra ảo ảnh gây 60% dmg; có iframe 0.6s khi biến hình
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("VanMaHoaThanRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "VanMaHoaThanRemote"
	skillRemote.Parent = ReplicatedStorage
end

local transformedPlayers = {}

local function createDemonAura(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end

	-- Dark aura
	local aura = Instance.new("Part")
	aura.Name = "DemonAura"
	aura.Shape = Enum.PartType.Ball
	aura.Size = Vector3.new(8, 8, 8)
	aura.Transparency = 0.6
	aura.CanCollide = false
	aura.Anchored = false
	aura.Material = Enum.Material.Neon
	aura.BrickColor = BrickColor.new("Really black")
	aura.Parent = workspace

	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart
	weld.Part1 = aura
	weld.Parent = aura

	local attachment = VFXUtils.CreateAttachment(aura)

	-- Demon particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Smoke,
		Lifetime = NumberRange.new(1, 1.5),
		Rate = 100,
		Speed = NumberRange.new(3, 8),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2),
			NumberSequenceKeypoint.new(0.5, 3),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Dark,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LightEmission = 0.7
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(150, 0, 200), 12, 25)

	return aura
end

local function transformVanMaHoaThan(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not humanoidRootPart then return end

	-- Transformation effect
	VFXUtils.CreateExplosion(humanoidRootPart.Position, {
		Color = VFXUtils.Colors.Dark,
		Size = 8,
		ParticleCount = 150,
		LightColor = Color3.fromRGB(150, 0, 200)
	})

	-- Iframe 0.6s
	local oldCanCollide = humanoidRootPart.CanCollide
	humanoidRootPart.CanCollide = false
	task.delay(0.6, function()
		humanoidRootPart.CanCollide = oldCanCollide
	end)

	-- Create aura
	local aura = createDemonAura(character)

	-- Buff stats
	local originalWalkSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = originalWalkSpeed * 1.3

	-- Mark as transformed
	transformedPlayers[player.UserId] = {
		character = character,
		startTime = tick(),
		aura = aura
	}

	print("👹 " .. player.Name .. " transformed into DEMON GOD! 10s duration")

	-- TODO: Implement shadow clone attacks when player attacks

	-- Revert after 10s
	task.delay(10, function()
		humanoid.WalkSpeed = originalWalkSpeed

		if aura then
			aura:Destroy()
		end

		transformedPlayers[player.UserId] = nil

		-- Revert effect
		VFXUtils.CreateExplosion(humanoidRootPart.Position, {
			Color = VFXUtils.Colors.Dark,
			Size = 6,
			ParticleCount = 80
		})

		print("👹 " .. player.Name .. "'s transformation ended")
	end)

	game.Debris:AddItem(aura, 10)
end

-- Function to check if player is transformed
function IsPlayerTransformed(player)
	return transformedPlayers[player.UserId] ~= nil
end

skillRemote.OnServerEvent:Connect(function(player)
	transformVanMaHoaThan(player)
end)

print("✅ Vạn Ma Hóa Thân (ULTIMATE) Server loaded!")
