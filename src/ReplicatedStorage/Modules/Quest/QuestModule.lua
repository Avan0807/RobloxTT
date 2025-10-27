-- QuestModule.lua - Hệ Thống Nhiệm Vụ
-- Copy vào ReplicatedStorage/Modules/Quest/QuestModule (ModuleScript)

local QuestModule = {}

-- ========================================
-- QUEST TYPES
-- ========================================

QuestModule.QuestType = {
	KILL = "Kill",           -- Giết quái
	COLLECT = "Collect",     -- Thu thập vật phẩm
	MEDITATION = "Meditation", -- Tu luyện
	LEVEL_UP = "LevelUp",    -- Nâng cấp
	EQUIP = "Equip",         -- Trang bị
	SHOP = "Shop"            -- Mua bán
}

-- ========================================
-- QUEST DIFFICULTY
-- ========================================

QuestModule.Difficulty = {
	EASY = {
		Name = "Dễ",
		Color = Color3.fromRGB(100, 255, 100),
		RewardMultiplier = 1.0
	},
	MEDIUM = {
		Name = "Trung Bình",
		Color = Color3.fromRGB(255, 200, 100),
		RewardMultiplier = 1.5
	},
	HARD = {
		Name = "Khó",
		Color = Color3.fromRGB(255, 100, 100),
		RewardMultiplier = 2.5
	},
	LEGENDARY = {
		Name = "Huyền Thoại",
		Color = Color3.fromRGB(255, 200, 0),
		RewardMultiplier = 5.0
	}
}

-- ========================================
-- QUEST DEFINITIONS
-- ========================================

QuestModule.Quests = {
	-- Tutorial Quests
	{
		QuestID = "tutorial_1",
		Name = "Bước Đầu Tu Luyện",
		Description = "Meditation để tăng 500 Tu Vi",
		QuestType = QuestModule.QuestType.MEDITATION,
		Difficulty = QuestModule.Difficulty.EASY,
		Requirement = {
			TuViGain = 500
		},
		Progress = {
			Current = 0,
			Goal = 500
		},
		Rewards = {
			Gold = 100,
			TuVi = 200,
			Items = {
				{Name = "Tu Khí Đan", Amount = 5}
			}
		},
		LevelRequirement = 1,
		IsRepeatable = false
	},

	{
		QuestID = "tutorial_2",
		Name = "Trang Bị Đầu Tiên",
		Description = "Trang bị một vũ khí",
		QuestType = QuestModule.QuestType.EQUIP,
		Difficulty = QuestModule.Difficulty.EASY,
		Requirement = {
			EquipSlot = "Weapon"
		},
		Progress = {
			Current = 0,
			Goal = 1
		},
		Rewards = {
			Gold = 150,
			Items = {
				{Name = "Phàm Y", Amount = 1}
			}
		},
		LevelRequirement = 1,
		IsRepeatable = false
	},

	-- Kill Quests
	{
		QuestID = "kill_beasts_1",
		Name = "Săn Linh Thú",
		Description = "Tiêu diệt 10 Linh Thú",
		QuestType = QuestModule.QuestType.KILL,
		Difficulty = QuestModule.Difficulty.EASY,
		Requirement = {
			EnemyType = "LinhThu",
			Amount = 10
		},
		Progress = {
			Current = 0,
			Goal = 10
		},
		Rewards = {
			Gold = 300,
			TuVi = 500,
			Items = {
				{Name = "Thú Cốt", Amount = 5}
			}
		},
		LevelRequirement = 1,
		IsRepeatable = true
	},

	{
		QuestID = "kill_beasts_2",
		Name = "Đại Chiến Linh Thú",
		Description = "Tiêu diệt 50 Linh Thú",
		QuestType = QuestModule.QuestType.KILL,
		Difficulty = QuestModule.Difficulty.MEDIUM,
		Requirement = {
			EnemyType = "LinhThu",
			Amount = 50
		},
		Progress = {
			Current = 0,
			Goal = 50
		},
		Rewards = {
			Gold = 1500,
			TuVi = 2500,
			Items = {
				{Name = "Tiểu Hoàn Đan", Amount = 3},
				{Name = "Thú Cốt", Amount = 20}
			}
		},
		LevelRequirement = 3,
		IsRepeatable = true
	},

	-- Collect Quests
	{
		QuestID = "collect_materials",
		Name = "Thu Thập Nguyên Liệu",
		Description = "Thu thập 20 Thú Cốt",
		QuestType = QuestModule.QuestType.COLLECT,
		Difficulty = QuestModule.Difficulty.EASY,
		Requirement = {
			ItemName = "Thú Cốt",
			Amount = 20
		},
		Progress = {
			Current = 0,
			Goal = 20
		},
		Rewards = {
			Gold = 500,
			Items = {
				{Name = "Vạn Niên Linh Dược", Amount = 2}
			}
		},
		LevelRequirement = 2,
		IsRepeatable = true
	},

	-- Level Up Quests
	{
		QuestID = "reach_level_5",
		Name = "Tu Luyện Tấn Triển",
		Description = "Đạt Level 5",
		QuestType = QuestModule.QuestType.LEVEL_UP,
		Difficulty = QuestModule.Difficulty.MEDIUM,
		Requirement = {
			Level = 5
		},
		Progress = {
			Current = 0,
			Goal = 5
		},
		Rewards = {
			Gold = 2000,
			TuVi = 5000,
			Items = {
				{Name = "Đại Hoàn Đan", Amount = 2},
				{Name = "Linh Kiếm", Amount = 1}
			}
		},
		LevelRequirement = 1,
		IsRepeatable = false
	},

	-- Shop Quests
	{
		QuestID = "first_purchase",
		Name = "Giao Dịch Đầu Tiên",
		Description = "Mua 5 vật phẩm từ cửa hàng",
		QuestType = QuestModule.QuestType.SHOP,
		Difficulty = QuestModule.Difficulty.EASY,
		Requirement = {
			PurchaseCount = 5
		},
		Progress = {
			Current = 0,
			Goal = 5
		},
		Rewards = {
			Gold = 400,
			Items = {
				{Name = "Tu Khí Đan", Amount = 10}
			}
		},
		LevelRequirement = 1,
		IsRepeatable = false
	},

	-- Daily Quests
	{
		QuestID = "daily_meditation",
		Name = "Tu Luyện Hàng Ngày",
		Description = "Meditation để tăng 2000 Tu Vi",
		QuestType = QuestModule.QuestType.MEDITATION,
		Difficulty = QuestModule.Difficulty.EASY,
		Requirement = {
			TuViGain = 2000
		},
		Progress = {
			Current = 0,
			Goal = 2000
		},
		Rewards = {
			Gold = 800,
			TuVi = 1000,
			Items = {
				{Name = "Tiểu Hoàn Đan", Amount = 2}
			}
		},
		LevelRequirement = 2,
		IsRepeatable = true,
		IsDaily = true
	},

	{
		QuestID = "daily_kills",
		Name = "Tiêu Diệt Hàng Ngày",
		Description = "Tiêu diệt 20 kẻ địch",
		QuestType = QuestModule.QuestType.KILL,
		Difficulty = QuestModule.Difficulty.MEDIUM,
		Requirement = {
			EnemyType = "Any",
			Amount = 20
		},
		Progress = {
			Current = 0,
			Goal = 20
		},
		Rewards = {
			Gold = 1200,
			TuVi = 1500,
			Items = {
				{Name = "Đại Hoàn Đan", Amount = 1}
			}
		},
		LevelRequirement = 3,
		IsRepeatable = true,
		IsDaily = true
	}
}

-- ========================================
-- GET QUEST BY ID
-- ========================================

function QuestModule.GetQuest(questID)
	for _, quest in ipairs(QuestModule.Quests) do
		if quest.QuestID == questID then
			-- Return a copy to avoid modifying the original
			local questCopy = {}
			for k, v in pairs(quest) do
				questCopy[k] = v
			end
			-- Deep copy Progress
			questCopy.Progress = {
				Current = quest.Progress.Current,
				Goal = quest.Progress.Goal
			}
			return questCopy
		end
	end
	return nil
end

-- ========================================
-- GET AVAILABLE QUESTS (by level)
-- ========================================

function QuestModule.GetAvailableQuests(playerLevel)
	local availableQuests = {}

	for _, quest in ipairs(QuestModule.Quests) do
		if quest.LevelRequirement <= playerLevel then
			table.insert(availableQuests, quest)
		end
	end

	return availableQuests
end

-- ========================================
-- UPDATE QUEST PROGRESS
-- ========================================

function QuestModule.UpdateProgress(quest, amount)
	quest.Progress.Current = quest.Progress.Current + amount

	-- Cap at goal
	if quest.Progress.Current > quest.Progress.Goal then
		quest.Progress.Current = quest.Progress.Goal
	end

	return quest.Progress.Current >= quest.Progress.Goal
end

-- ========================================
-- IS QUEST COMPLETE
-- ========================================

function QuestModule.IsComplete(quest)
	return quest.Progress.Current >= quest.Progress.Goal
end

-- ========================================
-- RESET QUEST PROGRESS
-- ========================================

function QuestModule.ResetProgress(quest)
	quest.Progress.Current = 0
end

-- ========================================
-- GET QUEST REWARDS TEXT
-- ========================================

function QuestModule.GetRewardsText(quest)
	local rewards = {}

	if quest.Rewards.Gold then
		table.insert(rewards, quest.Rewards.Gold .. " Tiên Ngọc")
	end

	if quest.Rewards.TuVi then
		table.insert(rewards, quest.Rewards.TuVi .. " Tu Vi")
	end

	if quest.Rewards.Items then
		for _, item in ipairs(quest.Rewards.Items) do
			table.insert(rewards, item.Amount .. " " .. item.Name)
		end
	end

	return table.concat(rewards, ", ")
end

-- ========================================
-- REFRESH DAILY QUESTS
-- ========================================

function QuestModule.RefreshDailyQuests()
	-- This should be called server-side daily
	print("📋 Daily quests refreshed!")
end

print("✅ QuestModule loaded")
return QuestModule
