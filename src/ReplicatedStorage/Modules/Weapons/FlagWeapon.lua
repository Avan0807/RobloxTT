-- FlagWeapon.lua - Flag/Spear Weapon Type (extends BaseWeapon)
-- Flags: Long range, AOE, spinning attacks

local BaseWeapon = require(script.Parent.BaseWeapon)
local EffectLibrary = require(game.ReplicatedStorage.Modules.Effects.EffectLibrary)

local FlagWeapon = setmetatable({}, {__index = BaseWeapon})
FlagWeapon.__index = FlagWeapon

-- ========================================
-- CONSTRUCTOR
-- ========================================

function FlagWeapon.new(config)
	-- Default flag config
	local flagConfig = {
		Type = "Flag",
		AttackSpeed = 0.8, -- Slower
		Range = 15, -- Long range
		MaxCombo = 4,
		CritRate = 0.08,
		CritDamage = 1.8,
	}

	-- Merge
	for k, v in pairs(config) do
		flagConfig[k] = v
	end

	local self = BaseWeapon.new(flagConfig)
	setmetatable(self, FlagWeapon)

	-- Flag-specific
	self.AOERadius = config.AOERadius or 8
	self.SpinSpeed = config.SpinSpeed or 360 -- degrees per second

	return self
end

-- ========================================
-- GRIP CFRAME (Flag specific)
-- ========================================

function FlagWeapon:GetGripCFrame()
	-- Flag/Spear grip (two-handed)
	return CFrame.new(0, -2, 0) * CFrame.Angles(math.rad(45), 0, 0)
end

-- ========================================
-- ATTACK OVERRIDE (Spinning AOE attack)
-- ========================================

function FlagWeapon:Attack(target)
	-- Call base attack
	BaseWeapon.Attack(self, target)

	-- Spinning slash AOE
	local character = self.Owner.Character
	if not character then return end

	local rootPart = character.HumanoidRootPart

	-- Create circular slash effect
	local numSlashes = 8
	for i = 1, numSlashes do
		local angle = (i / numSlashes) * math.pi * 2
		local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
		local startPos = rootPart.Position + Vector3.new(0, 2, 0)
		local endPos = startPos + (direction * self.AOERadius)

		task.wait(0.05)
		EffectLibrary.Slash(startPos, endPos, Color3.fromRGB(255, 200, 100))
	end

	-- Wind effect
	EffectLibrary.Wind(rootPart.Position, Vector3.new(0, 1, 0))

	-- Damage all enemies in AOE
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= character then
			local distance = (obj.PrimaryPart.Position - rootPart.Position).Magnitude
			if distance <= self.AOERadius then
				self:DealDamage(obj)
			end
		end
	end
end

-- ========================================
-- PASSIVE ABILITY: Knockback
-- ========================================

function FlagWeapon:TriggerPassive(target, damage)
	-- Always knockback enemies
	local rootPart = target.PrimaryPart or target:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local character = self.Owner.Character
	if not character then return end

	-- Calculate knockback direction
	local direction = (rootPart.Position - character.HumanoidRootPart.Position).Unit
	local knockbackForce = 50

	-- Apply knockback
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = direction * knockbackForce + Vector3.new(0, 20, 0)
	bodyVelocity.MaxForce = Vector3.new(50000, 50000, 50000)
	bodyVelocity.Parent = rootPart

	game:GetService("Debris"):AddItem(bodyVelocity, 0.2)

	-- Wind effect at target
	EffectLibrary.Wind(rootPart.Position, direction)

	print("💨 Knockback!")
end

-- ========================================
-- ACTIVE ABILITY: Whirlwind (Spinning AOE)
-- ========================================

function FlagWeapon:UseAbility(target)
	if not self.Owner then return end

	BaseWeapon.UseAbility(self, target)

	local character = self.Owner.Character
	if not character then return end

	local rootPart = character.HumanoidRootPart

	-- Spin for 3 seconds, dealing damage continuously
	local duration = 3
	local tickRate = 0.2 -- Damage every 0.2s
	local elapsed = 0

	print("🌀 WHIRLWIND!")

	-- Create spinning aura
	EffectLibrary.Aura(rootPart, Color3.fromRGB(200, 255, 255), duration)

	-- Spin character
	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		elapsed = elapsed + dt

		-- Rotate character
		rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(self.SpinSpeed * dt), 0)

		-- Deal damage periodically
		if elapsed % tickRate < dt then
			-- Find enemies in AOE
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= character then
					local distance = (obj.PrimaryPart.Position - rootPart.Position).Magnitude
					if distance <= self.AOERadius * 1.5 then
						-- Deal damage
						local damage = self.Damage * 0.3 -- 30% damage per tick
						obj.Humanoid:TakeDamage(damage)

						-- Slash effect
						EffectLibrary.Slash(
							rootPart.Position,
							obj.PrimaryPart.Position,
							Color3.fromRGB(150, 200, 255)
						)
					end
				end
			end

			-- Wind effect
			EffectLibrary.Wind(rootPart.Position, Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)))
		end

		if elapsed >= duration then
			connection:Disconnect()

			-- Final explosion
			EffectLibrary.Explosion(rootPart.Position, self.AOERadius * 1.5, Color3.fromRGB(150, 200, 255))
		end
	end)
end

print("✅ FlagWeapon loaded")
return FlagWeapon
