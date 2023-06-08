--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function setDefaultCurrencies(w)
	local tEquipment = CharWizardManager.character_choices["equipment"];

	if not tEquipment.currency then
		tEquipment.currency = {};
	end

	for _,v in pairs(CurrencyManager.getCurrencies()) do
		local wNewCurrency = w.createWindow();
		wNewCurrency.name.setValue(v);
		table.insert(tEquipment.currency, { name = v, count = 0 });
	end
end

function updateCurrencyAmount(w)
	local tEquipment = CharWizardManager.character_choices["equipment"];

	for _,v in pairs(tEquipment.currency) do
		if v.name == w.name.getValue() then
			v.count = w.amount.getValue();

			break
		end
	end
end

function collectBackgroundGold()
	local tEquipment = CharWizardManager.character_choices["equipment"];
	local tBackground = CharWizardManager.character_choices["background"];
	local sBackgroundRecord = tBackground.background;
	local nGold = 0;

	if sBackgroundRecord and sBackgroundRecord ~= "" then
		local sEquipment = DB.getValue(DB.findNode(sBackgroundRecord), "equipment", "");

		_,_,nGold = CharWizardEquipmentManager.parseBackgroundEquipmentKitItem(sEquipment:lower());
	end

	tEquipment.backgroundgold = nGold;

	return nGold;
end

function collectBackgroundEquipmentKit(wList)
	local tEquipment = CharWizardManager.character_choices["equipment"];
	local tBackground = CharWizardManager.character_choices["background"];
	local sBackgroundRecord = tBackground.background;

	if sBackgroundRecord and sBackgroundRecord ~= "" then
		local sEquipment = DB.getValue(DB.findNode(sBackgroundRecord), "equipment", "");
		local aItems, aChoices, nGold = CharWizardEquipmentManager.parseBackgroundEquipmentKitItem(sEquipment:lower());

		tEquipment.backgroundother = {};
		tEquipment.backgrounditems = {};

		if next(aItems) then
			tEquipment.backgrounditems = aItems;
		end

		for k,v in pairs(aChoices) do
			local wChoices = wList.createWindow();
			wChoices.type.setValue("Choice #" .. k);
			wChoices.type.setVisible(true);

			wChoices.setData(v, "background");
			wChoices.alert.setVisible(true);
		end

		tEquipment.backgroundgold = nGold;
	end
end

function parseBackgroundEquipmentKitItem(s)
	local aItems = {};
	local aChoices = {};
	local nGold = 0;

	local tSplitEquipment = StringManager.split(s, ",");
	for _,vItem in pairs(tSplitEquipment) do
		-- Gold
		if vItem:match("pouch containing") or vItem:match("purse containing") then
			nGold = tonumber(vItem:match("(%d+)"));
		end

		local tInnate = {};

		-- Clothes
		if vItem:match("common clothes") or vItem:match("commoner's clothes") then
			table.insert(tInnate, "clothes, common");
		elseif vItem:match("traveler's clothes") then
			table.insert(tInnate, "clothes, traveler's");
		elseif vItem:match("fine clothes") then
			table.insert(tInnate, "clothes, fine");
		elseif vItem:match("vestments") then
			table.insert(tInnate, "clothes, vestments");
		elseif vItem:match("costume") then
			table.insert(tInnate, "clothes, costume");
		end

		-- Items
		local tSimple = { "blanket", "block and tackle", "book", "carpenter's tools",
			"crowbar", "dagger", "disguise kit", "emblem", "fishing tackle", "forgery kit",
			"healer's kit", "herbalism kit", "hammer", "horn", "incense", "manacles",
			"poisoner's kit", "pouch", "robe", "staff", "shovel", "tent", "tinderbox",
			"torch",
		};
		for _,v in ipairs(tSimple) do
			if vItem:match(v) then
				table.insert(tInnate, v);
			end
		end

		if vItem:match("belaying pin") then
			table.insert(tInnate, "club");
		end

		if vItem:match("bullseye lantern") then
			table.insert(tInnate, "lantern, bullseye");
		end

		if vItem:match("ink") then
			table.insert(tInnate, "ink (1-ounce bottle)");
		end

		if vItem:match("iron pot") then
			table.insert(tInnate, "pot, iron");
		end

		if vItem:match("miner's pick") then
			table.insert(tInnate, "pick, miner's");
		end

		if vItem:match("parchment") then
			table.insert(tInnate, "parchment (one sheet)");
		end

		if vItem:match("pen ") or vItem:match("quill") or vItem == "pen" then
			table.insert(tInnate, "ink pen");
		end

		if vItem:match("silk rope") then
			table.insert(tInnate, "rope, silk (50 Feet)");
		end

		for _,v in ipairs(tInnate) do
			local nodeItem = RecordManager.findRecordByStringI("item", "name", v);

			if nodeItem then
				table.insert(aItems, { item = nodeItem, count = 1 });
			end
		end

		-- Choices
		if vItem:match("set of bone dice or deck of cards") or vItem:match("gaming set") then
			local tMappings = LibraryData.getMappings("item");
			local aChoicesLocal = {};
			for _,sMapping in ipairs(tMappings) do
				for _,vGlobalItem in pairs(DB.getChildrenGlobal(sMapping)) do
					local sMatch = StringManager.trim(DB.getValue(vGlobalItem, "subtype", ""));
					local sProperties = StringManager.trim(DB.getValue(vGlobalItem, "properties", ""))
					local bMagic = sProperties:match("magic");

					if sMatch:lower() == "gaming set" and not bMagic then
						table.insert(aChoicesLocal, { item = vGlobalItem, count = 1 });
					end
				end
			end

			table.insert(aChoices, aChoicesLocal);
		end

		if vItem:match("artisan") then
			local tMappings = LibraryData.getMappings("item");
			local aChoicesLocal = {};
			for _,sMapping in ipairs(tMappings) do
				for _,vGlobalItem in pairs(DB.getChildrenGlobal(sMapping)) do
					local sMatch = StringManager.trim(DB.getValue(vGlobalItem, "subtype", ""));
					local sProperties = StringManager.trim(DB.getValue(vGlobalItem, "properties", ""))
					local bMagic = sProperties:match("magic");

					if sMatch:lower() == "artisan's tools" and not bMagic then
						table.insert(aChoicesLocal, { item = vGlobalItem, count = 1 });
					end
				end
			end

			table.insert(aChoices, aChoicesLocal);
		end

		if vItem:match("holy symbol") then
			local tMappings = LibraryData.getMappings("item");
			local aChoicesLocal = {};
			for _,sMapping in ipairs(tMappings) do
				for _,vGlobalItem in pairs(DB.getChildrenGlobal(sMapping)) do
					local sMatch = StringManager.trim(DB.getValue(vGlobalItem, "subtype", ""));
					local sProperties = StringManager.trim(DB.getValue(vGlobalItem, "properties", ""))
					local bMagic = sProperties:match("magic");

					if sMatch:lower() == "holy symbol" and not bMagic then
						table.insert(aChoicesLocal, { item = vGlobalItem, count = 1 });
					end
				end
			end

			table.insert(aChoices, aChoicesLocal);
		end

		if vItem:match("musical instrument") then
			local tMappings = LibraryData.getMappings("item");
			local aChoicesLocal = {};
			for _,sMapping in ipairs(tMappings) do
				for _,vGlobalItem in pairs(DB.getChildrenGlobal(sMapping)) do
					local sMatch = StringManager.trim(DB.getValue(vGlobalItem, "subtype", ""));
					local sProperties = StringManager.trim(DB.getValue(vGlobalItem, "properties", ""))
					local bMagic = sProperties:match("magic");

					if sMatch:lower() == "musical instrument" and not bMagic then
						table.insert(aChoicesLocal, { item = vGlobalItem, count = 1 });
					end
				end
			end

			table.insert(aChoices, aChoicesLocal);
		end
	end

	return aItems, aChoices, nGold
end

function collectClassEquipmentKit(wList)
	local tEquipment = CharWizardManager.character_choices["equipment"];
	local tClass = CharWizardManager.character_choices["class"]
	local tStartingKit = {};

	tEquipment.classitems = {};

	for k,v in pairs(tClass) do
		if v.startingclass == 1 and CharWizardData.charwizard_starting_equipment[k:lower()] then
			tStartingKit = CharWizardData.charwizard_starting_equipment[k:lower()];

			break
		end
	end

	for k,v in pairs(tStartingKit) do
		-- Included
		if k:lower():match("included") then
			for _,vItem in pairs(v) do
				local nodeItem = RecordManager.findRecordByStringI("item", "name", vItem.item);
				if nodeItem then
					table.insert(tEquipment.classitems, { item = nodeItem, count = vItem.count });
				end
			end
		end

		-- Choices
		if k:lower():match("choices") then
			for i,vChoice in pairs(v) do
				local wChoices = wList.createWindow();
				wChoices.type.setValue("Choice #" .. i);
				wChoices.type.setVisible(true);

				local aSelections = {};
				for _,vItem in pairs(vChoice) do
					if vItem.selection then
						local tMappings = LibraryData.getMappings("item");
						for _,sMapping in ipairs(tMappings) do
							for _,vGlobalItem in pairs(DB.getChildrenGlobal(sMapping)) do
								local sMatch = StringManager.trim(DB.getValue(vGlobalItem, "subtype", ""));
								local sProperties = StringManager.trim(DB.getValue(vGlobalItem, "properties", ""))
								local bMagic = sProperties:match("magic");

								if sMatch:lower() == vItem.selection and not bMagic then
									table.insert(aSelections, { item = vGlobalItem, count = vItem.count });
								end
							end
						end
					end
					if vItem.item then
						local nodeItem = RecordManager.findRecordByStringI("item", "name", vItem.item);
						if nodeItem then
							table.insert(aSelections, { item = nodeItem, count = vItem.count });
						end
					end
				end

				wChoices.setData(aSelections, "class");
			end
		end
	end

	wList.window.parentcontrol.window.sub_currentinventory.subwindow.rebuildList();
end
