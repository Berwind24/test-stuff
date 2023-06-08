-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	self.onCursorModeChanged();
end

function onCursorModeChanged(sTool)
	window.onCursorModeChanged();
end
function onStateChanged()
	window.onStateChanged();
end

function onDrop(x, y, draginfo)
	return ImageManager.onImageDrop(self, x, y, draginfo);
end

function onTokenAdded(token)
	if window.onTokenCountChanged then
		window.onTokenCountChanged();
	end
end
function onTokenDeleted(token)
	if window.onTokenCountChanged then
		window.onTokenCountChanged();
	end
end
function onTargetSelect(tTargets)
	return ImageManager.onImageTargetSelect(self, tTargets);
end
