# 📱 Mobile Controls Guide

Hệ thống controls hoàn chỉnh cho cả PC và Mobile.

---

## 🎯 Tổng Quan

### ✅ Đã Hoàn Thành

**PC Controls:**
- ✅ WASD - Di chuyển
- ✅ Mouse - Attack & aim
- ✅ Q, E, R, F - Skills
- ✅ I, B - UI (Inventory, Shop)
- ✅ T - Toggle target

**Mobile Controls:**
- ✅ Virtual Joystick - Di chuyển
- ✅ Attack Button - Tấn công
- ✅ Skill Buttons (Q, E, R, F) - Skills với cooldown
- ✅ Auto-Target - Tự động tìm enemy
- ✅ Auto-Aim - Tự động quay về enemy
- ✅ Touch enemy - Manual target

---

## 📁 Files

```
src/StarterPlayer/StarterPlayerScripts/Mobile/
├── MobileControls.lua    ← Virtual joystick + buttons
└── AutoTarget.lua        ← Auto-targeting system
```

---

## 🕹️ Mobile Controls UI

### Layout

```
┌─────────────────────────────────────┐
│                                     │
│                          [R] Skill3 │
│                          [E] Skill2 │
│                          [Q] Skill1 │
│                                     │
│                                     │
│                                     │
│                         [F] [⚔️]   │
│   [🕹️]                  Skill4 Attack│
│    Joystick                         │
└─────────────────────────────────────┘
```

### Controls

#### 1. Virtual Joystick (Bottom Left)
```lua
-- Di chuyển nhân vật
-- Drag inner circle để di chuyển
-- Max distance: 45 pixels from center
-- Direction: -1 to 1 for X and Y
```

#### 2. Attack Button (Bottom Right)
```lua
-- Icon: ⚔️
-- Size: 80x80
-- Color: Red (RGB 255, 100, 100)
-- Function: Basic attack
```

#### 3. Skill Buttons (Right Side)
```lua
Skills = {
    Q = {Icon = "💥", Cooldown = 5s,  Position = Bottom},
    E = {Icon = "⚡", Cooldown = 10s, Position = Middle-Bottom},
    R = {Icon = "🔥", Cooldown = 15s, Position = Middle-Top},
    F = {Icon = "🛡️", Cooldown = 20s, Position = Top}
}
```

---

## 🎯 Auto-Target System

### Features

```lua
-- Auto-targeting
✅ Tự động tìm enemy gần nhất
✅ Max distance: 50 studs
✅ Highlight target (red outline)
✅ Auto-update khi enemy chết hoặc quá xa

-- Auto-aim
✅ Tự động quay nhân vật về target
✅ Character faces target direction
✅ Smooth rotation

-- Manual target
✅ PC: Nhấn T để toggle target
✅ Mobile: Touch vào enemy để target
```

### Config

```lua
AutoTarget.Config = {
    Enabled = true,
    MaxDistance = 50,        -- Max studs
    AutoAim = true,          -- Auto rotate to target
    ShowHighlight = true,    -- Red outline
    TargetKey = Enum.KeyCode.T,
    UpdateInterval = 0.2     -- Update every 0.2s
}
```

---

## 🎮 Usage Examples

### Example 1: Get Current Target

```lua
local AutoTarget = require(StarterPlayerScripts.Mobile.AutoTarget)

-- Get current target
local target = AutoTarget.GetTarget()

if target then
    print("Current target:", target.Name)

    -- Get target position
    local pos = AutoTarget.GetTargetPosition()
    print("Target position:", pos)
else
    print("No target")
end
```

### Example 2: Weapon Attack với Auto-Target

```lua
-- Trong weapon:Attack()
function Weapon:Attack()
    local AutoTarget = require(StarterPlayerScripts.Mobile.AutoTarget)
    local target = AutoTarget.GetTarget()

    if target then
        -- Attack targeted enemy
        self:DealDamage(target)
    else
        -- No target, attack in front
        -- Find enemies in range manually
    end
end
```

### Example 3: Skill với Auto-Target

```lua
-- Bind skill button to actual skill
local skillButtons = MobileControls.CreateSkillButtons(ui)

skillButtons.Q.Button.MouseButton1Click:Connect(function()
    if not skillButtons.Q.IsOnCooldown then
        -- Get target
        local target = AutoTarget.GetTarget()

        if target then
            -- Use skill on target
            SkillEffects.LightningStrike(player, target, 500)

            -- Start cooldown
            MobileControls.StartCooldown(skillButtons.Q)
        else
            print("No target!")
        end
    end
end)
```

### Example 4: Integrate với Weapon System

```lua
local BaseWeapon = require(ReplicatedStorage.Modules.Weapons.BaseWeapon)
local AutoTarget = require(StarterPlayerScripts.Mobile.AutoTarget)

-- Override Attack method
function MyWeapon:Attack(target)
    -- Mobile: Use auto-target if no target provided
    if not target and game:GetService("UserInputService").TouchEnabled then
        target = AutoTarget.GetTarget()
    end

    -- Call base attack
    BaseWeapon.Attack(self, target)
end
```

---

## 🔧 Customization

### Change Joystick Position

```lua
-- In MobileControls.CreateJoystick()
joystickFrame.Position = UDim2.new(0, 50, 1, -200)  -- Left side
-- Change to:
joystickFrame.Position = UDim2.new(1, -200, 1, -200)  -- Right side
```

### Change Button Size/Color

```lua
-- In MobileControls.CreateAttackButton()
button.Size = UDim2.new(0, 80, 0, 80)  -- Default
button.BackgroundColor3 = Color3.fromRGB(255, 100, 100)  -- Red

-- Change to:
button.Size = UDim2.new(0, 100, 0, 100)  -- Bigger
button.BackgroundColor3 = Color3.fromRGB(100, 200, 255)  -- Blue
```

### Change Skill Icons

```lua
-- In MobileControls.CreateSkillButtons()
local skills = {
    {Key = "Q", Icon = "💥"},  -- Default
    {Key = "E", Icon = "⚡"},
    {Key = "R", Icon = "🔥"},
    {Key = "F", Icon = "🛡️"}
}

-- Change to custom icons:
{Key = "Q", Icon = "🗡️"},  -- Sword
{Key = "E", Icon = "❄️"},  -- Ice
{Key = "R", Icon = "💀"},  -- Skull
{Key = "F", Icon = "✨"}   -- Sparkle
```

### Add More Skill Buttons

```lua
-- Add 5th and 6th skills
{Key = "Z", Position = UDim2.new(1, -200, 1, -200), Icon = "💨", Cooldown = 8},
{Key = "X", Position = UDim2.new(1, -200, 1, -300), Icon = "🌟", Cooldown = 12}
```

---

## 🎨 Visual Effects on Mobile

### Screen Effects (Mobile-safe)

```lua
local AdvancedEffects = require(ReplicatedStorage.Modules.Effects.AdvancedEffects)

-- Safe for mobile
AdvancedEffects.ScreenFlash(player, Color3.fromRGB(255, 255, 255), 0.3)
AdvancedEffects.CameraShake(player, 1, 0.5)

-- Use sparingly on mobile (performance)
AdvancedEffects.CameraBlur(player, 5, 0.5)  -- Keep intensity low
AdvancedEffects.CameraBloom(player, 1, 0.5) -- Keep intensity low
```

### UI Effects (Always safe)

```lua
-- Damage numbers - works on all devices
AdvancedEffects.DamageNumber(position, 1500, true, "Fire")

-- Floating text
AdvancedEffects.FloatingText(position, "CRITICAL!", Color3.fromRGB(255, 200, 0), 2)

-- Highlight target
AdvancedEffects.Highlight(enemy, 1, Color3.fromRGB(255, 0, 0))
```

---

## 📊 Performance Tips

### Mobile Optimization

```lua
-- ✅ DO: Use built-in effects
AdvancedEffects.QuickFire(part, 3)  -- Built-in Fire instance
AdvancedEffects.Sparkles(part, 3)   -- Built-in Sparkles

-- ✅ DO: Limit particle count
EffectLibrary.Lightning(pos, target)  -- OK, only 20 particles

-- ⚠️ AVOID: Too many custom particles
for i = 1, 100 do  -- BAD on mobile!
    EffectLibrary.Soul(randomPos)
end

-- ✅ DO: Use Highlight for targeting
AdvancedEffects.Highlight(enemy)  -- Very efficient!

-- ⚠️ AVOID: Constant screen effects
-- Don't spam camera blur/bloom every frame
```

### Cooldown Management

```lua
-- Automatically handled by MobileControls
-- Each skill button has visual cooldown overlay
-- Shows remaining seconds
-- Prevents spam clicking
```

---

## 🐛 Troubleshooting

### Mobile Controls Not Showing?

```lua
-- Check if on mobile device
local MobileControls = require(StarterPlayerScripts.Mobile.MobileControls)
print("Is mobile:", MobileControls.IsMobile)

-- Force enable (for testing on PC)
MobileControls.IsMobile = true
MobileControls.Initialize()
```

### Joystick Not Working?

```lua
-- Check if joystick is active
print("Joystick active:", joystickData.Active)
print("Direction:", joystickData.Direction)

-- Make sure Humanoid exists
local humanoid = player.Character:FindFirstChild("Humanoid")
print("Humanoid:", humanoid)
```

### Auto-Target Not Finding Enemies?

```lua
-- Check max distance
AutoTarget.Config.MaxDistance = 100  -- Increase range

-- Check if enemies have Humanoid
-- Enemies MUST have:
-- - Model
-- - Humanoid (with Health > 0)
-- - HumanoidRootPart

-- Test manually
local nearest = AutoTarget.FindNearestEnemy()
print("Nearest enemy:", nearest)
```

### Skills Not Firing?

```lua
-- Check cooldown
print("On cooldown:", skillButton.IsOnCooldown)
print("Remaining:", skillButton.CurrentCooldown)

-- Check target
local target = AutoTarget.GetTarget()
print("Has target:", target ~= nil)

-- Make sure RemoteEvents are set up
-- TODO: Connect skill buttons to actual skills
```

---

## 🚀 Next Steps

### TODO: Integrate với Weapon System

```lua
-- src/ReplicatedStorage/Modules/Weapons/BaseWeapon.lua
-- Add mobile support to Attack method

function BaseWeapon:Attack(target)
    -- Get target from AutoTarget if on mobile
    if not target and UserInputService.TouchEnabled then
        local AutoTarget = require(StarterPlayerScripts.Mobile.AutoTarget)
        target = AutoTarget.GetTarget()
    end

    -- Rest of attack logic...
end
```

### TODO: Bind Skill Buttons to Actual Skills

```lua
-- In MobileControls initialization
skillButtons.Q.Button.MouseButton1Click:Connect(function()
    if not skillButtons.Q.IsOnCooldown then
        -- Fire RemoteEvent to server
        ReplicatedStorage.RemoteEvents.UseSkill:FireServer("Q")

        -- Start cooldown
        MobileControls.StartCooldown(skillButtons.Q)
    end
end)

-- On server
RemoteEvents.UseSkill.OnServerEvent:Connect(function(player, skillKey)
    -- Execute skill based on key
    if skillKey == "Q" then
        SkillEffects.LightningStrike(player, target, 500)
    elseif skillKey == "E" then
        SkillEffects.IceStorm(player, position, 15, 5)
    -- ...
    end
end)
```

### TODO: Save Control Settings

```lua
-- Allow players to customize controls
-- - Joystick size/position
-- - Button size/layout
-- - Auto-aim on/off
-- - Max target distance
-- Save to DataStore
```

---

## 📚 References

- **[MobileControls.lua](src/StarterPlayer/StarterPlayerScripts/Mobile/MobileControls.lua)** - Virtual joystick + buttons
- **[AutoTarget.lua](src/StarterPlayer/StarterPlayerScripts/Mobile/AutoTarget.lua)** - Auto-targeting
- **[EffectLibrary.lua](src/ReplicatedStorage/Modules/Effects/EffectLibrary.lua)** - Basic effects
- **[AdvancedEffects.lua](src/ReplicatedStorage/Modules/Effects/AdvancedEffects.lua)** - Screen/UI effects
- **[WEAPON_SYSTEM_SUMMARY.md](WEAPON_SYSTEM_SUMMARY.md)** - Weapon integration

---

## ✅ Summary

**Mobile Controls:**
- ✅ Virtual joystick (movement)
- ✅ Attack button
- ✅ 4 skill buttons (Q, E, R, F)
- ✅ Visual cooldowns
- ✅ Auto-detect mobile device

**Auto-Target:**
- ✅ Auto-find nearest enemy
- ✅ Auto-aim character
- ✅ Highlight target
- ✅ Manual target by touch
- ✅ PC support (T key)

**Responsive:**
- ✅ Only shows on mobile devices
- ✅ Auto-hides on PC
- ✅ Touch-optimized UI
- ✅ Performance-optimized

**Ready for mobile! 📱⚔️**
