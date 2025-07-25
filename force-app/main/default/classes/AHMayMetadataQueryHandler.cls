public class AHMayMetadataQueryHandler implements AHMayQueryHandler {
    
    public AHMayQueryResult handleQuery(AHMayQueryRequest request, Map<String, Object> queryData) {
        if (queryData == null) {
            AHMayQueryResult result = new AHMayQueryResult();
            result.success = false;
            result.message = 'No query data provided for metadata request.';
            return result;
        }
        
        Object metadataTypeObj = queryData.get('METADATA_REQUEST');
        if (metadataTypeObj == null) {
            return getDefaultMetadataResponse();
        }
        
        String metadataType = String.valueOf(metadataTypeObj);
        
        try {
            // Get all available fields
            if (metadataType == 'AVAILABLE_FIELDS') {
                return getAvailableFields();
            } 
            // Get possible values for a specific field
            else if (metadataType == 'FIELD_VALUES') {
                Object fieldNameObj = queryData.get('FIELD_NAME');
                if (fieldNameObj != null) {
                    String fieldName = String.valueOf(fieldNameObj);
                    
                    // Check for pagination request
                    Integer pageNumber = 1; // Default to first page
                    if (queryData.containsKey('PAGE_NUMBER')) {
                        Object pageObj = queryData.get('PAGE_NUMBER');
                        if (pageObj != null) {
                            try {
                                pageNumber = Integer.valueOf(String.valueOf(pageObj));
                            } catch (Exception e) {
                                // If page number is invalid, default to page 1
                                pageNumber = 1;
                            }
                        }
                    } else if (request.pageNumber != null) {
                        // Use page number from request if available
                        pageNumber = request.pageNumber;
                    } else if (request.userInput != null && 
                              (request.userInput.containsIgnoreCase('next page') || 
                               request.userInput.containsIgnoreCase('show more'))) {
                        // Check if this is a "next page" request
                        // In this case, we need to get the current page from session context
                        pageNumber = getCurrentPageFromContext(request.sessionId, fieldName);
                        pageNumber++; // Increment for next page
                    }
                    
                    // Store the current page and field in context for pagination
                    if (request.sessionId != null) {
                        storePageInContext(request.sessionId, fieldName, pageNumber);
                    }
                    
                    return getFieldValues(fieldName, pageNumber);
                } else {
                    AHMayQueryResult result = new AHMayQueryResult();
                    result.success = false;
                    result.message = 'No field name specified for field values request.';
                    return result;
                }
            }
            // Handle count-only requests
            else if (metadataType == 'FIELD_VALUES_COUNT') {
                Object fieldNameObj = queryData.get('FIELD_NAME');
                if (fieldNameObj != null) {
                    String fieldName = String.valueOf(fieldNameObj);
                    return getFieldValuesCount(fieldName);
                } else {
                    AHMayQueryResult result = new AHMayQueryResult();
                    result.success = false;
                    result.message = 'No field name specified for field values count request.';
                    return result;
                }
            }
            // Default response if metadata type is unknown
            else {
                return getDefaultMetadataResponse();
            }
        } catch (Exception e) {
            AHMayQueryResult result = new AHMayQueryResult();
            result.success = false;
            result.message = 'Error processing metadata request: ' + e.getMessage();
            return result;
        }
    }
    
    private AHMayQueryResult getDefaultMetadataResponse() {
        AHMayQueryResult result = new AHMayQueryResult();
        result.success = true;
        result.message = 'Employee data includes fields such as Name, Division, Job Family, Location, Business Unit, Manager, etc.\n\n' +
                         'You can ask for specific data using queries like:\n' +
                         '- "Show me all employees in AMER division"\n' +
                         '- "Who reports to Adam Hakey?"\n' +
                         '- "Show me full-time employees in marketing"';
        result.metadataMap = new Map<String, Object>{
            'helpText' => 'To see available fields, ask "What employee fields do you have?" To see possible values for a field, ask "What are the possible values for Division?"'
        };
        return result;
    }

    // Enhanced version of getFieldValues with pagination support
    private AHMayQueryResult getFieldValues(String fieldName, Integer pageNumber) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            // Default page number if not specified
            if (pageNumber == null) {
                pageNumber = 1;
            }
            
            // Standardize field name format
            String cleanFieldName = fieldName.endsWith('__c') ? fieldName : fieldName + '__c';
            
            // Handle mappings for slack-related fields
            if (AHMayQueryUtils.FIELD_MAPPINGS.containsKey(fieldName.toLowerCase())) {
                cleanFieldName = AHMayQueryUtils.FIELD_MAPPINGS.get(fieldName.toLowerCase());
            }
            
            // Check if field exists in the schema
            Schema.SObjectField field = Schema.SObjectType.Learner_Profile__c.fields.getMap().get(cleanFieldName);
            
            if (field == null) {
                result.success = false;
                result.message = 'Field \'' + fieldName + '\' not found in the employee database.';
                return result;
            }
            
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            
            // For picklist fields, get values directly - most efficient method
            if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST) {
                List<String> values = new List<String>();
                for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                    if (entry.isActive()) {
                        values.add(entry.getLabel());
                    }
                }
                
                values.sort();
                return formatFieldValuesResponseWithPagination(fieldName, values, false, cleanFieldName, pageNumber);
            }
            
            // For non-picklist fields, use aggregation with pagination
            Integer pageSize = 20; // Number of values to show per page
            Integer offset = (pageNumber - 1) * pageSize;
            
            String countQuery = 'SELECT COUNT(Id) FROM (SELECT ' + cleanFieldName + 
                              ' FROM Learner_Profile__c WHERE ' + cleanFieldName + 
                              ' != null GROUP BY ' + cleanFieldName + ')';
            
            Integer totalUniqueValues;
            try {
                totalUniqueValues = Database.countQuery(countQuery);
            } catch (Exception e) {
                // If count query fails, use a different approach to estimate
                totalUniqueValues = estimateUniqueValueCount(cleanFieldName);
            }
            
            String valuesQuery = 'SELECT ' + cleanFieldName + ', COUNT(Id) recordCount ' +
                               'FROM Learner_Profile__c ' +
                               'WHERE ' + cleanFieldName + ' != null ' +
                               'GROUP BY ' + cleanFieldName + ' ' +
                               'ORDER BY COUNT(Id) DESC ' +
                               'LIMIT ' + pageSize + ' OFFSET ' + offset;
            
            List<AggregateResult> results;
            try {
                results = Database.query(valuesQuery);
            } catch (Exception e) {
                // If aggregation fails, fall back to sampling
                return getFieldValuesSampleWithPagination(fieldName, cleanFieldName, pageNumber);
            }
            
            List<String> values = new List<String>();
            Map<String, Integer> valueCounts = new Map<String, Integer>();
            
            for (AggregateResult ar : results) {
                Object value = ar.get(cleanFieldName);
                if (value != null) {
                    String strValue = String.valueOf(value);
                    values.add(strValue);
                    valueCounts.put(strValue, (Integer)ar.get('recordCount'));
                }
            }
            
            // Format the paginated results
            AHMayQueryResult paginatedResult = formatFieldValuesResponseWithPagination(
                fieldName, values, false, cleanFieldName, pageNumber);
            
            // Add pagination metadata
            paginatedResult.totalRecords = totalUniqueValues;
            paginatedResult.pageNumber = pageNumber;
            paginatedResult.hasMore = (offset + pageSize < totalUniqueValues);
            
            // Add counts to the metadata
            if (paginatedResult.metadataMap == null) {
                paginatedResult.metadataMap = new Map<String, Object>();
            }
            paginatedResult.metadataMap.put('valueCounts', valueCounts);
            
            return paginatedResult;
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error retrieving values for ' + fieldName + ': ' + e.getMessage();
            return result;
        }
    }
    
    // Fallback method that provides paginated sampling
    private AHMayQueryResult getFieldValuesSampleWithPagination(String fieldName, String cleanFieldName, Integer pageNumber) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            Integer pageSize = 20;
            Integer offset = (pageNumber - 1) * pageSize;
            
            // Use sampling with pagination
            String sampleQuery = 'SELECT ' + cleanFieldName + ' ' +
                              'FROM Learner_Profile__c ' +
                              'WHERE ' + cleanFieldName + ' != null ' +
                              'GROUP BY ' + cleanFieldName + ' ' +
                              'ORDER BY ' + cleanFieldName + ' ' +
                              'LIMIT ' + pageSize + ' OFFSET ' + offset;
            
            List<SObject> records;
            try {
                records = Database.query(sampleQuery);
            } catch (Exception e) {
                // If the GROUP BY fails, try a simpler approach
                sampleQuery = 'SELECT ' + cleanFieldName + ' ' +
                            'FROM Learner_Profile__c ' +
                            'WHERE ' + cleanFieldName + ' != null ' +
                            'ORDER BY ' + cleanFieldName + ' ' +
                            'LIMIT ' + pageSize + ' OFFSET ' + offset;
                records = Database.query(sampleQuery);
            }
            
            // Count total unique values
            Integer totalUniqueValues = estimateUniqueValueCount(cleanFieldName);
            
            // Extract values
            List<String> values = new List<String>();
            for (SObject record : records) {
                Object value = record.get(cleanFieldName);
                if (value != null) {
                    values.add(String.valueOf(value));
                }
            }
            
            // Format paginated response
            AHMayQueryResult paginatedResult = formatFieldValuesResponseWithPagination(
                fieldName, values, true, cleanFieldName, pageNumber);
            
            // Add pagination metadata
            paginatedResult.totalRecords = totalUniqueValues;
            paginatedResult.pageNumber = pageNumber;
            paginatedResult.hasMore = (offset + pageSize < totalUniqueValues);
            
            return paginatedResult;
        } catch (Exception e) {
            result.success = false;
            result.message = 'Unable to retrieve values for ' + fieldName + 
                           ' due to data volume. This field may have many unique values. ' +
                           'You can still use this field in your queries with specific values.';
            result.metadataMap = new Map<String, Object>{
                'field' => cleanFieldName,
                'error' => 'Data volume too large'
            };
            return result;
        }
    }
    
    // Helper method to estimate the total count of unique values
    private Integer estimateUniqueValueCount(String fieldName) {
        try {
            // Try to get an estimate using LIMIT
            String countQuery = 'SELECT COUNT(Id) FROM (SELECT ' + fieldName + 
                              ' FROM Learner_Profile__c WHERE ' + fieldName + 
                              ' != null GROUP BY ' + fieldName + ' LIMIT 10000)';
            
            Integer count = Database.countQuery(countQuery);
            
            // If we hit the limit, note that it's a minimum count
            if (count == 10000) {
                return 10000; // Indicates "10000+" values
            }
            
            return count;
        } catch (Exception e) {
            // If even the count estimate fails, return a default
            return 1000; // Indicate a large number of values
        }
    }
    
    // Enhanced formatting method with pagination support
    private AHMayQueryResult formatFieldValuesResponseWithPagination(
        String fieldName, List<String> values, Boolean isSample, String cleanFieldName, Integer pageNumber) {
        
        AHMayQueryResult result = new AHMayQueryResult();
        result.success = true;
        
        Integer totalValues = values.size();
        
        String message = 'Values for ' + fieldName + ' (Page ' + pageNumber + '):\n\n';
        
        for (String value : values) {
            if (value != null) {
                message += '- ' + value + '\n';
            }
        }
        
        if (isSample) {
            message += '\n\nNote: This is a sample of values from the database. There may be additional values.';
        }
        
        // Add pagination guidance
        if (result.hasMore) {
            message += '\n\nThere are more values available. You can request the next page by saying "show more values" or "next page of values".';
        }
        
        result.message = message;
        result.metadataMap = new Map<String, Object>{
            'values' => values, 
            'field' => cleanFieldName,
            'is_sample' => isSample,
            'page_number' => pageNumber,
            'total_shown' => values.size()
        };
        
        return result;
    }
    
    // Helper method to get current page from session context
    private Integer getCurrentPageFromContext(String sessionId, String fieldName) {
        if (String.isBlank(sessionId)) {
            return 1; // Default to page 1 if no session
        }
        
        Map<String, Object> context = AHMaySessionContext.getQueryContext(sessionId);
        if (context == null || !context.containsKey('FIELD_VALUES_PAGE_' + fieldName)) {
            return 1; // Default to page 1 if no context or field page not found
        }
        
        Object pageObj = context.get('FIELD_VALUES_PAGE_' + fieldName);
        if (pageObj != null) {
            try {
                return Integer.valueOf(String.valueOf(pageObj));
            } catch (Exception e) {
                return 1; // Default to page 1 if page number is invalid
            }
        }
        
        return 1; // Default to page 1 as fallback
    }
    
    // Helper method to store current page in session context
    private void storePageInContext(String sessionId, String fieldName, Integer pageNumber) {
        if (String.isBlank(sessionId)) {
            return; // Can't store without session
        }
        
        Map<String, Object> context = AHMaySessionContext.getQueryContext(sessionId);
        if (context == null) {
            context = new Map<String, Object>();
        }
        
        context.put('FIELD_VALUES_PAGE_' + fieldName, pageNumber);
        context.put('LAST_FIELD_VALUES_QUERY', fieldName);
        
        AHMaySessionContext.storeQueryContext(sessionId, context);
    }
    
    // Handler for count-only field value queries
    private AHMayQueryResult getFieldValuesCount(String fieldName) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            // Clean field name
            String cleanFieldName = fieldName.endsWith('__c') ? fieldName : fieldName + '__c';
            
            // Handle mappings for slack-related fields
            if (AHMayQueryUtils.FIELD_MAPPINGS.containsKey(fieldName.toLowerCase())) {
                cleanFieldName = AHMayQueryUtils.FIELD_MAPPINGS.get(fieldName.toLowerCase());
            }
            
            // Check if field exists in schema
            Schema.SObjectField field = Schema.SObjectType.Learner_Profile__c.fields.getMap().get(cleanFieldName);
            
            if (field == null) {
                result.success = false;
                result.message = 'Field \'' + fieldName + '\' not found in the employee database.';
                return result;
            }
            
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            
            // For picklist fields, count picklist values
            if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST) {
                List<Schema.PicklistEntry> entries = fieldDescribe.getPicklistValues();
                Integer activeCount = 0;
                
                for (Schema.PicklistEntry entry : entries) {
                    if (entry.isActive()) {
                        activeCount++;
                    }
                }
                
                result.success = true;
                result.message = 'There ' + (activeCount == 1 ? 'is' : 'are') + ' ' + activeCount + 
                               ' possible ' + getLabelFromFieldName(cleanFieldName) + ' value' + 
                               (activeCount == 1 ? '' : 's') + '.\n\n' +
                               'You can see these values by asking "What ' + 
                               getLabelFromFieldName(cleanFieldName) + ' values are there?"';
                
                result.metadataMap = new Map<String, Object>{
                    'field' => cleanFieldName,
                    'count' => activeCount
                };
                
                return result;
            }
            
            // For non-picklist fields, count unique values
            Integer uniqueCount = estimateUniqueValueCount(cleanFieldName);
            
            // Format result
            result.success = true;
            String fieldLabel = getLabelFromFieldName(cleanFieldName);
            
            String message;
            if (uniqueCount >= 10000) {
                message = 'There are over 10,000 unique ' + fieldLabel + ' values in the database.\n\n';
                message += 'You can see these values by asking "What ' + fieldLabel + 
                         ' values are there?" and then use pagination to navigate through them.';
            } else {
                message = 'There ' + (uniqueCount == 1 ? 'is' : 'are') + ' ' + uniqueCount + 
                        ' unique ' + fieldLabel + ' value' + (uniqueCount == 1 ? '' : 's') + 
                        ' in the database.\n\n' +
                        'You can see ' + (uniqueCount > 20 ? 'these values in pages' : 'all these values') + 
                        ' by asking "What ' + fieldLabel + ' values are there?"';
            }
            
            result.message = message;
            result.metadataMap = new Map<String, Object>{
                'field' => cleanFieldName,
                'count' => uniqueCount
            };
            
            return result;
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error counting values for ' + fieldName + ': ' + e.getMessage();
            return result;
        }
    }
    
    /**
     * Get a user-friendly label from a field name
     */
    private String getLabelFromFieldName(String fieldName) {
        // Try to get label from schema
        try {
            Schema.SObjectField field = Schema.SObjectType.Learner_Profile__c.fields.getMap().get(fieldName);
            if (field != null) {
                return field.getDescribe().getLabel().toLowerCase();
            }
        } catch (Exception e) {
            // Fallback to normalizing the API name
        }
        
        // Normalize API name as fallback
        String normalized = fieldName.replace('__c', '').replace('_', ' ').toLowerCase();
        
        // Handle common pluralization
        if (normalized.endsWith('s')) {
            return normalized;
        } else {
            return normalized + 's';
        }
    }
    
    private AHMayQueryResult getAvailableFields() {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            // Get fields from AHMayFieldConstants and organize them
            List<String> standardFields = AHMayFieldConstants.getStandardFields();
            
            // Map field API names to display info
            Map<String, Map<String, String>> fieldInfo = getFieldDisplayInfo();
            
            List<Map<String, String>> fields = new List<Map<String, String>>();
            
            // Convert standard fields to display format
            for (String apiField : standardFields) {
                if (fieldInfo.containsKey(apiField)) {
                    fields.add(fieldInfo.get(apiField));
                }
            }
            
            // Format response with categories
            result.success = true;
            result.message = 'Here are the employee data fields you can query:\n\n';
            
            // Group fields by category
            Map<String, List<Map<String, String>>> categorizedFields = new Map<String, List<Map<String, String>>>();
            
            for (Map<String, String> field : fields) {
                String category = field.get('category');
                if (!categorizedFields.containsKey(category)) {
                    categorizedFields.put(category, new List<Map<String, String>>());
                }
                categorizedFields.get(category).add(field);
            }
            
            // Create formatted message with new categories in the specific order
            List<String> categoryOrder = new List<String>{
                'General Information',
                'Communication',
                'Management',
                'Job',
                'Location',
                'Organization'
            };
            
            for (String category : categoryOrder) {
                if (categorizedFields.containsKey(category)) {
                    result.message += '## ' + category + '\n';
                    for (Map<String, String> field : categorizedFields.get(category)) {
                        result.message += '- ' + field.get('label') + '\n';
                    }
                    result.message += '\n';
                }
            }
            
            result.message += 'You can ask questions like:\n';
            result.message += '- "Who reports to Adam Hakey?"\n';
            result.message += '- "Show me employees in AMER division"\n';
            result.message += '- "Find contractors in India"\n';
            result.message += '- "What are the possible values for Division?"\n';
            result.message += '- "Show me employees who started in February 2024"\n';
            result.message += '- "Show employees with Slack ID"\n';
            
            result.metadataMap = new Map<String, Object>{'fields' => fields};
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error retrieving field metadata: ' + e.getMessage();
        }
        
        return result;
    }
    
    // Helper method to map API field names to display info
    private Map<String, Map<String, String>> getFieldDisplayInfo() {
        Map<String, Map<String, String>> fieldInfo = new Map<String, Map<String, String>>{
            'Name' => new Map<String, String>{'name' => 'Name', 'label' => 'Employee Name', 'type' => 'STRING', 'category' => 'General Information'},
            'Primary_Email__c' => new Map<String, String>{'name' => 'Primary_Email__c', 'label' => 'Email', 'type' => 'EMAIL', 'category' => 'General Information'},
            'Manager__c' => new Map<String, String>{'name' => 'Manager__c', 'label' => 'Manager', 'type' => 'STRING', 'category' => 'Management'},
            'Manager_Email__c' => new Map<String, String>{'name' => 'Manager_Email__c', 'label' => 'Manager Email', 'type' => 'EMAIL', 'category' => 'Management'},
            'Manager_Level__c' => new Map<String, String>{'name' => 'Manager_Level__c', 'label' => 'Manager Level', 'type' => 'STRING', 'category' => 'Management'},
            'Manager_Type__c' => new Map<String, String>{'name' => 'Manager_Type__c', 'label' => 'Manager Type', 'type' => 'STRING', 'category' => 'Management'},
            'Job_Family__c' => new Map<String, String>{'name' => 'Job_Family__c', 'label' => 'Job Family', 'type' => 'STRING', 'category' => 'Job'},
            'FTE__c' => new Map<String, String>{'name' => 'FTE__c', 'label' => 'FTE', 'type' => 'BOOLEAN', 'category' => 'Job'},
            'Commissionable__c' => new Map<String, String>{'name' => 'Commissionable__c', 'label' => 'Commissionable', 'type' => 'BOOLEAN', 'category' => 'Job'},
            'Job_Code__c' => new Map<String, String>{'name' => 'Job_Code__c', 'label' => 'Job Code', 'type' => 'STRING', 'category' => 'Job'},
            'Hire_Date__c' => new Map<String, String>{'name' => 'Hire_Date__c', 'label' => 'Hire Date', 'type' => 'DATE', 'category' => 'Job'},
            'Is_FLM__c' => new Map<String, String>{'name' => 'Is_FLM__c', 'label' => 'Front Line Manager', 'type' => 'BOOLEAN', 'category' => 'Job'},
            'Seller_Group__c' => new Map<String, String>{'name' => 'Seller_Group__c', 'label' => 'Seller Group', 'type' => 'STRING', 'category' => 'Job'},
            'AE_Type__c' => new Map<String, String>{'name' => 'AE_Type__c', 'label' => 'AE Type', 'type' => 'STRING', 'category' => 'Job'},
            'Current_Role_Start_Date__c' => new Map<String, String>{'name' => 'Current_Role_Start_Date__c', 'label' => 'Current Role Start Date', 'type' => 'DATE', 'category' => 'Job'},
            'Days_in_Current_Role__c' => new Map<String, String>{'name' => 'Days_in_Current_Role__c', 'label' => 'Days in Current Role', 'type' => 'NUMBER', 'category' => 'Job'},
            'Employee_Location__c' => new Map<String, String>{'name' => 'Employee_Location__c', 'label' => 'Location', 'type' => 'STRING', 'category' => 'Location'},
            'Work_Location_Country__c' => new Map<String, String>{'name' => 'Work_Location_Country__c', 'label' => 'Country', 'type' => 'STRING', 'category' => 'Location'},
            'Physical_Location__c' => new Map<String, String>{'name' => 'Physical_Location__c', 'label' => 'Physical Location', 'type' => 'STRING', 'category' => 'Location'},
            'Business_Unit_Name__c' => new Map<String, String>{'name' => 'Business_Unit_Name__c', 'label' => 'Business Unit', 'type' => 'STRING', 'category' => 'Organization'},
            'Cost_Center_Name__c' => new Map<String, String>{'name' => 'Cost_Center_Name__c', 'label' => 'Cost Center Name', 'type' => 'STRING', 'category' => 'Organization'},
            'Cost_Center_ID__c' => new Map<String, String>{'name' => 'Cost_Center_ID__c', 'label' => 'Cost Center ID', 'type' => 'STRING', 'category' => 'Organization'},
            'Division__c' => new Map<String, String>{'name' => 'Division__c', 'label' => 'Division', 'type' => 'STRING', 'category' => 'Organization'},
            'Macro_Segment__c' => new Map<String, String>{'name' => 'Macro_Segment__c', 'label' => 'Macro Segment', 'type' => 'STRING', 'category' => 'Organization'},
            'em_Industry__c' => new Map<String, String>{'name' => 'em_Industry__c', 'label' => 'Primary Industry', 'type' => 'STRING', 'category' => 'Organization'},
            'Acquired_Company__c' => new Map<String, String>{'name' => 'Acquired_Company__c', 'label' => 'Acquired Company', 'type' => 'STRING', 'category' => 'Organization'},
            'Customer_Market_Segment__c' => new Map<String, String>{'name' => 'Customer_Market_Segment__c', 'label' => 'Customer Market Segment', 'type' => 'STRING', 'category' => 'Organization'},
            'OU_Name__c' => new Map<String, String>{'name' => 'OU_Name__c', 'label' => 'Organizational Unit', 'type' => 'STRING', 'category' => 'Organization'},
            // Add SlackId field
            'SlackId__c' => new Map<String, String>{'name' => 'SlackId__c', 'label' => 'Slack ID', 'type' => 'STRING', 'category' => 'Communication'}
        };
        
        return fieldInfo;
    }
}