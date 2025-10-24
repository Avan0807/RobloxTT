# 🎯 SKILLSHOT SYSTEM

**Phase 3.5: Action-Based Combat System**

Hệ thống combat dạng skillshot với projectiles, dodge mechanics, và cross-platform controls (PC + Mobile).

---

## 📦 Files Trong Folder Này

| File | Type | Mục Đích |
|------|------|----------|
| **ProjectileModule.lua** | ModuleScript | Projectile physics, 5 projectile types, hit detection, AOE explosion |
| **DodgeSystem.lua** | ModuleScript | Dodge/dash mechanics, stamina system, i-frames, cooldown |
| **AimingSystem.lua** | LocalScript | Cross-platform aiming (Mouse cho PC, Touch cho Mobile) |
| **MobileControls.lua** | LocalScript | Virtual joystick + dodge button cho Mobile |
| **ProjectileService.lua** | Script | Server-side projectile management, damage calculation |
| **SkillshotCombatUI.lua** | LocalScript | Combat UI với skills bar, mana, dodge indicator |
| **SKILLSHOT_GUIDE.md** | Documentation | Chi tiết setup và customization |
| **README.md** | Documentation | File này |

---

## 🎮 Features

### ✅ Projectile System
- 5 loại projectile: MagicBolt, Fireball, Lightning, PunchWave, SoulBolt
- Physics-based movement
- Hit detection với `GetPartBoundsInRadius`
- AOE explosions (Fireball)
- Piercing projectiles (Lightning)
- Trail effects, particle effects, lights

### ✅ Dodge/Dash System
- Stamina: 100 max, cost 25 per dodge
- Cooldown: 2 seconds
- Regen: 10 stamina/second
- I-frames: 0.5 seconds invincibility
- Distance: 20 studs dash
- Visual effects: transparency + trail

### ✅ Aiming System
- **PC**: Mouse raycast to world
- **Mobile**: Touch delta to direction
- Auto-detect input type
- 3D aim indicator arrow
- Smooth camera-relative aiming

### ✅ Mobile Controls
- Virtual joystick (150×150px circular)
- Dodge button with cooldown display
- Stamina bar
- Camera-relative movement
- Touch handling

### ✅ Combat UI
- Skills bar: Q/E/R/F/G (max 5 skills)
- Cooldown overlays
- Mana bar
- Dodge indicator (PC only)
- Stamina bar (PC only)
- Crosshair
- Damage numbers

---

## 🚀 Quick Start

1. **Đọc SKILLSHOT_GUIDE.md** để biết cách cài đặt chi tiết
2. Copy files theo đúng folder structure
3. Tạo RemoteEvents: FireSkill, CreateProjectile, ShowDamage, Dodge
4. (Optional) Update SkillsModule với ProjectileType
5. Test!

---

## 🎯 Gameplay Flow

```
Player nhấn Q (skill 1)
    ↓
SkillshotCombatUI lấy AimDirection từ AimingSystem
    ↓
FireSkillEvent:FireServer(skillName, aimDirection)
    ↓
ProjectileService.CreateProjectile() trên server
    ↓
Projectile bay theo direction với physics
    ↓
ProjectileModule.CheckHit() kiểm tra va chạm
    ↓
Nếu hit → ApplyDamage() → Show damage number
    ↓
Nếu có AOE → ExplodeAOE() → Hit tất cả trong radius
```

---

## 🔗 Integration với FULL_SYSTEM

Skillshot System **tích hợp hoàn toàn** với FULL_SYSTEM:

- ✅ Sử dụng PlayerData từ PlayerDataService
- ✅ Sử dụng Stats từ RealmCalculator
- ✅ Sử dụng Skills từ SkillsModule
- ✅ Tích hợp Hồn Phiên cho Ma Đạo (collect souls on kill)
- ✅ Lifesteal, Crit Rate, Crit Damage hoạt động
- ✅ Mana consumption

**Lưu ý**: File `SkillshotCombatUI.lua` thay thế `CombatUI.lua` cũ.

---

## 🎨 Projectile Types

| Type | Speed | AOE | Piercing | Color | Use Case |
|------|-------|-----|----------|-------|----------|
| **MagicBolt** | 80 | ❌ | ❌ | Blue | Basic magic attack |
| **Fireball** | 60 | ✅ 8 studs | ❌ | Orange | AOE damage skill |
| **Lightning** | 150 | ❌ | ✅ | Yellow | Multi-target pierce |
| **PunchWave** | 50 | ❌ | ❌ | Orange | Physical melee wave |
| **SoulBolt** | 70 | ❌ | ❌ | Purple | Ma Đạo specific |

---

## 🎯 Controls

### PC
- **WASD**: Movement
- **Mouse**: Aim
- **Q/E/R/F/G**: Skills
- **Space**: Dodge

### Mobile
- **Joystick**: Movement
- **Touch screen**: Aim
- **Skill buttons**: Skills
- **DODGE button**: Dodge

---

## 📊 Stats Used

- **MagicDamage** → Magic projectiles
- **PhysicalDamage** → Physical projectiles
- **SoulDamage** → Soul projectiles (Ma Đạo)
- **CritRate** → Chance to crit
- **CritDamage** → Crit multiplier
- **Lifesteal** → Heal on hit
- **MP** → Mana for skills

---

## 🐛 Common Issues

| Issue | Solution |
|-------|----------|
| Projectiles not spawning | Check RemoteEvents folder exists |
| Skills not firing | Add `ProjectileType` field to skills |
| Joystick not showing | Verify `UserInputService.TouchEnabled` |
| Dodge not working | Check stamina (need 25) and cooldown (2s) |
| Damage not applied | Verify ProjectileService is running |

---

## 🔧 Customization

**Thay đổi dodge stats** → Edit `DodgeSystem.lua` lines 10-16

**Tạo projectile type mới** → Add to `ProjectileModule.ProjectileTypes`

**Thay đổi UI layout** → Edit `SkillshotCombatUI.lua` UI creation section

**Thêm visual effects** → Modify `ProjectileModule.CreateProjectile()`

---

## 📈 Performance

- ✅ Projectiles auto-cleanup after lifetime
- ✅ Server cleanup orphaned projectiles every 5s
- ✅ Hit detection optimized với `OverlapParams`
- ✅ Effects use Debris service
- ✅ Typically ~20-30 active projectiles max

---

## 🚀 Next Features (Ideas)

- [ ] Homing projectiles
- [ ] Chained lightning
- [ ] Projectile reflection
- [ ] Skill combos
- [ ] Charge-up skills
- [ ] Multi-stage projectiles
- [ ] Enemy dodge AI
- [ ] PvP combat

---

## 📝 Version

**Version**: 1.0.0
**Created**: 2025
**Compatible with**: FULL_SYSTEM v1.0

---

**🎮 Happy Gaming!**
