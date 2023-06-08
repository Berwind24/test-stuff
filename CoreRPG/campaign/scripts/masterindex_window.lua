-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local bDelayedChildrenChanged = false;
local bDelayedRebuild = false;

local fName = "";
local fSharedOnly = false;
local fCategory = "";

local bAllowCategories = true;

local cButtonAnchor = nil;
local aButtonControls = {};

local aEditControls = {};

local aCustomFilters = {};
local nCustomFilters = 0;
local aCustomFilterControls = {};
local aCustomFilterValueControls = {};
local aCustomFilterValues = {};

local sDelayedCategoryFocus = nil;

function onInit()
	ListManager.initCustomList(self);

	local node = getDatabaseNode();
	if node then
		local sRecordType = LibraryData.getRecordTypeFromPath(DB.getPath(node));
		if (sRecordType or "") ~= "" then
			self.setRecordType(sRecordType);
		end
	end

	Module.addEventHandler("onModuleLoad", onModuleLoadAndUnload);
	Module.addEventHandler("onModuleUnload", onModuleLoadAndUnload);
end
function onClose()
	ListManager.onCloseWindow(self);
	
	self.removeHandlers();
end

function onModuleLoadAndUnload(sModule)
	local nodeRoot = DB.getRoot(sModule);
	if nodeRoot then
		local vNodes = LibraryData.getMappings(self.getRecordType());
		for i = 1, #vNodes do
			if DB.getChild(nodeRoot, vNodes[i]) then
				bDelayedRebuild = true;
				self.onListRecordsChanged(true);
				break;
			end
		end
	end
end
function addHandlers()
	function addHandlerHelper(vNode)
		local sPath = DB.getPath(vNode);
		local sChildPath = sPath .. ".*@*";
		DB.addHandler(sChildPath, "onAdd", onChildAdded);
		DB.addHandler(sChildPath, "onDelete", onChildDeleted);
		DB.addHandler(sChildPath, "onCategoryChange", onChildCategoryChange);
		DB.addHandler(sChildPath, "onObserverUpdate", onChildObserverUpdate);
		DB.addHandler(DB.getPath(sChildPath, "name"), "onUpdate", onChildNameChange);
		DB.addHandler(DB.getPath(sChildPath, "nonid_name"), "onUpdate", onChildUnidentifiedNameChange);
		DB.addHandler(DB.getPath(sChildPath, "isidentified"), "onUpdate", onChildIdentifiedChange);
		for kCustomFilter,vCustomFilter in pairs(aCustomFilters) do
			DB.addHandler(DB.getPath(sChildPath, vCustomFilter.sField), "onUpdate", onChildCustomFilterValueChange);
		end
		DB.addHandler(sPath, "onChildCategoriesChange", onChildCategoriesChanged);
	end
	
	local vNodes = LibraryData.getMappings(self.getRecordType());
	for i = 1, #vNodes do
		addHandlerHelper(vNodes[i]);
	end
end
function removeHandlers()
	function removeHandlerHelper(vNode)
		local sPath = DB.getPath(vNode);
		local sChildPath = sPath .. ".*@*";
		DB.removeHandler(sChildPath, "onAdd", onChildAdded);
		DB.removeHandler(sChildPath, "onDelete", onChildDeleted);
		DB.removeHandler(sChildPath, "onCategoryChange", onChildCategoryChange);
		DB.removeHandler(sChildPath, "onObserverUpdate", onChildObserverUpdate);
		DB.removeHandler(DB.getPath(sChildPath, "name"), "onUpdate", onChildNameChange);
		DB.removeHandler(DB.getPath(sChildPath, "nonid_name"), "onUpdate", onChildUnidentifiedNameChange);
		DB.removeHandler(DB.getPath(sChildPath, "isidentified"), "onUpdate", onChildIdentifiedChange);
		for kCustomFilter,vCustomFilter in pairs(aCustomFilters) do
			DB.removeHandler(DB.getPath(sChildPath, vCustomFilter.sField), "onUpdate", onChildCustomFilterValueChange);
		end
		DB.removeHandler(sPath, "onChildCategoriesChange", onChildCategoriesChanged);
	end
	
	local vNodes = LibraryData.getMappings(self.getRecordType());
	for i = 1, #vNodes do
		removeHandlerHelper(vNodes[i]);
	end
end

local _sRecordType = "";
function getRecordType()
	return _sRecordType;
end
function setRecordType(sRecordType)
	if sRecordType == self.getRecordType() then
		return;
	end
	
	self.removeHandlers();
	self.clearButtons();
	self.clearCustomFilters();

	_sRecordType = sRecordType;

	local sDisplayTitle = LibraryData.getDisplayText(sRecordType);
	reftitle.setValue(sDisplayTitle);
	
	self.setupEditTools();
	self.setupCategories();
	self.setupButtons();
	self.setupCustomFilters();

	self.rebuildList();
	self.addHandlers();
end

local _tRecords = {};
function getAllRecords()
	return _tRecords;
end
function clearRecords()
	_tRecords = {};
end

function onListChanged()
	if bDelayedChildrenChanged then
		self.onListRecordsChanged(false);
	end
end
function onSortCompare(w1, w2)
	local tRecords = self.getAllRecords();
	return not ListManager.defaultSortFunc(tRecords[w1.getDatabaseNode()], tRecords[w2.getDatabaseNode()]);
end

function setupEditTools()
	list_iadd.setRecordType(LibraryData.getRecordDisplayClass(self.getRecordType()));
	local bAllowEdit = LibraryData.allowEdit(self.getRecordType());
	list_iedit.setVisible(bAllowEdit);
	list_iadd.setVisible(bAllowEdit);

	list.setReadOnly(not bAllowEdit);
	list.resetMenuItems();
	if not list.isReadOnly() and bAllowEdit then
		list.registerMenuItem(Interface.getString("list_menu_createitem"), "insert", 5);
	end
end
function setupCategories()
	bAllowCategories = LibraryData.allowCategories(self.getRecordType());
	label_category.setVisible(bAllowCategories);
	filter_category_label.setVisible(bAllowCategories);
	button_category_detail.setVisible(bAllowCategories);
	handleCategorySelect("*");
end

function clearButtons()
	for _,v in ipairs(aButtonControls) do
		v.destroy();
	end
	if cButtonAnchor then
		cButtonAnchor.destroy();
		cButtonAnchor = nil;
	end
	aButtonControls = {};
	
	for _,v in ipairs(aEditControls) do
		v.destroy();
	end
	aEditControls = {};
end
function setupButtons()
	local aIndexButtons = LibraryData.getIndexButtons(self.getRecordType());
	if #aIndexButtons > 0 then
		cButtonAnchor = createControl("masterindex_anchor_button", "buttonanchor");
		for k,v in ipairs(aIndexButtons) do
			local c = createControl(v, "button_custom" .. k);
			if c then
				table.insert(aButtonControls, c);
			end
		end
	end

	local aEditButtons = LibraryData.getEditButtons(self.getRecordType());
	if #aEditButtons > 0 then
		for k,v in ipairs(aEditButtons) do
			local c = createControl(v, "button_edit" .. k);
			if c then
				c.setVisible(true);
				table.insert(aEditControls, c);
			end
		end
	end
end

function clearCustomFilters()
	for _,c in pairs(aCustomFilterValueControls) do
		c.onDestroy();
		c.destroy();
	end
	aCustomFilterValueControls = {};
	for _,c in pairs(aCustomFilterControls) do
		c.destroy();
	end
	aCustomFilterControls = {};
	aCustomFilters = {};
	nCustomFilters = 0;
end
function setupCustomFilters()
	aCustomFilters = LibraryData.getCustomFilters(self.getRecordType());
	
	local aSortedFilters = {};
	for kFilter,_ in pairs(aCustomFilters) do
		table.insert(aSortedFilters, kFilter);
	end
	table.sort(aSortedFilters);
	for _,vFilter in ipairs(aSortedFilters) do
		self.addCustomFilter(vFilter);
	end
	nCustomFilters = #aSortedFilters;
end
function addCustomFilter(sCustomType)
	local c = createControl("masterindex_filter_custom", "filter_custom_" .. sCustomType);
	c.setValue(sCustomType);
	aCustomFilterControls[sCustomType] = c;
	
	local c2 = createControl("masterindex_filter_custom_value",  "filter_custom_value_" .. sCustomType);
	c2.setFilterType(sCustomType);
	aCustomFilterValueControls[sCustomType] = c2;
	
	aCustomFilterValues[sCustomType] = "";
end
function clearFilterValues()
	if fSharedOnly then
		filter_sharedonly.setValue(0);
	end
	if fName ~= "" then
		filter_name.setValue();
	end
	for kCustomFilter,_ in pairs(aCustomFilters) do
		aCustomFilterValueControls[kCustomFilter].setValue("");
	end
end

function rebuildList(bSkipRefresh)
	local sListDisplayClass = LibraryData.getIndexDisplayClass(self.getRecordType());
	if sListDisplayClass ~= "" then
		list.setChildClass(sListDisplayClass);
	end
	
	self.clearRecords();
	RecordManager.callForEachRecord(self.getRecordType(), self.addListRecord);

	ListManager.setDisplayOffset(self, 0, true);
	if not bSkipRefresh then
		self.onListRecordsChanged();
	end
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
function onChildCategoriesChanged()
	self.onListRecordsChanged(true);
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
		self.rebuildCategories();
		self.rebuildCustomFilterValues();
		self.refreshDisplayList();
	end
end
function addListRecord(vNode)
	local rRecord = {};
	rRecord.vNode = vNode;
	rRecord.sCategory = UtilityManager.getNodeCategory(vNode);
	rRecord.nAccess = UtilityManager.getNodeAccessLevel(vNode);
	
	rRecord.bIdentifiable = LibraryData.isIdentifiable(self.getRecordType(), vNode);
	if rRecord.bIdentifiable and not self.getRecordIDState(rRecord) then
		rRecord.sDisplayName = DB.getValue(vNode, "nonid_name", "");
	else
		rRecord.sDisplayName = DB.getValue(vNode, "name", "");
	end
	rRecord.sDisplayNameLower = Utility.convertStringToLower(rRecord.sDisplayName);

	rRecord.aCustomValues = {};
	for kCustomFilter,vCustomFilter in pairs(aCustomFilters) do
		rRecord.aCustomValues[kCustomFilter] = DB.getValue(vNode, vCustomFilter.sField, "");
	end

	self.getAllRecords()[vNode] = rRecord;
end

function getFilterValues(kCustomFilter, vNode)
	local vValues = {};
	
	local vCustomFilter = aCustomFilters[kCustomFilter];
	if vCustomFilter then
		if vCustomFilter.fGetValue then
			vValues = vCustomFilter.fGetValue(vNode);
			if type(vValues) ~= "table" then
				vValues = { vValues };
			end
		elseif vCustomFilter.sType == "boolean" then
			if DB.getValue(vNode, vCustomFilter.sField, 0) ~= 0 then
				vValues = { LibraryData.sFilterValueYes };
			else
				vValues = { LibraryData.sFilterValueNo };
			end
		else
			local vValue = DB.getValue(vNode, vCustomFilter.sField);
			if vCustomFilter.sType == "number" then
				vValues = { tostring(vValue or 0) };
			else
				local sValue;
				if vValue then
					sValue = tostring(vValue) or "";
				else
					sValue = "";
				end
				if sValue == "" then
					vValues = { LibraryData.sFilterValueEmpty };
				else
					vValues = { sValue };
				end
			end
		end
	end
	
	return vValues;
end

function rebuildCustomFilterValues()
	for kCustomFilter,_ in pairs(aCustomFilters) do
		self.rebuildCustomFilterValueHelper(kCustomFilter);
	end
end
function rebuildCustomFilterValueHelper(kCustomFilter)
	local cFilter = aCustomFilterValueControls[kCustomFilter];
	if not cFilter then
		return;
	end

	local tFilterValues = {};
	local tRecords = self.getAllRecords();
	for _,vRecord in pairs(tRecords) do
		if cFilter then
			local vValues = self.getFilterValues(kCustomFilter, vRecord.vNode);
			for _,v in ipairs(vValues) do
				if (v or "") ~= "" then
					tFilterValues[v] = true;
				end
			end
		end
	end

	cFilter.clear();
	if not tFilterValues[cFilter.getValue()] then
		cFilter.setValue("");
	end

	local tSortedFilterValues = {};
	for k,_ in pairs(tFilterValues) do
		table.insert(tSortedFilterValues, k);
	end
	if aCustomFilters[kCustomFilter].fSort then
		tSortedFilterValues = aCustomFilters[kCustomFilter].fSort(tSortedFilterValues);
	elseif aCustomFilters[kCustomFilter].sType == "number" then
		table.sort(tSortedFilterValues, function(a,b) return (tonumber(a) or 0) < (tonumber(b) or 0); end);
	else
		table.sort(tSortedFilterValues);
	end
	table.insert(tSortedFilterValues, 1, "");
	cFilter.addItems(tSortedFilterValues);
end

function onCustomFilterValueChanged(sFilterType, cFilterValue)
	aCustomFilterValues[sFilterType] = cFilterValue.getValue():lower();
	self.refreshDisplayList(true);
end

function getRecordIDState(vRecord)
	return LibraryData.getIDState(self.getRecordType(), vRecord.vNode);
end

function onChildCategoryChange(vNode)
	local tRecords = self.getAllRecords();
	if tRecords[vNode] then
		tRecords[vNode].sCategory = UtilityManager.getNodeCategory(vNode);
		if fCategory ~= "*" then
			self.refreshDisplayList();
		else
			for _,w in ipairs(list.getWindows()) do
				if vNode == w.getDatabaseNode() then
					w.onCategoryChange();
					break;
				end
			end
		end
	end
end
function onChildObserverUpdate(vNode)
	local tRecords = self.getAllRecords();
	if tRecords[vNode] then
		tRecords[vNode].nAccess = UtilityManager.getNodeAccessLevel(vNode);
		if fSharedOnly then
			self.refreshDisplayList();
		end
	end
end
function onChildCustomFilterValueChange(vNode)
	local sNodeName = DB.getName(vNode);
	for kCustomFilter,vCustomFilter in pairs(aCustomFilters) do
		if vCustomFilter.sField == sNodeName then
			self.rebuildCustomFilterValueHelper(kCustomFilter);
			if aCustomFilterValues[kCustomFilter] ~= "" then
				self.refreshDisplayList();
			end
			break;
		end
	end
end
function onChildNameChange(vNameNode)
	local vNode = DB.getParent(vNameNode);
	local rRecord = self.getAllRecords()[vNode];
	if not rRecord.bIdentifiable or self.getRecordIDState(rRecord) then
		rRecord.sDisplayName = DB.getValue(vNode, "name", "");
		rRecord.sDisplayNameLower = Utility.convertStringToLower(rRecord.sDisplayName);
		self.refreshDisplayList();
	end
end
function onChildUnidentifiedNameChange(vNameNode)
	local vNode = DB.getParent(vNameNode);
	local rRecord = self.getAllRecords()[vNode];
	if rRecord.bIdentifiable and not self.getRecordIDState(rRecord) then
		rRecord.sDisplayName = DB.getValue(vNode, "nonid_name", "");
		rRecord.sDisplayNameLower = Utility.convertStringToLower(rRecord.sDisplayName);
		self.refreshDisplayList();
	end
end
function onChildIdentifiedChange (vIDNode)
	local vNode = DB.getParent(vIDNode);
	local rRecord = self.getAllRecords()[vNode];
	if rRecord.bIdentifiable and not Session.IsHost then
		if self.getRecordIDState(rRecord) then
			rRecord.sDisplayName = DB.getValue(vNode, "name", "");
		else
			rRecord.sDisplayName = DB.getValue(vNode, "nonid_name", "");
		end
		rRecord.sDisplayNameLower = Utility.convertStringToLower(rRecord.sDisplayName);
		self.refreshDisplayList();
	end
end

function handleCategorySelect(sCategory)
	if not bAllowCategories then
		return;
	end
	
	filter_category.setValue(sCategory);
	fCategory = sCategory;

	if fCategory == "*" then
		filter_category_label.setValue(Interface.getString("masterindex_label_category_all"));
	elseif fCategory == "" then
		filter_category_label.setValue(Interface.getString("masterindex_label_category_empty"));
	else
		filter_category_label.setValue(fCategory);
	end
	
	for _,w in ipairs(list_category.getWindows()) do
		w.setActiveByKey(fCategory);
	end
	
	button_category_detail.setValue(0);
	
	local sDefaultCategory = sCategory;
	if sDefaultCategory == "*" then
		sDefaultCategory = "";
	end
	for _,vMapping in ipairs(LibraryData.getMappings(self.getRecordType())) do
		DB.setDefaultChildCategory(vMapping, sDefaultCategory);
	end

	ListManager.setDisplayOffset(self, 0, true);
	self.refreshDisplayList(true);
end
function handleCategoryNameChange(sOriginal, sNew)
	if sOriginal == sNew then
		return;
	end
	for _,vMapping in ipairs(LibraryData.getMappings(self.getRecordType())) do
		DB.updateChildCategory(vMapping, sOriginal, sNew, true);
	end
end
function handleCategoryDelete(sName)
	for _,vMapping in ipairs(LibraryData.getMappings(self.getRecordType())) do
		DB.removeChildCategory(vMapping, sName, true);
	end
end
function handleCategoryAdd()
	local aMappings = LibraryData.getMappings(self.getRecordType());
	sDelayedCategoryFocus = DB.addChildCategory(aMappings[1]);
end
function rebuildCategories()
	if not bAllowCategories then
		return;
	end
	
	local aCategories = {};
	for _,vMapping in ipairs(LibraryData.getMappings(self.getRecordType())) do
		for _,vCategory in ipairs(DB.getChildCategories(vMapping, true)) do
			if type(vCategory) == "string" then
				aCategories[vCategory] = vCategory;
			else
				aCategories[vCategory.name] = vCategory.name;
			end
		end
	end
	aCategories["*"] = Interface.getString("masterindex_label_category_all");
	aCategories[""] = Interface.getString("masterindex_label_category_empty");

	list_category.closeAll();
	for kCategory,vCategory in pairs(aCategories) do
		local w = list_category.createWindow();
		w.setData(kCategory, vCategory, (fCategory == kCategory));
	end
	list_category.applySort();
	
	if not aCategories[fCategory] then
		self.handleCategorySelect("*");
	end
	
	if button_category_iedit.getValue() == 1 then
		button_category_iedit.setValue(0);
		button_category_iedit.setValue(1);
	end

	if sDelayedCategoryFocus then
		for _,w in ipairs(list_category.getWindows()) do
			if w.getCategory() == sDelayedCategoryFocus then
				w.category_label.setFocus();
				break;
			end
		end
		sDelayedCategoryFocus = nil;
	end
end

function onNameFilterChanged()
	fName = Utility.convertStringToLower(filter_name.getValue());
	self.refreshDisplayList(true);
end
function onSharedOnlyFilterChanged()
	fSharedOnly = (filter_sharedonly.getValue() == 1);
	self.refreshDisplayList(true);
end

function onIDChanged()
	for _,w in ipairs(list.getWindows()) do
		w.onIDChanged();
	end
	self.refreshDisplayList();
end

function addEntry()
	list_iadd.onButtonPress();
end

function getIndexRecord(vNode)
	if bDelayedChildrenChanged then
		self.onListRecordsChanged(false);
	end

	local sCategory = UtilityManager.getNodeCategory(vNode);
	local sModule = UtilityManager.getNodeModule(vNode);
	
	local tRecords = self.getAllRecords();
	for _,rRecord in pairs(tRecords) do
		if sModule == UtilityManager.getNodeModule(rRecord.vNode) and sCategory == rRecord.sCategory then
			local sNameLower = DB.getValue(rRecord.vNode, "name", ""):lower();
			if sNameLower:match("%(contents%)") or sNameLower:match("%(index%)") then
				if vNode == rRecord.vNode then
					return nil;
				end
				return rRecord.vNode;
			end
		end
	end
	
	return nil;
end
function getNextRecord(vNode)
	if bDelayedChildrenChanged then
		self.onListRecordsChanged(false);
	end

	local sCategory = UtilityManager.getNodeCategory(vNode);
	local sModule = UtilityManager.getNodeModule(vNode);

	aSortedRecords = {};
	local tRecords = self.getAllRecords();
	for _,rRecord in pairs(tRecords) do
		if sModule == UtilityManager.getNodeModule(rRecord.vNode) and sCategory == rRecord.sCategory then
			table.insert(aSortedRecords, rRecord);
		end
	end
	table.sort(aSortedRecords, ListManager.defaultSortFunc);
	
	local bGetNext = false;
	for _,rRecord in ipairs(aSortedRecords) do
		if bGetNext then
			return rRecord.vNode;
		end
		if rRecord.vNode == vNode then
			bGetNext = true;
		end
	end
	
	return nil;
end
function getPrevRecord(vNode)	
	if bDelayedChildrenChanged then
		self.onListRecordsChanged(false);
	end

	local sCategory = UtilityManager.getNodeCategory(vNode);
	local sModule = UtilityManager.getNodeModule(vNode);

	aSortedRecords = {};
	local tRecords = self.getAllRecords();
	for _,rRecord in pairs(tRecords) do
		if sModule == UtilityManager.getNodeModule(rRecord.vNode) and sCategory == rRecord.sCategory then
			table.insert(aSortedRecords, rRecord);
		end
	end
	table.sort(aSortedRecords, ListManager.defaultSortFunc);
	
	local nodePrev = nil;
	for _,rRecord in ipairs(aSortedRecords) do
		if rRecord.vNode == vNode then
			return nodePrev;
		end
		nodePrev = rRecord.vNode;
	end
	
	return nil;
end

--
--	LIST HANDLING
--

function refreshDisplayList(bResetScroll)
	ListManager.refreshDisplayList(self, bResetScroll);
	
	local nListOffset = 40;
	if ListManager.getMaxPages(self) > 1 then
		nListOffset = nListOffset + 24;
	end
	if nCustomFilters > 0 then
		nListOffset = nListOffset + (25 * nCustomFilters);
	end
	list.setAnchor("bottom", "bottomanchor", "top", "relative", -nListOffset);
end
function addDisplayListItem(v)
	local wItem = list.createWindow(v.vNode);
	if wItem.category and (fCategory ~= "*") then
		wItem.category.setVisible(false);
	end
	wItem.setRecordType(self.getRecordType());
end

function isFilteredRecord(v)
	if bAllowCategories and fCategory ~= "*" then
		if v.sCategory ~= fCategory then
			return false;
		end
	end
	if fSharedOnly then
		if v.nAccess == 0 then
			return false;
		end
	end
	for kCustomFilter,sCustomFilterValue in pairs(aCustomFilterValues) do
		if sCustomFilterValue ~= "" then
			local vValues = self.getFilterValues(kCustomFilter, v.vNode);
			local bMatch = false;
			for _,v in ipairs(vValues) do
				if v:lower() == sCustomFilterValue then
					bMatch = true;
					break;
				end
			end
			if not bMatch then
				return false;
			end
		end
	end
	if fName ~= "" then
		if not string.find(v.sDisplayNameLower, fName, 0, true) then
			return false;
		end
	end
	return true;
end
