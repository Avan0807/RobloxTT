-- HonPhienAdvanced.lua - Advanced Hồn Phiên Features
-- Copy vào ReplicatedStorage/Modules/HonPhien/HonPhienAdvanced (ModuleScript)

local HonPhienAdvanced = {}

-- ========================================
-- TẾ LỄ HỒN PHIÊN (Soul Banner Sacrifice)
-- ========================================

HonPhienAdvanced.TeLeBuffs = {
	-- 100 souls sacrifice
	{
		Name = "Soul Power Boost",
		SoulCost = 100,
		Duration = 600, -- 10 minutes
		Effects = {
			SoulDamageMultiplier = 1.5 -- +50% Soul Dmg
		},
		Description = "+50% Soul Damage for 10 minutes",
		Icon = "💀"
	},

	-- 500 souls sacrifice
	{
		Name = "Summon Oan Hồn Boss",
		SoulCost = 500,
		Duration = 300, -- 5 minutes
		Effects = {
			SummonBoss = true,
			BossType = "OanHon",
			BossPower = 1.5
		},
		Description = "Summon a Oan Hồn to fight for you (5 min)",
		Icon = "👻"
	},

	-- 1000 souls sacrifice
	{
		Name = "Ma Hóa (Demonize)",
		SoulCost = 1000,
		Duration = 600, -- 10 minutes
		Effects = {
			AllStatsMultiplier = 2.0, -- Double all stats
			Lifesteal = 0.5,
			AppearanceChange = true
		},
		Description = "Transform into Demon Form - Double all stats (10 min)",
		Icon = "😈"
	},

	-- 5000 souls sacrifice (high tier)
	{
		Name = "Soul Overdrive",
		SoulCost = 5000,
		Duration = 300, -- 5 minutes
		Effects = {
			SoulDamageMultiplier = 5.0, -- +400% Soul Dmg
			HPRegen = 1000 -- 1000 HP/sec
		},
		Description = "+400% Soul Damage + 1000 HP/sec (5 min)",
		Icon = "🔥"
	},

	-- 10000 souls sacrifice (ultimate)
	{
		Name = "Soul Army",
		SoulCost = 10000,
		Duration = 180, -- 3 minutes
		Effects = {
			SummonArmy = true,
			ArmySize = 100,
			AllStatsMultiplier = 3.0
		},
		Description = "Summon 100 soul warriors + Triple stats (3 min)",
		Icon = "💀👻💀"
	}
}

-- ========================================
-- SPECIAL SKILLS
-- ========================================

HonPhienAdvanced.SpecialSkills = {
	-- Skill 1: Hồn Hải Mạn Thiên
	{
		SkillID = "hon_hai_man_thien",
		Name = "Hồn Hải Mạn Thiên",
		UnlockRealm = "MaTon", -- Ma Tôn 1+
		Cooldown = 30,
		Description = "Release all souls as AOE damage",
		SoulCost = "All", -- Uses all souls in banner
		Effects = {
			AOERange = 50,
			DamagePerSoul = 1, -- Each soul = 1 damage
			Type = "AOE"
		},
		Animation = "Wave",
		Icon = "🌊"
	},

	-- Skill 2: Thị Hồn (Devour Souls)
	{
		SkillID = "thi_hon",
		Name = "Thị Hồn",
		UnlockRealm = "MaTon", -- Ma Tôn 4+
		UnlockLevel = 4,
		Cooldown = 60,
		Description = "Consume 1000 souls to heal to full HP",
		SoulCost = 1000,
		Effects = {
			HealPercent = 1.0, -- Full heal
			Type = "Heal"
		},
		Animation = "Absorb",
		Icon = "💚"
	},

	-- Skill 3: Ma Vực Triển Khai
	{
		SkillID = "ma_vuc_trien_khai",
		Name = "Ma Vực Triển Khai",
		UnlockRealm = "MaTon", -- Ma Tôn 7+
		UnlockLevel = 7,
		Cooldown = 120,
		Description = "Create Demon Domain",
		SoulCost = 5000,
		Duration = 60, -- 1 minute
		Effects = {
			DomainRange = 80,
			EnemyDebuff = 0.5, -- -50% stats
			SoulDrainRate = 10, -- 10 souls/sec from enemies
			Type = "Domain"
		},
		Animation = "Expand",
		Icon = "⚫"
	},

	-- Skill 4: Linh Hồn Phong Ấn
	{
		SkillID = "linh_hon_phong_an",
		Name = "Linh Hồn Phong Ấn",
		UnlockRealm = "MaHoang", -- Ma Hoàng 1+
		Cooldown = 30,
		Description = "Seal enemy soul (instant kill if HP < 30%)",
		SoulCost = 0,
		Effects = {
			InstantKillThreshold = 0.30, -- 30% HP
			SealDuration = 10, -- If not killed, seal for 10s
			Type = "Execute"
		},
		Animation = "Seal",
		Icon = "🔒"
	},

	-- Skill 5: Ma Hoàng Hóa Thân
	{
		SkillID = "ma_hoang_hoa_than",
		Name = "Ma Hoàng Hóa Thân",
		UnlockRealm = "MaHoang", -- Ma Hoàng 4+
		UnlockLevel = 4,
		Cooldown = 300, -- 5 minutes
		Description = "Transform into Ma Hoàng",
		SoulCost = 0,
		Duration = 180, -- 3 minutes
		Effects = {
			AllStatsMultiplier = 10.0, -- 10x stats
			SoulDrainAura = 100, -- Drain 100 souls/sec from nearby
			AuraRange = 100,
			Type = "Transformation"
		},
		Animation = "Transform",
		Icon = "👹"
	},

	-- Skill 6: Hồn Phiên Giới (Ultimate)
	{
		SkillID = "hon_phien_gioi",
		Name = "Hồn Phiên Giới",
		UnlockRealm = "MaHoang", -- Ma Hoàng 7+
		UnlockLevel = 7,
		Cooldown = 86400, -- 1 day
		Description = "Create Soul Banner World",
		SoulCost = 50000,
		Duration = 300, -- 5 minutes
		Effects = {
			WorldRange = 200,
			InfiniteMinions = true,
			EnemyHPDrain = 0.05, -- 5% max HP/sec
			NoEscape = true,
			PermanentSeal = true, -- Souls trapped forever
			Type = "Ultimate"
		},
		Animation = "WorldExpand",
		Icon = "🌍"
	}
}

-- ========================================
-- PASSIVE BUFFS FROM SOUL COUNT
-- ========================================

function HonPhienAdvanced.GetPassiveBuff(currentSouls)
	-- Ma Tôn 4+ passive: Each 1000 souls = +1% stats (max +180%)
	local buffPercent = math.floor(currentSouls / 1000)
	buffPercent = math.min(buffPercent, 180) -- Cap at 180%

	return buffPercent / 100 -- Return as multiplier
end

-- ========================================
-- CAN USE TẾ LỄ
-- ========================================

function HonPhienAdvanced.CanUseTeLe(currentSouls, buffIndex)
	local buff = HonPhienAdvanced.TeLeBuffs[buffIndex]
	if not buff then
		return false, "Buff not found"
	end

	if currentSouls < buff.SoulCost then
		return false, "Not enough souls! Need: " .. buff.SoulCost
	end

	return true
end

-- ========================================
-- ACTIVATE TẾ LỄ BUFF
-- ========================================

function HonPhienAdvanced.ActivateTeLe(buffIndex)
	local buff = HonPhienAdvanced.TeLeBuffs[buffIndex]
	if not buff then
		return nil
	end

	return {
		Name = buff.Name,
		Duration = buff.Duration,
		Effects = buff.Effects,
		StartTime = os.time(),
		EndTime = os.time() + buff.Duration
	}
end

-- ========================================
-- CAN USE SPECIAL SKILL
-- ========================================

function HonPhienAdvanced.CanUseSkill(skillID, playerData)
	-- Find skill
	local skill = nil
	for _, s in ipairs(HonPhienAdvanced.SpecialSkills) do
		if s.SkillID == skillID then
			skill = s
			break
		end
	end

	if not skill then
		return false, "Skill not found"
	end

	-- Check realm
	if skill.UnlockRealm then
		local realmName = playerData.Realm1 and playerData.Realm1.Name
		if not realmName or not realmName:match(skill.UnlockRealm) then
			return false, "Requires " .. skill.UnlockRealm .. " realm"
		end
	end

	-- Check level
	if skill.UnlockLevel then
		local level = playerData.Realm1 and playerData.Realm1.Level or 0
		if level < skill.UnlockLevel then
			return false, "Requires level " .. skill.UnlockLevel
		end
	end

	-- Check soul cost
	if skill.SoulCost and skill.SoulCost ~= "All" then
		local currentSouls = playerData.HonPhien and playerData.HonPhien.Souls or 0
		if currentSouls < skill.SoulCost then
			return false, "Not enough souls! Need: " .. skill.SoulCost
		end
	end

	return true
end

-- ========================================
-- GET SKILL DATA
-- ========================================

function HonPhienAdvanced.GetSkill(skillID)
	for _, skill in ipairs(HonPhienAdvanced.SpecialSkills) do
		if skill.SkillID == skillID then
			return skill
		end
	end
	return nil
end

-- ========================================
-- GET AVAILABLE SKILLS
-- ========================================

function HonPhienAdvanced.GetAvailableSkills(playerData)
	local available = {}

	for _, skill in ipairs(HonPhienAdvanced.SpecialSkills) do
		local canUse, msg = HonPhienAdvanced.CanUseSkill(skill.SkillID, playerData)
		if canUse then
			table.insert(available, skill)
		end
	end

	return available
end

-- ========================================
-- CALCULATE SKILL DAMAGE
-- ========================================

function HonPhienAdvanced.CalculateSkillDamage(skillID, currentSouls)
	local skill = HonPhienAdvanced.GetSkill(skillID)
	if not skill then
		return 0
	end

	-- For Hồn Hải Mạn Thiên
	if skillID == "hon_hai_man_thien" then
		return currentSouls * skill.Effects.DamagePerSoul
	end

	return 0
end

-- ========================================
-- IS BUFF ACTIVE
-- ========================================

function HonPhienAdvanced.IsBuffActive(buffData)
	if not buffData or not buffData.EndTime then
		return false
	end

	return os.time() < buffData.EndTime
end

-- ========================================
-- GET REMAINING TIME
-- ========================================

function HonPhienAdvanced.GetRemainingTime(buffData)
	if not buffData or not buffData.EndTime then
		return 0
	end

	local remaining = buffData.EndTime - os.time()
	return math.max(0, remaining)
end

print("✅ HonPhienAdvanced loaded")
return HonPhienAdvanced
