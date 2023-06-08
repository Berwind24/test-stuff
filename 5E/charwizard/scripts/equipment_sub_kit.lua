--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	ListManager.initCustomList(self);
	ListManager.refreshDisplayList(self);
end
function onClose()
	ListManager.onCloseWindow(self);
end

local _nPageSize = 12;
function getPageSize()
	return _nPageSize;
end
function resetPageSize()
	_nPageSize = 12;
end
function handleSizeChanged()
	local nWinWidth, nWinHeight = self.getSize();
	local nListLeft, nListTop = list.getPosition();
	local w = nWinWidth - nListLeft - LIST_RIGHT_OFFSET;
	local h = nWinHeight - nListTop - LIST_BOTTOM_OFFSET;

	local nColWidth = list.getColumnWidth();
	local nRecordsWide = 1;
	if nColWidth > 0 then
		nRecordsWide = math.max(math.floor(w / nColWidth), 1)
	end
	local nRecordsHigh = math.max(math.floor(h / RECORD_DEFAULT_HEIGHT), 1);

	local nNewPageSize = math.max(nRecordsWide * nRecordsHigh, 1);
	local nPageSize = self.getPageSize();
	if nPageSize ~= nNewPageSize then
		nPageSize = nNewPageSize;
		ListManager.refreshDisplayList(self);
	end
end

local _tChoiceItems = {};
function getAllRecords()
	return _tChoiceItems;
end
function clearRecords()
	_tChoiceItems = {};
end
local _sKitType = "";
function getKitType()
	return _sKitType;
end
function setKitType(s)
	_sKitType = s;
end
function clearKitType()
	_sKitType = "";
end
function setData(tData, sType)
	self.clearRecords();

	for _,vItem in ipairs(tData) do
		local rRecord = {};
		rRecord.vNode = vItem.item;
		rRecord.sDisplayName = DB.getValue(vItem.item, "name", "");
		rRecord.sDisplayNameLower = rRecord.sDisplayName:lower();
		rRecord.nCount = vItem.count;

		self.getAllRecords()[vItem.item] = rRecord;
	end

	self.clearKitType();
	self.setKitType(sType);

	ListManager.refreshDisplayList(self);
end

function addDisplayListItem(v)
	local wItem = list.createWindow();

	wItem.name.setValue(StringManager.titleCase(v.sDisplayName));
	wItem.count.setValue(v.nCount);
	wItem.link.setValue("item", DB.getPath(v.vNode));
end

function getSortFunction()
	return self.sortFunc;
end
function sortFunc(a, b)
	return a.sDisplayName < b.sDisplayName;
end

local _sNameFilterLower = "";
function onNameFilterChanged()
	local sNewFilterLower = Utility.convertStringToLower(filter_name.getValue());
	if _sNameFilterLower ~= sNewFilterLower then
		_sNameFilterLower = sNewFilterLower;
		ListManager.setDisplayOffset(self, 0);
	end
end
function isFilteredRecord(v)
	if _sNameFilterLower ~= "" then
		if not string.find(Utility.convertStringToLower(v.sDisplayName), _sNameFilterLower, 0, true) then
			return false;
		end
	end
	return true;
end

