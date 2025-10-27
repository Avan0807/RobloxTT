-- DevProductModule.lua - Developer Products (Consumables)
-- Copy vào ReplicatedStorage/Modules/Monetization/DevProductModule (ModuleScript)

local DevProductModule = {}

-- ========================================
-- DEVELOPER PRODUCTS
-- ========================================

DevProductModule.Products = {
	-- ========== GOLD PACKS ==========
	{
		ProductID = 0,  -- TODO: Replace với Product ID từ Creator Hub
		Name = "50K Gold Pack",
		DisplayName = "50,000 Gold",
		Price = 49,  -- 49 Robux
		Type = "Gold",
		Amount = 50000,
		Icon = "rbxassetid://0",
		Description = "Get 50,000 gold instantly!"
	},
	{
		ProductID = 0,
		Name = "100K Gold Pack",
		DisplayName = "100,000 Gold",
		Price = 99,
		Type = "Gold",
		Amount = 100000,
		Bonus = 10000,  -- +10k bonus!
		Icon = "rbxassetid://0",
		Description = "Get 110,000 gold (+10k bonus!)"
	},
	{
		ProductID = 0,
		Name = "500K Gold Pack",
		DisplayName = "500,000 Gold",
		Price = 399,
		Type = "Gold",
		Amount = 500000,
		Bonus = 100000,  -- +100k bonus!
		Icon = "rbxassetid://0",
		Description = "Get 600,000 gold (+100k bonus!)"
	},
	{
		ProductID = 0,
		Name = "1M Gold Pack",
		DisplayName = "1,000,000 Gold (BEST VALUE!)",
		Price = 699,
		Type = "Gold",
		Amount = 1000000,
		Bonus = 300000,  -- +300k bonus!
		BestValue = true,
		Icon = "rbxassetid://0",
		Description = "Get 1,300,000 gold (+300k bonus!) - BEST VALUE!"
	},

	-- ========== TU VI BOOSTS ==========
	{
		ProductID = 0,
		Name = "Tu Vi Boost 1h",
		DisplayName = "2x Tu Vi (1 Hour)",
		Price = 99,
		Type = "Boost",
		BoostType = "TuVi",
		Duration = 3600,  -- 1 hour (seconds)
		Multiplier = 2,  -- x2
		Icon = "rbxassetid://0",
		Description = "Double Tu Vi gain for 1 hour!"
	},
	{
		ProductID = 0,
		Name = "Tu Vi Boost 8h",
		DisplayName = "2x Tu Vi (8 Hours)",
		Price = 499,
		Type = "Boost",
		BoostType = "TuVi",
		Duration = 28800,  -- 8 hours
		Multiplier = 2,
		Icon = "rbxassetid://0",
		Description = "Double Tu Vi gain for 8 hours!"
	},

	-- ========== GOLD BOOSTS ==========
	{
		ProductID = 0,
		Name = "Gold Boost 1h",
		DisplayName = "2x Gold (1 Hour)",
		Price = 99,
		Type = "Boost",
		BoostType = "Gold",
		Duration = 3600,
		Multiplier = 2,
		Icon = "rbxassetid://0",
		Description = "Double gold drops for 1 hour!"
	},

	-- ========== COMBO BOOSTS ==========
	{
		ProductID = 0,
		Name = "Mega Boost 1h",
		DisplayName = "3x Everything (1 Hour)",
		Price = 249,
		Type = "Boost",
		BoostType = "All",
		Duration = 3600,
		Multiplier = 3,  -- x3 everything!
		Icon = "rbxassetid://0",
		Description = "3x Tu Vi, Gold, Drop Rate for 1 hour!"
	},

	-- ========== SKILL BOOKS ==========
	{
		ProductID = 0,
		Name = "Lôi Pháp Kinh",
		DisplayName = "Lôi Pháp (Lightning)",
		Price = 999,
		Type = "Skill",
		SkillID = "LightningStrike",
		Icon = "rbxassetid://0",
		Description = "Unlock Lôi Pháp skill - Lightning Strike ability!"
	},
	{
		ProductID = 0,
		Name = "Ma Hoàng Tuyệt Học",
		DisplayName = "Ma Hoàng Ultimate",
		Price = 1999,
		Type = "Skill",
		SkillID = "MaHoangUltimate",
		Icon = "rbxassetid://0",
		Description = "Unlock Ma Hoàng's ultimate technique!"
	},

	-- ========== EXCLUSIVE WEAPONS ==========
	{
		ProductID = 0,
		Name = "Thiên Địa Kiếm",
		DisplayName = "Thiên Địa Sword",
		Price = 1499,
		Type = "Weapon",
		ItemName = "Thiên Địa Kiếm",
		Icon = "rbxassetid://0",
		Description = "Legendary sword - Lightning strikes on hit!",
		Stats = {
			Damage = 1000,
			CritRate = 0.3,
			CritDamage = 2.0,
			Special = "Lightning Strike (10% chance)"
		}
	},
	{
		ProductID = 0,
		Name = "Ma Hoàng Giáp",
		DisplayName = "Ma Hoàng Armor",
		Price = 1299,
		Type = "Armor",
		ItemName = "Ma Hoàng Giáp",
		Icon = "rbxassetid://0",
		Description = "Legendary armor - Absorb souls on kill!",
		Stats = {
			HP = 2000,
			Defense = 100,
			MagicResist = 80,
			Special = "Soul Absorption (restore 10% HP on kill)"
		}
	},

	-- ========== CONSUMABLES ==========
	{
		ProductID = 0,
		Name = "Resurrection Pill",
		DisplayName = "Hồi Sinh Đan",
		Price = 199,
		Type = "Consumable",
		ItemName = "Hồi Sinh Đan",
		Icon = "rbxassetid://0",
		Description = "Instant revive on death (one-time use)"
	},
	{
		ProductID = 0,
		Name = "Realm Breakthrough Pill",
		DisplayName = "Phá Cảnh Đan",
		Price = 499,
		Type = "Consumable",
		ItemName = "Phá Cảnh Đan",
		Icon = "rbxassetid://0",
		Description = "Skip Thiên Kiếp and breakthrough instantly!"
	},

	-- ========== BUNDLES ==========
	{
		ProductID = 0,
		Name = "Starter Pack",
		DisplayName = "Starter Pack (BEST DEAL!)",
		Price = 499,
		Type = "Bundle",
		Icon = "rbxassetid://0",
		Description = "Perfect for beginners!",
		Contents = {
			{Type = "Gold", Amount = 100000},
			{Type = "Item", Name = "Linh Kiếm", Quantity = 1},
			{Type = "Item", Name = "Linh Y", Quantity = 1},
			{Type = "Item", Name = "Tu Khí Đan", Quantity = 10},
			{Type = "Boost", BoostType = "TuVi", Duration = 3600, Multiplier = 2}
		}
	}
}

-- ========================================
-- GET PRODUCT BY ID
-- ========================================

function DevProductModule.GetProduct(productID)
	for _, product in ipairs(DevProductModule.Products) do
		if product.ProductID == productID then
			return product
		end
	end
	return nil
end

-- ========================================
-- GET PRODUCT BY NAME
-- ========================================

function DevProductModule.GetProductByName(name)
	for _, product in ipairs(DevProductModule.Products) do
		if product.Name == name then
			return product
		end
	end
	return nil
end

-- ========================================
-- GET PRODUCTS BY TYPE
-- ========================================

function DevProductModule.GetProductsByType(productType)
	local filtered = {}
	for _, product in ipairs(DevProductModule.Products) do
		if product.Type == productType then
			table.insert(filtered, product)
		end
	end
	return filtered
end

-- ========================================
-- PROMPT PURCHASE
-- ========================================

function DevProductModule.PromptPurchase(player, productName)
	local product = DevProductModule.GetProductByName(productName)
	if not product then
		warn("Product not found:", productName)
		return
	end

	if product.ProductID == 0 then
		warn("Product ID not set for:", productName)
		return
	end

	local MarketplaceService = game:GetService("MarketplaceService")

	local success, err = pcall(function()
		MarketplaceService:PromptProductPurchase(player, product.ProductID)
	end)

	if not success then
		warn("Error prompting purchase:", err)
	end
end

-- ========================================
-- PROCESS PURCHASE (Server-side)
-- ========================================

function DevProductModule.ProcessPurchase(player, product)
	-- This is called from ProcessReceipt

	if product.Type == "Gold" then
		-- Give gold
		local totalGold = product.Amount + (product.Bonus or 0)
		-- TODO: Implement AddGold function
		print(player.Name, "received", totalGold, "gold")
		return true

	elseif product.Type == "Boost" then
		-- Apply boost
		-- TODO: Implement ApplyBoost function
		print(player.Name, "activated", product.Name, "for", product.Duration, "seconds")
		return true

	elseif product.Type == "Skill" then
		-- Unlock skill
		-- TODO: Implement UnlockSkill function
		print(player.Name, "unlocked skill:", product.SkillID)
		return true

	elseif product.Type == "Weapon" or product.Type == "Armor" then
		-- Give item
		-- TODO: Implement AddItem function
		print(player.Name, "received:", product.ItemName)
		return true

	elseif product.Type == "Consumable" then
		-- Give consumable item
		-- TODO: Implement AddItem function
		print(player.Name, "received consumable:", product.ItemName)
		return true

	elseif product.Type == "Bundle" then
		-- Process bundle contents
		for _, content in ipairs(product.Contents) do
			if content.Type == "Gold" then
				-- Give gold
				print("  - Giving", content.Amount, "gold")
			elseif content.Type == "Item" then
				-- Give item
				print("  - Giving", content.Quantity, "x", content.Name)
			elseif content.Type == "Boost" then
				-- Apply boost
				print("  - Applying", content.BoostType, "boost")
			end
		end
		return true
	end

	warn("Unknown product type:", product.Type)
	return false
end

-- ========================================
-- GET ALL PRODUCTS (for UI)
-- ========================================

function DevProductModule.GetAllProducts()
	return DevProductModule.Products
end

-- ========================================
-- GET FEATURED PRODUCTS
-- ========================================

function DevProductModule.GetFeaturedProducts()
	local featured = {}
	for _, product in ipairs(DevProductModule.Products) do
		if product.BestValue or product.Type == "Bundle" then
			table.insert(featured, product)
		end
	end
	return featured
end

print("✅ DevProductModule loaded")
return DevProductModule
