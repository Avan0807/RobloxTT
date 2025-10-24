# 🎯 SKILLSHOT SYSTEM - Setup Guide

## Tổng Quan

Hệ thống SKILLSHOT biến game từ hệ thống combat target-lock truyền thống sang **action-based combat** với:
- ✅ Skillshots (kỹ năng phóng theo hướng ngắm)
- ✅ Dodge/Dash với i-frames (khung hình bất tử)
- ✅ Hệ thống ngắm cho cả PC (chuột) và Mobile (touch)
- ✅ Joystick điều khiển cho Mobile
- ✅ Stamina system cho dodge
- ✅ Projectile physics với hit detection
- ✅ Visual effects (particles, trails, explosions)

---

## 📁 Cấu Trúc Thư Mục

```
ReplicatedStorage/
├── Modules/
│   ├── Combat/
│   │   ├── ProjectileModule (ModuleScript) ← Mới
│   │   └── DodgeSystem (ModuleScript) ← Mới
│   ├── Skills/
│   │   └── SkillsModule (ModuleScript) ← Đã có từ FULL_SYSTEM
│   └── Stats/
│       └── RealmCalculator (ModuleScript) ← Đã có từ FULL_SYSTEM
└── RemoteEvents/ (Folder)
    ├── FireSkill (RemoteEvent) ← Mới
    ├── CreateProjectile (RemoteEvent) ← Mới
    ├── ShowDamage (RemoteEvent) ← Mới
    ├── Dodge (RemoteEvent) ← Mới
    ├── LevelUp (RemoteEvent) ← Đã có
    ├── Breakthrough (RemoteEvent) ← Đã có
    └── StartMeditation (RemoteEvent) ← Đã có

ServerScriptService/
├── PlayerDataService (Script) ← Đã có từ FULL_SYSTEM
├── ProjectileService (Script) ← Mới
├── EnemyService (Script) ← Đã có
└── MapGenerator (Script) ← Đã có

StarterPlayer/
└── StarterPlayerScripts/
    ├── AimingSystem (LocalScript) ← Mới
    ├── MobileControls (LocalScript) ← Mới
    ├── SkillshotCombatUI (LocalScript) ← Mới (thay thế CombatUI)
    ├── CultivationUI (LocalScript) ← Đã có
    └── StatsUI (LocalScript) ← Đã có
```

---

## 🔧 Hướng Dẫn Cài Đặt

### Bước 1: Tạo Folder Structure

1. Mở Roblox Studio
2. Trong `ReplicatedStorage`, tạo folder `Modules/Combat/` nếu chưa có
3. Trong `ReplicatedStorage`, tạo folder `RemoteEvents/`
4. Trong `StarterPlayer`, tạo `StarterPlayerScripts/` nếu chưa có

### Bước 2: Copy Files - ReplicatedStorage

**Modules/Combat/**
- Copy `ProjectileModule.lua` → Đổi thành **ModuleScript** tên `ProjectileModule`
- Copy `DodgeSystem.lua` → Đổi thành **ModuleScript** tên `DodgeSystem`

**RemoteEvents/**
- Tạo 4 **RemoteEvent** mới:
  - `FireSkill`
  - `CreateProjectile`
  - `ShowDamage`
  - `Dodge`

### Bước 3: Copy Files - ServerScriptService

- Copy `ProjectileService.lua` → Đổi thành **Script** tên `ProjectileService`

### Bước 4: Copy Files - StarterPlayerScripts

- Copy `AimingSystem.lua` → Đổi thành **LocalScript** tên `AimingSystem`
- Copy `MobileControls.lua` → Đổi thành **LocalScript** tên `MobileControls`
- Copy `SkillshotCombatUI.lua` → Đổi thành **LocalScript** tên `SkillshotCombatUI`

**Lưu ý**: Bạn có thể **tắt/xóa** file `CombatUI.lua` cũ nếu đã có từ FULL_SYSTEM.

### Bước 5: Update SkillsModule (Optional)

Thêm `ProjectileType` cho mỗi skill trong `SkillsModule.lua`:

```lua
SkillsModule.TienThien = {
    {
        Name = "Linh Phong Chưởng",
        Key = "Q",
        Cooldown = 1,
        ManaCost = 20,
        DamageMultiplier = 1.0,
        DamageType = "Magic",
        ProjectileType = "MagicBolt", -- ← Thêm dòng này
        Range = 50
    },
    {
        Name = "Hỏa Cầu Thuật",
        Key = "E",
        Cooldown = 5,
        ManaCost = 50,
        DamageMultiplier = 2.5,
        DamageType = "Magic",
        ProjectileType = "Fireball", -- ← Fireball có AOE
        Range = 60,
        AOERadius = 8
    },
    {
        Name = "Vân Vũ Lôi Điện",
        Key = "R",
        Cooldown = 15,
        ManaCost = 100,
        DamageMultiplier = 5.0,
        DamageType = "Magic",
        ProjectileType = "Lightning", -- ← Lightning xuyên qua
        IsUltimate = true,
        Range = 100
    }
}
```

**Các ProjectileType có sẵn**:
- `MagicBolt` - Đạn ma thuật cơ bản (màu xanh dương)
- `Fireball` - Cầu lửa có AOE explosion (màu đỏ cam)
- `Lightning` - Tia sét xuyên qua (màu vàng, piercing)
- `PunchWave` - Sóng đấm vật lý (màu cam)
- `SoulBolt` - Đạn linh hồn Ma Đạo (màu tím)

---

## 🎮 Hướng Dẫn Chơi

### PC Controls

| Phím | Chức Năng |
|------|-----------|
| **WASD** | Di chuyển |
| **Mouse** | Ngắm hướng (con trỏ chuột) |
| **Q** | Skill 1 |
| **E** | Skill 2 |
| **R** | Skill 3 (Ultimate) |
| **F** | Skill 4 |
| **G** | Skill 5 |
| **Space** | Dodge/Dash (tiêu tốn stamina) |

### Mobile Controls

- **Joystick (trái dưới)**: Di chuyển
- **Chạm màn hình**: Ngắm hướng (delta từ điểm chạm)
- **Q/E/R/F/G buttons**: Dùng skill
- **DODGE button**: Dodge/Dash

### Dodge Mechanics

- **Stamina**: 100 max, mỗi dodge tốn 25
- **Cooldown**: 2 giây
- **Regen**: 10 stamina/giây
- **I-frames**: 0.5 giây bất tử sau khi dodge
- **Distance**: Dash 20 studs trong 0.3 giây

---

## 🔥 Projectile Types - Chi Tiết

### 1. MagicBolt (Đạn Ma Thuật)
```lua
{
    Size = Vector3.new(1, 1, 3),
    Color = Color3.fromRGB(100, 200, 255),
    Speed = 80,
    Lifetime = 3,
    Piercing = false,
    AOERadius = 0,
    Trail = true,
    ParticleEffect = "Magic"
}
```
- Đạn cơ bản, tốc độ nhanh
- Không xuyên qua
- Không có AOE
- Có trail và particle effect

### 2. Fireball (Cầu Lửa)
```lua
{
    Size = Vector3.new(2, 2, 2),
    Color = Color3.fromRGB(255, 100, 50),
    Speed = 60,
    Lifetime = 4,
    Piercing = false,
    AOERadius = 8, -- Nổ khi chạm
    Trail = true,
    ParticleEffect = "Fire"
}
```
- Chậm hơn MagicBolt
- **AOE explosion** 8 studs khi chạm mục tiêu
- Damage AOE = 70% damage gốc
- Visual: Orange explosion effect

### 3. Lightning (Tia Sét)
```lua
{
    Size = Vector3.new(0.5, 0.5, 10),
    Color = Color3.fromRGB(255, 255, 100),
    Speed = 150,
    Lifetime = 2,
    Piercing = true, -- Xuyên qua
    AOERadius = 0,
    Trail = true,
    ParticleEffect = "Lightning"
}
```
- Rất nhanh (150 speed)
- **Piercing**: Xuyên qua nhiều mục tiêu
- Tia dài, mỏng
- Màu vàng chói

### 4. PunchWave (Sóng Đấm)
```lua
{
    Size = Vector3.new(3, 2, 1),
    Color = Color3.fromRGB(255, 200, 100),
    Speed = 50,
    Lifetime = 2,
    Piercing = false,
    AOERadius = 0,
    Trail = false,
    ParticleEffect = "Punch"
}
```
- Chậm, ngắn hạn
- Thích hợp cho physical skills
- Màu cam/vàng

### 5. SoulBolt (Đạn Linh Hồn - Ma Đạo)
```lua
{
    Size = Vector3.new(1.5, 1.5, 2),
    Color = Color3.fromRGB(200, 100, 200),
    Speed = 70,
    Lifetime = 3,
    Piercing = false,
    AOERadius = 0,
    Trail = true,
    ParticleEffect = "Soul"
}
```
- Đặc thù cho Ma Đạo
- Màu tím/hồng
- Lifesteal áp dụng

---

## 🧪 Testing

### Test 1: PC Controls
1. Play test trong Studio
2. Di chuyển với WASD
3. Nhấn Q để bắn skill (đạn bay theo hướng chuột)
4. Nhấn Space để dodge
5. Kiểm tra cooldown UI

### Test 2: Mobile Controls
1. Trong Studio, vào **Test** → **Emulation** → chọn thiết bị mobile
2. Kiểm tra joystick xuất hiện góc trái dưới
3. Kéo joystick để di chuyển
4. Nhấn DODGE button để dodge
5. Nhấn skill buttons (Q/E/R/F/G)

### Test 3: Hit Detection
1. Spawn 1 enemy từ EnemyService
2. Bắn skill vào enemy
3. Kiểm tra damage numbers xuất hiện
4. Kiểm tra enemy health giảm

### Test 4: Dodge I-frames
1. Đứng trước enemy đang tấn công
2. Nhấn Space ngay khi enemy tấn công
3. Nếu timing đúng, sẽ thấy chữ "DODGE!" xuất hiện
4. Health không bị giảm

---

## 🐛 Troubleshooting

### Lỗi: "Projectile module not found"
**Nguyên nhân**: Chưa copy ProjectileModule vào đúng vị trí.
**Giải pháp**: Kiểm tra `ReplicatedStorage.Modules.Combat.ProjectileModule` tồn tại.

### Lỗi: "Remote event not found"
**Nguyên nhân**: Chưa tạo RemoteEvents.
**Giải pháp**:
1. Vào `ReplicatedStorage`
2. Tạo folder `RemoteEvents`
3. Tạo 4 RemoteEvent: FireSkill, CreateProjectile, ShowDamage, Dodge

### Skills không bắn được
**Nguyên nhân 1**: Chưa cập nhật SkillsModule với ProjectileType.
**Giải pháp**: Thêm field `ProjectileType` cho mỗi skill.

**Nguyên nhân 2**: Không đủ MP.
**Giải pháp**: Kiểm tra mana bar, tăng MaxMP trong Constants.

### Joystick không hiện trên Mobile
**Nguyên nhân**: Script phát hiện sai thiết bị.
**Giải pháp**: Kiểm tra `UserInputService.TouchEnabled` trong MobileControls.lua line 12.

### Dodge không hoạt động
**Nguyên nhân**: Không đủ stamina hoặc đang cooldown.
**Giải pháp**: Đợi stamina regen (10/giây) và cooldown hết (2 giây).

---

## 📊 Performance Notes

- Projectiles tự động cleanup sau `Lifetime` (2-4 giây)
- Server dọn dẹp projectiles mồ côi mỗi 5 giây
- Hit detection sử dụng `GetPartBoundsInRadius` (tối ưu hơn Region3)
- Visual effects sử dụng Debris service để tự động xóa

---

## 🎨 Customization

### Tạo Projectile Type Mới

Trong `ProjectileModule.lua`, thêm vào `ProjectileModule.ProjectileTypes`:

```lua
ProjectileModule.ProjectileTypes.IceShard = {
    Size = Vector3.new(1, 1, 4),
    Color = Color3.fromRGB(100, 200, 255),
    Speed = 90,
    Lifetime = 3,
    Piercing = false,
    AOERadius = 5, -- Freeze AOE
    Trail = true,
    ParticleEffect = "Ice",

    -- Custom effect
    OnHitEffect = function(position)
        -- Tạo ice particles
        local ice = Instance.new("Part")
        ice.Size = Vector3.new(5, 0.5, 5)
        ice.Position = position
        ice.Material = Enum.Material.Ice
        ice.Transparency = 0.5
        ice.Anchored = true
        ice.CanCollide = false
        ice.Parent = workspace
        game:GetService("Debris"):AddItem(ice, 2)
    end
}
```

### Thay Đổi Dodge Stats

Trong `DodgeSystem.lua`:

```lua
DodgeSystem.DODGE_DISTANCE = 30 -- Tăng khoảng cách dash
DodgeSystem.DODGE_DURATION = 0.2 -- Nhanh hơn
DodgeSystem.IFRAME_DURATION = 0.7 -- I-frames dài hơn
DodgeSystem.STAMINA_COST = 20 -- Rẻ hơn
DodgeSystem.STAMINA_REGEN_RATE = 15 -- Regen nhanh hơn
```

---

## 🚀 Next Steps

1. ✅ **Phase 1**: FULL_SYSTEM (Cultivation, Stats, UI)
2. ✅ **Phase 2**: Combat & Enemies
3. ✅ **Phase 3.5**: SKILLSHOT_SYSTEM (Hiện tại)
4. ⏳ **Phase 4**: Advanced Enemy AI với dodge
5. ⏳ **Phase 5**: Boss battles với skill patterns
6. ⏳ **Phase 6**: PvP combat
7. ⏳ **Phase 7**: Skill tree & Customization

---

## 📝 Credits

- **ProjectileModule**: Physics-based projectile system
- **DodgeSystem**: Stamina-based dodge với i-frames
- **AimingSystem**: Cross-platform aiming (PC + Mobile)
- **MobileControls**: Virtual joystick + touch controls
- **SkillshotCombatUI**: Unified combat interface

---

**🎯 Chúc bạn code vui vẻ! Nếu có bug, check lại folder structure và RemoteEvents trước nhé!**
