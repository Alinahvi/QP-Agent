@isTest
private class AHMayPromptServiceTest {
    @isTest
    static void testPromptParsing() {
        // Mock the Einstein LLM API response
        Test.setMock(HttpCalloutMock.class, new EinsteinLLMMock());
        
        Test.startTest();
        String response = AHMayPromptService.generatePromptResponse('Show me employees in AMER');
        Map<String, Object> parsedData = AHMayPromptService.parseResponseToMap(response);
        Test.stopTest();
        
        System.assertNotEquals(null, parsedData);
        System.assertEquals('Active', parsedData.get('Status__c'));
        System.assertEquals('AMER', parsedData.get('Division__c'));
    }
    
    @isTest
    static void testJsonCleanup() {
        String dirtyJson = '```json{"Division__c": "AMER"}```';
        String cleanJson = AHMayPromptService.cleanJsonResponse(dirtyJson);
        
        System.assertEquals('{"Division__c": "AMER"}', cleanJson);
    }
    
    // Mock class for Einstein LLM API
    private class EinsteinLLMMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"generations":[{"text":"{\\"Status__c\\": \\"Active\\", \\"Division__c\\": \\"AMER\\"}"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}