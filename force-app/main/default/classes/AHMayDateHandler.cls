public class AHMayDateHandler {
    
    public static Map<String, Object> parseDateCriteria(Map<String, Object> queryData) {
        if (queryData == null) {
            return new Map<String, Object>();
        }
        
        Map<String, Object> processedData = new Map<String, Object>(queryData);
        
        System.debug('AHMayDateHandler - Parsing date criteria from: ' + JSON.serialize(queryData));
        
        // Handle date ranges
        if (queryData.containsKey('Hire_Date__c_RANGE')) {
            Object rangeObj = queryData.get('Hire_Date__c_RANGE');
            System.debug('Found Hire_Date__c_RANGE: ' + JSON.serialize(rangeObj));
            
            if (rangeObj instanceof Map<String, Object>) {
                Map<String, Object> rangeMap = (Map<String, Object>)rangeObj;
                String startStr = (String)rangeMap.get('start');
                String endStr = (String)rangeMap.get('end');
                
                if (startStr != null && endStr != null) {
                    Date startDate = parseDate(startStr);
                    Date endDate = parseDate(endStr);
                    
                    if (startDate != null && endDate != null) {
                        processedData.put('Hire_Date__c_START', startDate);
                        processedData.put('Hire_Date__c_END', endDate);
                        
                        // Debug logging
                        System.debug('Date range detected: ' + startStr + ' to ' + endStr);
                        System.debug('Parsed dates: ' + startDate + ' to ' + endDate);
                    } else {
                        System.debug('ERROR: Failed to parse dates: ' + startStr + ' or ' + endStr);
                    }
                } else {
                    System.debug('ERROR: Missing start or end date in range');
                }
            } else {
                System.debug('ERROR: Hire_Date__c_RANGE is not a valid map');
            }
            // Remove the original range object to avoid double processing
            processedData.remove('Hire_Date__c_RANGE');
        }
        
        // Handle relative dates
        if (queryData.containsKey('Hire_Date__c_RELATIVE')) {
            String relative = (String)queryData.get('Hire_Date__c_RELATIVE');
            System.debug('Found Hire_Date__c_RELATIVE: ' + relative);
            
            Date[] range = getRelativeDateRange(relative);
            
            if (range != null && range.size() == 2) {
                processedData.put('Hire_Date__c_START', range[0]);
                processedData.put('Hire_Date__c_END', range[1]);
                
                // Debug logging
                System.debug('Relative date range: ' + relative);
                System.debug('Parsed to: ' + range[0] + ' to ' + range[1]);
            } else {
                System.debug('ERROR: Failed to calculate relative date range for: ' + relative);
            }
            processedData.remove('Hire_Date__c_RELATIVE');
        }
        
        // Handle date operators
        if (queryData.containsKey('Hire_Date__c_OPERATOR')) {
            Object operatorObj = queryData.get('Hire_Date__c_OPERATOR');
            System.debug('Found Hire_Date__c_OPERATOR: ' + JSON.serialize(operatorObj));
            
            if (operatorObj instanceof Map<String, Object>) {
                Map<String, Object> operatorMap = (Map<String, Object>)operatorObj;
                String operator = (String)operatorMap.get('operator');
                String value = (String)operatorMap.get('value');
                
                if (operator != null && value != null) {
                    Date dateValue = parseDate(value);
                    if (dateValue != null) {
                        processedData.put('Hire_Date__c_OP', operator);
                        processedData.put('Hire_Date__c_VAL', dateValue);
                        
                        // Debug logging
                        System.debug('Date operator detected: ' + operator + ' ' + value);
                        System.debug('Parsed to: ' + operator + ' ' + dateValue);
                    } else {
                        System.debug('ERROR: Failed to parse date value: ' + value);
                    }
                } else {
                    System.debug('ERROR: Missing operator or value in date operator');
                }
            } else {
                System.debug('ERROR: Hire_Date__c_OPERATOR is not a valid map');
            }
            processedData.remove('Hire_Date__c_OPERATOR');
        }
        
        // Handle natural language date specifiers
        if (queryData.containsKey('Hire_Date__c_TEXT')) {
            String dateText = (String)queryData.get('Hire_Date__c_TEXT');
            System.debug('Found Hire_Date__c_TEXT: ' + dateText);
            
            Date[] range = parseNaturalLanguageDate(dateText);
            
            if (range != null && range.size() == 2) {
                processedData.put('Hire_Date__c_START', range[0]);
                processedData.put('Hire_Date__c_END', range[1]);
                
                // Debug logging
                System.debug('Natural language date: "' + dateText + '"');
                System.debug('Parsed to: ' + range[0] + ' to ' + range[1]);
            } else {
                System.debug('ERROR: Failed to parse natural language date: ' + dateText);
            }
            processedData.remove('Hire_Date__c_TEXT');
        }
        
        // Log the processed data
        System.debug('AHMayDateHandler - Date criteria processed to: ' + JSON.serialize(processedData));
        
        return processedData;
    }
    
    public static void addDateConditions(Map<String, Object> queryData, List<String> conditions) {
        // Add verbose debugging
        System.debug('AHMayDateHandler - Adding date conditions from data: ' + JSON.serialize(queryData));
        
        if (queryData == null) {
            System.debug('AHMayDateHandler - No query data provided, skipping date conditions');
            return;
        }
        
        Boolean addedDateCondition = false;
        
        // Handle date ranges
        if (queryData.containsKey('Hire_Date__c_START') && queryData.containsKey('Hire_Date__c_END')) {
            Date startDate = (Date)queryData.get('Hire_Date__c_START');
            Date endDate = (Date)queryData.get('Hire_Date__c_END');
            
            if (startDate != null && endDate != null) {
                // Format dates correctly for SOQL
                String startCondition = 'Hire_Date__c >= ' + formatDateForSOQL(startDate);
                String endCondition = 'Hire_Date__c <= ' + formatDateForSOQL(endDate);
                
                conditions.add(startCondition);
                conditions.add(endCondition);
                addedDateCondition = true;
                
                // Debug the added conditions
                System.debug('AHMayDateHandler - Added date range conditions: ' + 
                           startCondition + ' AND ' + endCondition);
            } else {
                System.debug('AHMayDateHandler - ERROR: Start or end date is null');
            }
        }
        
        // Handle date operators
        if (queryData.containsKey('Hire_Date__c_OP') && queryData.containsKey('Hire_Date__c_VAL')) {
            String operator = (String)queryData.get('Hire_Date__c_OP');
            Date dateValue = (Date)queryData.get('Hire_Date__c_VAL');
            
            if (operator != null && dateValue != null) {
                String operatorCondition = 'Hire_Date__c ' + operator + ' ' + formatDateForSOQL(dateValue);
                conditions.add(operatorCondition);
                addedDateCondition = true;
                
                // Debug the added condition
                System.debug('AHMayDateHandler - Added date operator condition: ' + operatorCondition);
            } else {
                System.debug('AHMayDateHandler - ERROR: Operator or date value is null');
            }
        }
        
        // Debug the final conditions list
        if (addedDateCondition) {
            System.debug('AHMayDateHandler - Final date conditions added: ' + conditions);
        } else {
            System.debug('AHMayDateHandler - No date conditions were added');
        }
    }
    
    // Parse natural language date references
    private static Date[] parseNaturalLanguageDate(String text) {
        if (String.isBlank(text)) {
            return null;
        }
        
        text = text.toLowerCase();
        Date today = Date.today();
        Date[] result = new Date[2];
        
        // Pattern: "in [month] [year]"
        Pattern monthYearPattern = Pattern.compile('in (january|february|march|april|may|june|july|august|september|october|november|december) (\\d{4})');
        Matcher monthYearMatcher = monthYearPattern.matcher(text);
        
        if (monthYearMatcher.find()) {
            String monthName = monthYearMatcher.group(1);
            Integer year = Integer.valueOf(monthYearMatcher.group(2));
            Integer month = getMonthNumber(monthName);
            
            if (month > 0) {
                Date firstOfMonth = Date.newInstance(year, month, 1);
                Date lastOfMonth = getLastDayOfMonth(year, month);
                
                result[0] = firstOfMonth;
                result[1] = lastOfMonth;
                return result;
            }
        }
        
        // Pattern: "in [year]"
        Pattern yearPattern = Pattern.compile('in (\\d{4})');
        Matcher yearMatcher = yearPattern.matcher(text);
        
        if (yearMatcher.find()) {
            Integer year = Integer.valueOf(yearMatcher.group(1));
            result[0] = Date.newInstance(year, 1, 1);
            result[1] = Date.newInstance(year, 12, 31);
            return result;
        }
        
        // Common time phrases
        if (text.contains('last year')) {
            result[0] = Date.newInstance(today.year() - 1, 1, 1);
            result[1] = Date.newInstance(today.year() - 1, 12, 31);
            return result;
        } else if (text.contains('this year')) {
            result[0] = Date.newInstance(today.year(), 1, 1);
            result[1] = Date.newInstance(today.year(), 12, 31);
            return result;
        } else if (text.contains('last month')) {
            Date firstOfThisMonth = today.toStartOfMonth();
            Date firstOfLastMonth = firstOfThisMonth.addMonths(-1);
            Date lastOfLastMonth = firstOfThisMonth.addDays(-1);
            
            result[0] = firstOfLastMonth;
            result[1] = lastOfLastMonth;
            return result;
        } else if (text.contains('this month')) {
            result[0] = today.toStartOfMonth();
            result[1] = today.toStartOfMonth().addMonths(1).addDays(-1);
            return result;
        } else if (text.contains('last quarter')) {
            Integer currentQuarter = ((today.month() - 1) / 3) + 1;
            Integer lastQuarterYear = today.year();
            Integer lastQuarter = currentQuarter - 1;
            
            if (lastQuarter < 1) {
                lastQuarter = 4;
                lastQuarterYear--;
            }
            
            Integer startMonth = ((lastQuarter - 1) * 3) + 1;
            Integer endMonth = startMonth + 2;
            
            result[0] = Date.newInstance(lastQuarterYear, startMonth, 1);
            result[1] = Date.newInstance(lastQuarterYear, endMonth, getLastDayOfMonth(lastQuarterYear, endMonth).day());
            return result;
        } else if (text.contains('this quarter')) {
            Integer currentQuarter = ((today.month() - 1) / 3) + 1;
            Integer startMonth = ((currentQuarter - 1) * 3) + 1;
            Integer endMonth = startMonth + 2;
            
            result[0] = Date.newInstance(today.year(), startMonth, 1);
            result[1] = Date.newInstance(today.year(), endMonth, getLastDayOfMonth(today.year(), endMonth).day());
            return result;
        }
        
        // Could not parse
        return null;
    }
    
    private static Date parseDate(String dateStr) {
        if (String.isBlank(dateStr)) {
            System.debug('AHMayDateHandler - Cannot parse empty date string');
            return null;
        }
        
        try {
            // Try ISO format (YYYY-MM-DD)
            String[] parts = dateStr.split('-');
            if (parts.size() == 3) {
                Integer year = Integer.valueOf(parts[0]);
                Integer month = Integer.valueOf(parts[1]);
                Integer day = Integer.valueOf(parts[2]);
                System.debug('AHMayDateHandler - Parsed ISO date: ' + year + '-' + month + '-' + day);
                return Date.newInstance(year, month, day);
            }
        } catch (Exception e) {
            System.debug('AHMayDateHandler - Error parsing ISO date string: ' + dateStr + ', error: ' + e.getMessage());
        }
        
        try {
            // Try to parse month name and year (e.g., "February 2024")
            String[] parts = dateStr.split(' ');
            if (parts.size() == 2) {
                String monthName = parts[0];
                Integer year = Integer.valueOf(parts[1]);
                Integer month = getMonthNumber(monthName);
                
                if (month > 0) {
                    // First day of month
                    System.debug('AHMayDateHandler - Parsed month name date: ' + year + '-' + month + '-1');
                    return Date.newInstance(year, month, 1);
                }
            }
        } catch (Exception e) {
            System.debug('AHMayDateHandler - Error parsing month name date: ' + dateStr + ', error: ' + e.getMessage());
        }
        
        try {
            // Try to parse "mm/dd/yyyy" format
            String[] parts = dateStr.split('/');
            if (parts.size() == 3) {
                Integer month = Integer.valueOf(parts[0]);
                Integer day = Integer.valueOf(parts[1]);
                Integer year = Integer.valueOf(parts[2]);
                System.debug('AHMayDateHandler - Parsed mm/dd/yyyy date: ' + year + '-' + month + '-' + day);
                return Date.newInstance(year, month, day);
            }
        } catch (Exception e) {
            System.debug('AHMayDateHandler - Error parsing mm/dd/yyyy date: ' + dateStr + ', error: ' + e.getMessage());
        }
        
        System.debug('AHMayDateHandler - Failed to parse date string: ' + dateStr);
        return null;
    }
    
    private static Integer getMonthNumber(String monthName) {
        Map<String, Integer> monthMap = new Map<String, Integer>{
            'january' => 1, 'february' => 2, 'march' => 3, 'april' => 4,
            'may' => 5, 'june' => 6, 'july' => 7, 'august' => 8,
            'september' => 9, 'october' => 10, 'november' => 11, 'december' => 12,
            'jan' => 1, 'feb' => 2, 'mar' => 3, 'apr' => 4,
            'jun' => 6, 'jul' => 7, 'aug' => 8, 'sep' => 9, 'sept' => 9,
            'oct' => 10, 'nov' => 11, 'dec' => 12
        };
        
        return monthMap.containsKey(monthName.toLowerCase()) ? 
               monthMap.get(monthName.toLowerCase()) : 0;
    }
    
    private static Date[] getRelativeDateRange(String relative) {
        Date today = Date.today();
        Date[] result = new Date[2];
        
        if (relative == 'LAST_MONTH') {
            // Calculate first and last day of previous month
            Date firstOfThisMonth = today.toStartOfMonth();
            Date firstOfLastMonth = firstOfThisMonth.addMonths(-1);
            Date lastOfLastMonth = firstOfThisMonth.addDays(-1);
            
            result[0] = firstOfLastMonth;
            result[1] = lastOfLastMonth;
        } else if (relative == 'THIS_MONTH') {
            // Calculate first and last day of current month
            result[0] = today.toStartOfMonth();
            result[1] = today.toStartOfMonth().addMonths(1).addDays(-1);
        } else if (relative == 'LAST_YEAR') {
            // Calculate first and last day of previous year
            result[0] = Date.newInstance(today.year() - 1, 1, 1);
            result[1] = Date.newInstance(today.year() - 1, 12, 31);
        } else if (relative == 'THIS_YEAR') {
            // Calculate first and last day of current year
            result[0] = Date.newInstance(today.year(), 1, 1);
            result[1] = Date.newInstance(today.year(), 12, 31);
        } else if (relative == 'YESTERDAY') {
            // Yesterday
            Date yesterday = today.addDays(-1);
            result[0] = yesterday;
            result[1] = yesterday;
        } else if (relative == 'TODAY') {
            // Today
            result[0] = today;
            result[1] = today;
        } else if (relative == 'LAST_WEEK') {
            // Last week (previous 7 days)
            result[0] = today.addDays(-7);
            result[1] = today.addDays(-1);
        } else if (relative == 'THIS_WEEK') {
            // Calculate first and last day of current week (Sunday to Saturday)
            Integer dayOfWeek = Math.mod(today.daysBetween(Date.newInstance(1900, 1, 7)), 7);
            result[0] = today.addDays(-dayOfWeek); // Sunday
            result[1] = result[0].addDays(6); // Saturday
        } else if (relative == 'NEXT_MONTH') {
            // Next month
            Date firstOfNextMonth = today.toStartOfMonth().addMonths(1);
            Date lastOfNextMonth = firstOfNextMonth.addMonths(1).addDays(-1);
            result[0] = firstOfNextMonth;
            result[1] = lastOfNextMonth;
        } else if (relative == 'NEXT_WEEK') {
            // Calculate first and last day of next week
            Integer dayOfWeek = Math.mod(today.daysBetween(Date.newInstance(1900, 1, 7)), 7);
            Date thisSunday = today.addDays(-dayOfWeek);
            Date nextSunday = thisSunday.addDays(7);
            result[0] = nextSunday;
            result[1] = nextSunday.addDays(6); // Next Saturday
        } else if (relative == 'NEXT_YEAR') {
            // Next year
            result[0] = Date.newInstance(today.year() + 1, 1, 1);
            result[1] = Date.newInstance(today.year() + 1, 12, 31);
        } else if (relative == 'LAST_QUARTER') {
            // Calculate last quarter
            Integer currMonth = today.month();
            Integer currQuarter = ((currMonth - 1) / 3) + 1;
            Integer lastQuarter = currQuarter - 1;
            Integer yearOffset = 0;
            
            if (lastQuarter < 1) {
                lastQuarter = 4;
                yearOffset = -1;
            }
            
            Integer startMonth = ((lastQuarter - 1) * 3) + 1;
            Integer endMonth = startMonth + 2;
            
            result[0] = Date.newInstance(today.year() + yearOffset, startMonth, 1);
            result[1] = Date.newInstance(today.year() + yearOffset, endMonth, 
                                       getLastDayOfMonth(today.year() + yearOffset, endMonth).day());
        } else if (relative == 'THIS_QUARTER') {
            // Calculate current quarter
            Integer currMonth = today.month();
            Integer currQuarter = ((currMonth - 1) / 3) + 1;
            Integer startMonth = ((currQuarter - 1) * 3) + 1;
            Integer endMonth = startMonth + 2;
            
            result[0] = Date.newInstance(today.year(), startMonth, 1);
            result[1] = Date.newInstance(today.year(), endMonth, 
                                       getLastDayOfMonth(today.year(), endMonth).day());
        } else if (relative == 'NEXT_QUARTER') {
            // Calculate next quarter
            Integer currMonth = today.month();
            Integer currQuarter = ((currMonth - 1) / 3) + 1;
            Integer nextQuarter = currQuarter + 1;
            Integer yearOffset = 0;
            
            if (nextQuarter > 4) {
                nextQuarter = 1;
                yearOffset = 1;
            }
            
            Integer startMonth = ((nextQuarter - 1) * 3) + 1;
            Integer endMonth = startMonth + 2;
            
            result[0] = Date.newInstance(today.year() + yearOffset, startMonth, 1);
            result[1] = Date.newInstance(today.year() + yearOffset, endMonth, 
                                       getLastDayOfMonth(today.year() + yearOffset, endMonth).day());
        } else {
            // Default to this month if unknown relative value
            result[0] = today.toStartOfMonth();
            result[1] = today.toStartOfMonth().addMonths(1).addDays(-1);
        }
        
        return result;
    }
    
    // Format date for SOQL query
    public static String formatDateForSOQL(Date dateValue) {
        if (dateValue == null) {
            return 'null';
        }
        
        // Format as YYYY-MM-DD for SOQL date literal
        String formattedDate = dateValue.year() + '-' + 
               String.valueOf(dateValue.month()).leftPad(2, '0') + '-' + 
               String.valueOf(dateValue.day()).leftPad(2, '0');
               
        return formattedDate;
    }
    
    // Get the last day of a month
    public static Date getLastDayOfMonth(Integer year, Integer month) {
        // Determine the last day based on month and leap year
        if (month == 2) {
            // Check for leap year
            Boolean isLeapYear = (Math.mod(year, 4) == 0) && 
                               (Math.mod(year, 100) != 0 || Math.mod(year, 400) == 0);
            return Date.newInstance(year, month, isLeapYear ? 29 : 28);
        } else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return Date.newInstance(year, month, 30);
        } else {
            return Date.newInstance(year, month, 31);
        }
    }
    
    // Method to get the month name from a date
    public static String getMonthName(Date d) {
        List<String> months = new List<String>{
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
        };
        
        return months[d.month() - 1];
    }
}