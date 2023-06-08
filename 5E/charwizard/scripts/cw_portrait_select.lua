--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local _tPath = {};
local cControl = "";

function onInit()
	buildWindows();
end

function buildWindows()
	list.closeAll();

	if #_tPath > 0 then
		local w = list.createWindowWithClass("portrait_select_up");
		w.icon.setIcon("tokenbagup");
	end

	local sPath = table.concat(_tPath, "/");
	for _, v in ipairs(User.getPortraitDirectoryList(sPath)) do
		local w = list.createWindowWithClass("portrait_select_folder");
		w.icon.setIcon("tokenbag");
		w.icon.setTooltipText(v);
	end

	for _, v in ipairs(User.getPortraitFileList(sPath)) do
		local w = list.createWindow();
		w.portrait.setFile(v);
		local sPortraitSansModule = StringManager.split(v, "@")[1];
		local aPortraitPath = StringManager.split(sPortraitSansModule, "/");
		if #aPortraitPath > 0 then
			w.portrait.setTooltipText(aPortraitPath[#aPortraitPath]);
		end
	end
end

function setControl(c)
	cControl = c;
end

function onActivate(sFile)
	CharWizardManager.character_choices["background"].portrait = sFile;
	cControl.setAsset(sFile);

	close();
end
function onPathUp()
	if #_tPath > 0 then
		table.remove(_tPath);
		buildWindows();
	end
end
function onPathSelect(sFolder)
	table.insert(_tPath, sFolder);
	buildWindows();
end
