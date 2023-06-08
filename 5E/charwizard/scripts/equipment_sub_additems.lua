--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local bDelayedChildrenChanged = false;
local bDelayedRebuild = false;

LIST_RIGHT_OFFSET = 40;
LIST_BOTTOM_OFFSET = 147;

function onInit()
	ListManager.initCustomList(self);
	self.rebuildList();

	local wTop = UtilityManager.getTopWindow(self);
	--[[wTop.onSizeChanged = handleSizeChanged;
	self.handleSizeChanged();--]]
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

local _sRecordType = "item";
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
	rRecord.sType = DB.getValue(vNode, "type", "");

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

local _sButtonFilter = "";
local _sFilter = "";
function onFilterChanged(sType)
	_sButtonFilter = sType;
	ListManager.refreshDisplayList(self, true);
end
function onNameFilterChanged(sTextFilter)
	_sFilter = sTextFilter;
	ListManager.refreshDisplayList(self, true);
end
function isFilteredRecord(v)
	local sType = v.sType;

	if sType ~= "" then
		sType = sType:lower();
	end

	if sType == "treasure" or sType == "woundrous item" then
		return false;
	end

	local bButtonMatch;
	local bTextMatch;
	if _sButtonFilter ~= "" then
		if _sButtonFilter == sType then
			bButtonMatch = true;
		end

		if _sButtonFilter == "gear" then
			if sType ~= "weapon" and sType ~= "armor" then
				bButtonMatch = true;
			end
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