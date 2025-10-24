--[[
    ===========================================
    🎮 GAME TU TIÊN - AUTO INSTALLER
    ===========================================

    HƯỚNG DẪN SỬ DỤNG:

    1. Mở Roblox Studio
    2. Tạo New Place (Baseplate)
    3. Copy TOÀN BỘ script này
    4. Paste vào ServerScriptService (tạo script mới, paste vào)
    5. Click RUN (Play button) trong Studio
    6. Đợi console hiện "✅ Installation Complete!"
    7. Stop game, xóa script Installer này đi
    8. Save place

    Script sẽ tự động tạo:
    - Cấu trúc folders
    - Tất cả modules
    - Maps
    - UI
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")

print("===========================================")
print("🎮 GAME TU TIÊN - AUTO INSTALLER")
print("===========================================")
print("")
print("⏳ Đang cài đặt... Vui lòng đợi!")
print("")

-- ========================================
-- HELPER: TẠO FOLDER
-- ========================================

local function CreateFolder(parent, name)
    local folder = parent:FindFirstChild(name)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = parent
        print("📁 Created folder: " .. name)
    end
    return folder
end

-- ========================================
-- HELPER: TẠO MODULE SCRIPT
-- ========================================

local function CreateModuleScript(parent, name, source)
    local module = parent:FindFirstChild(name)
    if module then
        module:Destroy()
    end

    module = Instance.new("ModuleScript")
    module.Name = name
    module.Source = source
    module.Parent = parent
    print("📄 Created module: " .. name)

    return module
end

-- ========================================
-- HELPER: TẠO SCRIPT
-- ========================================

local function CreateScript(parent, name, source)
    local script = parent:FindFirstChild(name)
    if script then
        script:Destroy()
    end

    script = Instance.new("Script")
    script.Name = name
    script.Source = source
    script.Parent = parent
    print("📄 Created script: " .. name)

    return script
end

-- ========================================
-- HELPER: TẠO LOCAL SCRIPT
-- ========================================

local function CreateLocalScript(parent, name, source)
    local script = parent:FindFirstChild(name)
    if script then
        script:Destroy()
    end

    script = Instance.new("LocalScript")
    script.Name = name
    script.Source = source
    script.Parent = parent
    print("📄 Created local script: " .. name)

    return script
end

task.wait(1)

print("")
print("========================================")
print("BƯỚC 1: TẠO CẤU TRÚC FOLDERS")
print("========================================")
print("")

-- ReplicatedStorage structure
local DataFolder = CreateFolder(ReplicatedStorage, "Data")
local ModulesFolder = CreateFolder(ReplicatedStorage, "Modules")
local PlayerDataFolder = CreateFolder(ModulesFolder, "PlayerData")
local StatsFolder = CreateFolder(ModulesFolder, "Stats")
CreateFolder(ModulesFolder, "Combat")  -- Tạo sẵn cho sau

-- ServerScriptService structure
local ServicesFolder = CreateFolder(ServerScriptService, "Services")

task.wait(1)

print("")
print("========================================")
print("BƯỚC 2: TẠO DATA MODULES")
print("========================================")
print("")

-- Constants.lua (rút gọn cho demo)
local constantsSource = [[
local Constants = {}

Constants.CultivationType = {
    TIEN_THIEN = "TienThien",
    CO_THAN = "CoThan",
    MA_DAO = "MaDao"
}

Constants.BaseStats = {
    TienThien = {
        HP = 500, MP = 600, MagicDamage = 50, Defense = 30, MagicDefense = 40,
        Speed = 20, CritRate = 0.05, CritDamage = 1.5
    },
    CoThan = {
        HP = 800, MP = 0, PhysicalDamage = 80, Defense = 60, MagicDefense = 30,
        Speed = 12, CritRate = 0.03, CritDamage = 1.3
    },
    MaDao = {
        HP = 550, MP = 400, SoulDamage = 75, Defense = 35, MagicDefense = 35,
        Speed = 16, Lifesteal = 0.5, CritRate = 0.06, CritDamage = 1.6
    }
}

Constants.NgungKhiMultipliers = {1.0, 1.2, 1.4, 1.7, 2.0, 2.4, 2.8, 3.3, 4.0}

print("✅ Constants loaded")
return Constants
]]

CreateModuleScript(DataFolder, "Constants", constantsSource)

task.wait(0.5)

print("")
print("========================================")
print("BƯỚC 3: TẠO PLAYER DATA SYSTEM")
print("========================================")
print("")

-- PlayerDataTemplate.lua (rút gọn)
local playerDataSource = [[
local Constants = require(game.ReplicatedStorage.Data.Constants)

local PlayerDataTemplate = {}

function PlayerDataTemplate.CreateNew(cultivationType)
    cultivationType = cultivationType or Constants.CultivationType.TIEN_THIEN

    return {
        UserId = 0,
        DisplayName = "",
        CultivationType = cultivationType,
        CurrentRealm = 1,
        CurrentLevel = 1,
        TuViPoints = 0,
        Stats = {
            HP = 500, MaxHP = 500, MP = 600, MaxMP = 600,
            MagicDamage = 50, PhysicalDamage = 0, SoulDamage = 0,
            Defense = 30, MagicDefense = 40, Speed = 20,
            CritRate = 0.05, CritDamage = 1.5, Lifesteal = 0
        },
        Soul = {
            Power = 100,
            Quality = "Thuong",
            Stability = 100
        },
        Inventory = {
            TuKhiDan = 0, TienNgoc = 0, LinhThach = 0
        }
    }
end

print("✅ PlayerDataTemplate loaded")
return PlayerDataTemplate
]]

CreateModuleScript(PlayerDataFolder, "PlayerDataTemplate", playerDataSource)

task.wait(0.5)

print("")
print("========================================")
print("BƯỚC 4: TẠO STATS CALCULATOR")
print("========================================")
print("")

local statsCalcSource = [[
local Constants = require(game.ReplicatedStorage.Data.Constants)

local StatsCalculator = {}

function StatsCalculator.CalculateStats(playerData)
    local cultivationType = playerData.CultivationType
    local level = playerData.CurrentLevel

    local baseStats = Constants.BaseStats[cultivationType]
    local multiplier = Constants.NgungKhiMultipliers[level] or 1.0

    local newStats = {}
    newStats.MaxHP = math.floor((baseStats.HP or 500) * multiplier)
    newStats.HP = math.min(playerData.Stats.HP or newStats.MaxHP, newStats.MaxHP)
    newStats.MaxMP = math.floor((baseStats.MP or 0) * multiplier)
    newStats.MP = math.min(playerData.Stats.MP or newStats.MaxMP, newStats.MaxMP)

    newStats.MagicDamage = math.floor((baseStats.MagicDamage or 0) * multiplier)
    newStats.PhysicalDamage = math.floor((baseStats.PhysicalDamage or 0) * multiplier)
    newStats.SoulDamage = math.floor((baseStats.SoulDamage or 0) * multiplier)

    newStats.Defense = math.floor((baseStats.Defense or 30) * multiplier)
    newStats.MagicDefense = math.floor((baseStats.MagicDefense or 30) * multiplier)
    newStats.Speed = baseStats.Speed or 16
    newStats.CritRate = baseStats.CritRate or 0.05
    newStats.CritDamage = baseStats.CritDamage or 1.5
    newStats.Lifesteal = baseStats.Lifesteal or 0

    return newStats
end

print("✅ StatsCalculator loaded")
return StatsCalculator
]]

CreateModuleScript(StatsFolder, "StatsCalculator", statsCalcSource)

task.wait(0.5)

print("")
print("========================================")
print("BƯỚC 5: TẠO PLAYER DATA SERVICE")
print("========================================")
print("")

local playerServiceSource = [[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataTemplate = require(ReplicatedStorage.Modules.PlayerData.PlayerDataTemplate)
local StatsCalculator = require(ReplicatedStorage.Modules.Stats.StatsCalculator)

local PlayerDataService = {}
PlayerDataService.PlayerData = {}

function PlayerDataService.LoadData(player)
    local userId = player.UserId
    local data = PlayerDataTemplate.CreateNew("TienThien")
    data.UserId = userId
    data.DisplayName = player.Name
    data.Stats = StatsCalculator.CalculateStats(data)
    data.Stats.HP = data.Stats.MaxHP
    data.Stats.MP = data.Stats.MaxMP

    PlayerDataService.PlayerData[userId] = data
    print("✅ Loaded data for " .. player.Name)
    return data
end

function PlayerDataService.GetData(player)
    return PlayerDataService.PlayerData[player.UserId]
end

Players.PlayerAdded:Connect(function(player)
    print("👤 " .. player.Name .. " joined!")
    PlayerDataService.LoadData(player)

    player.CharacterAdded:Connect(function(character)
        wait(1)
        local data = PlayerDataService.GetData(player)
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and data then
            humanoid.MaxHealth = data.Stats.MaxHP
            humanoid.Health = data.Stats.HP
            humanoid.WalkSpeed = data.Stats.Speed
            print("✅ " .. player.Name .. " character setup complete")
        end
    end)
end)

print("✅ PlayerDataService loaded")
return PlayerDataService
]]

CreateScript(ServicesFolder, "PlayerDataService", playerServiceSource)

task.wait(0.5)

print("")
print("========================================")
print("BƯỚC 6: TẠO UI")
print("========================================")
print("")

local uiSource = [[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Constants = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("Constants"))
local StatsCalculator = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Stats"):WaitForChild("StatsCalculator"))

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatsUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.3
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "🎮 GAME TU TIÊN"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 20
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 1, -60)
infoLabel.Position = UDim2.new(0, 10, 0, 50)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = [[
👤 Player: ]] .. player.Name .. [[

⚔️ Hệ: Tiên Thiên
📊 Cảnh Giới: Ngưng Khí Tầng 1
❤️ HP: 500 / 500
💙 MP: 600 / 600
⚡ Magic Dmg: 50

✅ Game đã setup xong!
Chúc bạn tu tiên vui vẻ!
]]
infoLabel.TextColor3 = Color3.new(1, 1, 1)
infoLabel.TextSize = 14
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = mainFrame

print("✅ StatsUI loaded")


CreateLocalScript(StarterPlayerScripts, "StatsUI", uiSource)

task.wait(0.5)

print("")
print("========================================")
print("BƯỚC 7: TẠO MAPS (ĐƠN GIẢN)")
print("========================================")
print("")

local mapGenSource = [[
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

print("🗺️ Generating maps...")

-- Tạo Map 1: Rừng Linh Thú
local map1 = Instance.new("Folder")
map1.Name = "RungLinhThu"
map1.Parent = Workspace

local spawn1 = Instance.new("SpawnLocation")
spawn1.Name = "Spawn"
spawn1.Size = Vector3.new(10, 1, 10)
spawn1.Position = Vector3.new(0, 10, 0)
spawn1.Anchored = true
spawn1.BrickColor = BrickColor.new("Bright green")
spawn1.Material = Enum.Material.Neon
spawn1.Transparency = 0.5
spawn1.Parent = map1

-- Ground
local ground1 = Instance.new("Part")
ground1.Name = "Ground"
ground1.Size = Vector3.new(200, 1, 200)
ground1.Position = Vector3.new(0, 0, 0)
ground1.Anchored = true
ground1.BrickColor = BrickColor.new("Bright green")
ground1.Material = Enum.Material.Grass
ground1.Parent = map1

-- Một số cây đơn giản
for i = 1, 10 do
    local x = math.random(-80, 80)
    local z = math.random(-80, 80)

    local tree = Instance.new("Part")
    tree.Name = "Tree"
    tree.Size = Vector3.new(3, 15, 3)
    tree.Position = Vector3.new(x, 7.5, z)
    tree.Anchored = true
    tree.BrickColor = BrickColor.new("Brown")
    tree.Material = Enum.Material.Wood
    tree.Parent = map1

    local leaves = Instance.new("Part")
    leaves.Size = Vector3.new(8, 8, 8)
    leaves.Position = Vector3.new(x, 18, z)
    leaves.Anchored = true
    leaves.BrickColor = BrickColor.new("Bright green")
    leaves.Material = Enum.Material.Grass
    leaves.Shape = Enum.PartType.Ball
    leaves.Parent = map1
end

print("✅ Map created: Rừng Linh Thú")

-- Lighting
Lighting.Brightness = 2
Lighting.Ambient = Color3.fromRGB(150, 150, 150)
Lighting.ClockTime = 14

print("✅ Maps setup complete!")
]]

CreateScript(ServerScriptService, "MapGenerator", mapGenSource)

task.wait(1)

print("")
print("========================================")
print("✅ CÀI ĐẶT HOÀN TẤT!")
print("========================================")
print("")
print("📋 ĐÃ TẠO:")
print("  📁 ReplicatedStorage/Data/Constants")
print("  📁 ReplicatedStorage/Modules/PlayerData/PlayerDataTemplate")
print("  📁 ReplicatedStorage/Modules/Stats/StatsCalculator")
print("  📁 ServerScriptService/Services/PlayerDataService")
print("  📁 ServerScriptService/MapGenerator")
print("  📁 StarterPlayer/StarterPlayerScripts/StatsUI")
print("")
print("🎯 TIẾP THEO:")
print("  1. STOP game (Click nút Stop)")
print("  2. XÓA script 'Installer' này đi")
print("  3. SAVE place")
print("  4. Click PLAY để test!")
print("")
print("✨ Chúc bạn code vui vẻ! ✨")
print("========================================")

-- Auto tạo map sau 2 giây
task.wait(2)
print("")
print("🗺️ Đang tạo maps tự động...")

-- Script sẽ tự chạy MapGenerator
local mapGen = ServerScriptService:FindFirstChild("MapGenerator")
if mapGen then
    require(mapGen)
end
