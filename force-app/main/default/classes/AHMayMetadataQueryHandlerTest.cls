@isTest
private class AHMayMetadataQueryHandlerTest {
    @isTest
    static void testAvailableFields() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        
        Map<String, Object> queryData = new Map<String, Object>{
            'METADATA_REQUEST' => 'AVAILABLE_FIELDS'
        };
        
        AHMayMetadataQueryHandler handler = new AHMayMetadataQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assert(result.message.contains('Here are the employee data fields'));
        System.assert(result.message.contains('General Information'));
        System.assert(result.message.contains('Management'));
        System.assert(result.message.contains('Job'));
        System.assert(result.message.contains('Location'));
        System.assert(result.message.contains('Organization'));
    }
    
    @isTest
    static void testFieldValues() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        
        Map<String, Object> queryData = new Map<String, Object>{
            'METADATA_REQUEST' => 'FIELD_VALUES',
            'FIELD_NAME' => 'Division__c'
        };
        
        AHMayMetadataQueryHandler handler = new AHMayMetadataQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assert(result.message.contains('Values for Division'));
    }
    
    @isTest
    static void testFieldValuesPagination() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.pageNumber = 2;
        request.sessionId = 'test-session';
        
        Map<String, Object> queryData = new Map<String, Object>{
            'METADATA_REQUEST' => 'FIELD_VALUES',
            'FIELD_NAME' => 'Division__c',
            'PAGE_NUMBER' => 2
        };
        
        AHMayMetadataQueryHandler handler = new AHMayMetadataQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assert(result.message.contains('(Page 2)'));
    }
    
    @isTest
    static void testFieldValuesCount() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        
        Map<String, Object> queryData = new Map<String, Object>{
            'METADATA_REQUEST' => 'FIELD_VALUES_COUNT',
            'FIELD_NAME' => 'Division__c'
        };
        
        AHMayMetadataQueryHandler handler = new AHMayMetadataQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assert(result.message.contains('unique'));
    }
    
    @isTest
    static void testInvalidFieldName() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        
        Map<String, Object> queryData = new Map<String, Object>{
            'METADATA_REQUEST' => 'FIELD_VALUES',
            'FIELD_NAME' => 'Invalid_Field__c'
        };
        
        AHMayMetadataQueryHandler handler = new AHMayMetadataQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        System.assertEquals(false, result.success);
        System.assert(result.message.contains('not found'));
    }
    
    @isTest
    static void testDefaultMetadataResponse() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        
        Map<String, Object> queryData = new Map<String, Object>{
            'METADATA_REQUEST' => 'UNKNOWN_TYPE'
        };
        
        AHMayMetadataQueryHandler handler = new AHMayMetadataQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assert(result.message.contains('Employee data includes fields'));
    }
}