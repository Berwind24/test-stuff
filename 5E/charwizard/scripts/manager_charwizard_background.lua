--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function processBackground(w)
	local tBackground = CharWizardManager.character_choices["background"];
	local tEquipment = CharWizardManager.character_choices["equipment"];
	local wTop = UtilityManager.getTopWindow(w);
	local sClass,sRecord = w.shortcut.getValue();
	local sBackground = DB.getValue(DB.findNode(sRecord), "name", "");

	tBackground.background = sRecord;
	tEquipment.backgroundkit = sBackground;
	tEquipment.backgrounditems = {};

	wTop.sub_background.subwindow.sub_backgroundselection.setVisible(false);
	wTop.sub_background.subwindow.background_select_header.setValue(sBackground:upper());

	CharWizardBackgroundManager.updateBackgroundFeatures(wTop.sub_background.subwindow.background_decisions_list);
end

function updateBackgroundFeatures(w)
	local tBackground = CharWizardManager.character_choices["background"];
	local sBackgroundRecord = tBackground.background;
	local sSkill = DB.getValue(DB.findNode(sBackgroundRecord), "skill", "");
	local sTool = DB.getValue(DB.findNode(sBackgroundRecord), "tool", "");
	local sLanguages = DB.getValue(DB.findNode(sBackgroundRecord), "languages", "");
	local aBackgroundFeatures = {};

	for _,v in pairs(DB.getChildren(DB.findNode(sBackgroundRecord), "features")) do
		local sFeature = DB.getValue(v, "name", "");

		aBackgroundFeatures[sFeature] = v.getPath();
	end

	if sSkill ~= "" then
		local w2 = w.createWindow();
		w2.feature.setValue("Skill");
		w2.feature.setVisible(true);
		w2.button_expand.setVisible(true);
		w2.feature_desc.setValue(sSkill);

		CharWizardBackgroundManager.handleBackgroundSkills(w2, sSkill);
	end

	if sTool ~= "" then
		local w2 = w.createWindow();
		w2.feature.setValue("Proficiency");
		w2.feature.setVisible(true);
		w2.button_expand.setVisible(true);
		w2.feature_desc.setValue(sTool);

		CharWizardBackgroundManager.handleBackgroundTools(w2, sTool);
	end

	if sLanguages ~= "" then
		local w2 = w.createWindow();
		w2.feature.setValue("Language");
		w2.feature.setVisible(true);
		w2.button_expand.setVisible(true);
		w2.feature_desc.setValue(sLanguages);

		CharWizardBackgroundManager.handleBackgroundLanguages(w2, sLanguages)
	end

	for kFeature,vFeature in pairs(aBackgroundFeatures) do
		local sTraitType = StringManager.simplify(vFeature)
		local sText = DB.getValue(DB.findNode(vFeature), "text", "");

		local w2 = w.createWindow();
		w2.feature.setValue(kFeature);
		w2.feature.setVisible(true);
		w2.button_expand.setVisible(true);
		w2.shortcut.setValue("reference_backgroundfeature", vFeature);
		w2.feature_desc.setValue(sText);
	end
end

function handleBackgroundSkills(w, s)
	local tBackground = CharWizardManager.character_choices["background"];
	local tBackgroundFeature, tBackgroundInnate, bChoice, aChoices, nChoices;

	tBackgroundInnate, bChoice, aChoices, nChoices = CharWizardBackgroundManager.parseBackgroundSkills(s:lower());

	if not tBackground.skill then
		tBackground.skill = {};
	end

	for _,v in pairs(tBackgroundInnate) do
		local tSelected = CharWizardManager.getAvailableSkills();
		local w2 = w.decisions_list.createWindow();
		local sTitle = "Select ";
		sTitle = sTitle .. "Skill";

		w2.decision.setValue(sTitle);
		w2.decision.setVisible(true);
		w2.decision_choice.setComboBoxVisible(true);

		if StringManager.contains(tSelected, v) then
			table.insert(tBackground.skill, { skill = v, expertise = 0, type = w.feature.getValue() })
			w2.decision_choice.setValue(StringManager.capitalize(v));
		end

		tSelected = CharWizardManager.getAvailableSkills();
		for _,v in pairs(tSelected) do
			w2.decision_choice.add(StringManager.capitalize(v));
		end
	end

	if bChoice then
		for i = 1, nChoices do
			local w2 = w.decisions_list.createWindow();
			w2.decision.setValue("Select Skill");
			w2.decision.setVisible(true);
			w2.decision_choice.setComboBoxVisible(true);

			for _,v in pairs(aChoices) do
				w2.decision_choice.add(StringManager.capitalize(v));
				w.alert.setVisible(true);
			end
		end
	end
end

function handleBackgroundTools(w, s)
	local tBackground = CharWizardManager.character_choices["background"];
	local tBackgroundFeature, tBackgroundInnate, bChoice, aChoices, nChoices;

	tBackgroundInnate, bChoice, aChoices, nChoices = CharWizardBackgroundManager.parseBackgroundTools(s:lower());

	if not tBackground.proficiency then
		tBackground.proficiency = {};
	end

	for _,v in pairs(tBackgroundInnate) do
		table.insert(tBackground.proficiency, { proficiency = v, expertise = 0 } )
	end

	if bChoice then
		for i = 1, nChoices do
			local w2 = w.decisions_list.createWindow();
			w2.decision.setValue("Select Tool Proficiency");
			w2.decision.setVisible(true);
			w2.decision_choice.setComboBoxVisible(true);

			for _,v in pairs(aChoices) do
				w2.decision_choice.add(StringManager.capitalize(v));
				w.alert.setVisible(true);
			end
		end
	end
end

function handleBackgroundLanguages(w, s)
	local tBackground = CharWizardManager.character_choices["background"];
	local tBackgroundFeature, tBackgroundInnate, bChoice, aChoices, nChoices;

	tBackgroundInnate, bChoice, aChoices, nChoices = CharWizardBackgroundManager.parseBackgroundLanguages(s:lower());

	if not tBackground.language then
		tBackground.language = {};
	end

	for _,v in ipairs(tBackgroundInnate) do
		local tSelected = CharWizardManager.getAvailableLanguages();
		local w2 = w.decisions_list.createWindow();
		local sTitle = "Select ";
		sTitle = sTitle .. "Language";

		w2.decision.setValue(sTitle);
		w2.decision.setVisible(true);
		w2.decision_choice.setComboBoxVisible(true);

		if not StringManager.contains(tBackground.language, v) then
			if StringManager.contains(tSelected, v) then
				table.insert(tBackground.language, { language = v, type = w.feature.getValue() });
				w2.decision_choice.setValue(StringManager.capitalize(v));
			end
		end

        for _,vLang in ipairs(tSelected) do
            if not StringManager.contains(aLanguages, vLang) then
                local sLang = StringManager.capitalize(vLang);
                w2.decision_choice.add(sLang);
            end
        end
	end

	if bChoice then
		for i = 1, nChoices do
			local w2 = w.decisions_list.createWindow();
			w2.decision.setValue("Select Language");
			w2.decision.setVisible(true);
			w2.decision_choice.setComboBoxVisible(true);

			for _,v in pairs(aChoices) do
				w2.decision_choice.add(StringManager.capitalize(v));
				w.alert.setVisible(true);
			end
		end
	end
end

--
-- Parsers
--

function parseBackgroundSkills(s)
	local aSelectedSkills = CharWizardManager.getAvailableSkills();
	local aSortedSelectedSkills = {};
	for _,v in ipairs(aSelectedSkills) do
		aSortedSelectedSkills[v] = true;
	end

	local nPicks = 0;
	local aPickSkills = {};
	local aSkills = {};
	if s:match("choose %w+ from among ") then
		local sPicks, sPickSkills = s:match("choose (%w+) from among (.*)");
		sPickSkills = sPickSkills:gsub("and ", "");

		s = "";
		nPicks = CharManager.convertSingleNumberTextToNumber(sPicks);

		for sSkill in string.gmatch(sPickSkills, "(%a[%a%s]+)%,?") do
			local sTrim = StringManager.trim(sSkill);
			if aSortedSelectedSkills[sTrim] then
				table.insert(aPickSkills, sTrim);
			end
		end
	elseif s:match("plus %w+ from among ") then
		local sPicks, sPickSkills = s:match("plus (%w+) from among (.*)");
		sPickSkills = sPickSkills:gsub("and ", "");
		sPickSkills = sPickSkills:gsub(", as appropriate for your order", "");

		s = s:gsub(sSkills:match("plus %w+ from among (.*)"), "");
		nPicks = CharManager.convertSingleNumberTextToNumber(sPicks);

		for sSkill in string.gmatch(sPickSkills, "(%a[%a%s]+)%,?") do
			local sTrim = StringManager.trim(sSkill);
			if sTrim ~= "" then
				if aSortedSelectedSkills[sTrim] then
					table.insert(aPickSkills, sTrim);
				end
			end
		end
	elseif s:match("plus %w+ of your choice from among") then
		local sPicks, sPickSkills = s:match("plus (%w+) of your choice from among (.*)");
		sPickSkills = sPickSkills:gsub("and ", "");

		s = s:gsub("plus %w+ of your choice from among (.*)", "");

		nPicks = CharManager.convertSingleNumberTextToNumber(sPicks);
		for sSkill in string.gmatch(sPickSkills, "(%a[%a%s]+)%,?") do
			local sTrim = StringManager.trim(sSkill);
			if sTrim ~= "" then
				if aSortedSelectedSkills[sTrim] then
					table.insert(aPickSkills, sTrim);
				end
			end
		end
	elseif s:match("plus your choice of one from among") then
		local sPickSkills = s:match("plus your choice of one from among (.*)");
		sPickSkills = sPickSkills:gsub("and ", "");

		s = s:gsub("plus your choice of one from among (.*)", "");

		nPicks = 1;
		for sSkill in string.gmatch(sPickSkills, "(%a[%a%s]+)%,?") do
			local sTrim = StringManager.trim(sSkill);
			if sTrim ~= "" then
				if aSortedSelectedSkills[sTrim] then
					table.insert(aPickSkills, sTrim);
				end
			end
		end
	elseif s:match("and one intelligence, wisdom, or charisma skill of your choice, as appropriate to your faction") then
		s = s:gsub("and one intelligence, wisdom, or charisma skill of your choice, as appropriate to your faction", "");

		nPicks = 1;
		for k,v in pairs(DataCommon.skilldata) do
			if (v.stat == "intelligence") or (v.stat == "wisdom") or (v.stat == "charisma") then
				if aSortedSelectedSkills[k:lower()] then
					table.insert(aPickSkills, k:lower());
				end
			end
		end
		table.sort(aPickSkills);
	end

	for sSkill in s:gmatch("(%a[%a%s]+),?") do
		local sTrim = StringManager.trim(sSkill);
		if sTrim ~= "" then
			table.insert(aSkills, sTrim);
		end
	end

	return aSkills, (nPicks > 0), aPickSkills, nPicks;
end

function parseBackgroundTools(s)
	local aBackgroundTools = {};
	local aFinalBackgroundTools = {};
	local aChoiceTools = {};
	local nToolChoices = 1;
	local bChoice = false;

	if s:match("two") then
		nToolChoices = 2;
	end

	local sTools = s:match("choose two from among ([^.]+)");

	if not sTools then
		sTools = s:gsub(", likely something native to your homeland", "");

		if sTools:match(" or") then
			sTools = sTools:gsub(" or", ",");
			bChoice = true;
		end
	end

	sTools = sTools:gsub("and", "");
	aBackgroundTools = StringManager.split(sTools, ",", true);

	for _,vTools in pairs(aBackgroundTools) do
		vTools = StringManager.trim(vTools);

		if vTools:match("type") or vTools:match("choice") or nToolChoices > 1 then
			bChoice = true;

			if vTools:match("thieves%'") then
				table.insert(aChoiceTools, "thieves' tools");
			end
		end

		if vTools:match("gaming") or vTools:match("musical") or vTools:match("artisan") then
			local aToolGroups = {};
			local sChoiceTools = vTools:match("type of (.+)");

			if vTools:match("gaming") then
				table.insert(aToolGroups, "gaming set");
			end

			if vTools:match("musical") then
				table.insert(aToolGroups, "musical instrument");
			end

			if vTools:match("artisan") then
				table.insert(aToolGroups, "artisan's tools");
			end

			for _,v in pairs(aToolGroups) do
				local a = CharWizardManager.getToolType(v);

				for _,i in pairs(a) do
					table.insert(aChoiceTools, i);
				end
			end
		else
			if not bChoice then
				table.insert(aFinalBackgroundTools, vTools:lower());
			else
				table.insert(aChoiceTools, vTools:lower());
			end
		end
	end

	return aFinalBackgroundTools, bChoice, aChoiceTools, nToolChoices;
end

function parseBackgroundLanguages(s)
	local aLanguages = {};
	local aBackgroundLanguages = {};
	local aChoiceLanguages = {};
	local nLanguageChoices = 1;
	local bChoice = true;
	local aAvailableLanguages = CharWizardManager.getAvailableLanguages()

	if s:match("two") then
		nLanguageChoices = 2;
	end

	if s:match("if you already speak Dwarvish") then
		--if StringManager.contains(aAvailableLanguages, "dwarvish") then
		if aAvailableLanguages["dwarvish"] then
			table.insert(aBackgroundLanguages, "Dwarvish");
			bChoice = false;
		end
	end

	if s:match("choose") then
		local sChoiceLanguages = s:match("choose one of (.+)");

		if not sChoiceLanguages then
			sChoiceLanguages = s:match("choose either (.+)");
		end

		if not sChoiceLanguages then
			sChoiceLanguages = s:match("choose two languages one of which is an exotic language %((.+)%)");
			aChoiceLanguages = aAvailableLanguages;
		end

		if not sChoiceLanguages then
			sChoiceLanguages = s:match("of your choice");
			aChoiceLanguages = aAvailableLanguages;
		end

		if not sChoiceLanguages then
			return {}, false;
		end

		sChoiceLanguages = sChoiceLanguages:gsub("and ", "");
		sChoiceLanguages = sChoiceLanguages:gsub("or ", "");
		sChoiceLanguages = sChoiceLanguages:gsub("plus(.+)", "");
		sChoiceLanguages = sChoiceLanguages:gsub("one(.+)", "");

		for s in sChoiceLanguages:gmatch("(%a[%a%s]+)%,?") do
			aChoiceLanguages[s:lower()] = {tooltip = "Select Language" };
		end
	end

	if #aChoiceLanguages > 0 then
		return aBackgroundLanguages, bChoice, aChoiceLanguages, nLanguageChoices;
	else
		return aBackgroundLanguages, bChoice, aAvailableLanguages, nLanguageChoices;
	end
end

--
-- Decisions
--

local bUpdating = false;
function processBackgroundDecision(w)
	if bUpdating then
		return
	end

	bUpdating = true;

	local sFeature = w.windowlist.window.feature.getValue();
	local sFeatureType = StringManager.simplify(sFeature:lower());
	local sDecisionChoice = w.decision_choice.getValue():lower();
	local sDecision = w.decision.getValue();
	sDecision = sDecision:gsub("Select ", ""):lower();
	sDecision = sDecision:gsub("%(s%)", "");

	if sDecision == "skill" then
		CharWizardBackgroundManager.processBackgroundDecisionSkill(w);
	elseif sDecision == "language" then
		CharWizardBackgroundManager.processBackgroundDecisionLanguage(w);
	elseif sDecision:match("tool") or sDecision:match("proficiency") then
		CharWizardBackgroundManager.processBackgroundDecisionTool(w);
	end

	bUpdating = false;
end

function processBackgroundDecisionSkill(w)
    local tBackground = CharWizardManager.character_choices["background"];
    if not tBackground.skill then
        tBackground.skill = {};
    end

    local aChoices = {};
    local aChoiceWin = {};

    for k,v in ipairs(tBackground.skill) do
        if v.type == w.windowlist.window.feature.getValue() then
            tBackground.skill[k] = nil;
        end
    end

    for _,wSkill in ipairs(w.windowlist.getWindows()) do
        if wSkill.decision_choice.getValue() ~= "" then
            table.insert(aChoices, wSkill.decision_choice.getValue():lower());
        end

        wSkill.decision_choice.clear();
        aChoiceWin[wSkill] = wSkill;
    end

    for _,v in ipairs(aChoices) do
        table.insert(tBackground.skill, { skill = v, type = w.windowlist.window.feature.getValue() });
    end

    local sFeatureText = w.windowlist.window.feature.getValue();
	local _,_,aSkillChoices = CharWizardBackgroundManager.parseBackgroundSkills(sFeatureText:lower());
    local tSelected = CharWizardManager.getAvailableSkills();

    if not next(aSkillChoices) then
        aSkillChoices = tSelected;
    end

    for _,wChoice in pairs(aChoiceWin) do
        for _,vSkill in pairs(aSkillChoices) do
            if StringManager.contains(tSelected, vSkill) then
                wChoice.decision_choice.add(StringManager.capitalize(vSkill));
            end
        end
    end
end

function processBackgroundDecisionLanguage(w)
	local tBackground = CharWizardManager.character_choices["background"];
    if not tBackground.language then
        tBackground.language = {};
    end

    local aChoices = {};
    local aChoiceWin = {};

    for k,v in ipairs(tBackground.language) do
        if v.type == w.windowlist.window.feature.getValue() then
            tBackground.language[k] = nil;
        end
    end

    for _,wLang in ipairs(w.windowlist.getWindows()) do
        if wLang.decision_choice.getValue() ~= "" then
            table.insert(aChoices, wLang.decision_choice.getValue():lower());
        end

        wLang.decision_choice.clear();
        aChoiceWin[wLang] = wLang;
    end

    for _,v in ipairs(aChoices) do
        table.insert(tBackground.language, { language = v, type = w.windowlist.window.feature.getValue() });
    end

    local sFeatureText = w.windowlist.window.feature_desc.getValue();
    local _,_,aLangChoices = CharWizardBackgroundManager.parseBackgroundLanguages(sFeatureText:lower());
    local tSelected = CharWizardManager.getAvailableLanguages();

    if not next(aLangChoices) then
        aLangChoices = tSelected;
    end

    for _,wChoice in pairs(aChoiceWin) do
        for _,vLang in pairs(aLangChoices) do
            if StringManager.contains(tSelected, vLang) then
                wChoice.decision_choice.add(StringManager.capitalize(vLang));
            end
        end
    end
end

function processBackgroundDecisionTool(w)
	local tBackground = CharWizardManager.character_choices["background"];
	local sBackgroundRecord = tBackground.background;
	local sTool = DB.getValue(DB.findNode(sBackgroundRecord), "tool", "");

	if not tBackground.proficiencies then
		tBackground.proficiencies = {};
	end

	local aChoices = {};
	local aChoiceWin = {};
	local aDecisions = {};

	for k,v in pairs(tBackground.proficiency) do
		if v.type == "innate" then
			aChoices[v.proficiency] = v;
		elseif v.type == "decision" then
			table.remove(tBackground.proficiency, k);
		end
	end

	for _,w in pairs(w.windowlist.getWindows()) do
		if w.decision_choice.getValue() ~= "" then
			aChoices[w.decision_choice.getValue():lower()] = w;
		end

		w.decision_choice.clear();
		aChoiceWin[w] = w;
	end

	for _,v in pairs(w.windowlist.getWindows()) do
		if v.decision_choice.getValue() ~= "" then
			table.insert(aDecisions, { proficiency = v.decision_choice.getValue():lower() } );
		end
	end

	for _,v in pairs(aDecisions) do
		table.insert(tBackground.proficiency, { type = "decision", proficiency = v.proficiency });
	end

	local _,_,aChoiceProf = CharWizardBackgroundManager.parseBackgroundTools(sTool:lower());
	for _,wChoice in pairs(aChoiceWin) do
		for _,vProficiency in pairs(aChoiceProf) do
			local bCreate = true;

			if aChoices[vProficiency] then
				bCreate = false;
			end

			if bCreate then
				wChoice.decision_choice.add(StringManager.titleCase(vProficiency));
			end
		end
	end
end
