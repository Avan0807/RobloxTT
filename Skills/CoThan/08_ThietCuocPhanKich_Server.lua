-- ============================================
-- THIẾT CƯỚC PHẢN KÍCH - SERVER (PASSIVE)
-- Khi dodge thành công → auto phản đòn 1 hit 300% dmg
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local playerDodges = {}

local function createCounterEffect(origin, direction)
	local counter = VFXUtils.CreateProjectile({
		Name = "IronCounter",
		Shape = Enum.PartType.Block,
		Size = Vector3.new(2, 3, 4),
		Position = origin + Vector3.new(0, 1, 0),
		Transparency = 0.4,
		BrickColor = BrickColor.new("Really red"),
		Velocity = direction * 100
	})

	local attachment = VFXUtils.CreateAttachment(counter)

	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Spark,
		Lifetime = NumberRange.new(0.2, 0.4),
		Rate = 100,
		Speed = NumberRange.new(5, 15),
		SpreadAngle = Vector2.new(40, 40),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.5),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(200, 0, 0)},
		LightEmission = 1
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(255, 0, 0), 10, 15)

	return counter
end

-- Function called when player successfully dodges
function TriggerThietCuocPhanKich(player, attacker)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local attackerRoot = attacker:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart or not attackerRoot then return end

	-- Calculate direction to attacker
	local direction = (attackerRoot.Position - humanoidRootPart.Position).Unit

	-- Create counter attack
	local counter = createCounterEffect(humanoidRootPart.Position, direction)

	local touchConnection
	touchConnection = counter.Touched:Connect(function(hit)
		if hit and hit.Parent == attacker then
			local humanoid = attacker:FindFirstChild("Humanoid")
			if humanoid then
				-- 300% counter damage
				local counterDamage = 60  -- High base for counter
				humanoid:TakeDamage(counterDamage)

				VFXUtils.CreateExplosion(counter.Position, {
					Color = {Color3.fromRGB(255, 0, 0)},
					Size = 4,
					ParticleCount = 60
				})

				VFXUtils.ApplyKnockback(attacker, direction, 50)

				print("⚔️💥 " .. player.Name .. " COUNTER-ATTACKED! Damage: " .. counterDamage)
			end

			touchConnection:Disconnect()
			counter:Destroy()
		end
	end)

	game.Debris:AddItem(counter, 2)
end

-- Monitor dodge mechanics (integration point)
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")

		-- Track dodge state (this would integrate with your dodge system)
		playerDodges[player.UserId] = {
			lastDodgeTime = 0
		}

		print("✅ Thiết Cước Phản Kích ready for " .. player.Name)
	end)
end)

print("✅ Thiết Cước Phản Kích (Passive) Server loaded!")
