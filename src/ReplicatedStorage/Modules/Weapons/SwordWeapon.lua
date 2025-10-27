-- SwordWeapon.lua - Sword Weapon Type (extends BaseWeapon)
-- Swords: Fast attacks, medium range, slash effects

local BaseWeapon = require(script.Parent.BaseWeapon)
local EffectLibrary = require(game.ReplicatedStorage.Modules.Effects.EffectLibrary)

local SwordWeapon = setmetatable({}, {__index = BaseWeapon})
SwordWeapon.__index = SwordWeapon

-- ========================================
-- CONSTRUCTOR
-- ========================================

function SwordWeapon.new(config)
	-- Default sword config
	local swordConfig = {
		Type = "Sword",
		AttackSpeed = 1.5, -- Fast
		Range = 8, -- Medium
		MaxCombo = 3,
		CritRate = 0.1, -- 10%
		CritDamage = 2.0, -- x2
	}

	-- Merge with custom config
	for k, v in pairs(config) do
		swordConfig[k] = v
	end

	-- Create base weapon
	local self = BaseWeapon.new(swordConfig)
	setmetatable(self, SwordWeapon)

	-- Sword-specific properties
	self.SlashColor = config.SlashColor or Color3.fromRGB(255, 255, 255)
	self.TrailEnabled = config.TrailEnabled ~= false -- Default true

	return self
end

-- ========================================
-- GRIP CFRAME (Sword specific)
-- ========================================

function SwordWeapon:GetGripCFrame()
	-- Sword grip
	return CFrame.new(0, -1.5, 0) * CFrame.Angles(math.rad(0), math.rad(90), 0)
end

-- ========================================
-- ATTACK OVERRIDE (Add slash effect)
-- ========================================

function SwordWeapon:Attack(target)
	-- Call base attack
	BaseWeapon.Attack(self, target)

	-- Create slash effect
	local character = self.Owner.Character
	if character then
		local rootPart = character.HumanoidRootPart
		local startPos = self:GetWeaponTipPosition()
		local endPos = startPos + (rootPart.CFrame.LookVector * self.Range)

		EffectLibrary.Slash(startPos, endPos, self.SlashColor)
	end
end

-- ========================================
-- PASSIVE ABILITY: Bleeding (Example)
-- ========================================

function SwordWeapon:TriggerPassive(target, damage)
	-- 20% chance to apply bleeding
	if math.random() < 0.2 then
		print("🩸 Bleeding applied!")

		-- Apply bleeding DoT
		local bleedDamage = damage * 0.1 -- 10% of initial damage per second
		local duration = 3 -- 3 seconds

		for i = 1, duration do
			task.wait(1)
			local humanoid = target:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid:TakeDamage(bleedDamage)
				EffectLibrary.Blood(target.Position + Vector3.new(0, 2, 0))
			else
				break
			end
		end
	end
end

-- ========================================
-- ACTIVE ABILITY: Dash Slash (Example)
-- ========================================

function SwordWeapon:UseAbility(target)
	if not self.Owner then return end

	-- Check cooldown
	BaseWeapon.UseAbility(self, target)

	local character = self.Owner.Character
	if not character then return end

	local rootPart = character.HumanoidRootPart
	local humanoid = character.Humanoid

	-- Dash forward
	local dashDistance = 20
	local dashDirection = rootPart.CFrame.LookVector
	local targetPosition = rootPart.Position + (dashDirection * dashDistance)

	-- Create tween
	local TweenService = game:GetService("TweenService")
	local tween = TweenService:Create(
		rootPart,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{CFrame = CFrame.new(targetPosition, targetPosition + dashDirection)}
	)

	-- Wind trail effect
	for i = 1, 5 do
		task.wait(0.05)
		EffectLibrary.Wind(rootPart.Position, dashDirection)
	end

	tween:Play()

	-- Deal AOE damage at end
	tween.Completed:Connect(function()
		-- Find enemies in range
		local hitRadius = 10
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= character then
				local distance = (obj.PrimaryPart.Position - rootPart.Position).Magnitude
				if distance <= hitRadius then
					-- Deal damage
					local damage = self.Damage * 1.5 -- 150% damage
					obj.Humanoid:TakeDamage(damage)

					-- Slash effect
					EffectLibrary.Slash(rootPart.Position, obj.PrimaryPart.Position, self.SlashColor)
				end
			end
		end

		-- Explosion effect at landing
		EffectLibrary.Explosion(rootPart.Position, 10, self.SlashColor)
	end)

	print("⚡ Dash Slash activated!")
end

print("✅ SwordWeapon loaded")
return SwordWeapon
