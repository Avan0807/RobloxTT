# 📦 PHASES 4-9 - Advanced Features

**Game tu luyện Roblox - Hệ thống mở rộng**

---

## 🎯 Tổng Quan

Phases 4-9 bổ sung các hệ thống nâng cao vào game tu luyện:

| Phase | Tên | Files | Mô tả |
|-------|-----|-------|-------|
| **Phase 4** | Loot & Inventory | 5 files | Hệ thống rơi đồ và túi đồ |
| **Phase 5** | Equipment | 3 files | Hệ thống trang bị |
| **Phase 6** | Shop & Economy | 3 files | Cửa hàng mua bán |
| **Phase 7** | Quest/Mission | 3 files | Nhiệm vụ |
| **Phase 8** | Boss System | 3 files | Boss chiến đấu |
| **Phase 9** | DataStore | 2 files | Lưu trữ dữ liệu |

**Tổng cộng**: 19 files mới

---

## 📦 Phase 4: Loot & Inventory System

### Files
1. `1_ReplicatedStorage/Modules/Loot/LootModule.lua` (ModuleScript)
2. `1_ReplicatedStorage/Modules/Inventory/InventoryModule.lua` (ModuleScript)
3. `2_ServerScriptService/LootService.lua` (Script)
4. `2_ServerScriptService/InventoryService.lua` (Script)
5. `3_StarterPlayerScripts/InventoryUI.lua` (LocalScript)

### Features
- ✅ Loot drop từ enemies (Pills, Materials, Gold)
- ✅ Rarity system (Common, Uncommon, Rare, Epic, Legendary)
- ✅ Inventory với 50 slots
- ✅ Item stacking (max 999)
- ✅ Use items (Pills tăng Tu Vi)
- ✅ Sort inventory
- ✅ Visual loot drops với proximity prompts
- ✅ Auto-pickup khi đứng gần

### Controls
- **I** - Open/Close Inventory
- **Click item** - Use item (Pills)
- **Sort button** - Sort inventory by rarity

### Integration
- Enemies drop loot khi chết
- Pills có thể dùng để tăng Tu Vi
- Items cần cho breakthrough (từ Phase 1-3)

---

## ⚔️ Phase 5: Equipment System

### Files
1. `1_ReplicatedStorage/Modules/Equipment/EquipmentModule.lua` (ModuleScript)
2. `2_ServerScriptService/EquipmentService.lua` (Script)
3. `3_StarterPlayerScripts/EquipmentUI.lua` (LocalScript)

### Features
- ✅ 7 equipment slots (Weapon, Armor, Helmet, Boots, 2 Accessories, Talisman)
- ✅ Equipment tiers (Phàm, Linh, Địa, Thiên, Tiên, Thần)
- ✅ Stat bonuses (HP, Damage, Defense, Speed, Crit, etc.)
- ✅ Level requirements
- ✅ Cultivation type restrictions
- ✅ Visual equipment display
- ✅ Equipment upgrade system

### Controls
- **E** - Open/Close Equipment UI
- **Click slot** - Unequip item
- **Equip from inventory** - Items auto-equip to correct slot

### Equipment Types
- **Weapons**: Kiếm (Tiên Thiên), Quyền (Cổ Thần), Trượng (Ma Đạo)
- **Armor**: Y, Giáp
- **Accessories**: Nhẫn, Bùa
- **Talisman**: Pháp Bảo

---

## 🛒 Phase 6: Shop & Economy System

### Files
1. `1_ReplicatedStorage/Modules/Shop/ShopModule.lua` (ModuleScript)
2. `2_ServerScriptService/ShopService.lua` (Script)
3. `3_StarterPlayerScripts/ShopUI.lua` (LocalScript)

### Features
- ✅ 4 shop categories (Pills, Equipment, Materials, Special)
- ✅ Buy/Sell system
- ✅ Dynamic pricing
- ✅ Stock system (limited items)
- ✅ Level requirements
- ✅ Daily deals
- ✅ Shop dialogues
- ✅ Auto-refresh daily

### Controls
- **B** - Open/Close Shop
- **Click Buy** - Purchase item
- **Click Sell** - Sell item from inventory

### Shop Categories
- **Pills**: Tu Khí Đan, Tiểu Hoàn Đan, Đại Hoàn Đan
- **Equipment**: Weapons, Armors, Accessories
- **Materials**: Thú Cốt, Vạn Niên Linh Dược, Kim Cang Xá Lợi
- **Special**: Limited items (Thái Cổ Linh Đan, Lôi Pháp)

---

## 📋 Phase 7: Quest/Mission System

### Files
1. `1_ReplicatedStorage/Modules/Quest/QuestModule.lua` (ModuleScript)
2. `2_ServerScriptService/QuestService.lua` (Script)
3. `3_StarterPlayerScripts/QuestUI.lua` (LocalScript)

### Features
- ✅ Multiple quest types (Kill, Collect, Meditation, Level Up, Equip, Shop)
- ✅ Quest difficulties (Easy, Medium, Hard, Legendary)
- ✅ Quest tracker (always visible)
- ✅ Quest rewards (Gold, Tu Vi, Items)
- ✅ Daily quests (auto-reset)
- ✅ Repeatable quests
- ✅ Quest progression tracking
- ✅ Tutorial quests

### Controls
- **Q** - Open/Close Quest Log
- **Quest Tracker** - Shows active quests (top right)

### Quest Types
- **Kill**: Giết enemies
- **Collect**: Thu thập items
- **Meditation**: Tăng Tu Vi
- **Level Up**: Đạt level
- **Equip**: Trang bị items
- **Shop**: Mua items

---

## 👑 Phase 8: Boss System

### Files
1. `1_ReplicatedStorage/Modules/Boss/BossModule.lua` (ModuleScript)
2. `2_ServerScriptService/BossService.lua` (Script)
3. `3_StarterPlayerScripts/BossUI.lua` (LocalScript)

### Features
- ✅ 3 bosses (Beginner, Mid-tier, World Boss)
- ✅ Boss phases (HP thresholds trigger power-ups)
- ✅ Special abilities (AOE, Charge, Summon, etc.)
- ✅ Boss health bar (top center)
- ✅ Rich loot tables
- ✅ Auto-respawn timers
- ✅ World boss announcements
- ✅ Phase transition messages

### Bosses
1. **Linh Thú Vương** (Level 5, 5K HP)
   - Location: Rừng Linh Thú
   - Respawn: 5 minutes
   - Abilities: Roar, Charge

2. **Thiên Môn Ma Vương** (Level 15, 20K HP)
   - Location: Huyền Thiên Sơn
   - Respawn: 10 minutes
   - Abilities: Dark Bolt, Soul Drain, Summon Minions

3. **Thiên Ma Đế Tôn** (Level 27, 100K HP)
   - Location: World Boss Area
   - Respawn: 1 hour
   - Abilities: Void Blast, Death Ray, Summon Army, Meteor Storm
   - World Boss (announced to all players)

### Boss Mechanics
- **Phases**: Bosses get stronger at 75%, 50%, 25% HP
- **Abilities**: Auto-use on cooldown when in range
- **Loot**: Guaranteed gold + Tu Vi, chance for rare items

---

## 💾 Phase 9: DataStore Persistence

### Files
1. `1_ReplicatedStorage/Modules/DataStore/DataStoreModule.lua` (ModuleScript)
2. `2_ServerScriptService/DataStoreService.lua` (Script)

### Features
- ✅ Save all player data
- ✅ Auto-save every 5 minutes
- ✅ Save on player leave
- ✅ Save on server shutdown
- ✅ Retry logic (3 attempts)
- ✅ Data validation
- ✅ Data migration support
- ✅ Serialize/Deserialize
- ✅ Data size checking (4MB limit)

### Saved Data
- Cultivation (Type, Realm, Level, Tu Vi)
- Inventory (Gold, Items)
- Equipment (All slots)
- Quests (Active, Completed)
- Hồn Phiên (for Ma Đạo)
- Achievements
- Playtime
- Last login

### DataStore Settings
- **Auto-save interval**: 5 minutes
- **Max retries**: 3
- **Retry delay**: 1-3 seconds (exponential)
- **Data version**: 1 (for future migrations)

---

## 🎮 Full Controls Summary

| Key | Function |
|-----|----------|
| **WASD** | Move |
| **Mouse** | Aim |
| **Q, E, R, F, G** | Skills |
| **Space** | Dodge/Dash |
| **I** | Inventory |
| **E** | Equipment |
| **B** | Shop |
| **Q** | Quest Log |
| **ESC** | Close UI |

---

## 📊 Integration Map

```
Phase 1-3 (Core)
    ↓
Phase 4 (Loot & Inventory)
    ↓
Phase 5 (Equipment) ←→ Inventory
    ↓
Phase 6 (Shop) ←→ Inventory + Equipment
    ↓
Phase 7 (Quests) ←→ All systems
    ↓
Phase 8 (Bosses) ←→ Loot + Combat
    ↓
Phase 9 (DataStore) ←→ ALL SYSTEMS
```

---

## 🔧 Setup Instructions

### 1. Copy All Files
Follow folder structure:
- `1_ReplicatedStorage/` → Copy to `ReplicatedStorage`
- `2_ServerScriptService/` → Copy to `ServerScriptService`
- `3_StarterPlayerScripts/` → Copy to `StarterPlayer/StarterPlayerScripts`

### 2. Create Required RemoteEvents
Add these to `ReplicatedStorage/RemoteEvents/`:
- `GetInventory` (RemoteEvent)
- `UseItem` (RemoteEvent)
- `SyncInventory` (RemoteEvent)
- `EquipItem` (RemoteEvent)
- `UnequipItem` (RemoteEvent)
- `SyncEquipment` (RemoteEvent)
- `BuyItem` (RemoteEvent)
- `SellItem` (RemoteEvent)
- `GetShop` (RemoteEvent)
- `SyncShop` (RemoteEvent)
- `AcceptQuest` (RemoteEvent)
- `AbandonQuest` (RemoteEvent)
- `GetQuests` (RemoteEvent)
- `SyncQuests` (RemoteEvent)
- `BossNotification` (RemoteEvent)
- `LootNotification` (RemoteEvent)
- `ShopNotification` (RemoteEvent)
- `QuestNotification` (RemoteEvent)

### 3. Enable Studio Access to API Services
- Go to Game Settings → Security
- Enable "Allow HTTP Requests"
- Enable "Enable Studio Access to API Services"

### 4. Test
- Press F5 to play
- Test each system:
  - Kill enemies → Loot drops
  - Press I → Open inventory
  - Press E → Open equipment
  - Press B → Open shop
  - Press Q → Open quests
  - Find bosses → Fight

---

## 📈 Performance Notes

- **Auto-save**: Every 5 minutes
- **Loot cleanup**: 60 seconds auto-despawn
- **Boss AI**: 0.5s tick rate
- **Quest tracking**: Real-time updates
- **Max inventory slots**: 50
- **Max item stack**: 999
- **DataStore limit**: 4MB per player

---

## 🐛 Troubleshooting

### Inventory not showing
- Wait 2-3 seconds after spawn
- Check RemoteEvents folder exists

### Items not saving
- Enable Studio Access to API Services
- Check Output for DataStore errors
- Check data size (must be < 4MB)

### Bosses not spawning
- Check BossService loaded
- Look in workspace for boss models
- Check boss spawn positions

### Quests not tracking
- Accept quest first (press Q)
- Check quest type matches action
- Look at quest tracker (top right)

---

## 🚀 Future Enhancements

- [ ] Trading system (player-to-player)
- [ ] Guilds/Clans
- [ ] PvP Arena
- [ ] Leaderboards
- [ ] Pets/Companions
- [ ] Crafting system
- [ ] Auction House
- [ ] VIP/Game Passes
- [ ] More bosses
- [ ] Dungeons

---

## 📝 Credits

**Game Type**: Cultivation RPG (Tu Tiên/修仙)
**Phases 4-9**: Advanced systems expansion
**Total Files**: 37 (Phase 1-3) + 19 (Phase 4-9) = **56 files**
**Total Lines**: ~5,800 (Phase 1-3) + ~7,000 (Phase 4-9) = **~12,800 lines**

---

## ✨ Complete Feature List

### ✅ Combat & Skills
- Skillshot-based combat
- 45 skills (15 per cultivation type)
- Dodge system with i-frames
- Damage numbers
- Crit system

### ✅ Cultivation
- 3 cultivation types
- 27 realms (3×9)
- Tu Vi system
- Breakthrough mechanics
- Hồn Phiên (Ma Đạo)

### ✅ World & Enemies
- 2 maps + portals
- 12 enemy types
- 3 bosses
- Enemy AI
- Auto-respawn

### ✅ Loot & Items
- Loot drops
- 5 rarities
- Inventory (50 slots)
- Item stacking
- Pills, Materials, Equipment

### ✅ Equipment
- 7 equipment slots
- 6 tiers
- Stat bonuses
- Level requirements

### ✅ Economy
- Shop system
- Buy/Sell
- Gold currency
- Daily deals

### ✅ Quests
- 6 quest types
- Quest tracker
- Daily quests
- Rewards

### ✅ Data
- DataStore persistence
- Auto-save
- Data validation
- Migration support

### ✅ UI
- Inventory UI (I)
- Equipment UI (E)
- Shop UI (B)
- Quest UI (Q)
- Boss health bars
- Stats display
- Cultivation UI

---

**🎉 GAME HOÀN CHỈNH 100%! 🎉**

Tất cả 9 phases đã được implement và sẵn sàng để chơi!
