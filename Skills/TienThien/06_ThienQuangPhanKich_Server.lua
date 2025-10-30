-- ============================================
-- THIÊN QUANG PHẢN KÍCH - SERVER
-- Parry phép: nếu đỡ được skill địch → phản lại 200% sát thương
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("ThienQuangPhanKichRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "ThienQuangPhanKichRemote"
	skillRemote.Parent = ReplicatedStorage
end

local parryingPlayers = {}

local function createParryShield(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end

	local shield = Instance.new("Part")
	shield.Name = "ParryShield"
	shield.Shape = Enum.PartType.Ball
	shield.Size = Vector3.new(6, 6, 6)
	shield.Position = humanoidRootPart.Position
	shield.Transparency = 0.5
	shield.CanCollide = false
	shield.Anchored = true
	shield.Material = Enum.Material.ForceField
	shield.BrickColor = BrickColor.new("Gold")
	shield.Parent = workspace

	-- Weld to character
	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart
	weld.Part1 = shield
	weld.C0 = CFrame.new(0, 0, 0)
	weld.Parent = shield

	local attachment = VFXUtils.CreateAttachment(shield)

	-- Shield particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Star,
		Lifetime = NumberRange.new(0.5, 0.8),
		Rate = 50,
		Speed = NumberRange.new(2, 5),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new(1),
		Color = VFXUtils.Colors.Light,
		LightEmission = 1
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(255, 240, 100), 8, 15)

	return shield
end

skillRemote.OnServerEvent:Connect(function(player, isActivating)
	local character = player.Character
	if not character then return end

	if isActivating then
		-- Activate parry
		parryingPlayers[player.UserId] = {
			character = character,
			startTime = tick()
		}

		local shield = createParryShield(character)

		print("🛡️ " .. player.Name .. " is parrying!")

		-- Remove shield after 0.6s
		task.delay(0.6, function()
			if shield then
				shield:Destroy()
			end
		end)
	else
		-- Deactivate parry
		parryingPlayers[player.UserId] = nil
	end
end)

-- Function to check if attack should be parried
function CheckParry(attackerCharacter, victimCharacter, damage)
	-- Find victim player
	local victimPlayer = game.Players:GetPlayerFromCharacter(victimCharacter)
	if not victimPlayer then return false end

	local parryData = parryingPlayers[victimPlayer.UserId]
	if parryData and parryData.character == victimCharacter then
		-- Parry successful!
		print("✨ PARRY SUCCESS! Reflecting damage!")

		-- Reflect damage 200%
		local attackerHumanoid = attackerCharacter:FindFirstChild("Humanoid")
		if attackerHumanoid then
			attackerHumanoid:TakeDamage(damage * 2)
		end

		-- Effect
		local humanoidRootPart = victimCharacter:FindFirstChild("HumanoidRootPart")
		if humanoidRootPart then
			VFXUtils.CreateExplosion(humanoidRootPart.Position, {
				Color = VFXUtils.Colors.Light,
				Size = 4,
				ParticleCount = 80
			})
		end

		return true
	end

	return false
end

print("✅ Thiên Quang Phản Kích Server loaded!")
