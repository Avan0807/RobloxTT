-- ============================================
-- CỔ ẢNH ĐOẠT HỒN - SERVER (CÔNG PHÁP THƯỢNG PHẨM)
-- Lướt qua kẻ địch tốc độ cao (iframe 0.4s), đánh 2 hit chéo
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("CoAnhDoatHonRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "CoAnhDoatHonRemote"
	skillRemote.Parent = ReplicatedStorage
end

local SLASH_COLORS = {
	Color3.fromRGB(255, 100, 100),
	Color3.fromRGB(255, 50, 50),
	Color3.fromRGB(255, 0, 0)
}

local function createDashTrail(startPos, endPos)
	-- Create multiple shadow clones
	for i = 0, 8 do
		local pos = startPos:Lerp(endPos, i / 8)

		task.delay(i * 0.03, function()
			local shadow = Instance.new("Part")
			shadow.Name = "ShadowClone"
			shadow.Size = Vector3.new(2, 5, 1)
			shadow.Position = pos
			shadow.Transparency = 0.3 + (i * 0.08)
			shadow.CanCollide = false
			shadow.Anchored = true
			shadow.Material = Enum.Material.Neon
			shadow.BrickColor = BrickColor.new("Really red")
			shadow.Parent = workspace

			local attachment = VFXUtils.CreateAttachment(shadow)

			VFXUtils.CreateParticle({
				Parent = attachment,
				Texture = VFXUtils.Textures.Smoke,
				Lifetime = NumberRange.new(0.3, 0.5),
				Rate = 0,
				Speed = NumberRange.new(3, 8),
				SpreadAngle = Vector2.new(180, 180),
				Size = NumberSequence.new(1.5),
				Color = SLASH_COLORS,
				LightEmission = 0.8,
				EmitCount = 15
			}):Emit(15)

			Debris:AddItem(shadow, 0.5)
		end)
	end
end

local function createSlashEffect(position, angle)
	local slash = Instance.new("Part")
	slash.Name = "CrossSlash"
	slash.Shape = Enum.PartType.Block
	slash.Size = Vector3.new(6, 0.5, 10)
	slash.Position = position
	slash.Orientation = Vector3.new(0, angle, 45)
	slash.Transparency = 0.3
	slash.CanCollide = false
	slash.Anchored = true
	slash.Material = Enum.Material.Neon
	slash.BrickColor = BrickColor.new("Really red")
	slash.Parent = workspace

	local attachment = VFXUtils.CreateAttachment(slash)

	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Spark,
		Lifetime = NumberRange.new(0.3, 0.6),
		Rate = 0,
		Speed = NumberRange.new(10, 25),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = SLASH_COLORS,
		LightEmission = 1,
		EmitCount = 60
	}):Emit(60)

	VFXUtils.CreateLight(attachment, Color3.fromRGB(255, 50, 50), 12, 20)

	-- Fade out
	local fadeTween = TweenService:Create(
		slash,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Transparency = 1}
	)
	fadeTween:Play()

	Debris:AddItem(slash, 1)
end

local function performCoAnhDoatHon(player, targetPosition)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local startPos = humanoidRootPart.Position
	local direction = (targetPosition - startPos).Unit
	local dashDistance = 20

	-- Calculate end position (behind target if hitting enemy)
	local endPos = startPos + (direction * dashDistance)

	-- Create dash trail
	createDashTrail(startPos, endPos)

	-- Teleport instantly
	humanoidRootPart.CFrame = CFrame.new(endPos, endPos + direction)

	-- Iframe 0.4s
	local originalCanCollide = humanoidRootPart.CanCollide
	humanoidRootPart.CanCollide = false

	-- Find and hit enemies along path
	local hitEnemies = {}
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {character}

	-- Check for enemies in area
	local midPoint = (startPos + endPos) / 2
	local hitParts = workspace:GetPartBoundsInRadius(midPoint, dashDistance / 2 + 5)

	for _, part in ipairs(hitParts) do
		local targetChar = part.Parent
		local humanoid = targetChar and targetChar:FindFirstChild("Humanoid")

		if humanoid and targetChar ~= character and not hitEnemies[targetChar] then
			hitEnemies[targetChar] = true

			-- First hit
			task.delay(0.1, function()
				humanoid:TakeDamage(40)
				createSlashEffect(part.Position, 45)
				VFXUtils.ApplyKnockback(targetChar, direction, 20)
				print("⚔️ Cổ Ảnh Đoạt Hồn - Hit 1 on " .. targetChar.Name)
			end)

			-- Second hit (cross slash)
			task.delay(0.25, function()
				humanoid:TakeDamage(40)
				createSlashEffect(part.Position, -45)
				VFXUtils.ApplyKnockback(targetChar, Vector3.new(0, 1, 0), 40)
				print("⚔️⚔️ Cổ Ảnh Đoạt Hồn - Hit 2 on " .. targetChar.Name)
			end)
		end
	end

	-- Arrival effect
	VFXUtils.CreateExplosion(endPos, {
		Color = SLASH_COLORS,
		Size = 5,
		ParticleCount = 80
	})

	-- Restore collision after iframe
	task.wait(0.4)
	humanoidRootPart.CanCollide = originalCanCollide

	print("⚔️ " .. player.Name .. " used Cổ Ảnh Đoạt Hồn!")
end

skillRemote.OnServerEvent:Connect(function(player, targetPosition)
	if typeof(targetPosition) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	performCoAnhDoatHon(player, targetPosition)
end)

print("✅ Cổ Ảnh Đoạt Hồn Server loaded!")
