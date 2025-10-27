-- EquipmentService.lua - Server Equipment Management
-- Copy vào ServerScriptService/EquipmentService (Script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EquipmentModule = require(ReplicatedStorage.Modules.Equipment.EquipmentModule)
local InventoryModule = require(ReplicatedStorage.Modules.Inventory.InventoryModule)

local EquipmentService = {}
EquipmentService.PlayerLoadouts = {} -- {userId = loadout}

-- ========================================
-- GET PLAYER LOADOUT
-- ========================================

function EquipmentService.GetLoadout(player)
	local userId = player.UserId

	if not EquipmentService.PlayerLoadouts[userId] then
		EquipmentService.PlayerLoadouts[userId] = EquipmentModule.CreateLoadout()
	end

	return EquipmentService.PlayerLoadouts[userId]
end

-- ========================================
-- EQUIP ITEM
-- ========================================

function EquipmentService.EquipItem(player, itemName)
	-- Get equipment data
	local equipment = EquipmentModule.GetEquipmentData(itemName)
	if not equipment then
		return false, "Equipment not found!"
	end

	-- Get player data
	local playerData = EquipmentService.GetPlayerData(player)
	if not playerData then
		return false, "Player data not found!"
	end

	-- Check if player can equip
	local canEquip, msg = EquipmentModule.CanEquip(
		equipment,
		playerData.Level or 1,
		playerData.CultivationType or "TienThien"
	)

	if not canEquip then
		return false, msg
	end

	-- Check if player has item in inventory
	local inventory = EquipmentService.GetInventory(player)
	if not InventoryModule.HasItem(inventory, itemName, 1) then
		return false, "Item not in inventory!"
	end

	-- Get loadout
	local loadout = EquipmentService.GetLoadout(player)

	-- Equip
	local success, message, oldEquipment = EquipmentModule.Equip(loadout, equipment)

	if success then
		-- Remove from inventory
		InventoryModule.RemoveItem(inventory, itemName, 1)

		-- If there was old equipment, add it back to inventory
		if oldEquipment then
			InventoryModule.AddItem(inventory, oldEquipment, 1)
		end

		-- Update player stats
		EquipmentService.UpdatePlayerStats(player)

		-- Sync to client
		EquipmentService.SyncLoadout(player)

		return true, message
	else
		return false, message
	end
end

-- ========================================
-- UNEQUIP ITEM
-- ========================================

function EquipmentService.UnequipItem(player, slotName)
	local loadout = EquipmentService.GetLoadout(player)
	local success, message, equipment = EquipmentModule.Unequip(loadout, slotName)

	if success then
		-- Add to inventory
		local inventory = EquipmentService.GetInventory(player)
		InventoryModule.AddItem(inventory, equipment, 1)

		-- Update player stats
		EquipmentService.UpdatePlayerStats(player)

		-- Sync to client
		EquipmentService.SyncLoadout(player)

		return true, message
	else
		return false, message
	end
end

-- ========================================
-- UPDATE PLAYER STATS
-- ========================================

function EquipmentService.UpdatePlayerStats(player)
	local loadout = EquipmentService.GetLoadout(player)
	local equipmentStats = EquipmentModule.GetTotalStats(loadout)

	-- Get player data
	local playerData = EquipmentService.GetPlayerData(player)
	if not playerData then return end

	-- Store equipment stats separately
	playerData.EquipmentStats = equipmentStats

	-- Apply to character if exists
	if player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			-- Apply HP bonus
			humanoid.MaxHealth = humanoid.MaxHealth + equipmentStats.HP
			humanoid.Health = math.min(humanoid.Health + equipmentStats.HP, humanoid.MaxHealth)
		end
	end

	-- Sync player data
	EquipmentService.SyncPlayerData(player)
end

-- ========================================
-- SYNC LOADOUT TO CLIENT
-- ========================================

function EquipmentService.SyncLoadout(player)
	local loadout = EquipmentService.GetLoadout(player)

	-- Convert to sendable format
	local loadoutData = {}
	for slotName, equipment in pairs(loadout) do
		if equipment then
			loadoutData[slotName] = {
				Name = equipment.Name,
				Type = equipment.Type,
				Tier = equipment.Tier,
				Level = equipment.Level,
				Stats = equipment.Stats,
				Description = equipment.Description,
				Icon = equipment.Icon
			}
		end
	end

	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("SyncEquipment")

	if remoteEvent then
		remoteEvent:FireClient(player, loadoutData)
	end
end

-- ========================================
-- GET INVENTORY
-- ========================================

function EquipmentService.GetInventory(player)
	-- Integrate with InventoryService
	local InventoryService = script.Parent:FindFirstChild("InventoryService")
	if InventoryService then
		local module = require(InventoryService)
		return module.GetInventory and module.GetInventory(player)
	end

	-- Fallback
	return InventoryModule.CreateNew()
end

-- ========================================
-- GET PLAYER DATA
-- ========================================

function EquipmentService.GetPlayerData(player)
	-- Integrate with PlayerDataService
	local PlayerDataService = script.Parent:FindFirstChild("PlayerDataService")
	if PlayerDataService then
		local module = require(PlayerDataService)
		return module.GetPlayerData and module.GetPlayerData(player)
	end

	-- Fallback
	return {
		Level = 1,
		CultivationType = "TienThien",
		EquipmentStats = {}
	}
end

-- ========================================
-- SYNC PLAYER DATA
-- ========================================

function EquipmentService.SyncPlayerData(player)
	local PlayerDataService = script.Parent:FindFirstChild("PlayerDataService")
	if PlayerDataService then
		local module = require(PlayerDataService)
		if module.SyncPlayerData then
			module.SyncPlayerData(player)
		end
	end
end

-- ========================================
-- SETUP REMOTE EVENTS
-- ========================================

function EquipmentService.SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if not remoteEvents then
		remoteEvents = Instance.new("Folder")
		remoteEvents.Name = "RemoteEvents"
		remoteEvents.Parent = ReplicatedStorage
	end

	-- Equip Item
	local equipItem = remoteEvents:FindFirstChild("EquipItem")
	if not equipItem then
		equipItem = Instance.new("RemoteEvent")
		equipItem.Name = "EquipItem"
		equipItem.Parent = remoteEvents
	end

	equipItem.OnServerEvent:Connect(function(player, itemName)
		local success, msg = EquipmentService.EquipItem(player, itemName)

		-- Send response
		local response = remoteEvents:FindFirstChild("EquipResponse")
		if not response then
			response = Instance.new("RemoteEvent")
			response.Name = "EquipResponse"
			response.Parent = remoteEvents
		end

		response:FireClient(player, success, msg)
	end)

	-- Unequip Item
	local unequipItem = remoteEvents:FindFirstChild("UnequipItem")
	if not unequipItem then
		unequipItem = Instance.new("RemoteEvent")
		unequipItem.Name = "UnequipItem"
		unequipItem.Parent = remoteEvents
	end

	unequipItem.OnServerEvent:Connect(function(player, slotName)
		local success, msg = EquipmentService.UnequipItem(player, slotName)

		local response = remoteEvents:FindFirstChild("EquipResponse")
		if response then
			response:FireClient(player, success, msg)
		end
	end)

	-- Get Equipment
	local getEquipment = remoteEvents:FindFirstChild("GetEquipment")
	if not getEquipment then
		getEquipment = Instance.new("RemoteEvent")
		getEquipment.Name = "GetEquipment"
		getEquipment.Parent = remoteEvents
	end

	getEquipment.OnServerEvent:Connect(function(player)
		EquipmentService.SyncLoadout(player)
	end)
end

-- ========================================
-- PLAYER JOIN/LEAVE
-- ========================================

function EquipmentService.OnPlayerJoin(player)
	-- Create loadout
	EquipmentService.GetLoadout(player)

	-- Give starter equipment
	EquipmentService.GiveStarterEquipment(player)

	-- Sync to client
	task.wait(2)
	EquipmentService.SyncLoadout(player)
end

function EquipmentService.OnPlayerLeave(player)
	-- Save loadout (DataStore integration later)
	EquipmentService.PlayerLoadouts[player.UserId] = nil
end

-- ========================================
-- GIVE STARTER EQUIPMENT
-- ========================================

function EquipmentService.GiveStarterEquipment(player)
	-- Wait for inventory to be ready
	task.wait(1)

	local inventory = EquipmentService.GetInventory(player)

	-- Give basic equipment based on cultivation type
	local basicWeapon = EquipmentModule.Weapons.BasicSword
	local basicArmor = EquipmentModule.Armors.BasicRobe

	InventoryModule.AddItem(inventory, basicWeapon, 1)
	InventoryModule.AddItem(inventory, basicArmor, 1)

	-- Give additional equipment
	InventoryModule.AddItem(inventory, EquipmentModule.Weapons.BasicGauntlet, 1)
	InventoryModule.AddItem(inventory, EquipmentModule.Weapons.BasicStaff, 1)
end

-- ========================================
-- INITIALIZE
-- ========================================

function EquipmentService.Initialize()
	print("⚔️ EquipmentService initializing...")

	-- Setup remote events
	EquipmentService.SetupRemoteEvents()

	-- Connect player events
	game.Players.PlayerAdded:Connect(EquipmentService.OnPlayerJoin)
	game.Players.PlayerRemoving:Connect(EquipmentService.OnPlayerLeave)

	-- Handle existing players
	for _, player in ipairs(game.Players:GetPlayers()) do
		task.spawn(function()
			EquipmentService.OnPlayerJoin(player)
		end)
	end

	print("✅ EquipmentService ready!")
end

-- Auto-initialize
EquipmentService.Initialize()

return EquipmentService
