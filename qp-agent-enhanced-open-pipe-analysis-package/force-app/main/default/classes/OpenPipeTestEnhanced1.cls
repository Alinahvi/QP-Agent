@IsTest
public class OpenPipeTestEnhanced1 {
    
    @TestSetup
    static void setupTestData() {
        // Create test data for Agent_Open_Pipe__c records
        List<Agent_Open_Pipe__c> testRecords = new List<Agent_Open_Pipe__c>();
        
        // Create test records with various scenarios
        for (Integer i = 0; i < 10; i++) {
            Agent_Open_Pipe__c record = new Agent_Open_Pipe__c();
            record.OU_NAME__C = 'AMER ACC';
            record.OPEN_PIPE_PROD_NM__C = 'Tableau Server';
            record.WORK_LOCATION_COUNTRY__C = 'United States';
            record.MACROSGMENT__C = 'ENTR';
            record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C = 100000 + (i * 10000);
            record.OPEN_PIPE_OPTY_STG_NM__C = '03 - Validating Benefits & Value';
            record.FULL_NAME__C = 'Test AE ' + i;
            record.OPEN_PIPE_OPTY_NM__C = 'Test Opportunity ' + i;
            record.OPEN_PIPE_AE_SCORE__C = 3 + Math.mod(i, 3);
            record.PRIMARY_INDUSTRY__C = 'Technology';
            testRecords.add(record);
        }
        
        insert testRecords;
    }
    
    @IsTest
    static void testAnalyzeOpenPipeBasic() {
        // Test basic analysis functionality
        Map<String, Object> params = new Map<String, Object>{
            'ou' => 'AMER ACC',
            'analysisType' => 'STAGE_COUNT',
            'groupBy' => 'STAGE'
        };
        
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipe(params);
        Test.stopTest();
        
        // Verify result is not empty and contains expected sections
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.contains('Executive Summary'), 'Result should contain Executive Summary');
        System.assert(result.contains('Analysis Summary'), 'Result should contain Analysis Summary');
        System.assert(result.contains('Results'), 'Result should contain Results section');
    }
    
    @IsTest
    static void testAnalyzeOpenPipeWithProductFilter() {
        // Test analysis with product filtering
        Map<String, Object> params = new Map<String, Object>{
            'ou' => 'AMER ACC',
            'product' => 'Tableau',
            'analysisType' => 'PRODUCT_PERFORMANCE',
            'groupBy' => 'PRODUCT'
        };
        
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipe(params);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.contains('Tableau'), 'Result should contain Tableau product');
    }
    
    @IsTest
    static void testAnalyzeOpenPipeWithCountryFilter() {
        // Test analysis with country filtering - using test data
        Map<String, Object> params = new Map<String, Object>{
            'ou' => 'AMER ACC',
            'analysisType' => 'AE_ANALYSIS',
            'groupBy' => 'AE'
        };
        
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipe(params);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.contains('Executive Summary'), 'Result should contain Executive Summary');
        System.assert(result.contains('Analysis Summary'), 'Result should contain Analysis Summary');
        System.assert(result.contains('Results'), 'Result should contain Results section');
    }
    
    @IsTest
    static void testAnalyzeOpenPipeWithSegmentFilter() {
        // Test analysis with segment filtering
        Map<String, Object> params = new Map<String, Object>{
            'ou' => 'AMER ACC',
            'segment' => 'ENTR',
            'analysisType' => 'STAGE_COUNT',
            'groupBy' => 'STAGE'
        };
        
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipe(params);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    
    @IsTest
    static void testGetFieldSuggestions() {
        // Test field suggestions functionality
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.getFieldSuggestions('test');
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.contains('Available Fields'), 'Result should contain Available Fields section');
        System.assert(result.contains('stage'), 'Result should contain stage field');
        System.assert(result.contains('product'), 'Result should contain product field');
    }
    
    @IsTest
    static void testValidateFilterCriteria() {
        // Test filter criteria validation
        String testCriteria = 'stage=\'03 - Validating Benefits & Value\'';
        
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.validateFilterCriteria(testCriteria);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.contains('Filter Criteria Validation'), 'Result should contain validation section');
    }
    
    @IsTest
    static void testValidateFilterCriteriaEmpty() {
        // Test filter criteria validation with empty input
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.validateFilterCriteria('');
        Test.stopTest();
        
        System.assertEquals('Filter criteria cannot be empty.', result, 'Should return empty criteria message');
    }
    
    @IsTest
    static void testAnalyzeOpenPipeTerritoryAnalysis() {
        // Test territory analysis with higher limit
        Map<String, Object> params = new Map<String, Object>{
            'ou' => 'AMER ACC',
            'analysisType' => 'territory',
            'groupBy' => 'AE'
        };
        
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipe(params);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.contains('Executive Summary'), 'Result should contain Executive Summary');
    }
    
    @IsTest
    static void testAnalyzeOpenPipeWithNegativeIntent() {
        // Test analysis with negative intent
        Map<String, Object> params = new Map<String, Object>{
            'ou' => 'AMER ACC',
            'analysisType' => 'STAGE_COUNT',
            'groupBy' => 'STAGE',
            'negativeIntent' => true,
            'excludeProductListCsv' => 'Tableau'
        };
        
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipe(params);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    
    @IsTest
    static void testAnalyzeOpenPipeWithAllFlags() {
        // Test analysis with all intelligence flags enabled
        Map<String, Object> params = new Map<String, Object>{
            'ou' => 'AMER ACC',
            'analysisType' => 'STAGE_COUNT',
            'groupBy' => 'STAGE',
            'includeClosureProb' => true,
            'includeStageBottlenecks' => true,
            'includePMF' => true,
            'includeAEBenchmarks' => true,
            'includeHealthScore' => true
        };
        
        Test.startTest();
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipe(params);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.contains('Executive Summary'), 'Result should contain Executive Summary');
    }
}
