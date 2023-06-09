-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local m_sIndexPath = "";
local m_sPrevPath = "";
local m_sNextPath = "";

function onInit()
	local vNode = getDatabaseNode();
	local sPath = DB.getPath(vNode);
	local sModule = DB.getModule(vNode);
	
	ReferenceManualManager.init(sModule, sPath);
	
	m_sIndexPath = ReferenceManualManager.getIndexRecord(sModule) or "";
	m_sPrevPath = ReferenceManualManager.getPrevRecord(sModule, sPath) or "";
	m_sNextPath = ReferenceManualManager.getNextRecord(sModule, sPath) or "";
	
	page_top.setVisible(m_sIndexPath ~= "");
	page_prev.setVisible(m_sPrevPath ~= "");
	page_next.setVisible(m_sNextPath ~= "");

	onLockChanged();
end

function onLockChanged()
	if header.subwindow then
		header.subwindow.update();
	end
	if content and content.subwindow then
		content.subwindow.update();
	end
end

function handlePageTop()
	if m_sIndexPath ~= "" then
		activateLink("referencemanualpage", m_sIndexPath);
	end
end

function handlePagePrev()
	if m_sPrevPath ~= "" then
		activateLink("referencemanualpage", m_sPrevPath);
	end
end

function handlePageNext()
	if m_sNextPath ~= "" then
		activateLink("referencemanualpage", m_sNextPath);
	end
end

function activateLink(sClass, sRecord)
	if sClass == "referencemanualpage" then
		local x,y = getPosition();
		local w,h = getSize();
		local wNew = Interface.openWindow(sClass, sRecord);
		if wNew then
			wNew.setPosition(x,y);
			wNew.setSize(w,h);
			close();
		end
	else
		Interface.openWindow(sClass, sRecord);
	end
end

