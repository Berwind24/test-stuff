--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local bDelayedChildrenChanged = false;
local bDelayedRebuild = false;

local sFilter = "";

function onInit()
	ListManager.initCustomList(self);

	self.rebuildList();
	self.updateFilterButtons();
end
function onClose()
	ListManager.onCloseWindow(self);
end

local _tRecords = {};
function getAllRecords()
	return _tRecords;
end
function clearRecords()
	_tRecords = {};
end

function onSortCompare(w1, w2)
	local tRecords = self.getAllRecords();
	local _,sW1Record = w1.link.getValue();
	local _,sW2Record = w2.link.getValue();
	return not ListManager.defaultSortFunc(tRecords[DB.findNode(sW1Record)], tRecords[DB.findNode(sW2Record)]);
end

function onChildAdded(vNode)
	self.addListRecord(vNode);
	self.onListRecordsChanged(true);
end
function onChildDeleted(vNode)
	local tRecords = self.getAllRecords();
	if tRecords[vNode] then
		tRecords[vNode] = nil;
		self.onListRecordsChanged(true);
	end
end

function updateTotals()
	local sClassName = parentcontrol.window.class.getValue();
	local tClass = CharWizardManager.character_choices["class"][sClassName];

	cantrips_max.setValue(tClass.cantrips);

	known_spells_max.setValue(tClass.knownspells);
	known_spells_max.setVisible(known_spells_max.getValue() ~= 0);
	known_spells_label.setVisible(known_spells_max.getValue() ~= 0);

	prepared_spells_max.setValue(tClass.preparedspells);
	prepared_spells_max.setVisible(prepared_spells_max.getValue() ~= 0);
	prepared_spells_label.setVisible(prepared_spells_max.getValue() ~= 0);
end

function onListChanged()
	if bDelayedChildrenChanged then
		self.onListRecordsChanged(false);
	end
end

function addListRecord(vNode)
	local rRecord = {};
	rRecord.vNode = vNode;
	rRecord.sDisplayName = DB.getValue(vNode, "name", "");
	rRecord.sDisplayNameLower = rRecord.sDisplayName:lower();
	rRecord.aSource = LibraryData5E.getSpellSourceValue(vNode);
	rRecord.nSpellLevel = DB.getValue(vNode, "level", 0);

	self.getAllRecords()[vNode] = rRecord;
end

function onListRecordsChanged(bAllowDelay)
	if bAllowDelay then
		ListManager.helperSaveScrollPosition(self);
		bDelayedChildrenChanged = true;
		list.setDatabaseNode(nil);
	else
		bDelayedChildrenChanged = false;
		if bDelayedRebuild then
			bDelayedRebuild = false;
			self.rebuildList(true);
		end
		ListManager.refreshDisplayList(self);
	end
end

function rebuildList(bSkipRefresh)
	self.rebuildListData();

	ListManager.setDisplayOffset(self, 0, true);
	if not bSkipRefresh then
		self.onListRecordsChanged();
	end
end
function rebuildListData()
	self.clearRecords();

	local sClassName = parentcontrol.window.class.getValue();
	local tClass = CharWizardManager.character_choices["class"][sClassName];
	if tClass.spell then
		for _,v in pairs(tClass.spell) do
			self.addListRecord(DB.findNode(v));
		end
	end
end

function getPageSize()
	return 20;
end

function updateFilterButtons()
	local sClassName = parentcontrol.window.class.getValue();
	local sClassSpec = CharWizardManager.character_choices["class"][sClassName].specialization;
	local tClassMagicData = CharWizardClassManager.getCharWizardMagicData();
	local tClass = CharWizardManager.character_choices["class"];
	local tClassName = CharWizardManager.character_choices["class"][sClassName];
	local bPactMagic = false;
	local bSpellcaster = false;

	for _,vData in ipairs(tClassMagicData) do
		if vData.sName == sClassName then
			if vData.bPactMagic then
				bPactMagic = true;
				bSpellcaster = true;
			else
				bSpellcaster = true;
			end

			break
		end
	end

	spellcasting_filters.closeAll();
	pactspellcasting_filters.closeAll();

	local aSpellLevels = {};
	for _,v in pairs(tClass) do
		if v.spell then
			for _,v2 in ipairs(v.spell) do
				local nSpellLevel = DB.getValue(DB.findNode(v2), "level", 0);
				aSpellLevels[nSpellLevel + 1] = true;
			end
		end
	end

	if bSpellcaster and not bPactMagic then
		for i = 1, 10 do
			local bMake;

			if aSpellLevels[i] then
				bMake = true;
			end

			if bMake then
				local w = spellcasting_filters.createWindow();
				local cText = w.button_filter.addTextWidget("button-white", (i - 1));
		        cText.setPosition("center", 0, 1);
		        cText.setName("spelllevel");

				w.windowlist.setVisible(true);
			end
		end
	end

	if bSpellcaster and bPactMagic then
		for i = 1, 6 do
			local bMake;

			if aSpellLevels[i] then
				bMake = true;
			end

			if bMake then
				local w = pactspellcasting_filters.createWindow();
				local cText = w.button_filter.addTextWidget("button-white", (i - 1));
		        cText.setPosition("center", 0, 1);
		        cText.setName("spelllevel");
				w.windowlist.setVisible(true);
		    end
		end
	end
end

function refreshDisplayList(bResetScroll)
	ListManager.refreshDisplayList(self, bResetScroll);

	local nListOffset = 40;
	if ListManager.getMaxPages(self) > 1 then
		nListOffset = nListOffset + 24;
	end
end

function onFilterChanged(nLevel)
	sFilter = nLevel;
	ListManager.refreshDisplayList(self, true);
end

function isFilteredRecord(v)
	local sClassName = parentcontrol.window.class.getValue();
	local sClassSpec = CharWizardManager.character_choices["class"][sClassName].specialization;
	local tClass = CharWizardManager.character_choices["class"][sClassName];

	local bMatch;
	if sFilter ~= "" then
		if tonumber(sFilter) == v.nSpellLevel then
			bMatch = true;
		end
	else
		if v.nSpellLevel ~= 0 then
			if (tClass.pactmagicslots and tClass.pactmagicslots[v.nSpellLevel]) or
				(tClass.spellslots and tClass.spellslots[v.nSpellLevel]) then

				bMatch = true;
			end
		else
			bMatch = true;
		end
	end

	if not bMatch then
		return false;
	end

	return true;
end
