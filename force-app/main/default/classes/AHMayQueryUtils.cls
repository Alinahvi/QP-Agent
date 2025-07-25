public class AHMayQueryUtils {
    
    // Define query types and their associated keys
    private static final Map<String, Set<String>> QUERY_TYPE_KEYS = new Map<String, Set<String>>{
        'HIERARCHY' => new Set<String>{'HIERARCHICAL_QUERY', 'HIERARCHICAL_QUERY_OR'},
        'DIRECT_REPORTS' => new Set<String>{'DIRECT_REPORTS', 'DIRECT_REPORTS_OR'},
        'METADATA' => new Set<String>{'METADATA_REQUEST', 'FIELD_NAME'},
        'EMPLOYEE_DETAILS' => new Set<String>{'EMPLOYEE_DETAILS', 'EMPLOYEE_NAME'},
        'AGGREGATION' => new Set<String>{'AGGREGATION', 'GROUP_BY_FIELD', 'GROUP_BY_FIELDS', 
                                       'GROUP_BY_DATE_UNIT', 'ANALYSIS'},
        'CONTEXT' => new Set<String>{'MAINTAIN_PREVIOUS_CONTEXT', 'NEXT_PAGE', 'REFINE_PREVIOUS', 
                                   'ORIGINAL_QUERY'},  // Make sure ORIGINAL_QUERY is here
        'SUPPORTED' => new Set<String>{'UNSUPPORTED_QUERY', 'QUERY_ATTRIBUTE'}
    };
    
    // Define field types
    private static final Set<String> DATE_FIELD_PREFIXES = new Set<String>{
        'Hire_Date__c_', 'Start_Date__c_', 'End_Date__c_', 'Created_Date__c_'
    };
    
    // Define system fields that shouldn't be treated as filters
    private static final Set<String> SYSTEM_FIELDS = new Set<String>{
        'Status__c'  // Status__c is added by default, not a user filter
    };
    
    // Add special keys that should never be treated as fields
    private static final Set<String> SPECIAL_KEYS = new Set<String>{
        'ORIGINAL_QUERY',
        'MAINTAIN_PREVIOUS_CONTEXT',
        'NEXT_PAGE',
        'REFINE_PREVIOUS'
    };
    
    // Add field redirects for non-filterable fields
    private static final Map<String, String> FIELD_REDIRECTS = new Map<String, String>{
        'Employee_Location__c' => 'Physical_Location__c',  // Redirect long text area to filterable field
        'Employee_Location__c_LIKE' => 'Physical_Location__c_LIKE'  // Add LIKE variant redirect
    };
    
    // Location fields that should use LIKE for better matching
    private static final Set<String> LOCATION_FIELDS = new Set<String>{
        'Physical_Location__c',
        'Work_Location_Country__c'
    };
    
    // Add known non-filterable fields
    private static final Set<String> NON_FILTERABLE_FIELDS = new Set<String>{
        'Employee_Location__c'  // Long Text Area fields can't be filtered in SOQL
    };
    
    // Add field mapping for slack-related terms
    public static final Map<String, String> FIELD_MAPPINGS = new Map<String, String>{
        'slack' => 'SlackId__c',
        'slack id' => 'SlackId__c',
        'slack_id' => 'SlackId__c',
        'direct message' => 'SlackId__c'
    };
    
    /**
     * Improved method to extract query fields that handles all types of conditions
     * @param queryData The raw query data from the prompt parser
     * @return Map of fields that should be used as filters
     */
    public static Map<String, Object> extractQueryFields(Map<String, Object> queryData) {
        Map<String, Object> fieldConditions = new Map<String, Object>();
        
        if (queryData == null) {
            return fieldConditions;
        }
        
        // Get all special keys that shouldn't be treated as field filters
        Set<String> specialKeys = getSpecialKeys();
        
        for (String field : queryData.keySet()) {
            // Skip special keys that are never fields
            if (SPECIAL_KEYS.contains(field)) {
                continue;
            }
            
            // Skip non-filterable fields unless they use LIKE operator
            if (NON_FILTERABLE_FIELDS.contains(field) && !field.endsWith('_LIKE')) {
                System.debug('Skipping non-filterable field: ' + field);
                continue;
            }
            
            // Check if this field should be redirected
            String actualField = field;
            Object value = queryData.get(field);
            
            if (FIELD_REDIRECTS.containsKey(field)) {
                actualField = FIELD_REDIRECTS.get(field);
                System.debug('Redirecting field ' + field + ' to ' + actualField);
            }
            
            // Map slack-related terms to SlackId__c field
            if (FIELD_MAPPINGS.containsKey(field.toLowerCase())) {
                actualField = FIELD_MAPPINGS.get(field.toLowerCase());
                System.debug('Mapping field ' + field + ' to ' + actualField);
            }
            
            // Special handling for location fields - convert to LIKE query if not already
            if (LOCATION_FIELDS.contains(actualField) && 
                !actualField.endsWith('_LIKE') &&
                value instanceof String) {
                // Convert to LIKE query for better matching
                actualField = actualField + '_LIKE';
                String strValue = (String)value;
                if (!strValue.startsWith('%')) {
                    strValue = '%' + strValue;
                }
                if (!strValue.endsWith('%')) {
                    strValue = strValue + '%';
                }
                value = strValue;
                System.debug('Converting location field to LIKE query: ' + actualField + ' = ' + value);
            }
            
            // Check if this is a field condition
            if (isFieldCondition(actualField, specialKeys)) {
                fieldConditions.put(actualField, value);
            }
        }
        
        return fieldConditions;
    }
    
    /**
     * Check if any additional filters exist beyond the primary query type
     * @param queryData The query data
     * @param primaryQueryType The primary type of query (e.g., 'HIERARCHY', 'DIRECT_REPORTS')
     * @return True if additional filters exist
     */
    public static Boolean hasAdditionalFilters(Map<String, Object> queryData, String primaryQueryType) {
        if (queryData == null) {
            return false;
        }
        
        Set<String> primaryKeys = QUERY_TYPE_KEYS.get(primaryQueryType);
        Set<String> contextKeys = QUERY_TYPE_KEYS.get('CONTEXT');
        Set<String> systemKeys = SYSTEM_FIELDS;
        
        for (String key : queryData.keySet()) {
            // Skip special keys that are never fields
            if (SPECIAL_KEYS.contains(key)) {
                continue;
            }
            
            // Skip non-filterable fields
            if (NON_FILTERABLE_FIELDS.contains(key)) {
                continue;
            }
            
            // Apply field redirect if needed
            String actualKey = key;
            if (FIELD_REDIRECTS.containsKey(key)) {
                actualKey = FIELD_REDIRECTS.get(key);
            }
            
            // Map slack-related terms
            if (FIELD_MAPPINGS.containsKey(key.toLowerCase())) {
                actualKey = FIELD_MAPPINGS.get(key.toLowerCase());
            }
            
            // Remove operator suffixes for comparison
            if (actualKey.endsWith('_LIKE')) {
                actualKey = actualKey.substring(0, actualKey.lastIndexOf('_'));
            } else if (actualKey.endsWith('_OR')) {
                actualKey = actualKey.substring(0, actualKey.length() - 3);
            }
            
            // If the key is not a primary key, context key, or system field, it's an additional filter
            if (!primaryKeys.contains(actualKey) && 
                !contextKeys.contains(actualKey) && 
                !systemKeys.contains(actualKey)) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Get all special keys that shouldn't be treated as field filters
     * @return Set of special keys
     */
    private static Set<String> getSpecialKeys() {
        Set<String> specialKeys = new Set<String>();
        
        // Add all query type keys
        for (Set<String> keys : QUERY_TYPE_KEYS.values()) {
            specialKeys.addAll(keys);
        }
        
        // Add system fields
        specialKeys.addAll(SYSTEM_FIELDS);
        
        // Add special keys that are never fields
        specialKeys.addAll(SPECIAL_KEYS);
        
        return specialKeys;
    }
    
    /**
     * Check if a field should be treated as a filter condition
     * @param field The field name
     * @param specialKeys Set of keys that aren't field conditions
     * @return True if this is a field condition
     */
    private static Boolean isFieldCondition(String field, Set<String> specialKeys) {
        // Skip special keys
        if (specialKeys.contains(field)) {
            return false;
        }
        
        // Never treat SPECIAL_KEYS as fields
        if (SPECIAL_KEYS.contains(field)) {
            return false;
        }
        
        // Include all field conditions: standard fields, OR conditions, LIKE conditions, and date fields
        return field.endsWith('__c') || 
               field.endsWith('_OR') || 
               field.endsWith('_LIKE') ||
               isDateField(field);
    }
    
    /**
     * Check if a field is a date-related field
     * @param field The field name
     * @return True if this is a date field
     */
    private static Boolean isDateField(String field) {
        for (String prefix : DATE_FIELD_PREFIXES) {
            if (field.startsWith(prefix)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Build WHERE clause conditions from field conditions
     * @param fieldConditions Map of field conditions
     * @return List of SQL WHERE clause strings
     */
    public static List<String> buildWhereConditions(Map<String, Object> fieldConditions) {
        List<String> conditions = new List<String>();
        
        if (fieldConditions == null || fieldConditions.isEmpty()) {
            return conditions;
        }
        
        // Apply field redirects before processing
        Map<String, Object> redirectedConditions = new Map<String, Object>();
        for (String field : fieldConditions.keySet()) {
            // Skip special keys that are never fields
            if (SPECIAL_KEYS.contains(field)) {
                continue;
            }
            
            // Skip non-filterable fields unless they use LIKE operator
            if (NON_FILTERABLE_FIELDS.contains(field) && !field.endsWith('_LIKE')) {
                continue;
            }
            
            String actualField = field;
            Object value = fieldConditions.get(field);
            
            if (FIELD_REDIRECTS.containsKey(field)) {
                actualField = FIELD_REDIRECTS.get(field);
                value = fieldConditions.get(field);
                System.debug('Applying redirect in conditions: ' + field + ' -> ' + actualField);
            }
            
            // Apply slack field mapping
            if (FIELD_MAPPINGS.containsKey(field.toLowerCase())) {
                actualField = FIELD_MAPPINGS.get(field.toLowerCase());
                value = fieldConditions.get(field);
                System.debug('Applying mapping in conditions: ' + field + ' -> ' + actualField);
            }
            
            redirectedConditions.put(actualField, value);
        }
        
        // Process date fields first
        Map<String, Object> processedData = AHMayDateHandler.parseDateCriteria(redirectedConditions);
        AHMayDateHandler.addDateConditions(processedData, conditions);
        
        // Process non-date fields
        for (String field : processedData.keySet()) {
            // Skip special keys that are never fields
            if (SPECIAL_KEYS.contains(field)) {
                continue;
            }
            
            if (!isDateField(field)) {
                Object value = processedData.get(field);
                String condition = buildCondition(field, value);
                if (String.isNotBlank(condition)) {
                    conditions.add(condition);
                }
            }
        }
        
        return conditions;
    }
    
    /**
     * Build a single condition string from field and value
     * @param fieldName The field name
     * @param value The value to filter by
     * @return SQL condition string
     */
    public static String buildCondition(String fieldName, Object value) {
        if (String.isBlank(fieldName) || value == null) {
            return null;
        }
        
        // Skip special keys that are never fields
        if (SPECIAL_KEYS.contains(fieldName)) {
            return null;
        }
        
        // Skip non-filterable fields unless they use LIKE operator
        if (NON_FILTERABLE_FIELDS.contains(fieldName) && !fieldName.endsWith('_LIKE')) {
            return null;
        }
        
        // Handle LIKE conditions
        if (fieldName.endsWith('_LIKE')) {
            String actualField = fieldName.substring(0, fieldName.length() - 5);
            // Skip if base field is non-filterable
            if (NON_FILTERABLE_FIELDS.contains(actualField)) {
                System.debug('Cannot use LIKE on non-filterable field: ' + actualField);
                return null;
            }
            
            String searchValue = String.valueOf(value);
            return actualField + ' LIKE \'' + String.escapeSingleQuotes(searchValue) + '\'';
        }
        
        // Handle OR conditions
        if (fieldName.endsWith('_OR') && value instanceof List<Object>) {
            String baseField = fieldName.substring(0, fieldName.length() - 3);
            // Skip if base field is non-filterable
            if (NON_FILTERABLE_FIELDS.contains(baseField)) {
                return null;
            }
            return buildOrCondition(baseField, (List<Object>)value);
        }
        
        // Handle single value conditions
        if (value instanceof Boolean) {
            return fieldName + ' = ' + value;
        } else if (value instanceof String) {
            // Special handling for location fields - always use LIKE
            if (LOCATION_FIELDS.contains(fieldName)) {
                String searchValue = '%' + (String)value + '%';
                return fieldName + ' LIKE \'' + String.escapeSingleQuotes(searchValue) + '\'';
            } else {
                return fieldName + ' = \'' + String.escapeSingleQuotes((String)value) + '\'';
            }
        } else if (value instanceof Integer || value instanceof Decimal || value instanceof Long) {
            return fieldName + ' = ' + value;
        } else if (value instanceof Date) {
            return fieldName + ' = ' + formatDate((Date)value);
        } else if (value instanceof Datetime) {
            return fieldName + ' = ' + formatDateTime((Datetime)value);
        }
        
        return null;
    }
    
    /**
     * Build OR condition for multiple values
     * @param fieldName The field name (without _OR suffix)
     * @param values List of values for OR condition
     * @return SQL OR condition string
     */
    private static String buildOrCondition(String fieldName, List<Object> values) {
        // Skip special keys that are never fields
        if (SPECIAL_KEYS.contains(fieldName)) {
            return null;
        }
        
        // Skip if base field is non-filterable
        if (NON_FILTERABLE_FIELDS.contains(fieldName)) {
            return null;
        }
        
        List<String> orConditions = new List<String>();
        
        for (Object value : values) {
            String condition = buildCondition(fieldName, value);
            if (String.isNotBlank(condition)) {
                orConditions.add(condition);
            }
        }
        
        if (orConditions.isEmpty()) {
            return null;
        }
        
        return '(' + String.join(orConditions, ' OR ') + ')';
    }
    
    private static String formatDate(Date d) {
        return d.year() + '-' + 
            String.valueOf(d.month()).leftPad(2, '0') + '-' + 
            String.valueOf(d.day()).leftPad(2, '0');
    }
    
    private static String formatDateTime(Datetime dt) {
        return dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }
}