-- ============================================
-- HƯ KHÔNG DỊCH CHUYỂN - SERVER (CÔNG PHÁP THƯỢNG PHẨM)
-- Blink xuyên qua địch, gây AOE khi xuất hiện (iframe 0.5s)
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("HuKhongDichChuyenRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "HuKhongDichChuyenRemote"
	skillRemote.Parent = ReplicatedStorage
end

local function createBlinkTrail(startPos, endPos)
	-- Create portal effects at both positions
	for _, pos in ipairs({startPos, endPos}) do
		local portal = Instance.new("Part")
		portal.Name = "VoidPortal"
		portal.Shape = Enum.PartType.Ball
		portal.Size = Vector3.new(4, 4, 4)
		portal.Position = pos
		portal.Transparency = 0.5
		portal.CanCollide = false
		portal.Anchored = true
		portal.Material = Enum.Material.Neon
		portal.BrickColor = BrickColor.new("Royal purple")
		portal.Parent = workspace

		local attachment = VFXUtils.CreateAttachment(portal)

		-- Void particles
		VFXUtils.CreateParticle({
			Parent = attachment,
			Texture = VFXUtils.Textures.Magic,
			Lifetime = NumberRange.new(0.5, 0.8),
			Rate = 0,
			Speed = NumberRange.new(5, 15),
			SpreadAngle = Vector2.new(180, 180),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 2),
				NumberSequenceKeypoint.new(0.5, 3),
				NumberSequenceKeypoint.new(1, 0)
			}),
			Color = VFXUtils.Colors.Dark,
			LightEmission = 0.8,
			EmitCount = 60
		}):Emit(60)

		VFXUtils.CreateLight(attachment, Color3.fromRGB(150, 0, 200), 10, 20)

		Debris:AddItem(portal, 1)
	end
end

local function blinkHuKhongDichChuyen(player, oldPosition, direction)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	-- Calculate blink distance (15m)
	local blinkDistance = 15
	local newPosition = oldPosition + (direction * blinkDistance)

	-- Create trail effects
	createBlinkTrail(oldPosition, newPosition)

	-- Teleport
	humanoidRootPart.CFrame = CFrame.new(newPosition)

	-- Iframe 0.5s
	local originalCanCollide = humanoidRootPart.CanCollide
	humanoidRootPart.CanCollide = false

	-- AOE damage at arrival
	VFXUtils.DamageInRadius(newPosition, 8, 45, {character})

	-- Explosion at arrival
	VFXUtils.CreateExplosion(newPosition, {
		Color = VFXUtils.Colors.Dark,
		Size = 5,
		ParticleCount = 80,
		LightColor = Color3.fromRGB(150, 0, 200)
	})

	-- Knockback enemies
	local hitParts = workspace:GetPartBoundsInRadius(newPosition, 8)
	for _, part in ipairs(hitParts) do
		local targetChar = part.Parent
		local humanoid = targetChar and targetChar:FindFirstChild("Humanoid")

		if humanoid and targetChar ~= character then
			local knockbackDir = (targetChar:FindFirstChild("HumanoidRootPart").Position - newPosition).Unit
			VFXUtils.ApplyKnockback(targetChar, knockbackDir, 50)
		end
	end

	-- Restore collision after iframe
	task.wait(0.5)
	humanoidRootPart.CanCollide = originalCanCollide

	print("✨ " .. player.Name .. " blinked with Hư Không Dịch Chuyển!")
end

skillRemote.OnServerEvent:Connect(function(player, oldPosition, direction)
	if typeof(oldPosition) ~= "Vector3" or typeof(direction) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	blinkHuKhongDichChuyen(player, oldPosition, direction)
end)

print("✅ Hư Không Dịch Chuyển Server loaded!")
