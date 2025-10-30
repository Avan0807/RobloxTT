-- ============================================
-- HỒI TỨC CỔ HUYẾT - SERVER (PASSIVE)
-- Khi còn <30% HP, mỗi hit hồi 2% HP trong 8s
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local activeLifesteal = {}

local LIFESTEAL_COLORS = {
	Color3.fromRGB(200, 0, 0),
	Color3.fromRGB(150, 0, 0),
	Color3.fromRGB(100, 0, 0)
}

local function createLifestealAura(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end

	local aura = Instance.new("Part")
	aura.Name = "BloodAura"
	aura.Shape = Enum.PartType.Ball
	aura.Size = Vector3.new(5, 5, 5)
	aura.Transparency = 0.7
	aura.CanCollide = false
	aura.Anchored = false
	aura.Material = Enum.Material.Neon
	aura.BrickColor = BrickColor.new("Crimson")
	aura.Parent = workspace

	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart
	weld.Part1 = aura
	weld.Parent = aura

	local attachment = VFXUtils.CreateAttachment(aura)

	-- Blood particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Smoke,
		Lifetime = NumberRange.new(0.8, 1.2),
		Rate = 60,
		Speed = NumberRange.new(2, 6),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 1.5),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = LIFESTEAL_COLORS,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LightEmission = 0.6
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(200, 0, 0), 8, 15)

	return aura
end

-- Function to call when player lands a hit (during lifesteal mode)
function ApplyLifesteal(player, damage)
	local data = activeLifesteal[player.UserId]
	if not data then return end

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Heal 2% of max HP
	local healAmount = humanoid.MaxHealth * 0.02
	humanoid.Health = math.min(humanoid.Health + healAmount, humanoid.MaxHealth)

	-- Heal effect
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if humanoidRootPart then
		local healEffect = Instance.new("Part")
		healEffect.Size = Vector3.new(1, 1, 1)
		healEffect.Position = humanoidRootPart.Position + Vector3.new(0, 3, 0)
		healEffect.Transparency = 1
		healEffect.Anchored = true
		healEffect.CanCollide = false
		healEffect.Parent = workspace

		local attachment = VFXUtils.CreateAttachment(healEffect)

		VFXUtils.CreateParticle({
			Parent = attachment,
			Texture = VFXUtils.Textures.Star,
			Lifetime = NumberRange.new(0.5, 0.8),
			Rate = 0,
			Speed = NumberRange.new(3, 8),
			Size = NumberSequence.new(1.2),
			Color = {Color3.fromRGB(255, 100, 100)},
			LightEmission = 1,
			EmitCount = 15
		}):Emit(15)

		game.Debris:AddItem(healEffect, 1)
	end

	print("💉 " .. player.Name .. " healed " .. math.floor(healAmount) .. " HP from lifesteal")
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")

		-- Monitor health
		humanoid.HealthChanged:Connect(function(health)
			local healthPercent = health / humanoid.MaxHealth

			-- Activate lifesteal when below 30% HP
			if healthPercent < 0.3 and not activeLifesteal[player.UserId] then
				-- Activate lifesteal mode
				local aura = createLifestealAura(character)

				activeLifesteal[player.UserId] = {
					character = character,
					aura = aura,
					startTime = tick()
				}

				print("💉 " .. player.Name .. " activated HỒI TỨC CỔ HUYẾT! Lifesteal active for 8s")

				-- Deactivate after 8s
				task.delay(8, function()
					if activeLifesteal[player.UserId] then
						local data = activeLifesteal[player.UserId]
						if data.aura then
							data.aura:Destroy()
						end
						activeLifesteal[player.UserId] = nil
						print("💉 " .. player.Name .. "'s lifesteal expired")
					end
				end)

			-- Deactivate if health goes above 30%
			elseif healthPercent >= 0.3 and activeLifesteal[player.UserId] then
				local data = activeLifesteal[player.UserId]
				if data.aura then
					data.aura:Destroy()
				end
				activeLifesteal[player.UserId] = nil
			end
		end)
	end)
end)

print("✅ Hồi Tức Cổ Huyết (Passive) Server loaded!")
