-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onDrop(x, y, draginfo)
	local sPrototype, dropref = draginfo.getTokenData();
	if (sPrototype or "") == "" then
		return nil;
	end
	
	setPrototype(sPrototype);
	CombatManager.replaceCombatantToken(window.getDatabaseNode(), dropref);
	return true;
end

function onDragStart(button, x, y, draginfo)
	local nSpace = DB.getValue(window.getDatabaseNode(), "space");
	TokenManager.setDragTokenUnits(nSpace);

	draginfo.setType("token");
	draginfo.setTokenData(getValue());
	if window.link then
		local sClass, sRecord = window.link.getValue();
		if sRecord == "" then
			sRecord = window.getDatabasePath();
		end
		draginfo.setShortcutData(sClass, sRecord);
	end
	return true;
end
function onDragEnd(draginfo)
	TokenManager.endDragTokenWithUnits();

	local prototype, dropref = draginfo.getTokenData();
	if dropref then
		CombatManager.replaceCombatantToken(window.getDatabaseNode(), dropref);
	end
	return true;
end

function onClickDown(button, x, y)
	return true;
end
function onClickRelease(button, x, y)
	if button == 1 then
		-- CTRL + left click to target CT entry with active CT entry
		if Input.isControlPressed() then
			local nodeActive = CombatManager.getActiveCT();
			if nodeActive then
				local nodeTarget = window.getDatabaseNode();
				if nodeTarget then
					TargetingManager.toggleCTTarget(nodeActive, nodeTarget);
				end
			end
		-- All other left clicks will toggle activation outline for linked token (if any)
		else
			local token = CombatManager.getTokenFromCT(window.getDatabaseNode());
			if token then
				token.setActive(not token.isActive());
			end
		end
	end

	return true;
end
function onDoubleClick(x, y)
	CombatManager.openMap(window.getDatabaseNode());
end

function onWheel(notches)
	TokenManager.onWheelCT(window.getDatabaseNode(), notches);
	return true;
end
