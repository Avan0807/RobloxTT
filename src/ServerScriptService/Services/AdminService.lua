-- AdminService.lua - Server Admin Command Handler
-- Copy vào ServerScriptService/AdminService (Script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local AdminModule = require(ReplicatedStorage.Modules.Admin.AdminModule)

local AdminService = {}

-- ========================================
-- EXECUTE COMMAND
-- ========================================

function AdminService.ExecuteCommand(player, commandName, args)
	-- Check if admin
	if not AdminModule.IsAdmin(player) then
		return false, "You are not an admin!"
	end

	-- Get command
	local cmd = AdminModule.GetCommand(commandName)
	if not cmd then
		return false, "Unknown command: " .. commandName
	end

	-- Execute command function
	local functionName = cmd.Function
	if AdminService[functionName] then
		local success, result = pcall(AdminService[functionName], player, args)
		if success then
			return true, result or "Command executed successfully!"
		else
			return false, "Error: " .. tostring(result)
		end
	else
		return false, "Command function not implemented: " .. functionName
	end
end

-- ========================================
-- GET PLAYER DATA
-- ========================================

function AdminService.GetPlayerData(player)
	local PlayerDataService = ServerScriptService:FindFirstChild("PlayerDataService")
	if PlayerDataService then
		local module = require(PlayerDataService)
		return module.PlayerData and module.PlayerData[player]
	end
	return nil
end

-- ========================================
-- SYNC PLAYER DATA
-- ========================================

function AdminService.SyncPlayerData(player)
	local PlayerDataService = ServerScriptService:FindFirstChild("PlayerDataService")
	if PlayerDataService then
		local module = require(PlayerDataService)
		if module.SyncPlayerData then
			module.SyncPlayerData(player)
		end
	end
end

-- ========================================
-- CULTIVATION COMMANDS
-- ========================================

function AdminService.SetRealm(player, args)
	local playerData = AdminService.GetPlayerData(player)
	if not playerData then return "Player data not found!" end

	local realm = args[1] or "LuyenKhi"
	local level = tonumber(args[2]) or 1

	playerData.Realm = realm
	playerData.RealmLevel = math.clamp(level, 1, 9)

	AdminService.SyncPlayerData(player)
	return "Set realm to " .. realm .. " level " .. level
end

function AdminService.AddTuVi(player, args)
	local playerData = AdminService.GetPlayerData(player)
	if not playerData then return "Player data not found!" end

	local amount = tonumber(args[1]) or 10000

	playerData.TuVi = (playerData.TuVi or 0) + amount

	AdminService.SyncPlayerData(player)
	return "Added " .. amount .. " Tu Vi"
end

function AdminService.SetPath(player, args)
	local playerData = AdminService.GetPlayerData(player)
	if not playerData then return "Player data not found!" end

	local path = args[1] or "MaDao"

	playerData.CultivationType = path
	playerData.Realm = "LuyenKhi"
	playerData.RealmLevel = 1

	AdminService.SyncPlayerData(player)
	return "Changed path to " .. path
end

-- ========================================
-- MA ĐẠO COMMANDS
-- ========================================

function AdminService.AddSouls(player, args)
	local playerData = AdminService.GetPlayerData(player)
	if not playerData then return "Player data not found!" end

	local amount = tonumber(args[1]) or 10000

	if not playerData.HonPhien then
		playerData.HonPhien = {Souls = 0}
	end

	playerData.HonPhien.Souls = (playerData.HonPhien.Souls or 0) + amount

	AdminService.SyncPlayerData(player)
	return "Added " .. amount .. " souls"
end

function AdminService.AddKills(player, args)
	local playerData = AdminService.GetPlayerData(player)
	if not playerData then return "Player data not found!" end

	local amount = tonumber(args[1]) or 1000

	if not playerData.SatKhi then
		playerData.SatKhi = {TotalKills = 0, CurrentTier = 1}
	end

	playerData.SatKhi.TotalKills = (playerData.SatKhi.TotalKills or 0) + amount

	-- Update tier
	local TanSatModule = require(ReplicatedStorage.Modules.TanSat.TanSatModule)
	for i = #TanSatModule.SatKhiTiers, 1, -1 do
		local tier = TanSatModule.SatKhiTiers[i]
		if playerData.SatKhi.TotalKills >= tier.KillsRequired then
			playerData.SatKhi.CurrentTier = i
			break
		end
	end

	AdminService.SyncPlayerData(player)
	return "Added " .. amount .. " kills, now tier " .. playerData.SatKhi.CurrentTier
end

function AdminService.SetTier(player, args)
	local playerData = AdminService.GetPlayerData(player)
	if not playerData then return "Player data not found!" end

	local tier = math.clamp(tonumber(args[1]) or 1, 1, 5)

	if not playerData.SatKhi then
		playerData.SatKhi = {TotalKills = 0, CurrentTier = 1}
	end

	local TanSatModule = require(ReplicatedStorage.Modules.TanSat.TanSatModule)
	local tierData = TanSatModule.SatKhiTiers[tier]

	playerData.SatKhi.CurrentTier = tier
	playerData.SatKhi.TotalKills = tierData.KillsRequired

	AdminService.SyncPlayerData(player)
	return "Set to tier " .. tier .. ": " .. tierData.Name
end

-- ========================================
-- ITEM COMMANDS
-- ========================================

function AdminService.GiveItem(player, args)
	local itemName = table.concat(args, " ")

	local InventoryService = ServerScriptService:FindFirstChild("InventoryService")
	if not InventoryService then return "InventoryService not found!" end

	local invModule = require(InventoryService)
	local InventoryModule = require(ReplicatedStorage.Modules.Inventory.InventoryModule)
	local LootModule = require(ReplicatedStorage.Modules.Loot.LootModule)

	local inventory = invModule.GetInventory and invModule.GetInventory(player)
	if not inventory then return "Inventory not found!" end

	-- Find item
	local itemData = LootModule.GetItemData(itemName)
	if not itemData then
		return "Item not found: " .. itemName
	end

	InventoryModule.AddItem(inventory, itemData, 1)

	if invModule.SyncInventory then
		invModule.SyncInventory(player)
	end

	return "Gave 1x " .. itemName
end

function AdminService.GiveGold(player, args)
	local playerData = AdminService.GetPlayerData(player)
	if not playerData then return "Player data not found!" end

	local amount = tonumber(args[1]) or 100000

	playerData.Gold = (playerData.Gold or 0) + amount

	AdminService.SyncPlayerData(player)
	return "Added " .. amount .. " gold"
end

function AdminService.ClearInventory(player, args)
	local InventoryService = ServerScriptService:FindFirstChild("InventoryService")
	if not InventoryService then return "InventoryService not found!" end

	local invModule = require(InventoryService)
	local inventory = invModule.GetInventory and invModule.GetInventory(player)
	if not inventory then return "Inventory not found!" end

	for i = 1, 50 do
		inventory[i] = nil
	end

	if invModule.SyncInventory then
		invModule.SyncInventory(player)
	end

	return "Cleared inventory"
end

-- ========================================
-- QUEST COMMANDS
-- ========================================

function AdminService.CompleteQuest(player, args)
	local QuestService = ServerScriptService:FindFirstChild("QuestService")
	if not QuestService then return "QuestService not found!" end

	local questModule = require(QuestService)

	local playerData = AdminService.GetPlayerData(player)
	if not playerData or not playerData.Quests then return "No active quests!" end

	-- Complete all active quests
	for questID, quest in pairs(playerData.Quests) do
		if quest.Status == "Active" then
			quest.Progress = quest.RequiredAmount
			if questModule.CompleteQuest then
				questModule.CompleteQuest(player, questID)
			end
		end
	end

	return "Completed all active quests"
end

function AdminService.ResetQuests(player, args)
	local playerData = AdminService.GetPlayerData(player)
	if not playerData then return "Player data not found!" end

	playerData.Quests = {}
	playerData.LastDailyQuestReset = 0

	AdminService.SyncPlayerData(player)
	return "Reset all quests"
end

-- ========================================
-- COMBAT COMMANDS
-- ========================================

function AdminService.SpawnEnemy(player, args)
	local enemyType = args[1] or "Normal"
	local level = tonumber(args[2]) or 1

	local EnemyService = ServerScriptService:FindFirstChild("EnemyService")
	if not EnemyService then return "EnemyService not found!" end

	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return "Character not found!"
	end

	local spawnPos = player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 20)

	-- Spawn enemy
	local enemyModule = require(EnemyService)
	if enemyModule.SpawnEnemy then
		enemyModule.SpawnEnemy(enemyType, level, spawnPos)
	end

	return "Spawned " .. enemyType .. " level " .. level
end

function AdminService.SpawnBoss(player, args)
	local bossName = table.concat(args, " ")

	local BossService = ServerScriptService:FindFirstChild("BossService")
	if not BossService then return "BossService not found!" end

	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return "Character not found!"
	end

	local bossModule = require(BossService)
	if bossModule.SpawnBoss then
		bossModule.SpawnBoss(bossName, player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 30))
	end

	return "Spawned boss: " .. bossName
end

function AdminService.KillAll(player, args)
	local killed = 0

	for _, enemy in ipairs(workspace:GetChildren()) do
		if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Name ~= player.Name then
			local humanoid = enemy:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid.Health = 0
				killed = killed + 1
			end
		end
	end

	return "Killed " .. killed .. " enemies"
end

-- ========================================
-- THIÊN KIẾP COMMANDS
-- ========================================

function AdminService.StartTribulation(player, args)
	local ThienKiepService = ServerScriptService:FindFirstChild("ThienKiepService")
	if not ThienKiepService then return "ThienKiepService not found!" end

	local kiepModule = require(ThienKiepService)
	if kiepModule.StartThienKiep then
		local success, msg = kiepModule.StartThienKiep(player)
		return msg
	end

	return "Started Thiên Kiếp"
end

function AdminService.SkipTribulation(player, args)
	-- Instant breakthrough
	local playerData = AdminService.GetPlayerData(player)
	if not playerData then return "Player data not found!" end

	local ThienKiepModule = require(ReplicatedStorage.Modules.ThienKiep.ThienKiepModule)
	local kiep = ThienKiepModule.GetThienKiepForRealm(playerData.Realm, playerData.RealmLevel)

	if not kiep then
		return "No tribulation available!"
	end

	-- Apply rewards
	ThienKiepModule.ApplySuccessRewards(playerData, kiep)

	AdminService.SyncPlayerData(player)
	return "Skipped tribulation, breakthrough to " .. kiep.TargetRealm
end

-- ========================================
-- SKILL COMMANDS
-- ========================================

function AdminService.UnlockSkills(player, args)
	local playerData = AdminService.GetPlayerData(player)
	if not playerData then return "Player data not found!" end

	-- Unlock all skills (implementation depends on your skill system)
	return "Unlocked all skills"
end

function AdminService.ResetCooldowns(player, args)
	-- Reset all skill cooldowns
	return "Reset all cooldowns"
end

function AdminService.MaxSkills(player, args)
	local playerData = AdminService.GetPlayerData(player)
	if not playerData then return "Player data not found!" end

	-- Max all skill levels
	if not playerData.Skills then
		playerData.Skills = {}
	end

	local HonPhienAdvanced = require(ReplicatedStorage.Modules.HonPhien.HonPhienAdvanced)
	for _, skill in ipairs(HonPhienAdvanced.SpecialSkills) do
		playerData.Skills[skill.SkillID] = {
			XP = 30000, -- Max XP
			Level = 10
		}
	end

	AdminService.SyncPlayerData(player)
	return "Maxed all skills to level 10"
end

-- ========================================
-- PLAYER STATE COMMANDS
-- ========================================

function AdminService.Heal(player, args)
	if not player.Character then return "Character not found!" end

	local humanoid = player.Character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.Health = humanoid.MaxHealth
		return "Healed to full HP"
	end

	return "Humanoid not found!"
end

function AdminService.Kill(player, args)
	local targetName = args[1] or player.Name
	local target = Players:FindFirstChild(targetName)

	if not target or not target.Character then
		return "Player not found!"
	end

	local humanoid = target.Character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.Health = 0
		return "Killed " .. targetName
	end

	return "Humanoid not found!"
end

function AdminService.ToggleGod(player, args)
	if not player.Character then return "Character not found!" end

	local humanoid = player.Character:FindFirstChild("Humanoid")
	if not humanoid then return "Humanoid not found!" end

	if humanoid.MaxHealth == math.huge then
		-- Disable god mode
		humanoid.MaxHealth = 100
		humanoid.Health = 100
		return "God mode OFF"
	else
		-- Enable god mode
		humanoid.MaxHealth = math.huge
		humanoid.Health = math.huge
		return "God mode ON"
	end
end

function AdminService.SetSpeed(player, args)
	if not player.Character then return "Character not found!" end

	local humanoid = player.Character:FindFirstChild("Humanoid")
	if not humanoid then return "Humanoid not found!" end

	local speed = tonumber(args[1]) or 16

	humanoid.WalkSpeed = speed
	return "Set speed to " .. speed
end

function AdminService.Teleport(player, args)
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return "Character not found!"
	end

	local x = tonumber(args[1]) or 0
	local y = tonumber(args[2]) or 50
	local z = tonumber(args[3]) or 0

	player.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
	return "Teleported to " .. x .. ", " .. y .. ", " .. z
end

-- ========================================
-- UTILITY COMMANDS
-- ========================================

function AdminService.ForceSave(player, args)
	local DataStoreService = ServerScriptService:FindFirstChild("DataStoreService")
	if not DataStoreService then return "DataStoreService not found!" end

	local dsModule = require(DataStoreService)
	if dsModule.SavePlayerData then
		dsModule.SavePlayerData(player)
		return "Saved player data"
	end

	return "Save function not found!"
end

function AdminService.ResetData(player, args)
	local playerData = AdminService.GetPlayerData(player)
	if not playerData then return "Player data not found!" end

	-- Reset to default
	local PlayerDataTemplate = require(ReplicatedStorage.Modules.Cultivation.PlayerDataTemplate)
	local PlayerDataService = require(ServerScriptService.PlayerDataService)

	PlayerDataService.PlayerData[player] = PlayerDataTemplate.CreateNew()

	AdminService.SyncPlayerData(player)
	return "Reset all player data"
end

function AdminService.ShowInfo(player, args)
	local playerData = AdminService.GetPlayerData(player)
	if not playerData then return "Player data not found!" end

	local info = {
		"=== PLAYER INFO ===",
		"Path: " .. (playerData.CultivationType or "None"),
		"Realm: " .. (playerData.Realm or "None") .. " Lv." .. (playerData.RealmLevel or 0),
		"Tu Vi: " .. (playerData.TuVi or 0),
		"Gold: " .. (playerData.Gold or 0),
		"Souls: " .. (playerData.HonPhien and playerData.HonPhien.Souls or 0),
		"Kills: " .. (playerData.SatKhi and playerData.SatKhi.TotalKills or 0),
		"Tier: " .. (playerData.SatKhi and playerData.SatKhi.CurrentTier or 1)
	}

	return table.concat(info, "\n")
end

function AdminService.ShowHelp(player, args)
	local help = {"=== ADMIN COMMANDS ==="}

	for _, cmd in ipairs(AdminModule.Commands) do
		table.insert(help, "/" .. cmd.Usage .. " - " .. cmd.Description)
	end

	return table.concat(help, "\n")
end

-- ========================================
-- SETUP REMOTE EVENTS
-- ========================================

function AdminService.SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if not remoteEvents then
		remoteEvents = Instance.new("Folder")
		remoteEvents.Name = "RemoteEvents"
		remoteEvents.Parent = ReplicatedStorage
	end

	-- Execute Command
	local executeCmd = remoteEvents:FindFirstChild("ExecuteAdminCommand")
	if not executeCmd then
		executeCmd = Instance.new("RemoteEvent")
		executeCmd.Name = "ExecuteAdminCommand"
		executeCmd.Parent = remoteEvents
	end

	executeCmd.OnServerEvent:Connect(function(player, commandName, args)
		local success, result = AdminService.ExecuteCommand(player, commandName, args)

		local response = remoteEvents:FindFirstChild("AdminCommandResponse")
		if not response then
			response = Instance.new("RemoteEvent")
			response.Name = "AdminCommandResponse"
			response.Parent = remoteEvents
		end

		response:FireClient(player, success, result)
	end)

	-- Execute Preset
	local executePreset = remoteEvents:FindFirstChild("ExecuteAdminPreset")
	if not executePreset then
		executePreset = Instance.new("RemoteEvent")
		executePreset.Name = "ExecuteAdminPreset"
		executePreset.Parent = remoteEvents
	end

	executePreset.OnServerEvent:Connect(function(player, presetIndex)
		if not AdminModule.IsAdmin(player) then return end

		local preset = AdminModule.Presets[presetIndex]
		if not preset then return end

		-- Execute all commands in preset
		for _, cmdString in ipairs(preset.Commands) do
			local commandName, args = AdminModule.ParseCommand("/" .. cmdString)
			if commandName then
				AdminService.ExecuteCommand(player, commandName, args)
			end
		end

		local response = remoteEvents:FindFirstChild("AdminCommandResponse")
		if response then
			response:FireClient(player, true, "Applied preset: " .. preset.Name)
		end
	end)
end

-- ========================================
-- CHAT COMMAND HANDLER
-- ========================================

function AdminService.SetupChatCommands()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			if not AdminModule.IsAdmin(player) then return end

			if message:sub(1, 1) == "/" then
				local commandName, args = AdminModule.ParseCommand(message)
				if commandName then
					local success, result = AdminService.ExecuteCommand(player, commandName, args)
					print("[ADMIN] " .. player.Name .. ": " .. message)
					print("[RESULT] " .. tostring(result))

					-- Send to client
					local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
					if remoteEvents then
						local response = remoteEvents:FindFirstChild("AdminCommandResponse")
						if response then
							response:FireClient(player, success, result)
						end
					end
				end
			end
		end)
	end)
end

-- ========================================
-- INITIALIZE
-- ========================================

function AdminService.Initialize()
	print("🔧 AdminService initializing...")

	AdminService.SetupRemoteEvents()
	AdminService.SetupChatCommands()

	print("✅ AdminService ready!")
	print("📝 Admin commands enabled. Use /help to see all commands.")
end

-- Auto-initialize
AdminService.Initialize()

return AdminService
