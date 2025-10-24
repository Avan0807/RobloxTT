-- LootService.lua - Server Loot Management
-- Copy vào ServerScriptService/LootService (Script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LootModule = require(ReplicatedStorage.Modules.Loot.LootModule)
local InventoryModule = require(ReplicatedStorage.Modules.Inventory.InventoryModule)

local LootService = {}
LootService.ActiveLoots = {} -- {lootPart = lootData}

-- ========================================
-- CREATE LOOT DROP
-- ========================================

function LootService.CreateLootDrop(position, enemyLevel)
	-- Generate loot
	local lootItems = LootModule.GenerateLoot(enemyLevel)

	if not lootItems or #lootItems == 0 then
		return nil
	end

	-- Create visual loot drops
	local lootDrops = {}

	for i, lootData in ipairs(lootItems) do
		-- Offset position for multiple items
		local offset = Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
		local lootPosition = position + offset

		-- Create loot part
		local lootPart = LootModule.CreateLootDrop(lootPosition, lootData)
		lootPart.Parent = workspace

		-- Store loot data
		LootService.ActiveLoots[lootPart] = lootData

		-- Animate spawn (bounce effect)
		task.spawn(function()
			local startY = lootPosition.Y
			for t = 0, 1, 0.1 do
				if lootPart.Parent then
					local bounce = math.sin(t * math.pi) * 3
					lootPart.Position = Vector3.new(lootPosition.X, startY + bounce, lootPosition.Z)
					task.wait(0.05)
				end
			end

			if lootPart.Parent then
				lootPart.Position = Vector3.new(lootPosition.X, startY, lootPosition.Z)
			end
		end)

		-- Auto-despawn after 60 seconds
		task.delay(60, function()
			if lootPart.Parent then
				LootService.RemoveLootDrop(lootPart)
			end
		end)

		table.insert(lootDrops, lootPart)
	end

	return lootDrops
end

-- ========================================
-- PICKUP LOOT
-- ========================================

function LootService.PickupLoot(player, lootPart)
	-- Check if loot exists
	local lootData = LootService.ActiveLoots[lootPart]
	if not lootData then
		return false, "Loot not found!"
	end

	-- Get player data
	local playerData = LootService.GetPlayerData(player)
	if not playerData then
		return false, "Player data not found!"
	end

	-- Get player inventory
	if not playerData.Inventory then
		playerData.Inventory = InventoryModule.CreateNew()
	end

	-- Add item to inventory
	local success, msg = InventoryModule.AddItem(playerData.Inventory, lootData, lootData.Amount or 1)

	if success then
		-- Remove loot drop
		LootService.RemoveLootDrop(lootPart)

		-- Notify player
		LootService.NotifyPlayer(player, "Picked up: " .. lootData.Name .. " x" .. (lootData.Amount or 1))

		return true, msg
	else
		return false, msg
	end
end

-- ========================================
-- REMOVE LOOT DROP
-- ========================================

function LootService.RemoveLootDrop(lootPart)
	-- Fade out effect
	task.spawn(function()
		for i = 0, 1, 0.1 do
			if lootPart and lootPart.Parent then
				lootPart.Transparency = i
				task.wait(0.05)
			end
		end

		if lootPart and lootPart.Parent then
			lootPart:Destroy()
		end
	end)

	LootService.ActiveLoots[lootPart] = nil
end

-- ========================================
-- GET PLAYER DATA
-- ========================================

function LootService.GetPlayerData(player)
	-- This should integrate with your existing PlayerDataService
	-- For now, we'll use a simple storage
	if not LootService.PlayerDataCache then
		LootService.PlayerDataCache = {}
	end

	if not LootService.PlayerDataCache[player.UserId] then
		LootService.PlayerDataCache[player.UserId] = {
			Inventory = InventoryModule.CreateNew()
		}
	end

	return LootService.PlayerDataCache[player.UserId]
end

-- ========================================
-- NOTIFY PLAYER
-- ========================================

function LootService.NotifyPlayer(player, message)
	-- Send notification to client
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("LootNotification")

	if remoteEvent then
		remoteEvent:FireClient(player, message)
	else
		-- Fallback: print to output
		print("[Loot] " .. player.Name .. ": " .. message)
	end
end

-- ========================================
-- SETUP PROXIMITY PROMPTS
-- ========================================

function LootService.SetupProximityPrompt(lootPart)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Pick up"
	prompt.ObjectText = LootService.ActiveLoots[lootPart].Name or "Loot"
	prompt.MaxActivationDistance = 10
	prompt.HoldDuration = 0.5
	prompt.Parent = lootPart

	prompt.Triggered:Connect(function(player)
		LootService.PickupLoot(player, lootPart)
	end)

	return prompt
end

-- ========================================
-- MODIFY CreateLootDrop to add ProximityPrompt
-- ========================================

local originalCreateLootDrop = LootService.CreateLootDrop
function LootService.CreateLootDrop(position, enemyLevel)
	local lootDrops = originalCreateLootDrop(position, enemyLevel)

	if lootDrops then
		for _, lootPart in ipairs(lootDrops) do
			LootService.SetupProximityPrompt(lootPart)
		end
	end

	return lootDrops
end

-- ========================================
-- AUTO-PICKUP (Optional - for nearby players)
-- ========================================

function LootService.StartAutoPickup()
	task.spawn(function()
		while true do
			task.wait(0.5)

			for lootPart, lootData in pairs(LootService.ActiveLoots) do
				if lootPart and lootPart.Parent then
					-- Find nearby players
					local position = lootPart.Position
					for _, player in ipairs(game.Players:GetPlayers()) do
						if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
							local distance = (player.Character.HumanoidRootPart.Position - position).Magnitude

							-- Auto-pickup if very close (2 studs)
							if distance <= 2 then
								LootService.PickupLoot(player, lootPart)
								break
							end
						end
					end
				end
			end
		end
	end)
end

-- ========================================
-- INTEGRATE WITH ENEMY SERVICE
-- ========================================

function LootService.OnEnemyKilled(enemyModel, position, enemyLevel)
	-- Create loot drop
	LootService.CreateLootDrop(position, enemyLevel)
end

-- ========================================
-- INITIALIZE
-- ========================================

function LootService.Initialize()
	print("🎁 LootService initializing...")

	-- Start auto-pickup loop
	LootService.StartAutoPickup()

	-- Listen for enemy deaths (integrate with EnemyService)
	local EnemyService = script.Parent:FindFirstChild("EnemyService")
	if EnemyService then
		-- You'll need to add this event to EnemyService
		-- EnemyService.OnEnemyKilled:Connect(LootService.OnEnemyKilled)
	end

	print("✅ LootService ready!")
end

-- Auto-initialize
LootService.Initialize()

return LootService
