-- ============================================
-- HỎA LIỆT QUYỀN - SERVER
-- Tung quyền lửa cận chiến, hit trúng tạo shock nổ 2m AOE
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("HoaLietQuyenRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "HoaLietQuyenRemote"
	skillRemote.Parent = ReplicatedStorage
end

local function createFireFist(origin, direction)
	local fist = VFXUtils.CreateProjectile({
		Name = "FireFist",
		Shape = Enum.PartType.Block,
		Size = Vector3.new(2, 2, 4),
		Position = origin + Vector3.new(0, 2, 0),
		Transparency = 0.6,
		BrickColor = BrickColor.new("Bright red"),
		Velocity = direction * 60
	})

	local attachment = VFXUtils.CreateAttachment(fist)

	-- Fire effect
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Fire,
		Lifetime = NumberRange.new(0.3, 0.6),
		Rate = 80,
		Speed = NumberRange.new(3, 8),
		SpreadAngle = Vector2.new(40, 40),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2),
			NumberSequenceKeypoint.new(0.5, 3),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Fire,
		LightEmission = 1
	})

	VFXUtils.CreateTrail(fist, {
		Lifetime = 0.8,
		Color = VFXUtils.Colors.Fire,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		})
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(255, 150, 0), 7, 12)

	return fist
end

local function punchHoaLietQuyen(player, direction)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local origin = humanoidRootPart.Position
	local fist = createFireFist(origin, direction)

	local touchConnection
	touchConnection = fist.Touched:Connect(function(hit)
		if hit and not hit:IsDescendantOf(character) then
			-- AOE explosion 2m
			VFXUtils.CreateExplosion(fist.Position, {
				Color = VFXUtils.Colors.Fire,
				Size = 4,
				ParticleCount = 60
			})

			-- Damage trong bán kính
			VFXUtils.DamageInRadius(fist.Position, 4, 35, {character})

			print("💥 " .. player.Name .. " hit with Hỏa Liệt Quyền!")

			touchConnection:Disconnect()
			fist:Destroy()
		end
	end)

	Debris:AddItem(fist, 2)
end

skillRemote.OnServerEvent:Connect(function(player, direction)
	if typeof(direction) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	punchHoaLietQuyen(player, direction)
end)

print("✅ Hỏa Liệt Quyền Server loaded!")
