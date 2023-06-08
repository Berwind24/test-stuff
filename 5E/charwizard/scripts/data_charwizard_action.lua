-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- Examples:
-- { type = "attack", range = "[M|R]", [modifier = #] }
--		If modifier defined, then attack bonus will be this fixed value
--		Otherwise, the attack bonus will be the ability bonus defined for the spell group
--
-- { type = "damage", clauses = { { dice = { "d#", ... }, modifier = #, type = "", [stat = ""] }, ... } }
--		Each damage action can have multiple clauses which can do different damage types
--
-- { type = "heal", [subtype = "temp", ][sTargeting = "self", ] clauses = { { dice = { "d#", ... }, bonus = #, [stat = ""] }, ... } }
--		Each heal action can have multiple clauses 
--		Heal actions are either direct healing or granting temporary hit points (if subtype = "temp" set)
--		If sTargeting = "self" set, then the heal will always be applied to self instead of target.
--
-- { type = "powersave", save = "<ability>", [savemod = #, ][savestat = "<ability>", ][onmissdamage = "half"] }
--		If savemod defined, then the DC will be this fixed value.
--		If savestat defined, then the DC will be calculated as 8 + specified ability bonus + proficiency bonus
--		Otherwise, the save DC will be the same as the spell group
--
-- { type = "effect", sName = "<effect text>", [sTargeting = "self", ][nDuration = #, ][sUnits = "[<empty>|minute|hour|day]", ][sApply = "[<empty>|action|roll|single]"] }
--		If sTargeting = "self" set, then the effect will always be applied to self instead of target.
--		If nDuration not set or is equal to zero, then the effect will not expire.
--[[
	[""] = {
		actions = {
			{ type = "attack", range = "[M|R]", [modifier = #] },
			{ type = "damage", clauses = { { dice = { "d#", ... }, modifier = #, dmgtype = "", [stat = ""] }, ... } },
			{ type = "heal", [subtype = "temp", ][sTargeting = "self", ] clauses = { { dice = { "d#", ... }, bonus = #, [stat = ""] }, ... } },
			{ type = "powersave", save = "<ability>", [savemod = #, ][savestat = "<ability>", ][onmissdamage = "half"] },
			{ type = "effect", sName = "<effect text>", [sTargeting = "self", ][nDuration = #, ][sUnits = "[<empty>|minute|hour|day]", ][sApply = "[<empty>|action|roll|single]"] },
		},
	},
--]]
parsedata = {
	--
	-- CLASSES
	--
	-- Artificier
	["protector"] = { actions = { { type = "heal", subtype = "temp", clauses = { { dice = { "d8" }, bonus = 0, stat = "intelligence" }, }, }, }, },
	["spellstoringitem"] = { actions = {}, prepared = 1, usesperiod = "once" },
	["soulofartifice"] = {
		actions = { { type = "effect", sName = "Soul of Artifice; SAVE: 1", sTargeting = "self", }, },
		prepared = 1,
	},
	["restorativereagents"] = {
		spell = { innate = {"lesser restoration"}, },
		actions = { { type = "heal", subtype = "temp", clauses = { { dice = { "d6", "d6" }, bonus = 0, stat = "intelligence" }, } }, },
	},
	["flashofgenius"] = { actions = { { type = "effect", sName = "Flash of Genius; SAVE: [INT]; CHECK: [INT]", sApply = "action", } }, prepared = 1, },
	-- Artificer - Alchemist
	["toolproficiencyalchemist"] = { proficiency = { innate = {"alchemist's supplies"}, }, },
	["alchemistsspells"] = {
		spell = {
			level = {
				[3] = {"healing word", "ray of sickness"},
				[5] = {"flaming sphere", "melf's acid arrow"},
				[9] = {"gaseous form", "mass healing word"},
				[13] = {"blight", "death ward"},
				[17] = {"cloudkill", "raise dead"},
			},
		},
	},
	["alchemicalsavant"] = {
		actions = {
			{ type = "effect", sName = "Alchemical Savant; HEAL: [INT]", sTargeting = "self", sApply = "roll", },
			{ type = "effect", sName = "Alchemical Savant; DMG: [INT]", sTargeting = "self", sApply = "roll", },
		},
	},
	["experimentalelixier"] = {
		multiple_actions = {
			["Experimental Elixier (Healing)"] = { actions = { { type = "heal", clauses = { { dice = { "d4", "d4" }, bonus = 0, stat = "intelligence" }, } }, }, },
			["Experimental Elixier (Resilience)"] = { actions = { { type = "effect", sName = "AC: 1", nDuration = 10, sUnits = "minute", }, }, },
			["Experimental Elixier (Boldness)"] = {
				actions = {
					{ type = "effect", sName = "ATK: d4", nDuration = 1, sUnits = "minute", },
					{ type = "effect", sName = "SAVE: d4", nDuration = 1, sUnits = "minute", },
				},
			},
		},
	},
	["restorativereagents"] = { actions = { { type = "heal", subtype = "temp", clauses = { { dice = { "d6", "d6" }, bonus = 0, stat = "intelligence" }, } }, }, },
	["chemicalmastery"] = {
		actions = { { type = "effect", sName = "Chemical Mastery; RESIST: acid; RESIST: poison; IMMUNE: poisoned", sTargeting = "self", }, },
		spell = { innate = {"greater restoration"} },

	},
	-- Artificer - Armorer
	["toolsofthetraidearmorer"] = { proficiency = { innate = {"heavy armor", "smith's tools"}, }, },
	["armorerspells"] = {
		spell = {
			level = {
				[3] = {"magic missile", "thunderwave"},
				[5] = {"mirror image", "shatter"},
				[9] = {"hypnotic pattern", "lightning bolt"},
				[13] = {"fire shield", "greater invisibility"},
				[17] = {"passwall", "wall of force"},
			},
		},
	},
	["armormodel"] = {
		multiple_actions = {
			["Armor Model (Thunder Gauntlets)"] = { actions = { { type = "damage", clauses = { { dice = { "d8", }, modifier = 0, dmgtype = "thunder", }, } }, }, },
			["Armor Model (Defensive Field)"] = { actions = { { type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = { }, bonus = 0, stat = "artificer" }, } }, }, },
			["Armor Model (Lightning Launcher)"] = {
				actions = {
					{ type = "attack", range = "R", },
					{ type = "damage", clauses = { { dice = { "d6", }, modifier = 0, dmgtype = "lightning", }, } },
				},
			},
			["Dampening Field"] = { actions = { { type = "effect", sName = "Dampening Field; ADVSAV: stealth", sTargeting = "self", }, }, },
		},
	},
	-- Artificer - Artillerist
	["toolsofthetraideartillerist"] = { proficiency = { innate = {"woodcarver's tools"}, }, },
	["fortifiedposition"] = { actions = { { type = "effect", sName = "Fortified Position; Allies within 10 ft. of Eldritch Cannon have 1/2 cover", sTargeting = "self", } }, },
	["artilleristspells"] = {
		spell = {
			level = {
				[3] = {"shield", "thunderwave"},
				[5] = {"scorching ray", "shatter"},
				[9] = {"fireball", "wind wall"},
				[13] = {"ice storm", "wall of fire"},
				[17] = {"cone of cold", "wall of force"},
			},
		},
	},
	["eldritchcannon"] = { actions = { { type = "heal", clauses = { { dice = { "d6", "d6" }, bonus = 0, }, } }, }, },
	["arcanefirearm"] = { actions = { { type = "effect", sName = "Arcane Firearm; DMG: 1d8", sTargeting = "self",  sApply = "roll" }, }, },
	["explosivecannon"] = {
		actions = {
			{ type = "damage", clauses = { { dice = { "d8", "d8", "d8" }, modifier = 0, dmgtype = "force", }, } },
			{ type = "powersave", save = "dexterity", onmissdamage = "half" },
		},
	},
	-- Artificer - Battle Smith
	["toolproficiencybattlesmith"] = { proficiency = { innate = {"smith's tools"}, }, },
	["battlesmithspells"] = {
		spell = {
			level = {
				[3] = {"heroism", "shield"},
				[5] = {"branding smite", "warding bond"},
				[9] = {"aura of vitality", "conjure barrage"},
				[13] = {"aura of purity", "fire shield"},
				[17] = {"banishing smite", "mass cure wounds"},
			},
		},
	},
	["improveddefender"] = {
		actions = {
			{ type = "effect", sName = "Steel Defender; AC: 2", },
			{ type = "damage", clauses = { { dice = { "d4" }, modifier = 0, dmgtype = "force", stat = "intelligence"  }, } },
		},
	},
	["battleready"] = { proficiency = { innate = {"martial weapons"}, }, },
	["arcanejolt"] = {
		actions = {
			{ type = "effect", sName = "Arcane Jolt; DMG: 2d6 force", sTargeting = "self", sApply = "roll", },
			{ type = "heal", clauses = { { dice = { "d6", "d6" }, bonus = 0, }, }, },
		},
	},
	-- Barbarian
	["rage"] = { actions = { { type = "effect", sName = "Rage; ADVCHK: strength; ADVSAV: strength; DMG: 2, melee; RESIST: bludgeoning, piercing, slashing", sTargeting = "self", nDuration = 1, sUnits = "minute" }, }, prepared = 2, },
	["recklessattack"] = { actions = { { type = "effect", sName = "Reckless Attack; ADVATK: melee; GRANTADVATK", sTargeting = "self", nDuration = 1,  }, }, },
	["feralinstinct"] = { actions = { { type = "effect", sName = "Feral Instinct; ADVINIT; Can't be surprised but must enter rage", sTargeting = "self" }, }, },
	["relentlessrage"] = { actions = { { type = "powersave", save = "constitution", savemod = 10, }, }, usesperiod = "enc", },
	["retaliation"] = { actions = { { type = "effect", sName = "Retaliation", sTargeting = "self", }, }, },
	["brutalcritical"] = { actions = { { type = "effect", sName = "Brutal Critical; DMG: 3d8, melee, critical", sTargeting = "self", } }, },
	["dangersense"] = { actions = { { type = "effect", sName = "Danger Sense; ADVSAV: dexterity", sTargeting = "self", sApply = "action" } }, },
	["frenzy"] = { actions = { { type = "effect", sName = "Frenzy; Extra bonus action attack and suffer exhaustion after rage", sTargeting = "self", }, }, },
	-- Barbarian - Path of the Ancestral Guardian
	["ancestralprotectors"] = {
		actions = {
			{ type = "effect", sName = "Ancestral Protectors; GRANTADVATK", sTargeting = "self", nDuration = 1 },
			{ type = "effect", sName = "Ancestral Protectors; DISATK", nDuration = 1 },
			{ type = "effect", sName = "Ancestral Protectors; RESIST: all", sApply = "roll" },
		},
	},
	["consultthespirits"] = { actions = {}, prepared = 1, spell = { innate = { "augury", "clairvoyance" }, }, },
	["vengefulancestors"] = { actions = { { type = "damage", clauses = { { dice = { }, modifier = 1, dmgtype = "force", }, } }, }, },
	-- Barbarian - Path of the Battlerager
	["battleragerarmor"] = {
		actions = {
			{ type = "attack", range = "M", },
			{ type = "damage", clauses = { { dice = { "d4", }, modifier = 0, dmgtype = "piercing", stat = "strength" }, } },
			{ type = "damage", clauses = { { dice = {}, modifier = 3, dmgtype = "piercing", }, } },
		},
	},
	["battleragercharge"] = { actions = { { type = "effect", sName = "Battlerager Charge; Bonus action dash while raging", sTargeting = "self", }, }, },
	["recklessabandon"] = { actions = { { type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = { }, bonus = 0, stat = "constitution" }, } }, }, },
	["spikedretribution"] = { actions = { { type = "damage", clauses = { { dice = { }, modifier = 3, dmgtype = "piercing", }, } }, }, },
	-- Barbarian - Path of the Beast
	["formofthebeast"] = {
		["multiple_actions"] = {
			["Form of the Beast (Bite)"] = {
				actions = {
					{ type = "attack", range = "M", },
					{ type = "damage", clauses = { { dice = { "d8", }, modifier = 0, dmgtype = "piercing", stat = "strength" }, } },
					{ type = "heal", sTargeting = "self", clauses = { { dice = { }, bonus = 0, stat = "prf" }, } },
				},
			},
			["Form of the Beast (Claws)"] = {
				actions = {
					{ type = "attack", range = "M", },
					{ type = "damage", clauses = { { dice = { "d6", }, modifier = 0, dmgtype = "slashing", stat = "strength" }, } },
				},
			},
			["Form of the Beast (Tail)"] = {
				actions = {
					{ type = "attack", range = "M", },
					{ type = "damage", clauses = { { dice = { "d8", }, modifier = 0, dmgtype = "piercing", stat = "strength" }, } },
					{ type = "effect", sName = "AC: 1d8", sTargeting = "self", sApply = "single" },
				},
			},
		},
	},
	["infectiousfury"] = {
		actions = {
			{ type = "powersave", save = "wisdom", savestat = "constitution", },
			{ type = "damage", clauses = { { dice = { "d12", "d12" }, modifier = 0, dmgtype = "psychic", }, } },
		},
	},
	["callthehunt"] = {
	   actions = {
			{ type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = { }, bonus = 5, }, } },
			{ type = "effect", sName = "DMG: 1d6", },
	   },
	},
	-- Barbarian - Path of the Berserker
	["mindlessrage"] = { actions = { { type = "effect", sName = "Mindless Rage; IMMUNE: frightened, charmed", sTargeting = "self", }, }, },
	["intimidatingpresence"] = {
		actions = {
			{ type = "powersave", save = "wisdom", savemod = 0, savestat = "charisma", },
			{ type = "effect", sName = "Intimidating Presence; Frightened", nDuration = 1 },
		},
	},
	-- Barbarian - Path of the Storm Herald
	["stormaura"] = {
		actions = {
			{ type = "damage", clauses = { { dice = { }, modifier = 2, dmgtype = "fire", }, } },
			{ type = "powersave", save = "dexterity", onmissdamage = "half" },
			{ type = "damage", clauses = { { dice = { "d6" }, modifier = 0, dmgtype = "lightning", }, } },
			{ type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = { }, bonus = 2 }, } },
		},
	},
	["stormsoul"] = {
		multiple_actions = {
			["Storm Soul (Desert)"] = { actions = { { type = "effect", sName = "Storm Soul: Desert; RESIST: fire; Special fire powers", sTargeting = "self", nDuration = 1, sUnits = "minute" }, }, },
			["Storm Soul (Sea)"] = { actions = { { type = "effect", sName = "Storm Soul: Sea; RESIST: lightning; Breathe underwater; Swim Speed 30'", sTargeting = "self", nDuration = 1, sUnits = "minute" }, }, },
			["Storm Soul (Tundra)"] = { actions = { { type = "effect", sName = "Storm Soul: Tundra; RESIST: cold; Special water powers", sTargeting = "self", nDuration = 1, sUnits = "minute" }, }, },
		},
	},
	["shieldingstorm"] = {
		actions = {
			{ type = "effect", sName = "Shielding Storm; RESIST: fire", },
			{ type = "effect", sName = "Shielding Storm; RESIST: lightning", },
			{ type = "effect", sName = "Shielding Storm; RESIST: cold", },
		},
	},
	["ragingstorm"] = {
		actions = {
			{ type = "powersave", save = "dexterity" },
			{ type = "effect", sName = "Raging Storm; Prone" },
			{ type = "damage", clauses = { { dice = {}, modifier = 0, dmgtype = "fire", stat = "barbarian" }, }, },
			{ type = "powersave", save = "strength" },
			{ type = "effect", sName = "Raging Storm; Speed reduced to zero", nDuration = 1 },
		},
	},
	-- Barbarian - Path of the Totem Warrior
	["aspectofthebeast"] = {
		multiple_actions = {
			["Aspect of the Beast (Bear)"] = { actions = { { type = "effect", sName = "Aspect of the Beast (Bear); ADVCHK: strength", sTargeting = "self" }, }, },
			["Aspect of the Beast (Eagle)"] = { actions = { { type = "effect", sName = "Aspect of the Beast (Eagle); Special sight", sTargeting = "self" }, }, },
			["Aspect of the Beast (Wolf)"] = { actions = { { type = "effect", sName = "Aspect of the Beast (Wolf); Special tracking and movement", sTargeting = "self" }, }, },
		},
	},
	["spiritseeker"] = { spell = { innate = { "beast sense", "speak with animals" }, }, },
	["totemspirit"] = {
		multiple_actions = {
			["Totem Spirit (Bear)"] = { actions = { { type = "effect", sName = "Totem Spirit (Bear); RESIST: all, !psychic", sTargeting = "self", nDuration = 1, sUnits = "minute" }, }, },
			["Totem Spirit (Eagle)"] = { actions = { { type = "effect", sName = "Totem Spirit (Eagle); Opportunity attacks are at disadvantage and bonus action dash", sTargeting = "self" }, }, },
			["Totem Spirit (Wolf)"] = { actions = { { type = "effect", sName = "Totem Spirit (Wolf); ADVATK: melee", sApply = "roll" }, }, },
		},
	},
	["totemicattunement"] = {
		multiple_actions = {
			["Totemic Attunement (Bear)"] = {
				actions = {
					 { type = "effect", sName = "Totemic Attunement (Bear); DISATK: melee", sApply = "roll", },
					 { type = "effect", sName = "Totemic Attunement (Bear); GRANTADVATK: melee", sTargeting = "self", sApply = "roll", },
				},
			},
			["Totemic Attunement (Eagle)"] = { actions = { { type = "effect", sName = "Totemic Attunement (Eagle); Fly speed", sTargeting = "self", }, }, },
			["Totemic Attunement (Wolf)"] = { actions = { { type = "effect", sName = "Totemic Attunement (Wolf); Prone", }, }, },
		},
	},
	-- Barbarian - Path of the Zealot
	["divinefury"] = {
		actions = {
			{ type = "effect", sName = "Divine Fury; DMG: [HLVL] necrotic; DMG: 1d6 necrotic", sTargeting = "self", sApply = "roll" },
			{ type = "effect", sName = "Divine Fury; DMG: [HLVL] radiant; DMG: 1d6 radiant", sTargeting = "self", sApply = "roll" },
		},
	},
	["zealouspresence"] = { actions = { { type = "effect", sName = "Zealous Presence; ADVATK;ADVSAV", nDuration = 1 }, }, prepared = 1, },
	-- Bard
	["bardicinspiration"] = { actions = { { type = "effect", sName = "Bardic Inspiration (d6) used for ability check, attack roll, or saving throw", nDuration = 10, sUnits = "minute" }, }, },
	["countercharm"] = { actions = { { type = "effect", sName = "Countercharm; Advantage on saving throws vs. Frightened or Charmed", sTargeting = "self", nDuration = 1 }, }, },
	["jackofalltrades"] = {
		actions = {
			{ type = "effect", sName = "Jack of all Trades; INIT: [HPRF]", sTargeting = "self", nDuration = 1, sApply = "roll" },
			{ type = "effect", sName = "Jack of all Trades; CHECK: [HPRF], all", sTargeting = "self", sApply = "roll" },
		},
	},
	["songofrest"] = { actions = { { type = "heal", clauses = { { dice = { "d6" }, bonus = 0 }, } }, }, },
	-- Bard - College of Creation
	-- Bard - College of Eloquence
	-- Bard - College of Glamour
	["mantleofinspiration"] = { actions = { { type = "heal", subtype = "temp", clauses = { { dice = {}, bonus = 5, }, } }, }, },
	["enthrallingperformance"] = {
		actions = {
			{ type = "powersave", save = "wisdom" },
			{ type = "effect", sName = "Enthralling Performance; Charmed", nDuration = 1, sUnits = "hour" },
		},
		prepared = 1,
		usesperiod = "enc",
	},
	["mantleofmajesty"] = { actions = { { type = "effect", sName = "Mantle of Majesty", sTargeting = "self", nDuration = 1, sUnits = "minute" }, }, prepared = 1 },
	["unbreakablemajesty"] = {
		actions = {
			{ type = "powersave", save = "charisma" },
			{ type = "effect", sName = "Unbreakable Majesty", sTargeting = "self", nDuration = 1, sUnits = "minute", },
			{ type = "effect", sName = "Unbreakable Majesty ; DISSAV", sApply = "action" },
		},
		prepared = 1,
		usesperiod = "enc",
	},
	-- Bard - College of Lore
	["bonusproficiencieslore"] = { skill = { choice = 3, choice_skill = {"any"}, }, },
	["additionalmagicalsecrets"] = { spell = { choice = 2, choice_spell = {"any"}, } },
	["peerlessskill"] = {},
	-- Bard - College of Spirits
	["guidingwhispers"] = { spell = { innate = {"guidance"}, }, },
	-- Bard - College of Swords
	["bonusproficienciesloreswords"] = { proficiency = { innate = {"medium armor", "scimitar"}, }, },
	["fightingstyle"] = {
		["multiple_actions"] = {
			["Fighting Style (Protection)"] = { actions = { { type = "effect", sName = "Fighting Style (Protection); DISATK", sApply = "roll" }, }, },
			["Fighting Style (Archery)"] = { actions = { { type = "effect", sName = "Fighting Style (Archery); ATK: 2,ranged", sTargeting = "self", }, }, },
			["Fighting Style (Dueling)"] = { actions = { { type = "effect", sName = "Fighting Style (Dueling); DMG: 2, melee", sTargeting = "self", }, }, },
		},
	},
	["bladeflourish"] = {
		multiple_actions = {
			["Blade Flourish (Defensive)"] = {
				actions = {
					{ type = "effect", sName = "Blade Flourish (Defensive Flourish); DMG: 1", sTargeting = "self", sApply = "roll" },
					{ type = "effect", sName = "Blade Flourish (Defensive Flourish); AC: 1", sTargeting = "self", nDuration = 1, },
				},
			},
			["Blade Flourish (Slashing)"] = { actions = { { type = "effect", sName = "Blade Flourish (Slashing Flourish); DMG: 1", sTargeting = "self", sApply = "roll" }, }, },
			["Blade Flourish (Mobile)"] = { actions = { { type = "effect", sName = "Blade Flourish (Mobile Flourish); DMG: 1", sTargeting = "self", sApply = "roll" }, }, },
		},
	},
	-- Bard - College of Valor
	["bonusproficienciesvalor"] = { proficiency = { innate = { "medium armor", "shields", "martial weapons" }, }, },
	["combatinspiration"] = { actions = { { type = "effect", sName = "Combat Inspiration; (d6) used for ability check, attack roll, saving throw, weapon damage, or AC", nDuration = 10, sUnits = "minute" }, }, },
	-- Bard - College of Whispers
	["psychicblades"] = { actions = { { type = "effect", sName = "Psychic Blades; DMG: 2d6 psychic", sTargeting = "self", sApply = "roll" }, }, },
	["wordsofterror"] = {
		actions = {
			{ type = "powersave", save = "wisdom", },
			{ type = "effect", sName = "Frightened", nDuration = 1, sUnits = "hour", },
		},
	},
	["mantleofwhispers"] = {
		actions = {
			{ type = "effect", sName = "Mantle of Whispers; SKILL: 5 deception", sTargeting = "self", nDuration = 1, sUnits = "hour", },
		},
		prepared = 1,
		usesperiod = "enc",
	},
	["shadowlore"] = {
		actions = {
			{ type = "powersave", save = "wisdom" },
			{ type = "effect", sName = "Shadow Lore; Charmed", nDuration = 8, sUnits = "hour", },
		},
		prepared = 1,
	},
	-- Cleric
	["channeldivinity"] = {
		["multiple_actions"] = {
			["Channel Divinity (Turn Undead)"] = {
				actions = {
					{ type = "powersave", save = "wisdom", },
					{ type = "effect", sName = "Channel Divinity (Turn Undead); Turned", nDuration = 1, sUnits = "minute", },
				},
				prepared = 1,
			},
			["Channel Divinity (Arcane Abjuration)"] = { actions = { { type = "effect", sName = "Channel Divinity (Arcane Abjuration); Banished", nDuration = 1, sUnits = "minute", }, }, prepared = 1, },
			["Channel Divinity (Destructive Wrath)"] = { actions = {}, prepared = 1 },
			["Channel Divinity (Touch of Death)"] = {
				actions = {
					{ type = "damage", clauses = { { dice = { }, modifier = 5, dmgtype = "necrotic", stat = "cleric" }, } },
					{ type = "effect", sName = "Channel Divinity (Touch of Death); DMG: 5 [2LVL] necrotic", sTargeting = "self", sApply = "action", },
				},
				prepared = 1,
			},
			["Channel Divinity (Path to the Grave)"] = { actions = { { type = "effect", sName = "Channel Divinity (Path to the Grave); VULN: all", sApply = "action" }, }, },
			["Channel Divinity (Knowledge of the Ages)"] = { actions = { { type = "effect", sName = "Channel Divinity (Knowledge of the Ages); SKILL: [PRF]", sTargeting = "self", nDuration = 10, sUnits = "minute" }, }, prepared = 1, },
			["Channel Divinity (Read Thoughts)"] = {
				actions = {
					{ type = "powersave", save = "wisdom", },
					{ type = "effect", sName = "Channel Divinity (Read Thoughts)", nDuration = 1, sUnits = "minute" },
				},
				prepared = 1,
			},
			["Channel Divinity (Preserve Life)"] = { actions = { { type = "heal", clauses = { { dice = { }, bonus = 0, stat = "cleric" }, }, }, }, prepared = 1 },
			["Channel Divinity (Radiance of the Dawn)"] = {
				actions = {
					{ type = "powersave", save = "constitution", onmissdamage = "half" },
					{ type = "damage", clauses = { { dice = { "d10", "d10" }, modifier = 0, dmgtype = "radiant", stat = "cleric" }, } },
				},
				prepared = 1,
			},
			["Channel Divinity (Charm Animals and Plants)"] = {
				actions = {
					{ type = "effect", sName = "Channel Divinity (Charm Animals And Plants); Charmed", },
					{ type = "powersave", save = "wisdom", },
				},
				prepared = 1,
			},
			["Channel Divinity (Balm of Peace)"] = { actions = { { type = "heal", clauses = { { dice = { "d6", "d6" }, bonus = 0, stat = "wisdom" }, } }, }, },
			["Channel Divinity (Invoke Duplicity)"] = {
				actions = {
					{ type = "effect", sName = "Channel Divinity (Invoke Duplicity)", sTargeting = "self", nDuration = 1, sUnits = "minute" },
					{ type = "effect", sName = "Channel Divinity (Invoke Duplicity); ADVATK", sApply = "roll" },
				},
				prepared = 1,
			},
			["Channel Divinity (Cloak of Shadows)"] = { actions = { { type = "effect", sName = "Channel Divinity (Cloak of Shadows); Invisible", sTargeting = "self", nDuration = 1, }, }, prepared = 1, },
			["Channel Divinity (Twilight Sanctuary)"] = {
				actions = {
					{ type = "heal", subtype = "temp", clauses = { { dice = { "d6" }, bonus = 0, stat = "cleric" }, } },
					{ type = "effect", sName = "Channel Divinity (Twilight Sanctuary); Charmed", },
					{ type = "effect", sName = "Channel Divinity (Twilight Sanctuary); Frightened", },
				},
			},
			["Channel Divinity (Guided Strike)"] = { actions = { { type = "effect", sName = "Channel Divinity (Guided Strike); ATK: 10", sTargeting = "self", sApply = "roll" }, }, prepared = 1, },
			["Channel Divinity (War God's Blessing)"] = { actions = { { type = "effect", sName = "Channel Divinity (War God's Blessing); ATK: 10", sApply = "roll" }, }, prepared = 1, },
			["Channel Divinity (Control Undead)"] = {
				actions = {
					{ type = "powersave", save = "wisdom", },
					{ type = "effect", sName = "Channel Divinity (Control Undead)", nDuration = 24, sUnits = "hour", },
				},
			},
			["Channel Divinity (Dreadful Aspect)"] = {
				actions = {
					{ type = "powersave", save = "wisdom", },
					{ type = "effect", sName = "Channel Divinity (Dreadful Aspect); Frightened", nDuration = 1, sUnits = "minute", },
				},
			},
			["Channel Divinity (Touch of Death)"] = { actions = { { type = "effect", sName = "Channel Divinity (Touch of Death); DMG: 5 [2LVL] necrotic", sTargeting = "self", sApply = "action", }, }, },
			["Channel Divinity (Abjure Enemy)"] = {
				actions = {
					{ type = "effect", sName = "Channel Divinity (Abjure Enemy); IF: TYPE (fiend,undead); DISSAV: wisdom", nDuration = 1, sApply = "roll", },
					{ type = "powersave", save = "wisdom", },
					{ type = "effect", sName = "Channel Divinity (Abjure Enemy); Frightened", nDuration = 1, },
					{ type = "effect", sName = "Channel Divinity (Abjure Enemy); Speed halved", nDuration = 1, },
				},
			},
			["Channel Divinity (Nature's Wrath)"] = {
				actions = {
					{ type = "effect", sName = "Channel Divinity (Nature's Wrath); Restrained", },
					{ type = "powersave", save = "dexterity", },
					{ type = "powersave", save = "strength", },
				},
			},
			["Channel Divinity (Sacred Weapon)"] = { actions = { { type = "effect", sName = "Channel Divinity (Sacred Weapon); ATK: [CHA]; DMGTYPE: magic", sTargeting = "self", nDuration = 1, sUnits = "minute", }, }, },
			["Channel Divinity (Turn of the Faithless)"] = {
				actions = {
					{ type = "powersave", save = "wisdom", },
					{ type = "effect", sName = "Channel Divinity (Turn the Faithless); Turned", nDuration = 1, sUnits = "minute", },
				},
			},
			["Channel Divinity (Turn of the Unholy)"] = {
				actions = {
					{ type = "powersave", save = "wisdom", },
					{ type = "effect", sName = "Channel Divinity (Turn the Unholy); Turned", nDuration = 1, sUnits = "minute", },
				},
			},
			["Channel Divinity (Turn the Tide)"] = { actions = { { type = "heal", clauses = { { dice = { "d6" }, bonus = 0, stat = "charisma" }, } }, }, },
			["Channel Divinity (Vow of Enmity)"] = { actions = { { type = "effect", sName = "Channel Divinity (Vow of Enmity); ADVATK", sTargeting = "self", nDuration = 1, sUnits = "minute", }, }, },
			["Channel Divinity (Order' s Demand)"] = { actions = { { type = "powersave", save = "wisdom", }, { type = "effect", sName = "Order's Demand; Charmed", }, }, },
			["Channel Divinity (Path of the Grave)"] = { actions = { { type = "effect", sName = "Channel Divinity (Path to the Grave); VULN: ; ADVATK", nDuration = 1, }, }, },
			["Channel Divinity (Conquering Presence)"] = {
				actions = {
					{ type = "powersave", save = "widsom", },
					{ type = "effect", sName = "Channel Divinity (Conquering Presense); Frightened", nDuration = 1, sUnits = "minute" },
				},
			},
			["Channel Divinity (Emissary of Peace)"] = { actions = { { type = "effect", sName = "Channel Divinity (Emissary of Peace); SKILL: 5 persuasion", sTargeting = "self", nDuration = 10, sUnits = "minute" }, }, },
			["Channel Divinity (Rebuke the Violent)"] = { actions = { { type = "powersave", save = "wisdom", onmissdamage = "half" }; }, },
		},
	},
	["divineintervention"] = { actions = {}, prepared = 1 },
	-- Cleric - Arcana Domain
	["domainspellsarcana"] = {
		spell = {
			level = {
				[1] = {"detect magic" , "magic missile"},
				[3] = {"magic weapon", "nystul's magic aura"},
				[5] = {"dispel magic", "magic circle"},
				[7] = {"arcane eye", "leomund's secret chest"},
				[9] = {"planar binding", "teleportation circle"},
			},
		},
	},
	["arcanainitiate"] = { skill = { innate = {"arcana"}, }, spell = { choice = 2, choice_spell = {"any"}, spelllist = {"wizard"}, }, },
	["arcanemastery"] = { spell = { choice = 4, choice_spell = {"any"}, spelllist = {"wizard"}, }, },
	-- Cleric - Death Domain
	["domainspellsdeathdomain"] = {
		spell = {
			level = {
				[1] = {"false life", "ray of sickness"},
				[3] = {"blindness/deafness", "ray of enfeeblement"},
				[5] = {"animate dead", "vampiric touch"},
				[7] = {"blight", "death ward"},
				[9] = {"antilife shell", "cloudkill"},
			},
		},
	},
	["bonusproficienciesdeath"] = { proficiency = { innate = { "martial weapons" }, }, },
	--["reaper"] = { spell = { choice = 1, spellschool = {"necromancy"}, spelllevel = { 0 }, }, },
	["inescapabledestruction"] = { actions = { { type = "effect", sName = "Inescapable Destruction; Channel Divinity and spells ignore necrotic resistance", sTargeting = "self", }, }, },
	["divinestrikedeath"] = { actions = { { type = "effect", name = "Divine Strike (Death); DMG: 1d8 necrotic", sTargeting = "self", sApply = "roll" }, }, },
	-- Cleric - Forge Domain
	["domainspellsforge"] = {
		spell = {
			level = {
				[1] = {"indentify", "searing smite"},
				[3] = {"heat metal", "magic weapon"},
				[5] = {"elemental weapon", "protection from enegery"},
				[7] = {"fabricate", "wall of fire"},
				[9] = {"animate objects", "creation"},
			},
		},
	},
	["bonusproficienciesforgedomain"] = { proficiency = { innate = { "heavy armor", "smith's tools" }, }, },
	["blessingoftheforge"] = {
		actions = {
			{ type = "effect", sName = "Blessing of the Forge (Weapon); ATK: 1; DMG: 1; DMGTYPE: magic", },
			{ type = "effect", sName = "Blessing of the Forge (Armor); AC: 1", },
		},
		prepared = 1,
	},
	["souloftheforge"] = { actions = { { type = "effect", sName = "Soul of the Forge; RESIST: fire; AC:1", sTargeting = "self", }, }, },
	["divinestrikeforge"] = { actions = { { type = "effect", sName = "DMG: 1d8 fire", sTargeting = "self", sApply = "roll" }, }, },
	["saintofforgeandfire"] = { actions = { { type = "effect", sName = "Saint of Forge; IMMUNE: fire; RESIST: bludgeoning, piercing, slashing, !magic", sTargeting = "self", }, }, },
	-- Cleric - Grave Domain
	["domainspellsgravedomain"] = {
		spell = {
			level = {
				[1] = { "bane", "false life" },
				[3] = { "gentle repose", "ray of enfeeblement" },
				[5] = { "revivify", "vampiric touch" },
				[7] = { "blight", "death ward" },
				[9] = { "antilife shell", "raise dead" },
			},
		},
	},
	["eyesofthegrave"] = { actions = {}, prepared = 1, },
	["sentinelatdeathsdoor"] = { actions = {}, prepared = 1, },
	["potentspellcasting"] = { actions = { { type = "effect", sName = "Potent Spellcasting; DMG: [WIS]", sTargeting = "self", sApply = "roll" }, }, },
	["keeperofsouls"] = { actions = { { type = "heal", clauses = { { dice = {}, bonus = 1, }, } }, }, },
	-- Cleric - Knowledge Domain
	["knowledgedomainspells"] = {
		spell = {
			level = {
				[1] = { "command", "indentify" },
				[3] = { "augury", "suggestion" },
				[5] = { "nondetection", "speak with dead" },
				[7] = { "arcane eye", "confusion" },
				[9] = { "legend lore", "scrying" },
			},
		},
	},
	["visionsofthepast"] = { actions = { { type = "effect", sName = "Visions of the Past", sTargeting = "self", nDuration = 1, sUnits = "minute", }, }, prepared = 1, usesperiod = "enc" },
	["blessingsofknowledge"] = { language = { choice = 2, choice_language = {"any"}, }, skill = { choice = 2, choice_skill = {"arcana", "history", "nature", "religion"}, prof = "double", }, },
	-- Cleric - Life Domain
	["domainspellslife"] = {
		spell = {
			level = {
				[1] = {"bless", "cure wounds"},
				[3] = {"lesser restoration", "spiritual weapon"},
				[5] = {"beacon of hope", "revivify"},
				[7] = {"death ward", "guardian of faith"},
				[9] = {"mass cure wounds", "raise dead"},
			},
		},
	},
	["bonusproficiencieslife"] = { proficiency = { innate = {"heavy armor"}, }, },
	["discipleoflife"] = { actions = { { type = "heal", clauses = { { dice = { }, bonus = 3, }, } }, }, },
	["blessedhealer"] = { actions = { { type = "heal", sTargeting = "self", clauses = { { dice = { }, bonus = 2, }, } }, }, },
	["divinestrikelife"] = { actions = { { type = "effect", sName = "Divine Strike (Life); DMG: 1d8 radiant", sTargeting = "self", sApply = "roll" }, }, },
	["supremeheal"] = { actions = { { type = "heal", clauses = { { dice = { }, bonus = 8, }, } }, }, },
	-- Cleric - Light Domain
	["domainspellslight"] = {
		spell = {
			level = {
				[1] = {"burning hands", "faerie fire"},
				[3] = {"flaming sphere", "scorching ray"},
				[5] = {"daylight", "fireball"},
				[7] = {"guardian of faith", "wall of fire"},
				[9] = {"flame strike", "scrying"},
			},
		},
	},
	["bonuscantriplightdomain"] = { spell = { innate = {"light"}, }, },
	["wardingflare"] = { actions = { { type = "effect", sName = "Warding Flare; DISATK", sApply = "roll" }, }, prepared = 1 },
	["coronaoflight"] = {
		actions = { 
			{ type = "effect", sName = "Corona of Light", nDuration = 1, sUnits = "minute", }, 
			{ type = "effect", sName = "Corona of Light; DISSAV: dexterity", }, 
		}, 
	},
	-- Cleric - Nature Domain
	["domainspellsnature"] = {
		spell = {
			level = {
				[1] = {"animal friendship", "speak with animals"},
				[3] = {"barkskin", "spike growth"},
				[5] = {"plant growth", "wind wall"},
				[7] = {"dominate beast", "grasping vine"},
				[9] = {"insect plague", "tree stride"},
			},
		},
	},
	["acolyteofnature"] = { spell = { choice = 1, choice_spell = {"any"}, spelllist = {"druid"}, spelllevel = 0, }, skill = { choice = 1, choice_skill = {"animal handling", "nature", "survival"}, }, },
	["bonusproficienciesnature"] = { proficiency = { innate = {"heavy armor"}, }, },
	["dampenelements"] = { actions = { { type = "effect", sName = "Dampen Elements; RESIST: acid,cold,fire,lightning,thunder", sApply = "action" }, }, },
	["divinestrikenature"] = { actions = { { type = "effect", sName = "DMG: 1d8 cold, fire, or lightning", sTargeting = "self", sApply = "roll" }, }, },
	-- Cleric - Order Domain
	["domainspellsorder"] = {
		spell = {
			level = {
				[1] = {"command", "heroism"},
				[3] = {"hold person", "zone of truth"},
				[5] = {"mass healing ward", "slow"},
				[7] = {"compulsion", "locate creature"},
				[9] = {"commune", "dominate person"},
			},
		},
	},
	["bonusproficienciesorder"] = { proficiency = { innate = {"heavy armor"}, }, skill = { choice = 1, choice_skill = {"intimidation", "persuasion"}, } },
	["embodimentofthelaw"] = { actions = {}, prepared = 1 },
	["orderswrath"] = {
		actions = {
			{ type = "damage", clauses = { { dice = { "d8", "d8" }, modifier = 0, dmgtype = "psychic", }, }, },
			{ type = "effect", sName = "Order's Wrath (Cursed)", nDuration = 1, },
		},
	},
	["divinestrikeorder"] = { actions = { { type = "effect", sName = "Divine Strike (Order); DMG: 1d8 psychic", sTargeting = "self", }, }, },
	-- Cleric - Peace Domain
	["domainspellspeace"] = {
		spell = {
			level = {
				[1] = {"heroism", "sanctuary"},
				[3] = {"aid", "warding bond"},
				[5] = {"beacon of hope", "sending"},
				[7] = {"aura of purity", "otiluke's resilient sphere"},
				[9] = {"restoration", "rary's telepathic bond"},
			},
		},
	},
	["implementofpeace"] = { skill = { choice = 1, choice_skill = {"insight", "performance", "persuasion"} }, },
	-- Cleric - Tempest Domain
	["domainspellstempest"] = {
		spell = {
			level = {
				[1] = {"fog cloud", "thunderwave"},
				[3] = {"gust of wind", "shatter"},
				[5] = {"call lightning", "sleet storm"},
				[7] = {"control water", "ice storm"},
				[9] = {"destructive wave", "insect plague"},
			},
		},
	},
	["bonusproficienciestempest"] = { proficiency = { innate = {"martial weapons", "heavy armor"}, }, },
	["stormborn"] = { actions = { { type = "effect", sName = "Stormborn; Fly walking speed", sTargeting = "self", }, }, },
	["wrathofthestorm"] = {
		actions = {
			{ type = "powersave", save = "dexterity", onmissdamage = "half" },
			{ type = "damage", clauses = { { dice = { "d8", "d8" }, modifier = 0, dmgtype = "lightning", }, } },
			{ type = "damage", clauses = { { dice = { "d8", "d8" }, modifier = 0, dmgtype = "thunder", }, } },
		},
		prepared = 1,
	},
	["divinestriketempest"] = { actions = { { type = "effect", sName = "DMG: 1d8 thunder", sTargeting = "self", }, }, },
	-- Cleric - Trickery Domain
	["domainspellstrickery"] = {
		spell = {
			level = {
				[1] = {"charm person", "disguise self"},
				[3] = {"mirror image", "pass without trace"},
				[5] = {"blink", "dispel magic"},
				[7] = {"dimension door", "polymorph"},
				[9] = {"dominate person", "modify memory"},
			},
		},
	},
	["blessingofthetrickster"] = { actions = { { type = "effect", sName = "Blessing of the Trickster; ADVSKILL: stealth", nDuration = 1, sUnits = "hour", }, }, },
	["divinestriketrickery"] = { actions = { { type = "effect", sName = "DMG: 1d8 poison", sTargeting = "self", }, }, },
	-- Cleric - Twilight Domain
	["domainspellstwilight"] = {
		spell = {
			level = {
				[1] = {"faerie fire", "sleep"},
				[3] = {"moonbeam", "see invisibility"},
				[5] = {"aura of vitality", "leomund's tiny hut"},
				[7] = {"aura of life", "greater invisibility"},
				[9] = {"circle of power", "mislead"},
			},
		},
	},
	["bonusproficienciestwilight"] = { proficiency = { innate = {"martial weapons", "heavy armor"}, }, },
	["vigilantblessing"] = { actions = { { type = "effect", sName = "Vigilant Blessing;ADVINIT", sApply = "roll" }, }, },
	["divinestriketwilight"] = { actions = { { type = "effect", sName = "DMG: 1d8 radiant", sTargeting = "self", sApply = "roll" }, }, },
	-- Cleric - War Domain
	["domainspellswar"] = {
		spell = {
			level = {
				[1] = {"divine favor", "shield of faith"},
				[3] = {"magic weapon", "spiritual weapon"},
				[5] = {"crusader's mantle", "spirit guardians"},
				[7] = {"freedom of movement", "stoneskin"},
				[9] = {"flame strike", "hold monster"},
			},
		},
	},
	["warpriest"] = { actions = {}, prepared = 1 },
	["bonusproficiencieswardomain"] = { proficiency = { innate = {"martial weapons", "heavy armor"}, }, },
	["divinestrikewar"] = { actions = { { type = "effect", sName = "DMG: 1d8", sTargeting = "self", sApply = "roll" }, }, },
	["avatarofbattle"] = { actions = { { type = "effect", sName = "Avatar of Battle; RESIST: bludgeoning,piercing,slashing,!magic", sTargeting = "self", }, }, },
	-- Druid
	["druidic"] = { language = { innate = {"druidic"}, }, },
	["wildshape"] = { actions = {}, prepared = 2, usesperiod = "enc", },
	-- Druid - Circle of Dreams
	["balmofthesummercourt"] = {
		actions = {
			{ type = "heal", clauses = { { dice = { "d6", }, bonus = 0, }, } },
			{ type = "heal", subtype = "temp", clauses = { { dice = { }, bonus = 1, }, } },
		},
		prepared = 1,
	},
	["hearthofmoonlightandshadow"] = { actions = { { type = "effect", sName = "Hearth of Moonlight and Shadow; SKILL: 5 perception,stealth", }, }, },
	["hiddenpaths"] = { actions = {}, prepared = 1, },
	["walkerindreams"] = { actions = {}, prepared = 1, spell = { innate = { "scrying", "teleportaion circle" }, }, prepared = 1, },
	-- Druid - Circle of Spores
	["circlespellsspores"] = {
		spell = {
			level = {
				[2] = {"chill touch"},
				[3] = {"blindness/deafness", "gentle repose"},
				[5] = {"animate dead", "gaseous form"},
				[7] = {"blight", "confusion"},
				[9] = {"cloudkill", "contagion" },
			},
		},
	},
	["fungalinfestation"] = { actions = {}, prepared = 1 },
	["haloofspores"] = {
		actions = {
			{ type = "powersave", save = "constitution", savestat = "spell", },
			{ type = "damage", clauses = { { dice = { "d4" }, modifier = 0, dmgtype = "necrotic", }, } },
		},
	},
	["symbioticentity"] = {
		actions = {
			{ type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = { }, bonus = 4 }, } },
			{ type = "effect", sName = "Symbiotic Entity; DMG: 1d6 necrotic", sTargeting = "self", nDuration = 10, sUnits = "minute", },
		},
	},
	["spreadingspores"] = { actions = { { type = "powersave", save = "constitution", savestat = "spell", }, }, },
	["fungalbody"] = { actions = { { type = "effect", sName = "Fungal Body; IMMUNE: blinded; IMMUNE: deafened; IMMUNE: frightened; IMMUNE: poisoned; IMMUNE: critical", sTargeting = "self", }, }, },
	-- Druid - Circle of Stars
	["starmap"] = { spell = { innate = { "guidance", "guiding bolt" } }, },
	["starryform"] = {
		["multiple_actions"] = {
			["Starry Form (Archer)"] = {
				actions = {
					{ type = "attack", range = "R", },
					{ type = "damage", clauses = { { dice = { "d8" }, modifier = 0, dmgtype = "radiant", stat = "wisdom" }, } },
				},
			},
			["Starry Form (Chalice)"] = { actions = { { type = "heal", sTargeting = "self", clauses = { { dice = { "d8" }, bonus = 0, stat = "wisdom" }, } }, }, },
		},
	},
	["cosmicomen"] = {
		["multiple_actions"] = {
			["Cosmic Omen (Weal (even))"] = { actions = {}, },
			["Cosmic Omen (Woe (odd))"] = { actions = {}, },
		},
	},
	["fullofstars"] = { actions = { { type = "effect", sName = "RESIST: bludgeoning, piercing, slashing", sTargeting = "self", }, }, },
	-- Druid - Circle of the Land
	["bonuscantripland"] = { spell = { choice = 1, choice_spell = {"any"}, spelllist = "druid", spelllevel = 0, }, },
	["landsstride"] = { actions = { { type = "effect", sName = "Land's Stride; IFT: TYPE(plant); ADVSAV:all", sTargeting = "self", sApply = "action" }, }, },
	["naturalrecovery"] = { actions = {}, prepared = 1 },
	["naturesward"] = {
		actions = {
			{ type = "effect", sName = "Nature's Ward; IMMUNE: poison; IMMUNE: poisoned; IFT:TYPE(elemental,fey); IMMUNE: charmed; IMMUNE: frightened", sTargeting = "self", },
			{ type = "effect", sName = "Nature's Ward; IMMUNE: disease", sTargeting = "self", },
		},
	},
	["naturessanctuary"] = { actions = { { type = "powersave", save = "wisdom", }, }, },
	-- Druid - Circle of the Moon
	["combatwildshape"] = { actions = { { type = "heal", sTargeting = "self", clauses = { { dice = { "d8" }, bonus = 0 }, } }, }, usesperiod = "enc", },
	["primalstrike"] = { actions = { { type = "effect", sName = "Primal Strike; DMGTYPE: magic", sTargeting = "self", }, }, },
	-- Druid - Circle of the Shepherd
	["spirittotem"] = {
		actions = {
			{ type = "heal", subtype = "temp", clauses = { { dice = { }, bonus = 5, stat = "druid" }, }, },
			{ type = "heal", clauses = { { dice = { }, bonus = 0, stat = "druid" }, }, },
			{ type = "effect", sName = "Spirit Totem (Bear); AVDCHK: strength; ADVSAV: strength", nDuration = 1, sUnits = "minute", },
			{ type = "effect", sName = "Spirit Totem (Hawk); ADVSKILL: perception", nDuration = 1, sUnits = "minute", },
			{ type = "effect", sName = "Spirit Totem (Hawk); ADVATK", sApply = "roll" },
			{ type = "effect", sName = "Spirit Totem (Unicorn); ADVCHK", sApply = "action", },
		},
		prepared = 1,
		usesperiod = "enc"
	},
	["mightysummoner"] = { actions = { { type = "effect", sName = "Mighty Summoner; DMGTYPE: magic", sTargeting = "self" }, }, },
	["guardianspirit"] = { actions = { { type = "heal", clauses = { { dice = { }, bonus = 0, stat = "druid" }, }, }, }, },
	["faithfulsummons"] = {
		spell = { innate = { "conjure animals" }, },
		actions = { { type = "effect", sName = "Faithful Summons", sTargeting = "self", nDuration = 1, sUnits = "hour" } },
		prepared = 1,
	},
	-- Druid - Circle of Wildfire
	-- Fighter
	["secondwind"] = { actions = { { type = "heal", sTargeting = "self", clauses = { { dice = { "d10" }, bonus = 0, stat = "fighter" }, }, }, }, prepared = 1, usesperiod = "enc", },
	["actionsurge"] = { actions = {}, prepared = 1, usesperiod = "enc", },
	["indomitable"] = { actions = {}, prepared = 1, },
	-- Fighter - Arcane Archer
	["arcanearcherlore"] = {
		skill = { choice = 1, choice_skill = {"arcana", "nature"}, },
		spell = { choice = 1, choice_spell = {"prestidigitation", "druidcraft"}, },
	},
	["arcaneshot"] = {
		["multiple_actions"] = {
			["Arcane Shot (Banishing Arrow)"] = {
				actions = {
					{ type = "powersave", save = "charisma", },
					{ type = "effect", sName = "Arcane Shot (Banishing Arrow); Incapacitated", nDuration = 1, },
				},
			},
			["Arcane Shot (Beguiling Arrow)"] = {
				actions = {
					{ type = "effect", sName = "Arcane Shot (Beguiling Arrow); DMG: 2d6, psychic", sTargeting = "self", sApply = "roll" },
					{ type = "powersave", save = "wisdom", },
					{ type = "effect", sName = "Arcane Shot (Beguiling Arrow); Charmed", nDuration = 1 },
				},
			},
			["Arcane Shot (Bursting Arrow)"] = { actions = { { type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "force", }, }, }, }, },
			["Arcane Shot (Enfeebling Arrow)"] = {
				actions = {
					{ type = "effect", sName = "Arcane Shot (Enfeebling Arrow); DMG: 2d6, necrotic", sTargeting = "self", sApply = "roll" },
					{ type = "powersave", save = "constitution", },
					{ type = "effect", sName = "Arcane Shot (Enfeebling Arrow); Damage Halved", },
				},
			},
			["Arcane Shot (Grasping Arrow)"] = {
				actions = {
					{ type = "effect", sName = "Arcane Shot (Grasping Arrow); DMG: 2d6, poison", sTargeting = "self", sApply = "roll" },
					{ type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "slashing", }, } },
					{ type = "effect", sName = "Arcane Shot (Grasping Arrow); Takes damage on move", nDuration = 1, sUnits = "minute", },
				},
			},
			["Arcane Shot (Piercing Arrow)"] = {
				actions = {
					{ type = "powersave", save = "dexterity", onmissdamage = "half" },
					{ type = "effect", sName = "Arcane Shot (Piercing Arrow); DMG: 1d6, piercing", sTargeting = "self", sApply = "roll" },
				},
			},
			["Arcane Shot (Seeking Arrow)"] = {
				actions = {
					{ type = "powersave", save = "dexterity", onmissdamage = "half" },
					{ type = "effect", sName = "Arcane Shot (Seeking Arrow); DMG: 1d6, force", sTargeting = "self", sApply = "roll" },
				},
			},
			["Arcane Shot (Shadow Arrow)"] = {
				actions = {
					{ type = "effect", sName = "Arcane Shot (Shadow Arrow); DMG: 2d6, psychic", sTargeting = "self", sApply = "roll" },
					{ type = "powersave", save = "wisdom", },
					{ type = "effect", sName = "Arcane Shot (Shadow Arrow); Can't see beyond 5'", nDuration = 1, },
				},
			},
		},
	},
	["magicarrow"] = { actions = { { type = "effect", sName = "Magic Arrow; DMGTYPE: magic", sTargeting = "self", sApply = "roll" }, }, },
	-- Fighter - Battle Master
	["combatsuperiority"] = {
		["multiple_actions"] = {
			["Combat Superiority (Superiority Dice)"] = { actions = {}, prepared = 4 },
			["Combat Superiority (Commander's Strike)"] = { actions = { { type = "effect", sName = "Commander's Strike; DMG: 1d8", sApply = "roll" }, }, },
			["Combat Superiority (Disarming Strike)"] = {
				actions = {
					{ type = "effect", sName = "Disarming Strike; DMG: 1d8", sTargeting = "self", sApply = "action" },
					{ type = "powersave", save = "strength", },
					{ type = "effect", sName = "Disarming Strike; Disarmed", nDuration = 1, },
				},
			},
			["Combat Superiority (Distracting Strike)"] = {
				actions = {
					{ type = "effect", sName = "Distracting Strike; DMG: 1d8", sApply = "action" },
					{ type = "effect", sName = "Distracting Strike; GRANTADVATK", nDuration = 1, sApply = "action" },
				},
			},
			["Combat Superiority (Evasive Footwork)"] = { actions = { { type = "effect", sName = "Evasive Footwork; AC: #", sTargeting = "self" }, }, },
			["Combat Superiority (Feinting Attack)"] = {
				actions = {
					{ type = "effect", sName = "Feinting Attack; DMG: 1d8", sTargeting = "self", sApply = "roll" },
					{ type = "effect", sName = "Feinting Attack; ADVATK", sTargeting = "self", nDuration = 1, sApply = "action" },
				},
			},
			["Combat Superiority (Goading Attack)"] = {
				actions = {
					{ type = "effect", sName = "Goading Attack; DMG: 1d8", sTargeting = "self", sApply = "action" },
					{ type = "effect", sName = "Goading Attack; GRANTADVATK", sTargeting = "self", sApply = "action" },
					{ type = "powersave", save = "wisdom", },
					{ type = "effect", sName = "Goaded; DISATK", nDuration = 1 },
				},
			},
			["Combat Superiority (Lunging Attack)"] = { actions = { { type = "effect", sName = "Lunging Attack; DMG: 1d8", sTargeting = "self", sApply = "action" }, }, },
			["Combat Superiority (Maneuvering Attack)"] = { actions = { { type = "effect", sName = "Maneuvering Attack; DMG: 1d8", sTargeting = "self", sApply = "action" }, }, },
			["Combat Superiority (Menacing Attack)"] = {
				actions = {
					{ type = "powersave", save = "wisdom", },
					{ type = "effect", sName = "Menacing Attack; Frightened", nDuration = 1 },
					{ type = "effect", sName = "Menacing Attack; DMG: 1d8", sTargeting = "self", sApply = "action" },
				},
			},
			["Combat Superiority (Parry)"] = { actions = { { type = "heal", sTargeting = "self", clauses = { { dice = { "d8" }, bonus = 0, stat = "dexterity" }, } }, }, },
			["Combat Superiority (Precision Attack)"] = { actions = { { type = "effect", sName = "Precision Attack; ATK: 1d8", sTargeting = "self", sApply = "action" }, }, },
			["Combat Superiority (Pushing Attack)"] = {
				actions = {
					{ type = "powersave", save = "strength", },
					{ type = "effect", sName = "Pushing Attack; DMG: 1d8", sTargeting = "self", sApply = "action" },
				},
			},
			["Combat Superiority (Rally)"] = { actions = { { type = "heal", subtype = "temp", clauses = { { dice = { "d8" }, bonus = 0, stat = "charisma" }, } }, }, },
			["Combat Superiority (Riposte)"] = { actions = { { type = "effect", sName = "Riposte; DMG: 1d8", sTargeting = "self", nDuration = 1, sApply = "action" }, }, },
			["Combat Superiority (Sweeping Attack)"] = {
				actions = {
					{ type = "damage", clauses = { { dice = { "d8" }, modifier = 0, dmgtype = "slashing", }, } },
					{ type = "damage", clauses = { { dice = { "d8" }, modifier = 0, dmgtype = "piercing", }, } },
					{ type = "damage", clauses = { { dice = { "d8" }, modifier = 0, dmgtype = "bludgeoning", }, } },
				},
			},
			["Combat Superiority (Trip Attack)"] = {
				actions = {
					{ type = "powersave", save = "strength", },
					{ type = "effect", sName = "Trip Attack; Prone", },
					{ type = "effect", sName = "Trip Attack; DMG:1d8", sTargeting = "self", sApply = "action" },
				},
			},
		},
	},
	["studentofwar"] = { proficiency = { choice = 1, choice_prof = {"artisan's tools"}, }, },
	-- Fighter - Cavalier
	["bonusproficiencycavalier"] = {
		["multiple_choice"] = {
			skill = { choice = 1, choice_skill = {"animal handling", "history", "insight", "performance", "persuasion"}, },
			language = { choice = 1, choice_language = {"any"}, },
		},
	},
	["borntothesaddle"] = { actions = { { type = "effect", sName = "Born to the Saddle; ADVSAV", sTargeting = "self", sApply = "action" }, }, },
	["unwaveringmark"] = {
		actions = {
			{ type = "effect", sName = "Unwavering Mark", nDuration = 1, },
			{ type = "effect", sName = "Unwavering Mark; DISATK", sApply = "roll", },
			{ type = "damage", clauses = { { dice = {}, modifier = 0, dmgtype = "", stat = "fighter" }, }, },
		},
		prepared = 1,
	},
	["wardingmaneuver"] = {
		actions = {
			{ type = "effect", sName = "Warding Maneuver; AC: 1", sApply = "action" },
			{ type = "effect", sName = "Warding Maneuver; RESIST: all", sApply = "action" },
		},
		prepared = 1,
	},
	["holdtheline"] = {
		actions = {
			{ type = "effect", sName = "Hold the Line; Speed zero", },
		},
	},
	["ferociouscharger"] = {
		actions = {
			{ type = "powersave", save = "strength", savestat = "strength", },
			{ type = "effect", sName = "Ferocious Charger; Prone", },
		},
	},
	-- Fighter - Champion
	["remarkableathlete"] = {
		actions = {
			{ type = "effect", sName = "Remarkable Athlete; CHECK: [HPRF] dexterity, strength, constitution", sTargeting = "self", sApply = "action" },
			{ type = "effect", sName = "Remarkable Athlete; INIT: [HPRF]; [STR] ft added to running long jump", sTargeting = "self", },
		},
	},
	["survivor"] = { actions = { { type = "effect", sName = "survivor; IF:Bloodied; REGEN:5 [CON]", sTargeting = "self", }, }, },
	-- Fighter - Echo Knight
	["reclaimpotential"] = { actions = { { type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = { "d6", "d6" }, bonus = 0, stat = "constitution" }, } }, }, },
	-- Fighter - Eldritch Knight
	["eldritchstrike"] = { actions = { { type = "effect", sName = "Eldritch Strike; DISSAV: all", nDuration = 1 }, }, },
	-- Fighter - Psi Warrior
	-- Figther - Purple Dragon Knight
	["rallyingcry"] = { actions = { { type = "heal", sTargeting = "self", clauses = { { dice = { }, bonus = 0, stat = "fighter" }, }, }, }, },
	["royalenvoy"] = { actions = { { type = "effect", sName = "SKILL:[PRF], persuasion", sTargeting = "self", }, }, },
	-- Fighter - Rune Knight
	["bonusproficienciesruneknight"] = { proficiency = { innate = {"smith's tools"}, }, language = { innate = {"giant"}, }, },
	-- Fighter - Samurai
	["bonusproficiencysamurai"] = {
		skill = { choice = 1, choice_skill = {"history", "insight", "performance", "persuasion"}, },
		language = { choice = 1, choice_language = {"any"}, },
	},
	["fightingspirit"] = {
		actions = {
			{ type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = { }, bonus = 5, }, } },
			{ type = "effect", sName = "Fighting Spirit; ADVATK", sTargeting = "self", nDuration = 1, },
		},
		prepared = 3
	},
	["strengthbeforedeath"] = { actions = {}, prepared = 1 },
	["elegantcourtier"] = {
		actions = {
			{ type = "effect", sName = "Elegant Courtier; SKILL: [WIS] persuasion", sTargeting = "self", sApply = "action", },
			{ type = "effect", sName = "Elegant Courtier; SAVE: [PRF] wisdom", sTargeting = "self", },
			{ type = "effect", sName = "Elegant Courtier; SAVE: [PRF] intelligence", sTargeting = "self", },
			{ type = "effect", sName = "Elegant Courtier; SAVE: [PRF] charisma", sTargeting = "self", },
		},
	},
	["rapidstrike"] = { actions = { { type = "effect", sName = "ADVATK:", sTargeting = "self", sApply = "action" }, }, },
	-- Monk
	["martialarts"] = {
		actions = {
			{ type = "attack", range = "M", },
			{ type = "damage", clauses = { { dice = { "d4", }, modifier = 0, dmgtype = "bludgeoning", stat = "dexterity" }, } },
		},
	},
	["ki"] = {
		["multiple_actions"] = {
			["Ki Points"] = { actions = {}, prepared = 2, usesperiod = "enc" },
			["Ki (Flurry of Blows)"] = {
				actions = {
					{ type = "powersave", save = "dexterity", },
					{ type = "effect", sName = "Flurry of Blows;Prone", },
					{ type = "powersave", save = "strength", },
				},
			},
			["Ki (Patient Defense)"] = { actions = { { type = "effect", sName = "Patient Defense; Dodge", sTargeting = "self", nDuration = 1, }, }, },
			["Ki (Step of the Wind)"] = { actions = { { type = "effect", sName = "Step of the Wind; Jump doubled", sTargeting = "self", }, }, },
			--[["Radiant Sunbolt"] = {
				actions = {
					{ type = "attack", range = "R" },
					{ type = "damage", clauses = { { dice = { "d4" }, modifier = 0, dmgtype = "radiant", stat = "dexterity" }, } },
				},
			},--]]
		},
		prepared = 1
	},
	["deflectmissiles"] = {
		actions = {
			{ type = "attack", range = "R", },
			{ type = "heal", clauses = { { dice = { "d10" }, bonus = 0, stat = "dexterity" }, { dice = {}, bonus = 0, stat = "monk" } } },
		},
	},
	["slowfall"] = { actions = { { type = "heal", sTargeting = "self", clauses = { { dice = { }, bonus = 0, stat = "monk" }, } }, }, },
	["stunningstrike"] = {
		actions = {
			{ type = "powersave", save = "constitution", },
			{ type = "effect", sName = "Stunning Strike; Stunned", nDuration = 1, },
		},
	},
	["evasion"] = { actions = { { type = "effect", sName = "Evasion", sTargeting = "self", }, }, },
	["purityofbody"] = { actions = { { type = "effect", sName = "Purity of Body; Immunity to disease; IMMUNE: poison,poisoned", sTargeting = "self", }, }, },
	["diamondsoul"] = { actions = { { type = "effect", sName = "Diamond Soul; SAVE: [PRF]", sTargeting = "self", }, }, },
	["emptybody"] = { actions = { { type = "effect", sName = "Empty Body; Invisible; RESIST:all,!force", sTargeting = "self", nDuration = 1, sUnits = "minute", }, }, },
	-- Monk - Way of Mercy
	["implementsofmercy"] = { skill = { innate = {"insight", "medicine"}, }, proficiency = { innate = {"herbalism kit"}, }, },
	-- Monk - Way of Shadow
	["shadowarts"] = { spell = { innate = {"minor illusion"}, }, },
	["shadowstep"] = { actions = { { type = "effect", sName = "Shadow Step; ADVATK: melee", sTargeting = "self", nDuration = 1, sApply = "action" }, }, },
	["cloakofshadows"] = { actions = { { type = "effect", sName = "Cloak of Shadows; Invisible", sTargeting = "self", }, }, },
	-- Monk - Way of the Ascendant
	["draconicdisciple"] = {
		["multiple_actions"] = {},
		language = { innate = {"Draconic"}, },
	},
	-- Monk - Way of the Astral Self
	-- Monk - Way of the Drunken Master
	["bonusproficienciesdrunkenmaster"] = { skill = { innate = {"performance"}, }, proficiency = { innate = {"brewer's supplies"}, }, },
	["drunkardsluck"] = {
		actions = {
			{ type = "effect", sName = "ADVATK", sTargeting = "self", sApply = "action" },
			{ type = "effect", sName = "ADVCHK", sTargeting = "self", sApply = "action" },
			{ type = "effect", sName = "ADVSAV", sTargeting = "self", sApply = "action" },
		},
	},
	-- Monk - Way of the Four Elements
	["discipleoftheelements"] = {
		["multiple_actions"] = {
			["Disciple of the Elements (Breath of Winter)"] = {
				actions = {},
			},
			["Disciple of the Elements (Fangs of the Fire Snake)"] = { actions = { { type = "effect", sName = "Fangs of the Fire Snake; DMG: 1d10 fire", sTargeting = "self", sApply = "roll" }, }, },
			["Disciple of the Elements (Fist of Unbroken Air)"] = {
				actions = {
					{ type = "powersave", save = "strength", onmissdamage = "half" },
					{ type = "damage", clauses = { { dice = { "d10", "d10", "d10" }, modifier = 0, dmgtype = "bludgeoning", }, } },
					{ type = "effect", sName = "Fist of Unbroken Air; Prone", },
				},
			},
			["Disciple of the Elements (Water Whip)"] = {
				actions = {
					{ type = "powersave", save = "dexterity", onmissdamage = "half" },
					{ type = "damage", clauses = { { dice = { "d10", "d10", "d10" }, modifier = 0, dmgtype = "bludgeoning", }, } },
					{ type = "effect", sName = "Water Whip; Prone", },
				},
			},
		},
	},
	-- Monk - Way of the Kensei
	["pathofthekensei"] = {
		actions = {
			{ type = "effect", sName = "Path of the Kensei; AC: 2", sTargeting = "self", nDuration = 1, },
			{ type = "effect", sName = "Path of the Kensei; DMG: 1d4, ranged", sTargeting = "self", nDuration = 1 },
		},
		proficiency = { choice = 1, choice_prof = { "calligrapher's supplies", "painter's supplies" }, },
	},
	["onewiththeblade"] = {
		actions = {
			{ type = "effect", sName = "One with the Blade; DMGTYPE: magic", sTargeting = "self", },
			{ type = "effect", sName = "One with the Blade; DMG: 1d4", sTargeting = "self", sApply = "roll" },
		},
	},
	["sharpentheblade"] = {
		actions = {
			{ type = "effect", sName = "Sharpen the Blade One Point; ATK: 1; DMG: 1", sTargeting = "self", nDuration = 1, sUnits = "minute", },
			{ type = "effect", sName = "Sharpen the Blade Two Points; ATK: 2; DMG: 2", sTargeting = "self", nDuration = 1, sUnits = "minute", },
			{ type = "effect", sName = "Sharpen the Blade Three Points; ATK: 3; DMG: 3", sTargeting = "self", nDuration = 1, sUnits = "minute", },
		},
	},
	-- Monk - Way of the Long Death
	["touchofdeath"] = { actions = { { type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = { }, bonus = 0, stat = "wisdom" }, { dice = { }, bonus = 0, stat = "monk" }, }, }, }, },
	["hourofreaping"] = {
		actions = {
			{ type = "powersave", save = "wisdom", },
			{ type = "effect", sName = "Frightened", nDuration = 1, },
		},
	},
	["touchofthelongdeath"] = {
		actions = {
			{ type = "powersave", save = "constitution", onmissdamage = "half" },
			{ type = "damage", clauses = { { dice = { "d10", "d10" }, modifier = 0, dmgtype = "necrotic", }, } },
		},
	},
	-- Monk - Way of the Open Hand
	["openhandtechnique"] = {
		actions = {
			{ type = "powersave", save = "dexterity", },
			{ type = "effect", sName = "Open Hand Technique; Prone", },
			{ type = "powersave", save = "strength", },
			{ type = "effect", sName = "Open Hand Technique; Can't take reactions", nDuration = 1 },
		},
	},
	["wholenessofbody"] = { actions = { { type = "heal", sTargeting = "self", clauses = { { dice = { }, bonus = 0, stat = "monk" }, } }, }, prepared = 1 },
	["tranquility"] = {
		actions = {
			{ type = "powersave", save = "wisdom", savestat = "wisdom", },
			{ type = "effect", sName = "Tranquility", sTargeting = "self", },
		},
	},
	["quiveringpalm"] = {
		actions = {
			{ type = "powersave", save = "constitution", },
			{ type = "damage", clauses = { { dice = { "d10","d10","d10","d10","d10","d10","d10","d10","d10","d10" }, modifier = 0, dmgtype = "necrotic", }, } },
		},
	},
	-- Monk - Way of the Sun Soul
	["radiantsunbolt"] = {
		actions = {
			{ type = "attack", range = "R" },
			{ type = "damage", clauses = { { dice = { "d4" }, modifier = 0, dmgtype = "radiant", stat = "dexterity" }, } },
		},
	},
	["searingsunburst"] = { actions = { { type = "powersave", save = "constitution", }, { type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "radiant", }, } }, }, },
	["sunshield"] = { actions = { { type = "damage", clauses = { { dice = { }, modifier = 5, dmgtype = "radiant", stat = "wisdom" }, } }, }, },
	-- Paladin
	["layonhands"] = { actions = { { type = "heal", clauses = { { dice = { }, bonus = 5, }, } }, }, },
	["divinesmite"] = { actions = { { type = "effect", sName = "Divine Smite; DMG: 2d8 radiant; IFT: TYPE(fiend,undead); DMG:1d8 radiant", sTargeting = "self", sApply = "roll" }, }, },
	["divinesense"] = { actions = { { type = "effect", sName = "Divine Sense; Know the location of any celestial, fiend, or undead (also hallow spell) within 60'", sTargeting = "self", nDuration = 1, }, }, prepared = 1 },
	["divinehealth"] = { actions = { { type = "effect", sName = "Divine Health; Immune to disease", sTargeting = "self", }, }, },
	["auraofprotection"] = { actions = { { type = "effect", sName = "Aura of Protection; SAVE: [CHA]", sTargeting = "self" }, }, },
	["auraofcourage"] = { actions = { { type = "effect", sName = "Aura of Courage; IMMUNE: frightened", }, }, },
	["improveddivinesmite"] = { actions = { { type = "effect", sName = "Improved Divine Smite; DMG: 1d8 radiant,melee", sTargeting = "self", }, }, },
	["cleansingtouch"] = { actions = {}, prepared = 1 },
	-- Paladin - Oath of Conquest
	["conquestoathspells"] = {
		spell = {
			level = {
				[3] = {"armor of agathys", "command"},
				[5] = {"hold person", "spiritual weapon"},
				[9] = {"bestow curse", "fear"},
				[13] = {"dominate beast", "stoneskin"},
				[17] = {"cloudkill", "dominate person"},
			},
		},
	},
	["auraofconquest"] = { actions = { { type = "effect", sName = "Aura of Conquest; DMGO: [HLVL] psychic; Movement is zero", }, }, },
	["scornfulrebuke"] = { actions = { { type = "damage", clauses = { { dice = {}, modifier = 0, dmgtype = "psychic", stat = "charisma" }, }, }, }, },
	["invincibleconqueror"] = { actions = { { type = "effect", sName = "Invincible Conqueror; RESIST: all", sTargeting = "self", nDuration = 1, sUnits = "minute", }, }, },
	-- Paladin - Oath of Devotion
	["oathspellsdevotion"] = {
		spell = {
			level = {
				[3] = {"protection from evil and good", "sanctuary"},
				[5] = {"lesser restoration", "zone of truth"},
				[9] = {"beacon of hope", "dispel magic"},
				[13] = {"freedom of movement", "guardian of faith"},
				[17] = {"commune", "flame strike"},
			},
		},
	},
	["auraofdevotion"] = { actions = { { type = "effect", sName = "Aura of Devotion; IMMUNE: Charmed", }, }, },
	["purityofspirit"] = {
		actions = {
			{ type = "effect", sName = "IFT: TYPE(aberration,celestial,elemental,fey,fiend,undead);GRANTDISATK:", sTargeting = "self", },
			{ type = "effect", sName = "IFT: TYPE(aberration,celestial,elemental,fey,fiend,undead); IMMUNE: charmed, frightened", sTargeting = "self", },
		},
	},
	["holynimbus"] = { actions = { { type = "damage", clauses = { { dice = { }, modifier = 10, dmgtype = "radiant", }, }, }, }, prepared = 1, },
	-- Paladin - Oath of Glory
	-- Paladin - Oath of Redemption
	["protectivespirit"] = { actions = { { type = "effect", sName = "Protective Spirit; IF: Bloodied; REGEN: [HLVL]; IF: Bloodied; REGEN: 1d6", sTargeting = "self", }, }, },
	["emissaryofredemption"] = { actions = { { type = "effect", sName = "Emissary of Redemption; RESIST: all", sTargeting = "self", }, }, },
	-- Paladin - Oath of the Ancients
	["auraofwarding"] = { actions = { { type = "effect", sName = "Aura of Warding; RESIST: all", sTargeting = "self", }, }, },
	["undyingsentinel"] = { actions = { { type = "heal", clauses = { { dice = {}, bonus = 1, }, } }, }, prepared = 1, },
	["elderchampion"] = { actions = { { type = "effect", sName = "Elder Champion; REGEN: 10", sTargeting = "self", nDuration = 1, sUnits = "minute" }, }, },
	-- Paladin - Oath of the Crown
	["championchallenge"] = {
		actions = {
			{ type = "powersave", save = "wisdom", },
			{ type = "effect", sName = "Champion Challenge; Compelled to battle with and cannot move more than 30' from Paladin", },
		},
	},
	["unyieldingspirit"] = { actions = { { type = "effect", sName = "Unyielding Spirit; Advantages on saving throws against paralyzed and stunned", sTargeting = "self", }, }, },
	["exhaltedchampion"] = {
		actions = {
			{ type = "effect", sName = "Exhalted Champion; RESIST: bludgeoning,piercing,slashing,!magic", sTargeting = "self", nDuration = 1, sUnits = "hour", },
			{ type = "effect", sName = "Exhalted Champion; ADVDEATH; ADVSAV: wisdom", nDuration = 1, sUnits = "hour", },
		},
	},
	-- Paladin - Oath of the Watchers
	-- Paladin - Oath of Vengeance
	["relentlessavenger"] = { actions = { { type = "effect", sName = "Relentless Avenger; After hitting with an opportunity attack, move up to half your speed immediately, doesn't provoke opportunity attacks", sTargeting = "self", }, }, },
	["avengingangel"] = {
		actions = {
			{ type = "powersave", save = "wisdom", },
			{ type = "effect", sName = "Avenging Angel; Frightened; GRANTADVATK", nDuration = 1, sUnits = "minute", },
			{ type = "effect", sName = "Avenging Angel; Fly 60", sTargeting = "self", nDuration = 1, sUnits = "hour", },
		},
	},
	-- Paladin - Oathbreaker
	["auraofhate"] = { actions = { { type = "effect", sName = "Aura of Hate; DMG: [CHA]", }, }, },
	["supernaturalresistance"] = { actions = { { type = "effect", sName = "Supernatural Resistance; RESIST: bludgeoning,piercing,slashing,!magic", sTargeting = "self" }, }, },
	["dreadlord"] = {
		actions = {
			{ type = "damage", clauses = { { dice = { "d10", "d10", "d10", "d10" }, modifier = 0, dmgtype = "psychic", }, }, },
			{ type = "effect", sName = "Dread Lord (Aura of Gloom)", sTargeting = "self", nDuration = 1, sUnits = "minute", },
			{ type = "effect", sName = "Dread Lord (Aura of Gloom); GRANTDISATK", },
			{ type = "attack", range = "M", modifier = 1 },
			{ type = "damage", clauses = { { dice = { "d10", "d10", "d10" }, modifier = 0, dmgtype = "necrotic", stat = "charisma" }, }, },
		},
		prepared = 1,
	},
	-- Ranger
	["favoredenemy"] = {
		actions = {
			{ type = "effect", sName = "Favored Enemy; ADVSKILL: survival", sTargeting = "self", sApply = "action" },
			{ type = "effect", sName = "Favored Enemy; ADVCHK: intelligence", sTargeting = "self", sApply = "action" },
		},
	},
	["landsstride"] = { actions = { { type = "effect", sName = "Land's Stride; ADVSAV:all", sTargeting = "self", sApply = "action" }, }, },
	["hideinplainsight"] = { actions = { { type = "effect", sName = "Hide in Plain Sight; SKILL: 10, stealth", sTargeting = "self", sApply = "action" }, }, },
	["feralsenses"] = { actions = { { type = "effect", sName = "Feral Senses; IFT: invisible; ADVATK", sTargeting = "self", }, }, },
	["foeslayer"] = {
		actions = {
			{ type = "effect", sName = "Foe Slayer; ATK:[WIS]", sTargeting = "self", sApply = "action" },
			{ type = "effect", sName = "Foe Slayer; IFT: TYPE(giant,orc); DMG:[WIS]", sTargeting = "self", sApply = "action" },
		},
	},
	-- Ranger - Beast Master
	-- Ranger - Drakewarden
	-- Ranger - Fey Wanderer
	-- Ranger - Gloom Stalker
	["dreadambusher"] = {
		actions = {
			{ type = "effect", sName = "Dread Ambusher; DMG: 1d8", sTargeting = "self", sApply = "roll" },
			{ type = "effect", sName = "Dread Ambusher; INIT: [WIS]", sTargeting = "self", },
		},
		prepared = 1,
	},
	["ironmind"] = {
		actions = {
			{ type = "effect", sName = "Iron Mind; SAVE: [PRF] wisdom", sTargeting = "self", },
			{ type = "effect", sName = "Iron Mind; SAVE: [PRF] intelligence", sTargeting = "self", },
			{ type = "effect", sName = "Iron Mind; SAVE: [PRF] charisma", sTargeting = "self", },
		},
	},
	["shadowydodge"] = { actions = { { type = "effect", sName = "Shadowy Dodge; GRANTDISATK", sTargeting = "self", sApply = "action" }, }, },
	["stalkersflurry"] = { actions = { { type = "effect", sName = "Stalker's Flurry; Extra attack upon miss once per turn", sTargeting = "self", }, }, },
	["umbralsight"] = { actions = { { type = "effect", sName = "Umbral Sight; Invisible", sTargeting = "self", }, }, },
	-- Ranger - Horizon Walker
	["detectportal"] = { actions = {}, prepared = 1, },
	["etherealstep"] = { actions = {}, prepared = 1, usesperiod = "enc" },
	["planarwarrior"] = {
		actions = {
			{ type = "effect", sName = "Planar Warrior; DMGTYPE: force", sTargeting = "self", sApply = "roll" },
			{ type = "effect", sName = "Planar Warrior; DMG: 1d8 force", sTargeting = "self", sApply = "roll" },
		},
		prepared = 1,
	},
	["spectraldefense"] = { actions = { { type = "effect", sName = "Spectral Defense; RESIST: all", sTargeting = "self", sApply = "action" }, }, },
	-- Ranger - Hunter
	["huntersprey"] = {
		["multiple_actions"] = {
			["Hunter's Prey (Colossus Slayer)"] = { actions = { { type = "effect", sName = "Colossus Slayer; IFT: Wounded; DMG: 1d8", sTargeting = "self", sApply = "roll" }, }, },
			["Hunter's Prey (Giant Killer)"] = { actions = { { type = "effect", sName = "Giant Killer; Large(r) creature within 5 feet misses, can reaction attack", sTargeting = "self", sApply = "roll" }, }, },
			["Hunter's Prey (Horde Breaker)"] = { actions = { { type = "effect", sName = "Horde Breaker; Can attack additional foe adjacent to target once per turn", sTargeting = "self", }, }, },
		},
	},
	["defensivetactics"] = {
		["multiple_actions"] = {
			["Defensive Tactics (Escape the Horde)"] = { actions = { { type = "effect", sName = "Escape the Horde; GRANTDISATK: opportunity", sTargeting = "self", }, }, },
			["Defensive Tactics (Multiattack Defense)"] = { actions = { { type = "effect", sName = "Multiattack Defense; AC: 4", sTargeting = "self", nDuration = 1 }, }, },
			["Defensive Tactics (Steel Will)"] = { actions = { { type = "effect", sName = "Steel Will; Advantage on saving throws against frightened", sTargeting = "self", }, }, },
		},
	},
	["superiorhuntersdefense"] = {
		["multiple_actions"] = {
			["Superior Hunter's Defense (Evasion)"] = { actions = { { type = "effect", sName = "Superior Hunter's Defense (Evasion); Evasion", sTargeting = "self", }, }, },
			["Superior Hunter's Defense (Stand Against the Tide)"] = { actions = { { type = "effect", sName = "Superior Hunter's Defense (Stand Against the Tide); Creature misses with melee, can force that same attack against another creature", sTargeting = "self", }, }, },
			["Superior Hunter's Defense (Uncanny Dodge)"] = { actions = { { type = "effect", sName = "Superior Hunter's Defense (Uncanny Dodge); RESIST: all", sTargeting = "self", sApply = "action" }, }, },
		},
	},
	-- Ranger - Monster Slayer
	["hunterssense"] = { actions = {}, prepared = 1 },
	["magicusersnemesis"] = { actions = { { type = "powersave", save = "wisdom", }, }, prepared = 1 },
	["slayersprey"] = { actions = { { type = "effect", sName = "Slayer's Prey; DMG: 1d6", sTargeting = "self", sApply = "roll" }, }, },
	["supernaturaldefense"] = { actions = { { type = "effect", sName = "Supernatural Defense; SAVE: 1d6; CHECK: 1d6", sTargeting = "self", sApply = "action" }, }, },
	-- Ranger - Swarmkeeper
	-- Rogue
	["sneakattack"] = { actions = { { type = "effect", sName = "Sneak Attack; DMG: 1d6", sTargeting = "self", sApply = "roll" }, }, },
	["thievescant"] = { language = { innate = {"Thieves' Cant"}, } },
	["uncannydodge"] = { actions = { { type = "effect", sName = "Uncanny Dodge; RESIST: all", sTargeting = "self", sApply = "action" }, }, },
	["blindsense"] = { actions = { { type = "effect", sName = "Blindsense; Aware of hidden and invisible creature location within 10'", sTargeting = "self", sApply = "action" }, }, },
	["slipperymind"] = { actions = { { type = "effect", sName = "Slippery Mind; SAVE: [PRF] wisdom", sTargeting = "self" }, }, },
	["reliabletalent"] = { actions = { { type = "effect", sName = "Reliable Talent; Proficient ability checks roll at 10 minimum", sTargeting = "self", }, }, },
	["strokeofluck"] = { actions = {}, prepared = 1 },
	-- Rogue - Arcane Trickster
	["magicalambush"] = { actions = { { type = "effect", sName = "Magical Ambush; DISSAV: all", sApply = "roll" }, }, },
	["versatiletrickster"] = { actions = { { type = "effect", sName = "Versatile Trickster; ADVATK", sTargeting = "self", nDuration = 1 }, }, },
	["spellthief"] = {
		actions = {
			{ type = "effect", sName = "Spell Steal", sTargeting = "self", nDuration = 1, sUnits = "hour", },
			{ type = "powersave", save = "spell", savestat = "spell", },
		},
	},
	-- Rogue - Assassin
	["bonusproficienciesassassin"] = { proficiency = { innate = {"disguise kit", "poisoner's kit"}, }, },
	["assassinate"] = { actions = { { type = "effect", sName = "Assassinate; ADVATK", sTargeting = "self", sApply = "action" }, }, },
	["impostor"] = { actions = { { type = "effect", sName = "Impostor; ADVSKILL: deception", sTargeting = "self", sApply = "action" }, }, },
	["deathstrike"] = { actions = { { type = "powersave", save = "constitution", }, }, },
	-- Rogue - Inquisitive
	["unerringeye"] = { actions = {}, prepared = 1, },
	["steadyeye"] = { actions = { { type = "effect", sName = "Steady Eye; ADVCHK: perception,investigation", sTargeting = "self", sApply = "action" }, }, },
	["eyeforweakness"] = { actions = { { type = "effect", sName = "Eye for Weakness; DMG: 3d6", sTargeting = "self", sApply = "roll", }, }, },
	["insightfulfighting"] = { actions = { { type = "effect", sName = "Insightful Fighting", sTargeting = "self", nDuration = 1, sUnits = "minute", }, }, },
	-- Rogue - Mastermind
	["masterofintrigue"] = { proficiency = { choice = 1, choice_prof = {"disguise kit", "forgery kit", "gaming set"}, }, language = { choice = 1, choice_language = {"any"}, }, },
	["masteroftactics"] = { actions = { { type = "effect", sName = "Master of Tactics; ADVATK; ADVCHK", sTargeting = "self", sApply = "action" }, }, },
	-- Rogue - Phantom
	-- Rogue - Scout
	["survivalist"] = { actions = { { type = "effect", sName = "Survivalist; SKILL: [PRF] nature, survival", sTargeting = "self" }, }, },
	["ambushmaster"] = {
		actions = {
			{ type = "effect", sName = "Ambush Master; ADVINIT", sTargeting = "self" },
			{ type = "effect", sName = "Ambush Master; GRANTADVATK", nDuration = 1, },
		},
	},
	-- Rogue - Soulknife
	-- Rogue - Swashbuckler
	["rakishaudacity"] = { actions = { { type = "effect", sName = "Rakish Audacity; INIT: [CHA]", sTargeting = "self" }, }, },
	["panache"] = {
		actions = {
			{ type = "effect", sName = "Panache; Charmed", nDuration = 1, sUnits = "minute" },
			{ type = "effect", sName = "Panache; DISATK", nDuration = 1, sUnits = "minute" },
			{ type = "effect", sName = "Panache; GRANTADVATK", sTargeting = "self", nDuration = 1, sUnits = "minute" },
		},
	},
	["elegantmaneuver"] = { actions = { { type = "effect", sName = "Elegant Maneuver; ADVSKILL: acrobatics,athletics", sTargeting = "self", nDuration = 1 }, }, },
	["masterduelist"] = { actions = { { type = "effect", sName = "Master Duelist; ADVATK", sTargeting = "self", sApply = "action" }, }, prepared = 1, usesperiod = "enc", },
	-- Rogue - Thief
	["supremesneak"] = { actions = { { type = "effect", sName = "Supreme Sneak; ADVSKILL: stealth", sTargeting = "self", sApply = "action" }, }, },
	["secondstorywork"] = { actions = { { type = "effect", sName = "Second-Story Work; [DEX] ft added to running jump and climb at normal speed", sApply = "action" }, }, },
	-- Sorcerer
	["fontofmagic"] = { actions = {}, prepared = 2, },
	["metamagic"] = {
		["multiple_actions"] = {
			["Metamagic (Heightened Spell)"] = { actions = { { type = "effect", sName = "Heightened Spell; DISSAV: all", sApply = "action" }, }, },
		},
	},
	-- Sorcerer - Aberrant Mind
	-- Sorcerer - Clockwork Soul
	-- Sorcerer - Divine Soul
	["favoredbythegods"] = { actions = {}, prepared = 1, },
	["strengthofthegrave"] = { actions = {}, prepared = 1 },
	-- Sorcerer - Draconic Bloodline
	["elementalaffinity"] = {
		actions = {
			{ type = "effect", sName = "Elemental Affinity; RESIST: ", sTargeting = "self", nDuration = 1, sUnits = "hour" },
			{ type = "effect", sName = "Elemental Affinity; DMG: [CHA]", sTargeting = "self", nDuration = 1, sUnits = "hour" },
		},
	},
	["draconicpresence"] = {
		actions = {
			{ type = "powersave", save = "wisdom", },
			{ type = "effect", sName = "Draconic Presence; Charmed", nDuration = 1, sUnits = "minute" },
			{ type = "effect", sName = "Draconic Presence", sTargeting = "self", nDuration = 1, sUnits = "minute" },
			{ type = "effect", sName = "Draconic Presence; Frightened", nDuration = 1, sUnits = "minute" },
		},
	},
	["dragonwings"] = { actions = { { type = "effect", sName = "Dragon Wings; Fly #", sTargeting = "self", }, }, },
	-- Sorcerer - Shadow Magic
	["houndofillomen"] = {
		actions = {
			{ type = "damage", clauses = { { dice = {}, modifier = 5, dmgtype = "force", }, }, },
			{ type = "effect", sName = "Hound of Ill Omen", sTargeting = "self", nDuration = 5, sUnits = "minute" },
		},
	},
	["otherworldlywings"] = { actions = { { type = "effect", sName = "Otherworldly Wings; Fly 30'", sTargeting = "self", }, }, },
	["umbralform"] = {
		actions = {
			{ type = "damage", clauses = { { dice = {}, modifier = 5, dmgtype = "force", }, }, },
			{ type = "effect", sName = "Umbral Form; RESIST: all,!radiant,!force", sTargeting = "self", nDuration = 1, sUnits = "minute" },
		},
	},
	["strengthofthegrave"] = { actions = {}, prepared = 1 },
	-- Sorcerer - Storm Sorcery
	["heartofthestorm"] = {
		actions = {
			{ type = "effect", sName = "Heart of the Storm; RESIST: lightning,thunder", sTargeting = "self", },
			{ type = "damage", clauses = { { dice = {}, modifier = 1, dmgtype = "lightning", }, } },
			{ type = "damage", clauses = { { dice = {}, modifier = 1, dmgtype = "thunder", }, } },
		},
	},
	["stormsfury"] = {
		actions = {
			{ type = "damage", clauses = { { dice = {}, modifier = 1, dmgtype = "lightning", stat = "sorcerer" }, } },
			{ type = "powersave", save = "strength", },
		},
	},
	["windsoul"] = {
		actions = {
			{ type = "effect", sName = "Wind Soul; IMMUNE: lightning,thunder; Fly 60", sTargeting = "self", },
			{ type = "effect", sName = "Wind Soul; Fly 30", nDuration = 1, sUnits = "hour", },
			{ type = "effect", sName = "Wind Soul; IMMUNE: lightning,thunder; Fly 30", nDuration = 1, sUnits = "hour", },
		},
		prepared = 1
	},
	["tempestuousmagic"] = { actions = { { type = "effect", sName = "Tempestuous Magic; Fly 10' with no opp attack", sTargeting = "self", }, }, },
	-- Sorcerer - Wild Magic
	["tidesofchaos"] = { actions = { { type = "effect", sName = "Tides of Chaos; ADVATK; ADVCHK; ADVSAV", sTargeting = "self", sApply = "action", }, }, prepared = 1 },
	-- Warlock
	["eldritchinvocations"] = {
		multiple_actions = {
			["Eldritch Invocations (Bewitching Whispers)"] = { actions = {}, prepared = 1, },
			["Eldritch Invocations (Chains of Carceri)"] = { actions = {}, prepared = 1, },
			["Eldritch Invocations (Devil's Sight)"] = { actions = { { type = "effect", sName = "Devil's Sight 120", }, }, },
			["Eldritch Invocations (Dreadful Word)"] = {
				spell = { innate = { "confusion" }, },
				actions = {
					{ type = "powersave", save = "wisdom", },
					{ type = "effect", sName = "Dreadful Word; roll on Confusion Table", },
				},
				prepared = 1,
			},
			["Eldritch Invocations (Gaze of Two Minds)"] = { actions = { { type = "effect", sName = "Gaze of Two Minds; Blinded; Deafened", nDuration = 1, sTargeting = "self" }, }, },
			["Eldritch Invocations (Minions of Chaos)"] = { actions = {}, prepared = 1 },
			["Eldritch Invocations (Mire of the Mind)"] = { actions = {}, prepared = 1 },
			["Eldritch Invocations (One with the Shadows)"] = { actions = { { type = "effect", sName = "One with Shadows; Invisible", sTargeting = "self", }, }, },
			["Eldritch Invocations (Scultor of Flesh)"] = { actions = { { type = "effect", sName = "One with Shadows; Invisible", sTargeting = "self", }, }, prepared = 1, },
			["Eldritch Invocations (Sign of Ill Omen)"] = { actions = {}, prepared = 1 },
			["Eldritch Invocations (Thief of Five Fates)"] = { actions = {}, prepared = 1 },
			["Eldritch Invocations (Witch Sight)"] = { actions = { { type = "effect", sName = "Witch Sight 30', can see shapechanger or concealed creature", sTargeting = "self", }, }, },
		},
	},
	["eldritchmaster"] = { actions = {}, prepared = 1 },
	["mysticarcanum"] = { actions = {}, prepared = 1 },
	-- Warlock - Hexblade
	["expandedspellslisthexblade"] = {},
	["hexbladescurse"] = {
		actions = {
			{ type = "effect", sName = "Hexblade's Curse; Cursed", nDuration = 1, sUnits = "minute", },
			{ type = "heal", sTargeting = "self", clauses = { { dice = {}, bonus = 0, stat = "warlock" }, { dice = {}, bonus = 0, stat = "charisma" } } },
			{ type = "effect", sName = "Hexblade's Curse; IFT: custom(Cursed); DMG: [PRF]", sTargeting = "self", },
			{ type = "effect", sName = "Hexblade's Curse; CRIT: 19", sTargeting = "self", },
		},
		prepared = 1,
		usesperiod = "enc",
	},
	["hexwarrior"] = { proficiency = { innate = {"medium armor", "shields", "martial weapons"}, }, },
	["masterofhexes"] = { actions = { { type = "effect", sName = "Master of Hexes; Cursed", }, }, },
	["accursedspecter"] = { actions = { { type = "effect", sName = "Accursed Specter; ATK: [CHA]", }, }, prepared = 1, },
	-- Warlock - The Archfey
	["feypresence"] = {
		actions = {
			{ type = "powersave", save = "wisdom", },
			{ type = "effect", sName = "Fey Presence; Frightened", nDuration = 1 },
			{ type = "effect", sName = "Fey Presence; Charmed", nDuration = 1, },
		},
		prepared = 1,
		usesperiod = "enc"
	},
	["mistyescape"] = { actions = { { type = "effect", sName = "Misty Escape; Invisible", nDuration = 1, sTargeting = "self" }, }, prepared = 1, usesperiod = "enc" },
	["beguilingdefenses"] = {
		actions = {
			{ type = "powersave", save = "wisdom", },
			{ type = "effect", sName = "Beguiling Defenses; IMMUNE: Charmed", sTargeting = "self", },
			{ type = "effect", sName = "Beguiling Defenses; Charmed", nDuration = 1, sUnits = "minute" },
		},
	},
	["darkdelirium"] = {
		actions = {
			{ type = "powersave", save = "wisdom", },
			{ type = "effect", sName = "Dark Delirium; Charmed", nDuration = 1, sUnits = "minute" },
			{ type = "effect", sName = "Dark Delirium; Frightened", nDuration = 1, sUnits = "minute" },
			{ type = "effect", sName = "Dark Delirium", sTargeting = "self", nDuration = 1, sUnits = "minute" },
		},
		prepared = 1,
		usesperiod = "enc",
	},
	-- Warlock - The Celestial
	["healinglight"] = { actions = { { type = "heal", sTargeting = "self", clauses = { { dice = { "d6" }, bonus = 0, }, }, }, }, prepared = 1, },
	["searingvengeance"] = {
		actions = {
			{ type = "damage", clauses = { { dice = { "d8", "d8" }, modifier = 0, dmgtype = "radiant", stat = "charisma" }, }, },
			{ type = "effect", sName = "Searing Vengeance; Blinded", },
		},
		prepared = 1,
	},
	-- Warlock - The Fathomless
	-- Warlock - The Fiend
	["darkonesblessing"] = { actions = { { type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = {}, bonus = 0, stat = "warlock" }, { dice = {}, bonus = 0, stat = "charisma" }, }, }, }, },
	["darkonesownluck"] = { actions = { { type = "effect", sName = "Dark One's Own Luck; CHECK: 1d10; SAVE: 1d10", sTargeting = "self", sApply = "action" }, }, prepared = 1, usesperiod = "enc" },
	["fiendishresilience"] = { actions = { { type = "effect", sName = "Fiendish Resilience; RESIST: !magic,!silver,edit", sTargeting = "self" }, }, prepared = 1, usesperiod = "enc" },
	["hurlthroughhell"] = {
		actions = {
			{ type = "damage", clauses = { { dice = { "d10","d10","d10","d10","d10","d10","d10","d10","d10","d10" }, modifier = 0, dmgtype = "psychic", }, } },
			{ type = "effect", sName = "Hurl Through Hell", nDuration = 1 },
		},
		prepared = 1,
	},
	-- Warlock - The Genie
	-- Warlock - The Great Old One
	["entropicward"] = {
		actions = {
			{ type = "effect", sName = "Entropic Ward; DISATK", sApply = "action" },
			{ type = "effect", sName = "Entropic Ward; ADVATK", sTargeting = "self", nDuration = 1, sApply = "action" },
		},
		prepared = 1,
		usesperiod = "enc"
	},
	["createthrall"] = { actions = { { type = "effect", sName = "Create Thrall; Charmed", }, }, },
	["thoughtshield"] = { actions = { { type = "effect", sName = "Thought Shield; RESIST: psychic", sTargeting = "self", }, }, },
	-- Warlock - The Undead
	-- Warlock - The Undying
	["amongthedead"] = {
		actions = {
			{ type = "powersave", save = "wisdom", },
			{ type = "effect", sName = "Among the Dead; Advantages on saving throws vs. disease, undead must pass wisdom saving throw to attack", sTargeting = "self", },
		},
		spell = { innate = { "spare the dying" }, },
	},
	["defydeath"] = { actions = { { type = "heal", sTargeting = "self", clauses = { { dice = { "d8" }, bonus = 0, stat = "constitution" }, }, }, }, prepared = 1, },
	["undyingnature"] = {},
	["indestructiblelife"] = { actions = { { type = "heal", sTargeting = "self", clauses = { { dice = { "d8" }, bonus = 0, stat = "warlock" }, }, }, }, prepared = 1, usesperiod = "enc" },
	-- Wizard
	["arcanerecovery"] = { actions = {}, prepared = 1 },
	["benigntransposition"] = { actions = {}, prepared = 1 },
	-- Wizard - Bladesinging
	["songofvictory"] = { actions = { { type = "effect", sName = "Song of Victory; DMG: [INT]", sTargeting = "self", }, }, },
	["bladesong"] = { actions = { { type = "effect", sName = "Bladesong; AC: [INT]; SAVE: [INT] concentration; ADVSKILL: acrobatics; Speed increase by 10", sTargeting = "self", nDuration = 1, sUnits = "minute", }, }, prepared = 1, usesperiod = "enc", },
	["durablemagic"] = { actions = { { type = "effect", sName = "Durable Magic; AC: 2; SAVE: 2; (C)", sTargeting = "self", }, }, },
	["powersurge"] = { actions = { { type = "effect", sName = "Power Surge; DMG: [HLVL] force,magic", sTargeting = "self", sApply = "roll", }, }, },
	["tacticalwit"] = { actions = { { type = "effect", sName = "Tactical Wit; INIT: [INT]", sTargeting = "self", }, }, },
	-- Wizard - Chronurgy Magic
	-- Wizard - Graviturgy Magic
	-- Wizard - Order of Scribes
	-- Wizard - School of Abjuration
	["arcaneward"] = {
		actions = {
			{ type = "effect", sName = "Arcane Ward", sTargeting = "self" },
			{ type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = {}, bonus = 0, stat = "intelligence" }, } },
		},
		prepared = 1,
	},
	["improvedabjuration"] = { actions = { { type = "effect", sName = "Improved Abjuration; CHECK: [PRF]", sTargeting = "self", sApply = "action" }, }, },
	["spellresistance"] = {
		actions = {
			{ type = "effect", sName = "Spell Resistance; ADVSAV: all", sTargeting = "self", sApply = "action" },
			{ type = "effect", sName = "Spell Resistance; RESIST: all", sTargeting = "self", sApply = "action" },
		},
	},
	-- Wizard - School of Conjuration
	["minorconjuration"] = { actions = { { type = "effect", sName = "Minor Conjuration", sTargeting = "self", nDuration = 1, sUnits = "hour", }, }, },
	["durablesummons"] = { actions = { { type = "heal", subtype = "temp", clauses = { { dice = {}, bonus = 30, }, } }, }, },
	-- Wizard - School of Divination
	["thethirdeye"] = {
		multiple_actions = {
			["The Third Eye (Darkvision)"] = { actions = { { type = "effect", sName = "The Third Eye Darkvision; Darkvision 60", sTargeting = "self" }, }, prepared = 1, usesperiod = "enc", },
			["The Third Eye (Ethereal Sight)"] = { actions = { { type = "effect", sName = "The Third Eye Darkvision; Ethereal Sight 60", sTargeting = "self"}, }, prepared = 1, usesperiod = "enc" },
			["The Third Eye (Greater Comprehension)"] = { actions = { { type = "effect", sName = "Greater Comprehension", sTargeting = "self", }, }, prepared = 1, usesperiod = "enc" },
			["The Third Eye (See Invisibility)"] = { actions = { { type = "effect", sName = "See Invisibility within 10 feet", sTargeting = "self", }, }, prepared = 1, usesperiod = "enc" },
		},
	},
	["portent"] = { actions = {}, prepared = 2 },
	-- Wizard - School of Enchantment
	["hypnoticgaze"] = {
		actions = {
			{ type = "powersave", save = "wisdom", },
			{ type = "effect", sName = "Hypnotic Gaze; Charmed; Incapacitated", nDuration = 1, },
		},
		prepared = 1,
	},
	["instinctivecharm"] = { actions = { { type = "powersave", save = "wisdom", }, }, prepared = 1, },
	["altermemories"] = { actions = { { type = "powersave", save = "intelligence" }, }, },
	-- Wizard - School of Evocation
	["empoweredevocation"] = { actions = { { type = "effect", sName = "Empowered Evocation; DMG: [INT]", sTargeting = "self", sApply = "roll" }, }, },
	["overchannel"] = { actions = { { type = "damage", clauses = { { dice = { "d12", "d12" }, dmgtype = "necrotic", }, } }, }, },
	-- Wizard - School of Illusion
	["illusoryself"] = { actions = {}, prepared = 1, usesperiod = "enc" },
	["illusoryreality"] = { actions = { { type = "effect", sName = "Illusory Reality", sTargeting = "self", nDuration = 1, sUnits = "minute", }, }, },
	-- Wizard - School of Necromancy
	["undeadthralls"] = { actions = { { type = "effect", sName = "Undead Thralls; DMG: [PRF]", }, }, },
	["inuredtoundeath"] = { actions = { { type = "effect", sName = "Inured to Undeath; RESIST: necrotic; HP MAX cannot be reduced", sTargeting = "self", }, }, },
	["commandundead"] = { actions = { { type = "powersave", save = "charisma", }, { type = "effect", sName = "Command Undead; Save every hour", }, }, },
	-- Wizard - School of Transmutation
	["minoralchemy"] = { actions = { { type = "effect", sName = "Minor Alchemy", sTargeting = "self", nDuration = 1, sUnits = "hour" }, }, },
	["transmutersstone"] = {
		actions = {
			{ type = "effect", sName = "Transmuter's Stone; Darkvision 60", },
			{ type = "effect", sName = "Transmuter's Stone; SAVE: [PRF] constitution", },
			{ type = "effect", sName = "Transmuter's Stone; RESIST: acid, cold, fire, lightning, thunder", },
		},
	},
	["shapechanger"] = { actions = {}, prepared = 1, usesperiod = "enc" },
	["mastertransmuter"] = { actions = {}, prepared = 1 },
	-- Wizard - School of War Magic
	["arcanedeflection"] = { actions = { { type = "effect", sName = "Arcane Deflection; AC: 2; SAVE: 4", sTargeting = "self", sApply = "action" }, }, },
	["deflectingshroud"] = { actions = { { type = "effect", sName = "Deflecting Shroud; DMG: [HLVL] force,magic", sTargeting = "self", sApply = "roll" }, }, },
	--
	-- Races
	--
	-- Aasimar
	-- warlock has this as well
	["celestialresistance"] = { actions = { { type = "effect", sName = "Celestial Resistance; RESIST: necrotic,radiant", sTargeting = "self", }, }, },
	["healinghands"] = { actions = { { type = "heal", clauses = { { dice = {}, bonus = 0, stat = "level" }, } }, }, },
	["necroticshroud"] = {
		actions = {
			{ type = "effect", sName = "Necrotic Shroud; Frightened", nDuration = 1, },
			{ type = "effect", sName = "Necrotic Shroud", sTargeting = "self", nDuration = 1, sUnits = "minute" },
			{ type = "powersave", save = "charisma", },
			{ type = "effect", sName = "Necrotic Shroud; DMG: [LVL] necrotic", sTargeting = "self", sApply = "action" },
		},
		prepared = 1
	},
	["radiantconsumption"] = {
		actions = {
			{ type = "effect", sName = "Radiant Consumption", sTargeting = "self", nDuration = 1, },
			{ type = "damage", clauses = { { dice = {}, modifier = 1, dmgtype = "radiant", }, } },
			{ type = "effect", sName = "Radiant Consumption; DMG: [LVL] radiant", sTargeting = "self", sApply = "action" },
		},
		prepared = 1
	},
	["radiantsoul"] = {
		-- Warlock shares same name
		actions = {
			--{ type = "effect", sName = "Radiant Soul; DMG: [LVL] radiant", sTargeting = "self", sApply = "action", },
			{ type = "effect", sName = "Radiant Soul; DMG: RESIST: radiant", sTargeting = "self", },
			{ type = "effect", sName = "Radiant Soul; DMG: [CHA]", sTargeting = "self", sApply = "roll" },
		},
		--prepared = 1
	},
	-- Bugbear
	["surpriseattack"] = { actions = { { type = "effect", sName = "Surprise Attack; DMG: 2d6", sTargeting = "self", sApply = "roll", }, }, },
	-- Centaur
	["charge"] = { actions = {}, prepared = 1 },
	["equinebuild"] = { actions = { { type = "effect", sName = "Equine Build; Climb movement costs 4 extra rather thn 1 extra.", sTargeting = "self", }, }, },
	-- Changeling
	["changeappearance"] = { actions = { { type = "effect", sName = "Change Appearance; ADVCHK: charisma", sTargeting = "self", sApply = "roll", }, }, },
	["divergentpersona"] = { actions = { { type = "effect", sName = "Divergent Persona; SKILL: [PRF]", sTargeting = "self", sApply = "roll", }, }, },
	["unsettlingvisage"] = { actions = { { type = "effect", sName = "Unsettling Visage; DISATK", sTargeting = "self", sApply = "roll", }, }, prepared = 1, usesperiod = "enc" },
	-- Dragonborn
	["reddragonbornbreathweapon"] = {
		actions = {
			{ type = "powersave", save = "dexterity", savestat = "constitution", onmissdamage = "half" },
			{ type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "fire", }, } },
		},
	},
	["reddragonbornresistance"] = { actions = { { type = "effect", sName = "Draconic Resistance; RESIST: fire;", sTargeting = "self", }, }, },
	["bluedragonbornbreathweapon"] = {
		actions = {
			{ type = "powersave", save = "dexterity", savestat = "constitution", onmissdamage = "half" },
			{ type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "lightning", }, } },
		},
	},
	["bluedragonbornresistance"] = { actions = { { type = "effect", sName = "Draconic Resistance; RESIST: lightning;", sTargeting = "self", }, }, },
	["greendragonbornbreathweapon"] = {
		actions = {
			{ type = "powersave", save = "constitution", savestat = "constitution",  onmissdamage = "half" },
			{ type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "poison", }, } },
		},
	},
	["greendragonbornresistance"] = { actions = { { type = "effect", sName = "Draconic Resistance; RESIST: poison;", sTargeting = "self", }, }, },
	["bronzedragonbornbreathweapon"] = {
		actions = {
			{ type = "powersave", save = "dexterity", savestat = "constitution",  onmissdamage = "half" },
			{ type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "lightning", }, } },
		},
	},
	["bronzedragonbornresistance"] = { actions = { { type = "effect", sName = "Draconic Resistance; RESIST: lightning;", sTargeting = "self", }, }, },
	["blackdragonbornbreathweapon"] = {
		actions = {
			{ type = "powersave", save = "dexterity", savestat = "constitution",  onmissdamage = "half" },
			{ type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "acid", }, } },
		},
	},
	["blackdragonbornresistance"] = { actions = { { type = "effect", sName = "Draconic Resistance; RESIST: acid;", sTargeting = "self", }, }, },
	["whitedragonbornbreathweapon"] = {
		actions = {
			{ type = "powersave", save = "constitution", savestat = "constitution",  onmissdamage = "half" },
			{ type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "cold", }, } },
		},
	},
	["whitedragonbornresistance"] = { actions = { { type = "effect", sName = "Draconic Resistance; RESIST: cold;", sTargeting = "self", }, }, },
	["golddragonbornbreathweapon"] = {
		actions = {
			{ type = "powersave", save = "dexterity", savestat = "constitution",  onmissdamage = "half" },
			{ type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "fire", }, } },
		},
	},
	["golddragonbornresistance"] = { actions = { { type = "effect", sName = "Draconic Resistance; RESIST: fire;", sTargeting = "self", }, }, },
	["copperdragonbornbreathweapon"] = {
		actions = {
			{ type = "powersave", save = "dexterity", savestat = "constitution",  onmissdamage = "half" },
			{ type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "acid", }, } },
		},
	},
	["copperdragonbornresistance"] = { actions = { { type = "effect", sName = "Draconic Resistance; RESIST: acid;", sTargeting = "self", }, }, },
	["brassdragonbornbreathweapon"] = {
		actions = {
			{ type = "powersave", save = "dexterity", savestat = "constitution",  onmissdamage = "half" },
			{ type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "fire", }, } },
		},
	},
	["brassdragonbornresistance"] = { actions = { { type = "effect", sName = "Draconic Resistance; RESIST: fire;", sTargeting = "self", }, }, },
	["silverdragonbornbreathweapon"] = {
		actions = {
			{ type = "powersave", save = "constitution", savestat = "constitution",  onmissdamage = "half" },
			{ type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "cold", }, } },
		},
	},
	["silverdragonbornresistance"] = { actions = { { type = "effect", sName = "Draconic Resistance; RESIST: cold;", sTargeting = "self", }, }, },
	-- Duergar
	["duergarmagic"] = {
		actions = {
			{ type = "powersave", save = "constitution", magic = true, savebase = "group" },
			{ type = "effect", sName = "Duergar Magic Enlarged; ADVCHK: strength; ADVSAV: strength; DMG: 1d4; (C)", nDuration = 1, sUnits = "minute" },
			{ type = "effect", sName = "Duergar Magic Reduced; DISCHK: strength; DISSAV: strength; DMG: -1d4; (C)", nDuration = 1, sUnits = "minute" },
		},
		prepared = 1
	},
	["duergarresilience"] = { actions = { { type = "effect", sName = "Duergar Resilience; Advantage against illusions, charmed, and paralyzed", sTargeting = "self" }, }, },
	["sunlightsensitivity"] = { actions = { { type = "effect", sName = "Sunlight Sensitivity; DISATK; DISSKILL: perception", sTargeting = "self" }, }, },
	-- Dwarf
	["dwarvenresilience"] = { actions = { { type = "effect", sName = "Dwarven Resilience; RESIST: poison; Advantage on saving throws vs. poison", sTargeting = "self" }, }, },
	["stonecunning"] = { actions = { { type = "effect", sName = "Stonecunning; SKILL: [2PRF] history", sTargeting = "self", sApply = "action" }, }, },
	["masteroflocks"] = { actions = { { type = "effect", sName = "Master of Locks; SKILL: 1d4 history, investigation, thieves' tools", sTargeting = "self", sApply = "action" }, }, },
	["wardsandseals"] = { actions = {}, prepared = 1 },
	["wardersintuition"] = { actions = { { type = "effect", sName = "Warder's Intuition; SKILL: 1d4 investigation, thieves' tools", sTargeting = "self", }, }, },
	-- Elf
	["feyancestry"] = { actions = { { type = "effect", sName = "Fey Ancestry; Advantage on saving throws vs. charmed, no magic sleep", sTargeting = "self", }, }, },
	["feystep"] = {
		actions = {
			{ type = "powersave", save = "wisdom", savestat = "charisma", },
			{ type = "effect", sName = "Fey Step; Charmed", nDuration = 1, sUnits = "minute" },
			{ type = "effect", sName = "Fey Step; Frightened", nDuration = 1, },
			{ type = "damage", clauses = { { dice = {}, modifier = 0, dmgtype = "fire", stat = "charisma" }, } },
		},
		prepared = 1
	},
	["maskofthewild"] = { actions = { { type = "effect", sName = "Mask of the Wild; Hide when lightly obscurred", sTargeting = "self", }, }, },
	["feyancestry"] = { spell = { innate = {"dancing lights"}, level = { [3] = { "faerie fire" }, [5] = { "darkness" }, }, }, },
	["childofthesea"] = { actions = { { type = "effect", sName = "Child of the Sea; Swim speed 30' and can breathe air and water", sTargeting = "self", }, }, },
	["friendofthesea"] = { actions = { { type = "effect", sName = "Friend of the Sea; Can communicate with beasts that have a swim speed", sTargeting = "self", }, }, },
	["giftoftheshadows"] = { actions = { { type = "effect", sName = "Gift of the Shadows; SKILL: 1d4 performance, stealth", sTargeting = "self", }, }, },
	["slipintoshadow"] = { actions = { { type = "effect", sName = "Slip Into Shadow; Hidden", sTargeting = "self", }, }, prepared = 1 },
	["deductiveintuition"] = { actions = { { type = "effect", sName = "Deductive Intuition; SKILL: 1d4 investigation, insight", sTargeting = "self", }, }, },
	["headwinds"] = { actions = {}, prepared = 1 },
	["stormsblessing"] = { actions = { { type = "effect", sName = "Storm's Blessing; RESIST: lightning", sTargeting = "self", }, }, },
	["windwrightsintuition"] = {
		actions = {
			{ type = "effect", sName = "Windwright's Intuition; SKILL: 1d4, acrobatics", sTargeting = "self", },
			{ type = "effect", sName = "Windwright's Intuition; SKILL: 1d4", sTargeting = "self", sApply = "action" },
		},
	},
	["cunningintuition"] = { actions = { { type = "effect", sName = "Cunning Intuition; SKILL: 1d4 performance, stealth", sTargeting = "self", }, }, },
	["stormsboon"] = { actions = { { type = "effect", sName = "Storm's Boon; RESIST: lightning", sTargeting = "self", }, }, },
	-- Firbolg
	["firbolgmagic"] = { spell = { innate = {"detect magic", "disguise self"}, }, },
	["hiddenstep"] = { actions = { { type = "effect", sName = "Hidden Step; Invisible", sTargeting = "self", nDuration = 1 }, }, prepared = 1, usesperiod = "enc" },
	["speechofbeastandleaf"] = { actions = { { type = "effect", sName = "Speech of Beast and Leaf; ADVCHK: charisma", sTargeting = "self", nApply = "action" }, }, },
	-- Genasi
	["acidresistance"] = { actions = { { type = "effect", sName = "Acid Resistance; RESIST: acid", sTargeting = "self", }, }, },
	["calltothewave"] = { spell = { innate = {"shape water"}, level = { [3] = { "create or destroy water" } }, }, },
	["earthwalk"] = { actions = { { type = "effect", sName = "Earth Walk; Earth and stone not difficult terrain", sTargeting = "self", }, }, },
	["fireresistance"] = { actions = { { type = "effect", sName = "Fire Resistance; RESIST: fire", sTargeting = "self", }, }, },
	["mergewithstone"] = { spell = { innate = {"pass without trace"}, }, },
	["minglewiththewind"] = { spell = { innate = {"levitate"}, }, },
	["reachtotheblaze"] = { spell = { innate = {"produce flame"}, level = { [3] = { "burning hands" } }, }, },
	-- Githzerai
	-- Gnome
	["artificerslore"] = { actions = { { type = "effect", sName = "Artificer's Lore; SKILL: [PRF] history", sTargeting = "self", sApply = "action" }, }, },
	["gnomecunning"] = { actions = { { type = "effect", sName = "Gnome Cunning; ADVSAV: intelligence,wisdom,charisma", sTargeting = "self", sApply = "action" }, }, },
	["stonecamouflage"] = { actions = { { type = "effect", sName = "Stone Camouflage; ADVCHK: dexterity", sTargeting = "self", sApply = "action" }, }, },
	["giftedscribe"] = { actions = { { type = "effect", sName = "Gifted Scribe; SKILL: 1d4 forgery kit, calligrapher's supplies", sTargeting = "self", }, }, },
	["scribesinsight"] = { actions = {}, prepared = 1, },
	-- Hobgoblin
	["savingface"] = { actions = {}, prepared = 1, },
	-- Goblin
	["furyofthesmall"] = { actions = { { type = "damage", clauses = { { dice = {}, modifier = 0, dmgtype = "", stat = "level" }, } }, }, prepared = 1, usesperiod = "enc" },
	["nimbleescape"] = { actions = { { type = "effect", sName = "Nimble Escape; Disengage or hide as bonus action", sTargeting = "self", }, }, },
	-- Goliath
	["nimbleescape"] = { actions = { { type = "heal", sTargeting = "self", clauses = { { dice = { "d12" }, bonus = 0, stat = "constitution" }, } }, }, prepared = 1, usesperiod = "enc" },
	-- Half-Orc
	["relentlessendurance"] = { actions = { { type = "heal", sTargeting = "self", clauses = { { dice = {}, bonus = 1, }, } }, }, prepared = 1, },
	["huntersintuition"] = { actions = { { type = "effect", sName = "Hunter's Intuition; SKILL: 1d4 perception, survival", sTargeting = "self", }, }, },
	["imprintprey"] = { actions = { { type = "effect", sName = "Imprint Prey", sTargeting = "self", }, }, prepared = 1, usesperiod = "enc" },
	-- Halfling
	["brave"] = { actions = { { type = "effect", sName = "Brave; ADVSAV: all", sTargeting = "self", sApply = "action" }, }, },
	["naturallystealthy"] = { actions = { { type = "effect", sName = "Naturally Stealthy; Hide attempt obsucured by creature at least one size larger", }, }, },
	["silentspeech"] = { actions = { { type = "effect", sName = "Silent Speech; Telepathy 30 (if shared language)", sTargeting = "self" }, }, },
	["stoutresilience"] = { actions = { { type = "effect", sName = "Stout Resilience; RESIST: poison; Advantage on saving throws vs. poison", sTargeting = "self" }, }, },
	["healingtouch"] = { actions = {}, prepared = 1, usesperiod = "enc" },
	["medicalintuition"] = { actions = { { type = "effect", sName = "Halfling Dragonmarked: ; SKILL: 1d4 medicine", sTargeting = "self" }, }, },
	["artisansintuition"] = { actions = { { type = "effect", sName = "Artisan's Intuition; SKILL 1d4 edit", sTargeting = "self" }, }, },
	["everhospitable"] = { actions = { { type = "effect", sName = "Ever Hospitable; SKILL: 1d4 persuasion, brewer's supplies", sTargeting = "self" }, }, },
	-- Human
	["intuitivemotion"] = { actions = { { type = "effect", sName = "Intuitive Motion; SKILL: 1d4 athletics", sTargeting = "self" }, { type = "effect", sName = "Intuitive Motion; SKILL: 1d4", sTargeting = "self", sApply ="action" }, }, },
	["primalconnection"] = { actions = {}, prepared = 1, usesperiod = "enc" },
	["sentinelsintuition"] = {
		actions = {
			{ type = "effect", sName = "Sentinel's Intuition; INIT: 1d4", sTargeting = "self" },
			{ type = "effect", sName = "Sentinel's Intuition; SKILL: 1d4 perception", sTargeting = "self", sApply ="action" },
		},
	},
	["sentinelsshield"] = { spell = { innate = {"blade ward", "shield"}, }, },
	["sharedpassage"] = { actions = {}, prepared = 1, },
	["spellsmith"] = {
		actions = {
			{ type = "effect", sName = "Spellsmith; AC: 1", sTargeting = "self", nDuration = 1, sUnits = "hour" },
			{ type = "effect", sName = "Spellsmith; DMG: 1; ATK: 1; DMGTYPE: magic", sTargeting = "self", nDuration = 1, sUnits = "hour" },
		},
	},
	["vigilantguardian"] = { actions = { { type = "effect", sName = "Vigilant Guardian; ADVSKILL: insight, perception", sTargeting = "self", sApply = "action", }, }, },
	["wildintuition"] = { actions = { { type = "effect", sName = "Wild Intuition; SKILL: 1d4 animal handling, nature", sTargeting = "self", }, }, },
	["intuativemotion"] = { actions = { { type = "effect", sName = "Intuative Motion; SKILL: 1d4 acrobatics, vehicles (land)", sTargeting = "self", }, }, },
	["sentinalsintuition"] = { actions = { { type = "effect", sName = "Sentinal's Intuition; SKILL: 1d4 insight, perception", sTargeting = "self", }, }, },
	-- Kalashtar
	["dualmind"] = { actions = { { type = "effect", sName = "Dual Mind; ADVSAV: wisdom", sTargeting = "self", sApply = "roll" }, }, },
	["mentaldiscipline"] = {
		actions = {
			{ type = "effect", sName = "Mental Discipline (Kalashtar); RESIST: psychic", sTargeting = "self", },
			{ type = "effect", sName = "Mental Discipline (Githzerai): Advantage on saves vs. charmed/frightened", sTargeting = "self", },
		},
	},
	["mindlink"] = { actions = { { type = "effect", sName = "Mind Link; Telepathy 60' with one creature", sTargeting = "self", }, }, },
	["psychicglamour"] = { actions = { { type = "effect", sName = "Psychic Glamour; ADVSKILL: edit", sTargeting = "self", }, }, },
	["severedfromdreams"] = { actions = { { type = "effect", sName = "Severed from Dreams; Immune to dream effects", sTargeting = "self", }, }, },
	-- Kenku
	["mimicry"] = { actions = { { type = "effect", sName = "Mimicry", sTargeting = "self" }, }, },
	["expertforgery"] = { actions = { { type = "effect", sName = "Expert Forgery; ADVCHK: all", sTargeting = "self", sApply = "action" }, }, },
	-- Kobold
	["packtactics"] = { actions = { { type = "effect", sName = "Pack Tactics; ADVATK", sTargeting = "self", }, }, },
	["grovelcowerandbeg"] = { actions = { { type = "effect", sName = "Grovel Cower and Beg; GRANTADVATK", nDuration = 1, }, }, prepared = 1, usesperiod = "enc" },
	-- Lizardfolk
	["bite"] = { actions = { { type = "damage", clauses = { { dice = { "d6" }, modifier = 0, dmgtype = "piercing", stat = "strength" }, } }, }, },
	["hungryjaws"] = { actions = { { type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = {}, bonus = 0, stat = "constitution" }, } }, }, prepared = 1, usesperiod = "enc" },
	-- Loxodon
	["keensmell"] = {
		actions = {
			{ type = "effect", sName = "Keen Smell; ADVSKILL: perception", sTargeting = "self", sApply = "action" },
			{ type = "effect", sName = "Keen Smell; ADVSKILL: survival", sTargeting = "self", sApply = "action" },
			{ type = "effect", sName = "Keen Smell; ADVSKILL: investigation", sTargeting = "self", sApply = "action" },
		},
	},
	["loxodonserenity"] = { actions = { { type = "effect", sName = "Loxodon Serenity; Advantage against being charmed or frightened.", sTargeting = "self", }, }, },
	-- Minotaur
	["hammeringhorns"] = { actions = { { type = "powersave", save = "strength", savestat = "strength", }, }, },
	-- Orc
	["aggressive"] = { actions = { { type = "effect", sName = "Aggressive; Bonus action move", }, }, },
	-- Shadar-kai
	["blessingoftheravenqueen"] = { actions = { { type = "effect", sName = "Blessing of the Raven Queen; RESIST: all", sTargeting = "self", nDuration = 1 }, }, },
	["necroticresistance"] = { actions = { { type = "effect", sName = "Necrotic Resistance; RESIST: necrotic", sTargeting = "self", }, }, },
	-- Shifter
	["markthescent"] = {
		actions = {
			{ type = "effect", sName = "Mark the Scent; CHECK: [PRF]", sTargeting = "self", sApply = "roll" },
		},
		usesperiod = "enc"
	},
	["shifted"] = {
		actions = {
			{ type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = {}, bonus = 0, stat = "level" }, { dice = {}, bonus = 0, stat = "constitution" } } },
			{ type = "effect", sName = "Shifted", sTargeting = "self", nDuration = 1, sUnits = "minute" },
		},
		prepared = 1,
		usesperiod = "enc"
	},
	["shiftingfeature"] = {
		["multiple_actions"] = {
			["Shifting Feature (Beasthide)"] = { actions = { { type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = { "d6" }, bonus = 0, }, } }, { type = "effect", sName = "Shifting Feature (Beastside); AC: 1", sTargeting = "self", nDuration = 1, sUnits = "minute" }, }, },
			["Shifting Feature (Longtooth)"] = { actions = { { type = "damage", clauses = { { dice = { "d6" }, modifier = 0, dmgtype = "piercing", stat = "strength" }, } }, }, },
			["Shifting Feature (Swiftstride)"] = { actions = { { type = "effect", sName = "Shifting Feature (Swiftstride); Special movement", sTargeting = "self", nDuration = 1, sUnits = "minute" }, }, },
			["Shifting Feature (Wildhunt)"] = { actions = { { type = "effect", sName = "Shifting Feature (Wildhunt); ADVCHK: wisdom", sTargeting = "self", nDuration = 1, sUnits = "minute" }, }, },
		},
	},
	-- Simic Hybrid
	["animalenhancement"] = {
		["multiple_actions"] = {
			["Animal Enhancement (Manta Glide)"] = { actions = { { type = "effect", sName = "Animal Enhancement (Underater Adaptation); Can breathe air and water, swimming speed equal to walking speed.", sTargeting = "self", }, }, },
			["Animal Enhancement (Nimble Climber)"] = { actions = { { type = "effect", sName = "Animal Enhancement (Nimble Climber); Climbing speed equal to walking speed", sTargeting = "self", }, }, },
			["Animal Enhancement (Grappling Appendages)"] = {
				actions = {
					{ type = "effect", sName = "Animal Enhancement (Grappling Appendages); Grappled", },
					{ type = "damage", clauses = { { dice = { "d6" }, modifier = 0, dmgtype = "bludgeoning", stat = "strength" }, } },
				},
			},
			["Animal Enhancement (Carapace)"] = { actions = { { type = "effect", sName = "Animal Enhancement (Carapace); AC: 1", sTargeting = "self", }, }, },
			["Animal Enhancement (Acid Spit)"] = {
				actions = {
					{ type = "powersave", save = "dexterity", savestat = "constitution", },
					{ type = "damage", clauses = { { dice = { "d10", "d10" }, modifier = 0, dmgtype = "acid", }, } },
				},
			},
		},
	},
	-- Tabaxi
	["catsclaws"] = { actions = { { type = "damage", clauses = { { dice = { "d4" }, modifier = 0, dmgtype = "slashing", stat = "strength" }, } }, }, },
	-- Tiefling
	["infernallegacy"] = {
		spell = {
			innate = {"thaumaturgy"},
			level = { [3] = { "hellish rebuke" }, },
		},
	},
	["hellishresistance"] = { actions = { { type = "effect", sName = "Hellish Resistance; RESIST: fire", sTargeting = "self" }, }, },
	["hellfire"] = { spell = { level = { [3] = { "burning hands" }, }, }, },
	["devilstongue"] = {
		spell = {
			innate = {"vicious mockery"},
			level = {
				[3] = { "charm person" },
				[5] = { "enthrall" },
			},
		},
	},
	-- Tortle
	["claws"] = { actions = { { type = "damage", clauses = { { dice = { "d4" }, modifier = 0, dmgtype = "slashing", stat = "strength" } } }, }, },
	["holdbreath"] = { actions = { { type = "effect", sName = "Hold Breath", sTargeting = "self", nDuration = 1, sUnits = "hour" }, }, },
	["shelldefense"] = { actions = { { type = "effect", sName = "Shell Defense; AC: 4; ADVSAV: constitution, strength; prone; Speed is zero; DISSAV: dexterity; no actions.", sTargeting = "self", }, }, },
	-- Triton
	["guardiansofthedepths"] = { actions = { { type = "effect", sName = "Guardians of the Depths; RESIST: cold", sTargeting = "self" }, }, },
	["controlairandwater"] = {
		spell = {
			innate = {"fog cloud"},
			level = {
				[3] = { "gust of wind" },
				[5] = { "wall of water" },
			},
		},
	},
	-- Vedalken
	["partiallyamphibious"] = { actions = { { type = "effect", sName = "Partially Amphibious; Breathe underwater", sTargeting = "self", nDuration = 1, sUnits = "hour" }, }, },
	["tirelessprecision"] = { actions = { { type = "effect", sName = "Tireless Precision; SKILL: 1d4", sTargeting = "self", sApply = "roll" }, }, },
	["vedalkendispassion"] = { actions = { { type = "effect", sName = "Vedalken Dispassion; ADVSAV: intelligence,wisdom,charisma", sTargeting = "self", }, }, },
	-- Verdan
	["vedalkendispassion"] = { actions = { { type = "effect", sName = "Vedalken Dispassion; ADVSAV: intelligence,wisdom,charisma", sTargeting = "self", }, }, },
	["telepathicinsight"] = { actions = { { type = "effect", sName = "Telepathic Insight; ADVSAV: wisdom, charisma", sTargeting = "self", }, }, },
	["limitedtelepathy"] = { actions = { { type = "effect", sName = "Limited Telepathy 30 ft.", sTargeting = "self", }, }, },
	-- Warforged
	["integratedtool"] = { actions = { { type = "effect", sName = "Integrated Tool: ADVSKILL: ", sTargeting = "self" }, }, },
	["ironfists"] = { actions = { { type = "damage", clauses = { { dice = { "d4" }, modifier = 0, dmgtype = "bludgeoning", stat = "strength" }, } }, }, },
	["warforgedresilience"] = { actions = { { type = "effect", sName = "Warforged Resilience; RESIST: poison; Advantage against poison; Immune to disease and exhaustion; don't need sleep, food, drink, or air", sTargeting = "self" }, }, },
	["constructedresilience"] = { actions = { { type = "effect", sName = "Constructed Resilience; RESIST: poison; advantage on saves vs. poisoned, do not need to eat, drink, or breathe, or sleep, immune to disease, cannot be put to sleep by magic. ", sTargeting = "self" }, }, },
	["integratedprotection"] = { actions = { { type = "effect", sName = "Integrated Protection; AC: 1", sTargeting = "self" }, }, },
	-- Yuan-ti
	["yuantiinnatespellcasting"] = { spell = { innate = {"poison spray", "animal friendship"}, level = { [3] = { "suggestion" }, }, }, },
	["magicresistance"] = { actions = { { type = "effect", sName = "Yuan-ti Pureblood; Magic Resistance", sTargeting = "self" }, }, },
	["poisonimmunity"] = { actions = { { type = "effect", sName = "Poison Immunity; IMMUNE: poison,poisoned", sTargeting = "self" }, }, },
}
