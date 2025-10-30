# 🚀 Quick Setup Guide - Skills System

## ⚡ Setup trong 5 phút

### Bước 1: Copy VFXUtils (2 phút)

1. Mở file `Skills/Shared/VFXUtils.lua`
2. Copy toàn bộ code (Ctrl+A, Ctrl+C)
3. Mở Roblox Studio
4. Vào **ReplicatedStorage**
5. Click **+** → chọn **ModuleScript**
6. Đổi tên thành `VFXUtils`
7. Xóa code mặc định, paste code đã copy (Ctrl+V)
8. Save (Ctrl+S)

### Bước 2: Tạo RemoteEvents (1 phút)

#### Option A: Chạy script tự động (Khuyến nghị)

1. Vào **View** → **Command Bar** (nếu chưa hiện)
2. Copy script này và paste vào Command Bar:

```lua
local RS = game:GetService("ReplicatedStorage")
local skills = {"NguHanhTramRemote","LoiAnhDichThanRemote","BangToaTramRemote","HoaLietQuyenRemote","PhongThanKetGioiRemote","ThienQuangPhanKichRemote","ThuyLuuTocBoRemote","VanKiemHoiTongRemote","TuLoiGiangRemote","TamLoiKichRemote","ThaiHuPhongGioiRemote","HuKhongDichChuyenRemote","NguHanhHopNhatRemote","ThienDaoPhanQuyetRemote","CoQuyenTamLienRemote","LinhHonTramRemote","VanMaHoaThanRemote"}
for _, name in ipairs(skills) do
	if not RS:FindFirstChild(name) then
		local r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = RS
		print("✅ " .. name)
	end
end
print("🎉 Done!")
```

3. Nhấn **Enter**
4. Check Output để xem kết quả

#### Option B: Tạo thủ công

Trong **ReplicatedStorage**, tạo các **RemoteEvent** với tên:
- `NguHanhTramRemote`
- `LoiAnhDichThanRemote`
- `BangToaTramRemote`
- ... (xem danh sách đầy đủ trong README.md)

### Bước 3: Setup Client Scripts (1 phút)

1. Vào **StarterPlayer** → **StarterCharacterScripts**
2. Tạo Folder mới tên `Skills` (chuột phải → Insert Object → Folder)
3. Copy tất cả file có tên `*_Client.lua` vào folder này
4. **QUAN TRỌNG**: Chuyển đổi sang **LocalScript**:
   - Chuột phải vào file → Properties
   - Đổi ClassName thành `LocalScript`

**Shortcut**: Chọn tất cả Client files → chuột phải → Convert to LocalScript

### Bước 4: Setup Server Scripts (1 phút)

1. Vào **ServerScriptService**
2. Tạo Folder mới tên `Skills`
3. Copy tất cả file có tên `*_Server.lua` vào folder này
4. Đảm bảo chúng là **Script** (không phải LocalScript)

### Bước 5: Test (30 giây)

1. Nhấn **F5** để chạy game trong Studio
2. Nhấn các phím:
   - **E** = Ngũ Hành Trảm (5 tia nguyên tố)
   - **Shift** = Lôi Ảnh Dịch Thân (dash)
   - **R** = Băng Tỏa Trảm (freeze)
   - **V** = Thiên Đạo Phán Quyết (ULTIMATE)

3. Check **Output** (View → Output) để xem logs

## ✅ Checklist

- [ ] VFXUtils trong ReplicatedStorage
- [ ] Tất cả RemoteEvents đã tạo
- [ ] Client scripts trong StarterCharacterScripts (LocalScript)
- [ ] Server scripts trong ServerScriptService (Script)
- [ ] Test skills trong Studio (F5)

## 🐛 Troubleshooting

### Lỗi: "VFXUtils is not a valid member of ReplicatedStorage"

**Fix**: VFXUtils phải là **ModuleScript** và ở đúng **ReplicatedStorage**

### Lỗi: "Remote is not a valid member of ReplicatedStorage"

**Fix**:
1. Check xem RemoteEvent đã tạo chưa
2. Kiểm tra tên RemoteEvent phải khớp với code (case-sensitive)
3. Chạy lại script tạo RemoteEvents

### Lỗi: Script không chạy

**Fix**:
- Client scripts phải là **LocalScript** trong **StarterCharacterScripts**
- Server scripts phải là **Script** trong **ServerScriptService**

### Skills không kích hoạt khi nhấn phím

**Fix**:
1. Check Output để xem skill đã load chưa (phải có "✅ [Skill Name] loaded!")
2. Đảm bảo không đang chat/type (thoát textbox trước khi nhấn skill)
3. Check cooldown (có thể skill đang cooldown)

## 🎮 Testing Tips

### Test từng skill:

```lua
-- Paste vào Command Bar để reset cooldowns
for _, script in ipairs(game.Players.LocalPlayer.Character:GetDescendants()) do
	if script:IsA("LocalScript") and script.Name:match("Client") then
		-- Reset cooldown logic
	end
end
```

### Test damage:

```lua
-- Thêm vào server script để log damage
print("Damage dealt: " .. damage .. " to " .. target.Name)
```

### Test VFX:

Enable **Performance Stats** (Shift+F5) để xem FPS khi spawn nhiều VFX

## 🎨 Customization Quick Tips

### Thay đổi màu skill nhanh:

Tìm dòng này trong Server script:

```lua
Color = VFXUtils.Colors.Fire  -- Thay Fire thành Ice, Lightning, etc.
```

### Thay đổi key binding nhanh:

Tìm dòng này trong Client script:

```lua
if input.KeyCode == Enum.KeyCode.E  -- Thay E thành key khác
```

### Tăng/giảm damage nhanh:

```lua
local baseDamage = 30  -- Thay số này
```

## 📞 Need More Help?

Xem **README.md** để có hướng dẫn chi tiết hơn về:
- Template tạo skill mới
- VFX Editor integration
- Advanced customization
- Full keybinds list

---

**Estimated setup time**: 5-10 phút
**Difficulty**: ⭐⭐☆☆☆ (Easy-Medium)
