-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local bInit = false;

local slots = {};
local nMaxSlotRow = 10;
local nDefaultSpacing = 10;
local nSpacing = nDefaultSpacing;

local sMaxNodeName = "";
local sCurrNodeName = "";

local nLocalMax = 0;
local nLocalCurrent = 0;

function onInit()
	-- Get any custom fields
	if values then
		if values[1].maximum then
			nLocalMax = tonumber(values[1].maximum[1]) or 0;
		end
		if values[1].current then
			nLocalCurrent = tonumber(values[1].current[1]) or 0;
		end
	end
	if maxslotperrow then
		nMaxSlotRow = tonumber(maxslotperrow[1]) or 10;
	end

	-- Synch to the data nodes
	local nodeWin = window.getDatabaseNode();
	if nodeWin then
		local sLoadMaxNodeName = "";
		local sLoadCurrNodeName = "";
		
		if sourcefields then
			if sourcefields[1].maximum then
				sLoadMaxNodeName = sourcefields[1].maximum[1];
			end
			if sourcefields[1].current then
				sLoadCurrNodeName = sourcefields[1].current[1];
			end
		end
		
		if sLoadMaxNodeName ~= "" then
			if not DB.getValue(nodeWin, sLoadMaxNodeName) then
				DB.setValue(nodeWin, sLoadMaxNodeName, "number", 1);
			end
			self.setMaxNode(DB.getPath(nodeWin, sLoadMaxNodeName));
		end
		if sLoadCurrNodeName ~= "" then
			self.setCurrNode(DB.getPath(nodeWin, sLoadCurrNodeName));
		end
	end
	
	if spacing then
		nSpacing = tonumber(spacing[1]) or nDefaultSpacing;
	end
	if allowsinglespacing then
		setAnchoredHeight(nSpacing);
	else
		setAnchoredHeight(nSpacing*2);
	end
	setAnchoredWidth(nSpacing);

	bInit = true;
	
	self.updateSlots();

	registerMenuItem(Interface.getString("counter_menu_clear"), "erase", 4);
end
function onClose()
	bInit = false;
	
	self.setMaxNode("");
	self.setCurrNode("");
end

function onMenuSelection(selection)
	if selection == 4 then
		self.setCurrentValue(0);
	end
end
function onWheel(notches)
	if isReadOnly() then
		return;
	end
	if not Input.isControlPressed() then
		return false;
	end

	self.adjustCounter(notches);
	return true;
end
function onClickDown(button, x, y)
	if isReadOnly() then
		return;
	end
	return true;
end
function onClickRelease(button, x, y)
	if isReadOnly() then
		return;
	end
	
	local m = self.getMaxValue();
	local c = self.getCurrentValue();

	local nClickH = math.floor(x / nSpacing) + 1;
	local nClickV;
	if m > nMaxSlotRow then
		nClickV	= math.floor(y / nSpacing);
	else
		nClickV = 0;
	end
	local nClick = (nClickV * nMaxSlotRow) + nClickH;

	if nClick > c then
		self.adjustCounter(1);
	else
		self.adjustCounter(-1);
	end

	return true;
end

function update()
	self.updateSlots();
	
	if self.onValueChanged then
		self.onValueChanged();
	end
end
function updateSlots()
	if not bInit then
		return;
	end
	
	self.checkBounds();

	local m = self.getMaxValue();
	local c = self.getCurrentValue();
	
	if #slots ~= m then
		-- Clear
		for _,v in ipairs(slots) do
			v.destroy();
		end
		slots = {};

		-- Build slots
		for i = 1, m do
			local sIcon;
			if i > c then
				sIcon = stateicons[1].off[1];
			else
				sIcon = stateicons[1].on[1];
			end
			
			local nW = (i - 1) % nMaxSlotRow;
			local nH = math.floor((i - 1) / nMaxSlotRow);
			local nX = (nSpacing * nW) + math.floor(nSpacing / 2);
			local nY;
			if m > nMaxSlotRow or allowsinglespacing then
				nY = (nSpacing * nH) + math.floor(nSpacing / 2);
			else
				nY = (nSpacing * nH) + nSpacing;
			end

			slots[i] = addBitmapWidget({ icon = sIcon, position = "topleft", x = nX, y = nY });
		end
		
		if m > nMaxSlotRow then
			setAnchoredWidth(nMaxSlotRow * nSpacing);
			setAnchoredHeight((math.floor((m - 1) / nMaxSlotRow) + 1) * nSpacing);
		else
			setAnchoredWidth(m * nSpacing);
			if allowsinglespacing then
				setAnchoredHeight(nSpacing);
			else
				setAnchoredHeight(nSpacing * 2);
			end
		end
	else
		for i = 1, m do
			if i > c then
				slots[i].setBitmap(stateicons[1].off[1]);
			else
				slots[i].setBitmap(stateicons[1].on[1]);
			end
		end
	end
end

function adjustCounter(nAdj)
	local m = self.getMaxValue();
	local c = self.getCurrentValue() + nAdj;
	
	if c > m then
		self.setCurrentValue(m);
	elseif c < 0 then
		self.setCurrentValue(0);
	else
		self.setCurrentValue(c);
	end
end
function checkBounds()
	local m = self.getMaxValue();
	local c = self.getCurrentValue();
	
	if c > m then
		self.setCurrentValue(m);
	elseif c < 0 then
		self.setCurrentValue(0);
	end
end

function getMaxValue()
	if sMaxNodeName ~= "" then
		return DB.getValue(sMaxNodeName, 0);
	end
	return nLocalMax;
end
function setMaxValue(nMax)
	if sMaxNodeName ~= "" then
		DB.setValue(sMaxNodeName, "number", nMax);
	else
		nLocalMax = nMax;
	end
end
function setMaxNode(sNewMaxNodeName)
	if sMaxNodeName ~= "" then
		DB.removeHandler(sMaxNodeName, "onUpdate", update);
	end
	sMaxNodeName = sNewMaxNodeName;
	if sMaxNodeName ~= "" then
		DB.addHandler(sMaxNodeName, "onUpdate", update);
	end
	self.updateSlots();
end

function getCurrentValue()
	if sCurrNodeName ~= "" then
		return DB.getValue(sCurrNodeName, 0);
	end
	return nLocalCurrent;
end
function setCurrentValue(nCount)
	if sCurrNodeName ~= "" then
		DB.setValue(sCurrNodeName, "number", nCount);
	else
		nLocalCurrent = nCurrent;
	end
end
function setCurrNode(sNewCurrNodeName)
	if sCurrNodeName ~= "" then
		DB.removeHandler(sCurrNodeName, "onUpdate", update);
	end
	sCurrNodeName = sNewCurrNodeName;
	if sCurrNodeName ~= "" then
		DB.addHandler(sCurrNodeName, "onUpdate", update);
	end
	self.updateSlots();
end
