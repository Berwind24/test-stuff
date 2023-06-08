--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function processRace(w)
	local tRace = CharWizardManager.character_choices["race"];
	local wTop = UtilityManager.getTopWindow(w);
	local sTitle = "";
	local sRace = "";
	local sSubRace = "";

	local sClass,sRecord = w.shortcut.getValue();
	if sClass == "reference_subrace" then
		sSubRace = DB.getValue(DB.findNode(sRecord), "name", "");
		tRace.subrace = sRecord;

		_,sRecord = w.windowlist.window.shortcut.getValue();
	end

	sRace = DB.getValue(DB.findNode(sRecord), "name", "");
	sTitle = sRace;

	if sSubRace ~= "" then
		sTitle = sTitle .. " (" .. sSubRace .. ")";
	end

	tRace.race = sRecord;
	wTop.sub_race.subwindow.sub_raceselection.setVisible(false);
	wTop.sub_race.subwindow.race_select_header.setValue(sTitle:upper());

	CharWizardRaceManager.updateRaceTraits(wTop.sub_race.subwindow.race_decisions_list);
end

--
-- Traits
--

function collectRaceTraits()
	local tRace = CharWizardManager.character_choices["race"];
	local sRaceRecord = tRace.race;
	local sSubRaceRecord = tRace.subrace;
	local sDarkvision = tRace.darkvision;
	local aRaceTraits = {};

	if sSubRaceRecord then
		for _,v in pairs(DB.getChildren(DB.findNode(sSubRaceRecord), "traits")) do
			local sTrait = DB.getValue(v, "name", "");

			aRaceTraits[sTrait] = {};
			aRaceTraits[sTrait].subracetrait = v.getPath();
		end
	end

	for _,v in pairs(DB.getChildren(DB.findNode(sRaceRecord), "traits")) do
		local sTrait = DB.getValue(v, "name", "");

		if sTrait:lower() ~= "subrace" then
			if aRaceTraits[sTrait] then
				aRaceTraits[sTrait].racetrait = v.getPath();
			else
				aRaceTraits[sTrait] = {};
				aRaceTraits[sTrait].racetrait = v.getPath();
			end
		end
	end

	return aRaceTraits;
end

function encodeTraitText(vTrait)
	local sText = "";

	if vTrait.racetrait then
		sText = DB.getValue(DB.findNode(vTrait.racetrait), "text", "");
	end

	if vTrait.subracetrait then
		local sSubRace = DB.getValue(DB.getChild(DB.findNode(vTrait.subracetrait), ("...")), "name", "");
		sText = sText .. "<p><b>" .. sSubRace .. "</b></p>" .. DB.getValue(DB.findNode(vTrait.subracetrait), "text", "");
	end

	return sText;
end

function updateRaceTraits(w)
	local tRace = CharWizardManager.character_choices["race"];
	local aRaceTraits = CharWizardRaceManager.collectRaceTraits(w);
	local bAbilityScore = false;

	for kTrait,vTrait in pairs(aRaceTraits) do
		local sText = CharWizardRaceManager.encodeTraitText(vTrait);
		local sTraitType = StringManager.simplify(kTrait);

		local w2 = w.createWindow();
		w2.trait.setValue(kTrait);
		w2.trait.setVisible(true);
		w2.button_expand.setVisible(true);
		w2.shortcut.setValue("reference_racialtrait", vTrait.racetrait);
		w2.trait_desc.setValue(sText);

		if sTraitType:match("abilityscoreincrease") then
			CharWizardRaceManager.handleAbilityScoreInc(w2, sText);
			bAbilityScore = true;
		end
		if sTraitType:match("size") then
			CharWizardRaceManager.handleRaceSize(w2, sText);
		end
		if sTraitType:match("speed") then
			CharWizardRaceManager.handleRaceSpeed(w2, sText, false);
		end
		if CharWizardData.aRaceSpecialSpeed[sTraitType] then
			CharWizardRaceManager.handleRaceSpeed(w2, sText, true);
		end
		if CharWizardData.aRaceLanguages[sTraitType] then
			CharWizardRaceManager.handleRaceLanguages(w2, sText);
		end
		if CharWizardData.aRaceProficiency[sTraitType] then
			CharWizardRaceManager.handleRaceProficiencies(w2, sText);
		end
		if CharWizardData.aRaceSkill[sTraitType] then
			CharWizardRaceManager.handleRaceSkills(w2, sText);
		end
		if CharWizardData.aRaceSpells[sTraitType] then
			CharWizardRaceManager.handleRaceSpells(w2, sText, vTrait);
		end
		if sTraitType == "variabletrait" then
			local w3 = w2.decisions_list.createWindow();
			w3.decision.setValue("Select Variable Trait");
			w3.decision.setVisible(true);
			w3.decision_choice.setComboBoxVisible(true);
			w3.decision_choice.addItems({"Darkvision", "Skill"});
		end
		if sTraitType == "darkvision" then
			local sDarkVision = sText:match("(%d+)");

			if sDarkVision then
				local nDist = tonumber(sDarkVision) or 60;

				tRace.darkvision = "Darkvision " .. nDist;
			end
		end
		if sTraitType == "superiordarkvision" then
			local sDarkVision = sText:match("(%d+)");

			if sDarkVision then
				local nDist = tonumber(sDarkVision) or 120;

				tRace.darkvision = "Superior Darkvision " .. nDist;
			end
		end
		if sTraitType == "feat" then
			CharWizardRaceManager.handleRaceFeat(w2, sText);
		end
	end

	if not bAbilityScore then
		local w2 = w.createWindow();
		w2.trait.setValue("Ability Score Increase");
		w2.trait.setVisible(true);
		w2.button_expand.setVisible(true);
		w2.shortcut.setValue();
		w2.trait_desc.setValue();

		local w3 = w2.decisions_list.createWindow();
		w3.decision.setValue("Select Option");
		w3.decision.setVisible(true);
		w3.decision_choice.setComboBoxVisible(true);
		w3.decision_choice.addItems({"Option 1: One +2, One +1", "Option 2: Three +1's"});
	end

	CharWizardManager.updateAlerts();
end

function handleAbilityScoreInc(w, s)
	local tRace = CharWizardManager.character_choices["race"];
	local aRaceIncreases, bTasha = CharWizardRaceManager.parseRaceAbilityScoreInc(s:lower());
	local tFinalChoices = {};
	local tFinalDefaults = {};
	local bInnateIncrease = false;

	if not tRace.abilityincrease then
		tRace.abilityincrease = {};
	end

	if bTasha then
		local w2 = w.decisions_list.createWindow();
		w2.decision.setValue("Select Option");
		w2.decision.setVisible(true);
		w2.decision_choice.setComboBoxVisible(true);
		w2.decision_choice.addItems({"Option 1: One +2, One +1", "Option 2: Three +1's"});
	else
		for k,v in pairs(aRaceIncreases) do
			if not tFinalChoices[v.increase] then
				tFinalChoices[v.increase] = 1;
			else
				tFinalChoices[v.increase] = tFinalChoices[v.increase] + 1;
			end

			if v.stat ~= "any" then
				tFinalDefaults[v.stat] = v.increase;
			end
			bInnateIncrease = true;
		end

		for k,v in pairs(tFinalDefaults) do

			tFinalChoices[v] = tonumber(tFinalChoices[v]) - 1;
			table.insert(tRace.abilityincrease, { ability = k, mod = v })

			local w2 = w.decisions_list.createWindow();
			w2.decision.setValue("Increase Ability Score " .. (tonumber(v) < 0 and "" or "+") .. v);
			w2.decision.setVisible(true);
			w2.decision_choice.setComboBoxVisible(true);
			w2.decision_choice.setValue(StringManager.capitalize(k));

			for _,v2 in pairs(DataCommon.abilities) do
				if not tFinalDefaults[v2] then
					w2.decision_choice.add(StringManager.capitalize(v2));
					w.alert.setVisible(true);
				end
			end
		end

		for k,v in pairs(tFinalChoices) do
			if v ~= 0 then
				for i = 1, v do
					local w2 = w.decisions_list.createWindow();
					w2.decision.setValue("Increase " .. (tonumber(v) < 0 and "" or "+") .. k);
					w2.decision.setVisible(true);
					w2.decision_choice.setComboBoxVisible(true);

					for _,v in pairs(DataCommon.abilities) do
						if not tFinalDefaults[v] then
							w2.decision_choice.add(StringManager.capitalize(v));
							w.alert.setVisible(true);
						end
					end
				end
			end
		end
	end

	w.trait_desc.setValue(s);
end

function handleRaceSize(w, s)
	local tRace = CharWizardManager.character_choices["race"];
	local sCharWizardRaceSize = tRace.size;
	local aChoices,sSize = CharWizardRaceManager.parseRaceSize(s:lower());

	if next(aChoices) then
		local w2 = w.decisions_list.createWindow();
		w2.decision.setValue("Select Size");
		w2.decision.setVisible(true);
		w2.decision_choice.setComboBoxVisible(true);

		for _,v in pairs(aChoices) do
			w2.decision_choice.add(StringManager.capitalize(v));
		end
		w2.alert.setVisible(true);
	else
		if not sSize then
			tRace.size = "Medium";
		else
			tRace.size = sSize;
		end
	end
end

function handleRaceSpeed(w, s, bSpecialTrait)
	local tRace = CharWizardManager.character_choices["race"];
	local nSpeed, tSpecial = CharRaceManager.parseRaceSpeed(s:lower());
	local sTitle = "";

	if bSpecialTrait then
		if #tSpecial > 0 then
			local sExistingSpecial = tRace.speedspecial or "";

			if sExistingSpecial then
				if sExistingSpecial ~= "" then
					table.insert(tSpecial, 1, sExistingSpecial);
				end
			end
		end
	end

	tRace.speed = nSpeed .. "ft.";
	tRace.speedspecial = table.concat(tSpecial, ",");
end

local bLangUpdate = false;
function handleRaceLanguages(w, s)
	if bLangUpdate then
		return false
	end

	bLangUpdate = true;

	local tRace = CharWizardManager.character_choices["race"];
	local aLanguages, aChoiceLanguages, nChoices, bChoice = CharWizardRaceManager.parseRaceLanguages(s:lower());

	if not tRace.language then
		tRace.language = {};
	end

	for _,v in ipairs(aLanguages) do
		local tSelected = CharWizardManager.getAvailableLanguages();
        local w2 = w.decisions_list.createWindow();
        local sTitle = "Select ";
        sTitle = sTitle .. "Language";

        w2.decision.setValue(sTitle);
        w2.decision.setVisible(true);
        w2.decision_choice.setComboBoxVisible(true);

		if not StringManager.contains(tRace.language, v) then
			if StringManager.contains(tSelected, v) then
				table.insert(tRace.language, { language = v, type = w.trait.getValue() });
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
			local tSelected = CharWizardManager.getAvailableLanguages();
			local w2 = w.decisions_list.createWindow();
			w2.decision.setValue("Select Language");
			w2.decision.setVisible(true);
			w2.decision_choice.setComboBoxVisible(true);

			if not next(aChoiceLanguages) then
				aChoiceLanguages = tSelected;
			end
			for _,v in ipairs(aChoiceLanguages) do
				w2.decision_choice.add(StringManager.capitalize(v));
				w.alert.setVisible(true);
			end
		end
	end

	bLangUpdate = false;
end

function handleRaceProficiencies(w, s)
	local tRace = CharWizardManager.character_choices["race"];
	local sText = s:lower();
	local aProficiencies,bChoice,aChoiceProficiencies,nChoices = CharWizardRaceManager.parseRaceProficiencies(sText);

	for _,v in pairs(aProficiencies) do
		if not tRace.proficiency then
			tRace.proficiency = {};
		end

		local tCurProfs = CharWizardManager.collectProficiencies();

		if not StringManager.contains(tCurProfs, v) then
			local aFinalProfs = {};
			if v:match("all armor") then
				if not tCurProfs[v] then
					table.insert(aFinalProfs, v);
				end
			elseif v:match("simple weapons") then
				if not tCurProfs[v] then
					table.insert(aFinalProfs, v);
				end
			elseif v:match("martial weapons") then
				if not tCurProfs[v] then
					table.insert(aFinalProfs, v);
				end
			else
				if not tCurProfs[v] then
					table.insert(aFinalProfs, v);
				end
			end

			for _,v2 in pairs(aFinalProfs) do
				if not StringManager.contains(tCurProfs, v2) then
					table.insert(tRace.proficiency, { proficiency = v, type = "innate", expertise = 0 } )
				end
			end
		end
	end

	if bChoice then
		for i = 1, nChoices do
			local w2 = w.decisions_list.createWindow();
			w2.decision.setValue("Select Proficiency");
			w2.decision.setVisible(true);
			w2.decision_choice.setComboBoxVisible(true);

			for _,v in pairs(aChoiceProficiencies) do
				if not StringManager.contains(tCurProfs, v) then
					w2.decision_choice.add(StringManager.capitalize(v));
					w.alert.setVisible(true);
				end
			end
		end
	end
end

function handleRaceSkills(w, s)
	local tRace = CharWizardManager.character_choices["race"];
	local sText = s:lower();
	local bChoice, aRaceSkills, aChoices, nChoices, aChoiceProficiencies = CharWizardRaceManager.parseRaceSkills(sText);

	if not tRace.skill then
		tRace.skill = {};
	end

	for _,v in pairs(aRaceSkills) do
		local tSelected = CharWizardManager.getAvailableSkills();
        local w2 = w.decisions_list.createWindow();
        local sTitle = "Select ";
        sTitle = sTitle .. "Skill";

        w2.decision.setValue(sTitle);
        w2.decision.setVisible(true);
        w2.decision_choice.setComboBoxVisible(true);

        if not StringManager.contains(tRace.skill, v) then
            if StringManager.contains(tSelected, v) then
                table.insert(tRace.skill, { skill = v, type = w.trait.getValue() });
                w2.decision_choice.setValue(StringManager.capitalize(v));
            end
        end

        for _,vSkill in ipairs(tSelected) do
            if not StringManager.contains(aRaceSkills, vSkill) then
                local sSkill = StringManager.capitalize(vSkill);
                w2.decision_choice.add(sSkill);
            end
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

	if next(aChoiceProficiencies) then
		local w2 = w.decisions_list.createWindow();
		w2.decision.setValue("Select Proficiency");
		w2.decision.setVisible(true);
		w2.decision_choice.setComboBoxVisible(true);

		for _,v in pairs(aChoiceProficiencies) do
			w2.decision_choice.add(StringManager.capitalize(v));
			w.alert.setVisible(true);
		end
	end
end

function handleRaceSpells(w, s, aSources)
	local tRace = CharWizardManager.character_choices["race"];
	local aSpells, aChoiceSpells, nChoices, bChoice = CharWizardRaceManager.parseRaceSpells(w, s, aSources);

	if not tRace.spell then
		tRace.spell = {};
	end

	if aSpells and #aSpells > 0 then
		for _,v in pairs(aSpells) do
			local nodeSpell = RecordManager.findRecordByStringI("spell", "name", v);
			table.insert(tRace.spell, DB.getPath(nodeSpell));
		end
	end

	if next(aChoiceSpells) then
		local w2 = w.decisions_list.createWindow();
		w2.decision.setValue("Select Spell");
		w2.decision.setVisible(true);
		w2.decision_choice.setComboBoxVisible(true);

		for _,v in pairs(aChoiceSpells) do
			w2.decision_choice.add(StringManager.capitalize(v));
			w.alert.setVisible(true);
		end
	end
end

function handleRaceFeat(w, s)
	local tRace = CharWizardManager.character_choices["race"];
	local bChoice, aFeats, aChoiceFeats, nChoices = CharWizardRaceManager.parseRaceFeats(s:lower());

	if aFeats then
		for _,v in pairs(aFeats) do
			if not tRace.feat then
				tRace.feat = {};
			end
			table.insert(tRace.feat, {feat = v, type = "innate"});
		end
	end

	if bChoice then
		local w2 = w.decisions_list.createWindow();
		w2.decision.setValue("Select Feat");
		w2.decision.setVisible(true);
		w2.sub_decision_choice.setVisible(true);
		w.alert.setVisible(true);
	end
end

--
-- Parsing
--

function parseRaceAbilityScoreInc(s)
	local aIncreases = {};
	local aAdjust = StringManager.split(s, ",.\r\n");
	local bChoice = false;
	local nChoice = 1;
	local nChoiceInc = 1;

	for _,v in pairs(aAdjust) do
		if v:match("alternatively") then
			return aIncreases, true;
		end
		if v:match("choice") and not v:match("choose a subrace") then
			bChoice = true;
		end
		if bChoice then
			if v:match("two") then
				nChoice = 2;
			end
			if v:match("increase[s]? by (%d+)") then
				nChoiceInc = v:match("increase[s]? by (%d+)");
			end
		end

		if v:match("your ability scores each increase") then
			for k,i in pairs(DataCommon.abilities) do
				table.insert(aIncreases, {stat = i, increase = 1})
			end
		elseif v:match("ability score[s]? of your choice") then
			for i = 1, nChoice do
				table.insert(aIncreases, {stat = "any", increase = tonumber(nChoiceInc)})
			end
		else
			local a1, a2, sIncrease = v:match("your (%w+) and (%w+) scores increase by (%d+)");

			if not a1 then
				a1, a2, sIncrease = v:match("your (%w+) and (%w+) scores both increase by (%d+)");
			end

			if not a1 then
				a1, a2, a3, sIncrease = v:match("your (%w+) score, (%w+) score, and (%w+) score each increase by (%d+)");
			end

			if a3 then
				local nIncrease = tonumber(sIncrease) or 0;

				table.insert(aIncreases, {stat = a1, increase = nIncrease})
				table.insert(aIncreases, {stat = a2, increase = nIncrease})
				table.insert(aIncreases, {stat = a3, increase = nIncrease})
			elseif a2 then
				local nIncrease = tonumber(sIncrease) or 0;

				table.insert(aIncreases, {stat = a1, increase = nIncrease})
				table.insert(aIncreases, {stat = a2, increase = nIncrease})
			elseif a1 then
				local nIncrease = tonumber(sIncrease) or 0;

				table.insert(aIncreases, {stat = a1, increase = nIncrease})
			else
				for a1, sIncrease in v:gmatch("your (%w+) score increases by (%d+)") do
					local nIncrease = tonumber(sIncrease) or 0;

					table.insert(aIncreases, {stat = a1, increase = nIncrease})
				end

				for a1, sDecrease in v:gmatch("your (%w+) score is reduced by (%d+)") do
					local nDecrease = tonumber(sDecrease) or 0;

					table.insert(aIncreases, {stat = a1, increase = nDecrease * -1})
				end
			end
		end
	end

	return aIncreases;
end

function parseRaceSize(s)
	local sSizeText = s:lower();
	local aChoices = {};
	local sSize = nil;

	if sSizeText:match("choice") then
		table.insert(aChoices, "small");
		table.insert(aChoices, "medium");
	else
		sSize = sSizeText:match("your size is (%w+)");

		if not sSize then
			sSize = sSizeText:match("you are (%w+)");
		end

		if not sSize then
			sSize = "Medium";
		end
	end

	return aChoices,sSize
end

function parseRaceLanguages(s)
	local aLanguages = {};
	local aChoiceLanguages = {};
	local nChoices = 1;
	local bChoice = false;
	local bChoiceLanguages = false;

	local sLanguages = s:match("you can speak, read, and write ([^.]+)");
	local aChoiceLanguages = {};
	local aSortLanguages = {};

	local aAvailableLanguages = CharWizardManager.getAvailableLanguages();

	for k,v in pairs(aAvailableLanguages) do
		aSortLanguages[v:lower()] = "";
	end

	if not sLanguages then
		sLanguages = s:match("you can read and write ([^.]+)");
	end
	if not sLanguages then
		sLanguages = s:match("you speak, read, and write ([^.]+)");
	end
	if not sLanguages then
		sLanguages = s:match("your character can speak, read, and write ([^.]+)");
	end
	if not sLanguages then
		sLanguages = s:match("(, and fluency in one language of your choice.)")
	end

	if not sLanguages then
		return
	end

	if sLanguages:match("and your choice of (%w+) or (%w+)") then
		local sLanguage1, sLanguage2 = s:match("and your choice of (%w+) or (%w+)");
		aChoiceLanguages[sLanguage1] = { tooltip = "Select Language" };
		aChoiceLanguages[sLanguage2] = { tooltip = "Select Language" };

		sLanguages = sLanguages:gsub("and your choice of (%w+) or (%w+)", "")
		bChoice = true;
	end

	if sLanguages:match(" two ") then
		nChoices = 2;
		sLanguages = sLanguages:gsub("two other languages of your choice", "");
	end

	for k,v in pairs(CharWizardData.aParseRaceLangChoices) do
		if sLanguages:match(k) then
			bChoice = true;
		end

		sLanguages = sLanguages:gsub(k, "");
	end

	sLanguages = sLanguages:gsub(", but you can speak only by using your mimicry trait", "");
	sLanguages = sLanguages:gsub(" and ", ",");
	sLanguages = sLanguages:gsub(" ", "");
	sLanguages = sLanguages:gsub(", but you.*$", "");

	local aSplitLanguages = StringManager.split(sLanguages, ",");
	for _,v in pairs(aSplitLanguages) do
		--if aSortLanguages[v:lower()] then
			table.insert(aLanguages, v:lower());
		--end
	end

	local aFinalChoiceLanguages = {};
	for _,v in pairs(aChoiceLanguages) do
		if aSortLanguages[v:lower()] and not StringManager.contains(aSplitLanguages, v:lower()) then
			table.insert(aFinalChoiceLanguages, v:lower())
		end
	end

	return aLanguages, aFinalChoiceLanguages, nChoices, bChoice
end

function parseRaceProficiencies(sText)
	local aProficiencies = {};
	local aChoiceProficiencies = {};
	local nChoices = 1;
	local bChoice = false;
	local bChoiceProficiency = false;
	local tCurTools = CharWizardManager.collectProficiencies();

	local sProficiency = sText:match("you have proficiency with ([^.]+)")

	if not sProficiency then
		sProficiency = sText:match("you gain proficiency with ([^.]+)")
	end

	if not sProficiency then
		sProficiency = sText:match("you gain two tool proficiencies of your choice")
		nChoices = 2;
	end

	if not sProficiency then
		sProficiency = sText:match("you are proficient with ([^.]+)")
	end

	if not sProficiency then
		sProficiency = sText:match("one tool proficiency of your choice")
	end

	if not sProficiency then
		sProficiency = sText:match("artisan's tools %((.*)%)");
	end

	if not sProficiency then
		sProficiency = sText:match("you have proficiency with ([^.]+)")
	end

	if not sProficiency and not bChoice then
		return aProficiencies, bChoice, aChoiceProficiencies, nChoices
	end

	sProficiency = sProficiency:gsub(" and ", ",")
	sProficiency = sProficiency:gsub(" or ", ",")
	sProficiency = sProficiency:gsub("the ", "")

	if sProficiency:match("choice") then
		if sProficiency:match("choice: (.*)") then
			sProficiency = sProficiency:match("choice: (.*)")
		end

		bChoice = true;
	elseif sProficiency:match("type") then
		bChoice = true;
	end

	if bChoice then
		for _,vProf in pairs(StringManager.split(sProficiency, ",")) do
			if vProf:match("of your choice") then
				for _,vAllTool in pairs(CharWizardManager.getToolType()) do
					local sTool = StringManager.trim(vAllTool);
					if not tCurTools[sTool] then
						table.insert(aChoiceProficiencies, sTool);
					end
				end
			elseif vProf:lower():match("one type of") then
				for _,vAllTool in pairs(CharWizardManager.getToolType("artisan's tools")) do
					local sTool = StringManager.trim(vAllTool);
					if not tCurTools[sTool] then
						table.insert(aChoiceProficiencies, sTool);
					end
				end
			else
				local sTool = StringManager.trim(vProf);
				if not tCurTools[sTool] then
					table.insert(aChoiceProficiencies, sTool);
				end
			end
		end

		return aProficiencies, bChoice, aChoiceProficiencies, nChoices;
	else
		for _,v in pairs(StringManager.split(sProficiency, ",")) do
			if v == "light" then
				v = "light armor";
			end

			local sTool = StringManager.trim(v);
			if not tCurTools[sTool] then
				table.insert(aProficiencies, sTool);
			end
		end

		return aProficiencies, bChoice, aChoiceProficiencies, nChoices
	end
end

function parseRaceSkills(sText)
	local aRaceSkills = {};
	local aRaceChoiceSkills = {};
	local aChoiceProficiencies = {};
	local nChoices = 1;
	local bChoice = false;
	local aAvailableSkills = CharWizardManager.getAvailableSkills();
	local aSortAvailableSkills = {};
	local sSkillText = sText:match("two skills of your choice");
	local sToolType = nil;

	local tAvailableSkills = {};
	for kSkill,_ in pairs(DataCommon.skilldata) do
		local sSkillName = StringManager.trim(kSkill):lower();
		if not StringManager.contains(tSkills, sSkillName) then
			tAvailableSkills[sSkillName] = { tooltip = "Select skill" };
		end
	end

	for k,v in pairs(aAvailableSkills) do
		aSortAvailableSkills[v] = "";
	end

	if not sSkillText then
		sSkillText = sText:match("following skills of your choice: [^.]+");
	end

	if not sSkillText then
		sSkillText = sText:match("choose one of the following skills: [^.]+")
	end

	if not sSkillText then
		sSkillText, sToolType = sText:match("you have proficiency in the (.-) skills, and you have proficiency with one (.-) of your choice");
	end

	if not sSkillText then
		sSkillText = sText:match("proficiency in ([^.]+)");
	end

	if not sSkillText then
		sSkillText = sText:match("proficient in the (.-) skill");
	end

	if not sSkillText then
		sSkillText = sText:match("proficiency with ([^.]+)");
	end

	if not sSkillText then
		sSkillText = sText:match("proficiency of ([^.]+)");
	end

	if not sSkillText then
		sSkillText = sText:match("trained in ([^.]+)");
	end

	if not sSkillText then
		sSkillText = sText:match("you are proficient in your choice of two of the following skills: [^.]+");
		nChoices = 2;
	end

	if not sSkillText then
		return bChoice, aRaceSkills, nil, nChoices, aChoiceProficiencies;
	end

	if sSkillText:match("choice") or sSkillText:match("choose") then
		if sSkillText:match("choice: ([^.]+)") or sSkillText:match("skills: ([^.]+)") then
			local sChoiceSkills = sSkillText:match("choice: ([^.]+)");

			if not sChoiceSkills then
				sChoiceSkills = sSkillText:match("skills: ([^.]+)");
			end

			if sChoiceSkills then
				sChoiceSkills = sChoiceSkills:gsub("and ", "");
				sChoiceSkills = sChoiceSkills:gsub("or ", "");

				local aWords = StringManager.split(sChoiceSkills, ",")
				for _,t in pairs(aWords) do
					t = StringManager.trim(t);
					local sSkillLower = t:lower();

					for k,_ in pairs(DataCommon.skilldata) do
						local sMatch = StringManager.trim(k):lower();
						if sSkillLower == sMatch then
							table.insert(aRaceChoiceSkills, t);
						end
					end
					if t == "two" then
						nChoices = 2;
					end
				end
			end
		else
			if sSkillText:match("of your choice") then
				if sSkillText:match("two ") then
					nChoices = 2;
				end
			end
		end

		bChoice = true;
	else
		sSkillText = sSkillText:gsub(" and ", " ")

		local aWords = StringManager.split(sSkillText, " ")
		for _,t in pairs(aWords) do
			if DataCommon.skilldata[StringManager.titleCase(t)] then
				if aSortAvailableSkills[t] then
					table.insert(aRaceSkills, t);
				end
			end
		end

		if sToolType then
			for _,vAllTool in pairs(CharWizardManager.getToolType(sToolType)) do
				local tCurTools = CharWizardManager.collectProficiencies();
				if not tCurTools[vAllTool] then
					table.insert(aChoiceProficiencies, vAllTool);
				end
			end
		end
	end

	if not bChoice then
		return bChoice, aRaceSkills, nil, nChoices, aChoiceProficiencies;
	else
		local aFinalSkills = {};

		for k,v in pairs(CharWizardManager.getAvailableSkills()) do
			table.insert(aFinalSkills, v:lower());
		end

		if #aRaceChoiceSkills > 0 then
			local aFinalChoiceSkills = {};

			for _,v in pairs(aRaceChoiceSkills) do
				v = StringManager.trim(v);

				if StringManager.contains(aFinalSkills, v:lower()) then
					table.insert(aFinalChoiceSkills, v:lower());
				end
			end

			return bChoice, aRaceSkills, aFinalChoiceSkills, nChoices, aChoiceProficiencies;
		else

			return bChoice, aRaceSkills, aFinalSkills, nChoices, aChoiceProficiencies;
		end
	end
end

function parseRaceSpells(w, s, aSources)
	local aSpells = {};

	for _,vSource in ipairs(aSources) do
		table.insert(aSpells, CharManager.helperParseAbilitySpells(DB.findNode(vSource)));
	end

	local aChoiceSpells = {};
	local bChoice = false;

	local sText = s:lower();
	local nChoices = 0;
	local sChoices, sSpellList = sText:match("you know (.-) cantrip of your choice from the (.-) spell list")

	if (sChoices or "") ~= "" then
		nChoices = CharManager.convertSingleNumberTextToNumber(sChoices);
		bChoice = true;
	end

	if nChoices > 0 then
		local tMappings = LibraryData.getMappings("spell");
		for _,sMapping in ipairs(tMappings) do
			for _,vGlobalItem in pairs(DB.getChildrenGlobal(sMapping)) do
				local sSpell = StringManager.trim(DB.getValue(vGlobalItem, "name", ""));
				local nSpellLevel = DB.getValue(vGlobalItem, "level", 0);
				local sSpellSource = StringManager.trim(DB.getValue(vGlobalItem, "source", ""))
				local aSpellSources = StringManager.split(sSpellSource:lower(), ",");

				for _,vSource in pairs(aSpellSources) do
					vSource = StringManager.trim(vSource);

					if sSpellList then
						if vSource:lower():match(sSpellList:lower()) then
							if nSpellLevel == 0 then
								table.insert(aChoiceSpells, sSpell)
							end
						end
					else
						if nSpellLevel == 0 then
							table.insert(aChoiceSpells, sSpell)
						end
					end
				end
			end
		end
	end

	return aSpells, aChoiceSpells, nChoices, bChoice
end

function parseRaceFeats(sText)
	local aRaceFeats = {};
	local aChoiceFeats = {};
	local nChoices = 1;
	local bChoice = false;
	local tAvailableFeats = CharWizardManager.getAvailableFeats();
	local aSortAvailableFeats = {};
	local sFeatText = sText:match("you gain one feat of your choice");

	for k,v in pairs(tAvailableFeats) do
		aSortAvailableFeats[v] = "";
	end

	if not sFeatText then
		return bChoice, aRaceFeats, nil, nChoices;
	end

	if sFeatText:match("choice") or sFeatText:match("choose") then
		if sFeatText:match("choice: ([^.]+)") or sFeatText:match("feats: ([^.]+)") then
			local sChoiceFeats = sFeatText:match("choice: ([^.]+)");

			if not sChoiceFeats then
				sChoiceFeats = sFeatText:match("feats: ([^.]+)");
			end

			if sChoiceFeats then
				sChoiceFeats = sChoiceFeats:gsub("and ", "");
				sChoiceFeats = sChoiceFeats:gsub("or ", "");

				local aWords = StringManager.split(sChoiceFeats, ",")
				for _,t in pairs(aWords) do
					t = StringManager.trim(t);
					local sFeatLower = t:lower();

					if aSortAvailableFeats[sFeatLower] then
						table.insert(aChoiceFeats, t);
					end
					if t == "two" then
						nChoices = 2;
					end
				end
			end
		else
			if sFeatText:match("of your choice") then
				if sFeatText:match("two ") then
					nChoices = 2;
				end
			end
		end

		bChoice = true;
	else
		sFeatText = sFeatText:gsub(" and ", " ")

		local aWords = StringManager.split(sFeatText, " ")
		for _,t in pairs(aWords) do
			if aSortAvailableFeats[t] then
				table.insert(aRaceFeats, t);
			end
		end
	end

	if not bChoice then
		return bChoice, aRaceFeats, nil, nChoices;
	else
		local aFinalFeats = {};

		for k,v in pairs(tAvailableFeats) do
			table.insert(aFinalFeats, v:lower());
		end

		if #aChoiceFeats > 0 then
			local aFinalChoiceFeats = {};

			for _,v in pairs(aChoiceFeats) do
				v = StringManager.trim(v);

				if StringManager.contains(aFinalFeats, v:lower()) then
					table.insert(aFinalChoiceFeats, v:lower());
				end
			end

			return bChoice, aRaceFeats, aFinalChoiceFeats, nChoices;
		else

			return bChoice, aRaceFeats, aFinalFeats, nChoices;
		end
	end
end

--
-- Decisions
--

local bUpdating = false;
function processRaceDecision(w)
	if bUpdating then
		return
	end

	bUpdating = true;

	local sTrait = w.windowlist.window.trait.getValue();
	local sTraitType = StringManager.simplify(sTrait:lower());
	local sDecisionChoice = w.decision_choice.getValue():lower();
	local sDecision = w.decision.getValue();
	sDecision = sDecision:gsub("Select ", ""):lower();

	if sDecision == "option" then
		CharWizardRaceManager.processRaceDecisiionAbilityScoreOption(w, sDecisionChoice);
	elseif sDecision == "variable trait" then
		CharWizardRaceManager.processRaceDecisionVariableTrait(w, sDecisionChoice);
	elseif sDecision == "size" then
		local tRace = CharWizardManager.character_choices["race"];
		tRace.size = sDecisionChoice:lower();
	else
		if sTraitType == "abilityscoreincrease" then
			CharWizardRaceManager.processRaceDecisionAbilityScoreInc(w);
		end
		if CharWizardData.aRaceLanguages[sTraitType] then
			CharWizardRaceManager.processRaceDecisionLanguage(w);
		end
		if CharWizardData.aRaceSkill[sTraitType] then
			CharWizardRaceManager.processRaceDecisionSkill(w);
		end
		if CharWizardData.aRaceProficiency[sTraitType] then
			CharWizardRaceManager.processRaceDecisionProficiency(w);
		end
		if CharWizardData.aRaceSpells[sTraitType] then
			CharWizardRaceManager.processRaceDecisionSpell(w);
		end
	end

	bUpdating = false;
end

function processRaceDecisiionAbilityScoreOption(w, sDecisionChoice)
	local tRace = CharWizardManager.character_choices["race"];
	local aChoices = {};
	local aChoiceWin = {};

	if not tRace.abilityincrease then
		tRace.abilityincrease = {};
	end

	for k,v in pairs(tRace.abilityincrease) do
		tRace.abilityincrease[k] = nil;
	end

	for _,wDecisions in pairs(w.windowlist.getWindows()) do
		if wDecisions.decision.getValue():lower():match("increase") then
			table.insert(aChoiceWin, wDecisions);
		end
	end

	for _,wChoice in ipairs(aChoiceWin) do
		wChoice.close();
	end

	if sDecisionChoice:match("option 1") then
		local w2 = w.windowlist.createWindow();
		w2.decision.setValue("Increase +2");
		w2.decision.setVisible(true);
		w2.decision_choice.setComboBoxVisible(true);

		for _,v in pairs(DataCommon.abilities) do
			w2.decision_choice.add(StringManager.capitalize(v));
			w.alert.setVisible(true);
		end

		local w3 = w.windowlist.createWindow();
		w3.decision.setValue("Increase +1");
		w3.decision.setVisible(true);
		w3.decision_choice.setComboBoxVisible(true);

		for _,v in pairs(DataCommon.abilities) do
			w3.decision_choice.add(StringManager.capitalize(v));
			w.alert.setVisible(true);
		end
	else
		for i = 1, 3 do
			local w3 = w.windowlist.createWindow();
			w3.decision.setValue("Increase +1");
			w3.decision.setVisible(true);
			w3.decision_choice.setComboBoxVisible(true);

			for _,v in pairs(DataCommon.abilities) do
				w3.decision_choice.add(StringManager.capitalize(v));
			end
		end
	end
end

--[[function processRaceDecisionFeat(w)
	local tRace = CharWizardManager.character_choices["race"];
	if not tRace.feat then
		tRace.feat = {};
	end

	local sFeat = window.name.getValue();
	tRace.feat = sFeat:lower();

	w.windowlist.window.parentcontrol.window.choice.setValue(sFeat);
	w.windowlist.window.parentcontrol.window.button_modify.setVisible(true);
	w.windowlist.window.parentcontrol.setVisible(false);
	w.windowlist.window.rebuildList();
end--]]

function processRaceDecisionVariableTrait(w, sDecisionChoice)
	local tRace = CharWizardManager.character_choices["race"];
	local sDarkvision = tRace.darkvision;

	if sDecisionChoice:match("darkvision") then
		tRace.darkvision = "Darkvision 60";

		if not tRace.skill then
			tRace.skill = {};
		end
		for k,v in pairs(tRace.skill) do
			if v.type == "decision" then
				table.remove(tRace.skill, k);
			end
		end

		for _,v in pairs(w.windowlist.getWindows()) do
			if v.decision.getValue():lower():match("skill") then
				v.close();
			end
		end
	else
		sDarkvision = "";

		local w3 = w.windowlist.createWindow();
		w3.decision.setValue("Select Skill");
		w3.decision.setVisible(true);
		w3.decision_choice.setComboBoxVisible(true);

		local aSkillChoices = CharWizardManager.getAvailableSkills();
		for _,vSkill in pairs(aSkillChoices) do
			w3.decision_choice.add(StringManager.capitalize(vSkill));
		end
	end
end

function processRaceDecisionAbilityScoreInc(w)
	local tRace = CharWizardManager.character_choices["race"];
	if not tRace.abilityincrease then
		tRace.abilityincrease = {};
	end

	local aChoices = {};
	local aChoiceWin = {};

	for k,v in pairs(tRace.abilityincrease) do
		tRace.abilityincrease[k] = nil;
	end

	for _,w in pairs(w.windowlist.getWindows()) do
		if w.decision.getValue() ~= "Select Option" then
			if w.decision_choice.getValue() ~= "" then
				aChoices[w.decision_choice.getValue():lower()] = w;
			end

			aChoiceWin[w] = w;
			w.decision_choice.clear();
		end
	end

	for k,v in pairs(aChoices) do
		local sDecision = v.decision.getValue();
		local nMod = sDecision:match("%d+");
		table.insert(tRace.abilityincrease, { ability = k, mod = nMod, win = w } );
	end

	for _,wChoice in pairs(aChoiceWin) do
		for _,vAbil in pairs(DataCommon.abilities) do
			if not aChoices[vAbil] then
				wChoice.decision_choice.add(StringManager.capitalize(vAbil));
			end
		end
	end
end

function processRaceDecisionLanguage(w)
	local tRace = CharWizardManager.character_choices["race"];
	if not tRace.language then
		tRace.language = {};
	end

	local aChoices = {};
	local aChoiceWin = {};

	for k,v in ipairs(tRace.language) do
		if v.type == w.windowlist.window.trait.getValue() then
			tRace.language[k] = nil;
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
		table.insert(tRace.language, { language = v, type = w.windowlist.window.trait.getValue() });
	end

	local sTraitText = w.windowlist.window.trait_desc.getValue();
	local _,aLangChoices = CharWizardRaceManager.parseRaceLanguages(sTraitText:lower());
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

function processRaceDecisionSkill(w)
	local tRace = CharWizardManager.character_choices["race"];
	if not tRace.skill then
		tRace.skill = {};
	end

	local aChoices = {};
	local aChoiceWin = {};

	for k,v in ipairs(tRace.skill) do
		if v.type == w.windowlist.window.trait.getValue() then
			tRace.skill[k] = nil;
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
		table.insert(tRace.skill, { skill = v, type = w.windowlist.window.trait.getValue() });
	end

	local sTraitText = w.windowlist.window.trait_desc.getValue();
	local _,_,aSkillChoices = CharWizardRaceManager.parseRaceSkills(sTraitText:lower());
	local tSelected = CharWizardManager.getAvailableSkills();

	if not aSkillChoices then
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

function processRaceDecisionProficiency(w)
	local tRace = CharWizardManager.character_choices["race"];
	if not tRace.proficiency then
		tRace.proficiency = {};
	end

	local aChoices = {};
	local aChoiceWin = {};
	local aDecisions = {};

	for k,v in pairs(tRace.proficiency) do
		if v.type == "innate" then
			aChoices[v.proficiency] = v;
		elseif v.type == "decision" then
			table.remove(tRace.proficiency, k);
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
		table.insert(tRace.proficiency, { proficiency = v.proficiency, expertise = 0, win = w });
	end

	local sTraitText = w.windowlist.window.trait_desc.getValue();
	local _,_,aChoiceProficiencies = CharWizardRaceManager.parseRaceProficiencies(sTraitText:lower());

	if aChoiceProficiencies then
		for _,wChoice in pairs(aChoiceWin) do
			for _,vProficiency in pairs(aChoiceProficiencies) do
				local bCreate = true;

				if aChoices[vProficiency] then
					bCreate = false;
				end

				if bCreate then
					wChoice.decision_choice.add(StringManager.capitalize(vProficiency));
				end
			end
		end
	end
end

function processRaceDecisionSpell(w)
	local tRace = CharWizardManager.character_choices["race"];
	if not tRace.spell then
		tRace.spell = {};
	end

	local aChoices = {};
	local aChoiceWin = {};
	local aDecisions = {};

	for k,v in pairs(tRace.spell) do
		if v.type == "decision" then
			table.remove(tRace.spell, k);
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
			table.insert(aDecisions, { spell = v.decision_choice.getValue():lower() } );
		end
	end

	for _,v in pairs(aDecisions) do
		table.insert(tRace.spell, { spell = v.spell, win = w });
	end

	local aRaceTraits = CharWizardRaceManager.collectRaceTraits();
	local aChoiceSpells = {};

	for _,vTrait in pairs(aRaceTraits) do
		local sText = CharWizardRaceManager.encodeTraitText(vTrait);

		local _,aCurChoiceSpells = CharWizardRaceManager.parseRaceSpells(w, sText:lower(), vTrait);
		for _,v in pairs(aCurChoiceSpells) do
			table.insert(aChoiceSpells, v);
		end
	end

	for _,wChoice in pairs(aChoiceWin) do
		for kSpell,vSpell in ipairs(aChoiceSpells) do
			if not aChoices[vSpell] then
				wChoice.decision_choice.add(StringManager.capitalize(vSpell));
			end
		end
	end
end
