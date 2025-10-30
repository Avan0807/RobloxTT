-- ============================================
-- TỬ ẢNH HOÁN THÂN - SERVER
-- Đổi chỗ với bóng ma cách xa tối đa 12m (iframe 0.4s)
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("TuAnhHoanThanRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "TuAnhHoanThanRemote"
	skillRemote.Parent = ReplicatedStorage
end

local function createShadowPortal(position)
	local portal = Instance.new("Part")
	portal.Name = "ShadowPortal"
	portal.Shape = Enum.PartType.Cylinder
	portal.Size = Vector3.new(0.5, 4, 4)
	portal.Position = position + Vector3.new(0, 0.3, 0)
	portal.Orientation = Vector3.new(0, 0, 90)
	portal.Transparency = 0.5
	portal.CanCollide = false
	portal.Anchored = true
	portal.Material = Enum.Material.Neon
	portal.BrickColor = BrickColor.new("Really black")
	portal.Parent = workspace

	local attachment = VFXUtils.CreateAttachment(portal)

	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Smoke,
		Lifetime = NumberRange.new(0.5, 0.8),
		Rate = 0,
		Speed = NumberRange.new(5, 15),
		SpreadAngle = Vector2.new(180, 180),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(100, 200),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2),
			NumberSequenceKeypoint.new(0.5, 3),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Dark,
		LightEmission = 0.7,
		EmitCount = 50
	}):Emit(50)

	VFXUtils.CreateLight(attachment, Color3.fromRGB(100, 0, 150), 8, 15)

	Debris:AddItem(portal, 1)
end

local function performTuAnhHoanThan(player, targetPosition)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local oldPosition = humanoidRootPart.Position

	-- Create portals at both positions
	createShadowPortal(oldPosition)
	createShadowPortal(targetPosition)

	-- Teleport
	humanoidRootPart.CFrame = CFrame.new(targetPosition)

	-- Iframe 0.4s
	local originalCanCollide = humanoidRootPart.CanCollide
	humanoidRootPart.CanCollide = false

	-- Shadow effect during teleport
	local shadow = Instance.new("Part")
	shadow.Name = "TeleportShadow"
	shadow.Size = Vector3.new(2, 5, 1)
	shadow.Position = targetPosition
	shadow.Transparency = 0.3
	shadow.CanCollide = false
	shadow.Anchored = true
	shadow.Material = Enum.Material.Neon
	shadow.BrickColor = BrickColor.new("Really black")
	shadow.Parent = workspace

	local attachment = VFXUtils.CreateAttachment(shadow)

	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Smoke,
		Lifetime = NumberRange.new(0.3, 0.5),
		Rate = 100,
		Speed = NumberRange.new(2, 6),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new(1.5),
		Color = VFXUtils.Colors.Dark,
		LightEmission = 0.6
	})

	Debris:AddItem(shadow, 0.5)

	-- Restore collision
	task.wait(0.4)
	humanoidRootPart.CanCollide = originalCanCollide

	print("🌀 " .. player.Name .. " swapped positions with shadow!")
end

skillRemote.OnServerEvent:Connect(function(player, targetPosition)
	if typeof(targetPosition) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	performTuAnhHoanThan(player, targetPosition)
end)

print("✅ Tử Ảnh Hoán Thân Server loaded!")
