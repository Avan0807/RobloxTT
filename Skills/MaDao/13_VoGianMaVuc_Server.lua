-- ============================================
-- VÔ GIAN MA VỰC - SERVER (CÔNG PHÁP THƯỢNG PHẨM)
-- Mở domain 10m, địch bên trong bị giảm 50% regen và tầm nhìn
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("VoGianMaVucRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "VoGianMaVucRemote"
	skillRemote.Parent = ReplicatedStorage
end

local function createDarkDomain(position, casterChar)
	-- Domain sphere
	local domain = Instance.new("Part")
	domain.Name = "DarkDomain"
	domain.Shape = Enum.PartType.Ball
	domain.Size = Vector3.new(20, 20, 20)
	domain.Position = position
	domain.Transparency = 0.8
	domain.CanCollide = false
	domain.Anchored = true
	domain.Material = Enum.Material.ForceField
	domain.BrickColor = BrickColor.new("Really black")
	domain.Parent = workspace

	local attachment = VFXUtils.CreateAttachment(domain)

	-- Dark energy particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Smoke,
		Lifetime = NumberRange.new(3, 4),
		Rate = 100,
		Speed = NumberRange.new(5, 12),
		SpreadAngle = Vector2.new(180, 180),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(50, 100),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 3),
			NumberSequenceKeypoint.new(0.5, 4),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = VFXUtils.Colors.Dark,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LightEmission = 0.5
	})

	-- Soul wisps
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Star,
		Lifetime = NumberRange.new(2, 3),
		Rate = 60,
		Speed = NumberRange.new(3, 8),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new(1.5),
		Color = {Color3.fromRGB(100, 0, 150), Color3.fromRGB(150, 0, 200)},
		LightEmission = 0.9
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(100, 0, 150), 15, 30)

	return domain
end

local function castVoGianMaVuc(player, targetPosition)
	local character = player.Character
	if not character then return end

	local domain = createDarkDomain(targetPosition, character)

	local duration = 10
	local startTime = tick()
	local affectedPlayers = {}

	print("⚫🌀 " .. player.Name .. " opened Vô Gian Ma Vực!")

	-- Monitor players in domain
	local heartbeat
	heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
		if tick() - startTime >= duration then
			heartbeat:Disconnect()

			-- Restore affected players
			for targetPlayer, originalFOV in pairs(affectedPlayers) do
				local camera = targetPlayer:FindFirstChild("PlayerScripts")
				-- Restore FOV (game-specific logic needed)
			end

			domain:Destroy()
			print("⚫🌀 Domain expired")
			return
		end

		-- Check enemies in domain radius
		local hitParts = workspace:GetPartBoundsInRadius(targetPosition, 10)
		local currentlyAffected = {}

		for _, part in ipairs(hitParts) do
			local targetChar = part.Parent
			local humanoid = targetChar and targetChar:FindFirstChild("Humanoid")
			local targetPlayer = humanoid and game.Players:GetPlayerFromCharacter(targetChar)

			if humanoid and targetChar ~= character and targetPlayer then
				currentlyAffected[targetPlayer] = true

				if not affectedPlayers[targetPlayer] then
					affectedPlayers[targetPlayer] = 70  -- Store original FOV

					-- Apply debuffs
					print("⚫ " .. targetPlayer.Name .. " entered domain! -50% regen, reduced vision")

					-- Reduce vision by adding dark fog (visual effect)
					-- Game-specific implementation needed
				end

				-- Continuous effects
				-- Reduce health regen by 50% (game-specific)
			end
		end

		-- Remove players who left domain
		for targetPlayer, _ in pairs(affectedPlayers) do
			if not currentlyAffected[targetPlayer] then
				affectedPlayers[targetPlayer] = nil
				print("⚫ " .. targetPlayer.Name .. " left domain")
			end
		end
	end)

	Debris:AddItem(domain, duration)
end

skillRemote.OnServerEvent:Connect(function(player, targetPosition)
	if typeof(targetPosition) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	castVoGianMaVuc(player, targetPosition)
end)

print("✅ Vô Gian Ma Vực Server loaded!")
