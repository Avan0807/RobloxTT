-- ============================================
-- PHONG THẦN KẾT GIỚI - SERVER
-- Tạo vòng xoáy gió đẩy lùi và giảm tốc 30% trong 3s
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("PhongThanKetGioiRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "PhongThanKetGioiRemote"
	skillRemote.Parent = ReplicatedStorage
end

local function createWindVortex(position)
	local vortex = Instance.new("Part")
	vortex.Name = "WindVortex"
	vortex.Shape = Enum.PartType.Cylinder
	vortex.Size = Vector3.new(0.5, 12, 12)
	vortex.Position = position + Vector3.new(0, 3, 0)
	vortex.Orientation = Vector3.new(0, 0, 90)
	vortex.Transparency = 0.8
	vortex.CanCollide = false
	vortex.Anchored = true
	vortex.Material = Enum.Material.Neon
	vortex.BrickColor = BrickColor.new("Mint")
	vortex.Parent = workspace

	local attachment = VFXUtils.CreateAttachment(vortex)

	-- Wind particles
	local wind = VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Cloud,
		Lifetime = NumberRange.new(1, 1.5),
		Rate = 60,
		Speed = NumberRange.new(8, 15),
		SpreadAngle = Vector2.new(180, 180),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(100, 200),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 2),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Wind,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LightEmission = 0.6
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(180, 255, 200), 6, 15)

	return vortex
end

local function castPhongThanKetGioi(player, targetPosition)
	local vortex = createWindVortex(targetPosition)

	-- Liên tục check enemies trong 3 giây
	local duration = 3
	local startTime = tick()
	local affectedCharacters = {}

	local heartbeat
	heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
		if tick() - startTime >= duration then
			heartbeat:Disconnect()

			-- Restore speeds
			for char, originalSpeed in pairs(affectedCharacters) do
				local humanoid = char:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.WalkSpeed = originalSpeed
				end
			end

			vortex:Destroy()
			return
		end

		-- Check enemies in radius
		local hitParts = workspace:GetPartBoundsInRadius(targetPosition, 10)
		for _, part in ipairs(hitParts) do
			local character = part.Parent
			local humanoid = character and character:FindFirstChild("Humanoid")
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoid and humanoidRootPart and character ~= player.Character then
				-- Save original speed
				if not affectedCharacters[character] then
					affectedCharacters[character] = humanoid.WalkSpeed
				end

				-- Slow 30%
				humanoid.WalkSpeed = affectedCharacters[character] * 0.7

				-- Knockback from center
				local direction = (humanoidRootPart.Position - targetPosition).Unit
				VFXUtils.ApplyKnockback(character, direction, 20)
			end
		end
	end)

	Debris:AddItem(vortex, duration)

	print("🌪️ " .. player.Name .. " cast Phong Thần Kết Giới!")
end

skillRemote.OnServerEvent:Connect(function(player, targetPosition)
	if typeof(targetPosition) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	castPhongThanKetGioi(player, targetPosition)
end)

print("✅ Phong Thần Kết Giới Server loaded!")
