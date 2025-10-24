-- ShopService.lua - Server Shop Management
-- Copy vào ServerScriptService/ShopService (Script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShopModule = require(ReplicatedStorage.Modules.Shop.ShopModule)
local InventoryModule = require(ReplicatedStorage.Modules.Inventory.InventoryModule)
local LootModule = require(ReplicatedStorage.Modules.Loot.LootModule)
local EquipmentModule = require(ReplicatedStorage.Modules.Equipment.EquipmentModule)

local ShopService = {}
ShopService.ServerShopData = {} -- Track stock per server

-- ========================================
-- INITIALIZE SHOP
-- ========================================

function ShopService.InitializeShop()
	-- Copy shop data
	local allShops = ShopModule.GetAllShops()

	for category, shop in pairs(allShops) do
		ShopService.ServerShopData[category] = {}

		for i, item in ipairs(shop) do
			ShopService.ServerShopData[category][i] = {
				ItemName = item.ItemName,
				Price = item.Price,
				SellPrice = item.SellPrice,
				Stock = item.Stock,
				LevelRequirement = item.LevelRequirement
			}
		end
	end

	print("🛒 Shop initialized with all items")
end

-- ========================================
-- BUY ITEM
-- ========================================

function ShopService.BuyItem(player, itemName, quantity)
	quantity = quantity or 1

	-- Find item in shop
	local shopItem = ShopModule.FindItem(itemName)
	if not shopItem then
		return false, "Item not found in shop!"
	end

	-- Get player data
	local playerData = ShopService.GetPlayerData(player)
	if not playerData then
		return false, "Player data not found!"
	end

	-- Check level requirement
	if shopItem.LevelRequirement and playerData.Level < shopItem.LevelRequirement then
		return false, "Level too low! Required: " .. shopItem.LevelRequirement
	end

	-- Check stock
	if shopItem.Stock ~= -1 then
		local serverStock = ShopService.GetServerStock(shopItem)
		if serverStock < quantity then
			return false, "Not enough stock! Available: " .. serverStock
		end
	end

	-- Calculate total price
	local discount = ShopModule.GetDiscount(shopItem.Category)
	local unitPrice = ShopModule.CalculatePrice(shopItem.Price, playerData.Level, discount)
	local totalPrice = unitPrice * quantity

	-- Get player inventory
	local inventory = ShopService.GetInventory(player)
	if not inventory then
		return false, "Inventory not found!"
	end

	-- Check if can afford
	if inventory.Gold < totalPrice then
		return false, ShopModule.GetRandomDialogue("NoMoney")
	end

	-- Deduct gold
	inventory.Gold = inventory.Gold - totalPrice

	-- Get item data (from LootModule or EquipmentModule)
	local itemData = LootModule.GetItemData(itemName) or EquipmentModule.GetEquipmentData(itemName)

	if not itemData then
		-- Create basic item data
		itemData = {
			Name = itemName,
			Type = "Item",
			Description = shopItem.Description
		}
	end

	-- Add to inventory
	local success, msg = InventoryModule.AddItem(inventory, itemData, quantity)

	if success then
		-- Reduce stock if limited
		if shopItem.Stock ~= -1 then
			ShopService.ReduceStock(shopItem, quantity)
		end

		-- Sync inventory
		ShopService.SyncInventory(player)

		return true, ShopModule.GetRandomDialogue("Buy") .. " (-" .. totalPrice .. " Tiên Ngọc)"
	else
		-- Refund gold
		inventory.Gold = inventory.Gold + totalPrice
		return false, msg
	end
end

-- ========================================
-- SELL ITEM
-- ========================================

function ShopService.SellItem(player, itemName, quantity)
	quantity = quantity or 1

	-- Find item in shop
	local shopItem = ShopModule.FindItem(itemName)
	if not shopItem then
		return false, "Cannot sell this item!"
	end

	-- Check if item can be sold
	if shopItem.SellPrice <= 0 then
		return false, "This item cannot be sold!"
	end

	-- Get player inventory
	local inventory = ShopService.GetInventory(player)
	if not inventory then
		return false, "Inventory not found!"
	end

	-- Check if player has item
	if not InventoryModule.HasItem(inventory, itemName, quantity) then
		return false, "You don't have enough of this item!"
	end

	-- Remove from inventory
	local success, msg = InventoryModule.RemoveItem(inventory, itemName, quantity)

	if success then
		-- Add gold
		local totalGold = shopItem.SellPrice * quantity
		inventory.Gold = inventory.Gold + totalGold

		-- Sync inventory
		ShopService.SyncInventory(player)

		return true, ShopModule.GetRandomDialogue("Sell") .. " (+" .. totalGold .. " Tiên Ngọc)"
	else
		return false, msg
	end
end

-- ========================================
-- GET SERVER STOCK
-- ========================================

function ShopService.GetServerStock(shopItem)
	-- Find in server shop data
	for category, items in pairs(ShopService.ServerShopData) do
		for _, item in ipairs(items) do
			if item.ItemName == shopItem.ItemName then
				return item.Stock
			end
		end
	end

	return shopItem.Stock
end

-- ========================================
-- REDUCE STOCK
-- ========================================

function ShopService.ReduceStock(shopItem, quantity)
	for category, items in pairs(ShopService.ServerShopData) do
		for _, item in ipairs(items) do
			if item.ItemName == shopItem.ItemName then
				if item.Stock > 0 then
					item.Stock = item.Stock - quantity
				end
				return
			end
		end
	end
end

-- ========================================
-- REFRESH SHOP STOCK
-- ========================================

function ShopService.RefreshShop()
	ShopService.InitializeShop()
	ShopModule.RefreshDailyDeals()

	-- Notify all players
	for _, player in ipairs(game.Players:GetPlayers()) do
		ShopService.NotifyPlayer(player, "🛒 Shop has been refreshed!")
		ShopService.SyncShop(player)
	end
end

-- ========================================
-- GET INVENTORY
-- ========================================

function ShopService.GetInventory(player)
	local InventoryService = script.Parent:FindFirstChild("InventoryService")
	if InventoryService then
		local module = require(InventoryService)
		return module.GetInventory and module.GetInventory(player)
	end

	return nil
end

-- ========================================
-- GET PLAYER DATA
-- ========================================

function ShopService.GetPlayerData(player)
	local PlayerDataService = script.Parent:FindFirstChild("PlayerDataService")
	if PlayerDataService then
		local module = require(PlayerDataService)
		return module.GetPlayerData and module.GetPlayerData(player)
	end

	return {Level = 1}
end

-- ========================================
-- SYNC INVENTORY
-- ========================================

function ShopService.SyncInventory(player)
	local InventoryService = script.Parent:FindFirstChild("InventoryService")
	if InventoryService then
		local module = require(InventoryService)
		if module.SyncInventory then
			module.SyncInventory(player)
		end
	end
end

-- ========================================
-- SYNC SHOP TO CLIENT
-- ========================================

function ShopService.SyncShop(player)
	-- Send current shop data
	local shopData = {}

	for category, items in pairs(ShopService.ServerShopData) do
		shopData[category] = items
	end

	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("SyncShop")

	if remoteEvent then
		remoteEvent:FireClient(player, shopData)
	end
end

-- ========================================
-- NOTIFY PLAYER
-- ========================================

function ShopService.NotifyPlayer(player, message)
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("ShopNotification")

	if remoteEvent then
		remoteEvent:FireClient(player, message)
	end
end

-- ========================================
-- SETUP REMOTE EVENTS
-- ========================================

function ShopService.SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if not remoteEvents then
		remoteEvents = Instance.new("Folder")
		remoteEvents.Name = "RemoteEvents"
		remoteEvents.Parent = ReplicatedStorage
	end

	-- Buy Item
	local buyItem = remoteEvents:FindFirstChild("BuyItem")
	if not buyItem then
		buyItem = Instance.new("RemoteEvent")
		buyItem.Name = "BuyItem"
		buyItem.Parent = remoteEvents
	end

	buyItem.OnServerEvent:Connect(function(player, itemName, quantity)
		local success, msg = ShopService.BuyItem(player, itemName, quantity)

		local response = remoteEvents:FindFirstChild("ShopNotification")
		if not response then
			response = Instance.new("RemoteEvent")
			response.Name = "ShopNotification"
			response.Parent = remoteEvents
		end

		response:FireClient(player, msg)

		if success then
			ShopService.SyncShop(player)
		end
	end)

	-- Sell Item
	local sellItem = remoteEvents:FindFirstChild("SellItem")
	if not sellItem then
		sellItem = Instance.new("RemoteEvent")
		sellItem.Name = "SellItem"
		sellItem.Parent = remoteEvents
	end

	sellItem.OnServerEvent:Connect(function(player, itemName, quantity)
		local success, msg = ShopService.SellItem(player, itemName, quantity)

		local response = remoteEvents:FindFirstChild("ShopNotification")
		if response then
			response:FireClient(player, msg)
		end

		if success then
			ShopService.SyncShop(player)
		end
	end)

	-- Get Shop
	local getShop = remoteEvents:FindFirstChild("GetShop")
	if not getShop then
		getShop = Instance.new("RemoteEvent")
		getShop.Name = "GetShop"
		getShop.Parent = remoteEvents
	end

	getShop.OnServerEvent:Connect(function(player)
		ShopService.SyncShop(player)
	end)
end

-- ========================================
-- AUTO REFRESH SHOP (Daily)
-- ========================================

function ShopService.StartAutoRefresh()
	task.spawn(function()
		while true do
			task.wait(86400) -- 24 hours
			ShopService.RefreshShop()
		end
	end)
end

-- ========================================
-- INITIALIZE
-- ========================================

function ShopService.Initialize()
	print("🛒 ShopService initializing...")

	-- Initialize shop
	ShopService.InitializeShop()

	-- Setup remote events
	ShopService.SetupRemoteEvents()

	-- Start auto-refresh
	ShopService.StartAutoRefresh()

	print("✅ ShopService ready!")
end

-- Auto-initialize
ShopService.Initialize()

return ShopService
