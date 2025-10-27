# ⚔️ Weapon System - Quick Summary

## 📋 Mapping Tu Luyện → Vũ Khí

```
Cổ Thần   → Đấm Tay (Fist)    → Fast combo, lifesteal
Tiên Thiên → Kiếm (Sword)      → Slash, elemental
Ma Đạo     → Cờ (Flag)         → AOE, knockback
```

---

## 📁 File Structure

```
src/ReplicatedStorage/Modules/
├── Weapons/
│   ├── BaseWeapon.lua         ← Base class (DONE ✅)
│   ├── SwordWeapon.lua        ← Tiên Thiên (DONE ✅)
│   ├── FlagWeapon.lua         ← Ma Đạo (DONE ✅)
│   ├── FistWeapon.lua         ← Cổ Thần (DONE ✅)
│   ├── WeaponConfig.lua       ← Path mapping (DONE ✅)
│   └── WeaponExamples.lua     ← Examples (DONE ✅)
│
└── Effects/
    ├── EffectLibrary.lua      ← 14 effects (DONE ✅)
    └── SkillEffects.lua       ← 10+ skills (DONE ✅)
```

---

## 🎯 Base Weapons (Starter cho mỗi path)

### 1. Cổ Thần - Phàm Thể Quyền
```lua
Type: Fist
Damage: 80
AttackSpeed: 2.0 (Fast)
Range: 5 (Short)
```

### 2. Tiên Thiên - Phàm Kiếm
```lua
Type: Sword
Damage: 100
AttackSpeed: 1.5 (Medium)
Range: 8 (Medium)
```

### 3. Ma Đạo - Ma Đạo Cờ
```lua
Type: Flag
Damage: 90
AttackSpeed: 1.0 (Slow)
Range: 12 (Long)
```

---

## 🔧 Cách Thêm Vũ Khí Mới

### Bước 1: Thêm vào WeaponConfig.lua

```lua
-- File: src/ReplicatedStorage/Modules/Weapons/WeaponConfig.lua

WeaponConfig.WeaponTiers = {
    CoThan = {
        {
            MinRealm = 1,
            MaxRealm = 9,
            Weapons = {
                "Phàm Thể Quyền",
                "Thiết Quyền",        -- ← Thêm vũ khí mới
                "Kim Cương Quyền"     -- ← Thêm vũ khí mới
            }
        }
    }
}
```

### Bước 2: Tạo Weapon Instance

```lua
-- Trong game code (khi player chọn path)
local FistWeapon = require(ReplicatedStorage.Modules.Weapons.FistWeapon)
local WeaponConfig = require(ReplicatedStorage.Modules.Weapons.WeaponConfig)

-- Get base weapon config
local baseConfig = WeaponConfig.GetBaseWeapon("CoThan")

-- Create weapon
local weapon = FistWeapon.new(baseConfig)

-- Equip to player
weapon:Equip(player)
```

### Bước 3: Custom Weapon (Nếu cần)

```lua
-- Tạo custom fist weapon cho Cổ Thần
local customFist = FistWeapon.new({
    Name = "Thiết Quyền",
    Damage = 150,
    AttackSpeed = 2.5,

    PassiveAbility = function(self, target, damage)
        -- Custom passive: Stun on 5th combo
        if self.Combo == 5 then
            -- Stun enemy
            print("STUN!")
        end
    end,

    ActiveAbility = function(self, target)
        -- Custom active: Meteor Punch
        EffectLibrary.Explosion(target.Position, 10, Color3.fromRGB(255, 100, 0))
    end
})
```

---

## 🎨 Effects Có Sẵn (14 effects)

```lua
local EffectLibrary = require(ReplicatedStorage.Modules.Effects.EffectLibrary)

-- Elemental (Tiên Thiên style)
EffectLibrary.Lightning(pos, target)
EffectLibrary.Fire(pos, duration)
EffectLibrary.Ice(pos, size)
EffectLibrary.Wind(pos, direction)

-- Dark/Soul (Ma Đạo style)
EffectLibrary.Blood(pos)
EffectLibrary.Soul(pos)

-- Combat (Cổ Thần style)
EffectLibrary.Explosion(pos, size, color)
EffectLibrary.Slash(start, end, color)

-- Support
EffectLibrary.Heal(pos)
EffectLibrary.Aura(parent, color, duration)
```

---

## 📊 Weapon Type Characteristics

| Path | Weapon | Speed | Range | Combo | Special |
|------|--------|-------|-------|-------|---------|
| **Cổ Thần** | Đấm Tay | 2.5 atk/s | 5 studs | 5-hit | Lifesteal, Combo scaling |
| **Tiên Thiên** | Kiếm | 1.5 atk/s | 8 studs | 3-hit | Slash effects, Crit |
| **Ma Đạo** | Cờ | 1.0 atk/s | 12 studs | 4-hit | AOE, Knockback |

---

## 🚀 Usage Examples

### Example 1: Player Chọn Path
```lua
-- Server-side: Khi player chọn cultivation path
local function OnPlayerSelectPath(player, path)
    -- Validate path
    if not WeaponConfig.IsValidPath(path) then
        warn("Invalid path:", path)
        return
    end

    -- Get base weapon config
    local weaponConfig = WeaponConfig.GetBaseWeapon(path)

    -- Create weapon based on type
    local weapon
    if weaponConfig.Type == "Fist" then
        weapon = FistWeapon.new(weaponConfig)
    elseif weaponConfig.Type == "Sword" then
        weapon = SwordWeapon.new(weaponConfig)
    elseif weaponConfig.Type == "Flag" then
        weapon = FlagWeapon.new(weaponConfig)
    end

    -- Equip weapon
    weapon:Equip(player)

    print(player.Name, "selected", path, "- equipped", weaponConfig.Name)
end
```

### Example 2: Unlock Weapon Theo Realm
```lua
-- Khi player level up realm
local function OnRealmBreakthrough(player, newRealm)
    local path = player.CultivationPath -- "CoThan", "TienThien", hoặc "MaDao"

    -- Get available weapons for new realm
    local availableWeapons = WeaponConfig.GetWeaponsForRealm(path, newRealm)

    print("Available weapons for", path, "at realm", newRealm .. ":")
    for _, weaponName in ipairs(availableWeapons) do
        print(" -", weaponName)
    end

    -- TODO: Show in shop UI
end
```

### Example 3: Use Effects
```lua
-- Trong weapon's active ability
ActiveAbility = function(self, target)
    -- Cổ Thần style - Physical impact
    EffectLibrary.Explosion(target.Position, 10, Color3.fromRGB(200, 150, 100))

    -- Tiên Thiên style - Lightning
    EffectLibrary.Lightning(target.Position + Vector3.new(0, 10, 0), target.Position)

    -- Ma Đạo style - Soul drain
    EffectLibrary.Soul(target.Position)
    EffectLibrary.Blood(target.Position)
end
```

---

## 📝 TODO: Sau Này Bạn Sẽ Thêm

### Cổ Thần (Fist) Weapons
```
Tier 1 (Realm 1-9):
- ✅ Phàm Thể Quyền (Base)
- [ ] Thiết Quyền (Iron Fist)
- [ ] Kim Cương Quyền (Diamond Fist)

Tier 2 (Realm 10-18):
- [ ] Cổ Ma Quyền
- [ ] Bá Thể Quyền
- [ ] ...

Tier 3 (Realm 19-27):
- [ ] Cổ Tôn Quyền
- [ ] Thiên Địa Quyền
- [ ] ...
```

### Tiên Thiên (Sword) Weapons
```
Tier 1:
- ✅ Phàm Kiếm (Base)
- [ ] Linh Kiếm
- [ ] Băng Kiếm (Ice Sword)
- [ ] Lôi Kiếm (Lightning Sword)

Tier 2:
- [ ] Thiên Kiếm
- [ ] ...

Tier 3:
- [ ] Tiên Kiếm
- [ ] ...
```

### Ma Đạo (Flag) Weapons
```
Tier 1:
- ✅ Ma Đạo Cờ (Base)
- [ ] Hồn Cờ (Soul Flag)
- [ ] Huyết Cờ (Blood Flag)

Tier 2:
- [ ] Ma Tôn Cờ
- [ ] ...

Tier 3:
- [ ] Ma Hoàng Cờ
- [ ] ...
```

---

## 🎯 Next Steps

### 1. Design Weapons (Bạn làm)
- ✅ OOP Structure đã xong
- ✅ Effects đã xong
- **→ Giờ chỉ cần design weapons và thêm vào WeaponConfig**

### 2. Thêm Models (Optional)
```lua
-- Khi có 3D models
local weapon = FistWeapon.new({
    Model = game.ReplicatedStorage.Models.CoThanFist,
    // ...
})
```

### 3. Thêm Animations (Optional)
```lua
local weapon = SwordWeapon.new({
    AttackAnimations = {12345, 12346, 12347},
    IdleAnimation = 12348,
    // ...
})
```

### 4. Integrate với Shop
```lua
-- Trong ShopModule.lua
{
    ItemName = "Thiết Quyền",
    Type = "Weapon",
    WeaponType = "Fist",
    Price = 50000,
    RequiredPath = "CoThan",
    RequiredRealm = 5
}
```

---

## 📚 Docs Reference

- **[WEAPON_EFFECTS_GUIDE.md](WEAPON_EFFECTS_GUIDE.md)** - Complete guide (200+ lines)
- **[BaseWeapon.lua](src/ReplicatedStorage/Modules/Weapons/BaseWeapon.lua)** - Base class API
- **[EffectLibrary.lua](src/ReplicatedStorage/Modules/Effects/EffectLibrary.lua)** - All effects
- **[WeaponConfig.lua](src/ReplicatedStorage/Modules/Weapons/WeaponConfig.lua)** - Path mapping

---

## ✅ Summary

**Đã xong:**
- ✅ OOP weapon system (BaseWeapon, 3 types)
- ✅ 14 reusable effects
- ✅ 10+ skill effects
- ✅ Path → Weapon mapping
- ✅ Base weapons cho 3 paths
- ✅ Complete documentation

**Bạn cần làm:**
- 🎨 Design weapon stats (damage, speed, etc.)
- 🎨 Tạo custom PassiveAbility và ActiveAbility
- 🎨 Thêm vào WeaponConfig.WeaponTiers

**Structure đã sẵn sàng cho bạn phát triển tiếp! 🚀**
