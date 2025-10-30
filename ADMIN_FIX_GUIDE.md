# 🔧 Admin System Fix - Hướng Dẫn Sửa Lỗi Admin

## ❌ Vấn Đề

Admin commands không hoạt động sau khi sync Rojo vì:

1. **Services được sync như ModuleScripts** - Không tự động chạy
2. **Thiếu Script khởi tạo** - Không có script nào gọi `AdminService.Initialize()`
3. **Backend không được load** - Các Services không được khởi tạo

## ✅ Giải Pháp

Tôi đã tạo **init.server.lua** - Script chính sẽ tự động load và khởi tạo TẤT CẢ các Services.

### File Đã Tạo

1. **[src/ServerScriptService/init.server.lua](src/ServerScriptService/init.server.lua)** - Main initialization script
2. **[default.project.json](default.project.json)** - Updated to include init script

## 🔄 Cách Sửa (3 Bước)

### Bước 1: Dừng Rojo Server

Nếu Rojo server đang chạy, nhấn `Ctrl+C` trong terminal để dừng.

### Bước 2: Sync Lại Với Rojo

```bash
cd d:\Roblox\RobloxTT
rojo serve default.project.json
```

Trong Roblox Studio:
1. Click **PLUGINS** tab
2. Click **Rojo** icon
3. Click **Connect**
4. Click **Sync In** (QUAN TRỌNG!)

### Bước 3: Kiểm Tra Output

Nhấn **F5** để chạy game, bạn sẽ thấy trong Output window:

```
🚀 Server initializing...
✅ Essential folders loaded

📦 Loading Services...
✅ PlayerDataService initialized
✅ DataStoreService initialized
✅ AdminService initialized
✅ InventoryService initialized
✅ EquipmentService initialized
✅ ShopService initialized
✅ QuestService initialized
✅ LootService initialized
✅ EnemyService initialized
✅ BossService initialized
✅ ProjectileService initialized
✅ HonPhienAdvancedService initialized
✅ ThienKiepService initialized
✅ TanSatService initialized
✅ MonetizationService initialized
✅ MapGenerator initialized

✅ All services loaded!
📊 Loaded 15 services

🎮 Server ready!
🔧 Admin commands enabled in Studio
💬 Use /help to see all admin commands
==================================================
```

## 🧪 Test Admin Commands

Trong Studio, nhấn **F5** và thử các commands sau trong chat:

### Test Commands Cơ Bản

```
/help              → Xem tất cả commands
/info              → Xem thông tin nhân vật
/god               → Bật God mode
/heal              → Hồi full HP
/speed 50          → Tăng tốc độ chạy
```

### Test Cultivation Commands

```
/setRealm MaTon 5  → Set cảnh giới lên Ma Tôn cấp 5
/addTuVi 100000    → Thêm 100,000 Tu Vi
/setPath MaDao     → Đổi sang Ma Đạo
/addSouls 10000    → Thêm 10,000 hồn phiến
```

### Test Item Commands

```
/giveGold 1000000  → Thêm 1 triệu vàng
/unlockSkills      → Mở khóa tất cả skills
/maxSkills         → Max tất cả skills lên level 10
```

### Test Combat Commands

```
/spawnEnemy Normal 10     → Spawn kẻ địch level 10
/spawnBoss Linh Thú Vương → Spawn boss
/killAll                  → Giết tất cả kẻ địch
```

## 🔍 Kiểm Tra Sync Thành Công

Mở **Explorer** trong Studio và kiểm tra:

### ServerScriptService
```
ServerScriptService
├── Scripts (Folder)
│   └── init (Script) ← PHẢI LÀ SCRIPT (icon màu xanh dương)
└── Services (Folder)
    ├── AdminService (ModuleScript)
    ├── PlayerDataService (ModuleScript)
    ├── DataStoreService (ModuleScript)
    └── ... (other services)
```

**QUAN TRỌNG**: File `init` trong folder Scripts PHẢI là **Script** (icon màu xanh dương), KHÔNG phải ModuleScript!

### ReplicatedStorage
```
ReplicatedStorage
├── Modules (Folder)
│   ├── Admin (Folder)
│   ├── Combat (Folder)
│   ├── Cultivation (Folder)
│   └── ...
└── RemoteEvents (Folder)
    ├── ExecuteAdminCommand (RemoteEvent)
    ├── AdminCommandResponse (RemoteEvent)
    └── ...
```

## ⚠️ Troubleshooting

### Vấn Đề 1: Không thấy init script trong Explorer
**Nguyên nhân**: Chưa Sync In
**Giải pháp**: Mở Rojo plugin → Click "Sync In"

### Vấn Đề 2: init là ModuleScript thay vì Script
**Nguyên nhân**: File không có extension .server.lua
**Giải pháp**: Kiểm tra file name là `init.server.lua` (không phải `init.lua`)

### Vấn Đề 3: Output không hiển thị messages khởi tạo
**Nguyên nhân**: Script không chạy hoặc bị lỗi
**Giải pháp**:
1. Kiểm tra Output window có lỗi màu đỏ không
2. Kiểm tra init là Script (không phải ModuleScript)
3. Restart Studio và sync lại

### Vấn Đề 4: Admin commands vẫn không hoạt động
**Nguyên nhân**: AdminService không được khởi tạo
**Giải pháp**:
1. Kiểm tra Output có dòng "✅ AdminService initialized"
2. Nếu không có, kiểm tra lỗi màu đỏ trong Output
3. Đảm bảo bạn đang test trong Studio (tự động admin)

### Vấn Đề 5: "Player data not found!" error
**Nguyên nhân**: PlayerDataService chưa tạo data cho player
**Giải pháp**: Chờ vài giây sau khi spawn, PlayerDataService cần thời gian khởi tạo

## 📋 Checklist Hoàn Chỉnh

- [ ] Dừng Rojo server cũ
- [ ] Chạy `rojo serve default.project.json`
- [ ] Mở Roblox Studio
- [ ] Mở Rojo plugin
- [ ] Click "Connect"
- [ ] Click "Sync In"
- [ ] Kiểm tra init là Script trong ServerScriptService
- [ ] Nhấn F5 để chạy game
- [ ] Kiểm tra Output có messages khởi tạo
- [ ] Test command `/help` trong chat
- [ ] Test command `/god` để xác nhận admin hoạt động

## 🎉 Khi Thành Công

Bạn sẽ thấy:
1. ✅ Output hiển thị tất cả services được load
2. ✅ Admin commands hoạt động trong chat
3. ✅ `/help` hiển thị danh sách commands
4. ✅ `/god` bật god mode thành công

## 📚 Tài Liệu Liên Quan

- [ADMIN_TESTING_GUIDE.md](ADMIN_TESTING_GUIDE.md) - Danh sách đầy đủ 30+ admin commands
- [ROJO_SETUP_GUIDE.md](ROJO_SETUP_GUIDE.md) - Hướng dẫn setup Rojo chi tiết
- [SYNC_CHECKLIST.md](SYNC_CHECKLIST.md) - Checklist sync tổng quát

---

**Lưu Ý**: File init.server.lua sẽ tự động load và khởi tạo TẤT CẢ services mỗi khi server start. Bạn không cần làm gì thêm!
