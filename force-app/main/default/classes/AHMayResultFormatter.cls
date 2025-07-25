public class AHMayResultFormatter {
    
    public static List<AHMayEmployeeRecord> formatEmployeeRecords(List<Learner_Profile__c> profiles) {
        List<AHMayEmployeeRecord> records = new List<AHMayEmployeeRecord>();
        
        for (Learner_Profile__c profile : profiles) {
            AHMayEmployeeRecord record = new AHMayEmployeeRecord();
            // Primary visible fields (these will be displayed by default)
            record.recordId = profile.Id;
            record.name = profile.Name;
            record.email = profile.Primary_Email__c;
            record.manager = profile.Manager__c;
            record.managerEmail = profile.Manager_Email__c;
            
            // Store secondary fields in metadata map for potential analysis
            Map<String, Object> metadata = new Map<String, Object>();
            metadata.put('division', profile.Division__c);
            metadata.put('jobFamily', profile.Job_Family__c);
            metadata.put('location', profile.Employee_Location__c);
            
            // Safely handle Physical_Location__c since it might not be queried
            try {
                // Use getSObject method to check if field exists in query result
                if (profile.getSObjectType().getDescribe().fields.getMap().containsKey('Physical_Location__c')) {
                    Object physicalLocation = profile.get('Physical_Location__c');
                    metadata.put('physicalLocation', physicalLocation);
                }
            } catch (SObjectException e) {
                // Field wasn't queried, skip it
                System.debug('Field Physical_Location__c was not queried, skipping');
            }
            
            metadata.put('businessUnit', profile.Business_Unit_Name__c);
            metadata.put('isFTE', profile.FTE__c);
            metadata.put('isCommissionable', profile.Commissionable__c);
            metadata.put('jobCode', profile.Job_Code__c);
            metadata.put('costCenterName', profile.Cost_Center_Name__c);
            metadata.put('costCenterId', profile.Cost_Center_ID__c);
            metadata.put('hireDate', profile.Hire_Date__c);
            metadata.put('country', profile.Work_Location_Country__c);
            metadata.put('daysInRole', profile.Days_in_Current_Role__c);
            metadata.put('isFLM', profile.Is_FLM__c);
            metadata.put('sellerGroup', profile.Seller_Group__c);
            metadata.put('macroSegment', profile.Macro_Segment__c);
            metadata.put('primaryIndustry', profile.em_Industry__c);
            metadata.put('aeType', profile.AE_Type__c);
            metadata.put('managerLevel', profile.Manager_Level__c);
            metadata.put('acquiredCompany', profile.Acquired_Company__c);
            metadata.put('currentRoleStartDate', profile.Current_Role_Start_Date__c);
            metadata.put('ouName', profile.OU_Name__c);
            metadata.put('managerType', profile.Manager_Type__c);
            metadata.put('customerMarketSegment', profile.Customer_Market_Segment__c);
            metadata.put('slackId', profile.SlackId__c);

            
            // Management chain fields (used for org queries) - handle missing fields gracefully
            for (Integer i = 1; i <= 10; i++) {
                String fieldName = 'Emp_Mgt_Chain_Lvl_';
                if (i < 10) {
                    fieldName += '0' + i;
                } else {
                    fieldName += i;
                }
                fieldName += '_Nm__c';
                
                try {
                    // Only add management chain fields if they exist in the query result
                    Object fieldValue = profile.get(fieldName);
                    metadata.put('mgtChain' + i, fieldValue);
                } catch (Exception e) {
                    // Field wasn't selected in query - skip it
                }
            }
            
            record.metadataMap = metadata;
            records.add(record);
        }
        
        return records;
    }    
    public static String formatSuccessMessage(Integer recordCount, Integer totalRecords, Integer pageNumber) {
        Integer totalPages = Math.max(1, (Integer) Math.ceil(totalRecords / 20.0));
        
        String message = recordCount + ' employees displayed (Page ' + pageNumber + ' of ' + totalPages + ')\n';
        message += 'Total matching employees: ' + totalRecords + '\n\n';
        
        if (pageNumber < totalPages) {
            message += 'Would you like to see the next page? Just ask to "show more" or "next page".\n';
        }
        
        // Suggestion for large result sets
        if (totalRecords > 5000) {
            message += '\nTIP: Your query returned many results. Consider adding filters like region, role, or location for more specific results.';
        }
        
        return message;
    }
    
    // New method to format results with only essential info
    public static String formatConciseEmployeeList(List<AHMayEmployeeRecord> records) {
        String message = '';
        
        for (AHMayEmployeeRecord record : records) {
            message += '* ' + record.name + '\n';
            message += '   * Email: ' + (record.email != null ? record.email : 'N/A') + '\n';
            message += '   * Manager: ' + (record.manager != null ? record.manager : 'N/A') + '\n\n';
        }
        
        return message;
    }
    // Add this new method to AHMayResultFormatter class after the existing methods
public static String formatHierarchicalSummary(String managerName, List<Learner_Profile__c> orgMembers, 
                                        Integer totalCount, Integer pageNumber, Integer totalPages,
                                        Boolean isFiltered) {
    String message = isFiltered ? 'Filtered organization for: ' + managerName : 'Organization for: ' + managerName;
    message += '\n\n**' + totalCount + ' total employees** in ' + managerName + '\'s organization\n';
    message += 'Showing ' + orgMembers.size() + ' employees (Page ' + pageNumber + ' of ' + totalPages + ')\n\n';
    
    // Show concise employee list
    for (Integer i = 0; i < orgMembers.size(); i++) {
        Learner_Profile__c emp = orgMembers[i];
        message += (i+1) + '. **' + emp.Name + '**';
        if (emp.Primary_Email__c != null) {
            message += ' (' + emp.Primary_Email__c + ')';
        }
        message += '\n';
    }
    
    // Add pagination and help text
    if (pageNumber < totalPages) {
        message += '\nFor more employees, ask to "see the next page" or "show more".\n';
    }
    
    message += '\nFor detailed information about an employee, ask "tell me about [name]" or "show details for [name]".\n';
    message += 'You can also ask to "group these employees by [field]" or "filter these to [criteria]".';
    
    return message;
}

/**
 * Format a Slack link with icon for an employee's Slack ID
 * @param slackId The employee's Slack ID
 * @return Formatted link with icon for display
 */
public static String formatSlackLink(String slackId) {
    if (String.isBlank(slackId)) {
        return 'N/A';
    }
    
    // Format as markdown link with inline image using the enterprise Slack URL format
    return '[![Slack](resource/SlackIcon)](https://salesforce.enterprise.slack.com/user/@' + slackId + ') [Chat on Slack](https://salesforce.enterprise.slack.com/user/@' + slackId + ')';
}
}