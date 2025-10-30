-- ============================================
-- NGŨ HÀNH TRẢM - SERVER
-- Phóng 5 tia nguyên tố hình quạt; mỗi tia trúng tăng 3% sát thương phép (stack 5 lần)
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- Load VFX Utils
local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

-- Tạo RemoteEvent
local skillRemote = ReplicatedStorage:FindFirstChild("NguHanhTramRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "NguHanhTramRemote"
	skillRemote.Parent = ReplicatedStorage
end

-- Damage stacks (lưu theo player)
local damageStacks = {}

local ELEMENT_COLORS = {
	VFXUtils.Colors.Fire,      -- Lửa
	VFXUtils.Colors.Ice,       -- Băng
	VFXUtils.Colors.Lightning, -- Lôi
	VFXUtils.Colors.Wind,      -- Phong
	VFXUtils.Colors.Earth      -- Thổ
}

local function createElementBeam(origin, direction, index)
	-- Góc phóng hình quạt: -30° đến +30°
	local angle = math.rad(-30 + (index - 1) * 15)
	local rotatedDirection = CFrame.new(Vector3.new(), direction) * CFrame.Angles(0, angle, 0)
	local finalDirection = rotatedDirection.LookVector

	-- Tạo projectile
	local beam = VFXUtils.CreateProjectile({
		Name = "ElementBeam_" .. index,
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(1.5, 1.5, 1.5),
		Position = origin + Vector3.new(0, 2, 0),
		Transparency = 0.5,
		BrickColor = BrickColor.new("White"),
		Velocity = finalDirection * 100
	})

	-- Attachment và particles
	local attachment = VFXUtils.CreateAttachment(beam)

	-- Element particle
	local particle = VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Magic,
		Lifetime = NumberRange.new(0.3, 0.5),
		Rate = 50,
		Speed = NumberRange.new(3, 8),
		SpreadAngle = Vector2.new(30, 30),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.5),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = ELEMENT_COLORS[index],
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LightEmission = 1
	})

	-- Trail
	VFXUtils.CreateTrail(beam, {
		Lifetime = 0.5,
		Color = ELEMENT_COLORS[index],
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		})
	})

	-- Light
	VFXUtils.CreateLight(attachment, ELEMENT_COLORS[index][3], 5, 10)

	return beam
end

local function shootNguHanhTram(player, origin, direction)
	local character = player.Character
	if not character then return end

	-- Khởi tạo stack nếu chưa có
	if not damageStacks[player.UserId] then
		damageStacks[player.UserId] = 0
	end

	-- Tạo 5 tia
	for i = 1, 5 do
		local beam = createElementBeam(origin, direction, i)

		-- Collision detection
		local touchConnection
		touchConnection = beam.Touched:Connect(function(hit)
			if hit and not hit:IsDescendantOf(character) then
				local humanoid = hit.Parent:FindFirstChild("Humanoid")
				if humanoid then
					-- Tăng stack
					damageStacks[player.UserId] = math.min(damageStacks[player.UserId] + 1, 5)
					local damageMultiplier = 1 + (damageStacks[player.UserId] * 0.03)

					local baseDamage = 15
					local finalDamage = baseDamage * damageMultiplier

					humanoid:TakeDamage(finalDamage)
					print(string.format("💥 %s hit! Stack: %d | Damage: %.1f", player.Name, damageStacks[player.UserId], finalDamage))
				end

				-- Explosion nhỏ
				VFXUtils.CreateExplosion(beam.Position, {
					Color = ELEMENT_COLORS[i],
					Size = 2,
					ParticleCount = 30
				})

				touchConnection:Disconnect()
				beam:Destroy()
			end
		end)

		Debris:AddItem(beam, 3)
	end
end

skillRemote.OnServerEvent:Connect(function(player, origin, direction)
	if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then
		warn("⚠️ Invalid data from " .. player.Name)
		return
	end

	shootNguHanhTram(player, origin, direction)
end)

print("✅ Ngũ Hành Trảm Server loaded!")
