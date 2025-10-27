# 🎮 Admin Testing & Monetization Guide

## 📋 Mục Lục

1. [Admin Commands - Test Game](#admin-commands---test-game)
2. [Quick Test Presets](#quick-test-presets)
3. [Thêm Vũ Khí/Công Pháp Vào Shop](#thêm-vũ-khícông-pháp-vào-shop)
4. [Monetization - Bán Cho Người Chơi](#monetization---bán-cho-người-chơi)
5. [Setup Admin System](#setup-admin-system)

---

## 🛠️ Admin Commands - Test Game

### Cách Dùng Commands

**Trong game, mở chat và gõ:**

```
/commandName [arguments]
```

### 📊 Tu Luyện & Progression

```lua
/setRealm MaTon 5          -- Set cảnh giới Ma Tôn cấp 5
/addTuVi 100000            -- Thêm 100k Tu Vi
/setPath MaDao             -- Đổi sang Ma Đạo (TienThien/CoThan/MaDao)
```

**Test nhanh từng giai đoạn:**
```lua
-- Early game
/setRealm LuyenKhi 3
/addTuVi 10000

-- Mid game
/setRealm MaTon 5
/addTuVi 100000

-- End game
/setRealm MaHoang 9
/addTuVi 1000000
```

### ⚔️ Combat Testing

```lua
/heal                      -- Hồi full HP
/god                       -- Bật/tắt god mode (bất tử)
/speed 100                 -- Tăng tốc độ di chuyển
/resetCooldowns            -- Reset tất cả cooldowns
```

### 🎁 Items & Gold

```lua
/giveItem "Kim Đan" 10     -- Give 10 Kim Đan
/giveGold 1000000          -- Give 1 triệu gold
/clearInventory            -- Xóa hết inventory
```

### 🐉 Boss & Enemies

```lua
/spawnBoss "Linh Thú Vương"    -- Spawn boss
/spawnEnemy Boss 50             -- Spawn enemy level 50
/killAll                        -- Giết tất cả quái
```

### ⚡ Skills

```lua
/unlockSkills              -- Unlock tất cả skills
/maxSkills                 -- Max tất cả skill levels
/resetCooldowns            -- Reset cooldowns
```

### 🌩️ Thiên Kiếp

```lua
/startTribulation          -- Bắt đầu Thiên Kiếp
/skipTribulation           -- Skip Thiên Kiếp (auto complete)
```

### 🔧 Ma Đạo Specific

```lua
/addSouls 50000           -- Thêm 50k souls (Ma Đạo)
/addKills 10000           -- Thêm 10k kills
/setTier 5                -- Set Tàn Sát tier 5
```

### 🗺️ Teleport

```lua
/tp 0 50 0                -- Teleport đến vị trí (x, y, z)
```

### 💾 Data Management

```lua
/save                     -- Force save data
/reset                    -- Reset toàn bộ data (cẩn thận!)
/info                     -- Xem thông tin player
/help                     -- Xem tất cả commands
```

---

## ⚡ Quick Test Presets

File [AdminModule.lua](src/ReplicatedStorage/Modules/Admin/AdminModule.lua) có sẵn **5 presets** để test nhanh:

### 1️⃣ Beginner Ma Đạo
```lua
/setPath MaDao
/setRealm LuyenKhi 5
/addTuVi 10000
/addSouls 1000
/giveGold 50000
```

### 2️⃣ Mid-Game Ma Đạo (Ma Tôn)
```lua
/setPath MaDao
/setRealm MaTon 5
/addTuVi 100000
/addSouls 10000
/addKills 5000
/giveGold 500000
```

### 3️⃣ End-Game Ma Đạo (Ma Hoàng)
```lua
/setPath MaDao
/setRealm MaHoang 7
/addTuVi 1000000
/addSouls 100000
/addKills 100000
/giveGold 10000000
/unlockSkills
/maxSkills
```

### 4️⃣ MAX POWER (God Mode)
```lua
/setPath MaDao
/setRealm DoKiep 9
/addTuVi 10000000
/addSouls 500000
/addKills 200000
/giveGold 99999999
/unlockSkills
/maxSkills
/god
/speed 50
```

### 5️⃣ Test Thiên Kiếp
```lua
/setPath MaDao
/setRealm LuyenKhi 9
/addTuVi 50000
/heal
/god
```

**💡 Tip:** Tự tạo thêm preset bằng cách thêm vào `AdminModule.Presets`

---

## 🗡️ Thêm Vũ Khí/Công Pháp Vào Shop

### Thêm Vũ Khí Mới

Mở [ShopModule.lua](src/ReplicatedStorage/Modules/Shop/ShopModule.lua) và thêm vào `EquipmentShop`:

```lua
{
    ItemName = "Ma Hoàng Kiếm",           -- Tên vũ khí
    Category = ShopModule.Category.EQUIPMENT,
    Price = 50000,                         -- Giá mua (Gold)
    SellPrice = 25000,                     -- Giá bán lại
    Stock = 5,                             -- Số lượng (-1 = unlimited)
    LevelRequirement = 20,                 -- Yêu cầu level
    Description = "Kiếm Ma Hoàng cực mạnh - +500 Damage",
    Icon = "rbxassetid://123456789",      -- Icon ID

    -- Stats (tự thêm nếu cần)
    Stats = {
        Damage = 500,
        CritRate = 0.2,
        CritDamage = 1.5
    }
}
```

### Thêm Công Pháp (Skills)

```lua
{
    ItemName = "Lôi Pháp Kinh",
    Category = ShopModule.Category.SPECIAL,
    Price = 100000,                        -- Robux: 1000R$ = 100000
    SellPrice = 0,                         -- Không bán lại được
    Stock = 1,                             -- Limited 1 per player
    LevelRequirement = 15,
    Description = "Công pháp sấm sét - Unlock skill Lôi Đình",
    Icon = "rbxassetid://123456789",

    Type = "Skill",                        -- Đánh dấu là skill
    SkillID = "LightningStrike"
}
```

### Thêm Áo Giáp

```lua
{
    ItemName = "Ma Hoàng Giáp",
    Category = ShopModule.Category.EQUIPMENT,
    Price = 80000,
    SellPrice = 40000,
    Stock = 3,
    LevelRequirement = 25,
    Description = "Giáp Ma Hoàng - +1000 HP, +50 Defense",
    Icon = "rbxassetid://123456789",

    Stats = {
        HP = 1000,
        Defense = 50,
        MagicResist = 30
    }
}
```

---

## 💰 Monetization - Bán Cho Người Chơi

### 1️⃣ Bán Bằng In-Game Gold (Miễn Phí)

**Shop thông thường** - Người chơi dùng gold kiếm được trong game:

```lua
-- ShopModule.lua
{
    ItemName = "Phàm Kiếm",
    Price = 500,              -- 500 gold
    SellPrice = 250,
    Stock = -1                -- Unlimited
}
```

### 2️⃣ Bán Bằng Robux (Developer Products)

**Tạo Developer Product trên Roblox Creator Hub:**

1. Vào: https://create.roblox.com/dashboard/creations
2. Chọn game của bạn → **Monetization** → **Passes**
3. Click **Create a Pass** hoặc **Developer Products**

#### **Game Pass (Mua 1 lần, dùng mãi mãi)**

Ví dụ: VIP Pass

```lua
-- Tạo file: src/ReplicatedStorage/Modules/Shop/GamePassModule.lua

local GamePassModule = {}

GamePassModule.GamePasses = {
    VIP = {
        ID = 123456789,           -- Game Pass ID từ Creator Hub
        Name = "VIP Pass",
        Price = 299,              -- 299 Robux
        Benefits = {
            "10% discount tất cả items",
            "+50% Tu Vi gain",
            "Exclusive VIP chat tag",
            "VIP teleport locations"
        }
    },

    DoubleXP = {
        ID = 987654321,
        Name = "Double XP",
        Price = 199,
        Benefits = {
            "+100% Tu Vi gain",
            "+100% Gold gain"
        }
    }
}

function GamePassModule.HasPass(player, passName)
    local passData = GamePassModule.GamePasses[passName]
    if not passData then return false end

    local MarketplaceService = game:GetService("MarketplaceService")
    local success, hasPass = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passData.ID)
    end)

    return success and hasPass
end

return GamePassModule
```

#### **Developer Products (Mua nhiều lần)**

Ví dụ: Gold Packs, Boost Potions

```lua
-- Tạo file: src/ReplicatedStorage/Modules/Shop/DevProductModule.lua

local DevProductModule = {}

DevProductModule.Products = {
    -- Gold Packs
    {
        ProductID = 111111111,        -- Developer Product ID
        Name = "100K Gold Pack",
        Price = 99,                   -- 99 Robux
        Type = "Gold",
        Amount = 100000,
        Icon = "rbxassetid://123"
    },
    {
        ProductID = 222222222,
        Name = "500K Gold Pack",
        Price = 399,
        Type = "Gold",
        Amount = 500000,
        Icon = "rbxassetid://456"
    },
    {
        ProductID = 333333333,
        Name = "1M Gold Pack (Best Value!)",
        Price = 699,
        Type = "Gold",
        Amount = 1000000,
        Bonus = 200000,               -- +200k bonus!
        Icon = "rbxassetid://789"
    },

    -- Tu Vi Boosts
    {
        ProductID = 444444444,
        Name = "Tu Vi Boost (1 hour)",
        Price = 149,
        Type = "Boost",
        Duration = 3600,              -- 1 hour
        Multiplier = 2,               -- x2 Tu Vi
        Icon = "rbxassetid://101"
    },

    -- Skill Books
    {
        ProductID = 555555555,
        Name = "Ma Hoàng Tuyệt Học",
        Price = 999,
        Type = "Skill",
        SkillID = "MaHoangUltimate",
        Icon = "rbxassetid://202"
    },

    -- Exclusive Weapons
    {
        ProductID = 666666666,
        Name = "Thiên Địa Kiếm",
        Price = 1499,
        Type = "Weapon",
        ItemName = "Thiên Địa Kiếm",
        Stats = {
            Damage = 1000,
            CritRate = 0.3,
            Special = "Lightning Strike on hit"
        },
        Icon = "rbxassetid://303"
    }
}

function DevProductModule.GetProduct(productID)
    for _, product in ipairs(DevProductModule.Products) do
        if product.ProductID == productID then
            return product
        end
    end
    return nil
end

return DevProductModule
```

### 3️⃣ Xử Lý Mua Hàng (Server-Side)

```lua
-- src/ServerScriptService/Services/MonetizationService.lua

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DevProductModule = require(ReplicatedStorage.Modules.Shop.DevProductModule)
local InventoryModule = require(ReplicatedStorage.Modules.Inventory.InventoryModule)

-- ===== PROCESS PURCHASE =====
MarketplaceService.ProcessReceipt = function(receiptInfo)
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local product = DevProductModule.GetProduct(receiptInfo.ProductId)
    if not product then
        warn("Unknown product:", receiptInfo.ProductId)
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    -- Xử lý theo type
    if product.Type == "Gold" then
        -- Give gold
        local totalGold = product.Amount + (product.Bonus or 0)
        -- TODO: Add gold to player data
        print(player.Name, "purchased", totalGold, "gold")

    elseif product.Type == "Boost" then
        -- Apply boost
        -- TODO: Apply boost effect
        print(player.Name, "activated", product.Name)

    elseif product.Type == "Skill" then
        -- Unlock skill
        -- TODO: Unlock skill
        print(player.Name, "unlocked skill:", product.SkillID)

    elseif product.Type == "Weapon" then
        -- Give weapon
        InventoryModule.AddItem(player, product.ItemName, 1)
        print(player.Name, "received weapon:", product.ItemName)
    end

    return Enum.ProductPurchaseDecision.PurchaseGranted
end
```

---

## 🎯 Setup Admin System

### Bước 1: Thêm UserID Của Bạn

Mở [AdminModule.lua:10](src/ReplicatedStorage/Modules/Admin/AdminModule.lua#L10):

```lua
AdminModule.Admins = {
    123456789,  -- Thay bằng UserID của bạn
}
```

**Tìm UserID:**
1. Vào profile Roblox của bạn
2. URL sẽ có dạng: `roblox.com/users/123456789/profile`
3. Copy số `123456789`

### Bước 2: Test Trong Studio

Trong Studio, admin commands **tự động hoạt động** (không cần add UserID).

Chỉ cần:
1. Play game trong Studio
2. Mở chat (/)
3. Gõ `/help` để xem tất cả commands

### Bước 3: Tạo Admin UI (Optional)

Thay vì gõ chat, tạo UI admin panel:

```lua
-- AdminUI.lua (tự tạo)
local AdminUI = {}

function AdminUI.ShowPanel()
    -- Hiển thị UI với buttons:
    -- [Give Gold] [Set Level] [God Mode] [Spawn Boss]
    -- Click button → Fire RemoteEvent → Server xử lý
end

return AdminUI
```

---

## 📊 Test Workflow Recommended

### Test Flow 1: Tu Luyện System

```
1. /setPath MaDao
2. /setRealm LuyenKhi 1
3. /addTuVi 5000
4. Test tu luyện → Check level up
5. /addTuVi 100000 → Test next realm
6. Check Thiên Kiếp trigger
```

### Test Flow 2: Combat System

```
1. /setRealm MaTon 5
2. /unlockSkills
3. /spawnEnemy Boss 10
4. Test combat mechanics
5. /heal (nếu cần)
6. /resetCooldowns → Test skills
7. /killAll → Cleanup
```

### Test Flow 3: Shop System

```
1. /giveGold 100000
2. Mở Shop UI (nhấn B)
3. Test mua items
4. Check inventory
5. Test bán lại items
6. Check gold update
```

### Test Flow 4: Boss Battle

```
1. /god → Bật god mode
2. /spawnBoss "Linh Thú Vương"
3. Test boss mechanics
4. /speed 100 → Test kiting
5. /resetCooldowns → Spam skills
6. Tắt god mode → Test thật
```

---

## 💡 Tips & Best Practices

### Testing

- ✅ **Luôn bật `/god` khi test mechanics** (không bị chết)
- ✅ **Dùng `/save` trước khi test nguy hiểm** (backup data)
- ✅ **Test ở nhiều realm khác nhau** (balancing)
- ✅ **Dùng `/info` để kiểm tra stats** (debug)

### Monetization

- 💰 **Game Pass cho permanent benefits** (VIP, Double XP)
- 💰 **Developer Products cho consumables** (Gold, Boosts)
- 💰 **Special items chỉ bán bằng Robux** (tạo scarcity)
- 💰 **Bundle deals** (mua nhiều = discount)

### Balancing

- ⚖️ **Không bán weapons quá OP** (pay-to-win = bad)
- ⚖️ **Cosmetics > Power** (bán skins, effects)
- ⚖️ **Boosts > Direct power** (x2 XP ok, +9999 damage không ok)

---

## 🐛 Troubleshooting

### Commands không hoạt động?

1. Check UserID đã thêm vào `AdminModule.Admins`
2. Check AdminService đang chạy (ServerScriptService)
3. Check Output window có lỗi không

### Mua hàng không nhận được item?

1. Check `ProcessReceipt` function trong MonetizationService
2. Check Product ID đúng chưa
3. Check DataStore có save không

### Shop không hiển thị items?

1. Check ShopModule đã load chưa
2. Check ShopUI đã require ShopModule
3. Check RemoteEvents đã sync

---

## 📚 File References

- **Admin Commands:** [AdminModule.lua](src/ReplicatedStorage/Modules/Admin/AdminModule.lua)
- **Shop Items:** [ShopModule.lua](src/ReplicatedStorage/Modules/Shop/ShopModule.lua)
- **Shop UI:** [ShopUI.lua](src/StarterPlayer/StarterPlayerScripts/UI/ShopUI.lua)
- **Game Design:** [GAME_DESIGN.md](GAME_DESIGN.md)

---

Chúc bạn test game hiệu quả! 🚀
