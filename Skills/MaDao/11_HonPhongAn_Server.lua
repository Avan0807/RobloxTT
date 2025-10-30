-- ============================================
-- HỒN PHONG ẤN - SERVER (CÔNG PHÁP THƯỢNG PHẨM)
-- Đánh dấu linh hồn, nếu địch chết trong 6s → bị giam linh hồn, không thể hồi sinh
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("HonPhongAnRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "HonPhongAnRemote"
	skillRemote.Parent = ReplicatedStorage
end

local sealedSouls = {}

local SEAL_COLORS = {
	Color3.fromRGB(200, 0, 255),
	Color3.fromRGB(150, 0, 200),
	Color3.fromRGB(100, 0, 150)
}

local function createSealMark(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end

	-- Seal mark above head
	local seal = Instance.new("Part")
	seal.Name = "SoulSeal"
	seal.Shape = Enum.PartType.Cylinder
	seal.Size = Vector3.new(0.2, 3, 3)
	seal.Position = humanoidRootPart.Position + Vector3.new(0, 4, 0)
	seal.Orientation = Vector3.new(0, 0, 90)
	seal.Transparency = 0.5
	seal.CanCollide = false
	seal.Anchored = false
	seal.Material = Enum.Material.Neon
	seal.BrickColor = BrickColor.new("Royal purple")
	seal.Parent = workspace

	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart
	weld.Part1 = seal
	weld.C0 = CFrame.new(0, 4, 0)
	weld.Parent = seal

	local attachment = VFXUtils.CreateAttachment(seal)

	-- Seal particles
	VFXUtils.CreateParticle({
		Parent = attachment,
		Texture = VFXUtils.Textures.Magic,
		Lifetime = NumberRange.new(0.8, 1.2),
		Rate = 60,
		Speed = NumberRange.new(1, 4),
		SpreadAngle = Vector2.new(30, 30),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(100, 200),
		Size = NumberSequence.new(1.5),
		Color = SEAL_COLORS,
		LightEmission = 1
	})

	-- Chains
	for i = 1, 4 do
		local chain = Instance.new("Part")
		chain.Name = "SealChain"
		chain.Size = Vector3.new(0.2, 5, 0.2)
		chain.Position = humanoidRootPart.Position + Vector3.new(0, 2.5, 0)
		chain.Transparency = 0.3
		chain.CanCollide = false
		chain.Anchored = false
		chain.Material = Enum.Material.Neon
		chain.BrickColor = BrickColor.new("Royal purple")
		chain.Parent = workspace

		local angle = (i / 4) * math.pi * 2
		local offset = Vector3.new(math.cos(angle) * 2, 2.5, math.sin(angle) * 2)

		local weld2 = Instance.new("Weld")
		weld2.Part0 = humanoidRootPart
		weld2.Part1 = chain
		weld2.C0 = CFrame.new(offset)
		weld2.Parent = chain

		game.Debris:AddItem(chain, 6)
	end

	VFXUtils.CreateLight(attachment, Color3.fromRGB(200, 0, 255), 8, 15)

	return seal
end

local function applySoulSeal(player, targetCharacter)
	local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
	if not targetPlayer then return end

	local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
	if not targetHumanoid then return end

	-- Create seal mark
	local seal = createSealMark(targetCharacter)

	-- Track sealed target
	sealedSouls[targetPlayer.UserId] = {
		character = targetCharacter,
		seal = seal,
		startTime = tick(),
		caster = player
	}

	print("🔒 " .. player.Name .. " sealed " .. targetPlayer.Name .. "'s soul!")

	-- Monitor death
	local deathConnection
	deathConnection = targetHumanoid.Died:Connect(function()
		local sealData = sealedSouls[targetPlayer.UserId]
		if sealData and tick() - sealData.startTime < 6 then
			-- Soul imprisoned!
			print("🔒💀 " .. targetPlayer.Name .. "'s soul is IMPRISONED! Cannot respawn!")

			-- Prevent respawn (visual effect - game logic needed)
			local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				-- Create soul prison effect
				for i = 1, 3 do
					task.delay(i * 0.3, function()
						VFXUtils.CreateExplosion(targetRoot.Position, {
							Color = SEAL_COLORS,
							Size = 5 + i,
							ParticleCount = 60,
							LightColor = Color3.fromRGB(200, 0, 255)
						})
					end)
				end

				-- Soul orb trapped
				local soulOrb = Instance.new("Part")
				soulOrb.Name = "TrappedSoul"
				soulOrb.Shape = Enum.PartType.Ball
				soulOrb.Size = Vector3.new(2, 2, 2)
				soulOrb.Position = targetRoot.Position + Vector3.new(0, 3, 0)
				soulOrb.Transparency = 0.3
				soulOrb.CanCollide = false
				soulOrb.Anchored = true
				soulOrb.Material = Enum.Material.Neon
				soulOrb.BrickColor = BrickColor.new("Alder")
				soulOrb.Parent = workspace

				local att = VFXUtils.CreateAttachment(soulOrb)
				VFXUtils.CreateLight(att, Color3.fromRGB(150, 100, 200), 10, 20)

				game.Debris:AddItem(soulOrb, 5)
			end
		end

		deathConnection:Disconnect()
		sealedSouls[targetPlayer.UserId] = nil
	end)

	-- Remove seal after 6s
	task.delay(6, function()
		if seal then
			seal:Destroy()
		end
		if sealedSouls[targetPlayer.UserId] then
			sealedSouls[targetPlayer.UserId] = nil
			deathConnection:Disconnect()
			print("🔒 Seal on " .. targetPlayer.Name .. " expired")
		end
	end)

	game.Debris:AddItem(seal, 6)
end

skillRemote.OnServerEvent:Connect(function(player, targetCharacter)
	if not targetCharacter or not targetCharacter:IsA("Model") then
		warn("⚠️ Invalid target")
		return
	end

	applySoulSeal(player, targetCharacter)
end)

print("✅ Hồn Phong Ấn Server loaded!")
