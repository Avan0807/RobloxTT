-- ============================================
-- DIỆT HỒN LIÊN KÍCH - SERVER (CÔNG PHÁP THƯỢNG PHẨM)
-- Combo 5 hit cực nhanh, mỗi hit +10% lifesteal, kết thúc gây 400% dmg
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("DietHonLienKichRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "DietHonLienKichRemote"
	skillRemote.Parent = ReplicatedStorage
end

local function createSoulSlash(origin, direction, hitNumber)
	local intensity = 0.5 + (hitNumber * 0.1)

	local slash = VFXUtils.CreateProjectile({
		Name = "SoulAnnihilation_" .. hitNumber,
		Shape = Enum.PartType.Block,
		Size = Vector3.new(3 + hitNumber * 0.3, 4 + hitNumber * 0.3, 1),
		Position = origin + Vector3.new(0, 2, 0),
		Transparency = 0.3,
		BrickColor = BrickColor.new("Royal purple"),
		Velocity = direction * (80 + hitNumber * 10)
	})

	local attachment = VFXUtils.CreateAttachment(slash)

	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Magic,
		Lifetime = NumberRange.new(0.3, 0.5),
		Rate = 80 + hitNumber * 15,
		Speed = NumberRange.new(5, 15),
		SpreadAngle = Vector2.new(40, 40),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2 * intensity),
			NumberSequenceKeypoint.new(0.5, 3 * intensity),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Dark,
		LightEmission = 1
	})

	VFXUtils.CreateTrail(slash, {
		Lifetime = 0.5,
		Color = VFXUtils.Colors.Dark,
		WidthScale = NumberSequence.new(2 * intensity)
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(150, 0, 200), 8 + hitNumber, 15)

	return slash
end

local function performDietHonLienKich(player, direction)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not humanoidRootPart then return end

	local origin = humanoidRootPart.Position
	local totalLifesteal = 0

	-- 5-hit combo
	for hit = 1, 5 do
		task.delay((hit - 1) * 0.15, function()
			local slash = createSoulSlash(origin, direction, hit)
			local baseDamage = hit < 5 and 20 or 80  -- Final hit does 400% (80 vs 20 base)
			local lifestealPercent = 0.1 * hit  -- 10%, 20%, 30%, 40%, 50%

			local touchConnection
			touchConnection = slash.Touched:Connect(function(hitPart)
				if hitPart and not hitPart:IsDescendantOf(character) then
					local targetHumanoid = hitPart.Parent:FindFirstChild("Humanoid")
					if targetHumanoid then
						-- Damage
						targetHumanoid:TakeDamage(baseDamage)

						-- Lifesteal
						local healAmount = baseDamage * lifestealPercent
						humanoid.Health = math.min(humanoid.Health + healAmount, humanoid.MaxHealth)

						-- Effect
						local explosionSize = hit < 5 and 3 or 8
						VFXUtils.CreateExplosion(slash.Position, {
							Color = VFXUtils.Colors.Dark,
							Size = explosionSize,
							ParticleCount = 40 + (hit * 20),
							LightColor = Color3.fromRGB(150, 0, 200)
						})

						if hit == 5 then
							-- Final hit special effect
							VFXUtils.ApplyKnockback(hitPart.Parent, direction, 80)

							print("👻⚔️⚔️⚔️⚔️⚔️ DIỆT HỒN LIÊN KÍCH - FINAL HIT! Damage: " .. baseDamage .. ", Total Lifesteal: 50%")
						else
							print("👻⚔️ Diệt Hồn Liên Kích Hit " .. hit .. " - Damage: " .. baseDamage .. ", Lifesteal: " .. (lifestealPercent * 100) .. "%")
						end

						touchConnection:Disconnect()
						slash:Destroy()
					end
				end
			end)

			Debris:AddItem(slash, 1.5)
		end)
	end

	print("👻⚔️ " .. player.Name .. " unleashed Diệt Hồn Liên Kích!")
end

skillRemote.OnServerEvent:Connect(function(player, direction)
	if typeof(direction) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	performDietHonLienKich(player, direction)
end)

print("✅ Diệt Hồn Liên Kích Server loaded!")
