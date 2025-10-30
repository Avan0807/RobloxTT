--[[
	HƯỚNG DẪN IMPORT SKILLS VÀO ROBLOX STUDIO

	CÁC BƯỚC:

	1. MỞ ROBLOX STUDIO
	2. TẠO VFXUtils:
	   - Vào ReplicatedStorage
	   - Insert Object → ModuleScript
	   - Đổi tên thành "VFXUtils"
	   - Copy code từ Skills/Shared/VFXUtils.lua vào

	3. TẠO REMOTEEVENTS:
	   - Mở Command Bar (View → Command Bar)
	   - Copy đoạn code dưới đây và paste vào Command Bar
	   - Nhấn Enter
]]

-- ============================================
-- PASTE ĐOẠN NÀY VÀO COMMAND BAR
-- ============================================

local RS = game:GetService("ReplicatedStorage")

local remotes = {
	-- Tiên Thiên (14 skills)
	"NguHanhTramRemote",
	"LoiAnhDichThanRemote",
	"BangToaTramRemote",
	"HoaLietQuyenRemote",
	"PhongThanKetGioiRemote",
	"ThienQuangPhanKichRemote",
	"ThuyLuuTocBoRemote",
	"VanKiemHoiTongRemote",
	"TuLoiGiangRemote",
	"TamLoiKichRemote",
	"ThaiHuPhongGioiRemote",
	"HuKhongDichChuyenRemote",
	"NguHanhHopNhatRemote",
	"ThienDaoPhanQuyetRemote",

	-- Cổ Thần (11 skills)
	"CoQuyenTamLienRemote",
	"PhaThachCuocRemote",
	"KimCangChuongRemote",
	"TramPhongBoRemote",
	"ThietCotPhongTheRemote",
	"LongHongQuyenRemote",
	"ThienTruDiaTramRemote",
	"CoMaTheHoaRemote",
	"ChanThienQuyenRemote",
	"BatHoangBatDietRemote",
	"CoAnhDoatHonRemote",

	-- Ma Đạo (15 skills)
	"LinhHonTramRemote",
	"OanHonDuoiBongRemote",
	"TeHonRemote",
	"HapHonTramRemote",
	"MaAnhDichThanRemote",
	"HonPhienPhongXuatRemote",
	"TanHonKetGioiRemote",
	"MaTamGiaiPhongRemote",
	"AmHonCanXeRemote",
	"TuAnhHoanThanRemote",
	"HonPhongAnRemote",
	"DietHonLienKichRemote",
	"VoGianMaVucRemote",
	"HuyDietLinhTheRemote",
	"VanMaHoaThanRemote"
}

local created = 0
for _, name in ipairs(remotes) do
	if not RS:FindFirstChild(name) then
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = RS
		created = created + 1
		print("✅ Created: " .. name)
	else
		print("⚠️ Already exists: " .. name)
	end
end

print("\n🎉 DONE! Created " .. created .. " RemoteEvents")
print("📊 Total RemoteEvents: " .. #remotes)

-- ============================================
-- SAU ĐÓ COPY SCRIPTS THỦ CÔNG:
-- ============================================

--[[
	4. CLIENT SCRIPTS (LocalScript):
	   Folder: StarterPlayer → StarterCharacterScripts

	   Tạo cấu trúc:
	   StarterCharacterScripts/
	   ├── SkillsTienThien/     (Folder)
	   ├── SkillsCoThan/        (Folder)
	   └── SkillsMaDao/         (Folder)

	   Copy các file *_Client.lua:
	   - Từ Skills/TienThien/ → vào SkillsTienThien/
	   - Từ Skills/CoThan/ → vào SkillsCoThan/
	   - Từ Skills/MaDao/ → vào SkillsMaDao/

	   ⚠️ QUAN TRỌNG: Phải chuyển thành LocalScript!
	   Cách: Insert Object → LocalScript, rồi paste code

	5. SERVER SCRIPTS (Script):
	   Folder: ServerScriptService → Skills/

	   Tạo cấu trúc:
	   ServerScriptService/
	   └── Skills/
	       ├── TienThien/       (Folder)
	       ├── CoThan/          (Folder)
	       └── MaDao/           (Folder)

	   Copy các file *_Server.lua:
	   - Từ Skills/TienThien/ → vào Skills/TienThien/
	   - Từ Skills/CoThan/ → vào Skills/CoThan/
	   - Từ Skills/MaDao/ → vào Skills/MaDao/

	   ⚠️ QUAN TRỌNG: Phải là Script (không phải LocalScript)!
	   Cách: Insert Object → Script, rồi paste code

	6. TEST:
	   - Nhấn F5 để chạy game
	   - Check Output (View → Output) để xem logs
	   - Test skills bằng cách nhấn phím tương ứng:
	     * E, R, T, F, G, H, J, K, L
	     * Shift, Z, X, C, V, B

	7. TROUBLESHOOTING:
	   - Nếu skill không hoạt động:
	     → Check Output có error không
	     → Check VFXUtils đã ở ReplicatedStorage chưa
	     → Check RemoteEvent có đúng tên không
	     → Check script đúng loại (LocalScript vs Script)
]]

-- ============================================
-- THÔNG TIN SKILLS
-- ============================================

print("\n📋 SKILL LIST:")
print("\n🔵 TIÊN THIÊN (14 skills):")
print("  E - Ngũ Hành Trảm")
print("  Shift - Lôi Ảnh Dịch Thân")
print("  R - Băng Tỏa Trảm")
print("  T - Hỏa Liệt Quyền")
print("  Y - Phong Thần Kết Giới")
print("  F - Thiên Quang Phản Kích")
print("  G - Thủy Lưu Tốc Bộ")
print("  H - Vân Kiếm Hồi Tông")
print("  J - Tử Lôi Giáng")
print("  Q (x3) - Tam Lôi Kích")
print("  Z - Thái Hư Phong Giới")
print("  X - Hư Không Dịch Chuyển")
print("  C (hold) - Ngũ Hành Hợp Nhất")
print("  V - Thiên Đạo Phán Quyết (ULTIMATE)")

print("\n🔴 CỔ THẦN (11 active skills):")
print("  E (x3) - Cổ Quyền Tam Liên")
print("  R - Phá Thạch Cước")
print("  T (hold) - Kim Cang Chưởng")
print("  Shift - Trảm Phong Bộ")
print("  F - Thiết Cốt Phòng Thể")
print("  G - Long Hống Quyền")
print("  H - Thiên Trụ Địa Trảm")
print("  Z - Cổ Ma Thể Hóa")
print("  X (hold) - Chấn Thiên Quyền")
print("  C - Bát Hoang Bất Diệt")
print("  V - Cổ Ảnh Đoạt Hồn")

print("\n🟣 MA ĐẠO (15 skills):")
print("  E - Linh Hồn Trảm")
print("  R - Oan Hồn Đuổi Bóng")
print("  T - Tế Hồn")
print("  F - Hấp Hồn Trảm")
print("  Shift - Ma Ảnh Dịch Thân")
print("  G - Hồn Phiên Phóng Xuất")
print("  H - Tàn Hồn Kết Giới")
print("  J - Ma Tâm Giải Phóng")
print("  K (x2) - Âm Hồn Cắn Xé")
print("  L - Tử Ảnh Hoán Thân")
print("  Z - Hồn Phong Ấn")
print("  X - Diệt Hồn Liên Kích")
print("  C - Vô Gian Ma Vực")
print("  V (hold) - Hủy Diệt Linh Thể (ULTIMATE)")
print("  B - Vạn Ma Hóa Thân (ULTIMATE)")

print("\n✅ Setup complete! Copy scripts manually now.")
