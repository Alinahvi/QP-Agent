@isTest
private class AHMayQueryBuilderTest {
    
    @isTest
    static void testBuildSOQLQuery_BasicQuery() {
        // Test basic query with standard fields
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('Division__c', 'Sales');
        
        Test.startTest();
        String query = AHMayQueryBuilder.buildSOQLQuery(queryData, true, 50, 0);
        Test.stopTest();
        
        System.assert(query.contains('SELECT'), 'Query should contain SELECT');
        System.assert(query.contains('FROM Learner_Profile__c'), 'Query should be from Learner_Profile__c');
        System.assert(query.contains('WHERE'), 'Query should contain WHERE clause');
        System.assert(query.contains('Status__c = \'Active\''), 'Query should filter for Active status');
        System.assert(query.contains('Division__c = \'Sales\''), 'Query should include Division condition');
        System.assert(query.contains('ORDER BY Name ASC'), 'Query should order by Name');
        System.assert(query.contains('LIMIT 50 OFFSET 0'), 'Query should include limit and offset');
    }
    
    @isTest
    static void testBuildSOQLQuery_WithoutOrderAndLimit() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('Job_Family__c', 'Engineering');
        
        Test.startTest();
        String query = AHMayQueryBuilder.buildSOQLQuery(queryData, false, 100, 10);
        Test.stopTest();
        
        System.assert(!query.contains('ORDER BY'), 'Query should not contain ORDER BY');
        System.assert(!query.contains('LIMIT'), 'Query should not contain LIMIT');
        System.assert(!query.contains('OFFSET'), 'Query should not contain OFFSET');
    }
    
    @isTest
    static void testGetRequiredFields_StandardFields() {
        Map<String, Object> queryData = new Map<String, Object>();
        
        Test.startTest();
        List<String> fields = AHMayQueryBuilder.getRequiredFields(queryData);
        Test.stopTest();
        
        // Verify standard fields are included
        System.assert(fields.contains('Id'), 'Should include Id field');
        System.assert(fields.contains('Name'), 'Should include Name field');
        System.assert(fields.contains('Primary_Email__c'), 'Should include Primary_Email__c');
        System.assert(fields.contains('Manager__c'), 'Should include Manager__c');
        System.assert(fields.contains('Manager_Email__c'), 'Should include Manager_Email__c');
        
        // Verify always-included fields
        System.assert(fields.contains('Division__c'), 'Should include Division__c');
        System.assert(fields.contains('Job_Family__c'), 'Should include Job_Family__c');
        System.assert(fields.contains('Work_Location_Country__c'), 'Should include Work_Location_Country__c');
        System.assert(fields.contains('Seller_Group__c'), 'Should include Seller_Group__c');
        System.assert(fields.contains('Macro_Segment__c'), 'Should include Macro_Segment__c');
        System.assert(fields.contains('em_Industry__c'), 'Should include em_Industry__c');
        System.assert(fields.contains('AE_Type__c'), 'Should include AE_Type__c');
    }
    
    @isTest
    static void testGetRequiredFields_HierarchicalQuery() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('HIERARCHICAL_QUERY', true);
        
        Test.startTest();
        List<String> fields = AHMayQueryBuilder.getRequiredFields(queryData);
        Test.stopTest();
        
        // Verify hierarchy fields are included
        System.assert(fields.contains('Emp_Mgt_Chain_Lvl_01_Nm__c'), 'Should include management chain level 1');
        System.assert(fields.contains('Emp_Mgt_Chain_Lvl_05_Nm__c'), 'Should include management chain level 5');
        System.assert(fields.contains('Emp_Mgt_Chain_Lvl_10_Nm__c'), 'Should include management chain level 10');
        
        // Verify detailed fields are included for hierarchical queries
        System.assert(fields.contains('Employee_Location__c'), 'Should include Employee_Location__c');
        System.assert(fields.contains('Business_Unit_Name__c'), 'Should include Business_Unit_Name__c');
        System.assert(fields.contains('FTE__c'), 'Should include FTE__c');
        System.assert(fields.contains('Commissionable__c'), 'Should include Commissionable__c');
        System.assert(fields.contains('Job_Code__c'), 'Should include Job_Code__c');
        System.assert(fields.contains('Cost_Center_Name__c'), 'Should include Cost_Center_Name__c');
        System.assert(fields.contains('Hire_Date__c'), 'Should include Hire_Date__c');
    }
    
    @isTest
    static void testGetRequiredFields_HierarchicalQueryOR() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('HIERARCHICAL_QUERY_OR', true);
        
        Test.startTest();
        List<String> fields = AHMayQueryBuilder.getRequiredFields(queryData);
        Test.stopTest();
        
        // Should include hierarchy fields
        System.assert(fields.contains('Emp_Mgt_Chain_Lvl_01_Nm__c'), 'Should include management chain fields');
    }
    
    @isTest
    static void testGetRequiredFields_NeedHierarchyFields() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('NEED_HIERARCHY_FIELDS', true);
        
        Test.startTest();
        List<String> fields = AHMayQueryBuilder.getRequiredFields(queryData);
        Test.stopTest();
        
        // Should include hierarchy fields
        System.assert(fields.contains('Emp_Mgt_Chain_Lvl_01_Nm__c'), 'Should include management chain fields');
    }
    
    @isTest
    static void testGetRequiredFields_DetailQuery() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('EMPLOYEE_DETAILS', true);
        
        Test.startTest();
        List<String> fields = AHMayQueryBuilder.getRequiredFields(queryData);
        Test.stopTest();
        
        // Verify detailed fields are included
        System.assert(fields.contains('Days_in_Current_Role__c'), 'Should include Days_in_Current_Role__c');
        System.assert(fields.contains('Is_FLM__c'), 'Should include Is_FLM__c');
    }
    
    @isTest
    static void testGetRequiredFields_DirectReportsQuery() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('DIRECT_REPORTS', true);
        
        Test.startTest();
        List<String> fields = AHMayQueryBuilder.getRequiredFields(queryData);
        Test.stopTest();
        
        // Should include detailed fields
        System.assert(fields.contains('Cost_Center_ID__c'), 'Should include Cost_Center_ID__c');
    }
    
    @isTest
    static void testGetRequiredFields_SimpleListQuery() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('FTE__c', 1.0);
        queryData.put('Commissionable__c', true);
        
        Test.startTest();
        List<String> fields = AHMayQueryBuilder.getRequiredFields(queryData);
        Test.stopTest();
        
        // Should include only referenced fields for simple queries
        System.assert(fields.contains('FTE__c'), 'Should include FTE__c when referenced');
        System.assert(fields.contains('Commissionable__c'), 'Should include Commissionable__c when referenced');
        
        // Should not include detailed fields for simple queries
        System.assert(!fields.contains('Days_in_Current_Role__c'), 'Should not include Days_in_Current_Role__c for simple query');
    }
    
    @isTest
    static void testGetRequiredFields_AggregationQuery() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('AGGREGATION', true);
        queryData.put('GROUP_BY_FIELD', 'Department__c');
        
        Test.startTest();
        List<String> fields = AHMayQueryBuilder.getRequiredFields(queryData);
        Test.stopTest();
        
        System.assert(fields.contains('Department__c'), 'Should include GROUP_BY_FIELD');
    }
    
    @isTest
    static void testGetRequiredFields_CustomFieldsFromData() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('Custom_Field__c', 'Value');
        queryData.put('Another_Custom__c', 'Value2');
        
        Test.startTest();
        List<String> fields = AHMayQueryBuilder.getRequiredFields(queryData);
        Test.stopTest();
        
        System.assert(fields.contains('Custom_Field__c'), 'Should include custom fields from query data');
        System.assert(fields.contains('Another_Custom__c'), 'Should include custom fields from query data');
    }
    
    @isTest
    static void testGetRequiredFields_IgnoreSpecialKeys() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('Field__c_OR', 'Value'); // Should be ignored
        queryData.put('Hire_Date__c_START', '2024-01-01'); // Should be ignored
        queryData.put('Status__c', 'Active'); // Should be ignored (it's always included)
        
        Test.startTest();
        List<String> fields = AHMayQueryBuilder.getRequiredFields(queryData);
        Test.stopTest();
        
        // These special keys should not be added as fields
        System.assert(!fields.contains('Field__c_OR'), 'Should not include _OR fields');
        System.assert(!fields.contains('Hire_Date__c_START'), 'Should not include date range fields');
        System.assert(fields.contains('Status__c'), 'Status__c should be in standard fields only');
    }
    
    @isTest
    static void testGetQueryConditions_BasicConditions() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('Division__c', 'Sales');
        queryData.put('FTE__c', 1.0);
        queryData.put('Commissionable__c', true);
        
        Test.startTest();
        List<String> conditions = AHMayQueryBuilder.getQueryConditions(queryData);
        Test.stopTest();
        
        // Should always include active status
        System.assert(containsCondition(conditions, 'Status__c = \'Active\''), 'Should include Active status condition');
        
        // Should include field conditions
        System.assert(containsCondition(conditions, 'Division__c = \'Sales\''), 'Should include Division condition');
        System.assert(containsCondition(conditions, 'FTE__c = 1.0'), 'Should include FTE condition');
        System.assert(containsCondition(conditions, 'Commissionable__c = true'), 'Should include Commissionable condition');
    }
    
    @isTest
    static void testGetQueryConditions_PartialNameMatch() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('Name', 'John');
        queryData.put('PARTIAL_NAME_MATCH', true);
        
        Test.startTest();
        List<String> conditions = AHMayQueryBuilder.getQueryConditions(queryData);
        Test.stopTest();
        
        System.assert(containsCondition(conditions, 'Name LIKE \'%John%\''), 'Should use LIKE for partial name match');
    }
    
    @isTest
    static void testGetQueryConditions_ExactNameMatch() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('Name', 'John Doe');
        
        Test.startTest();
        List<String> conditions = AHMayQueryBuilder.getQueryConditions(queryData);
        Test.stopTest();
        
        System.assert(containsCondition(conditions, 'Name = \'John Doe\''), 'Should use exact match without PARTIAL_NAME_MATCH');
    }
    
    @isTest
    static void testGetQueryConditions_EscapeSingleQuotes() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('Name', 'O\'Brien');
        
        Test.startTest();
        List<String> conditions = AHMayQueryBuilder.getQueryConditions(queryData);
        Test.stopTest();
        
        System.assert(containsCondition(conditions, 'Name = \'O\\\'Brien\''), 'Should escape single quotes');
    }
    
    @isTest
    static void testGetQueryConditions_NullQueryData() {
        Test.startTest();
        List<String> conditions = AHMayQueryBuilder.getQueryConditions(null);
        Test.stopTest();
        
        System.assertEquals(1, conditions.size(), 'Should only have status condition');
        System.assertEquals('Status__c = \'Active\'', conditions[0], 'Should only include Active status');
    }
    
    @isTest
    static void testGetQueryConditions_IgnoreSpecialFields() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('Field__c', 'Value');
        queryData.put('HIERARCHICAL_QUERY', true); // Should be ignored
        queryData.put('Field__c_OR', 'Value'); // Should be ignored
        queryData.put('Hire_Date__c_START', '2024-01-01'); // Should be handled by date handler
        
        Test.startTest();
        List<String> conditions = AHMayQueryBuilder.getQueryConditions(queryData);
        Test.stopTest();
        
        System.assert(containsCondition(conditions, 'Field__c = \'Value\''), 'Should include regular field');
        System.assert(!containsCondition(conditions, 'HIERARCHICAL_QUERY'), 'Should not include HIERARCHICAL_QUERY');
        System.assert(!containsCondition(conditions, 'Field__c_OR'), 'Should not include _OR fields');
    }
    
    @isTest
    static void testBuildCountQuery() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('Division__c', 'Sales');
        
        Test.startTest();
        String countQuery = AHMayQueryBuilder.buildCountQuery(queryData);
        Test.stopTest();
        
        System.assert(countQuery.contains('SELECT COUNT()'), 'Count query should use COUNT()');
        System.assert(countQuery.contains('FROM Learner_Profile__c'), 'Should query from Learner_Profile__c');
        System.assert(countQuery.contains('WHERE'), 'Should contain WHERE clause');
        System.assert(countQuery.contains('Status__c = \'Active\''), 'Should filter for Active status');
        System.assert(countQuery.contains('Division__c = \'Sales\''), 'Should include Division condition');
    }
    
    @isTest
    static void testBuildSpecializedQuery_Hierarchical() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('Division__c', 'Sales');
        
        Test.startTest();
        String query = AHMayQueryBuilder.buildSpecializedQuery(queryData, 'HIERARCHICAL', true, 25, 5);
        Test.stopTest();
        
        // Should include hierarchy fields
        System.assert(query.contains('Emp_Mgt_Chain_Lvl_01_Nm__c'), 'Should include hierarchy fields');
        System.assert(query.contains('LIMIT 25 OFFSET 5'), 'Should include limit and offset');
    }
    
    @isTest
    static void testBuildSpecializedQuery_NonHierarchical() {
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('Job_Family__c', 'Engineering');
        
        Test.startTest();
        String query = AHMayQueryBuilder.buildSpecializedQuery(queryData, 'SIMPLE', false, 50, 0);
        Test.stopTest();
        
        System.assert(query.contains('Job_Family__c = \'Engineering\''), 'Should include job family condition');
        System.assert(!query.contains('LIMIT'), 'Should not include limit when includeOrderAndLimit is false');
    }
    
    // Helper method to check if a condition exists in the list
    private static Boolean containsCondition(List<String> conditions, String condition) {
        for (String c : conditions) {
            if (c.contains(condition)) {
                return true;
            }
        }
        return false;
    }
    
    @isTest
    static void testIntegrationWithDateHandler() {
        // This test assumes AHMayDateHandler exists and processes date criteria
        Map<String, Object> queryData = new Map<String, Object>();
        queryData.put('Hire_Date__c_START', '2024-01-01');
        queryData.put('Hire_Date__c_END', '2024-12-31');
        
        Test.startTest();
        List<String> conditions = AHMayQueryBuilder.getQueryConditions(queryData);
        Test.stopTest();
        
        // The actual date conditions would be added by AHMayDateHandler
        // We're just verifying the integration point works
        System.assertNotEquals(null, conditions, 'Conditions should not be null');
        System.assert(conditions.size() >= 1, 'Should have at least the status condition');
    }
}