-- InventoryService.lua - Server Inventory Management
-- Copy vào ServerScriptService/InventoryService (Script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventoryModule = require(ReplicatedStorage.Modules.Inventory.InventoryModule)

local InventoryService = {}
InventoryService.PlayerInventories = {} -- {userId = inventory}

-- ========================================
-- GET PLAYER INVENTORY
-- ========================================

function InventoryService.GetInventory(player)
	local userId = player.UserId

	if not InventoryService.PlayerInventories[userId] then
		InventoryService.PlayerInventories[userId] = InventoryModule.CreateNew()
	end

	return InventoryService.PlayerInventories[userId]
end

-- ========================================
-- ADD ITEM (Server)
-- ========================================

function InventoryService.AddItem(player, itemData, amount)
	local inventory = InventoryService.GetInventory(player)
	local success, msg = InventoryModule.AddItem(inventory, itemData, amount)

	if success then
		-- Sync to client
		InventoryService.SyncInventory(player)
	end

	return success, msg
end

-- ========================================
-- REMOVE ITEM (Server)
-- ========================================

function InventoryService.RemoveItem(player, itemName, amount)
	local inventory = InventoryService.GetInventory(player)
	local success, msg = InventoryModule.RemoveItem(inventory, itemName, amount)

	if success then
		-- Sync to client
		InventoryService.SyncInventory(player)
	end

	return success, msg
end

-- ========================================
-- USE ITEM (Server)
-- ========================================

function InventoryService.UseItem(player, itemName)
	local inventory = InventoryService.GetInventory(player)

	-- Get player data
	local playerData = InventoryService.GetPlayerData(player)
	if not playerData then
		return false, "Player data not found!"
	end

	local success, msg = InventoryModule.UseItem(inventory, itemName, playerData)

	if success then
		-- Sync to client
		InventoryService.SyncInventory(player)
		InventoryService.SyncPlayerData(player)
	end

	return success, msg
end

-- ========================================
-- SYNC INVENTORY TO CLIENT
-- ========================================

function InventoryService.SyncInventory(player)
	local inventory = InventoryService.GetInventory(player)
	local summary = InventoryModule.GetSummary(inventory)

	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("SyncInventory")

	if remoteEvent then
		remoteEvent:FireClient(player, summary)
	end
end

-- ========================================
-- GET PLAYER DATA
-- ========================================

function InventoryService.GetPlayerData(player)
	-- Integrate with existing PlayerDataService
	local PlayerDataService = script.Parent:FindFirstChild("PlayerDataService")
	if PlayerDataService then
		local module = require(PlayerDataService)
		return module.GetPlayerData and module.GetPlayerData(player)
	end

	-- Fallback: Create temporary data
	return {
		TuVi = 0,
		Realm = 1,
		Level = 1
	}
end

-- ========================================
-- SYNC PLAYER DATA
-- ========================================

function InventoryService.SyncPlayerData(player)
	-- This should call your existing PlayerDataService sync
	local PlayerDataService = script.Parent:FindFirstChild("PlayerDataService")
	if PlayerDataService then
		local module = require(PlayerDataService)
		if module.SyncPlayerData then
			module.SyncPlayerData(player)
		end
	end
end

-- ========================================
-- HANDLE REMOTE EVENTS
-- ========================================

function InventoryService.SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if not remoteEvents then
		remoteEvents = Instance.new("Folder")
		remoteEvents.Name = "RemoteEvents"
		remoteEvents.Parent = ReplicatedStorage
	end

	-- Get Inventory
	local getInventory = remoteEvents:FindFirstChild("GetInventory")
	if not getInventory then
		getInventory = Instance.new("RemoteEvent")
		getInventory.Name = "GetInventory"
		getInventory.Parent = remoteEvents
	end

	getInventory.OnServerEvent:Connect(function(player)
		InventoryService.SyncInventory(player)
	end)

	-- Use Item
	local useItem = remoteEvents:FindFirstChild("UseItem")
	if not useItem then
		useItem = Instance.new("RemoteEvent")
		useItem.Name = "UseItem"
		useItem.Parent = remoteEvents
	end

	useItem.OnServerEvent:Connect(function(player, itemName)
		local success, msg = InventoryService.UseItem(player, itemName)

		-- Send response
		local response = remoteEvents:FindFirstChild("ItemUsed")
		if not response then
			response = Instance.new("RemoteEvent")
			response.Name = "ItemUsed"
			response.Parent = remoteEvents
		end

		response:FireClient(player, success, msg)
	end)

	-- Drop Item (optional)
	local dropItem = remoteEvents:FindFirstChild("DropItem")
	if not dropItem then
		dropItem = Instance.new("RemoteEvent")
		dropItem.Name = "DropItem"
		dropItem.Parent = remoteEvents
	end

	dropItem.OnServerEvent:Connect(function(player, itemName, amount)
		local success, msg = InventoryService.RemoveItem(player, itemName, amount)
		-- Could create a loot drop in world here
	end)

	-- Sort Inventory
	local sortInventory = remoteEvents:FindFirstChild("SortInventory")
	if not sortInventory then
		sortInventory = Instance.new("RemoteEvent")
		sortInventory.Name = "SortInventory"
		sortInventory.Parent = remoteEvents
	end

	sortInventory.OnServerEvent:Connect(function(player)
		local inventory = InventoryService.GetInventory(player)
		InventoryModule.Sort(inventory)
		InventoryService.SyncInventory(player)
	end)
end

-- ========================================
-- PLAYER JOIN/LEAVE
-- ========================================

function InventoryService.OnPlayerJoin(player)
	-- Create inventory
	InventoryService.GetInventory(player)

	-- Give starter items
	InventoryService.GiveStarterItems(player)

	-- Sync to client
	task.wait(2) -- Wait for client to load
	InventoryService.SyncInventory(player)
end

function InventoryService.OnPlayerLeave(player)
	-- Save inventory (integrate with DataStore later)
	-- For now, just remove from memory
	InventoryService.PlayerInventories[player.UserId] = nil
end

-- ========================================
-- GIVE STARTER ITEMS
-- ========================================

function InventoryService.GiveStarterItems(player)
	-- Give some starter gold and pills
	local LootModule = require(ReplicatedStorage.Modules.Loot.LootModule)

	InventoryService.AddItem(player, {Type = "Gold", Name = "Tiên Ngọc"}, 1000)
	InventoryService.AddItem(player, LootModule.Pills.TuKhiDan, 10)
	InventoryService.AddItem(player, LootModule.Pills.TheTuDan, 5)
	InventoryService.AddItem(player, LootModule.Pills.MaDaoDan, 5)
end

-- ========================================
-- INITIALIZE
-- ========================================

function InventoryService.Initialize()
	print("📦 InventoryService initializing...")

	-- Setup remote events
	InventoryService.SetupRemoteEvents()

	-- Connect player events
	game.Players.PlayerAdded:Connect(InventoryService.OnPlayerJoin)
	game.Players.PlayerRemoving:Connect(InventoryService.OnPlayerLeave)

	-- Handle existing players
	for _, player in ipairs(game.Players:GetPlayers()) do
		task.spawn(function()
			InventoryService.OnPlayerJoin(player)
		end)
	end

	print("✅ InventoryService ready!")
end

-- Auto-initialize
InventoryService.Initialize()

return InventoryService
