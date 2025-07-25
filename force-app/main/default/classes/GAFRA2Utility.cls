public with sharing class GAFRA2Utility {

    // Valid Salesforce Date Literals for SOQL
    private static final Set<String> VALID_DATE_LITERALS = new Set<String>{
        'YESTERDAY', 'TODAY', 'TOMORROW', 'LAST_WEEK', 'THIS_WEEK', 'NEXT_WEEK',
        'LAST_MONTH', 'THIS_MONTH', 'NEXT_MONTH', 'LAST_90_DAYS', 'NEXT_90_DAYS',
        'THIS_QUARTER', 'LAST_QUARTER', 'NEXT_QUARTER', 'THIS_YEAR', 'LAST_YEAR', 'NEXT_YEAR',
        'THIS_FISCAL_QUARTER', 'LAST_FISCAL_QUARTER', 'NEXT_FISCAL_QUARTER',
        'THIS_FISCAL_YEAR', 'LAST_FISCAL_YEAR', 'NEXT_FISCAL_YEAR'
    };

    // Valid Salesforce Date Literals that take an integer parameter (e.g., LAST_N_DAYS:30)
    private static final Set<String> N_UNIT_DATE_LITERALS = new Set<String>{
        'LAST_N_DAYS', 'NEXT_N_DAYS', 'LAST_N_WEEKS', 'NEXT_N_WEEKS', 'LAST_N_MONTHS', 'NEXT_N_MONTHS',
        'LAST_N_QUARTERS', 'NEXT_N_QUARTERS', 'LAST_N_YEARS', 'NEXT_N_YEARS', 'LAST_N_FISCAL_QUARTERS',
        'NEXT_N_FISCAL_QUARTERS', 'LAST_N_FISCAL_YEARS', 'NEXT_N_FISCAL_YEARS'
    };

    /**
     * @description Parses a string input to create a SOQL date filter condition.
     * @param fieldName The API name of the date/datetime field to filter on.
     * @param input The string representing the date filter. Can be a single date (YYYY-MM-DD),
     *              a date range (YYYY-MM-DD:YYYY-MM-DD), or a Salesforce date literal (e.g., TODAY, LAST_N_DAYS:30).
     * @return A valid SOQL WHERE clause string, or null if the input is invalid.
     */
    public static String parseDateFilter(String fieldName, String input) {
        if (String.isBlank(input)) {
            return null;
        }

        String sanitizedInput = input.trim().toUpperCase();

        // Handle date ranges like 2023-10-01:2023-10-31
        if (sanitizedInput.contains(':')) {
            List<String> parts = sanitizedInput.split(':');
            if (parts.size() == 2 && Pattern.matches('\\d{4}-\\d{2}-\\d{2}', parts[0].trim()) && Pattern.matches('\\d{4}-\\d{2}-\\d{2}', parts[1].trim())) {
                return String.format('({0} >= {1}T00:00:00Z AND {0} <= {2}T23:59:59Z)', new List<String>{fieldName, parts[0].trim(), parts[1].trim()});
            }
            // Handle N-unit literals like LAST_N_DAYS:30
            else if (parts.size() == 2 && N_UNIT_DATE_LITERALS.contains(parts[0]) && Pattern.matches('\\d+', parts[1])) {
                 return fieldName + ' = ' + sanitizedInput;
            }
        }
        // Handle single dates like 2023-10-27
        else if (Pattern.matches('\\d{4}-\\d{2}-\\d{2}', sanitizedInput)) {
            return 'DAY_ONLY(' + fieldName + ') = ' + sanitizedInput;
        }
        // Handle simple literals like TODAY, YESTERDAY
        else if (VALID_DATE_LITERALS.contains(sanitizedInput)) {
            return fieldName + ' = ' + sanitizedInput;
        }
        
        // Return null if the format is unrecognized to prevent invalid queries
        return null;
    }
}