-- PlayerDataTemplate.lua - Template Dữ Liệu Player
-- Copy vào ReplicatedStorage/Modules/PlayerData/PlayerDataTemplate (ModuleScript)

local Constants = require(game.ReplicatedStorage.Data.Constants)

local PlayerDataTemplate = {}

function PlayerDataTemplate.CreateNew(cultivationType)
	cultivationType = cultivationType or Constants.CultivationType.TIEN_THIEN

	-- Get realm names for this cultivation type
	local realmNames = Constants.RealmNames[cultivationType]

	local data = {
		-- ========================================
		-- THÔNG TIN CƠ BẢN
		-- ========================================
		UserId = 0,
		DisplayName = "",
		CultivationType = cultivationType,
		TuViPoints = 0, -- Điểm Tu Vi hiện tại

		-- ========================================
		-- CẢNH GIỚI (Realms)
		-- ========================================
		CurrentRealm = 1,  -- Đang ở Cảnh Giới nào (1, 2, 3)
		CurrentLevel = 1,  -- Đang ở Tầng/Sao/Tinh nào (1-9)

		Realms = {
			Realm1 = {
				Name = realmNames.Realm1,
				Level = 1,
				Locked = false
			},
			Realm2 = {
				Name = realmNames.Realm2,
				Level = 0,
				Locked = true
			},
			Realm3 = {
				Name = realmNames.Realm3,
				Level = 0,
				Locked = true
			}
		},

		-- ========================================
		-- STATS (Tự động tính từ Realm)
		-- ========================================
		Stats = {
			HP = 500,
			MaxHP = 500,
			MP = 600,
			MaxMP = 600,
			MagicDamage = 0,
			PhysicalDamage = 0,
			SoulDamage = 0,
			Defense = 30,
			MagicDefense = 40,
			Speed = 20,
			CritRate = 0.05,
			CritDamage = 1.5,
			Lifesteal = 0
		},

		-- ========================================
		-- ĐAN DƯỢC & TÀI NGUYÊN (Inventory)
		-- ========================================
		DanDuoc = {
			-- Currency
			TienNgoc = 0,

			-- Tiên Thiên Pills
			TuKhiDan = 0,
			TieuHoanDan = 0,
			DaiHoanDan = 0,
			TrucCoDan = 0,
			VanNienLinhDuoc = 0,
			ThienLinhDan = 0,
			KimDan = 0,
			TienLinhDan = 0,
			ThaiCoLinhDan = 0,

			-- Cổ Thần Pills
			TheTuDan = 0,
			ThuCot = 0,
			CoThanHuyet = 0,
			KimCangXaLoi = 0,
			CoMaDan = 0,
			ThaiCoHuyet = 0,
			CoTonLinhDan = 0,
			CoTonThanCach = 0,
			ChiTonLinhDuoc = 0,

			-- Ma Đạo Pills & Souls
			MaDaoDan = 0,
			PhamNhanLinhHon = 0,  -- Phàm Nhân Linh Hồn
			TuSiLinhHon = 0,      -- Tu Sĩ Linh Hồn
			YeuThuLinhHon = 0,    -- Yêu Thú Linh Hồn
			CaoThuLinhHon = 0,    -- Cao Thủ Linh Hồn
			BossLinhHon = 0,      -- Boss Linh Hồn
			TienNhanLinhHon = 0,  -- Tiên Nhân Linh Hồn
			MaTonDan = 0,
			MaHoangLinhDan = 0,
			MaToLinhDuoc = 0,

			-- Special Items
			HonPhienHaPham = 0,        -- Hồn Phiên Hạ Phẩm
			HonPhienTrungPham = 0,     -- Hồn Phiên Trung Phẩm
			VanHonPhanTrungPham = 0,   -- Vạn Hồn Phan Trung Phẩm
			VanHonPhanThuongPham = 0   -- Vạn Hồn Phan Thượng Phẩm
		},

		-- ========================================
		-- HỒN PHIÊN (Chỉ cho Ma Đạo)
		-- ========================================
		HonPhien = {
			Equipped = false,          -- Có trang bị Hồn Phiên không
			Tier = "HaPham",          -- HaPham, TrungPham, ThuongPham, VanHon, DieTThe
			CurrentSouls = 0,         -- Số linh hồn hiện tại
			MaxSouls = 10,            -- Sức chứa tối đa
			TotalKills = 0            -- Tổng số sinh linh đã giết
		},

		-- ========================================
		-- CÔNG PHÁP (Skills/Techniques)
		-- ========================================
		Skills = {
			-- Sẽ thêm khi học skill
			-- Format: {Name = "SkillName", Level = 1, Unlocked = true}
		},

		-- ========================================
		-- SÁT KHÍ (Slaughter Count - for Ma Đạo)
		-- ========================================
		SatKhi = 0, -- Số lần giết sinh linh
		Reputation = "Neutral", -- Neutral, Evil, Demonic

		-- ========================================
		-- BREAKTHROUGH HISTORY
		-- ========================================
		BreakthroughHistory = {
			-- Lưu lại lịch sử đột phá
			-- {Realm = "NgungKhi", Level = 9, Time = tick()}
		}
	}

	return data
end

print("✅ PlayerDataTemplate loaded (Full System)")
return PlayerDataTemplate
