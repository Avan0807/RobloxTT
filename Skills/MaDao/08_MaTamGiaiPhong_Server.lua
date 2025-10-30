-- ============================================
-- MA TÂM GIẢI PHÓNG - SERVER
-- Buff bản thân: +25% lifesteal trong 8s
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("MaTamGiaiPhongRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "MaTamGiaiPhongRemote"
	skillRemote.Parent = ReplicatedStorage
end

local lifestealPlayers = {}

local function activateMaTamGiaiPhong(player)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	-- Create lifesteal aura
	local aura = Instance.new("Part")
	aura.Name = "LifestealAura"
	aura.Shape = Enum.PartType.Ball
	aura.Size = Vector3.new(6, 6, 6)
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

	-- Blood aura particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Smoke,
		Lifetime = NumberRange.new(1, 1.5),
		Rate = 70,
		Speed = NumberRange.new(3, 7),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.5),
			NumberSequenceKeypoint.new(0.5, 2),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Blood,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LightEmission = 0.6
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(200, 0, 0), 10, 18)

	-- Store lifesteal data
	lifestealPlayers[player.UserId] = {
		character = character,
		aura = aura,
		startTime = tick(),
		lifestealPercent = 0.25  -- 25% lifesteal
	}

	print("🩸 " .. player.Name .. " activated Ma Tâm Giải Phóng! +25% lifesteal for 8s")

	-- Remove after 8s
	task.delay(8, function()
		if aura then
			aura:Destroy()
		end

		lifestealPlayers[player.UserId] = nil
		print("🩸 " .. player.Name .. "'s lifesteal buff expired")
	end)

	game.Debris:AddItem(aura, 8)
end

-- Function to check lifesteal buff and apply healing
function ApplyMaTamLifesteal(player, damageDealt)
	local data = lifestealPlayers[player.UserId]
	if not data or tick() - data.startTime >= 8 then
		return 0
	end

	local character = player.Character
	if not character then return 0 end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return 0 end

	-- Calculate heal amount
	local healAmount = damageDealt * data.lifestealPercent
	humanoid.Health = math.min(humanoid.Health + healAmount, humanoid.MaxHealth)

	return healAmount
end

skillRemote.OnServerEvent:Connect(function(player)
	activateMaTamGiaiPhong(player)
end)

print("✅ Ma Tâm Giải Phóng Server loaded!")
