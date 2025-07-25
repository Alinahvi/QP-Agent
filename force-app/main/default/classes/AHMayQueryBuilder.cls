public class AHMayQueryBuilder {
    
    // Standard fields to include in all queries
    private static final List<String> STANDARD_FIELDS = new List<String>{
        'Id', 'Name', 'Primary_Email__c', 'Manager__c', 'Manager_Email__c'
    };
    
    // Build a SOQL query based on query data
    public static String buildSOQLQuery(Map<String, Object> queryData, Boolean includeOrderAndLimit, Integer pageSize, Integer offset) {
        List<String> selectFields = getRequiredFields(queryData);
        List<String> conditions = getQueryConditions(queryData);
        
        String query = 'SELECT ' + String.join(selectFields, ', ') + 
                    ' FROM Learner_Profile__c WHERE ' + String.join(conditions, ' AND ');
        
        if (includeOrderAndLimit) {
            query += ' ORDER BY Name ASC LIMIT ' + pageSize + ' OFFSET ' + offset;
        }
        
        return query;
    }
    
    // Get only the fields required for this specific query type
    public static List<String> getRequiredFields(Map<String, Object> queryData) {
        Set<String> fields = new Set<String>(STANDARD_FIELDS);
        
        // Add fields explicitly referenced in the query for dynamic selection
        if (queryData != null) {
            for (String key : queryData.keySet()) {
                if (key.endsWith('__c') && !key.endsWith('_OR') && !STANDARD_FIELDS.contains(key) && 
                    !key.startsWith('Hire_Date__c_') && key != 'Status__c') {
                    fields.add(key);
                }
            }
        }
        
        // Add special fields for hierarchical queries
        Boolean needsHierarchyFields = false;
        
        if (queryData != null) {
            needsHierarchyFields = queryData.containsKey('HIERARCHICAL_QUERY') || 
                                queryData.containsKey('HIERARCHICAL_QUERY_OR') ||
                                queryData.get('NEED_HIERARCHY_FIELDS') == true;
        }
        
        if (needsHierarchyFields) {
            // Add management chain fields for hierarchical queries
            for (Integer i = 1; i <= 10; i++) {
                String fieldName = 'Emp_Mgt_Chain_Lvl_';
                if (i < 10) {
                    fieldName += '0' + String.valueOf(i);
                } else {
                    fieldName += String.valueOf(i);
                }
                fieldName += '_Nm__c';
                fields.add(fieldName);
            }
        }
        
        // Add commonly needed fields based on query type
        if (queryData != null) {
            Boolean isDetailQuery = queryData.containsKey('EMPLOYEE_DETAILS') || 
                                 queryData.containsKey('DIRECT_REPORTS');
            
            // Always include these fields for all queries
            fields.add('Division__c');
            fields.add('Job_Family__c');
            fields.add('Work_Location_Country__c');
            
            // Add new market/sales related fields
            fields.add('Seller_Group__c');
            fields.add('Macro_Segment__c');
            fields.add('em_Industry__c');
            fields.add('AE_Type__c');

            
            // For simple list queries, limit fields for better performance
            if (!isDetailQuery && !needsHierarchyFields) {
                // Keep the field set minimal for list queries
                if (queryData.containsKey('FTE__c')) fields.add('FTE__c');
                if (queryData.containsKey('Commissionable__c')) fields.add('Commissionable__c');
                if (queryData.containsKey('Hire_Date__c')) fields.add('Hire_Date__c');
                if (queryData.containsKey('Employee_Location__c')) fields.add('Employee_Location__c');
                if (queryData.containsKey('Business_Unit_Name__c')) fields.add('Business_Unit_Name__c');
                // Add new fields conditionally if referenced
                if (queryData.containsKey('Seller_Group__c')) fields.add('Seller_Group__c');
                if (queryData.containsKey('Macro_Segment__c')) fields.add('Macro_Segment__c');
                if (queryData.containsKey('em_Industry__c')) fields.add('em_Industry__c');
                if (queryData.containsKey('AE_Type__c')) fields.add('AE_Type__c');
            } else {
                // For detailed/hierarchical queries, include more fields
                fields.add('Employee_Location__c');
                fields.add('Business_Unit_Name__c');
                fields.add('FTE__c');
                fields.add('Commissionable__c');
                fields.add('Job_Code__c');
                fields.add('Cost_Center_Name__c');
                fields.add('Cost_Center_ID__c');
                fields.add('Hire_Date__c');
                fields.add('Days_in_Current_Role__c');
                fields.add('Is_FLM__c');
                // These new fields are already added above in the "always include" section
            }
            
            // Add fields needed for aggregation
            if (queryData.containsKey('AGGREGATION') && queryData.containsKey('GROUP_BY_FIELD')) {
                String groupByField = (String)queryData.get('GROUP_BY_FIELD');
                if (!fields.contains(groupByField)) {
                    fields.add(groupByField);
                }
            }
        }
        
        return new List<String>(fields);
    }
    
    // Build query conditions with date handling
    public static List<String> getQueryConditions(Map<String, Object> queryData) {
        List<String> conditions = new List<String>();
        conditions.add('Status__c = \'Active\'');
        
        if (queryData == null) {
            return conditions;
        }
        
        // Debug input data to verify date conditions are present
        System.debug('Query data before date processing: ' + JSON.serialize(queryData));
        
        // Process date-related criteria first
        Map<String, Object> processedData = AHMayDateHandler.parseDateCriteria(queryData);
        List<String> dateConditions = new List<String>();
        AHMayDateHandler.addDateConditions(processedData, dateConditions);
        
        // Debug to verify date conditions are generated
        System.debug('Date conditions from AHMayDateHandler: ' + dateConditions);
        
        // Add all date conditions
        conditions.addAll(dateConditions);
        
        // Process regular field conditions
        for (String field : processedData.keySet()) {
            if (field.endsWith('__c') && field != 'Status__c' && 
                !field.contains('HIERARCHICAL_QUERY') && !field.endsWith('_OR') &&
                !field.startsWith('Hire_Date__c_')) {
                
                Object value = processedData.get(field);
                if (value != null) {
                    if (value instanceof Boolean) {
                        conditions.add(field + ' = ' + value);
                    } else if (value instanceof String) {
                        // Use LIKE for partial name matches if configured
                        if (field == 'Name' && queryData.containsKey('PARTIAL_NAME_MATCH')) {
                            conditions.add(field + ' LIKE \'%' + String.escapeSingleQuotes((String)value) + '%\'');
                        } else {
                            conditions.add(field + ' = \'' + String.escapeSingleQuotes((String)value) + '\'');
                        }
                    } else if (value instanceof Integer || value instanceof Decimal) {
                        conditions.add(field + ' = ' + value);
                    }
                }
            }
        }
        
        // Debug final conditions
        System.debug('Final query conditions: ' + conditions);
        
        return conditions;
    }
    
    // Build a count query with date handling
    public static String buildCountQuery(Map<String, Object> queryData) {
        List<String> conditions = getQueryConditions(queryData);
        return 'SELECT COUNT() FROM Learner_Profile__c WHERE ' + String.join(conditions, ' AND ');
    }
    
    // Build a specialized query with selective field inclusion for better performance
    public static String buildSpecializedQuery(Map<String, Object> queryData, String queryType, 
                                            Boolean includeOrderAndLimit, Integer pageSize, Integer offset) {
        // Set specific needs based on query type
        if (queryType == 'HIERARCHICAL') {
            queryData.put('NEED_HIERARCHY_FIELDS', true);
        }
        
        // Get optimized field list and conditions
        List<String> selectFields = getRequiredFields(queryData);
        List<String> conditions = getQueryConditions(queryData);
        
        String query = 'SELECT ' + String.join(selectFields, ', ') + 
                     ' FROM Learner_Profile__c WHERE ' + String.join(conditions, ' AND ');
        
        if (includeOrderAndLimit) {
            query += ' ORDER BY Name ASC LIMIT ' + pageSize + ' OFFSET ' + offset;
        }
        
        return query;
    }
}