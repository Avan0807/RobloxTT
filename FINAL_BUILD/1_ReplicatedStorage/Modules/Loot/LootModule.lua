-- LootModule.lua - Hệ Thống Loot Drops
-- Copy vào ReplicatedStorage/Modules/Loot/LootModule (ModuleScript)

local LootModule = {}

-- ========================================
-- ITEM TYPES
-- ========================================

LootModule.ItemType = {
	PILL = "Pill",           -- Đan Dược
	MATERIAL = "Material",   -- Nguyên Liệu
	GOLD = "Gold",          -- Tiên Ngọc
	SOUL = "Soul"           -- Linh Hồn (for Ma Đạo)
}

-- ========================================
-- RARITY SYSTEM
-- ========================================

LootModule.Rarity = {
	COMMON = {
		Name = "Common",
		Color = Color3.fromRGB(200, 200, 200),
		DropChance = 0.70 -- 70%
	},
	UNCOMMON = {
		Name = "Uncommon",
		Color = Color3.fromRGB(100, 255, 100),
		DropChance = 0.20 -- 20%
	},
	RARE = {
		Name = "Rare",
		Color = Color3.fromRGB(100, 150, 255),
		DropChance = 0.08 -- 8%
	},
	EPIC = {
		Name = "Epic",
		Color = Color3.fromRGB(200, 100, 255),
		DropChance = 0.015 -- 1.5%
	},
	LEGENDARY = {
		Name = "Legendary",
		Color = Color3.fromRGB(255, 200, 0),
		DropChance = 0.005 -- 0.5%
	}
}

-- ========================================
-- PILL DEFINITIONS
-- ========================================

LootModule.Pills = {
	-- Tiên Thiên Pills
	TuKhiDan = {
		Name = "Tu Khí Đan",
		Type = LootModule.ItemType.PILL,
		Rarity = LootModule.Rarity.COMMON,
		Description = "Tăng 100 Tu Vi",
		TuViBonus = 100,
		Icon = "rbxassetid://0" -- Thay bằng icon ID thực
	},

	TieuHoanDan = {
		Name = "Tiểu Hoàn Đan",
		Type = LootModule.ItemType.PILL,
		Rarity = LootModule.Rarity.UNCOMMON,
		Description = "Tăng 500 Tu Vi",
		TuViBonus = 500,
		Icon = "rbxassetid://0"
	},

	DaiHoanDan = {
		Name = "Đại Hoàn Đan",
		Type = LootModule.ItemType.PILL,
		Rarity = LootModule.Rarity.RARE,
		Description = "Tăng 2000 Tu Vi",
		TuViBonus = 2000,
		Icon = "rbxassetid://0"
	},

	-- Cổ Thần Pills
	TheTuDan = {
		Name = "Thể Tu Đan",
		Type = LootModule.ItemType.PILL,
		Rarity = LootModule.Rarity.COMMON,
		Description = "Tăng thể chất",
		TuViBonus = 150,
		Icon = "rbxassetid://0"
	},

	CoThanHuyet = {
		Name = "Cổ Thần Huyết",
		Type = LootModule.ItemType.MATERIAL,
		Rarity = LootModule.Rarity.UNCOMMON,
		Description = "Huyết của Cổ Thần",
		Icon = "rbxassetid://0"
	},

	-- Ma Đạo Pills
	MaDaoDan = {
		Name = "Ma Đạo Đan",
		Type = LootModule.ItemType.PILL,
		Rarity = LootModule.Rarity.COMMON,
		Description = "Tăng Ma Lực",
		TuViBonus = 120,
		Icon = "rbxassetid://0"
	}
}

-- ========================================
-- MATERIAL DEFINITIONS
-- ========================================

LootModule.Materials = {
	ThuCot = {
		Name = "Thú Cốt",
		Type = LootModule.ItemType.MATERIAL,
		Rarity = LootModule.Rarity.COMMON,
		Description = "Xương thú",
		Icon = "rbxassetid://0"
	},

	VanNienLinhDuoc = {
		Name = "Vạn Niên Linh Dược",
		Type = LootModule.ItemType.MATERIAL,
		Rarity = LootModule.Rarity.RARE,
		Description = "Linh dược 10,000 năm tuổi",
		Icon = "rbxassetid://0"
	},

	KimCangXaLoi = {
		Name = "Kim Cang Xá Lợi",
		Type = LootModule.ItemType.MATERIAL,
		Rarity = LootModule.Rarity.EPIC,
		Description = "Xá lợi Kim Cang",
		Icon = "rbxassetid://0"
	},

	ThaiCoLinhDan = {
		Name = "Thái Cổ Linh Đan",
		Type = LootModule.ItemType.MATERIAL,
		Rarity = LootModule.Rarity.LEGENDARY,
		Description = "Linh đan từ thời Thái Cổ",
		Icon = "rbxassetid://0"
	}
}

-- ========================================
-- LOOT TABLES BY ENEMY LEVEL
-- ========================================

LootModule.LootTables = {
	-- Low Level (1-9)
	Low = {
		Gold = {Min = 10, Max = 50},
		DropChance = 0.60, -- 60% drop chance
		Items = {
			{Item = "TuKhiDan", Weight = 50},
			{Item = "TheTuDan", Weight = 30},
			{Item = "MaDaoDan", Weight = 20},
			{Item = "ThuCot", Weight = 40}
		}
	},

	-- Mid Level (10-18)
	Mid = {
		Gold = {Min = 50, Max = 200},
		DropChance = 0.70,
		Items = {
			{Item = "TieuHoanDan", Weight = 40},
			{Item = "CoThanHuyet", Weight = 30},
			{Item = "VanNienLinhDuoc", Weight = 20},
			{Item = "ThuCot", Weight = 50}
		}
	},

	-- High Level (19-27)
	High = {
		Gold = {Min = 200, Max = 1000},
		DropChance = 0.80,
		Items = {
			{Item = "DaiHoanDan", Weight = 30},
			{Item = "KimCangXaLoi", Weight = 20},
			{Item = "VanNienLinhDuoc", Weight = 40},
			{Item = "ThaiCoLinhDan", Weight = 10}
		}
	}
}

-- ========================================
-- GENERATE LOOT
-- ========================================

function LootModule.GenerateLoot(enemyLevel)
	-- Determine loot table
	local lootTable
	if enemyLevel <= 9 then
		lootTable = LootModule.LootTables.Low
	elseif enemyLevel <= 18 then
		lootTable = LootModule.LootTables.Mid
	else
		lootTable = LootModule.LootTables.High
	end

	-- Check if loot drops
	if math.random() > lootTable.DropChance then
		return nil
	end

	local loot = {}

	-- Always drop gold
	local goldAmount = math.random(lootTable.Gold.Min, lootTable.Gold.Max)
	table.insert(loot, {
		Type = LootModule.ItemType.GOLD,
		Name = "Tiên Ngọc",
		Amount = goldAmount,
		Icon = "rbxassetid://0"
	})

	-- Drop 1-3 items
	local itemCount = math.random(1, 3)
	for i = 1, itemCount do
		local itemName = LootModule.SelectRandomItem(lootTable.Items)

		-- Get item data
		local itemData = LootModule.Pills[itemName] or LootModule.Materials[itemName]

		if itemData then
			local amount = 1
			if itemData.Type == LootModule.ItemType.MATERIAL then
				amount = math.random(1, 5) -- Materials can drop in stacks
			end

			table.insert(loot, {
				Name = itemData.Name,
				Type = itemData.Type,
				Rarity = itemData.Rarity,
				Amount = amount,
				Description = itemData.Description,
				Icon = itemData.Icon,
				TuViBonus = itemData.TuViBonus
			})
		end
	end

	return loot
end

-- ========================================
-- SELECT RANDOM ITEM (Weighted)
-- ========================================

function LootModule.SelectRandomItem(items)
	-- Calculate total weight
	local totalWeight = 0
	for _, item in ipairs(items) do
		totalWeight = totalWeight + item.Weight
	end

	-- Random selection
	local rand = math.random() * totalWeight
	local currentWeight = 0

	for _, item in ipairs(items) do
		currentWeight = currentWeight + item.Weight
		if rand <= currentWeight then
			return item.Item
		end
	end

	return items[1].Item -- Fallback
end

-- ========================================
-- GET ITEM DATA
-- ========================================

function LootModule.GetItemData(itemName)
	return LootModule.Pills[itemName] or LootModule.Materials[itemName]
end

-- ========================================
-- CREATE LOOT DROP VISUAL
-- ========================================

function LootModule.CreateLootDrop(position, lootData)
	-- Create a part for loot drop
	local lootPart = Instance.new("Part")
	lootPart.Name = "LootDrop"
	lootPart.Size = Vector3.new(2, 2, 2)
	lootPart.Position = position + Vector3.new(0, 2, 0)
	lootPart.Anchored = true
	lootPart.CanCollide = false
	lootPart.Shape = Enum.PartType.Ball

	-- Set color based on rarity
	if lootData.Rarity then
		lootPart.Color = lootData.Rarity.Color
		lootPart.Material = Enum.Material.Neon
	else
		lootPart.Color = Color3.fromRGB(255, 215, 0) -- Gold color
		lootPart.Material = Enum.Material.Gold
	end

	-- Add highlight
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Parent = lootPart

	-- Add BillboardGui for name
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = lootPart

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = lootData.Name
	nameLabel.TextColor3 = lootData.Rarity and lootData.Rarity.Color or Color3.fromRGB(255, 215, 0)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.Parent = billboard

	return lootPart
end

print("✅ LootModule loaded")
return LootModule
