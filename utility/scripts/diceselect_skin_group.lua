-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local _sID = nil;

function getID()
	return _sID;
end

function setData(nOrder, sID)
	_sID = sID;
	order.setValue(nOrder);
	name.setValue(Interface.getString("diceskin_group_" .. sID));
	name.setColor("FF808080");
	button_store.productid = { sID };
end
function setOwned()
	if owned.getValue() == 0 then
		owned.setValue(1);
		name.setColor(nil);
		button_store.setVisible(false);
		self.toggle();
	end
end

function toggle()
	list.setVisible(not list.isVisible());
	if list.isVisible() then
		status.setIcon("button_collapse");
	else
		status.setIcon("button_expand");
	end
end
