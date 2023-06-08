--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	ActionsManager.registerResultHandler("charwizardwealthroll", onRoll);

	self.update();
end

function update()
	local tEquipment = CharWizardManager.character_choices["equipment"];
	local tClass = CharWizardManager.character_choices["class"];

	if button_select_changechoice.isVisible() then
		if backgroundkit_header.isVisible() or classkit_header.isVisible() then
			if sub_backgroundkit.subwindow then
				local wSubBackgroundKit = sub_backgroundkit.subwindow;

				if wSubBackgroundKit.kit_list.isEmpty() then
					CharWizardEquipmentManager.collectBackgroundEquipmentKit(wSubBackgroundKit.kit_list);
				end
			end
			if sub_classkit.subwindow then
				local wSubClassKit = sub_classkit.subwindow;

				if wSubClassKit.kit_list.isEmpty() then
					CharWizardEquipmentManager.collectClassEquipmentKit(wSubClassKit.kit_list);
				end
			end

			startingwealth.setValue("");
			button_addbackgold.setValue(0);
			background_gold.setValue(CharWizardEquipmentManager.collectBackgroundGold());
			button_addbackgold.setValue(1);
		else
			if startingwealth.getValue() == "" then
				local sStartingWealth = "";
				for k,v in pairs(tClass) do
					if v.startingclass == 1 and CharWizardData.charwizard_starting_equipment[k:lower()] then
						sStartingWealth = CharWizardData.charwizard_starting_equipment[k:lower()].starting_wealth;

						break
					end
				end

				startingwealth.setValue(sStartingWealth);
			end

			button_addbackgold.setValue(0);
			CharWizardEquipmentManager.collectBackgroundGold();
			background_gold.setValue(tEquipment.backgroundgold);
			button_addbackgold.setValue(1);

			CharWizardManager.character_choices["equipment"].classitems = {};
			CharWizardManager.character_choices["equipment"].backgrounditems = {};

			if sub_backgroundkit.subwindow then
				sub_backgroundkit.subwindow.kit_list.closeAll();
			end
			if sub_backgroundkit.subwindow then
				sub_classkit.subwindow.kit_list.closeAll();
			end
		end
	else
		CharWizardManager.character_choices["equipment"] = {};
		currencylist.closeAll();

		if sub_backgroundkit.subwindow then
			sub_backgroundkit.subwindow.kit_list.closeAll();
		end
		if sub_classkit.subwindow then
			sub_classkit.subwindow.kit_list.closeAll();
		end

		background_gold.setValue(0);
		button_addbackgold.setValue(0);

		CharWizardEquipmentManager.setDefaultCurrencies(currencylist);
	end

	if sub_currentinventory.subwindow then
		sub_currentinventory.subwindow.rebuildList();
	end
end

function handleWealthRoll()
	local sWealth = startingwealth.getValue();
	local sFinalWealth = sWealth:gsub("[xX]", "*");
	local rRoll = { sType = "charwizardwealthroll", sDesc = "[STARTING WEALTH GENERATION]", nMod = 0 };
	rRoll.aDice = { expr = sFinalWealth };

	ActionsManager.actionDirect(nil, "charwizardwealthroll", { rRoll }, {{}});

	return true
end

function onRoll(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	Comm.deliverChatMessage(rMessage);

	local tEquipment = CharWizardManager.character_choices["equipment"];
	local nBackgroundGold = tEquipment.backgroundgold;

	for _,v in pairs(currencylist.getWindows()) do
		if v.name.getValue():lower() == "gp" then
			local nTotal = ActionsManager.total(rRoll);
			if nBackgroundGold then
				nTotal = nTotal + nBackgroundGold;
			end
			v.amount.setValue(nTotal);

			break
		end
	end

	return true
end

function updateVisibility(sType)
	if sType == "backgroundkit" then
		sub_backgroundkit.setVisible(not sub_backgroundkit.isVisible());

		if sub_backgroundkit.isVisible() then
			backgroundkit_expand.setValue(1);
		else
			backgroundkit_expand.setValue(0);
		end
	end
	if sType == "classkit" then
		sub_classkit.setVisible(not sub_classkit.isVisible());

		if sub_classkit.isVisible() then
			classkit_expand.setValue(1);
		else
			classkit_expand.setValue(0);
		end
	end
	if sType == "additems" then
		sub_additems.setVisible(not sub_additems.isVisible())

		if sub_additems.isVisible() then
			additems_expand.setValue(1);
		else
			additems_expand.setValue(0);
		end
	end

	self.update();
end
