# RobloxTT - Tu Tiên Game

Game tu tiên Roblox với hệ thống OOP và Rojo sync.

## Bắt Đầu Nhanh

### 1. Cài Rojo
```bash
# Download: https://github.com/rojo-rbx/rojo/releases
# Giải nén rojo.exe vào thư mục project
```

### 2. Start Server
```bash
cd d:\Roblox\RobloxTT
rojo serve default.project.json
```

### 3. Sync Vào Studio
1. Mở Roblox Studio
2. Cài Rojo plugin: https://www.roblox.com/library/13916111004/Rojo
3. Click Rojo icon → Connect → Sync In

### 4. Test Game
- Nhấn Play trong Studio
- Test phím: `I` (Inventory), `B` (Shop)

## Cấu Trúc Project

```
RobloxTT/
├── src/                       # Code chính (OOP structure)
│   ├── ReplicatedStorage/
│   │   └── Modules/
│   │       ├── UI/            # BaseUI, ButtonManager, UIManager
│   │       ├── Combat/
│   │       ├── Cultivation/
│   │       └── ...
│   ├── ServerScriptService/
│   └── StarterPlayer/
├── Assets/                    # Design assets
├── kichban/                   # Game design files
├── GAME_DESIGN.md            # Thiết kế game chi tiết
├── MIGRATION_GUIDE.md        # Hướng dẫn refactor UI
└── default.project.json      # Rojo config
```

## Tính Năng OOP Framework

### BaseUI - Base Class cho UI
```lua
local MyUI = setmetatable({}, {__index = BaseUI})

function MyUI.new()
    local self = BaseUI.new({
        Name = "MyUI",
        ToggleKey = Enum.KeyCode.X,
        RemoteEvents = {"Event1", "Event2"}
    })
    setmetatable(self, MyUI)
    return self
end
```

Tự động có:
- `Open()`, `Close()`, `Toggle()`
- `ShowSuccess()`, `ShowError()`, `ShowWarning()`
- `SetupInput()`, `SetupRemoteEvents()`

### ButtonManager - Tạo Buttons Nhanh
```lua
ButtonManager.CreateCloseButton(parent, onClick)
ButtonManager.CreatePrimaryButton(parent, "Save", position, onClick)
ButtonManager.CreateSuccessButton(parent, "Buy", position, onClick)
```

Tự động có: hover effect, click animation, debounce

### UIManager - Quản Lý Global
```lua
UIManager.Open("Inventory")
UIManager.CloseAll()
UIManager.ShowNotification("Message!", "success")
```

## UI Cần Refactor

Đã refactor:
- [x] InventoryUI
- [x] ShopUI

Cần refactor (dùng template trong MIGRATION_GUIDE.md):
- [ ] EquipmentUI
- [ ] QuestUI
- [ ] CultivationUI
- [ ] StatsUI
- [ ] AdminUI
- [ ] BossUI
- [ ] HonPhienAdvancedUI
- [ ] ThienKiepUI
- [ ] TanSatUI
- [ ] SkillshotCombatUI

## Tài Liệu

- **README.md** - File này (quick start)
- **GAME_DESIGN.md** - Thiết kế game chi tiết (hệ thống Hồn, tu luyện, maps, v.v.)
- **MIGRATION_GUIDE.md** - Hướng dẫn refactor UI với template
- **ADMIN_TESTING_GUIDE.md** - Admin commands để test game
- **MONETIZATION_SETUP.md** - Hướng dẫn bán items cho người chơi
- **WEAPON_SYSTEM_SUMMARY.md** - Tổng quan hệ thống vũ khí (START HERE ⭐)
- **WEAPON_EFFECTS_GUIDE.md** - Chi tiết OOP API và examples
- **EFFECTS_REFERENCE.md** - 34+ effects (EffectLibrary + AdvancedEffects) 🎨
- **MOBILE_CONTROLS_GUIDE.md** - Mobile controls (Joystick, Auto-target, Skills) 📱

## Development Workflow

1. Sửa code trong `src/`
2. Rojo tự động sync vào Studio
3. Test trong Studio
4. Commit: `git add . && git commit -m "message"`

## Tips

- Không sửa code trực tiếp trong Studio (Git không track được)
- Refactor từng UI một, test kỹ trước khi refactor UI tiếp theo
- Dùng template trong MIGRATION_GUIDE.md để refactor nhanh

## Game Design

Xem **GAME_DESIGN.md** cho:
- Hệ thống Hồn (Soul System)
- 3 hệ tu luyện (Tiên Thiên, Cổ Thần, Ma Đạo)
- Hệ thống khắc chế
- Maps và quái vật
- Hệ thống luyện đan
