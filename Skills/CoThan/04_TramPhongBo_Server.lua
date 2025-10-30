-- ============================================
-- TRẢM PHONG BỘ - SERVER
-- Dash 10m (iframe 0.3s), đòn tiếp theo gây 1.5x dmg
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("TramPhongBoRemote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "TramPhongBoRemote"
	skillRemote.Parent = ReplicatedStorage
end

local buffedPlayers = {}  -- Track players with damage buff

local function createDashTrail(startPos, endPos)
	-- Create multiple afterimages
	for i = 0, 5 do
		local pos = startPos:Lerp(endPos, i / 5)

		task.delay(i * 0.05, function()
			local afterimage = Instance.new("Part")
			afterimage.Name = "DashAfterimage"
			afterimage.Size = Vector3.new(2, 5, 1)
			afterimage.Position = pos
			afterimage.Transparency = 0.5 + (i * 0.1)
			afterimage.CanCollide = false
			afterimage.Anchored = true
			afterimage.Material = Enum.Material.Neon
			afterimage.BrickColor = BrickColor.new("Deep orange")
			afterimage.Parent = workspace

			local attachment = VFXUtils.CreateAttachment(afterimage)

			VFXUtils.CreateParticle({
				Parent = attachment,
				Texture = VFXUtils.Textures.Smoke,
				Lifetime = NumberRange.new(0.3, 0.5),
				Rate = 0,
				Speed = NumberRange.new(2, 6),
				SpreadAngle = Vector2.new(180, 180),
				Size = NumberSequence.new(1.5),
				Color = {Color3.fromRGB(255, 150, 50), Color3.fromRGB(255, 100, 0)},
				LightEmission = 0.7,
				EmitCount = 20
			}):Emit(20)

			game.Debris:AddItem(afterimage, 0.5)
		end)
	end
end

local function performTramPhongBo(player, direction)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local startPos = humanoidRootPart.Position
	local endPos = startPos + (direction * 10)

	-- Create dash trail
	createDashTrail(startPos, endPos)

	-- Teleport
	humanoidRootPart.CFrame = CFrame.new(endPos, endPos + direction)

	-- Iframe 0.3s
	local originalCanCollide = humanoidRootPart.CanCollide
	humanoidRootPart.CanCollide = false

	-- Effect at arrival
	VFXUtils.CreateExplosion(endPos, {
		Color = {Color3.fromRGB(255, 150, 50), Color3.fromRGB(255, 100, 0)},
		Size = 3,
		ParticleCount = 40
	})

	-- Apply damage buff
	buffedPlayers[player.UserId] = {
		character = character,
		endTime = tick() + 3  -- 3 second buff window
	}

	print("💨 " .. player.Name .. " dashed with Trảm Phong Bộ! Next attack: +50% damage")

	-- Restore collision after iframe
	task.wait(0.3)
	humanoidRootPart.CanCollide = originalCanCollide

	-- Remove buff after 3s
	task.delay(3, function()
		if buffedPlayers[player.UserId] then
			buffedPlayers[player.UserId] = nil
			print("💨 " .. player.Name .. "'s damage buff expired")
		end
	end)
end

-- Function to check if player has damage buff
function HasTramPhongBoBuff(player)
	local buffData = buffedPlayers[player.UserId]
	if buffData and tick() < buffData.endTime then
		return true, 1.5  -- Return true and damage multiplier
	end
	return false, 1.0
end

skillRemote.OnServerEvent:Connect(function(player, direction)
	if typeof(direction) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	performTramPhongBo(player, direction)
end)

print("✅ Trảm Phong Bộ Server loaded!")
