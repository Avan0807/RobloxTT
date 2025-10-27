-- WeaponConfig.lua - Mapping giữa Tu Luyện Paths và Weapon Types

local WeaponConfig = {}

-- ========================================
-- PATH → WEAPON TYPE MAPPING
-- ========================================

WeaponConfig.PathWeaponMapping = {
	TienThien = "Sword",  -- Tiên Thiên = Kiếm
	CoThan = "Fist",      -- Cổ Thần = Đấm tay
	MaDao = "Flag"        -- Ma Đạo = Cờ
}

-- ========================================
-- BASE WEAPONS (Starter weapons for each path)
-- ========================================

WeaponConfig.BaseWeapons = {
	-- Cổ Thần - Đấm tay
	CoThan = {
		Name = "Phàm Thể Quyền",
		Type = "Fist",
		Rarity = "Common",
		Damage = 80,
		AttackSpeed = 2.0,
		Range = 5,
		Description = "Đấm tay cơ bản cho Cổ Thần tu sĩ",
		Icon = "rbxassetid://0", -- TODO: Add icon

		-- Stats scaling với realm
		Scaling = {
			TuVi = 0.15,  -- Cổ Thần focus vào thể chất
			Realm = 0.25
		}
	},

	-- Tiên Thiên - Kiếm
	TienThien = {
		Name = "Phàm Kiếm",
		Type = "Sword",
		Rarity = "Common",
		Damage = 100,
		AttackSpeed = 1.5,
		Range = 8,
		Description = "Thanh kiếm cơ bản cho Tiên Thiên tu sĩ",
		Icon = "rbxassetid://0",

		Scaling = {
			TuVi = 0.12,
			Realm = 0.2
		}
	},

	-- Ma Đạo - Cờ
	MaDao = {
		Name = "Ma Đạo Cờ",
		Type = "Flag",
		Rarity = "Common",
		Damage = 90,
		AttackSpeed = 1.0,
		Range = 12,
		Description = "Cờ chiến cơ bản cho Ma Đạo tu sĩ",
		Icon = "rbxassetid://0",

		Scaling = {
			TuVi = 0.1,
			Realm = 0.18
		}
	}
}

-- ========================================
-- WEAPON TIERS (Theo realm progression)
-- ========================================

WeaponConfig.WeaponTiers = {
	-- Cổ Thần (Fist weapons)
	CoThan = {
		-- Tier 1: Cảnh 1 (Cổ Thần 1-9 Sao)
		{
			MinRealm = 1,
			MaxRealm = 9,
			Weapons = {
				"Phàm Thể Quyền",    -- Base weapon
				-- TODO: Thêm weapons sau
			}
		},
		-- Tier 2: Cảnh 2 (Cổ Ma 1-9 Sao)
		{
			MinRealm = 10,
			MaxRealm = 18,
			Weapons = {
				-- TODO: Thêm weapons cao cấp hơn
			}
		},
		-- Tier 3: Cảnh 3 (Cổ Tôn 1-9 Sao)
		{
			MinRealm = 19,
			MaxRealm = 27,
			Weapons = {
				-- TODO: Thêm legendary weapons
			}
		}
	},

	-- Tiên Thiên (Sword weapons)
	TienThien = {
		{
			MinRealm = 1,
			MaxRealm = 9,
			Weapons = {
				"Phàm Kiếm",
				-- TODO: Thêm swords
			}
		},
		{
			MinRealm = 10,
			MaxRealm = 18,
			Weapons = {
				-- TODO: Linh Kiếm, etc.
			}
		},
		{
			MinRealm = 19,
			MaxRealm = 27,
			Weapons = {
				-- TODO: Thiên Kiếm, etc.
			}
		}
	},

	-- Ma Đạo (Flag weapons)
	MaDao = {
		{
			MinRealm = 1,
			MaxRealm = 9,
			Weapons = {
				"Ma Đạo Cờ",
				-- TODO: Thêm flags
			}
		},
		{
			MinRealm = 10,
			MaxRealm = 18,
			Weapons = {
				-- TODO: Hồn Cờ, etc.
			}
		},
		{
			MinRealm = 19,
			MaxRealm = 27,
			Weapons = {
				-- TODO: Ma Hoàng Cờ, etc.
			}
		}
	}
}

-- ========================================
-- GET WEAPON TYPE BY PATH
-- ========================================

function WeaponConfig.GetWeaponType(path)
	return WeaponConfig.PathWeaponMapping[path]
end

-- ========================================
-- GET BASE WEAPON FOR PATH
-- ========================================

function WeaponConfig.GetBaseWeapon(path)
	return WeaponConfig.BaseWeapons[path]
end

-- ========================================
-- GET AVAILABLE WEAPONS FOR REALM
-- ========================================

function WeaponConfig.GetWeaponsForRealm(path, realmLevel)
	local tiers = WeaponConfig.WeaponTiers[path]
	if not tiers then return {} end

	local availableWeapons = {}

	for _, tier in ipairs(tiers) do
		if realmLevel >= tier.MinRealm and realmLevel <= tier.MaxRealm then
			-- Current tier weapons
			for _, weaponName in ipairs(tier.Weapons) do
				table.insert(availableWeapons, weaponName)
			end
		elseif realmLevel > tier.MaxRealm then
			-- Can also use lower tier weapons
			for _, weaponName in ipairs(tier.Weapons) do
				table.insert(availableWeapons, weaponName)
			end
		end
	end

	return availableWeapons
end

-- ========================================
-- PATH DESCRIPTIONS
-- ========================================

WeaponConfig.PathDescriptions = {
	CoThan = {
		Name = "Cổ Thần",
		WeaponType = "Đấm Tay",
		Description = "Tu luyện thể chất, sức mạnh vật lý tuyệt đối",
		Style = "Cận chiến, tốc độ nhanh, combo mạnh",
		Color = Color3.fromRGB(200, 150, 100) -- Vàng đất
	},

	TienThien = {
		Name = "Tiên Thiên",
		WeaponType = "Kiếm",
		Description = "Tu luyện pháp lực, sử dụng nguyên tố thiên nhiên",
		Style = "Trung cự, slash damage, elemental effects",
		Color = Color3.fromRGB(100, 200, 255) -- Xanh dương
	},

	MaDao = {
		Name = "Ma Đạo",
		WeaponType = "Cờ",
		Description = "Tu luyện hồn phách, hấp thụ sinh lực",
		Style = "Xa-trung cự, AOE damage, lifesteal",
		Color = Color3.fromRGB(150, 0, 100) -- Tím đen
	}
}

-- ========================================
-- VALIDATE PATH
-- ========================================

function WeaponConfig.IsValidPath(path)
	return WeaponConfig.PathWeaponMapping[path] ~= nil
end

print("✅ WeaponConfig loaded")
return WeaponConfig
