-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

genmethod = {
	"",
	"Standard Array",
	"Point Buy",
	"Dice Roll/Manual Entry",
};

genrolltype = {
	"",
};

aParseRaceLangChoices = {
	[", and fluency in one language of your choice."] = "",
	[" and one other language that you and your dm agree is appropriate for the character"] = "",
	[" and one other language that you and your dm agree is appropriate for your character"] = "",
	["one extra language of your choice"] = "",
	["one other language of your choice"] = "",
	["one additional language of your choice"] = "",
	["two other languages of your choice"] = "",
};
aRaceSkill = {
	["keensenses"] = true,
	["skillversatility"] = true,
	["menacing"] = true,
	["skills"] = true,
	["changelinginstincts"] = true,
	["graceful"] = true,
	["naturaltracker"] = true,
	["fierce"] = true,
	["tough"] = true,
	["specializeddesign"] = true,
	["survivor"] = true,
	["silentfeathers"] = true,
	["leporinesenses"] = true,
	["tirelessprecision"] = true,
	["wiryframe"] = true,
	["naturalathelete"] = true,
	["survivalinstinct"] = true,
	["kenkutraining"] = true,
	["primalintuition"] = true,
	["skill"] = true,
	["imposingpresence"] = true,
	["hunterslore"] = true,
	["catstalent"] = true,
	["psychicglamour"] = true,
	["reveler"] = true,
	["sneaky"] = true,
	["bestialinstincts"] = true,
	["naturalaffinity"] = true,
	["littlegiant"] = true,
	["kenkurecall"] = true,
	["naturesintuition"] = true,
	["besitalinstincts"] = true,
};
aRaceProficiency = {
	["proficiency"] = true,
	["dwarvencombattraining"] = true,
	["toolproficiency"] = true,
	["dwarvenarmortraining"] = true,
	["drowweapontraining"] = true,
	["elfweapontraining"] = true,
	["giftedscribe"] = true,
	["tinker"] = true,
	["specializeddesign"] = true,
	["divergentpersona"] = true,
	["masonsproficiency"] = true,
	["martialprodigy"] = true,
	["seaelftraining"] = true,
	["makersgift"] = true,
};
aRaceSpecialSpeed = {
	["fleetoffoot"] = true,
	["seamonkey"] = true,
	["couriersspeed"] = true,
	["swiftstride"] = true,
	["spiderclimb"] = true,
	["fairyflight"] = true,
	["nimbleflight"] = true,
	["nimbleclimber"] = true,
	["underwateradaptation"] = true,
	["flight"] = true,
	["swimspeed"] = true,
	["swim"] = true,
	["winged"] = true,
	["catsclaws"] = true,
};
aRaceSpells = {
	["wardsandseals"] = true,
	["duergarmagic"] = true,
	["shapeshadows"] = true,
	["drowmagic"] = true,
	["scribesinsight"] = true,
	["whisperingwind"] = true,
	["naturalillusionist"] = true,
	["jorascosblessing"] = true,
	["innkeeperscharms"] = true,
	["infernallegacy"] = true,
	["sensethreats"] = true,
	["headwinds"] = true,
	["naturesvoice"] = true,
	["primalconnection"] = true,
	["makersgift"] = true,
	["sentinelsshield"] = true,
	["astralfire"] = true,
	["fairymagic"] = true,
	["sensethreats"] = true,
	["hexmagic"] = true,
	["draconiclegacy"] = true,
	["magicsight"] = true,
	["githyankipsionics"] = true,
	["githzeraipsionics"] = true,
	["calltothewave"] = true,
	["mergewithstone"] = true,
	["reachtotheblaze"] = true,
	["minglewiththewind"] = true,
	["celestiallegacy"] = true,
	["lightbearer"] = true,
	["firbolgmagic"] = true,
	["feystep"] = true,
	["innatespellcasting"] = true,
	["cantrip"] = true,
	["blessingofthemoonweaver"] = true,
	["childofthewood"] = true,
	["firbolgmagic"] = true,
	["controlairandwater"] = true,
	["serpentinespellcasting"] = true,
};
aRaceLanguages = {
	["languages"] = true,
	["extralanguage"] = true,
	["specializeddesign"] = true,
};
aRaceTraitNoParse = {
	["age"] = true,
	["subrace"] = true,
	["alignment"] = true,
	["abilityscoreincrease"] = true,
	["abilityscoreincreases"] = true,
};
aRaceTraitNoAdd = {
	["cantrip"] = true,
	["darkvision"] = true,
	["size"] = true,
	["superiordarkvision"] = true,
	["variabletrait"] = true,
};

aAllArmor = {
	["light armor"] = true,
	["medium armor"] = true,
	["heavy armor"] = true,
};
aSimpleWeapons = {
	["clubs"] = true,
	["daggers"] = true,
	["greatclubs"] = true,
	["handaxes"] = true,
	["javelins"] = true,
	["light hammers"] = true,
	["maces"] = true,
	["quarterstaffs"] = true,
	["sickles"] = true,
	["spears"] = true,
	["light crossbows"] = true,
	["darts"] = true,
	["shortbows"] = true,
	["slings"] = true,
	["club"] = true,
	["dagger"] = true,
	["greatclub"] = true,
	["handaxe"] = true,
	["javelin"] = true,
	["light hammer"] = true,
	["mace"] = true,
	["quarterstaff"] = true,
	["sickle"] = true,
	["spear"] = true,
	["light crossbow"] = true,
	["dart"] = true,
	["shortbow"] = true,
	["sling"] = true
};
aMartialWeapons = {
	["battleaxe"] = true,
	["flail"] = true,
	["glaive"] = true,
	["greataxe"] = true,
	["greatsword"] = true,
	["halberd"] = true,
	["lance"] = true,
	["longsword"] = true,
	["maul"] = true,
	["morningstar"] = true,
	["pike"] = true,
	["rapier"] = true,
	["scimitar"] = true,
	["shortsword"] = true,
	["trident"] = true,
	["war pick"] = true,
	["warhammer"] = true,
	["whip"] = true,
	["blowgun"] = true,
	["hand crossbow"] = true,
	["heavy crossbow"] = true,
	["longbow"] = true,
	["net"] = true,
	["battleaxes"] = true,
	["flails"] = true,
	["glaives"] = true,
	["greataxes"] = true,
	["greatswords"] = true,
	["halberds"] = true,
	["lances"] = true,
	["longswords"] = true,
	["mauls"] = true,
	["morningstars"] = true,
	["pikes"] = true,
	["rapiers"] = true,
	["scimitars"] = true,
	["shortswords"] = true,
	["tridents"] = true,
	["war picks"] = true,
	["warhammers"] = true,
	["whips"] = true,
	["blowguns"] = true,
	["hand crossbows"] = true,
	["heavy crossbows"] = true,
	["longbows"] = true,
	["nets"] = true
};

SPELLSLOTS = {
	{2,0,0,0,0,0,0,0,0},
	{3,0,0,0,0,0,0,0,0},
	{4,2,0,0,0,0,0,0,0},
	{4,3,0,0,0,0,0,0,0},
	{4,3,2,0,0,0,0,0,0},
	{4,3,3,0,0,0,0,0,0},
	{4,3,3,1,0,0,0,0,0},
	{4,3,3,2,0,0,0,0,0},
	{4,3,3,3,1,0,0,0,0},
	{4,3,3,3,2,0,0,0,0},
	{4,3,3,3,2,1,0,0,0},
	{4,3,3,3,2,1,0,0,0},
	{4,3,3,2,1,1,1,0,0},
	{4,3,3,3,2,1,1,0,0},
	{4,3,3,3,2,1,1,1,0},
	{4,3,3,3,2,1,1,1,0},
	{4,3,3,3,2,1,1,1,1},
	{4,3,3,3,3,1,1,1,1},
	{4,3,3,3,3,2,1,1,1},
	{4,3,3,3,3,2,2,1,1}
};

CLASS_CANTRIPS = {
	--Druid/Bard/Warlock/Artificer
	[1] = { 2,2,2,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4 },
	--Cleric/Wizard
	[2] = { 3,3,3,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5,5 },
	--Sorcerer
	[3] = { 4,4,4,5,5,5,5,5,5,6,6,6,6,6,6,6,6,6,6,6 },
	--Eldritch Knight
	[4] = { 0,0,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3 },
	--Arcane Trickster
	[5] = { 0,0,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4 },
};

WARLOCK_SPELLS = {{2,2,1,1,0},{2,3,2,1,2},{2,4,2,2,2},{3,5,2,2,2},{3,6,2,3,3},{3,7,2,3,3},{3,8,2,4,4},{3,9,2,4,4},{3,10,2,5,5},{4,10,2,5,5},{4,11,3,5,5},{4,11,3,5,6},{4,12,3,5,6},{4,12,3,5,6},{4,13,3,5,7},{4,13,3,5,7},{4,14,4,5,7},{4,14,4,5,8},{4,15,4,5,8},{4,15,4,5,8}};

--Spells Known
BARD_SPELLSKNOWN = {4,5,6,7,8,9,10,11,12,14,15,15,16,18,19,19,20,22,22,22};
ELDRITCH_KNIGHT_SPELLSKNOWN = {0,0,3,4,4,4,5,6,6,7,8,8,9,10,10,11,11,11,12,13};
RANGER_SPELLSKNOWN = {0,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11};
ARCANE_TRICKSTER_SPELLSKNOWN = {0,0,3,4,4,4,5,6,6,7,8,8,9,10,10,11,11,11,12,13};
SORCERER_SPELLSKNOWN = {2,3,4,5,6,7,8,9,10,11,12,12,13,13,14,14,15,15,15,15};
WARLOCK_SPELLSKNOWN = {2,3,4,5,6,7,8,9,10,10,11,11,12,12,13,13,14,14,15,15};
WIZARD_SPELLSKNOWN = {6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44};

--Cantrips
ARTIFICER_CANTRIPS = 1;
BARD_CANTRIPS = 1;
CLERIC_CANTRIPS = 2;
DRUID_CANTRIPS = 1;
ELDRITCH_KNIGHT_CANTRIPS = 4;
ARCANE_TRICKSTER_CANTRIPS = 5;
SORCERER_CANTRIPS = 3;
WARLOCK_CANTRIPS = 1;
WIZARD_CANTRIPS = 2;

function onInit()
	charwizard_starting_equipment = {
		["anti paladin"] = {
			starting_wealth = "5d4x10",
			choices = {
				[1] = {
					{ item = "shield", count = 1 },
					{ selection = "martial weapons", count = 2 },
				},
				[2] = {
					{ selection = "martial weapons", count = 2 },
				},
				[3] = {
					{ item = "javelin", count = 5 },
					{ selection = "simple melee weapons", count = 1 },
				},
				[4] = {
					{ item = "priest's pack", count = 1 },
					{ item = "explorer's pack", count = 1 },
				},
				[5] = {
					{ selection = "holy symbol", count = 1 },
				},
			},
			included = {
				{ item = "chain mail", count = 1 },
			},
		},
		["artificer"] = {
			starting_wealth = "5d4x10",
			choices = {
				[1] = {
					{ selection = "simple melee weapons", count = 1 },
					{ selection = "simple ranged weapons", count = 1 },
				},
				[2] = {
					{ selection = "simple melee weapons", count = 1 },
					{ selection = "simple ranged weapons", count = 1 },
				},
				[3] = {
					{ item = "studded leather", count = 1, },
					{ item = "scale mail", count = 1 },
				},
			},
			included = {
				{ item = "crossbow, light", count = 1 },
				{ item = "bolts (20)", count = 1 },
				{ item = "thieves' tools", count = 1 },
				{ item = "dungeoneer's pack", count = 1 },
			},
		},
		["barbarian"] = {
			starting_wealth = "5d4x10",
			choices = {
				[1] = {
					{ selection = "martial weapons", count = 1}
				},
				[2] = {
					{ selection = "simple melee weapons", count = 1 },
				},
				[3] = {
					{ selection = "simple melee weapons", count = 1 },
				},
			},
			included = {
				{ item = "explorer's pack", count = 1 },
				{ item = "javelin", count = 4 },
			},
		},
		["bard"] = {
			starting_wealth = "5d4x10",
			choices = {
				[1] = {
					{ item = "rapier", count = 1 },
					{ item = "longsword", count = 1 },
					{ selection = "simple melee weapons", count = 1 },
					{ selection = "simple ranged weapons", count = 1 },
				},
				[2] = {
					{ item = "diplomat's pack", count = 1 },
					{ item = "entertainer's pack", count = 1 },
				},
				[3] = {
					{ item = "lute", count = 1 },
					{ selection = "musical instrument", count = 1 },
				},
			},
			included = {
				{ item = "leather", count = 1 },
				{ item = "dagger", count = 1 },
			},
		},
		["cleric"] = {
			starting_wealth = "5d4x10",
			choices = {
				[1] = {
					{ item = "mace", count = 1 },
					{ item = "warhammer", count = 1, prof = 1 },
				},
				[2] = {
					{ item = "scale mail", count = 1 },
					{ item = "leather", count = 1 },
					{ item = "chain mail", count = 1, prof = 1 },
				},
				[3] = {
					{ item = "crossbow, light", count = 1, additional = "crossbow bolts (20)" },
					{ selection = "simple melee weapons", count = 1 },
					{ selection = "simple ranged weapons", count = 1 },
				},
				[4] = {
					{ item = "priest's pack", count = 1 },
					{ item = "explorer's pack", count = 1 },
				},
				[5] = {
					{ selection = "holy symbol", count = 1 },
				},
			},
			included = {
				{ item = "shield", count = 1 },
			},
		},
		["druid"] = {
			starting_wealth = "2d4x10",
			choices = {
				[1] = {
					{ item = "shield", count = 1 },
					{ selection = "simple melee weapons", count = 1 },
					{ selection = "simple ranged weapons", count = 1 },
				},
				[2] = {
					{ item = "scimitar", count = 1 },
					{ selection = "simple melee weapon", count = 1 },
				},
				[3] = {
					{ selection = "druidic focus", count = 1 },
				},
			},
			included = {
				{ item = "leather", count = 1 },
				{ item = "explorer's pack", count = 1 },
			},
		},
		["fighter"] = {
			starting_wealth = "5d4x10",
			choices = {
				[1] = {
					{ item = "chain mail", count = 1 },
					{ item = "leather", count = 1 },
				},
				[2] = {
					{ item = "shield", count = 1 },
					{ selection = "martial weapons", count = 1 },
					{ selection = "martial ranged weapons", count = 1 },
				},
				[3] = {
					{ selection = "martial weapons", count = 1 },
					{ selection = "martial ranged weapons", count = 1 },
				},
				[4] = {
					{ item = "crossbow, light", count = 1, additional = "bolts (20)" },
					{ item = "handaxe", count = 2 },
				},
				[5] = {
					{ item = "dungeoneer's pack", count = 1 },
					{ item = "explorer's pack", count = 1 },
				},
			},
			included = {
				{ item = "longbow", count = 1 },
				{ item = "arrows (20)", count = 1 },
			},
		},
		["monk"] = {
			starting_wealth = "5d4",
			choices = {
				[1] = {
					{ item = "shortsword", count = 1 },
					{ selection = "simple melee weapons", count = 1 },
					{ selection = "simple ranged weapons", count = 1 },
				},
				[2] = {
					{ item = "dungeoneer's pack", count = 1 },
					{ item = "explorer's pack", count = 1 },
				},
			},
			included = {
				{ item = "dart", count = 10 },
			},
		},
		["paladin"] = {
			starting_wealth = "5d4x10",
			choices = {
				[1] = {
					{ item = "shield", count = 1},
					{ selection = "martial weapons", count = 1},
				},
				[2] = {
					{ selection = "martial weapons", count = 1 },
				},
				[3] = {
					{ item = "javelin", count = 5 },
					{ selection = "simple melee weapons", count = 1 },
				},
				[4] = {
					{ item = "priest's pack", count = 1 },
					{ item = "explorer's pack", count = 1 },
				},
				[5] = {
					{ selection = "holy symbol", count = 1 },
				},
			},
			included = {
				{ item = "chain mail", count = 1 },
			},
		},
		["ranger"] = {
			starting_wealth = "5d4x10",
			choices = {
				[1] = {
					{ item = "scale mail", count = 1 },
					{ item = "leather", count = 1 },
				},
				[2] = {
					{ item = "shortsword", count = 2 },
					{ selection = "simple melee weapon", count = 1 },
				},
				[3] = {
					{ item = "dungeoneer's pack", count = 1 },
					{ item = "explorer's pack", count = 1 },
				},
			},
			included = {
				{ item = "longbow", count = 1 },
				{ item = "quiver", count = 1 },
				{ item = "arrows (20)", count = 1 },
			},
		},
		["rogue"] = {
			starting_wealth = "4d4x10",
			choices = {
				[1] = {
					{ item = "rapier", count = 1 },
					{ item = "shortsword", count = 1 },
				},
				[2] = {
					{ item = "shortbow", count = 1, additional = {"quiver", "arrows (20)"} },
					{ item = "shortsword", count = 1 },
				},
				[3] = {
					{ item = "burglar's pack", count = 1 },
					{ item = "dungeoneer's pack", count = 1 },
					{ item = "explorer's pack", count = 1 },
				},
			},
			included = {
				{ item = "leather", count = 1 },
				{ item = "dagger", count = 2 },
				{ item = "theives' tools", count = 1 },
			},
		},
		["sorcerer"] = {
			starting_wealth = "3d4x10",
			choices = {
				[1] = {
					{ item = "crossbow, light", count = 1, additional = "bolts (20)" },
					{ selection = "simple melee weapons", count = 1 },
					{ selection = "simple ranged weapons", count = 1 },
				},
				[2] = {
					{ item = "component pouch", count = 1, },
					{ selection = "arcane focus", count = 1 },
				},
				[3] = {
					{ item = "dungeoneer's pack", count = 1 },
					{ item = "explorer's pack", count = 1 },
				},
			},
			included = {
				{ item = "dagger", count = 2 },
			},
		},
		["warlock"] = {
			starting_wealth = "4d4x10",
			choices = {
				[1] = {
					{ item = "crossbow, light", count = 1, additional = "bolts (20)" },
					{ selection = "simple melee weapons", count = 1 },
					{ selection = "simple ranged weapons", count = 1 },
				},
				[2] = {
					{ item = "component pouch", count = 1, },
					{ selection = "arcane focus", count = 1 },
				},
				[3] = {
					{ item = "scholar's pack", count = 1 },
					{ item = "dungeoneer's pack", count = 1 },
				},
				[4] = {
					{ selection = "simple melee weapons", count = 1 },
					{ selection = "simple ranged weapons", count = 1 },
				},
			},
			included = {
				{ item = "leather", count = 1 },
				{ item = "dagger", count = 2 },
			},
		},
		["wizard"] = {
			starting_wealth = "4d4x10",
			choices = {
				[1] = {
					{ item = "quarterstaff", count = 1 },
					{ item = "dagger", count = 1 },
				},
				[2] = {
					{ item = "component pouch", count = 1, },
					{ selection = "arcane focus", count = 1 },
				},
				[3] = {
					{ item = "scholar's pack", count = 1 },
					{ item = "explorer's pack", count = 1 },
				},
			},
			included = {
				{ item = "spellbook", count = 1 },
			},
		},
	};
end

--
-- Registration
--

function registerNewRaceSkill(s)
	aRaceSkill[s] = true;
end
function registerNewRaceProficiency(s)
	aRaceProficiency[s] = true;
end
function registerNewRaceSpecialSpeed(s)
	aRaceSpecialSpeed[s] = true;
end
function registerNewRaceSpells(s)
	aRaceSpells[s] = true;
end
function registerNewRaceLanguages(s)
	aRaceLanguages[s] = true;
end

function registerNewCasterClass(s)
	aCasterClasses[s] = true;
end

function registerNewCharWizardStartingEquipment(s, aEquipment)
	charwizard_starting_equipment[s] = aEquipment;
end

