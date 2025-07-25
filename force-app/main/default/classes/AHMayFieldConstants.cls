public class AHMayFieldConstants {
    
    // Define all available fields in one place for consistency
    public static final List<String> STANDARD_SELECT_FIELDS = new List<String>{
        'Id', 
        'Name', 
        'Primary_Email__c', 
        'Manager__c', 
        'Manager_Email__c',
        'Division__c', 
        'Job_Family__c', 
        'Employee_Location__c', 
        'Physical_Location__c',  // Add this field to the standard list
        'Business_Unit_Name__c',
        'FTE__c', 
        'Commissionable__c', 
        'Job_Code__c', 
        'Cost_Center_Name__c',
        'Cost_Center_ID__c', 
        'Hire_Date__c', 
        'Days_in_Current_Role__c', 
        'Work_Location_Country__c',
        'Is_FLM__c', 
        'Seller_Group__c', 
        'Macro_Segment__c', 
        'em_Industry__c',
        'AE_Type__c',
        'Manager_Level__c',
        'Acquired_Company__c',
        'Current_Role_Start_Date__c',
        'OU_Name__c',
        'Manager_Type__c',
        'Customer_Market_Segment__c',
        'SlackId__c' 
    };
    
    // Management chain fields for hierarchical queries
    public static final List<String> MANAGEMENT_CHAIN_FIELDS = new List<String>{
        'Emp_Mgt_Chain_Lvl_01_Nm__c',
        'Emp_Mgt_Chain_Lvl_02_Nm__c',
        'Emp_Mgt_Chain_Lvl_03_Nm__c',
        'Emp_Mgt_Chain_Lvl_04_Nm__c',
        'Emp_Mgt_Chain_Lvl_05_Nm__c',
        'Emp_Mgt_Chain_Lvl_06_Nm__c',
        'Emp_Mgt_Chain_Lvl_07_Nm__c',
        'Emp_Mgt_Chain_Lvl_08_Nm__c',
        'Emp_Mgt_Chain_Lvl_09_Nm__c',
        'Emp_Mgt_Chain_Lvl_10_Nm__c'
    };
    
    // Mapping of fields referenced in queries to their appropriate API names
        public static final Map<String, String> FIELD_MAPPINGS = new Map<String, String>{
        'division' => 'Division__c',
        'region' => 'Division__c',
        'geo' => 'Division__c',
        'location' => 'Physical_Location__c',  // Change to one consistent field
        'physical location' => 'Physical_Location__c', // Add this mapping
        'detailed location' => 'Employee_Location__c', // Change this mapping
        'office' => 'Physical_Location__c',
        'city' => 'Physical_Location__c',
        'country' => 'Work_Location_Country__c',
        'job' => 'Job_Family__c',
        'role' => 'Job_Family__c',
        'family' => 'Job_Family__c',
        'ae' => 'AE_Type__c',
        'account executive' => 'AE_Type__c',
        'business unit' => 'Business_Unit_Name__c',
        'bu' => 'Business_Unit_Name__c',
        'cost center' => 'Cost_Center_Name__c',
        'job code' => 'Job_Code__c',
        'seller group' => 'Seller_Group__c',
        'sales group' => 'Seller_Group__c',
        'macro segment' => 'Macro_Segment__c',
        'segment' => 'Macro_Segment__c',
        'market segment' => 'Macro_Segment__c',
        'location' => 'Physical_Location__c', 
        'industry' => 'em_Industry__c',
        'primary industry' => 'em_Industry__c',
        'fte' => 'FTE__c',
        'full time' => 'FTE__c',
        'contractor' => 'FTE__c',
        'commissionable' => 'Commissionable__c',
        'sales' => 'Commissionable__c',
        'manager level' => 'Manager_Level__c',
        'flm' => 'Is_FLM__c',
        'front line manager' => 'Is_FLM__c',
        'first line manager' => 'Is_FLM__c'
    };
    
    // Get all fields for hierarchical queries
    public static List<String> getHierarchicalFields() {
        List<String> allFields = new List<String>(STANDARD_SELECT_FIELDS);
        allFields.addAll(MANAGEMENT_CHAIN_FIELDS);
        return allFields;
    }
    
    // Get standard fields for regular queries
    public static List<String> getStandardFields() {
        return new List<String>(STANDARD_SELECT_FIELDS);
    }
    
    // Get fields needed based on query data
    public static List<String> getFieldsForQuery(Map<String, Object> queryData) {
        Set<String> requiredFields = new Set<String>(STANDARD_SELECT_FIELDS);
        
        if (queryData == null) {
            return new List<String>(requiredFields);
        }
        
        // Add management chain fields for hierarchical queries
        if (queryData.containsKey('HIERARCHICAL_QUERY') || 
            queryData.containsKey('HIERARCHICAL_QUERY_OR')) {
            requiredFields.addAll(MANAGEMENT_CHAIN_FIELDS);
        }
        
        // Add any fields specifically referenced in the query
        for (String key : queryData.keySet()) {
            if (key.endsWith('__c') && !key.startsWith('Hire_Date__c_')) {
                requiredFields.add(key);
            }
        }
        
        // For aggregation queries, ensure the group by field is included
        if (queryData.containsKey('GROUP_BY_FIELD')) {
            String groupByField = (String)queryData.get('GROUP_BY_FIELD');
            if (groupByField != null && groupByField.endsWith('__c')) {
                requiredFields.add(groupByField);
            }
        } else if (queryData.containsKey('GROUP_BY_FIELDS')) {
            List<Object> groupByFields = (List<Object>)queryData.get('GROUP_BY_FIELDS');
            for (Object field : groupByFields) {
                if (field instanceof String && ((String)field).endsWith('__c')) {
                    requiredFields.add((String)field);
                }
            }
        }
        
        return new List<String>(requiredFields);
    }
}