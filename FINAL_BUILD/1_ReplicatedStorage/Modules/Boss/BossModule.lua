-- BossModule.lua - Hệ Thống Boss
-- Copy vào ReplicatedStorage/Modules/Boss/BossModule (ModuleScript)

local BossModule = {}

-- ========================================
-- BOSS DEFINITIONS
-- ========================================

BossModule.Bosses = {
	-- Beginner Boss
	{
		BossID = "boss_linh_thu_vuong",
		Name = "Linh Thú Vương",
		Description = "Vua của các Linh Thú",
		Level = 5,
		Realm = 1,

		Stats = {
			HP = 5000,
			MagicDamage = 0,
			PhysicalDamage = 100,
			SoulDamage = 0,
			Defense = 50,
			MagicDefense = 30,
			Speed = 15,
			CritRate = 0.1
		},

		-- Boss Phases (at HP thresholds)
		Phases = {
			{
				HPPercent = 0.75, -- At 75% HP
				Name = "Enraged",
				DamageMultiplier = 1.2,
				SpeedMultiplier = 1.1,
				Message = "Linh Thú Vương đã nổi giận!"
			},
			{
				HPPercent = 0.50,
				Name = "Berserk",
				DamageMultiplier = 1.5,
				SpeedMultiplier = 1.3,
				Message = "Linh Thú Vương đã cuồng nộ!"
			},
			{
				HPPercent = 0.25,
				Name = "Desperate",
				DamageMultiplier = 2.0,
				SpeedMultiplier = 1.5,
				Message = "Linh Thú Vương chiến đấu quyết tử!"
			}
		},

		-- Special Abilities
		Abilities = {
			{
				Name = "Roar",
				Cooldown = 15,
				Damage = 200,
				Range = 30,
				Description = "AOE attack"
			},
			{
				Name = "Charge",
				Cooldown = 10,
				Damage = 300,
				Range = 50,
				Description = "Dash attack"
			}
		},

		-- Loot
		LootTable = {
			GuaranteedDrops = {
				Gold = {Min = 1000, Max = 2000},
				TuVi = {Min = 2000, Max = 5000}
			},
			Items = {
				{ItemName = "Đại Hoàn Đan", Amount = 5, Chance = 1.0},
				{ItemName = "Linh Kiếm", Amount = 1, Chance = 0.3},
				{ItemName = "Vạn Niên Linh Dược", Amount = 3, Chance = 0.5},
				{ItemName = "Kim Cang Xá Lợi", Amount = 1, Chance = 0.1}
			}
		},

		SpawnLocation = "RungLinhThu",
		RespawnTime = 300, -- 5 minutes

		-- Visual
		ModelName = "LinhThuVuong",
		Size = Vector3.new(8, 8, 8),
		Color = Color3.fromRGB(200, 50, 50)
	},

	-- Mid-tier Boss
	{
		BossID = "boss_thien_mon_ma_vuong",
		Name = "Thiên Môn Ma Vương",
		Description = "Ma Vương từ Thiên Môn",
		Level = 15,
		Realm = 2,

		Stats = {
			HP = 20000,
			MagicDamage = 300,
			PhysicalDamage = 0,
			SoulDamage = 250,
			Defense = 100,
			MagicDefense = 120,
			Speed = 20,
			CritRate = 0.15,
			Lifesteal = 0.2
		},

		Phases = {
			{
				HPPercent = 0.70,
				Name = "Dark Aura",
				DamageMultiplier = 1.3,
				Message = "Thiên Môn Ma Vương giải phóng Ma Khí!"
			},
			{
				HPPercent = 0.40,
				Name = "Demon Form",
				DamageMultiplier = 1.6,
				SpeedMultiplier = 1.2,
				Message = "Thiên Môn Ma Vương biến hình Ma Thần!"
			},
			{
				HPPercent = 0.15,
				Name = "Final Form",
				DamageMultiplier = 2.5,
				SpeedMultiplier = 1.5,
				HPRegen = 100, -- HP per second
				Message = "Thiên Môn Ma Vương phát huy toàn lực!"
			}
		},

		Abilities = {
			{
				Name = "Dark Bolt",
				Cooldown = 5,
				Damage = 400,
				Range = 60,
				Description = "Magic projectile"
			},
			{
				Name = "Soul Drain",
				Cooldown = 20,
				Damage = 600,
				Range = 40,
				Heal = 0.5, -- Heal 50% of damage dealt
				Description = "Lifesteal attack"
			},
			{
				Name = "Summon Minions",
				Cooldown = 30,
				MinionCount = 3,
				Description = "Summons 3 minions"
			}
		},

		LootTable = {
			GuaranteedDrops = {
				Gold = {Min = 5000, Max = 10000},
				TuVi = {Min = 10000, Max = 20000}
			},
			Items = {
				{ItemName = "Thiên Kiếm", Amount = 1, Chance = 0.2},
				{ItemName = "Thiên Giáp", Amount = 1, Chance = 0.2},
				{ItemName = "Thái Cổ Linh Đan", Amount = 2, Chance = 0.4},
				{ItemName = "Lôi Pháp", Amount = 1, Chance = 0.15},
				{ItemName = "Kim Cang Xá Lợi", Amount = 3, Chance = 0.6}
			}
		},

		SpawnLocation = "HuyenThienSon",
		RespawnTime = 600, -- 10 minutes

		ModelName = "ThienMonMaVuong",
		Size = Vector3.new(12, 12, 12),
		Color = Color3.fromRGB(100, 0, 200)
	},

	-- World Boss
	{
		BossID = "boss_thien_ma_de_ton",
		Name = "Thiên Ma Đế Tôn",
		Description = "Đế Vương của Ma Giới",
		Level = 27,
		Realm = 3,

		Stats = {
			HP = 100000,
			MagicDamage = 800,
			PhysicalDamage = 600,
			SoulDamage = 1000,
			Defense = 300,
			MagicDefense = 300,
			Speed = 25,
			CritRate = 0.20,
			CritDamage = 2.5,
			Lifesteal = 0.3
		},

		Phases = {
			{
				HPPercent = 0.90,
				Name = "Awakening",
				DamageMultiplier = 1.2,
				Message = "Thiên Ma Đế Tôn tỉnh giấc!"
			},
			{
				HPPercent = 0.75,
				Name = "Unleashed",
				DamageMultiplier = 1.5,
				Message = "Thiên Ma Đế Tôn giải phóng sức mạnh!"
			},
			{
				HPPercent = 0.50,
				Name = "True Power",
				DamageMultiplier = 2.0,
				SpeedMultiplier = 1.3,
				Message = "Thiên Ma Đế Tôn hiện nguyên hình!"
			},
			{
				HPPercent = 0.25,
				Name = "Apocalypse",
				DamageMultiplier = 3.0,
				SpeedMultiplier = 1.5,
				HPRegen = 500,
				Message = "Thiên Ma Đế Tôn khai Thiên Ma Diệt Thế!"
			}
		},

		Abilities = {
			{
				Name = "Void Blast",
				Cooldown = 8,
				Damage = 1500,
				Range = 80,
				Description = "Massive AOE"
			},
			{
				Name = "Death Ray",
				Cooldown = 15,
				Damage = 2500,
				Range = 100,
				Description = "Line attack"
			},
			{
				Name = "Summon Army",
				Cooldown = 45,
				MinionCount = 10,
				Description = "Summons demon army"
			},
			{
				Name = "Meteor Storm",
				Cooldown = 60,
				Damage = 3000,
				Range = 150,
				Duration = 10,
				Description = "Rain of meteors"
			}
		},

		LootTable = {
			GuaranteedDrops = {
				Gold = {Min = 50000, Max = 100000},
				TuVi = {Min = 100000, Max = 200000}
			},
			Items = {
				{ItemName = "Thiên Kiếm", Amount = 1, Chance = 0.8},
				{ItemName = "Thiên Giáp", Amount = 1, Chance = 0.8},
				{ItemName = "Thái Cổ Linh Đan", Amount = 10, Chance = 1.0},
				{ItemName = "Lôi Pháp", Amount = 1, Chance = 0.5},
				{ItemName = "Kim Cang Xá Lợi", Amount = 10, Chance = 1.0},
				{ItemName = "Huyền Vận Nhẫn", Amount = 1, Chance = 0.3}
			}
		},

		SpawnLocation = "WorldBossArea",
		RespawnTime = 3600, -- 1 hour
		IsWorldBoss = true, -- Announced to all players

		ModelName = "ThienMaDeTon",
		Size = Vector3.new(20, 20, 20),
		Color = Color3.fromRGB(255, 0, 0)
	}
}

-- ========================================
-- GET BOSS BY ID
-- ========================================

function BossModule.GetBoss(bossID)
	for _, boss in ipairs(BossModule.Bosses) do
		if boss.BossID == bossID then
			-- Return a copy
			local bossCopy = {}
			for k, v in pairs(boss) do
				bossCopy[k] = v
			end
			return bossCopy
		end
	end
	return nil
end

-- ========================================
-- GET BOSSES BY LOCATION
-- ========================================

function BossModule.GetBossesByLocation(locationName)
	local bosses = {}
	for _, boss in ipairs(BossModule.Bosses) do
		if boss.SpawnLocation == locationName then
			table.insert(bosses, boss)
		end
	end
	return bosses
end

-- ========================================
-- CALCULATE BOSS STATS (with phase)
-- ========================================

function BossModule.CalculatePhaseStats(boss, currentHP)
	local hpPercent = currentHP / boss.Stats.HP
	local activePhase = nil

	-- Find active phase
	for _, phase in ipairs(boss.Phases or {}) do
		if hpPercent <= phase.HPPercent then
			activePhase = phase
		end
	end

	if not activePhase then
		return boss.Stats
	end

	-- Apply phase multipliers
	local phaseStats = {}
	for stat, value in pairs(boss.Stats) do
		phaseStats[stat] = value
	end

	if activePhase.DamageMultiplier then
		phaseStats.MagicDamage = phaseStats.MagicDamage * activePhase.DamageMultiplier
		phaseStats.PhysicalDamage = phaseStats.PhysicalDamage * activePhase.DamageMultiplier
		phaseStats.SoulDamage = phaseStats.SoulDamage * activePhase.DamageMultiplier
	end

	if activePhase.SpeedMultiplier then
		phaseStats.Speed = phaseStats.Speed * activePhase.SpeedMultiplier
	end

	return phaseStats, activePhase
end

-- ========================================
-- GENERATE BOSS LOOT
-- ========================================

function BossModule.GenerateLoot(boss)
	local loot = {}
	local lootTable = boss.LootTable

	-- Guaranteed drops
	if lootTable.GuaranteedDrops then
		if lootTable.GuaranteedDrops.Gold then
			local gold = math.random(
				lootTable.GuaranteedDrops.Gold.Min,
				lootTable.GuaranteedDrops.Gold.Max
			)
			table.insert(loot, {
				Type = "Gold",
				Name = "Tiên Ngọc",
				Amount = gold
			})
		end

		if lootTable.GuaranteedDrops.TuVi then
			local tuvi = math.random(
				lootTable.GuaranteedDrops.TuVi.Min,
				lootTable.GuaranteedDrops.TuVi.Max
			)
			table.insert(loot, {
				Type = "TuVi",
				Name = "Tu Vi",
				Amount = tuvi
			})
		end
	end

	-- Item drops (with chance)
	if lootTable.Items then
		for _, itemDrop in ipairs(lootTable.Items) do
			if math.random() <= itemDrop.Chance then
				table.insert(loot, {
					Type = "Item",
					Name = itemDrop.ItemName,
					Amount = itemDrop.Amount
				})
			end
		end
	end

	return loot
end

print("✅ BossModule loaded")
return BossModule
