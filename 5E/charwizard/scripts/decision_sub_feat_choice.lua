--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local bDelayedChildrenChanged = false;
local bDelayedRebuild = false;

function onInit()
	ListManager.initCustomList(self);
	self.rebuildList();
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

local _sRecordType = "feat";
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

	local nodeFeat = RecordManager.findRecordByStringI("feat", "name", rRecord.sDisplayNameLower);
	if DB.getModule(nodeFeat) then
		local tModule = Module.getModuleInfo(DB.getModule(nodeFeat));
		rRecord.sModule = tModule.displayname;
	else
		rRecord.sModule = "Campaign";
	end

	self.getAllRecords()[vNode] = rRecord;
end

function getPageSize()
	return 16;
end
function refreshDisplayList(bResetScroll)
	ListManager.refreshDisplayList(self, bResetScroll);

	local nListOffset = 40;
	if ListManager.getMaxPages(self) > 1 then
		nListOffset = nListOffset + 24;
	end
end
function addDisplayListItem(v)
	local wRace = list.createWindow(v.vNode);
	wRace.name.setTooltipText(v.sModule);
end

local _sFilter = "";
function onNameFilterChanged(sTextFilter)
	_sFilter = sTextFilter;
	ListManager.refreshDisplayList(self, true);
end
function isFilteredRecord(v)
	local tSelectedFeats = CharWizardManager.collectFeats();

	for _,vFeat in pairs(tSelectedFeats) do
		if v.sDisplayNameLower == vFeat then
			return false;
		end
	end

	if _sFilter ~= "" then
		local sFilterLowered = _sFilter:lower();

		if not v.sDisplayNameLower:find(sFilterLowered) then
			return false;
		end
	end

	return true;
end