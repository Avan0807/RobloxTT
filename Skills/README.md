# 🎮 Roblox Skills System - VFX Editor Integration

Hệ thống skill hoàn chỉnh cho game Roblox với 3 hệ phái: **Tiên Thiên**, **Cổ Thần**, và **Ma Đạo**.

## 📁 Cấu trúc thư mục

```
Skills/
├── Shared/
│   └── VFXUtils.lua          # Utilities chung cho tất cả skills
├── TienThien/                # Hệ Tiên Thiên (15 skills) ⚡
│   ├── 01_NguHanhTram_Client.lua
│   ├── 01_NguHanhTram_Server.lua
│   ├── 02_LoiAnhDichThan_Client.lua
│   ├── ... (30 files total)
│   └── 15_ThienDaoPhanQuyet_Server.lua (ULTIMATE)
├── CoThan/                   # Hệ Cổ Thần (samples) 👊
│   ├── 01_CoQuyenTamLien_Client.lua
│   ├── 01_CoQuyenTamLien_Server.lua
│   └── 15_ThanCotPhucSinh_Server.lua (ULTIMATE)
└── MaDao/                    # Hệ Ma Đạo (samples) 👻
    ├── 01_LinhHonTram_Server.lua
    └── 15_VanMaHoaThan_Server.lua (ULTIMATE)
```

## 🚀 Hướng dẫn Setup

### Bước 1: Copy VFXUtils vào ReplicatedStorage

1. Mở Roblox Studio
2. Vào **ReplicatedStorage**
3. Tạo **ModuleScript** mới, đổi tên thành `VFXUtils`
4. Copy toàn bộ code từ `Skills/Shared/VFXUtils.lua` vào ModuleScript

### Bước 2: Setup RemoteEvents

Tạo RemoteEvent cho mỗi skill trong **ReplicatedStorage**. Bạn có thể chạy script này trong **Command Bar**:

```lua
-- Paste code này vào Command Bar trong Studio
local RS = game:GetService("ReplicatedStorage")

-- Tiên Thiên RemoteEvents
local ttSkills = {
	"NguHanhTramRemote",
	"LoiAnhDichThanRemote",
	"BangToaTramRemote",
	"HoaLietQuyenRemote",
	"PhongThanKetGioiRemote",
	"ThienQuangPhanKichRemote",
	"ThuyLuuTocBoRemote",
	"VanKiemHoiTongRemote",
	"TuLoiGiangRemote",
	-- Công pháp thượng phẩm
	"TamLoiKichRemote",
	"ThaiHuPhongGioiRemote",
	"HuKhongDichChuyenRemote",
	"NguHanhHopNhatRemote",
	"ThienDaoPhanQuyetRemote"
}

-- Cổ Thần RemoteEvents
local ctSkills = {
	"CoQuyenTamLienRemote"
	-- Add more...
}

-- Ma Đạo RemoteEvents
local mdSkills = {
	"LinhHonTramRemote",
	"VanMaHoaThanRemote"
	-- Add more...
}

-- Tạo tất cả RemoteEvents
for _, name in ipairs(ttSkills) do
	if not RS:FindFirstChild(name) then
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = RS
		print("✅ Created: " .. name)
	end
end

print("🎉 All RemoteEvents created!")
```

### Bước 3: Setup Client Scripts

1. Vào **StarterPlayer > StarterCharacterScripts**
2. Tạo thư mục `Skills`
3. Copy tất cả **_Client.lua** files vào đây
4. **Lưu ý**: Client scripts phải ở dạng **LocalScript**

### Bước 4: Setup Server Scripts

1. Vào **ServerScriptService**
2. Tạo thư mục `Skills`
3. Copy tất cả **_Server.lua** files vào đây
4. **Lưu ý**: Server scripts phải ở dạng **Script** (không phải LocalScript)

## 🎯 Controls (Keybinds)

### Hệ Tiên Thiên ⚡

| Key | Skill | Type |
|-----|-------|------|
| E | Ngũ Hành Trảm | Kỹ năng thường |
| Shift | Lôi Ảnh Dịch Thân | Dash |
| R | Băng Tỏa Trảm | CC |
| T | Hỏa Liệt Quyền | Cận chiến |
| Y | Phong Thần Kết Giới | Zone control |
| F | Thiên Quang Phản Kích | Parry |
| G | Thủy Lưu Tốc Bộ | Buff |
| H | Vân Kiếm Hồi Tông | Boomerang |
| J | Tử Lôi Giáng | Targeted |
| Q (x3) | Tam Lôi Kích | Combo |
| Z | Thái Hư Phong Giới | Domain |
| X | Hư Không Dịch Chuyển | Blink |
| C (hold) | Ngũ Hành Hợp Nhất | Charge |
| **V** | **Thiên Đạo Phán Quyết** | **ULTIMATE** |

### Hệ Cổ Thần 👊

| Key | Skill | Type |
|-----|-------|------|
| E (x3) | Cổ Quyền Tam Liên | Combo |
| ... | (Chưa implement) | ... |
| **V** | **Thần Cốt Phục Sinh** | **ULTIMATE (Passive)** |

### Hệ Ma Đạo 👻

| Key | Skill | Type |
|-----|-------|------|
| E | Linh Hồn Trảm | Soul damage |
| ... | (Chưa implement) | ... |
| **V** | **Vạn Ma Hóa Thân** | **ULTIMATE** |

## 📝 Template để tạo skill mới

### Client Template

```lua
-- ============================================
-- TÊN SKILL - CLIENT
-- Mô tả skill
-- Key: [KEY]
-- ============================================

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local skillRemote = ReplicatedStorage:WaitForChild("[SkillName]Remote")

local canCast = true
local cooldownTime = 5

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.[KEY] and canCast then
		canCast = false

		-- Get direction/target
		local camera = workspace.CurrentCamera
		local direction = camera.CFrame.LookVector

		-- Send to server
		skillRemote:FireServer(direction)

		print("🎯 [SKILL NAME]!")

		task.wait(cooldownTime)
		canCast = true
	end
end)

print("✅ [Skill Name] loaded! Press [KEY]")
```

### Server Template

```lua
-- ============================================
-- TÊN SKILL - SERVER
-- Mô tả skill chi tiết
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local VFXUtils = require(ReplicatedStorage:WaitForChild("VFXUtils"))

local skillRemote = ReplicatedStorage:FindFirstChild("[SkillName]Remote")
if not skillRemote then
	skillRemote = Instance.new("RemoteEvent")
	skillRemote.Name = "[SkillName]Remote"
	skillRemote.Parent = ReplicatedStorage
end

local function performSkill(player, direction)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	-- TODO: Implement skill logic
	-- 1. Create projectile/effect
	-- 2. Damage calculation
	-- 3. VFX

	print("✅ " .. player.Name .. " used [Skill Name]!")
end

skillRemote.OnServerEvent:Connect(function(player, direction)
	if typeof(direction) ~= "Vector3" then
		warn("⚠️ Invalid data")
		return
	end

	performSkill(player, direction)
end)

print("✅ [Skill Name] Server loaded!")
```

## 🎨 VFX Editor Integration

Các skills đã được thiết kế để tương thích với **vfx-editor** plugin:

### Cách chỉnh sửa VFX trong Studio:

1. Cài đặt **vfx-editor** plugin từ Roblox Marketplace
2. Run game trong Studio (F5)
3. Select một ParticleEmitter trong Workspace
4. Mở plugin để chỉnh sửa:
   - NumberSequence (size, transparency)
   - ColorSequence
   - Bezier curves
   - Texture flipbooks

### VFXUtils Features:

- `VFXUtils.Colors` - Preset màu sắc cho từng nguyên tố
- `VFXUtils.Textures` - Texture IDs từ Roblox library
- `VFXUtils.CreateParticle()` - Tạo particle emitter nhanh
- `VFXUtils.CreateExplosion()` - Tạo hiệu ứng nổ
- `VFXUtils.CreateTrail()` - Tạo trail effect
- `VFXUtils.DamageInRadius()` - AOE damage
- `VFXUtils.ApplyKnockback()` - Knockback effect

## 🔧 Customization

### Thay đổi damage:

Tìm `baseDamage` trong file Server và điều chỉnh:

```lua
local baseDamage = 30  -- Thay đổi giá trị này
```

### Thay đổi cooldown:

Trong file Client:

```lua
local cooldownTime = 5  -- Giây
```

### Thay đổi màu sắc VFX:

Sử dụng `VFXUtils.Colors` hoặc tạo custom:

```lua
local customColors = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(200, 0, 0),
	Color3.fromRGB(150, 0, 0)
}
```

## 📊 Status

- ✅ **Hệ Tiên Thiên**: 15/15 skills hoàn thành
- 🟡 **Hệ Cổ Thần**: 3/15 skills (samples)
- 🟡 **Hệ Ma Đạo**: 2/15 skills (samples)

## 🤝 Hỗ trợ

Nếu gặp lỗi:

1. Kiểm tra Output console trong Studio (View > Output)
2. Đảm bảo VFXUtils đã được đặt trong ReplicatedStorage
3. Kiểm tra RemoteEvents đã được tạo đúng tên
4. Đảm bảo scripts đúng loại (LocalScript vs Script)

## 📜 License

Free to use and modify for your Roblox game!

---

Made with ❤️ using vfx-editor library
