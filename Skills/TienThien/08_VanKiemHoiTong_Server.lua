-- ============================================
-- VÂN KIẾM HỒI TÔNG - SERVER
-- Tung kiếm bay rồi recall về gây damage trên đường bay về (double-hit mechanic)
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("VanKiemHoiTongRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "VanKiemHoiTongRemote"
	skillRemote.Parent = ReplicatedStorage
end

local function createSword(origin)
	local sword = Instance.new("Part")
	sword.Name = "CloudSword"
	sword.Shape = Enum.PartType.Block
	sword.Size = Vector3.new(0.5, 0.5, 4)
	sword.Position = origin
	sword.Transparency = 0.3
	sword.CanCollide = false
	sword.Anchored = false
	sword.Material = Enum.Material.Neon
	sword.BrickColor = BrickColor.new("Cyan")
	sword.Parent = workspace

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.Parent = sword

	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyGyro.P = 10000
	bodyGyro.Parent = sword

	local attachment = VFXUtils.CreateAttachment(sword)

	-- Cloud/wind effect
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Cloud,
		Lifetime = NumberRange.new(0.4, 0.7),
		Rate = 60,
		Speed = NumberRange.new(5, 10),
		SpreadAngle = Vector2.new(30, 30),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.5),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Wind,
		LightEmission = 0.7
	})

	VFXUtils.CreateTrail(sword, {
		Lifetime = 0.6,
		Color = VFXUtils.Colors.Wind,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		})
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(180, 255, 200), 6, 10)

	return sword
end

local function throwAndRecall(player, direction)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local origin = humanoidRootPart.Position + Vector3.new(0, 3, 0)
	local sword = createSword(origin)

	local bodyVelocity = sword:FindFirstChild("BodyVelocity")
	local bodyGyro = sword:FindFirstChild("BodyGyro")

	if not bodyVelocity or not bodyGyro then
		sword:Destroy()
		return
	end

	local hitCharacters = {}

	-- Phase 1: Throw forward
	bodyVelocity.Velocity = direction * 80
	bodyGyro.CFrame = CFrame.new(Vector3.new(), direction)

	-- Damage on touch (going out)
	local touchConnection
	touchConnection = sword.Touched:Connect(function(hit)
		if hit and not hit:IsDescendantOf(character) then
			local targetChar = hit.Parent
			local humanoid = targetChar and targetChar:FindFirstChild("Humanoid")

			if humanoid and not hitCharacters[targetChar] then
				hitCharacters[targetChar] = 1
				humanoid:TakeDamage(20)
				print("⚔️ Sword hit " .. targetChar.Name .. " (going out)")
			end
		end
	end)

	-- Phase 2: Recall after 1 second
	task.wait(1)

	-- Return to player
	local returning = true
	local heartbeat
	heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
		if not sword or not sword.Parent or not humanoidRootPart.Parent then
			if heartbeat then heartbeat:Disconnect() end
			if sword then sword:Destroy() end
			return
		end

		local direction = (humanoidRootPart.Position - sword.Position).Unit
		bodyVelocity.Velocity = direction * 100
		bodyGyro.CFrame = CFrame.new(Vector3.new(), direction)

		-- Check distance
		if (humanoidRootPart.Position - sword.Position).Magnitude < 3 then
			returning = false
			heartbeat:Disconnect()
			touchConnection:Disconnect()

			-- Effect on return
			VFXUtils.CreateExplosion(humanoidRootPart.Position, {
				Color = VFXUtils.Colors.Wind,
				Size = 2,
				ParticleCount = 40
			})

			sword:Destroy()
			print("⚔️ Sword returned to " .. player.Name)
		end
	end)

	-- Double hit on return
	sword.Touched:Connect(function(hit)
		if returning and hit and not hit:IsDescendantOf(character) then
			local targetChar = hit.Parent
			local humanoid = targetChar and targetChar:FindFirstChild("Humanoid")

			if humanoid then
				if hitCharacters[targetChar] == 1 then
					-- Second hit!
					humanoid:TakeDamage(30)
					hitCharacters[targetChar] = 2
					print("⚔️⚔️ DOUBLE HIT on " .. targetChar.Name .. "!")
				elseif not hitCharacters[targetChar] then
					humanoid:TakeDamage(20)
					hitCharacters[targetChar] = 1
				end
			end
		end
	end)

	Debris:AddItem(sword, 5)
end

skillRemote.OnServerEvent:Connect(function(player, direction)
	if typeof(direction) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	throwAndRecall(player, direction)
end)

print("✅ Vân Kiếm Hồi Tông Server loaded!")
