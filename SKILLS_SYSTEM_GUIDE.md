# ⚔️ Skills System - Hướng Dẫn Sử Dụng

## ✅ Vấn Đề Đã Fix

**Vấn đề**: Không thể dùng skills Q/E/R/F, không có keybindings, mobile buttons không hoạt động

**Giải pháp**:
- ✅ Created **PlayerController** - PC keyboard controls (Q/E/R/F)
- ✅ Created **SkillService** - Server-side skill handler
- ✅ Bound **Mobile skill buttons** to actual skill usage
- ✅ Added **visual effects** for each skill
- ✅ Fixed **SpawnProtectionNotification** RemoteEvent error

## 🎮 Controls

### PC Controls (Keyboard)

```
Q - Skill 1 (Cooldown: 2s)  💥 Red effect
E - Skill 2 (Cooldown: 5s)  💥 Blue effect
R - Skill 3 (Cooldown: 10s) 💥 Yellow effect
F - Skill 4 (Cooldown: 15s) 💥 Green effect

Shift - Dash (Cooldown: 3s) 💨 Quick dash

I - Open Inventory
P - Open Shop
```

### Mobile Controls (Touch)

```
Joystick (Left) - Move character

Skills (Right side):
┌──────┐
│  Q   │ ← Skill 1
├──────┤
│  E   │ ← Skill 2
├──────┤
│  R   │ ← Skill 3
└──────┘
   ┌──────┐
   │  F   │ ← Skill 4
   └──────┘

Attack Button (Bottom right) - Basic attack
```

## 🔥 Skills Currently Available

### Skill 1 (Q)
- **Effect**: Test Skill - Deal damage
- **Cooldown**: 2 seconds
- **Visual**: Red sphere explosion
- **Damage**: 50
- **Range**: 15 studs AOE

### Skill 2 (E)
- **Effect**: AOE Attack
- **Cooldown**: 5 seconds
- **Visual**: Blue sphere explosion
- **Damage**: 100
- **Range**: 15 studs AOE

### Skill 3 (R)
- **Effect**: Ultimate
- **Cooldown**: 10 seconds
- **Visual**: Yellow sphere explosion
- **Damage**: 150
- **Range**: 15 studs AOE

### Skill 4 (F)
- **Effect**: Defensive
- **Cooldown**: 15 seconds
- **Visual**: Green sphere explosion
- **Damage**: 200
- **Range**: 15 studs AOE

## 💨 Dash Ability (Shift)

- **Cooldown**: 3 seconds
- **Distance**: 20 studs
- **Effect**: Quick dash in movement direction
- **Visual**: Blue trail effect
- **Note**: If not moving, dashes forward

## 🧪 How to Test

### Test Skills on PC

1. **Spawn into game** (F5)
2. **Wait for spawn protection** to end (10s)
3. **Spawn an enemy**:
   ```
   /spawnEnemy Normal 5
   ```
4. **Press Q** - Red explosion, enemy takes 50 damage
5. **Press E** - Blue explosion, enemy takes 100 damage
6. **Press R** - Yellow explosion, enemy takes 150 damage
7. **Press F** - Green explosion, enemy takes 200 damage
8. **Press Shift** - Dash forward

### Test Skills on Mobile

1. **Enable mobile emulation** in Studio (if on PC):
   - View → Emulation → Device: Phone
2. **Spawn into game**
3. **Use virtual joystick** to move
4. **Tap skill buttons** (Q/E/R/F) on right side
5. **Observe** skill effects and cooldown timers

### Test with Boss

```bash
/god  # Enable god mode

/spawnBoss Linh Thú Vương

# Now spam skills!
Q → E → R → F
```

## 📊 Skills System Architecture

### Client Side

```
Player Presses Q
    ↓
PlayerController.UseSkill(1)
    ↓
Fires RemoteEvent:UseSkill(1)
    ↓
    [SERVER]
```

### Server Side

```
UseSkill Event Received
    ↓
SkillService.UseSkill(player, 1)
    ↓
Check cooldown → Execute skill → Create visual effect
    ↓
Damage nearby enemies (15 studs AOE)
    ↓
Set cooldown
```

### Mobile Integration

```
User Taps Q Button
    ↓
MobileControls: button.MouseButton1Click
    ↓
Convert "Q" → Slot 1
    ↓
Fires RemoteEvent:UseSkill(1)
    ↓
MobileControls.StartCooldown(button)
    ↓
Shows cooldown overlay + timer
```

## 🛠️ Customization

### Change Keybindings

Edit [PlayerController.lua:16-26](src/StarterPlayer/StarterPlayerScripts/PlayerController.lua:16-26):

```lua
PlayerController.Settings = {
	SkillKeys = {
		Skill1 = Enum.KeyCode.Q,   -- Change to your preferred key
		Skill2 = Enum.KeyCode.E,
		Skill3 = Enum.KeyCode.R,
		Skill4 = Enum.KeyCode.F,
	},

	OtherKeys = {
		Dash = Enum.KeyCode.LeftShift,  -- Change dash key
		Inventory = Enum.KeyCode.I,
		Shop = Enum.KeyCode.P,
	}
}
```

### Change Skill Cooldowns

Edit [SkillService.lua:17-36](src/ServerScriptService/Services/SkillService.lua:17-36):

```lua
SkillService.Skills = {
	[1] = {
		Name = "Skill 1 (Q)",
		Cooldown = 2,  -- Change cooldown (seconds)
		Effect = "Custom effect description"
	},
	-- ... more skills
}
```

### Change Skill Damage

Edit [SkillService.lua:93](src/ServerScriptService/Services/SkillService.lua:93):

```lua
-- Current: Higher slot = more damage
local damage = 50 * skillSlot  -- 50, 100, 150, 200

-- Fixed damage per skill
local damages = {100, 200, 500, 1000}
local damage = damages[skillSlot]
```

### Change Skill Effects Colors

Edit [SkillService.lua:104-113](src/ServerScriptService/Services/SkillService.lua:104-113):

```lua
if skillSlot == 1 then
	effect.Color = Color3.fromRGB(255, 100, 100) -- Red
elseif skillSlot == 2 then
	effect.Color = Color3.fromRGB(100, 100, 255) -- Blue
-- ... change colors here
```

### Change Dash Settings

Edit [PlayerController.lua:28-31](src/StarterPlayer/StarterPlayerScripts/PlayerController.lua:28-31):

```lua
DashDistance = 20,     -- studs (increase for longer dash)
DashCooldown = 3,      -- seconds
```

## 🔮 Advanced: Real Skills Implementation

Current skills are **placeholder/test skills**. To implement real cultivation skills:

### 1. Create Skill Definitions

```lua
-- In SkillsModule.lua or similar
local CultivationSkills = {
	TienThien = {
		{Name = "Lightning Strike", Damage = 200, Cooldown = 5, Element = "Lightning"},
		{Name = "Ice Storm", Damage = 150, Cooldown = 10, Element = "Ice"},
		-- ...
	},
	MaDao = {
		{Name = "Soul Drain", Damage = 180, Cooldown = 7, Element = "Soul"},
		{Name = "Blood Demon Slash", Damage = 250, Cooldown = 12, Element = "Blood"},
		-- ...
	},
	CoThan = {
		{Name = "Golden Body", Damage = 0, Cooldown = 15, Type = "Defense"},
		{Name = "Fist of Heaven", Damage = 300, Cooldown = 8, Element = "Physical"},
		-- ...
	}
}
```

### 2. Load Player's Skills

```lua
function SkillService.LoadPlayerSkills(player)
	local playerData = GetPlayerData(player)
	local cultivationType = playerData.CultivationType  -- TienThien, MaDao, CoThan

	-- Get skills for this path
	local pathSkills = CultivationSkills[cultivationType]

	-- Assign to player's skill slots based on unlocked skills
	return {
		[1] = pathSkills[1],
		[2] = playerData.UnlockedSkills[2],
		[3] = playerData.UnlockedSkills[3],
		[4] = playerData.UnlockedSkills[4]
	}
end
```

### 3. Execute Real Skills

```lua
function SkillService.ExecuteSkill(player, skillSlot)
	local playerSkills = SkillService.LoadPlayerSkills(player)
	local skill = playerSkills[skillSlot]

	if skill.Element == "Lightning" then
		-- Use SkillEffects.LightningStrike()
		local SkillEffects = require(ReplicatedStorage.Modules.Effects.SkillEffects)
		SkillEffects.LightningStrike(player.Character, target, skill.Damage)

	elseif skill.Element == "Ice" then
		-- Use SkillEffects.IceStorm()
		SkillEffects.IceStorm(player.Character, position, radius, duration)
	end
end
```

## 📁 Files Created/Modified

### Files Created (3)

1. **[PlayerController.lua](src/StarterPlayer/StarterPlayerScripts/PlayerController.lua)** - 200 lines
   - PC keyboard controls
   - Q/E/R/F skill bindings
   - Shift dash
   - I/P UI toggles

2. **[SkillService.lua](src/ServerScriptService/Services/SkillService.lua)** - 180 lines
   - Server-side skill handler
   - Cooldown tracking
   - Test skill implementation
   - Visual effects

3. **[SKILLS_SYSTEM_GUIDE.md](SKILLS_SYSTEM_GUIDE.md)** - This file
   - Complete usage guide

### Files Modified (3)

1. **[MobileControls.lua](src/StarterPlayer/StarterPlayerScripts/Mobile/MobileControls.lua)**
   - Added ReplicatedStorage import
   - Added skill button click handlers
   - Bound buttons to UseSkill RemoteEvent

2. **[init.server.lua](src/ServerScriptService/Scripts/init.server.lua)**
   - Added SkillService to load order

3. **[default.project.json](default.project.json)**
   - Added SpawnProtectionNotification RemoteEvent

## 🔧 Troubleshooting

### Skills Not Working on PC

**Symptoms**: Pressing Q/E/R/F does nothing

**Solutions**:
1. Check Output for "🎮 PlayerController initialized!"
2. Make sure you're not typing in chat (gameProcessedEvent)
3. Sync with Rojo to get PlayerController.lua
4. Check RemoteEvents.UseSkill exists

### Skills Not Working on Mobile

**Symptoms**: Tapping buttons does nothing

**Solutions**:
1. Check Output for "📱 Mobile skill used..."
2. Verify MobileControls.IsMobile = true
3. Check if buttons visible on screen
4. Sync with Rojo for updated MobileControls.lua

### No Visual Effects

**Symptoms**: Skill activates but no explosion

**Solutions**:
1. Check server Output for "🔥 [Player] used Skill..."
2. Verify SkillService.Initialize() ran
3. Check workspace for effect Parts

### Cooldown Not Working

**Symptoms**: Can spam skills infinitely

**Solutions**:
1. Check SkillService.Cooldowns table
2. Verify tick() time working
3. Check cooldown values in SkillService.Skills

## 📊 Summary

### What You Can Do Now

✅ **Press Q/E/R/F** on PC to use skills
✅ **Tap skill buttons** on mobile
✅ **Press Shift** to dash
✅ **See visual effects** (colored explosions)
✅ **Damage enemies** within 15 studs
✅ **Cooldowns work** properly
✅ **Mobile & PC** both supported

### What's Next (Optional)

- Replace test skills with real cultivation skills
- Bind skills to player's cultivation path
- Add skill unlock/upgrade system
- Create skill tree UI
- Add more visual effects from SkillEffects.lua
- Implement mana/energy system
- Add skill combos

---

## 🎉 Quick Test

```bash
# 1. Sync with Rojo
# In Studio: Rojo → Sync In

# 2. Press F5 to start game

# 3. Open Output window

# 4. You should see:
#    "🎮 PlayerController initialized!"
#    "⚔️ SkillService ready!"

# 5. Press Q
# You should see:
#    "🔥 Using skill: 1"
#    "✅ [YourName] -> Used Skill 1 (Q)"
#    Red explosion effect appears!

# 6. Spam all skills!
Q → E → R → F → Shift (dash)

# 7. Enjoy! 🎮
```

**🔥 Skills Are Now Working! Have Fun!**
