-- HonPhienModule.lua - Hệ Thống Hồn Phiên cho Ma Đạo
-- Copy vào ReplicatedStorage/Modules/MaDao/HonPhienModule (ModuleScript)

local Constants = require(game.ReplicatedStorage.Data.Constants)

local HonPhienModule = {}

-- Add souls to Hồn Phiên when killing enemies
function HonPhienModule.AddSouls(playerData, amount)
	if playerData.CultivationType ~= "MaDao" then
		return false, "Only Ma Đạo can use Hồn Phiên"
	end

	if not playerData.HonPhien.Equipped then
		return false, "No Hồn Phiên equipped"
	end

	local currentSouls = playerData.HonPhien.CurrentSouls
	local maxSouls = playerData.HonPhien.MaxSouls

	-- Add souls (capped at max)
	local newSouls = math.min(currentSouls + amount, maxSouls)
	playerData.HonPhien.CurrentSouls = newSouls

	-- Track total kills
	playerData.HonPhien.TotalKills = playerData.HonPhien.TotalKills + 1

	return true, "Added " .. amount .. " souls (" .. newSouls .. "/" .. maxSouls .. ")"
end

-- Use souls from Hồn Phiên (for skills)
function HonPhienModule.UseSouls(playerData, amount)
	if playerData.CultivationType ~= "MaDao" then
		return false, 0
	end

	local currentSouls = playerData.HonPhien.CurrentSouls

	if currentSouls < amount then
		return false, 0
	end

	-- Use souls
	playerData.HonPhien.CurrentSouls = currentSouls - amount

	return true, amount
end

-- Equip Hồn Phiên
function HonPhienModule.EquipHonPhien(playerData, tier)
	if playerData.CultivationType ~= "MaDao" then
		return false, "Only Ma Đạo can equip Hồn Phiên"
	end

	-- Check if player has this tier in inventory
	local itemName = tier .. "HonPhien"
	if not playerData.DanDuoc[itemName] or playerData.DanDuoc[itemName] <= 0 then
		return false, "Don't have " .. tier .. " Hồn Phiên"
	end

	-- Unequip current if any
	if playerData.HonPhien.Equipped then
		local currentTier = playerData.HonPhien.Tier
		local returnItemName = currentTier .. "HonPhien"
		if playerData.DanDuoc[returnItemName] then
			playerData.DanDuoc[returnItemName] = playerData.DanDuoc[returnItemName] + 1
		end
	end

	-- Consume item
	playerData.DanDuoc[itemName] = playerData.DanDuoc[itemName] - 1

	-- Equip new
	playerData.HonPhien.Equipped = true
	playerData.HonPhien.Tier = tier

	-- Set max souls based on tier and level
	local maxSouls = HonPhienModule.GetMaxSouls(playerData)
	playerData.HonPhien.MaxSouls = maxSouls

	-- Keep current souls (capped at new max)
	playerData.HonPhien.CurrentSouls = math.min(playerData.HonPhien.CurrentSouls, maxSouls)

	return true, "Equipped " .. tier .. " Hồn Phiên (Max: " .. maxSouls .. " souls)"
end

-- Get max souls capacity based on realm and tier
function HonPhienModule.GetMaxSouls(playerData)
	local currentRealm = playerData.CurrentRealm
	local currentLevel = playerData.CurrentLevel
	local tier = playerData.HonPhien.Tier

	-- Realm 1: Ma Đạo - Uses normal Hồn Phiên
	if currentRealm == 1 then
		return Constants.HonPhien.Capacity[currentLevel] or 10
	end

	-- Realm 2: Ma Tôn - Uses Vạn Hồn Phan
	if currentRealm == 2 then
		return Constants.HonPhien.VanHonPhanCapacity[currentLevel] or 10000
	end

	-- Realm 3: Ma Hoàng - Uses Diệt Thế Ma Phan
	if currentRealm == 3 then
		return Constants.HonPhien.DieTTheMaPhanCapacity[currentLevel] or 1000000
	end

	return 10
end

-- Sacrifice souls for temporary buffs
function HonPhienModule.SacrificeSouls(playerData, soulAmount, buffType)
	if playerData.CultivationType ~= "MaDao" then
		return false, "Only Ma Đạo can sacrifice souls"
	end

	local currentSouls = playerData.HonPhien.CurrentSouls
	if currentSouls < soulAmount then
		return false, "Not enough souls (need " .. soulAmount .. ", have " .. currentSouls .. ")"
	end

	-- Remove souls
	playerData.HonPhien.CurrentSouls = currentSouls - soulAmount

	-- Apply buff (this would be handled by a BuffModule in real implementation)
	local buffData = {
		Type = buffType,
		SoulsUsed = soulAmount,
		Time = tick()
	}

	-- Buffs:
	-- 100 souls: +50% Soul Dmg for 10 minutes
	-- 500 souls: Summon Boss Oan Hồn for 5 minutes
	-- 1000 souls: Ma Hóa - Transform into Ma Nhân for 10 minutes

	return true, "Sacrificed " .. soulAmount .. " souls for " .. buffType
end

-- Get souls from killing different enemy types
function HonPhienModule.GetSoulGainFromEnemy(enemyType)
	local soulGain = {
		Normal = 1,        -- Quái thường: 1 soul
		Elite = 5,         -- Quái tinh anh: 5 souls
		Boss = 20,         -- Boss: 20 souls
		Player = 50,       -- Player (PvP): 50 souls
		WorldBoss = 100    -- World Boss: 100 souls
	}

	return soulGain[enemyType] or 1
end

-- Calculate damage bonus from souls
function HonPhienModule.GetSoulDamageBonus(currentSouls)
	-- Ma Tôn passive: Mỗi 1000 souls = +1% stats (max +180%)
	local bonusPercent = math.floor(currentSouls / 1000)
	bonusPercent = math.min(bonusPercent, 180) -- Cap at 180%

	return bonusPercent / 100 -- Return as multiplier (0.01 to 1.80)
end

-- Update max souls when player levels up
function HonPhienModule.UpdateMaxSouls(playerData)
	if playerData.CultivationType ~= "MaDao" then
		return
	end

	if not playerData.HonPhien.Equipped then
		return
	end

	local newMax = HonPhienModule.GetMaxSouls(playerData)
	playerData.HonPhien.MaxSouls = newMax

	-- Don't reduce current souls if they exceed new max
	-- (allows keeping souls when downgrading temporarily)
end

-- Get Hồn Phiên info display
function HonPhienModule.GetDisplayInfo(playerData)
	if playerData.CultivationType ~= "MaDao" then
		return "N/A (Not Ma Đạo)"
	end

	if not playerData.HonPhien.Equipped then
		return "No Hồn Phiên equipped"
	end

	local current = playerData.HonPhien.CurrentSouls
	local max = playerData.HonPhien.MaxSouls
	local percent = math.floor((current / max) * 100)
	local tier = playerData.HonPhien.Tier
	local totalKills = playerData.HonPhien.TotalKills

	return string.format("%s | %d/%d souls (%d%%) | Kills: %d",
		tier, current, max, percent, totalKills)
end

print("✅ HonPhienModule loaded (Full System)")
return HonPhienModule
