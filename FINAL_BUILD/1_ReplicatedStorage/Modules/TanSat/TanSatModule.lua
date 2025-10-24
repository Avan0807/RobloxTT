-- TanSatModule.lua - Hệ Thống Tàn Sát (Slaughter System)
-- Copy vào ReplicatedStorage/Modules/TanSat/TanSatModule (ModuleScript)

local TanSatModule = {}

-- ========================================
-- SÁT KHÍ TIERS (Kill Count Tiers)
-- ========================================

TanSatModule.SatKhiTiers = {
	{
		Name = "Tân Thủ Sát Nhân",
		KillsRequired = 0,
		SoulDamageBonus = 0,
		Color = Color3.fromRGB(200, 200, 200),
		Title = "Beginner Killer"
	},
	{
		Name = "Sát Nhân",
		KillsRequired = 100,
		SoulDamageBonus = 0.10, -- +10%
		Color = Color3.fromRGB(150, 255, 150),
		Title = "Killer"
	},
	{
		Name = "Huyết Sát",
		KillsRequired = 1000,
		SoulDamageBonus = 0.50, -- +50%
		Color = Color3.fromRGB(255, 200, 100),
		Title = "Blood Slaughterer"
	},
	{
		Name = "Ma Đầu",
		KillsRequired = 10000,
		SoulDamageBonus = 1.50, -- +150%
		Color = Color3.fromRGB(255, 100, 100),
		Title = "Demon Head",
		Penalty = {
			Bounty = 50000,
			CityBanned = true,
			NPCHostile = true
		}
	},
	{
		Name = "Ma Đầu Huyền Thoại",
		KillsRequired = 100000,
		SoulDamageBonus = 5.0, -- +500%
		Color = Color3.fromRGB(200, 0, 200),
		Title = "Legendary Demon",
		Penalty = {
			Bounty = 500000,
			CityBanned = true,
			NPCHostile = true,
			HuntedByAll = true
		}
	}
}

-- ========================================
-- LINH HỒN TYPES & VALUES
-- ========================================

TanSatModule.LinhHonTypes = {
	PhamNhan = {
		Name = "Phàm Nhân Linh Hồn",
		Value = 1,
		Description = "Linh hồn người thường",
		Color = Color3.fromRGB(200, 200, 200)
	},
	TuSi = {
		Name = "Tu Sĩ Linh Hồn",
		Value = 5,
		Description = "Linh hồn tu sĩ",
		Color = Color3.fromRGB(100, 200, 255)
	},
	CaoThu = {
		Name = "Cao Thủ Linh Hồn",
		Value = 20,
		Description = "Linh hồn cao thủ",
		Color = Color3.fromRGB(255, 150, 100)
	},
	YeuThu = {
		Name = "Yêu Thú Linh Hồn",
		Value = 10,
		Description = "Linh hồn yêu thú",
		Color = Color3.fromRGB(150, 255, 150)
	},
	Boss = {
		Name = "Boss Linh Hồn",
		Value = 100,
		Description = "Linh hồn boss",
		Color = Color3.fromRGB(255, 200, 0)
	},
	TienNhan = {
		Name = "Tiên Nhân Linh Hồn",
		Value = 500,
		Description = "Linh hồn tiên nhân (cực hiếm)",
		Color = Color3.fromRGB(255, 100, 255)
	},
	ThanLinh = {
		Name = "Thần Linh Hồn",
		Value = 5000,
		Description = "Linh hồn thần linh (legendary)",
		Color = Color3.fromRGB(255, 0, 0)
	}
}

-- ========================================
-- GET CURRENT TIER
-- ========================================

function TanSatModule.GetCurrentTier(killCount)
	local currentTier = TanSatModule.SatKhiTiers[1]

	for _, tier in ipairs(TanSatModule.SatKhiTiers) do
		if killCount >= tier.KillsRequired then
			currentTier = tier
		else
			break
		end
	end

	return currentTier
end

-- ========================================
-- GET NEXT TIER
-- ========================================

function TanSatModule.GetNextTier(killCount)
	local currentTierIndex = 1

	for i, tier in ipairs(TanSatModule.SatKhiTiers) do
		if killCount >= tier.KillsRequired then
			currentTierIndex = i
		else
			break
		end
	end

	-- Return next tier if exists
	if currentTierIndex < #TanSatModule.SatKhiTiers then
		return TanSatModule.SatKhiTiers[currentTierIndex + 1]
	end

	return nil -- Max tier reached
end

-- ========================================
-- CALCULATE SOUL DAMAGE BONUS
-- ========================================

function TanSatModule.CalculateSoulDamageBonus(killCount)
	local tier = TanSatModule.GetCurrentTier(killCount)
	return tier.SoulDamageBonus
end

-- ========================================
-- GET LINH HỒN VALUE
-- ========================================

function TanSatModule.GetLinhHonValue(enemyType, enemyLevel)
	-- Determine soul type based on enemy
	local soulType = "PhamNhan"

	if enemyType:match("Boss") then
		soulType = "Boss"
	elseif enemyLevel >= 20 then
		soulType = "CaoThu"
	elseif enemyLevel >= 10 then
		soulType = "TuSi"
	elseif enemyType:match("Yeu") or enemyType:match("Beast") then
		soulType = "YeuThu"
	end

	local linhHon = TanSatModule.LinhHonTypes[soulType]
	return linhHon.Value, linhHon
end

-- ========================================
-- CHECK IF HAS PENALTY
-- ========================================

function TanSatModule.HasPenalty(killCount)
	local tier = TanSatModule.GetCurrentTier(killCount)
	return tier.Penalty ~= nil, tier.Penalty
end

-- ========================================
-- GET BOUNTY AMOUNT
-- ========================================

function TanSatModule.GetBounty(killCount)
	local hasPenalty, penalty = TanSatModule.HasPenalty(killCount)

	if hasPenalty and penalty.Bounty then
		return penalty.Bounty
	end

	return 0
end

-- ========================================
-- CAN ENTER CITY
-- ========================================

function TanSatModule.CanEnterCity(killCount)
	local hasPenalty, penalty = TanSatModule.HasPenalty(killCount)

	if hasPenalty and penalty.CityBanned then
		return false
	end

	return true
end

-- ========================================
-- GET TIER PROGRESS (for UI)
-- ========================================

function TanSatModule.GetTierProgress(killCount)
	local currentTier = TanSatModule.GetCurrentTier(killCount)
	local nextTier = TanSatModule.GetNextTier(killCount)

	if not nextTier then
		return {
			Current = killCount,
			Goal = killCount,
			Percent = 1.0,
			MaxTier = true
		}
	end

	local progress = killCount - currentTier.KillsRequired
	local goal = nextTier.KillsRequired - currentTier.KillsRequired
	local percent = progress / goal

	return {
		Current = progress,
		Goal = goal,
		Percent = percent,
		MaxTier = false
	}
end

-- ========================================
-- GET TITLE TEXT
-- ========================================

function TanSatModule.GetTitleText(killCount)
	local tier = TanSatModule.GetCurrentTier(killCount)
	return tier.Name .. " (" .. killCount .. " kills)"
end

-- ========================================
-- APPLY BUFFS TO STATS
-- ========================================

function TanSatModule.ApplyBuffsToStats(stats, killCount, cultivationType)
	-- Only apply to Ma Đạo
	if cultivationType ~= "MaDao" then
		return stats
	end

	local bonus = TanSatModule.CalculateSoulDamageBonus(killCount)

	-- Apply Soul Damage bonus
	if stats.SoulDamage then
		stats.SoulDamage = stats.SoulDamage * (1 + bonus)
	end

	return stats
end

-- ========================================
-- SHOULD SPAWN HUNTERS (NPC Hunt)
-- ========================================

function TanSatModule.ShouldSpawnHunters(killCount)
	local hasPenalty, penalty = TanSatModule.HasPenalty(killCount)

	if hasPenalty and penalty.NPCHostile then
		-- 10% chance every 5 minutes for NPC hunters to spawn
		if math.random() < 0.1 then
			return true
		end
	end

	return false
end

-- ========================================
-- GET HUNTER DIFFICULTY
-- ========================================

function TanSatModule.GetHunterDifficulty(killCount)
	local tier = TanSatModule.GetCurrentTier(killCount)

	if killCount >= 100000 then
		return "Extreme" -- 5 hunters, very strong
	elseif killCount >= 10000 then
		return "Hard" -- 3 hunters, strong
	else
		return "Normal" -- 1 hunter
	end
end

print("✅ TanSatModule loaded")
return TanSatModule
