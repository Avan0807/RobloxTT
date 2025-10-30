-- init.server.lua - Main Server Initialization Script
-- This script loads and initializes all game services

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🚀 Server initializing...")

-- ========================================
-- WAIT FOR ESSENTIAL FOLDERS
-- ========================================

local function WaitForChild(parent, childName, timeout)
	local startTime = tick()
	while not parent:FindFirstChild(childName) do
		if timeout and (tick() - startTime) > timeout then
			warn("⚠️ Timeout waiting for " .. parent:GetFullName() .. "." .. childName)
			return nil
		end
		wait(0.1)
	end
	return parent:FindFirstChild(childName)
end

-- Wait for essential folders
local Services = WaitForChild(ServerScriptService, "Services", 10)
local Modules = WaitForChild(ReplicatedStorage, "Modules", 10)
local RemoteEvents = WaitForChild(ReplicatedStorage, "RemoteEvents", 10)

if not Services then
	error("❌ Services folder not found in ServerScriptService!")
end

if not Modules then
	error("❌ Modules folder not found in ReplicatedStorage!")
end

print("✅ Essential folders loaded")

-- ========================================
-- LOAD ALL SERVICES
-- ========================================

local loadedServices = {}

local function LoadService(serviceName)
	local serviceModule = Services:FindFirstChild(serviceName)
	if serviceModule then
		local success, service = pcall(function()
			return require(serviceModule)
		end)

		if success then
			loadedServices[serviceName] = service

			-- Initialize if it has an Initialize function
			if service.Initialize and typeof(service.Initialize) == "function" then
				local initSuccess, initError = pcall(function()
					service.Initialize()
				end)

				if initSuccess then
					print("✅ " .. serviceName .. " initialized")
				else
					warn("⚠️ " .. serviceName .. " initialization failed: " .. tostring(initError))
				end
			else
				print("✅ " .. serviceName .. " loaded (no Initialize function)")
			end

			return true
		else
			warn("❌ Failed to require " .. serviceName .. ": " .. tostring(service))
			return false
		end
	else
		warn("⚠️ " .. serviceName .. " not found in Services folder")
		return false
	end
end

-- Load services in order (some depend on others)
print("\n📦 Loading Services...")

-- Core services first
LoadService("PlayerDataService")
LoadService("DataStoreService")

-- Admin service (IMPORTANT for testing)
LoadService("AdminService")

-- Player protection (MUST load before combat systems)
LoadService("SpawnProtectionService")

-- Game systems
LoadService("InventoryService")
LoadService("EquipmentService")
LoadService("ShopService")
-- LoadService("QuestService")  -- TEMPORARILY DISABLED - has errors
LoadService("LootService")

-- Combat systems
LoadService("SkillService")
LoadService("EnemyService")
LoadService("BossService")
LoadService("ProjectileService")

-- Cultivation systems
LoadService("HonPhienAdvancedService")
LoadService("ThienKiepService")
LoadService("TanSatService")

-- Monetization
LoadService("MonetizationService")

-- Map generation
LoadService("MapGenerator")

print("\n✅ All services loaded!")
print("📊 Loaded " .. #loadedServices .. " services")

-- ========================================
-- EXPOSE SERVICES GLOBALLY (Optional)
-- ========================================

_G.Services = loadedServices

print("\n🎮 Server ready!")
print("🔧 Admin commands enabled in Studio")
print("💬 Use /help to see all admin commands")
print("=" .. string.rep("=", 50))
