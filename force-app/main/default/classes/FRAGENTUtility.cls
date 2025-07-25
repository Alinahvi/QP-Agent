/**
 * @description Utility class for the Field Readiness Agent. This class provides shared, reusable
 * methods for common operations such as secure dynamic query building, date parsing,
 * and data serialization. It is the central library for safe data handling.
 * @version 2.4
 */
public with sharing class FRAGENTUtility {

    // A secure list of valid Salesforce Date Literals for SOQL WHERE clauses.
    private static final Set<String> VALID_DATE_LITERALS = new Set<String>{
        'YESTERDAY', 'TODAY', 'TOMORROW', 'LAST_WEEK', 'THIS_WEEK', 'NEXT_WEEK',
        'LAST_MONTH', 'THIS_MONTH', 'NEXT_MONTH', 'LAST_90_DAYS', 'NEXT_90_DAYS',
        'THIS_QUARTER', 'LAST_QUARTER', 'NEXT_QUARTER', 'THIS_YEAR', 'LAST_YEAR', 'NEXT_YEAR',
        'THIS_FISCAL_QUARTER', 'LAST_FISCAL_QUARTER', 'NEXT_FISCAL_QUARTER',
        'THIS_FISCAL_YEAR', 'LAST_FISCAL_YEAR', 'NEXT_FISCAL_YEAR'
    };

    // A secure list of valid Salesforce Date Literals that take an integer parameter (e.g., LAST_N_DAYS:30).
    private static final Set<String> N_UNIT_DATE_LITERALS = new Set<String>{
        'LAST_N_DAYS', 'NEXT_N_DAYS', 'LAST_N_WEEKS', 'NEXT_N_WEEKS', 'LAST_N_MONTHS', 'NEXT_N_MONTHS',
        'LAST_N_QUARTERS', 'NEXT_N_QUARTERS', 'LAST_N_YEARS', 'NEXT_N_YEARS', 'LAST_N_FISCAL_QUARTERS',
        'NEXT_N_FISCAL_QUARTERS', 'LAST_N_FISCAL_YEARS', 'NEXT_N_FISCAL_YEARS'
    };

    /**
     * @description A custom exception class for agent-specific errors.
     */
    public class FRAGENTException extends Exception {}

    /**
     * @description Parses a date filter string for a SOQL query, ensuring the literal is a valid and safe Salesforce date literal.
     * @param field The API name of the date/datetime field to filter (e.g., 'CreatedDate').
     * @param literal The SOQL date literal string (e.g., 'LAST_90_DAYS').
     * @return A formatted and safe SOQL WHERE clause component (e.g., "CreatedDate = LAST_90_DAYS").
     * @throws FRAGENTException if the literal is not a valid date literal.
     */
    public static String parseDateFilter(String field, String literal) {
        if (String.isBlank(field) || String.isBlank(literal)) {
            return '';
        }

        String upperLiteral = literal.toUpperCase();
        Boolean isValid = false;

        if (upperLiteral.contains(':')) {
            List<String> parts = upperLiteral.split(':');
            if (parts.size() == 2 && N_UNIT_DATE_LITERALS.contains(parts[0]) && parts[1].isNumeric()) {
                isValid = true;
            }
        } else {
            if (VALID_DATE_LITERALS.contains(upperLiteral)) {
                isValid = true;
            }
        }

        if (!isValid) {
            throw new FRAGENTException('Invalid or unsafe date literal provided: ' + literal);
        }

        return String.escapeSingleQuotes(field.trim()) + ' = ' + literal;
    }

    /**
     * @description Builds a date range clause for a SOQL WHERE condition using bind variable placeholders.
     * @param fieldName The API name of the date/datetime field to filter on.
     * @param startDate The start date of the range (inclusive). Can be null.
     * @param endDate The end date of the range (inclusive). Can be null.
     * @return A formatted SOQL clause string (e.g., "CreatedDate >= :startDate AND CreatedDate <= :endDate").
     */
    public static String buildDateRangeClause(String fieldName, Date startDate, Date endDate) {
        if (String.isBlank(fieldName) || (startDate == null && endDate == null)) {
            return '';
        }

        List<String> clauses = new List<String>();
        String sanitizedField = String.escapeSingleQuotes(fieldName.trim());

        // FIX: Return placeholders for bind variables instead of concatenated values.
        // This is the correct, safe way to handle dynamic dates.
        if (startDate != null) {
            clauses.add(sanitizedField + ' >= :startDate');
        }
        if (endDate != null) {
            clauses.add(sanitizedField + ' <= :endDate');
        }
        
        return String.join(clauses, ' AND ');
    }

    /**
     * @description Builds a safe SOQL query string by validating the object and fields against the schema.
     */
    public static String buildSafeQuery(String objectApi, List<String> fieldList) {
        if (String.isBlank(objectApi) || fieldList == null || fieldList.isEmpty()) {
            throw new FRAGENTException('Object API Name and Field List cannot be empty.');
        }

        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApi);
        if (sObjectType == null) throw new FRAGENTException('Invalid SObject type: ' + objectApi);
        
        Schema.DescribeSObjectResult sObjectDescribe = sObjectType.getDescribe();
        if (!sObjectDescribe.isQueryable()) throw new FRAGENTException('Object is not queryable: ' + objectApi);

        Map<String, Schema.SObjectField> fieldMap = sObjectDescribe.fields.getMap();
        List<String> validatedFields = new List<String>();

        for (String fieldName : fieldList) {
            String sanitizedField = String.escapeSingleQuotes(fieldName.trim());
            if (!fieldMap.containsKey(sanitizedField)) throw new FRAGENTException('Invalid field: ' + sanitizedField + ' for object: ' + objectApi);
            
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(sanitizedField).getDescribe();
            if (!fieldDescribe.isAccessible()) throw new FRAGENTException('Field is not accessible: ' + sanitizedField);
            
            validatedFields.add(fieldDescribe.getName());
        }

        return 'SELECT ' + String.join(validatedFields, ', ') + ' FROM ' + sObjectDescribe.getName();
    }

    /**
     * @description Serializes a list of SObject records into a comma-separated values (CSV) string.
     */
    public static String serializeToCsv(List<SObject> records, List<String> fieldNames) {
        if (records == null || records.isEmpty() || fieldNames == null || fieldNames.isEmpty()) {
            return '';
        }
        
        List<String> csvLines = new List<String>();
        csvLines.add(String.join(fieldNames, ','));
        
        for (SObject record : records) {
            List<String> rowValues = new List<String>();
            for (String fieldName : fieldNames) {
                Object value = record.get(fieldName);
                String stringValue = (value != null) ? String.valueOf(value) : '';
                if (stringValue.contains(',') || stringValue.contains('"') || stringValue.contains('\n')) {
                    stringValue = '"' + stringValue.replace('"', '""') + '"';
                }
                rowValues.add(stringValue);
            }
            csvLines.add(String.join(rowValues, ','));
        }
        
        return String.join(csvLines, '\n');
    }
}