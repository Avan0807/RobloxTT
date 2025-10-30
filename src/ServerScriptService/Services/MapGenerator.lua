-- MapGenerator.lua - Tạo 2 Maps cho Game Tu Luyện
-- Copy vào ServerScriptService/MapGenerator (Script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Get EnemyService from global services (loaded by init.server.lua)
local function GetEnemyService()
	return _G.Services and _G.Services.EnemyService
end

-- ========================================
-- MAP GENERATOR
-- ========================================

local MapGenerator = {}

-- ========================================
-- CREATE RỪNG LINH THÚ (Map 1 - Beginner)
-- ========================================

function MapGenerator.CreateRungLinhThu()
	local map = Instance.new("Folder")
	map.Name = "RungLinhThu"

	-- Ground (100×100 grass terrain)
	local ground = Instance.new("Part")
	ground.Name = "Ground"
	ground.Size = Vector3.new(200, 2, 200)
	ground.Position = Vector3.new(0, 0, 0)
	ground.Anchored = true
	ground.Color = Color3.fromRGB(107, 142, 35)
	ground.Material = Enum.Material.Grass
	ground.Parent = map

	-- Spawn location for players
	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "PlayerSpawn"
	spawnLocation.Size = Vector3.new(10, 1, 10)
	spawnLocation.Position = Vector3.new(0, 3, 0)
	spawnLocation.Anchored = true
	spawnLocation.Color = Color3.fromRGB(100, 200, 255)
	spawnLocation.Material = Enum.Material.Neon
	spawnLocation.BrickColor = BrickColor.new("Bright blue")
	spawnLocation.Transparency = 0.5
	spawnLocation.CanCollide = false
	spawnLocation.Duration = 0
	spawnLocation.Parent = map

	-- Trees (decoration)
	local treesFolder = Instance.new("Folder")
	treesFolder.Name = "Trees"
	treesFolder.Parent = map

	for i = 1, 20 do
		local tree = Instance.new("Model")
		tree.Name = "Tree" .. i

		-- Trunk
		local trunk = Instance.new("Part")
		trunk.Name = "Trunk"
		trunk.Size = Vector3.new(2, 10, 2)
		trunk.Position = Vector3.new(
			math.random(-80, 80),
			6,
			math.random(-80, 80)
		)
		trunk.Anchored = true
		trunk.Color = Color3.fromRGB(101, 67, 33)
		trunk.Material = Enum.Material.Wood
		trunk.Parent = tree

		-- Leaves
		local leaves = Instance.new("Part")
		leaves.Name = "Leaves"
		leaves.Size = Vector3.new(8, 8, 8)
		leaves.Position = trunk.Position + Vector3.new(0, 8, 0)
		leaves.Anchored = true
		leaves.Color = Color3.fromRGB(34, 139, 34)
		leaves.Material = Enum.Material.Grass
		leaves.Shape = Enum.PartType.Ball
		leaves.Parent = tree

		tree.Parent = treesFolder
	end

	-- Rocks (decoration)
	local rocksFolder = Instance.new("Folder")
	rocksFolder.Name = "Rocks"
	rocksFolder.Parent = map

	for i = 1, 15 do
		local rock = Instance.new("Part")
		rock.Name = "Rock" .. i
		rock.Size = Vector3.new(
			math.random(3, 6),
			math.random(2, 4),
			math.random(3, 6)
		)
		rock.Position = Vector3.new(
			math.random(-90, 90),
			rock.Size.Y / 2 + 1,
			math.random(-90, 90)
		)
		rock.Anchored = true
		rock.Color = Color3.fromRGB(163, 162, 165)
		rock.Material = Enum.Material.Rock
		rock.Parent = rocksFolder
	end

	-- Enemy spawn points
	local enemySpawns = Instance.new("Folder")
	enemySpawns.Name = "EnemySpawns"
	enemySpawns.Parent = map

	-- Spawn 10 enemy locations
	local spawnPositions = {
		Vector3.new(30, 3, 30),
		Vector3.new(-30, 3, 30),
		Vector3.new(30, 3, -30),
		Vector3.new(-30, 3, -30),
		Vector3.new(50, 3, 0),
		Vector3.new(-50, 3, 0),
		Vector3.new(0, 3, 50),
		Vector3.new(0, 3, -50),
		Vector3.new(40, 3, 40),
		Vector3.new(-40, 3, -40)
	}

	for i, pos in ipairs(spawnPositions) do
		local spawn = Instance.new("Part")
		spawn.Name = "Spawn" .. i
		spawn.Size = Vector3.new(3, 1, 3)
		spawn.Position = pos
		spawn.Anchored = true
		spawn.Transparency = 1 -- Invisible
		spawn.CanCollide = false
		spawn.Parent = enemySpawns
	end

	-- Portal to Map 2
	local portal = Instance.new("Part")
	portal.Name = "PortalToHuyenThienSon"
	portal.Size = Vector3.new(6, 10, 1)
	portal.Position = Vector3.new(0, 6, 95)
	portal.Anchored = true
	portal.Color = Color3.fromRGB(138, 43, 226)
	portal.Material = Enum.Material.Neon
	portal.Transparency = 0.3
	portal.CanCollide = false
	portal.Parent = map

	-- Portal sign
	local sign = Instance.new("Part")
	sign.Size = Vector3.new(10, 4, 0.2)
	sign.Position = portal.Position + Vector3.new(0, 7, 0)
	sign.Anchored = true
	sign.Color = Color3.fromRGB(139, 69, 19)
	sign.Material = Enum.Material.Wood
	sign.Parent = map

	local signGui = Instance.new("SurfaceGui")
	signGui.Face = Enum.NormalId.Front
	signGui.Parent = sign

	local signText = Instance.new("TextLabel")
	signText.Size = UDim2.new(1, 0, 1, 0)
	signText.BackgroundTransparency = 1
	signText.Text = "HUYỀN THIÊN SƠN\n(Level 10+)"
	signText.TextColor3 = Color3.fromRGB(255, 255, 255)
	signText.TextScaled = true
	signText.Font = Enum.Font.SourceSansBold
	signText.Parent = signGui

	-- Lighting
	local lighting = game:GetService("Lighting")
	lighting.Ambient = Color3.fromRGB(100, 120, 100)
	lighting.OutdoorAmbient = Color3.fromRGB(120, 140, 120)
	lighting.Brightness = 2

	map.Parent = workspace

	print("✅ Created map: Rừng Linh Thú")

	return map
end

-- ========================================
-- CREATE HUYỀN THIÊN SƠN (Map 2 - Advanced)
-- ========================================

function MapGenerator.CreateHuyenThienSon()
	local map = Instance.new("Folder")
	map.Name = "HuyenThienSon"

	-- Main ground (mountains)
	local ground = Instance.new("Part")
	ground.Name = "Ground"
	ground.Size = Vector3.new(250, 2, 250)
	ground.Position = Vector3.new(300, 0, 0)
	ground.Anchored = true
	ground.Color = Color3.fromRGB(156, 156, 156)
	ground.Material = Enum.Material.Rock
	ground.Parent = map

	-- Mountain peaks
	local peaksFolder = Instance.new("Folder")
	peaksFolder.Name = "Peaks"
	peaksFolder.Parent = map

	for i = 1, 5 do
		local peak = Instance.new("Part")
		peak.Name = "Peak" .. i
		peak.Size = Vector3.new(20, math.random(30, 60), 20)
		peak.Position = Vector3.new(
			300 + math.random(-100, 100),
			peak.Size.Y / 2 + 1,
			math.random(-100, 100)
		)
		peak.Anchored = true
		peak.Color = Color3.fromRGB(121, 121, 121)
		peak.Material = Enum.Material.Rock
		peak.Parent = peaksFolder
	end

	-- Floating platforms (cultivation areas)
	local platformsFolder = Instance.new("Folder")
	platformsFolder.Name = "FloatingPlatforms"
	platformsFolder.Parent = map

	local platformPositions = {
		Vector3.new(280, 20, 0),
		Vector3.new(320, 30, 20),
		Vector3.new(300, 40, -20),
		Vector3.new(260, 25, 30),
		Vector3.new(340, 35, -30)
	}

	for i, pos in ipairs(platformPositions) do
		local platform = Instance.new("Part")
		platform.Name = "Platform" .. i
		platform.Size = Vector3.new(15, 2, 15)
		platform.Position = pos
		platform.Anchored = true
		platform.Color = Color3.fromRGB(186, 218, 255)
		platform.Material = Enum.Material.Marble
		platform.Parent = platformsFolder

		-- Glow effect
		local light = Instance.new("PointLight")
		light.Brightness = 2
		light.Range = 30
		light.Color = Color3.fromRGB(100, 200, 255)
		light.Parent = platform
	end

	-- Spawn location
	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "PlayerSpawn"
	spawnLocation.Size = Vector3.new(10, 1, 10)
	spawnLocation.Position = Vector3.new(300, 3, 0)
	spawnLocation.Anchored = true
	spawnLocation.Color = Color3.fromRGB(100, 200, 255)
	spawnLocation.Material = Enum.Material.Neon
	spawnLocation.BrickColor = BrickColor.new("Bright blue")
	spawnLocation.Transparency = 0.5
	spawnLocation.CanCollide = false
	spawnLocation.Duration = 0
	spawnLocation.Parent = map

	-- Crystal formations
	local crystalsFolder = Instance.new("Folder")
	crystalsFolder.Name = "Crystals"
	crystalsFolder.Parent = map

	for i = 1, 20 do
		local crystal = Instance.new("Part")
		crystal.Name = "Crystal" .. i
		crystal.Size = Vector3.new(2, math.random(4, 8), 2)
		crystal.Position = Vector3.new(
			300 + math.random(-110, 110),
			crystal.Size.Y / 2 + 2,
			math.random(-110, 110)
		)
		crystal.Anchored = true
		crystal.Color = Color3.fromRGB(100, 200, 255)
		crystal.Material = Enum.Material.Neon
		crystal.Transparency = 0.3
		crystal.Parent = crystalsFolder

		-- Sparkle light
		local light = Instance.new("PointLight")
		light.Brightness = 1.5
		light.Range = 15
		light.Color = Color3.fromRGB(100, 200, 255)
		light.Parent = crystal
	end

	-- Enemy spawn points
	local enemySpawns = Instance.new("Folder")
	enemySpawns.Name = "EnemySpawns"
	enemySpawns.Parent = map

	local spawnPositions = {
		Vector3.new(330, 3, 30),
		Vector3.new(270, 3, 30),
		Vector3.new(330, 3, -30),
		Vector3.new(270, 3, -30),
		Vector3.new(350, 3, 0),
		Vector3.new(250, 3, 0),
		Vector3.new(300, 3, 50),
		Vector3.new(300, 3, -50),
		Vector3.new(340, 3, 40),
		Vector3.new(260, 3, -40)
	}

	for i, pos in ipairs(spawnPositions) do
		local spawn = Instance.new("Part")
		spawn.Name = "Spawn" .. i
		spawn.Size = Vector3.new(3, 1, 3)
		spawn.Position = pos
		spawn.Anchored = true
		spawn.Transparency = 1
		spawn.CanCollide = false
		spawn.Parent = enemySpawns
	end

	-- Portal back to Map 1
	local portal = Instance.new("Part")
	portal.Name = "PortalToRungLinhThu"
	portal.Size = Vector3.new(6, 10, 1)
	portal.Position = Vector3.new(300, 6, -120)
	portal.Anchored = true
	portal.Color = Color3.fromRGB(50, 200, 50)
	portal.Material = Enum.Material.Neon
	portal.Transparency = 0.3
	portal.CanCollide = false
	portal.Parent = map

	-- Portal sign
	local sign = Instance.new("Part")
	sign.Size = Vector3.new(10, 4, 0.2)
	sign.Position = portal.Position + Vector3.new(0, 7, 0)
	sign.Anchored = true
	sign.Color = Color3.fromRGB(139, 69, 19)
	sign.Material = Enum.Material.Wood
	sign.Parent = map

	local signGui = Instance.new("SurfaceGui")
	signGui.Face = Enum.NormalId.Front
	signGui.Parent = sign

	local signText = Instance.new("TextLabel")
	signText.Size = UDim2.new(1, 0, 1, 0)
	signText.BackgroundTransparency = 1
	signText.Text = "RỪNG LINH THÚ\n(Trở về)"
	signText.TextColor3 = Color3.fromRGB(255, 255, 255)
	signText.TextScaled = true
	signText.Font = Enum.Font.SourceSansBold
	signText.Parent = signGui

	-- Skybox effect
	local lighting = game:GetService("Lighting")
	lighting.Ambient = Color3.fromRGB(80, 100, 120)
	lighting.OutdoorAmbient = Color3.fromRGB(100, 120, 150)
	lighting.Brightness = 1.5

	map.Parent = workspace

	print("✅ Created map: Huyền Thiên Sơn")

	return map
end

-- ========================================
-- PORTAL TELEPORT SYSTEM
-- ========================================

local function SetupPortalTeleport(portal, targetPosition)
	portal.Touched:Connect(function(hit)
		local character = hit.Parent
		if character and character:FindFirstChild("Humanoid") then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				-- Teleport
				hrp.CFrame = CFrame.new(targetPosition)
				print("🌀", character.Name, "teleported to", portal.Name)
			end
		end
	end)
end

-- ========================================
-- INITIALIZE MAPS
-- ========================================

function MapGenerator.Initialize()
	-- Create maps
	local map1 = MapGenerator.CreateRungLinhThu()
	local map2 = MapGenerator.CreateHuyenThienSon()

	-- Setup portals
	local portal1 = map1:FindFirstChild("PortalToHuyenThienSon")
	local portal2 = map2:FindFirstChild("PortalToRungLinhThu")

	if portal1 then
		SetupPortalTeleport(portal1, Vector3.new(300, 5, 0))
	end

	if portal2 then
		SetupPortalTeleport(portal2, Vector3.new(0, 5, 0))
	end

	-- Auto-spawn enemies
	wait(2)
	local EnemyService = GetEnemyService()
	if EnemyService and EnemyService.AutoSpawnForMap then
		EnemyService.AutoSpawnForMap("RungLinhThu", map1)
		EnemyService.AutoSpawnForMap("HuyenThienSon", map2)
	else
		warn("⚠️ EnemyService not available for auto-spawn")
	end

	print("✅ MapGenerator initialized with 2 maps!")
end

-- Auto-initialize on script load
task.delay(1, function()
	MapGenerator.Initialize()
end)

return MapGenerator
