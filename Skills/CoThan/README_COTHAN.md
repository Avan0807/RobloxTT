# 👊 HỆ CỔ THẦN - Ancient God System

**Phong cách**: Cận chiến - Timing - Phản đòn - Áp sát áp lực cao

## 📋 Danh sách Skills (15/15)

### ⚔️ Kỹ năng thường (10 skills)

| # | Tên Skill | Key | Mô tả | Cooldown |
|---|-----------|-----|-------|----------|
| 01 | **Cổ Quyền Tam Liên** | E (x3) | 3 cú combo punch (light > heavy > ground slam) | 3s |
| 02 | **Phá Thạch Cước** | R | Đá mạnh, trúng tường → +200% damage | 4s |
| 03 | **Kim Cang Chưởng** | T (hold) | Charge 0.5s, sóng chấn xuyên qua địch | 6s |
| 04 | **Trảm Phong Bộ** | Shift | Dash 10m (iframe 0.3s), đòn sau +50% dmg | 5s |
| 05 | **Thiết Cốt Phòng Thể** | F | Giảm 50% sát thương 2s, cho phép counter | 10s |
| 06 | **Long Hống Quyền** | G | Hét ra khí xung chặn đòn, gây stagger | 7s |
| 07 | **Thiên Trụ Địa Trảm** | H | Nhảy lên đập đất, shockwave 5m | 8s |
| 08 | **Thiết Cước Phản Kích** | Passive | Dodge thành công → auto counter 300% dmg | - |
| 09 | **Thần Lực Dẫn Nổ** | Passive | Trúng 5 đòn → nổ vòng 3m | - |
| 10 | **Hồi Tức Cổ Huyết** | Passive | <30% HP: mỗi hit hồi 2% HP (8s) | - |

### 🌟 Công pháp thượng phẩm (5 skills)

| # | Tên Skill | Key | Mô tả | Cooldown |
|---|-----------|-----|-------|----------|
| 11 | **Cổ Ma Thể Hóa** | Z | Biến thân 15s: melee range x2, +100% reflect | 30s |
| 12 | **Chấn Thiên Quyền** | X (hold) | Charge punch, shockwave xuyên 40m | 25s |
| 13 | **Bát Hoang Bất Diệt** | C | 5s miễn CC, không stagger (70% dmg) | 20s |
| 14 | **Cổ Ảnh Đoạt Hồn** | V | Lướt tốc độ cao, 2 hit chéo (iframe 0.4s) | 15s |
| 15 | **Thần Cốt Phục Sinh** | Passive | Chết → giữ 1 HP, 1.2s invincible | 120s |

## 🎮 Hướng dẫn chơi

### Combo cơ bản:
1. **E (x3)** → Cổ Quyền Tam Liên (combo starter)
2. **Shift** → Trảm Phong Bộ (dash + buff damage)
3. **R** → Phá Thạch Cước (finish, bonus nếu đẩy vào tường)

### Combo nâng cao (Dodge - Counter):
1. **F** → Thiết Cốt Phòng Thể (defend mode)
2. Địch tấn công → Trigger counter attack
3. **E (x3)** → Follow-up combo
4. **Passive skill 08** → Auto counter nếu dodge thành công

### Combo Ultimate:
1. **Z** → Cổ Ma Thể Hóa (transformation buff)
2. **X (charge)** → Chấn Thiên Quyền (max charge)
3. **V** → Cổ Ảnh Đoạt Hồn (finisher)

### Survivability:
- **F** - Thiết Cốt Phòng Thể: 50% damage reduction
- **C** - Bát Hoang Bất Diệt: Immune to CC
- **Passive 10** - Hồi Tức Cổ Huyết: Auto lifesteal at low HP
- **Passive 15** - Thần Cốt Phục Sinh: Death prevention (2 min CD)

## 💡 Tips & Tricks

### 1. Wall Bounce Combo:
- Sử dụng **Phá Thạch Cước (R)** gần tường để trigger 200% bonus damage
- Kết hợp với **Chấn Thiên Quyền (X)** để đẩy địch vào tường

### 2. Hit Counter Management:
- **Passive 09 (Thần Lực Dẫn Nổ)** cần 5 hits
- Dùng **Cổ Quyền Tam Liên (E x3)** để stack nhanh (3 hits)
- Thêm 2 đòn nữa → Trigger explosion

### 3. Iframe Chains:
- **Trảm Phong Bộ (Shift)**: 0.3s iframe
- **Thiết Cước Phản Kích (Passive)**: Counter sau dodge
- **Cổ Ảnh Đoạt Hồn (V)**: 0.4s iframe
- Chain các iframe để né damage liên tục

### 4. Transformation Tactics:
- **Cổ Ma Thể Hóa (Z)** → Melee range x2
- Trong transformation: Spam **E** và **H** để maximize AOE
- Reflect damage: Tank hits để reflect về địch

## ⚡ Synergies

### Best Skill Combos:

**Aggressive Playstyle:**
```
Shift (dash) → Z (transform) → E x3 → H (ground slam) → X (charged punch)
```

**Defensive Playstyle:**
```
F (defend) → Wait for attack → Counter → E x3 → R (wall kick)
```

**1v1 PvP:**
```
G (roar stagger) → Shift (dash) → E x3 → V (cross slash) → R (finish)
```

## 🔧 Integration Notes

### Passive Skills:
- **Skill 08, 09, 10** không có Client script (passive)
- Server tự động theo dõi events:
  - Dodge detection → Counter attack
  - Hit counter → Explosion trigger
  - HP monitoring → Lifesteal activation

### Buff Tracking:
Server cung cấp các functions để check buffs:
```lua
-- Trảm Phong Bộ
HasTramPhongBoBuff(player) → returns (hasBuff, damageMultiplier)

-- Thiết Cốt Phòng Thể
IsPlayerDefending(player) → returns (isDefending, damageReduction)

-- Cổ Ma Thể Hóa
IsCoMaTransformed(player) → returns (isTransformed, meleeRange, reflectDamage)

-- Bát Hoang Bất Diệt
IsUnstoppable(player) → returns (isUnstoppable, damageMultiplier)
```

## 📊 Stats Comparison

| Attribute | Rating | Notes |
|-----------|--------|-------|
| Damage | ⭐⭐⭐⭐⭐ | Highest melee damage |
| Range | ⭐⭐☆☆☆ | Close-range only |
| Mobility | ⭐⭐⭐☆☆ | Dashes available |
| Defense | ⭐⭐⭐⭐☆ | Multiple defensive skills |
| Sustain | ⭐⭐⭐⭐☆ | Lifesteal + revive |
| Skill Floor | ⭐⭐⭐⭐☆ | Requires timing |
| Skill Ceiling | ⭐⭐⭐⭐⭐ | Master dodge-counter |

## 🎯 Matchups

**Thắng:**
- 🔵 Tiên Thiên (áp sát không cho kite)
- 🟣 Ma Đạo (tank lifesteal)

**Hòa:**
- 🔴 Cổ Thần (skill-based 1v1)

**Thua:**
- Long-range kite builds
- High mobility enemies

---

**Chất chơi**: Đánh nhịp cận chiến, canh dodge – counter – combo. Dễ vào nhịp PvP 1v1! 💪
