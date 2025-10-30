# 🔧 Rojo Setup & Sync Guide

Hướng dẫn chi tiết cách cài đặt và sync code với Roblox Studio.

---

## 📋 Tổng Quan

**Rojo là gì?**
- Tool để sync code từ VSCode/file system vào Roblox Studio
- Cho phép dùng Git, VSCode, và code editors khác
- Tự động sync khi bạn sửa file

**Bạn cần:**
1. Rojo CLI (command line tool)
2. Rojo Plugin (trong Roblox Studio)
3. File `default.project.json` (đã có sẵn!)

---

## 📦 Bước 1: Cài Rojo CLI

### Option A: Download Trực Tiếp (Dễ nhất!)

1. **Download Rojo:**
   - Vào: https://github.com/rojo-rbx/rojo/releases
   - Tìm release mới nhất (vd: v7.4.1)
   - Download file cho Windows: `rojo-7.4.1-windows.zip`

2. **Giải nén:**
   ```
   Giải nén vào: d:\Roblox\RobloxTT\
   Sẽ có file: rojo.exe
   ```

3. **Test:**
   ```bash
   # Mở Command Prompt hoặc PowerShell
   cd d:\Roblox\RobloxTT
   .\rojo.exe --version
   ```

   Kết quả: `Rojo 7.4.1`

### Option B: Cài Bằng Aftman (Advanced)

```bash
# Cài Aftman trước
# https://github.com/LPGhatguy/aftman

# Trong thư mục project
aftman add rojo-rbx/rojo
aftman install
```

---

## 🔌 Bước 2: Cài Rojo Plugin Trong Studio

1. **Mở Roblox Studio**

2. **Cài Plugin:**
   - Click **PLUGINS** tab (trên top menu)
   - Click **Toolbox** button
   - Search: `Rojo`
   - Tìm plugin tên "Rojo - Roblox Studio Sync"
   - Click **Install**

   **Hoặc:**
   - Vào link: https://www.roblox.com/library/13916111004/Rojo
   - Click **Get** để cài vào Studio

3. **Kiểm tra:**
   - Trong Studio, tab **PLUGINS**
   - Bạn sẽ thấy icon **Rojo** (màu xanh lá)

---

## 🚀 Bước 3: Start Rojo Server

### Mở Command Prompt/PowerShell

```bash
# Navigate to project folder
cd d:\Roblox\RobloxTT

# Start Rojo server
rojo serve default.project.json
```

hoặc (nếu rojo.exe trong folder):

```bash
cd d:\Roblox\RobloxTT
.\rojo.exe serve default.project.json
```

### Kết Quả

```
Rojo server listening on localhost:34872
```

**⚠️ QUAN TRỌNG: GIỮ CỬA SỔ NÀY MỞ!**
- Không tắt window này
- Rojo server đang chạy
- Khi sửa file, Rojo sẽ tự động sync

---

## 🔗 Bước 4: Connect Studio Với Rojo

### Trong Roblox Studio:

1. **Tạo/Mở Place:**
   - File → New (hoặc mở place hiện có)

2. **Click Rojo Icon:**
   - Tab **PLUGINS**
   - Click icon **Rojo** (xanh lá)
   - Một window nhỏ sẽ hiện ra

3. **Connect:**
   - Trong Rojo window, click **Connect**
   - Nếu thành công, sẽ hiện: "Connected to localhost:34872"

4. **Sync In (Lần đầu):**
   - Click nút **Sync In**
   - Một popup warning sẽ hiện:
     ```
     This will replace the current contents of...
     Are you sure?
     ```
   - Click **Yes** hoặc **Confirm**

5. **Chờ Sync:**
   - Progress bar sẽ chạy
   - Khi xong, bạn sẽ thấy tất cả code trong Explorer:
     ```
     ReplicatedStorage
       ├── Modules
       │   ├── UI
       │   ├── Weapons
       │   ├── Effects
       │   └── ...
       └── RemoteEvents
           ├── LevelUp
           ├── SyncInventory
           └── ...

     ServerScriptService
       └── Services

     StarterPlayer
       └── StarterPlayerScripts
           ├── UI
           └── Mobile
     ```

---

## ✅ Kiểm Tra Sync Thành Công

### Check Explorer (Trong Studio)

```
Explorer window (phải):
├── ReplicatedStorage
│   ├── Modules
│   │   ├── Admin
│   │   ├── Combat
│   │   ├── Cultivation
│   │   ├── Effects
│   │   │   ├── AdvancedEffects
│   │   │   ├── EffectLibrary
│   │   │   └── SkillEffects
│   │   ├── Equipment
│   │   ├── Monetization
│   │   ├── UI
│   │   └── Weapons
│   │       ├── BaseWeapon
│   │       ├── SwordWeapon
│   │       ├── FlagWeapon
│   │       ├── FistWeapon
│   │       └── WeaponConfig
│   └── RemoteEvents (Folder)
│       ├── LevelUp (RemoteEvent)
│       ├── SyncInventory (RemoteEvent)
│       └── ... (30+ RemoteEvents)
│
├── ServerScriptService
│   └── Services
│       ├── AdminService
│       ├── MonetizationService
│       └── ShopService
│
└── StarterPlayer
    └── StarterPlayerScripts
        ├── UI
        │   ├── InventoryUI
        │   └── ShopUI
        └── Mobile
            ├── MobileControls
            └── AutoTarget
```

### Test Admin Commands

1. Click **Play** (F5)
2. Mở chat (/)
3. Gõ: `/help`
4. Nếu thấy list commands → ✅ Success!

---

## 🔄 Auto-Sync (Realtime)

**Sau khi connect, Rojo sẽ tự động sync:**

1. **Sửa file trong VSCode:**
   ```lua
   -- Edit BaseWeapon.lua
   self.Damage = 200  -- Change value
   ```

2. **Save file (Ctrl+S)**

3. **Rojo tự động sync:**
   - Trong command prompt, bạn sẽ thấy:
     ```
     [Rojo] File changed: src/ReplicatedStorage/Modules/Weapons/BaseWeapon.lua
     [Rojo] Syncing...
     ```

4. **Trong Studio:**
   - File tự động update
   - Không cần Sync In lại
   - Chỉ cần Play để test

---

## 🎮 Workflow

### Workflow Hàng Ngày

```
1. Start Rojo server
   → cd d:\Roblox\RobloxTT
   → rojo serve default.project.json

2. Mở Studio
   → Click Rojo icon → Connect

3. Code trong VSCode
   → Sửa file
   → Save (Ctrl+S)
   → Rojo tự động sync

4. Test trong Studio
   → Play (F5)
   → Test changes
   → Stop
   → Quay lại 3

5. Commit to Git
   → git add .
   → git commit -m "message"
```

---

## ⚠️ Common Issues

### Issue 1: "Connection failed"

**Nguyên nhân:** Rojo server chưa chạy

**Fix:**
```bash
# Mở Command Prompt
cd d:\Roblox\RobloxTT
rojo serve default.project.json

# Giữ window này mở!
```

### Issue 2: "Port 34872 already in use"

**Nguyên nhân:** Rojo server đã chạy rồi

**Fix:**
```bash
# Tìm window Command Prompt đang chạy Rojo
# Hoặc stop process:
taskkill /F /IM rojo.exe

# Rồi start lại
rojo serve default.project.json
```

### Issue 3: Changes không sync

**Nguyên nhân:** Chưa connect hoặc mất connection

**Fix:**
1. Trong Studio: Rojo icon → Disconnect
2. Click Connect lại
3. Không cần Sync In (trừ khi cần reset)

### Issue 4: "default.project.json not found"

**Nguyên nhân:** Sai thư mục

**Fix:**
```bash
# Check path
cd d:\Roblox\RobloxTT
dir

# Phải thấy file: default.project.json
# Nếu không thấy, bạn đang ở sai folder!
```

### Issue 5: Studio bị lag sau khi sync

**Nguyên nhân:** Quá nhiều files

**Fix:**
- Bình thường thôi, lần đầu sync sẽ hơi lâu
- Sau đó sẽ nhanh
- Nếu vẫn lag, restart Studio

---

## 💡 Pro Tips

### Tip 1: Dùng 2 Monitors

```
Monitor 1: VSCode (code)
Monitor 2: Roblox Studio (test)

→ Code bên trái, test bên phải
→ Save → Auto sync → Play → Test
```

### Tip 2: Keep Rojo Server Open

```
Mở Command Prompt riêng cho Rojo
→ Pin nó vào taskbar
→ Minimize nhưng không tắt
→ Khi code, chỉ cần mở Studio là xong
```

### Tip 3: Check Rojo Output

```
Trong Command Prompt window, bạn sẽ thấy:
[Rojo] File changed: ...
[Rojo] Syncing...

→ Helpful để debug
→ Biết file nào đang sync
```

### Tip 4: Git Ignore Rojo Files

```
.gitignore đã có sẵn:
*.rbxl
*.rbxlx

→ Không commit Studio files
→ Chỉ commit source code trong src/
```

---

## 📊 Rojo vs Manual Copy-Paste

| Feature | Rojo ✅ | Manual ❌ |
|---------|---------|-----------|
| Auto-sync | Yes | No (copy mỗi lần) |
| Git support | Yes | Khó |
| VSCode | Yes | No |
| Fast iteration | Yes (save → test) | No (copy → paste → test) |
| Team collaboration | Easy | Khó |
| Backup | Git | Manual |

---

## 🎯 Quick Commands

```bash
# Start server
rojo serve default.project.json

# Build to .rbxl file (optional)
rojo build default.project.json -o game.rbxl

# Check version
rojo --version

# Help
rojo --help
```

---

## ✅ Checklist

### Initial Setup
- [ ] Download Rojo CLI
- [ ] Cài Rojo Plugin trong Studio
- [ ] Start Rojo server (`rojo serve`)
- [ ] Connect trong Studio (Rojo icon)
- [ ] Sync In lần đầu
- [ ] Test (`/help` trong chat)

### Daily Workflow
- [ ] Start Rojo server
- [ ] Mở Studio → Connect
- [ ] Code trong VSCode
- [ ] Save → Auto sync
- [ ] Play → Test
- [ ] Repeat!

---

## 📚 Resources

- **Rojo Docs:** https://rojo.space/docs
- **Rojo GitHub:** https://github.com/rojo-rbx/rojo
- **Plugin:** https://www.roblox.com/library/13916111004/Rojo
- **Discord:** https://discord.gg/rojo (community support)

---

## 🎉 Summary

**3 Bước Đơn Giản:**

1. **Start Rojo:**
   ```bash
   cd d:\Roblox\RobloxTT
   rojo serve default.project.json
   ```

2. **Connect Studio:**
   - PLUGINS → Rojo icon → Connect → Sync In

3. **Code & Test:**
   - Edit file trong VSCode → Save
   - Play trong Studio → Test
   - Repeat!

**Done! Bây giờ bạn có thể code như pro! 🚀**
