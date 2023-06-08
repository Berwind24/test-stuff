--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local bDelayedChildrenChanged = false;
local bDelayedRebuild = false;

LIST_RIGHT_OFFSET = 5;
LIST_BOTTOM_OFFSET = 70;

function onInit()
	ListManager.initCustomList(self);

	self.rebuildList();
	self.updateFilterButtons();

	self.onSizeChanged = handleSizeChanged;
	self.handleSizeChanged();
end
function onClose()
	ListManager.onCloseWindow(self);
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

local _sRecordType = "spell";
function getRecordType()
	return _sRecordType;
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
function onListChanged()
	if bDelayedChildrenChanged then
		self.onListRecordsChanged(false);
	end
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
	RecordManager.callForEachRecord(self.getRecordType(), self.addListRecord);
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

local _nPageSize = 20;
function getPageSize()
	return _nPageSize;
end
function resetPageSize()
	_nPageSize = 20;
end
function setPageSize(nPageSize)
	_nPageSize = nPageSize;
end
function handleSizeChanged()
	--local wTop = UtilityManager.getTopWindow(self);
	local nWinWidth, nWinHeight = self.getSize();
	local nListLeft, nListTop = list.getPosition();
	local w = nWinWidth - nListLeft - LIST_RIGHT_OFFSET;
	local h = nWinHeight - nListTop - LIST_BOTTOM_OFFSET;

	local nColWidth = list.getColumnWidth();
	local nRecordsWide = 1;
	if nColWidth > 0 then
		nRecordsWide = math.max(math.floor(w / nColWidth), 1)
	end
	local nRecordsHigh = math.max(math.floor(h / 20), 1);

	local nNewPageSize = math.max(nRecordsWide * nRecordsHigh, 1);
	local nPageSize = self.getPageSize();
	if nPageSize ~= nNewPageSize then
		self.setPageSize(nNewPageSize);
		ListManager.refreshDisplayList(self);
	end
end
function refreshDisplayList(bResetScroll)
	ListManager.refreshDisplayList(self, bResetScroll);

	local nListOffset = 40;
	if ListManager.getMaxPages(self) > 1 then
		nListOffset = nListOffset + 24;
	end
end

local sComboFilter = "";
local sFilter = "";
function onFilterChanged(nLevel)
	sComboFilter = nLevel;
	ListManager.refreshDisplayList(self, true);
end
function onNameFilterChanged(sTextFilter)
	sFilter = sTextFilter;
	ListManager.refreshDisplayList(self, true);
end
function isFilteredRecord(v)
	local sClassName = parentcontrol.window.parentcontrol.window.class.getValue();
	local sClassSpec = CharWizardManager.character_choices["class"][sClassName].specialization;
	local tClass = CharWizardManager.character_choices["class"][sClassName];

	local bMatch;
	-- Check source matches class/spec name
	for _,sSource in ipairs(v.aSource) do
		if (StringManager.trim(sSource):lower() == StringManager.trim(sClassName):lower()) then
			bMatch = true;

			break
		end
		if sClassSpec and sClassSpec ~= "" then
			if StringManager.trim(sSource:lower()):match(sClassSpec:lower()) then
				bMatch = true;

				break
			end
		end
	end

	-- Check spell lists for match
	if ClassSpellListManager.getClassSpellListRecord(sClassName) then
		for _,vSpellNode in ipairs(ClassSpellListManager.getClassSpellListRecord(sClassName).tSpells) do
			if vSpellNode == v.vNode then
				bMatch = true;

				break
			end
		end
	end

	if sClassSpec then
		if ClassSpellListManager.getClassSpellListRecord(sClassSpec) then
			for _,vSpellNode in ipairs(ClassSpellListManager.getClassSpellListRecord(sClassSpec)) do
				if vSpellNode == v.vNode then
					bMatch = true;

					break
				end
			end
		end
	end

	local bTextMatch = false;
	if sFilter ~= "" then
		local sFilterLowered = sFilter:lower();
		if v.sDisplayNameLower:find(sFilterLowered) then
			bTextMatch = true;
		end
	else
		bTextMatch = true;
	end

	if not bMatch or not bTextMatch then
		return false;
	end

	local bMatch;
	if sComboFilter ~= "" then
		if tonumber(sComboFilter) == v.nSpellLevel then
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

	if tClass.spell then
		for _,vSpell in ipairs(tClass.spell) do
			local sSpellName = DB.getValue(DB.findNode(vSpell), "name", "");
			if v.vNode == DB.findNode(vSpell) or sSpellName:lower() == v.sDisplayNameLower then
				return false
			end
		end
	end

	return true;
end
function updateFilterButtons()
	local sClassName = parentcontrol.window.parentcontrol.window.class.getValue();
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

	parentcontrol.window.spellcasting_spellsfilters.closeAll();
	parentcontrol.window.pactspellcasting_spellsfilters.closeAll();
	parentcontrol.window.spellcasting_spellsfilters.setVisible(tClass.spellslots);
	parentcontrol.window.pactspellcasting_spellsfilters.setVisible(tClass.pactmagicslots);

	if bSpellcaster and not bPactMagic then
		for i = 1, 10 do
			local bMake;

			if i == 1 then
				bMake = true;
			end
			if tClass.spellslots[i - 1] then
				bMake = true;
			end

			if bMake then
				local w = parentcontrol.window.spellcasting_spellsfilters.createWindow();
				local cText = w.button_filter.addTextWidget("button-white", (i - 1));
		        cText.setPosition("center", 0, 1);
		        cText.setName("spelllevel");

		        if i == 1 then
		        	w.button_filter.setValue(1);
		        end
			end
		end
	end

	if bSpellcaster and bPactMagic then
		for i = 1, 6 do
			local bMake;

			if i == 1 then
				bMake = true;
			end
			if tClass.pactmagicslots[i - 1] then
				bMake = true;
			end

			if bMake then
				local w = parentcontrol.window.pactspellcasting_spellsfilters.createWindow();
				local cText = w.button_filter.addTextWidget("button-white", (i - 1));
		        cText.setPosition("center", 0, 1);
		        cText.setName("spelllevel");
		    end
		end
	end
end