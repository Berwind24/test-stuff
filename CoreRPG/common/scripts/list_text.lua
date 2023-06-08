-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local _sFocusField = "name";

function onInit()
	if newfocus then
		_sFocusField = newfocus[1];
	end
end

function onListChanged()
	self.update();
end
function update()
	local sEdit = getName() .. "_iedit";
	if window[sEdit] then
		local bEdit = (window[sEdit].getValue() == 1);
		for _,w in ipairs(getWindows()) do
			if w.idelete then
				w.idelete.setVisibility(bEdit);
			end
		end
	end
end

function addEntry(bFocus)
	local w = createWindow();
	if bFocus and w[_sFocusField] then
		w[_sFocusField].setFocus();
	end
	if self.onEntryAdded then
		self.onEntryAdded(w);
	end
	return w;
end
