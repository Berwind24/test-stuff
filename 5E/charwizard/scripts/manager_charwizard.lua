--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

character_choices = {
	["abilityscore"] = {};
	["race"] = {},
	["class"] = {},
	["abilities"] = {},
	["background"] = {},
	["equipment"] = {},
	["import"] = {},
};

function outputUserMessage(sResource, ...)
	local sFormat = Interface.getString(sResource);
	local sMsg = string.format(sFormat, ...);
	ChatManager.SystemMessage(sMsg);
end

--
--Overrides
--

function onInit()
	CharManager.parseSkillProficiencyText = parseSkillProficiencyText;
end

function parseSkillProficiencyText(nodeSkillProf)
	if not nodeSkillProf then
		return 0, {};
	end
	local sText = DB.getValue(nodeSkillProf, "text", "");
	if (sText or "") == "" then
		return 0, {};
	end

	local tSkills = {};
	local sPicks;
	if sText:match("Choose any ") then
		sPicks = sText:match("Choose any (%w+)");

	elseif sText:match("Choose ") then
		sPicks = sText:match("Choose (%w+) ");

		sText = sText:gsub("Choose (%w+) from ", "");
		sText = sText:gsub("Choose (%w+) skills? from ", "");
		sText = sText:gsub("and ", "");
		sText = sText:gsub("or ", "");

		for sSkill in sText:gmatch("(%a[%a%s]+)%,?") do
			table.insert(tSkills, StringManager.trim(sSkill));
		end
	else
		local tCheckSkills = StringManager.split(sText, ",")
		for _,v in ipairs(tCheckSkills) do
			if DataCommon.skilldata[v:lower()] then
				table.insert(tSkills, v:lower());
			end
		end
	end

	local nPicks = CharManager.convertSingleNumberTextToNumber(sPicks) or 0;

	return nPicks, tSkills;
end

--
-- Collection Utilities
--

function collectWizardWindow()
	if CharWizardManager.character_choices.identity then
		return Interface.findWindow("charwizard_levelup", "");
	else
		return Interface.findWindow("charwizard", "");
	end
end

function collectSkills()
	local tRace = CharWizardManager.character_choices.race or {};
	local tClass = CharWizardManager.character_choices.class or {};
	local tBackground = CharWizardManager.character_choices.background or {};
	local tImport = CharWizardManager.character_choices.import or {};
	local tSkills = {};
	local tCheckDuplicates = {};

	if tRace.skill then
		for _,v in pairs(tRace.skill) do
			local sTrimSkill = StringManager.trim(v.skill);
			table.insert(tSkills, sTrimSkill);
		end
	end

	for _,v in pairs(tClass) do
		if v.features then
			for _,v2 in pairs(v.features) do
				if v2.skill then
					for _,v3 in pairs(v2.skill) do
						local sTrimSkill = StringManager.trim(v3.skill);
						table.insert(tSkills, sTrimSkill);
					end
				end
			end
		end
	end

	if tBackground.skill then
		for _,v in pairs(tBackground.skill) do
			local sTrimSkill = StringManager.trim(v.skill);
			table.insert(tSkills, sTrimSkill);
		end
	end

	if tImport.skills then
		for _,v in pairs(tImport.skills) do
			table.insert(tSkills, StringManager.trim(v.skill));
		end
	end

	return tSkills;
end

function collectExpertiseSkills()
	local tRace = CharWizardManager.character_choices["race"] or {};
	local tClass = CharWizardManager.character_choices["class"] or {};
	local tBackground = CharWizardManager.character_choices["background"] or {};
	local tImport = CharWizardManager.character_choices.import or {};
	local tSkills = {};

	if tRace.skill then
		for _,v in pairs(tRace.skill) do
			if v.expertise == 0 then
				table.insert(tSkills, StringManager.trim(v.skill));
			end
		end
	end

	for _,v in pairs(tClass) do
		if v.features then
			for _,v2 in pairs(v.features) do
				if v2.skill then
					for _,v3 in pairs(v2.skill) do
						if v3.expertise == 0 then
							table.insert(tSkills, StringManager.trim(v3.skill));
						end
					end
				end
			end
		end
	end

	if tBackground.skill then
		for _,v in pairs(tBackground.skill) do
			if v.expertise == 0 then
				table.insert(tSkills, StringManager.trim(v.skill));
			end
		end
	end

	if tImport.skills then
		for _,v in pairs(tImport.skills) do
			if v.expertise == 0 then
				table.insert(tSkills, StringManager.trim(v.skill));
			end
		end
	end

	return tSkills;
end

function getAvailableSkills()
	local tSkills = CharWizardManager.collectSkills();
	local tAvailableSkills = {};

	for kSkill,_ in pairs(DataCommon.skilldata) do
		local sSkillName = StringManager.trim(kSkill):lower();
		if not StringManager.contains(tSkills, sSkillName) then
			table.insert(tAvailableSkills, sSkillName);
		end
	end

	return tAvailableSkills;
end

function collectLanguages()
	local tRace = CharWizardManager.character_choices.race or {};
	local tClass = CharWizardManager.character_choices.class or {};
	local tBackground = CharWizardManager.character_choices.background or {};
	local tImport = CharWizardManager.character_choices.import or {};
	local tKnownLanguages = {};

	if tRace.language then
		for _,v in pairs(tRace.language) do
			table.insert(tKnownLanguages, StringManager.trim(v.language));
		end
	end
	for _,v in pairs(tClass) do
		if v.features then
			for _,v2 in pairs(v.features) do
				if v2.language then
					for _,v3 in pairs(v2.language) do
						table.insert(tKnownLanguages, StringManager.trim(v3.language));
					end
				end
			end
		end
	end
	if tBackground.language then
		for _,v in pairs(tBackground.language) do
			table.insert(tKnownLanguages, StringManager.trim(v.language));
		end
	end

	if tImport.languages then
		for _,v in pairs(tImport.languages) do
			table.insert(tKnownLanguages, StringManager.trim(v.language));
		end
	end

	return tKnownLanguages;
end

function getAvailableLanguages()
	local tKnownLanguages = CharWizardManager.collectLanguages();
	local tAvailableLanguages = {};

	for _,vLang in pairs(DB.getChildren(DB.findNode("languages"))) do
		local sLangName = StringManager.trim(DB.getValue(vLang, "name", "")):lower();
		if not StringManager.contains(tKnownLanguages, sLangName) then
			table.insert(tAvailableLanguages, sLangName);
		end
	end

	return tAvailableLanguages;
end

function setExpertiseProf(sName, nMod)
	local tClass = CharWizardManager.character_choices.class or {};
	local tRace = CharWizardManager.character_choices.race or {};
	local tBackground = CharWizardManager.character_choices.background or {};
	local tImport = CharWizardManager.character_choices.import or {};

	if sName == "thieves' tools" then
		for _,v in pairs(tClass) do
			if v.features then
				for _,v2 in pairs(v.features) do
					if v2.proficiency then
						for _,v3 in pairs(v2.proficiency) do
							local sMatch = StringManager.trim(v3.proficiency):lower();
							if sName == sMatch then
								v3.expertise = nMod;

								return
							end
						end
					end
				end
			end
		end
	end

	if tRace.skill then
		for _,v in pairs(tRace.skill) do
			local sMatch = StringManager.trim(v.skill):lower();
			if sName == sMatch then
				v.expertise = nMod;

				return
			end
		end
	end

	for _,v in pairs(tClass) do
		if v.features then
			for _,v2 in pairs(v.features) do
				if v2.skill then
					for _,v3 in pairs(v2.skill) do
						local sMatch = StringManager.trim(v3.skill):lower();
						if sName == sMatch then
							v3.expertise = nMod;

							return
						end
					end
				end
			end
		end
	end

	if tBackground.skill then
		for _,v in pairs(tBackground.skill) do
			local sMatch = StringManager.trim(v.skill):lower();
			if sName == sMatch then
				v.expertise = nMod;

				return
			end
		end
	end

	if tImport.skills then
		for _,v in pairs(tImport.skills) do
			local sMatch = StringManager.trim(v.skill):lower();
			if sName == sMatch then
				v.expertise = nMod;

				return
			end
		end
	end
end

function collectExpertiseProf(sName)
	local tClass = CharWizardManager.character_choices.class or {};
	local tRace = CharWizardManager.character_choices.race or {};
	local tBackground = CharWizardManager.character_choices.background or {};
	local tImport = CharWizardManager.character_choices.import or {};

	if tRace.skill then
		for _,v in pairs(tRace.skill) do
			local sMatch = StringManager.trim(v.skill):lower();
			if sName == sMatch then
				return v.expertise;
			end
		end
	end

	for _,v in pairs(tClass) do
		if v.features then
			for _,v2 in pairs(v.features) do
				if v2.skill then
					for _,v3 in pairs(v2.skill) do
						local sMatch = StringManager.trim(v3.skill):lower();
						if sName == sMatch then
							return v3.expertise;
						end
					end
				end
			end
		end
	end

	if tBackground.skill then
		for _,v in pairs(tBackground.skill) do
			local sMatch = StringManager.trim(v.skill):lower();
			if sName == sMatch then
				return v.expertise;
			end
		end
	end

	if tImport.skills then
		for _,v in pairs(tImport.skills) do
			local sMatch = StringManager.trim(v.skill):lower();
			if sName == sMatch then
				return v.expertise;
			end
		end
	end

	if sName == "thieves' tools" then
		for _,v in pairs(tClass) do
			if v.features then
				for _,v2 in pairs(v.features) do
					if v2.proficiency then
						for _,v3 in pairs(v2.proficiency) do
							local sMatch = StringManager.trim(v3.proficiency):lower();
							if sName == sMatch then

								return v3.expertise;
							end
						end
					end
				end
			end
		end
	end

	return 0
end

function collectProficiencies(bSummary)
	local tRace = CharWizardManager.character_choices.race or {};
	local tClass = CharWizardManager.character_choices.class or {};
	local tBackground = CharWizardManager.character_choices.background or {};
	local tImport = CharWizardManager.character_choices.import or {};
	local aCurProfs = {};
	local bAllArmor = false;
	local bSimpleWeapons = false;
	local bMartialWeapons = false;

	if tRace.proficiency then
		for _,v in pairs(tRace.proficiency) do
			local sMatch = StringManager.trim(v.proficiency):lower();
			if sMatch == "all armor" then
				bAllArmor = true;
			end
			if sMatch == "simple weapons" then
				bSimpleWeapons = true;
			end
			if sMatch == "martial weapons" then
				bMartialWeapons = true;
			end

			aCurProfs[sMatch] = v;
		end
	end
	for _,v in pairs(tClass) do
		if v.features then
			for _,v2 in pairs(v.features) do
				if v2.proficiency then
					for _,v3 in pairs(v2.proficiency) do
						local sMatch = StringManager.trim(v3.proficiency):lower();
						if sMatch == "all armor" then
							bAllArmor = true;
						end
						if sMatch == "simple weapons" then
							bSimpleWeapons = true;
						end
						if sMatch == "martial weapons" then
							bMartialWeapons = true;
						end

						aCurProfs[sMatch] = v3;
					end
				end
			end
		end
	end
	if tBackground.proficiency then
		for _,v in pairs(tBackground.proficiency) do
			local sMatch = StringManager.trim(v.proficiency):lower();
			if sMatch == "all armor" then
				bAllArmor = true;
			end
			if sMatch == "simple weapons" then
				bSimpleWeapons = true;
			end
			if sMatch == "martial weapons" then
				bMartialWeapons = true;
			end

			aCurProfs[sMatch] = v;
		end
	end

	if tImport.profs then
		for _,v in pairs(tImport.profs) do
			local sMatch = StringManager.trim(v.proficiency):lower();
			if sMatch == "all armor" then
				bAllArmor = true;
			end
			if sMatch == "simple weapons" then
				bSimpleWeapons = true;
			end
			if sMatch == "martial weapons" then
				bMartialWeapons = true;
			end

			aCurProfs[sMatch] = v;
		end
	end

	if bSummary then
		local aFinalProfs = aCurProfs;
		if bSimpleWeapons then
			for t,_ in pairs(CharWizardData.aSimpleWeapons) do
				aFinalProfs[t] = nil;
			end
		end
		if bMartialWeapons then
			for t,_ in pairs(CharWizardData.aMartialWeapons) do
				aFinalProfs[t] = nil;
			end
		end
		if bAllArmor then
			for t,_ in pairs(CharWizardData.aAllArmor) do
				aFinalProfs[t] = nil;
			end
		end

		return aFinalProfs
	else
		return aCurProfs;
	end
end

function getToolType(sToolType)
	local aTools = {};

	if sToolType and sToolType ~= "" then
		sToolType = string.lower(sToolType);
	end

	local aMappings = LibraryData.getMappings("item");
	for _,vMapping in ipairs(aMappings) do
		for _,vItems in pairs(DB.getChildrenGlobal(vMapping)) do
			local sTypeMatch = StringManager.trim(DB.getValue(vItems, "type", "")):lower();
			if sTypeMatch == "tools" then
				if sToolType and sToolType ~= "" then
					local sSubtypeMatch = StringManager.trim(DB.getValue(vItems, "subtype", "")):lower();
					if sSubtypeMatch == sToolType then
						table.insert(aTools, StringManager.trim(DB.getValue(vItems, "name", "")):lower());
					end
				else
					table.insert(aTools, StringManager.trim(DB.getValue(vItems, "name", "")):lower());
				end
			end
		end
	end

	local aFinalTools = {};
	local aDupes = {};

	for _,v in ipairs(aTools) do
		if not aDupes[v] then
			table.insert(aFinalTools, v);
			aDupes[v] = true;
		end
	end

	return aFinalTools;
end

function collectFeats()
	local tRace = CharWizardManager.character_choices["race"];
	local tClass = CharWizardManager.character_choices["class"];
	local tSelectedFeats = {};

	if tRace.feat then
		table.insert(tSelectedFeats, StringManager.trim(tRace.feat));
	end

	for _,v in pairs(tClass) do
		if v.features then
			for k,v2 in pairs(v.features) do
				if v2.feat then
					table.insert(tSelectedFeats, StringManager.trim(v2.feat));
				end
			end
		end
	end

	return tSelectedFeats;
end

function getAvailableFeats()
	local tKnownFeats = CharWizardManager.collectFeats();
	local tAvailableFeats = {};

	local aMappings = LibraryData.getMappings("feat");
	for _,vMapping in ipairs(aMappings) do
		for _,vFeat in pairs(DB.getChildrenGlobal(vMapping)) do
			local sFeat = StringManager.trim(DB.getValue(vFeat, "name", ""));
			if sFeat ~= "" and (not StringManager.contains(tKnownFeats, sFeat:lower())) then
				table.insert(tAvailableFeats, sFeat:lower());
			end
		end
	end

	return tAvailableFeats;
end

--
-- Summary
--

function clearSummary()
	local wTop = CharWizardManager.collectWizardWindow();
	local wCommit = wTop.sub_commit.subwindow;

	if wCommit.sub_commit_summary.subwindow then
		local wSummary = wCommit.sub_commit_summary.subwindow;
		wSummary.strength_total.setValue();
		wSummary.strength_modifier.setValue();
		wSummary.dexterity_total.setValue();
		wSummary.dexterity_modifier.setValue();
		wSummary.constitution_total.setValue();
		wSummary.constitution_modifier.setValue();
		wSummary.intelligence_total.setValue();
		wSummary.intelligence_modifier.setValue();
		wSummary.wisdom_total.setValue();
		wSummary.wisdom_modifier.setValue();
		wSummary.charisma_total.setValue();
		wSummary.charisma_modifier.setValue();

		wSummary.summary_race.setValue();
		wSummary.summary_background.setValue();
		wSummary.summary_class.setValue();
		wSummary.summary_senses.setValue();
		wSummary.summary_speed.setValue();
		wSummary.summary_speedspecial.setValue();

		wSummary.summary_languages.closeAll();
		wSummary.summary_skills.closeAll();
		wSummary.summary_traits.closeAll();
		wSummary.summary_features.closeAll();
		wSummary.summary_proficiencies.closeAll();
	end
end

function populateSummary()
	local wTop = CharWizardManager.collectWizardWindow();
	local wCommit = wTop.sub_commit.subwindow;
	local wSummary = wCommit.sub_commit_summary.subwindow;
	local tASI = CharWizardManager.character_choices.abilityscore or {};
	local tRace = CharWizardManager.character_choices.race or {};
	local tBackground = CharWizardManager.character_choices.background or {};
	local tClass = CharWizardManager.character_choices.class or {};

	local sRace, sSubRace, sBackground;
	if tRace.race and tRace.race ~= "" then
		sRace = DB.getValue(DB.findNode(tRace.race), "name", "");
		for _,v in pairs(DB.getChildren(DB.findNode(tRace.race), "traits")) do
			local w = wSummary.summary_traits.createWindow();
			w.name.setValue(DB.getValue(v, "name", ""));
		end
	end
	if tRace.subrace and tRace.subrace ~= "" then
		sSubRace = DB.getValue(DB.findNode(tRace.subrace), "name", "");
		for _,v in pairs(DB.getChildren(DB.findNode(tRace.subrace), "traits")) do
			local w = wSummary.summary_traits.createWindow();
			w.name.setValue(DB.getValue(v, "name", ""));
		end
	end
	if tBackground.background and tBackground.background ~= "" then
		sBackground = DB.getValue(DB.findNode(tBackground.background), "name", "");
	end

	if next(tASI) then
		for k,v in pairs(tASI) do
			local nBase = v.base or 10;
			local nRace = v.race or 0;
			local nMisc = v.misc or 0;
			local nOverride = v.override;
			local tASI = CharWizardAbilitiesManager.collectASIAbilities();
			local nASI = tASI[k] or 0;

			if not v.total then
				v.total = nBase + nRace + nASI + nMisc;
			end

			v.modifier = math.floor((v.total - 10) / 2);

			wSummary[k .. "_total"].setValue(v.total);
			wSummary[k .. "_modifier"].setValue((v.modifier <= 0 and "" or "+") .. v.modifier);
		end
	else
		for _,v in ipairs(DataCommon.abilities) do
			wSummary[v .. "_modifier"].setValue(0);
		end
	end

	local sRaceTitle = sRace or "";
	if sSubRace and sSubRace ~= "" then
		sRaceTitle = sRaceTitle .. " (" .. sSubRace .. ")";
	end

	local tClasses = {};
	for k,v in pairs(tClass) do
		local sClass = k;
		local sSpec = v.specialization;
		local nLevel = v.level or 0;

		sClass = sClass:sub(1,3);

		if nLevel > 0 then
			table.insert(tClasses, sClass .. " " .. math.floor(nLevel*100)*0.01);
		end

		if v.features then
			for k,v2 in pairs(v.features) do
				local w = wSummary.summary_features.createWindow();
				local sFeature = k;
				sFeature = sFeature:gsub("%(Level %d+%)", "");
				sFeature = StringManager.trim(sFeature);

				w.name.setValue(sFeature);
			end
		end
	end

	wSummary.summary_race.setValue(sRaceTitle);
	wSummary.summary_background.setValue(sBackground);
	wSummary.summary_class.setValue(table.concat(tClasses, " / "));
	wSummary.summary_senses.setValue(tRace.darkvision);
	wSummary.summary_speed.setValue(tRace.speed);
	wSummary.summary_speedspecial.setValue(tRace.speedspecial);

	for _,v in ipairs(CharWizardManager.collectLanguages()) do
		local w = wSummary.summary_languages.createWindow();
		w.name.setValue(StringManager.capitalize(v));
	end

	for _,v in ipairs(CharWizardManager.collectSkills()) do
		local w = wSummary.summary_skills.createWindow();
		w.name.setValue(StringManager.capitalize(v));
	end

	for _,v in pairs(CharWizardManager.collectProficiencies(true)) do
		local w = wSummary.summary_proficiencies.createWindow();
		w.name.setValue(StringManager.titleCase(v.proficiency));
	end

	for _,v in ipairs(CharWizardManager.collectFeats()) do
		local w = wSummary.summary_feats.createWindow();
		w.name.setValue(StringManager.titleCase(v.name));
	end
end

--
-- Alerts
--

local _tWarnings = {};
function checkCompletion()
	local wTop = CharWizardManager.collectWizardWindow();
	local bComplete = true;
	local aRaceAlerts, aClassAlerts, aAbilitiesAlerts, aBackgroundAlerts, aEquipmentAlerts = CharWizardManager.updateAlerts();

	_tWarnings = {};

	if next(aRaceAlerts) or next(aClassAlerts) or next(aAbilitiesAlerts) or next(aBackgroundAlerts) or next(aEquipmentAlerts) then
		bComplete = false;
	end

	if not bComplete and wTop.sub_commit.subwindow then
		wTop.sub_commit.subwindow.warnings.closeAll();

		for _,v in ipairs(aRaceAlerts) do
			local w = wTop.sub_commit.subwindow.warnings.createWindow();
			w.warning.setValue(v);
			table.insert(_tWarnings, v);
		end
		for _,v in ipairs(aClassAlerts) do
			local w = wTop.sub_commit.subwindow.warnings.createWindow();
			w.warning.setValue(v);
			table.insert(_tWarnings, v);
		end
		for _,v in ipairs(aAbilitiesAlerts) do
			local w = wTop.sub_commit.subwindow.warnings.createWindow();
			w.warning.setValue(v);
			table.insert(_tWarnings, v);
		end
		for _,v in ipairs(aBackgroundAlerts) do
			local w = wTop.sub_commit.subwindow.warnings.createWindow();
			w.warning.setValue(v);
			table.insert(_tWarnings, v);
		end
		for _,v in ipairs(aEquipmentAlerts) do
			local w = wTop.sub_commit.subwindow.warnings.createWindow();
			w.warning.setValue(v);
			table.insert(_tWarnings, v);
		end
	end

	return bComplete;
end

function getCommitWarnings()
	return _tWarnings;
end

function updateAlerts()
	local wTop = CharWizardManager.collectWizardWindow();
	local aButtons = {};

	if CharWizardManager.character_choices.identity then
		aButtons = { "class" };
	else
		aButtons = { "race", "class", "abilities", "background", "equipment" };
	end

	local aRaceAlerts = {};
	local aClassAlerts = {};
	local aAbilitiesAlerts = {};
	local aBackgroundAlerts = {};
	local aEquipmentAlerts = {};

	for _,vButton in ipairs(aButtons) do
		if wTop and wTop.sub_step_buttons.subwindow["button_" .. vButton] then
			local bTopAlert = false;

			local cAlert = wTop.sub_step_buttons.subwindow["button_" .. vButton].findWidget("alert");
			if not cAlert then
				cAlert = wTop.sub_step_buttons.subwindow["button_" .. vButton].addBitmapWidget();
				cAlert.setPosition("bottomright", -5, -5);
				cAlert.setSize(20, 20)
				cAlert.setName("alert");
			end

			if vButton == "race" then
				bTopAlert,aRaceAlerts = CharWizardManager.updateRaceAlerts(wTop);
			elseif vButton == "class" then
				bTopAlert,aClassAlerts = CharWizardManager.updateClassAlerts(wTop);
			elseif vButton == "abilities" then
				bTopAlert,aAbilitiesAlerts = CharWizardManager.updateAbilitiesAlerts(wTop);
			elseif vButton == "background" then
				bTopAlert,aBackgroundAlerts = CharWizardManager.updateBackgroundAlerts(wTop);
			elseif vButton == "equipment" then
				bTopAlert,aEquipmentAlerts = CharWizardManager.updateEquipmentAlerts(wTop);
			end

			if bTopAlert then
				cAlert.setBitmap("button_alert");
			else
				cAlert.setBitmap("button_dialog_ok_down");
			end
		end
	end

	return aRaceAlerts, aClassAlerts, aAbilitiesAlerts, aBackgroundAlerts, aEquipmentAlerts;
end

function updateRaceAlerts(w)
	local wRace = w.sub_race.subwindow;
	local aAlerts = {};
	local bTopAlert = false;

	if wRace then
		if not wRace.race_decisions_list or wRace.race_decisions_list.isEmpty() then
			return true, {"Select Race"};
		end

		for _,v in pairs(wRace.race_decisions_list.getWindows()) do
			local bAlert = false;
			for _,v2 in pairs(v.decisions_list.getWindows()) do
				local bFeat = v2.decision.getValue():lower():match("feat");

				if bFeat then
					if v2.choice.getValue() == "" then
						bAlert = true;
						bTopAlert = true;

						table.insert(aAlerts, v2.decision.getValue());
					end
				else
					if v2.decision_choice.getValue() == "" then
						bAlert = true;
						bTopAlert = true;

						table.insert(aAlerts, v2.decision.getValue());
					end
				end

				v2.alert.setVisible(bAlert);
			end

			v.alert.setVisible(bAlert);
		end
	else
		return true, {"Select Race"};
	end

	return bTopAlert, aAlerts
end

function updateClassAlerts(w)
	local wClass = w.sub_class.subwindow;
	local aAlerts = {};
	local bTopAlert = false;

	if wClass then
		if wClass.class_list.isEmpty() then
			return true, {"Select Class"};
		end

		for _,vClass in pairs(wClass.class_list.getWindows()) do
			for _,v in pairs(vClass.class_decisions_list.getWindows()) do
				local bAlert = false;
				for _,v2 in pairs(v.decisions_list.getWindows()) do
					local bFeat = v2.decision.getValue():lower():match("feat");

					if bFeat then
						if v2.choice.getValue() == "" then
							bAlert = true;
							bTopAlert = true;

							table.insert(aAlerts, v.feature.getValue());
						end
					else
						if v2.decision_choice.getValue() == "" then
							bAlert = true;
							bTopAlert = true;

							table.insert(aAlerts, "Select " .. v.feature.getValue() .. " Choice");
						end

						v2.alert.setVisible(bAlert);
					end
				end

				v.alert.setVisible(bAlert);
			end
		end
	else
		return true, {"Select Class"};
	end

	return bTopAlert, aAlerts
end

function updateAbilitiesAlerts(w)
	local wAbility = w.sub_abilities.subwindow;

	if wAbility then
		local sGenMethod = wAbility.cb_genmethod.getValue();

		if sGenMethod == "" then
			return true, {"Select Ability Scores"};
		else
			if sGenMethod:lower() == "point buy" then
				local nPointsUsed = wAbility.points_used.getValue();
				local nPointsMax = wAbility.points_max.getValue();

				if nPointsUsed ~= nPointsMax then
					return true, {"Select Ability Scores - Not all points used"};
				else
					return false, {}
				end
			else
				local bBase = false;
				for _,v in pairs(DataCommon.abilities) do
					if wAbility[v .. "_base"].getValue() ~= 0 then
						bBase = true;
					end
				end

				if not bBase then
					return true, {"Select Ability Scores"};
				else
					return false, {}
				end
			end
		end
	end

	return true, {"Select Ability Scores"};
end

function updateBackgroundAlerts(w)
	local wBackground = w.sub_background.subwindow;
	local aAlerts = {};
	local bTopAlert = false;

	if wBackground then
		if not wBackground.background_decisions_list or wBackground.background_decisions_list.isEmpty() then
			return true, {"Select Background"};
		end

		for _,v in pairs(wBackground.background_decisions_list.getWindows()) do
			local bAlert = false;
			for _,v2 in pairs(v.decisions_list.getWindows()) do
				if v2.decision_choice.getValue() == "" then
					bAlert = true;
					bTopAlert = true;
				end

				v2.alert.setVisible(bAlert);
			end

			v.alert.setVisible(bAlert);
		end
	else
		return true, {"Select Background"};
	end

	return bTopAlert, aAlerts
end

function updateEquipmentAlerts(w)
	local wEquipment = w.sub_equipment.subwindow;
	local aAlerts = {};
	local bTopAlert = false;

	if wEquipment then
		if wEquipment.backgroundkit_header.isVisible() then
			local bBackgroundSelected = false;
			local bClassSelected = false;

			if wEquipment.sub_backgroundkit.subwindow then
				for _,v in pairs(wEquipment.sub_backgroundkit.subwindow.kit_list.getWindows()) do
					local bAlert = false;
					if not v.button_modify.isVisible() then
						bBackgroundSelected = true;
						bTopAlert = true;
						bAlert = true;
					end

					v.alert.setVisible(bAlert);
				end
			end
			if wEquipment.sub_classkit.subwindow then
				for _,v in pairs(wEquipment.sub_classkit.subwindow.kit_list.getWindows()) do
					local bAlert = false;
					if not v.button_modify.isVisible() then
						bBackgroundSelected = true;
						bTopAlert = true;
						bAlert = true;
					end

					v.alert.setVisible(bAlert);
				end
			end

			if bBackgroundSelected then
				table.insert(aAlerts, "Select Background Kit Choice");
			end
			if bClassSelected then
				table.insert(aAlerts, "Select Class Kit Choice");
			end
		end
	else
		return true, {"Select Equipment Choice"};
	end

	return bTopAlert, aAlerts
end

--
-- Import
--

function checkImport(nodeChar)
	local bCanImport = true;
	local tMissingClasses = {};
	local tMissingClassSpecializations = {};

	for _,vClass in pairs(DB.getChildren(nodeChar, "classes")) do
		local sLinkClass, sLinkRecord = DB.getValue(vClass, "shortcut", "", "");
		if sLinkRecord ~= "" then
			if not DB.findNode(sLinkRecord) then
				local sClassName = DB.getValue(vClass, "name", "");
				local sClassModule = StringManager.split(sLinkRecord, "@")[2] or "";
				table.insert(tMissingClasses, { sName = sClassName, sModule = sClassModule });
			end
		end
		local sSpecLinkClass, sSpecLinkRecord = DB.getValue(vClass, "specializationlink", "", "");
		if sSpecLinkRecord ~= "" then
			if not DB.findNode(sSpecLinkRecord) then
				local sSpecName = DB.getValue(vClass, "specialization", "");
				local sSpecModule = StringManager.split(sSpecLinkRecord, "@")[2] or "";
				table.insert(tMissingClassSpecializations, { sName = sSpecName, sModule = sSpecModule });
			end
		end
	end
	if #tMissingClasses > 0 then
		ChatManager.SystemMessage(Interface.getString("char_error_wizard_import_missingclass"));
		for _,v in ipairs(tMissingClasses) do
			ChatManager.SystemMessage(string.format("  '%s' - (%s)", v.sName, v.sModule));
		end
		bCanImport = false;
	end
	if #tMissingClassSpecializations > 0 then
		ChatManager.SystemMessage(Interface.getString("char_error_wizard_import_missingclassspecialization"));
		for _,v in ipairs(tMissingClassSpecializations) do
			ChatManager.SystemMessage(string.format("  '%s' - (%s)", v.sName, v.sModule));
		end
		bCanImport = false;
	end

	return bCanImport
end

function importCharacter(nodeChar)
	local bCanImport = true;
	local tMissingClasses = {};
	local tMissingClassSpecializations = {};

	local bCanImport = CharWizardManager.checkImport(nodeChar);
	if not bCanImport then
		return;
	end

	local wChar = Interface.findWindow("charsheet", nodeChar);
	if wChar then
		wChar.close();
	end
	local wCharClass = Interface.findWindow("charsheet_classes", nodeChar);
	if wCharClass then
		wCharClass.close();
	end

	local wndWizard = Interface.openWindow("charwizard_levelup", "");

	CharWizardManager.character_choices = {
		name = DB.getValue(nodeChar, "name", ""),
		identity = DB.getPath(nodeChar);
		race = {},
		class = {},
		abilityscore = {},
		background = {},
		import = {};
	};

	local tChar = CharWizardManager.character_choices;
	local _,sRaceRecord = DB.getValue(nodeChar, "racelink", "");
	local _,sSubRaceRecord = DB.getValue(nodeChar, "subracelink", "");
	tChar.race = {
		race = sRaceRecord,
		subrace = sSubRaceRecord,
		speed = DB.getValue(nodeChar, "speed.base", 0);
		speedspecial = DB.getValue(nodeChar, "speed.special", "");
		darkvision = DB.getValue(nodeChar, "senses", "");
		size = DB.getValue(nodeChar, "size", "");
	};

	local nStr, nDex, nCon, nInt, nWis, nCha;
	for k,vAbilityScore in pairs(DB.getChildren(nodeChar, "abilities", "")) do
		tChar.abilityscore[k] = {};
		tChar.abilityscore[k].base = DB.getValue(vAbilityScore, "score", 0);
	end

	local _,sBackgroundRecord = DB.getValue(nodeChar, "backgroundlink", "");
	tChar.background.background = sBackgroundRecord;

	tChar.import.skills = {};
	for _,vSkills in pairs(DB.getChildren(nodeChar, "skilllist")) do
		if DB.getValue(vSkills, "prof", 0) > 0 then
			local sSkillName = DB.getValue(vSkills, "name", "");
			local nExp = 0;

			if DB.getValue(vSkills, "prof", 0) == 2 then
				nExp = 1;
			end

			table.insert(tChar.import.skills, { type = "import", skill = sSkillName:lower(), expertise = nExp } );
		end
	end

	tChar.import.profs = {};
	for _,vProfs in pairs(DB.getChildren(nodeChar, "proficiencylist")) do
		local sProf = DB.getValue(vProfs, "name", "");
		table.insert(tChar.import.profs, { type = "import", proficiency = sProf:lower(), expertise = 0 } );
	end

	tChar.import.languages = {};
	for _,vLangs in pairs(DB.getChildren(nodeChar, "languagelist")) do
		local sLang = DB.getValue(vLangs, "name", "");
		table.insert(tChar.import.languages, { type = "import", language = sLang:lower() } );
	end

	for _,vClass in pairs(DB.getChildren(nodeChar, "classes")) do
		local sClassName = StringManager.trim(DB.getValue(vClass, "name", ""));
		local sClassRef, sClassRecord = DB.getValue(vClass, "shortcut", "");
		local nClassLevel = DB.getValue(vClass, "level", "");
		local sSpecClass, sSpecRecord = DB.getValue(vClass, "specializationlink", "", "");
		local sSpec = DB.getValue(DB.findNode(sSpecRecord), "name", "");

		tChar.class[sClassName] = {};
		tChar.class[sClassName].record = sClassRecord;
		tChar.class[sClassName].level = nClassLevel;
		tChar.class[sClassName].import = 1;
		--tChar.class[sClassName].specialization = sSpecRecord;
		tChar.class[sClassName].specialization = sSpec;

		CharWizardClassManager.addClass(sClassRecord, true);
	end
end

--
-- Commit
--

function onCommit(bLevelUp)
	CharWizardManager.onCommitButtonHelper(bLevelUp);
end

function onCommitButtonHelper(bLevelUp)
	local wTop = CharWizardManager.collectWizardWindow();
	 if bLevelUp then
		CharWizardManager.levelupCharacter();
	else
		if Session.IsHost then
			CharWizardManager.commitCharacter();
		else
			CharWizardManager.requestCommit();
		end
	end
end

function requestResponse(bResult, sIdentity)
	if bResult then
		CharWizardManager.commitCharacter(sIdentity);
	else
		ChatManager.SystemMessage("Error: Failed to create new PC identity.")
	end
	bRequested = false;
end

function requestCommit()
	if not bRequested then
		User.requestIdentity(nil, "charsheet", "name", nil, requestResponse);
		bRequested = true;
	end
end

function commitCharacter(identity)
	local wTop = CharWizardManager.collectWizardWindow();
	local tChar = CharWizardManager.character_choices;
	local tRace = CharWizardManager.character_choices["race"];

	-- Open the character sheet
	local nodeChar;
	if Session.IsHost then
		nodeChar = DB.createChild("charsheet");
	else
		nodeChar = DB.findNode("charsheet." .. identity);
	end
	Interface.openWindow("charsheet", nodeChar);

	-- Set warnings
	if #(CharWizardManager.getCommitWarnings()) > 0 then
		local tNotes = {};
		for _,v in ipairs(CharWizardManager.getCommitWarnings()) do
			table.insert(tNotes, v);
		end
		DB.setValue(nodeChar, "notes", "string", table.concat(tNotes, "\r"));
	end

	-- Set name
	DB.setValue(nodeChar, "name", "string", tChar.name or "");

	-- Set physical parameters
	if tRace.speed then
		DB.setValue(nodeChar, "speed.base", "number", tRace.speed:match("%d+"));
	end
	if tRace.speedspecial then
		DB.setValue(nodeChar, "speed.special", "string", tRace.speedspecial);
	end
	if tRace.darkvision then
		DB.setValue(nodeChar, "senses", "string", tRace.darkvision);
	end
	if tRace.size then
		DB.setValue(nodeChar, "size", "string", tRace.size);
	end

	-- Apply character options in the correct order
	CharWizardManager.addCommitRace(nodeChar);
	CharWizardManager.setCommitAbilityScores(nodeChar);
	CharWizardManager.addCommitBackground(nodeChar);
	CharWizardManager.addCommitFeats(nodeChar);
	CharWizardManager.addCommitClasses(nodeChar);
	CharWizardManager.addCommitProficiencies(nodeChar);
	CharWizardManager.addCommitSkills(nodeChar);
	CharWizardManager.addCommitLanguages(nodeChar);
	CharWizardManager.addCommitInnateSpells(nodeChar)
	CharWizardManager.addCommitSpells(nodeChar);
	CharWizardManager.addCommitInventory(nodeChar);
	CharWizardManager.addCommitCurrency(nodeChar);

	-- Close the wizard window
	wTop.close();
end

function levelupCharacter(identity)
	local identity = CharWizardManager.character_choices.identity;
	-- Open the character sheet
	local nodeChar = DB.findNode(identity);
	Interface.openWindow("charsheet", nodeChar);

	-- Apply character options in the correct order
	--if self.levelUpClass ~= "" then
		CharWizardManager.setCommitAbilityScores(nodeChar);
		CharWizardManager.addCommitFeats(nodeChar);
		CharWizardManager.addCommitLevelUpClass(nodeChar);
		CharWizardManager.addCommitProficiencies(nodeChar);
		CharWizardManager.addCommitSkills(nodeChar);
		CharWizardManager.addCommitLanguages(nodeChar);
	--end
	CharWizardManager.addCommitSpells(nodeChar);

	-- Close the wizard window
	CharWizardManager.collectWizardWindow().close();
end

function addCommitRace(nodeChar)
	local tRace = CharWizardManager.character_choices["race"];
	if tRace == {} then
		return;
	end

	if tRace.race then
		local sRaceRecord = tRace.race;
		local rAdd = CharManager.helperBuildAddStructure(nodeChar, "reference_race", sRaceRecord, true);
		if not rAdd then
			return;
		end

		CharRaceManager.helperAddRaceMain(rAdd);

		if tRace.subrace then
			local sSubRaceRecord = tRace.subrace;
			local nodeSubRace = DB.findNode(sSubRaceRecord);

			if nodeSubRace then
				rAdd.sSubracePath = DB.getPath(nodeSubRace);
				CharRaceManager.helperAddRaceSubrace(rAdd);
			end
		end
	end

	return;
end

function addCommitBackground(nodeChar)
	local tBackground = CharWizardManager.character_choices["background"];
	if tBackground == {} then
		return;
	end

	if tBackground.background then
		CharBackgroundManager.addBackground(nodeChar, "reference_background", tBackground.background, true);
	end

	return
end

function setCommitAbilityScores(nodeChar)
	local tASI = CharWizardManager.character_choices["abilityscore"];
	for _,v in ipairs(DataCommon.abilities) do
		if tASI[v] and tASI[v].total then
			local nScore = tASI[v].total;
			if DB.getValue(nodeChar, "abilities." .. v .. ".score", 0) ~= nScore then
				DB.setValue(nodeChar, "abilities." .. v .. ".score", "number", nScore);
				DB.setValue(nodeChar, "abilities." .. v .. ".bonus", "number", math.floor((nScore - 10) / 2));

				CharWizardManager.outputUserMessage("char_abilities_message_abilityset", StringManager.titleCase(v), nScore, DB.getValue(nodeChar, "name", ""));
			end
		end
	end
end

function setCommitLevelUpAbilityScores(nodeChar)
	local tASI = CharWizardManager.character_choices["abilityscore"];
	for _,vAbility in ipairs(DataCommon.abilities) do
		if tASI[vAbility] and tASI[vAbility].base then
			local nBase = tASI[vAbility].base;
			local nASI = 0;

			for k,v in pairs(CharWizardAbilityManager.collectASIAbilities()) do
				if k == vAbility then
					nASI = v;
				end
			end

			local nScore = nBase + nASI;
			if DB.getValue(nodeChar, "abilities." .. vAbility .. ".score", 0) ~= nScore then
				DB.setValue(nodeChar, "abilities." .. vAbility .. ".score", "number", nScore);

				CharWizardManager.outputUserMessage("char_abilities_message_abilityset", StringManager.titleCase(v), nScore, DB.getValue(nodeChar, "name", ""));
			end
		end
	end
end

function addCommitClasses(nodeChar)
	local tClass = CharWizardManager.character_choices["class"];

	local tMainClass = {
		sName = "",
		nLevel = 0,
		sRecord = "",
	};

	local tMultiClasses = {};
	for k,v in pairs(tClass) do
		if v.startingclass then
			if v.startingclass == 1 then
				tMainClass.sName = k;
				tMainClass.nLevel = v.level;
				tMainClass.sRecord = v.record;

				if v.specialization then
					tMainClass.sSpecChoice = v.specialization;
					tMainClass.nSpecLevel = CharClassManager.getClassSpecializationLevel(k);
				end
			else
				local tMultiClass = {
					sName = k,
					nLevel = v.level,
					sRecord = v.record,
				};
				if v.specialization then
					tMultiClass.nSpecLevel = CharClassManager.getClassSpecializationLevel(sClassName);
					tMultiClass.sSpecChoice = v.specialization;
				end

				table.insert(tMultiClasses, tMultiClass);
			end
		end
	end

	for i = 1, tMainClass.nLevel do
		local rAdd = CharManager.helperBuildAddStructure(nodeChar, "reference_class", tMainClass.sRecord, true);
		if rAdd then
			CharClassManager.helperAddClassMain(rAdd);
			if i == tMainClass.nSpecLevel then
				rAdd.sClassSpecChoice = tMainClass.sSpecChoice;
				CharClassManager.helperAddClassSpecialization(rAdd);
			end
		end
	end

	if #tMultiClasses > 0 then
		for _,tMultiClass in ipairs(tMultiClasses) do
			for i = 1, tMultiClass.nLevel do
				local rAdd = CharManager.helperBuildAddStructure(nodeChar, "reference_class", tMultiClass.sRecord, true);
				if rAdd then
					CharClassManager.helperAddClassMain(rAdd);
					if i == tMultiClass.nSpecLevel then
						rAdd.sClassSpecChoice = tMultiClass.sSpecChoice;
						CharClassManager.helperAddClassSpecialization(rAdd);
					end
				end
			end
		end
	end
end

function addCommitLevelUpClass(nodeChar)
	local tLvlClass = {
		sName = "",
		nLevel = 0,
		sRecord = "",
	};

	local sClassRecord = "";
	for k,v in pairs(CharWizardManager.character_choices.class) do
		if v.levelup == 1 then
			tLvlClass.sName = k;
			tLvlClass.nLevel = v.level;
			tLvlClass.sRecord = v.record;

			if v.specialization then
				tLvlClass.sSpecChoice = v.specialization;
				tLvlClass.nSpecLevel = CharClassManager.getClassSpecializationLevel(k);
			end

			break;
		end
	end

	local rAdd = CharManager.helperBuildAddStructure(nodeChar, "reference_class", tLvlClass.sRecord, true);
	if rAdd then
		CharClassManager.helperAddClassMain(rAdd);
		if tLvlClass.nLevel == tLvlClass.nSpecLevel then
			rAdd.sClassSpecChoice = tLvlClass.sSpecChoice;
			CharClassManager.helperAddClassSpecialization(rAdd);
		end
	end
end

function addCommitSkills(nodeChar)
	local tCollectedSkills = CharWizardManager.collectSkills();
	local tSkills = {};

	if CharWizardManager.character_choices.skills then
		local aSortedSkills = {};
		for _,v in ipairs(CharWizardManager.character_choices.skills) do
			aSortedSkills[v.skill] = true;
		end

		for _,v in ipairs(tCollectedSkills) do
			if not aSortedSkills[v] then
				table.insert(tSkills, v);
			end
		end
	else
		tSkills = tCollectedSkills;
	end

	-- Get the list we are going to add to
	local nodeList = nodeChar.createChild("skilllist");
	if not nodeList then
		return;
	end

	for _,v in pairs(tSkills) do
		-- Add Skills
		local sSkill = StringManager.trim(StringManager.titleCase(v));
		local sSkillLower = sSkill:lower();

		local nodeSkill;
		for _,vSkill in pairs(DB.getChildren(nodeChar, "skilllist")) do
			local sMatch = StringManager.trim(DB.getValue(vSkill, "name", "")):lower();
			if sMatch == sSkillLower then
				nodeSkill = vSkill;
			end
		end

		if not nodeSkill then
			nodeSkill = nodeList.createChild();
		end

		if nodeSkill then
			local nProficient = 1;
			local nExpProf = CharWizardManager.collectExpertiseProf(sSkillLower);

			if nExpProf == 1 then
				nProficient = 2;
			end

			if sSkillLower == "sleight of hand" then
				sSkill = "Sleight of Hand";
			end

			if sSkill ~= StringManager.trim(DB.getValue(nodeSkill, "name", "")) and
				nProficient ~= DB.getValue(nodeSkill, "prof", 0) then

				DB.setValue(nodeSkill, "name", "string", sSkill);

				if DataCommon.skilldata[sSkill] then
					DB.setValue(nodeSkill, "stat", "string", DataCommon.skilldata[sSkill].stat);
				end

				DB.setValue(nodeSkill, "prof", "number", nProficient);

				-- Announce
				if nProficient == 2 then
					CharWizardManager.outputUserMessage("char_abilities_message_expertiseadd", DB.getValue(nodeSkill, "name", ""), DB.getValue(nodeChar, "name", ""));
				else
					CharWizardManager.outputUserMessage("char_abilities_message_skilladd", DB.getValue(nodeSkill, "name", ""), DB.getValue(nodeChar, "name", ""));
				end
			end
		end
	end
end

function addCommitProficiencies(nodeChar)
	local tCollectedProf = CharWizardManager.collectProficiencies(true);
	local tProf = {};

	if next(CharWizardManager.character_choices.import) then
		local aSortedProfs = {};
		if CharWizardManager.character_choices.import.profs then
			for _,v in ipairs(CharWizardManager.character_choices.import.profs) do
				aSortedProfs[v.proficiency] = true;
			end

			for _,v in pairs(tCollectedProf) do
				if not aSortedProfs[v.proficiency] then
					table.insert(tProf, v);
				end
			end
		end
	else
		tProf = tCollectedProf;
	end

    -- Get the list we are going to add to
	local nodeList = nodeChar.createChild("proficiencylist");
	if not nodeList then
		return;
	end

	for _,v in pairs(tProf) do
		-- Add Proficiencies
		local sProfName = v.proficiency;
		local vNew = nodeList.createChild();
		DB.setValue(vNew, "name", "string", StringManager.titleCase(sProfName));

		-- Announce
		CharWizardManager.outputUserMessage("char_abilities_message_profadd",
		sProfName, DB.getValue(nodeChar, "name", ""));
	end
end

function addCommitLanguages(nodeChar)
	local tCollectedLang = CharWizardManager.collectLanguages(true);
	local tLang = {};

	if next(CharWizardManager.character_choices.import) then
		if CharWizardManager.character_choices.import.languages then
			local aSortedLangs = {};
			for _,v in ipairs(CharWizardManager.character_choices.import.languages) do
				aSortedLangs[v.language] = true;
			end
			for _,v in ipairs(tCollectedLang) do
				if not aSortedLangs[v] then
					table.insert(tLang, v);
				end
			end
		end
	else
		tLang = tCollectedLang;
	end

	for _,v in pairs(tLang) do
		CharManager.addLanguage(nodeChar, StringManager.titleCase(v));
	end
end

function addCommitInnateSpells(nodeChar)
	local tRace = CharWizardManager.character_choices["race"];
	local tClass = CharWizardManager.character_choices["class"];
	local tBackground = CharWizardManager.character_choices["background"];
	local sCharName = DB.getValue(nodeChar, "name", "");

	if tRace.spell then
		for _,v in pairs(tRace.spell) do
			local sRace = DB.getValue(DB.findNode(tRace.race), "name", "");
			local sSpell = v.spell;
			local sSpellName = StringManager.titleCase(sSpell);
			local nodeSpell = RecordManager.findRecordByStringI("spell", "name", sSpell);
			local sSpellGroup = StringManager.titleCase(sRace .. " Innate Spells");
			local nodePowerGroups = DB.createChild(nodeChar, "powergroup");

			nodeNewGroup = nodePowerGroups.createChild();
			DB.setValue(nodeNewGroup, "castertype", "string", "memorization");
			-- Could only find High Elf with a Cantrip choice assume intelligence
			DB.setValue(nodeNewGroup, "stat", "string", "intelligence");
			DB.setValue(nodeNewGroup, "name", "string", sSpellGroup);

			PowerManager.addPower("reference_spell", nodeSpell, nodeChar, sSpellGroup);

			CharWizardManager.outputUserMessage("char_abilities_message_spelladd",
			sSpellName, sCharName);
		end
	end

	if tClass.spell then
		-- future use for feature adds
	end

	if tBackground.spell then
		-- future use for feature adds
	end
end

function addLevelUpClass(nodeChar)
	local rAdd = CharWizardManager.helperBuildAddStructure(nodeChar,
	"reference_class", self.levelUpClass, true);

	if not rAdd then
		return;
	end

	CharClassManager.helperAddClassMain(rAdd);

	local nClassLevel = CharClassManager.getCharClassLevel(nodeChar, rAdd.sSourceName);
	local nClassSpecLevel = CharClassManager.getClassSpecializationLevel(rAdd.sSourceName);
	if nClassLevel == nClassSpecLevel then
		rAdd.sClassSpecChoice = self.getClassSpecializationChoice(rAdd.sSourceName);
		CharClassManager.helperAddClassSpecialization(rAdd);
	end
end

function addCommitSpells(nodeChar)
	local tClass = CharWizardManager.character_choices["class"];

	local aGroups = {};
	for _,v in pairs(DB.getChildren(nodeChar, "powergroup")) do
		aGroups[DB.getValue(v, "name", ""):lower()] = "";
	end

	for k,vClass in pairs(tClass) do
		if vClass.spell then
			for _,vSelectedSpell in pairs(vClass.spell) do
				local sSpellName = DB.getValue(DB.findNode(vSelectedSpell), "name", "");
				local sRecord = vSelectedSpell;

				if not aGroups["spells (" .. k:lower() .. ")"] then
					PowerManager.addPower("reference_spell", sRecord, nodeChar, "Spells");
				else
					PowerManager.addPower("reference_spell", sRecord, nodeChar,
					"Spells (" .. StringManager.titleCase(k) .. ")");
				end
			end
		end
	end
end

function addCommitFeats(nodeChar)
	local tFeats = CharWizardManager.collectFeats();
	for _,v in ipairs(tFeats) do
		local nodeFeat = RecordManager.findRecordByStringI("feat", "name", v:lower());
		CharFeatManager.addFeat(nodeChar, "reference_feat", DB.getPath(nodeFeat), true);
	end
end

function addCommitInventory(nodeChar)
	local tEquipment = CharWizardManager.character_choices["equipment"];

	if tEquipment.classitems and next(tEquipment.classitems) then
		for _,v in pairs(tEquipment.classitems) do
			ItemManager.handleItem("charsheet." .. nodeChar.getName(), "inventorylist", "item", DB.getPath(v.item), true);
		end
	end

	if tEquipment.backgrounditems and next(tEquipment.backgrounditems) then
		for _,v in pairs(tEquipment.backgrounditems) do
			ItemManager.handleItem("charsheet." .. nodeChar.getName(), "inventorylist", "item", DB.getPath(v.item), true);
		end
	end

	if tEquipment.additems and next(tEquipment.additems) then
		for _,v in pairs(tEquipment.additems) do
			ItemManager.handleItem("charsheet." .. nodeChar.getName(), "inventorylist", "item", DB.getPath(v.item), true);
		end
	end

	CharArmorManager.calcItemArmorClass(nodeChar);
end

function addCommitCurrency(nodeChar)
	local tEquipment = CharWizardManager.character_choices["equipment"];

	if tEquipment.currency then
		for _,v in ipairs(tEquipment.currency) do
			CurrencyManager.addCharCurrency(nodeChar, v.name, v.count);
		end
	end
end
