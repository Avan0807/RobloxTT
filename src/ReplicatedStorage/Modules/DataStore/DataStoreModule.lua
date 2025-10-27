-- DataStoreModule.lua - DataStore Wrapper
-- Copy vào ReplicatedStorage/Modules/DataStore/DataStoreModule (ModuleScript)

local DataStoreModule = {}

-- ========================================
-- SETTINGS
-- ========================================

DataStoreModule.MaxRetries = 3
DataStoreModule.RetryDelay = 1
DataStoreModule.AutoSaveInterval = 300 -- 5 minutes

-- ========================================
-- DATA VERSION
-- ========================================

DataStoreModule.CurrentVersion = 1

-- ========================================
-- DEFAULT PLAYER DATA
-- ========================================

function DataStoreModule.GetDefaultData()
	return {
		-- Meta
		Version = DataStoreModule.CurrentVersion,
		LastSave = os.time(),

		-- Cultivation
		CultivationType = nil, -- Not chosen yet
		Realm = 1,
		Level = 1,
		TuVi = 0,

		-- Stats (will be calculated from Realm/Level)
		Stats = {
			HP = 500,
			MP = 500,
			MagicDamage = 0,
			PhysicalDamage = 0,
			SoulDamage = 0,
			Defense = 30,
			MagicDefense = 30,
			Speed = 16,
			CritRate = 0.05,
			CritDamage = 1.5,
			Lifesteal = 0
		},

		-- Inventory
		Inventory = {
			Gold = 0,
			Slots = {}
		},

		-- Equipment
		Equipment = {
			Weapon = nil,
			Armor = nil,
			Helmet = nil,
			Boots = nil,
			Accessory1 = nil,
			Accessory2 = nil,
			Talisman = nil
		},

		-- Quests
		Quests = {
			Active = {},
			Completed = {}
		},

		-- Ma Đạo specific
		HonPhien = {
			Souls = 0,
			Capacity = 0
		},

		-- Achievements
		Achievements = {},

		-- Playtime
		PlayTime = 0,
		LastLogin = os.time()
	}
end

-- ========================================
-- VALIDATE DATA
-- ========================================

function DataStoreModule.ValidateData(data)
	-- Check if data exists
	if not data or type(data) ~= "table" then
		return false, "Invalid data format"
	end

	-- Check version
	if not data.Version then
		return false, "Missing version"
	end

	-- Check required fields
	if not data.Realm or not data.Level or not data.TuVi then
		return false, "Missing cultivation data"
	end

	return true
end

-- ========================================
-- MIGRATE DATA (if old version)
-- ========================================

function DataStoreModule.MigrateData(data)
	if data.Version == DataStoreModule.CurrentVersion then
		return data
	end

	-- Migration logic for future versions
	-- Example:
	-- if data.Version == 1 then
	--     data.NewField = defaultValue
	--     data.Version = 2
	-- end

	print("Migrated data from version", data.Version, "to", DataStoreModule.CurrentVersion)
	data.Version = DataStoreModule.CurrentVersion

	return data
end

-- ========================================
-- SERIALIZE DATA (Prepare for saving)
-- ========================================

function DataStoreModule.SerializeData(playerData)
	-- Create a clean copy for saving
	local saveData = {}

	-- Copy basic fields
	saveData.Version = DataStoreModule.CurrentVersion
	saveData.LastSave = os.time()

	-- Cultivation
	saveData.CultivationType = playerData.CultivationType
	saveData.Realm = playerData.Realm
	saveData.Level = playerData.Level
	saveData.TuVi = playerData.TuVi

	-- Inventory
	saveData.Inventory = {
		Gold = playerData.Inventory and playerData.Inventory.Gold or 0,
		Slots = {}
	}

	-- Serialize inventory slots
	if playerData.Inventory and playerData.Inventory.Slots then
		for i, slot in ipairs(playerData.Inventory.Slots) do
			table.insert(saveData.Inventory.Slots, {
				Name = slot.Name,
				Type = slot.Type,
				Amount = slot.Amount,
				-- Don't save functions or complex objects
			})
		end
	end

	-- Equipment (save names only)
	saveData.Equipment = {}
	if playerData.Equipment then
		for slotName, equipment in pairs(playerData.Equipment) do
			if equipment then
				saveData.Equipment[slotName] = equipment.Name
			end
		end
	end

	-- Quests
	saveData.Quests = {
		Active = {},
		Completed = playerData.Quests and playerData.Quests.Completed or {}
	}

	-- Serialize active quests
	if playerData.Quests and playerData.Quests.Active then
		for _, quest in ipairs(playerData.Quests.Active) do
			table.insert(saveData.Quests.Active, {
				QuestID = quest.QuestID,
				Progress = quest.Progress
			})
		end
	end

	-- HonPhien
	saveData.HonPhien = playerData.HonPhien or {Souls = 0, Capacity = 0}

	-- Achievements
	saveData.Achievements = playerData.Achievements or {}

	-- Playtime
	saveData.PlayTime = playerData.PlayTime or 0
	saveData.LastLogin = os.time()

	return saveData
end

-- ========================================
-- DESERIALIZE DATA (After loading)
-- ========================================

function DataStoreModule.DeserializeData(saveData)
	-- Start with default data
	local playerData = DataStoreModule.GetDefaultData()

	-- Merge saved data
	if saveData then
		for key, value in pairs(saveData) do
			playerData[key] = value
		end
	end

	return playerData
end

-- ========================================
-- CALCULATE DATA SIZE (for debugging)
-- ========================================

function DataStoreModule.CalculateDataSize(data)
	local httpService = game:GetService("HttpService")
	local jsonString = httpService:JSONEncode(data)
	return #jsonString
end

print("✅ DataStoreModule loaded")
return DataStoreModule
