-- ============================================
-- LÔI ẢNH DỊCH THÂN - SERVER
-- Dịch chuyển 8m về hướng chuột, để lại bóng sét đánh ngược lại (iframe 0.4s)
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("LoiAnhDichThanRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "LoiAnhDichThanRemote"
	skillRemote.Parent = ReplicatedStorage
end

local function createLightningShadow(position)
	local shadow = Instance.new("Part")
	shadow.Name = "LightningShadow"
	shadow.Size = Vector3.new(3, 6, 0.5)
	shadow.Position = position
	shadow.Transparency = 0.5
	shadow.CanCollide = false
	shadow.Anchored = true
	shadow.Material = Enum.Material.Neon
	shadow.BrickColor = BrickColor.new("Electric blue")
	shadow.Parent = workspace

	-- Lightning effect
	local attachment = VFXUtils.CreateAttachment(shadow)
	local lightning = VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Lightning,
		Lifetime = NumberRange.new(0.2, 0.4),
		Rate = 100,
		Speed = NumberRange.new(5, 15),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Lightning,
		LightEmission = 1
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(150, 180, 255), 8, 15)

	-- Sau 0.5s tự động gây damage
	task.delay(0.5, function()
		VFXUtils.DamageInRadius(shadow.Position, 5, 25)
		VFXUtils.CreateExplosion(shadow.Position, {
			Color = VFXUtils.Colors.Lightning,
			Size = 3,
			ParticleCount = 50
		})
		shadow:Destroy()
	end)

	Debris:AddItem(shadow, 1)
end

local function dashLoiAnhDichThan(player, oldPosition, direction)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	-- Tạo bóng sét ở vị trí cũ
	createLightningShadow(oldPosition)

	-- Teleport 8m
	local newPosition = oldPosition + (direction * 8)
	humanoidRootPart.CFrame = CFrame.new(newPosition)

	-- Iframe 0.4s (tạm thời vô hiệu hóa collision)
	local originalCanCollide = humanoidRootPart.CanCollide
	humanoidRootPart.CanCollide = false

	task.wait(0.4)
	humanoidRootPart.CanCollide = originalCanCollide

	-- Effect tại vị trí mới
	VFXUtils.CreateExplosion(newPosition, {
		Color = VFXUtils.Colors.Lightning,
		Size = 2,
		ParticleCount = 30
	})

	print("⚡ " .. player.Name .. " dashed with Lôi Ảnh Dịch Thân!")
end

skillRemote.OnServerEvent:Connect(function(player, oldPosition, direction)
	if typeof(oldPosition) ~= "Vector3" or typeof(direction) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	dashLoiAnhDichThan(player, oldPosition, direction)
end)

print("✅ Lôi Ảnh Dịch Thân Server loaded!")
