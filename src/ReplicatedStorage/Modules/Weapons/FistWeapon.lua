-- FistWeapon.lua - Fist/Martial Arts Weapon Type (extends BaseWeapon)
-- Fists: Very fast attacks, short range, combo focused

local BaseWeapon = require(script.Parent.BaseWeapon)
local EffectLibrary = require(game.ReplicatedStorage.Modules.Effects.EffectLibrary)

local FistWeapon = setmetatable({}, {__index = BaseWeapon})
FistWeapon.__index = FistWeapon

-- ========================================
-- CONSTRUCTOR
-- ========================================

function FistWeapon.new(config)
	-- Default fist config
	local fistConfig = {
		Type = "Fist",
		AttackSpeed = 2.5, -- Very fast
		Range = 5, -- Short
		MaxCombo = 5, -- Long combos
		CritRate = 0.15, -- High crit
		CritDamage = 1.7,
		Damage = 80, -- Lower base damage (compensated by speed)
	}

	-- Merge
	for k, v in pairs(config) do
		fistConfig[k] = v
	end

	local self = BaseWeapon.new(fistConfig)
	setmetatable(self, FistWeapon)

	-- Fist-specific
	self.ComboDamageBonus = config.ComboDamageBonus or 0.2 -- +20% per combo
	self.LastHitTime = 0
	self.ComboWindow = 1.5 -- Reset combo if no hit within 1.5s

	return self
end

-- ========================================
-- GRIP CFRAME (Fist - no weapon model)
-- ========================================

function FistWeapon:GetGripCFrame()
	-- No grip needed for fists
	return CFrame.new()
end

function FistWeapon:Equip(player)
	-- Don't spawn weapon model for fists
	self.Owner = player
	self.IsEquipped = true
	print("✅", player.Name, "equipped", self.Name, "(Bare hands)")
end

-- ========================================
-- ATTACK OVERRIDE (Combo system)
-- ========================================

function FistWeapon:Attack(target)
	local now = tick()

	-- Reset combo if too long since last hit
	if now - self.LastHitTime > self.ComboWindow then
		self.Combo = 0
	end

	self.LastHitTime = now

	-- Call base attack
	BaseWeapon.Attack(self, target)

	-- Punch effect
	local character = self.Owner.Character
	if character then
		local rootPart = character.HumanoidRootPart
		local hitPos = rootPart.Position + (rootPart.CFrame.LookVector * self.Range)

		-- Impact effect
		if self.Combo == self.MaxCombo then
			-- Final combo hit - explosion
			EffectLibrary.Explosion(hitPos, 5, Color3.fromRGB(255, 200, 0))
		else
			-- Regular punch - small burst
			EffectLibrary.Wind(hitPos, rootPart.CFrame.LookVector)
		end
	end

	-- Show combo counter
	if self.Combo > 1 then
		print("🥊 COMBO x" .. self.Combo .. "!")
	end
end

-- ========================================
-- DEAL DAMAGE OVERRIDE (Combo bonus)
-- ========================================

function FistWeapon:DealDamage(target)
	if not target or not target:FindFirstChild("Humanoid") then return end

	-- Calculate damage with combo bonus
	local baseDamage = self.Damage
	local comboMultiplier = 1 + (self.Combo - 1) * self.ComboDamageBonus

	-- Temporarily modify damage
	local originalDamage = self.Damage
	self.Damage = baseDamage * comboMultiplier

	-- Call base damage
	local finalDamage = BaseWeapon.DealDamage(self, target)

	-- Restore damage
	self.Damage = originalDamage

	return finalDamage
end

-- ========================================
-- PASSIVE ABILITY: Life Steal (Ma Đạo style)
-- ========================================

function FistWeapon:TriggerPassive(target, damage)
	-- 10% lifesteal
	local healAmount = damage * 0.1

	local character = self.Owner.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.Health = math.min(humanoid.Health + healAmount, humanoid.MaxHealth)

			-- Heal effect
			EffectLibrary.Heal(character.HumanoidRootPart.Position)

			print("💚 Lifesteal: +" .. math.floor(healAmount) .. " HP")
		end
	end
end

-- ========================================
-- ACTIVE ABILITY: Rapid Punches
-- ========================================

function FistWeapon:UseAbility(target)
	if not self.Owner or not target then return end

	BaseWeapon.UseAbility(self, target)

	local character = self.Owner.Character
	if not character then return end

	local rootPart = character.HumanoidRootPart

	-- Unleash 10 rapid punches
	local numPunches = 10
	local punchInterval = 0.1

	print("👊 RAPID PUNCHES!")

	-- Speed aura
	EffectLibrary.Aura(rootPart, Color3.fromRGB(255, 255, 0), numPunches * punchInterval)

	for i = 1, numPunches do
		task.wait(punchInterval)

		-- Check if target still exists
		if not target or not target.Parent or not target:FindFirstChild("Humanoid") then
			break
		end

		-- Deal damage
		local damage = self.Damage * 0.5 -- 50% damage per punch
		target.Humanoid:TakeDamage(damage)

		-- Punch effect
		local hitPos = target.PrimaryPart.Position
		EffectLibrary.Wind(hitPos, (hitPos - rootPart.Position).Unit)

		-- Every 3rd punch - explosion
		if i % 3 == 0 then
			EffectLibrary.Explosion(hitPos, 3, Color3.fromRGB(255, 200, 0))
		end
	end

	-- Final mega punch
	task.wait(0.3)
	if target and target.Parent and target:FindFirstChild("Humanoid") then
		local megaDamage = self.Damage * 2 -- 200% damage
		target.Humanoid:TakeDamage(megaDamage)

		-- Mega explosion
		EffectLibrary.Explosion(target.PrimaryPart.Position, 10, Color3.fromRGB(255, 100, 0))

		-- Knockback
		local direction = (target.PrimaryPart.Position - rootPart.Position).Unit
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = direction * 100 + Vector3.new(0, 50, 0)
		bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
		bodyVelocity.Parent = target.PrimaryPart

		game:GetService("Debris"):AddItem(bodyVelocity, 0.3)

		print("💥 FINAL PUNCH! " .. math.floor(megaDamage) .. " damage!")
	end
end

print("✅ FistWeapon loaded")
return FistWeapon
