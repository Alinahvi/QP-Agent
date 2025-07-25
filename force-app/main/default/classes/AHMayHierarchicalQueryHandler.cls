public class AHMayHierarchicalQueryHandler implements AHMayQueryHandler {
    
    public AHMayQueryResult handleQuery(AHMayQueryRequest request, Map<String, Object> queryData) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            // Debug: Check input data
            System.debug('Hierarchical Query Data: ' + JSON.serialize(queryData));
            
            // Handle multiple managers in hierarchical queries
            if (queryData.containsKey('HIERARCHICAL_QUERY_OR')) {
                return handleMultipleManagers(request, queryData);
            }
            
            // Safe null check for manager name
            Object managerObj = queryData.get('HIERARCHICAL_QUERY');
            if (managerObj == null) {
                result.success = false;
                result.message = 'No manager specified for hierarchical query.';
                return result;
            }
            
            String managerName = String.valueOf(managerObj);
            System.debug('Manager Name: ' + managerName);
            
            String managerEmail = findManagerEmail(managerName);
            System.debug('Manager Email: ' + managerEmail);
            
            if (String.isBlank(managerEmail)) {
                result.success = false;
                result.message = 'Could not find manager: ' + managerName + 
                              '. Please check the spelling or provide more specific information.';
                return result;
            }
            
            // Build the chain condition for all levels
            List<String> chainConditions = buildChainConditions(managerEmail);
            
            // Extract additional conditions using AHMayQueryUtils
            Map<String, Object> additionalConditions = AHMayQueryUtils.extractQueryFields(queryData);
            System.debug('Additional Conditions: ' + JSON.serialize(additionalConditions));
            
            // Check for date conditions
            Boolean hasDateConditions = false;
            for (String key : additionalConditions.keySet()) {
                if (key.startsWith('Hire_Date__c')) {
                    hasDateConditions = true;
                    System.debug('Found date condition: ' + key + ' = ' + additionalConditions.get(key));
                }
            }
            
            // If we have Hire_Date__c_RANGE in the original query, process it directly
            if (queryData.containsKey('Hire_Date__c_RANGE')) {
                Object rangeObj = queryData.get('Hire_Date__c_RANGE');
                if (rangeObj instanceof Map<String, Object>) {
                    System.debug('Found Hire_Date__c_RANGE: ' + JSON.serialize(rangeObj));
                    Map<String, Object> rangeMap = (Map<String, Object>)rangeObj;
                    additionalConditions.put('Hire_Date__c_RANGE', rangeMap);
                }
            }
            
            // Build query with pagination
            Integer pageSize = 20;
            Integer offset = (request.pageNumber != null ? request.pageNumber - 1 : 0) * pageSize;
            
            String query = buildHierarchicalQuery(chainConditions, additionalConditions, pageSize, offset);
            System.debug('Hierarchical Query: ' + query);
            
            // Execute the query
            List<Learner_Profile__c> orgMembers = Database.query(query);
            System.debug('Org Members Found: ' + orgMembers.size());
            
            // Get the count
            Integer totalCount = getHierarchicalQueryCount(chainConditions, additionalConditions);
            System.debug('Total Count: ' + totalCount);
            
            // If we found results, store them in the cache for future use
            if (!orgMembers.isEmpty() && request.sessionId != null) {
                AHMayQueryCache.storeResults(request.sessionId, orgMembers);
                AHMaySessionContext.storeSessionTotalCount(request.sessionId, totalCount);
                System.debug('Stored ' + orgMembers.size() + ' records in cache for session ' + request.sessionId);
                
                // Store the query context for follow-up operations
                AHMaySessionContext.storeQueryContext(request.sessionId, queryData);
            }
            
            // Format results
            return formatHierarchicalResult(managerName, orgMembers, totalCount, 
                                         request.pageNumber, query, !additionalConditions.isEmpty());
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error processing hierarchical query: ' + e.getMessage() + 
                           ' (Line: ' + e.getLineNumber() + ')';
            System.debug('Hierarchical Error: ' + e.getMessage());
            System.debug('Stack Trace: ' + e.getStackTraceString());
        }
        
        return result;
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
    
    private String buildHierarchicalQuery(List<String> chainConditions, Map<String, Object> additionalConditions, 
                                         Integer pageSize, Integer offset) {
        // Get hierarchical fields from AHMayFieldConstants
        List<String> selectFields = AHMayFieldConstants.getHierarchicalFields();
        
        String query = 'SELECT ' + String.join(selectFields, ', ') + 
                      ' FROM Learner_Profile__c WHERE Status__c = \'Active\'';
        
        // Add chain conditions only if they exist
        if (chainConditions != null && !chainConditions.isEmpty()) {
            query += ' AND (' + String.join(chainConditions, ' OR ') + ')';
        }
        
        // Use AHMayQueryUtils to build additional conditions
        List<String> conditions = AHMayQueryUtils.buildWhereConditions(additionalConditions);
        
        // Add conditions to the query (excluding Status__c which is already added)
        for (String condition : conditions) {
            if (!condition.startsWith('Status__c')) {
                query += ' AND ' + condition;
            }
        }
        
        // Add pagination
        query += ' ORDER BY Name ASC LIMIT ' + pageSize + ' OFFSET ' + offset;
        
        return query;
    }
    
    private Integer getHierarchicalQueryCount(List<String> chainConditions, Map<String, Object> additionalConditions) {
        String countQuery = 'SELECT COUNT() FROM Learner_Profile__c WHERE Status__c = \'Active\'';
        
        // Add chain conditions only if they exist
        if (chainConditions != null && !chainConditions.isEmpty()) {
            countQuery += ' AND (' + String.join(chainConditions, ' OR ') + ')';
        }
        
        // Use AHMayQueryUtils to build additional conditions
        List<String> conditions = AHMayQueryUtils.buildWhereConditions(additionalConditions);
        
        // Add conditions to the query (excluding Status__c which is already added)
        for (String condition : conditions) {
            if (!condition.startsWith('Status__c')) {
                countQuery += ' AND ' + condition;
            }
        }
        
        System.debug('Count Query: ' + countQuery);
        return Database.countQuery(countQuery);
    }
    
    private AHMayQueryResult formatHierarchicalResult(String managerName, List<Learner_Profile__c> orgMembers, 
                                                Integer totalCount, Integer pageNumber, String query, 
                                                Boolean isFiltered) {
        AHMayQueryResult result = new AHMayQueryResult();
        Integer pageSize = 20;
        
        result.success = true;
        result.totalRecords = totalCount;
        result.pageNumber = pageNumber != null ? pageNumber : 1;
        result.records = AHMayResultFormatter.formatEmployeeRecords(orgMembers);
        
        Integer totalPages = Math.max(1, (Integer) Math.ceil(totalCount / (Double)pageSize));
        
        // Use the new concise format for initial results
        if (totalCount == 0) {
            result.message = 'No employees found in this organization structure.\n';
            result.message += 'Try checking the spelling or be more specific about the manager name.';
        } else {
            // Use our new formatter for a more concise view
            result.message = AHMayResultFormatter.formatHierarchicalSummary(
                managerName, orgMembers, totalCount, result.pageNumber, totalPages, isFiltered);
        }
        
        result.queryUsed = query;
        result.hasMore = (totalCount > (result.pageNumber - 1) * pageSize + orgMembers.size());
        result.parsedQuery = isFiltered ? 'Filtered organization for: ' + managerName : 'Organization for: ' + managerName;
        
        // Add metadata to indicate this is a hierarchical query result for context
        if (result.metadataMap == null) {
            result.metadataMap = new Map<String, Object>();
        }
        result.metadataMap.put('queryType', 'HIERARCHICAL');
        result.metadataMap.put('managerName', managerName);
        
        return result;
    }
    
    private AHMayQueryResult handleMultipleManagers(AHMayQueryRequest request, Map<String, Object> queryData) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            // Get the list of managers with null check
            Object managersObj = queryData.get('HIERARCHICAL_QUERY_OR');
            if (managersObj == null) {
                result.success = false;
                result.message = 'No managers specified for multiple manager hierarchical query.';
                return result;
            }
            
            List<Object> managerObjs = (List<Object>)managersObj;
            List<String> managerNames = new List<String>();
            List<String> managerEmails = new List<String>();
            
            for (Object obj : managerObjs) {
                if (obj != null) {
                    String managerName = String.valueOf(obj);
                    managerNames.add(managerName);
                    
                    // Find email for each manager
                    String email = findManagerEmail(managerName);
                    if (!String.isBlank(email)) {
                        managerEmails.add(email);
                    }
                }
            }
            
            if (managerEmails.isEmpty()) {
                result.success = false;
                result.message = 'Could not find any of the specified managers: ' + String.join(managerNames, ', ') + 
                              '. Please check the spelling or provide more specific information.';
                return result;
            }
            
            // Build all chain conditions
            List<String> allChainConditions = new List<String>();
            
            for (String email : managerEmails) {
                List<String> managerChainConditions = buildChainConditions(email);
                if (!managerChainConditions.isEmpty()) {
                    allChainConditions.add('(' + String.join(managerChainConditions, ' OR ') + ')');
                }
            }
            
            // Extract additional conditions using AHMayQueryUtils
            Map<String, Object> additionalConditions = AHMayQueryUtils.extractQueryFields(queryData);
            
            // Build query with pagination
            Integer pageSize = 20;
            Integer offset = (request.pageNumber != null ? request.pageNumber - 1 : 0) * pageSize;
            
            // Get hierarchical fields from AHMayFieldConstants
            List<String> selectFields = AHMayFieldConstants.getHierarchicalFields();
            
            String query = 'SELECT ' + String.join(selectFields, ', ') + 
                         ' FROM Learner_Profile__c WHERE Status__c = \'Active\'';
            
            // Add chain conditions only if they exist
            if (!allChainConditions.isEmpty()) {
                query += ' AND (' + String.join(allChainConditions, ' OR ') + ')';
            }
            
            // Use AHMayQueryUtils to build additional conditions
            List<String> conditions = AHMayQueryUtils.buildWhereConditions(additionalConditions);
            
            // Add conditions to the query (excluding Status__c which is already added)
            for (String condition : conditions) {
                if (!condition.startsWith('Status__c')) {
                    query += ' AND ' + condition;
                }
            }
            
            // Add pagination
            query += ' ORDER BY Name ASC LIMIT ' + pageSize + ' OFFSET ' + offset;
            
            // Execute query
            List<Learner_Profile__c> orgMembers = Database.query(query);
            
            // Get total count
            String countQuery = 'SELECT COUNT() FROM Learner_Profile__c WHERE Status__c = \'Active\'';
            
            // Add chain conditions only if they exist
            if (!allChainConditions.isEmpty()) {
                countQuery += ' AND (' + String.join(allChainConditions, ' OR ') + ')';
            }
                             
            // Add conditions to the query (excluding Status__c which is already added)
            for (String condition : conditions) {
                if (!condition.startsWith('Status__c')) {
                    countQuery += ' AND ' + condition;
                }
            }
            
            Integer totalCount = Database.countQuery(countQuery);
            
            // Store results in cache if we have a session ID
            if (!orgMembers.isEmpty() && request.sessionId != null) {
                AHMayQueryCache.storeResults(request.sessionId, orgMembers);
                AHMaySessionContext.storeSessionTotalCount(request.sessionId, totalCount);
                
                // Store query context for follow-up operations
                AHMaySessionContext.storeQueryContext(request.sessionId, queryData);
            }
            
            // Format results
            result.success = true;
            result.totalRecords = totalCount;
            result.pageNumber = request.pageNumber != null ? request.pageNumber : 1;
            result.records = AHMayResultFormatter.formatEmployeeRecords(orgMembers);
            
            String managerList = String.join(managerNames, ' or ');
            Integer totalPages = Math.max(1, (Integer) Math.ceil(totalCount / (Double)pageSize));
            
            if (totalCount == 0) {
                result.message = 'No employees found in the organization of any of these managers: ' + managerList + '.\n';
                result.message += 'Try checking the spelling or provide more specific information.';
            } else {
                // Use our new formatter for a more concise view
                result.message = AHMayResultFormatter.formatHierarchicalSummary(
                    managerList, orgMembers, totalCount, result.pageNumber, totalPages, 
                    !additionalConditions.isEmpty());
            }
            
            result.queryUsed = query;
            result.hasMore = (totalCount > offset + pageSize);
            result.parsedQuery = 'Organization for multiple managers: ' + managerList;
            
            // Add metadata to indicate this is a hierarchical query result for context
            if (result.metadataMap == null) {
                result.metadataMap = new Map<String, Object>();
            }
            result.metadataMap.put('queryType', 'HIERARCHICAL_MULTIPLE');
            result.metadataMap.put('managerNames', managerNames);
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error finding organization: ' + e.getMessage();
        }
        
        return result;
    }
    
    private String findManagerEmail(String managerName) {
        try {
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
            
            return '';
        } catch (Exception e) {
            System.debug('Error finding manager email: ' + e.getMessage());
            return '';
        }
    }
}