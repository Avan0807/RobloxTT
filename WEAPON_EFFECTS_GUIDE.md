-- 🎨 Weapon & Effects System - Complete Guide

Hệ thống OOP hoàn chỉnh cho vũ khí và hiệu ứng công pháp.

---

## 📚 Mục Lục

1. [Tổng Quan](#tổng-quan)
2. [BaseWeapon Class](#baseweapon-class)
3. [EffectLibrary](#effectlibrary)
4. [Weapon Types](#weapon-types)
5. [SkillEffects](#skilleffects)
6. [Tạo Vũ Khí Mới](#tạo-vũ-khí-mới)
7. [Examples](#examples)

---

## 🎯 Tổng Quan

### Files Đã Tạo

```
src/ReplicatedStorage/Modules/
├── Weapons/
│   ├── BaseWeapon.lua         # Base class cho tất cả vũ khí
│   ├── SwordWeapon.lua        # Kiếm (fast, slash, bleeding)
│   ├── FlagWeapon.lua         # Cờ (long range, AOE, knockback)
│   ├── FistWeapon.lua         # Đấm tay (very fast, combo, lifesteal)
│   └── WeaponExamples.lua     # 6 vũ khí mẫu
│
└── Effects/
    ├── EffectLibrary.lua      # 14 hiệu ứng reusable
    └── SkillEffects.lua       # 10+ công pháp effects
```

### Architecture

```
BaseWeapon (abstract)
    ├── SwordWeapon (extends BaseWeapon)
    ├── FlagWeapon (extends BaseWeapon)
    └── FistWeapon (extends BaseWeapon)

EffectLibrary (static functions)
    ├── Lightning, Fire, Ice, Blood, Soul, Wind
    ├── Explosion, Slash, Heal, Aura
    └── ...

SkillEffects (static functions)
    ├── Tiên Thiên: LightningStrike, IceStorm, Fireball
    ├── Cổ Thần: GoldenBody, EightDesolateFist
    └── Ma Đạo: SoulDrain, BloodDemonSlash, MassacreSoulShatter
```

---

## ⚔️ BaseWeapon Class

### Properties

```lua
-- Basic Info
self.Name = "Weapon Name"
self.Type = "Sword" | "Flag" | "Fist"
self.Rarity = "Common" | "Rare" | "Epic" | "Legendary" | "Mythic"
self.Level = 1

-- Stats
self.Damage = 100
self.AttackSpeed = 1.0  -- Attacks per second
self.Range = 10         -- Studs
self.CritRate = 0.05    -- 5%
self.CritDamage = 1.5   -- x1.5 damage

-- Abilities
self.PassiveAbility = function(self, target, damage) end
self.ActiveAbility = function(self, target) end
self.AbilityCooldown = 10 -- Seconds
```

### Methods

```lua
-- Core Methods
weapon:Equip(player)              -- Equip weapon to player
weapon:Unequip()                  -- Unequip weapon
weapon:Attack(target)             -- Basic attack
weapon:DealDamage(target)         -- Calculate and deal damage
weapon:UseAbility(target)         -- Use active ability
weapon:TriggerPassive(target, damage)  -- Override for passive effects

-- Utility
weapon:Upgrade()                  -- Upgrade weapon (+10% damage)
weapon:GetInfo()                  -- Get weapon info (for UI)
weapon:PlayAnimation(animId)      -- Play animation
weapon:PlayEffect(effectFunc, pos) -- Play visual effect
weapon:PlaySound(soundId)         -- Play sound
```

---

## ✨ EffectLibrary

### Available Effects (14 total)

```lua
local EffectLibrary = require(ReplicatedStorage.Modules.Effects.EffectLibrary)

-- Elemental Effects
EffectLibrary.Lightning(position, targetPosition)
EffectLibrary.Fire(position, duration)
EffectLibrary.Ice(position, size)
EffectLibrary.Wind(position, direction)

-- Ma Đạo Effects
EffectLibrary.Blood(position)
EffectLibrary.Soul(position)

-- Combat Effects
EffectLibrary.Explosion(position, size, color)
EffectLibrary.Slash(startPos, endPos, color)

-- Support Effects
EffectLibrary.Heal(position)
EffectLibrary.Aura(parent, color, duration)  -- Continuous effect
EffectLibrary.SpeedBoost(caster, duration, multiplier)
EffectLibrary.Teleport(caster, targetPosition)
```

### Usage Examples

```lua
-- Simple effects
EffectLibrary.Lightning(Vector3.new(0, 10, 0), Vector3.new(0, 0, 0))
EffectLibrary.Fire(workspace.Part.Position, 5) -- 5 seconds
EffectLibrary.Ice(enemy.Position, 3) -- Size 3

-- Advanced effects
EffectLibrary.Explosion(
    Vector3.new(0, 5, 0),
    10,  -- Size
    Color3.fromRGB(255, 100, 0)  -- Orange
)

EffectLibrary.Slash(
    sword.Position,
    enemy.Position,
    Color3.fromRGB(255, 0, 0)  -- Red
)

-- Continuous effects
local aura = EffectLibrary.Aura(
    player.Character.HumanoidRootPart,
    Color3.fromRGB(255, 200, 0),  -- Gold
    10  -- Duration
)
```

---

## 🗡️ Weapon Types

### 1. SwordWeapon (Kiếm)

**Đặc điểm:**
- Fast attacks (1.5 attacks/sec)
- Medium range (8 studs)
- 3-hit combos
- Slash effects
- High crit (10% base)

**Usage:**
```lua
local SwordWeapon = require(ReplicatedStorage.Modules.Weapons.SwordWeapon)

local mySword = SwordWeapon.new({
    Name = "My Custom Sword",
    Damage = 300,
    SlashColor = Color3.fromRGB(255, 0, 0),

    PassiveAbility = function(self, target, damage)
        -- Custom passive (e.g., bleeding)
        if math.random() < 0.3 then
            print("Bleeding!")
            -- Apply bleeding DoT
        end
    end,

    ActiveAbility = function(self, target)
        -- Custom active skill
        print("Dash Slash!")
        -- Dash forward and slash
    end
})

mySword:Equip(player)
mySword:Attack(enemy)
mySword:UseAbility(boss)
```

### 2. FlagWeapon (Cờ/Thương)

**Đặc điểm:**
- Slower attacks (0.8 attacks/sec)
- Long range (15 studs)
- AOE damage (8 studs radius)
- Spinning attacks
- Knockback

**Usage:**
```lua
local FlagWeapon = require(ReplicatedStorage.Modules.Weapons.FlagWeapon)

local myFlag = FlagWeapon.new({
    Name = "Wind Flag",
    Damage = 400,
    AOERadius = 10,
    SpinSpeed = 360,

    PassiveAbility = function(self, target, damage)
        -- Knockback already included in base FlagWeapon
        -- Add custom effects
    end,

    ActiveAbility = function(self, target)
        -- Whirlwind attack (already included)
        -- Or override with custom skill
    end
})
```

### 3. FistWeapon (Đấm Tay)

**Đặc điểm:**
- Very fast attacks (2.5 attacks/sec)
- Short range (5 studs)
- 5-hit combos
- Combo damage scaling (+20% per hit)
- Lifesteal (10%)
- High crit (15% base)

**Usage:**
```lua
local FistWeapon = require(ReplicatedStorage.Modules.Weapons.FistWeapon)

local myFist = FistWeapon.new({
    Name = "Iron Fist",
    Damage = 150,
    ComboDamageBonus = 0.3, -- +30% per combo

    PassiveAbility = function(self, target, damage)
        -- Lifesteal already included
        -- Add custom effects (e.g., stun)
    end,

    ActiveAbility = function(self, target)
        -- Rapid Punches (already included)
        -- Or custom ability
    end
})
```

---

## 🔮 SkillEffects

### Tiên Thiên (Magic) Skills

```lua
local SkillEffects = require(ReplicatedStorage.Modules.Effects.SkillEffects)

-- Lightning Strike (5 strikes + mega strike)
SkillEffects.LightningStrike(player, enemy, 500)

-- Ice Storm (AOE over time)
SkillEffects.IceStorm(player, position, 15, 5)  -- radius, duration

-- Fireball (Projectile)
SkillEffects.Fireball(player, direction, 300)
```

### Cổ Thần (Body) Skills

```lua
-- Golden Body (Defense buff)
SkillEffects.GoldenBody(player, 10)  -- 10 seconds

-- Eight Desolate Fist (8-direction punch AOE)
SkillEffects.EightDesolateFist(player, 400)
```

### Ma Đạo (Soul/Dark) Skills

```lua
-- Soul Drain (Drain HP over 3 seconds)
SkillEffects.SoulDrain(player, enemy, 500)

-- Blood Demon Slash (Dash + multi-slash + lifesteal)
SkillEffects.BloodDemonSlash(player, enemy, 600)

-- Massacre Soul Shatter (Mega AOE ultimate)
SkillEffects.MassacreSoulShatter(player, position, 20, 1000)
```

### Utility Skills

```lua
-- Speed Boost
SkillEffects.SpeedBoost(player, 5, 2)  -- 5 sec, x2 speed

-- Teleport
SkillEffects.Teleport(player, targetPosition)
```

---

## 🎨 Tạo Vũ Khí Mới

### Template 1: Simple Sword

```lua
local SwordWeapon = require(ReplicatedStorage.Modules.Weapons.SwordWeapon)
local EffectLibrary = require(ReplicatedStorage.Modules.Effects.EffectLibrary)

local function CreateFireSword()
    return SwordWeapon.new({
        Name = "Hỏa Diệm Kiếm",
        Rarity = "Epic",
        Damage = 400,
        SlashColor = Color3.fromRGB(255, 100, 0),

        -- Passive: Burn on hit
        PassiveAbility = function(self, target, damage)
            -- 50% chance to burn
            if math.random() < 0.5 then
                EffectLibrary.Fire(target.Position, 3)

                -- Burn DoT (3 seconds)
                for i = 1, 3 do
                    task.wait(1)
                    local humanoid = target:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        humanoid:TakeDamage(damage * 0.2) -- 20% per second
                    end
                end
            end
        end,

        -- Active: Flame Slash Wave
        ActiveAbility = function(self, target)
            local character = self.Owner.Character
            local rootPart = character.HumanoidRootPart

            -- Fire wave forward
            for i = 1, 10 do
                local pos = rootPart.Position + (rootPart.CFrame.LookVector * i * 2)
                EffectLibrary.Fire(pos, 2)

                -- Damage enemies
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                        local distance = (obj.PrimaryPart.Position - pos).Magnitude
                        if distance <= 5 then
                            obj.Humanoid:TakeDamage(self.Damage * 1.5)
                        end
                    end
                end

                task.wait(0.1)
            end
        end,

        AbilityCooldown = 15
    })
end
```

### Template 2: Ice Fist

```lua
local FistWeapon = require(ReplicatedStorage.Modules.Weapons.FistWeapon)
local EffectLibrary = require(ReplicatedStorage.Modules.Effects.EffectLibrary)

local function CreateIceFist()
    return FistWeapon.new({
        Name = "Băng Phong Quyền",
        Rarity = "Rare",
        Damage = 200,

        -- Passive: Freeze on crit
        PassiveAbility = function(self, target, damage)
            -- Base lifesteal
            FistWeapon.TriggerPassive(self, target, damage)

            -- Freeze on crit
            local isCrit = math.random() < self.CritRate
            if isCrit then
                EffectLibrary.Ice(target.Position, 3)

                -- Slow enemy (TODO: implement slow)
                print("❄️ Frozen!")
            end
        end,

        -- Active: Ice Prison
        ActiveAbility = function(self, target)
            if not target then return end

            -- Trap in ice
            EffectLibrary.Ice(target.Position, 5)

            -- Stun for 3 seconds
            local humanoid = target:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 0

                task.delay(3, function()
                    humanoid.WalkSpeed = 16
                end)
            end

            -- Deal damage over time
            for i = 1, 3 do
                task.wait(1)
                if humanoid and humanoid.Health > 0 then
                    humanoid:TakeDamage(self.Damage * 0.5)
                    EffectLibrary.Ice(target.Position, 3)
                end
            end
        end,

        AbilityCooldown = 20
    })
end
```

### Template 3: Soul Flag

```lua
local FlagWeapon = require(ReplicatedStorage.Modules.Weapons.FlagWeapon)
local EffectLibrary = require(ReplicatedStorage.Modules.Effects.EffectLibrary)

local function CreateSoulFlag()
    return FlagWeapon.new({
        Name = "Hồn Pháp Cờ",
        Rarity = "Legendary",
        Damage = 600,
        AOERadius = 12,

        -- Passive: Soul steal on kill
        PassiveAbility = function(self, target, damage)
            -- Base knockback
            FlagWeapon.TriggerPassive(self, target, damage)

            -- Soul steal on kill
            local humanoid = target:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health <= 0 then
                EffectLibrary.Soul(target.Position)

                -- Heal caster
                local casterHumanoid = self.Owner.Character:FindFirstChild("Humanoid")
                if casterHumanoid then
                    casterHumanoid.Health = math.min(
                        casterHumanoid.Health + 100,
                        casterHumanoid.MaxHealth
                    )
                end
            end
        end,

        -- Active: Soul Vortex
        ActiveAbility = function(self, target)
            local character = self.Owner.Character
            local rootPart = character.HumanoidRootPart

            -- Create soul vortex
            for i = 1, 10 do
                local angle = (i / 10) * math.pi * 2
                local radius = 15
                local pos = rootPart.Position + Vector3.new(
                    math.cos(angle) * radius,
                    2,
                    math.sin(angle) * radius
                )

                EffectLibrary.Soul(pos)
            end

            -- Pull enemies in
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= character then
                    local distance = (obj.PrimaryPart.Position - rootPart.Position).Magnitude
                    if distance <= 20 then
                        -- Pull towards center
                        local direction = (rootPart.Position - obj.PrimaryPart.Position).Unit

                        local bodyVelocity = Instance.new("BodyVelocity")
                        bodyVelocity.Velocity = direction * 50
                        bodyVelocity.MaxForce = Vector3.new(50000, 50000, 50000)
                        bodyVelocity.Parent = obj.PrimaryPart

                        game:GetService("Debris"):AddItem(bodyVelocity, 2)

                        -- Damage
                        obj.Humanoid:TakeDamage(self.Damage * 2)
                        EffectLibrary.Soul(obj.PrimaryPart.Position)
                    end
                end
            end

            -- Final explosion
            task.wait(2)
            EffectLibrary.Explosion(rootPart.Position, 15, Color3.fromRGB(100, 0, 150))
        end,

        AbilityCooldown = 30
    })
end
```

---

## 💡 Examples & Usage

### Example 1: Equip Weapon

```lua
local WeaponExamples = require(ReplicatedStorage.Modules.Weapons.WeaponExamples)

-- Create weapon
local sword = WeaponExamples.ThienDiKiem()

-- Equip to player
sword:Equip(player)

-- Attack enemy
sword:Attack(enemy)

-- Use special ability
sword:UseAbility(boss)

-- Unequip
sword:Unequip()
```

### Example 2: Use Skills

```lua
local SkillEffects = require(ReplicatedStorage.Modules.Effects.SkillEffects)

-- Player presses skill hotkey
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        -- Lightning Strike
        SkillEffects.LightningStrike(player, mouse.Target.Parent, 500)

    elseif input.KeyCode == Enum.KeyCode.E then
        -- Ice Storm at mouse position
        SkillEffects.IceStorm(player, mouse.Hit.Position, 15, 5)

    elseif input.KeyCode == Enum.KeyCode.R then
        -- Fireball towards mouse
        local direction = (mouse.Hit.Position - player.Character.HumanoidRootPart.Position).Unit
        SkillEffects.Fireball(player, direction, 300)
    end
end)
```

### Example 3: Custom Effect Combo

```lua
-- Create custom skill with multiple effects
function CustomUltimate(player, target)
    local rootPart = player.Character.HumanoidRootPart

    -- Phase 1: Lightning strikes
    for i = 1, 5 do
        EffectLibrary.Lightning(rootPart.Position + Vector3.new(0, 10, 0), rootPart.Position)
        task.wait(0.2)
    end

    -- Phase 2: Ice explosion
    EffectLibrary.Ice(rootPart.Position, 10)

    -- Phase 3: Fire ring
    for i = 1, 8 do
        local angle = (i / 8) * math.pi * 2
        local pos = rootPart.Position + Vector3.new(math.cos(angle) * 10, 0, math.sin(angle) * 10)
        EffectLibrary.Fire(pos, 3)
    end

    -- Phase 4: Soul explosion
    for i = 1, 20 do
        local randomPos = rootPart.Position + Vector3.new(
            math.random(-15, 15),
            math.random(0, 10),
            math.random(-15, 15)
        )
        EffectLibrary.Soul(randomPos)
    end

    -- Final: Mega explosion
    task.wait(1)
    EffectLibrary.Explosion(rootPart.Position, 20, Color3.fromRGB(255, 255, 255))
end
```

---

## 📋 Available Weapons

### Sword Examples
1. **Thiên Địa Kiếm** (Heaven-Earth Sword)
   - Lightning on crit
   - Active: Lightning Slash AOE

2. **Ma Hoàng Kiếm** (Demon Emperor Sword)
   - Soul drain on kill
   - Active: Soul Explosion

### Flag Examples
3. **Phong Vân Cờ** (Wind-Cloud Flag)
   - Wind knockback
   - Active: Tornado

### Fist Examples
4. **Thiết Tay** (Iron Fist)
   - Lifesteal
   - Active: Mega Punch

5. **Ma Tôn Quyền** (Demon Lord Fist)
   - Blood explosion on kill
   - Active: Massacre Punch Barrage (20 punches!)

---

## 🎯 Tips & Best Practices

### Performance
- ✅ Effects tự động cleanup (Debris:AddItem)
- ✅ Use Heartbeat cho continuous effects
- ✅ Limit particle count (< 100 active)

### Balancing
- ⚖️ Sword: High damage, medium speed
- ⚖️ Flag: AOE damage, slower, knockback
- ⚖️ Fist: Lower damage, very fast, combo scaling

### Customization
- 🎨 Change `SlashColor` cho swords
- 🎨 Change `AOERadius` cho flags
- 🎨 Change `ComboDamageBonus` cho fists
- 🎨 Mix & match effects từ EffectLibrary

---

## 🚀 Next Steps

1. **Add weapon models** - Tạo 3D models cho vũ khí
2. **Add animations** - Tạo attack animations
3. **Add sounds** - Thêm SoundIds
4. **Implement buffs/debuffs** - Slow, stun, burn DoT
5. **Create weapon shop** - Integrate với ShopModule
6. **Add weapon upgrade system** - Level up, enhance, etc.

---

Hệ thống đã sẵn sàng! Bạn chỉ cần:
1. Design 3D models cho vũ khí
2. Tạo animations
3. Thêm sounds
4. Tạo vũ khí mới bằng templates

Happy coding! 🎮✨
