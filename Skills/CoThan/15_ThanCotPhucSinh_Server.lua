-- ============================================
-- THẦN CỐT PHỤC SINH - SERVER (ULTIMATE - CỔ THẦN)
-- Nếu chết, giữ lại 1 HP, trở lại chiến đấu 3s với invincible frame 1.2s
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local playerRevives = {}
local COOLDOWN_TIME = 120  -- 2 phút cooldown

local function createReviveEffect(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	-- Explosion effect
	for i = 1, 3 do
		task.delay(i * 0.2, function()
			VFXUtils.CreateExplosion(humanoidRootPart.Position, {
				Color = {Color3.fromRGB(255, 200, 0), Color3.fromRGB(255, 150, 0)},
				Size = 6,
				ParticleCount = 100
			})
		end)
	end

	-- Aura
	local aura = Instance.new("Part")
	aura.Name = "ReviveAura"
	aura.Shape = Enum.PartType.Ball
	aura.Size = Vector3.new(6, 6, 6)
	aura.Transparency = 0.5
	aura.CanCollide = false
	aura.Anchored = false
	aura.Material = Enum.Material.Neon
	aura.BrickColor = BrickColor.new("Gold")
	aura.Parent = workspace

	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart
	weld.Part1 = aura
	weld.Parent = aura

	game.Debris:AddItem(aura, 1.2)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")

		playerRevives[player.UserId] = tick()  -- Initialize

		humanoid.Died:Connect(function()
			-- Check if revive is off cooldown
			if tick() - playerRevives[player.UserId] >= COOLDOWN_TIME then
				-- REVIVE!
				task.wait(0.1)

				humanoid.Health = 1
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

				createReviveEffect(character)

				-- Invincible for 1.2s
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				if humanoidRootPart then
					local oldCanCollide = humanoidRootPart.CanCollide
					humanoidRootPart.CanCollide = false

					task.wait(1.2)
					humanoidRootPart.CanCollide = oldCanCollide
				end

				-- Set cooldown
				playerRevives[player.UserId] = tick()

				print("💀➡️💪 " .. player.Name .. " REVIVED with Thần Cốt Phục Sinh!")
			end
		end)
	end)
end)

print("✅ Thần Cốt Phục Sinh (ULTIMATE) Server loaded!")
