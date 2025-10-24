# ⚡ QUICK START - 5 Phút Setup

**Cài đặt game tu luyện hoàn chỉnh chỉ trong 5 phút!**

---

## ✅ Bước 1: Tạo Folders (1 phút)

Trong Roblox Studio:

### ReplicatedStorage
```
ReplicatedStorage/
├── Data/
├── Modules/
│   ├── Combat/
│   ├── Cultivation/
│   └── Skills/
└── RemoteEvents/
```

### RemoteEvents
Tạo 7 **RemoteEvent** trong `ReplicatedStorage/RemoteEvents/`:
1. LevelUp
2. Breakthrough
3. StartMeditation
4. FireSkill
5. CreateProjectile
6. ShowDamage
7. Dodge

---

## 📥 Bước 2: Copy 18 Files (3 phút)

### A. Data (2 ModuleScripts)
→ `ReplicatedStorage/Data/`
- Constants.lua → ModuleScript `Constants`
- EnemyTemplate.lua → ModuleScript `EnemyTemplate`

### B. Combat (2 ModuleScripts)
→ `ReplicatedStorage/Modules/Combat/`
- ProjectileModule.lua → ModuleScript `ProjectileModule`
- DodgeSystem.lua → ModuleScript `DodgeSystem`

### C. Cultivation (4 ModuleScripts)
→ `ReplicatedStorage/Modules/Cultivation/`
- PlayerDataTemplate.lua → ModuleScript `PlayerDataTemplate`
- RealmCalculator.lua → ModuleScript `RealmCalculator`
- CultivationModule.lua → ModuleScript `CultivationModule`
- HonPhienModule.lua → ModuleScript `HonPhienModule`

### D. Skills (1 ModuleScript)
→ `ReplicatedStorage/Modules/Skills/`
- SkillsModule.lua → ModuleScript `SkillsModule`

### E. Server (4 Scripts)
→ `ServerScriptService/`
- PlayerDataService.lua → **Script** `PlayerDataService`
- ProjectileService.lua → **Script** `ProjectileService`
- EnemyService.lua → **Script** `EnemyService`
- MapGenerator.lua → **Script** `MapGenerator`

### F. Client (5 LocalScripts)
→ `StarterPlayer/StarterPlayerScripts/`
- AimingSystem.lua → **LocalScript** `AimingSystem`
- MobileControls.lua → **LocalScript** `MobileControls`
- SkillshotCombatUI.lua → **LocalScript** `SkillshotCombatUI`
- CultivationUI.lua → **LocalScript** `CultivationUI`
- StatsUI.lua → **LocalScript** `StatsUI`

---

## 🎮 Bước 3: Play! (1 phút)

1. Nhấn **Play** (F5)
2. Đợi 2-3 giây
3. Check Output console thấy:
```
✅ MapGenerator initialized with 2 maps!
✅ Auto-spawned enemies
✅ All UIs loaded
```

4. **Enjoy!** 🎉

---

## 🎯 Controls

**PC**: WASD + Mouse + Q/E/R + Space (dodge)
**Mobile**: Joystick + Touch + Skill buttons + Dodge button

---

## 📚 Chi Tiết Hơn?

Đọc:
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Setup chi tiết
- [README.md](README.md) - Features overview
- [FILE_LIST.md](FILE_LIST.md) - File checklist

---

## 🐛 Lỗi?

| Lỗi | Fix |
|-----|-----|
| Module not found | Check folder structure |
| RemoteEvent not found | Tạo 7 RemoteEvents |
| UI không hiện | Đợi 2-3s |
| Skills không bắn | Verify SkillsModule có ProjectileType |

---

**⏱️ Total time: ~5 phút**

**Happy Coding!** 🚀
