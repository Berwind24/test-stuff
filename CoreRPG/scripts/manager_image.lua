-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	ImageManager.addStandardDropHandlers();

	Interface.addKeyedEventHandler("onWindowOpened", "imagewindow", ImageManager.onWindowOpened);
end
function onTabletopInit()
	ImageManager.registerDBHandlers();
end
function onWindowOpened(w)
	ImageManager.checkImageSharing(w);
end

function registerDBHandlers()
	local vNodes = LibraryData.getMappings("image");
	for i = 1, #vNodes do
		local sPath = vNodes[i] .. ".*@*";
		DB.addHandler(sPath, "onDelete", ImageManager.onImageRecordDeleted);
	end
end
function onImageRecordDeleted(nodeImageRecord)
	ImageManager.checkImagePanelDeletion(nodeImageRecord);
end

-- Panel functions

local wBackPanel = nil;
function registerBackPanel(w)
	wBackPanel = w;
end
local wFullPanel = nil;
function registerFullPanel(w)
	wFullPanel = w;
end

function getPanelValue(wPanel)
	if not wPanel then 
		return "", ""; 
	end
	local _, sRecord = wPanel.sub.getValue();
	local x, y, zoom;
	if wPanel.sub.subwindow then
		x, y, zoom = wPanel.sub.subwindow.image.getViewpoint();
	end
	return sRecord, x, y, zoom;
end
function getPanelDataValue(wPanel)
	if not wPanel then 
		return ""; 
	end
	local _, sRecord = wPanel.sub.getValue();
	return sRecord;
end
function isPanelDataValue(wPanel, sRecord)
	if (sRecord or "") == "" then 
		return false; 
	end
	local sPanelRecord = ImageManager.getPanelDataValue(wPanel);
	if (sPanelRecord or "") == "" then 
		return false; 
	end
	return (sPanelRecord == sRecord);
end
function clearPanelValue(wPanel)
	if not wPanel then 
		return; 
	end
	ImageManager.setPanelValue(wPanel, "", "");
end
function setPanelValue(wPanel, sRecord, x, y, zoom)
	if not wPanel then 
		return; 
	end
	local bShow = true;
	local bShow = ((sRecord or "") ~= "");
	if bShow then
		wPanel.sub.setValue("imagepanelwindow", sRecord);
		wPanel.setBackColor("808080");
	else
		wPanel.sub.setValue();
		wPanel.setBackColor();
	end
	if wPanel.getClass() == "imagefullpanel" then
		wPanel.button_backpanel.setVisible(bShow);
	elseif wPanel.getClass() == "imagebackpanel" then
		wPanel.button_restore.setVisible(bShow);
		wPanel.button_fullpanel.setVisible(bShow);
	end
	wPanel.button_help.setVisible(bShow);
	wPanel.button_close.setVisible(bShow);
	wPanel.setEnabled(bShow);
	if x and y and zoom and wPanel.sub.subwindow then
		wPanel.sub.subwindow.image.setViewpoint(x, y, zoom);
	end
end

function closePanel()
	ImageManager.clearPanelValue(wBackPanel);
	ImageManager.clearPanelValue(wFullPanel);
end
function sendWindowToBackPanel(w)
	if not wBackPanel then 
		return; 
	end
	local sClass = w.getClass();
	if (sClass or "") ~= "imagewindow" then 
		return; 
	end
	local vNode = w.getDatabaseNode();
	if not vNode then 
		return; 
	end
	local x,y,zoom = w.image.getViewpoint();
	ImageManager.setPanelValue(wBackPanel, DB.getPath(vNode), x, y, zoom);
	w.close();
end
function sendBackPanelToWindow()
	if not wBackPanel then 
		return; 
	end
	local sRecord, x, y, zoom = ImageManager.getPanelValue(wBackPanel);
	ImageManager.clearPanelValue(wBackPanel);
	local w = Interface.openWindow("imagewindow", sRecord);
	if not w then 
		return; 
	end
	w.image.setViewpoint(x, y, zoom);
end
function sendBackPanelToFullPanel()
	if not wBackPanel or not wFullPanel then 
		return; 
	end
	local sRecord, x, y, zoom = ImageManager.getPanelValue(wBackPanel);
	ImageManager.clearPanelValue(wBackPanel);
	ImageManager.setPanelValue(wFullPanel, sRecord, x, y, zoom);
end
function sendFullPanelToBackPanel()
	if not wBackPanel or not wFullPanel then 
		return; 
	end
	local sRecord, x, y, zoom = ImageManager.getPanelValue(wFullPanel);
	ImageManager.clearPanelValue(wFullPanel);
	ImageManager.setPanelValue(wBackPanel, sRecord, x, y, zoom);
end
function checkImageSharing(w)
	local sClass = w.getClass() or "";
	if sClass ~= "imagewindow" then 
		return; 
	end
	local vRecord = w.getDatabaseNode();
	if not vRecord then 
		return; 
	end
	local sRecord = DB.getPath(vRecord);
	
	if ImageManager.isPanelDataValue(wBackPanel, sRecord) or ImageManager.isPanelDataValue(wFullPanel, sRecord) then
		w.close();
	end
end
function checkImagePanelDeletion(nodeImageRecord)
	local sRecord = DB.getPath(nodeImageRecord);
	if ImageManager.isPanelDataValue(wBackPanel, sRecord) then
		ImageManager.clearPanelValue(wBackPanel);
	end
	if ImageManager.isPanelDataValue(wFullPanel, sRecord) then
		ImageManager.clearPanelValue(wFullPanel);
	end
end

-- Registration functions

local _tImages = {};
function registerImage(cImage)
	table.insert(_tImages, cImage);
	ImageManager.onImageInit(cImage);
end
function unregisterImage(cImage)
	for k, v in ipairs(_tImages) do
		if v == cImage then
			table.remove(_tImages, k);
			return;
		end
	end
end
function getActiveImages()
	return _tImages;
end

-- Drop handling

function addStandardDropHandlers()
	ImageManager.registerDropCallback("shortcut", ImageManager.onImageShortcutDrop);
	ImageManager.registerDropCallback("combattrackerff", ImageManager.onImageCTFactionDrop);
end

local _tDropCallbacks = {};
function registerDropCallback(sDropType, fn)
	UtilityManager.registerKeyCallback(_tDropCallbacks, sDropType, fn);
end
function unregisterDropCallback(sDropType, fn)
	UtilityManager.unregisterKeyCallback(_tDropCallbacks, sDropType, fn);
end

function onImageShortcutDrop(cImageControl, x, y, draginfo)
	local sClass,_ = draginfo.getShortcutData();
	if sClass == "charsheet" then
		if not Input.isShiftPressed() then
			return true;
		end
	end
end
function onImageCTFactionDrop(cImageControl, x, y, draginfo)
	return CombatManager.handleFactionDropOnImage(draginfo, cImageControl, x, y);
end

-- Event handlers

function onImageInit(cImage)
	for _,vToken in ipairs(cImage.getTokens()) do
		TokenManager.updateAttributesFromToken(vToken);
	end
	if Session.IsHost then
		cImage.setTokenOrientationMode(false);
	end
end
function onTokenAdd(tokenMap)
	Debug.console("ImageManager.onTokenAdd - DEPRECATED - 2023-02-21 - No longer used");
end
function onTokenDelete(tokenMap)
	Debug.console("ImageManager.onTokenDelete - DEPRECATED - 2023-02-21 - No longer used");
end

function onImageTargetSelect(cImageControl, tTargets)
	local aSelected = cImageControl.getSelectedTokens();
	if #aSelected == 0 then
		local tokenActive = TargetingManager.getActiveToken(cImageControl);
		if tokenActive then
			local bAllTargeted = true;
			for _,vToken in ipairs(tTargets) do
				if not vToken.isTargetedBy(tokenActive) then
					bAllTargeted = false;
					break;
				end
			end
			
			for _,vToken in ipairs(tTargets) do
				tokenActive.setTarget(not bAllTargeted, vToken);
			end
			return true;
		end
	end
end
function onImageDrop(cImageControl, x, y, draginfo)
	if UtilityManager.performKeyCallbacks(_tDropCallbacks, draginfo.getType(), cImageControl, x, y, draginfo) then
		return true;
	end
end

-- Helpers

-- NOTE: Returns ctrlImage, winImage, bWindowOpened
function getImageControl(tokeninstance, bOpen)
	if not tokeninstance then 
		return nil, nil, false; 
	end
	local nodeImage = tokeninstance.getContainerNode();
	if not nodeImage then 
		return nil, nil, false; 
	end
	local vNodeImageRecord = DB.getParent(nodeImage);
	if not vNodeImageRecord then 
		return nil, nil, false; 
	end
	local sRecord = DB.getPath(vNodeImageRecord);
	
	if ImageManager.isPanelDataValue(wBackPanel, sRecord) then
		return wBackPanel.sub.subwindow.image, wBackPanel.sub.subwindow, false;
	end
	if ImageManager.isPanelDataValue(wFullPanel, sRecord) then
		return wFullPanel.sub.subwindow.image, wFullPanel.sub.subwindow, false;
	end
	local w = Interface.findWindow("imagewindow", sRecord);
	if w then
		return w.image, w, false;
	end
	if not bOpen then 
		return nil, nil, false; 
	end
	local w = Interface.openWindow("imagewindow", sRecord);
	if w then
		return w.image, w, true;
	end
	return nil, nil, false;
end
function centerOnToken(tokeninstance, bOpen)
	if not tokeninstance then 
		return; 
	end
	local ctrlImage = ImageManager.getImageControl(tokeninstance, bOpen);
	if not ctrlImage then 
		return; 
	end
	local x,y = tokeninstance.getPosition();
	ctrlImage.setViewpoint(x,y);
end
