--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local bDelayedChildrenChanged = false;
local bDelayedRebuild = false;

LIST_RIGHT_OFFSET = 10;
LIST_BOTTOM_OFFSET = 440;

function onInit()
	ListManager.initCustomList(self);
	self.rebuildList();

	local wTop = UtilityManager.getTopWindow(self);
	wTop.onSizeChanged = handleSizeChanged;
	self.handleSizeChanged();
end
function onClose()
	ListManager.onCloseWindow(self);
end

local _sRecordType = "background";
function getRecordType()
	return _sRecordType;
end

local _tRecords = {};
local _tModules = {};
function getAllRecords()
	return _tRecords;
end
function getAllModules()
	return _tModules;
end
function clearRecords()
	_tRecords = {};
	_tModules = {};
end

function onSortCompare(w1, w2)
	local tRecords = self.getAllRecords();
	local _,sW1Record = w1.shortcut.getValue();
	local _,sW2Record = w2.shortcut.getValue();
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
	self.rebuildListDisplay();

	ListManager.setDisplayOffset(self, 0, true);
	if not bSkipRefresh then
		self.onListRecordsChanged();
	end
end
function rebuildListData()
	self.clearRecords();
	RecordManager.callForEachRecord(self.getRecordType(), self.addListRecord);
end
function rebuildListDisplay()
	parentcontrol.window.filter_background.clear();
	for k,_ in pairs(self.getAllModules()) do
		parentcontrol.window.filter_background.add(k);
	end
	parentcontrol.window.filter_background.add("");
end
function addListRecord(vNode)
	local rRecord = {};
	rRecord.vNode = vNode;
	rRecord.sDisplayName = DB.getValue(vNode, "name", "");
	rRecord.sDisplayNameLower = rRecord.sDisplayName:lower();
	if vNode.getModule() then
		local tModule = Module.getModuleInfo(vNode.getModule());
		rRecord.sModule = tModule.displayname;
	else
		rRecord.sModule = "Campaign";
	end

	self.getAllRecords()[vNode] = rRecord;
	self.getAllModules()[rRecord.sModule] = true;
end

local _nPageSize = 7;
function getPageSize()
	return _nPageSize;
end
function resetPageSize()
	_nPageSize = 7;
end
function setPageSize(nPageSize)
	_nPageSize = nPageSize;
end
function handleSizeChanged()
	local wTop = UtilityManager.getTopWindow(self);
	local nWinWidth, nWinHeight = wTop.getSize();
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
function addDisplayListItem(v)
	if v.vNode then
		local wBackground = list.createWindow(v.vNode);
		wBackground.name.setTooltipText(v.sModule);
		wBackground.button_select.setVisible(true);
	end
end

local _sComboFilter = "";
local _sFilter = "";
function onFilterChanged(sModule)
	_sComboFilter = sModule:lower();
	ListManager.refreshDisplayList(self, true);
end
function onNameFilterChanged(sTextFilter)
	_sFilter = sTextFilter;
	ListManager.refreshDisplayList(self, true);
end
function isFilteredRecord(v)
	local sModule = v.sModule;

	if sModule ~= "" then
		sModule = sModule:lower();
	else
		sModule = "campaign";
	end

	local bButtonMatch;
	local bTextMatch;
	if _sComboFilter ~= "" then
		if _sComboFilter == sModule then
			bButtonMatch = true;
		end
	else
		bButtonMatch = true;
	end

	if _sFilter ~= "" then
		local sFilterLowered = _sFilter:lower();

		if v.sDisplayNameLower:find(sFilterLowered) then
			bTextMatch = true;
		end
	else
		bTextMatch = true;
	end

	if not bButtonMatch or not bTextMatch then
		return false;
	end

	return true;
end
