-- QuestService.lua - Server Quest Management
-- Copy vào ServerScriptService/QuestService (Script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local QuestModule = require(ReplicatedStorage.Modules.Quest.QuestModule)
local InventoryModule = require(ReplicatedStorage.Modules.Inventory.InventoryModule)

local QuestService = {}
QuestService.PlayerQuests = {} -- {userId = {active = {}, completed = {}}}

-- ========================================
-- GET PLAYER QUESTS
-- ========================================

function QuestService.GetPlayerQuests(player)
	local userId = player.UserId

	if not QuestService.PlayerQuests[userId] then
		QuestService.PlayerQuests[userId] = {
			Active = {},
			Completed = {}
		}
	end

	return QuestService.PlayerQuests[userId]
end

-- ========================================
-- ACCEPT QUEST
-- ========================================

function QuestService.AcceptQuest(player, questID)
	local playerQuests = QuestService.GetPlayerQuests(player)

	-- Check if already active
	for _, quest in ipairs(playerQuests.Active) do
		if quest.QuestID == questID then
			return false, "Quest already active!"
		end
	end

	-- Check if already completed (non-repeatable)
	for _, completedID in ipairs(playerQuests.Completed) do
		if completedID == questID then
			local questData = QuestModule.GetQuest(questID)
			if questData and not questData.IsRepeatable then
				return false, "Quest already completed!"
			end
		end
	end

	-- Get quest data
	local quest = QuestModule.GetQuest(questID)
	if not quest then
		return false, "Quest not found!"
	end

	-- Check level requirement
	local playerData = QuestService.GetPlayerData(player)
	if playerData and quest.LevelRequirement > playerData.Level then
		return false, "Level too low! Required: " .. quest.LevelRequirement
	end

	-- Add to active quests
	table.insert(playerQuests.Active, quest)

	-- Sync to client
	QuestService.SyncQuests(player)

	return true, "Quest accepted: " .. quest.Name
end

-- ========================================
-- UPDATE QUEST PROGRESS
-- ========================================

function QuestService.UpdateQuestProgress(player, questType, data)
	local playerQuests = QuestService.GetPlayerQuests(player)
	local completedQuests = {}

	for i, quest in ipairs(playerQuests.Active) do
		if quest.QuestType == questType then
			local shouldUpdate = false
			local amount = 0

			-- Check based on quest type
			if questType == QuestModule.QuestType.KILL then
				if quest.Requirement.EnemyType == "Any" or quest.Requirement.EnemyType == data.EnemyType then
					shouldUpdate = true
					amount = data.Amount or 1
				end

			elseif questType == QuestModule.QuestType.MEDITATION then
				shouldUpdate = true
				amount = data.TuViGain or 0

			elseif questType == QuestModule.QuestType.LEVEL_UP then
				shouldUpdate = true
				quest.Progress.Current = data.Level or 0

			elseif questType == QuestModule.QuestType.COLLECT then
				if quest.Requirement.ItemName == data.ItemName then
					local inventory = QuestService.GetInventory(player)
					if inventory then
						quest.Progress.Current = InventoryModule.GetItemCount(inventory, data.ItemName)
					end
				end

			elseif questType == QuestModule.QuestType.SHOP then
				shouldUpdate = true
				amount = data.PurchaseCount or 1

			elseif questType == QuestModule.QuestType.EQUIP then
				if quest.Requirement.EquipSlot == data.SlotName or not quest.Requirement.EquipSlot then
					shouldUpdate = true
					amount = 1
				end
			end

			-- Update progress
			if shouldUpdate then
				local isComplete = QuestModule.UpdateProgress(quest, amount)

				if isComplete then
					table.insert(completedQuests, i)
				end
			end
		end
	end

	-- Handle completed quests
	for i = #completedQuests, 1, -1 do
		local questIndex = completedQuests[i]
		local quest = playerQuests.Active[questIndex]

		-- Give rewards
		QuestService.GiveRewards(player, quest)

		-- Mark as completed
		table.insert(playerQuests.Completed, quest.QuestID)

		-- Remove from active
		table.remove(playerQuests.Active, questIndex)

		-- Notify player
		QuestService.NotifyPlayer(player, "✅ Quest completed: " .. quest.Name)
	end

	-- Sync to client
	if #completedQuests > 0 then
		QuestService.SyncQuests(player)
	end
end

-- ========================================
-- GIVE REWARDS
-- ========================================

function QuestService.GiveRewards(player, quest)
	local inventory = QuestService.GetInventory(player)
	local playerData = QuestService.GetPlayerData(player)

	if not inventory or not playerData then return end

	local rewards = quest.Rewards

	-- Give gold
	if rewards.Gold then
		inventory.Gold = inventory.Gold + rewards.Gold
	end

	-- Give Tu Vi
	if rewards.TuVi then
		playerData.TuVi = playerData.TuVi + rewards.TuVi
	end

	-- Give items
	if rewards.Items then
		local LootModule = require(ReplicatedStorage.Modules.Loot.LootModule)

		for _, itemReward in ipairs(rewards.Items) do
			local itemData = LootModule.GetItemData(itemReward.Name)
			if itemData then
				InventoryModule.AddItem(inventory, itemData, itemReward.Amount)
			end
		end
	end

	-- Sync
	QuestService.SyncInventory(player)
	QuestService.SyncPlayerData(player)
end

-- ========================================
-- ABANDON QUEST
-- ========================================

function QuestService.AbandonQuest(player, questID)
	local playerQuests = QuestService.GetPlayerQuests(player)

	for i, quest in ipairs(playerQuests.Active) do
		if quest.QuestID == questID then
			table.remove(playerQuests.Active, i)
			QuestService.SyncQuests(player)
			return true, "Quest abandoned"
		end
	end

	return false, "Quest not found in active quests"
end

-- ========================================
-- GET INVENTORY
-- ========================================

function QuestService.GetInventory(player)
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

function QuestService.GetPlayerData(player)
	local PlayerDataService = script.Parent:FindFirstChild("PlayerDataService")
	if PlayerDataService then
		local module = require(PlayerDataService)
		return module.GetPlayerData and module.GetPlayerData(player)
	end
	return {Level = 1, TuVi = 0}
end

-- ========================================
-- SYNC INVENTORY
-- ========================================

function QuestService.SyncInventory(player)
	local InventoryService = script.Parent:FindFirstChild("InventoryService")
	if InventoryService then
		local module = require(InventoryService)
		if module.SyncInventory then
			module.SyncInventory(player)
		end
	end
end

-- ========================================
-- SYNC PLAYER DATA
-- ========================================

function QuestService.SyncPlayerData(player)
	local PlayerDataService = script.Parent:FindFirstChild("PlayerDataService")
	if PlayerDataService then
		local module = require(PlayerDataService)
		if module.SyncPlayerData then
			module.SyncPlayerData(player)
		end
	end
end

-- ========================================
-- SYNC QUESTS TO CLIENT
-- ========================================

function QuestService.SyncQuests(player)
	local playerQuests = QuestService.GetPlayerQuests(player)

	-- Convert to sendable format
	local questData = {
		Active = {},
		Completed = playerQuests.Completed
	}

	for _, quest in ipairs(playerQuests.Active) do
		table.insert(questData.Active, {
			QuestID = quest.QuestID,
			Name = quest.Name,
			Description = quest.Description,
			QuestType = quest.QuestType,
			Difficulty = quest.Difficulty,
			Progress = quest.Progress,
			Rewards = quest.Rewards,
			IsDaily = quest.IsDaily
		})
	end

	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("SyncQuests")

	if remoteEvent then
		remoteEvent:FireClient(player, questData)
	end
end

-- ========================================
-- NOTIFY PLAYER
-- ========================================

function QuestService.NotifyPlayer(player, message)
	local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("QuestNotification")

	if remoteEvent then
		remoteEvent:FireClient(player, message)
	end
end

-- ========================================
-- SETUP REMOTE EVENTS
-- ========================================

function QuestService.SetupRemoteEvents()
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if not remoteEvents then
		remoteEvents = Instance.new("Folder")
		remoteEvents.Name = "RemoteEvents"
		remoteEvents.Parent = ReplicatedStorage
	end

	-- Accept Quest
	local acceptQuest = remoteEvents:FindFirstChild("AcceptQuest")
	if not acceptQuest then
		acceptQuest = Instance.new("RemoteEvent")
		acceptQuest.Name = "AcceptQuest"
		acceptQuest.Parent = remoteEvents
	end

	acceptQuest.OnServerEvent:Connect(function(player, questID)
		local success, msg = QuestService.AcceptQuest(player, questID)

		local notif = remoteEvents:FindFirstChild("QuestNotification")
		if not notif then
			notif = Instance.new("RemoteEvent")
			notif.Name = "QuestNotification"
			notif.Parent = remoteEvents
		end

		notif:FireClient(player, msg)
	end)

	-- Abandon Quest
	local abandonQuest = remoteEvents:FindFirstChild("AbandonQuest")
	if not abandonQuest then
		abandonQuest = Instance.new("RemoteEvent")
		abandonQuest.Name = "AbandonQuest"
		abandonQuest.Parent = remoteEvents
	end

	abandonQuest.OnServerEvent:Connect(function(player, questID)
		local success, msg = QuestService.AbandonQuest(player, questID)

		local notif = remoteEvents:FindFirstChild("QuestNotification")
		if notif then
			notif:FireClient(player, msg)
		end
	end)

	-- Get Quests
	local getQuests = remoteEvents:FindFirstChild("GetQuests")
	if not getQuests then
		getQuests = Instance.new("RemoteEvent")
		getQuests.Name = "GetQuests"
		getQuests.Parent = remoteEvents
	end

	getQuests.OnServerEvent:Connect(function(player)
		QuestService.SyncQuests(player)
	end)
end

-- ========================================
-- PLAYER JOIN/LEAVE
-- ========================================

function QuestService.OnPlayerJoin(player)
	-- Initialize quests
	QuestService.GetPlayerQuests(player)

	-- Give starter quests
	task.wait(3)
	QuestService.AcceptQuest(player, "tutorial_1")
	QuestService.AcceptQuest(player, "tutorial_2")

	-- Sync
	QuestService.SyncQuests(player)
end

function QuestService.OnPlayerLeave(player)
	-- Save quests (DataStore integration later)
	QuestService.PlayerQuests[player.UserId] = nil
end

-- ========================================
-- REFRESH DAILY QUESTS
-- ========================================

function QuestService.RefreshDailyQuests()
	QuestModule.RefreshDailyQuests()

	-- Reset daily quest progress for all players
	for userId, playerQuests in pairs(QuestService.PlayerQuests) do
		for _, quest in ipairs(playerQuests.Active) do
			if quest.IsDaily then
				QuestModule.ResetProgress(quest)
			end
		end
	end

	print("📋 Daily quests refreshed for all players!")
end

-- ========================================
-- AUTO REFRESH DAILY QUESTS
-- ========================================

function QuestService.StartAutoRefresh()
	task.spawn(function()
		while true do
			task.wait(86400) -- 24 hours
			QuestService.RefreshDailyQuests()
		end
	end)
end

-- ========================================
-- INITIALIZE
-- ========================================

function QuestService.Initialize()
	print("📋 QuestService initializing...")

	-- Setup remote events
	QuestService.SetupRemoteEvents()

	-- Connect player events
	game.Players.PlayerAdded:Connect(QuestService.OnPlayerJoin)
	game.Players.PlayerRemoving:Connect(QuestService.OnPlayerLeave)

	-- Handle existing players
	for _, player in ipairs(game.Players:GetPlayers()) do
		task.spawn(function()
			QuestService.OnPlayerJoin(player)
		end)
	end

	-- Start auto-refresh
	QuestService.StartAutoRefresh()

	print("✅ QuestService ready!")
end

-- Auto-initialize
QuestService.Initialize()

-- Export for other services
QuestService.UpdateProgress = function(player, questType, data)
	QuestService.UpdateQuestProgress(player, questType, data)
end

return QuestService
