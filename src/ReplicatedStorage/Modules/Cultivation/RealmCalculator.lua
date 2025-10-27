-- RealmCalculator.lua - Tính Toán Stats Theo Cảnh Giới
-- Copy vào ReplicatedStorage/Modules/Stats/RealmCalculator (ModuleScript)

local Constants = require(game.ReplicatedStorage.Data.Constants)

local RealmCalculator = {}

-- Get multiplier table for cultivation type
local function GetMultiplierTable(cultivationType)
	if cultivationType == "TienThien" then
		return Constants.TienThienMultipliers
	elseif cultivationType == "CoThan" then
		return Constants.CoThanMultipliers
	elseif cultivationType == "MaDao" then
		return Constants.MaDaoMultipliers
	end
	return nil
end

-- Get current multiplier based on realm and level
function RealmCalculator.GetMultiplier(playerData)
	local cultivationType = playerData.CultivationType
	local currentRealm = playerData.CurrentRealm
	local currentLevel = playerData.CurrentLevel

	local multiplierTable = GetMultiplierTable(cultivationType)
	if not multiplierTable then
		warn("Invalid cultivation type:", cultivationType)
		return 1.0
	end

	-- Get realm name
	local realmData = playerData.Realms["Realm" .. currentRealm]
	if not realmData then
		warn("Realm not found:", currentRealm)
		return 1.0
	end

	local realmName = realmData.Name
	local realmMultipliers = multiplierTable[realmName]

	if not realmMultipliers then
		warn("Multipliers not found for realm:", realmName)
		return 1.0
	end

	-- Get multiplier for current level (1-9)
	local multiplier = realmMultipliers[currentLevel] or 1.0

	return multiplier
end

-- Calculate all stats based on current realm
function RealmCalculator.CalculateStats(playerData)
	local cultivationType = playerData.CultivationType
	local baseStats = Constants.BaseStats[cultivationType]

	if not baseStats then
		warn("Base stats not found for:", cultivationType)
		return playerData.Stats
	end

	local multiplier = RealmCalculator.GetMultiplier(playerData)

	local newStats = {}

	-- Calculate HP
	newStats.MaxHP = math.floor((baseStats.HP or 500) * multiplier)
	newStats.HP = math.min(playerData.Stats.HP or newStats.MaxHP, newStats.MaxHP)

	-- Calculate MP
	newStats.MaxMP = math.floor((baseStats.MP or 0) * multiplier)
	newStats.MP = math.min(playerData.Stats.MP or newStats.MaxMP, newStats.MaxMP)

	-- Calculate Damage Stats
	newStats.MagicDamage = math.floor((baseStats.MagicDamage or 0) * multiplier)
	newStats.PhysicalDamage = math.floor((baseStats.PhysicalDamage or 0) * multiplier)
	newStats.SoulDamage = math.floor((baseStats.SoulDamage or 0) * multiplier)

	-- Calculate Defense
	newStats.Defense = math.floor((baseStats.Defense or 30) * multiplier)
	newStats.MagicDefense = math.floor((baseStats.MagicDefense or 30) * multiplier)

	-- Static stats
	newStats.Speed = baseStats.Speed or 16
	newStats.CritRate = baseStats.CritRate or 0.05
	newStats.CritDamage = baseStats.CritDamage or 1.5
	newStats.Lifesteal = baseStats.Lifesteal or 0

	-- Special bonuses for Ma Đạo based on realm
	if cultivationType == "MaDao" then
		local currentRealm = playerData.CurrentRealm

		-- Ma Tôn (Realm 2): Tăng Lifesteal
		if currentRealm == 2 then
			local level = playerData.CurrentLevel
			-- 60% at level 1, up to 100% at level 9
			newStats.Lifesteal = 0.6 + (level - 1) * 0.05
		end

		-- Ma Hoàng (Realm 3): Lifesteal trên 100%
		if currentRealm == 3 then
			local level = playerData.CurrentLevel
			-- 110% at level 1, up to 150% at level 9
			newStats.Lifesteal = 1.1 + (level - 1) * 0.05
		end
	end

	return newStats
end

-- Get display name for current realm/level
function RealmCalculator.GetRealmDisplayName(playerData)
	local currentRealm = playerData.CurrentRealm
	local currentLevel = playerData.CurrentLevel

	local realmData = playerData.Realms["Realm" .. currentRealm]
	if not realmData then
		return "Unknown"
	end

	local realmName = realmData.Name
	local cultivationType = playerData.CultivationType

	-- Format name based on cultivation type
	if cultivationType == "TienThien" then
		return realmName .. " Tầng " .. currentLevel
	elseif cultivationType == "CoThan" then
		return realmName .. " " .. currentLevel .. " Sao"
	elseif cultivationType == "MaDao" then
		return realmName .. " " .. currentLevel .. " Tinh"
	end

	return realmName .. " " .. currentLevel
end

-- Check if player can level up (has enough Tu Vi Points)
function RealmCalculator.CanLevelUp(playerData)
	local currentLevel = playerData.CurrentLevel

	-- If already at level 9, need breakthrough
	if currentLevel >= 9 then
		return false, "Need breakthrough"
	end

	-- Get required Tu Vi Points
	local requiredTuVi = Constants.TuViPerLevel[currentLevel]
	if not requiredTuVi then
		return false, "Invalid level"
	end

	if playerData.TuViPoints < requiredTuVi then
		return false, "Not enough Tu Vi Points (need " .. requiredTuVi .. ")"
	end

	return true, "OK"
end

-- Check if player can breakthrough to next realm
function RealmCalculator.CanBreakthrough(playerData)
	local currentRealm = playerData.CurrentRealm
	local currentLevel = playerData.CurrentLevel

	-- Must be at level 9 of current realm
	if currentLevel < 9 then
		return false, "Must reach level 9 first"
	end

	-- Check if already at max realm
	if currentRealm >= 3 then
		return false, "Already at max realm"
	end

	-- Get required Tu Vi Points for breakthrough
	local requiredTuVi = Constants.TuViBreakthrough[currentRealm]
	if not requiredTuVi then
		return false, "Invalid realm"
	end

	if playerData.TuViPoints < requiredTuVi then
		return false, "Not enough Tu Vi Points (need " .. requiredTuVi .. ")"
	end

	return true, "OK"
end

-- Get Tu Vi Points per minute (AFK farming)
function RealmCalculator.GetTuViPerMinute(playerData)
	local currentRealm = playerData.CurrentRealm

	-- Base rate
	local baseRate = 1

	-- Higher realms get more Tu Vi per minute
	if currentRealm == 2 then
		baseRate = 5
	elseif currentRealm == 3 then
		baseRate = 20
	end

	-- TODO: Add bonuses from skills, equipment, etc.

	return baseRate
end

print("✅ RealmCalculator loaded (Full System)")
return RealmCalculator
