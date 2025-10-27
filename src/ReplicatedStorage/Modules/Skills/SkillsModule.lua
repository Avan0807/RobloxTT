-- SkillsModule.lua - Hệ Thống Kỹ Năng cho 3 Hệ Tu Luyện
-- Copy vào ReplicatedStorage/Modules/Skills/SkillsModule (ModuleScript)

local SkillsModule = {}

-- ========================================
-- TIÊN THIÊN SKILLS (Magic)
-- ========================================

SkillsModule.TienThien = {
	-- Basic skills (Ngưng Khí Tầng 1+)
	{
		Name = "Linh Phong Chưởng",
		Key = "Q",
		RequiredRealm = 1,
		RequiredLevel = 1,
		Cooldown = 1,
		ManaCost = 20,
		DamageType = "Magic",
		DamageMultiplier = 1.0,
		Range = 15,
		ProjectileType = "MagicBolt",
		Description = "Tấn công cơ bản bằng pháp thuật",
		Animation = "Punch"
	},

	-- Ngưng Khí Tầng 4+
	{
		Name = "Hỏa Cầu Thuật",
		Key = "E",
		RequiredRealm = 1,
		RequiredLevel = 4,
		Cooldown = 5,
		ManaCost = 50,
		DamageType = "Magic",
		DamageMultiplier = 2.5,
		Range = 20,
		AOERadius = 8,
		ProjectileType = "Fireball",
		Description = "Phóng hỏa cầu gây sát thương vùng",
		Animation = "Point"
	},

	-- Ngưng Khí Tầng 7+
	{
		Name = "Vân Vũ Lôi Điện",
		Key = "R",
		RequiredRealm = 1,
		RequiredLevel = 7,
		Cooldown = 15,
		ManaCost = 100,
		DamageType = "Magic",
		DamageMultiplier = 5.0,
		Range = 25,
		AOERadius = 10,
		ProjectileType = "Lightning",
		Description = "Triệu hồi sét đánh gây sát thương lớn",
		Animation = "Point",
		IsUltimate = true
	},

	-- Trúc Cơ Tầng 1+ (Realm 2)
	{
		Name = "Vạn Kiếm Quy Tông",
		Key = "F",
		RequiredRealm = 2,
		RequiredLevel = 1,
		Cooldown = 30,
		ManaCost = 200,
		DamageType = "Magic",
		DamageMultiplier = 8.0,
		Range = 40,
		AOERadius = 20,
		ProjectileType = "Lightning",
		Description = "Triệu hồi ngàn kiếm bay tấn công",
		Animation = "Point",
		IsUltimate = true
	},

	-- Nguyên Anh Tầng 1+ (Realm 3)
	{
		Name = "Hồng Mông Sơ Khai",
		Key = "G",
		RequiredRealm = 3,
		RequiredLevel = 1,
		Cooldown = 60,
		ManaCost = 500,
		DamageType = "Magic",
		DamageMultiplier = 20.0,
		Range = 100,
		AOERadius = 50,
		ProjectileType = "Fireball",
		Description = "Đại skill Nguyên Anh, sức mạnh kinh thiên động địa",
		Animation = "Point",
		IsUltimate = true
	}
}

-- ========================================
-- CỔ THẦN SKILLS (Physical)
-- ========================================

SkillsModule.CoThan = {
	-- Basic skills (Cổ Thần 1 Sao+)
	{
		Name = "Bá Vương Quyền",
		Key = "Q",
		RequiredRealm = 1,
		RequiredLevel = 1,
		Cooldown = 0.8,
		ManaCost = 0,
		DamageType = "Physical",
		DamageMultiplier = 1.0,
		Range = 8,
		ProjectileType = "PunchWave",
		Description = "Đấm mạnh vào mục tiêu",
		Animation = "Punch"
	},

	-- Cổ Thần 4 Sao+
	{
		Name = "Mãnh Hổ Hạ Sơn",
		Key = "E",
		RequiredRealm = 1,
		RequiredLevel = 4,
		Cooldown = 8,
		ManaCost = 0,
		DamageType = "Physical",
		DamageMultiplier = 3.0,
		Range = 10,
		ProjectileType = "PunchWave",
		Description = "Đấm 3 hit combo liên tiếp",
		Animation = "Slash",
		ComboHits = 3
	},

	-- Cổ Thần 7 Sao+
	{
		Name = "Thiết Thân Hoành Luyện",
		Key = "R",
		RequiredRealm = 1,
		RequiredLevel = 7,
		Cooldown = 20,
		ManaCost = 0,
		DamageType = "Physical",
		DamageMultiplier = 6.0,
		Range = 12,
		ProjectileType = "PunchWave",
		Description = "Đòn giáng thiên địa, phản damage 20%",
		Animation = "Slash",
		ReflectDamage = 0.2,
		IsUltimate = true
	},

	-- Cổ Ma 1 Sao+ (Realm 2)
	{
		Name = "Hỗn Độn Bất Diệt Thể",
		Key = "F",
		RequiredRealm = 2,
		RequiredLevel = 1,
		Cooldown = 30,
		ManaCost = 0,
		DamageType = "Physical",
		DamageMultiplier = 10.0,
		Range = 15,
		AOERadius = 10,
		ProjectileType = "PunchWave",
		Description = "AOE sóng xung kích, hồi 5% HP khi kill",
		Animation = "Slash",
		HealOnKill = 0.05,
		IsUltimate = true
	},

	-- Cổ Tôn 1 Sao+ (Realm 3)
	{
		Name = "Bàn Cổ Chân Thân",
		Key = "G",
		RequiredRealm = 3,
		RequiredLevel = 1,
		Cooldown = 60,
		ManaCost = 0,
		DamageType = "Physical",
		DamageMultiplier = 30.0,
		Range = 20,
		AOERadius = 30,
		ProjectileType = "PunchWave",
		Description = "Biến thành khổng lồ, +400% stats trong 30s",
		Animation = "Slash",
		BuffDuration = 30,
		BuffMultiplier = 4.0,
		IsUltimate = true
	}
}

-- ========================================
-- MA ĐẠO SKILLS (Soul/Dark)
-- ========================================

SkillsModule.MaDao = {
	-- Basic skills (Ma Đạo 1 Tinh+)
	{
		Name = "Huyết Ảnh Trảo",
		Key = "Q",
		RequiredRealm = 1,
		RequiredLevel = 1,
		Cooldown = 1,
		ManaCost = 15,
		DamageType = "Soul",
		DamageMultiplier = 1.0,
		Range = 12,
		ProjectileType = "SoulBolt",
		Description = "Tấn công bằng sức mạnh linh hồn",
		Animation = "Punch",
		SoulGain = 1 -- Hút 1 linh hồn vào Hồn Phiên
	},

	-- Ma Đạo 4 Tinh+
	{
		Name = "Phách Tán Linh Kiếm",
		Key = "E",
		RequiredRealm = 1,
		RequiredLevel = 4,
		Cooldown = 6,
		ManaCost = 40,
		DamageType = "Soul",
		DamageMultiplier = 2.5,
		Range = 15,
		ProjectileType = "SoulBolt",
		BypassDefense = 0.3, -- Bỏ qua 30% defense
		Description = "Tấn công linh hồn trực tiếp, bỏ qua phòng thủ",
		Animation = "Point",
		SoulGain = 2
	},

	-- Ma Đạo 7 Tinh+
	{
		Name = "Vạn Hồn Phiên Động",
		Key = "R",
		RequiredRealm = 1,
		RequiredLevel = 7,
		Cooldown = 18,
		ManaCost = 80,
		DamageType = "Soul",
		DamageMultiplier = 5.5,
		Range = 20,
		AOERadius = 12,
		ProjectileType = "SoulBolt",
		Description = "Phóng thích linh hồn từ Hồn Phiên",
		Animation = "Point",
		IsUltimate = true,
		UsesHonPhien = true, -- Damage = Số linh hồn × 10
		SoulGain = 5
	},

	-- Ma Tôn 1 Tinh+ (Realm 2)
	{
		Name = "Vạn Quỷ Phệ Hồn",
		Key = "F",
		RequiredRealm = 2,
		RequiredLevel = 1,
		Cooldown = 30,
		ManaCost = 150,
		DamageType = "Soul",
		DamageMultiplier = 12.0,
		Range = 30,
		AOERadius = 20,
		ProjectileType = "SoulBolt",
		Description = "Triệu hồi vạn quỷ tấn công",
		Animation = "Point",
		IsUltimate = true,
		SoulGain = 10
	},

	-- Ma Hoàng 1 Tinh+ (Realm 3)
	{
		Name = "Diệt Thế Ma Phan",
		Key = "G",
		RequiredRealm = 3,
		RequiredLevel = 1,
		Cooldown = 60,
		ManaCost = 300,
		DamageType = "Soul",
		DamageMultiplier = 25.0,
		Range = 50,
		AOERadius = 40,
		ProjectileType = "SoulBolt",
		Description = "Skill tối thượng Ma Hoàng, phong ấn linh hồn",
		Animation = "Point",
		IsUltimate = true,
		InstantKillThreshold = 0.3, -- Instant kill nếu HP < 30%
		SoulGain = 50
	}
}

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

-- Get skills for a cultivation type
function SkillsModule.GetSkills(cultivationType)
	if cultivationType == "TienThien" then
		return SkillsModule.TienThien
	elseif cultivationType == "CoThan" then
		return SkillsModule.CoThan
	elseif cultivationType == "MaDao" then
		return SkillsModule.MaDao
	end
	return {}
end

-- Get available skills for player (based on realm and level)
function SkillsModule.GetAvailableSkills(playerData)
	local skills = SkillsModule.GetSkills(playerData.CultivationType)
	local availableSkills = {}

	local currentRealm = playerData.CurrentRealm
	local currentLevel = playerData.CurrentLevel

	for _, skill in ipairs(skills) do
		if currentRealm > skill.RequiredRealm or
		   (currentRealm == skill.RequiredRealm and currentLevel >= skill.RequiredLevel) then
			table.insert(availableSkills, skill)
		end
	end

	return availableSkills
end

-- Calculate skill damage
function SkillsModule.CalculateSkillDamage(skill, playerStats, honPhienSouls)
	honPhienSouls = honPhienSouls or 0

	local baseDamage = 0

	if skill.DamageType == "Physical" then
		baseDamage = playerStats.PhysicalDamage or 0
	elseif skill.DamageType == "Magic" then
		baseDamage = playerStats.MagicDamage or 0
	elseif skill.DamageType == "Soul" then
		baseDamage = playerStats.SoulDamage or 0
	end

	local skillDamage = baseDamage * skill.DamageMultiplier

	-- Special: Skills that use Hồn Phiên
	if skill.UsesHonPhien and honPhienSouls > 0 then
		skillDamage = skillDamage + (honPhienSouls * 10)
	end

	return math.floor(skillDamage)
end

-- Check if player can use skill
function SkillsModule.CanUseSkill(skill, playerStats, lastCastTime)
	-- Check mana
	if skill.ManaCost > 0 and playerStats.MP < skill.ManaCost then
		return false, "Không đủ MP"
	end

	-- Check cooldown
	local currentTime = tick()
	if currentTime - lastCastTime < skill.Cooldown then
		local remaining = skill.Cooldown - (currentTime - lastCastTime)
		return false, "Cooldown còn " .. string.format("%.1f", remaining) .. "s"
	end

	return true, "OK"
end

print("✅ SkillsModule loaded (Full System)")
return SkillsModule
