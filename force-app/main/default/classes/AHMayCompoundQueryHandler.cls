public class AHMayCompoundQueryHandler implements AHMayQueryHandler {
    
    public AHMayQueryResult handleQuery(AHMayQueryRequest request, Map<String, Object> queryData) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            System.debug('AHMayCompoundQueryHandler - Processing compound query: ' + JSON.serialize(queryData));
            
            // Step 1: Determine primary intent (querying data)
            Map<String, Object> primaryQueryData = extractPrimaryQueryData(queryData);
            System.debug('Primary query data: ' + JSON.serialize(primaryQueryData));
            
            // Step 2: Execute primary query to get base dataset
            AHMayQueryHandler primaryHandler = getPrimaryHandler(primaryQueryData);
            AHMayQueryResult primaryResult = primaryHandler.handleQuery(request, primaryQueryData);
            
            if (!primaryResult.success || primaryResult.totalRecords == 0) {
                // If primary query fails or returns no data, just return its result
                return primaryResult;
            }
            
            // Step 3: Process secondary intent if present
            Map<String, Object> secondaryQueryData = extractSecondaryQueryData(queryData);
            System.debug('Secondary query data: ' + JSON.serialize(secondaryQueryData));
            
            if (secondaryQueryData != null && !secondaryQueryData.isEmpty()) {
                // We need session ID for context between handler calls
                if (String.isBlank(request.sessionId)) {
                    // Can't process secondary without session context
                    result = primaryResult;
                    result.message += '\n\nNote: A secondary operation was requested but requires a session context.';
                } else {
                    // Store primary result in cache for secondary handler to use
                    if (primaryResult.records != null && !primaryResult.records.isEmpty()) {
                        // Convert back to Learner_Profile__c records
                        List<Learner_Profile__c> profiles = convertToProfiles(primaryResult.records);
                        AHMayQueryCache.storeResults(request.sessionId, profiles);
                        AHMaySessionContext.storeSessionTotalCount(request.sessionId, primaryResult.totalRecords);
                    }
                    
                    // Execute secondary handler
                    AHMayQueryHandler secondaryHandler = getSecondaryHandler(secondaryQueryData);
                    AHMayQueryResult secondaryResult = secondaryHandler.handleQuery(request, secondaryQueryData);
                    
                    if (secondaryResult.success) {
                        result = secondaryResult;
                    } else {
                        // If secondary processing fails, return primary result with a note
                        result = primaryResult;
                        result.message += '\n\nNote: Secondary processing failed: ' + secondaryResult.message;
                    }
                }
            } else {
                // No secondary intent, just return primary result
                result = primaryResult;
            }
            
            // Add compound query context to result
            result.metadataMap = result.metadataMap != null ? result.metadataMap : new Map<String, Object>();
            result.metadataMap.put('isCompoundQuery', true);
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error processing compound query: ' + e.getMessage() + 
                           ' (Line: ' + e.getLineNumber() + ')';
            System.debug(LoggingLevel.ERROR, 'Compound Query Error: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack Trace: ' + e.getStackTraceString());
        }
        
        return result;
    }
    
    // Extract primary query data (filtering and employee fetching)
    private Map<String, Object> extractPrimaryQueryData(Map<String, Object> queryData) {
        Map<String, Object> primaryData = new Map<String, Object>(queryData);
        
        // Remove aggregation and analysis intents
        primaryData.remove('AGGREGATION');
        primaryData.remove('GROUP_BY_FIELD');
        primaryData.remove('GROUP_BY_FIELDS');
        primaryData.remove('GROUP_BY_DATE_UNIT');
        primaryData.remove('ANALYSIS');
        
        return primaryData;
    }
    
    // Extract secondary query data (usually aggregation or analysis)
    private Map<String, Object> extractSecondaryQueryData(Map<String, Object> queryData) {
        Map<String, Object> secondaryData = new Map<String, Object>();
        
        // Check for aggregation intent
        if ((queryData.containsKey('AGGREGATION') && (Boolean)queryData.get('AGGREGATION')) || 
            queryData.containsKey('GROUP_BY_FIELD') || 
            queryData.containsKey('GROUP_BY_FIELDS')) {
            
            secondaryData.put('AGGREGATION', true);
            secondaryData.put('MAINTAIN_PREVIOUS_CONTEXT', true);
            
            // Copy grouping parameters
            if (queryData.containsKey('GROUP_BY_FIELD')) {
                secondaryData.put('GROUP_BY_FIELD', queryData.get('GROUP_BY_FIELD'));
            }
            
            if (queryData.containsKey('GROUP_BY_FIELDS')) {
                secondaryData.put('GROUP_BY_FIELDS', queryData.get('GROUP_BY_FIELDS'));
            }
            
            if (queryData.containsKey('GROUP_BY_DATE_UNIT')) {
                secondaryData.put('GROUP_BY_DATE_UNIT', queryData.get('GROUP_BY_DATE_UNIT'));
            }
            
            return secondaryData;
        }
        
        // Check for analysis intent
        if (queryData.containsKey('ANALYSIS') && (Boolean)queryData.get('ANALYSIS')) {
            secondaryData.put('ANALYSIS', true);
            secondaryData.put('MAINTAIN_PREVIOUS_CONTEXT', true);
            return secondaryData;
        }
        
        // No secondary intent found
        return null;
    }
    
    // Get the primary handler (for fetching employees)
    private AHMayQueryHandler getPrimaryHandler(Map<String, Object> primaryData) {
        // Hierarchical query takes precedence
        if (primaryData.containsKey('HIERARCHICAL_QUERY') || 
            primaryData.containsKey('HIERARCHICAL_QUERY_OR')) {
            return new AHMayHierarchicalQueryHandler();
        }
        
        // Then direct reports
        if (primaryData.containsKey('DIRECT_REPORTS') || 
            primaryData.containsKey('DIRECT_REPORTS_OR')) {
            return new AHMayDirectReportsQueryHandler();
        }
        
        // Then employee details
        if (primaryData.containsKey('EMPLOYEE_DETAILS')) {
            return new AHMayEmployeeDetailsQueryHandler();
        }
        
        // Default to standard handler for attribute-based queries
        return new AHMayStandardQueryHandler();
    }
    
    // Get the secondary handler (usually for aggregation)
    private AHMayQueryHandler getSecondaryHandler(Map<String, Object> secondaryData) {
        // Most secondary operations are aggregations
        if ((secondaryData.containsKey('AGGREGATION') && (Boolean)secondaryData.get('AGGREGATION')) ||
            secondaryData.containsKey('GROUP_BY_FIELD') || 
            secondaryData.containsKey('GROUP_BY_FIELDS')) {
            return new AHMayAggregationHandler();
        }
        
        // Future: could add more secondary handlers here
        
        // Default to standard handler
        return new AHMayStandardQueryHandler();
    }
    
    // Convert AHMayEmployeeRecord list back to Learner_Profile__c records
    private List<Learner_Profile__c> convertToProfiles(List<AHMayEmployeeRecord> records) {
        List<Learner_Profile__c> profiles = new List<Learner_Profile__c>();
        
        for (AHMayEmployeeRecord record : records) {
            Learner_Profile__c profile = new Learner_Profile__c(
                Id = record.recordId,
                Name = record.name,
                Primary_Email__c = record.email,
                Manager__c = record.manager,
                Manager_Email__c = record.managerEmail
            );
            
            // Add other fields from metadata map if available
            if (record.metadataMap != null) {
                for (String field : record.metadataMap.keySet()) {
                    Object value = record.metadataMap.get(field);
                    
                    // Handle common field mappings
                    if (field == 'division') {
                        profile.Division__c = (String)value;
                    } else if (field == 'jobFamily') {
                        profile.Job_Family__c = (String)value;
                    } else if (field == 'location') {
                        profile.Employee_Location__c = (String)value;
                    } else if (field == 'businessUnit') {
                        profile.Business_Unit_Name__c = (String)value;
                    } else if (field == 'isFTE') {
                        profile.FTE__c = (Boolean)value;
                    } else if (field == 'isCommissionable') {
                        profile.Commissionable__c = (Boolean)value;
                    } else if (field == 'jobCode') {
                        profile.Job_Code__c = (String)value;
                    } else if (field == 'costCenterName') {
                        profile.Cost_Center_Name__c = (String)value;
                    } else if (field == 'costCenterId') {
                        profile.Cost_Center_ID__c = (String)value;
                    } else if (field == 'hireDate' && value instanceof String) {
                        try {
                            profile.Hire_Date__c = Date.valueOf((String)value);
                        } catch (Exception e) {
                            // Skip if date can't be parsed
                        }
                    } else if (field == 'country') {
                        profile.Work_Location_Country__c = (String)value;
                    } else if (field == 'daysInRole' && value instanceof Integer) {
                        profile.Days_in_Current_Role__c = (Integer)value;
                    } else if (field == 'isFLM') {
                        profile.Is_FLM__c = (Boolean)value;
                    } 
                    // Add new field mappings
                    else if (field == 'sellerGroup') {
                        profile.Seller_Group__c = (String)value;
                    } else if (field == 'macroSegment') {
                        profile.Macro_Segment__c = (String)value;
                    } else if (field == 'primaryIndustry') {
                        profile.em_Industry__c = (String)value;
                    }
                    // Management chain fields would need special handling here too
                }
            }
            
            profiles.add(profile);
        }
        
        return profiles;
    }
}