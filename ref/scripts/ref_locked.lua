-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local bUpdating = false;
local nodeSrc = nil;
local nDefault = 0;

function onInit()
	nodeSrc = window.getDatabaseNode();
	if (DB.getModule(nodeSrc) or "") ~= "" then
		nDefault = 1;
	end

	if nodeSrc and not DB.isReadOnly(nodeSrc) then
		setStateIcons(0, "padlock_open");
		setStateTooltipText(0, Interface.getString("tooltip_unlock"));
		setStateIcons(1, "padlock_closed");
		setStateTooltipText(1, Interface.getString("tooltip_lock"));
		onUpdate();
		DB.addHandler(DB.getPath(nodeSrc, "locked"), "onUpdate", onUpdate);
	else
		nodeSrc = nil;
		setReadOnly(true);
		setVisible(false);
	end

	notify();
end
function onClose()
	if nodeSrc then
		DB.removeHandler(DB.getPath(nodeSrc, "locked"), "onUpdate", onUpdate);
	end
end
	
function onUpdate()
	if bUpdating then
		return;
	end
	bUpdating = true;
	local nValue = DB.getValue(nodeSrc, "locked", nDefault);
	if nValue == 0 then
		setValue(0);
	else
		setValue(1);
	end
	bUpdating = false;
end
function onValueChanged()
	if not bUpdating then
		bUpdating = true;
		if nodeSrc then
			DB.setValue(nodeSrc, "locked", "number", getValue());
		end
		bUpdating = false;
	end
	notify();
end

function notify()
	if window.onLockChanged then
		window.onLockChanged();
	elseif window.parentcontrol and window.parentcontrol.window.onLockChanged then
		window.parentcontrol.window.onLockChanged();
	end
end
