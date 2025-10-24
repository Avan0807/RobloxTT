-- DataStoreService.lua - DataStore Management
-- Copy vào ServerScriptService/DataStoreService (Script)

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreModule = require(ReplicatedStorage.Modules.DataStore.DataStoreModule)

local DataStore = {}
DataStore.PlayerDataStore = nil
DataStore.SaveQueue = {}

-- ========================================
-- INITIALIZE DATASTORE
-- ========================================

function DataStore.Initialize()
	local success, err = pcall(function()
		DataStore.PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v1")
	end)

	if not success then
		warn("❌ Failed to initialize DataStore:", err)
		return false
	end

	print("💾 DataStore initialized successfully")
	return true
end

-- ========================================
-- LOAD PLAYER DATA
-- ========================================

function DataStore.LoadData(player)
	if not DataStore.PlayerDataStore then
		warn("DataStore not initialized!")
		return DataStoreModule.GetDefaultData()
	end

	local userId = player.UserId
	local key = "Player_" .. userId

	local attempts = 0
	local maxAttempts = DataStoreModule.MaxRetries

	while attempts < maxAttempts do
		attempts = attempts + 1

		local success, data = pcall(function()
			return DataStore.PlayerDataStore:GetAsync(key)
		end)

		if success then
			if data then
				-- Validate data
				local isValid, err = DataStoreModule.ValidateData(data)
				if isValid then
					-- Migrate if needed
					data = DataStoreModule.MigrateData(data)

					-- Deserialize
					local playerData = DataStoreModule.DeserializeData(data)

					print("✅ Loaded data for", player.Name)
					return playerData
				else
					warn("Invalid data for", player.Name, ":", err)
					return DataStoreModule.GetDefaultData()
				end
			else
				-- New player
				print("📝 New player:", player.Name)
				return DataStoreModule.GetDefaultData()
			end
		else
			warn("⚠️ Failed to load data (attempt " .. attempts .. "):", data)

			if attempts < maxAttempts then
				task.wait(DataStoreModule.RetryDelay * attempts)
			end
		end
	end

	-- Failed to load after retries
	warn("❌ Failed to load data for", player.Name, "after", maxAttempts, "attempts")
	return DataStoreModule.GetDefaultData()
end

-- ========================================
-- SAVE PLAYER DATA
-- ========================================

function DataStore.SaveData(player, playerData)
	if not DataStore.PlayerDataStore then
		warn("DataStore not initialized!")
		return false
	end

	local userId = player.UserId
	local key = "Player_" .. userId

	-- Serialize data
	local saveData = DataStoreModule.SerializeData(playerData)

	-- Check data size
	local dataSize = DataStoreModule.CalculateDataSize(saveData)
	if dataSize > 4000000 then -- 4MB limit
		warn("⚠️ Data too large for", player.Name, ":", dataSize, "bytes")
		return false
	end

	-- Save with retry
	local attempts = 0
	local maxAttempts = DataStoreModule.MaxRetries

	while attempts < maxAttempts do
		attempts = attempts + 1

		local success, err = pcall(function()
			DataStore.PlayerDataStore:SetAsync(key, saveData)
		end)

		if success then
			print("✅ Saved data for", player.Name, "(", dataSize, "bytes)")
			return true
		else
			warn("⚠️ Failed to save data (attempt " .. attempts .. "):", err)

			if attempts < maxAttempts then
				task.wait(DataStoreModule.RetryDelay * attempts)
			end
		end
	end

	warn("❌ Failed to save data for", player.Name, "after", maxAttempts, "attempts")
	return false
end

-- ========================================
-- AUTO SAVE
-- ========================================

function DataStore.StartAutoSave()
	task.spawn(function()
		while true do
			task.wait(DataStoreModule.AutoSaveInterval)

			print("💾 Auto-saving all player data...")

			for _, player in ipairs(game.Players:GetPlayers()) do
				task.spawn(function()
					local playerData = DataStore.GetPlayerData(player)
					if playerData then
						DataStore.SaveData(player, playerData)
					end
				end)
			end
		end
	end)
end

-- ========================================
-- GET PLAYER DATA (from other services)
-- ========================================

function DataStore.GetPlayerData(player)
	-- Get from PlayerDataService
	local PlayerDataService = script.Parent:FindFirstChild("PlayerDataService")
	if PlayerDataService then
		local module = require(PlayerDataService)
		return module.GetPlayerData and module.GetPlayerData(player)
	end
	return nil
end

-- ========================================
-- ON PLAYER JOIN
-- ========================================

function DataStore.OnPlayerJoin(player)
	print("📥 Loading data for", player.Name)

	-- Load data
	local playerData = DataStore.LoadData(player)

	-- Send to PlayerDataService
	local PlayerDataService = script.Parent:FindFirstChild("PlayerDataService")
	if PlayerDataService then
		local module = require(PlayerDataService)
		if module.SetPlayerData then
			module.SetPlayerData(player, playerData)
		end
	end

	-- Update last login
	playerData.LastLogin = os.time()
end

-- ========================================
-- ON PLAYER LEAVE
-- ========================================

function DataStore.OnPlayerLeave(player)
	print("📤 Saving data for", player.Name)

	-- Get player data
	local playerData = DataStore.GetPlayerData(player)

	if playerData then
		-- Update playtime
		if playerData.LastLogin then
			local sessionTime = os.time() - playerData.LastLogin
			playerData.PlayTime = (playerData.PlayTime or 0) + sessionTime
		end

		-- Save
		DataStore.SaveData(player, playerData)
	end
end

-- ========================================
-- BIND TO CLOSE (Save all before shutdown)
-- ========================================

function DataStore.BindToClose()
	game:BindToClose(function()
		print("⚠️ Server shutting down, saving all data...")

		local savePromises = {}

		for _, player in ipairs(game.Players:GetPlayers()) do
			table.insert(savePromises, task.spawn(function()
				local playerData = DataStore.GetPlayerData(player)
				if playerData then
					DataStore.SaveData(player, playerData)
				end
			end))
		end

		-- Wait for all saves to complete (max 30 seconds)
		local startTime = os.time()
		while #savePromises > 0 and (os.time() - startTime) < 30 do
			task.wait(0.5)
		end

		print("✅ All data saved!")
	end)
end

-- ========================================
-- WIPE DATA (Admin command)
-- ========================================

function DataStore.WipePlayerData(player)
	if not DataStore.PlayerDataStore then
		return false, "DataStore not initialized"
	end

	local userId = player.UserId
	local key = "Player_" .. userId

	local success, err = pcall(function()
		DataStore.PlayerDataStore:RemoveAsync(key)
	end)

	if success then
		print("🗑️ Wiped data for", player.Name)

		-- Reset to default
		local defaultData = DataStoreModule.GetDefaultData()
		local PlayerDataService = script.Parent:FindFirstChild("PlayerDataService")
		if PlayerDataService then
			local module = require(PlayerDataService)
			if module.SetPlayerData then
				module.SetPlayerData(player, defaultData)
			end
		end

		return true
	else
		warn("Failed to wipe data:", err)
		return false, err
	end
end

-- ========================================
-- INITIALIZE
-- ========================================

function DataStore.InitializeService()
	print("💾 DataStoreService initializing...")

	-- Initialize DataStore
	local success = DataStore.Initialize()
	if not success then
		warn("❌ DataStore initialization failed! Data will not be saved!")
		return
	end

	-- Connect events
	game.Players.PlayerAdded:Connect(DataStore.OnPlayerJoin)
	game.Players.PlayerRemoving:Connect(DataStore.OnPlayerLeave)

	-- Bind to close
	DataStore.BindToClose()

	-- Start auto-save
	DataStore.StartAutoSave()

	-- Handle existing players (for testing)
	for _, player in ipairs(game.Players:GetPlayers()) do
		task.spawn(function()
			DataStore.OnPlayerJoin(player)
		end)
	end

	print("✅ DataStoreService ready!")
end

-- Auto-initialize
DataStore.InitializeService()

-- Export functions
return {
	LoadData = DataStore.LoadData,
	SaveData = DataStore.SaveData,
	WipePlayerData = DataStore.WipePlayerData
}
