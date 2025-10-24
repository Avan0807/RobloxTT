-- Constants.lua - Hệ Thống Tu Luyện Hoàn Chỉnh
-- Copy vào ReplicatedStorage/Data/Constants (ModuleScript)

local Constants = {}

-- ========================================
-- 3 HỆ TU LUYỆN
-- ========================================

Constants.CultivationType = {
	TIEN_THIEN = "TienThien", -- Tu Linh Lực (Magic)
	CO_THAN = "CoThan",        -- Tu Thể Chất (Physical)
	MA_DAO = "MaDao"           -- Tu Hồn Phiên (Soul/Dark)
}

-- ========================================
-- REALM NAMES (Tên Cảnh Giới)
-- ========================================

Constants.RealmNames = {
	-- Tiên Thiên
	TienThien = {
		Realm1 = "NgungKhi",   -- Ngưng Khí (Tầng 1-9)
		Realm2 = "TrucCo",     -- Trúc Cơ (Tầng 1-9)
		Realm3 = "NguyenAnh"   -- Nguyên Anh (Tầng 1-9)
	},

	-- Cổ Thần
	CoThan = {
		Realm1 = "CoThan",     -- Cổ Thần (1-9 Sao)
		Realm2 = "CoMa",       -- Cổ Ma (1-9 Sao)
		Realm3 = "CoTon"       -- Cổ Tôn (1-9 Sao)
	},

	-- Ma Đạo
	MaDao = {
		Realm1 = "MaDao",      -- Ma Đạo (1-9 Tinh)
		Realm2 = "MaTon",      -- Ma Tôn (1-9 Tinh)
		Realm3 = "MaHoang"     -- Ma Hoàng (1-9 Tinh)
	}
}

-- ========================================
-- BASE STATS (Level 1 của mỗi hệ)
-- ========================================

Constants.BaseStats = {
	TienThien = {
		HP = 500,
		MP = 600,
		MagicDamage = 50,
		PhysicalDamage = 0,
		SoulDamage = 0,
		Defense = 30,
		MagicDefense = 40,
		Speed = 20,
		CritRate = 0.05,
		CritDamage = 1.5,
		Lifesteal = 0
	},

	CoThan = {
		HP = 800,
		MP = 0,
		MagicDamage = 0,
		PhysicalDamage = 80,
		SoulDamage = 0,
		Defense = 60,
		MagicDefense = 30,
		Speed = 12,
		CritRate = 0.03,
		CritDamage = 1.3,
		Lifesteal = 0
	},

	MaDao = {
		HP = 550,
		MP = 400,
		MagicDamage = 0,
		PhysicalDamage = 0,
		SoulDamage = 75,
		Defense = 35,
		MagicDefense = 35,
		Speed = 16,
		CritRate = 0.06,
		CritDamage = 1.6,
		Lifesteal = 0.5
	}
}

-- ========================================
-- STAT MULTIPLIERS (Nhân Chỉ Số)
-- ========================================

-- Tiên Thiên Multipliers (9 levels per realm, 3 realms)
Constants.TienThienMultipliers = {
	-- Realm 1: Ngưng Khí (Tầng 1-9)
	NgungKhi = {1.0, 1.2, 1.4, 1.7, 2.0, 2.4, 2.8, 3.3, 4.0},

	-- Realm 2: Trúc Cơ (Tầng 1-9)
	TrucCo = {8.0, 10.0, 12.5, 15.5, 19.0, 23.5, 29.0, 35.5, 43.0},

	-- Realm 3: Nguyên Anh (Tầng 1-9)
	NguyenAnh = {86.0, 110.0, 140.0, 180.0, 230.0, 290.0, 370.0, 470.0, 600.0}
}

-- Cổ Thần Multipliers
Constants.CoThanMultipliers = {
	-- Realm 1: Cổ Thần (1-9 Sao)
	CoThan = {1.0, 1.3, 1.6, 2.0, 2.5, 3.1, 3.8, 4.7, 6.0},

	-- Realm 2: Cổ Ma (1-9 Sao)
	CoMa = {12.0, 15.5, 20.0, 26.0, 33.5, 43.0, 55.0, 70.0, 90.0},

	-- Realm 3: Cổ Tôn (1-9 Sao)
	CoTon = {180.0, 235.0, 305.0, 395.0, 510.0, 660.0, 850.0, 1100.0, 1400.0}
}

-- Ma Đạo Multipliers
Constants.MaDaoMultipliers = {
	-- Realm 1: Ma Đạo (1-9 Tinh)
	MaDao = {1.0, 1.25, 1.5, 1.8, 2.2, 2.7, 3.3, 4.1, 5.0},

	-- Realm 2: Ma Tôn (1-9 Tinh)
	MaTon = {10.0, 13.0, 17.0, 22.0, 28.5, 37.0, 48.0, 62.0, 80.0},

	-- Realm 3: Ma Hoàng (1-9 Tinh)
	MaHoang = {160.0, 210.0, 275.0, 360.0, 470.0, 610.0, 790.0, 1020.0, 1300.0}
}

-- ========================================
-- TU VI POINTS REQUIREMENTS (Điểm Tu Vi)
-- ========================================

-- Nâng cấp trong cùng realm (1→2, 2→3, ...)
Constants.TuViPerLevel = {
	1000,   -- Level 1→2
	2500,   -- Level 2→3
	5000,   -- Level 3→4
	8000,   -- Level 4→5
	12000,  -- Level 5→6
	18000,  -- Level 6→7
	25000,  -- Level 7→8
	35000   -- Level 8→9
}

-- Đột phá sang realm mới (Realm 1→2, 2→3)
Constants.TuViBreakthrough = {
	100000,  -- Realm 1 → Realm 2
	500000   -- Realm 2 → Realm 3
}

-- ========================================
-- ĐAN DƯỢC REQUIREMENTS (Pills & Materials)
-- ========================================

-- Tiên Thiên Pills
Constants.TienThienPills = {
	-- Ngưng Khí (Tầng 1→9)
	NgungKhi = {
		{TuKhiDan = 10},
		{TuKhiDan = 25},
		{TuKhiDan = 50},
		{TuKhiDan = 80, TieuHoanDan = 10},
		{TuKhiDan = 120, TieuHoanDan = 20},
		{TuKhiDan = 180, TieuHoanDan = 35},
		{TuKhiDan = 250, TieuHoanDan = 50, DaiHoanDan = 5},
		{TuKhiDan = 350, TieuHoanDan = 80, DaiHoanDan = 10}
	},

	-- Trúc Cơ (Tầng 1→9)
	TrucCo = {
		{TrucCoDan = 50, TienNgoc = 100},
		{TrucCoDan = 80, TienNgoc = 200},
		{TrucCoDan = 120, TienNgoc = 350},
		{TrucCoDan = 180, TienNgoc = 500, VanNienLinhDuoc = 10},
		{TrucCoDan = 250, TienNgoc = 800, VanNienLinhDuoc = 20},
		{TrucCoDan = 350, TienNgoc = 1200, VanNienLinhDuoc = 35},
		{TrucCoDan = 500, TienNgoc = 1800, VanNienLinhDuoc = 50, ThienLinhDan = 5},
		{TrucCoDan = 700, TienNgoc = 2500, VanNienLinhDuoc = 80, ThienLinhDan = 10}
	},

	-- Nguyên Anh (Tầng 1→9)
	NguyenAnh = {
		{KimDan = 100, TienNgoc = 3000, ThienLinhDan = 50},
		{KimDan = 150, TienNgoc = 5000, ThienLinhDan = 80},
		{KimDan = 220, TienNgoc = 8000, ThienLinhDan = 120, TienLinhDan = 10},
		{KimDan = 300, TienNgoc = 12000, ThienLinhDan = 180, TienLinhDan = 20},
		{KimDan = 400, TienNgoc = 18000, ThienLinhDan = 250, TienLinhDan = 35},
		{KimDan = 550, TienNgoc = 25000, ThienLinhDan = 350, TienLinhDan = 50, ThaiCoLinhDan = 5},
		{KimDan = 750, TienNgoc = 35000, ThienLinhDan = 500, TienLinhDan = 80, ThaiCoLinhDan = 10},
		{KimDan = 1000, TienNgoc = 50000, ThienLinhDan = 700, TienLinhDan = 120, ThaiCoLinhDan = 20}
	}
}

-- Cổ Thần Pills
Constants.CoThanPills = {
	-- Cổ Thần (1→9 Sao)
	CoThan = {
		{TheTuDan = 15, ThuCot = 20},
		{TheTuDan = 30, ThuCot = 40},
		{TheTuDan = 60, ThuCot = 80, CoThanHuyet = 10},
		{TheTuDan = 100, ThuCot = 150, CoThanHuyet = 25},
		{TheTuDan = 150, ThuCot = 250, CoThanHuyet = 50},
		{TheTuDan = 220, ThuCot = 400, CoThanHuyet = 80, KimCangXaLoi = 5},
		{TheTuDan = 320, ThuCot = 600, CoThanHuyet = 120, KimCangXaLoi = 10},
		{TheTuDan = 450, ThuCot = 900, CoThanHuyet = 180, KimCangXaLoi = 20}
	},

	-- Cổ Ma (1→9 Sao)
	CoMa = {
		{CoMaDan = 80, TienNgoc = 200, KimCangXaLoi = 30},
		{CoMaDan = 120, TienNgoc = 350, KimCangXaLoi = 50},
		{CoMaDan = 180, TienNgoc = 550, KimCangXaLoi = 80, ThaiCoHuyet = 10},
		{CoMaDan = 260, TienNgoc = 850, KimCangXaLoi = 120, ThaiCoHuyet = 20},
		{CoMaDan = 370, TienNgoc = 1300, KimCangXaLoi = 180, ThaiCoHuyet = 35},
		{CoMaDan = 520, TienNgoc = 2000, KimCangXaLoi = 260, ThaiCoHuyet = 55, CoTonLinhDan = 5},
		{CoMaDan = 730, TienNgoc = 3000, KimCangXaLoi = 370, ThaiCoHuyet = 85, CoTonLinhDan = 10},
		{CoMaDan = 1000, TienNgoc = 4500, KimCangXaLoi = 530, ThaiCoHuyet = 130, CoTonLinhDan = 18}
	},

	-- Cổ Tôn (1→9 Sao)
	CoTon = {
		{CoTonLinhDan = 150, TienNgoc = 6000, CoTonThanCach = 100},
		{CoTonLinhDan = 220, TienNgoc = 10000, CoTonThanCach = 160},
		{CoTonLinhDan = 320, TienNgoc = 16000, CoTonThanCach = 250, ThaiCoLinhDan = 15},
		{CoTonLinhDan = 450, TienNgoc = 25000, CoTonThanCach = 380, ThaiCoLinhDan = 25},
		{CoTonLinhDan = 630, TienNgoc = 38000, CoTonThanCach = 550, ThaiCoLinhDan = 40},
		{CoTonLinhDan = 880, TienNgoc = 55000, CoTonThanCach = 780, ThaiCoLinhDan = 65, ChiTonLinhDuoc = 10},
		{CoTonLinhDan = 1200, TienNgoc = 80000, CoTonThanCach = 1100, ThaiCoLinhDan = 100, ChiTonLinhDuoc = 18},
		{CoTonLinhDan = 1600, TienNgoc = 120000, CoTonThanCach = 1500, ThaiCoLinhDan = 150, ChiTonLinhDuoc = 30}
	}
}

-- Ma Đạo Pills
Constants.MaDaoPills = {
	-- Ma Đạo (1→9 Tinh)
	MaDao = {
		{MaDaoDan = 12, PhamNhanLinhHon = 10},
		{MaDaoDan = 28, PhamNhanLinhHon = 25},
		{MaDaoDan = 55, PhamNhanLinhHon = 50, TuSiLinhHon = 5},
		{MaDaoDan = 90, PhamNhanLinhHon = 100, TuSiLinhHon = 15},
		{MaDaoDan = 140, PhamNhanLinhHon = 200, TuSiLinhHon = 30},
		{MaDaoDan = 200, PhamNhanLinhHon = 400, TuSiLinhHon = 50, HonPhienHaPham = 1},
		{MaDaoDan = 290, PhamNhanLinhHon = 700, TuSiLinhHon = 80, YeuThuLinhHon = 5},
		{MaDaoDan = 400, PhamNhanLinhHon = 1200, TuSiLinhHon = 120, YeuThuLinhHon = 15}
	},

	-- Ma Tôn (1→9 Tinh)
	MaTon = {
		{MaTonDan = 70, TienNgoc = 180, TuSiLinhHon = 200, CaoThuLinhHon = 20},
		{MaTonDan = 110, TienNgoc = 320, TuSiLinhHon = 400, CaoThuLinhHon = 40},
		{MaTonDan = 160, TienNgoc = 520, TuSiLinhHon = 700, CaoThuLinhHon = 70, BossLinhHon = 5},
		{MaTonDan = 240, TienNgoc = 800, TuSiLinhHon = 1100, CaoThuLinhHon = 110, BossLinhHon = 12},
		{MaTonDan = 340, TienNgoc = 1250, TuSiLinhHon = 1700, CaoThuLinhHon = 170, BossLinhHon = 22},
		{MaTonDan = 480, TienNgoc = 1900, TuSiLinhHon = 2600, CaoThuLinhHon = 260, BossLinhHon = 38, VanHonPhanTrungPham = 1},
		{MaTonDan = 670, TienNgoc = 2800, TuSiLinhHon = 3900, CaoThuLinhHon = 390, BossLinhHon = 60},
		{MaTonDan = 920, TienNgoc = 4200, TuSiLinhHon = 5700, CaoThuLinhHon = 570, BossLinhHon = 95}
	},

	-- Ma Hoàng (1→9 Tinh)
	MaHoang = {
		{MaHoangLinhDan = 140, TienNgoc = 5500, CaoThuLinhHon = 800, BossLinhHon = 150, TienNhanLinhHon = 15},
		{MaHoangLinhDan = 200, TienNgoc = 9500, CaoThuLinhHon = 1300, BossLinhHon = 250, TienNhanLinhHon = 28},
		{MaHoangLinhDan = 290, TienNgoc = 15000, CaoThuLinhHon = 2000, BossLinhHon = 400, TienNhanLinhHon = 48, ThaiCoLinhDan = 12},
		{MaHoangLinhDan = 410, TienNgoc = 23000, CaoThuLinhHon = 3100, BossLinhHon = 610, TienNhanLinhHon = 78, ThaiCoLinhDan = 22},
		{MaHoangLinhDan = 580, TienNgoc = 35000, CaoThuLinhHon = 4600, BossLinhHon = 920, TienNhanLinhHon = 125, ThaiCoLinhDan = 35},
		{MaHoangLinhDan = 810, TienNgoc = 52000, CaoThuLinhHon = 6800, BossLinhHon = 1360, TienNhanLinhHon = 195, ThaiCoLinhDan = 55, MaToLinhDuoc = 8},
		{MaHoangLinhDan = 1100, TienNgoc = 75000, CaoThuLinhHon = 10000, BossLinhHon = 2000, TienNhanLinhHon = 300, ThaiCoLinhDan = 85, MaToLinhDuoc = 15},
		{MaHoangLinhDan = 1500, TienNgoc = 110000, CaoThuLinhHon = 14500, BossLinhHon = 2900, TienNhanLinhHon = 450, ThaiCoLinhDan = 130, MaToLinhDuoc = 25}
	}
}

-- ========================================
-- HỒN PHIÊN (Soul Banner for Ma Đạo)
-- ========================================

Constants.HonPhien = {
	-- Capacity for each level
	Capacity = {
		10,      -- 1 Tinh
		25,      -- 2 Tinh
		50,      -- 3 Tinh
		100,     -- 4 Tinh
		200,     -- 5 Tinh
		400,     -- 6 Tinh
		700,     -- 7 Tinh
		1200,    -- 8 Tinh
		2000     -- 9 Tinh (Ma Đạo)
	},

	-- Ma Tôn capacity
	VanHonPhanCapacity = {
		10000,   -- 1 Tinh
		15000,   -- 2 Tinh
		22000,   -- 3 Tinh
		32000,   -- 4 Tinh
		45000,   -- 5 Tinh
		65000,   -- 6 Tinh
		90000,   -- 7 Tinh
		130000,  -- 8 Tinh
		180000   -- 9 Tinh (Ma Tôn)
	},

	-- Ma Hoàng capacity
	DieTTheMaPhanCapacity = {
		1000000,   -- 1 Tinh
		1500000,   -- 2 Tinh
		2200000,   -- 3 Tinh
		3200000,   -- 4 Tinh
		4500000,   -- 5 Tinh
		6500000,   -- 6 Tinh
		9000000,   -- 7 Tinh
		13000000,  -- 8 Tinh
		18000000   -- 9 Tinh (Ma Hoàng)
	}
}

-- ========================================
-- COMBAT
-- ========================================

Constants.Combat = {
	BaseAttackRange = 10,
	BaseAttackCooldown = 1.5,
	DefenseFormula = 100,
}

-- Rock-Paper-Scissors
Constants.TypeAdvantage = {
	-- Cổ Thần > Ma Đạo
	CoThan_vs_MaDao = 1.3,

	-- Ma Đạo > Tiên Thiên
	MaDao_vs_TienThien = 1.3,

	-- Tiên Thiên > Cổ Thần
	TienThien_vs_CoThan = 1.3
}

print("✅ Constants loaded (Full System)")
return Constants
