-- MonetizationService.lua - Xử Lý Mua Hàng (Server-side)
-- Copy vào ServerScriptService/Services/MonetizationService (Script)

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local DevProductModule = require(ReplicatedStorage.Modules.Monetization.DevProductModule)
local GamePassModule = require(ReplicatedStorage.Modules.Monetization.GamePassModule)

-- TODO: Require these when implemented
-- local InventoryModule = require(ReplicatedStorage.Modules.Inventory.InventoryModule)
-- local BoostModule = require(ReplicatedStorage.Modules.Boost.BoostModule)

local MonetizationService = {}

-- ========================================
-- PURCHASED RECEIPTS CACHE (Anti-duplicate)
-- ========================================

local purchasedReceipts = {}

local function hasProcessedReceipt(receiptInfo)
	local key = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
	return purchasedReceipts[key]
end

local function markReceiptAsProcessed(receiptInfo)
	local key = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
	purchasedReceipts[key] = true
end

-- ========================================
-- PROCESS RECEIPT (Developer Products)
-- ========================================

MarketplaceService.ProcessReceipt = function(receiptInfo)
	-- Check if already processed
	if hasProcessedReceipt(receiptInfo) then
		print("⚠️ Receipt already processed:", receiptInfo.PurchaseId)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	-- Get player
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		warn("❌ Player not found for receipt:", receiptInfo.PlayerId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Get product
	local product = DevProductModule.GetProduct(receiptInfo.ProductId)
	if not product then
		warn("❌ Unknown product:", receiptInfo.ProductId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	print("💰 Processing purchase:", player.Name, "bought", product.Name)

	-- Process purchase based on type
	local success = false

	if product.Type == "Gold" then
		success = MonetizationService.GiveGold(player, product)

	elseif product.Type == "Boost" then
		success = MonetizationService.ApplyBoost(player, product)

	elseif product.Type == "Skill" then
		success = MonetizationService.UnlockSkill(player, product)

	elseif product.Type == "Weapon" or product.Type == "Armor" then
		success = MonetizationService.GiveItem(player, product)

	elseif product.Type == "Consumable" then
		success = MonetizationService.GiveConsumable(player, product)

	elseif product.Type == "Bundle" then
		success = MonetizationService.ProcessBundle(player, product)

	else
		warn("❌ Unknown product type:", product.Type)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Mark as processed
	if success then
		markReceiptAsProcessed(receiptInfo)
		print("✅ Purchase granted:", player.Name, product.Name)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		warn("❌ Failed to process purchase:", player.Name, product.Name)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

-- ========================================
-- GIVE GOLD
-- ========================================

function MonetizationService.GiveGold(player, product)
	local totalGold = product.Amount + (product.Bonus or 0)

	-- TODO: Implement actual gold giving
	-- Example:
	-- local PlayerData = GetPlayerData(player)
	-- PlayerData.Gold = PlayerData.Gold + totalGold
	-- SavePlayerData(player)

	print("💰", player.Name, "received", totalGold, "gold")

	-- Send notification to player
	-- TODO: Implement notification system
	-- UIManager.ShowNotification(player, "Received " .. totalGold .. " gold!", "success")

	return true
end

-- ========================================
-- APPLY BOOST
-- ========================================

function MonetizationService.ApplyBoost(player, product)
	-- TODO: Implement boost system
	-- Example:
	-- local BoostModule = require(ReplicatedStorage.Modules.Boost.BoostModule)
	-- BoostModule.ApplyBoost(player, {
	--     Type = product.BoostType,
	--     Multiplier = product.Multiplier,
	--     Duration = product.Duration
	-- })

	print("⚡", player.Name, "activated boost:", product.BoostType, "x" .. product.Multiplier, "for", product.Duration, "seconds")

	return true
end

-- ========================================
-- UNLOCK SKILL
-- ========================================

function MonetizationService.UnlockSkill(player, product)
	-- TODO: Implement skill unlocking
	-- Example:
	-- local SkillsModule = require(ReplicatedStorage.Modules.Skills.SkillsModule)
	-- SkillsModule.UnlockSkill(player, product.SkillID)

	print("📚", player.Name, "unlocked skill:", product.SkillID)

	return true
end

-- ========================================
-- GIVE ITEM (Weapon/Armor)
-- ========================================

function MonetizationService.GiveItem(player, product)
	-- TODO: Implement inventory system
	-- Example:
	-- local InventoryModule = require(ReplicatedStorage.Modules.Inventory.InventoryModule)
	-- InventoryModule.AddItem(player, product.ItemName, 1, product.Stats)

	print("🗡️", player.Name, "received item:", product.ItemName)

	return true
end

-- ========================================
-- GIVE CONSUMABLE
-- ========================================

function MonetizationService.GiveConsumable(player, product)
	-- TODO: Implement inventory system
	-- Example:
	-- local InventoryModule = require(ReplicatedStorage.Modules.Inventory.InventoryModule)
	-- InventoryModule.AddItem(player, product.ItemName, 1)

	print("💊", player.Name, "received consumable:", product.ItemName)

	return true
end

-- ========================================
-- PROCESS BUNDLE
-- ========================================

function MonetizationService.ProcessBundle(player, product)
	print("📦", player.Name, "received bundle:", product.Name)

	for _, content in ipairs(product.Contents) do
		if content.Type == "Gold" then
			MonetizationService.GiveGold(player, {Amount = content.Amount, Bonus = 0})

		elseif content.Type == "Item" then
			-- TODO: Give item
			print("  📦 Item:", content.Quantity, "x", content.Name)

		elseif content.Type == "Boost" then
			MonetizationService.ApplyBoost(player, content)
		end
	end

	return true
end

-- ========================================
-- PROMPT PURCHASE (RemoteEvent)
-- ========================================

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Create RemoteEvent if not exists
local PromptPurchaseEvent = RemoteEvents:FindFirstChild("PromptPurchase")
if not PromptPurchaseEvent then
	PromptPurchaseEvent = Instance.new("RemoteEvent")
	PromptPurchaseEvent.Name = "PromptPurchase"
	PromptPurchaseEvent.Parent = RemoteEvents
end

PromptPurchaseEvent.OnServerEvent:Connect(function(player, productName)
	DevProductModule.PromptPurchase(player, productName)
end)

-- ========================================
-- PROMPT GAME PASS PURCHASE
-- ========================================

local PromptGamePassEvent = RemoteEvents:FindFirstChild("PromptGamePass")
if not PromptGamePassEvent then
	PromptGamePassEvent = Instance.new("RemoteEvent")
	PromptGamePassEvent.Name = "PromptGamePass"
	PromptGamePassEvent.Parent = RemoteEvents
end

PromptGamePassEvent.OnServerEvent:Connect(function(player, passName)
	GamePassModule.PromptPurchase(player, passName)
end)

-- ========================================
-- GAME PASS PURCHASED EVENT
-- ========================================

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	if wasPurchased then
		-- Find which pass was purchased
		for passName, passData in pairs(GamePassModule.GamePasses) do
			if passData.ID == gamePassId then
				print("✅", player.Name, "purchased Game Pass:", passName)

				-- Apply immediate benefits if needed
				-- TODO: Implement

				break
			end
		end
	end
end)

-- ========================================
-- GET PLAYER MULTIPLIERS (for other systems)
-- ========================================

function MonetizationService.GetPlayerMultipliers(player)
	return {
		TuVi = GamePassModule.GetTuViMultiplier(player),
		Gold = GamePassModule.GetGoldMultiplier(player),
		ShopDiscount = GamePassModule.GetShopDiscount(player),
		CultivationCooldown = GamePassModule.GetCultivationCooldownMultiplier(player)
	}
end

-- ========================================
-- CHECK PLAYER FEATURES
-- ========================================

function MonetizationService.GetPlayerFeatures(player)
	return {
		AutoLoot = GamePassModule.HasAutoLoot(player),
		MaxPetSlots = GamePassModule.GetMaxPetSlots(player),
		ChatTag = GamePassModule.GetChatTag(player)
	}
end

print("✅ MonetizationService initialized")
return MonetizationService
