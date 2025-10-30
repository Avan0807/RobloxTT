-- ============================================
-- THIẾT CỐT PHÒNG THỂ - SERVER
-- Giảm 50% sát thương trong 2s, cho phép counter
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("ThietCotPhongTheRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "ThietCotPhongTheRemote"
	skillRemote.Parent = ReplicatedStorage
end

local defendingPlayers = {}

local DEFENSE_COLORS = {
	Color3.fromRGB(100, 100, 100),
	Color3.fromRGB(120, 120, 120),
	Color3.fromRGB(140, 140, 140)
}

local function createDefenseShield(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end

	local shield = Instance.new("Part")
	shield.Name = "IronDefense"
	shield.Shape = Enum.PartType.Ball
	shield.Size = Vector3.new(6, 6, 6)
	shield.Transparency = 0.6
	shield.CanCollide = false
	shield.Anchored = false
	shield.Material = Enum.Material.Metal
	shield.BrickColor = BrickColor.new("Dark stone grey")
	shield.Parent = workspace

	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart
	weld.Part1 = shield
	weld.Parent = shield

	local attachment = VFXUtils.CreateAttachment(shield)

	-- Defense particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Spark,
		Lifetime = NumberRange.new(0.5, 0.8),
		Rate = 60,
		Speed = NumberRange.new(2, 5),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new(1),
		Color = DEFENSE_COLORS,
		LightEmission = 0.5
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(120, 120, 120), 6, 12)

	return shield
end

skillRemote.OnServerEvent:Connect(function(player, isActivating)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	if isActivating then
		-- Activate defense
		local shield = createDefenseShield(character)

		-- Store defense data
		defendingPlayers[player.UserId] = {
			character = character,
			shield = shield,
			startTime = tick()
		}

		print("🛡️ " .. player.Name .. " activated Thiết Cốt Phòng Thể! 50% damage reduction")

		-- Monitor for damage to trigger counter
		local healthConnection
		healthConnection = humanoid.HealthChanged:Connect(function(health)
			local defenseData = defendingPlayers[player.UserId]
			if defenseData then
				-- TODO: Implement counter attack logic here
				-- Find the attacker and counter with 150% damage
				print("🛡️⚔️ Counter attack triggered!")
			end
		end)

		-- Remove defense after 2s
		task.delay(2, function()
			if shield then
				shield:Destroy()
			end
			healthConnection:Disconnect()
		end)

	else
		-- Deactivate defense
		local defenseData = defendingPlayers[player.UserId]
		if defenseData and defenseData.shield then
			defenseData.shield:Destroy()
		end
		defendingPlayers[player.UserId] = nil

		print("🛡️ " .. player.Name .. "'s defense ended")
	end
end)

-- Function to check if player is defending (for damage reduction)
function IsPlayerDefending(player)
	local defenseData = defendingPlayers[player.UserId]
	if defenseData and tick() - defenseData.startTime < 2 then
		return true, 0.5  -- Return true and damage multiplier (50% reduction)
	end
	return false, 1.0
end

print("✅ Thiết Cốt Phòng Thể Server loaded!")
