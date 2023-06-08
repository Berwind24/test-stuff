-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local control = nil;
OOB_MSGTYPE_DICETOWER = "dicetower";

function onTabletopInit()
	if Session.IsHost then
		OOBManager.registerOOBMsgHandler(DiceTowerManager.OOB_MSGTYPE_DICETOWER, DiceTowerManager.handleDiceTower);
	end
end

function registerControl(ctrl)
	control = ctrl;
	DiceTowerManager.activate();
end

function activate()
	OptionsManager.registerCallback("TBOX", update);
	OptionsManager.registerCallback("REVL", update);

	DiceTowerManager.update();
end

function update()
	if control then
		local bShow = false;
		if OptionsManager.isOption("TBOX", "on") then
			bShow = not Session.IsHost or not OptionsManager.isOption("REVL", "off");
		end
		control.setVisible(bShow);
		if control.window.setEnabled then
			control.window.setEnabled(bShow);
		end

		if not Session.IsHost then
			control.resetMenuItems();
			if bShow then
				control.registerMenuItem(Interface.getString("dicetower_menu_whisper"), "broadcast", 7);
			end
		end
	end
end

function onMenuSelection(selection)
	if Session.IsHost then return; end
	
	if selection == 7 then
		ChatManager.sendWhisperToGM();
	end
end

function encodeOOBFromDrag(draginfo, i, rSource)
	local msgOOB = ActionsManager.decodeRollFromDrag(draginfo, i);
	
	msgOOB.type = DiceTowerManager.OOB_MSGTYPE_DICETOWER;
	msgOOB.sender = ActorManager.getCreatureNodeName(rSource);
	msgOOB.sUser = Session.UserName;

	if msgOOB.aDice and msgOOB.aDice.expr then
		if (msgOOB.nMod or 0) ~= 0 then
			msgOOB.sDice = string.format("%s%+d", msgOOB.aDice.expr, msgOOB.nMod);
		else
			msgOOB.sDice = msgOOB.aDice.expr;
		end
	else
		msgOOB.sDice = DiceManager.convertDiceToString(msgOOB.aDice, msgOOB.nMod);
	end

	UtilityManager.simplifyEncode(msgOOB, "aDice");

	return msgOOB;
end

function decodeRollFromOOB(msgOOB)
	msgOOB.type = nil;
	msgOOB.sender = nil;
	msgOOB.bTower = true;
	msgOOB.bSecret = true;

	msgOOB.nMod = tonumber(msgOOB.nMod) or 0;
	UtilityManager.simplifyDecode(msgOOB, "aDice");
	
	return msgOOB;
end

function onDrop(draginfo)
	if control then
		if OptionsManager.isOption("TBOX", "on") then
			local sDragType = draginfo.getType();
			if GameSystem.actions[sDragType] then
				local rSource = ActionsManager.actionDropHelper(draginfo, false);
				
				for i = 1, draginfo.getSlotCount() do
					local msgOOB = DiceTowerManager.encodeOOBFromDrag(draginfo, i, rSource);

					if not Session.IsHost then
						local msg = { font = "chatfont", icon = "dicetower_icon" };
						if rSource then
							msg.sender = ActorManager.getDisplayName(rSource);
						end
						msg.text = string.format("%s [%s]", msgOOB.sDesc or "", msgOOB.sDice);
						
						Comm.addChatMessage(msg);
					end

					msgOOB.sDice = nil;
					Comm.deliverOOBMessage(msgOOB, "");
				end
			elseif sDragType == "string" then
				ChatManager.processWhisperHelper("GM", draginfo.getStringData());
			end
		end
	end

	return true;
end

function handleDiceTower(msgOOB)
	local rActor = nil;
	if msgOOB.sender and msgOOB.sender ~= "" then
		rActor = ActorManager.resolveActor(msgOOB.sender);
	end

	local rRoll = DiceTowerManager.decodeRollFromOOB(msgOOB);
	rRoll.sDesc = string.format("[%s] %s", Interface.getString("dicetower_tag"), (rRoll.sDesc or ""));
	
	ActionsManager.roll(rActor, nil, rRoll);
end
