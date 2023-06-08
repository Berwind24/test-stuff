--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function setItemRecordType(sRecordType)
	local sDisplayClass = LibraryData.getRecordDisplayClass(sRecordType, getDatabaseNode());
	setItemClass(sDisplayClass);
end

function setItemClass(sDisplayClass)
	local node = getDatabaseNode();
	if node and sDisplayClass ~= "" then
		link.setValue(sDisplayClass, DB.getPath(node));
	else
		link.setVisible(false);
		link.setEnabled(false);
	end
end

function setColumnInfo(tColumns)
	for nColumn,rColumn in ipairs(tColumns) do
		ListManager.createViewEntryControl(self, nColumn, rColumn);
	end
end

function getFTColumnValue(sColumnName, nLength)
	Debug.console("ref_groupedlist_groupitem.lua:getFTColumnValue - DEPRECATED - 2022-07-12 - Use ListManager.getFTColumnValue");
	ChatManager.SystemMessage("ref_groupedlist_groupitem.lua:getFTColumnValue - DEPRECATED - 2022-07-12 - Contact forge/extension author");
	return ListManager.getFTColumnValue(getDatabaseNode(), sColumnName, nLength);
end
