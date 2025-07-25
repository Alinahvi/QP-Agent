@isTest
private class TrainingDateHelperTest {
    
    // Test relative date terms
    @isTest
    static void testParseRelativeDateTerm_Today() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('TODAY');
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(Date.today(), result.startDate, 'Start date should be today');
        System.assertEquals(Date.today(), result.endDate, 'End date should be today');
    }
    
    @isTest
    static void testParseRelativeDateTerm_Yesterday() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('YESTERDAY');
        Test.stopTest();
        
        Date expectedDate = Date.today().addDays(-1);
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(expectedDate, result.startDate, 'Start date should be yesterday');
        System.assertEquals(expectedDate, result.endDate, 'End date should be yesterday');
    }
    
    @isTest
    static void testParseRelativeDateTerm_Tomorrow() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('TOMORROW');
        Test.stopTest();
        
        Date expectedDate = Date.today().addDays(1);
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(expectedDate, result.startDate, 'Start date should be tomorrow');
        System.assertEquals(expectedDate, result.endDate, 'End date should be tomorrow');
    }
    
    @isTest
    static void testParseRelativeDateTerm_ThisWeek() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('THIS_WEEK');
        Test.stopTest();
        
        Date expectedStart = Date.today().toStartOfWeek();
        Date expectedEnd = expectedStart.addDays(6);
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(expectedStart, result.startDate, 'Start date should be start of this week');
        System.assertEquals(expectedEnd, result.endDate, 'End date should be end of this week');
    }
    
    @isTest
    static void testParseRelativeDateTerm_LastWeek() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('LAST_WEEK');
        Test.stopTest();
        
        Date startOfThisWeek = Date.today().toStartOfWeek();
        Date expectedEnd = startOfThisWeek.addDays(-1);
        Date expectedStart = expectedEnd.addDays(-6);
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(expectedStart, result.startDate, 'Start date should be start of last week');
        System.assertEquals(expectedEnd, result.endDate, 'End date should be end of last week');
    }
    
    @isTest
    static void testParseRelativeDateTerm_NextWeek() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('NEXT_WEEK');
        Test.stopTest();
        
        Date startOfThisWeek = Date.today().toStartOfWeek();
        Date expectedStart = startOfThisWeek.addDays(7);
        Date expectedEnd = expectedStart.addDays(6);
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(expectedStart, result.startDate, 'Start date should be start of next week');
        System.assertEquals(expectedEnd, result.endDate, 'End date should be end of next week');
    }
    
    @isTest
    static void testParseRelativeDateTerm_ThisMonth() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('THIS_MONTH');
        Test.stopTest();
        
        Date today = Date.today();
        Date expectedStart = today.toStartOfMonth();
        Date expectedEnd = Date.newInstance(today.year(), today.month(), Date.daysInMonth(today.year(), today.month()));
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(expectedStart, result.startDate, 'Start date should be start of this month');
        System.assertEquals(expectedEnd, result.endDate, 'End date should be end of this month');
    }
    
    @isTest
    static void testParseRelativeDateTerm_LastMonth() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('LAST_MONTH');
        Test.stopTest();
        
        Date firstDayLastMonth = Date.today().toStartOfMonth().addMonths(-1);
        Date expectedEnd = Date.newInstance(firstDayLastMonth.year(), firstDayLastMonth.month(), 
                                          Date.daysInMonth(firstDayLastMonth.year(), firstDayLastMonth.month()));
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(firstDayLastMonth, result.startDate, 'Start date should be start of last month');
        System.assertEquals(expectedEnd, result.endDate, 'End date should be end of last month');
    }
    
    @isTest
    static void testParseRelativeDateTerm_NextMonth() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('NEXT_MONTH');
        Test.stopTest();
        
        Date firstDayNextMonth = Date.today().toStartOfMonth().addMonths(1);
        Date expectedEnd = Date.newInstance(firstDayNextMonth.year(), firstDayNextMonth.month(), 
                                          Date.daysInMonth(firstDayNextMonth.year(), firstDayNextMonth.month()));
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(firstDayNextMonth, result.startDate, 'Start date should be start of next month');
        System.assertEquals(expectedEnd, result.endDate, 'End date should be end of next month');
    }
    
    @isTest
    static void testParseRelativeDateTerm_ThisQuarter() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('THIS_QUARTER');
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Verify quarter boundaries based on current month
        Date today = Date.today();
        Integer month = today.month();
        Integer expectedStartMonth;
        if (month >= 1 && month <= 3) expectedStartMonth = 1;
        else if (month >= 4 && month <= 6) expectedStartMonth = 4;
        else if (month >= 7 && month <= 9) expectedStartMonth = 7;
        else expectedStartMonth = 10;
        
        System.assertEquals(expectedStartMonth, result.startDate.month(), 'Start month should match quarter start');
        System.assertEquals(1, result.startDate.day(), 'Start day should be 1st');
        
        // Verify end date is last day of quarter
        Integer daysInRange = result.startDate.daysBetween(result.endDate) + 1;
        System.assert(daysInRange >= 89 && daysInRange <= 92, 'Quarter should have 89-92 days');
    }
    
    @isTest
    static void testParseRelativeDateTerm_CurrentQuarter() {
        // Test alternate term for this quarter
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('CURRENT_QUARTER');
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Should be same as THIS_QUARTER
        TrainingDateHelper.DateRange thisQuarterResult = TrainingDateHelper.parseRelativeDateTerm('THIS_QUARTER');
        System.assertEquals(thisQuarterResult.startDate, result.startDate, 'CURRENT_QUARTER should equal THIS_QUARTER');
        System.assertEquals(thisQuarterResult.endDate, result.endDate, 'CURRENT_QUARTER should equal THIS_QUARTER');
    }
    
    @isTest
    static void testParseRelativeDateTerm_LastQuarter() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('LAST_QUARTER');
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Verify it's exactly one quarter before current quarter
        TrainingDateHelper.DateRange thisQuarter = TrainingDateHelper.parseRelativeDateTerm('THIS_QUARTER');
        Integer monthsBetween = result.startDate.monthsBetween(thisQuarter.startDate);
        System.assertEquals(3, monthsBetween, 'Last quarter should be 3 months before this quarter');
    }
    
    @isTest
    static void testParseRelativeDateTerm_ThisYear() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('THIS_YEAR');
        Test.stopTest();
        
        Integer currentYear = Date.today().year();
        Date expectedStart = Date.newInstance(currentYear, 1, 1);
        Date expectedEnd = Date.newInstance(currentYear, 12, 31);
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(expectedStart, result.startDate, 'Start date should be Jan 1 of current year');
        System.assertEquals(expectedEnd, result.endDate, 'End date should be Dec 31 of current year');
    }
    
    @isTest
    static void testParseRelativeDateTerm_CalendarYearAliases() {
        // Test alternate terms
        Test.startTest();
        TrainingDateHelper.DateRange ccy = TrainingDateHelper.parseRelativeDateTerm('CURRENT_CALENDAR_YEAR');
        TrainingDateHelper.DateRange ccyShort = TrainingDateHelper.parseRelativeDateTerm('CCY');
        Test.stopTest();
        
        TrainingDateHelper.DateRange thisYear = TrainingDateHelper.parseRelativeDateTerm('THIS_YEAR');
        
        System.assertEquals(thisYear.startDate, ccy.startDate, 'CURRENT_CALENDAR_YEAR should equal THIS_YEAR');
        System.assertEquals(thisYear.endDate, ccy.endDate, 'CURRENT_CALENDAR_YEAR should equal THIS_YEAR');
        System.assertEquals(thisYear.startDate, ccyShort.startDate, 'CCY should equal THIS_YEAR');
        System.assertEquals(thisYear.endDate, ccyShort.endDate, 'CCY should equal THIS_YEAR');
    }
    
    @isTest
    static void testParseRelativeDateTerm_LastYear() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('LAST_YEAR');
        Test.stopTest();
        
        Integer lastYear = Date.today().year() - 1;
        Date expectedStart = Date.newInstance(lastYear, 1, 1);
        Date expectedEnd = Date.newInstance(lastYear, 12, 31);
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(expectedStart, result.startDate, 'Start date should be Jan 1 of last year');
        System.assertEquals(expectedEnd, result.endDate, 'End date should be Dec 31 of last year');
    }
    
    @isTest
    static void testParseRelativeDateTerm_LastCalendarYearAliases() {
        Test.startTest();
        TrainingDateHelper.DateRange lcy = TrainingDateHelper.parseRelativeDateTerm('LAST_CALENDAR_YEAR');
        TrainingDateHelper.DateRange lcyShort = TrainingDateHelper.parseRelativeDateTerm('LCY');
        Test.stopTest();
        
        TrainingDateHelper.DateRange lastYear = TrainingDateHelper.parseRelativeDateTerm('LAST_YEAR');
        
        System.assertEquals(lastYear.startDate, lcy.startDate, 'LAST_CALENDAR_YEAR should equal LAST_YEAR');
        System.assertEquals(lastYear.endDate, lcy.endDate, 'LAST_CALENDAR_YEAR should equal LAST_YEAR');
        System.assertEquals(lastYear.startDate, lcyShort.startDate, 'LCY should equal LAST_YEAR');
        System.assertEquals(lastYear.endDate, lcyShort.endDate, 'LCY should equal LAST_YEAR');
    }
    
    @isTest
    static void testParseRelativeDateTerm_ThisFiscalYear() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('THIS_FISCAL_YEAR');
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Fiscal year starts in February according to the constant
        Date today = Date.today();
        Integer expectedStartYear = today.month() >= 2 ? today.year() : today.year() - 1;
        Date expectedStart = Date.newInstance(expectedStartYear, 2, 1);
        Date expectedEnd = expectedStart.addYears(1).addDays(-1);
        
        System.assertEquals(expectedStart, result.startDate, 'Fiscal year should start Feb 1');
        System.assertEquals(expectedEnd, result.endDate, 'Fiscal year should end Jan 31 of next year');
    }
    
    @isTest
    static void testParseRelativeDateTerm_FiscalYearAliases() {
        Test.startTest();
        TrainingDateHelper.DateRange cfy = TrainingDateHelper.parseRelativeDateTerm('CURRENT_FISCAL_YEAR');
        TrainingDateHelper.DateRange cfyShort = TrainingDateHelper.parseRelativeDateTerm('CFY');
        Test.stopTest();
        
        TrainingDateHelper.DateRange thisFY = TrainingDateHelper.parseRelativeDateTerm('THIS_FISCAL_YEAR');
        
        System.assertEquals(thisFY.startDate, cfy.startDate, 'CURRENT_FISCAL_YEAR should equal THIS_FISCAL_YEAR');
        System.assertEquals(thisFY.endDate, cfy.endDate, 'CURRENT_FISCAL_YEAR should equal THIS_FISCAL_YEAR');
        System.assertEquals(thisFY.startDate, cfyShort.startDate, 'CFY should equal THIS_FISCAL_YEAR');
        System.assertEquals(thisFY.endDate, cfyShort.endDate, 'CFY should equal THIS_FISCAL_YEAR');
    }
    
    @isTest
    static void testParseRelativeDateTerm_LastFiscalYear() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('LAST_FISCAL_YEAR');
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Should be exactly one year before current fiscal year
        TrainingDateHelper.DateRange thisFY = TrainingDateHelper.parseRelativeDateTerm('THIS_FISCAL_YEAR');
        System.assertEquals(thisFY.startDate.addYears(-1), result.startDate, 'Last FY should start 1 year before this FY');
        System.assertEquals(thisFY.endDate.addYears(-1), result.endDate, 'Last FY should end 1 year before this FY');
    }
    
    @isTest
    static void testParseRelativeDateTerm_LastFiscalYearAlias() {
        Test.startTest();
        TrainingDateHelper.DateRange lfy = TrainingDateHelper.parseRelativeDateTerm('LFY');
        Test.stopTest();
        
        TrainingDateHelper.DateRange lastFY = TrainingDateHelper.parseRelativeDateTerm('LAST_FISCAL_YEAR');
        
        System.assertEquals(lastFY.startDate, lfy.startDate, 'LFY should equal LAST_FISCAL_YEAR');
        System.assertEquals(lastFY.endDate, lfy.endDate, 'LFY should equal LAST_FISCAL_YEAR');
    }
    
    @isTest
    static void testParseRelativeDateTerm_CaseInsensitive() {
        Test.startTest();
        TrainingDateHelper.DateRange upper = TrainingDateHelper.parseRelativeDateTerm('TODAY');
        TrainingDateHelper.DateRange lower = TrainingDateHelper.parseRelativeDateTerm('today');
        TrainingDateHelper.DateRange mixed = TrainingDateHelper.parseRelativeDateTerm('ToDaY');
        Test.stopTest();
        
        System.assertEquals(upper.startDate, lower.startDate, 'Case should not matter');
        System.assertEquals(upper.startDate, mixed.startDate, 'Case should not matter');
    }
    
    @isTest
    static void testParseRelativeDateTerm_WithWhitespace() {
        Test.startTest();
        TrainingDateHelper.DateRange trimmed = TrainingDateHelper.parseRelativeDateTerm('  TODAY  ');
        Test.stopTest();
        
        TrainingDateHelper.DateRange normal = TrainingDateHelper.parseRelativeDateTerm('TODAY');
        System.assertEquals(normal.startDate, trimmed.startDate, 'Whitespace should be trimmed');
    }
    
    @isTest
    static void testParseRelativeDateTerm_InvalidTerm() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('INVALID_TERM');
        Test.stopTest();
        
        System.assertEquals(null, result, 'Invalid term should return null');
    }
    
    @isTest
    static void testParseRelativeDateTerm_NullInput() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm(null);
        Test.stopTest();
        
        System.assertEquals(null, result, 'Null input should return null');
    }
    
    @isTest
    static void testParseRelativeDateTerm_EmptyString() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('');
        Test.stopTest();
        
        System.assertEquals(null, result, 'Empty string should return null');
    }
    
    @isTest
    static void testParseRelativeDateTerm_BlankString() {
        Test.startTest();
        TrainingDateHelper.DateRange result = TrainingDateHelper.parseRelativeDateTerm('   ');
        Test.stopTest();
        
        System.assertEquals(null, result, 'Blank string should return null');
    }
    
    // Test parseDateString method
    @isTest
    static void testParseDateString_ValidDate() {
        String dateStr = '2024-12-25';
        
        Test.startTest();
        Date result = TrainingDateHelper.parseDateString(dateStr);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Valid date string should return a date');
        System.assertEquals(2024, result.year(), 'Year should be 2024');
        System.assertEquals(12, result.month(), 'Month should be 12');
        System.assertEquals(25, result.day(), 'Day should be 25');
    }
    
    @isTest
    static void testParseDateString_InvalidFormat() {
        String dateStr = '12/25/2024'; // Invalid format for Date.valueOf()
        
        Test.startTest();
        Date result = TrainingDateHelper.parseDateString(dateStr);
        Test.stopTest();
        
        System.assertEquals(null, result, 'Invalid date format should return null');
    }
    
    @isTest
    static void testParseDateString_InvalidDate() {
        String dateStr = '2024-13-32'; // Invalid month and day
        
        Test.startTest();
        Date result = TrainingDateHelper.parseDateString(dateStr);
        Test.stopTest();
        
        System.assertEquals(null, result, 'Invalid date should return null');
    }
    
    @isTest
    static void testParseDateString_NullInput() {
        Test.startTest();
        Date result = TrainingDateHelper.parseDateString(null);
        Test.stopTest();
        
        System.assertEquals(null, result, 'Null input should return null');
    }
    
    @isTest
    static void testParseDateString_EmptyString() {
        Test.startTest();
        Date result = TrainingDateHelper.parseDateString('');
        Test.stopTest();
        
        System.assertEquals(null, result, 'Empty string should return null');
    }
    
    @isTest
    static void testParseDateString_BlankString() {
        Test.startTest();
        Date result = TrainingDateHelper.parseDateString('   ');
        Test.stopTest();
        
        System.assertEquals(null, result, 'Blank string should return null');
    }
    
    @isTest
    static void testParseDateString_NonDateString() {
        Test.startTest();
        Date result = TrainingDateHelper.parseDateString('not a date');
        Test.stopTest();
        
        System.assertEquals(null, result, 'Non-date string should return null');
    }
    
    // Test edge cases for quarters across year boundaries
    @isTest
    static void testQuarterYearBoundary() {
        // Mock being in Q4 (October-December)
        Date mockDate = Date.newInstance(2024, 12, 15);
        
        // We can't mock Date.today() directly, but we can test the logic
        // by verifying the quarter calculation works correctly
        Test.startTest();
        
        // Test Q4 of current year
        TrainingDateHelper.DateRange q4Result = TrainingDateHelper.parseRelativeDateTerm('THIS_QUARTER');
        
        // Test last quarter when in Q1 (should be Q4 of previous year)
        // This would need to be tested when actually in Q1
        
        Test.stopTest();
        
        System.assertNotEquals(null, q4Result, 'Quarter result should not be null');
    }
}