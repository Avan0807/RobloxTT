# 🎮 GAME TU TIÊN - TIÊN NGHỊCH

## 📋 Tổng Quan

Game MMORPG tu tiên với 3 hệ tu luyện độc đáo:
- **Tiên Thiên (仙天)**: Pháp thuật Magic Damage
- **Cổ Thần (古神)**: Thể chất Physical Damage
- **Ma Đạo (魔道)**: Linh hồn Soul Damage + Lifesteal

### ✨ Tính Năng Chính

✅ **Phase 1 (Hoàn thành)**:
- 3 hệ tu luyện với 27 cấp độ mỗi hệ (3 cảnh giới × 9 level)
- Hệ thống khắc chế tam giác (Rock-Paper-Scissors)
- Stats tự động tính toán theo cảnh giới
- Hệ thống Linh Hồn (Soul System)
- Hồn Phiên cho Ma Đạo
- 3 maps: Rừng Linh Thú, Động Thạch Quỷ, Ma Vực Huyết Trì
- UI hiển thị stats real-time
- PlayerData system với DataStore

🚧 **Phase 2 (Đang phát triển)**:
- Combat system
- Enemy AI & Spawn system
- Drop system (items + Linh Hồn)
- Boss system

📅 **Phase 3 (Kế hoạch)**:
- Hệ thống Luyện Đan
- Tu luyện AFK
- Quest system

📅 **Phase 4 (Kế hoạch)**:
- PvP Arena
- Guild system
- World Boss events

---

## 🗂️ Cấu Trúc Dự Án

```
Game/
├── kichban/                          # Tài liệu thiết kế
│   ├── SYSTEM_DESIGN_FINAL.md       # Thiết kế hệ thống
│   ├── MAP_QUAI_DESIGN.md           # Thiết kế maps & quái
│   ├── tuluyen.txt                  # Hệ thống tu luyện
│   └── luyendan.txt                 # Hệ thống luyện đan
│
└── src/                              # Source code
    ├── ReplicatedStorage/            # Shared modules (Server + Client)
    │   ├── Data/
    │   │   └── Constants.lua         # ⚙️ Tất cả hằng số game
    │   └── Modules/
    │       ├── PlayerData/
    │       │   └── PlayerDataTemplate.lua  # 📊 Template data player
    │       └── Stats/
    │           ├── StatsCalculator.lua     # 🧮 Tính toán stats
    │           └── RealmManager.lua        # 📈 Quản lý lên cấp/đột phá
    │
    ├── ServerScriptService/          # Server scripts
    │   ├── MapGenerator.lua          # 🗺️ Tạo maps tự động
    │   └── Services/
    │       └── PlayerDataService.lua # 💾 Quản lý PlayerData (server)
    │
    └── StarterPlayer/
        └── StarterPlayerScripts/
            └── StatsUI.lua           # 🖥️ UI hiển thị stats (client)
```

---

## 🚀 Hướng Dẫn Setup

### Bước 1: Tạo Project Roblox Mới

1. Mở **Roblox Studio**
2. Tạo **New Place** (Baseplate hoặc Flat Terrain)
3. Save place với tên bạn muốn

### Bước 2: Import Code

#### Cách 1: Copy thủ công (Khuyến nghị cho beginners)

1. **Tạo cấu trúc folders trong Roblox Studio:**

   ```
   ReplicatedStorage
   ├── Data (Folder)
   ├── Modules (Folder)
       ├── PlayerData (Folder)
       └── Stats (Folder)

   ServerScriptService
   └── Services (Folder)

   StarterPlayer
   └── StarterPlayerScripts (Folder)
   ```

2. **Copy từng file .lua:**
   - Click phải vào folder → Insert Object → Script/ModuleScript
   - Đổi tên script
   - Copy nội dung từ file `.lua` trong `src/` paste vào script

#### Cách 2: Dùng Rojo (Advanced)

```bash
# Install Rojo
npm install -g rojo

# Start sync
rojo serve

# Connect trong Roblox Studio plugin
```

### Bước 3: Tạo Maps

1. Vào **ServerScriptService**
2. Paste script `MapGenerator.lua`
3. Click **Run** trong Studio
4. Đợi console in ra "All Maps Created Successfully!"
5. 3 maps sẽ xuất hiện trong Workspace:
   - `RungLinhThu` (0, 0, 0)
   - `DongThachQuy` (1000, 0, 0)
   - `MaVucHuyetTri` (2000, 0, 0)

### Bước 4: Test Game

1. Click **Play** trong Studio
2. Bạn sẽ spawn tại Rừng Linh Thú
3. UI stats sẽ hiện ở góc trên bên trái
4. Có thể đi qua cổng teleport để chuyển map

---

## 📚 Hướng Dẫn Sử Dụng

### Kiểm Tra Stats Của Player (Server Console)

```lua
local PlayerDataService = require(game.ServerScriptService.Services.PlayerDataService)
local player = game.Players:FindFirstChild("YourUsername")
local data = PlayerDataService.GetData(player)

print(data.CurrentRealm)  -- Cảnh giới hiện tại
print(data.CurrentLevel)  -- Level hiện tại
print(data.Stats.MaxHP)   -- HP tối đa
```

### Thêm Tu Vi Điểm

```lua
local PlayerDataService = require(game.ServerScriptService.Services.PlayerDataService)
local player = game.Players:FindFirstChild("YourUsername")

PlayerDataService.AddTuViPoints(player, 5000)
```

### Thêm Items Vào Inventory

```lua
local PlayerDataService = require(game.ServerScriptService.Services.PlayerDataService)
local player = game.Players:FindFirstChild("YourUsername")

PlayerDataService.AddItem(player, "TuKhiDan", 100)
PlayerDataService.AddItem(player, "TienNgoc", 500)
```

### Lên Cấp (Tầng/Sao/Tinh)

```lua
local RealmManager = require(game.ReplicatedStorage.Modules.Stats.RealmManager)
local PlayerDataService = require(game.ServerScriptService.Services.PlayerDataService)
local player = game.Players:FindFirstChild("YourUsername")
local data = PlayerDataService.GetData(player)

-- Thêm đủ tài nguyên trước
PlayerDataService.AddTuViPoints(player, 10000)
PlayerDataService.AddItem(player, "TuKhiDan", 100)

-- Lên cấp
local success, message = RealmManager.LevelUp(data)
print(message)

-- Update stats sau khi lên cấp
PlayerDataService.UpdateStats(player)
```

### Đột Phá Cảnh Giới

```lua
local RealmManager = require(game.ReplicatedStorage.Modules.Stats.RealmManager)
local PlayerDataService = require(game.ServerScriptService.Services.PlayerDataService)
local player = game.Players:FindFirstChild("YourUsername")
local data = PlayerDataService.GetData(player)

-- Phải đạt level 9 trước
data.CurrentLevel = 9
PlayerDataService.AddTuViPoints(player, 100000)
PlayerDataService.AddItem(player, "TuKhiDan", 500)
PlayerDataService.AddItem(player, "TrucCoDan", 20)
-- ... thêm đủ tài nguyên

-- Đột phá
local success, message = RealmManager.Breakthrough(data)
print(message)

PlayerDataService.UpdateStats(player)
```

---

## 🎯 Cơ Chế Game

### Hệ Thống Khắc Chế

```
    TIÊN THIÊN (Magic)
          ↓ +30% damage
      CỔ THẦN (Physical)
          ↓ +30% damage
       MA ĐẠO (Soul)
          ↓ +30% damage
    TIÊN THIÊN (Magic)
```

### Công Thức Damage

```lua
finalDamage = (BaseDamage × CounterMultiplier) - (Defense × 0.5)

-- CounterMultiplier:
-- 1.3 nếu khắc chế
-- 1.0 nếu cân bằng
-- 0.77 nếu bị khắc
```

### Stats Growth

Mỗi cảnh giới có multiplier riêng:

**Tiên Thiên - Ngưng Khí (1-9):**
```
Tầng 1: × 1.0  → HP: 500
Tầng 5: × 2.0  → HP: 1,000
Tầng 9: × 4.0  → HP: 2,000
```

**Đột phá → Trúc Cơ Tầng 1:**
```
× 8.0 → HP: 4,000 (nhân đôi!)
```

---

## 🛠️ Development

### Thêm Cảnh Giới Mới

1. Thêm multipliers vào `Constants.lua`:
```lua
Constants.NewRealmMultipliers = {10.0, 13.0, ...}
```

2. Thêm vào realm list:
```lua
Constants.TienThienRealms = {
    {Name = "NgungKhi", MaxLevel = 9},
    {Name = "TrucCo", MaxLevel = 9},
    {Name = "YourNewRealm", MaxLevel = 9}  -- Thêm
}
```

3. Update `StatsCalculator.lua` để xử lý realm mới

### Thêm Items Mới

1. Thêm vào `PlayerDataTemplate.lua`:
```lua
Inventory = {
    YourNewItem = 0,
    ...
}
```

2. Thêm recipes trong `RealmManager.lua`

---

## 🐛 Troubleshooting

### UI không hiển thị

- Kiểm tra `StarterPlayerScripts` có `StatsUI.lua`
- Kiểm tra console có lỗi không (F9)
- Restart Studio và chạy lại

### Maps không tạo được

- Kiểm tra script `MapGenerator.lua` đã chạy chưa
- Xem Output console (View → Output)
- Có thể cần chờ vài giây để script chạy xong

### Player spawn không đúng chỗ

- Kiểm tra SpawnLocation đã tạo chưa
- Set `Spawn.Enabled = true`
- Hoặc xóa SpawnLocation cũ và tạo lại

### DataStore không save

- Trong Studio, DataStore mặc định tắt
- Để test DataStore: Game Settings → Security → Enable Studio Access to API Services
- Production: Set `USE_DATASTORE = true` trong `PlayerDataService.lua`

---

## 📝 Notes

- **Hiện tại chỉ có Tiên Thiên** làm mặc định
- UI hiển thị mock data, Phase 2 sẽ sync real data
- Maps đã có cổng teleport nhưng chưa hoạt động (Phase 2)
- Boss areas đã được đánh dấu (phần đỏ sáng) nhưng chưa có boss spawn

---

## 🚦 Roadmap

**Phase 1** ✅: Core systems (Hoàn thành)

**Phase 2** (Tiếp theo):
- [ ] Combat system với skills
- [ ] Enemy AI
- [ ] Spawn manager
- [ ] Drop system
- [ ] Boss mechanics

**Phase 3**:
- [ ] Luyện đan (Alchemy)
- [ ] Tu luyện AFK
- [ ] NPC & Quests
- [ ] Shop system

**Phase 4**:
- [ ] PvP Arena
- [ ] Guilds/Clans
- [ ] World Boss events
- [ ] Trading system

---

## 👥 Credits

Game được thiết kế dựa trên:
- Thể loại: Tu tiên/Cultivation novels
- Inspiration: Tiên Nghịch (Renegade Immortal), Hoàng Đình

Developed with ❤️ for Roblox

---

## 📞 Support

Nếu gặp vấn đề:
1. Kiểm tra phần Troubleshooting ở trên
2. Xem Output console (F9) trong Studio
3. Kiểm tra file structure có đúng không

Chúc bạn code vui! 🚀
