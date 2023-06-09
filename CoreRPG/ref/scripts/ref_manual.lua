-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local m_sCurrentPage = "";

local m_sIndexPath = "";
local m_sPrevPath = "";
local m_sNextPath = "";

function onLockChanged()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	if sub_index.subwindow then
		sub_index.subwindow.update(bReadOnly, true);
	end

	filter.setValue("");
	self.updateIndexHelperControls();
end

function showIndex(bShow)
	frame_index.setVisible(bShow);
	sub_index.setVisible(bShow);

	self.updateIndexHelperControls();
end

function updateIndexHelperControls()
	local bIndexVisible = frame_index.isVisible();
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());

	button_index_expand.setVisible(bIndexVisible and bReadOnly);
	button_index_collapse.setVisible(bIndexVisible and bReadOnly);
	filter.setVisible(bIndexVisible and bReadOnly);

	locked.setVisible(bIndexVisible and not locked.isReadOnly());
end

function activateLink(sClass, sRecord)
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	local bEdit = bReadOnly == false;

	if sClass == "reference_manualtextwide" or sClass == "referencemanualpage" then
		local nodeRecord = DB.findNode(sRecord);
		if nodeRecord then
			local sModule = DB.getModule(nodeRecord);
			if (sModule or "") ~= "" then
				if sModule == DB.getModule(getDatabaseNode()) then
					self.activateLinkHelper(sClass, sRecord);
					return;
				end

				local nodeParent = DB.getParent(nodeRecord);
				if nodeParent and DB.getPath(nodeParent):sub(1,23) == "reference.refmanualdata" then
					local w = Interface.openWindow("reference_manual", "reference.refmanualindex@" .. sModule);
					w.activateLink(sClass, sRecord);
					return;
				end
			else
				self.activateLinkHelper(sClass, sRecord);
				return;
			end
		end
	end
	if sClass == "reference_manualtextwide" then
		sClass = "referencemanualpage";
	end

	local w = Interface.findWindow(sClass, sRecord);
	if w then
		Interface.toggleWindow(sClass, sRecord);
	else
		w = Interface.openWindow(sClass, sRecord);
	end
end
function activateLinkHelper(sClass, sRecord)
	local _, sCurrentRecord = content.getValue();
	if (sCurrentRecord or "") ~= sRecord then
		content.setValue("reference_manualtextwide", sRecord);
	end
	content.setVisible(true);

	m_sCurrentPage = sRecord;
	
	local sModule = DB.getModule(getDatabaseNode());
	ReferenceManualManager.init(sModule, m_sCurrentPage);
	m_sIndexPath = ReferenceManualManager.getIndexRecord(sModule) or "";
	m_sPrevPath = ReferenceManualManager.getPrevRecord(sModule, m_sCurrentPage) or "";
	m_sNextPath = ReferenceManualManager.getNextRecord(sModule, m_sCurrentPage) or "";

	page_top.setVisible(m_sIndexPath ~= "");
	page_prev.setVisible(m_sPrevPath ~= "");
	page_next.setVisible(m_sNextPath ~= "");
end

function handlePageTop()
	if m_sIndexPath ~= "" then
		self.activateLink("reference_manualtextwide", m_sIndexPath);
	end
end

function handlePagePrev()
	if m_sPrevPath ~= "" then
		self.activateLink("reference_manualtextwide", m_sPrevPath);
	end
end

function handlePageNext()
	if m_sNextPath ~= "" then
		self.activateLink("reference_manualtextwide", m_sNextPath);
	end
end

