-- ============================================
-- THÁI HƯ PHONG GIỚI - SERVER (CÔNG PHÁP THƯỢNG PHẨM)
-- Tạo domain 10m giảm 50% cooldown cho bản thân, tăng cast speed 30% (10s)
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("ThaiHuPhongGioiRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "ThaiHuPhongGioiRemote"
	skillRemote.Parent = ReplicatedStorage
end

local activeDomains = {}

local function createDomain(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end

	-- Domain sphere
	local domain = Instance.new("Part")
	domain.Name = "ThaiHuDomain"
	domain.Shape = Enum.PartType.Ball
	domain.Size = Vector3.new(20, 20, 20)
	domain.Position = humanoidRootPart.Position
	domain.Transparency = 0.7
	domain.CanCollide = false
	domain.Anchored = true
	domain.Material = Enum.Material.ForceField
	domain.BrickColor = BrickColor.new("Bright blue")
	domain.Parent = workspace

	local attachment = VFXUtils.CreateAttachment(domain)

	-- Magic circle particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Magic,
		Lifetime = NumberRange.new(1, 1.5),
		Rate = 100,
		Speed = NumberRange.new(3, 8),
		SpreadAngle = Vector2.new(180, 180),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(50, 100),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2),
			NumberSequenceKeypoint.new(0.5, 2.5),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Color = {
			Color3.fromRGB(150, 200, 255),
			Color3.fromRGB(200, 220, 255),
			Color3.fromRGB(255, 255, 255)
		},
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LightEmission = 0.9
	})

	-- Swirling effect
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Star,
		Lifetime = NumberRange.new(2, 3),
		Rate = 50,
		Speed = NumberRange.new(5, 10),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new(1.5),
		Color = VFXUtils.Colors.Light,
		LightEmission = 1
	})

	VFXUtils.CreateLight(attachment, Color3.fromRGB(200, 220, 255), 12, 25)

	return domain
end

local function activateDomain(player)
	local character = player.Character
	if not character then return end

	local domain = createDomain(character)
	if not domain then return end

	-- Mark player as having domain buff
	activeDomains[player.UserId] = {
		character = character,
		domain = domain,
		startTime = tick()
	}

	print("🌟 " .. player.Name .. " activated Thái Hư Phong Giới! 50% CDR + 30% Cast Speed for 10s")

	-- TODO: Implement actual cooldown reduction and cast speed buff
	-- This would require integration with your skill system

	-- Remove after 10s
	task.delay(10, function()
		if domain then
			-- Fade out effect
			VFXUtils.CreateExplosion(domain.Position, {
				Color = VFXUtils.Colors.Light,
				Size = 5,
				ParticleCount = 100
			})

			domain:Destroy()
		end

		activeDomains[player.UserId] = nil
		print("🌟 " .. player.Name .. "'s domain expired")
	end)

	Debris:AddItem(domain, 10)
end

-- Function to check if player is in domain (for cooldown reduction)
function IsPlayerInDomain(player)
	return activeDomains[player.UserId] ~= nil
end

skillRemote.OnServerEvent:Connect(function(player)
	activateDomain(player)
end)

print("✅ Thái Hư Phong Giới Server loaded!")
