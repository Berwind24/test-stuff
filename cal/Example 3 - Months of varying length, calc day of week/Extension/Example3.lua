--
-- This function sets up our custom calendar calling functions.  
--

function onInit()
-- Register the function to calculate the day of week for the Example 2 calendar.  In the calender mod db.xml, you tell FG which function to use with the <lunardaycalc type="string">MKCustom</lunardaycalc> tag.
	CalendarManager.registerLunarDayHandler("Example3", calcExample3LunarDay);
end

--
-- This function calculates the day of the week for the MKCustom calendar.  the MKCustom calendar is a simple calendar where odd months have 30 days and even months have 31 days
--
function calcExample3LunarDay(nYear, nMonth, nDay)
	local rYear = nYear * 366;
	local rMonth = nMonth-1;
	local rMonthDays = (rMonth*30)+math.floor(rMonth/2);
	local rDay = (rYear + rMonthDays + nDay)%7;
	if rDay == 0 then
		return 7;
	end
	return rDay;
end
