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
	for _,v in pairs(tRecords) do
		if v.vNode == vNode then
			local tEquipment = CharWizardManager.character_choices["equipment"];
			local bDeleted = false;
			if tEquipment.additems and next(tEquipment.additems) then
				for i,v in pairs(tEquipment.additems) do
					if v.item == vNode then
						tEquipment.additems[i] = nil;
						break
					end
				end
			end

			self.rebuildList();
		end
	end
end

local _tRecords = {};
function getAllRecords()
	return _tRecords;
end
function clearRecords()
	_tRecords = {};
end

function getSortFunction()
	return sortFunc;
end
function sortFunc(a, b)
	if a.sDisplayNameLower ~= b.sDisplayNameLower then
		return a.sDisplayNameLower < b.sDisplayNameLower;
	end

	return a.sDisplayNameLower > b.sDisplayNameLower;
end
function onListChanged()
	if bDelayedChildrenChanged then
		self.onListRecordsChanged(false);
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

	local tEquipment = CharWizardManager.character_choices["equipment"];
	if tEquipment.classitems and next(tEquipment.classitems) then
		for _,v in pairs(tEquipment.classitems) do
			self.addListRecord(v);
		end
	end
	if tEquipment.backgrounditems and next(tEquipment.backgrounditems) then
		for _,v in pairs(tEquipment.backgrounditems) do
			self.addListRecord(v);
		end
	end
	if tEquipment.additems and next(tEquipment.additems) then
		for _,v in pairs(tEquipment.additems) do
			self.addListRecord(v);
		end
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
function addListRecord(tNode)
	local rRecord = {};
	rRecord.vNode = tNode.item;
	rRecord.sDisplayName = DB.getValue(tNode.item, "name", "");
	rRecord.sDisplayNameLower = rRecord.sDisplayName:lower();
	rRecord.nCount = tNode.count or 1;

	if self.getAllRecords()[rRecord.sDisplayNameLower] then
		rRecord.nCount = self.getAllRecords()[rRecord.sDisplayNameLower].nCount + rRecord.nCount;
	end

	self.getAllRecords()[rRecord.sDisplayNameLower] = rRecord;
end

function getPageSize()
	return 20;
end
function refreshDisplayList(bResetScroll)
	ListManager.refreshDisplayList(self, bResetScroll);

	local nListOffset = 40;
	if ListManager.getMaxPages(self) > 1 then
		nListOffset = nListOffset + 24;
	end
end
function addDisplayListItem(v)
	local wItem = list.createWindow(v.vNode);

	if v.nCount == 1 then
		wItem.count.setVisible(false);
	else
		wItem.count.setValue(v.nCount);
	end
end

