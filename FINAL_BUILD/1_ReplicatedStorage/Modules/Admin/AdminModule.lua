-- AdminModule.lua - Admin System
-- Copy vào ReplicatedStorage/Modules/Admin/AdminModule (ModuleScript)

local AdminModule = {}

-- ========================================
-- ADMIN LIST (Add your UserID here!)
-- ========================================

AdminModule.Admins = {
	-- Add your UserID here
	-- Example: 123456789,
	-- To find your UserID: https://www.roblox.com/users/YOUR_PROFILE_ID/profile
}

-- ========================================
-- CHECK IF PLAYER IS ADMIN
-- ========================================

function AdminModule.IsAdmin(player)
	-- Check by UserID
	for _, adminID in ipairs(AdminModule.Admins) do
		if player.UserId == adminID then
			return true
		end
	end

	-- Studio testing (always admin in Studio)
	if game:GetService("RunService"):IsStudio() then
		return true
	end

	return false
end

-- ========================================
-- ADMIN COMMANDS
-- ========================================

AdminModule.Commands = {
	-- CULTIVATION
	{
		Name = "setRealm",
		Description = "Set cultivation realm",
		Usage = "setRealm [realm] [level]",
		Example = "setRealm MaTon 5",
		Function = "SetRealm"
	},
	{
		Name = "addTuVi",
		Description = "Add Tu Vi points",
		Usage = "addTuVi [amount]",
		Example = "addTuVi 100000",
		Function = "AddTuVi"
	},
	{
		Name = "setPath",
		Description = "Change cultivation path",
		Usage = "setPath [TienThien/CoThan/MaDao]",
		Example = "setPath MaDao",
		Function = "SetPath"
	},

	-- MA ĐẠO
	{
		Name = "addSouls",
		Description = "Add souls (Ma Đạo)",
		Usage = "addSouls [amount]",
		Example = "addSouls 50000",
		Function = "AddSouls"
	},
	{
		Name = "addKills",
		Description = "Add kill count",
		Usage = "addKills [amount]",
		Example = "addKills 10000",
		Function = "AddKills"
	},
	{
		Name = "setTier",
		Description = "Set Tàn Sát tier",
		Usage = "setTier [1-5]",
		Example = "setTier 5",
		Function = "SetTier"
	},

	-- ITEMS & EQUIPMENT
	{
		Name = "giveItem",
		Description = "Give item to inventory",
		Usage = "giveItem [itemName] [amount]",
		Example = "giveItem Kim Đan 10",
		Function = "GiveItem"
	},
	{
		Name = "giveGold",
		Description = "Give gold",
		Usage = "giveGold [amount]",
		Example = "giveGold 1000000",
		Function = "GiveGold"
	},
	{
		Name = "clearInventory",
		Description = "Clear all items",
		Usage = "clearInventory",
		Example = "clearInventory",
		Function = "ClearInventory"
	},

	-- QUESTS & PROGRESSION
	{
		Name = "completeQuest",
		Description = "Complete current quest",
		Usage = "completeQuest [questID]",
		Example = "completeQuest 1",
		Function = "CompleteQuest"
	},
	{
		Name = "resetQuests",
		Description = "Reset daily quests",
		Usage = "resetQuests",
		Example = "resetQuests",
		Function = "ResetQuests"
	},

	-- COMBAT & ENEMIES
	{
		Name = "spawnEnemy",
		Description = "Spawn enemy",
		Usage = "spawnEnemy [type] [level]",
		Example = "spawnEnemy Boss 50",
		Function = "SpawnEnemy"
	},
	{
		Name = "spawnBoss",
		Description = "Spawn boss",
		Usage = "spawnBoss [bossName]",
		Example = "spawnBoss Linh Thú Vương",
		Function = "SpawnBoss"
	},
	{
		Name = "killAll",
		Description = "Kill all enemies",
		Usage = "killAll",
		Example = "killAll",
		Function = "KillAll"
	},

	-- THIÊN KIẾP
	{
		Name = "startTribulation",
		Description = "Force start Thiên Kiếp",
		Usage = "startTribulation",
		Example = "startTribulation",
		Function = "StartTribulation"
	},
	{
		Name = "skipTribulation",
		Description = "Auto-complete Thiên Kiếp",
		Usage = "skipTribulation",
		Example = "skipTribulation",
		Function = "SkipTribulation"
	},

	-- SKILLS
	{
		Name = "unlockSkills",
		Description = "Unlock all skills",
		Usage = "unlockSkills",
		Example = "unlockSkills",
		Function = "UnlockSkills"
	},
	{
		Name = "resetCooldowns",
		Description = "Reset all cooldowns",
		Usage = "resetCooldowns",
		Example = "resetCooldowns",
		Function = "ResetCooldowns"
	},
	{
		Name = "maxSkills",
		Description = "Max all skill levels",
		Usage = "maxSkills",
		Example = "maxSkills",
		Function = "MaxSkills"
	},

	-- PLAYER STATE
	{
		Name = "heal",
		Description = "Heal to full HP",
		Usage = "heal",
		Example = "heal",
		Function = "Heal"
	},
	{
		Name = "kill",
		Description = "Kill player",
		Usage = "kill [playerName]",
		Example = "kill Player1",
		Function = "Kill"
	},
	{
		Name = "god",
		Description = "Toggle god mode",
		Usage = "god",
		Example = "god",
		Function = "ToggleGod"
	},
	{
		Name = "speed",
		Description = "Set walk speed",
		Usage = "speed [amount]",
		Example = "speed 100",
		Function = "SetSpeed"
	},
	{
		Name = "tp",
		Description = "Teleport to position",
		Usage = "tp [x] [y] [z]",
		Example = "tp 0 50 0",
		Function = "Teleport"
	},

	-- UTILITY
	{
		Name = "save",
		Description = "Force save player data",
		Usage = "save",
		Example = "save",
		Function = "ForceSave"
	},
	{
		Name = "reset",
		Description = "Reset all player data",
		Usage = "reset",
		Example = "reset",
		Function = "ResetData"
	},
	{
		Name = "info",
		Description = "Show player info",
		Usage = "info",
		Example = "info",
		Function = "ShowInfo"
	},
	{
		Name = "help",
		Description = "Show all commands",
		Usage = "help",
		Example = "help",
		Function = "ShowHelp"
	}
}

-- ========================================
-- GET COMMAND
-- ========================================

function AdminModule.GetCommand(commandName)
	for _, cmd in ipairs(AdminModule.Commands) do
		if cmd.Name:lower() == commandName:lower() then
			return cmd
		end
	end
	return nil
end

-- ========================================
-- PARSE COMMAND
-- ========================================

function AdminModule.ParseCommand(message)
	-- Remove leading/trailing whitespace
	message = message:match("^%s*(.-)%s*$")

	-- Check if starts with prefix
	if not message:sub(1, 1) == "/" then
		return nil
	end

	-- Remove prefix
	message = message:sub(2)

	-- Split into words
	local words = {}
	for word in message:gmatch("%S+") do
		table.insert(words, word)
	end

	if #words == 0 then
		return nil
	end

	local commandName = words[1]
	local args = {}

	for i = 2, #words do
		table.insert(args, words[i])
	end

	return commandName, args
end

-- ========================================
-- QUICK ACCESS PRESETS
-- ========================================

AdminModule.Presets = {
	-- Beginner Ma Đạo
	{
		Name = "Beginner Ma Đạo",
		Commands = {
			"setPath MaDao",
			"setRealm LuyenKhi 5",
			"addTuVi 10000",
			"addSouls 1000",
			"giveGold 50000"
		}
	},

	-- Mid-Game Ma Đạo
	{
		Name = "Mid Ma Đạo (Ma Tôn)",
		Commands = {
			"setPath MaDao",
			"setRealm MaTon 5",
			"addTuVi 100000",
			"addSouls 10000",
			"addKills 5000",
			"giveGold 500000"
		}
	},

	-- End-Game Ma Đạo
	{
		Name = "End-Game Ma Đạo (Ma Hoàng)",
		Commands = {
			"setPath MaDao",
			"setRealm MaHoang 7",
			"addTuVi 1000000",
			"addSouls 100000",
			"addKills 100000",
			"giveGold 10000000",
			"unlockSkills",
			"maxSkills"
		}
	},

	-- Max Power (Test Mode)
	{
		Name = "MAX POWER (God Mode)",
		Commands = {
			"setPath MaDao",
			"setRealm DoKiep 9",
			"addTuVi 10000000",
			"addSouls 500000",
			"addKills 200000",
			"giveGold 99999999",
			"unlockSkills",
			"maxSkills",
			"god",
			"speed 50"
		}
	},

	-- Test Thiên Kiếp
	{
		Name = "Test Thiên Kiếp",
		Commands = {
			"setPath MaDao",
			"setRealm LuyenKhi 9",
			"addTuVi 50000",
			"heal",
			"god"
		}
	}
}

print("✅ AdminModule loaded")
return AdminModule
