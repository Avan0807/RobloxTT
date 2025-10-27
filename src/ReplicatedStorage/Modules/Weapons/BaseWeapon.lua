-- BaseWeapon.lua - Base Class cho tất cả vũ khí
-- All weapons extend từ class này

local BaseWeapon = {}
BaseWeapon.__index = BaseWeapon

-- ========================================
-- CONSTRUCTOR
-- ========================================

function BaseWeapon.new(config)
	local self = setmetatable({}, BaseWeapon)

	-- Basic Info
	self.Name = config.Name or "Unnamed Weapon"
	self.Type = config.Type or "Sword" -- Sword, Flag, Fist
	self.Rarity = config.Rarity or "Common" -- Common, Rare, Epic, Legendary, Mythic
	self.Level = config.Level or 1

	-- Stats
	self.Damage = config.Damage or 100
	self.AttackSpeed = config.AttackSpeed or 1.0 -- Attacks per second
	self.Range = config.Range or 10 -- Studs
	self.CritRate = config.CritRate or 0.05 -- 5%
	self.CritDamage = config.CritDamage or 1.5 -- x1.5 damage

	-- Scaling (for cultivation realms)
	self.Scaling = config.Scaling or {
		TuVi = 0.1, -- +10% damage per 1000 Tu Vi
		Realm = 0.2 -- +20% damage per realm
	}

	-- Visual
	self.Model = config.Model -- Weapon model
	self.Trail = config.Trail -- Trail effect
	self.IdleAnimation = config.IdleAnimation
	self.AttackAnimations = config.AttackAnimations or {}

	-- Effects
	self.HitEffect = config.HitEffect -- Effect khi đánh trúng
	self.SwingEffect = config.SwingEffect -- Effect khi vung
	self.SpecialEffect = config.SpecialEffect -- Special ability effect
	self.Sound = config.Sound or {}

	-- Special Abilities
	self.PassiveAbility = config.PassiveAbility -- Passive effect
	self.ActiveAbility = config.ActiveAbility -- Active skill
	self.AbilityCooldown = config.AbilityCooldown or 10 -- Seconds
	self.LastAbilityUse = 0

	-- State
	self.IsEquipped = false
	self.Owner = nil
	self.Combo = 0
	self.MaxCombo = config.MaxCombo or 3

	return self
end

-- ========================================
-- EQUIP / UNEQUIP
-- ========================================

function BaseWeapon:Equip(player)
	if self.IsEquipped then return end

	self.Owner = player
	self.IsEquipped = true

	-- Spawn weapon model
	if self.Model then
		local character = player.Character
		if character then
			local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
			if rightHand then
				local weaponClone = self.Model:Clone()
				weaponClone.Parent = character

				-- Weld to hand
				local weld = Instance.new("Weld")
				weld.Part0 = rightHand
				weld.Part1 = weaponClone.PrimaryPart or weaponClone:FindFirstChildWhichIsA("BasePart")
				weld.C0 = self:GetGripCFrame()
				weld.Parent = weaponClone
			end
		end
	end

	-- Play equip animation
	if self.IdleAnimation then
		self:PlayAnimation(self.IdleAnimation)
	end

	print("✅", player.Name, "equipped", self.Name)
end

function BaseWeapon:Unequip()
	if not self.IsEquipped then return end

	-- Remove weapon model
	if self.Owner and self.Owner.Character then
		local weaponModel = self.Owner.Character:FindFirstChild(self.Name)
		if weaponModel then
			weaponModel:Destroy()
		end
	end

	self.IsEquipped = false
	self.Owner = nil
	self.Combo = 0

	print("❌ Unequipped", self.Name)
end

-- ========================================
-- GET GRIP CFRAME (Override per weapon type)
-- ========================================

function BaseWeapon:GetGripCFrame()
	-- Default grip (override in subclasses)
	return CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(90), 0, 0)
end

-- ========================================
-- ATTACK
-- ========================================

function BaseWeapon:Attack(target)
	if not self.IsEquipped or not self.Owner then
		warn("Weapon not equipped!")
		return
	end

	-- Check cooldown
	local now = tick()
	local cooldown = 1 / self.AttackSpeed
	if now - (self.LastAttack or 0) < cooldown then
		return -- Still on cooldown
	end
	self.LastAttack = now

	-- Increment combo
	self.Combo = self.Combo + 1
	if self.Combo > self.MaxCombo then
		self.Combo = 1
	end

	-- Play attack animation
	local animIndex = self.Combo
	if self.AttackAnimations[animIndex] then
		self:PlayAnimation(self.AttackAnimations[animIndex])
	end

	-- Play swing effect
	if self.SwingEffect then
		self:PlayEffect(self.SwingEffect)
	end

	-- Play sound
	if self.Sound.Swing then
		self:PlaySound(self.Sound.Swing)
	end

	-- Deal damage if target in range
	if target then
		local distance = (self.Owner.Character.HumanoidRootPart.Position - target.Position).Magnitude
		if distance <= self.Range then
			self:DealDamage(target)
		end
	end
end

-- ========================================
-- DEAL DAMAGE
-- ========================================

function BaseWeapon:DealDamage(target)
	if not target or not target:FindFirstChild("Humanoid") then
		return
	end

	-- Calculate damage
	local baseDamage = self.Damage

	-- Apply scaling
	local playerData = self:GetPlayerData()
	if playerData then
		-- Tu Vi scaling
		local tuViBonus = (playerData.TuVi / 1000) * self.Scaling.TuVi
		baseDamage = baseDamage * (1 + tuViBonus)

		-- Realm scaling
		local realmLevel = playerData.RealmLevel or 1
		baseDamage = baseDamage * (1 + realmLevel * self.Scaling.Realm)
	end

	-- Critical hit?
	local isCrit = math.random() < self.CritRate
	local finalDamage = baseDamage

	if isCrit then
		finalDamage = baseDamage * self.CritDamage
		print("💥 CRITICAL HIT!")
	end

	-- Apply damage
	local humanoid = target:FindFirstChild("Humanoid")
	if humanoid then
		humanoid:TakeDamage(finalDamage)
	end

	-- Play hit effect
	if self.HitEffect then
		self:PlayEffect(self.HitEffect, target.Position)
	end

	-- Play hit sound
	if self.Sound.Hit then
		self:PlaySound(self.Sound.Hit)
	end

	-- Trigger passive ability
	if self.PassiveAbility then
		self:TriggerPassive(target, finalDamage)
	end

	print("⚔️", self.Owner.Name, "dealt", math.floor(finalDamage), "damage to", target.Name)
	return finalDamage
end

-- ========================================
-- SPECIAL ABILITY
-- ========================================

function BaseWeapon:UseAbility(target)
	if not self.ActiveAbility then
		warn("No active ability!")
		return
	end

	-- Check cooldown
	local now = tick()
	if now - self.LastAbilityUse < self.AbilityCooldown then
		local remaining = self.AbilityCooldown - (now - self.LastAbilityUse)
		warn("Ability on cooldown:", math.ceil(remaining), "seconds")
		return
	end

	-- Use ability
	self.LastAbilityUse = now
	self.ActiveAbility(self, target)

	print("✨", self.Owner.Name, "used", self.Name, "special ability!")
end

-- ========================================
-- TRIGGER PASSIVE (Override per weapon)
-- ========================================

function BaseWeapon:TriggerPassive(target, damage)
	-- Override in subclasses
	-- Example: Lifesteal, burn, freeze, etc.
end

-- ========================================
-- ANIMATION HELPERS
-- ========================================

function BaseWeapon:PlayAnimation(animationId)
	if not self.Owner or not self.Owner.Character then return end

	local humanoid = self.Owner.Character:FindFirstChild("Humanoid")
	if not humanoid then return end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then return end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. animationId

	local track = animator:LoadAnimation(animation)
	track:Play()

	return track
end

-- ========================================
-- EFFECT HELPERS
-- ========================================

function BaseWeapon:PlayEffect(effectFunction, position)
	if not effectFunction then return end

	-- effectFunction is a function that creates the effect
	-- Example: EffectLibrary.Lightning(position)
	effectFunction(position or self:GetWeaponTipPosition())
end

function BaseWeapon:PlaySound(soundId)
	if not soundId or not self.Owner then return end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. soundId
	sound.Parent = self.Owner.Character.HumanoidRootPart
	sound:Play()

	game:GetService("Debris"):AddItem(sound, 2)
end

-- ========================================
-- UTILITY
-- ========================================

function BaseWeapon:GetWeaponTipPosition()
	if not self.Owner or not self.Owner.Character then
		return Vector3.new(0, 0, 0)
	end

	local weaponModel = self.Owner.Character:FindFirstChild(self.Name)
	if weaponModel then
		local tip = weaponModel:FindFirstChild("Tip") or weaponModel.PrimaryPart
		if tip then
			return tip.Position
		end
	end

	return self.Owner.Character.HumanoidRootPart.Position
end

function BaseWeapon:GetPlayerData()
	-- TODO: Get player data from DataStore
	-- For now, return dummy data
	return {
		TuVi = 10000,
		RealmLevel = 5
	}
end

-- ========================================
-- UPGRADE WEAPON
-- ========================================

function BaseWeapon:Upgrade()
	self.Level = self.Level + 1
	self.Damage = self.Damage * 1.1 -- +10% damage per level

	print("⬆️", self.Name, "upgraded to level", self.Level)
end

-- ========================================
-- GET INFO (for UI)
-- ========================================

function BaseWeapon:GetInfo()
	return {
		Name = self.Name,
		Type = self.Type,
		Rarity = self.Rarity,
		Level = self.Level,
		Damage = self.Damage,
		AttackSpeed = self.AttackSpeed,
		Range = self.Range,
		CritRate = self.CritRate * 100 .. "%",
		CritDamage = self.CritDamage .. "x",
		PassiveAbility = self.PassiveAbility and "Yes" or "No",
		ActiveAbility = self.ActiveAbility and "Yes" or "No"
	}
end

print("✅ BaseWeapon loaded")
return BaseWeapon
