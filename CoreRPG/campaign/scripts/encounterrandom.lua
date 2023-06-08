-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onLockChanged()
	if header.subwindow then
		header.subwindow.update();
	end
	
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	
	npcs_iedit.setVisibility(not bReadOnly);

	npcs.setReadOnly(bReadOnly);
	for _,w in pairs(npcs.getWindows()) do
		w.expr.setReadOnly(bReadOnly);
		w.token.setReadOnly(bReadOnly);
		w.name.setReadOnly(bReadOnly);
	end
end
