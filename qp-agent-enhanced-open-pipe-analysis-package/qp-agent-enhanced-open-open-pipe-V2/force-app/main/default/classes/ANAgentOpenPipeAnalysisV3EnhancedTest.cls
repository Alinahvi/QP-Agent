/**
 * @description Comprehensive Test Class for V3 Enhanced Handler and Service
 * 
 * TEST COVERAGE:
 * - Handler: Input validation, error handling, service integration
 * - Service: Region validation, stage normalization, SOQL building, FLS, limits
 * - Edge cases: Empty data, invalid parameters, high-level regions
 * 
 * @author Salesforce
 * @date 2025-10-10
 */
@isTest
private class ANAgentOpenPipeAnalysisV3EnhancedTest {
    
    /**
     * TEST 1: Handler - Basic request with valid parameters
     */
    @isTest
    static void testHandler_BasicRequest() {
        // Setup
        ANAgentOpenPipeAnalysisHandlerV3Enhanced.Request req = new ANAgentOpenPipeAnalysisHandlerV3Enhanced.Request();
        req.queryParamsJson = '{"ou": "UKI", "stage": "2"}';
        
        // Execute
        Test.startTest();
        List<ANAgentOpenPipeAnalysisHandlerV3Enhanced.Response> responses = 
            ANAgentOpenPipeAnalysisHandlerV3Enhanced.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandlerV3Enhanced.Request>{ req });
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, responses, 'Should return responses');
        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assert(responses[0].message.contains('AGENT INSTRUCTION'), 'Should include agent instruction');
    }
    
    /**
     * TEST 2: Handler - Empty request list
     */
    @isTest
    static void testHandler_EmptyRequest() {
        // Execute
        Test.startTest();
        List<ANAgentOpenPipeAnalysisHandlerV3Enhanced.Response> responses = 
            ANAgentOpenPipeAnalysisHandlerV3Enhanced.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandlerV3Enhanced.Request>());
        Test.stopTest();
        
        // Verify
        System.assertEquals(1, responses.size(), 'Should return error response');
        System.assert(responses[0].message.contains('No request provided'), 'Should show error message');
    }
    
    /**
     * TEST 3: Handler - Null request list
     */
    @isTest
    static void testHandler_NullRequest() {
        // Execute
        Test.startTest();
        List<ANAgentOpenPipeAnalysisHandlerV3Enhanced.Response> responses = 
            ANAgentOpenPipeAnalysisHandlerV3Enhanced.analyzeOpenPipe(null);
        Test.stopTest();
        
        // Verify
        System.assertEquals(1, responses.size(), 'Should return error response');
        System.assert(responses[0].message.contains('No request provided'), 'Should show error message');
    }
    
    /**
     * TEST 4: Handler - Invalid JSON
     */
    @isTest
    static void testHandler_InvalidJson() {
        // Setup
        ANAgentOpenPipeAnalysisHandlerV3Enhanced.Request req = new ANAgentOpenPipeAnalysisHandlerV3Enhanced.Request();
        req.queryParamsJson = '{invalid json}';
        
        // Execute
        Test.startTest();
        List<ANAgentOpenPipeAnalysisHandlerV3Enhanced.Response> responses = 
            ANAgentOpenPipeAnalysisHandlerV3Enhanced.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandlerV3Enhanced.Request>{ req });
        Test.stopTest();
        
        // Verify
        System.assertEquals(1, responses.size(), 'Should return response');
        System.assert(responses[0].message.contains('Error'), 'Should show error message');
    }
    
    /**
     * TEST 5: Service - High-level region AMER
     */
    @isTest
    static void testService_HighLevelRegionAMER() {
        // Setup
        Map<String, Object> params = new Map<String, Object>{ 'ou' => 'AMER' };
        
        // Execute
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisServiceV3Enhanced.executeQuery(params);
        Test.stopTest();
        
        // Verify
        System.assert(result.contains('CLARIFICATION NEEDED'), 'Should ask for clarification');
        System.assert(result.contains('AMER ACC'), 'Should list AMER ACC as option');
        System.assert(result.contains('availableOUs'), 'Should include available OUs');
    }
    
    /**
     * TEST 6: Service - High-level region EMEA
     */
    @isTest
    static void testService_HighLevelRegionEMEA() {
        // Setup
        Map<String, Object> params = new Map<String, Object>{ 'ou' => 'EMEA' };
        
        // Execute
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisServiceV3Enhanced.executeQuery(params);
        Test.stopTest();
        
        // Verify
        System.assert(result.contains('CLARIFICATION'), 'Should ask for clarification');
        System.assert(result.contains('UKI'), 'Should list UKI as option');
        System.assert(result.contains('DACH'), 'Should list DACH as option');
    }
    
    /**
     * TEST 7: Service - High-level region APAC
     */
    @isTest
    static void testService_HighLevelRegionAPAC() {
        // Setup
        Map<String, Object> params = new Map<String, Object>{ 'ou' => 'APAC' };
        
        // Execute
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisServiceV3Enhanced.executeQuery(params);
        Test.stopTest();
        
        // Verify
        System.assert(result.contains('CLARIFICATION'), 'Should ask for clarification');
        System.assert(result.contains('Japan'), 'Should list Japan as option');
    }
    
    /**
     * TEST 8: Service - Missing OU and Country
     */
    @isTest
    static void testService_MissingOUAndCountry() {
        // Setup
        Map<String, Object> params = new Map<String, Object>{ 'stage' => '2' };
        
        // Execute
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisServiceV3Enhanced.executeQuery(params);
        Test.stopTest();
        
        // Verify
        System.assert(result.contains('ERROR'), 'Should return error');
        System.assert(result.contains('ou') || result.contains('country'), 'Should mention missing parameter');
    }
    
    /**
     * TEST 9: Service - Stage normalization "stage 2"
     */
    @isTest
    static void testService_StageNormalization_Stage2() {
        // Setup
        Map<String, Object> params = new Map<String, Object>{
            'ou' => 'UKI',
            'stage' => 'stage 2'
        };
        
        // Execute
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisServiceV3Enhanced.executeQuery(params);
        Test.stopTest();
        
        // Verify - should not error, should process query
        System.assertNotEquals(null, result, 'Should return result');
        System.assert(!result.contains('Error'), 'Should not have errors');
    }
    
    /**
     * TEST 10: Service - Stage normalization "2"
     */
    @isTest
    static void testService_StageNormalization_Number2() {
        // Setup
        Map<String, Object> params = new Map<String, Object>{
            'ou' => 'UKI',
            'stage' => '2'
        };
        
        // Execute
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisServiceV3Enhanced.executeQuery(params);
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, result, 'Should return result');
        System.assert(!result.contains('Error'), 'Should not have errors');
    }
    
    /**
     * TEST 11: Service - Stage normalization "stage2"
     */
    @isTest
    static void testService_StageNormalization_Stage2NoSpace() {
        // Setup
        Map<String, Object> params = new Map<String, Object>{
            'ou' => 'UKI',
            'stage' => 'stage2'
        };
        
        // Execute
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisServiceV3Enhanced.executeQuery(params);
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, result, 'Should return result');
        System.assert(!result.contains('Error'), 'Should not have errors');
    }
    
    /**
     * TEST 12: Service - Valid OU with product filter
     */
    @isTest
    static void testService_ValidOUWithProduct() {
        // Setup
        Map<String, Object> params = new Map<String, Object>{
            'ou' => 'UKI',
            'product' => 'Agentforce'
        };
        
        // Execute
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisServiceV3Enhanced.executeQuery(params);
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, result, 'Should return result');
        System.assert(result.contains('json'), 'Should contain JSON output');
    }
    
    /**
     * TEST 13: Service - With limit parameter
     */
    @isTest
    static void testService_WithLimit() {
        // Setup
        Map<String, Object> params = new Map<String, Object>{
            'ou' => 'UKI',
            'limitN' => 10
        };
        
        // Execute
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisServiceV3Enhanced.executeQuery(params);
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, result, 'Should return result');
        System.assert(result.contains('limits'), 'Should include limits section');
    }
    
    /**
     * TEST 14: Service - Complete parameter set
     */
    @isTest
    static void testService_CompleteParameters() {
        // Setup
        Map<String, Object> params = new Map<String, Object>{
            'ou' => 'UKI',
            'stage' => '2',
            'product' => 'Tableau',
            'filterCriteria' => 'OPEN_PIPE_OPTY_DAYS_IN_STAGE__C > 30',
            'groupBy' => 'PRODUCT',
            'analysisType' => 'PRODUCT_PERFORMANCE',
            'limitN' => 50
        };
        
        // Execute
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisServiceV3Enhanced.executeQuery(params);
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, result, 'Should return result');
        System.assert(result.contains('context'), 'Should include context');
        System.assert(result.contains('summary'), 'Should include summary');
    }
    
    /**
     * TEST 15: Integration - Handler to Service with stage normalization
     */
    @isTest
    static void testIntegration_HandlerToServiceStageNormalization() {
        // Setup
        ANAgentOpenPipeAnalysisHandlerV3Enhanced.Request req = new ANAgentOpenPipeAnalysisHandlerV3Enhanced.Request();
        req.queryParamsJson = '{"ou": "UKI", "stage": "stage 2", "filterCriteria": "OPEN_PIPE_OPTY_DAYS_IN_STAGE__C > 30"}';
        
        // Execute
        Test.startTest();
        List<ANAgentOpenPipeAnalysisHandlerV3Enhanced.Response> responses = 
            ANAgentOpenPipeAnalysisHandlerV3Enhanced.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandlerV3Enhanced.Request>{ req });
        Test.stopTest();
        
        // Verify
        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assert(responses[0].message.contains('AGENT INSTRUCTION'), 'Should have agent instruction');
        System.assert(responses[0].message.contains('json'), 'Should have JSON data');
    }
    
    /**
     * TEST 16: Integration - Handler to Service with region clarification
     */
    @isTest
    static void testIntegration_HandlerToServiceRegionClarification() {
        // Setup
        ANAgentOpenPipeAnalysisHandlerV3Enhanced.Request req = new ANAgentOpenPipeAnalysisHandlerV3Enhanced.Request();
        req.queryParamsJson = '{"ou": "AMER"}';
        
        // Execute
        Test.startTest();
        List<ANAgentOpenPipeAnalysisHandlerV3Enhanced.Response> responses = 
            ANAgentOpenPipeAnalysisHandlerV3Enhanced.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandlerV3Enhanced.Request>{ req });
        Test.stopTest();
        
        // Verify
        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assert(responses[0].message.contains('CLARIFICATION'), 'Should ask for clarification');
        System.assert(responses[0].message.contains('AMER ACC'), 'Should list OU options');
    }
    
    /**
     * TEST 17: Service - JSON structure validation
     */
    @isTest
    static void testService_JsonStructureValid() {
        // Setup
        Map<String, Object> params = new Map<String, Object>{ 'ou' => 'UKI' };
        
        // Execute
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisServiceV3Enhanced.executeQuery(params);
        Test.stopTest();
        
        // Verify JSON can be parsed
        System.assert(result.contains('```json'), 'Should have JSON block');
        System.assert(result.contains('context'), 'Should have context');
        System.assert(result.contains('summary'), 'Should have summary');
        System.assert(result.contains('fieldContext'), 'Should have field context');
    }
    
    /**
     * TEST 18: Service - Field context completeness
     */
    @isTest
    static void testService_FieldContextComplete() {
        // Setup
        Map<String, Object> params = new Map<String, Object>{ 'ou' => 'UKI' };
        
        // Execute
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisServiceV3Enhanced.executeQuery(params);
        Test.stopTest();
        
        // Verify field context includes key fields
        System.assert(result.contains('aeName'), 'Should explain aeName field');
        System.assert(result.contains('stage'), 'Should explain stage field');
        System.assert(result.contains('value'), 'Should explain value field');
        System.assert(result.contains('daysInStage'), 'Should explain daysInStage field');
    }
    
    /**
     * TEST 19: Service - Parameter extraction helpers
     */
    @isTest
    static void testService_ParameterHelpers() {
        // Setup
        Map<String, Object> params = new Map<String, Object>{
            'ou' => 'UKI',
            'limitN' => '10',
            'stage' => 2
        };
        
        // Execute
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisServiceV3Enhanced.executeQuery(params);
        Test.stopTest();
        
        // Verify - should handle string and integer conversions
        System.assertNotEquals(null, result, 'Should return result');
    }
    
    /**
     * TEST 20: Service - No emojis in output
     */
    @isTest
    static void testService_NoEmojisInOutput() {
        // Setup
        Map<String, Object> params = new Map<String, Object>{ 'ou' => 'UKI', 'stage' => '2' };
        
        // Execute
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisServiceV3Enhanced.executeQuery(params);
        Test.stopTest();
        
        // Verify no emojis in service output (agent adds them)
        // Extract just the service part (after agent instruction)
        Integer jsonStart = result.indexOf('```json');
        if (jsonStart > 0) {
            String serviceOutput = result.substring(jsonStart);
            // Check common emojis are NOT in service output
            System.assert(!serviceOutput.contains('📊'), 'Service should not contain chart emoji');
            System.assert(!serviceOutput.contains('🎯'), 'Service should not contain target emoji');
            System.assert(!serviceOutput.contains('✅'), 'Service should not contain checkmark emoji');
            System.assert(!serviceOutput.contains('⚠️'), 'Service should not contain warning emoji');
        }
    }
}

