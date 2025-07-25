@isTest
private class AHMayQueryUtilsTest {
    @isTest
    static void testExtractQueryFields() {
        Map<String, Object> queryData = new Map<String, Object>{
            'Status__c' => 'Active',
            'Division__c' => 'AMER',
            'HIERARCHICAL_QUERY' => 'John Doe', // Should be filtered out
            'METADATA_REQUEST' => 'FIELD_VALUES', // Should be filtered out
            'Job_Family__c' => 'Engineer'
        };
        
        Map<String, Object> fieldConditions = AHMayQueryUtils.extractQueryFields(queryData);
        
        System.assertEquals(3, fieldConditions.size());
        System.assert(fieldConditions.containsKey('Status__c'));
        System.assert(fieldConditions.containsKey('Division__c'));
        System.assert(fieldConditions.containsKey('Job_Family__c'));
        System.assert(!fieldConditions.containsKey('HIERARCHICAL_QUERY'));
    }
    
    @isTest
    static void testBuildWhereConditions() {
        Map<String, Object> fieldConditions = new Map<String, Object>{
            'Division__c' => 'AMER',
            'FTE__c' => true,
            'Hire_Date__c_START' => Date.newInstance(2024, 1, 1)
        };
        
        List<String> conditions = AHMayQueryUtils.buildWhereConditions(fieldConditions);
        
        System.assert(!conditions.isEmpty());
        System.assert(conditions.contains('Division__c = \'AMER\''));
        System.assert(conditions.contains('FTE__c = true'));
    }
    
    @isTest
    static void testOrConditionBuilding() {
        Map<String, Object> fieldConditions = new Map<String, Object>{
            'Division__c_OR' => new List<String>{'AMER', 'EMEA', 'APAC'}
        };
        
        List<String> conditions = AHMayQueryUtils.buildWhereConditions(fieldConditions);
        
        System.assert(!conditions.isEmpty());
        System.assertEquals(1, conditions.size());
        System.assert(conditions[0].contains('Division__c = \'AMER\' OR'));
    }
}