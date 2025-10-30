-- ============================================
-- NGỰ LINH HỒI SINH - SERVER (PASSIVE)
-- Hồi 20% HP tức thời khi trúng đòn chí mạng (cooldown 90s)
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local playerCooldowns = {}
local COOLDOWN_TIME = 90

local HEAL_COLORS = {
	Color3.fromRGB(100, 255, 100),
	Color3.fromRGB(150, 255, 150),
	Color3.fromRGB(200, 255, 200)
}

local function createHealEffect(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local healPart = Instance.new("Part")
	healPart.Name = "HealEffect"
	healPart.Size = Vector3.new(1, 1, 1)
	healPart.Position = humanoidRootPart.Position
	healPart.Transparency = 1
	healPart.Anchored = true
	healPart.CanCollide = false
	healPart.Parent = workspace

	local attachment = VFXUtils.CreateAttachment(healPart)

	-- Heal particles
	local heal = VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Star,
		Lifetime = NumberRange.new(0.8, 1.2),
		Rate = 0,
		Speed = NumberRange.new(5, 10),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.5),
			NumberSequenceKeypoint.new(0.5, 2),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.CreateColorSequence(HEAL_COLORS),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LightEmission = 1,
		EmitCount = 50
	})

	heal:Emit(50)

	VFXUtils.CreateLight(attachment, Color3.fromRGB(100, 255, 100), 10, 20)

	game.Debris:AddItem(healPart, 2)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")

		-- Initialize cooldown
		playerCooldowns[player.UserId] = 0

		-- Listen for health changes
		humanoid.HealthChanged:Connect(function(health)
			local maxHealth = humanoid.MaxHealth
			local healthPercent = health / maxHealth

			-- Check if it's a critical hit (lost more than 30% HP in one hit)
			-- and if passive is off cooldown
			if healthPercent < 0.3 and tick() > playerCooldowns[player.UserId] then
				-- Trigger healing
				local healAmount = maxHealth * 0.2
				humanoid.Health = math.min(health + healAmount, maxHealth)

				-- Effect
				createHealEffect(character)

				-- Set cooldown
				playerCooldowns[player.UserId] = tick() + COOLDOWN_TIME

				print("💚 Ngự Linh Hồi Sinh activated for " .. player.Name .. "! Healed " .. healAmount .. " HP")
			end
		end)
	end)
end)

print("✅ Ngự Linh Hồi Sinh (Passive) Server loaded!")
