-- ============================================
-- BĂNG TỎA TRẢM - SERVER
-- Đóng băng địch 1.2s, nếu địch bị hit thêm lần nữa sẽ vỡ băng gây 150% dmg
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("BangToaTramRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "BangToaTramRemote"
	skillRemote.Parent = ReplicatedStorage
end

local frozenTargets = {}

local function createIcePrison(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	-- Ice cage
	local ice = Instance.new("Part")
	ice.Name = "IcePrison"
	ice.Shape = Enum.PartType.Ball
	ice.Size = Vector3.new(5, 5, 5)
	ice.Position = humanoidRootPart.Position
	ice.Transparency = 0.3
	ice.CanCollide = false
	ice.Anchored = true
	ice.Material = Enum.Material.Ice
	ice.BrickColor = BrickColor.new("Pastel Blue")
	ice.Parent = workspace

	local attachment = VFXUtils.CreateAttachment(ice)

	-- Ice particles
	local iceParticle = VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Star,
		Lifetime = NumberRange.new(0.5, 1),
		Rate = 40,
		Speed = NumberRange.new(1, 3),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new(0.8),
		Color = VFXUtils.Colors.Ice,
		LightEmission = 0.8
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(150, 220, 255), 6, 12)

	return ice
end

local function freezeTarget(player, targetPosition)
	-- Tìm địch trong bán kính
	local hitParts = workspace:GetPartBoundsInRadius(targetPosition, 8)

	for _, part in ipairs(hitParts) do
		local character = part.Parent
		local humanoid = character and character:FindFirstChild("Humanoid")

		if humanoid and character ~= player.Character then
			-- Đóng băng
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				-- Mark as frozen
				frozenTargets[character] = true

				-- Freeze movement
				local originalWalkSpeed = humanoid.WalkSpeed
				humanoid.WalkSpeed = 0

				-- Create ice prison
				local icePrison = createIcePrison(character)

				-- Weld character to ice
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = humanoidRootPart
				weld.Part1 = icePrison
				weld.Parent = icePrison

				print("❄️ " .. character.Name .. " frozen!")

				-- Detection for shatter
				local connection
				connection = humanoid.HealthChanged:Connect(function()
					if frozenTargets[character] then
						-- Shatter effect
						VFXUtils.CreateExplosion(humanoidRootPart.Position, {
							Color = VFXUtils.Colors.Ice,
							Size = 4,
							ParticleCount = 80,
							Texture = VFXUtils.Textures.Star
						})

						-- 150% damage
						humanoid:TakeDamage(30)
						print("💥 " .. character.Name .. " shattered! Extra damage!")

						frozenTargets[character] = nil
						connection:Disconnect()
						icePrison:Destroy()
					end
				end)

				-- Unfreeze after 1.2s
				task.delay(1.2, function()
					if frozenTargets[character] then
						frozenTargets[character] = nil
						humanoid.WalkSpeed = originalWalkSpeed
						connection:Disconnect()
						icePrison:Destroy()
						print("❄️ " .. character.Name .. " unfrozen")
					end
				end)
			end
		end
	end

	-- Cast effect
	VFXUtils.CreateExplosion(targetPosition, {
		Color = VFXUtils.Colors.Ice,
		Size = 3,
		ParticleCount = 60,
		Texture = VFXUtils.Textures.Star
	})
end

skillRemote.OnServerEvent:Connect(function(player, targetPosition)
	if typeof(targetPosition) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	freezeTarget(player, targetPosition)
end)

print("✅ Băng Tỏa Trảm Server loaded!")
