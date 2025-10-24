-- ThienKiepModule.lua - Thiên Kiếp (Heavenly Tribulation) Boss System
-- Copy vào ReplicatedStorage/Modules/ThienKiep/ThienKiepModule (ModuleScript)

local ThienKiepModule = {}

-- ========================================
-- THIÊN KIẾP BOSSES (Breakthrough Bosses)
-- ========================================

ThienKiepModule.ThienKiepBosses = {
	-- Luyện Khí → Trúc Cơ (Realm 1 → 2)
	{
		BossID = "kiep_truc_co",
		Name = "Trúc Cơ Thiên Kiếp",
		Description = "Break through to Trúc Cơ realm",
		RequiredRealm = "LuyenKhi",
		RequiredRealmLevel = 9,
		TargetRealm = "TrucCo",

		Boss = {
			Name = "Thiên Lôi Linh Thú",
			Health = 5000,
			Damage = 150,
			Speed = 18,
			Color = Color3.fromRGB(150, 200, 255),
			Size = Vector3.new(8, 8, 8),

			Abilities = {
				{Name = "Lightning Strike", Cooldown = 5, Damage = 300},
				{Name = "Thunder Roar", Cooldown = 10, AOEDamage = 150, Range = 20}
			}
		},

		Rewards = {
			TuVi = 5000,
			Items = {
				{Name = "Trúc Cơ Đan", Amount = 3}
			}
		},

		FailurePenalty = {
			TuViLoss = 1000,
			HealthDamage = 0.5 -- 50% max HP damage
		}
	},

	-- Trúc Cơ → Kim Đan (Realm 2 → 3)
	{
		BossID = "kiep_kim_dan",
		Name = "Kim Đan Thiên Kiếp",
		Description = "Break through to Kim Đan realm",
		RequiredRealm = "TrucCo",
		RequiredRealmLevel = 9,
		TargetRealm = "KimDan",

		Boss = {
			Name = "Cửu Thiên Lôi Ma",
			Health = 15000,
			Damage = 350,
			Speed = 20,
			Color = Color3.fromRGB(255, 200, 0),
			Size = Vector3.new(10, 10, 10),

			Abilities = {
				{Name = "Lightning Storm", Cooldown = 8, Damage = 600, AOERange = 30},
				{Name = "Thunder Chain", Cooldown = 12, Damage = 800, ChainTargets = 3},
				{Name = "Heavenly Punishment", Cooldown = 20, Damage = 1500}
			}
		},

		Rewards = {
			TuVi = 15000,
			Items = {
				{Name = "Kim Đan", Amount = 2},
				{Name = "Lôi Linh Thạch", Amount = 5}
			}
		},

		FailurePenalty = {
			TuViLoss = 5000,
			HealthDamage = 0.7,
			RealmDemotion = true -- Can drop back to Trúc Cơ 8
		}
	},

	-- Kim Đan → Nguyên Anh (Realm 3 → 4)
	{
		BossID = "kiep_nguyen_anh",
		Name = "Nguyên Anh Thiên Kiếp",
		Description = "Break through to Nguyên Anh realm",
		RequiredRealm = "KimDan",
		RequiredRealmLevel = 9,
		TargetRealm = "NguyenAnh",

		Boss = {
			Name = "Thiên Ma Hóa Thân",
			Health = 40000,
			Damage = 800,
			Speed = 22,
			Color = Color3.fromRGB(200, 0, 200),
			Size = Vector3.new(12, 12, 12),

			Phases = {
				{
					HealthThreshold = 1.0,
					Name = "Phase 1: Thunder Form",
					Abilities = {
						{Name = "Lightning Barrage", Cooldown = 6, Damage = 1000},
						{Name = "Thunder Domain", Cooldown = 15, AOEDamage = 500, Duration = 10}
					}
				},
				{
					HealthThreshold = 0.5,
					Name = "Phase 2: Demon Form",
					Abilities = {
						{Name = "Demonic Lightning", Cooldown = 5, Damage = 1500},
						{Name = "Soul Shatter", Cooldown = 10, Damage = 2000, IgnoreDefense = true},
						{Name = "Tribulation Wrath", Cooldown = 20, Damage = 3000, AOERange = 40}
					}
				}
			}
		},

		Rewards = {
			TuVi = 50000,
			Items = {
				{Name = "Nguyên Anh Đan", Amount = 2},
				{Name = "Thiên Kiếp Linh Thạch", Amount = 10},
				{Name = "Linh Kiếm", Amount = 1}
			}
		},

		FailurePenalty = {
			TuViLoss = 20000,
			HealthDamage = 0.8,
			RealmDemotion = true,
			Injury = {
				Name = "Thiên Kiếp Thương",
				Duration = 3600, -- 1 hour
				Effects = {
					AllStatsMultiplier = 0.5 -- -50% stats
				}
			}
		}
	},

	-- Hóa Thần → Luyện Hư (Realm 4 → 5)
	{
		BossID = "kiep_luyen_hu",
		Name = "Luyện Hư Thiên Kiếp",
		Description = "Break through to Luyện Hư realm",
		RequiredRealm = "HoaThan",
		RequiredRealmLevel = 9,
		TargetRealm = "LuyenHu",

		Boss = {
			Name = "Hư Không Lôi Ma",
			Health = 100000,
			Damage = 2000,
			Speed = 25,
			Color = Color3.fromRGB(100, 100, 255),
			Size = Vector3.new(15, 15, 15),

			Phases = {
				{
					HealthThreshold = 1.0,
					Name = "Phase 1: Void Thunder",
					Abilities = {
						{Name = "Void Strike", Cooldown = 5, Damage = 3000},
						{Name = "Thunder Cascade", Cooldown = 10, Damage = 5000, Hits = 3}
					}
				},
				{
					HealthThreshold = 0.6,
					Name = "Phase 2: Tribulation Storm",
					Abilities = {
						{Name = "Tribulation Lightning", Cooldown = 5, Damage = 6000},
						{Name = "Void Domain", Cooldown = 15, AOEDamage = 3000, SlowEffect = 0.5}
					}
				},
				{
					HealthThreshold = 0.3,
					Name = "Phase 3: Heavenly Wrath",
					Abilities = {
						{Name = "Nine Heavens Thunder", Cooldown = 8, Damage = 10000},
						{Name = "Annihilation", Cooldown = 20, Damage = 20000, InstantKillThreshold = 0.20}
					}
				}
			}
		},

		Rewards = {
			TuVi = 200000,
			Items = {
				{Name = "Luyện Hư Đan", Amount = 3},
				{Name = "Hư Không Thạch", Amount = 20},
				{Name = "Thiên Kiếp Thánh Khí", Amount = 1}
			}
		},

		FailurePenalty = {
			TuViLoss = 100000,
			HealthDamage = 0.9,
			RealmDemotion = true,
			Injury = {
				Name = "Hư Không Thương",
				Duration = 7200,
				Effects = {
					AllStatsMultiplier = 0.3
				}
			},
			DeathRisk = 0.1 -- 10% chance of death on failure
		}
	},

	-- Đại Thừa → Độ Kiếp (Realm 8 → 9, final breakthrough)
	{
		BossID = "kiep_do_kiep",
		Name = "Độ Kiếp Thiên Ma",
		Description = "Ascend to Độ Kiếp realm",
		RequiredRealm = "DaiThua",
		RequiredRealmLevel = 9,
		TargetRealm = "DoKiep",

		Boss = {
			Name = "Cửu Trùng Thiên Ma Đế",
			Health = 500000,
			Damage = 10000,
			Speed = 30,
			Color = Color3.fromRGB(255, 0, 255),
			Size = Vector3.new(20, 20, 20),

			Phases = {
				{
					HealthThreshold = 1.0,
					Name = "Phase 1: Tribulation Begins",
					Abilities = {
						{Name = "Heaven's Judgment", Cooldown = 5, Damage = 15000},
						{Name = "Lightning Ocean", Cooldown = 10, AOEDamage = 10000, Range = 50}
					}
				},
				{
					HealthThreshold = 0.75,
					Name = "Phase 2: Divine Punishment",
					Abilities = {
						{Name = "God Slayer", Cooldown = 5, Damage = 25000, ArmorPenetration = 1.0},
						{Name = "Heavenly Chains", Cooldown = 12, Damage = 20000, Stun = 3}
					}
				},
				{
					HealthThreshold = 0.5,
					Name = "Phase 3: Void Collapse",
					Abilities = {
						{Name = "Void Annihilation", Cooldown = 8, Damage = 35000},
						{Name = "Reality Tear", Cooldown = 15, Damage = 50000, IgnoreAll = true}
					}
				},
				{
					HealthThreshold = 0.25,
					Name = "Phase 4: Final Judgment",
					Abilities = {
						{Name = "Apocalypse Thunder", Cooldown = 10, Damage = 80000},
						{Name = "Nine Heavens Extinction", Cooldown = 20, Damage = 150000, OneShot = true}
					}
				}
			}
		},

		Rewards = {
			TuVi = 1000000,
			Items = {
				{Name = "Độ Kiếp Thánh Đan", Amount = 5},
				{Name = "Thiên Ma Thánh Khí", Amount = 3},
				{Name = "Cửu Thiên Linh Bảo", Amount = 1}
			},
			Title = "Độ Kiếp Chân Nhân" -- Ascended Immortal
		},

		FailurePenalty = {
			TuViLoss = 500000,
			HealthDamage = 1.0, -- Instant death
			RealmDemotion = true,
			Injury = {
				Name = "Thiên Ma Phản Phệ",
				Duration = 86400, -- 24 hours
				Effects = {
					AllStatsMultiplier = 0.1,
					CannotMeditate = true
				}
			},
			DeathRisk = 0.5 -- 50% death chance
		}
	}
}

-- ========================================
-- GET THIÊN KIẾP BY REALM
-- ========================================

function ThienKiepModule.GetThienKiepForRealm(currentRealm, realmLevel)
	for _, kiep in ipairs(ThienKiepModule.ThienKiepBosses) do
		if kiep.RequiredRealm == currentRealm and kiep.RequiredRealmLevel == realmLevel then
			return kiep
		end
	end
	return nil
end

-- ========================================
-- CAN ATTEMPT THIÊN KIẾP
-- ========================================

function ThienKiepModule.CanAttemptThienKiep(playerData)
	-- Check if at max level of current realm
	if playerData.RealmLevel ~= 9 then
		return false, "Must reach realm level 9 first!"
	end

	-- Check if has Thiên Kiếp for this realm
	local kiep = ThienKiepModule.GetThienKiepForRealm(playerData.Realm, playerData.RealmLevel)
	if not kiep then
		return false, "No Thiên Kiếp available for this realm!"
	end

	-- Check if has injury
	if playerData.Injury and playerData.Injury.EndTime and os.time() < playerData.Injury.EndTime then
		local remaining = math.ceil((playerData.Injury.EndTime - os.time()) / 60)
		return false, "Still injured from previous failure! " .. remaining .. " min remaining"
	end

	return true, kiep
end

-- ========================================
-- GET BOSS DATA
-- ========================================

function ThienKiepModule.GetBossData(kiepID)
	for _, kiep in ipairs(ThienKiepModule.ThienKiepBosses) do
		if kiep.BossID == kiepID then
			return kiep.Boss
		end
	end
	return nil
end

-- ========================================
-- GET CURRENT PHASE
-- ========================================

function ThienKiepModule.GetCurrentPhase(boss, healthPercent)
	if not boss.Phases then
		return nil
	end

	for i = #boss.Phases, 1, -1 do
		local phase = boss.Phases[i]
		if healthPercent <= phase.HealthThreshold then
			return phase, i
		end
	end

	return boss.Phases[1], 1
end

-- ========================================
-- APPLY FAILURE PENALTY
-- ========================================

function ThienKiepModule.ApplyFailurePenalty(playerData, penalty)
	-- Tu Vi loss
	if penalty.TuViLoss then
		playerData.TuVi = math.max(0, playerData.TuVi - penalty.TuViLoss)
	end

	-- Health damage (handled by combat system)

	-- Realm demotion
	if penalty.RealmDemotion then
		if playerData.RealmLevel > 1 then
			playerData.RealmLevel = playerData.RealmLevel - 1
		end
	end

	-- Apply injury
	if penalty.Injury then
		playerData.Injury = {
			Name = penalty.Injury.Name,
			EndTime = os.time() + penalty.Injury.Duration,
			Effects = penalty.Injury.Effects
		}
	end

	-- Death risk
	if penalty.DeathRisk then
		if math.random() < penalty.DeathRisk then
			-- Player dies (handled by combat system)
			return true -- Death occurred
		end
	end

	return false -- No death
end

-- ========================================
-- APPLY SUCCESS REWARDS
-- ========================================

function ThienKiepModule.ApplySuccessRewards(playerData, kiep)
	-- Tu Vi reward
	if kiep.Rewards.TuVi then
		playerData.TuVi = playerData.TuVi + kiep.Rewards.TuVi
	end

	-- Breakthrough to next realm
	playerData.Realm = kiep.TargetRealm
	playerData.RealmLevel = 1

	-- Title (if any)
	if kiep.Rewards.Title then
		playerData.Title = kiep.Rewards.Title
	end

	-- Items are handled by loot system
end

-- ========================================
-- GET THIÊN KIẾP DESCRIPTION
-- ========================================

function ThienKiepModule.GetDescription(kiep)
	local desc = {
		"Thiên Kiếp Boss: " .. kiep.Boss.Name,
		"HP: " .. kiep.Boss.Health,
		"Damage: " .. kiep.Boss.Damage,
		"",
		"Success:",
		"  • Breakthrough to " .. kiep.TargetRealm,
		"  • +" .. kiep.Rewards.TuVi .. " Tu Vi"
	}

	if kiep.Rewards.Items then
		for _, item in ipairs(kiep.Rewards.Items) do
			table.insert(desc, "  • " .. item.Amount .. "x " .. item.Name)
		end
	end

	table.insert(desc, "")
	table.insert(desc, "Failure:")
	table.insert(desc, "  • -" .. kiep.FailurePenalty.TuViLoss .. " Tu Vi")

	if kiep.FailurePenalty.RealmDemotion then
		table.insert(desc, "  • Realm demotion")
	end

	if kiep.FailurePenalty.Injury then
		table.insert(desc, "  • " .. kiep.FailurePenalty.Injury.Name .. " injury")
	end

	if kiep.FailurePenalty.DeathRisk then
		table.insert(desc, "  • " .. (kiep.FailurePenalty.DeathRisk * 100) .. "% death chance")
	end

	return table.concat(desc, "\n")
end

print("✅ ThienKiepModule loaded")
return ThienKiepModule
