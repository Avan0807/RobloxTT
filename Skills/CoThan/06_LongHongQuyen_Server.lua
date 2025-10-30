-- ============================================
-- LONG HỐNG QUYỀN - SERVER
-- Hét ra khí xung chặn đòn địch, gây stagger nhẹ
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("LongHongQuyenRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "LongHongQuyenRemote"
	skillRemote.Parent = ReplicatedStorage
end

local ROAR_COLORS = {
	Color3.fromRGB(255, 200, 100),
	Color3.fromRGB(255, 180, 80),
	Color3.fromRGB(255, 160, 60)
}

local function createShockwave(origin)
	local shockwave = Instance.new("Part")
	shockwave.Name = "DragonRoar"
	shockwave.Shape = Enum.PartType.Ball
	shockwave.Size = Vector3.new(3, 3, 3)
	shockwave.Position = origin
	shockwave.Transparency = 0.7
	shockwave.CanCollide = false
	shockwave.Anchored = true
	shockwave.Material = Enum.Material.Neon
	shockwave.BrickColor = BrickColor.new("Deep orange")
	shockwave.Parent = workspace

	local attachment = VFXUtils.CreateAttachment(shockwave)

	-- Roar particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Smoke,
		Lifetime = NumberRange.new(0.6, 1),
		Rate = 0,
		Speed = NumberRange.new(20, 40),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2),
			NumberSequenceKeypoint.new(0.5, 4),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = ROAR_COLORS,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LightEmission = 0.6,
		EmitCount = 100
	}):Emit(100)

	VFXUtils.CreateLight(attachment, Color3.fromRGB(255, 180, 80), 15, 25)

	-- Expand shockwave
	local tweenService = game:GetService("TweenService")
	local expandTween = tweenService:Create(
		shockwave,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = Vector3.new(20, 20, 20), Transparency = 1}
	)
	expandTween:Play()

	Debris:AddItem(shockwave, 1)

	return shockwave
end

local function performLongHongQuyen(player)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local origin = humanoidRootPart.Position + Vector3.new(0, 2, 0)

	-- Create expanding shockwave
	createShockwave(origin)

	-- Damage and stagger enemies in radius
	local hitParts = workspace:GetPartBoundsInRadius(origin, 15)
	local affectedCharacters = {}

	for _, part in ipairs(hitParts) do
		local targetChar = part.Parent
		local humanoid = targetChar and targetChar:FindFirstChild("Humanoid")
		local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

		if humanoid and targetRoot and targetChar ~= character and not affectedCharacters[targetChar] then
			affectedCharacters[targetChar] = true

			-- Light damage
			humanoid:TakeDamage(20)

			-- Stagger (push back)
			local direction = (targetRoot.Position - origin).Unit
			VFXUtils.ApplyKnockback(targetChar, direction, 35)

			print("🐉 Long Hống Quyền staggered " .. targetChar.Name)
		end
	end

	-- Block incoming projectiles
	-- TODO: Implement projectile destruction logic

	print("🐉 " .. player.Name .. " unleashed Long Hống Quyền! Enemies staggered")
end

skillRemote.OnServerEvent:Connect(function(player)
	performLongHongQuyen(player)
end)

print("✅ Long Hống Quyền Server loaded!")
