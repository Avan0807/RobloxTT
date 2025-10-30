-- ============================================
-- THẦN LỰC DẪN NỔ - SERVER (PASSIVE)
-- Khi trúng 5 đòn, kích hoạt bùng nổ năng lượng (nổ vòng 3m)
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local hitCounters = {}  -- Track hits per player

local EXPLOSION_COLORS = {
	Color3.fromRGB(255, 150, 0),
	Color3.fromRGB(255, 100, 0),
	Color3.fromRGB(255, 50, 0)
}

local function triggerExplosion(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local position = humanoidRootPart.Position

	-- Massive explosion
	VFXUtils.CreateExplosion(position, {
		Color = EXPLOSION_COLORS,
		Size = 8,
		ParticleCount = 150,
		LightColor = Color3.fromRGB(255, 100, 0)
	})

	-- Damage all enemies in radius
	VFXUtils.DamageInRadius(position, 6, 40, {character})

	-- Knockback
	local hitParts = workspace:GetPartBoundsInRadius(position, 6)
	for _, part in ipairs(hitParts) do
		local targetChar = part.Parent
		if targetChar and targetChar ~= character then
			local direction = (part.Position - position).Unit
			VFXUtils.ApplyKnockback(targetChar, direction, 60)
		end
	end

	print("💥💥💥 THẦN LỰC DẪN NỔ TRIGGERED! Area explosion!")
end

-- Function to call when player lands a hit
function RecordHitForThanLuc(player)
	if not hitCounters[player.UserId] then
		hitCounters[player.UserId] = {count = 0, lastHitTime = 0}
	end

	local data = hitCounters[player.UserId]
	local currentTime = tick()

	-- Reset counter if too much time passed (5 seconds)
	if currentTime - data.lastHitTime > 5 then
		data.count = 0
	end

	data.count = data.count + 1
	data.lastHitTime = currentTime

	print("💢 " .. player.Name .. " hit count: " .. data.count .. "/5")

	-- Trigger explosion on 5th hit
	if data.count >= 5 then
		local character = player.Character
		if character then
			triggerExplosion(character)
		end

		-- Reset counter
		data.count = 0
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		hitCounters[player.UserId] = {count = 0, lastHitTime = 0}
		print("✅ Thần Lực Dẫn Nổ tracking for " .. player.Name)
	end)
end)

print("✅ Thần Lực Dẫn Nổ (Passive) Server loaded!")
