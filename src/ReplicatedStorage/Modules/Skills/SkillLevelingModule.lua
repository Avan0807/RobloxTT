-- SkillLevelingModule.lua - Skill Leveling System
-- Copy vào ReplicatedStorage/Modules/Skills/SkillLevelingModule (ModuleScript)

local SkillLevelingModule = {}

-- ========================================
-- SKILL LEVELS & PROGRESSION
-- ========================================

SkillLevelingModule.MaxSkillLevel = 10

-- XP required for each level
SkillLevelingModule.XPRequirements = {
	[1] = 0,      -- Level 1 (starting)
	[2] = 100,    -- Level 2
	[3] = 300,    -- Level 3
	[4] = 600,    -- Level 4
	[5] = 1000,   -- Level 5
	[6] = 2000,   -- Level 6
	[7] = 4000,   -- Level 7
	[8] = 8000,   -- Level 8
	[9] = 15000,  -- Level 9
	[10] = 30000  -- Level 10 (max)
}

-- ========================================
-- SKILL STAT SCALING PER LEVEL
-- ========================================

-- Each skill level provides:
SkillLevelingModule.ScalingPerLevel = {
	Damage = 0.10,        -- +10% damage per level
	Cooldown = -0.05,     -- -5% cooldown per level
	Range = 0.05,         -- +5% range per level
	Duration = 0.05,      -- +5% duration per level
	SoulCost = -0.03      -- -3% soul cost per level
}

-- ========================================
-- GET XP REQUIRED FOR LEVEL
-- ========================================

function SkillLevelingModule.GetXPRequired(level)
	if level < 1 then
		return 0
	elseif level > SkillLevelingModule.MaxSkillLevel then
		return SkillLevelingModule.XPRequirements[SkillLevelingModule.MaxSkillLevel]
	end

	return SkillLevelingModule.XPRequirements[level] or 0
end

-- ========================================
-- CALCULATE SKILL LEVEL FROM XP
-- ========================================

function SkillLevelingModule.CalculateLevel(xp)
	for level = SkillLevelingModule.MaxSkillLevel, 1, -1 do
		if xp >= SkillLevelingModule.GetXPRequired(level) then
			return level
		end
	end

	return 1
end

-- ========================================
-- ADD SKILL XP
-- ========================================

function SkillLevelingModule.AddXP(skillData, xpAmount)
	if not skillData then return false, 0 end

	local oldXP = skillData.XP or 0
	local oldLevel = SkillLevelingModule.CalculateLevel(oldXP)

	skillData.XP = oldXP + xpAmount

	-- Cap at max level XP
	local maxXP = SkillLevelingModule.GetXPRequired(SkillLevelingModule.MaxSkillLevel)
	if skillData.XP > maxXP then
		skillData.XP = maxXP
	end

	local newLevel = SkillLevelingModule.CalculateLevel(skillData.XP)
	local leveledUp = newLevel > oldLevel

	return leveledUp, newLevel
end

-- ========================================
-- GET SKILL MULTIPLIER
-- ========================================

function SkillLevelingModule.GetMultiplier(skillLevel, statType)
	if skillLevel <= 1 then
		return 1.0 -- No bonus at level 1
	end

	local scaling = SkillLevelingModule.ScalingPerLevel[statType] or 0
	local levelsAbove1 = skillLevel - 1

	return 1.0 + (scaling * levelsAbove1)
end

-- ========================================
-- APPLY SKILL LEVEL BONUSES
-- ========================================

function SkillLevelingModule.ApplyBonuses(baseSkill, skillLevel)
	if not baseSkill or not skillLevel or skillLevel <= 1 then
		return baseSkill
	end

	local bonusedSkill = {}

	-- Copy base skill
	for k, v in pairs(baseSkill) do
		bonusedSkill[k] = v
	end

	-- Apply damage bonus
	if bonusedSkill.Damage then
		bonusedSkill.Damage = bonusedSkill.Damage * SkillLevelingModule.GetMultiplier(skillLevel, "Damage")
	end

	-- Apply cooldown reduction
	if bonusedSkill.Cooldown then
		bonusedSkill.Cooldown = bonusedSkill.Cooldown * SkillLevelingModule.GetMultiplier(skillLevel, "Cooldown")
		bonusedSkill.Cooldown = math.max(1, bonusedSkill.Cooldown) -- Min 1 second cooldown
	end

	-- Apply range bonus
	if bonusedSkill.Range then
		bonusedSkill.Range = bonusedSkill.Range * SkillLevelingModule.GetMultiplier(skillLevel, "Range")
	end

	-- Apply duration bonus
	if bonusedSkill.Duration then
		bonusedSkill.Duration = bonusedSkill.Duration * SkillLevelingModule.GetMultiplier(skillLevel, "Duration")
	end

	-- Apply soul cost reduction
	if bonusedSkill.SoulCost and bonusedSkill.SoulCost ~= "All" then
		bonusedSkill.SoulCost = math.ceil(bonusedSkill.SoulCost * SkillLevelingModule.GetMultiplier(skillLevel, "SoulCost"))
		bonusedSkill.SoulCost = math.max(1, bonusedSkill.SoulCost) -- Min 1 soul cost
	end

	-- Apply bonuses to Effects table
	if bonusedSkill.Effects then
		local effects = {}
		for k, v in pairs(bonusedSkill.Effects) do
			effects[k] = v
		end

		-- Scale effect values
		if effects.AOERange then
			effects.AOERange = effects.AOERange * SkillLevelingModule.GetMultiplier(skillLevel, "Range")
		end

		if effects.DomainRange then
			effects.DomainRange = effects.DomainRange * SkillLevelingModule.GetMultiplier(skillLevel, "Range")
		end

		if effects.WorldRange then
			effects.WorldRange = effects.WorldRange * SkillLevelingModule.GetMultiplier(skillLevel, "Range")
		end

		bonusedSkill.Effects = effects
	end

	return bonusedSkill
end

-- ========================================
-- GET PROGRESS TO NEXT LEVEL
-- ========================================

function SkillLevelingModule.GetProgress(skillData)
	if not skillData then
		return {
			CurrentLevel = 1,
			CurrentXP = 0,
			XPToNextLevel = SkillLevelingModule.GetXPRequired(2),
			Progress = 0,
			MaxLevel = false
		}
	end

	local xp = skillData.XP or 0
	local currentLevel = SkillLevelingModule.CalculateLevel(xp)

	if currentLevel >= SkillLevelingModule.MaxSkillLevel then
		return {
			CurrentLevel = currentLevel,
			CurrentXP = xp,
			XPToNextLevel = 0,
			Progress = 1.0,
			MaxLevel = true
		}
	end

	local currentLevelXP = SkillLevelingModule.GetXPRequired(currentLevel)
	local nextLevelXP = SkillLevelingModule.GetXPRequired(currentLevel + 1)
	local xpInCurrentLevel = xp - currentLevelXP
	local xpNeeded = nextLevelXP - currentLevelXP
	local progress = xpInCurrentLevel / xpNeeded

	return {
		CurrentLevel = currentLevel,
		CurrentXP = xp,
		XPInLevel = xpInCurrentLevel,
		XPToNextLevel = xpNeeded,
		Progress = progress,
		MaxLevel = false
	}
end

-- ========================================
-- CALCULATE XP GAIN
-- ========================================

function SkillLevelingModule.CalculateXPGain(actionType, enemyLevel)
	-- Different actions give different XP
	local baseXP = {
		UseSkill = 10,         -- Using a skill
		KillEnemy = 20,        -- Killing an enemy with skill
		KillBoss = 100,        -- Killing a boss with skill
		UseTeLe = 50           -- Using Tế Lễ buff
	}

	local xp = baseXP[actionType] or 10

	-- Scale with enemy level
	if enemyLevel then
		xp = xp * (1 + (enemyLevel * 0.1))
	end

	return math.floor(xp)
end

-- ========================================
-- GET SKILL INFO TEXT
-- ========================================

function SkillLevelingModule.GetSkillInfoText(skillName, skillLevel)
	local progress = SkillLevelingModule.GetProgress({XP = SkillLevelingModule.GetXPRequired(skillLevel)})

	local bonuses = {
		"Damage: +" .. math.floor((SkillLevelingModule.GetMultiplier(skillLevel, "Damage") - 1) * 100) .. "%",
		"Cooldown: " .. math.floor((SkillLevelingModule.GetMultiplier(skillLevel, "Cooldown") - 1) * 100) .. "%",
		"Range: +" .. math.floor((SkillLevelingModule.GetMultiplier(skillLevel, "Range") - 1) * 100) .. "%",
		"Soul Cost: " .. math.floor((SkillLevelingModule.GetMultiplier(skillLevel, "SoulCost") - 1) * 100) .. "%"
	}

	return skillName .. " [Lv." .. skillLevel .. "]\n" .. table.concat(bonuses, " | ")
end

print("✅ SkillLevelingModule loaded")
return SkillLevelingModule
