-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

widgetTitle = nil;

function onInit()
	widgetTitle = addTextWidget({ font = font[1] });
	
	local sTitle = "";
	
	local bLinked = false;
	if field then
		local node = window.getDatabaseNode();
		if node then
			DB.addHandler(DB.getPath(node, field[1]), "onUpdate", onUpdate);
			sTitle = DB.getValue(node, field[1]);
			bLinked = true;
		end
	end
	if not bLinked then
		if resource then
			sTitle = Interface.getString(resource[1]);
		elseif static then
			sTitle = static[1];
		end
	end
	
	self.setValue(sTitle);

	window.onSizeChanged = updatePosition;
	self.updatePosition();
end
function onClose()
	if field then
		local node = window.getDatabaseNode();
		if node then
			DB.removeHandler(DB.getPath(node, field[1]), "onUpdate", onUpdate);
		end
	end
end

function onUpdate()
	if widgetTitle then
		local nodeTitle = DB.getChild(window.getDatabaseNode(), field[1]);
		self.setValue(DB.getValue(nodeTitle))
	end
end

function setValue(sTitle)
	if widgetTitle then
		widgetTitle.setText(sTitle);
		self.updatePosition();
	end
end

function updatePosition()
	if widgetTitle then
		widgetTitle.setMaxWidth(0);
		local wTitle, hTitle = widgetTitle.getSize();
		local wWindow, hWindow = window.getSize();

		local wMin = tonumber(parameters[1].minwidth[1]) or 0;
		local wMax = wWindow - (parameters[1].windowmargin[1] * 2);
		if (wTitle > wMax) then
			wTitle = wMax;
		elseif (wTitle < wMin) then
			wTitle = wMin;
		end
		setStaticBounds(parameters[1].windowmargin[1] + (wMax - wTitle) / 2, parameters[1].controly[1], wTitle, parameters[1].controlheight[1]);
		widgetTitle.setMaxWidth(wTitle);
	end
end
