
--
-- This LUA file contains the code needed for our custom calendar   
--


-- The onInit function is required and tells Fantasy Grounds about the other two functions, and when they should be used.
function onInit()
	-- Register the function to calculate the day of week for the sample calendar.  In the calender mod db.xml, you tell FG which function to use with the <lunardaycalc type="string">DayOfWeekCodeTag</lunardaycalc> tag.
	CalendarManager.registerLunarDayHandler("DayOfWeekCodeTag", calcMyLunarDay); 

	-- Register the function to calculate additional days for a month in a leap year for the sample calendar.  In the calender mod db.xml, you tell FG which function to use with the <periodvarcalc type="string">LeapYearCodeTag</periodvarcalc> tag	
	CalendarManager.registerMonthVarHandler("LeapYearCodeTag", calcMyMonthVar);	
	-- Register the function to change the Day display. In the calendar module db.xml, you tell FG which function to use with the <dayformat></dayformat> tag
	CalendarManager.registerDayDisplayHandler("xtraveller_imperial", TravdisplayImperialDay);

	-- Register the function to change the calendar date format.  This changes how the date appears in the chat when it is output.  In the calendar module db.xml, you tell FG which function to use with the <dateformat></dateformat> tag
	CalendarManager.registerDateDisplayHandler("xtraveller_imperial", TravdisplayImperialDate)

end

-- This function is used to calculate what day of the week any given day is.  The function is passed the variables nYear, nMonth, and nDay from Fantasy Grounds.  The return value of this function is the number of the day of the week, starting at 1.  So the first day of the week is 1, the second day is 2, etc.  If your calendar includes leap years, it is important that you account for those in your calculations. 
--One main purpose of this is so that the first day of the month will be the day of the week after the last day of the previous month.  Or in other words, if Jan 31 is on a Tuesday, then Feb 1 will be on a Wed.  Without this function, the first of each month will always start on the first day of the week.
--By default, Fantasy Grounds starts the calendar with the first day of the first month of year 0, starting on the first day of the week.  So for example, Jan 1, year 0, would be on Sunday.  However, the real Gregorian calendar is much more complicated than that.  See the Gregorian calendar example for more information.
-- The sample code below comes from the Example 3, which is a calendar year of 366 days.  Odd months having 30 days, and even months having 31 days. Further coverage of the logic is included in the example.
--
function calcMyLunarDay(nYear, nMonth, nDay)
	local rYear = nYear * 366;
	local rMonth = nMonth-1;
	local rMonthDays = (rMonth*30)+math.floor(rMonth/2);
	local rDay = (rYear + rMonthDays + nDay)%7;
	if rDay == 0 then
		return 7;
	end
	return rDay
end

--
-- This function is sued to calculate the number of days to add or remove from a month.  The function is passed the variables nYear and nMonth from Fantasy Grounds.  The return value of this function is the number of days to add or remove from a month.  
-- One primary use of this function is to calculate additional days for leap years.  For example, in the gregorian calendar, February typically has 28 days, however, under certain specific circumstances, it will have 29.    
-- The number of days to add can be positive or negative.  For example, if you return a -1 instead, February would have 27 days in a leap year instead of 29.  It is important to make sure that your Day of the Week calculation also reflects this leap year formula.
-- The following example comes from the included Collapse Calendar example. It processes a simple leap year calculation, every 4 years, 1 additional day is added to the 8th month.
--
function calcMyMonthVar(nYear, nMonth)
-- If it is the 8th month.
	if nMonth == 8 then
	-- Get the year
		local nYear = DB.getValue("calendar.current.year", 0);
		-- If the year is evenly divisible by 4 (every 4 years)
		if (nYear % 4) == 0 then
		-- tell FG to add one day to the month
			return 1;
		end
	end
-- otherwise, tell FG to not add any days to the month
	return 0;
end



-- This function is used to change how fantasy grounds displays the dates on the calendar.  In this case, it formats every day as 3 digits.
function TravdisplayImperialDay(nDay)
	return string.format("%03d", nDay);
end

-- This function is used to change how fantasy grounds formats the date ouput when it is output to the chat.  In this case, it formats the year as a 5 digit number, then a dash, then a 3 digit day.  So a date might look like 12345-254
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