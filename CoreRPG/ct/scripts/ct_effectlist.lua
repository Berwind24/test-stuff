-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	registerMenuItem(Interface.getString("ct_menu_effectadd"), "pointer", 2);
end

function addEntry(bFocus)
	local win = createWindow();
	if bFocus and win then
		win.label.setFocus();
	end
	return win;
end

function onEnter()
	addEntry(true);
	return true;
end

function onMenuSelection(selection)
	if selection == 2 then
		addEntry(true);
	end
end

function deleteChild(wChild)
	UtilityManager.safeDeleteWindow(wChild);
end

function reset()
	for _,v in pairs(getWindows()) do
		UtilityManager.safeDeleteWindow(v);
	end
end
