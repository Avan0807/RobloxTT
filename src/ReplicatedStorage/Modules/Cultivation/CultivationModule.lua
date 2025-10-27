-- CultivationModule.lua - Xử Lý Tu Luyện & Đột Phá
-- Copy vào ReplicatedStorage/Modules/Cultivation/CultivationModule (ModuleScript)

local Constants = require(game.ReplicatedStorage.Data.Constants)
local RealmCalculator = require(game.ReplicatedStorage.Modules.Stats.RealmCalculator)

local CultivationModule = {}

-- Get pills requirement table based on cultivation type
local function GetPillsTable(cultivationType)
	if cultivationType == "TienThien" then
		return Constants.TienThienPills
	elseif cultivationType == "CoThan" then
		return Constants.CoThanPills
	elseif cultivationType == "MaDao" then
		return Constants.MaDaoPills
	end
	return nil
end

-- Check if player has required pills for level up
function CultivationModule.HasRequiredPills(playerData, realmName, level)
	local cultivationType = playerData.CultivationType
	local pillsTable = GetPillsTable(cultivationType)

	if not pillsTable then
		return false, "Invalid cultivation type"
	end

	local realmPills = pillsTable[realmName]
	if not realmPills then
		return false, "Invalid realm"
	end

	-- Get requirements for this level (level is 1-8, array index)
	local requirements = realmPills[level]
	if not requirements then
		return false, "Invalid level"
	end

	-- Check each requirement
	for itemName, amount in pairs(requirements) do
		local playerAmount = playerData.DanDuoc[itemName] or 0
		if playerAmount < amount then
			return false, "Not enough " .. itemName .. " (need " .. amount .. ", have " .. playerAmount .. ")"
		end
	end

	return true, requirements
end

-- Consume pills from player inventory
local function ConsumePills(playerData, requirements)
	for itemName, amount in pairs(requirements) do
		if playerData.DanDuoc[itemName] then
			playerData.DanDuoc[itemName] = playerData.DanDuoc[itemName] - amount
		end
	end
end

-- Level up within same realm (1→2, 2→3, ..., 8→9)
function CultivationModule.LevelUp(playerData)
	-- Check if can level up
	local canLevelUp, reason = RealmCalculator.CanLevelUp(playerData)
	if not canLevelUp then
		return false, reason
	end

	local currentRealm = playerData.CurrentRealm
	local currentLevel = playerData.CurrentLevel
	local realmData = playerData.Realms["Realm" .. currentRealm]
	local realmName = realmData.Name

	-- Check pills requirement
	local hasPills, requirements = CultivationModule.HasRequiredPills(playerData, realmName, currentLevel)
	if not hasPills then
		return false, requirements
	end

	-- Get required Tu Vi Points
	local requiredTuVi = Constants.TuViPerLevel[currentLevel]

	-- Consume resources
	playerData.TuViPoints = playerData.TuViPoints - requiredTuVi
	ConsumePills(playerData, requirements)

	-- Level up!
	playerData.CurrentLevel = currentLevel + 1
	realmData.Level = currentLevel + 1

	-- Recalculate stats
	playerData.Stats = RealmCalculator.CalculateStats(playerData)

	-- Fully heal
	playerData.Stats.HP = playerData.Stats.MaxHP
	playerData.Stats.MP = playerData.Stats.MaxMP

	return true, "Leveled up to " .. RealmCalculator.GetRealmDisplayName(playerData)
end

-- Breakthrough to next realm (Realm 1→2 or 2→3)
function CultivationModule.Breakthrough(playerData)
	-- Check if can breakthrough
	local canBreakthrough, reason = RealmCalculator.CanBreakthrough(playerData)
	if not canBreakthrough then
		return false, reason
	end

	local currentRealm = playerData.CurrentRealm

	-- Get required Tu Vi Points
	local requiredTuVi = Constants.TuViBreakthrough[currentRealm]

	-- TODO: Check pills requirement for breakthrough
	-- (Different from level up, need special breakthrough pills)

	-- Consume Tu Vi Points
	playerData.TuViPoints = playerData.TuViPoints - requiredTuVi

	-- Unlock next realm
	local nextRealm = currentRealm + 1
	playerData.CurrentRealm = nextRealm
	playerData.CurrentLevel = 1

	local nextRealmData = playerData.Realms["Realm" .. nextRealm]
	nextRealmData.Locked = false
	nextRealmData.Level = 1

	-- Record breakthrough history
	table.insert(playerData.BreakthroughHistory, {
		Realm = nextRealmData.Name,
		Level = 1,
		Time = tick()
	})

	-- Recalculate stats (HUGE boost!)
	playerData.Stats = RealmCalculator.CalculateStats(playerData)

	-- Fully heal
	playerData.Stats.HP = playerData.Stats.MaxHP
	playerData.Stats.MP = playerData.Stats.MaxMP

	-- Special bonuses for Ma Đạo breakthrough
	if playerData.CultivationType == "MaDao" then
		if nextRealm == 2 then
			-- Unlock Vạn Hồn Phan
			playerData.HonPhien.Tier = "VanHon"
			playerData.HonPhien.MaxSouls = 10000
		elseif nextRealm == 3 then
			-- Unlock Diệt Thế Ma Phan
			playerData.HonPhien.Tier = "DieTThe"
			playerData.HonPhien.MaxSouls = 1000000
		end
	end

	return true, "Breakthrough successful! Now " .. RealmCalculator.GetRealmDisplayName(playerData)
end

-- Add Tu Vi Points (called by meditation/AFK farming)
function CultivationModule.AddTuViPoints(playerData, amount)
	playerData.TuViPoints = playerData.TuViPoints + amount
	return playerData.TuViPoints
end

-- Get next level requirements
function CultivationModule.GetNextLevelRequirements(playerData)
	local currentLevel = playerData.CurrentLevel

	if currentLevel >= 9 then
		return {
			Type = "Breakthrough",
			TuViRequired = Constants.TuViBreakthrough[playerData.CurrentRealm],
			Message = "Reach level 9, ready for breakthrough!"
		}
	end

	local realmData = playerData.Realms["Realm" .. playerData.CurrentRealm]
	local realmName = realmData.Name
	local hasPills, requirements = CultivationModule.HasRequiredPills(playerData, realmName, currentLevel)

	return {
		Type = "LevelUp",
		TuViRequired = Constants.TuViPerLevel[currentLevel],
		TuViCurrent = playerData.TuViPoints,
		Pills = requirements,
		HasPills = hasPills
	}
end

-- Process meditation (AFK farming)
function CultivationModule.Meditate(playerData, minutes)
	local tuViPerMinute = RealmCalculator.GetTuViPerMinute(playerData)
	local totalTuVi = tuViPerMinute * minutes

	CultivationModule.AddTuViPoints(playerData, totalTuVi)

	return totalTuVi
end

print("✅ CultivationModule loaded (Full System)")
return CultivationModule
