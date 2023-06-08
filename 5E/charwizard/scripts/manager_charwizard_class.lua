--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function addClass(sClassRecord, bImport)
	wTop = CharWizardManager.collectWizardWindow();

	local tClass = CharWizardManager.character_choices["class"];
	local sClassName = DB.getValue(DB.findNode(sClassRecord), "name", "");
	local bMultiClass = false;
	local bSpellCaster = false;

	if next(tClass) then
		bMultiClass = true;
	end

	local w = wTop.sub_class.subwindow.class_list.createWindow();
	w.class.setValue(sClassName);
	w.class.setVisible(true);
	w.level_label.setVisible(true);
	w.level.setVisible(true);
	w.idelete.setVisible(true);
	w.shortcut.setValue("reference_class", sClassRecord);

	if CharWizardManager.character_choices.identity then
		CharWizardClassManager.addClassImport(w, sClassName, sClassRecord, bMultiClass);
	else

		CharWizardClassManager.addClassStd(wTop, w, sClassName, sClassRecord, bMultiClass);
	end

	--Proficiencies
	w.button_features.setVisible(true);
	w.button_features.setValue(1);
	w.class_decisions_list.setVisible(true);

	wTop.sub_class.subwindow.sub_classselection.setVisible(false);
	wTop.sub_class.subwindow.filter_name.setVisible(false);
	wTop.sub_class.subwindow.button_addclass.setVisible(true);
end

function addClassImport(w, sClassName, sClassRecord, bMultiClass)
	local tClass = CharWizardManager.character_choices["class"];

	for k,v in pairs(tClass) do
		if v.levelup then
			tClass[k].levelup = nil;
		end
	end

	if not tClass[sClassName] then
		tClass[sClassName] = {};
		tClass[sClassName] = { record = sClassRecord };
	end

	if not tClass[sClassName].level then
		tClass[sClassName].level = 0;
	end

	w.level.setValue(tClass[sClassName].level);
	w.level_up.setVisible(false);
	w.level_down.setVisible(false);
	w.level_label.setVisible(false);
	w.levelup_button.setVisible(true);
	w.idelete.setVisible(false);

	if not tClass[sClassName].import then
		tClass[sClassName].levelup = 1;
		CharWizardClassManager.populateClassProficiencies(w, DB.findNode(sClassRecord), bMultiClass);
		CharWizardClassManager.updateClass(w, sClassName, 1);
	else
		CharWizardClassManager.updateClass(w, sClassName, tClass[sClassName].level);
	end

	CharWizardClassManager.updateClassLevels(wTop.sub_class.subwindow);
end

function addClassStd(wTop, w, sClassName, sClassRecord, bMultiClass)
	local tClass = CharWizardManager.character_choices["class"];
	local tEquipment = CharWizardManager.character_choices["equipment"];

	tClass[sClassName] = { record = sClassRecord };
	tClass[sClassName].level = 0;

	if not bMultiClass then
		tClass[sClassName].startingclass = 1;
		tEquipment.classkit = sClassName;
		tEquipment.classother = {};
		tEquipment.classitems = {};

		local wTop = UtilityManager.getTopWindow(w);
		if wTop.sub_equipment.subwindow then
			local wSubEquipment = wTop.sub_equipment.subwindow;

			if wSubEquipment.sub_currentinventory.subwindow then
				wSubEquipment.sub_currentinventory.subwindow.rebuildList();
			end
		end
	else
		local nCount = 0;
		for _,v in pairs(tClass) do
			nCount = nCount + 1;
		end

		tClass[sClassName].startingclass = nCount + 1;
	end

	CharWizardClassManager.updateClassLevels(wTop.sub_class.subwindow);
	CharWizardClassManager.populateClassProficiencies(w, DB.findNode(sClassRecord), bMultiClass);
	CharWizardClassManager.updateClass(w, sClassName, 1);
end

function deleteClass(wClass, bLevelUp)
	local tClass = CharWizardManager.character_choices["class"];
	local tEquipment = CharWizardManager.character_choices["equipment"];

	local wTop = UtilityManager.getTopWindow(wClass);
	local wClasses = wClass.windowlist.window;
	local sClassName = wClass.class.getValue();
	tClass[sClassName] = nil;

	local tClassMagicData = CharWizardClassManager.getCharWizardMagicData();
	local nNewCasterLevel = CharClassManager.helperCalcSpellcastingLevel(tClassMagicData);
	local nNewPactMagicLevel = CharClassManager.helperCalcPactMagicLevel(tClassMagicData);

	if nNewCasterLevel == 0 then
		tClass.spellslots = nil;
	end
	if nNewPactMagicLevel == 0 then
		tClass.pactmagicslots = nil;
	end

	if not bLevelUp then
		if next(tClass) then
			for _,v in pairs(tClass) do
				if v.startingclass then
					v.startingclass = v.startingclass - 1;

					if v.startingclass == 1 then
						tEquipment.classother = {};
						tEquipment.classitems = {};

						if wTop.sub_equipment.subwindow then
							if wTop.sub_equipment.subwindow.sub_classkit.subwindow then
								wTop.sub_equipment.subwindow.sub_classkit.subwindow.kit_list.closeAll();
							end

							wTop.sub_equipment.subwindow.startingwealth.setValue("");
						end
					end
				else
					tClass = {};
					tEquipment.classother = {};
					tEquipment.classitems = {};
				end
			end
		else
			tEquipment.classother = {};
			tEquipment.classitems = {};

			if wTop.sub_equipment.subwindow then
				if wTop.sub_equipment.subwindow.sub_classkit.subwindow then
					wTop.sub_equipment.subwindow.sub_classkit.subwindow.kit_list.closeAll();
				end

				wTop.sub_equipment.subwindow.startingwealth.setValue("");
			end

			wClass.windowlist.window.sub_classselection.setVisible(true);
			wClass.windowlist.window.sub_classselection.subwindow.rebuildList();
			wTop.sub_class.subwindow.button_addclass.setVisible(false);
		end
	end

	wClass.close();
	CharWizardManager.updateAlerts();
end

function clearClassFeatures(w, sClassName, nClassLevel, bNewSpecAdd)
	local tClass = CharWizardManager.character_choices["class"];

	local aRemoveWin = {};
	for _,v in pairs(w.class_decisions_list.getWindows()) do
		local sFeatureLevel = v.level.getValue();
		local nFeatureLevel = tonumber(sFeatureLevel);
		local _,sFeatureRecord = v.shortcut.getValue();
		local sFeatureSpec = StringManager.trim(DB.getValue(DB.findNode(sFeatureRecord), "specialization", ""));
		local bRemoveFeature;

		if sFeatureSpec == "" then
			bRemoveFeature = (nFeatureLevel > nClassLevel);
		else
			if sFeatureSpec ~= tClass[sClassName].specialization then
				bRemoveFeature = true;
			else
				bRemoveFeature = (nFeatureLevel > nClassLevel);
			end
		end

		if bRemoveFeature then
			local sFeature = v.feature.getValue();
			if tClass[sClassName].features[sFeature] then
				tClass[sClassName].features[sFeature] = nil;

				table.insert(aRemoveWin, v);
			end
		end
	end

	for _,v in ipairs(aRemoveWin) do
		v.close();
	end
end

function updateClass(w, sClassName, nNewClassLevel, bNewSpecAdd)
	local tClass = CharWizardManager.character_choices["class"];
	local nodeClass = RecordManager.findRecordByStringI("class", "name", sClassName);
	local sClassSpec = tClass[sClassName].specialization or "";

	nNewClassLevel = tonumber(nNewClassLevel);

	local nOldClassLevel = tClass[sClassName].level;

	tClass[sClassName].level = nNewClassLevel;
	w.level.setValue(tClass[sClassName].level);

	CharWizardClassManager.clearClassFeatures(w, sClassName, nNewClassLevel, bNewSpecAdd);

	if (nNewClassLevel > nOldClassLevel) then
		CharWizardClassManager.populateClassFeatures(w, nodeClass, nNewClassLevel, nOldClassLevel, bNewSpecAdd);
	end

	if nNewClassLevel == nOldClassLevel then
		if bNewSpecAdd then
			CharWizardClassManager.populateClassFeatures(w, nodeClass, nNewClassLevel, nOldClassLevel, bNewSpecAdd)
		end

		CharWizardClassManager.updateClassFeatures(w, nodeClass);
	end

	CharWizardClassManager.updateClassLevels(w.windowlist.window);

	local tClassMagicData = CharWizardClassManager.getCharWizardMagicData();
	local nSpellcastingLevel = CharClassManager.helperCalcSpellcastingLevel(tClassMagicData);
	local nPactMagicLevel = CharClassManager.helperCalcPactMagicLevel(tClassMagicData);

	if nSpellcastingLevel > 0 or nPactMagicLevel > 0 then
		CharWizardClassManager.updateSpellSlots(w, sClassName, nOldCasterLevel, nOldPactMagicLevel);
	end
end

function updateClassLevels(w)
	local nTotalLevel = 0;

	if not CharWizardManager.character_choices.identity then
		for _,v in pairs(w.class_list.getWindows()) do
			local nClassLevel = v.level.getValue();

			v.level_down.setVisible(nClassLevel ~= 1);

			nTotalLevel = nTotalLevel + nClassLevel;
		end

		local nMaxLevels = 21 - nTotalLevel;
		for _,v in pairs(w.class_list.getWindows()) do
			v.level_up.setVisible(nTotalLevel ~= 20);
		end
	end
end

function updateClassFeatures(w, nodeClass)
	local tClass = CharWizardManager.character_choices["class"];

	local sClassName = DB.getValue(nodeClass, "name", "");
	local sSpecialization = tClass[sClassName].specialization or "";

	for _,v in ipairs(w.class_decisions_list.getWindows()) do
		local sFeatureName = v.feature.getValue();
		local sFeatureType = StringManager.simplify(sFeatureName)
		local _,sFeatureRecord = v.shortcut.getValue();
		local sTrimmedFeatureType = sFeatureType:gsub("level%d+", "");

		if StringManager.contains({"skill", "language", "proficiency", "feat", "expertise"}, sTrimmedFeatureType) then
			for _,v2 in ipairs(v.decisions_list.getWindows()) do
				local sDecision = v2.decision.getValue();
				sDecision = sDecision:gsub("Select ", ""):lower();

				v2.decision_choice.clear();

				if sTrimmedFeatureType == "feat" then
					CharWizardClassManager.handleClassFeatDecision(v2, sClassName, sDecision, sFeatureName, sFeatureRecord)
				elseif sTrimmedFeatureType == "expertise" then
					CharWizardClassManager.handleClassExpertiseDecision(v2, sClassName, sDecision, sFeatureName, sFeatureRecord)
				else
					CharWizardClassManager.handleClassDecision(v2, sClassName, sDecision, sFeatureName, sFeatureRecord)
				end
			end
		end
	end
end

function populateClassProficiencies(w, nodeClass, bMultiClass)
	local tClass = CharWizardManager.character_choices["class"];

	local sClassName = DB.getValue(nodeClass, "name", "");
	local aProfDesc = {};
	local tProficiencies = DB.getChildren(nodeClass, "proficiencies");

	if not tClass[sClassName].features then
		tClass[sClassName].features = {};
	end

	local tClassFeatures = tClass[sClassName].features;
	if not tClassFeatures["Proficiencies"] then tClassFeatures["Proficiencies"] = {};
	end
	local tClassProfs = tClassFeatures.proficiency;

	if not tClassProfs then
		tClassProfs = {};
	end

	if bMultiClass then
		tProficiencies = DB.getChildren(nodeClass, "multiclassproficiencies");
		aProfDesc = {"<h>Multi-Class Proficiencies</h>"};
	end

	local w2 = w.class_decisions_list.createWindow();
	w2.feature.setValue("(Level 00) Proficiencies");
	w2.feature.setVisible(true);
	w2.level.setValue(0);
	w2.button_expand.setVisible(true);

	for _,v in pairs(tProficiencies) do
		local sSourceName = StringManager.trim(DB.getValue(v, "name", ""));
		local sSourceType = StringManager.simplify(sSourceName);

		if sSourceType == "" then
			sSourceType = v.getName();
		end

		if not bMultiClass then
			if sSourceType == "savingthrows" then
				local sSavingThrowDesc = CharWizardClassManager.addClassSavingThrow(v, tClassProfs);
				table.insert(aProfDesc, sSavingThrowDesc);
			end

			-- Skill Proficiencies
			if sSourceType == "skills" then
				local sClassProfDesc = CharWizardClassManager.addClassProfSkills(w2, v, tClassProfs);
				table.insert(aProfDesc, sClassProfDesc);
			end
		end

		-- Armor, Weapon or Tool Proficiencies
		if StringManager.contains({"armor", "weapons", "tools"}, sSourceType) then
			local sClassProfDesc = CharWizardClassManager.addClassProficiency(w2, v, sSourceType, sClassName);
			table.insert(aProfDesc, sClassProfDesc);
		end
	end

	local sProfDesc = table.concat(aProfDesc, "");
	w2.feature_desc.setValue(sProfDesc);
end

function addClassSavingThrow(nodeProf, tClassProfs)
	local sText = StringManager.trim(DB.getText(nodeProf, "text", ""));
	local sSavingThrowDesc = "";

	if sText ~= "" then
		sSavingThrowDesc = "<p><b>Saving Throws:</b> " .. sText .. "</p>";

		for sProf in sText:gmatch("(%a[%a%s]+)%,?") do
			local sProfLower = StringManager.trim(sProf):lower();
			if StringManager.contains(DataCommon.abilities, sProfLower) then
				if not tClassProfs.saveprof then
					tClassProfs.saveprof = {};
				end

				table.insert(tClassProfs.saveprof, { ability = sProfLower } )
			end
		end
	end

	return sSavingThrowDesc;
end

function addClassProficiency(w, nodeProf, sSourceType, sClassName)
	local tClass = CharWizardManager.character_choices["class"];
	if not tClass[sClassName].features then
		tClass[sClassName].features = {};
	end

	if not tClass[sClassName].features["Proficiencies"] then
		tClass[sClassName].features["Proficiencies"] = {};
	end

	if not tClass[sClassName].features["Proficiencies"].proficiency then
		tClass[sClassName].features["Proficiencies"].proficiency = {};
	end

	local sText = StringManager.trim(DB.getText(nodeProf, "text", ""));
	local sClassProfDesc = "";

	if sText ~= "" and sText:lower() ~= "none" then
		local sLoweredText = sText:lower();
		local sValue = "";

		if sSourceType == "armor" then
			sValue = Interface.getString("char_label_addprof_armor");
		elseif sSourceType == "weapons" then
			sValue = Interface.getString("char_label_addprof_weapon");
		else
			sValue = Interface.getString("char_label_addprof_tool");
		end
		sClassProfDesc = "<p><b>" .. sValue .. ":</b> " .. sText .. "</p>";

		for _,v in ipairs(StringManager.split(sLoweredText, ",")) do
			if v:match("druids") then
				v = v:gsub(" %(druids will not wear armor or use shields made of metal%)", "");
			end

			local bChoice, aClassProfs, nChoices, aChoiceProfs =
			CharWizardClassManager.parseClassProficiencies(v);

			if bChoice then
				for i = 1, nChoices do
					local w2 = w.decisions_list.createWindow();
					if sValue == Interface.getString("char_label_addprof_tool") then
						w2.decision.setValue("Select Proficiency");
					else
						w2.decision.setValue("Select " .. sValue);
					end
					w2.decision.setVisible(true);
					w2.decision_choice.setComboBoxVisible(true);

					for _,v in ipairs(aChoiceProfs) do
						w2.decision_choice.add(StringManager.capitalize(v));
					end
				end
			else
				for _,v in pairs(aClassProfs) do
					table.insert(tClass[sClassName].features["Proficiencies"].proficiency,
					{ proficiency = v, expertise = 0, type = "innate" });
				end
			end
		end
	end

	return sClassProfDesc;
end

function addClassProfSkills(w, nodeProf, tClassProfs)
	local tAvailableSkills = CharWizardManager.getAvailableSkills();
	local nPicks, tSkills = CharManager.parseSkillProficiencyText(nodeProf);
	local sProfDesc = {};

	local tFinalSkills = {};
	if nPicks > 0 then
		if #tSkills == 0 then
			for _,v in ipairs(tAvailableSkills) do
				table.insert(tFinalSkills, v);
			end
		else
			for _,v in ipairs(tSkills) do
				if not tClassProfs.skill then
					tClassProfs.skill = {};
				end

				v = StringManager.trim(v):lower();
				if StringManager.contains(tAvailableSkills, v) then
					table.insert(tFinalSkills, v);
				end
			end
		end
	end

	if nPicks ~= 0 then
		sProfDesc = "<p><b>Skills:</b> " .. StringManager.trim(DB.getText(nodeProf, "text", "")) .. "</p>";

		for i = 1, nPicks do
			local w2 = w.decisions_list.createWindow();
			w2.decision.setValue("Select Skill");
			w2.decision.setVisible(true);
			w2.decision_choice.setComboBoxVisible(true);

			for _,v in ipairs(tFinalSkills) do
				w2.decision_choice.add(StringManager.capitalize(v));
			end
		end
	else
		if next(tFinalSkills) then
			for _,v in ipairs(tFinalSkills) do
				table.insert( tClassProfs.skill, { skill = v:lower(), type = "innate", expertise = 0 });
			end
		end
	end

	return aProfDesc;
end

function populateClassFeatures(w, nodeClass, nClassLevel, nOldClassLevel, bNewSpecAdd)
	local tClass = CharWizardManager.character_choices["class"];
	local sClassName = DB.getValue(nodeClass, "name", "");
	local sSpecialization = tClass[sClassName].specialization or "";

	local tMappings = LibraryData.getMappings("class");
	local tFilteredClasses = {};
	for _,sMapping in ipairs(tMappings) do
		for _,v in pairs(DB.getChildrenGlobal(sMapping)) do
			local sChkClass = DB.getValue(v, "name", "");
			if sChkClass:lower() == sClassName:lower() then
				table.insert(tFilteredClasses, v);
			end
		end
	end

	local tAddFeatures = {};
	for _,vClass in ipairs(tFilteredClasses) do
		for _,vFeature in pairs(DB.getChildren(vClass, "features")) do
			local sFeature = DB.getValue(vFeature, "name", "");
			local nFeatureLevel = DB.getValue(vFeature, "level", 0);
			local sFeatureSpec = StringManager.trim(DB.getValue(vFeature, "specialization", ""));
			local bAddFeature;

			if (sFeatureSpec == "") and not bNewSpecAdd then
				bAddFeature = (nFeatureLevel == nClassLevel)
			else
				if sFeatureSpec == sSpecialization then
					if bNewSpecAdd then
						bAddFeature = nFeatureLevel <= nClassLevel;
					else
						bAddFeature = (nFeatureLevel == nClassLevel);
					end
				end
			end

			if bAddFeature then
				tAddFeatures[sFeature:lower()] = vFeature;
			end
		end
	end

	for _,v in pairs(tAddFeatures) do
		CharWizardClassManager.addClassFeature(w, v, sClassName);
	end
end

function addClassFeature(w, vFeature, sClassName)
	local tClass = CharWizardManager.character_choices.class;
	local sFeatureName = DB.getValue(vFeature, "name", "");
	local sFeatureText = DB.getValue(vFeature, "text", "");
	local sFeatureType = StringManager.simplify(sFeatureName);
	local nFeatureLevel = DB.getValue(vFeature, "level", "");

	sFeatureName =  "(Level " ..  string.format("%02d", nFeatureLevel) .. ") " .. sFeatureName;

	if not tClass[sClassName].features then
		tClass[sClassName].features = {};
	end

	if not tClass[sClassName].features[sFeatureName] then
		tClass[sClassName].features[sFeatureName] = {};
	end

	local w2 = w.class_decisions_list.createWindow();
	w2.feature.setValue(sFeatureName);
	w2.feature.setVisible(true);
	w2.level.setValue(nFeatureLevel);
	w2.button_expand.setVisible(true);
	w2.feature_desc.setValue(sFeatureText);
	w2.shortcut.setValue("reference_classfeature", vFeature.getPath());

	if DB.getValue(vFeature, "specializationchoice", 0) > 0 then
		local w3 = w2.decisions_list.createWindow();
		w3.decision.setValue("Select Specialization");
		w3.decision.setVisible(true);
		w3.decision_choice.setComboBoxVisible(true);

		local tClassSpecOptions = CharClassManager.getClassSpecializationOptions(sClassName);
		for k,v in pairs(tClassSpecOptions) do
			w3.decision_choice.add(v.text);
			w2.alert.setVisible(true);
		end
	elseif sFeatureType == "abilityscoreimprovement" then
		local w3 = w2.decisions_list.createWindow();
		w3.decision.setValue("Select Option");
		w3.decision.setVisible(true);
		w3.decision_choice.setComboBoxVisible(true);
		w3.decision_choice.addItems({"Ability Score Increase", "Feat"});
		w2.alert.setVisible(true);
	elseif sFeatureType == "expertise" then
		for i = 1, 2 do
			local w3 = w2.decisions_list.createWindow();
			w3.decision.setValue("Select Expertise");
			w3.decision.setVisible(true);
			w3.decision_choice.setComboBoxVisible(true);

			local aProfs = CharWizardManager.collectExpertiseSkills();
			if sClassName:lower() == "rogue" then
				local nProf = CharWizardManager.collectExpertiseProf("thieves' tools");
				if nProf and nProf == 0 then
					table.insert(aProfs, "thieves' tools");
				end
			end

			for _,v in ipairs(aProfs) do
				local nProf = CharWizardManager.collectExpertiseProf(v);
				if nProf and nProf == 0 then
					w3.decision_choice.add(StringManager.titleCase(v));
				end
			end
			w2.alert.setVisible(true);
		end
	elseif CharWizardDataAction.parsedata[sFeatureType] then
		local tFeatureAction = CharWizardDataAction.parsedata[sFeatureType];

		if tFeatureAction["proficiency"] then
			CharWizardClassManager.handleFeatureProficiency(w2, sClassName, sFeatureName, tFeatureAction["proficiency"]);
		end
		--[[if tFeatureAction["spell"] then
			CharWizardClassManager.handleFeatureSpells(w2, sClassName, sFeatureName, tFeatureAction["spell"]);
		end--]]
		if tFeatureAction["skill"] then
			CharWizardClassManager.handleFeatureSkills(w2, sClassName, sFeatureName, tFeatureAction["skill"]);
		end
		if tFeatureAction["language"] then
			CharWizardClassManager.handleFeatureLanguages(w2, sClassName, sFeatureName, tFeatureAction["language"]);
		end
	end
end

function handleFeatureProficiency(w, sClassName, sFeatureName, tFeature)
	local tClass = CharWizardManager.character_choices["class"];
	local tCurClass = tClass[sClassName];
	if tFeature.innate then
		if not tCurClass.features then
			tClass.features = {};
		end
		if not tCurClass.features[sFeatureName] then
			tCurClass.features[sFeatureName] = {};
		end
		if not tCurClass.features[sFeatureName].proficiency then
			tCurClass.features[sFeatureName].proficiency = {};
		end

		for _,v in pairs(tFeature.innate) do
			table.insert(tCurClass.features[sFeatureName].proficiency, { proficiency = v, type = "innate", expertise = 0 });
		end
	end

	if tFeature.choice then
		tChoiceProficiencies = {};
		tChoiceProficiencies = tFeature.choice_prof;

		for i = 1, tFeature.choice do
			local w2 = w.decisions_list.createWindow();
			w2.decision.setValue("Select Proficiency");
			w2.decision.setVisible(true);
			w2.decision_choice.setComboBoxVisible(true);

			for k,v in pairs(tChoiceProficiencies) do
				w2.decision_choice.add(StringManager.capitalize(v));
				w.alert.setVisible(true);
			end
		end
	end
end

function handleFeatureSkills(w, sClassName, sFeatureName, tFeature)
	local tClass = CharWizardManager.character_choices["class"];
	local tCurClass = tClass[sClassName];

	if not tCurClass.features then
		tCurClass.features = {};
	end

	if tFeature.innate then
		if not tCurClass.features[sFeatureName] then
			tCurClass.features[sFeatureName] = {};
		end
		if not tCurClass.features[sFeatureName].skill then
			tCurClass.features[sFeatureName].skill = {};
		end

		for _,v in pairs(tFeature.innate) do
			local tSelected = CharWizardManager.getAvailableSkills();
			local w2 = w.decisions_list.createWindow();
			local sTitle = "Select ";
			sTitle = sTitle .. "Skill";

			w2.decision.setValue(sTitle);
			w2.decision.setVisible(true);
			w2.decision_choice.setComboBoxVisible(true);

			if StringManager.contains(tSelected, v) then
				table.insert(tCurClass.features[sFeatureName].skill, { skill = v, expertise = 0 })
				w2.decision_choice.setValue(StringManager.capitalize(v));
			end

			tSelected = CharWizardManager.getAvailableSkills();
			for _,v in pairs(tSelected) do
				w2.decision_choice.add(StringManager.capitalize(v));
			end
		end
	end

	if tFeature.choice then
		tChoiceSkills = {};
		if StringManager.contains(tFeature.choice_skill, "any") then
			tChoiceSkills = CharWizardManager.getAvailableSkills();
		else
			tChoiceSkills = tFeature.choice_skill;
		end

		for i = 1, tFeature.choice do
			local w2 = w.decisions_list.createWindow();
			w2.decision.setValue("Select Skill");
			w2.decision.setVisible(true);
			w2.decision_choice.setComboBoxVisible(true);

			for k,v in pairs(tChoiceSkills) do
				w2.decision_choice.add(StringManager.capitalize(v));
				w.alert.setVisible(true);
			end
		end
	end
end

function handleFeatureLanguages(w, sClassName, sFeatureName, tFeature)
	local tClass = CharWizardManager.character_choices["class"];
	local tCurClass = tClass[sClassName];

	if not tCurClass.features then
		tCurClass.features = {};
	end

	if tFeature.innate then
		if not tCurClass.features[sFeatureName] then
			tCurClass.features[sFeatureName] = {};
		end
		if not tCurClass.features[sFeatureName].language then
			tCurClass.features[sFeatureName].language = {};
		end

		for _,v in pairs(tFeature.innate) do
			local tSelected = CharWizardManager.getAvailableLanguages();
			local w2 = w.decisions_list.createWindow();
			local sTitle = "Select ";
			sTitle = sTitle .. "Language";

			w2.decision.setValue(sTitle);
			w2.decision.setVisible(true);
			w2.decision_choice.setComboBoxVisible(true);

			if StringManager.contains(tSelected, v) then
				table.insert(tCurClass.features[sFeatureName].language, { language = v });
				w2.decision_choice.setValue(StringManager.capitalize(v));
			end

			tSelected = CharWizardManager.getAvailableLanguages();
			for _,v in pairs(tSelected) do
				w2.decision_choice.add(StringManager.capitalize(v));
			end
		end
	end

	if tFeature.choice then
		tChoiceLanguages = {};

		if StringManager.contains(tFeature.choice_language, "any") then
			tChoiceLanguages = CharWizardManager.getAvailableLanguages();
		else
			tChoiceLanguages = tFeature.choice_language;
		end

		for i = 1, tFeature.choice do
			local w2 = w.decisions_list.createWindow();
			w2.decision.setValue("Select Language");
			w2.decision.setVisible(true);
			w2.decision_choice.setComboBoxVisible(true);

			for k,v in pairs(tChoiceLanguages) do
				w2.decision_choice.add(StringManager.capitalize(v));
				w.alert.setVisible(true);
			end
		end
	end
end

function handleFeatureSpells(w, sClassName, sFeatureName, tFeature)
	local tClass = CharWizardManager.character_choices["class"];
	local tCurClass = tClass[sClassName];
	if not tCurClass.features then
		tCurClass.features = {};
	end
	if not tCurClass.features[sFeatureName] then
		tCurClass.features[sFeatureName] = {};
	end

	if tFeature.level then
		if not tCurClass.features[sFeatureName].spell then
			tCurClass.features[sFeatureName].spell = {};
		end

		for k,v in pairs(tFeature.level) do
			if tCurClass.level >= k then
				for _,v2 in pairs(v) do
					table.insert(tCurClass.features[sFeatureName].spell, { spell = v2, type = "innate" });
				end
			end
		end
	end

	if tFeature.innate then
		if not tCurClass.features[sFeatureName].spell then
			tCurClass.features[sFeatureName].spell = {};
		end

		for k,v in pairs(tFeature.innate) do
			table.insert(tCurClass.features[sFeatureName].spell, { spell = v, type = "innate" });
		end
	end

	if tFeature.choice then
		tChoiceSpells = {};

		if StringManager.contains(tFeature.choice_spell, "any") then
			local sSpellList = tFeature.spelllist;
			local sSpellSchool = tFeature.spellschool;
			local nSpellLevel = tFeature.spelllevel;

			local tMappings = LibraryData.getMappings("spell");
			for _,sMapping in ipairs(tMappings) do
				for _,v in pairs(DB.getChildrenGlobal(sMapping)) do
					local nodeSpell = v;
					local sSpellName = DB.getValue(nodeSpell, "name", "");
					local sList = DB.getValue(nodeSpell, "source", "");
					local sSchool = DB.getValue(nodeSpell, "school", "");
					local nLevel = DB.getValue(nodeSpell, "level", 0);

					local bAddSpell;
					if sSpellList then
						if StringManager.contains(StringManager.split(sList, ","), sClassName) then
							bAddSpell = true;
						end
						if StringManager.contains(StringManager.split(sList, ","), tCurClass.specialization) then
							bAddSpell = true;
						end
					end
					if sSpellSchool then
						if sSpellSchool == sSchool then
							bAddSpell = true;
						end
					end
					if nSpellLevel then
						if nSpellLevel == nLevel then
							bAddSpell = true;
						end
					end

					if bAddSpell then
						table.insert(tChoiceSpells, sSpellName);
					end
				end
			end
		else
			tChoiceSpells = tFeature.choice_spell;
		end

		for i = 1, tFeature.choice do
			if not tCurClass.features[sFeatureName].spells then
				tCurClass.features[sFeatureName].spells = {};
			end

			local w2 = w.decisions_list.createWindow();
			w2.decision.setValue("Select Spell");
			w2.decision.setVisible(true);
			w2.decision_choice.setComboBoxVisible(true);

			for k,v in pairs(tChoiceSpells) do
				w2.decision_choice.add(StringManager.capitalize(v));
				w.alert.setVisible(true);
			end
		end
	end
end

--
-- Parsers
--

function parseClassProficiencies(s)
	local aClassProfs = {};
	local nChoices = 1;
	local aChoiceProfs = {};
	local bChoice = false;
	local tCurProfs = CharWizardManager.collectProficiencies();
	local bGlobal = false;

	s = s:gsub(" or ", ",")
	aTools = StringManager.split(s, ",");

	for _,v in pairs(aTools) do
		v = StringManager.trim(v);

		if v:match("%d+") then
			nChoices = CharManager.convertSingleNumberTextToNumber(v:match("%d+"));
		end

		if v:match("gaming") or v:match("musical") or v:match("artisan") then
			local sToolType = v:match("gaming set");

			if not sToolType then
				sToolType = v:match("musical instrument");
			end

			if not sToolType then
				sToolType = v:match("artisan's tools");
			end
			local tTools = CharWizardManager.getToolType(sToolType);

			for _,vTool in pairs(tTools) do
				if not tCurProfs[vTool] then
					table.insert(aChoiceProfs, vTool);
				end
			end

			bChoice = true;
		end
		if v:match("all armor") or v:match("simple weapons") or
			v:match("martial weapons") then

			local sMatch = v:match("all armor");
			if not sMatch then
				sMatch = v:match("simple weapons");
			end
			if not sMatch then
				sMatch = v:match("martial weapons");
			end

			if not tCurProfs[sMatch] then
				table.insert(aClassProfs, sMatch);
			end

			bGlobal = true;
		end
		if not bChoice and not bGlobal then
			if not tCurProfs[v] then
				table.insert(aClassProfs, v);
			end
		end
	end

	return bChoice, aClassProfs, nChoices, aChoiceProfs;
end


--
-- Spells
--

function getCharWizardMagicData()
	local tClass = CharWizardManager.character_choices["class"];
	local tClassMagicData = {};
	local nSpellClasses = 0;

	for _,vClass in pairs(tClass) do
		if vClass.record then
			local nodeClass = DB.findNode(vClass.record);
			local sClassName = DB.getValue(nodeClass, "name", "");
			local nClassLevel = vClass.level or 0;
			local sClassSpec = vClass.specialization or "";
			local nodeSpellcasting, sName;

			local rAdd = {};
			rAdd.sName = sClassName;
			rAdd.nLevel = nClassLevel;
			rAdd.sClassSpec = sClassSpec;

			local tMappings = LibraryData.getMappings("class");
			local tFilteredClasses = {};
			for _,sMapping in ipairs(tMappings) do
				for _,v in pairs(DB.getChildrenGlobal(sMapping)) do
					local sChkClass = DB.getValue(v, "name", "");
					if sChkClass:lower() == sClassName:lower() then
						table.insert(tFilteredClasses, v);
					end
				end
			end

			for _,vClass in ipairs(tFilteredClasses) do
				for _,v in pairs(DB.getChildren(vClass, "features")) do
					if DB.getValue(v, "level", 0) <= nClassLevel then
						local sFeatureName = DB.getValue(v, "name", "");
						local sSourceNameLower = StringManager.trim(sFeatureName):lower();
						local sSpec = DB.getValue(v, "specialization", "");
						local bSpec = (sSpec == "") or (sSpec:lower() == sClassSpec:lower());
						local bSpellcasting = sSourceNameLower == CharManager.FEATURE_SPELLCASTING;
						rAdd.bPactMagic = sSourceNameLower == CharManager.FEATURE_PACT_MAGIC;

						if (bSpellcasting or rAdd.bPactMagic) and bSpec then
							nodeSpellcasting = v;

							if (sClassName:lower() == "fighter") or (sClassName:lower() == "rogue") then
								sName = sClassSpec;
							else
								sName = sClassName;
							end

							break
						end
					end
				end
			end
			if not nodeSpellcasting and (sClassSpec ~= "") then
				local nodeSpec = CharClassManager.getClassSpecializationRecord(sClassName, sClassSpec)
				if nodeSpec then
					for _,v in pairs(DB.getChildren(nodeSpec.linkrecord, "features")) do
						if DB.getValue(v, "level", 0) <= nClassLevel then
							local sFeatureName = DB.getValue(v, "name", "");
							local sSourceNameLower = StringManager.trim(sFeatureName):lower();
							local bSpellcasting = sSourceNameLower == CharManager.FEATURE_SPELLCASTING;
							rAdd.bPactMagic = sSourceNameLower == CharManager.FEATURE_PACT_MAGIC;

							if (bSpellcasting or rAdd.bPactMagic) then
								rAdd.bPactMagic = (sSourceNameLower == CharManager.FEATURE_PACT_MAGIC);
								nodeSpellcasting = v;
								sName = sClassSpec;

								break
							end
						end
					end
				end
			end

			if nodeSpellcasting then
				nSpellClasses = nSpellClasses + 1;
				rAdd = CharWizardClassManager.decodeSpellcastingFeature(nodeSpellcasting, sName, rAdd);
				table.insert(tClassMagicData, rAdd);
			end
		end
	end

	tClassMagicData.nSpellClasses = nSpellClasses;

	return tClassMagicData;
end

function decodeSpellcastingFeature(v, sName, rAdd)
	if not rAdd then
		return {};
	end

	local sSpellcasting = DB.getText(v, "text", ""):lower();
	rAdd.nSpellSlotMult = DB.getValue(v, "level", 0);
	rAdd.sAbility = sSpellcasting:match("(%a+) is your spellcasting ability");

	local sCantripCheck = "";
	if sName:match("%s+") then
		sCantripCheck = sName:gsub("%s+", "_");
	else
		sCantripCheck = sName;
	end

	local sKnownCheck = sCantripCheck:upper() .. "_SPELLSKNOWN";
	sCantripCheck = sCantripCheck:upper() .. "_CANTRIPS";

	if CharWizardData[sCantripCheck] then
		if CharWizardData.CLASS_CANTRIPS[CharWizardData[sCantripCheck]][rAdd.nLevel] ~= 0 then
			rAdd.nCantrips = CharWizardData.CLASS_CANTRIPS[CharWizardData[sCantripCheck]][rAdd.nLevel];
		end
	end

	if CharWizardData[sKnownCheck] then
		if CharWizardData[sKnownCheck][rAdd.nLevel] ~= 0 then
			rAdd.nKnownSpells = CharWizardData[sKnownCheck][rAdd.nLevel];
		else
			rAdd.nKnownSpells = 1;
		end
	else
		if rAdd.sAbility then
			local wTop = CharWizardManager.collectWizardWindow();
			local nAbilityScore = 10;
			local nAbilityBonus = 0;

			if wTop.sub_abilities and wTop.sub_abilities.subwindow then
				CharWizardAbilitiesManager.updateAbilitiesTotal(wTop.sub_abilities.subwindow, rAdd.sAbility)
				nAbilityScore = CharWizardManager.character_choices["abilityscore"][rAdd.sAbility].total or 10;
			end
			if CharWizardManager.character_choices.identity then
				local tASI = CharWizardAbilitiesManager.collectASIAbilities();
				nAbilityScore = CharWizardManager.character_choices["abilityscore"][rAdd.sAbility].base or 10;

				if tASI[sAbility] then
					nAbilityScore = nAbilityScore + tASI[rAdd.sAbility];
				end
			end

			nAbilityBonus = math.floor((nAbilityScore - 10) / 2);
			rAdd.nPreparedSpells = rAdd.nLevel + nAbilityBonus;

			if not rAdd.nPreparedSpells or rAdd.nPreparedSpells < 1 then
				rAdd.nPreparedSpells = 1;
			end
		end
	end

	return rAdd;
end

function updateSpellSlots(w, sClassName, nOldCasterLevel, nOldPactMagicLevel)
	local tClass = CharWizardManager.character_choices["class"];
	local tClassMagicData = CharWizardClassManager.getCharWizardMagicData();
	local nNewCasterLevel = CharClassManager.helperCalcSpellcastingLevel(tClassMagicData);
	local nNewPactMagicLevel = CharClassManager.helperCalcPactMagicLevel(tClassMagicData);

	if nNewCasterLevel > 0 then
		local tSpellcastingSlotChange = CharClassManager.helperGetSpellcastingSlotChange(0, nNewCasterLevel);
		local sTitle = sClassName:upper();
		sTitle = sTitle:gsub("[%s+]", "_");

		if not tClass.spellslots then
			tClass.spellslots = {};
		end

		tClass.spellslots = tSpellcastingSlotChange;
	end

	if nNewPactMagicLevel > 0 then
		local tPactMagicSlotChange = CharClassManager.helperGetPactMagicSlotChange(0, nNewPactMagicLevel);
		if not tClass.pactmagicslots then
			tClass.pactmagicslots = {};
		end

		tClass.pactmagicslots = tPactMagicSlotChange;
	end

	if nNewCasterLevel > 0 or nNewPactMagicLevel > 0 then
		local bCaster = false;
		for _,v in pairs(tClassMagicData) do
			if (type(v) == "table") and (sClassName:lower() == v.sName:lower()) then
				tClass[sClassName].cantrips = v.nCantrips or 0;
				tClass[sClassName].knownspells = v.nKnownSpells or 0;
				tClass[sClassName].preparedspells = v.nPreparedSpells or 0;

				bCaster = true;

				break
			end
		end

		if bCaster then
			w.button_spells.setVisible(true);
		end

		if w.sub_classspells.subwindow then
			w.sub_classspells.subwindow.updateTotals();
		end
	end
end

--
-- Decisions
--

local bUpdating = false
function processClassDecision(w)
	if bUpdating then
		return
	end

	bUpdating = true;

	local tClass = CharWizardManager.character_choices["class"];
	local sClassName = w.windowlist.window.windowlist.window.class.getValue();
	local sFeature = w.windowlist.window.feature.getValue();
	local _,sFeatureRecord = w.windowlist.window.feature.getValue();
	local tCurClass = tClass[sClassName];
	local wClass = w.windowlist.window.windowlist.window;

	local sDecision = w.decision.getValue();
	local sChoice = w.decision_choice.getValue();
	sDecision = sDecision:gsub("Select ", ""):lower();

	if sDecision == "specialization" then
		if sChoice ~= "" then
			tCurClass.specialization = sChoice;
			CharWizardClassManager.updateClass(wClass, sClassName, tCurClass.level, true);
		end
	elseif sDecision == "option" then
		CharWizardClassManager.handleOptionDecision(w, sOption, tClass, sClassName);
	elseif sDecision == "ability score increase" then
		CharWizardClassManager.handleClassASIDecision(w, sClassName, sDecision, sFeature, sFeatureRecord)
	elseif sDecision == "expertise" then
		CharWizardClassManager.handleClassExpertiseDecision(w, sClassName, sDecision, sFeature, sFeatureRecord);
	elseif StringManager.contains({"skill", "language", "proficiency"}, sDecision) then
		CharWizardClassManager.handleClassDecision(w, sClassName, sDecision, sFeature, sFeatureRecord)
	end

	local wTop = UtilityManager.getTopWindow(w);
	for _,v in pairs(wTop.sub_class.subwindow.class_list.getWindows()) do
		CharWizardClassManager.updateClass(v, v.class.getValue(), v.level.getValue());
	end

	bUpdating = false;
end

function handleClassExpertiseDecision(w, sClassName, sDecision, sFeature, sFeatureRecord)
	local tClass = CharWizardManager.character_choices["class"];
	local tCurClass = tClass[sClassName];
	local aChoices = {};
	local aChoiceWin = {};

	if not tCurClass.features[sFeature] then
		tCurClass.features[sFeature] = {};
	end

	if not tCurClass.features[sFeature][sDecision] then
		tCurClass.features[sFeature][sDecision] = {};
	end

	if tCurClass.features[sFeature][sDecision] then
		for k,v in pairs(tCurClass.features[sFeature][sDecision]) do
			CharWizardManager.setExpertiseProf(v, 0);
			tCurClass.features[sFeature][sDecision][k] = nil;
		end
	end

	for _,w in pairs(w.windowlist.getWindows()) do
		local sWinDecision = w.decision.getValue();
		sWinDecision = sWinDecision:gsub("Select ", "");

		if sWinDecision:lower() == sDecision then
			if w.decision_choice.getValue() ~= "" then
				aChoices[w.decision_choice.getValue():lower()] = w.decision_choice.getValue():lower();
			end

			w.decision_choice.clear();
			aChoiceWin[w] = w;
		end
	end

	for _,v in pairs(aChoices) do
		CharWizardManager.setExpertiseProf(v, 1);
	end

	for _,wChoice in pairs(aChoiceWin) do
		for _,vDecision in pairs(CharWizardManager.collectExpertiseSkills()) do
			wChoice.decision_choice.add(StringManager.capitalize(vDecision));
		end
		if sClassName:lower() == "rogue" then
			local nProf = CharWizardManager.collectExpertiseProf("thieves' tools");
			if nProf and nProf == 0 then
				wChoice.decision_choice.add("Thieves' Tools");
			end
		end
	end
end

function handleOptionDecision(w, sOption, tClass, sClassName)
	local sOption = w.decision_choice.getValue():lower();
	for _,v in pairs(w.windowlist.getWindows()) do
		local sWinDecision = v.decision.getValue():lower();
		sWinDecision = sWinDecision:gsub("select ","");

		if sWinDecision ~= "option" then
			v.close();
		end
	end

	if sOption == "ability score increase" then
		for i = 1, 2 do
			local w2 = w.windowlist.createWindow();
			w2.decision.setValue("Select Ability Score Increase");
			w2.decision.setVisible(true);
			w2.decision_choice.setComboBoxVisible(true);

			if i == 1 then
				w2.decision_desc.setValue("Select your ability score increases. Each selection provides a +1 to selected ability.")
				w2.decision_desc.setVisible(true)
			end

			for _,v in pairs(DataCommon.abilities) do
				w2.decision_choice.add(StringManager.capitalize(v));
				w.alert.setVisible(true);
			end
		end
	elseif sOption == "feat" then
		local w2 = w.windowlist.createWindow();
		w2.decision.setValue("Select Feat");
		w2.decision.setVisible(true);
		w2.sub_decision_choice.setVisible(true);
		w.alert.setVisible(true);
	end
end

function handleClassASIDecision(w, sClassName, sDecision, sFeature, sFeatureRecord)
	local tClass = CharWizardManager.character_choices["class"];
	local tCurClass = tClass[sClassName];
	local aChoices = {};
	local aChoiceWin = {};

	if not tCurClass.features[sFeature] then
		tCurClass.features[sFeature] = {};
	end

	tCurClass.features[sFeature].abilityinc = {};

	if tCurClass.features[sFeature].feat then
		tCurClass.features[sFeature].feat = nil;
	end

	local bEmpty = false;
	for _,w in pairs(w.windowlist.getWindows()) do
		local sWinDecision = w.decision.getValue();
		sWinDecision = sWinDecision:gsub("Select ", "");
		if sWinDecision:lower() == sDecision then
			if w.decision_choice.getValue() ~= "" then
				table.insert(aChoices, { ability = w.decision_choice.getValue():lower(), mod = 1 });
			end

			aChoiceWin[w] = w;
		end
	end

	for k,v in pairs(aChoices) do
		table.insert(tCurClass.features[sFeature].abilityinc, { ability = v.ability, mod = v.mod });
	end

	for _,wChoice in pairs(aChoiceWin) do
		for _,v in ipairs(DataCommon.abilities) do
			wChoice.decision_choice.add(StringManager.capitalize(vDecision));
		end
	end
end

function handleClassDecision(w, sClassName, sDecision, sFeature, sFeatureRecord)
	local tClass = CharWizardManager.character_choices["class"];
	local tCurClass = tClass[sClassName];
	local aChoices = {};
	local aChoiceWin = {};

	if not tCurClass.features then
		tCurClass.features = {};
	end

	if not tCurClass.features[sFeature] then
		tCurClass.features[sFeature] = {};
	end

	if not tCurClass.features[sFeature][sDecision] then
		tCurClass.features[sFeature][sDecision] = {};
	end

	if tCurClass.features[sFeature][sDecision] then
		for k,v in pairs(tCurClass.features[sFeature][sDecision]) do
			if v.type == "decision" then
				tCurClass.features[sFeature][sDecision][k] = nil;
			end
		end
	end

	for _,w in pairs(w.windowlist.getWindows()) do
		local sWinDecision = w.decision.getValue();
		sWinDecision = sWinDecision:gsub("Select ", "");

		if sWinDecision:lower() == sDecision then
			if w.decision_choice.getValue() ~= "" then
				aChoices[w.decision_choice.getValue():lower()] = w.decision_choice.getValue():lower();
			end

			w.decision_choice.clear();
			aChoiceWin[w] = w;
		end
	end

	for _,v in pairs(aChoices) do
		if not tCurClass.features[sFeature][sDecision] then
			tCurClass.features[sFeature][sDecision] = {};
		end

		table.insert(tCurClass.features[sFeature][sDecision], { ["type"] = "decision", [sDecision] = v, ["expertise"] = 0 });
	end

	local sFeatureType = StringManager.simplify(sFeature);
	local tFeatureAction = CharWizardDataAction.parsedata[sFeatureType];
	local tChoiceDecision = {};

	if tFeatureAction then
		if StringManager.contains(tFeatureAction[sDecision]["choice_" .. sDecision], "any") then
			if sDecision == "skill" then
				tChoiceDecision = CharWizardManager.getAvailableSkills();
			elseif sDecision == "language" then
				tChoiceDecision = CharWizardManager.getAvailableLanguages();
			end
		else
			tChoiceDecision = tFeatureAction[sDecision]["choice_" .. sDecision];
		end
	else
		for _,v in pairs(DB.getChildren(DB.findNode(tCurClass.record), "proficiencies")) do
			local sSourceName = StringManager.trim(DB.getValue(v, "name", ""));
			local sSourceType = StringManager.simplify(sSourceName);

			if sSourceType == "" then
				sSourceType = v.getName();
			end

			--Skills
			if (sSourceType == sDecision .. "s") and sDecision == "skill" then
				local tAvailableSkills = CharWizardManager.getAvailableSkills();
				local _,tSkills = CharManager.parseSkillProficiencyText(v);

				if #tSkills == 0 then
					for _,v in ipairs(tAvailableSkills) do
						table.insert(tChoiceDecision, v);
					end
				else
					for _,v in ipairs(tSkills) do
						v = StringManager.trim(v):lower();
						if StringManager.contains(tAvailableSkills, v) then
							table.insert(tChoiceDecision, v);
						end
					end
				end

				break
			end
			if sDecision == "language" then
				tChoiceDecision = CharWizardManager.getAvailableLanguages();
			end
			if sSourceType == sDecision or sSourceType == "tools" and sDecision == "proficiency" then
				local sText = DB.getValue(v, "text", "");

				if sText ~= "" then
					_,_,_,tChoiceDecision = CharWizardClassManager.parseClassProficiencies(sText:lower());
				end

				break
			end
		end
	end

	for _,wChoice in pairs(aChoiceWin) do
		for _,vDecision in pairs(tChoiceDecision) do
			local bCreate = true;

			if aChoices[vDecision:lower()] then
				bCreate = false;
			end

			if bCreate then
				wChoice.decision_choice.add(StringManager.capitalize(vDecision));
			end
		end
	end
end
