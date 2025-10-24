-- EnemyTemplate.lua - Template Quái cho tất cả Realms
-- Copy vào ReplicatedStorage/Modules/Combat/EnemyTemplate (ModuleScript)

local EnemyTemplate = {}

-- ========================================
-- MAP 1: RỪNG LINH THÚ (Newbie Area)
-- For Ngưng Khí 1-3 / Cổ Thần 1-3 Sao / Ma Đạo 1-3 Tinh
-- ========================================

EnemyTemplate.RungLinhThu = {
	-- Level 1
	{
		Name = "Thỏ Linh",
		Level = 1,
		Model = "Rabbit",
		Color = Color3.fromRGB(255, 200, 150),
		Size = Vector3.new(1.5, 1, 2),

		Stats = {
			MaxHP = 300,
			HP = 300,
			PhysicalDamage = 25,
			Defense = 15,
			Speed = 25,
			AttackRange = 5,
			DetectionRange = 15,
			AttackCooldown = 2
		},

		Drops = {
			TuKhiDan = {chance = 0.3, min = 1, max = 2},
			TheTuDan = {chance = 0.3, min = 1, max = 2},
			MaDaoDan = {chance = 0.3, min = 1, max = 2},
			TienNgoc = {chance = 0.5, min = 2, max = 5},
			PhamNhanLinhHon = {chance = 0.8, min = 1, max = 3} -- For Ma Đạo
		},

		ExpReward = 50
	},

	-- Level 2
	{
		Name = "Sói Rừng",
		Level = 2,
		Model = "Wolf",
		Color = Color3.fromRGB(100, 100, 100),
		Size = Vector3.new(2, 1.5, 3),

		Stats = {
			MaxHP = 500,
			HP = 500,
			PhysicalDamage = 40,
			Defense = 25,
			Speed = 30,
			AttackRange = 6,
			DetectionRange = 20,
			AttackCooldown = 1.8
		},

		Drops = {
			TuKhiDan = {chance = 0.4, min = 1, max = 3},
			TheTuDan = {chance = 0.4, min = 1, max = 3},
			MaDaoDan = {chance = 0.4, min = 1, max = 3},
			TienNgoc = {chance = 0.6, min = 5, max = 10},
			ThuCot = {chance = 0.5, min = 1, max = 2},
			PhamNhanLinhHon = {chance = 0.9, min = 2, max = 5}
		},

		ExpReward = 100
	},

	-- Level 3 - Mini Boss
	{
		Name = "Hổ Linh - Chúa Rừng",
		Level = 3,
		Model = "Tiger",
		Color = Color3.fromRGB(255, 140, 0),
		Size = Vector3.new(3, 2, 4),
		IsBoss = true,

		Stats = {
			MaxHP = 1200,
			HP = 1200,
			PhysicalDamage = 80,
			Defense = 40,
			Speed = 35,
			AttackRange = 8,
			DetectionRange = 30,
			AttackCooldown = 1.5
		},

		Drops = {
			TuKhiDan = {chance = 0.8, min = 3, max = 5},
			TheTuDan = {chance = 0.8, min = 3, max = 5},
			MaDaoDan = {chance = 0.8, min = 3, max = 5},
			TieuHoanDan = {chance = 0.6, min = 1, max = 2},
			TienNgoc = {chance = 1, min = 20, max = 50},
			ThuCot = {chance = 0.8, min = 3, max = 5},
			CoThanHuyet = {chance = 0.5, min = 1, max = 2},
			TuSiLinhHon = {chance = 0.9, min = 2, max = 5}
		},

		ExpReward = 300
	}
}

-- ========================================
-- MAP 2: HUYỀN THIÊN SƠN (Mid Area)
-- For Trúc Cơ 1-3 / Cổ Ma 1-3 Sao / Ma Tôn 1-3 Tinh
-- ========================================

EnemyTemplate.HuyenThienSon = {
	-- Level 1
	{
		Name = "Yêu Hồ Nhỏ",
		Level = 1,
		Realm = "Trúc Cơ", -- Equivalent
		Model = "Fox",
		Color = Color3.fromRGB(255, 150, 200),
		Size = Vector3.new(2, 1.5, 3),

		Stats = {
			MaxHP = 4000,
			HP = 4000,
			MagicDamage = 400,
			Defense = 200,
			Speed = 30,
			AttackRange = 20,
			DetectionRange = 30,
			AttackCooldown = 3
		},

		Drops = {
			TrucCoDan = {chance = 0.4, min = 1, max = 3},
			CoMaDan = {chance = 0.4, min = 1, max = 3},
			MaTonDan = {chance = 0.4, min = 1, max = 3},
			TienNgoc = {chance = 0.8, min = 20, max = 50},
			VanNienLinhDuoc = {chance = 0.5, min = 1, max = 2},
			KimCangXaLoi = {chance = 0.5, min = 1, max = 2},
			TuSiLinhHon = {chance = 0.9, min = 5, max = 10},
			CaoThuLinhHon = {chance = 0.5, min = 1, max = 3}
		},

		ExpReward = 500
	},

	-- Level 2
	{
		Name = "Kiếm Tu Lãng Khách",
		Level = 2,
		Realm = "Trúc Cơ",
		Model = "Swordsman",
		Color = Color3.fromRGB(100, 150, 200),
		Size = Vector3.new(2, 3, 2),

		Stats = {
			MaxHP = 6000,
			HP = 6000,
			PhysicalDamage = 600,
			Defense = 300,
			Speed = 35,
			AttackRange = 10,
			DetectionRange = 40,
			AttackCooldown = 2
		},

		Drops = {
			TrucCoDan = {chance = 0.5, min = 2, max = 4},
			CoMaDan = {chance = 0.5, min = 2, max = 4},
			MaTonDan = {chance = 0.5, min = 2, max = 4},
			TienNgoc = {chance = 0.9, min = 50, max = 100},
			ThienLinhDan = {chance = 0.4, min = 1, max = 2},
			KimCangXaLoi = {chance = 0.6, min = 2, max = 4},
			CaoThuLinhHon = {chance = 0.8, min = 2, max = 5}
		},

		ExpReward = 1000
	},

	-- Level 3 - Boss
	{
		Name = "Ma Đầu Huyền Thiên",
		Level = 3,
		Realm = "Trúc Cơ",
		Model = "Demon",
		Color = Color3.fromRGB(150, 0, 0),
		Size = Vector3.new(4, 5, 4),
		IsBoss = true,

		Stats = {
			MaxHP = 12000,
			HP = 12000,
			SoulDamage = 800,
			Defense = 400,
			Speed = 40,
			AttackRange = 25,
			DetectionRange = 50,
			AttackCooldown = 2.5
		},

		Drops = {
			TrucCoDan = {chance = 1, min = 5, max = 10},
			CoMaDan = {chance = 1, min = 5, max = 10},
			MaTonDan = {chance = 1, min = 5, max = 10},
			DaiHoanDan = {chance = 0.8, min = 2, max = 5},
			TienNgoc = {chance = 1, min = 200, max = 500},
			ThienLinhDan = {chance = 0.8, min = 3, max = 6},
			ThaiCoHuyet = {chance = 0.7, min = 2, max = 4},
			CaoThuLinhHon = {chance = 1, min = 10, max = 20},
			BossLinhHon = {chance = 0.9, min = 1, max = 3}
		},

		ExpReward = 3000
	}
}

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

-- Create enemy instance from template
function EnemyTemplate.CreateEnemy(templateData, spawnPosition)
	local enemy = {
		Name = templateData.Name,
		Level = templateData.Level,
		Realm = templateData.Realm or "Ngưng Khí",
		IsBoss = templateData.IsBoss or false,

		Stats = {},
		Drops = templateData.Drops,
		ExpReward = templateData.ExpReward,

		-- Runtime data
		Target = nil,
		LastAttackTime = 0,
		State = "Idle", -- Idle, Chasing, Attacking, Dead
		SpawnPosition = spawnPosition
	}

	-- Copy stats
	for key, value in pairs(templateData.Stats) do
		enemy.Stats[key] = value
	end

	return enemy
end

print("✅ EnemyTemplate loaded (Full System)")
return EnemyTemplate
