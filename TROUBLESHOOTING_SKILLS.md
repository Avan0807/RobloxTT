# 🔧 Troubleshooting - Skills & Commands Not Working

## Vấn Đề Chính Đã Tìm Ra

**PlayerController.lua** không được sync vì **default.project.json** chỉ sync UI và Mobile folders, không sync file PlayerController.lua ở root của StarterPlayerScripts!

## ✅ Đã Fix

Changed [default.project.json:135-141](default.project.json:135-141) to sync entire StarterPlayerScripts folder:

```json
"StarterPlayerScripts": {
  "$path": "src/StarterPlayer/StarterPlayerScripts"
}
```

## 🔄 QUAN TRỌNG: Các Bước Fix (Làm Theo Thứ Tự!)

### Bước 1: Dừng Rojo Server

Trong terminal đang chạy `rojo serve`:
```bash
Ctrl + C
```

### Bước 2: Khởi Động Lại Rojo

```bash
cd d:\Roblox\RobloxTT
rojo serve default.project.json
```

Đợi thấy:
```
Rojo server listening on port 34872
```

### Bước 3: Trong Studio - Sync In

1. Click **PLUGINS** tab
2. Click **Rojo** plugin icon
3. Click **"Connect"** (nếu chưa connect)
4. Click **"Sync In"**

**QUAN TRỌNG**: Phải click "Sync In", không phải "Sync Out"!

### Bước 4: Kiểm Tra File Đã Sync

Mở **Explorer** trong Studio, kiểm tra:

```
StarterPlayer
└── StarterPlayerScripts
    ├── PlayerController (LocalScript) ← PHẢI CÓ FILE NÀY!
    ├── UI (Folder)
    │   ├── BossHealthUI
    │   ├── InventoryUI
    │   ├── ShopUI
    │   └── SpawnProtectionUI
    └── Mobile (Folder)
        ├── MobileControls
        └── AutoTarget
```

**Nếu không thấy PlayerController**: Sync In lại!

### Bước 5: Restart Studio (Nếu Cần)

Nếu vẫn không thấy PlayerController sau khi Sync In:
1. **Save place** (File → Save)
2. **Close Studio**
3. **Re-open Studio**
4. **Connect Rojo** lại
5. **Sync In** lần nữa

### Bước 6: Test Trong Game

Nhấn **F5** để chạy game, kiểm tra **Output** window:

Bạn PHẢI thấy các dòng sau:

```
🎮 PlayerController initialized!
✅ PlayerController: Input setup complete!
🎮 Controls:
  Q/E/R/F - Skills
  Shift - Dash
  I - Inventory
  P - Shop
```

**Nếu KHÔNG thấy**: PlayerController chưa chạy! Quay lại Bước 4.

### Bước 7: Test Admin Commands

Trong chat, type:
```
/help
```

Bạn PHẢI thấy danh sách commands trong Output.

**Nếu không thấy**: Check Output có lỗi gì không.

### Bước 8: Test Skills

Press **Q** key.

Bạn PHẢI thấy:
- Output: `🔥 Using skill: 1`
- Red explosion effect xuất hiện
- Output: `✅ [YourName] -> Used Skill 1 (Q)`

## 🐛 Common Issues

### Issue 1: "PlayerController not found in Explorer"

**Nguyên nhân**: File chưa được sync

**Fix**:
1. Stop Rojo server (Ctrl+C)
2. Restart: `rojo serve default.project.json`
3. In Studio: Rojo → Sync In
4. Check Explorer lại

### Issue 2: "No output when pressing Q"

**Nguyên nhân**: PlayerController chưa chạy hoặc UseSkill RemoteEvent không tồn tại

**Fix**:
1. Check Output có "🎮 PlayerController initialized!" không
2. Nếu không có: PlayerController chưa chạy
3. Check Explorer → ReplicatedStorage → RemoteEvents → UseSkill (phải có)
4. Nếu không có: Sync In lại

### Issue 3: "Can't type in chat"

**Nguyên nhân**: UI đang capture keyboard input hoặc chat bị disable

**Fix**:
1. Close tất cả UI windows (Inventory, Shop)
2. Click vào game window để focus
3. Press "/" để mở chat
4. Type command

### Issue 4: "/help shows nothing"

**Nguyên nhân**: AdminService chưa khởi tạo hoặc không detect admin

**Fix**:
1. Check Output có "✅ AdminService ready!" không
2. Nếu không có: AdminService chưa load
3. Restart game (F5 lại)
4. Trong Studio, bạn tự động là admin

### Issue 5: "Skills fire but no effect"

**Nguyên nhân**: SkillService chưa load

**Fix**:
1. Check Output có "⚔️ SkillService ready!" không
2. Nếu không có: SkillService chưa load
3. Check init.server.lua có load SkillService không
4. Restart server (Stop → F5)

## 📋 Full Diagnostic Checklist

Copy checklist này và check từng mục:

```
☐ Rojo server running (rojo serve default.project.json)
☐ Studio connected to Rojo
☐ Clicked "Sync In" button
☐ PlayerController visible in Explorer (StarterPlayerScripts)
☐ Output shows "🎮 PlayerController initialized!"
☐ Output shows "⚔️ SkillService ready!"
☐ Output shows "✅ AdminService ready!"
☐ RemoteEvents/UseSkill exists in Explorer
☐ Can type in chat (/ opens chat)
☐ /help shows admin commands
☐ Pressing Q shows output message
☐ Red explosion appears when pressing Q
```

Nếu TẤT CẢ đều OK, skills SẼ hoạt động!

## 🆘 Nếu Vẫn Không Hoạt Động

Làm theo thứ tự:

1. **Stop Rojo** (Ctrl+C)
2. **Close Studio**
3. **Delete** `d:\Roblox\RobloxTT\.rojo.build` (nếu có)
4. **Restart Rojo**: `rojo serve default.project.json`
5. **Open Studio**
6. **Connect Rojo**
7. **Sync In**
8. **Press F5**
9. **Check Output** cho all messages
10. **Test** press Q

## 📸 Screenshot Output Để Debug

Nếu vẫn không hoạt động, chụp screenshot Output window và gửi cho tôi. Tôi cần thấy:
- Có message "PlayerController initialized!" không?
- Có message "SkillService ready!" không?
- Có error messages màu đỏ không?
- Khi press Q, có output gì không?

---

**TL;DR Quick Fix:**

```bash
# 1. Stop Rojo (Ctrl+C)
# 2. Restart Rojo
cd d:\Roblox\RobloxTT
rojo serve default.project.json

# 3. In Studio: Rojo → Sync In
# 4. Press F5
# 5. Check Output for "PlayerController initialized!"
# 6. Press Q to test
```
