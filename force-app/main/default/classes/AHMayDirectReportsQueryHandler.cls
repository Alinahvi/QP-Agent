public class AHMayDirectReportsQueryHandler implements AHMayQueryHandler {
    
    public AHMayQueryResult handleQuery(AHMayQueryRequest request, Map<String, Object> queryData) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            // Debug: Check input data
            System.debug('DirectReports Query Data: ' + JSON.serialize(queryData));
            
            // Handle multiple managers in direct reports queries
            if (queryData.containsKey('DIRECT_REPORTS_OR')) {
                return handleMultipleManagers(request, queryData);
            }
            
            // Safe null check for manager name
            Object managerObj = queryData.get('DIRECT_REPORTS');
            if (managerObj == null) {
                result.success = false;
                result.message = 'No manager specified for direct reports query.';
                return result;
            }
            
            String managerName = String.valueOf(managerObj);
            System.debug('Manager Name: ' + managerName);
            
            // Extract additional conditions using AHMayQueryUtils
            Map<String, Object> conditions = AHMayQueryUtils.extractQueryFields(queryData);
            System.debug('Additional Conditions: ' + JSON.serialize(conditions));
            
            // Try direct match on Manager__c field
            String nameQuery = buildDirectReportsQuery(managerName, conditions, request.pageNumber);
            System.debug('Name Query: ' + nameQuery);
            
            List<Learner_Profile__c> directReports = Database.query(nameQuery);
            System.debug('Direct Reports Found: ' + directReports.size());
            
            if (!directReports.isEmpty()) {
                // Query worked - format results
                return formatDirectReportsResult(managerName, directReports, 
                                               getDirectReportsCount(managerName, conditions), 
                                               request.pageNumber, nameQuery, 
                                               !conditions.isEmpty());
            }
            
            // Try with email lookup if name match didn't work
            String managerEmail = findManagerEmail(managerName);
            System.debug('Manager Email: ' + managerEmail);
            
            if (String.isBlank(managerEmail)) {
                result.success = false;
                result.message = 'Could not find manager: ' + managerName + 
                              '. Please check the spelling or provide more specific information.';
                return result;
            }
            
            String emailQuery = buildDirectReportsByEmailQuery(managerEmail, conditions, request.pageNumber);
            System.debug('Email Query: ' + emailQuery);
            
            List<Learner_Profile__c> emailDirectReports = Database.query(emailQuery);
            System.debug('Email Direct Reports Found: ' + emailDirectReports.size());
            
            return formatDirectReportsResult(managerName, emailDirectReports, 
                                         getDirectReportsByEmailCount(managerEmail, conditions), 
                                         request.pageNumber, emailQuery, 
                                         !conditions.isEmpty());
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error finding direct reports: ' + e.getMessage() + 
                           ' (Line: ' + e.getLineNumber() + ')';
            System.debug('DirectReports Error: ' + e.getMessage());
            System.debug('Stack Trace: ' + e.getStackTraceString());
        }
        
        return result;
    }
    
    private String buildDirectReportsQuery(String managerName, Map<String, Object> conditions, Integer pageNumber) {
        Integer pageSize = 20;
        Integer offset = (pageNumber != null ? pageNumber - 1 : 0) * pageSize;
        
        // Get standard fields from AHMayFieldConstants
        List<String> selectFields = AHMayFieldConstants.getStandardFields();
        
        String query = 'SELECT ' + String.join(selectFields, ', ') + 
                     ' FROM Learner_Profile__c WHERE Status__c = \'Active\' AND ' +
                     'Manager__c = \'' + String.escapeSingleQuotes(managerName) + '\'';
        
        // Use AHMayQueryUtils to build additional conditions
        List<String> additionalConditions = AHMayQueryUtils.buildWhereConditions(conditions);
        
        // Add conditions to the query (excluding Status__c which is already added)
        for (String condition : additionalConditions) {
            if (!condition.startsWith('Status__c')) {
                query += ' AND ' + condition;
            }
        }
        
        // Add pagination
        query += ' ORDER BY Name ASC LIMIT ' + pageSize + ' OFFSET ' + offset;
        
        return query;
    }
    
    private String buildDirectReportsByEmailQuery(String managerEmail, Map<String, Object> conditions, Integer pageNumber) {
        Integer pageSize = 20;
        Integer offset = (pageNumber != null ? pageNumber - 1 : 0) * pageSize;
        
        // Get standard fields from AHMayFieldConstants
        List<String> selectFields = AHMayFieldConstants.getStandardFields();
        
        String query = 'SELECT ' + String.join(selectFields, ', ') + 
                     ' FROM Learner_Profile__c WHERE Status__c = \'Active\' AND ' +
                     'Manager_Email__c = \'' + String.escapeSingleQuotes(managerEmail) + '\'';
        
        // Use AHMayQueryUtils to build additional conditions
        List<String> additionalConditions = AHMayQueryUtils.buildWhereConditions(conditions);
        
        // Add conditions to the query (excluding Status__c which is already added)
        for (String condition : additionalConditions) {
            if (!condition.startsWith('Status__c')) {
                query += ' AND ' + condition;
            }
        }
        
        // Add pagination
        query += ' ORDER BY Name ASC LIMIT ' + pageSize + ' OFFSET ' + offset;
        
        return query;
    }
    
    private Integer getDirectReportsCount(String managerName, Map<String, Object> conditions) {
        String countQuery = 'SELECT COUNT() FROM Learner_Profile__c WHERE ' +
                         'Status__c = \'Active\' AND ' +
                         'Manager__c = \'' + String.escapeSingleQuotes(managerName) + '\'';
        
        // Use AHMayQueryUtils to build additional conditions
        List<String> additionalConditions = AHMayQueryUtils.buildWhereConditions(conditions);
        
        // Add conditions to the query (excluding Status__c which is already added)
        for (String condition : additionalConditions) {
            if (!condition.startsWith('Status__c')) {
                countQuery += ' AND ' + condition;
            }
        }
        
        return Database.countQuery(countQuery);
    }
    
    private Integer getDirectReportsByEmailCount(String managerEmail, Map<String, Object> conditions) {
        String countQuery = 'SELECT COUNT() FROM Learner_Profile__c WHERE ' +
                         'Status__c = \'Active\' AND ' +
                         'Manager_Email__c = \'' + String.escapeSingleQuotes(managerEmail) + '\'';
        
        // Use AHMayQueryUtils to build additional conditions
        List<String> additionalConditions = AHMayQueryUtils.buildWhereConditions(conditions);
        
        // Add conditions to the query (excluding Status__c which is already added)
        for (String condition : additionalConditions) {
            if (!condition.startsWith('Status__c')) {
                countQuery += ' AND ' + condition;
            }
        }
        
        return Database.countQuery(countQuery);
    }
    
    private AHMayQueryResult formatDirectReportsResult(String managerName, List<Learner_Profile__c> directReports, 
                                                Integer totalCount, Integer pageNumber, String query, 
                                                Boolean isFiltered) {
        AHMayQueryResult result = new AHMayQueryResult();
        Integer pageSize = 20;
        
        result.success = true;
        result.totalRecords = totalCount;
        result.pageNumber = pageNumber != null ? pageNumber : 1;
        result.records = AHMayResultFormatter.formatEmployeeRecords(directReports);
        
        Integer totalPages = Math.max(1, (Integer) Math.ceil(totalCount / (Double)pageSize));
        
        // Create descriptive prefix for the message
        String contextPrefix = isFiltered ? 'Filtered direct reports for: ' : 'Direct reports for: ';
        
        if (totalCount == 0) {
            result.message = 'No direct reports found for this manager with these criteria.\n';
            result.message += 'Try checking the spelling or adjusting your search criteria.';
        } else {
            // Use our new formatter for a more concise view
            result.message = AHMayResultFormatter.formatHierarchicalSummary(
                managerName, directReports, totalCount, result.pageNumber, totalPages, isFiltered);
            
            // Modify first line to indicate these are direct reports
            result.message = result.message.replace(
                isFiltered ? 'Filtered organization for: ' : 'Organization for: ',
                contextPrefix
            );
            
            // Use appropriate language for direct reports, not organization
            result.message = result.message.replace(
                'total employees** in ' + managerName + '\'s organization',
                'total employees** who report directly to ' + managerName
            );
        }
        
        result.queryUsed = query;
        result.hasMore = (totalCount > (result.pageNumber - 1) * pageSize + directReports.size());
        result.parsedQuery = contextPrefix + managerName;
        
        // Add metadata to indicate this is a direct reports query result for context
        if (result.metadataMap == null) {
            result.metadataMap = new Map<String, Object>();
        }
        result.metadataMap.put('queryType', 'DIRECT_REPORTS');
        result.metadataMap.put('managerName', managerName);
        
        return result;
    }
    
    private AHMayQueryResult handleMultipleManagers(AHMayQueryRequest request, Map<String, Object> queryData) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            // Get the list of managers with null check
            Object managersObj = queryData.get('DIRECT_REPORTS_OR');
            if (managersObj == null) {
                result.success = false;
                result.message = 'No managers specified for multiple manager direct reports query.';
                return result;
            }
            
            List<Object> managerObjs = (List<Object>)managersObj;
            List<String> managerNames = new List<String>();
            
            for (Object obj : managerObjs) {
                if (obj != null) {
                    managerNames.add(String.valueOf(obj));
                }
            }
            
            if (managerNames.isEmpty()) {
                result.success = false;
                result.message = 'No valid managers found in the query.';
                return result;
            }
            
            // Create conditions for each manager
            List<String> managerConditions = new List<String>();
            
            for (String managerName : managerNames) {
                managerConditions.add('Manager__c = \'' + String.escapeSingleQuotes(managerName) + '\'');
                
                // Optionally add email-based conditions
                String managerEmail = findManagerEmail(managerName);
                if (!String.isBlank(managerEmail)) {
                    managerConditions.add('Manager_Email__c = \'' + String.escapeSingleQuotes(managerEmail) + '\'');
                }
            }
            
            // Extract additional filter conditions using AHMayQueryUtils
            Map<String, Object> additionalConditions = AHMayQueryUtils.extractQueryFields(queryData);
            
            // Build the query
            Integer pageSize = 20;
            Integer offset = (request.pageNumber != null ? request.pageNumber - 1 : 0) * pageSize;
            
            // Get standard fields from AHMayFieldConstants
            List<String> selectFields = AHMayFieldConstants.getStandardFields();
            
            String query = 'SELECT ' + String.join(selectFields, ', ') + 
                         ' FROM Learner_Profile__c WHERE Status__c = \'Active\' AND ' +
                         '(' + String.join(managerConditions, ' OR ') + ')';
            
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
            
            // Execute the query
            List<Learner_Profile__c> employees = Database.query(query);
            
            // Get total count
            String countQuery = 'SELECT COUNT() FROM Learner_Profile__c WHERE Status__c = \'Active\' AND ' +
                             '(' + String.join(managerConditions, ' OR ') + ')';
                             
            // Add conditions to the query (excluding Status__c which is already added)
            for (String condition : conditions) {
                if (!condition.startsWith('Status__c')) {
                    countQuery += ' AND ' + condition;
                }
            }
            
            Integer totalCount = Database.countQuery(countQuery);
            
            // Format results
            result.success = true;
            result.totalRecords = totalCount;
            result.pageNumber = request.pageNumber != null ? request.pageNumber : 1;
            result.records = AHMayResultFormatter.formatEmployeeRecords(employees);
            
            String managerList = String.join(managerNames, ' or ');
            Integer totalPages = Math.max(1, (Integer) Math.ceil(totalCount / (Double)pageSize));
            
            if (totalCount == 0) {
                result.message = 'No direct reports found for any of these managers: ' + managerList + '.\n';
                result.message += 'Try checking the spelling or provide more specific information.';
            } else {
                // Use our new formatter for a more concise view
                result.message = AHMayResultFormatter.formatHierarchicalSummary(
                    managerList, employees, totalCount, result.pageNumber, totalPages, 
                    !additionalConditions.isEmpty());
                
                // Modify first line to indicate these are direct reports
                result.message = result.message.replace(
                    'Organization for: ',
                    'Direct reports for: '
                );
                
                // Use appropriate language for direct reports, not organization
                result.message = result.message.replace(
                    'total employees** in ' + managerList + '\'s organization',
                    'total employees** who report directly to any of these managers: ' + managerList
                );
            }
            
            result.queryUsed = query;
            result.hasMore = (totalCount > offset + pageSize);
            result.parsedQuery = 'Direct reports to multiple managers: ' + managerList;
            
            // Add metadata
            if (result.metadataMap == null) {
                result.metadataMap = new Map<String, Object>();
            }
            result.metadataMap.put('queryType', 'DIRECT_REPORTS_MULTIPLE');
            result.metadataMap.put('managerNames', managerNames);
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error finding direct reports: ' + e.getMessage();
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