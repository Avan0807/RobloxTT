-- ============================================
-- OAN HỒN ĐUỔI BÓNG - SERVER
-- Triệu hồi 3 hồn bóng đuổi địch 4s (tracking nhẹ)
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("OanHonDuoiBongRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "OanHonDuoiBongRemote"
	skillRemote.Parent = ReplicatedStorage
end

local function createGhostSpirit(origin, targetChar, index)
	local ghost = VFXUtils.CreateProjectile({
		Name = "GhostSpirit_" .. index,
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(2, 3, 2),
		Position = origin + Vector3.new(math.random(-3, 3), 2, math.random(-3, 3)),
		Transparency = 0.6,
		BrickColor = BrickColor.new("Royal purple"),
		Anchored = false
	})

	local attachment = VFXUtils.CreateAttachment(ghost)

	-- Ghost particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Smoke,
		Lifetime = NumberRange.new(0.5, 1),
		Rate = 60,
		Speed = NumberRange.new(2, 6),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.5),
			NumberSequenceKeypoint.new(0.5, 2),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Dark,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LightEmission = 0.7
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(150, 0, 200), 6, 12)

	return ghost
end

local function summonOanHonDuoiBong(player, targetPosition)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	-- Find nearest enemy
	local nearestEnemy = nil
	local shortestDist = math.huge

	for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Character then
			local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
			if otherRoot then
				local dist = (otherRoot.Position - targetPosition).Magnitude
				if dist < shortestDist and dist < 50 then
					shortestDist = dist
					nearestEnemy = otherPlayer.Character
				end
			end
		end
	end

	if not nearestEnemy then
		print("👻 No target found for Oan Hồn Đuổi Bóng")
		return
	end

	-- Summon 3 ghosts
	for i = 1, 3 do
		task.delay((i - 1) * 0.2, function()
			local ghost = createGhostSpirit(humanoidRootPart.Position, nearestEnemy, i)
			local bodyVelocity = ghost:FindFirstChildOfClass("BodyVelocity")

			local startTime = tick()
			local duration = 4
			local hasHit = false

			-- Tracking behavior
			local heartbeat
			heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
				if tick() - startTime >= duration or not ghost.Parent then
					heartbeat:Disconnect()
					if ghost.Parent then
						ghost:Destroy()
					end
					return
				end

				local targetRoot = nearestEnemy:FindFirstChild("HumanoidRootPart")
				if targetRoot and bodyVelocity then
					local direction = (targetRoot.Position - ghost.Position).Unit
					bodyVelocity.Velocity = direction * 40
				end
			end)

			-- Damage on touch
			local touchConnection
			touchConnection = ghost.Touched:Connect(function(hit)
				if hit and hit.Parent == nearestEnemy and not hasHit then
					hasHit = true

					local humanoid = nearestEnemy:FindFirstChild("Humanoid")
					if humanoid then
						humanoid:TakeDamage(15)

						VFXUtils.CreateExplosion(ghost.Position, {
							Color = VFXUtils.Colors.Dark,
							Size = 2,
							ParticleCount = 30
						})

						print("👻 Ghost " .. i .. " hit target!")
					end

					touchConnection:Disconnect()
					heartbeat:Disconnect()
					ghost:Destroy()
				end
			end)

			Debris:AddItem(ghost, duration)
		end)
	end

	print("👻👻👻 " .. player.Name .. " summoned Oan Hồn Đuổi Bóng!")
end

skillRemote.OnServerEvent:Connect(function(player, targetPosition)
	if typeof(targetPosition) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	summonOanHonDuoiBong(player, targetPosition)
end)

print("✅ Oan Hồn Đuổi Bóng Server loaded!")
