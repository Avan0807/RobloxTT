-- DodgeSystem.lua - Hệ Thống Né Tránh/Dash
-- Copy vào ReplicatedStorage/Modules/Combat/DodgeSystem (ModuleScript)

local DodgeSystem = {}

-- ========================================
-- CONSTANTS
-- ========================================

DodgeSystem.DODGE_DISTANCE = 20 -- studs
DodgeSystem.DODGE_DURATION = 0.3 -- seconds
DodgeSystem.DODGE_COOLDOWN = 2 -- seconds
DodgeSystem.IFRAME_DURATION = 0.5 -- invincibility frames
DodgeSystem.STAMINA_COST = 25 -- stamina to dodge
DodgeSystem.MAX_STAMINA = 100
DodgeSystem.STAMINA_REGEN_RATE = 10 -- per second

-- ========================================
-- DODGE DATA (per player)
-- ========================================

DodgeSystem.PlayerDodgeData = {}
-- Format: {
--   [UserId] = {
--     Stamina = 100,
--     LastDodge = 0,
--     IsDodging = false,
--     IsInvincible = false,
--     LastStaminaUpdate = tick()
--   }
-- }

-- ========================================
-- INITIALIZE PLAYER
-- ========================================

function DodgeSystem.InitPlayer(player)
	DodgeSystem.PlayerDodgeData[player.UserId] = {
		Stamina = DodgeSystem.MAX_STAMINA,
		LastDodge = 0,
		IsDodging = false,
		IsInvincible = false,
		LastStaminaUpdate = tick()
	}
end

function DodgeSystem.RemovePlayer(player)
	DodgeSystem.PlayerDodgeData[player.UserId] = nil
end

-- ========================================
-- GET DODGE DATA
-- ========================================

function DodgeSystem.GetDodgeData(player)
	return DodgeSystem.PlayerDodgeData[player.UserId]
end

-- ========================================
-- CAN DODGE?
-- ========================================

function DodgeSystem.CanDodge(player)
	local data = DodgeSystem.GetDodgeData(player)
	if not data then
		return false, "No dodge data"
	end

	if data.IsDodging then
		return false, "Already dodging"
	end

	-- Check cooldown
	local currentTime = tick()
	if currentTime - data.LastDodge < DodgeSystem.DODGE_COOLDOWN then
		local remaining = DodgeSystem.DODGE_COOLDOWN - (currentTime - data.LastDodge)
		return false, string.format("Cooldown: %.1fs", remaining)
	end

	-- Check stamina
	if data.Stamina < DodgeSystem.STAMINA_COST then
		return false, "Not enough stamina"
	end

	return true, "OK"
end

-- ========================================
-- PERFORM DODGE
-- ========================================

function DodgeSystem.Dodge(player, direction)
	local canDodge, reason = DodgeSystem.CanDodge(player)
	if not canDodge then
		return false, reason
	end

	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return false, "No character"
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return false, "No humanoid"
	end

	local data = DodgeSystem.GetDodgeData(player)
	local hrp = character.HumanoidRootPart

	-- Consume stamina
	data.Stamina = data.Stamina - DodgeSystem.STAMINA_COST
	data.LastDodge = tick()
	data.IsDodging = true

	-- Calculate dodge direction
	local dodgeDirection = direction.Unit
	local dodgeTarget = hrp.Position + (dodgeDirection * DodgeSystem.DODGE_DISTANCE)

	-- Create BodyVelocity for dash
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = dodgeDirection * (DodgeSystem.DODGE_DISTANCE / DodgeSystem.DODGE_DURATION)
	bodyVelocity.MaxForce = Vector3.new(100000, 0, 100000) -- Only horizontal
	bodyVelocity.Parent = hrp

	-- Visual effect
	DodgeSystem.CreateDodgeEffect(character)

	-- Enable i-frames
	data.IsInvincible = true

	-- End dodge after duration
	task.delay(DodgeSystem.DODGE_DURATION, function()
		if bodyVelocity and bodyVelocity.Parent then
			bodyVelocity:Destroy()
		end
		data.IsDodging = false
	end)

	-- End i-frames
	task.delay(DodgeSystem.IFRAME_DURATION, function()
		data.IsInvincible = false
	end)

	return true, "Dodged!"
end

-- ========================================
-- CREATE DODGE EFFECT
-- ========================================

function DodgeSystem.CreateDodgeEffect(character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Make character semi-transparent during dodge
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			local originalTransparency = part.Transparency
			part.Transparency = math.min(part.Transparency + 0.5, 0.9)

			task.delay(DodgeSystem.DODGE_DURATION, function()
				if part and part.Parent then
					part.Transparency = originalTransparency
				end
			end)
		end
	end

	-- Trail effect
	local attachment0 = Instance.new("Attachment")
	attachment0.Parent = hrp

	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment0
	trail.Attachment1 = attachment0
	trail.Lifetime = 0.5
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail.WidthScale = NumberSequence.new(3)
	trail.Parent = hrp

	game:GetService("Debris"):AddItem(attachment0, 1)
	game:GetService("Debris"):AddItem(trail, 1)

	-- Whoosh sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://1295468425" -- Whoosh sound
	sound.Volume = 0.5
	sound.Parent = hrp
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 2)
end

-- ========================================
-- CHECK IF INVINCIBLE
-- ========================================

function DodgeSystem.IsInvincible(player)
	local data = DodgeSystem.GetDodgeData(player)
	if not data then return false end

	return data.IsInvincible
end

-- ========================================
-- UPDATE STAMINA (Call every frame or second)
-- ========================================

function DodgeSystem.UpdateStamina(player)
	local data = DodgeSystem.GetDodgeData(player)
	if not data then return end

	local currentTime = tick()
	local deltaTime = currentTime - data.LastStaminaUpdate
	data.LastStaminaUpdate = currentTime

	-- Regen stamina
	if data.Stamina < DodgeSystem.MAX_STAMINA then
		data.Stamina = math.min(data.Stamina + (DodgeSystem.STAMINA_REGEN_RATE * deltaTime), DodgeSystem.MAX_STAMINA)
	end
end

-- ========================================
-- GET STAMINA INFO
-- ========================================

function DodgeSystem.GetStaminaInfo(player)
	local data = DodgeSystem.GetDodgeData(player)
	if not data then
		return 0, DodgeSystem.MAX_STAMINA, 0
	end

	local cooldownRemaining = math.max(0, DodgeSystem.DODGE_COOLDOWN - (tick() - data.LastDodge))

	return data.Stamina, DodgeSystem.MAX_STAMINA, cooldownRemaining
end

print("✅ DodgeSystem loaded (Skillshot System)")
return DodgeSystem
