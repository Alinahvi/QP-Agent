/**
 * Implementation of AHMayQueryBuilderInterface for standard employee queries
 */
public class AHMayStandardQueryBuilder implements AHMayQueryBuilderInterface {
    
    // Standard fields to include in all queries
    private static final List<String> STANDARD_FIELDS = new List<String>{
        'Id', 'Name', 'Primary_Email__c', 'Manager__c', 'Manager_Email__c'
    };
    
    // Additional commonly used fields
    private static final List<String> COMMON_FIELDS = new List<String>{
        'Division__c', 'Job_Family__c', 'Employee_Location__c', 
        'Business_Unit_Name__c', 'FTE__c', 'Commissionable__c'
    };
    
    /**
     * Build a standard SOQL query based on query data
     */
    public String buildQuery(Map<String, Object> queryData, Integer pageSize, Integer offset) {
        List<String> selectFields = getRequiredFields(queryData);
        List<String> conditions = getQueryConditions(queryData);
        
        String query = 'SELECT ' + String.join(selectFields, ', ') + 
                     ' FROM Learner_Profile__c WHERE ' + String.join(conditions, ' AND ');
        
        if (pageSize != null) {
            query += ' ORDER BY Name ASC LIMIT ' + pageSize;
            
            if (offset != null && offset > 0) {
                query += ' OFFSET ' + offset;
            }
        }
        
        return query;
    }
    
    /**
     * Build a COUNT query to get total record count
     */
    public String buildCountQuery(Map<String, Object> queryData) {
        List<String> conditions = getQueryConditions(queryData);
        return 'SELECT COUNT() FROM Learner_Profile__c WHERE ' + String.join(conditions, ' AND ');
    }
    
    /**
     * Get only the fields required for this specific query type
     */
    public List<String> getRequiredFields(Map<String, Object> queryData) {
        Set<String> fields = new Set<String>(STANDARD_FIELDS);
        
        // Add common fields for usability
        fields.addAll(COMMON_FIELDS);
        
        // Add fields explicitly referenced in the query for dynamic selection
        if (queryData != null) {
            for (String key : queryData.keySet()) {
                if (key.endsWith('__c') && !key.endsWith('_OR') && !fields.contains(key) && 
                    !key.startsWith('Hire_Date__c_') && key != 'Status__c') {
                    fields.add(key);
                }
            }
            
            // Add additional fields based on query type
            Boolean needsDetailedInfo = queryData.containsKey('NEED_DETAILED_INFO') && 
                                     (Boolean)queryData.get('NEED_DETAILED_INFO');
            
            if (needsDetailedInfo) {
                fields.add('Job_Code__c');
                fields.add('Cost_Center_Name__c');
                fields.add('Cost_Center_ID__c');
                fields.add('Hire_Date__c');
                fields.add('Days_in_Current_Role__c');
                fields.add('Work_Location_Country__c');
                fields.add('Is_FLM__c');
            } else {
                // Selectively add important fields even if not directly referenced
                if (queryData.containsKey('Hire_Date__c')) fields.add('Hire_Date__c');
                if (queryData.containsKey('Work_Location_Country__c')) fields.add('Work_Location_Country__c');
            }
        }
        
        return new List<String>(fields);
    }
    
    /**
     * Build query conditions with date handling
     */
    public List<String> getQueryConditions(Map<String, Object> queryData) {
        List<String> conditions = new List<String>();
        conditions.add('Status__c = \'Active\'');
        
        if (queryData == null || queryData.isEmpty()) {
            return conditions;
        }
        
        // Process date-related criteria first
        Map<String, Object> processedData = AHMayDateHandler.parseDateCriteria(queryData);
        AHMayDateHandler.addDateConditions(processedData, conditions);
        
        for (String field : queryData.keySet()) {
            if (field.endsWith('__c') && field != 'Status__c' && 
                !field.contains('HIERARCHICAL_QUERY') && !field.endsWith('_OR') &&
                !field.startsWith('Hire_Date__c_')) {
                
                Object value = queryData.get(field);
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
        
        return conditions;
    }
}