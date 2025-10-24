-- ShopModule.lua - Hệ Thống Cửa Hàng
-- Copy vào ReplicatedStorage/Modules/Shop/ShopModule (ModuleScript)

local ShopModule = {}

-- ========================================
-- SHOP CATEGORIES
-- ========================================

ShopModule.Category = {
	PILLS = "Pills",
	EQUIPMENT = "Equipment",
	MATERIALS = "Materials",
	SPECIAL = "Special"
}

-- ========================================
-- PILL SHOP
-- ========================================

ShopModule.PillShop = {
	{
		ItemName = "Tu Khí Đan",
		Category = ShopModule.Category.PILLS,
		Price = 50,
		SellPrice = 25,
		Stock = -1, -- -1 = unlimited
		Description = "Tăng 100 Tu Vi",
		Icon = "rbxassetid://0"
	},
	{
		ItemName = "Tiểu Hoàn Đan",
		Category = ShopModule.Category.PILLS,
		Price = 250,
		SellPrice = 125,
		Stock = -1,
		Description = "Tăng 500 Tu Vi",
		Icon = "rbxassetid://0"
	},
	{
		ItemName = "Đại Hoàn Đan",
		Category = ShopModule.Category.PILLS,
		Price = 1000,
		SellPrice = 500,
		Stock = -1,
		Description = "Tăng 2000 Tu Vi",
		Icon = "rbxassetid://0"
	},
	{
		ItemName = "Thể Tu Đan",
		Category = ShopModule.Category.PILLS,
		Price = 60,
		SellPrice = 30,
		Stock = -1,
		Description = "Tăng thể chất",
		Icon = "rbxassetid://0"
	},
	{
		ItemName = "Ma Đạo Đan",
		Category = ShopModule.Category.PILLS,
		Price = 55,
		SellPrice = 27,
		Stock = -1,
		Description = "Tăng Ma Lực",
		Icon = "rbxassetid://0"
	}
}

-- ========================================
-- EQUIPMENT SHOP
-- ========================================

ShopModule.EquipmentShop = {
	-- Weapons
	{
		ItemName = "Phàm Kiếm",
		Category = ShopModule.Category.EQUIPMENT,
		Price = 500,
		SellPrice = 250,
		Stock = -1,
		LevelRequirement = 1,
		Description = "Thanh kiếm phàm trần",
		Icon = "rbxassetid://0"
	},
	{
		ItemName = "Linh Kiếm",
		Category = ShopModule.Category.EQUIPMENT,
		Price = 2000,
		SellPrice = 1000,
		Stock = 10,
		LevelRequirement = 5,
		Description = "Kiếm được tẩm linh lực",
		Icon = "rbxassetid://0"
	},
	{
		ItemName = "Thiên Kiếm",
		Category = ShopModule.Category.EQUIPMENT,
		Price = 10000,
		SellPrice = 5000,
		Stock = 3,
		LevelRequirement = 15,
		Description = "Kiếm từ Thiên Giới",
		Icon = "rbxassetid://0"
	},

	-- Armors
	{
		ItemName = "Phàm Y",
		Category = ShopModule.Category.EQUIPMENT,
		Price = 400,
		SellPrice = 200,
		Stock = -1,
		LevelRequirement = 1,
		Description = "Áo giáp phàm trần",
		Icon = "rbxassetid://0"
	},
	{
		ItemName = "Linh Y",
		Category = ShopModule.Category.EQUIPMENT,
		Price = 1800,
		SellPrice = 900,
		Stock = 10,
		LevelRequirement = 5,
		Description = "Pháp y linh lực",
		Icon = "rbxassetid://0"
	},

	-- Accessories
	{
		ItemName = "Huyền Vận Nhẫn",
		Category = ShopModule.Category.EQUIPMENT,
		Price = 3000,
		SellPrice = 1500,
		Stock = 5,
		LevelRequirement = 3,
		Description = "Nhẫn tăng may mắn",
		Icon = "rbxassetid://0"
	}
}

-- ========================================
-- MATERIAL SHOP
-- ========================================

ShopModule.MaterialShop = {
	{
		ItemName = "Thú Cốt",
		Category = ShopModule.Category.MATERIALS,
		Price = 30,
		SellPrice = 15,
		Stock = -1,
		Description = "Xương thú",
		Icon = "rbxassetid://0"
	},
	{
		ItemName = "Vạn Niên Linh Dược",
		Category = ShopModule.Category.MATERIALS,
		Price = 500,
		SellPrice = 250,
		Stock = 20,
		Description = "Linh dược 10,000 năm tuổi",
		Icon = "rbxassetid://0"
	},
	{
		ItemName = "Kim Cang Xá Lợi",
		Category = ShopModule.Category.MATERIALS,
		Price = 2000,
		SellPrice = 1000,
		Stock = 10,
		Description = "Xá lợi Kim Cang",
		Icon = "rbxassetid://0"
	}
}

-- ========================================
-- SPECIAL SHOP (Daily Deals)
-- ========================================

ShopModule.SpecialShop = {
	{
		ItemName = "Thái Cổ Linh Đan",
		Category = ShopModule.Category.SPECIAL,
		Price = 5000,
		SellPrice = 0, -- Cannot sell special items
		Stock = 1,
		LevelRequirement = 10,
		Description = "Linh đan từ thời Thái Cổ - Rare!",
		Icon = "rbxassetid://0"
	},
	{
		ItemName = "Lôi Pháp",
		Category = ShopModule.Category.SPECIAL,
		Price = 8000,
		SellPrice = 0,
		Stock = 1,
		LevelRequirement = 12,
		Description = "Pháp bảo sấm sét - Limited!",
		Icon = "rbxassetid://0"
	}
}

-- ========================================
-- GET ALL SHOPS
-- ========================================

function ShopModule.GetAllShops()
	return {
		[ShopModule.Category.PILLS] = ShopModule.PillShop,
		[ShopModule.Category.EQUIPMENT] = ShopModule.EquipmentShop,
		[ShopModule.Category.MATERIALS] = ShopModule.MaterialShop,
		[ShopModule.Category.SPECIAL] = ShopModule.SpecialShop
	}
end

-- ========================================
-- GET SHOP BY CATEGORY
-- ========================================

function ShopModule.GetShop(category)
	local shops = ShopModule.GetAllShops()
	return shops[category]
end

-- ========================================
-- FIND ITEM IN SHOP
-- ========================================

function ShopModule.FindItem(itemName)
	local allShops = ShopModule.GetAllShops()

	for category, shop in pairs(allShops) do
		for _, item in ipairs(shop) do
			if item.ItemName == itemName then
				return item
			end
		end
	end

	return nil
end

-- ========================================
-- CALCULATE PRICE (with discounts)
-- ========================================

function ShopModule.CalculatePrice(basePrice, playerLevel, discount)
	discount = discount or 0
	local finalPrice = basePrice * (1 - discount)

	-- VIP discount (placeholder)
	-- if player.HasVIP then
	--     finalPrice = finalPrice * 0.9
	-- end

	return math.floor(finalPrice)
end

-- ========================================
-- CAN AFFORD
-- ========================================

function ShopModule.CanAfford(playerGold, price)
	return playerGold >= price
end

-- ========================================
-- REFRESH DAILY DEALS
-- ========================================

function ShopModule.RefreshDailyDeals()
	-- Reset special shop stock
	for _, item in ipairs(ShopModule.SpecialShop) do
		if item.ItemName == "Thái Cổ Linh Đan" then
			item.Stock = 1
		elseif item.ItemName == "Lôi Pháp" then
			item.Stock = 1
		end
	end

	-- Could add random daily deals here
	print("🛒 Daily deals refreshed!")
end

-- ========================================
-- SELL PRICE MULTIPLIER
-- ========================================

ShopModule.SellMultiplier = 0.5 -- Sell for 50% of buy price

function ShopModule.GetSellPrice(buyPrice)
	return math.floor(buyPrice * ShopModule.SellMultiplier)
end

-- ========================================
-- DISCOUNT EVENTS
-- ========================================

ShopModule.ActiveDiscounts = {}

function ShopModule.SetDiscount(category, discountPercent, duration)
	ShopModule.ActiveDiscounts[category] = {
		Discount = discountPercent,
		ExpiresAt = os.time() + duration
	}
end

function ShopModule.GetDiscount(category)
	local discountData = ShopModule.ActiveDiscounts[category]

	if discountData and os.time() < discountData.ExpiresAt then
		return discountData.Discount
	end

	return 0
end

-- ========================================
-- SHOP NPC DIALOGUES
-- ========================================

ShopModule.ShopDialogues = {
	Greeting = {
		"Xin chào! Hảo khách muốn mua gì?",
		"Chào mừng đến cửa hàng!",
		"Ta có nhiều bảo vật đây!"
	},
	Buy = {
		"Cảm ơn quý khách!",
		"Giao dịch thành công!",
		"Chúc quý khách tu luyện tấn triển!"
	},
	Sell = {
		"Ta sẽ mua với giá này",
		"Được, ta nhận vật phẩm này"
	},
	NoMoney = {
		"Không đủ Tiên Ngọc!",
		"Hảo khách cần thêm tiền",
		"Giá quá cao cho hảo khách rồi"
	}
}

function ShopModule.GetRandomDialogue(type)
	local dialogues = ShopModule.ShopDialogues[type]
	if dialogues and #dialogues > 0 then
		return dialogues[math.random(1, #dialogues)]
	end
	return ""
end

print("✅ ShopModule loaded")
return ShopModule
