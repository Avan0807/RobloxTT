-- WeaponExamples.lua - Example Weapons với Effects
-- Template để tạo vũ khí mới

local SwordWeapon = require(script.Parent.SwordWeapon)
local FlagWeapon = require(script.Parent.FlagWeapon)
local FistWeapon = require(script.Parent.FistWeapon)
local EffectLibrary = require(game.ReplicatedStorage.Modules.Effects.EffectLibrary)

local WeaponExamples = {}

-- ========================================
-- SWORD EXAMPLES
-- ========================================

-- Thiên Địa Kiếm (Heaven-Earth Sword)
WeaponExamples.ThienDiKiem = function()
	return SwordWeapon.new({
		Name = "Thiên Địa Kiếm",
		Rarity = "Legendary",
		Level = 1,

		-- Stats
		Damage = 500,
		AttackSpeed = 1.8,
		Range = 10,
		CritRate = 0.25, -- 25%
		CritDamage = 2.5, -- x2.5

		-- Visual
		SlashColor = Color3.fromRGB(100, 200, 255),

		-- Passive: Lightning strikes on crit
		PassiveAbility = function(self, target, damage)
			local isCrit = math.random() < self.CritRate
			if isCrit then
				-- Lightning effect on crit
				EffectLibrary.Lightning(
					target.Position + Vector3.new(0, 10, 0),
					target.Position
				)
				print("⚡ Lightning strike!")
			end
		end,

		-- Active: Lightning Slash AOE
		ActiveAbility = function(self, target)
			print("⚡⚡ THIÊN ĐỊA CHÉM!")

			local character = self.Owner.Character
			local rootPart = character.HumanoidRootPart

			-- Mega slash forward
			local slashRange = 20
			local slashEnd = rootPart.Position + (rootPart.CFrame.LookVector * slashRange)

			EffectLibrary.Slash(
				rootPart.Position + Vector3.new(0, 2, 0),
				slashEnd,
				Color3.fromRGB(100, 200, 255)
			)

			-- Lightning strikes along the path
			for i = 1, 5 do
				local pos = rootPart.Position + (rootPart.CFrame.LookVector * (i * 4))
				EffectLibrary.Lightning(pos + Vector3.new(0, 10, 0), pos)

				-- Damage enemies in area
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= character then
						local distance = (obj.PrimaryPart.Position - pos).Magnitude
						if distance <= 5 then
							obj.Humanoid:TakeDamage(self.Damage * 1.5)
							print("⚡ Hit", obj.Name, "with lightning!")
						end
					end
				end
			end

			-- Final explosion
			EffectLibrary.Explosion(slashEnd, 10, Color3.fromRGB(100, 200, 255))
		end,

		AbilityCooldown = 15
	})
end

-- Ma Hoàng Kiếm (Demon Emperor Sword)
WeaponExamples.MaHoangKiem = function()
	return SwordWeapon.new({
		Name = "Ma Hoàng Kiếm",
		Rarity = "Mythic",
		Level = 1,

		Damage = 800,
		AttackSpeed = 2.0,
		Range = 12,
		CritRate = 0.3,
		CritDamage = 3.0,

		SlashColor = Color3.fromRGB(150, 0, 100),

		-- Passive: Soul drain on kill
		PassiveAbility = function(self, target, damage)
			local humanoid = target:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health <= 0 then
				-- Soul absorption
				EffectLibrary.Soul(target.Position)

				-- Heal caster
				local casterHumanoid = self.Owner.Character:FindFirstChild("Humanoid")
				if casterHumanoid then
					casterHumanoid.Health = math.min(
						casterHumanoid.Health + damage * 0.5,
						casterHumanoid.MaxHealth
					)
					EffectLibrary.Heal(self.Owner.Character.HumanoidRootPart.Position)
				end

				print("💀 Soul absorbed! +HP")
			end
		end,

		-- Active: Soul Explosion
		ActiveAbility = function(self, target)
			print("💀 MA HOÀNG HỒN BÃO!")

			local character = self.Owner.Character
			local rootPart = character.HumanoidRootPart

			-- Soul burst around caster
			for i = 1, 10 do
				local angle = (i / 10) * math.pi * 2
				local pos = rootPart.Position + Vector3.new(
					math.cos(angle) * 10,
					2,
					math.sin(angle) * 10
				)

				EffectLibrary.Soul(pos)
				EffectLibrary.Blood(pos)
			end

			-- Damage all nearby enemies
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= character then
					local distance = (obj.PrimaryPart.Position - rootPart.Position).Magnitude
					if distance <= 15 then
						obj.Humanoid:TakeDamage(self.Damage * 2)
						EffectLibrary.Soul(obj.PrimaryPart.Position)
					end
				end
			end

			EffectLibrary.Explosion(rootPart.Position, 15, Color3.fromRGB(100, 0, 150))
		end,

		AbilityCooldown = 20
	})
end

-- ========================================
-- FLAG EXAMPLES
-- ========================================

-- Phong Vân Cờ (Wind-Cloud Flag)
WeaponExamples.PhongVanCo = function()
	return FlagWeapon.new({
		Name = "Phong Vân Cờ",
		Rarity = "Epic",

		Damage = 400,
		AttackSpeed = 1.0,
		Range = 15,
		AOERadius = 10,

		-- Passive: Wind knockback
		PassiveAbility = function(self, target, damage)
			-- Already has knockback in base FlagWeapon
			-- Add wind effect
			EffectLibrary.Wind(
				target.Position,
				(target.Position - self.Owner.Character.HumanoidRootPart.Position).Unit
			)
		end,

		-- Active: Tornado
		ActiveAbility = function(self, target)
			print("🌪️ PHONG VÂN QUYỀN!")

			local character = self.Owner.Character
			local rootPart = character.HumanoidRootPart

			-- Create tornado
			local tornado = Instance.new("Part")
			tornado.Anchored = true
			tornado.CanCollide = false
			tornado.Transparency = 1
			tornado.Size = Vector3.new(10, 30, 10)
			tornado.Position = rootPart.Position + (rootPart.CFrame.LookVector * 15)
			tornado.Parent = workspace

			-- Wind aura
			EffectLibrary.Aura(tornado, Color3.fromRGB(200, 200, 200), 5)

			-- Spin and lift enemies
			local duration = 5
			local elapsed = 0
			local connection
			connection = game:GetService("RunService").Heartbeat:Connect(function(dt)
				elapsed = elapsed + dt

				-- Spin tornado
				tornado.CFrame = tornado.CFrame * CFrame.Angles(0, math.rad(500 * dt), 0)

				-- Wind effects
				if elapsed % 0.3 < dt then
					EffectLibrary.Wind(tornado.Position, Vector3.new(0, 1, 0))
				end

				-- Damage and lift enemies
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= character then
						local distance = (obj.PrimaryPart.Position - tornado.Position).Magnitude
						if distance <= 10 then
							-- Damage
							obj.Humanoid:TakeDamage(20)

							-- Lift up
							local bodyVelocity = obj.PrimaryPart:FindFirstChild("TornadoLift")
							if not bodyVelocity then
								bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.Name = "TornadoLift"
								bodyVelocity.MaxForce = Vector3.new(50000, 50000, 50000)
								bodyVelocity.Parent = obj.PrimaryPart
							end

							-- Spin around tornado
							local angle = math.atan2(
								obj.PrimaryPart.Position.Z - tornado.Position.Z,
								obj.PrimaryPart.Position.X - tornado.Position.X
							) + math.rad(100 * dt)

							local spinVelocity = Vector3.new(
								math.cos(angle) * 20,
								30, -- Upward
								math.sin(angle) * 20
							)

							bodyVelocity.Velocity = spinVelocity
						end
					end
				end

				if elapsed >= duration then
					connection:Disconnect()
					tornado:Destroy()

					-- Drop all enemies
					for _, obj in ipairs(workspace:GetDescendants()) do
						if obj.Name == "TornadoLift" then
							obj:Destroy()
						end
					end
				end
			end)
		end,

		AbilityCooldown = 25
	})
end

-- ========================================
-- FIST EXAMPLES
-- ========================================

-- Thiết Tay (Iron Fist)
WeaponExamples.ThietTay = function()
	return FistWeapon.new({
		Name = "Thiết Tay",
		Rarity = "Rare",

		Damage = 150,
		AttackSpeed = 3.0, -- Very fast
		CritRate = 0.2,
		ComboDamageBonus = 0.3, -- +30% per combo

		-- Passive: Already has lifesteal in base FistWeapon

		-- Active: Mega Punch
		ActiveAbility = function(self, target)
			if not target then return end

			print("👊 THIẾT QUYỀN!")

			local character = self.Owner.Character
			local rootPart = character.HumanoidRootPart

			-- Charge up
			EffectLibrary.Aura(rootPart, Color3.fromRGB(255, 200, 0), 1)

			task.wait(1)

			-- Dash punch
			local direction = (target.Position - rootPart.Position).Unit
			rootPart.CFrame = CFrame.new(target.Position - direction * 3, target.Position)

			-- MEGA PUNCH
			EffectLibrary.Explosion(target.Position, 15, Color3.fromRGB(255, 150, 0))

			-- Massive damage
			local humanoid = target:FindFirstChild("Humanoid")
			if humanoid then
				humanoid:TakeDamage(self.Damage * 5)
			end

			-- Knockback
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = direction * 200 + Vector3.new(0, 100, 0)
			bodyVelocity.MaxForce = Vector3.new(200000, 200000, 200000)
			bodyVelocity.Parent = target

			game:GetService("Debris"):AddItem(bodyVelocity, 0.5)

			print("💥 MEGA PUNCH! " .. (self.Damage * 5) .. " damage!")
		end,

		AbilityCooldown = 30
	})
end

-- Ma Tôn Quyền (Demon Lord Fist)
WeaponExamples.MaTonQuyen = function()
	return FistWeapon.new({
		Name = "Ma Tôn Quyền",
		Rarity = "Legendary",

		Damage = 300,
		AttackSpeed = 2.5,
		CritRate = 0.25,
		ComboDamageBonus = 0.5, -- +50% per combo!

		-- Passive: Blood explosion on kill
		PassiveAbility = function(self, target, damage)
			-- Call base lifesteal first
			FistWeapon.TriggerPassive(self, target, damage)

			-- Check if killed
			local humanoid = target:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health <= 0 then
				-- Blood explosion
				EffectLibrary.Explosion(target.Position, 8, Color3.fromRGB(150, 0, 0))

				for i = 1, 10 do
					EffectLibrary.Blood(target.Position + Vector3.new(
						math.random(-5, 5),
						math.random(0, 5),
						math.random(-5, 5)
					))
				end

				print("💀 Blood Explosion!")
			end
		end,

		-- Active: Massacre Punch Barrage
		ActiveAbility = function(self, target)
			print("☠️ MA TÔN LIÊN QUYỀN!")

			local character = self.Owner.Character
			local rootPart = character.HumanoidRootPart

			-- Dark aura
			EffectLibrary.Aura(rootPart, Color3.fromRGB(100, 0, 100), 5)

			-- 20 rapid punches
			for i = 1, 20 do
				task.wait(0.05)

				-- Find random enemy nearby
				local enemies = {}
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= character then
						local distance = (obj.PrimaryPart.Position - rootPart.Position).Magnitude
						if distance <= 15 then
							table.insert(enemies, obj)
						end
					end
				end

				if #enemies > 0 then
					local randomEnemy = enemies[math.random(1, #enemies)]
					local damage = self.Damage * 0.5

					randomEnemy.Humanoid:TakeDamage(damage)

					-- Blood effect
					EffectLibrary.Blood(randomEnemy.PrimaryPart.Position + Vector3.new(0, 2, 0))

					-- Soul effect occasionally
					if i % 5 == 0 then
						EffectLibrary.Soul(randomEnemy.PrimaryPart.Position)
					end
				end
			end

			-- Final mega explosion
			task.wait(0.5)
			EffectLibrary.Explosion(rootPart.Position, 20, Color3.fromRGB(100, 0, 100))

			-- Blood and soul effects everywhere
			for i = 1, 30 do
				local randomPos = rootPart.Position + Vector3.new(
					math.random(-20, 20),
					math.random(0, 10),
					math.random(-20, 20)
				)

				EffectLibrary.Blood(randomPos)
				if i % 3 == 0 then
					EffectLibrary.Soul(randomPos)
				end
			end

			print("☠️ MASSACRE COMPLETE!")
		end,

		AbilityCooldown = 40
	})
end

print("✅ WeaponExamples loaded")
return WeaponExamples
