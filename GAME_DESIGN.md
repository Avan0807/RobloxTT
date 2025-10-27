# 🎮 GAME TU TIÊN - KỊCH BẢN THIẾT KẾ HOÀN CHỈNH

> **Tổng hợp từ:** SYSTEM_DESIGN_FINAL.md, MAP_QUAI_DESIGN.md, tuluyen.txt, luyendan.txt, MapTanThu.txt
>
> **Author:** Game Design Team
>
> **Last Updated:** 2025-10-27

---

## 📚 MỤC LỤC

1. [Khái Niệm Cốt Lõi: Linh Hồn](#khái-niệm-cốt-lõi-linh-hồn)
2. [3 Hệ Tu Luyện & Khắc Chế](#3-hệ-tu-luyện--khắc-chế)
3. [Hệ Thống Tu Luyện Chi Tiết](#hệ-thống-tu-luyện-chi-tiết)
4. [Hệ Thống Maps & Quái Vật](#hệ-thống-maps--quái-vật)
5. [Hệ Thống Luyện Đan](#hệ-thống-luyện-đan)
6. [Danh Sách Đan Dược](#danh-sách-đan-dược)
7. [Hệ Thống Combat](#hệ-thống-combat)
8. [Cơ Chế Gameplay](#cơ-chế-gameplay)

---

## 🌟 KHÁI NIỆM CỐT LÕI: LINH HỒN

### **Mọi sinh vật đều có Linh Hồn!**

**Linh Hồn là gì?**
- Mỗi Player, NPC, Boss đều có **Sức Mạnh Linh Hồn** (Soul Power)
- Linh Hồn càng mạnh → Tu luyện càng nhanh, Luyện đan càng dễ
- Khi giết địch → Hấp thụ một phần Linh Hồn của họ

### **3 Thuộc Tính Linh Hồn**

1. **Soul Power (Linh Lực)**
   - Sức mạnh linh hồn tổng thể
   - Tăng khi tu luyện, giết quái, luyện đan
   - Ảnh hưởng: Damage, tốc độ tu luyện, tỷ lệ luyện đan thành công

2. **Soul Quality (Chất Linh Hồn)**
   - Phẩm chất linh hồn: Thường → Huyền → Thiên → Tiên
   - Càng cao càng hiếm
   - Ảnh hưởng: Critical Rate, Critical Damage, hiệu quả skill

3. **Soul Stability (Độ Ổn Định Linh Hồn)**
   - Độ vững chắc của linh hồn (0-100%)
   - Bị giảm khi chết, bị tấn công linh hồn, dùng skill mạnh
   - < 50%: Tốc độ tu luyện giảm, dễ thất bại khi luyện đan
   - Hồi phục: Thiền định, dùng đan dược, nghỉ ngơi

---

## ⚔️ 3 HỆ TU LUYỆN & KHẮC CHẾ

### **Tam Giác Khắc Chế (Rock-Paper-Scissors)**

```
     TIÊN THIÊN (Pháp)
           ↓ Khắc 30%
       CỔ THẦN (Thể)
           ↓ Khắc 30%
        MA ĐẠO (Hồn)
           ↓ Khắc 30%
     TIÊN THIÊN (Pháp)
```

### **Tóm Tắt 3 Hệ**

| Đặc điểm | Tiên Thiên | Cổ Thần | Ma Đạo |
|----------|-----------|---------|--------|
| **Damage Type** | Magic Damage | Physical Damage | Soul Damage |
| **HP** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Defense** | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| **Speed** | ⭐⭐⭐⭐⭐ | ⭐ | ⭐⭐⭐ |
| **Lifesteal** | 0% | 5% | 50-150% |
| **Range** | Xa | Cận | Trung-Cận |
| **Playstyle** | Kite, AOE | Tank, Melee | Lifesteal, Burst |
| **Khắc** | Cổ Thần | Ma Đạo | Tiên Thiên |
| **Bị khắc** | Ma Đạo | Tiên Thiên | Cổ Thần |

---

## 📖 HỆ THỐNG TU LUYỆN CHI TIẾT

### **Cấu Trúc 3 Cảnh Giới**

Mỗi hệ có **3 Đại Cảnh Giới**, mỗi cảnh giới có **9 cấp độ**:

| Cảnh Giới | Tiên Thiên | Cổ Thần | Ma Đạo |
|-----------|-----------|---------|--------|
| **Cảnh 1** | Ngưng Khí (Tầng 1-9) | Cổ Thần (1-9 Sao ⭐) | Ma Đạo (1-9 Tinh ✦) |
| **Cảnh 2** | Trúc Cơ (Tầng 1-9) | Cổ Ma (1-9 Sao ⭐) | Ma Tôn (1-9 Tinh ✦) |
| **Cảnh 3** | Nguyên Anh (Tầng 1-9) | Cổ Tôn (1-9 Sao ⭐) | Ma Hoàng (1-9 Tinh ✦) |

### **Stats Scaling - So Sánh Ở Đỉnh Cao**

**Cảnh 3 Cấp 9 (Đỉnh cao nhất):**

| Hệ | HP | Damage |
|----|-------|---------|
| **Tiên Thiên** (Nguyên Anh 9) | 300,000 | 30,000 Magic |
| **Cổ Thần** (Cổ Tôn 9 Sao) | 1,120,000 | 112,000 Physical |
| **Ma Đạo** (Ma Hoàng 9 Tinh) | 780,000 | 91,000 Dark + 150% Lifesteal |

> **Chi tiết đầy đủ các stats và yêu cầu nâng cấp xem trong `kichban/tuluyen.txt`**

---

## 🗺️ HỆ THỐNG MAPS & QUÁI VẬT

### **Map 1: RỪNG LINH THÚ** (Lv 1-9)

**Phù hợp:** Ngưng Khí 1-3, Cổ Thần 1-3 Sao, Ma Đạo 1-3 Tinh

**Quái vật:**

1. **Hoang Dã Sói** (Wild Wolf)
   - HP: 300 | Damage: 20-30 | Level: 1-2
   - Drop: Linh Thảo (60%), Thú Cốt (40%), Tụ Khí Đan (5%), Linh Thạch (100%)
   - **Ma Đạo:** Phàm Nhân Linh Hồn (30%)

2. **Yêu Hổ** (Demon Tiger)
   - HP: 500 | Damage: 35-50 | Level: 3-4
   - Drop: Thú Cốt (70%), Hỏa Linh Thạch (5%), Tụ Khí Đan (10%)
   - **Ma Đạo:** Phàm Nhân Linh Hồn (40%)

3. **Độc Xà** (Poison Snake)
   - HP: 250 | Damage: 15-25 + 10 poison/s (3s) | Level: 2-3
   - Drop: Linh Thảo (80%), Độc Nang (60%)
   - **Ma Đạo:** Phàm Nhân Linh Hồn (35%)

4. **【BOSS】Sói Vua** (Wolf King)
   - HP: 2,000 | Damage: 50-80 | Level: 5
   - Spawn: Mỗi 10 phút ở trung tâm rừng
   - Drop (100%):
     - 20-30 Tụ Khí Đan
     - 100-200 Linh Thạch
     - 10-20 Tiên Ngọc
     - **Ma Đạo:** Boss Linh Hồn (50%)
   - Skill: Triệu hồi 5 Hoang Dã Sói khi HP < 50%, gầm làm choáng 2s

---

### **Map 2: ĐỘNG THẠCH QUỶ** (Lv 10-20)

**Phù hợp:** Ngưng Khí 4-7, Cổ Thần 4-6 Sao, Ma Đạo 4-6 Tinh

**Quái vật:**

1. **Thạch Quỷ** (Stone Demon)
   - HP: 1,200 | Damage: 60-90 | Level: 10-12
   - Drop: Kim Cang Xá Lợi (30%), Cổ Thần Huyết (25%), Tiên Ngọc (20%)
   - **Ma Đạo:** Tu Sĩ Linh Hồn (40%)

2. **Binh Lính Xương** (Skeleton Warrior)
   - HP: 800 | Damage: 50-70 | Level: 10-14
   - Drop: Trúc Cơ Đan (15%), Ma Đạo Đan (30%)
   - **Ma Đạo:** Tu Sĩ Linh Hồn (50%)

3. **【BOSS】Ma Vương Động Chủ** (Cave Demon Lord)
   - HP: 12,000 | Damage: 150-250 | Level: 20
   - Spawn: Mỗi 1 giờ ở sâu trong động
   - Drop (100%):
     - 50-80 Trúc Cơ Đan
     - 100-200 Tiên Ngọc
     - 10 Đại Hoàn Đan
     - **Ma Đạo:** 10-20 Cao Thủ Linh Hồn + 3-5 Boss Linh Hồn
   - Phase 1 (100-50% HP): Cận chiến, triệu hồi Thạch Quỷ
   - Phase 2 (50-0% HP): Bay lên, phun lửa AOE

---

### **Map 3: MA VỰC HUYẾT TRÌ** (Lv 30-50)

**Phù hợp:** Trúc Cơ 1-9, Cổ Ma 1-9 Sao, Ma Tôn 1-9 Tinh

**Quái vật:**

1. **Huyết Ma** (Blood Demon)
   - HP: 8,000 | Damage: 200-300 | Level: 30-35
   - Lifesteal 30%
   - Drop: Kim Đan (30%), Ma Tâm Kết Tinh (25%)
   - **Ma Đạo:** Cao Thủ Linh Hồn (30%)

2. **【WORLD BOSS】Ma Hoàng Huyết Địa** (Blood Emperor)
   - HP: 200,000 | Damage: 800-1500 | Level: 50
   - Spawn: Mỗi 3 giờ, cần team 5-10 người
   - Drop (mỗi player tham gia):
     - 200-300 Kim Đan
     - 500-1000 Tiên Ngọc
     - 50 Thiên Linh Đan
     - **Ma Đạo:** 200-400 Cao Thủ Linh Hồn + 50-100 Boss Linh Hồn + 10 Tiên Nhân Linh Hồn (30%)
   - **Rare:** Vạn Hồn Phan Thượng Phẩm (10%)
   - Phase 1-4: Mechanics phức tạp

> **Chi tiết đầy đủ tất cả maps xem trong `kichban/MAP_QUAI_DESIGN.md`**

---

## 🔮 HỆ THỐNG LUYỆN ĐAN

### **3 Cảnh Giới Luyện Đan**

1. **Linh Hỏa** (Tầng 1-9): Luyện đan cơ bản
2. **Linh Dược Sư** (Tầng 1-9): Luyện đan cao cấp
3. **Đan Thánh** (Tầng 1-9): 100% thành công

### **Linh Hồn Ảnh Hưởng Đến Luyện Đan**

#### **1. Soul Power → Tỷ lệ thành công**
```lua
SuccessRate = BaseRate + (SoulPower / 100) * BonusRate
```

**Ví dụ:**
- Linh Hỏa Tầng 1: Base 30%
- Soul Power 500 → +5% → Total 35%
- Soul Power 2000 → +20% → Total 50%

#### **2. Soul Quality → Chất lượng đan**
- Soul Quality Thường: 100% Hạ Phẩm
- Soul Quality Huyền: 10% Trung Phẩm
- Soul Quality Thiên: 30% Thượng Phẩm
- Soul Quality Tiên: 50% Cực Phẩm

#### **3. Soul Stability → Xác suất crit (nhân đôi số lượng)**
- Soul Stability 100%: 20% crit → Ra 2 viên đan
- Soul Stability 80%: 15% crit
- Soul Stability < 50%: 0% crit

### **Quy Trình Luyện Đan**

1. **Chuẩn bị:**
   - Có Lò Đan (Alchemy Furnace)
   - Có nguyên liệu (Linh Thảo, Hỏa Linh Thạch, etc.)
   - Soul Stability > 50% (khuyến nghị)

2. **Luyện Đan:**
   - Bỏ nguyên liệu vào lò
   - Click "Luyện Đan"
   - Mất 10-30 giây (tùy loại đan)
   - Hiển thị progress bar + particle effect

3. **Kết quả:**
   - **Thành công:** Nhận đan + Exp luyện đan
   - **Thất bại:** Mất nguyên liệu + Exp luyện đan (ít hơn)
   - **Critical:** Nhận x2 đan

---

## 💊 DANH SÁCH ĐAN DƯỢC

### **Đan Dược 3 Hệ**

**Tiên Thiên:**
- Tụ Khí Đan (聚气丹) - Ngưng Khí 1-9
- Trúc Cơ Đan (筑基丹) - Trúc Cơ 1-9
- Kim Đan (金丹) - Nguyên Anh 1-9

**Cổ Thần:**
- Thể Tu Đan (体修丹) - Cổ Thần 1-9 Sao
- Cổ Ma Đan (古魔丹) - Cổ Ma 1-9 Sao
- Cổ Tôn Linh Đan (古尊灵丹) - Cổ Tôn 1-9 Sao

**Ma Đạo:**
- Ma Đạo Đan (魔道丹) - Ma Đạo 1-9 Tinh
- Ma Tôn Đan (魔尊丹) - Ma Tôn 1-9 Tinh
- Ma Hoàng Linh Đan (魔皇灵丹) - Ma Hoàng 1-9 Tinh

### **Hồn Phiên (魂幡) - Vũ Khí Ma Đạo**

**Phân Cấp:**
1. **Hồn Phiên Hạ Phẩm**: Max 5,000 linh hồn
2. **Hồn Phiên Trung Phẩm**: Max 50,000 linh hồn
3. **Vạn Hồn Phan Hạ Phẩm**: Max 500,000 linh hồn
4. **Vạn Hồn Phan Thượng Phẩm**: Max 5,000,000 linh hồn
5. **Diệt Thế Ma Phan**: Max 100,000,000 linh hồn

**Skill Hồn Phiên:**
- 100 linh hồn: +50% Soul Damage (10 phút)
- 500 linh hồn: Triệu hồi Boss Oan Hồn (5 phút)
- 1000 linh hồn: Ma Hóa - +200% damage (10 phút)

### **Đan Dược Cao Cấp**

1. **Tiểu Hoàn Đan**: Tăng tốc tu luyện +50%
2. **Đại Hoàn Đan**: Tăng tốc tu luyện +100%
3. **Thiên Linh Đan**: Tăng cơ hội đột phá +20%
4. **Tiên Linh Đan**: Tăng cơ hội đột phá +50%
5. **Thái Cổ Linh Đan**: Top tier, cực hiếm

### **Nguyên Liệu Đặc Biệt**

- **Tiên Ngọc**: Currency cao cấp
- **Vạn Niên Linh Dược**: Dược liệu 10,000 năm
- **Kim Cang Xá Lợi**: Cổ Thần đặc hữu
- **Phàm Nhân Linh Hồn**: Drop từ NPC thường
- **Tu Sĩ Linh Hồn**: Drop từ tu sĩ Ngưng Khí - Trúc Cơ
- **Cao Thủ Linh Hồn**: Drop từ tu sĩ Nguyên Anh
- **Boss Linh Hồn**: Drop từ dungeon boss
- **Tiên Nhân Linh Hồn**: Drop từ Tiên Nhân (cực hiếm)

---

## ⚔️ HỆ THỐNG COMBAT

### **Cơ Chế Combat**

**Quái vật:**
- AI đơn giản: Detect → Chase → Attack → Death
- Có animation tấn công, nhận damage, chết
- Drop item ngay lập tức khi chết

**Player:**
- Click chuột để tấn công
- Có combo system (optional)
- Hiển thị damage numbers
- Hồi HP/MP tự động khi không combat

**Ma Đạo đặc biệt:**
- Mỗi lần giết quái → Tự động hút Linh Hồn vào Hồn Phiên
- Hiển thị VFX hút linh hồn (particle bay vào player)
- Tích lũy Sát Khí (hiển thị số lần giết)

### **Hệ Thống Tàn Sát (Ma Đạo)**

- Mỗi lần giết NPC/Player: +1 Sát Khí
- Sát Khí càng cao → Damage càng mạnh:
  - 100 Sát Khí: +10% Soul Dmg
  - 1,000 Sát Khí: +50% Soul Dmg
  - 10,000 Sát Khí: +150% Soul Dmg
  - 100,000 Sát Khí: +500% Soul Dmg (Ma Đầu Huyền Thoại)
- **Nhược điểm:** Bị săn lùng, không vào được thành phố

---

## 🎮 CƠ CHẾ GAMEPLAY

### **Cách Lên Cảnh Giới**

**Không có Level truyền thống!** Thay vào đó:

1. **Ngồi thiền tu luyện** tại Đài Luyện Công
   - Mỗi phút: +1 Tu Vi Điểm
   - Cần đủ Tu Vi Điểm + Đan Dược → Nâng tầng/sao/tinh

2. **Đánh quái/boss** để lấy Đan Dược

3. **Hoàn thành Quest** để lấy Tiên Ngọc

4. **PvP/Arena** để lấy thêm tài nguyên

### **Tu Vi Điểm Yêu Cầu**

**Nâng cấp trong cùng cảnh:**
- 1→2: 1,000 Tu Vi Điểm
- 2→3: 2,500 Tu Vi Điểm
- 3→4: 5,000 Tu Vi Điểm
- 4→5: 8,000 Tu Vi Điểm
- 5→6: 12,000 Tu Vi Điểm
- 6→7: 18,000 Tu Vi Điểm
- 7→8: 25,000 Tu Vi Điểm
- 8→9: 35,000 Tu Vi Điểm

**Đột phá cảnh giới:**
- Cảnh 1 → Cảnh 2: 100,000 Tu Vi Điểm
- Cảnh 2 → Cảnh 3: 500,000 Tu Vi Điểm

### **Hệ Thống Đột Phá**

Khi đủ điều kiện:
1. Chuẩn bị tài nguyên (đan dược + tiên ngọc)
2. Vào Đột Phá Không Gian
3. Chiến đấu với Thiên Kiếp Boss
4. **Thắng:** Đột phá thành công, chỉ số nhân đôi
5. **Thua:** Mất 50% tài nguyên, phải thử lại

---

## 📊 BẢNG CÂN BẰNG 3 HỆ

### **PvP Winrate**

| Matchup | Win Rate | Lý Do |
|---------|----------|-------|
| Tiên Thiên vs Cổ Thần | 70-30 | Kite, slow, stun |
| Cổ Thần vs Ma Đạo | 65-35 | HP cao, Defense cao |
| Ma Đạo vs Tiên Thiên | 70-30 | Lifesteal, Soul Damage |

### **PvE Performance**

| Hệ | Solo PvE | Team PvE | Boss | Farming |
|----|----------|----------|------|---------|
| **Tiên Thiên** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Cổ Thần** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Ma Đạo** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 🎯 VÍ DỤ PROGRESSION

### **Player Tiên Thiên - 100 giờ chơi**

**Ngày 1-7:** Ngưng Khí 1 → 5
- HP: 500 → 1000
- Magic Dmg: 50 → 100

**Ngày 8-30:** Ngưng Khí 5 → 9
- HP: 1000 → 2000
- Magic Dmg: 100 → 200

**Ngày 31:** **ĐỘT PHÁ TRÚC CƠ**
- HP: 2000 → 4000
- Magic Dmg: 200 → 400
- Unlock: Bay được!

**Ngày 32-90:** Trúc Cơ 1 → 9
- HP: 4000 → 21,500
- Magic Dmg: 400 → 2,150

**Ngày 91-365:** Đột phá Nguyên Anh
- HP: 43,000 → 300,000
- Magic Dmg: 4,300 → 30,000
- Trở thành cao thủ server

---

## 💡 TÀI LIỆU THAM KHẢO

Xem chi tiết trong thư mục `kichban/`:

- **SYSTEM_DESIGN_FINAL.md** - Thiết kế hệ thống Linh Hồn và 3 hệ tu luyện
- **tuluyen.txt** - Chi tiết stats và yêu cầu đầy đủ cho 3 hệ
- **MAP_QUAI_DESIGN.md** - Thiết kế tất cả maps và quái vật
- **luyendan.txt** - Hệ thống luyện đan chi tiết
- **MapTanThu.txt** - Thiết kế map tân thủ

---

**🚀 Bắt đầu coding để biến ý tưởng thành hiện thực!**
