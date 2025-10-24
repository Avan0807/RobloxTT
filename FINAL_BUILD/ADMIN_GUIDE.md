# 🔧 ADMIN TOOLS GUIDE

Hướng dẫn sử dụng hệ thống Admin Tools để test và trải nghiệm game.

---

## 🎯 SETUP (QUAN TRỌNG!)

### Bước 1: Thêm UserID của bạn vào danh sách Admin

1. Mở file: `1_ReplicatedStorage/Modules/Admin/AdminModule.lua`
2. Tìm dòng:
```lua
AdminModule.Admins = {
	-- Add your UserID here
	-- Example: 123456789,
}
```

3. Thêm UserID của bạn:
```lua
AdminModule.Admins = {
	123456789,  -- Thay bằng UserID thật của bạn
}
```

### Cách tìm UserID của bạn:
1. Vào profile Roblox của bạn
2. URL sẽ có dạng: `https://www.roblox.com/users/123456789/profile`
3. Con số `123456789` là UserID của bạn

### Lưu ý:
- Trong Roblox Studio, bạn **LUÔN LUÔN** là admin (không cần thêm UserID)
- UserID chỉ cần khi publish game lên Roblox

---

## 🎮 CÁCH SỬ DỤNG

### Phương pháp 1: Admin Panel (UI) - KHUYẾN NGHỊ ⭐

**Mở Admin Panel**: Nhấn phím **F1**

Giao diện có 7 tabs:

#### 1️⃣ Presets Tab (Nhanh nhất!)
Các preset có sẵn để test nhanh:

| Preset | Mô tả | Dùng khi nào |
|--------|-------|--------------|
| **Beginner Ma Đạo** | Thiết lập Ma Đạo cơ bản | Test early game |
| **Mid Ma Đạo (Ma Tôn)** | Ma Đạo trung cấp | Test mid game features |
| **End-Game Ma Đạo (Ma Hoàng)** | Ma Đạo cuối game | Test end game + skills |
| **MAX POWER (God Mode)** | Sức mạnh tối đa + god mode | Test all features |
| **Test Thiên Kiếp** | Setup để test Thiên Kiếp | Test breakthrough bosses |

**Cách dùng**: Chọn preset → Click nút "⚡ APPLY"

#### 2️⃣ Cultivation Tab
Điều khiển tu luyện:
- **Path**: Chọn đường tu (TienThien/CoThan/MaDao)
- **Realm**: Chọn cảnh giới (LuyenKhi → DoKiep)
- **Tu Vi**: Thêm điểm Tu Vi (10K → 10M)

#### 3️⃣ Ma Đạo Tab
Điều khiển Ma Đạo:
- **Souls**: Thêm linh hồn (1K → 100K)
- **Kills**: Thêm kill count (100 → 100K)
- **Tier**: Đặt Tàn Sát tier (1 → 5)

#### 4️⃣ Items Tab
Quản lý items:
- **Gold**: Thêm vàng (10K → 99M)
- **Items**: Thêm items vào inventory
- **Clear Inv**: Xóa toàn bộ inventory

#### 5️⃣ Combat Tab
Chiến đấu:
- **Spawn Enemies**: Triệu hồi quái (Normal/Elite/Boss)
- **Kill All**: Giết tất cả quái
- **Heal**: Hồi full máu
- **God Mode**: Bất tử

#### 6️⃣ Player Tab
Điều khiển nhân vật:
- **Speed**: Thay đổi tốc độ chạy
- **TP Spawn**: Teleport về spawn
- **Info**: Xem thông tin nhân vật
- **Save**: Lưu dữ liệu
- **Reset**: Reset toàn bộ dữ liệu

#### 7️⃣ Commands Tab
Danh sách tất cả commands có thể dùng.

---

### Phương pháp 2: Chat Commands

Gõ lệnh trong chat với format: `/command [args]`

**Ví dụ**:
```
/setPath MaDao
/addSouls 50000
/setRealm MaTon 7
/god
```

---

## 📝 DANH SÁCH COMMANDS QUAN TRỌNG

### Cultivation Commands

```lua
/setPath [TienThien/CoThan/MaDao]  -- Đổi đường tu
/setRealm [realm] [level]          -- Đặt cảnh giới
/addTuVi [amount]                  -- Thêm Tu Vi
```

**Ví dụ**:
```
/setPath MaDao
/setRealm MaHoang 7
/addTuVi 1000000
```

### Ma Đạo Commands

```lua
/addSouls [amount]    -- Thêm linh hồn
/addKills [amount]    -- Thêm kill count
/setTier [1-5]        -- Đặt Tàn Sát tier
```

**Ví dụ**:
```
/addSouls 100000
/addKills 50000
/setTier 5
```

### Item Commands

```lua
/giveItem [itemName] [amount]  -- Thêm item
/giveGold [amount]             -- Thêm vàng
/clearInventory                -- Xóa inventory
```

**Ví dụ**:
```
/giveItem Kim Đan 10
/giveGold 1000000
```

### Combat Commands

```lua
/spawnEnemy [type] [level]  -- Triệu hồi quái
/spawnBoss [bossName]       -- Triệu hồi boss
/killAll                    -- Giết tất cả quái
/heal                       -- Hồi máu
/god                        -- Bật/tắt god mode
```

**Ví dụ**:
```
/spawnEnemy Boss 50
/killAll
/god
```

### Thiên Kiếp Commands

```lua
/startTribulation   -- Bắt đầu Thiên Kiếp
/skipTribulation    -- Bỏ qua Thiên Kiếp (auto win)
```

### Skill Commands

```lua
/unlockSkills      -- Mở khóa tất cả skills
/resetCooldowns    -- Reset cooldowns
/maxSkills         -- Max tất cả skills lên level 10
```

### Player Commands

```lua
/speed [amount]        -- Đặt tốc độ chạy
/tp [x] [y] [z]       -- Teleport
/info                 -- Xem thông tin
/save                 -- Lưu dữ liệu
/reset                -- Reset dữ liệu
/help                 -- Xem danh sách commands
```

**Ví dụ**:
```
/speed 100
/tp 0 50 0
/info
```

---

## 🚀 QUICK START SCENARIOS

### Scenario 1: Test Ma Đạo từ đầu

**Cách 1 (UI)**:
1. Nhấn F1
2. Tab "Presets"
3. Click "Beginner Ma Đạo" → APPLY

**Cách 2 (Commands)**:
```
/setPath MaDao
/setRealm LuyenKhi 5
/addTuVi 10000
/addSouls 1000
/giveGold 50000
```

### Scenario 2: Test Hồn Phiên Advanced Skills

**Cách 1 (UI)**:
1. Nhấn F1
2. Tab "Presets"
3. Click "End-Game Ma Đạo (Ma Hoàng)" → APPLY
4. Nhấn H để mở Hồn Phiên UI
5. Test các skills

**Cách 2 (Commands)**:
```
/setPath MaDao
/setRealm MaHoang 7
/addSouls 100000
/unlockSkills
/maxSkills
```

### Scenario 3: Test Thiên Kiếp Boss

**Cách 1 (UI)**:
1. Nhấn F1
2. Tab "Presets"
3. Click "Test Thiên Kiếp" → APPLY
4. Nhấn T để mở Thiên Kiếp UI
5. Click "START THIÊN KIẾP"

**Cách 2 (Commands)**:
```
/setPath MaDao
/setRealm LuyenKhi 9
/god
/startTribulation
```

### Scenario 4: Test Tàn Sát System

**Commands**:
```
/setPath MaDao
/addKills 10000      -- Lên tier Ma Đầu
/addSouls 50000      -- Thêm souls
/spawnEnemy Normal 1  -- Spawn quái để giết
```

### Scenario 5: Test MAX POWER

**Cách 1 (UI)**:
1. Nhấn F1
2. Tab "Presets"
3. Click "MAX POWER (God Mode)" → APPLY

**Cách 2 (Commands)**:
```
/setPath MaDao
/setRealm DoKiep 9
/addTuVi 10000000
/addSouls 500000
/addKills 200000
/giveGold 99999999
/unlockSkills
/maxSkills
/god
/speed 50
```

---

## 🎯 TESTING CHECKLIST

Dùng admin tools để test từng tính năng:

### ✅ Ma Đạo Features

- [ ] **Tàn Sát Tiers**
  ```
  /addKills 100     → Tier 2
  /addKills 1000    → Tier 3
  /addKills 10000   → Tier 4
  /addKills 100000  → Tier 5
  ```

- [ ] **Hồn Phiên Buffs**
  ```
  /setRealm MaTon 5
  /addSouls 10000
  Press H → Test Tế Lễ buffs
  ```

- [ ] **Special Skills**
  ```
  /setRealm MaHoang 7
  /addSouls 100000
  /maxSkills
  Press H → Test 6 skills
  ```

- [ ] **Passive Buffs**
  ```
  /setRealm MaTon 4
  /addSouls 180000  → +180% stats
  ```

### ✅ Thiên Kiếp System

- [ ] **Test Breakthrough**
  ```
  /setRealm LuyenKhi 9
  /god
  /startTribulation
  ```

- [ ] **Test All Thiên Kiếp Bosses**
  ```
  Luyện Khí 9 → /startTribulation
  Trúc Cơ 9 → /startTribulation
  Kim Đan 9 → /startTribulation
  ...etc
  ```

- [ ] **Test Skip**
  ```
  /setRealm LuyenKhi 9
  /skipTribulation  → Auto breakthrough
  ```

### ✅ Combat & Enemies

- [ ] **Spawn & Kill Enemies**
  ```
  /spawnEnemy Normal 10
  /spawnEnemy Boss 50
  /killAll
  ```

- [ ] **God Mode**
  ```
  /god  → Toggle on/off
  ```

### ✅ Items & Economy

- [ ] **Test Inventory**
  ```
  /giveItem Kim Đan 10
  /giveItem Trúc Cơ Đan 5
  /clearInventory
  ```

- [ ] **Test Gold**
  ```
  /giveGold 1000000
  Press B → Test shop
  ```

---

## 💡 TIPS & TRICKS

### 1. God Mode cho Testing
```
/god
/speed 100
```
→ Chạy nhanh + bất tử để test mọi thứ

### 2. Quick Max Power
```
Nhấn F1 → Presets → MAX POWER → APPLY
```
→ Instant max level với mọi thứ

### 3. Test Specific Realm
```
/setRealm [realm] 5   → Mid-level realm
/setRealm [realm] 9   → Ready for Thiên Kiếp
```

### 4. Reset khi Bug
```
/reset   → Reset toàn bộ dữ liệu
```

### 5. Check Info
```
/info    → Xem stats hiện tại
```

### 6. Save Progress
```
/save    → Lưu dữ liệu (trong Studio không cần)
```

---

## ⚠️ IMPORTANT NOTES

### Trong Roblox Studio:
- Bạn LUÔN là admin (không cần thêm UserID)
- DataStore không hoạt động (dùng `/save` không có tác dụng)
- Tất cả commands đều hoạt động

### Khi Publish Game:
- PHẢI thêm UserID vào `AdminModule.Admins`
- Chỉ có admins mới thấy được Admin UI
- Người chơi thường KHÔNG thể dùng commands

### Security:
- KHÔNG share UserID admin với người khác
- KHÔNG để admin commands trong production
- Có thể comment out `AdminService.Initialize()` khi release

---

## 🎨 UI CUSTOMIZATION

### Thay đổi keybind mở Admin Panel:

Mở `AdminUI.lua`, tìm dòng:
```lua
if input.KeyCode == Enum.KeyCode.F1 then
```

Đổi thành:
```lua
if input.KeyCode == Enum.KeyCode.F2 then  -- Hoặc key khác
```

### Thêm Preset mới:

Mở `AdminModule.lua`, thêm vào `AdminModule.Presets`:
```lua
{
	Name = "My Custom Preset",
	Commands = {
		"setPath MaDao",
		"setRealm MaTon 7",
		"addSouls 50000",
		-- ... thêm commands
	}
}
```

---

## 📞 TROUBLESHOOTING

### ❌ Admin Panel không mở (F1 không hoạt động)

**Giải pháp**:
1. Check console: Có thông báo "AdminUI loaded!" không?
2. Thử gõ `/help` trong chat
3. Check UserID đã đúng chưa (nếu test trên server)

### ❌ Commands không hoạt động

**Giải pháp**:
1. Check format: Phải bắt đầu bằng `/`
2. Check spelling: `/setPath` không phải `/setpath`
3. Check args: `/addSouls 1000` (có số)

### ❌ Preset không apply

**Giải pháp**:
1. Check console output
2. Thử apply từng command riêng lẻ
3. Check RemoteEvents có tồn tại không

---

## 📖 COMMAND REFERENCE

### Full Command List:

| Command | Args | Example | Description |
|---------|------|---------|-------------|
| `/setRealm` | realm, level | `/setRealm MaTon 5` | Đặt cảnh giới |
| `/addTuVi` | amount | `/addTuVi 100000` | Thêm Tu Vi |
| `/setPath` | path | `/setPath MaDao` | Đổi đường tu |
| `/addSouls` | amount | `/addSouls 50000` | Thêm linh hồn |
| `/addKills` | amount | `/addKills 10000` | Thêm kills |
| `/setTier` | 1-5 | `/setTier 5` | Đặt Tàn Sát tier |
| `/giveItem` | name | `/giveItem Kim Đan` | Thêm item |
| `/giveGold` | amount | `/giveGold 1000000` | Thêm vàng |
| `/clearInventory` | - | `/clearInventory` | Xóa inventory |
| `/spawnEnemy` | type, level | `/spawnEnemy Boss 50` | Spawn quái |
| `/killAll` | - | `/killAll` | Giết tất cả quái |
| `/startTribulation` | - | `/startTribulation` | Bắt đầu Thiên Kiếp |
| `/skipTribulation` | - | `/skipTribulation` | Skip Thiên Kiếp |
| `/unlockSkills` | - | `/unlockSkills` | Mở khóa skills |
| `/maxSkills` | - | `/maxSkills` | Max skills |
| `/heal` | - | `/heal` | Hồi máu |
| `/god` | - | `/god` | Toggle god mode |
| `/speed` | amount | `/speed 100` | Đặt tốc độ |
| `/tp` | x, y, z | `/tp 0 50 0` | Teleport |
| `/save` | - | `/save` | Lưu dữ liệu |
| `/reset` | - | `/reset` | Reset dữ liệu |
| `/info` | - | `/info` | Xem info |
| `/help` | - | `/help` | Xem commands |

---

## 🎉 CONCLUSION

Admin Tools giúp bạn:
- ✅ Test mọi tính năng nhanh chóng
- ✅ Không cần phải chơi từ đầu
- ✅ Debug dễ dàng
- ✅ Trải nghiệm full game ngay lập tức

**Khuyến nghị**: Dùng **Presets** trong Admin Panel (F1) để test nhanh nhất!

---

**Happy Testing! 🎮**
