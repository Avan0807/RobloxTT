-- ============================================
-- BÁT HOANG BẤT DIỆT - SERVER (CÔNG PHÁP THƯỢNG PHẨM)
-- Trong 5s, miễn khống chế và không bị stagger, nhưng giảm 30% dmg gây ra
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("BatHoangBatDietRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "BatHoangBatDietRemote"
	skillRemote.Parent = ReplicatedStorage
end

local unstoppablePlayers = {}

local UNSTOPPABLE_COLORS = {
	Color3.fromRGB(180, 150, 100),
	Color3.fromRGB(160, 130, 80),
	Color3.fromRGB(140, 110, 60)
}

local function createUnstoppableAura(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end

	local aura = Instance.new("Part")
	aura.Name = "UnstoppableAura"
	aura.Shape = Enum.PartType.Ball
	aura.Size = Vector3.new(7, 7, 7)
	aura.Transparency = 0.5
	aura.CanCollide = false
	aura.Anchored = false
	aura.Material = Enum.Material.ForceField
	aura.BrickColor = BrickColor.new("Gold")
	aura.Parent = workspace

	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart
	weld.Part1 = aura
	weld.Parent = aura

	local attachment = VFXUtils.CreateAttachment(aura)

	-- Rock armor particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Smoke,
		Lifetime = NumberRange.new(1, 1.5),
		Rate = 70,
		Speed = NumberRange.new(2, 5),
		SpreadAngle = Vector2.new(180, 180),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-50, 50),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.5),
			NumberSequenceKeypoint.new(0.5, 2),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = UNSTOPPABLE_COLORS,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LightEmission = 0.5
	})

	-- Energy particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Star,
		Lifetime = NumberRange.new(0.6, 1),
		Rate = 50,
		Speed = NumberRange.new(3, 8),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new(1.2),
		Color = {Color3.fromRGB(255, 200, 100)},
		LightEmission = 1
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(180, 150, 100), 10, 20)

	return aura
end

local function activateBatHoangBatDiet(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not humanoidRootPart then return end

	-- Activation effect
	VFXUtils.CreateExplosion(humanoidRootPart.Position, {
		Color = UNSTOPPABLE_COLORS,
		Size = 8,
		ParticleCount = 120
	})

	-- Create aura
	local aura = createUnstoppableAura(character)

	-- Disable stun/stagger states
	for _, state in ipairs({
		Enum.HumanoidStateType.FallingDown,
		Enum.HumanoidStateType.Ragdoll,
		Enum.HumanoidStateType.Seated
	}) do
		humanoid:SetStateEnabled(state, false)
	end

	-- Store unstoppable data
	unstoppablePlayers[player.UserId] = {
		character = character,
		aura = aura,
		startTime = tick(),
		damageMultiplier = 0.7  -- 30% damage reduction (deals 70% damage)
	}

	print("🛡️ " .. player.Name .. " activated BÁT HOANG BẤT DIỆT!")
	print("   - Immune to CC for 5s")
	print("   - Damage output: 70%")

	-- Revert after 5s
	task.delay(5, function()
		-- Re-enable states
		for _, state in ipairs({
			Enum.HumanoidStateType.FallingDown,
			Enum.HumanoidStateType.Ragdoll,
			Enum.HumanoidStateType.Seated
		}) do
			humanoid:SetStateEnabled(state, true)
		end

		if aura then
			aura:Destroy()
		end

		unstoppablePlayers[player.UserId] = nil

		-- End effect
		VFXUtils.CreateExplosion(humanoidRootPart.Position, {
			Color = UNSTOPPABLE_COLORS,
			Size = 6,
			ParticleCount = 80
		})

		print("🛡️ " .. player.Name .. "'s Bát Hoang Bất Diệt ended")
	end)

	game.Debris:AddItem(aura, 5)
end

-- Function to check if player is unstoppable
function IsUnstoppable(player)
	local data = unstoppablePlayers[player.UserId]
	if data and tick() - data.startTime < 5 then
		return true, data.damageMultiplier
	end
	return false, 1.0
end

skillRemote.OnServerEvent:Connect(function(player)
	activateBatHoangBatDiet(player)
end)

print("✅ Bát Hoang Bất Diệt Server loaded!")
