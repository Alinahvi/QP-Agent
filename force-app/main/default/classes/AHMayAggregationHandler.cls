public class AHMayAggregationHandler implements AHMayQueryHandler {
    
    // Maximum number of records to process to avoid governor limits
    private static final Integer MAX_RECORDS = 10000;
    
    public AHMayQueryResult handleQuery(AHMayQueryRequest request, Map<String, Object> queryData) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            // Debug: Log the incoming request
            System.debug('AHMayAggregationHandler - Processing request: ' + JSON.serialize(request));
            System.debug('AHMayAggregationHandler - Query data: ' + JSON.serialize(queryData));
            
            // Validate session context
            if (String.isBlank(request.sessionId)) {
                result.success = false;
                result.message = 'Aggregation requires a session context. Please run a query first.';
                return result;
            }
            
            // Get previous query results from cache and session metadata
            List<Learner_Profile__c> cachedRecords = AHMayQueryCache.getResults(request.sessionId);
            Integer totalCount = AHMaySessionContext.getSessionTotalCount(request.sessionId);
            Map<String, Object> previousContext = AHMaySessionContext.getQueryContext(request.sessionId);
            
            System.debug('AHMayAggregationHandler - Found ' + (cachedRecords != null ? cachedRecords.size() : 0) + 
                         ' cached records out of ' + totalCount + ' total records');
            
            // Verify we have records to process
            if (cachedRecords == null || cachedRecords.isEmpty()) {
                result.success = false;
                result.message = 'Aggregation queries require a previous context. Please first run a query to get employees, then ask for aggregation.';
                return result;
            }
            
            // Check if we need to fetch all records for analysis
            List<Learner_Profile__c> recordsToProcess = cachedRecords;
            Boolean isPartialAnalysis = false;
            
            if (totalCount != null && totalCount > cachedRecords.size()) {
                if (totalCount <= MAX_RECORDS) {
                    System.debug('AHMayAggregationHandler - Need to fetch all records. Have ' + cachedRecords.size() + 
                                 ' out of ' + totalCount);
                    
                    if (previousContext != null && !previousContext.isEmpty()) {
                        // Fetch all records instead of just the paginated view
                        recordsToProcess = fetchAllRecords(previousContext);
                        System.debug('AHMayAggregationHandler - Fetched ' + recordsToProcess.size() + ' records for processing');
                        
                        // Check if we still have incomplete data
                        if (recordsToProcess.size() < totalCount) {
                            isPartialAnalysis = true;
                            System.debug('WARNING: Analysis will be performed on partial data: ' + 
                                         recordsToProcess.size() + ' out of ' + totalCount + ' records');
                        }
                    }
                } else {
                    // Too many records to process safely
                    isPartialAnalysis = true;
                    System.debug('WARNING: Too many records to fetch all (' + totalCount + 
                                 ' exceeds limit of ' + MAX_RECORDS + '). Performing analysis on available records.');
                }
            }
            
            // Check for multi-field grouping
            if (queryData.containsKey('GROUP_BY_FIELDS') && queryData.get('GROUP_BY_FIELDS') instanceof List<Object>) {
                List<Object> groupFieldsObj = (List<Object>)queryData.get('GROUP_BY_FIELDS');
                List<String> groupFields = new List<String>();
                
                for (Object field : groupFieldsObj) {
                    if (field instanceof String) {
                        groupFields.add((String)field);
                    }
                }
                
                if (!groupFields.isEmpty()) {
                    AHMayQueryResult multiFieldResult = handleMultiFieldGrouping(recordsToProcess, groupFields);
                    
                    // Add warning to the result message if we're working with partial data
                    if (isPartialAnalysis && multiFieldResult.success) {
                        multiFieldResult.message += '\n\nNOTE: This analysis is based on a subset of the data (' + 
                                                recordsToProcess.size() + ' out of ' + totalCount + ' total records). ' +
                                                'For a complete analysis, try narrowing your initial query.';
                    }
                    
                    return multiFieldResult;
                }
            }
            
            // Check for single field grouping
            if (!queryData.containsKey('GROUP_BY_FIELD')) {
                // Try to guess the field if the query is about managers
                if (queryData.containsKey('MAINTAIN_PREVIOUS_CONTEXT') && 
                    request.userInput != null && 
                    request.userInput.toLowerCase().contains('manager')) {
                    queryData.put('GROUP_BY_FIELD', 'Manager__c');
                    System.debug('Auto-detected manager grouping');
                } else {
                    result.success = false;
                    result.message = 'No grouping field specified. Please provide a field to group by.';
                    return result;
                }
            }
            
            String groupByField = (String)queryData.get('GROUP_BY_FIELD');
            System.debug('AHMayAggregationHandler - Grouping by field: ' + groupByField);
            
            // Normalize grouping field references
            if (groupByField.equalsIgnoreCase('manager') || 
                groupByField.equalsIgnoreCase('manager name') ||
                groupByField.equalsIgnoreCase('managers')) {
                groupByField = 'Manager__c';
            } else if (groupByField.equalsIgnoreCase('division') ||
                      groupByField.equalsIgnoreCase('divisions') ||
                      groupByField.equalsIgnoreCase('region') ||
                      groupByField.equalsIgnoreCase('regions')) {
                groupByField = 'Division__c';
            } else if (groupByField.equalsIgnoreCase('location') ||
                      groupByField.equalsIgnoreCase('locations') ||
                      groupByField.equalsIgnoreCase('office') ||
                      groupByField.equalsIgnoreCase('offices')) {
                groupByField = 'Employee_Location__c';
            } else if (groupByField.equalsIgnoreCase('job family') ||
                      groupByField.equalsIgnoreCase('job families') ||
                      groupByField.equalsIgnoreCase('job') ||
                      groupByField.equalsIgnoreCase('jobs')) {
                groupByField = 'Job_Family__c';
            } else if (groupByField.equalsIgnoreCase('business unit') ||
                      groupByField.equalsIgnoreCase('business units') ||
                      groupByField.equalsIgnoreCase('bu')) {
                groupByField = 'Business_Unit_Name__c';
            } else if (groupByField.equalsIgnoreCase('country') ||
                      groupByField.equalsIgnoreCase('countries')) {
                groupByField = 'Work_Location_Country__c';
            }
            
            // Handle date-based grouping with unit specification
            if (groupByField.equalsIgnoreCase('Hire_Date__c') || 
                groupByField.toLowerCase().contains('hire date') ||
                groupByField.toLowerCase().contains('start date')) {
                
                String groupByDateUnit = 'MONTH'; // Default to month
                
                // Check if a specific date unit is specified
                if (queryData.containsKey('GROUP_BY_DATE_UNIT')) {
                    String unitSpec = String.valueOf(queryData.get('GROUP_BY_DATE_UNIT'));
                    if (unitSpec == 'YEAR' || unitSpec == 'QUARTER' || 
                        unitSpec == 'MONTH' || unitSpec == 'WEEK') {
                        groupByDateUnit = unitSpec;
                    }
                } else {
                    // Try to infer from query
                    if (request.userInput != null) {
                        String lowerInput = request.userInput.toLowerCase();
                        if (lowerInput.contains('year')) {
                            groupByDateUnit = 'YEAR';
                        } else if (lowerInput.contains('quarter')) {
                            groupByDateUnit = 'QUARTER';
                        } else if (lowerInput.contains('week')) {
                            groupByDateUnit = 'WEEK';
                        }
                    }
                }
                
                AHMayQueryResult dateResult = handleDateGrouping(recordsToProcess, 'Hire_Date__c', groupByDateUnit);
                
                // Add warning to the result message if we're working with partial data
                if (isPartialAnalysis && dateResult.success) {
                    dateResult.message += '\n\nNOTE: This analysis is based on a subset of the data (' + 
                                      recordsToProcess.size() + ' out of ' + totalCount + ' total records). ' +
                                      'For a complete analysis, try narrowing your initial query.';
                }
                
                return dateResult;
            }
            
            // Handle standard field grouping
            AHMayQueryResult standardResult = handleStandardGrouping(recordsToProcess, groupByField);
            
            // Add warning to the result message if we're working with partial data
            if (isPartialAnalysis && standardResult.success) {
                standardResult.message += '\n\nNOTE: This analysis is based on a subset of the data (' + 
                                      recordsToProcess.size() + ' out of ' + totalCount + ' total records). ' +
                                      'For a complete analysis, try narrowing your initial query.';
            }
            
            return standardResult;
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error processing aggregation query: ' + e.getMessage() + 
                           ' (Line: ' + e.getLineNumber() + ')';
            System.debug(LoggingLevel.ERROR, 'Aggregation Error: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack Trace: ' + e.getStackTraceString());
            return result;
        }
    }
    
    // Helper methods for fetching records and building queries
    private List<Learner_Profile__c> fetchAllRecords(Map<String, Object> queryContext) {
        try {
            System.debug('AHMayAggregationHandler - Attempting to fetch all records for complete analysis');
            
            String query = buildCompleteRecordsQuery(queryContext);
            
            if (String.isBlank(query)) {
                System.debug(LoggingLevel.ERROR, 'Could not build query to fetch all records');
                return new List<Learner_Profile__c>();
            }
            
            System.debug('Executing full records query: ' + query);
            List<Learner_Profile__c> allRecords = Database.query(query);
            System.debug('Fetched ' + allRecords.size() + ' total records');
            
            return allRecords;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error fetching all records: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack Trace: ' + e.getStackTraceString());
            return new List<Learner_Profile__c>();
        }
    }
    
    // Method to build the appropriate query based on query type
    private String buildCompleteRecordsQuery(Map<String, Object> queryContext) {
        // Determine which query type to build based on context
        if (queryContext.containsKey('HIERARCHICAL_QUERY')) {
            return buildHierarchicalQuery(queryContext);
        } else if (queryContext.containsKey('DIRECT_REPORTS')) {
            return buildDirectReportsQuery(queryContext);
        } else if (queryContext.containsKey('HIERARCHICAL_QUERY_OR')) {
            return buildMultipleManagersHierarchicalQuery(queryContext);
        } else if (queryContext.containsKey('DIRECT_REPORTS_OR')) {
            return buildMultipleManagersDirectReportsQuery(queryContext);
        } else {
            return buildStandardQuery(queryContext);
        }
    }
    
    // Build hierarchical query for a single manager
    private String buildHierarchicalQuery(Map<String, Object> queryContext) {
        Object managerNameObj = queryContext.get('HIERARCHICAL_QUERY');
        if (managerNameObj == null) {
            System.debug(LoggingLevel.ERROR, 'No manager specified for hierarchical query');
            return null;
        }
        
        String managerName = String.valueOf(managerNameObj);
        System.debug('Building hierarchical query for manager: ' + managerName);
        
        String managerEmail = findManagerEmail(managerName);
        
        if (String.isBlank(managerEmail)) {
            System.debug(LoggingLevel.ERROR, 'Could not find email for manager: ' + managerName);
            return null;
        }
        
        List<String> chainConditions = buildChainConditions(managerEmail);
        
        String query = 'SELECT Id, Name, Primary_Email__c, Manager__c, Manager_Email__c, ' +
                     'Division__c, Job_Family__c, Employee_Location__c, Business_Unit_Name__c, ' +
                     'FTE__c, Commissionable__c, Job_Code__c, Cost_Center_Name__c, ' +
                     'Cost_Center_ID__c, Hire_Date__c, Days_in_Current_Role__c, Work_Location_Country__c, ' +
                     'Is_FLM__c, ' +
                     'Emp_Mgt_Chain_Lvl_01_Nm__c, Emp_Mgt_Chain_Lvl_02_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_03_Nm__c, Emp_Mgt_Chain_Lvl_04_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_05_Nm__c, Emp_Mgt_Chain_Lvl_06_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_07_Nm__c, Emp_Mgt_Chain_Lvl_08_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_09_Nm__c, Emp_Mgt_Chain_Lvl_10_Nm__c ' +
                     'FROM Learner_Profile__c WHERE Status__c = \'Active\'';
        
        if (!chainConditions.isEmpty()) {
            query += ' AND (' + String.join(chainConditions, ' OR ') + ')';
        }
        
        // Add any additional filtering conditions
        query += appendAdditionalConditions(queryContext);
        
        // Order by name but don't apply pagination limits
        query += ' ORDER BY Name ASC';
        
        return query;
    }
    
    // Build query for multiple managers in hierarchical structure
    private String buildMultipleManagersHierarchicalQuery(Map<String, Object> queryContext) {
        Object managersObj = queryContext.get('HIERARCHICAL_QUERY_OR');
        if (managersObj == null || !(managersObj instanceof List<Object>)) {
            System.debug(LoggingLevel.ERROR, 'No valid managers list for hierarchical OR query');
            return null;
        }
        
        List<Object> managerObjs = (List<Object>)managersObj;
        List<String> allChainConditions = new List<String>();
        
        for (Object obj : managerObjs) {
            if (obj != null) {
                String managerName = String.valueOf(obj);
                String managerEmail = findManagerEmail(managerName);
                
                if (!String.isBlank(managerEmail)) {
                    List<String> managerChainConditions = buildChainConditions(managerEmail);
                    if (!managerChainConditions.isEmpty()) {
                        allChainConditions.add('(' + String.join(managerChainConditions, ' OR ') + ')');
                    }
                }
            }
        }
        
        String query = 'SELECT Id, Name, Primary_Email__c, Manager__c, Manager_Email__c, ' +
                     'Division__c, Job_Family__c, Employee_Location__c, Business_Unit_Name__c, ' +
                     'FTE__c, Commissionable__c, Job_Code__c, Cost_Center_Name__c, ' +
                     'Cost_Center_ID__c, Hire_Date__c, Days_in_Current_Role__c, Work_Location_Country__c, ' +
                     'Is_FLM__c, ' +
                     'Emp_Mgt_Chain_Lvl_01_Nm__c, Emp_Mgt_Chain_Lvl_02_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_03_Nm__c, Emp_Mgt_Chain_Lvl_04_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_05_Nm__c, Emp_Mgt_Chain_Lvl_06_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_07_Nm__c, Emp_Mgt_Chain_Lvl_08_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_09_Nm__c, Emp_Mgt_Chain_Lvl_10_Nm__c ' +
                     'FROM Learner_Profile__c WHERE Status__c = \'Active\'';
        
        if (!allChainConditions.isEmpty()) {
            query += ' AND (' + String.join(allChainConditions, ' OR ') + ')';
        }
        
        // Add any additional filtering conditions
        query += appendAdditionalConditions(queryContext);
        
        // Order by name but don't apply pagination limits
        query += ' ORDER BY Name ASC';
        
        return query;
    }
    
    // Build query for direct reports to a single manager
    private String buildDirectReportsQuery(Map<String, Object> queryContext) {
        Object managerNameObj = queryContext.get('DIRECT_REPORTS');
        if (managerNameObj == null) {
            System.debug(LoggingLevel.ERROR, 'No manager specified for direct reports query');
            return null;
        }
        
        String managerName = String.valueOf(managerNameObj);
        
        String query = 'SELECT Id, Name, Primary_Email__c, Manager__c, Manager_Email__c, ' +
                     'Division__c, Job_Family__c, Employee_Location__c, Business_Unit_Name__c, ' +
                     'FTE__c, Commissionable__c, Job_Code__c, Cost_Center_Name__c, ' +
                     'Cost_Center_ID__c, Hire_Date__c, Days_in_Current_Role__c, Work_Location_Country__c, ' +
                     'Is_FLM__c, ' +
                     'Emp_Mgt_Chain_Lvl_01_Nm__c, Emp_Mgt_Chain_Lvl_02_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_03_Nm__c, Emp_Mgt_Chain_Lvl_04_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_05_Nm__c, Emp_Mgt_Chain_Lvl_06_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_07_Nm__c, Emp_Mgt_Chain_Lvl_08_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_09_Nm__c, Emp_Mgt_Chain_Lvl_10_Nm__c ' +
                     'FROM Learner_Profile__c WHERE Status__c = \'Active\' AND ' +
                     'Manager__c = \'' + String.escapeSingleQuotes(managerName) + '\'';
        
        // Try by email as well if available
        String managerEmail = findManagerEmail(managerName);
        if (!String.isBlank(managerEmail)) {
            query = query.replace('Manager__c =', '(Manager__c =');
            query += ' OR Manager_Email__c = \'' + String.escapeSingleQuotes(managerEmail) + '\')';
        }
        
        // Add any additional filtering conditions
        query += appendAdditionalConditions(queryContext);
        
        // Order by name but don't apply pagination
        query += ' ORDER BY Name ASC';
        
        return query;
    }
    
    // Build query for direct reports to multiple managers
    private String buildMultipleManagersDirectReportsQuery(Map<String, Object> queryContext) {
        Object managersObj = queryContext.get('DIRECT_REPORTS_OR');
        if (managersObj == null || !(managersObj instanceof List<Object>)) {
            System.debug(LoggingLevel.ERROR, 'No valid managers list for direct reports OR query');
            return null;
        }
        
        List<Object> managerObjs = (List<Object>)managersObj;
        List<String> managerConditions = new List<String>();
        
        for (Object obj : managerObjs) {
            if (obj != null) {
                String managerName = String.valueOf(obj);
                managerConditions.add('Manager__c = \'' + String.escapeSingleQuotes(managerName) + '\'');
                
                // Try by email as well if available
                String managerEmail = findManagerEmail(managerName);
                if (!String.isBlank(managerEmail)) {
                    managerConditions.add('Manager_Email__c = \'' + String.escapeSingleQuotes(managerEmail) + '\'');
                }
            }
        }
        
        String query = 'SELECT Id, Name, Primary_Email__c, Manager__c, Manager_Email__c, ' +
                     'Division__c, Job_Family__c, Employee_Location__c, Business_Unit_Name__c, ' +
                     'FTE__c, Commissionable__c, Job_Code__c, Cost_Center_Name__c, ' +
                     'Cost_Center_ID__c, Hire_Date__c, Days_in_Current_Role__c, Work_Location_Country__c, ' +
                     'Is_FLM__c, ' +
                     'Emp_Mgt_Chain_Lvl_01_Nm__c, Emp_Mgt_Chain_Lvl_02_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_03_Nm__c, Emp_Mgt_Chain_Lvl_04_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_05_Nm__c, Emp_Mgt_Chain_Lvl_06_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_07_Nm__c, Emp_Mgt_Chain_Lvl_08_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_09_Nm__c, Emp_Mgt_Chain_Lvl_10_Nm__c ' +
                     'FROM Learner_Profile__c WHERE Status__c = \'Active\'';
        
        if (!managerConditions.isEmpty()) {
            query += ' AND (' + String.join(managerConditions, ' OR ') + ')';
        }
        
        // Add any additional filtering conditions
        query += appendAdditionalConditions(queryContext);
        
        // Order by name but don't apply pagination
        query += ' ORDER BY Name ASC';
        
        return query;
    }
    
    // Build standard query based on attributes
    private String buildStandardQuery(Map<String, Object> queryContext) {
        List<String> conditions = new List<String>{'Status__c = \'Active\''};
        
        // Add all conditions from previous query
        for (String field : queryContext.keySet()) {
            // Skip special fields
            if (field.endsWith('__c') && field != 'Status__c' && 
                !field.contains('HIERARCHICAL_QUERY') && 
                !field.contains('DIRECT_REPORTS') && 
                !field.endsWith('_OR') &&
                !field.startsWith('Hire_Date__c_') &&
                !field.equals('MAINTAIN_PREVIOUS_CONTEXT') &&
                !field.equals('NEXT_PAGE') &&
                !field.equals('GROUP_BY_FIELD') &&
                !field.equals('AGGREGATION') &&
                !field.equals('ANALYSIS')) {
                
                Object value = queryContext.get(field);
                if (value != null) {
                    if (value instanceof Boolean) {
                        conditions.add(field + ' = ' + value);
                    } else if (value instanceof String) {
                        conditions.add(field + ' = \'' + String.escapeSingleQuotes((String)value) + '\'');
                    } else if (value instanceof Integer || value instanceof Decimal) {
                        conditions.add(field + ' = ' + value);
                    }
                }
            }
        }
        
        String query = 'SELECT Id, Name, Primary_Email__c, Manager__c, Manager_Email__c, ' +
                     'Division__c, Job_Family__c, Employee_Location__c, Business_Unit_Name__c, ' +
                     'FTE__c, Commissionable__c, Job_Code__c, Cost_Center_Name__c, ' +
                     'Cost_Center_ID__c, Hire_Date__c, Days_in_Current_Role__c, Work_Location_Country__c, ' +
                     'Is_FLM__c, ' +
                     'Emp_Mgt_Chain_Lvl_01_Nm__c, Emp_Mgt_Chain_Lvl_02_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_03_Nm__c, Emp_Mgt_Chain_Lvl_04_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_05_Nm__c, Emp_Mgt_Chain_Lvl_06_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_07_Nm__c, Emp_Mgt_Chain_Lvl_08_Nm__c, ' +
                     'Emp_Mgt_Chain_Lvl_09_Nm__c, Emp_Mgt_Chain_Lvl_10_Nm__c ' +
                     'FROM Learner_Profile__c WHERE ' + String.join(conditions, ' AND ');
        
        // Process date conditions
        Map<String, Object> dateConditions = extractDateConditions(queryContext);
        if (!dateConditions.isEmpty()) {
            // Process these with AHMayDateHandler methods
            List<String> dateQueryParts = new List<String>();
            Map<String, Object> processedData = AHMayDateHandler.parseDateCriteria(dateConditions);
            AHMayDateHandler.addDateConditions(processedData, dateQueryParts);
            
            for (String condition : dateQueryParts) {
                query += ' AND ' + condition;
            }
        }
        
        // No pagination
        query += ' ORDER BY Name ASC';
        
        return query;
    }
    
    // Helper method to append additional conditions
    private String appendAdditionalConditions(Map<String, Object> queryContext) {
        String additionalConditions = '';
        
        // Process date conditions if present
        Map<String, Object> dateConditions = extractDateConditions(queryContext);
        if (!dateConditions.isEmpty()) {
            // Process these with AHMayDateHandler methods
            List<String> dateQueryParts = new List<String>();
            Map<String, Object> processedData = AHMayDateHandler.parseDateCriteria(dateConditions);
            AHMayDateHandler.addDateConditions(processedData, dateQueryParts);
            
            for (String condition : dateQueryParts) {
                additionalConditions += ' AND ' + condition;
            }
        }
        
        // Add additional non-date standard conditions
        for (String field : queryContext.keySet()) {
            // Only process standard fields that aren't special keys
            if (field.endsWith('__c') && field != 'Status__c' && 
                !field.contains('HIERARCHICAL_QUERY') && 
                !field.contains('DIRECT_REPORTS') && 
                !field.endsWith('_OR') && 
                !field.startsWith('Hire_Date__c_') &&
                !field.equals('MAINTAIN_PREVIOUS_CONTEXT') &&
                !field.equals('NEXT_PAGE') &&
                !field.equals('GROUP_BY_FIELD') &&
                !field.equals('AGGREGATION') &&
                !field.equals('ANALYSIS')) {
                
                Object value = queryContext.get(field);
                if (value != null) {
                    if (value instanceof Boolean) {
                        additionalConditions += ' AND ' + field + ' = ' + value;
                    } else if (value instanceof String) {
                        additionalConditions += ' AND ' + field + ' = \'' + String.escapeSingleQuotes((String)value) + '\'';
                    } else if (value instanceof Integer || value instanceof Decimal) {
                        additionalConditions += ' AND ' + field + ' = ' + value;
                    }
                }
            }
        }
        
        return additionalConditions;
    }
    
    // Helper method to extract date conditions
    private Map<String, Object> extractDateConditions(Map<String, Object> queryContext) {
        Map<String, Object> dateConditions = new Map<String, Object>();
        
        for (String key : queryContext.keySet()) {
            if (key.startsWith('Hire_Date__c_') || key.equals('Hire_Date__c')) {
                dateConditions.put(key, queryContext.get(key));
            }
        }
        
        return dateConditions;
    }
    
    private List<String> buildChainConditions(String managerEmail) {
        List<String> chainConditions = new List<String>();
        
        if (String.isBlank(managerEmail)) {
            return chainConditions;
        }
        
        for (Integer i = 1; i <= 10; i++) {
            String fieldName = 'Emp_Mgt_Chain_Lvl_';
            if (i < 10) {
                fieldName += '0' + i;
            } else {
                fieldName += i;
            }
            fieldName += '_Nm__c';
            
            chainConditions.add(fieldName + ' = \'' + String.escapeSingleQuotes(managerEmail) + '\'');
        }
        
        return chainConditions;
    }
    
    private String findManagerEmail(String managerName) {
        try {
            if (String.isBlank(managerName)) {
                return '';
            }
            
            // First try exact match on Learner_Profile__c
            String exactProfileQuery = 'SELECT Id, Name, Primary_Email__c FROM Learner_Profile__c WHERE ' +
                                     'Status__c = \'Active\' AND ' +
                                     'Name = \'' + String.escapeSingleQuotes(managerName) + '\' LIMIT 1';
            
List<Learner_Profile__c> exactProfiles = Database.query(exactProfileQuery);
           
           if (!exactProfiles.isEmpty() && exactProfiles[0].Primary_Email__c != null) {
               return exactProfiles[0].Primary_Email__c;
           }
           
           // Try partial match on Learner_Profile__c
           String partialProfileQuery = 'SELECT Id, Name, Primary_Email__c FROM Learner_Profile__c WHERE ' +
                                      'Status__c = \'Active\' AND ' +
                                      'Name LIKE \'%' + String.escapeSingleQuotes(managerName) + '%\' LIMIT 1';
           
           List<Learner_Profile__c> partialProfiles = Database.query(partialProfileQuery);
           
           if (!partialProfiles.isEmpty() && partialProfiles[0].Primary_Email__c != null) {
               return partialProfiles[0].Primary_Email__c;
           }
           
           // As last resort, look up the User
           String userQuery = 'SELECT Id, Email FROM User WHERE ' +
                            'IsActive = true AND ' +
                            '(Name = \'' + String.escapeSingleQuotes(managerName) + '\' OR ' +
                            'Name LIKE \'%' + String.escapeSingleQuotes(managerName) + '%\') LIMIT 1';
           
           List<User> users = Database.query(userQuery);
           
           if (!users.isEmpty() && users[0].Email != null) {
               return users[0].Email;
           }
           
           // If we still couldn't find it, try normalizing the name
           // Sometimes the system has "Firstname Lastname" but users type "Lastname, Firstname"
           if (managerName.contains(',')) {
               List<String> nameParts = managerName.split(',');
               if (nameParts.size() == 2) {
                   String reversedName = nameParts[1].trim() + ' ' + nameParts[0].trim();
                   return findManagerEmail(reversedName); // Recursive call with reversed name
               }
           }
           
           return '';
       } catch (Exception e) {
           System.debug('Error finding manager email: ' + e.getMessage());
           return '';
       }
   }
   
   private AHMayQueryResult createErrorResult(String message) {
       AHMayQueryResult result = new AHMayQueryResult();
       result.success = false;
       result.message = message;
       return result;
   }
   
   private AHMayQueryResult handleDateGrouping(List<Learner_Profile__c> records, String dateField, String groupingType) {
       AHMayQueryResult result = new AHMayQueryResult();
       
       try {
           System.debug('Handling date grouping by ' + groupingType + ' for field ' + dateField);
           
           // Group records by date unit
           Map<String, List<Learner_Profile__c>> dateGroups = new Map<String, List<Learner_Profile__c>>();
           Map<String, Integer> groupCounts = new Map<String, Integer>();
           
           // Sort keys for ordered display
           List<String> sortedKeys = new List<String>();
           Map<String, String> displayLabels = new Map<String, String>();
           
           for (Learner_Profile__c record : records) {
               Date dateValue = record.get(dateField) != null ? (Date)record.get(dateField) : null;
               
               if (dateValue != null) {
                   String groupKey;
                   String displayLabel;
                   
                   if (groupingType == 'YEAR') {
                       // Group by year
                       groupKey = String.valueOf(dateValue.year());
                       displayLabel = groupKey;
                   } else if (groupingType == 'QUARTER') {
                       // Group by quarter-year
                       Integer quarter = ((dateValue.month() - 1) / 3) + 1;
                       groupKey = dateValue.year() + '-Q' + quarter;
                       displayLabel = 'Q' + quarter + ' ' + dateValue.year();
                   } else if (groupingType == 'WEEK') {
                       // Group by week-year
                       // This is an approximation since Apex doesn't have built-in week calculation
                       // We'll use the day of year divided by 7 to get a rough week number
                       Date startOfYear = Date.newInstance(dateValue.year(), 1, 1);
                       Integer dayOfYear = dateValue.dayOfYear();
                       Integer weekNumber = (Integer)((dayOfYear - 1) / 7) + 1;
                       
                       groupKey = dateValue.year() + '-W' + String.valueOf(weekNumber).leftPad(2, '0');
                       displayLabel = 'Week ' + weekNumber + ', ' + dateValue.year();
                   } else {
                       // Default to month-year grouping
                       groupKey = dateValue.year() + '-' + 
                                 String.valueOf(dateValue.month()).leftPad(2, '0');
                       
                       displayLabel = getMonthName(dateValue.month()) + ' ' + dateValue.year();
                   }
                   
                   // Add to groups
                   if (!dateGroups.containsKey(groupKey)) {
                       dateGroups.put(groupKey, new List<Learner_Profile__c>());
                       sortedKeys.add(groupKey);
                       displayLabels.put(groupKey, displayLabel);
                   }
                   
                   dateGroups.get(groupKey).add(record);
               }
           }
           
           // Sort the keys for consistent display
           sortedKeys.sort();
           
           // Format the result
           result.success = true;
           result.totalRecords = records.size();
           
           // Create the message with grouped data
           String message = 'Employees grouped by ' + 
                         (groupingType == 'YEAR' ? 'year' : 
                          groupingType == 'QUARTER' ? 'quarter' : 
                          groupingType == 'WEEK' ? 'week' : 'month') + ':\n\n';
           
           for (String key : sortedKeys) {
               List<Learner_Profile__c> groupRecords = dateGroups.get(key);
               String label = displayLabels.get(key);
               
               message += label + ': ' + groupRecords.size() + ' employees\n';
               groupCounts.put(label, groupRecords.size());
           }
           
           result.message = message;
           
           // Include all records in the result
           result.records = AHMayResultFormatter.formatEmployeeRecords(records);
           
           // Add grouping metadata
           result.metadataMap = new Map<String, Object>{
               'grouping' => groupingType.toLowerCase(),
               'groupField' => dateField,
               'groupCounts' => groupCounts
           };
           
           return result;
           
       } catch (Exception e) {
           result.success = false;
           result.message = 'Error grouping by date: ' + e.getMessage();
           System.debug('Date grouping error: ' + e.getMessage());
           return result;
       }
   }
   
   private AHMayQueryResult handleStandardGrouping(List<Learner_Profile__c> records, String fieldName) {
       AHMayQueryResult result = new AHMayQueryResult();
       
       try {
           // Clean field name if needed (e.g., strip __c if not present)
           String apiFieldName = fieldName.endsWith('__c') ? fieldName : fieldName + '__c';
           
           // Special handling for manager field to ensure visibility
           Boolean isManagerField = (apiFieldName == 'Manager__c');
           
           // Group records by field value
           Map<String, List<Learner_Profile__c>> groups = new Map<String, List<Learner_Profile__c>>();
           Map<String, Integer> groupCounts = new Map<String, Integer>();
           
           // Null/empty value group
           List<Learner_Profile__c> nullValueGroup = new List<Learner_Profile__c>();
           
           for (Learner_Profile__c record : records) {
               // Handle special fields directly
               if (isManagerField) {
                   String managerName = record.Manager__c;
                   
                   if (String.isBlank(managerName)) {
                       nullValueGroup.add(record);
                       continue;
                   }
                   
                   // Add to manager group
                   if (!groups.containsKey(managerName)) {
                       groups.put(managerName, new List<Learner_Profile__c>());
                   }
                   
                   groups.get(managerName).add(record);
                   continue;
               }
               
               // Handle standard fields
               try {
                   Object fieldValue = record.get(apiFieldName);
                   String groupKey;
                   
                   if (fieldValue == null) {
                       nullValueGroup.add(record);
                       continue;
                   }
                   
                   // Convert various types to string for grouping
                   if (fieldValue instanceof Boolean) {
                       groupKey = ((Boolean)fieldValue) ? 'True' : 'False';
                   } else if (fieldValue instanceof Date) {
                       groupKey = ((Date)fieldValue).format();
                   } else {
                       groupKey = String.valueOf(fieldValue);
                   }
                   
                   if (String.isBlank(groupKey)) {
                       nullValueGroup.add(record);
                       continue;
                   }
                   
                   // Add to appropriate group
                   if (!groups.containsKey(groupKey)) {
                       groups.put(groupKey, new List<Learner_Profile__c>());
                   }
                   
                   groups.get(groupKey).add(record);
               } catch (Exception e) {
                   // If field doesn't exist, add to null group
                   System.debug('Field ' + apiFieldName + ' not found on record ' + record.Id + ': ' + e.getMessage());
                   nullValueGroup.add(record);
               }
           }
           
           // Sort group keys for consistent display
           List<String> sortedKeys = new List<String>(groups.keySet());
           sortedKeys.sort();
           
           // Format the result
           result.success = true;
           result.totalRecords = records.size();
           
           // Get the field label for nicer display
           String fieldLabel = getFieldLabel(apiFieldName);
           if (String.isBlank(fieldLabel)) {
               fieldLabel = apiFieldName.replace('__c', '');
           }
           
           // Create the message with grouped data
           String message = 'Employees grouped by ' + fieldLabel + ':\n\n';
           
           for (String key : sortedKeys) {
               List<Learner_Profile__c> groupRecords = groups.get(key);
               message += key + ': ' + groupRecords.size() + ' employees\n';
               groupCounts.put(key, groupRecords.size());
           }
           
           // Add null/empty group if any
           if (!nullValueGroup.isEmpty()) {
               message += '(No value): ' + nullValueGroup.size() + ' employees\n';
               groupCounts.put('(No value)', nullValueGroup.size());
           }
           
           result.message = message;
           
           // Include all records in the result
           result.records = AHMayResultFormatter.formatEmployeeRecords(records);
           
           // Add grouping metadata
           result.metadataMap = new Map<String, Object>{
               'grouping' => 'standard',
               'groupField' => apiFieldName,
               'groupFieldLabel' => fieldLabel,
               'groupCounts' => groupCounts,
               'totalRecordsGrouped' => records.size()
           };
           
           return result;
           
       } catch (Exception e) {
           result.success = false;
           result.message = 'Error grouping by ' + fieldName + ': ' + e.getMessage();
           System.debug('Standard grouping error: ' + e.getMessage() + ' at line ' + e.getLineNumber());
           System.debug('Stack trace: ' + e.getStackTraceString());
           return result;
       }
   }
   
   private AHMayQueryResult handleMultiFieldGrouping(List<Learner_Profile__c> records, List<String> groupByFields) {
       AHMayQueryResult result = new AHMayQueryResult();
       
       try {
           System.debug('Handling multi-field grouping by: ' + String.join(groupByFields, ', '));
           
           // Ensure we have fields to group by
           if (groupByFields.isEmpty()) {
               return createErrorResult('No valid fields provided for grouping');
           }
           
           // Normalize field names
           List<String> normalizedFields = new List<String>();
           
           for (String field : groupByFields) {
               // Add proper __c suffix if missing
               String normalizedField = field.endsWith('__c') ? field : field + '__c';
               normalizedFields.add(normalizedField);
           }
           
           // Build map of grouped records
           // The key is a compound key of all group values concatenated
           Map<String, List<Learner_Profile__c>> groupedRecords = new Map<String, List<Learner_Profile__c>>();
           Map<String, Map<String, String>> groupKeysMap = new Map<String, Map<String, String>>();
           
           for (Learner_Profile__c record : records) {
               // Build compound key and individual values
               String compoundKey = '';
               Map<String, String> fieldValues = new Map<String, String>();
               
               for (String field : normalizedFields) {
                   Object value = record.get(field);
                   String strValue = (value != null) ? String.valueOf(value) : 'null';
                   
                   compoundKey += field + ':' + strValue + ';';
                   fieldValues.put(field, strValue);
               }
               
               // Add to grouped records
               if (!groupedRecords.containsKey(compoundKey)) {
                   groupedRecords.put(compoundKey, new List<Learner_Profile__c>());
                   groupKeysMap.put(compoundKey, fieldValues);
               }
               
               groupedRecords.get(compoundKey).add(record);
           }
           
           // Format result
           result.success = true;
           result.totalRecords = records.size();
           
           // Get field labels for display
           Map<String, String> fieldLabels = new Map<String, String>();
           for (String field : normalizedFields) {
               fieldLabels.put(field, getFieldLabel(field));
           }
           
           // Create message with grouped data
           String message = 'Employees grouped by multiple fields:\n\n';
           
           // Sort keys for consistent display
           List<String> sortedKeys = new List<String>(groupedRecords.keySet());
           
           // Build map of counts for metadata
           Map<String, Object> groupCounts = new Map<String, Object>();
           
           for (String key : sortedKeys) {
               List<Learner_Profile__c> groupRecords = groupedRecords.get(key);
               Map<String, String> fieldValueMap = groupKeysMap.get(key);
               
               // Build group label
               String groupLabel = '';
               for (String field : normalizedFields) {
                   String fieldLabel = fieldLabels.get(field);
                   String fieldValue = fieldValueMap.get(field);
                   
                   if (fieldValue == 'null') {
                       fieldValue = '(No value)';
                   }
                   
                   if (groupLabel.length() > 0) {
                       groupLabel += ', ';
                   }
                   groupLabel += fieldLabel + ': ' + fieldValue;
               }
               
               message += groupLabel + ': ' + groupRecords.size() + ' employees\n';
               
               // Add to counts map
               groupCounts.put(groupLabel, groupRecords.size());
           }
           
           result.message = message;
           
           // Include all records in the result
           result.records = AHMayResultFormatter.formatEmployeeRecords(records);
           
           // Add grouping metadata
           result.metadataMap = new Map<String, Object>{
               'grouping' => 'multi-field',
               'groupFields' => normalizedFields,
               'groupFieldLabels' => fieldLabels,
               'groupCounts' => groupCounts,
               'totalRecordsGrouped' => records.size()
           };
           
           return result;
           
       } catch (Exception e) {
           result.success = false;
           result.message = 'Error grouping by multiple fields: ' + e.getMessage();
           System.debug('Multi-field grouping error: ' + e.getMessage());
           return result;
       }
   }
   
   // Helper method to get month name
   private String getMonthName(Integer monthNumber) {
       List<String> months = new List<String>{
           'January', 'February', 'March', 'April', 'May', 'June', 
           'July', 'August', 'September', 'October', 'November', 'December'
       };
       
       if (monthNumber < 1 || monthNumber > 12) {
           return 'Unknown Month';
       }
       
       return months[monthNumber - 1];
   }
   
   // Helper method to get field label
   private String getFieldLabel(String fieldName) {
       try {
           Schema.SObjectField field = Schema.SObjectType.Learner_Profile__c.fields.getMap().get(fieldName);
           if (field != null) {
               return field.getDescribe().getLabel();
           }
           
           // If field not found in schema, try to make a readable version of API name
           return fieldName.replace('__c', '').replace('_', ' ');
       } catch (Exception e) {
           System.debug('Error getting field label: ' + e.getMessage());
           return fieldName.replace('__c', '');
       }
   }
}