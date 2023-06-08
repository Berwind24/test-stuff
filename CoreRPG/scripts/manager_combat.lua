-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

OOB_MSGTYPE_ENDTURN = "endturn";

CT_MAIN_PATH = "combattracker";
CT_COMBATANT_PATH = "combattracker.list.*";
CT_COMBATANT_PARENT = "combattracker.list";
CT_LIST = "combattracker.list";
CT_ROUND = "combattracker.round";

local sActiveCT = nil;

function onTabletopInit()
	CombatManager.registerStandardCombatHotKeys();

	OOBManager.registerOOBMsgHandler(CombatManager.OOB_MSGTYPE_ENDTURN, CombatManager.handleEndTurn);
	DB.addHandler(CombatManager.CT_COMBATANT_PATH, "onDelete", CombatManager.onDeleteCombatantEvent);
	DB.addHandler(CombatManager.CT_COMBATANT_PARENT, "onChildDeleted", CombatManager.onPostDeleteCombatantEvent);
	DB.addHandler(DB.getPath(CombatManager.CT_COMBATANT_PATH, "effects"), "onChildAdded", CombatManager.onAddCombatantEffectEvent);
	DB.addHandler(DB.getPath(CombatManager.CT_COMBATANT_PATH, "effects"), "onChildDeleted", CombatManager.onDeleteCombatantEffectEvent);
	if Session.IsHost then
		DB.addHandler("charsheet.*", "onDelete", CombatManager.onCharDelete);
		OptionsManager.registerCallback("TPTY", onOptionTokenPartyVisionMoveChanged);
		OptionsManager.registerCallback("TFOW", onOptionTokenFOWChanged);
	end
end

local _bInitHotKey = false;
function registerStandardCombatHotKeys()
	if _bInitHotKey then
		return;
	end

	Interface.addKeyedEventHandler("onHotkeyActivated", "combattrackernextactor", CombatManager.onHotKeyNextActor);
	Interface.addKeyedEventHandler("onHotkeyActivated", "combattrackernextround", CombatManager.onHotKeyNextRound);

	_bInitHotKey = true;
end
function onHotKeyNextActor()
	if Session.IsHost then
		CombatManager.nextActor();
	else
		CombatManager.notifyEndTurn();
	end
	return true;
end
function onHotKeyNextRound()
	if Session.IsHost then
		CombatManager.nextRound(1);
	end
	return true;
end

function onOptionTokenPartyVisionMoveChanged()
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		TokenManager.updateVisibility(v);
		TokenManager.updateFaction(DB.createChild(v, "friendfoe"));
	end
end

function onOptionTokenFOWChanged()
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		TokenManager.updateFaction(DB.createChild(v, "friendfoe"));
	end
end

--
-- COMBATANT HANDLERS
-- NOTE: Combatant list/count handler is single linked, combat event handlers are multi-linked, and field handlers are unmanaged (ruleset code must add/remove)
--

local fCustomGetCombatantNodes = nil;
function setCustomGetCombatantNodes(f)
	fCustomGetCombatantNodes = f;
end

-- NOTE: Pre-delete events are only triggered when removing combatants through UI
local aCustomPreDeleteCombatantHandlers = {};
function setCustomPreDeleteCombatantHandler(fn)
	table.insert(aCustomPreDeleteCombatantHandlers, fn);
end
function removeCustomPreDeleteCombatantHandler(fn)
	for kCustomDelete,fCustomDelete in ipairs(aCustomPreDeleteCombatantHandlers) do
		if fCustomDelete == fn then
			table.remove(aCustomPreDeleteCombatantHandlers, kCustomDelete);
			return true;
		end
	end
	return false;
end
function onPreDeleteCombatantEvent(nodeCT)
	for _,fn in ipairs(aCustomPreDeleteCombatantHandlers) do
		if fn(nodeCT) then
			return true;
		end
	end
	return false;
end

local aCustomDeleteCombatantHandlers = {};
function setCustomDeleteCombatantHandler(f)
	table.insert(aCustomDeleteCombatantHandlers, f);
end
function removeCustomDeleteCombatantHandler(f)
	for kCustomDelete,fCustomDelete in ipairs(aCustomDeleteCombatantHandlers) do
		if fCustomDelete == f then
			table.remove(aCustomDeleteCombatantHandlers, kCustomDelete);
			return true;
		end
	end
	return false;
end
function onDeleteCombatantEvent(nodeCT)
	for _,fCustomDelete in ipairs(aCustomDeleteCombatantHandlers) do
		if fCustomDelete(nodeCT) then
			return true;
		end
	end
	return false;
end

local aCustomPostDeleteCombatantHandlers = {};
function setCustomPostDeleteCombatantHandler(fn)
	table.insert(aCustomPostDeleteCombatantHandlers, fn);
end
function removeCustomPostDeleteCombatantHandler(fn)
	for kCustomDelete,fCustomDelete in ipairs(aCustomPostDeleteCombatantHandlers) do
		if fCustomDelete == fn then
			table.remove(aCustomPostDeleteCombatantHandlers, kCustomDelete);
			return true;
		end
	end
	return false;
end
function onPostDeleteCombatantEvent()
	for _,fn in ipairs(aCustomPostDeleteCombatantHandlers) do
		fn();
	end
end

local aCustomAddCombatantEffectHandlers = {};
function setCustomAddCombatantEffectHandler(f)
	table.insert(aCustomAddCombatantEffectHandlers, f);
end
function removeCustomAddCombatantEffectHandler(f)
	for kCustomAdd,fCustomAdd in ipairs(aCustomAddCombatantEffectHandlers) do
		if fCustomAdd == f then
			table.remove(aCustomAddCombatantEffectHandlers, kCustomAdd);
			return true;
		end
	end
	return false;
end
function onAddCombatantEffectEvent(nodeEffectList, nodeEffect)
	for _,fCustomAdd in ipairs(aCustomAddCombatantEffectHandlers) do
		if fCustomAdd(DB.getParent(nodeEffectList), nodeEffect) then
			return true;
		end
	end
	return false;
end

local aCustomDeleteCombatantEffectHandlers = {};
function setCustomDeleteCombatantEffectHandler(f)
	table.insert(aCustomDeleteCombatantEffectHandlers, f);
end
function removeCustomDeleteCombatantEffectHandler(f)
	for kCustomDelete,fCustomDelete in ipairs(aCustomDeleteCombatantEffectHandlers) do
		if fCustomDelete == f then
			table.remove(aCustomDeleteCombatantEffectHandlers, kCustomDelete);
			return true;
		end
	end
	return false;
end
function onDeleteCombatantEffectEvent(nodeEffectList)
	local nodeCT = DB.getChild(nodeEffectList, "..");
	for _,fCustomDelete in ipairs(aCustomDeleteCombatantEffectHandlers) do
		if fCustomDelete(nodeCT) then
			return true;
		end
	end
	return false;
end

function addCombatantFieldChangeHandler(sField, sEvent, f)
	DB.addHandler(DB.getPath(CombatManager.CT_COMBATANT_PATH, sField), sEvent, f);
end
function removeCombatantFieldChangeHandler(sField, sEvent, f)
	DB.removeHandler(DB.getPath(CombatManager.CT_COMBATANT_PATH, sField), sEvent, f);
end
function addCombatantEffectFieldChangeHandler(sField, sEvent, f)
	DB.addHandler(DB.getPath(CombatManager.CT_COMBATANT_PATH, "effects.*", sField), sEvent, f);
end
function removeCombatantEffectFieldChangeHandler(sField, sEvent, f)
	DB.removeHandler(DB.getPath(CombatManager.CT_COMBATANT_PATH, "effects.*", sField), sEvent, f);
end

--
-- MULTI HANDLERS
-- NOTE: Handlers added here will all be called in the order they were added.
--

local aCustomRoundStart = {};
function setCustomRoundStart(fRoundStart)
	table.insert(aCustomRoundStart, fRoundStart);
end
function onRoundStartEvent(nCurrent)
	if #aCustomRoundStart > 0 then
		for _,fCustomRoundStart in ipairs(aCustomRoundStart) do
			fCustomRoundStart(nCurrent);
		end
	end
end

local aCustomTurnStart = {};
function setCustomTurnStart(fTurnStart)
	table.insert(aCustomTurnStart, fTurnStart);
end
function onTurnStartEvent(nodeCT)
	if #aCustomTurnStart > 0 then
		for _,fCustomTurnStart in ipairs(aCustomTurnStart) do
			fCustomTurnStart(nodeCT);
		end
	end
end

local aCustomTurnEnd = {};
function setCustomTurnEnd(fTurnEnd)
	table.insert(aCustomTurnEnd, fTurnEnd);
end
function onTurnEndEvent(nodeCT)
	if #aCustomTurnEnd > 0 then
		for _,fCustomTurnEnd in ipairs(aCustomTurnEnd) do
			fCustomTurnEnd(nodeCT);
		end
	end
end

local aCustomInitChange = {};
function setCustomInitChange(fInitChange)
	table.insert(aCustomInitChange, fInitChange);
end
function onInitChangeEvent(nodeOldCT, nodeNewCT)
	if #aCustomInitChange > 0 then
		for _,fCustomInitChange in ipairs(aCustomInitChange) do
			fCustomInitChange(nodeOldCT, nodeNewCT);
		end
	end
end

local aCustomCombatReset = {};
function setCustomCombatReset(fCombatReset)
	table.insert(aCustomCombatReset, fCombatReset);
end
function onCombatResetEvent()
	if #aCustomCombatReset > 0 then
		for _,fCustomCombatReset in ipairs(aCustomCombatReset) do
			fCustomCombatReset();
		end
	end
end

--
-- SINGLE HANDLERS
-- NOTE: Setting these handlers will override previous handlers
--

local fCustomSort = nil;
function setCustomSort(fSort)
	fCustomSort = fSort;
end
function getCustomSort()
	return fCustomSort;
end
-- NOTE: Lua sort function expects the opposite boolean value compared to built-in FG sorting
function onSortCompare(node1, node2)
	if fCustomSort then
		return not fCustomSort(node1, node2);
	end
	
	return not CombatManager.sortfuncSimple(node1, node2);
end

--
-- GENERAL
--

function createCombatantNode()
	DB.createNode(CombatManager.CT_LIST);
	return DB.createChild(CombatManager.CT_LIST);
end

function getCombatantNodes()
	if fCustomGetCombatantNodes then
		return fCustomGetCombatantNodes();
	end
	return DB.getChildren(CombatManager.CT_LIST);
end

function getActiveCT()
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		if DB.getValue(v, "active", 0) == 1 then
			return v;
		end
	end
	return nil;
end

function getCTFromNode(varNode)
	-- Get path name desired
	local sNode;
	if type(varNode) == "string" then
		sNode = varNode;
	elseif type(varNode) == "databasenode" then
		sNode = DB.getPath(varNode);
	else
		return nil;
	end
	
	local tCombatantList = CombatManager.getCombatantNodes();

	-- Check for exact CT match
	for _,v in pairs(tCombatantList) do
		if DB.getPath(v) == sNode then
			return v;
		end
	end

	-- Otherwise, check for link match
	for _,v in pairs(tCombatantList) do
		local sClass, sRecord = DB.getValue(v, "link", "", "");
		if sRecord == sNode then
			return v;
		end
	end

	return nil;
end

function getCTFromTokenRef(vContainer, nId)
	local sContainerNode = nil;
	if type(vContainer) == "string" then
		sContainerNode = vContainer;
	elseif type(vContainer) == "databasenode" then
		sContainerNode = DB.getPath(vContainer);
	else
		return nil;
	end
	
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		local sCTContainerName = DB.getValue(v, "tokenrefnode", "");
		local nCTId = tonumber(DB.getValue(v, "tokenrefid", "")) or 0;
		if (sCTContainerName == sContainerNode) and (nCTId == nId) then
			return v;
		end
	end
	
	return nil;
end

function getCTFromToken(token)
	if not token then
		return nil;
	end
	
	local nodeContainer = token.getContainerNode();
	local nID = token.getId();

	return CombatManager.getCTFromTokenRef(nodeContainer, nID);
end

function getTokenFromCT(vEntry)
	local nodeCT = nil;
	if type(vEntry) == "string" then
		nodeCT = DB.findNode(vEntry);
	elseif type(vEntry) == "databasenode" then
		nodeCT = vEntry;
	end
	if not nodeCT then
		return nil;
	end
	
	return Token.getToken(DB.getValue(nodeCT, "tokenrefnode", ""), DB.getValue(nodeCT, "tokenrefid", ""));
end

function getFactionFromCT(vEntry)
	local nodeCT = nil;
	if type(vEntry) == "string" then
		nodeCT = DB.findNode(vEntry);
	elseif type(vEntry) == "databasenode" then
		nodeCT = vEntry;
	end
	if not nodeCT then
		return nil;
	end
	
	return DB.getValue(nodeCT, "friendfoe", "");
end

function getTokenVisibilityFromCT(vEntry)
	local nodeCT = nil;
	if type(vEntry) == "string" then
		nodeCT = DB.findNode(vEntry);
	elseif type(vEntry) == "databasenode" then
		nodeCT = vEntry;
	end
	if not nodeCT then
		return true;
	end
	
	return (DB.getValue(nodeCT, "tokenvis", 0) == 1);
end

function getCurrentUserCT()
	if Session.IsHost then
		return CombatManager.getActiveCT();
	end
	
	-- If active identity is owned, then use that one
	local nodeActive = CombatManager.getActiveCT();
	local sClass, sRecord = DB.getValue(nodeActive, "link", "npc", "");
	if sClass == "charsheet" then
		local aOwned = User.getOwnedIdentities();
		for _,v in ipairs(aOwned) do
			if sRecord == ("charsheet." .. v) then
				return nodeActive;
			end
		end
	end
	
	-- Otherwise, use active identity (if any)
	local sID = User.getCurrentIdentity();
	if sID then
		return CombatManager.getCTFromNode("charsheet." .. sID);
	end

	return nil;
end

function openMap(vNode)
	local nodeCT = CombatManager.getCTFromNode(vNode);
	if not nodeCT then 
		return; 
	end
	CombatManager.centerOnToken(nodeCT, true);
end

function isCTHidden(vEntry)
	local nodeCT = nil;
	if type(vEntry) == "string" then
		nodeCT = DB.findNode(vEntry);
	elseif type(vEntry) == "databasenode" then
		nodeCT = vEntry;
	end
	if not nodeCT then
		return false;
	end
	
	if CombatManager.getFactionFromCT(nodeCT) == "friend" then
		return false;
	end
	if CombatManager.getTokenVisibilityFromCT(nodeCT) then
		return false;
	end
	return true;
end

function onCharDelete(nodeChar)
	if not Session.IsHost then
		return;
	end

	local nodeCT = CombatManager.getCTFromNode(nodeChar);
	if nodeCT then
		DB.setValue(nodeCT, "link", "windowreference", "npc", "");
	end
end

function onTokenDelete(tokenMap)
	local nodeCT = CombatManager.getCTFromToken(tokenMap);
	if nodeCT then
		DB.setValue(nodeCT, "tokenrefnode", "string", "");
		DB.setValue(nodeCT, "tokenrefid", "string", "");
	end
end

--
-- COMBAT TRACKER SORT
--
-- NOTE: Lua sort function expects the opposite boolean value compared to built-in FG sorting
--

function sortfuncSimple(node1, node2)
	return DB.getPath(node1) < DB.getPath(node2);
end

function sortfuncStandard(node1, node2)
	local bHost = Session.IsHost;
	local sOptCTSI = OptionsManager.getOption("CTSI");
	
	local sFaction1 = DB.getValue(node1, "friendfoe", "");
	local sFaction2 = DB.getValue(node2, "friendfoe", "");
	
	local bShowInit1 = bHost or ((sOptCTSI == "friend") and (sFaction1 == "friend")) or (sOptCTSI == "on");
	local bShowInit2 = bHost or ((sOptCTSI == "friend") and (sFaction2 == "friend")) or (sOptCTSI == "on");
	
	if bShowInit1 ~= bShowInit2 then
		if bShowInit1 then
			return true;
		elseif bShowInit2 then
			return false;
		end
	else
		if bShowInit1 then
			local nValue1 = DB.getValue(node1, "initresult", 0);
			local nValue2 = DB.getValue(node2, "initresult", 0);
			if nValue1 ~= nValue2 then
				return nValue1 > nValue2;
			end
		else
			if sFaction1 ~= sFaction2 then
				if sFaction1 == "friend" then
					return true;
				elseif sFaction2 == "friend" then
					return false;
				end
			end
		end
	end
	
	local sValue1 = DB.getValue(node1, "name", "");
	local sValue2 = DB.getValue(node2, "name", "");
	if sValue1 ~= sValue2 then
		return sValue1 < sValue2;
	end

	return DB.getPath(node1) < DB.getPath(node2);
end

function sortfuncDnD(node1, node2)
	local bHost = Session.IsHost;
	local sOptCTSI = OptionsManager.getOption("CTSI");
	
	local sFaction1 = DB.getValue(node1, "friendfoe", "");
	local sFaction2 = DB.getValue(node2, "friendfoe", "");
	
	local bShowInit1 = bHost or ((sOptCTSI == "friend") and (sFaction1 == "friend")) or (sOptCTSI == "on");
	local bShowInit2 = bHost or ((sOptCTSI == "friend") and (sFaction2 == "friend")) or (sOptCTSI == "on");
	
	if bShowInit1 ~= bShowInit2 then
		if bShowInit1 then
			return true;
		elseif bShowInit2 then
			return false;
		end
	else
		if bShowInit1 then
			local nValue1 = DB.getValue(node1, "initresult", 0);
			local nValue2 = DB.getValue(node2, "initresult", 0);
			if nValue1 ~= nValue2 then
				return nValue1 > nValue2;
			end
			
			nValue1 = DB.getValue(node1, "init", 0);
			nValue2 = DB.getValue(node2, "init", 0);
			if nValue1 ~= nValue2 then
				return nValue1 > nValue2;
			end
		else
			if sFaction1 ~= sFaction2 then
				if sFaction1 == "friend" then
					return true;
				elseif sFaction2 == "friend" then
					return false;
				end
			end
		end
	end
	
	local sValue1 = DB.getValue(node1, "name", "");
	local sValue2 = DB.getValue(node2, "name", "");
	if sValue1 ~= sValue2 then
		return sValue1 < sValue2;
	end

	return DB.getPath(node1) < DB.getPath(node2);
end

function getSortedCombatantList()
	local aEntries = {};
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		table.insert(aEntries, v);
	end
	if #aEntries > 0 then
		if fCustomSort then
			table.sort(aEntries, fCustomSort);
		else
			table.sort(aEntries, sortfuncSimple);
		end
	end
	return aEntries;
end

--
-- TURN FUNCTIONS
--

function handleEndTurn(msgOOB)
	local rActor = ActorManager.resolveActor(getActiveCT());
	local nodeActor = ActorManager.getCreatureNode(rActor);
	if nodeActor and DB.getOwner(nodeActor) == msgOOB.user then
		CombatManager.nextActor();
	end
end

function notifyEndTurn()
	local msgOOB = {};
	msgOOB.type = CombatManager.OOB_MSGTYPE_ENDTURN;
	msgOOB.user = Session.UserName;

	Comm.deliverOOBMessage(msgOOB, "");
end

function addGMIdentity(nodeEntry)
	if OptionsManager.isOption("CTAV", "on") then
		local sName = ActorManager.getDisplayName(nodeEntry);
		local sClass,_ = DB.getValue(nodeEntry, "link", "", "");
		
		if sClass == "charsheet" or sName == "" then
			sActiveCT = nil;
			GmIdentityManager.activateGMIdentity();
		else
			if GmIdentityManager.existsIdentity(sName) then
				sActiveCT = nil;
				GmIdentityManager.setCurrent(sName);
			else
				sActiveCT = sName;
				GmIdentityManager.addIdentity(sName);
			end
		end
	end
end

function clearGMIdentity()
	if sActiveCT then
		GmIdentityManager.removeIdentity(sActiveCT);
		sActiveCT = nil;
	end
end

-- Handle turn notification (including bell ring based on option)
function showTurnMessage(nodeEntry, bActivate, bSkipBell)
	if not Session.IsHost then
		return;
	end

	local rActor = ActorManager.resolveActor(nodeEntry);
	local sName = ActorManager.getDisplayName(rActor);
	local sFaction = ActorManager.getFaction(rActor);

	local msgGM = {font = "narratorfont", icon = "turn_flag"};
	msgGM.text = string.format("[%s] %s", Interface.getString("combat_tag_turn"), sName);

	local msgPlayer = {font = "narratorfont", icon = "turn_flag"};
	msgPlayer.text = msgGM.text;

	if OptionsManager.isOption("RSHE", "on") then
		if sFaction == "friend" then
			local sEffects = EffectManager.getEffectsString(nodeEntry, true);
			if sEffects ~= "" then
				msgPlayer.text = msgPlayer.text .. " - [" .. sEffects .. "]";
			end
		end
		local sEffectsGM = EffectManager.getEffectsString(nodeEntry, false);
		if sEffectsGM ~= "" then
			msgGM.text = msgGM.text .. " - [" .. sEffectsGM .. "]";
		end
	end

	local sOptRSHT = OptionsManager.getOption("RSHT");
	local bShowPlayerMessage = bActivate and ((sOptRSHT == "all") or ((sOptRSHT == "on") and (sFaction == "friend")));

	msgGM.secret = not bShowPlayerMessage;
	Comm.addChatMessage(msgGM);

	if bShowPlayerMessage and not CombatManager.isCTHidden(nodeEntry) then
		local aUsers = User.getActiveUsers();
		if #aUsers > 0 then
			Comm.deliverChatMessage(msgPlayer, aUsers);
		end

		if not bSkipBell and ActorManager.isPC(rActor) and OptionsManager.isOption("RING", "on") then
			local nodePC = ActorManager.getCreatureNode(rActor);
			if nodePC then
				local sOwner = DB.getOwner(nodePC);
				if (sOwner or "") ~= "" then
					User.ringBell(sOwner);
				end
			end
		end
	end
end

function requestActivation(nodeEntry, bSkipBell)
	-- De-activate all other entries
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		DB.setValue(v, "active", "number", 0);
	end
	
	-- Set active flag
	DB.setValue(nodeEntry, "active", "number", 1);

	-- Turn notification
	CombatManager.showTurnMessage(nodeEntry, true, bSkipBell);

	-- Handle GM identity list updates (based on option)
	CombatManager.clearGMIdentity();
	CombatManager.addGMIdentity(nodeEntry);
end

function centerOnToken(nodeEntry, bOpen)
	if not Session.IsHost then
		local sClass, sRecord = DB.getValue(nodeEntry, "link", "", "");
		if sClass ~= "charsheet" then 
			return; 
		end
		local bOwned = DB.isOwner(sRecord);
		if not bOwned then 
			return; 
		end
	end
	ImageManager.centerOnToken(getTokenFromCT(nodeEntry), bOpen);
end

function isActorToSkipTurn(nodeEntry)
	local rActor = ActorManager.resolveActor(nodeEntry);
	if EffectManager.hasEffect(rActor, "SKIPTURN") then
		return true;
	end

	local sFaction = ActorManager.getFaction(rActor);
	if sFaction == "friend" then
		return false;
	else
		local bSkipDeadEnemy = OptionsManager.isOption("CTSD", "on");
		if bSkipDeadEnemy then
			if ActorHealthManager.isDyingOrDead(rActor) then
				return true;
			end
		end
	end

	local bSkipHidden = OptionsManager.isOption("CTSH", "on");
	if bSkipHidden and CombatManager.isCTHidden(nodeEntry) then
		return true;
	end

	return false;
end

function nextActor(bSkipBell, bNoRoundAdvance)
	if not Session.IsHost then
		return;
	end

	local aEntries = CombatManager.getSortedCombatantList();

	local nodeActive = CombatManager.getActiveCT();
	local nIndexActive = 0;
	
	local nodeNext = nil;
	local nIndexNext = 0;

	-- Determine the next actor
	if #aEntries > 0 then
		if nodeActive then
			for i = 1,#aEntries do
				if aEntries[i] == nodeActive then
					nIndexActive = i;
					break;
				end
			end
		end
		for i = nIndexActive + 1, #aEntries do
			if not CombatManager.isActorToSkipTurn(aEntries[i]) then
				nIndexNext = i;
				break;
			end
		end
		if nIndexNext > nIndexActive then
			nodeNext = aEntries[nIndexNext];
			for i = nIndexActive + 1, nIndexNext - 1 do
				CombatManager.showTurnMessage(aEntries[i], false);
			end
		end
	end

	-- If next actor available, advance effects, activate and start turn
	if nodeNext then
		-- End turn for current actor
		if nodeActive then
			CombatManager.onTurnEndEvent(nodeActive);
		end
	
		-- Process effects in between current and next actors
		if nodeActive then
			CombatManager.onInitChangeEvent(nodeActive, nodeNext);
		else
			CombatManager.onInitChangeEvent(nil, nodeNext);
		end
		
		-- Start turn for next actor
		CombatManager.requestActivation(nodeNext, bSkipBell);
		CombatManager.onTurnStartEvent(nodeNext);
	elseif not bNoRoundAdvance then
		for i = nIndexActive + 1, #aEntries do
			CombatManager.showTurnMessage(aEntries[i], false);
		end
		CombatManager.nextRound(1);
	end
end

function nextRound(nRounds)
	if not Session.IsHost then
		return;
	end

	local nodeActive = CombatManager.getActiveCT();
	local nCurrent = DB.getValue(CombatManager.CT_ROUND, 0);

	-- If current actor, then advance based on that
	local nStartCounter = 1;
	local aEntries = CombatManager.getSortedCombatantList();
	if nodeActive then
		DB.setValue(nodeActive, "active", "number", 0);
		CombatManager.clearGMIdentity();

		local bFastTurn = false;
		for i = 1,#aEntries do
			if aEntries[i] == nodeActive then
				bFastTurn = true;
				CombatManager.onTurnEndEvent(nodeActive);
			elseif bFastTurn then
				CombatManager.onTurnStartEvent(aEntries[i]);
				CombatManager.onTurnEndEvent(aEntries[i]);
			end
		end
		
		CombatManager.onInitChangeEvent(nodeActive);

		nStartCounter = nStartCounter + 1;

		-- Announce round
		nCurrent = nCurrent + 1;
		local msg = {font = "narratorfont", icon = "turn_flag"};
		msg.text = string.format("[%s %d]", Interface.getString("combat_tag_round"), nCurrent);
		Comm.deliverChatMessage(msg);
	end
	for i = nStartCounter, nRounds do
		for i = 1,#aEntries do
			CombatManager.onTurnStartEvent(aEntries[i]);
			CombatManager.onTurnEndEvent(aEntries[i]);
		end
		
		CombatManager.onInitChangeEvent();
		
		-- Announce round
		nCurrent = nCurrent + 1;
		local msg = {font = "narratorfont", icon = "turn_flag"};
		msg.text = string.format("[%s %d]", Interface.getString("combat_tag_round"), nCurrent);
		Comm.deliverChatMessage(msg);
	end

	-- Update round counter
	DB.setValue(CombatManager.CT_ROUND, "number", nCurrent);
	
	-- Custom round start callback (such as per round initiative rolling)
	CombatManager.onRoundStartEvent(nCurrent);
	
	-- Check option to see if we should advance to first actor or stop on round start
	if OptionsManager.isOption("RNDS", "off") then
		local bSkipBell = (nRounds > 1);
		if #aEntries > 0 then
			CombatManager.nextActor(bSkipBell, true);
		end
	end
end

--
-- ADD FUNCTIONS
--

function stripCreatureNumber(s)
	local nStarts, _, sNumber = string.find(s, " ?(%d+)$");
	if nStarts then
		return string.sub(s, 1, nStarts - 1), sNumber;
	end
	return s;
end
function randomName(sBaseName)
	local aNames = {};
	local nCombatantCount = 0;
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		local sName = DB.getValue(v, "name", "");
		if sName ~= "" then
			table.insert(aNames, DB.getValue(v, "name", ""));
		end
		nCombatantCount = nCombatantCount + 1;
	end
	
	local nRandomRange = nCombatantCount * 2;
	local sNewName = sBaseName;
	local nSuffix;
	local bContinue = true;
	while bContinue do
		bContinue = false;
		nSuffix = math.random(nRandomRange);
		sNewName = sBaseName .. " " .. nSuffix;
		if StringManager.contains(aNames, sNewName) then
			bContinue = true;
		end
	end

	return sNewName, nSuffix;
end

--
-- RESET FUNCTIONS
--

function resetInit()
	-- De-activate all entries
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		DB.setValue(v, "active", "number", 0);
	end
	
	-- Clear GM identity additions (based on option)
	CombatManager.clearGMIdentity();

	-- Reset the round counter
	DB.setValue(CombatManager.CT_ROUND, "number", 1);
	
	CombatManager.onCombatResetEvent();
end

function resetCombatantEffects()
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		DB.deleteChildren(v, "effects");
	end
end

--
-- GENERAL ITERATION FUNCTIONS
--

function callForEachCombatant(f, ...)
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		f(v, ...);
	end
end

function callForEachCombatantEffect(f, ...)
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		EffectManager.startDelayedUpdates();
		for _,nodeEffect in pairs(DB.getChildList(v, "effects")) do
			f(nodeEffect, ...);
		end
		EffectManager.endDelayedUpdates();
	end
end

--
-- COMMON RULESET SPECIFIC FUNCTIONS
--

function rollTypeInit(sType, fRollCombatantEntryInit, ...)
	local tCombatantNodesToRoll = {};

	-- Calculate which combatants to roll initiative for
	for _,nodeCT in pairs(CombatManager.getCombatantNodes()) do
		local bRoll = true;
		if sType then
			local rActor = ActorManager.resolveActor(nodeCT);
			if sType == "pc" then
				if not ActorManager.isPC(rActor) then
					bRoll = false;
				end
			elseif not ActorManager.isRecordType(rActor, sType) then
				bRoll = false;
			end
		end
		if bRoll then
			table.insert(tCombatantNodesToRoll, nodeCT);
		end
	end

	-- Reset all entries to default "empty" value for initiative
	-- Must reset all before rolling to support initiative grouping
	for _,nodeCT in ipairs(tCombatantNodesToRoll) do
		DB.setValue(nodeCT, "initresult", "number", -10000);
	end
	-- Then, roll all initiatives
	for _,nodeCT in ipairs(tCombatantNodesToRoll) do
		fRollCombatantEntryInit(nodeCT, ...);
	end
end
function rollStandardEntryInit(tInit)
	if not tInit or not tInit.nodeEntry then
		return;
	end

	-- For PCs, we always roll unique initiative
	local sClass, sRecord = DB.getValue(tInit.nodeEntry, "link", "", "");
	if sClass == "charsheet" then
		DB.setValue(tInit.nodeEntry, "initresult", "number", CombatManager.helperRollRandomInit(tInit));
		return;
	end
	
	-- For NPCs, if NPC init option is not group, then roll unique initiative
	local sOptINIT = OptionsManager.getOption("INIT");
	if sOptINIT ~= "group" then
		DB.setValue(tInit.nodeEntry, "initresult", "number", CombatManager.helperRollRandomInit(tInit));
		return;
	end

	-- For NPCs with group option enabled
	
	-- Get the entry's database node name and creature name
	local sStripName = CombatManager.stripCreatureNumber(DB.getValue(tInit.nodeEntry, "name", ""));
	if sStripName == "" then
		DB.setValue(tInit.nodeEntry, "initresult", "number", CombatManager.helperRollRandomInit(tInit));
		return;
	end
		
	-- Iterate through list looking for other creatures with same name
	local nLastInit = nil;
	local sEntryFaction = DB.getValue(tInit.nodeEntry, "friendfoe", "");
	for _,nodeCT in pairs(CombatManager.getCombatantNodes()) do
		if DB.getName(nodeCT) ~= DB.getName(tInit.nodeEntry) then
			if DB.getValue(nodeCT, "friendfoe", "") == sEntryFaction then
				local sTemp = CombatManager.stripCreatureNumber(DB.getValue(nodeCT, "name", ""));
				if sTemp == sStripName then
					local nChildInit = DB.getValue(nodeCT, "initresult", 0);
					if nChildInit ~= -10000 then
						nLastInit = nChildInit;
					end
				end
			end
		end
	end
	
	-- If we found similar creatures, then match the initiative of the last one found; otherwise, roll
	DB.setValue(tInit.nodeEntry, "initresult", "number", nLastInit or CombatManager.helperRollRandomInit(tInit));
end
function helperRollRandomInit(tInit)
	if not tInit then
		return math.random(20);
	end
	if tInit.fnRollRandom then
		return tInit.fnRollRandom(tInit);
	end
	return math.random(tInit.nDie or 20) + (tInit.nMod or 0);
end

--
-- COMBAT TRACKER SUPPORT
--

function handleFactionDropOnImage(draginfo, imagecontrol, x, y)
	if not Session.IsHost then
		return;
	end

	-- Get faction records, and fill unassigned slots
	local sFaction = draginfo.getStringData();
	local tFactionData = CombatFormationManager.getFactionFormationRecords(sFaction);
	CombatFormationManager.fillFactionFormationSlots(sFaction, tFactionData, "column3");

	-- Place on map at calculated positions
	local nodeImage = imagecontrol.getDatabaseNode();
	local nCenterX, nCenterY = imagecontrol.snapToGrid(x, y);
	local nGridSize = imagecontrol.getGridSize();
	for _,v in ipairs(tFactionData) do
		if v.nodeCT then
			local sToken = DB.getValue(v.nodeCT, "token", "");
			if sToken ~= "" then
				local tAddPos = v.tSlotPos or { x = 0, y = 0 };

				-- Add it to the image at the drop coordinates
				TokenManager.setDragTokenUnits(DB.getValue(v.nodeCT, "space"));
				local tokenMap = Token.addToken(nodeImage, sToken, nCenterX + (nGridSize * tAddPos.x), nCenterY + (nGridSize * -tAddPos.y));
				TokenManager.endDragTokenWithUnits();

				-- Update token references
				CombatManager.replaceCombatantToken(v.nodeCT, tokenMap);
			end
		end
	end	
	
	return true;
end

function replaceCombatantToken(nodeCT, newTokenInstance)
	local oldTokenInstance = CombatManager.getTokenFromCT(nodeCT);
	if oldTokenInstance and oldTokenInstance ~= newTokenInstance then
		if not newTokenInstance then
			local nodeContainerOld = oldTokenInstance.getContainerNode();
			if nodeContainerOld then
				local x,y = oldTokenInstance.getPosition();
				TokenManager.setDragTokenUnits(DB.getValue(nodeCT, "space"));
				newTokenInstance = Token.addToken(DB.getPath(nodeContainerOld), DB.getValue(nodeCT, "token", ""), x, y);
				TokenManager.endDragTokenWithUnits();
			end
		end
		oldTokenInstance.delete();
	end

	TokenManager.linkToken(nodeCT, newTokenInstance);
	TokenManager.updateVisibility(nodeCT);
	TargetingManager.updateTargetsFromCT(nodeCT, newTokenInstance);
end

function getRecordType(v)
	return LibraryData.getRecordTypeFromDisplayClass(DB.getValue(v, "link", ""));
end
function isRecordType(v, s)
	return (CombatManager.getRecordType(v) == s);
end
function isPC(v)
	return CombatManager.isRecordType(v, "charsheet");
end
function isActive(v)
	return (DB.getValue(v, "active", 0) == 1);
end

function deleteFaction(sFaction)
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		if DB.getValue(v, "friendfoe", "") == sFaction then
			CombatManager.deleteCombatant(v);
		end
	end
end
function deleteNonFaction(sFaction)
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		if DB.getValue(v, "friendfoe", "") ~= sFaction then
			CombatManager.deleteCombatant(v);
		end
	end
end
function deleteCombatant(v)
	-- Perform any pre-delete activities
	CombatManager.onPreDeleteCombatantEvent(v);

	-- Clear any effects first, so that saves aren't triggered when initiative advanced
	DB.deleteChildren(v, "effects");

	-- Clear NPC wounds, so that ruleset turn end dying checks aren't triggered when initiative advanced
	if not CombatManager.isPC(v) and DB.getChild(v, "wounds") then
		DB.setValue(v, "wounds", "number", 0);
	end

	-- Move to the next actor, if this CT entry is active
	if CombatManager.isActive(v) then
		CombatManager.nextActor();
	end

	-- Delete the database node and close the window
	DB.deleteNode(v);
end

--
-- DEPRECATED
--

function setCustomDrop(fn)
	CombatDropManager.registerLegacyDropCallback(fn);
end
function onDropEvent(rSource, rTarget, draginfo)
	CombatDropManager.onLegacyDropEvent(rSource, rTarget, draginfo);
end

function onDrop(sNodeType, sNodePath, draginfo)
	return CombatDropManager.handleAnyDrop(draginfo, sNodePath);
end

local fCustomAddPC = nil;
function setCustomAddPC(fAddPC)
	fCustomAddPC = fAddPC;
end
function getCustomAddPC()
	return fCustomAddPC;
end
local fCustomAddNPC = nil;
function setCustomAddNPC(fAddNPC)
	fCustomAddNPC = fAddNPC;
end
function getCustomAddNPC()
	return fCustomAddNPC;
end
local fCustomAddBattle = nil;
function setCustomAddBattle(fAddBattle)
	fCustomAddBattle = fAddBattle;
end
function getCustomAddBattle()
	return fCustomAddBattle;
end
local fCustomNPCSpaceReach = nil;
function setCustomNPCSpaceReach(fNPCSpaceReach)
	fCustomNPCSpaceReach = fNPCSpaceReach;
end
function getCustomNPCSpaceReach()
	return fCustomNPCSpaceReach;
end

function addPC(nodePC)
	Debug.console("CombatManager.addPC - DEPRECATED - 2022-08-16 - Use CombatRecordManager.setRecordTypePostAddCallback/setRecordTypeCallback(\"charsheet\", fn).");
	CombatRecordManager.addPC({ sRecordType = "charsheet", nodeRecord = nodePC });
end
function addBattle(nodeBattle)
	Debug.console("CombatManager.addBattle - DEPRECATED - 2022-08-16 - Use CombatRecordManager.setRecordTypePostAddCallback/setRecordTypeCallback(\"battle\", fn).");
	CombatRecordManager.addBattle({ sRecordType = "battle", nodeRecord = nodeBattle });
end
function addNPC(sClass, nodeNPC, sName)
	Debug.console("CombatManager.addNPC - DEPRECATED - 2022-08-16 - Use CombatRecordManager.setRecordTypePostAddCallback/setRecordTypeCallback(\"npc\", fn).");
	local tCustom = { sRecordType = "npc", nodeRecord = nodeNPC, sClass = sClass, sName = sName };
	CombatRecordManager.addNPC(tCustom);
	return tCustom.nodeCT;
end
function addNPCHelper(nodeSource, sName, sClass)
	Debug.console("CombatManager.addNPCHelper - DEPRECATED - 2022-08-16 - Use CombatRecordManager.setRecordTypePostAddCallback/setRecordTypeCallback(\"npc\", fn).");
	local tCustom = { sRecordType = "npc", nodeRecord = nodeSource, sClass = sClass, sName = sName };
	CombatRecordManager.addNPCHelper(tCustom);
	return tCustom.nodeCT, tCustom.nodeCTLastMatch;
end
function getNPCSpaceReach(nodeNPC)
	Debug.console("CombatManager.getNPCSpaceReach - DEPRECATED - 2022-08-16 - ActorCommonManager.getSpaceReach.");
	return ActorCommonManager.getSpaceReach(nodeNPC);
end
