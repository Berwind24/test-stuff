function onInit()
    CalendarManager.registerLunarDayHandler("EldorianCalc", calcEldorianLunarDay);
    CalendarManager.registerMonthVarHandler("EldorianCalc", calcEldorianMonthVar);
end

function calcEldorianLunarDay(nYear, nMonth, nDay)
    local rYear = nYear * 369; -- 369 is the total number of days in a year
    local rMonth = nMonth-1;
    local rMonthDays = (rMonth*30)+math.floor(rMonth/2);
    local rDay = (rYear + rMonthDays + nDay)%10; -- 10 is the number of days in a week
    if rDay == 0 then
        return 10;
    end
    return rDay
end

function calcEldorianMonthVar(nYear, nMonth)
    if nMonth == 10 then -- 10th month is Midwinter Festival
        if (nYear % 2) == 0 then
            if (nYear % 10) ~= 0 or (nYear % 50) == 0 then
                return 1;
            end
        end
    end
    return 0;
end
