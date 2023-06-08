-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

DEFAULT_FILL_FACING = 0;
DEFAULT_FILL_RANGE = 3;

function getFactionFormationRecords(sFaction)
	local tPartyFormation;
	if sFaction == "friend" then
		tPartyFormation = PartyFormationManager.getFormation();
	else
		tPartyFormation = {};
	end

	local tAssigned = {};
	local tFactionData = {};
	if sFaction == "friend" then
		for _,v in ipairs(PartyManager.getPartyNodes()) do
			local sClass, sRecord = DB.getValue(v, "link", "", "");
			table.insert(tFactionData, { sClass = sClass, sRecord = sRecord, tSlotPos = tPartyFormation[sRecord] });
			tAssigned[sRecord] = #tFactionData;
		end
	end
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		if CombatManager.getFactionFromCT(v) == sFaction then
			local sClass,sRecord = DB.getValue(v, "link", "", "");
			if sRecord == "" then
				sRecord = DB.getPath(v);
			end
			if tAssigned[sRecord] then
				tFactionData[tAssigned[sRecord]].nodeCT = v;
			else
				table.insert(tFactionData, { nodeCT = v, sClass = sClass, sRecord = sRecord, tSlotPos = tPartyFormation[sRecord] });
				tAssigned[sRecord] = #tFactionData;
			end
		end
	end
	return tFactionData;
end

function fillFactionFormationSlots(sFaction, tFactionData, sFillType, nFillRange)
	local nFillFacing;
	if sFaction == "friend" then
		nFillFacing = PartyFormationManager.getFormationFacing();
		if not nFillRange then
			nFillRange = PartyFormationManager.SLOT_RANGE;
		end
	else
		nFillFacing = CombatFormationManager.DEFAULT_FILL_FACING;
		if not nFillRange then
			nFillRange = CombatFormationManager.DEFAULT_FILL_RANGE;
		end
	end

	local tSlotsUsed = {};
	for _,v in ipairs(tFactionData) do
		if v.tSlotPos then
			tSlotsUsed[StringManager.convertPointToString(v.tSlotPos)] = true;
		end
	end

	if sFillType == "column3" then
		local tOpenSlotPos = CombatFormationManager.getStartColumnFillSlot(3, #tFactionData, nFillFacing, nFillRange);
		for _,v in pairs(tFactionData) do
			if not v.tSlotPos then
				tOpenSlotPos = CombatFormationManager.getNextOpenColumnx3FillSlot(tOpenSlotPos, tSlotsUsed, nFillFacing, nFillRange);
				if not tOpenSlotPos then
					break;
				end
				v.tSlotPos = tOpenSlotPos;
				tSlotsUsed[StringManager.convertPointToString(tOpenSlotPos)] = true;
			end
		end
	elseif sFillType == "column2" then
		local tOpenSlotPos = CombatFormationManager.getStartColumnFillSlot(2, #tFactionData, nFillFacing, nFillRange);
		for _,v in ipairs(tFactionData) do
			if not v.tSlotPos then
				tOpenSlotPos = CombatFormationManager.getNextOpenColumnx2FillSlot(tOpenSlotPos, tSlotsUsed, nFillFacing, nFillRange);
				if not tOpenSlotPos then
					break;
				end
				v.tSlotPos = tOpenSlotPos;
				tSlotsUsed[StringManager.convertPointToString(tOpenSlotPos)] = true;
			end
		end
	elseif sFillType == "column1" then
		local tOpenSlotPos = CombatFormationManager.getStartColumnFillSlot(1, #tFactionData, nFillFacing, nFillRange);
		for _,v in ipairs(tFactionData) do
			if not v.tSlotPos then
				tOpenSlotPos = CombatFormationManager.getNextOpenColumnx1FillSlot(tOpenSlotPos, tSlotsUsed, nFillFacing, nFillRange);
				if not tOpenSlotPos then
					break;
				end
				v.tSlotPos = tOpenSlotPos;
				tSlotsUsed[StringManager.convertPointToString(tOpenSlotPos)] = true;
			end
		end
	end

	-- Default remaining fill of spiral
	local tOpenSlotPos = nil;
	for _,v in ipairs(tFactionData) do
		if not v.tSlotPos then
		 	tOpenSlotPos = CombatFormationManager.getNextOpenSpiralSlot(tOpenSlotPos, tSlotsUsed, nFillFacing);
		 	if not tOpenSlotPos then
		 		break;
		 	end
			v.tSlotPos = tOpenSlotPos;
			tSlotsUsed[StringManager.convertPointToString(tOpenSlotPos)] = true;
		end
	end
end

-- Spiral counter-clockwise left start
function getNextOpenSpiralSlot(tSlotPos, tSlotsUsed, nFillFacing)
	local tOpenSlotPos;
	if tSlotPos then	
		tOpenSlotPos = { x = tSlotPos.x, y = tSlotPos.y };
	else
		tOpenSlotPos = { x = 0, y = 0 };
	end
	while (tSlotsUsed[StringManager.convertPointToString(tOpenSlotPos)]) do
		local nRing = math.max(math.abs(tOpenSlotPos.x), math.abs(tOpenSlotPos.y));
		if nRing > 0 then
			--local nRingSize = nRing * 8;
			if tOpenSlotPos.y >= nRing then
				if tOpenSlotPos.x <= -nRing then
					-- Advance down
					tOpenSlotPos.y = tOpenSlotPos.y - 1;
				else
					-- Advance left
					tOpenSlotPos.x = tOpenSlotPos.x - 1;
				end
			elseif tOpenSlotPos.x >= nRing then
				if tOpenSlotPos.y >= nRing then
					-- Advance left
					tOpenSlotPos.x = tOpenSlotPos.x - 1;
				else
					-- Advance up
					tOpenSlotPos.y = tOpenSlotPos.y + 1;
				end
			elseif tOpenSlotPos.y <= -nRing then
				if tOpenSlotPos.x >= nRing then
					-- Advance up
					tOpenSlotPos.y = tOpenSlotPos.y + 1;
				else
					-- Advance right
					tOpenSlotPos.x = tOpenSlotPos.x + 1;
				end
			elseif tOpenSlotPos.x <= -nRing then
				if tOpenSlotPos.y <= -nRing then
					-- Advance right
					tOpenSlotPos.x = tOpenSlotPos.x + 1;
				else
					-- Advance down
					tOpenSlotPos.y = tOpenSlotPos.y - 1;
				end
			else
				tOpenSlotPos = { x = 0, y = 0 };
				ChatManager.SystemMessage("Error while calculating spiral formation slot");
				break;
			end
		end
		-- Advance to next ring
		if nFillFacing == 1 then
			if (tOpenSlotPos.x == 0) and (tOpenSlotPos.y == nRing) then
				tOpenSlotPos = { x = 0, y = nRing + 1 };
			end			
		elseif nFillFacing == 2 then
			if (tOpenSlotPos.x == nRing) and (tOpenSlotPos.y == 0) then
				tOpenSlotPos = { x = nRing + 1, y = 0 };
			end			
		elseif nFillFacing == 3 then
			if (tOpenSlotPos.x == 0) and (tOpenSlotPos.y == -nRing) then
				tOpenSlotPos = { x = 0, y = -nRing - 1 };
			end			
		else
			if (tOpenSlotPos.x == -nRing) and (tOpenSlotPos.y == 0) then
				tOpenSlotPos = { x = -nRing - 1, y = 0 };
			end			
		end
	end
	return tOpenSlotPos;
end

-- Fills top-down from starting slot position or 0,0
-- Can return nil
function getStartColumnFillSlot(nColumns, nCount, nFillFacing, nFillRange)
	if not nFillRange then
		nFillRange = PartyFormationManager.SLOT_RANGE;
	end

	local nCountRange = math.floor(nCount / nColumns);
	if (nCount % nColumns) > 0 then
		nCountRange = nCountRange + 1;
	end
	if nFillFacing == 1 then
		return { x = math.max(0, math.min(nFillRange, (nCountRange - nFillRange - 1))), y = 0 };
	elseif nFillFacing == 2 then
		return { x = 0, y = math.min(0, math.max(-nFillRange, (-nCountRange + nFillRange + 1))) };
	elseif nFillFacing == 3 then
		return { x = math.min(0, math.max(-nFillRange, (-nCountRange + nFillRange + 1))), y = 0 };
	end
	return { x = 0, y = math.max(0, math.min(nFillRange, (nCountRange - nFillRange - 1))) };
end
function getNextOpenColumnx1FillSlot(tSlotPos, tSlotsUsed, nFillFacing, nFillRange)
	if not nFillRange then
		nFillRange = PartyFormationManager.SLOT_RANGE;
	end

	local tOpenSlotPos;
	if tSlotPos then	
		tOpenSlotPos = { x = tSlotPos.x, y = tSlotPos.y };
	else
		tOpenSlotPos = { x = 0, y = 0 };
	end
	while (tSlotsUsed[StringManager.convertPointToString(tOpenSlotPos)]) do
		if nFillFacing == 1 then
			tOpenSlotPos.y = 0;
			tOpenSlotPos.x = tOpenSlotPos.x - 1;
			if tOpenSlotPos.x < -nFillRange then
				return nil;
			end
		elseif nFillFacing == 2 then
			tOpenSlotPos.x = 0;
			tOpenSlotPos.y = tOpenSlotPos.y + 1;
			if tOpenSlotPos.y > nFillRange then
				return nil;
			end
		elseif nFillFacing == 3 then
			tOpenSlotPos.y = 0;
			tOpenSlotPos.x = tOpenSlotPos.x + 1;
			if tOpenSlotPos.x > nFillRange then
				return nil;
			end
		else
			tOpenSlotPos.x = 0;
			tOpenSlotPos.y = tOpenSlotPos.y - 1;
			if tOpenSlotPos.y < -nFillRange then
				return nil;
			end
		end
	end
	return tOpenSlotPos;
end
function getNextOpenColumnx2FillSlot(tSlotPos, tSlotsUsed, nFillFacing, nFillRange)
	if not nFillRange then
		nFillRange = PartyFormationManager.SLOT_RANGE;
	end

	local tOpenSlotPos;
	if tSlotPos then	
		tOpenSlotPos = { x = tSlotPos.x, y = tSlotPos.y };
	else
		tOpenSlotPos = { x = 0, y = 0 };
	end
	while (tSlotsUsed[StringManager.convertPointToString(tOpenSlotPos)]) do
		if nFillFacing == 1 then
			if tOpenSlotPos.y == 0 then
				tOpenSlotPos.y = -1;
			else
				tOpenSlotPos.y = 0;
				tOpenSlotPos.x = tOpenSlotPos.x - 1;
				if tOpenSlotPos.x < -nFillRange then
					return nil;
				end
			end
		elseif nFillFacing == 2 then
			if tOpenSlotPos.x == 0 then
				tOpenSlotPos.x = -1;
			else
				tOpenSlotPos.x = 0;
				tOpenSlotPos.y = tOpenSlotPos.y + 1;
				if tOpenSlotPos.y > nFillRange then
					return nil;
				end
			end
		elseif nFillFacing == 3 then
			if tOpenSlotPos.y == 0 then
				tOpenSlotPos.y = 1;
			else
				tOpenSlotPos.y = 0;
				tOpenSlotPos.x = tOpenSlotPos.x + 1;
				if tOpenSlotPos.x > nFillRange then
					return nil;
				end
			end
		else
			if tOpenSlotPos.x == 0 then
				tOpenSlotPos.x = 1;
			else
				tOpenSlotPos.x = 0;
				tOpenSlotPos.y = tOpenSlotPos.y - 1;
				if tOpenSlotPos.y < -nFillRange then
					return nil;
				end
			end
		end
	end
	return tOpenSlotPos;
end
function getNextOpenColumnx3FillSlot(tSlotPos, tSlotsUsed, nFillFacing, nFillRange)
	if not nFillRange then
		nFillRange = PartyFormationManager.SLOT_RANGE;
	end

	local tOpenSlotPos;
	if tSlotPos then	
		tOpenSlotPos = { x = tSlotPos.x, y = tSlotPos.y };
	else
		tOpenSlotPos = { x = 0, y = 0 };
	end
	while (tSlotsUsed[StringManager.convertPointToString(tOpenSlotPos)]) do
		if nFillFacing == 1 then
			if tOpenSlotPos.y == 0 then
				tOpenSlotPos.y = -1;
			elseif tOpenSlotPos.y == -1 then
				tOpenSlotPos.y = 1;
			else
				tOpenSlotPos.x = tOpenSlotPos.x - 1;
				tOpenSlotPos.y = 0;
				if tOpenSlotPos.x < -nFillRange then
					return nil;
				end
			end
		elseif nFillFacing == 2 then
			if tOpenSlotPos.x == 0 then
				tOpenSlotPos.x = 1;
			elseif tOpenSlotPos.x == 1 then
				tOpenSlotPos.x = -1;
			else
				tOpenSlotPos.x = 0;
				tOpenSlotPos.y = tOpenSlotPos.y + 1;
				if tOpenSlotPos.y > nFillRange then
					return nil;
				end
			end
		elseif nFillFacing == 3 then
			if tOpenSlotPos.y == 0 then
				tOpenSlotPos.y = 1;
			elseif tOpenSlotPos.y == 1 then
				tOpenSlotPos.y = -1;
			else
				tOpenSlotPos.x = tOpenSlotPos.x + 1;
				tOpenSlotPos.y = 0;
				if tOpenSlotPos.x > nFillRange then
					return nil;
				end
			end
		else
			if tOpenSlotPos.x == 0 then
				tOpenSlotPos.x = -1;
			elseif tOpenSlotPos.x == -1 then
				tOpenSlotPos.x = 1;
			else
				tOpenSlotPos.x = 0;
				tOpenSlotPos.y = tOpenSlotPos.y - 1;
				if tOpenSlotPos.y < -nFillRange then
					return nil;
				end
			end
		end
	end
	return tOpenSlotPos;
end

