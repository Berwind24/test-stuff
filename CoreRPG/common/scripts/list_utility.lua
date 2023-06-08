-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	super.onInit();
	if not isReadOnly() and DB.isOwner(getDatabaseNode()) then
		registerMenuItem(Interface.getString("list_menu_createitem"), "insert", 5);
	end
end

function onListChanged()
	-- Empty on purpose to override list_text version
end

function onMenuSelection(selection)
	if selection == 5 then
		if window.filter then
			window.filter.setValue();
		end
		addEntry();
	end
end

function onFilter(w)
	if window.filter then
		local sFilter = window.filter.getValue();
		if sFilter ~= "" then
			if not w.label.getValue():upper():find(sFilter:upper(), 1, true) then
				return false;
			end
		end
	end
	if w.isgmonly and not Session.IsHost and w.isgmonly.getValue() == 1 then
		return false;
	end
	return true;
end
