-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

DEFAULT_DICESKIN_GROUP = "DEFAULT";

WIDGET_PADDING = 2;
WIDGET_SIZE = 16;
WIDGET_HALF_SIZE = 10;

local _tDiceSkinGroups = {
	"DEFAULT",
	"SWKELEMENTALBASICSDICE",
	"SWKMETALDICE",
	"SWKAURADICE",
	"SWKMAGICALDICE",
	"SWKRINGOFELEMENTSDICE",
	"SWKMAGICALTRAILDICE",
	"SWKFORCEFIELDDICE",
	"SWKWIZARDWROUGHTDICE",
	"SWKARTIFICERDICE",
};

local _tDiceSkinGroupStoreID = {
	["SWKMETALDICE"] = "SWKMETALDICE",
	["SWKAURADICE"] = "SWKAURADICE",
	["SWKMAGICALDICE"] = "SWKMAGICALDICE",
	["SWKRINGOFELEMENTSDICE"] = "SWKRINGOFELEMENTSDICE",
	["SWKMAGICALTRAILDICE"] = "SWKMAGICALTRAILDICE",
	["SWKFORCEFIELDDICE"] = "SWKFORCEFIELDDICE",
	["SWKWIZARDWROUGHTDICE"] = "SWKWIZARDWROUGHTDICE",
	["SWKARTIFICERDICE"] = "SWKARTIFICERDICE",
};

local _tDiceSkinToGroupMap = {
	[0] = "DEFAULT",
	[1] = "DEFAULT", [2] = "SWKMETALDICE", [3] = "SWKMETALDICE", [4] = "SWKMETALDICE", [5] = "SWKMETALDICE",
	[6] = "SWKMETALDICE", [7] = "SWKMETALDICE", [8] = "SWKMETALDICE", [9] = "SWKMETALDICE", 
	[10] = "SWKAURADICE", [11] = "SWKAURADICE", [12] = "SWKAURADICE", [13] = "SWKAURADICE", [14] = "SWKAURADICE", 
	[15] = "SWKAURADICE", [16] = "SWKAURADICE", [17] = "SWKAURADICE", [18] = "SWKAURADICE", [19] = "SWKAURADICE", 
	[20] = "SWKAURADICE", [21] = "SWKAURADICE", [22] = "SWKAURADICE", [23] = "SWKAURADICE", [24] = "SWKAURADICE", 
	[25] = "SWKAURADICE", [26] = "SWKAURADICE", [27] = "SWKAURADICE", [28] = "SWKAURADICE", [29] = "SWKAURADICE", 
	[30] = "SWKMAGICALDICE", [31] = "SWKMAGICALDICE", [32] = "SWKMAGICALDICE", [33] = "SWKMAGICALDICE", [34] = "SWKMAGICALDICE", 
	[35] = "SWKMAGICALDICE", [36] = "SWKMAGICALDICE", [37] = "SWKMAGICALDICE", [38] = "SWKMAGICALDICE", [39] = "SWKMAGICALDICE", 
	[40] = "SWKRINGOFELEMENTSDICE", [41] = "SWKRINGOFELEMENTSDICE", [42] = "SWKRINGOFELEMENTSDICE", [43] = "SWKRINGOFELEMENTSDICE", [44] = "SWKRINGOFELEMENTSDICE", 
	[45] = "SWKRINGOFELEMENTSDICE", [46] = "SWKRINGOFELEMENTSDICE", [47] = "SWKRINGOFELEMENTSDICE", [48] = "SWKRINGOFELEMENTSDICE", [49] = "SWKRINGOFELEMENTSDICE", 
	[50] = "SWKRINGOFELEMENTSDICE", [51] = "SWKRINGOFELEMENTSDICE", [52] = "SWKRINGOFELEMENTSDICE", [53] = "SWKRINGOFELEMENTSDICE", [54] = "SWKRINGOFELEMENTSDICE", 
	[55] = "SWKRINGOFELEMENTSDICE", [56] = "SWKRINGOFELEMENTSDICE", [57] = "SWKRINGOFELEMENTSDICE", [58] = "SWKRINGOFELEMENTSDICE", [59] = "SWKRINGOFELEMENTSDICE", 
	[60] = "SWKMAGICALTRAILDICE", [61] = "SWKMAGICALTRAILDICE", [62] = "SWKMAGICALTRAILDICE", [63] = "SWKMAGICALTRAILDICE", [64] = "SWKMAGICALTRAILDICE", 
	[65] = "SWKMAGICALTRAILDICE", [66] = "SWKMAGICALTRAILDICE", [67] = "SWKMAGICALTRAILDICE", [68] = "SWKMAGICALTRAILDICE", [69] = "SWKMAGICALTRAILDICE", 
	[70] = "SWKMAGICALTRAILDICE", [71] = "SWKMAGICALTRAILDICE", [72] = "SWKMAGICALTRAILDICE", [73] = "SWKMAGICALTRAILDICE", [74] = "SWKMAGICALTRAILDICE", 
	[75] = "SWKMAGICALTRAILDICE", [76] = "SWKMAGICALTRAILDICE", [77] = "SWKMAGICALTRAILDICE", [78] = "SWKMAGICALTRAILDICE", [79] = "SWKMAGICALTRAILDICE", 
	[80] = "SWKFORCEFIELDDICE", [81] = "SWKFORCEFIELDDICE", [82] = "SWKFORCEFIELDDICE", [83] = "SWKFORCEFIELDDICE", [84] = "SWKFORCEFIELDDICE", 
	[85] = "SWKFORCEFIELDDICE", [86] = "SWKFORCEFIELDDICE", [87] = "SWKFORCEFIELDDICE", [88] = "SWKFORCEFIELDDICE", [89] = "SWKFORCEFIELDDICE", 
	[90] = "DEFAULT", [91] = "SWKFORCEFIELDDICE", [92] = "SWKMETALDICE", [93] = "SWKMETALDICE",
	[94] = "SWKELEMENTALBASICSDICE", [95] = "SWKELEMENTALBASICSDICE", [96] = "SWKELEMENTALBASICSDICE", [97] = "SWKELEMENTALBASICSDICE", [98] = "SWKELEMENTALBASICSDICE", 
	[99] = "SWKELEMENTALBASICSDICE", [100] = "SWKELEMENTALBASICSDICE", [101] = "SWKELEMENTALBASICSDICE", [102] = "SWKELEMENTALBASICSDICE", [103] = "SWKELEMENTALBASICSDICE", 
	[110] = "SWKWIZARDWROUGHTDICE", [111] = "SWKWIZARDWROUGHTDICE", [112] = "SWKWIZARDWROUGHTDICE", [113] = "SWKWIZARDWROUGHTDICE", [114] = "SWKWIZARDWROUGHTDICE", 
	[115] = "SWKWIZARDWROUGHTDICE", [116] = "SWKWIZARDWROUGHTDICE", [117] = "SWKWIZARDWROUGHTDICE", [118] = "SWKWIZARDWROUGHTDICE", [119] = "SWKWIZARDWROUGHTDICE", 
	[120] = "SWKWIZARDWROUGHTDICE", [121] = "SWKWIZARDWROUGHTDICE", [122] = "SWKWIZARDWROUGHTDICE", [123] = "SWKWIZARDWROUGHTDICE", [124] = "SWKWIZARDWROUGHTDICE", 
	[125] = "SWKWIZARDWROUGHTDICE", 
	[130] = "SWKARTIFICERDICE", [131] = "SWKARTIFICERDICE", [132] = "SWKARTIFICERDICE", [133] = "SWKARTIFICERDICE", [134] = "SWKARTIFICERDICE", 
	[135] = "SWKARTIFICERDICE", [136] = "SWKARTIFICERDICE", [137] = "SWKARTIFICERDICE", [138] = "SWKARTIFICERDICE", [139] = "SWKARTIFICERDICE", 
	[140] = "SWKARTIFICERDICE", [141] = "SWKARTIFICERDICE",
};

local _tDiceSkinAttributeInfo = {
	[0] = {bTintable = true},
	[1] = {bDisabled = true, bTrail = true, sElement = "frost", sIcon = "frost"},
	[2] = {sIcon = "metal_gold"},
	[3] = {sIcon = "metal_darkgold"},
	[4] = {sIcon = "metal_steel"},
	[5] = {sIcon = "metal_pitted", bTintable = true},
	[6] = {sIcon = "metal_polishedsilver", bTintable = true},
	[7] = {sIcon = "metal_rustediron"},
	[8] = {sIcon = "metal_stainedcopper"},
	[9] = {sIcon = "metal_polishedsilver", bTintable = true},
	[10] = {sElement = "arcane", bAuraCast = true},
	[11] = {sElement = "earth", bAuraCast = true},
	[12] = {sElement = "fire",  bAuraCast = true},
	[13] = {sElement = "frost", bAuraCast = true},
	[14] = {sElement = "life", bAuraCast = true},
	[15] = {sElement = "light", bAuraCast = true},
	[16] = {sElement = "lightning", bAuraCast = true},
	[17] = {sElement = "shadow", bAuraCast = true},
	[18] = {sElement = "storm", bAuraCast = true},
	[19] = {sElement = "water", bAuraCast = true},
	[20] = {sElement = "arcane",  bAura = true},
	[21] = {sElement = "earth", bAura = true},
	[22] = {sElement = "fire", bAura = true},
	[23] = {sElement = "frost", bAura = true},
	[24] = {sElement = "life", bAura = true},
	[25] = {sElement = "light", bAura = true},
	[26] = {sElement = "lightning", bAura = true},
	[27] = {sElement = "shadow", bAura = true},
	[28] = {sElement = "storm", bAura = true},
	[29] = {sElement = "water", bAura = true},
	[30] = {sElement = "arcane", bAura = true, bTrail = true},
	[31] = {sElement = "earth", bAura = true, bTrail = true},
	[32] = {sElement = "fire", bAura = true, bTrail = true},
	[33] = {sElement = "frost", bAura = true, bTrail = true},
	[34] = {sElement = "life", bAura = true, bTrail = true},
	[35] = {sElement = "light", bAura = true, bTrail = true},
	[36] = {sElement = "lightning", bAura = true, bTrail = true},
	[37] = {sElement = "shadow", bAura = true, bTrail = true},
	[38] = {sElement = "storm", bAura = true, bTrail = true},
	[39] = {sElement = "water", bAura = true, bTrail = true},
	[40] = {sElement = "arcane", bAura = true},
	[41] = {sElement = "earth", bAura = true},
	[42] = {sElement = "fire", bAura = true},
	[43] = {sElement = "frost", bAura = true},
	[44] = {sElement = "life", bAura = true},
	[45] = {sElement = "light", bAura = true},
	[46] = {sElement = "lightning", bAura = true},
	[47] = {sElement = "shadow", bAura = true},
	[48] = {sElement = "storm", bAura = true},
	[49] = {sElement = "water", bAura = true},
	[50] = {sElement = "arcane",  bAuraCast = true},
	[51] = {sElement = "earth", bAuraCast = true},
	[52] = {sElement = "fire", bAuraCast = true},
	[53] = {sElement = "frost", bAuraCast = true},
	[54] = {sElement = "life", bAuraCast = true},
	[55] = {sElement = "light", bAuraCast = true},
	[56] = {sElement = "lightning", bAuraCast = true},
	[57] = {sElement = "shadow", bAuraCast = true},
	[58] = {sElement = "storm", bAuraCast = true},
	[59] = {sElement = "water", bAuraCast = true},
	[60] = {sElement = "arcane",  bTrail = true},
	[61] = {sElement = "earth", bTrail = true},
	[62] = {sElement = "fire",  bTrail = true},
	[63] = {sElement = "frost", bTrail = true},
	[64] = {sElement = "life", bTrail = true},
	[65] = {sElement = "light", bTrail = true},
	[66] = {sElement = "lightning", bTrail = true},
	[67] = {sElement = "shadow", bTrail = true},
	[68] = {sElement = "storm", bTrail = true},
	[69] = {sElement = "water", bTrail = true},
	[70] = {sElement = "arcane",  bTrail = true},
	[71] = {sElement = "earth", bTrail = true},
	[72] = {sElement = "fire",  bTrail = true},
	[73] = {sElement = "frost", bTrail = true},
	[74] = {sElement = "life", bTrail = true},
	[75] = {sElement = "light", bTrail = true},
	[76] = {sElement = "lightning", bTrail = true},
	[77] = {sElement = "shadow", bTrail = true},
	[78] = {sElement = "storm", bTrail = true},
	[79] = {sElement = "water", bTrail = true},
	[80] = {sElement = "arcane",  bForceField = true},
	[81] = {sElement = "earth", bForceField = true},
	[82] = {sElement = "fire", bForceField = true},
	[83] = {sElement = "frost", bForceField = true},
	[84] = {sElement = "life", bForceField = true},
	[85] = {sElement = "light", bForceField = true},
	[86] = {sElement = "lightning", bForceField = true},
	[87] = {sElement = "shadow", bForceField = true},
	[88] = {sElement = "storm", bForceField = true},
	[89] = {sElement = "water", bForceField = true},
	[90] = {bDisabled = true, sElement = "earth", bTrail = true},
	[91] = {bForceField = true, bTintable = true},
	[92] = {sIcon = "metal_rustediron", bTintable = true},
	[93] = {sIcon = "metal_stainedcopper", bTintable = true},
	[94] = {sElement = "arcane"},
	[95] = {sElement = "earth"},
	[96] = {sElement = "fire"},
	[97] = {sElement = "frost"},
	[98] = {sElement = "life"},
	[99] = {sElement = "light"},
	[100] = {sElement = "lightning"},
	[101] = {sElement = "shadow"},
	[102] = {sElement = "storm"},
	[103] = {sElement = "water"},
	[110] = {sIcon = "decorative_base", bDecorative = true, bTintable = true},
	[111] = {sIcon = "decorative_base_inverted", bDecorative = true, bTintable = true},
	[112] = {sIcon = "decorative_storm", bDecorative = true, sElement = "storm"},
	[113] = {sIcon = "decorative_storm_inverted", bDecorative = true, sElement = "storm"},
	[114] = {sIcon = "decorative_water", bDecorative = true, sElement = "water"},
	[115] = {sIcon = "decorative_water_inverted", bDecorative = true, sElement = "water"},
	[116] = {sIcon = "decorative_iron", bDecorative = true},
	[117] = {sIcon = "decorative_iron_inverted", bDecorative = true},
	[118] = {sIcon = "decorative_bark", bDecorative = true},
	[119] = {sIcon = "decorative_bark_inverted", bDecorative = true},
	[120] = {sIcon = "decorative_gold_white", bDecorative = true},
	[121] = {sIcon = "decorative_gold_white_inverted", bDecorative = true},
	[122] = {sIcon = "decorative_gold_antique", bDecorative = true},
	[123] = {sIcon = "decorative_gold_antique_inverted", bDecorative = true},
	[124] = {sIcon = "decorative_gold_green", bDecorative = true},
	[125] = {sIcon = "decorative_gold_green_inverted", bDecorative = true},
	[130] = {sIcon = "artificer_base", bArtificer = true, bTintable = true},
	[131] = {sIcon = "artificer_nightshade", bArtificer = true},
	[132] = {sIcon = "artificer_bark", bArtificer = true},
	[133] = {sIcon = "artificer_darkgold", bArtificer = true},
	[134] = {sIcon = "artificer_gold", bArtificer = true},
	[135] = {sIcon = "artificer_whitegold", bArtificer = true},
	[136] = {sIcon = "artificer_rustediron", bArtificer = true},
	[137] = {sIcon = "artificer_greeniron", bArtificer = true},
	[138] = {sIcon = "artificer_stainedcopper", bArtificer = true},
	[139] = {sIcon = "artificer_storm", bArtificer = true},
	[140] = {sIcon = "artificer_greengilt", bArtificer = true},
	[141] = {sIcon = "artificer_liquiddream", bArtificer = true},
};

local _tDiceSkinInfo = {};

function onInit()
	local tDiceSkins = Interface.getDiceSkins();
	for _,v in pairs(tDiceSkins) do
		local tData = _tDiceSkinAttributeInfo[v];
		if not tData or not tData.bDisabled then
			local tInfo = Interface.getDiceSkinInfo(v);
			if tData then
				for k,v in pairs(tData) do
					tInfo[k] = v;
				end
			end
			_tDiceSkinInfo[v] = tInfo;
		end
	end
end

function getAllDiceSkins()
	return _tDiceSkinInfo;
end
function isDiceSkinOwned(nID)
	if nID == 0 then
		return true;
	end
	if _tDiceSkinInfo[nID] then
		return _tDiceSkinInfo[nID].owned or false;
	end
	return false;
end
function isDiceSkinTintable(nID)
	if nID == 0 then
		return true;
	end
	if _tDiceSkinInfo[nID] then
		return _tDiceSkinInfo[nID].bTintable or false;
	end
	return true;
end

function getDiceSkinGroups()
	return _tDiceSkinGroups;
end
function getDiceSkinGroup(nID)
	return _tDiceSkinToGroupMap[nID] or DiceSkinManager.DEFAULT_DICESKIN_GROUP;
end

function getDiceSkinGroupName(nID)
	return Interface.getString("diceskin_group_" .. DiceSkinManager.getDiceSkinGroup(nID));
end
function getDiceSkinName(nID)
	local sName = Interface.getString("diceskin_" .. nID);
	if (sName or "") == "" then
		sName = string.format("%s (%d)", Interface.getString("diceskin_unknown"), nID);
	end
	return sName;
end

function getDiceSkinIcon(nID)
	if nID > 0 then
		local tInfo = _tDiceSkinInfo[nID];
		if tInfo and tInfo.sIcon then
			return "diceskin_icon_" .. tInfo.sIcon;
		elseif tInfo and tInfo.sElement then
			return "diceskin_icon_element_" .. tInfo.sElement;
		end
	end
	return "diceskin_icon_default";
end

--
--	COLOR WINDOW HANDLING
--

function populateDiceSelectWindow(w)
	local tDiceSkinGroupWindows = {};

	-- Create dice skin group windows
	local tDiceSkinGroups = DiceSkinManager.getDiceSkinGroups();
	for k,v in ipairs(tDiceSkinGroups) do
		local wDiceSkinGroup = w.list_skin.createWindow();
		wDiceSkinGroup.setData(k, v);
		tDiceSkinGroupWindows[v] = wDiceSkinGroup;
	end

	for nID, tInfo in pairs(DiceSkinManager.getAllDiceSkins()) do
		-- Get correct dice skin group window
		local sDiceSkinGroup = DiceSkinManager.getDiceSkinGroup(nID);
		local wDiceSkinGroup = tDiceSkinGroupWindows[sDiceSkinGroup];
		if not wDiceSkinGroup then
			wDiceSkinGroup = tDiceSkinGroupWindows[DiceSkinManager.DEFAULT_DICESKIN_GROUP];
		end

		-- Add dice skin list entry
		local wDiceSkin = wDiceSkinGroup.list.createWindow();
		wDiceSkin.setData(nID, tInfo);
		if wDiceSkin.isOwned() then
			wDiceSkinGroup.setOwned();
		end
	end

	local tDeleteSkinGroups = {};
	for _,wDiceSkinGroup in ipairs(w.list_skin.getWindows()) do
		if wDiceSkinGroup.list.isEmpty() then
			table.insert(tDeleteSkinGroups, wDiceSkinGroup);
		end
	end
	for _,wDiceSkinGroup in ipairs(tDeleteSkinGroups) do
		wDiceSkinGroup.close();
	end
end

function setupDiceSelectButton(cButton, nID)
	cButton.setIcons(DiceSkinManager.getDiceSkinIcon(nID));
	cButton.setTooltipText(DiceSkinManager.getDiceSkinName(nID));

	DiceSkinManager.setupButtonTintableWidget(cButton, nID);
	DiceSkinManager.setupButtonGeneralWidgets(cButton, nID)
end
function setupCustomButton(cButton, tColor)
	cButton.setIcons(DiceSkinManager.getDiceSkinIcon(tColor.diceskin));
	cButton.setTooltipText(DiceSkinManager.getDiceSkinName(tColor.diceskin));

	DiceSkinManager.setupButtonColorWidgets(cButton, tColor);
	DiceSkinManager.setupButtonGeneralWidgets(cButton, tColor.diceskin)
end

function setupButtonTintableWidget(cButton, nID)
	local tInfo = _tDiceSkinInfo[nID];

	-- Tintable
	if tInfo and tInfo.bTintable then
		cButton.addBitmapWidget({
			icon = "diceskin_attribute_tintable", position="topright",
			x = -(DiceSkinManager.WIDGET_PADDING + DiceSkinManager.WIDGET_HALF_SIZE),
			y = (DiceSkinManager.WIDGET_PADDING + DiceSkinManager.WIDGET_HALF_SIZE),
			w = DiceSkinManager.WIDGET_SIZE,
			h = DiceSkinManager.WIDGET_SIZE,
		});
	end
end
function setupButtonColorWidgets(cButton, tColor)
	local tInfo = _tDiceSkinInfo[tColor.diceskin];

	-- Tintable
	if tInfo and tInfo.bTintable then
		local tWidget = {
			icon = "colorgizmo_bigbtn_base", position="topright",
			x = -(DiceSkinManager.WIDGET_PADDING + DiceSkinManager.WIDGET_HALF_SIZE),
			y = (DiceSkinManager.WIDGET_PADDING + DiceSkinManager.WIDGET_HALF_SIZE),
			w = DiceSkinManager.WIDGET_SIZE,
			h = DiceSkinManager.WIDGET_SIZE,
		};

		tWidget.icon = "colorgizmo_bigbtn_base";
		cButton.addBitmapWidget(tWidget);

		tWidget.icon = "colorgizmo_bigbtn_color";
		tWidget.color = tColor.dicebodycolor;
		cButton.addBitmapWidget(tWidget);
		
		tWidget.icon = "colorgizmo_bigbtn_effects";
		tWidget.color = nil;
		cButton.addBitmapWidget(tWidget);

		tWidget.y = (DiceSkinManager.WIDGET_PADDING + DiceSkinManager.WIDGET_SIZE + DiceSkinManager.WIDGET_HALF_SIZE);

		tWidget.icon = "colorgizmo_bigbtn_base";
		cButton.addBitmapWidget(tWidget);

		tWidget.icon = "colorgizmo_bigbtn_color";
		tWidget.color = tColor.dicetextcolor;
		cButton.addBitmapWidget(tWidget);
		
		tWidget.icon = "colorgizmo_bigbtn_effects";
		tWidget.color = nil;
		cButton.addBitmapWidget(tWidget);
	end
end
function setupButtonGeneralWidgets(cButton, nID)
	local tInfo = _tDiceSkinInfo[nID];

	-- Element
	if tInfo and tInfo.sElement then
		cButton.addBitmapWidget({
			icon = "diceskin_element_" .. tInfo.sElement, position="bottomright",
			x = -(DiceSkinManager.WIDGET_PADDING + DiceSkinManager.WIDGET_HALF_SIZE),
			y = -(DiceSkinManager.WIDGET_PADDING + DiceSkinManager.WIDGET_HALF_SIZE),
			w = DiceSkinManager.WIDGET_SIZE,
			h = DiceSkinManager.WIDGET_SIZE,
		});
	end
	
	-- Attributes
	if tInfo then
		local tWidget = {
			position="topleft", 
			x = DiceSkinManager.WIDGET_PADDING + DiceSkinManager.WIDGET_HALF_SIZE,
			y = DiceSkinManager.WIDGET_PADDING + DiceSkinManager.WIDGET_HALF_SIZE,
			w = DiceSkinManager.WIDGET_SIZE,
			h = DiceSkinManager.WIDGET_SIZE,
		};

		if tInfo.bArtificer then
			tWidget.icon = "diceskin_attribute_artificer";
			cButton.addBitmapWidget(tWidget);
			tWidget.y = tWidget.y + DiceSkinManager.WIDGET_PADDING + DiceSkinManager.WIDGET_SIZE;
		end
		if tInfo.bDecorative then
			tWidget.icon = "diceskin_attribute_decorative";
			cButton.addBitmapWidget(tWidget);
			tWidget.y = tWidget.y + DiceSkinManager.WIDGET_PADDING + DiceSkinManager.WIDGET_SIZE;
		end
		if tInfo.bAura then
			tWidget.icon = "diceskin_attribute_aura";
			cButton.addBitmapWidget(tWidget);
			tWidget.y = tWidget.y + DiceSkinManager.WIDGET_PADDING + DiceSkinManager.WIDGET_SIZE;
		end
		if tInfo.bAuraCast then
			tWidget.icon = "diceskin_attribute_auracast";
			cButton.addBitmapWidget(tWidget);
			tWidget.y = tWidget.y + DiceSkinManager.WIDGET_PADDING + DiceSkinManager.WIDGET_SIZE;
		end
		if tInfo.bForceField then
			tWidget.icon = "diceskin_attribute_forcefield";
			cButton.addBitmapWidget(tWidget);
			tWidget.y = tWidget.y + DiceSkinManager.WIDGET_PADDING + DiceSkinManager.WIDGET_SIZE;
		end
		if tInfo.bImpact then
			tWidget.icon = "diceskin_attribute_impact";
			cButton.addBitmapWidget(tWidget);
			tWidget.y = tWidget.y + DiceSkinManager.WIDGET_PADDING + DiceSkinManager.WIDGET_SIZE;
		end
		if tInfo.bTrail then
			tWidget.icon = "diceskin_attribute_trail";
			cButton.addBitmapWidget(tWidget);
			tWidget.y = tWidget.y + DiceSkinManager.WIDGET_PADDING + DiceSkinManager.WIDGET_SIZE;
		end
	end
end

function onDiceSelectButtonActivate(nID)
	if DiceSkinManager.isDiceSkinOwned(nID) then
		UserManager.setDiceSkin(nID);
	else
		local sDiceSkinGroup = DiceSkinManager.getDiceSkinGroup(nID);
		if _tDiceSkinGroupStoreID[sDiceSkinGroup] then
			UtilityManager.sendToStoreDLC(_tDiceSkinGroupStoreID[sDiceSkinGroup]);
		end
	end
end
function onDiceSelectButtonDrag(draginfo, nID)
	draginfo.setType("diceskin");
	draginfo.setIcon(DiceSkinManager.getDiceSkinIcon(nID));
	draginfo.setDescription(DiceSkinManager.getDiceSkinName(nID));

	local tDiceSkinData = { nID, UserManager.getDiceBodyColor(), UserManager.getDiceTextColor() };
	draginfo.setStringData(table.concat(tDiceSkinData, "|"));

	return true;
end
