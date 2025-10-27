-- InventoryModule.lua - Hệ Thống Inventory
-- Copy vào ReplicatedStorage/Modules/Inventory/InventoryModule (ModuleScript)

local InventoryModule = {}

-- ========================================
-- INVENTORY SETTINGS
-- ========================================

InventoryModule.MaxSlots = 50
InventoryModule.MaxStackSize = 999

-- ========================================
-- CREATE NEW INVENTORY
-- ========================================

function InventoryModule.CreateNew()
	return {
		Slots = {}, -- {ItemName, Amount, ...itemData}
		Gold = 0
	}
end

-- ========================================
-- ADD ITEM
-- ========================================

function InventoryModule.AddItem(inventory, itemData, amount)
	amount = amount or 1

	-- Special handling for Gold
	if itemData.Type == "Gold" then
		inventory.Gold = inventory.Gold + amount
		return true, "Added " .. amount .. " Tiên Ngọc"
	end

	-- Check if item already exists (stackable)
	for i, slot in ipairs(inventory.Slots) do
		if slot.Name == itemData.Name then
			-- Stack items
			local newAmount = slot.Amount + amount

			-- Check max stack size
			if newAmount <= InventoryModule.MaxStackSize then
				slot.Amount = newAmount
				return true, "Stacked " .. amount .. " " .. itemData.Name
			else
				-- Stack is full, create new slot
				local overflow = newAmount - InventoryModule.MaxStackSize
				slot.Amount = InventoryModule.MaxStackSize
				return InventoryModule.AddItem(inventory, itemData, overflow)
			end
		end
	end

	-- Item doesn't exist, create new slot
	if #inventory.Slots >= InventoryModule.MaxSlots then
		return false, "Inventory full!"
	end

	table.insert(inventory.Slots, {
		Name = itemData.Name,
		Type = itemData.Type,
		Rarity = itemData.Rarity,
		Amount = amount,
		Description = itemData.Description,
		Icon = itemData.Icon,
		TuViBonus = itemData.TuViBonus
	})

	return true, "Added " .. amount .. " " .. itemData.Name
end

-- ========================================
-- REMOVE ITEM
-- ========================================

function InventoryModule.RemoveItem(inventory, itemName, amount)
	amount = amount or 1

	-- Special handling for Gold
	if itemName == "Tiên Ngọc" or itemName == "Gold" then
		if inventory.Gold >= amount then
			inventory.Gold = inventory.Gold - amount
			return true, "Removed " .. amount .. " Tiên Ngọc"
		else
			return false, "Not enough gold!"
		end
	end

	-- Find and remove item
	for i = #inventory.Slots, 1, -1 do
		local slot = inventory.Slots[i]
		if slot.Name == itemName then
			if slot.Amount >= amount then
				slot.Amount = slot.Amount - amount

				-- Remove slot if empty
				if slot.Amount <= 0 then
					table.remove(inventory.Slots, i)
				end

				return true, "Removed " .. amount .. " " .. itemName
			else
				return false, "Not enough " .. itemName .. "!"
			end
		end
	end

	return false, "Item not found!"
end

-- ========================================
-- GET ITEM COUNT
-- ========================================

function InventoryModule.GetItemCount(inventory, itemName)
	-- Gold check
	if itemName == "Tiên Ngọc" or itemName == "Gold" then
		return inventory.Gold
	end

	-- Count stacks
	local total = 0
	for _, slot in ipairs(inventory.Slots) do
		if slot.Name == itemName then
			total = total + slot.Amount
		end
	end

	return total
end

-- ========================================
-- HAS ITEM (Check if has enough)
-- ========================================

function InventoryModule.HasItem(inventory, itemName, amount)
	amount = amount or 1
	return InventoryModule.GetItemCount(inventory, itemName) >= amount
end

-- ========================================
-- USE ITEM (Pills)
-- ========================================

function InventoryModule.UseItem(inventory, itemName, playerData)
	-- Find item
	local itemSlot = nil
	for _, slot in ipairs(inventory.Slots) do
		if slot.Name == itemName then
			itemSlot = slot
			break
		end
	end

	if not itemSlot then
		return false, "Item not found!"
	end

	-- Check item type
	if itemSlot.Type == "Pill" then
		-- Use pill - Add Tu Vi
		if itemSlot.TuViBonus then
			playerData.TuVi = playerData.TuVi + itemSlot.TuViBonus

			-- Remove one pill
			local success, msg = InventoryModule.RemoveItem(inventory, itemName, 1)
			if success then
				return true, "Used " .. itemName .. " (+" .. itemSlot.TuViBonus .. " Tu Vi)"
			end
		end
	end

	return false, "Cannot use this item!"
end

-- ========================================
-- SORT INVENTORY (by Rarity, then Name)
-- ========================================

function InventoryModule.Sort(inventory)
	local rarityOrder = {
		["Legendary"] = 1,
		["Epic"] = 2,
		["Rare"] = 3,
		["Uncommon"] = 4,
		["Common"] = 5
	}

	table.sort(inventory.Slots, function(a, b)
		local rarityA = rarityOrder[a.Rarity and a.Rarity.Name or "Common"] or 6
		local rarityB = rarityOrder[b.Rarity and b.Rarity.Name or "Common"] or 6

		if rarityA == rarityB then
			return a.Name < b.Name
		end
		return rarityA < rarityB
	end)
end

-- ========================================
-- GET INVENTORY SUMMARY
-- ========================================

function InventoryModule.GetSummary(inventory)
	local summary = {
		TotalSlots = #inventory.Slots,
		MaxSlots = InventoryModule.MaxSlots,
		Gold = inventory.Gold,
		Items = {}
	}

	for _, slot in ipairs(inventory.Slots) do
		table.insert(summary.Items, {
			Name = slot.Name,
			Amount = slot.Amount,
			Rarity = slot.Rarity and slot.Rarity.Name or "Common"
		})
	end

	return summary
end

-- ========================================
-- TRANSFER ITEMS (Trading)
-- ========================================

function InventoryModule.TransferItem(fromInventory, toInventory, itemName, amount)
	-- Check if sender has item
	if not InventoryModule.HasItem(fromInventory, itemName, amount) then
		return false, "Not enough items to transfer!"
	end

	-- Get item data from sender
	local itemData = nil
	for _, slot in ipairs(fromInventory.Slots) do
		if slot.Name == itemName then
			itemData = slot
			break
		end
	end

	if not itemData then
		return false, "Item not found!"
	end

	-- Remove from sender
	local success1, msg1 = InventoryModule.RemoveItem(fromInventory, itemName, amount)
	if not success1 then
		return false, msg1
	end

	-- Add to receiver
	local success2, msg2 = InventoryModule.AddItem(toInventory, itemData, amount)
	if not success2 then
		-- Rollback
		InventoryModule.AddItem(fromInventory, itemData, amount)
		return false, msg2
	end

	return true, "Transferred " .. amount .. " " .. itemName
end

print("✅ InventoryModule loaded")
return InventoryModule
