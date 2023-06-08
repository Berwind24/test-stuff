--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local tStandardArray = {15,14,13,12,10,8};

function setGenMethod(w)
	local sGenMethod = w.cb_genmethod.getValue();
	local bStandardArray = sGenMethod:lower() == "standard array";
	local bManual = sGenMethod:lower() == "dice roll/manual entry";
	local bPointBuy = sGenMethod:lower() == "point buy";

	if sGenMethod == "" then
		nBase = 10;
	elseif bPointBuy then
		nBase = 8;
	end
	for i,v in ipairs(DataCommon.abilities) do
		if bStandardArray then
			w[v .. "_base"].setValue(tStandardArray[i]);
		else
			w[v .. "_base"].setValue(nBase);
		end
	end

	w.cb_genroll.setVisible(bManual);

	w.point_label.setVisible(bPointBuy);
	w.points_used.setVisible(bPointBuy);
	w.pointbuy_label.setVisible(bPointBuy);
	w.points_max.setVisible(bPointBuy);

	w.constitution_genup.setVisible(bPointBuy);
	w.strength_genup.setVisible(bPointBuy);
	w.dexterity_genup.setVisible(bPointBuy);
	w.intelligence_genup.setVisible(bPointBuy);
	w.wisdom_genup.setVisible(bPointBuy);
	w.charisma_genup.setVisible(bPointBuy);
end

function updateAbilitiesTotal(w, sAbility)
	local tASI = CharWizardManager.character_choices["abilityscore"] or {};
	local nBase = w[sAbility .. "_base"].getValue();
	local nRace = w[sAbility .. "_race"].getValue();
	local nASI = w[sAbility .. "_asi"].getValue();
	local nMisc = w[sAbility .. "_misc"].getValue();
	local nOverride = w[sAbility .. "_override"].getValue();
	local nTotal = nBase + nRace + nASI + nMisc;
	local nModifier = math.floor((nTotal - 10) / 2);

	if nOverride > 0 then
		w[sAbility .. "_total"].setValue(nOverride);
		nTotal = nOverride;
	end

	w[sAbility .. "_total"].setValue(nTotal);
	w[sAbility .. "_modifier"].setValue((tonumber(nModifier) <= 0 and "" or "+") .. nModifier);

	tASI[sAbility] = { total = nTotal, score = nBase, modifier = nModifier, race = nRace, asi = nASI, override = nOverride };
end

function updateRaceAbilities(w)
	local tRace = CharWizardManager.character_choices["race"];
	for _,v in pairs(DataCommon.abilities) do
		w[v .. "_race"].setValue(0);
	end

	if tRace.abilityincrease then
		for _,v in pairs(tRace.abilityincrease) do
			w[v.ability .. "_race"].setValue(v.mod or 0);

			CharWizardAbilitiesManager.updateAbilitiesTotal(w, v.ability);
		end
	end
end

function collectASIAbilities()
	local tClass = CharWizardManager.character_choices.class;
	local tClassASI = {};
	for _,vClass in pairs(tClass) do
		if vClass.features then
			for _,vCurClassFeature in pairs(vClass.features) do
				for kFeature,vFeature in pairs(vCurClassFeature) do
					if kFeature == "abilityinc" then
						table.insert(tClassASI, vFeature);
					end
				end
			end
		end
	end

	local tFinalASI = {};
	for _,v in ipairs(tClassASI) do
		for _,v2 in ipairs(v) do
			if tFinalASI[v2.ability] then
				tFinalASI[v2.ability] = tFinalASI[v2.ability] + v2.mod;
			else
				tFinalASI[v2.ability] = v2.mod;
			end
		end
	end

	return tFinalASI;
end

function updateASIAbilities(w)
	for _,v in pairs(DataCommon.abilities) do
		w[v .. "_asi"].setValue(0);
	end

	local tClassASI = CharWizardAbilitiesManager.collectASIAbilities();
	for k,v in pairs(tClassASI) do
		w[k .. "_asi"].setValue(v);
	end
end

function recalcAbilityPointsSpent(w)
	local nPointTotal = 0;
	local nPointMax = w.points_max.getValue();

	for k,v in ipairs(DataCommon.abilities) do
		local currStatControl = v .. "_base";
		local nCurrStat = w[currStatControl].getValue();

		if nCurrStat >= 15 then
			nPointTotal = nPointTotal + 9;
		elseif nCurrStat == 14 then
			nPointTotal = nPointTotal + 7;
		elseif nCurrStat == 13 then
			nPointTotal = nPointTotal + 5;
		elseif nCurrStat == 12 then
			nPointTotal = nPointTotal + 4;
		elseif nCurrStat == 11 then
			nPointTotal = nPointTotal + 3;
		elseif nCurrStat == 10 then
			nPointTotal = nPointTotal + 2;
		elseif nCurrStat == 9 then
			nPointTotal = nPointTotal + 1;
		end
	end

	w.points_used.setValue(nPointTotal);

	for k,v in ipairs(DataCommon.abilities) do
		w[v .. "_genup"].setVisible(w.points_max.getValue() > 0 and w[v .. "_base"].getValue() < 15);
		w[v .. "_gendown"].setVisible(w[v .. "_base"].getValue() > 8);

		if nPointTotal == nPointMax then
			w[v .. "_genup"].setVisible(false);
		end
	end
end

function handleAbilityPointBuy(w, sName, nMod)
	local sAbility = "";
	local bUp = false;

	if nMod > 0 then
		sAbility = sName:gsub("_genup", "_base");
		bUp = true;
	else
		sAbility = sName:gsub("_gendown", "_base");
	end

	local nCurrStatValue = w[sAbility].getValue();
	nCurrStatValue = nCurrStatValue + nMod;

	w[sAbility].setValue(nCurrStatValue);

	CharWizardAbilitiesManager.recalcAbilityPointsSpent(w, sAbility);
	CharWizardAbilitiesManager.updateAbilitiesTotal(w, sAbility:gsub("_base", ""));
	CharWizardManager.updateAlerts();
end
