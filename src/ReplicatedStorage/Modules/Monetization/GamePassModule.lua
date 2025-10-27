-- GamePassModule.lua - Game Pass System
-- Copy vào ReplicatedStorage/Modules/Monetization/GamePassModule (ModuleScript)

local GamePassModule = {}

-- ========================================
-- GAME PASSES
-- ========================================

GamePassModule.GamePasses = {
	VIP = {
		ID = 0,  -- TODO: Replace với Game Pass ID từ Creator Hub
		Name = "VIP Pass",
		Price = 299,  -- 299 Robux
		Description = "Unlock VIP benefits",
		Benefits = {
			"10% discount tất cả shop items",
			"+50% Tu Vi gain khi tu luyện",
			"+50% Gold gain khi giết quái",
			"Exclusive VIP chat tag [VIP]",
			"Access to VIP teleport locations",
			"Priority server join"
		},
		Icon = "rbxassetid://0"
	},

	DoubleXP = {
		ID = 0,  -- TODO: Replace
		Name = "2x Tu Vi Boost",
		Price = 199,
		Description = "Double Tu Vi gain forever!",
		Benefits = {
			"+100% Tu Vi gain",
			"Permanent boost"
		},
		Icon = "rbxassetid://0"
	},

	DoubleGold = {
		ID = 0,  -- TODO: Replace
		Name = "2x Gold Boost",
		Price = 199,
		Description = "Double Gold drops forever!",
		Benefits = {
			"+100% Gold gain from enemies",
			"+100% Gold from quests",
			"Permanent boost"
		},
		Icon = "rbxassetid://0"
	},

	AutoLoot = {
		ID = 0,  -- TODO: Replace
		Name = "Auto Loot",
		Price = 149,
		Description = "Automatically pick up loot",
		Benefits = {
			"Auto collect loot drops",
			"No need to click",
			"Never miss rare items!"
		},
		Icon = "rbxassetid://0"
	},

	PetSlots = {
		ID = 0,  -- TODO: Replace
		Name = "+3 Pet Slots",
		Price = 99,
		Description = "Unlock 3 additional pet slots",
		Benefits = {
			"Equip up to 6 pets (default: 3)",
			"More pets = more power!"
		},
		Icon = "rbxassetid://0"
	},

	FastCultivation = {
		ID = 0,  -- TODO: Replace
		Name = "Fast Cultivation",
		Price = 249,
		Description = "50% faster meditation cooldown",
		Benefits = {
			"-50% cultivation cooldown",
			"Tu luyện nhanh hơn",
			"Reach higher realms faster!"
		},
		Icon = "rbxassetid://0"
	}
}

-- ========================================
-- CHECK IF PLAYER HAS GAME PASS
-- ========================================

function GamePassModule.HasPass(player, passName)
	local passData = GamePassModule.GamePasses[passName]
	if not passData then
		warn("Game Pass not found:", passName)
		return false
	end

	-- If ID is 0, not setup yet
	if passData.ID == 0 then
		warn("Game Pass ID not set for:", passName)
		return false
	end

	local MarketplaceService = game:GetService("MarketplaceService")

	local success, hasPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passData.ID)
	end)

	if not success then
		warn("Error checking game pass for", player.Name, ":", hasPass)
		return false
	end

	return hasPass
end

-- ========================================
-- GET MULTIPLIER BASED ON PASSES
-- ========================================

function GamePassModule.GetTuViMultiplier(player)
	local multiplier = 1

	if GamePassModule.HasPass(player, "VIP") then
		multiplier = multiplier * 1.5  -- +50%
	end

	if GamePassModule.HasPass(player, "DoubleXP") then
		multiplier = multiplier * 2  -- +100%
	end

	return multiplier
end

function GamePassModule.GetGoldMultiplier(player)
	local multiplier = 1

	if GamePassModule.HasPass(player, "VIP") then
		multiplier = multiplier * 1.5  -- +50%
	end

	if GamePassModule.HasPass(player, "DoubleGold") then
		multiplier = multiplier * 2  -- +100%
	end

	return multiplier
end

function GamePassModule.GetShopDiscount(player)
	local discount = 0

	if GamePassModule.HasPass(player, "VIP") then
		discount = discount + 0.1  -- 10% off
	end

	return discount
end

function GamePassModule.GetMaxPetSlots(player)
	local slots = 3  -- Default

	if GamePassModule.HasPass(player, "PetSlots") then
		slots = slots + 3  -- +3 slots
	end

	return slots
end

function GamePassModule.GetCultivationCooldownMultiplier(player)
	local multiplier = 1

	if GamePassModule.HasPass(player, "FastCultivation") then
		multiplier = multiplier * 0.5  -- -50% cooldown
	end

	return multiplier
end

function GamePassModule.HasAutoLoot(player)
	return GamePassModule.HasPass(player, "AutoLoot")
end

-- ========================================
-- PROMPT PURCHASE
-- ========================================

function GamePassModule.PromptPurchase(player, passName)
	local passData = GamePassModule.GamePasses[passName]
	if not passData then
		warn("Game Pass not found:", passName)
		return
	end

	if passData.ID == 0 then
		warn("Game Pass ID not set for:", passName)
		return
	end

	-- Check if already owns
	if GamePassModule.HasPass(player, passName) then
		warn(player.Name, "already owns", passName)
		return
	end

	local MarketplaceService = game:GetService("MarketplaceService")

	local success, err = pcall(function()
		MarketplaceService:PromptGamePassPurchase(player, passData.ID)
	end)

	if not success then
		warn("Error prompting purchase:", err)
	end
end

-- ========================================
-- GET ALL PASSES (for UI)
-- ========================================

function GamePassModule.GetAllPasses()
	local passes = {}
	for name, data in pairs(GamePassModule.GamePasses) do
		table.insert(passes, {
			Name = name,
			DisplayName = data.Name,
			Price = data.Price,
			Description = data.Description,
			Benefits = data.Benefits,
			Icon = data.Icon
		})
	end
	return passes
end

-- ========================================
-- GET PLAYER CHAT TAG
-- ========================================

function GamePassModule.GetChatTag(player)
	if GamePassModule.HasPass(player, "VIP") then
		return "[VIP]"
	end
	return ""
end

print("✅ GamePassModule loaded")
return GamePassModule
