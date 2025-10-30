-- ============================================
-- KIM CANG CHƯỞNG - SERVER
-- Charge 0.5s, tạo sóng chấn xuyên qua địch, knockdown
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("KimCangChuongRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "KimCangChuongRemote"
	skillRemote.Parent = ReplicatedStorage
end

local chargingPlayers = {}

local GOLDEN_COLORS = {
	Color3.fromRGB(255, 215, 0),
	Color3.fromRGB(255, 200, 0),
	Color3.fromRGB(255, 185, 0)
}

local function createChargingAura(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end

	local aura = Instance.new("Part")
	aura.Name = "GoldenPalmAura"
	aura.Shape = Enum.PartType.Ball
	aura.Size = Vector3.new(4, 4, 4)
	aura.Transparency = 0.5
	aura.CanCollide = false
	aura.Anchored = false
	aura.Material = Enum.Material.Neon
	aura.BrickColor = BrickColor.new("Gold")
	aura.Parent = workspace

	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart
	weld.Part1 = aura
	weld.Parent = aura

	local attachment = VFXUtils.CreateAttachment(aura)

	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Star,
		Lifetime = NumberRange.new(0.4, 0.7),
		Rate = 80,
		Speed = NumberRange.new(3, 8),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new(1.5),
		Color = GOLDEN_COLORS,
		LightEmission = 1
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(255, 215, 0), 10, 15)

	return aura
end

local function createShockwave(origin, direction)
	local shockwave = VFXUtils.CreateProjectile({
		Name = "GoldenPalmWave",
		Shape = Enum.PartType.Block,
		Size = Vector3.new(5, 5, 2),
		Position = origin + Vector3.new(0, 2, 0),
		Transparency = 0.3,
		BrickColor = BrickColor.new("Gold"),
		Velocity = direction * 90
	})

	-- Make it pierce through enemies
	shockwave.CanCollide = false

	local attachment = VFXUtils.CreateAttachment(shockwave)

	-- Golden wave particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Magic,
		Lifetime = NumberRange.new(0.5, 0.8),
		Rate = 100,
		Speed = NumberRange.new(5, 15),
		SpreadAngle = Vector2.new(60, 60),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2.5),
			NumberSequenceKeypoint.new(0.5, 3),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = GOLDEN_COLORS,
		LightEmission = 1
	})

	VFXUtils.CreateTrail(shockwave, {
		Lifetime = 1,
		Color = GOLDEN_COLORS,
		WidthScale = NumberSequence.new(4),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(1, 1)
		})
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(255, 215, 0), 12, 20)

	return shockwave
end

skillRemote.OnServerEvent:Connect(function(player, action, ...)
	local character = player.Character
	if not character then return end

	if action == "start_charge" then
		-- Create charging aura
		local aura = createChargingAura(character)
		chargingPlayers[player.UserId] = aura

	elseif action == "release" then
		local direction = ...
		if typeof(direction) ~= "Vector3" then
			warn("⚠️ Invalid data")
			return
		end

		-- Remove charging aura
		if chargingPlayers[player.UserId] then
			chargingPlayers[player.UserId]:Destroy()
			chargingPlayers[player.UserId] = nil
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then return end

		local origin = humanoidRootPart.Position
		local shockwave = createShockwave(origin, direction)

		local damagedEnemies = {}
		local baseDamage = 45

		-- Pierce through multiple enemies
		local touchConnection
		touchConnection = shockwave.Touched:Connect(function(hit)
			if hit and not hit:IsDescendantOf(character) then
				local targetChar = hit.Parent
				local humanoid = targetChar and targetChar:FindFirstChild("Humanoid")

				if humanoid and not damagedEnemies[targetChar] then
					-- Mark as damaged (pierce mechanic)
					damagedEnemies[targetChar] = true

					-- Damage
					humanoid:TakeDamage(baseDamage)

					-- Knockdown effect
					VFXUtils.ApplyKnockback(targetChar, direction, 60)
					VFXUtils.ApplyKnockback(targetChar, Vector3.new(0, 1, 0), 30)  -- Vertical knockback

					-- Effect on hit
					VFXUtils.CreateExplosion(hit.Position, {
						Color = GOLDEN_COLORS,
						Size = 3,
						ParticleCount = 40
					})

					print("💎 Kim Cang Chưởng pierced " .. targetChar.Name .. "! Damage: " .. baseDamage)
				end
			end
		end)

		-- Destroy after traveling 40 studs or 2 seconds
		task.delay(2, function()
			if shockwave and shockwave.Parent then
				touchConnection:Disconnect()

				-- Final explosion
				VFXUtils.CreateExplosion(shockwave.Position, {
					Color = GOLDEN_COLORS,
					Size = 6,
					ParticleCount = 80
				})

				shockwave:Destroy()
			end
		end)

		Debris:AddItem(shockwave, 2)
	end
end)

print("✅ Kim Cang Chưởng Server loaded!")
