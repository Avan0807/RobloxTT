# 🎮 FINAL BUILD - Setup Guide Hoàn Chỉnh

## 📋 Tổng Quan

Đây là **bản build hoàn chỉnh** của game tu luyện Roblox với:
- ✅ Hệ thống tu luyện 3 hệ (Tiên Thiên, Cổ Thần, Ma Đạo)
- ✅ 27 cảnh giới (3 realms × 9 levels)
- ✅ Combat skillshot với dodge mechanics
- ✅ PC + Mobile controls
- ✅ 2 maps với enemies và AI
- ✅ UI đầy đủ
- ✅ Hồn Phiên system (Ma Đạo)

---

## 📁 Cấu Trúc Files

```
FINAL_BUILD/
├── 1_ReplicatedStorage/
│   ├── Data/
│   │   ├── Constants.lua ← 450 lines, tất cả constants
│   │   └── EnemyTemplate.lua ← Enemy definitions cho 2 maps
│   └── Modules/
│       ├── Combat/
│       │   ├── ProjectileModule.lua ← Skillshot system
│       │   └── DodgeSystem.lua ← Dodge/dash mechanics
│       ├── Cultivation/
│       │   ├── PlayerDataTemplate.lua ← Player data structure
│       │   ├── RealmCalculator.lua ← Stats calculation
│       │   ├── CultivationModule.lua ← Level up, breakthrough
│       │   └── HonPhienModule.lua ← Ma Đạo Soul Banner
│       └── Skills/
│           └── SkillsModule.lua ← 15 skills × 3 hệ (có ProjectileType)
│
├── 2_ServerScriptService/
│   ├── PlayerDataService.lua ← Server data management
│   ├── ProjectileService.lua ← Server projectile + damage
│   ├── EnemyService.lua ← Enemy AI system
│   └── MapGenerator.lua ← 2 maps + portals
│
├── 3_StarterPlayerScripts/
│   ├── AimingSystem.lua ← PC/Mobile aiming
│   ├── MobileControls.lua ← Joystick + dodge button
│   ├── SkillshotCombatUI.lua ← Combat UI với skillshots
│   ├── CultivationUI.lua ← Tu luyện UI
│   └── StatsUI.lua ← Stats display
│
└── SETUP_GUIDE.md ← File này
```

---

## 🔧 Bước 1: Tạo Folder Structure trong Roblox Studio

### 1.1. ReplicatedStorage

1. Mở Roblox Studio
2. Trong **ReplicatedStorage**, tạo:
```
ReplicatedStorage/
├── Data/ (Folder)
├── Modules/ (Folder)
│   ├── Combat/ (Folder)
│   ├── Cultivation/ (Folder)
│   └── Skills/ (Folder)
└── RemoteEvents/ (Folder)
```

3. Trong **RemoteEvents** folder, tạo 7 RemoteEvents:
   - `LevelUp` (RemoteEvent)
   - `Breakthrough` (RemoteEvent)
   - `StartMeditation` (RemoteEvent)
   - `FireSkill` (RemoteEvent)
   - `CreateProjectile` (RemoteEvent)
   - `ShowDamage` (RemoteEvent)
   - `Dodge` (RemoteEvent)

### 1.2. ServerScriptService

Folder này có sẵn, bạn chỉ cần thêm scripts vào.

### 1.3. StarterPlayer

1. Trong **StarterPlayer**, tìm **StarterPlayerScripts**
2. Nếu chưa có, tạo folder **StarterPlayerScripts**

---

## 📥 Bước 2: Copy Files vào Roblox Studio

### 2.1. Data Files (ReplicatedStorage/Data/)

| File | Đổi thành | Vị trí |
|------|-----------|---------|
| `Constants.lua` | **ModuleScript** tên `Constants` | ReplicatedStorage/Data/ |
| `EnemyTemplate.lua` | **ModuleScript** tên `EnemyTemplate` | ReplicatedStorage/Data/ |

**Cách copy**:
1. Mở file `.lua` trong editor
2. Copy toàn bộ nội dung (Ctrl+A, Ctrl+C)
3. Trong Roblox Studio, tạo ModuleScript tại vị trí tương ứng
4. Paste nội dung vào (Ctrl+V)
5. Đổi tên cho đúng

### 2.2. Combat Modules (ReplicatedStorage/Modules/Combat/)

| File | Type | Tên trong Studio |
|------|------|------------------|
| `ProjectileModule.lua` | ModuleScript | `ProjectileModule` |
| `DodgeSystem.lua` | ModuleScript | `DodgeSystem` |

### 2.3. Cultivation Modules (ReplicatedStorage/Modules/Cultivation/)

| File | Type | Tên trong Studio |
|------|------|------------------|
| `PlayerDataTemplate.lua` | ModuleScript | `PlayerDataTemplate` |
| `RealmCalculator.lua` | ModuleScript | `RealmCalculator` |
| `CultivationModule.lua` | ModuleScript | `CultivationModule` |
| `HonPhienModule.lua` | ModuleScript | `HonPhienModule` |

### 2.4. Skills Module (ReplicatedStorage/Modules/Skills/)

| File | Type | Tên trong Studio |
|------|------|------------------|
| `SkillsModule.lua` | ModuleScript | `SkillsModule` |

### 2.5. Server Scripts (ServerScriptService/)

| File | Type | Tên trong Studio |
|------|------|------------------|
| `PlayerDataService.lua` | **Script** | `PlayerDataService` |
| `ProjectileService.lua` | **Script** | `ProjectileService` |
| `EnemyService.lua` | **Script** | `EnemyService` |
| `MapGenerator.lua` | **Script** | `MapGenerator` |

⚠️ **LƯU Ý**: Đây là **Script**, KHÔNG phải ModuleScript!

### 2.6. Client Scripts (StarterPlayer/StarterPlayerScripts/)

| File | Type | Tên trong Studio |
|------|------|------------------|
| `AimingSystem.lua` | **LocalScript** | `AimingSystem` |
| `MobileControls.lua` | **LocalScript** | `MobileControls` |
| `SkillshotCombatUI.lua` | **LocalScript** | `SkillshotCombatUI` |
| `CultivationUI.lua` | **LocalScript** | `CultivationUI` |
| `StatsUI.lua` | **LocalScript** | `StatsUI` |

⚠️ **LƯU Ý**: Đây là **LocalScript**, KHÔNG phải Script!

---

## ✅ Bước 3: Verify Installation

### 3.1. Check ReplicatedStorage

Nhấn vào **ReplicatedStorage** trong Explorer, bạn phải thấy:
```
ReplicatedStorage
├── Data
│   ├── Constants (ModuleScript)
│   └── EnemyTemplate (ModuleScript)
├── Modules
│   ├── Combat
│   │   ├── ProjectileModule (ModuleScript)
│   │   └── DodgeSystem (ModuleScript)
│   ├── Cultivation
│   │   ├── PlayerDataTemplate (ModuleScript)
│   │   ├── RealmCalculator (ModuleScript)
│   │   ├── CultivationModule (ModuleScript)
│   │   └── HonPhienModule (ModuleScript)
│   └── Skills
│       └── SkillsModule (ModuleScript)
└── RemoteEvents
    ├── LevelUp (RemoteEvent)
    ├── Breakthrough (RemoteEvent)
    ├── StartMeditation (RemoteEvent)
    ├── FireSkill (RemoteEvent)
    ├── CreateProjectile (RemoteEvent)
    ├── ShowDamage (RemoteEvent)
    └── Dodge (RemoteEvent)
```

### 3.2. Check ServerScriptService

```
ServerScriptService
├── PlayerDataService (Script)
├── ProjectileService (Script)
├── EnemyService (Script)
└── MapGenerator (Script)
```

### 3.3. Check StarterPlayer

```
StarterPlayer
└── StarterPlayerScripts
    ├── AimingSystem (LocalScript)
    ├── MobileControls (LocalScript)
    ├── SkillshotCombatUI (LocalScript)
    ├── CultivationUI (LocalScript)
    └── StatsUI (LocalScript)
```

---

## 🎮 Bước 4: Test Game

### 4.1. Run Test

1. Nhấn **Play** (F5) trong Studio
2. Chờ 2-3 giây để scripts load

**Kiểm tra Output Console**, phải thấy:
```
✅ Constants loaded
✅ PlayerDataService loaded
✅ ProjectileService loaded
✅ EnemyService loaded (AI enabled)
✅ Created map: Rừng Linh Thú
✅ Created map: Huyền Thiên Sơn
✅ MapGenerator initialized with 2 maps!
✅ Auto-spawned enemies for RungLinhThu
✅ Auto-spawned enemies for HuyenThienSon
✅ AimingSystem loaded
✅ MobileControls loaded
✅ SkillshotCombatUI loaded
✅ CultivationUI loaded
✅ StatsUI loaded
```

### 4.2. Kiểm Tra Features

**UI Test**:
- [ ] Thấy **CultivationUI** (góc phải trên) với realm info
- [ ] Thấy **StatsUI** (góc trái trên) với HP/MP/Stats
- [ ] Thấy **Skills bar** (dưới giữa) với Q/E/R skills
- [ ] Thấy **Dodge indicator** (trái dưới - chỉ trên PC)
- [ ] Thấy **Mana bar** (dưới giữa)

**Movement Test (PC)**:
- [ ] WASD di chuyển được
- [ ] Chuột di chuyển camera
- [ ] Space dodge được (có dash effect)

**Movement Test (Mobile)**:
- [ ] Joystick (trái dưới) di chuyển được
- [ ] Dodge button hoạt động

**Combat Test**:
- [ ] Nhấn Q → skill bắn ra (projectile bay theo hướng chuột/touch)
- [ ] Projectile có trail effect
- [ ] Hit enemy → damage number hiện
- [ ] Enemy health bar giảm
- [ ] Nhấn Space → dodge → thấy character trong suốt

**Enemy AI Test**:
- [ ] Enemy spawn ở 2 maps
- [ ] Enemy đuổi theo player khi gần
- [ ] Enemy tấn công khi đến gần
- [ ] Enemy quay về spawn point khi player xa
- [ ] Enemy respawn sau khi chết (30s)

**Map Test**:
- [ ] Spawn ở **Rừng Linh Thú**
- [ ] Thấy cây, đá, grass
- [ ] Thấy portal màu tím (đi Huyền Thiên Sơn)
- [ ] Chạm portal → teleport được
- [ ] Ở **Huyền Thiên Sơn**: núi, platform bay, crystal
- [ ] Thấy portal màu xanh (về Rừng Linh Thú)

---

## 🎯 Bước 5: Gameplay Guide

### 5.1. Controls

**PC**:
- **WASD**: Di chuyển
- **Mouse**: Ngắm
- **Q/E/R/F/G**: Skills (theo realm)
- **Space**: Dodge/Dash (cost 25 stamina)

**Mobile**:
- **Joystick** (trái dưới): Di chuyển
- **Chạm màn hình**: Ngắm
- **Q/E/R buttons**: Skills
- **DODGE button**: Dodge

### 5.2. Cultivation System

1. **Meditation (AFK farming)**:
   - Click nút "MEDITATION" trong CultivationUI
   - Nhận 10 Tu Vi Points mỗi 5 giây
   - Cần đủ Tu Vi Points để level up

2. **Level Up**:
   - Cần đủ Tu Vi Points + Pills (tiên đan)
   - Click nút "LEVEL UP"
   - Stats tăng theo multiplier

3. **Breakthrough (Phá cảnh)**:
   - Khi đạt level 9 của realm hiện tại
   - Click "BREAKTHROUGH"
   - Mở realm mới với stats mạnh hơn

### 5.3. Combat Tips

- **Kiting**: Di chuyển liên tục, bắn skill từ xa
- **Dodge timing**: Nhấn Space ngay khi enemy tấn công → i-frames 0.5s
- **Stamina management**: Dodge tốn 25, regen 10/giây → tối đa 4 dodge liên tục
- **AOE skills**: Hỏa Cầu Thuật (E) có AOE explosion 8 studs
- **Piercing**: Vân Vũ Lôi Điện (R) xuyên qua nhiều enemies

### 5.4. Ma Đạo - Hồn Phiên System

Nếu chọn **Ma Đạo**:
1. Equip Hồn Phiên trong UI
2. Kill enemies → thu linh hồn
3. Tích đủ linh hồn → unlock skills mạnh hơn
4. Lifesteal tăng theo realm (lên đến 150% ở Ma Hoàng)

---

## 🐛 Troubleshooting

### Lỗi 1: "Module not found"
**Nguyên nhân**: Sai tên hoặc sai vị trí folder.
**Giải pháp**: Kiểm tra lại structure ở Bước 3.1-3.3.

### Lỗi 2: "RemoteEvent not found"
**Nguyên nhân**: Chưa tạo RemoteEvents.
**Giải pháp**: Tạo 7 RemoteEvents trong ReplicatedStorage/RemoteEvents.

### Lỗi 3: Scripts không chạy
**Nguyên nhân**: Nhầm loại script (Script vs LocalScript vs ModuleScript).
**Giải pháp**:
- **ModuleScript**: Tất cả files trong ReplicatedStorage
- **Script**: Files trong ServerScriptService
- **LocalScript**: Files trong StarterPlayerScripts

### Lỗi 4: UI không hiện
**Nguyên nhân**: LocalScripts chưa load hoặc PlayerData chưa được tạo.
**Giải pháp**: Đợi 2-3 giây sau khi nhấn Play. Check Output console.

### Lỗi 5: Enemies không spawn
**Nguyên nhân**: EnemyTemplate chưa được require hoặc maps chưa có EnemySpawns folder.
**Giải pháp**:
- Verify EnemyTemplate.lua đã copy đúng
- MapGenerator tự động tạo EnemySpawns folder

### Lỗi 6: Projectiles không bắn
**Nguyên nhân**: Chưa cập nhật SkillsModule với ProjectileType.
**Giải pháp**: SkillsModule trong FINAL_BUILD đã có ProjectileType sẵn. Verify đã copy đúng file.

### Lỗi 7: Dodge không hoạt động
**Nguyên nhân**: Không đủ stamina (< 25) hoặc đang cooldown (2s).
**Giải pháp**: Đợi stamina regen hoặc cooldown hết.

---

## 📊 System Stats

### Performance

- **Scripts**: 13 total (4 Server, 5 Client, 4+ Modules)
- **Lines of Code**: ~5000+ lines
- **Max Enemies**: 20 per map (40 total)
- **Projectile Lifetime**: 2-4 seconds (auto cleanup)
- **AI Update Rate**: 0.1s (10 times/second)

### Features Count

- **Cultivation Types**: 3 (Tiên Thiên, Cổ Thần, Ma Đạo)
- **Realms**: 3 per type
- **Levels per Realm**: 9
- **Total Realms**: 27
- **Skills**: 15 per type (45 total)
- **Projectile Types**: 5 (MagicBolt, Fireball, Lightning, PunchWave, SoulBolt)
- **Maps**: 2 (Rừng Linh Thú, Huyền Thiên Sơn)
- **Enemy Types**: 6 per map (12 total)

---

## 🚀 Next Steps (Optional Enhancements)

1. **Loot System**: Enemies drop pills/materials
2. **Inventory**: Store pills and equipment
3. **Shop**: Buy pills with currency
4. **Quests**: Daily quests for rewards
5. **Boss Battles**: Special bosses with patterns
6. **PvP**: Player vs Player combat
7. **Guilds**: Tu luyện with friends
8. **Leaderboard**: Top players by realm
9. **Pets**: Companion pets with bonuses
10. **Cosmetics**: Skins, effects, titles

---

## 📝 Credits & Version

**Version**: FINAL_BUILD v1.0
**Created**: 2025
**Platform**: Roblox Studio
**Language**: Lua
**Game Genre**: Cultivation RPG / Action Combat

**Features**:
- Cultivation system based on Chinese xianxia novels
- Action-based skillshot combat (not target-lock)
- Cross-platform (PC + Mobile)
- Complete AI enemy system
- 2 fully-featured maps with portals

---

## 🎉 You're All Set!

Nếu mọi thứ hoạt động đúng, bạn đã có một **game tu luyện hoàn chỉnh** với:
- ✅ Tu luyện progression (27 realms)
- ✅ Skillshot combat
- ✅ Dodge mechanics
- ✅ Enemy AI
- ✅ 2 maps
- ✅ PC + Mobile support

**Chúc bạn code vui vẻ! Nếu cần giúp thêm, hãy check lại guide này!** 🚀

---

**💡 Pro Tip**: Khi test, mở **Output** console (View → Output) để theo dõi logs và debug errors.
