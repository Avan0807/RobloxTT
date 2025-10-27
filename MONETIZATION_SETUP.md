# 💰 Monetization Setup - Quick Guide

## 🎯 Hướng Dẫn Bán Items Cho Người Chơi

### Bước 1️⃣: Tạo Game Pass trên Roblox

1. Vào: https://create.roblox.com/dashboard/creations
2. Chọn game của bạn
3. Click **Monetization** → **Passes**
4. Click **Create a Pass**
5. Điền:
   - **Name:** VIP Pass
   - **Description:** Get VIP benefits!
   - **Price:** 299 Robux
   - Upload icon
6. Click **Save**
7. **Copy Game Pass ID** (trong URL: `/catalog/123456789/VIP-Pass`)

### Bước 2️⃣: Cập Nhật GamePassModule.lua

Mở [GamePassModule.lua](src/ReplicatedStorage/Modules/Monetization/GamePassModule.lua):

```lua
GamePassModule.GamePasses = {
    VIP = {
        ID = 123456789,  -- ✅ Paste Game Pass ID vào đây
        Name = "VIP Pass",
        Price = 299,
        -- ...
    }
}
```

### Bước 3️⃣: Tạo Developer Products

1. Vào: https://create.roblox.com/dashboard/creations
2. Chọn game → **Monetization** → **Developer Products**
3. Click **Create a Developer Product**
4. Điền:
   - **Name:** 100K Gold Pack
   - **Description:** Get 100,000 gold!
   - **Price:** 99 Robux
5. Click **Save**
6. **Copy Product ID**

### Bước 4️⃣: Cập Nhật DevProductModule.lua

Mở [DevProductModule.lua](src/ReplicatedStorage/Modules/Monetization/DevProductModule.lua):

```lua
{
    ProductID = 987654321,  -- ✅ Paste Product ID vào đây
    Name = "100K Gold Pack",
    Price = 99,
    Type = "Gold",
    Amount = 100000,
    Bonus = 10000,
    -- ...
}
```

### Bước 5️⃣: Test Trong Game

```lua
-- Trong Studio, test bằng command:
/giveGold 0  -- Reset gold về 0

-- Rồi click button mua trong game
-- (Purchase prompt sẽ hiện nhưng không charge tiền trong Studio)
```

---

## 🛒 Các Loại Monetization

### 1️⃣ Game Pass (Mua 1 lần, dùng mãi)

**Phù hợp với:**
- VIP benefits
- Permanent boosts (Double XP, Double Gold)
- Quality of life (Auto Loot, Fast Travel)
- Cosmetics (Chat tags, Special effects)

**Giá đề xuất:**
- Basic features: 99-199 Robux
- Premium features: 299-499 Robux
- Ultimate VIP: 999+ Robux

### 2️⃣ Developer Products (Mua nhiều lần)

**Phù hợp với:**
- Gold packs (50K, 100K, 500K, 1M)
- Temporary boosts (1h, 8h, 24h)
- Consumable items (Resurrection Pills, Breakthrough Pills)
- Skill books
- Exclusive weapons/armors

**Giá đề xuất:**
- Small items: 49-99 Robux
- Medium items: 149-399 Robux
- Large items: 499-999 Robux
- Premium items: 1299-1999 Robux

---

## 📊 Pricing Strategy

### Gold Packs (Ví dụ)

| Pack | Gold | Bonus | Price | Value |
|------|------|-------|-------|-------|
| Small | 50K | - | 49R$ | 1K/R$ |
| Medium | 100K | +10K | 99R$ | 1.1K/R$ |
| Large | 500K | +100K | 399R$ | 1.5K/R$ |
| **Best Value** | 1M | +300K | 699R$ | **1.86K/R$** ⭐ |

**💡 Tip:** Pack lớn nhất nên có **best value** để khuyến khích mua nhiều!

### Boosts

| Boost | Duration | Price |
|-------|----------|-------|
| 2x Tu Vi | 1 hour | 99R$ |
| 2x Tu Vi | 8 hours | 499R$ (save 40%!) |
| 3x All | 1 hour | 249R$ |

### Bundles

**Starter Pack (499R$):**
- 100K Gold
- Linh Kiếm
- Linh Y
- 10x Tu Khí Đan
- 1h 2x Tu Vi Boost

**Value = ~800R$ if bought separately** → Save 38%!

---

## 🎨 Best Practices

### ✅ Nên Làm

- **Game Passes cho convenience** (Auto Loot, Fast TP) - Không ảnh hưởng balance
- **Boosts thay vì direct power** - x2 XP OK, +9999 damage KHÔNG OK
- **Bundles có discount** - Mua nhiều = save nhiều
- **Best Value tag** - Highlight pack có giá trị nhất
- **VIP có nhiều perks** - 10% discount + XP boost + cosmetics + etc.

### ❌ Không Nên

- **Pay-to-win weapons** - Bán vũ khí quá OP so với free items
- **Essential features behind paywall** - Core gameplay phải free
- **Excessive pricing** - 9999R$ cho 1 item = bad
- **False advertising** - "VIP" nhưng chỉ có 1 benefit

---

## 🔧 Implementation Checklist

### Game Pass Setup

- [ ] Create Game Pass trên Roblox Creator Hub
- [ ] Copy Game Pass ID
- [ ] Update `GamePassModule.lua` với ID
- [ ] Test trong Studio
- [ ] Test trên live server (với alt account)

### Developer Product Setup

- [ ] Create Developer Products trên Creator Hub
- [ ] Copy Product IDs
- [ ] Update `DevProductModule.lua` với IDs
- [ ] Implement giving logic trong `MonetizationService.lua`
- [ ] Test purchases trong Studio
- [ ] Test trên live server

### Integration

- [ ] Connect shop UI với monetization modules
- [ ] Add "Buy with Robux" buttons
- [ ] Show Game Pass benefits trong UI
- [ ] Add VIP chat tags
- [ ] Implement boost timers/UI
- [ ] Test all purchase flows

---

## 🧪 Testing

### Test Game Pass

```lua
-- Trong game, test HasPass:
local GamePassModule = require(ReplicatedStorage.Modules.Monetization.GamePassModule)

print("Has VIP:", GamePassModule.HasPass(player, "VIP"))
print("Tu Vi Multiplier:", GamePassModule.GetTuViMultiplier(player))
print("Shop Discount:", GamePassModule.GetShopDiscount(player))
```

### Test Developer Product

```lua
-- Server-side test:
local DevProductModule = require(ReplicatedStorage.Modules.Monetization.DevProductModule)

-- Prompt purchase
DevProductModule.PromptPurchase(player, "100K Gold Pack")

-- Trong Studio, purchase prompt sẽ hiện (fake purchase)
-- Trên live server, player sẽ bị charge Robux
```

---

## 📈 Analytics & Optimization

### Track These Metrics

1. **Conversion Rate** - % players who buy
2. **ARPPU** - Average Revenue Per Paying User
3. **Most Popular Items** - Which items sell best?
4. **Bundle Performance** - Do bundles convert better?
5. **VIP Retention** - Do VIP players stay longer?

### A/B Testing Ideas

- Test different price points (99R$ vs 149R$)
- Test bundle contents
- Test discount percentages
- Test UI placement (Shop tab vs Popup)

---

## 💡 Monetization Tips

### Freemium Model

- **80% game content = FREE**
- 20% premium content = Paid

### Whale-Friendly

- Offer expensive bundles for whales (1999R$+)
- But keep game balanced for free players

### Seasonal Events

- Limited-time bundles (Tết, Christmas)
- Exclusive seasonal items
- Flash sales (50% off for 24h)

### Daily Deals

- Rotate featured items
- "Today only" discounts
- Create urgency

---

## 🔒 Anti-Exploit

### Server-Side Validation

```lua
-- ❌ BAD - Client gọi để give gold
RemoteEvent:FireServer("GiveGold", 999999)

-- ✅ GOOD - Server validate purchase
MarketplaceService.ProcessReceipt = function(receiptInfo)
    -- Server checks purchase is legit
    -- Then gives gold
end
```

### Receipt Validation

```lua
-- ✅ Anti-duplicate purchases
local purchasedReceipts = {}

if purchasedReceipts[receiptInfo.PurchaseId] then
    return Enum.ProductPurchaseDecision.PurchaseGranted
end
```

---

## 📚 References

- **Admin Commands:** [ADMIN_TESTING_GUIDE.md](ADMIN_TESTING_GUIDE.md)
- **Game Pass Module:** [GamePassModule.lua](src/ReplicatedStorage/Modules/Monetization/GamePassModule.lua)
- **Dev Product Module:** [DevProductModule.lua](src/ReplicatedStorage/Modules/Monetization/DevProductModule.lua)
- **Monetization Service:** [MonetizationService.lua](src/ServerScriptService/Services/MonetizationService.lua)
- **Roblox Docs:** https://create.roblox.com/docs/production/monetization

---

🎉 **Chúc bạn kiếm nhiều Robux!** 💰
