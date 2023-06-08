-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	if Session.IsHost then
		registerMenuItem(Interface.getString("list_menu_createitem"), "insert", 5);
	end
end

function onMenuSelection(selection)
	if selection == 5 then
		self.addEntry();
	end
end
function onDrop(x, y, draginfo)
	if Session.IsHost then
		local rEffect = EffectManager.decodeEffectFromDrag(draginfo);
		if rEffect then
			local node = addEntry();
			if node then
				EffectManager.setEffect(node, rEffect);
			end
		end
		return true;
	end
end
function onListChanged()
	window.onListChanged();
end

function addEntry()
	window.filter.setValue();
	return DB.createChild(window.getDatabaseNode());
end
