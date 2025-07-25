@isTest
private class AHMayDateHandlerTest {
    @isTest
    static void testDateRangeParsing() {
        Map<String, Object> queryData = new Map<String, Object>{
            'Hire_Date__c_RANGE' => new Map<String, Object>{
                'start' => '2024-01-01',
                'end' => '2024-12-31'
            }
        };
        
        Map<String, Object> processedData = AHMayDateHandler.parseDateCriteria(queryData);
        
        System.assertNotEquals(null, processedData.get('Hire_Date__c_START'));
        System.assertNotEquals(null, processedData.get('Hire_Date__c_END'));
    }
    
    @isTest
    static void testRelativeDateParsing() {
        Map<String, Object> queryData = new Map<String, Object>{
            'Hire_Date__c_RELATIVE' => 'LAST_MONTH'
        };
        
        Map<String, Object> processedData = AHMayDateHandler.parseDateCriteria(queryData);
        
        System.assertNotEquals(null, processedData.get('Hire_Date__c_START'));
        System.assertNotEquals(null, processedData.get('Hire_Date__c_END'));
    }
    
    @isTest
    static void testDateConditionBuilding() {
        Map<String, Object> queryData = new Map<String, Object>{
            'Hire_Date__c_START' => Date.newInstance(2024, 1, 1),
            'Hire_Date__c_END' => Date.newInstance(2024, 12, 31)
        };
        
        List<String> conditions = new List<String>();
        AHMayDateHandler.addDateConditions(queryData, conditions);
        
        System.assert(!conditions.isEmpty());
        System.assertEquals(2, conditions.size());
    }
    
    @isTest
    static void testNaturalLanguageDateParsing() {
        Map<String, Object> queryData = new Map<String, Object>{
            'Hire_Date__c_TEXT' => 'in February 2024'
        };
        
        Map<String, Object> processedData = AHMayDateHandler.parseDateCriteria(queryData);
        
        System.assertNotEquals(null, processedData.get('Hire_Date__c_START'));
        System.assertNotEquals(null, processedData.get('Hire_Date__c_END'));
        
        Date startDate = (Date)processedData.get('Hire_Date__c_START');
        Date endDate = (Date)processedData.get('Hire_Date__c_END');
        
        System.assertEquals(2, startDate.month());
        System.assertEquals(2024, startDate.year());
    }
}