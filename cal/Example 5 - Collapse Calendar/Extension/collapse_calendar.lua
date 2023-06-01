-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	CalendarManager.registerLunarDayHandler("collapse", calcCollapseLunarDay);
	CalendarManager.registerMonthVarHandler("collapse", calcCollapseMonthVar);
end

function calcCollapseLunarDay(nYear, nMonth, nDay)
	local nZYear = nYear - 1;
	local nZYearDays = nZYear * 365 + math.floor(nZYear / 4);
	local rDay = nDay + (nMonth-1)*30;
	if nMonth > 4 then
		rDay = rDay - 29;
	end
	if nMonth > 8 then
		rDay = rDay - 27;
		if (nYear % 4) == 0 then
			rDay = rDay + 1;
		end
	end
	rDay = (nZYearDays + rDay) % 7;
	if rDay == 0 then
		return 7;
	end
	return rDay;
end

function calcCollapseMonthVar(nYear, nMonth)
	if nMonth == 8 then
		local nYear = DB.getValue("calendar.current.year", 0);
		if (nYear % 4) == 0 then
			return 1;
		end
	end

	return 0;
end

