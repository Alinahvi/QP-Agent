public class AHMayEmployeeDetailsQueryHandler implements AHMayQueryHandler {
    
    public AHMayQueryResult handleQuery(AHMayQueryRequest request, Map<String, Object> queryData) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            // Debug: Check input data
            System.debug('Employee Details Query Data: ' + JSON.serialize(queryData));
            
            // Safe null check for employee name
            Object nameObj = queryData.get('EMPLOYEE_NAME');
            if (nameObj == null) {
                result.success = false;
                result.message = 'No employee name specified for details query.';
                return result;
            }
            
            String employeeName = String.valueOf(nameObj);
            System.debug('Employee Name: ' + employeeName);
            
            // Get all standard fields from AHMayFieldConstants
            List<String> selectFields = AHMayFieldConstants.getStandardFields();
            
            // Build query using fields from constants
            String query = 'SELECT ' + String.join(selectFields, ', ') + 
                         ' FROM Learner_Profile__c WHERE Status__c = \'Active\' AND ' +
                         'Name LIKE \'%' + String.escapeSingleQuotes(employeeName) + '%\' LIMIT 5';
            
            System.debug('Employee Details Query: ' + query);
            List<Learner_Profile__c> employees = Database.query(query);
            
            if (employees.isEmpty()) {
                result.success = false;
                result.message = 'Could not find employee: ' + employeeName + '. Please check the spelling or provide more specific information.';
                return result;
            }
            
            // Check if we have multiple matches
            if (employees.size() > 1) {
                return handleAmbiguousName(employeeName, employees);
            }
            
            // Format detailed employee info
            Learner_Profile__c emp = employees[0];
            result.success = true;
            result.totalRecords = 1;
            result.records = AHMayResultFormatter.formatEmployeeRecords(employees);
            
            // Create detailed message
            String message = '## Details for: ' + emp.Name + '\n\n';
            message += 'Email: ' + getFieldValue(emp, 'Primary_Email__c') + '\n';
            
            // Add Slack link using our new formatter
            String slackId = getFieldValue(emp, 'SlackId__c');
            if (slackId != 'N/A') {
                message += 'Slack: ' + AHMayResultFormatter.formatSlackLink(slackId) + '\n';
            }
            
            message += 'Manager: ' + getFieldValue(emp, 'Manager__c') + '\n';
            message += 'Manager Email: ' + getFieldValue(emp, 'Manager_Email__c') + '\n';
            message += 'Division: ' + getFieldValue(emp, 'Division__c') + '\n';
            message += 'Job Family: ' + getFieldValue(emp, 'Job_Family__c') + '\n';
            message += 'Location: ' + getFieldValue(emp, 'Employee_Location__c') + '\n';
            message += 'Business Unit: ' + getFieldValue(emp, 'Business_Unit_Name__c') + '\n';
            message += 'FTE: ' + (emp.FTE__c ? 'Yes' : 'No') + '\n';
            message += 'Commissionable: ' + (emp.Commissionable__c ? 'Yes' : 'No') + '\n';
            message += 'Front Line Manager: ' + (emp.Is_FLM__c ? 'Yes' : 'No') + '\n';
            message += 'Job Code: ' + getFieldValue(emp, 'Job_Code__c') + '\n';
            message += 'Cost Center: ' + formatCostCenter(emp) + '\n';
            message += 'Hire Date: ' + formatDate(emp.Hire_Date__c) + '\n';
            message += 'Country: ' + getFieldValue(emp, 'Work_Location_Country__c') + '\n';
            
            // Add AE Type field
            String aeType = getFieldValue(emp, 'AE_Type__c');
            if (aeType != 'N/A') {
                message += 'AE Type: ' + aeType + '\n';
            }
            
            // Add new fields to detail view
            String sellerGroup = getFieldValue(emp, 'Seller_Group__c');
            if (sellerGroup != 'N/A') {
                message += 'Seller Group: ' + sellerGroup + '\n';
            }
            
            String macroSegment = getFieldValue(emp, 'Macro_Segment__c');
            if (macroSegment != 'N/A') {
                message += 'Macro Segment: ' + macroSegment + '\n';
            }
            
            String primaryIndustry = getFieldValue(emp, 'em_Industry__c');
            if (primaryIndustry != 'N/A') {
                message += 'Primary Industry: ' + primaryIndustry + '\n';
            }
            
            String managerLevel = getFieldValue(emp, 'Manager_Level__c');
            if (managerLevel != 'N/A') {
                message += 'Manager Level: ' + managerLevel + '\n';
            }
            
            String acquiredCompany = getFieldValue(emp, 'Acquired_Company__c');
            if (acquiredCompany != 'N/A') {
                message += 'Acquired Company: ' + acquiredCompany + '\n';
            }
            
            result.message = message;
            result.queryUsed = query;
            
            // Add metadata to indicate this is an employee details query result
            if (result.metadataMap == null) {
                result.metadataMap = new Map<String, Object>();
            }
            result.metadataMap.put('queryType', 'EMPLOYEE_DETAILS');
            result.metadataMap.put('employeeName', emp.Name);
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error retrieving employee details: ' + e.getMessage() + 
                           ' (Line: ' + e.getLineNumber() + ')';
            System.debug('Employee Details Error: ' + e.getMessage());
            System.debug('Stack Trace: ' + e.getStackTraceString());
        }
        
        return result;
    }
    
    private String getFieldValue(SObject obj, String fieldName) {
        try {
            Object value = obj.get(fieldName);
            return value != null ? String.valueOf(value) : 'N/A';
        } catch (Exception e) {
            return 'N/A';
        }
    }
    
    private String formatCostCenter(Learner_Profile__c emp) {
        String result = getFieldValue(emp, 'Cost_Center_Name__c');
        String id = getFieldValue(emp, 'Cost_Center_ID__c');
        
        if (id != 'N/A') {
            result += ' (' + id + ')';
        }
        
        return result;
    }
    
    private String formatDate(Date dateValue) {
        if (dateValue != null) {
            return dateValue.format();
        }
        return 'N/A';
    }
    
    private AHMayQueryResult handleAmbiguousName(String name, List<Learner_Profile__c> possibleMatches) {
        AHMayQueryResult result = new AHMayQueryResult();
        result.success = true;
        result.message = 'Found multiple matches for "' + name + '". Did you mean:\n\n';
        
        for (Learner_Profile__c match : possibleMatches) {
            result.message += '- ' + match.Name + ' (' + 
                           getFieldValue(match, 'Division__c') + ', ' + 
                           (match.Manager__c != null ? 'Manager: ' + match.Manager__c : 'No Manager') + ')\n';
        }
        
        result.message += '\nPlease specify which one you meant.';
        result.records = AHMayResultFormatter.formatEmployeeRecords(possibleMatches);
        result.totalRecords = possibleMatches.size();
        
        return result;
    }
}