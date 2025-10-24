-- MapGenerator.lua - Tạo 2 Maps Mẫu
-- Copy vào ServerScriptService/MapGenerator (Script)

local Workspace = game:GetService("Workspace")

local MapGenerator = {}

-- ========================================
-- CREATE MAP 1: RỪNG LINH THÚ
-- ========================================

function MapGenerator.CreateRungLinhThu()
	local mapFolder = Instance.new("Folder")
	mapFolder.Name = "RungLinhThu"
	mapFolder.Parent = Workspace

	-- Spawn Area (invisible marker)
	local spawnArea = Instance.new("Part")
	spawnArea.Name = "SpawnArea"
	spawnArea.Size = Vector3.new(100, 1, 100)
	spawnArea.Position = Vector3.new(0, 50, 0)
	spawnArea.Anchored = true
	spawnArea.Transparency = 1
	spawnArea.CanCollide = false
	spawnArea.Parent = mapFolder

	-- Ground
	local ground = Instance.new("Part")
	ground.Name = "Ground"
	ground.Size = Vector3.new(200, 1, 200)
	ground.Position = Vector3.new(0, 0, 0)
	ground.Anchored = true
	ground.BrickColor = BrickColor.new("Bright green")
	ground.Material = Enum.Material.Grass
	ground.Parent = mapFolder

	-- Spawn point for players
	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "SpawnLocation"
	spawnLocation.Size = Vector3.new(10, 1, 10)
	spawnLocation.Position = Vector3.new(0, 1, -80)
	spawnLocation.Anchored = true
	spawnLocation.BrickColor = BrickColor.new("Bright blue")
	spawnLocation.Transparency = 0.5
	spawnLocation.CanCollide = false
	spawnLocation.Parent = mapFolder

	-- Trees (random)
	for i = 1, 30 do
		local tree = Instance.new("Part")
		tree.Name = "Tree"
		tree.Size = Vector3.new(3, 15, 3)
		tree.Position = Vector3.new(
			math.random(-90, 90),
			7.5,
			math.random(-90, 90)
		)
		tree.Anchored = true
		tree.BrickColor = BrickColor.new("Brown")
		tree.Material = Enum.Material.Wood
		tree.Parent = mapFolder

		-- Leaves
		local leaves = Instance.new("Part")
		leaves.Name = "Leaves"
		leaves.Shape = Enum.PartType.Ball
		leaves.Size = Vector3.new(8, 8, 8)
		leaves.Position = tree.Position + Vector3.new(0, 10, 0)
		leaves.Anchored = true
		leaves.BrickColor = BrickColor.new("Dark green")
		leaves.Material = Enum.Material.Grass
		leaves.Parent = mapFolder
	end

	-- Rocks
	for i = 1, 20 do
		local rock = Instance.new("Part")
		rock.Name = "Rock"
		rock.Size = Vector3.new(
			math.random(2, 5),
			math.random(2, 4),
			math.random(2, 5)
		)
		rock.Position = Vector3.new(
			math.random(-90, 90),
			2,
			math.random(-90, 90)
		)
		rock.Anchored = true
		rock.BrickColor = BrickColor.new("Medium stone grey")
		rock.Material = Enum.Material.Rock
		rock.Parent = mapFolder
	end

	-- Sign
	local sign = Instance.new("Part")
	sign.Name = "Sign"
	sign.Size = Vector3.new(8, 6, 0.5)
	sign.Position = Vector3.new(0, 3, -70)
	sign.Anchored = true
	sign.BrickColor = BrickColor.new("Brown")
	sign.Parent = mapFolder

	local signGui = Instance.new("SurfaceGui")
	signGui.Face = Enum.NormalId.Front
	signGui.Parent = sign

	local signText = Instance.new("TextLabel")
	signText.Size = UDim2.new(1, 0, 1, 0)
	signText.BackgroundTransparency = 1
	signText.Text = "🌲 RỪNG LINH THÚ 🌲\nNewbie Area (Lv.1-3)\n\n⚡ Tiên Thiên: Ngưng Khí\n💪 Cổ Thần: 1-3 Sao\n🩸 Ma Đạo: 1-3 Tinh"
	signText.TextColor3 = Color3.fromRGB(255, 255, 255)
	signText.TextScaled = true
	signText.Font = Enum.Font.SourceSansBold
	signText.Parent = signGui

	print("✅ Created map: Rừng Linh Thú")
end

-- ========================================
-- CREATE MAP 2: HUYỀN THIÊN SƠN
-- ========================================

function MapGenerator.CreateHuyenThienSon()
	local mapFolder = Instance.new("Folder")
	mapFolder.Name = "HuyenThienSon"
	mapFolder.Parent = Workspace

	-- Spawn Area
	local spawnArea = Instance.new("Part")
	spawnArea.Name = "SpawnArea"
	spawnArea.Size = Vector3.new(100, 1, 100)
	spawnArea.Position = Vector3.new(300, 100, 0)
	spawnArea.Anchored = true
	spawnArea.Transparency = 1
	spawnArea.CanCollide = false
	spawnArea.Parent = mapFolder

	-- Ground (mountain style)
	local ground = Instance.new("Part")
	ground.Name = "Ground"
	ground.Size = Vector3.new(200, 5, 200)
	ground.Position = Vector3.new(300, 50, 0)
	ground.Anchored = true
	ground.BrickColor = BrickColor.new("Medium stone grey")
	ground.Material = Enum.Material.Rock
	ground.Parent = mapFolder

	-- Spawn point
	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "SpawnLocation"
	spawnLocation.Size = Vector3.new(10, 1, 10)
	spawnLocation.Position = Vector3.new(300, 53, -80)
	spawnLocation.Anchored = true
	spawnLocation.BrickColor = BrickColor.new("Bright blue")
	spawnLocation.Transparency = 0.5
	spawnLocation.CanCollide = false
	spawnLocation.Parent = mapFolder

	-- Mountain peaks
	for i = 1, 10 do
		local peak = Instance.new("Part")
		peak.Name = "Peak"
		peak.Size = Vector3.new(
			math.random(10, 20),
			math.random(30, 60),
			math.random(10, 20)
		)
		peak.Position = Vector3.new(
			300 + math.random(-80, 80),
			math.random(60, 90),
			math.random(-80, 80)
		)
		peak.Anchored = true
		peak.BrickColor = BrickColor.new("Dark stone grey")
		peak.Material = Enum.Material.Slate
		peak.Parent = mapFolder
	end

	-- Floating platforms
	for i = 1, 15 do
		local platform = Instance.new("Part")
		platform.Name = "Platform"
		platform.Size = Vector3.new(
			math.random(8, 15),
			2,
			math.random(8, 15)
		)
		platform.Position = Vector3.new(
			300 + math.random(-90, 90),
			math.random(60, 120),
			math.random(-90, 90)
		)
		platform.Anchored = true
		platform.BrickColor = BrickColor.new("Cyan")
		platform.Material = Enum.Material.Neon
		platform.Transparency = 0.3
		platform.Parent = mapFolder
	end

	-- Crystals
	for i = 1, 20 do
		local crystal = Instance.new("Part")
		crystal.Name = "Crystal"
		crystal.Size = Vector3.new(2, 8, 2)
		crystal.Position = Vector3.new(
			300 + math.random(-90, 90),
			56,
			math.random(-90, 90)
		)
		crystal.Anchored = true
		crystal.BrickColor = BrickColor.new("Bright blue")
		crystal.Material = Enum.Material.Neon
		crystal.Transparency = 0.4
		crystal.Parent = mapFolder
	end

	-- Sign
	local sign = Instance.new("Part")
	sign.Name = "Sign"
	sign.Size = Vector3.new(10, 8, 0.5)
	sign.Position = Vector3.new(300, 57, -70)
	sign.Anchored = true
	sign.BrickColor = BrickColor.new("Really black")
	sign.Material = Enum.Material.Neon
	sign.Parent = mapFolder

	local signGui = Instance.new("SurfaceGui")
	signGui.Face = Enum.NormalId.Front
	signGui.Parent = sign

	local signText = Instance.new("TextLabel")
	signText.Size = UDim2.new(1, 0, 1, 0)
	signText.BackgroundTransparency = 1
	signText.Text = "⛰️ HUYỀN THIÊN SƠN ⛰️\nMid Area (Lv.Trúc Cơ)\n\n⚡ Tiên Thiên: Trúc Cơ 1-3\n💪 Cổ Thần: Cổ Ma 1-3 Sao\n🩸 Ma Đạo: Ma Tôn 1-3 Tinh"
	signText.TextColor3 = Color3.fromRGB(100, 200, 255)
	signText.TextScaled = true
	signText.Font = Enum.Font.SourceSansBold
	signText.Parent = signGui

	print("✅ Created map: Huyền Thiên Sơn")
end

-- ========================================
-- PORTAL BETWEEN MAPS
-- ========================================

function MapGenerator.CreatePortal(name, position, destination, color)
	local portal = Instance.new("Part")
	portal.Name = name
	portal.Size = Vector3.new(10, 15, 2)
	portal.Position = position
	portal.Anchored = true
	portal.CanCollide = false
	portal.BrickColor = BrickColor.new(color)
	portal.Material = Enum.Material.Neon
	portal.Transparency = 0.3
	portal.Parent = Workspace

	-- Portal effect
	local light = Instance.new("PointLight")
	light.Brightness = 5
	light.Range = 20
	light.Color = portal.Color
	light.Parent = portal

	-- Touch to teleport
	portal.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid then
			local character = hit.Parent
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = CFrame.new(destination)
			end
		end
	end)

	-- Sign
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(0, 200, 0, 50)
	billboardGui.StudsOffset = Vector3.new(0, 8, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = portal

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.Parent = billboardGui
end

-- ========================================
-- INITIALIZE
-- ========================================

MapGenerator.CreateRungLinhThu()
wait(1)
MapGenerator.CreateHuyenThienSon()
wait(1)

-- Create portals
MapGenerator.CreatePortal(
	"Portal to Huyền Thiên Sơn",
	Vector3.new(80, 2, 0),
	Vector3.new(220, 53, 0),
	"Bright blue"
)

MapGenerator.CreatePortal(
	"Portal to Rừng Linh Thú",
	Vector3.new(220, 53, 0),
	Vector3.new(80, 2, 0),
	"Bright green"
)

print("✅ MapGenerator complete! 2 maps created with portals!")
return MapGenerator
