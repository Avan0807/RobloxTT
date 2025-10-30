-- ============================================
-- CỔ QUYỀN TAM LIÊN - SERVER
-- 3 cú combo punch: light > heavy > ground slam
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("CoQuyenTamLienRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "CoQuyenTamLienRemote"
	skillRemote.Parent = ReplicatedStorage
end

local PUNCH_COLORS = {
	Color3.fromRGB(255, 200, 100), -- Light punch - vàng nhạt
	Color3.fromRGB(255, 150, 50),  -- Heavy punch - cam
	Color3.fromRGB(255, 100, 0)    -- Ground slam - đỏ cam
}

local function createPunchEffect(origin, direction, comboNumber)
	local punchWave = VFXUtils.CreateProjectile({
		Name = "PunchWave_" .. comboNumber,
		Shape = Enum.PartType.Block,
		Size = Vector3.new(2 + comboNumber, 2 + comboNumber, 1),
		Position = origin + Vector3.new(0, 1, 0),
		Transparency = 0.5,
		BrickColor = BrickColor.new("Bright orange"),
		Velocity = direction * (40 + comboNumber * 10)
	})

	local attachment = VFXUtils.CreateAttachment(punchWave)

	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Smoke,
		Lifetime = NumberRange.new(0.3, 0.6),
		Rate = 40 + comboNumber * 20,
		Speed = NumberRange.new(2, 8),
		SpreadAngle = Vector2.new(30, 30),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.5),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = {PUNCH_COLORS[comboNumber]},
		LightEmission = 0.5
	})

	VFXUtils.CreateLight(attachment, PUNCH_COLORS[comboNumber], 5, 10)

	return punchWave
end

local function performCombo(player, comboNumber, direction)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local origin = humanoidRootPart.Position
	local punchWave = createPunchEffect(origin, direction, comboNumber)

	local damages = {15, 25, 40}  -- Increasing damage
	local knockbacks = {10, 20, 50}  -- Increasing knockback

	local touchConnection
	touchConnection = punchWave.Touched:Connect(function(hit)
		if hit and not hit:IsDescendantOf(character) then
			local targetChar = hit.Parent
			local humanoid = targetChar and targetChar:FindFirstChild("Humanoid")

			if humanoid then
				humanoid:TakeDamage(damages[comboNumber])
				VFXUtils.ApplyKnockback(targetChar, direction, knockbacks[comboNumber])

				if comboNumber == 3 then
					-- Ground slam - AOE
					VFXUtils.DamageInRadius(punchWave.Position, 5, 20, {character})
					VFXUtils.CreateExplosion(punchWave.Position, {
						Color = {PUNCH_COLORS[3]},
						Size = 5,
						ParticleCount = 80
					})
				end

				print("👊 Cổ Quyền hit " .. comboNumber .. " - Damage: " .. damages[comboNumber])
			end

			touchConnection:Disconnect()
			punchWave:Destroy()
		end
	end)

	game.Debris:AddItem(punchWave, 2)
end

skillRemote.OnServerEvent:Connect(function(player, comboNumber, direction)
	if typeof(comboNumber) ~= "number" or typeof(direction) ~= "Vector3" then return end
	performCombo(player, comboNumber, direction)
end)

print("✅ Cổ Quyền Tam Liên Server loaded!")
