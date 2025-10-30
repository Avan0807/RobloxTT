-- ============================================
-- LINH HỒN TRẢM - SERVER (MA ĐẠO)
-- Slash linh hồn, gây 200% Soul Dmg, xuyên 25% giáp
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("LinhHonTramRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "LinhHonTramRemote"
	skillRemote.Parent = ReplicatedStorage
end

local SOUL_COLORS = {
	Color3.fromRGB(150, 0, 200),
	Color3.fromRGB(120, 0, 180),
	Color3.fromRGB(100, 0, 150),
	Color3.fromRGB(80, 0, 120)
}

local function createSoulSlash(origin, direction)
	local slash = VFXUtils.CreateProjectile({
		Name = "SoulSlash",
		Shape = Enum.PartType.Block,
		Size = Vector3.new(4, 6, 1),
		Position = origin + Vector3.new(0, 2, 0),
		Transparency = 0.4,
		BrickColor = BrickColor.new("Royal purple"),
		Velocity = direction * 70
	})

	local attachment = VFXUtils.CreateAttachment(slash)

	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Magic,
		Lifetime = NumberRange.new(0.4, 0.7),
		Rate = 80,
		Speed = NumberRange.new(5, 12),
		SpreadAngle = Vector2.new(40, 40),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2),
			NumberSequenceKeypoint.new(0.5, 3),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = SOUL_COLORS,
		LightEmission = 0.8
	})

	VFXUtils.CreateTrail(slash, {
		Lifetime = 0.8,
		Color = SOUL_COLORS,
		WidthScale = NumberSequence.new(3)
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(150, 0, 200), 8, 15)

	return slash
end

local function performLinhHonTram(player, direction)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local origin = humanoidRootPart.Position
	local slash = createSoulSlash(origin, direction)

	local touchConnection
	touchConnection = slash.Touched:Connect(function(hit)
		if hit and not hit:IsDescendantOf(character) then
			local humanoid = hit.Parent:FindFirstChild("Humanoid")
			if humanoid then
				-- 200% Soul Damage (bypasses 25% armor)
				local baseDamage = 30
				local soulDamage = baseDamage * 2
				humanoid:TakeDamage(soulDamage)

				VFXUtils.CreateExplosion(slash.Position, {
					Color = SOUL_COLORS,
					Size = 4,
					ParticleCount = 60,
					LightColor = Color3.fromRGB(150, 0, 200)
				})

				print("👻 Linh Hồn Trảm - Soul Damage: " .. soulDamage)
			end

			touchConnection:Disconnect()
			slash:Destroy()
		end
	end)

	game.Debris:AddItem(slash, 3)
end

skillRemote.OnServerEvent:Connect(function(player, direction)
	if typeof(direction) ~= "Vector3" then return end
	performLinhHonTram(player, direction)
end)

print("✅ Linh Hồn Trảm Server loaded!")
