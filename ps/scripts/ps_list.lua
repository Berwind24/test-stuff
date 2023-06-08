-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onDrop(x, y, draginfo)
	if Session.IsHost then
		if draginfo.isType("shortcut") then
			local sClass = draginfo.getShortcutData();
			if sClass == "charsheet" then
				PartyManager.addChar(draginfo.getDatabaseNode());
			end
			return true;
		end
	end
	return false;
end
