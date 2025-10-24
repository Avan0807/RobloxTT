# 🚀 HƯỚNG DẪN SETUP GAME - CHỈ 5 PHÚT!

## ✅ CÁCH 1: DÙNG AUTO INSTALLER (KHUYẾN NGHỊ - DỄ NHẤT)

### Bước 1: Mở Roblox Studio
1. Mở **Roblox Studio**
2. Chọn **New** → **Baseplate** (hoặc Flat Terrain)

### Bước 2: Copy Installer Script
1. Mở file `INSTALLER.lua` trong thư mục game
2. **Copy TOÀN BỘ** nội dung file (Ctrl+A → Ctrl+C)

### Bước 3: Paste vào Studio
1. Trong Roblox Studio, tìm **ServerScriptService** (panel bên trái)
2. Click phải **ServerScriptService** → **Insert Object** → **Script**
3. Đổi tên script thành `Installer`
4. **Paste** code vừa copy vào (xóa hết code cũ trước)

```
Explorer (panel bên trái):
├─ Workspace
├─ Players
├─ Lighting
├─ ReplicatedStorage
├─ ServerScriptService
│  └─ Installer ← PASTE CODE VÀO ĐÂY
└─ ...
```

### Bước 4: Chạy Script
1. Click nút **Play** (▶) ở trên cùng Studio
2. Mở **Output** window (View → Output, hoặc Ctrl+Shift+X)
3. Xem script chạy tự động, đợi đến khi thấy:
   ```
   ✅ CÀI ĐẶT HOÀN TẤT!
   ```

### Bước 5: Dọn dẹp & Save
1. Click nút **Stop** (⏹) để dừng game
2. **XÓA script `Installer`** đi (click phải → Delete)
3. **SAVE place**: File → Save to Roblox / Save to File

### Bước 6: Test Game
1. Click **Play** lại
2. Bạn sẽ spawn tại Rừng Linh Thú
3. UI hiển thị stats ở góc trên bên trái
4. Hoàn tất! 🎉

---

## 🛠️ CÁCH 2: IMPORT THỦ CÔNG (CHO AI MUỐN HIỂU RÕ)

### Bước 1: Tạo Cấu Trúc Folders

Trong **ReplicatedStorage**:
1. Click phải ReplicatedStorage → Insert Object → Folder
2. Đặt tên `Data`
3. Tạo thêm folder `Modules`
4. Trong `Modules`, tạo 2 folders: `PlayerData` và `Stats`

Kết quả:
```
ReplicatedStorage
├─ Data
└─ Modules
   ├─ PlayerData
   └─ Stats
```

Trong **ServerScriptService**:
1. Tạo folder `Services`

```
ServerScriptService
└─ Services
```

### Bước 2: Copy Modules

#### 2.1. Constants.lua
1. Mở file `src/ReplicatedStorage/Data/Constants.lua`
2. Copy toàn bộ nội dung
3. Trong Studio: ReplicatedStorage → Data → Insert Object → **ModuleScript**
4. Đổi tên thành `Constants`
5. Paste code vào

#### 2.2. PlayerDataTemplate.lua
1. Mở file `src/ReplicatedStorage/Modules/PlayerData/PlayerDataTemplate.lua`
2. Copy code
3. Trong Studio: ReplicatedStorage → Modules → PlayerData → Insert Object → **ModuleScript**
4. Đổi tên thành `PlayerDataTemplate`
5. Paste code

#### 2.3. StatsCalculator.lua
1. Mở file `src/ReplicatedStorage/Modules/Stats/StatsCalculator.lua`
2. Copy code
3. Vào: ReplicatedStorage → Modules → Stats → Insert Object → **ModuleScript**
4. Đổi tên thành `StatsCalculator`
5. Paste code

#### 2.4. PlayerDataService.lua
1. Mở file `src/ServerScriptService/Services/PlayerDataService.lua`
2. Copy code
3. Vào: ServerScriptService → Services → Insert Object → **Script** (không phải ModuleScript!)
4. Đổi tên thành `PlayerDataService`
5. Paste code

#### 2.5. MapGenerator.lua
1. Mở file `src/ServerScriptService/MapGenerator.lua`
2. Copy code
3. Vào: ServerScriptService → Insert Object → **Script**
4. Đổi tên thành `MapGenerator`
5. Paste code

#### 2.6. StatsUI.lua
1. Mở file `src/StarterPlayer/StarterPlayerScripts/StatsUI.lua`
2. Copy code
3. Vào: StarterPlayer → StarterPlayerScripts → Insert Object → **LocalScript**
4. Đổi tên thành `StatsUI`
5. Paste code

### Bước 3: Run & Test
1. Click Play
2. Maps sẽ tự động tạo
3. UI sẽ hiện lên

---

## 🆘 TROUBLESHOOTING

### ❌ Lỗi: "ReplicatedStorage.Data is not a valid member"
**Nguyên nhân**: Bạn chưa tạo folder `Data` trong ReplicatedStorage

**Cách fix**:
- Check lại cấu trúc folders
- Đảm bảo tên folders đúng chính xác (phân biệt hoa thường!)

### ❌ Lỗi: "attempt to index nil value"
**Nguyên nhân**: Module chưa được load đúng

**Cách fix**:
1. Mở Output (View → Output)
2. Xem dòng lỗi cụ thể
3. Check lại đã copy đúng code chưa
4. Kiểm tra tên file có đúng không

### ❌ UI không hiển thị
**Cách fix**:
- Check file `StatsUI.lua` có trong StarterPlayerScripts không
- Phải là **LocalScript**, không phải Script
- Restart Studio và thử lại

### ❌ Maps không tạo
**Cách fix**:
- Check file `MapGenerator.lua` có trong ServerScriptService không
- Phải là **Script**, không phải LocalScript
- Xem Output có lỗi gì không

### ❌ Script chạy nhưng không có gì xảy ra
**Cách fix**:
1. Mở Output window (Ctrl+Shift+X)
2. Xem có print statements không
3. Nếu không có gì in ra → Script chưa chạy
4. Check lại script có trong đúng folder không

---

## 📱 CONTACT & SUPPORT

Nếu vẫn gặp lỗi:
1. Chụp ảnh **Output window** (phần lỗi)
2. Chụp ảnh **Explorer** (cấu trúc folders)
3. Gửi lại để được hỗ trợ

---

## 🎯 SAU KHI SETUP XONG

Game hiện tại có:
- ✅ Player spawn system
- ✅ Stats UI (hiển thị HP, MP, Damage, etc.)
- ✅ Map Rừng Linh Thú
- ✅ Player data management
- ✅ Hệ thống tính toán stats tự động

**Chưa có** (sẽ làm tiếp):
- ⏳ Enemy spawn (quái chưa xuất hiện)
- ⏳ Combat system (chưa đánh nhau được)
- ⏳ Loot drops (chưa rơi item)
- ⏳ Level up system

---

## ✨ TIPS

- **Save thường xuyên**: Ctrl+S hoặc File → Save
- **Test nhỏ**: Mỗi lần thêm module, test ngay
- **Xem Output**: Luôn mở Output để debug
- **Backup**: Copy place trước khi thay đổi lớn

Chúc bạn setup thành công! 🚀
