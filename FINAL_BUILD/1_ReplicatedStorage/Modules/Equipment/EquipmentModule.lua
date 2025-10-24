-- EquipmentModule.lua - Hệ Thống Trang Bị
-- Copy vào ReplicatedStorage/Modules/Equipment/EquipmentModule (ModuleScript)

local EquipmentModule = {}

-- ========================================
-- EQUIPMENT SLOTS
-- ========================================

EquipmentModule.Slots = {
	WEAPON = "Weapon",       -- Vũ Khí
	ARMOR = "Armor",         -- Giáp
	HELMET = "Helmet",       -- Mũ
	BOOTS = "Boots",         -- Giày
	ACCESSORY1 = "Accessory1", -- Phụ kiện 1
	ACCESSORY2 = "Accessory2", -- Phụ kiện 2
	TALISMAN = "Talisman"    -- Pháp Bảo
}

-- ========================================
-- EQUIPMENT TYPES
-- ========================================

EquipmentModule.Type = {
	WEAPON = "Weapon",
	ARMOR = "Armor",
	HELMET = "Helmet",
	BOOTS = "Boots",
	ACCESSORY = "Accessory",
	TALISMAN = "Talisman"
}

-- ========================================
-- EQUIPMENT TIERS
-- ========================================

EquipmentModule.Tier = {
	MORTAL = {
		Name = "Phàm",
		Color = Color3.fromRGB(200, 200, 200),
		StatMultiplier = 1.0
	},
	SPIRITUAL = {
		Name = "Linh",
		Color = Color3.fromRGB(100, 255, 100),
		StatMultiplier = 1.5
	},
	EARTH = {
		Name = "Địa",
		Color = Color3.fromRGB(100, 150, 255),
		StatMultiplier = 2.0
	},
	HEAVEN = {
		Name = "Thiên",
		Color = Color3.fromRGB(200, 100, 255),
		StatMultiplier = 3.0
	},
	IMMORTAL = {
		Name = "Tiên",
		Color = Color3.fromRGB(255, 200, 0),
		StatMultiplier = 5.0
	},
	DIVINE = {
		Name = "Thần",
		Color = Color3.fromRGB(255, 50, 50),
		StatMultiplier = 8.0
	}
}

-- ========================================
-- WEAPON DEFINITIONS
-- ========================================

EquipmentModule.Weapons = {
	-- Tiên Thiên Weapons
	BasicSword = {
		Name = "Phàm Kiếm",
		Type = EquipmentModule.Type.WEAPON,
		Tier = EquipmentModule.Tier.MORTAL,
		Level = 1,
		CultivationType = "TienThien",
		Stats = {
			MagicDamage = 20,
			CritRate = 0.05
		},
		Description = "Thanh kiếm phàm trần",
		Icon = "rbxassetid://0"
	},

	SpiritSword = {
		Name = "Linh Kiếm",
		Type = EquipmentModule.Type.WEAPON,
		Tier = EquipmentModule.Tier.SPIRITUAL,
		Level = 5,
		CultivationType = "TienThien",
		Stats = {
			MagicDamage = 50,
			CritRate = 0.08,
			MP = 50
		},
		Description = "Kiếm được tẩm linh lực",
		Icon = "rbxassetid://0"
	},

	HeavenSword = {
		Name = "Thiên Kiếm",
		Type = EquipmentModule.Type.WEAPON,
		Tier = EquipmentModule.Tier.HEAVEN,
		Level = 15,
		CultivationType = "TienThien",
		Stats = {
			MagicDamage = 150,
			CritRate = 0.12,
			MP = 150,
			CritDamage = 0.5
		},
		Description = "Kiếm từ Thiên Giới",
		Icon = "rbxassetid://0"
	},

	-- Cổ Thần Weapons
	BasicGauntlet = {
		Name = "Phàm Quyền",
		Type = EquipmentModule.Type.WEAPON,
		Tier = EquipmentModule.Tier.MORTAL,
		Level = 1,
		CultivationType = "CoThan",
		Stats = {
			PhysicalDamage = 30,
			HP = 50
		},
		Description = "Quyền thủ phàm trần",
		Icon = "rbxassetid://0"
	},

	AncientGauntlet = {
		Name = "Cổ Thần Quyền",
		Type = EquipmentModule.Type.WEAPON,
		Tier = EquipmentModule.Tier.EARTH,
		Level = 10,
		CultivationType = "CoThan",
		Stats = {
			PhysicalDamage = 120,
			HP = 200,
			Defense = 30
		},
		Description = "Quyền của Cổ Thần",
		Icon = "rbxassetid://0"
	},

	-- Ma Đạo Weapons
	BasicStaff = {
		Name = "Ma Trượng",
		Type = EquipmentModule.Type.WEAPON,
		Tier = EquipmentModule.Tier.MORTAL,
		Level = 1,
		CultivationType = "MaDao",
		Stats = {
			SoulDamage = 25,
			Lifesteal = 0.1
		},
		Description = "Trượng ma đạo cơ bản",
		Icon = "rbxassetid://0"
	},

	DemonStaff = {
		Name = "Ma Hoàng Trượng",
		Type = EquipmentModule.Type.WEAPON,
		Tier = EquipmentModule.Tier.HEAVEN,
		Level = 15,
		CultivationType = "MaDao",
		Stats = {
			SoulDamage = 160,
			Lifesteal = 0.25,
			CritRate = 0.10
		},
		Description = "Trượng của Ma Hoàng",
		Icon = "rbxassetid://0"
	}
}

-- ========================================
-- ARMOR DEFINITIONS
-- ========================================

EquipmentModule.Armors = {
	-- Basic Armors
	BasicRobe = {
		Name = "Phàm Y",
		Type = EquipmentModule.Type.ARMOR,
		Tier = EquipmentModule.Tier.MORTAL,
		Level = 1,
		Stats = {
			HP = 100,
			Defense = 10,
			MagicDefense = 10
		},
		Description = "Áo giáp phàm trần",
		Icon = "rbxassetid://0"
	},

	SpiritRobe = {
		Name = "Linh Y",
		Type = EquipmentModule.Type.ARMOR,
		Tier = EquipmentModule.Tier.SPIRITUAL,
		Level = 5,
		Stats = {
			HP = 200,
			Defense = 25,
			MagicDefense = 25,
			Speed = 5
		},
		Description = "Pháp y linh lực",
		Icon = "rbxassetid://0"
	},

	HeavenArmor = {
		Name = "Thiên Giáp",
		Type = EquipmentModule.Type.ARMOR,
		Tier = EquipmentModule.Tier.HEAVEN,
		Level = 15,
		Stats = {
			HP = 500,
			Defense = 80,
			MagicDefense = 80,
			Speed = 10
		},
		Description = "Giáp từ Thiên Giới",
		Icon = "rbxassetid://0"
	}
}

-- ========================================
-- ACCESSORY DEFINITIONS
-- ========================================

EquipmentModule.Accessories = {
	LuckyRing = {
		Name = "Huyền Vận Nhẫn",
		Type = EquipmentModule.Type.ACCESSORY,
		Tier = EquipmentModule.Tier.SPIRITUAL,
		Level = 3,
		Stats = {
			CritRate = 0.10,
			CritDamage = 0.3
		},
		Description = "Nhẫn tăng may mắn",
		Icon = "rbxassetid://0"
	},

	VitalityAmulet = {
		Name = "Hộ Mệnh Bùa",
		Type = EquipmentModule.Type.ACCESSORY,
		Tier = EquipmentModule.Tier.EARTH,
		Level = 8,
		Stats = {
			HP = 300,
			Defense = 40,
			Lifesteal = 0.15
		},
		Description = "Bùa hộ mệnh",
		Icon = "rbxassetid://0"
	}
}

-- ========================================
-- TALISMAN DEFINITIONS
-- ========================================

EquipmentModule.Talismans = {
	ThunderTalisman = {
		Name = "Lôi Pháp",
		Type = EquipmentModule.Type.TALISMAN,
		Tier = EquipmentModule.Tier.HEAVEN,
		Level = 12,
		Stats = {
			MagicDamage = 100,
			MP = 100,
			Speed = 15
		},
		Description = "Pháp bảo sấm sét",
		Icon = "rbxassetid://0"
	}
}

-- ========================================
-- CREATE EQUIPMENT LOADOUT
-- ========================================

function EquipmentModule.CreateLoadout()
	return {
		[EquipmentModule.Slots.WEAPON] = nil,
		[EquipmentModule.Slots.ARMOR] = nil,
		[EquipmentModule.Slots.HELMET] = nil,
		[EquipmentModule.Slots.BOOTS] = nil,
		[EquipmentModule.Slots.ACCESSORY1] = nil,
		[EquipmentModule.Slots.ACCESSORY2] = nil,
		[EquipmentModule.Slots.TALISMAN] = nil
	}
end

-- ========================================
-- EQUIP ITEM
-- ========================================

function EquipmentModule.Equip(loadout, equipment)
	-- Determine slot based on equipment type
	local slot = nil

	if equipment.Type == EquipmentModule.Type.WEAPON then
		slot = EquipmentModule.Slots.WEAPON
	elseif equipment.Type == EquipmentModule.Type.ARMOR then
		slot = EquipmentModule.Slots.ARMOR
	elseif equipment.Type == EquipmentModule.Type.HELMET then
		slot = EquipmentModule.Slots.HELMET
	elseif equipment.Type == EquipmentModule.Type.BOOTS then
		slot = EquipmentModule.Slots.BOOTS
	elseif equipment.Type == EquipmentModule.Type.TALISMAN then
		slot = EquipmentModule.Slots.TALISMAN
	elseif equipment.Type == EquipmentModule.Type.ACCESSORY then
		-- Find empty accessory slot
		if not loadout[EquipmentModule.Slots.ACCESSORY1] then
			slot = EquipmentModule.Slots.ACCESSORY1
		elseif not loadout[EquipmentModule.Slots.ACCESSORY2] then
			slot = EquipmentModule.Slots.ACCESSORY2
		else
			return false, "No empty accessory slot!"
		end
	end

	if not slot then
		return false, "Invalid equipment type!"
	end

	-- Store old equipment
	local oldEquipment = loadout[slot]

	-- Equip new
	loadout[slot] = equipment

	return true, "Equipped " .. equipment.Name, oldEquipment
end

-- ========================================
-- UNEQUIP ITEM
-- ========================================

function EquipmentModule.Unequip(loadout, slotName)
	local equipment = loadout[slotName]

	if not equipment then
		return false, "Slot is empty!"
	end

	loadout[slotName] = nil

	return true, "Unequipped " .. equipment.Name, equipment
end

-- ========================================
-- CALCULATE TOTAL STATS
-- ========================================

function EquipmentModule.GetTotalStats(loadout)
	local totalStats = {
		HP = 0,
		MP = 0,
		MagicDamage = 0,
		PhysicalDamage = 0,
		SoulDamage = 0,
		Defense = 0,
		MagicDefense = 0,
		Speed = 0,
		CritRate = 0,
		CritDamage = 0,
		Lifesteal = 0
	}

	for slotName, equipment in pairs(loadout) do
		if equipment and equipment.Stats then
			for stat, value in pairs(equipment.Stats) do
				if totalStats[stat] then
					totalStats[stat] = totalStats[stat] + value
				end
			end
		end
	end

	return totalStats
end

-- ========================================
-- GET EQUIPMENT BY NAME
-- ========================================

function EquipmentModule.GetEquipmentData(itemName)
	-- Search in all equipment tables
	local allEquipment = {
		EquipmentModule.Weapons,
		EquipmentModule.Armors,
		EquipmentModule.Accessories,
		EquipmentModule.Talismans
	}

	for _, equipmentTable in ipairs(allEquipment) do
		for key, equipment in pairs(equipmentTable) do
			if equipment.Name == itemName or key == itemName then
				return equipment
			end
		end
	end

	return nil
end

-- ========================================
-- CAN EQUIP (Check level requirement)
-- ========================================

function EquipmentModule.CanEquip(equipment, playerLevel, cultivationType)
	-- Check level
	if equipment.Level and playerLevel < equipment.Level then
		return false, "Level too low! Required: " .. equipment.Level
	end

	-- Check cultivation type
	if equipment.CultivationType and equipment.CultivationType ~= cultivationType then
		return false, "Wrong cultivation type!"
	end

	return true
end

-- ========================================
-- UPGRADE EQUIPMENT
-- ========================================

function EquipmentModule.Upgrade(equipment, cost)
	-- Increase stats by 10%
	if equipment.Stats then
		for stat, value in pairs(equipment.Stats) do
			equipment.Stats[stat] = value * 1.1
		end
	end

	-- Increase level
	equipment.Level = (equipment.Level or 1) + 1

	return true, "Upgraded to Level " .. equipment.Level
end

print("✅ EquipmentModule loaded")
return EquipmentModule
