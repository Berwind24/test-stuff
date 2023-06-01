function onInit()
	CalendarManager.registerDayDisplayHandler("xtraveller_imperial", TravdisplayImperialDay);
	CalendarManager.registerDateDisplayHandler("xtraveller_imperial", TravdisplayImperialDate)
end

function TravdisplayImperialDay(nDay)
	return string.format("%03d", nDay);
end
function TravdisplayImperialDate(sEpoch, nYear, nMonth, nDay, bAddWeekDay, bShortOutput)
	local sDay = TravdisplayImperialDay(nDay);
	
	local sOutput;
	if bShortOutput or (nYear == 0) then
		sOutput = sDay;
	else
		sOutput = string.format("%05d", nYear) .. "-" .. sDay;
	end
	return sOutput
end