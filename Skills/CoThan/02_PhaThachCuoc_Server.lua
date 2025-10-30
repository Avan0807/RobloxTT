-- ============================================
-- PHÁ THẠCH CƯỚC - SERVER
-- Đá mạnh ra trước, nếu trúng tường/địa hình → gây thêm 200% damage
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("PhaThachCuocRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "PhaThachCuocRemote"
	skillRemote.Parent = ReplicatedStorage
end

local KICK_COLORS = {
	Color3.fromRGB(200, 150, 100),
	Color3.fromRGB(180, 130, 80),
	Color3.fromRGB(160, 110, 60)
}

local function createKickWave(origin, direction)
	local kick = VFXUtils.CreateProjectile({
		Name = "RockBreakingKick",
		Shape = Enum.PartType.Block,
		Size = Vector3.new(3, 2, 4),
		Position = origin + Vector3.new(0, 1, 0),
		Transparency = 0.5,
		BrickColor = BrickColor.new("Brown"),
		Velocity = direction * 70
	})

	local attachment = VFXUtils.CreateAttachment(kick)

	-- Rock particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Smoke,
		Lifetime = NumberRange.new(0.5, 0.9),
		Rate = 60,
		Speed = NumberRange.new(5, 12),
		SpreadAngle = Vector2.new(50, 50),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2),
			NumberSequenceKeypoint.new(0.5, 2.5),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = KICK_COLORS,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LightEmission = 0.3
	})

	VFXUtils.CreateTrail(kick, {
		Lifetime = 0.7,
		Color = KICK_COLORS,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(1, 1)
		})
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(200, 150, 100), 5, 10)

	return kick
end

local function performPhaThachCuoc(player, direction)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local origin = humanoidRootPart.Position
	local kick = createKickWave(origin, direction)

	local baseDamage = 35
	local hitWall = false

	local touchConnection
	touchConnection = kick.Touched:Connect(function(hit)
		if hit and not hit:IsDescendantOf(character) then
			-- Check if hit wall/terrain
			if hit:IsA("Terrain") or (hit:IsA("Part") and hit.Anchored) then
				hitWall = true

				-- 200% damage bonus
				local wallDamage = baseDamage * 3  -- 100% + 200% = 300%

				-- Find enemies nearby
				VFXUtils.DamageInRadius(kick.Position, 8, wallDamage, {character})

				-- Massive explosion
				VFXUtils.CreateExplosion(kick.Position, {
					Color = KICK_COLORS,
					Size = 7,
					ParticleCount = 120,
					LightColor = Color3.fromRGB(200, 150, 100)
				})

				-- Extra rock debris
				for i = 1, 10 do
					local debris = Instance.new("Part")
					debris.Size = Vector3.new(1, 1, 1)
					debris.Position = kick.Position
					debris.BrickColor = BrickColor.new("Brown")
					debris.Material = Enum.Material.Rock
					debris.CanCollide = false
					debris.Parent = workspace

					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					bodyVelocity.Velocity = Vector3.new(
						math.random(-30, 30),
						math.random(20, 40),
						math.random(-30, 30)
					)
					bodyVelocity.Parent = debris

					Debris:AddItem(debris, 2)
				end

				print("🦵💥 PHÁ THẠCH CƯỚC HIT WALL! 200% BONUS DAMAGE: " .. wallDamage)

			else
				-- Normal hit
				local humanoid = hit.Parent:FindFirstChild("Humanoid")
				if humanoid then
					humanoid:TakeDamage(baseDamage)
					VFXUtils.ApplyKnockback(hit.Parent, direction, 40)

					VFXUtils.CreateExplosion(kick.Position, {
						Color = KICK_COLORS,
						Size = 4,
						ParticleCount = 50
					})

					print("🦵 Phá Thạch Cước hit! Damage: " .. baseDamage)
				end
			end

			touchConnection:Disconnect()
			kick:Destroy()
		end
	end)

	Debris:AddItem(kick, 3)
end

skillRemote.OnServerEvent:Connect(function(player, direction)
	if typeof(direction) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	performPhaThachCuoc(player, direction)
end)

print("✅ Phá Thạch Cước Server loaded!")
