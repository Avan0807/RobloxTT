# 🎮 Hướng dẫn Test Nhanh Skills

## ⚡ Test 1 Skill để bắt đầu (5 phút)

### Bước 1: Setup VFXUtils

1. Mở Roblox Studio
2. Vào **ReplicatedStorage**
3. Click phải → **Insert Object** → **ModuleScript**
4. Đổi tên: `VFXUtils`
5. Mở [VFXUtils.lua](./Shared/VFXUtils.lua) → Copy hết → Paste vào Studio
6. **Ctrl+S** save

### Bước 2: Tạo RemoteEvent cho 1 skill

1. **View** → **Command Bar**
2. Paste code này vào Command Bar:

```lua
local RS = game:GetService("ReplicatedStorage")
local remote = Instance.new("RemoteEvent")
remote.Name = "NguHanhTramRemote"
remote.Parent = RS
print("✅ Created NguHanhTramRemote")
```

3. Nhấn **Enter**

### Bước 3: Copy Client Script

1. Vào **StarterPlayer** → **StarterCharacterScripts**
2. Click phải → **Insert Object** → **LocalScript**
3. Đổi tên: `NguHanhTram_Client`
4. Mở [TienThien/01_NguHanhTram_Client.lua](./TienThien/01_NguHanhTram_Client.lua)
5. **Ctrl+A** → **Ctrl+C** (copy hết code)
6. Quay Studio, chọn LocalScript vừa tạo
7. Xóa code mặc định, **Ctrl+V** paste code vào
8. **Ctrl+S** save

### Bước 4: Copy Server Script

1. Vào **ServerScriptService**
2. Click phải → **Insert Object** → **Script** (không phải LocalScript!)
3. Đổi tên: `NguHanhTram_Server`
4. Mở [TienThien/01_NguHanhTram_Server.lua](./TienThien/01_NguHanhTram_Server.lua)
5. **Ctrl+A** → **Ctrl+C**
6. Paste vào Script trong Studio
7. **Ctrl+S** save

### Bước 5: Test!

1. Nhấn **F5** để chạy game
2. Nhấn phím **E** để bắn 5 tia nguyên tố
3. Check **Output** (View → Output) để xem logs:
   - Phải thấy: `✅ Ngũ Hành Trảm loaded! Press E`
   - Khi nhấn E: `⚡ NGŨ HÀNH TRẢM!`

### ✅ Nếu thấy VFX bay ra = Thành công!

---

## 📁 Cấu trúc sau khi test skill đầu tiên:

```
🎮 Workspace (game đang chạy)

📦 ReplicatedStorage
   └── 📄 VFXUtils (ModuleScript)
   └── 📧 NguHanhTramRemote (RemoteEvent)

👤 StarterPlayer
   └── 📁 StarterCharacterScripts
       └── 📜 NguHanhTram_Client (LocalScript) ⭐

⚙️ ServerScriptService
   └── 📜 NguHanhTram_Server (Script) ⭐
```

---

## 🎯 Giải thích Script Types:

| Type | Chạy ở đâu | Dùng cho |
|------|------------|----------|
| **LocalScript** | Client (máy người chơi) | Input detection (nhấn phím) |
| **Script** | Server | Logic, damage, VFX spawn |
| **ModuleScript** | Shared | Utilities, functions chung |

### ⚠️ SAI THƯỜNG GẶP:

❌ **Client script là Script** → Không nhận input
✅ Client script phải là **LocalScript**

❌ **Server script là LocalScript** → Không spawn VFX
✅ Server script phải là **Script**

---

## 🚀 Thêm skills khác (mỗi skill 2 phút)

### Ví dụ thêm "Lôi Ảnh Dịch Thân":

1. **Command Bar**:
```lua
local remote = Instance.new("RemoteEvent")
remote.Name = "LoiAnhDichThanRemote"
remote.Parent = game.ReplicatedStorage
```

2. **StarterCharacterScripts**: Insert LocalScript → Copy từ `02_LoiAnhDichThan_Client.lua`

3. **ServerScriptService**: Insert Script → Copy từ `02_LoiAnhDichThan_Server.lua`

4. **Test**: F5 → Nhấn **Shift** để dash

---

## 🎨 Test tất cả skills (30 phút)

### Dùng script tự động tạo RemoteEvents:

1. Mở **Command Bar**
2. Copy toàn bộ code từ [IMPORT_TO_STUDIO.lua](./IMPORT_TO_STUDIO.lua)
3. Paste vào Command Bar → Enter
4. Sẽ tạo 40+ RemoteEvents tự động!

### Sau đó copy scripts:

#### Cách nhanh - Tạo folder:

```
StarterCharacterScripts/
├── 📁 TienThien/
│   ├── 📜 01_NguHanhTram_Client (LocalScript)
│   ├── 📜 02_LoiAnhDichThan_Client (LocalScript)
│   └── ... (copy tất cả *_Client.lua)
├── 📁 CoThan/
│   └── ... (copy *_Client.lua)
└── 📁 MaDao/
    └── ... (copy *_Client.lua)
```

```
ServerScriptService/
└── 📁 Skills/
    ├── 📁 TienThien/
    │   ├── 📜 01_NguHanhTram_Server (Script)
    │   └── ... (copy *_Server.lua)
    ├── 📁 CoThan/
    │   └── ...
    └── 📁 MaDao/
        └── ...
```

---

## 🐛 Troubleshooting

### Lỗi: "VFXUtils is not a valid member of ReplicatedStorage"

**Fix**: VFXUtils phải là **ModuleScript** trong **ReplicatedStorage**

### Lỗi: "NguHanhTramRemote is not a valid member"

**Fix**: Chạy lại script tạo RemoteEvent trong Command Bar

### Skill không hoạt động khi nhấn phím

**Fix**:
1. Check Output có log "✅ [Skill Name] loaded!" không
2. Nếu không → Client script chưa chạy
3. Check Client script phải là **LocalScript** trong **StarterCharacterScripts**

### VFX không xuất hiện

**Fix**:
1. Check Output có error không
2. Check Server script có chạy không (phải thấy "✅ [Skill] Server loaded!")
3. Server script phải là **Script** trong **ServerScriptService**

### Nhấn phím nhưng không có gì xảy ra

**Fix**:
1. Check Console (F9) → Client
2. Có thể đang focus vào chat box → Click ra ngoài rồi nhấn lại

---

## 📊 Checklist hoàn thành:

- [ ] VFXUtils trong ReplicatedStorage (ModuleScript)
- [ ] RemoteEvents đã tạo (dùng Command Bar)
- [ ] Client scripts trong StarterCharacterScripts (LocalScript)
- [ ] Server scripts trong ServerScriptService (Script)
- [ ] Test trong Studio (F5) → Skills hoạt động

---

## 🎮 Controls để test:

### Tiên Thiên:
- **E** = Ngũ Hành Trảm (5 tia)
- **Shift** = Lôi Ảnh Dịch Thân (dash)
- **R** = Băng Tỏa Trảm (freeze)
- **V** = Thiên Đạo Phán Quyết (ULTIMATE)

### Cổ Thần:
- **E x3** = Cổ Quyền Tam Liên (combo)
- **R** = Phá Thạch Cước (kick)
- **H** = Thiên Trụ Địa Trảm (ground slam)

### Ma Đạo:
- **E** = Linh Hồn Trảm (soul slash)
- **R** = Oan Hồn Đuổi Bóng (ghost summon)
- **V** = Hủy Diệt Linh Thể (ULTIMATE - hold)

---

**Time estimate**:
- Test 1 skill: **5 minutes**
- Test 5 skills: **15 minutes**
- Test all 45 skills: **30-60 minutes**

Good luck! 🚀
