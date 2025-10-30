# ✅ Rojo Sync Checklist

Checklist để đảm bảo sync thành công.

---

## 📋 Pre-Sync Checklist

### 1. Files & Folders ✅

```bash
# Check structure
d:\Roblox\RobloxTT\
├── src/
│   ├── ReplicatedStorage/
│   │   ├── Modules/
│   │   │   ├── Admin/          ✅
│   │   │   ├── Boss/           ✅
│   │   │   ├── Combat/         ✅
│   │   │   ├── Cultivation/    ✅
│   │   │   ├── DataStore/      ✅
│   │   │   ├── Effects/        ✅ (EffectLibrary, AdvancedEffects, SkillEffects)
│   │   │   ├── Equipment/      ✅
│   │   │   ├── HonPhien/       ✅
│   │   │   ├── Inventory/      ✅
│   │   │   ├── Loot/           ✅
│   │   │   ├── Monetization/   ✅ (GamePassModule, DevProductModule)
│   │   │   ├── Quest/          ✅
│   │   │   ├── Shop/           ✅
│   │   │   ├── Skills/         ✅
│   │   │   ├── TanSat/         ✅
│   │   │   ├── ThienKiep/      ✅
│   │   │   ├── UI/             ✅ (BaseUI, ButtonManager, UIManager)
│   │   │   └── Weapons/        ✅ (BaseWeapon, SwordWeapon, FlagWeapon, FistWeapon, WeaponConfig)
│   │   └── Data/               ✅
│   ├── ServerScriptService/
│   │   └── Services/           ✅ (AdminService, MonetizationService, ShopService)
│   ├── StarterPlayer/
│   │   └── StarterPlayerScripts/
│   │       ├── UI/             ✅ (InventoryUI, ShopUI)
│   │       └── Mobile/         ✅ (MobileControls, AutoTarget)
│   └── Workspace/
│       └── Maps/               ✅
├── default.project.json        ✅ (UPDATED!)
└── rojo.exe                    ✅ (hoặc installed via Aftman)
```

### 2. default.project.json ✅

**File đã được cập nhật và bao gồm:**

```json
{
  "name": "RobloxTT-Game",
  "tree": {
    "ReplicatedStorage": {
      "Modules": {...},           ✅ All modules
      "Data": {...},              ✅
      "RemoteEvents": {           ✅ 32 RemoteEvents
        "LevelUp",
        "SyncInventory",
        "UseSkill",
        "PromptPurchase",
        "PromptGamePass",
        ...
      }
    },
    "ServerScriptService": {
      "Services": {...}           ✅
    },
    "StarterPlayer": {
      "StarterPlayerScripts": {
        "UI": {...},              ✅
        "Mobile": {...}           ✅ JUST ADDED!
      }
    },
    "Workspace": {
      "Maps": {...}               ✅
    }
  }
}
```

---

## 🚀 Sync Steps

### Step 1: Start Rojo Server

```bash
cd d:\Roblox\RobloxTT
rojo serve default.project.json
```

**Expected Output:**
```
Rojo server listening on localhost:34872
```

✅ Server running
✅ Window kept open

### Step 2: Open Roblox Studio

1. Launch Roblox Studio
2. File → New (or open existing place)
3. ✅ Studio opened

### Step 3: Connect to Rojo

1. Tab **PLUGINS**
2. Click **Rojo** icon (green)
3. Click **Connect**
4. ✅ Should show: "Connected to localhost:34872"

### Step 4: Sync In

1. Click **Sync In** button
2. Confirm warning popup (click Yes)
3. Wait for progress bar to complete
4. ✅ Sync completed

---

## 🔍 Verify Sync Success

### Check Explorer (Studio)

Verify these folders exist in Explorer:

```
✅ ReplicatedStorage
   ✅ Modules
      ✅ Admin
         ✅ AdminModule
      ✅ Effects
         ✅ EffectLibrary
         ✅ AdvancedEffects
         ✅ SkillEffects
      ✅ Weapons
         ✅ BaseWeapon
         ✅ SwordWeapon
         ✅ FlagWeapon
         ✅ FistWeapon
         ✅ WeaponConfig
         ✅ WeaponExamples
      ✅ Monetization
         ✅ GamePassModule
         ✅ DevProductModule
      ✅ UI
         ✅ BaseUI
         ✅ ButtonManager
         ✅ UIManager
   ✅ RemoteEvents (Folder)
      ✅ LevelUp (RemoteEvent)
      ✅ SyncInventory (RemoteEvent)
      ✅ UseSkill (RemoteEvent)
      ✅ PromptPurchase (RemoteEvent)
      ✅ PromptGamePass (RemoteEvent)
      ✅ ... (32 total)

✅ ServerScriptService
   ✅ Services
      ✅ AdminService
      ✅ MonetizationService
      ✅ ShopService

✅ StarterPlayer
   ✅ StarterPlayerScripts
      ✅ UI
         ✅ InventoryUI
         ✅ ShopUI
      ✅ Mobile
         ✅ MobileControls
         ✅ AutoTarget

✅ Workspace
   ✅ Maps
      ✅ TestMap
```

### Test Admin Commands

1. Click **Play** (F5)
2. Open chat (/)
3. Type: `/help`

**Expected:**
```
Admin Commands:
- /setRealm [realm] [level]
- /addTuVi [amount]
- /giveGold [amount]
...
```

✅ Admin commands working

### Test Module Loading

Open **Output** window (View → Output):

**Expected:**
```
✅ AdminModule loaded
✅ EffectLibrary loaded
✅ AdvancedEffects loaded
✅ SkillEffects loaded
✅ BaseWeapon loaded
✅ SwordWeapon loaded
✅ FlagWeapon loaded
✅ FistWeapon loaded
✅ WeaponConfig loaded
✅ WeaponExamples loaded
✅ GamePassModule loaded
✅ DevProductModule loaded
```

✅ All modules loaded successfully

---

## 🐛 Troubleshooting

### ❌ Folder missing in Explorer?

**Check 1: File exists?**
```bash
dir src\ReplicatedStorage\Modules\Mobile
# Should show: MobileControls.lua, AutoTarget.lua
```

**Check 2: Path in default.project.json?**
```json
"Mobile": {
  "$path": "src/StarterPlayer/StarterPlayerScripts/Mobile"
}
```

**Fix:** Disconnect → Connect → Sync In again

### ❌ "Module not found" errors?

**Check Output window for specific error:**
```
ServerScriptService.Services.AdminService:5: attempt to call require, a nil value
```

**Fix:**
1. Check if file exists in src/
2. Check if folder synced to Explorer
3. Restart Studio
4. Sync In again

### ❌ RemoteEvents missing?

**Check Explorer:**
```
ReplicatedStorage → RemoteEvents → (should have 32 RemoteEvents)
```

**Fix:**
1. Disconnect Rojo
2. Connect again
3. Sync In
4. All RemoteEvents should appear

### ❌ Changes not syncing?

**Check Rojo server output:**
```
[Rojo] File changed: src/...
[Rojo] Syncing...
```

**If nothing shows:**
1. Save file (Ctrl+S)
2. Check Rojo server still running
3. Disconnect → Connect in Studio

---

## 📊 What Will Be Synced

### Total Items

- **Modules:** 50+ Lua files
- **RemoteEvents:** 32 events
- **Services:** 3 server scripts
- **UI Scripts:** 4 client scripts
- **Mobile Scripts:** 2 client scripts
- **Total:** 90+ items

### Size

- Total code: ~30,000 lines
- Sync time: 5-10 seconds (first time)
- Auto-sync: < 1 second per file

---

## ✅ Final Checklist

Before saying "Sync successful":

- [ ] Rojo server running
- [ ] Studio connected (green "Connected" status)
- [ ] Sync In completed (no errors)
- [ ] Explorer shows all folders
- [ ] RemoteEvents folder has 32 events
- [ ] `/help` command works in chat
- [ ] Output shows "loaded" messages
- [ ] No red errors in Output

**All checked? ✅ YOU'RE READY TO CODE! 🚀**

---

## 💡 Post-Sync Tips

### Test Everything

1. **Admin Commands:**
   ```
   /giveGold 100000
   /god
   /help
   ```

2. **Mobile Controls:**
   - View → Device Emulation → Phone
   - Should see joystick + buttons

3. **Effects:**
   ```lua
   -- Test in command bar
   local EffectLibrary = require(game.ReplicatedStorage.Modules.Effects.EffectLibrary)
   EffectLibrary.Lightning(Vector3.new(0, 10, 0), Vector3.new(0, 0, 0))
   ```

### Start Coding

Now you can:
- Edit files in VSCode
- Save (Ctrl+S)
- Auto-sync to Studio
- Play to test
- Repeat!

---

**File default.project.json đã CHUẨN và sẵn sàng sync! 🎉**
