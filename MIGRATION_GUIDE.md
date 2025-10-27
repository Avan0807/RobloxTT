# 🔄 Migration Guide - Từ FINAL_BUILD sang Rojo

## ⚡ Quick Start (5 phút)

### 1. Cài Rojo

```bash
# Download từ: https://rojo.space/

# Hoặc dùng Aftman:
aftman add rojo-rbx/rojo
```

### 2. Start Server

```bash
cd d:\Roblox\RobloxTT
rojo serve default.project.json
```

### 3. Sync Vào Studio

1. Mở Roblox Studio
2. Cài plugin: [Rojo Plugin](https://www.roblox.com/library/13916111004/Rojo)
3. Click **Rojo** icon → **Connect** → **Sync In**

**✅ DONE!** Toàn bộ `src/` đã sync vào game!

---

## 📂 So Sánh Cấu Trúc

### ❌ Cũ (FINAL_BUILD)

```
FINAL_BUILD/
├── 1_ReplicatedStorage/      # Prefix số, không chuẩn
├── 2_ServerScriptService/
└── 3_StarterPlayerScripts/
```

### ✅ Mới (src/ với Rojo)

```
src/
├── ReplicatedStorage/         # Chuẩn Rojo
├── ServerScriptService/
└── StarterPlayer/
```

---

## 🔧 Refactor UI - Step by Step

### Example: InventoryUI

#### ❌ Trước (509 dòng)

```lua
-- FINAL_BUILD/3_StarterPlayerScripts/InventoryUI.lua

local InventoryUI = {}
InventoryUI.IsOpen = false

function InventoryUI.CreateUI()
    -- 100+ dòng tạo UI...
end

function InventoryUI.Open()
    InventoryUI.IsOpen = true
    mainFrame.Visible = true
end

function InventoryUI.Close()
    InventoryUI.IsOpen = false
    mainFrame.Visible = false
end

function InventoryUI.Toggle()
    if InventoryUI.IsOpen then
        InventoryUI.Close()
    else
        InventoryUI.Open()
    end
end

function InventoryUI.ShowNotification(message)
    -- 40+ dòng tạo notification...
end

function InventoryUI.SetupInput()
    -- 20+ dòng setup input...
end

function InventoryUI.SetupRemoteEvents()
    -- 50+ dòng setup remote events...
end

-- ... 300+ dòng nữa
```

#### ✅ Sau (300 dòng, -41%)

```lua
-- src/StarterPlayer/StarterPlayerScripts/UI/InventoryUI.lua

local BaseUI = require(ReplicatedStorage.Modules.UI.BaseUI)
local ButtonManager = require(ReplicatedStorage.Modules.UI.ButtonManager)

local InventoryUI = setmetatable({}, {__index = BaseUI})

function InventoryUI.new()
    local self = BaseUI.new({
        Name = "InventoryUI",
        ToggleKey = Enum.KeyCode.I,
        RemoteEvents = {"SyncInventory", "UseItem"}
    })
    setmetatable(self, InventoryUI)
    return self
end

function InventoryUI:CreateMainFrame(parent)
    -- Chỉ tạo UI specific cho Inventory
    local mainFrame = self:CreateFrame({...})

    ButtonManager.CreateCloseButton(mainFrame, function()
        self:Close()
    end)

    return mainFrame
end

-- OnOpen, OnClose, Toggle, ShowNotification, SetupInput
-- -> TẤT CẢ đã có sẵn từ BaseUI!

local inventoryUI = InventoryUI.new()
inventoryUI:Initialize()
UIManager.Register("Inventory", inventoryUI)
```

---

## 📋 Checklist Migration

### Đã Refactor ✅

- [x] BaseUI.lua - Base class
- [x] ButtonManager.lua - Button utilities
- [x] UIManager.lua - UI management
- [x] InventoryUI.lua - Refactored (-41% code)
- [x] ShopUI.lua - Refactored (-50% code)

### Cần Refactor 🔄

- [ ] EquipmentUI.lua
- [ ] QuestUI.lua
- [ ] CultivationUI.lua
- [ ] StatsUI.lua
- [ ] AdminUI.lua
- [ ] BossUI.lua
- [ ] HonPhienAdvancedUI.lua
- [ ] ThienKiepUI.lua
- [ ] TanSatUI.lua
- [ ] SkillshotCombatUI.lua
- [ ] MobileControls.lua
- [ ] AimingSystem.lua

### Template Refactor UI

```lua
local BaseUI = require(ReplicatedStorage.Modules.UI.BaseUI)
local ButtonManager = require(ReplicatedStorage.Modules.UI.ButtonManager)
local UIManager = require(ReplicatedStorage.Modules.UI.UIManager)

local YourUI = setmetatable({}, {__index = BaseUI})
YourUI.__index = YourUI

function YourUI.new()
    local self = BaseUI.new({
        Name = "YourUI",
        ToggleKey = Enum.KeyCode.X,  -- Hotkey
        RemoteEvents = {"Event1", "Event2"}  -- List remote events
    })
    setmetatable(self, YourUI)
    return self
end

function YourUI:CreateMainFrame(parent)
    local mainFrame = self:CreateFrame({
        Parent = parent,
        Size = UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150),
        CornerRadius = 10
    })

    -- Your UI elements here...

    ButtonManager.CreateCloseButton(mainFrame, function()
        self:Close()
    end)

    return mainFrame
end

-- Override hooks if needed
function YourUI:OnOpen()
    -- Called when UI opens
end

function YourUI:OnClose()
    -- Called when UI closes
end

-- Remote event handlers (auto-connected if named On{EventName})
function YourUI:OnEvent1(data)
    -- Handles "Event1" remote event
end

local yourUI = YourUI.new()
yourUI:Initialize()
UIManager.Register("YourUI", yourUI)

return yourUI
```

---

## 🗺️ Map Cleanup

### ❌ Xóa Maps Cũ

```
Assets/Kiếm Design/  -> XÓA (chỉ design assets)
```

### ✅ Giữ Lại

```
src/Workspace/Maps/TestMap/  -> Map test cơ bản
```

### Tạo Map Mới Qua Rojo

```lua
-- src/Workspace/Maps/NewMap/Ground.lua
return function(parent)
    local ground = Instance.new("Part")
    ground.Size = Vector3.new(200, 1, 200)
    ground.Anchored = true
    ground.Parent = parent
    return ground
end
```

---

## 🚨 Breaking Changes

### 1. Import Paths

#### ❌ Cũ
```lua
local Module = require(ReplicatedStorage.Modules.Cultivation.CultivationModule)
```

#### ✅ Mới (Giống nhau, nhưng qua Rojo)
```lua
local Module = require(ReplicatedStorage.Modules.Cultivation.CultivationModule)
```

### 2. UI Initialization

#### ❌ Cũ
```lua
-- Auto-run at bottom of file
InventoryUI.Initialize()
```

#### ✅ Mới
```lua
local inventoryUI = InventoryUI.new()
inventoryUI:Initialize()
UIManager.Register("Inventory", inventoryUI)
```

### 3. Remote Events

#### ❌ Cũ
```lua
function InventoryUI.SetupRemoteEvents()
    local syncInventory = remoteEvents:WaitForChild("SyncInventory")
    syncInventory.OnClientEvent:Connect(function(data)
        InventoryUI.UpdateInventory(data)
    end)
end
```

#### ✅ Mới (Auto-connected)
```lua
-- Chỉ cần define handler với tên On{EventName}
function InventoryUI:OnSyncInventory(data)
    self:UpdateInventory(data)
end
```

---

## 📚 Next Steps

1. **Refactor còn lại các UI** - Dùng template ở trên
2. **Test từng UI** - Ensure mọi thứ hoạt động
3. **Xóa FINAL_BUILD** - Sau khi migrate xong
4. **Commit to Git** - Version control

---

## 💡 Tips

- Refactor từng UI một, test kỹ trước khi sang UI khác
- Dùng `UIManager.PrintStatus()` để debug
- Nếu có lỗi, check Output window trong Studio
- Rojo auto-sync, nhưng đôi khi cần **Sync In** thủ công

---

**Good luck! 🚀**
