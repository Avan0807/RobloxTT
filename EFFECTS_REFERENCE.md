# 🎨 Complete Effects Reference

Tổng hợp TẤT CẢ effects có trong hệ thống.

---

## 📚 2 Libraries

### 1. EffectLibrary.lua (Basic Effects)
14 effects dùng ParticleEmitter, Beam, Trail custom

### 2. AdvancedEffects.lua (Built-in Roblox Effects) ⭐ MỚI
20+ effects dùng built-in instances của Roblox

---

## 🎯 EffectLibrary.lua (14 Effects)

```lua
local EffectLibrary = require(ReplicatedStorage.Modules.Effects.EffectLibrary)
```

### Elemental Effects
```lua
-- Lightning (5 strikes + beam)
EffectLibrary.Lightning(position, targetPosition)

-- Fire (particles + smoke + light)
EffectLibrary.Fire(position, duration)

-- Ice (crystals)
EffectLibrary.Ice(position, size)

-- Wind (particles)
EffectLibrary.Wind(position, direction)
```

### Dark/Soul Effects
```lua
-- Blood splatter
EffectLibrary.Blood(position)

-- Soul particles (spiral)
EffectLibrary.Soul(position)
```

### Combat Effects
```lua
-- Explosion (custom particles)
EffectLibrary.Explosion(position, size, color)

-- Slash beam
EffectLibrary.Slash(startPosition, endPosition, color)
```

### Support Effects
```lua
-- Heal particles (green upward)
EffectLibrary.Heal(position)

-- Aura (continuous particles around object)
local aura = EffectLibrary.Aura(parent, color, duration)

-- Speed boost (trail + aura)
EffectLibrary.SpeedBoost(caster, duration, multiplier)

-- Teleport (soul effects)
EffectLibrary.Teleport(caster, targetPosition)
```

---

## ⚡ AdvancedEffects.lua (20+ Effects) ⭐

```lua
local AdvancedEffects = require(ReplicatedStorage.Modules.Effects.AdvancedEffects)
```

### Built-in Instance Effects (Dễ dùng!)

```lua
-- Fire instance (built-in, realistic!)
AdvancedEffects.QuickFire(part, duration)

-- Smoke instance (built-in)
AdvancedEffects.Smoke(part, duration, color)

-- Sparkles instance (hay cho magic!)
AdvancedEffects.Sparkles(part, duration, color)

-- Highlight (NEW - outline objects, hay cho targeting!)
AdvancedEffects.Highlight(target, duration, color)
```

### Camera/Screen Effects (Player-only)

```lua
-- Blur screen
AdvancedEffects.CameraBlur(player, intensity, duration)

-- Shake camera (impact feeling)
AdvancedEffects.CameraShake(player, intensity, duration)

-- Bloom glow (magic/divine effects)
AdvancedEffects.CameraBloom(player, intensity, duration)

-- Color correction (desaturate for dark magic, etc.)
AdvancedEffects.ColorCorrection(player, saturation, contrast, duration)

-- Screen flash (white for holy, red for damage)
AdvancedEffects.ScreenFlash(player, color, duration)

-- Vignette (dark edges, focus effect)
AdvancedEffects.Vignette(player, intensity, duration)
```

### UI Effects (BillboardGui)

```lua
-- Damage numbers (floating numbers above enemies)
AdvancedEffects.DamageNumber(position, damage, isCrit, damageType)
-- damageType: "Normal", "Heal", "Soul", "Fire", "Ice"

-- Floating text (status messages)
AdvancedEffects.FloatingText(position, "STUNNED!", color, duration)
```

### Special Effects

```lua
-- Shockwave (expanding ring on ground)
AdvancedEffects.Shockwave(position, size, color, duration)

-- Energy sphere (charging attack)
local sphere = AdvancedEffects.EnergySphere(parent, duration, color)

-- Force field barrier (protective sphere)
local barrier = AdvancedEffects.ForceField(character, duration, color)

-- Lightning arc (chain lightning between points)
AdvancedEffects.LightningArc(startPos, endPos, color, segments)
```

---

## 🎮 Usage Examples

### Example 1: Cổ Thần Mega Punch

```lua
-- Charging
local sphere = AdvancedEffects.EnergySphere(
    player.Character.HumanoidRootPart,
    2,
    Color3.fromRGB(200, 150, 100)
)

task.wait(2)

-- Punch!
AdvancedEffects.CameraShake(player, 1, 0.5)
AdvancedEffects.Shockwave(
    enemy.Position,
    15,
    Color3.fromRGB(200, 150, 100),
    0.5
)
EffectLibrary.Explosion(enemy.Position, 10, Color3.fromRGB(255, 150, 0))

-- Damage number
AdvancedEffects.DamageNumber(
    enemy.Position + Vector3.new(0, 3, 0),
    1500,
    true, -- is crit
    "Normal"
)
```

### Example 2: Tiên Thiên Lightning Strike

```lua
-- Target highlight
AdvancedEffects.Highlight(
    enemy,
    1,
    Color3.fromRGB(255, 255, 100)
)

task.wait(0.5)

-- Lightning!
EffectLibrary.Lightning(
    enemy.Position + Vector3.new(0, 20, 0),
    enemy.Position
)

-- Screen effects for caster
AdvancedEffects.CameraBloom(player, 2, 1)
AdvancedEffects.ScreenFlash(player, Color3.fromRGB(255, 255, 255), 0.3)

-- Damage
AdvancedEffects.DamageNumber(
    enemy.Position + Vector3.new(0, 3, 0),
    2000,
    false,
    "Ice" -- Lightning = Ice color
)
```

### Example 3: Ma Đạo Soul Drain

```lua
-- Start draining
AdvancedEffects.Highlight(
    enemy,
    3,
    Color3.fromRGB(150, 0, 200)
)

-- Screen vignette for caster
AdvancedEffects.Vignette(player, 0.7, 3)

-- Soul particles
for i = 1, 10 do
    task.wait(0.3)
    EffectLibrary.Soul(enemy.Position)
    EffectLibrary.LightningArc(
        enemy.Position,
        player.Character.HumanoidRootPart.Position,
        Color3.fromRGB(150, 0, 200),
        5
    )

    -- Heal number on player
    AdvancedEffects.DamageNumber(
        player.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0),
        50,
        false,
        "Heal"
    )
end

-- Final burst
EffectLibrary.Explosion(enemy.Position, 8, Color3.fromRGB(150, 0, 200))
```

### Example 4: Defensive Skill (Force Field)

```lua
-- Activate barrier
local barrier = AdvancedEffects.ForceField(
    player.Character,
    10,
    Color3.fromRGB(100, 200, 255)
)

-- Screen effects
AdvancedEffects.CameraBloom(player, 1, 0.5)
AdvancedEffects.ColorCorrection(player, 0.5, 0, 10) -- Slightly saturated

-- Sparkles on character
local sparkles = AdvancedEffects.Sparkles(
    player.Character.HumanoidRootPart,
    10,
    Color3.fromRGB(100, 200, 255)
)

-- Floating text
AdvancedEffects.FloatingText(
    player.Character.HumanoidRootPart.Position + Vector3.new(0, 4, 0),
    "PROTECTED!",
    Color3.fromRGB(100, 200, 255),
    2
)
```

### Example 5: Ultimate Skill Combo

```lua
function UltimateSkill(player, enemies)
    -- Phase 1: Charge (2 seconds)
    local sphere = AdvancedEffects.EnergySphere(
        player.Character.HumanoidRootPart,
        2,
        Color3.fromRGB(255, 200, 0)
    )
    AdvancedEffects.CameraBloom(player, 2, 2)
    AdvancedEffects.FloatingText(
        player.Character.HumanoidRootPart.Position,
        "CHARGING...",
        Color3.fromRGB(255, 200, 0),
        2
    )

    task.wait(2)

    -- Phase 2: Release
    AdvancedEffects.ScreenFlash(player, Color3.fromRGB(255, 255, 255), 0.5)
    AdvancedEffects.CameraShake(player, 2, 1)

    -- Shockwave
    AdvancedEffects.Shockwave(
        player.Character.HumanoidRootPart.Position,
        30,
        Color3.fromRGB(255, 200, 0),
        1
    )

    -- Phase 3: Multi-hit
    for _, enemy in ipairs(enemies) do
        -- Highlight
        AdvancedEffects.Highlight(enemy, 0.5, Color3.fromRGB(255, 0, 0))

        -- Lightning
        EffectLibrary.Lightning(enemy.Position + Vector3.new(0, 10, 0), enemy.Position)

        -- Fire
        AdvancedEffects.QuickFire(enemy.PrimaryPart, 3)

        -- Damage number
        AdvancedEffects.DamageNumber(
            enemy.Position + Vector3.new(0, 3, 0),
            5000,
            true,
            "Fire"
        )

        task.wait(0.2)
    end

    -- Phase 4: Final explosion
    task.wait(0.5)
    for _, enemy in ipairs(enemies) do
        EffectLibrary.Explosion(enemy.Position, 15, Color3.fromRGB(255, 100, 0))
    end

    AdvancedEffects.CameraShake(player, 3, 1)
end
```

---

## 📊 Effect Categories

### 🔥 Damage Effects
```lua
-- Visual
EffectLibrary.Explosion()
EffectLibrary.Slash()
EffectLibrary.Lightning()
AdvancedEffects.Shockwave()

-- UI
AdvancedEffects.DamageNumber()

-- Screen
AdvancedEffects.CameraShake()
AdvancedEffects.ScreenFlash()
```

### 💚 Heal Effects
```lua
EffectLibrary.Heal()
AdvancedEffects.DamageNumber(pos, amount, false, "Heal")
AdvancedEffects.Sparkles(part, 2, Color3.fromRGB(0, 255, 100))
```

### 🛡️ Defensive Effects
```lua
AdvancedEffects.ForceField()
AdvancedEffects.Highlight()
AdvancedEffects.ColorCorrection() -- Saturation boost
```

### ⚡ Buff Effects
```lua
EffectLibrary.Aura()
AdvancedEffects.Sparkles()
AdvancedEffects.FloatingText()
AdvancedEffects.CameraBloom()
```

### 💀 Dark/Soul Effects
```lua
EffectLibrary.Soul()
EffectLibrary.Blood()
AdvancedEffects.Vignette()
AdvancedEffects.ColorCorrection(-1, 0) -- Desaturate
```

### 🎯 Targeting Effects
```lua
AdvancedEffects.Highlight() -- Best!
AdvancedEffects.Sparkles()
EffectLibrary.Aura()
```

---

## 💡 Best Practices

### Performance
- ✅ Use AdvancedEffects built-in instances (Fire, Smoke, Sparkles) - faster than custom particles
- ✅ Use Debris:AddItem() để auto cleanup
- ✅ Limit concurrent effects (< 20)
- ⚠️ Camera effects chỉ dùng cho local player

### Visual Quality
- 🎨 Combine multiple effects (e.g., Fire + Smoke + Sparkles)
- 🎨 Use Highlight for targeting - rất rõ ràng!
- 🎨 DamageNumber cho feedback
- 🎨 ScreenFlash + CameraShake cho impact

### UX
- 📱 Floating text cho status messages
- 📱 Color-code damage types
- 📱 Camera effects cho important moments
- 📱 Highlight enemies khi targeting

---

## 🆕 New in AdvancedEffects

**Chưa có trong EffectLibrary:**
1. ✨ **Highlight** - Outline objects (BEST for targeting!)
2. 📸 **Camera effects** - Blur, Bloom, Shake, ColorCorrection
3. 💬 **DamageNumber** - Floating damage numbers
4. 💬 **FloatingText** - Status messages
5. ⚡ **Shockwave** - Ground impact effect
6. 🔮 **EnergySphere** - Charging visual
7. 🛡️ **ForceField** - Barrier sphere
8. ⚡ **LightningArc** - Chain lightning
9. 🔥 **QuickFire** - Built-in Fire instance
10. 💨 **Smoke** - Built-in Smoke instance
11. ✨ **Sparkles** - Built-in Sparkles instance

---

## 📚 Files

- **[EffectLibrary.lua](src/ReplicatedStorage/Modules/Effects/EffectLibrary.lua)** - Basic effects
- **[AdvancedEffects.lua](src/ReplicatedStorage/Modules/Effects/AdvancedEffects.lua)** - Advanced effects ⭐
- **[SkillEffects.lua](src/ReplicatedStorage/Modules/Effects/SkillEffects.lua)** - Pre-built skills

---

**Giờ bạn có 34+ effects để dùng! 🎨✨**
