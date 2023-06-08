-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onSortCompare(w1, w2)
	local nodeW1 = w1.getDatabaseNode();
	local nodeW2 = w2.getDatabaseNode();
	
	local sRefNode1 = DB.getValue(nodeW1, "refclass", "");
	local sRefNode2 = DB.getValue(nodeW2, "refclass", "");
	if sRefNode1 ~= sRefNode2 then
		return sRefNode1 > sRefNode2;
	end
	local sName1 = DB.getValue(nodeW1, "name", ""):lower();
	local sName2 = DB.getValue(nodeW2, "name", ""):lower();
	if sName1 ~= sName2 then
		return sName1 > sName2;
	end
end

function onDrop(x, y, draginfo)
	if draginfo.getType() == "shortcut" then
		local sClass, sRecord = draginfo.getShortcutData();
		if LibraryData.isRecordDisplayClass("itemtemplate", sClass) then
			ForgeManagerItem.addTemplate(sClass, sRecord);
			window.templates.updateItemIcons();
		elseif LibraryData.isRecordDisplayClass("item", sClass) then
			ForgeManagerItem.addBaseItem(sClass, sRecord);
			updateItemIcons();
		elseif LibraryData.isRecordDisplayClass("spell", sClass) then
			ForgeManagerItem.addTemplate(sClass, sRecord);
			window.templates.updateItemIcons();
		end
	end
	return true;
end

function onListChanged()
	window.statusicon.setIndex(0);
	window.status.setValue("");
end

function addEntry(bFocus)
	local w = createWindow();
	if bFocus and w then
		w.name.setFocus();
	end
	return w;
end

function updateItemIcons()
	for _,v in pairs(getWindows()) do
		v.itemtype.update();
	end	
end

