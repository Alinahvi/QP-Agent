/**
 * @description Test class for Open Pipe Analysis V3 Intelligence capabilities
 * @author AI Assistant
 * @version 1.0
 */
@IsTest
public class ANAgentOpenPipeAnalysisV3IntelligenceTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test data for Open Pipe Analysis
        List<Agent_Open_Pipe__c> testRecords = new List<Agent_Open_Pipe__c>();
        
        // Create test opportunities with different AE scores and stages
        for (Integer i = 0; i < 20; i++) {
            Agent_Open_Pipe__c record = new Agent_Open_Pipe__c();
            record.OU_NAME__c = 'AMER ACC';
            record.FULL_NAME__c = 'Test AE ' + (i % 5);
            record.EMP_EMAIL_ADDR__c = 'testae' + (i % 5) + '@company.com';
            record.OPEN_PIPE_PROD_NM__c = 'Data Cloud';
            record.OPEN_PIPE_OPTY_STG_NM__c = '0' + (Math.mod(i, 5) + 2) + ' - Test Stage';
            record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__c = 10 + (i * 2);
            record.OPEN_PIPE_AE_SCORE__c = 1.0 + (i * 0.2);
            record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c = 100000 + (i * 10000);
            record.MACROSGMENT__c = 'ENTR';
            record.PRIMARY_INDUSTRY__c = 'Technology';
            record.LEARNER_PROFILE_ID__c = 'LP' + (i % 5);
            testRecords.add(record);
        }
        
        insert testRecords;
    }
    
    @IsTest
    static void testClosureProbabilityAnalysis() {
        Test.startTest();
        
        // Test closure probability analysis
        ANAgentOpenPipeAnalysisV3Handler.Request request = new ANAgentOpenPipeAnalysisV3Handler.Request();
        request.ouName = 'AMER ACC';
        request.includeClosureProb = true;
        request.limitN = 5;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = 
            ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{request});
        
        System.assertEquals(1, responses.size(), 'Should return one response');
        String message = responses[0].message;
        
        // Verify closure probability section is included
        System.assert(message.contains('AE Closure Probability Analysis'), 'Should contain closure probability section');
        System.assert(message.contains('closure probability'), 'Should contain probability information');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testStageBottleneckAnalysis() {
        Test.startTest();
        
        // Test stage bottleneck analysis
        ANAgentOpenPipeAnalysisV3Handler.Request request = new ANAgentOpenPipeAnalysisV3Handler.Request();
        request.ouName = 'AMER ACC';
        request.includeStageBottlenecks = true;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = 
            ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{request});
        
        System.assertEquals(1, responses.size(), 'Should return one response');
        String message = responses[0].message;
        
        // Verify stage bottleneck section is included
        System.assert(message.contains('Stage Bottleneck Analysis'), 'Should contain bottleneck section');
        System.assert(message.contains('days vs peer'), 'Should contain peer comparison');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testProductMarketFitAnalysis() {
        Test.startTest();
        
        // Test product-market fit analysis
        ANAgentOpenPipeAnalysisV3Handler.Request request = new ANAgentOpenPipeAnalysisV3Handler.Request();
        request.ouName = 'AMER ACC';
        request.includePMF = true;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = 
            ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{request});
        
        System.assertEquals(1, responses.size(), 'Should return one response');
        String message = responses[0].message;
        
        // Verify PMF section is included
        System.assert(message.contains('Product-Market Fit Analysis'), 'Should contain PMF section');
        System.assert(message.contains('performs'), 'Should contain performance comparison');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testAEBenchmarkAnalysis() {
        Test.startTest();
        
        // Test AE benchmark analysis
        ANAgentOpenPipeAnalysisV3Handler.Request request = new ANAgentOpenPipeAnalysisV3Handler.Request();
        request.ouName = 'AMER ACC';
        request.includeAEBenchmarks = true;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = 
            ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{request});
        
        System.assertEquals(1, responses.size(), 'Should return one response');
        String message = responses[0].message;
        
        // Verify AE benchmark section is included
        System.assert(message.contains('AE Performance Benchmarking'), 'Should contain benchmark section');
        System.assert(message.contains('percentile'), 'Should contain percentile information');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testHealthScoreAnalysis() {
        Test.startTest();
        
        // Test health score analysis
        ANAgentOpenPipeAnalysisV3Handler.Request request = new ANAgentOpenPipeAnalysisV3Handler.Request();
        request.ouName = 'AMER ACC';
        request.includeHealthScore = true;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = 
            ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{request});
        
        System.assertEquals(1, responses.size(), 'Should return one response');
        String message = responses[0].message;
        
        // Verify health score section is included
        System.assert(message.contains('Pipeline Health Score'), 'Should contain health score section');
        System.assert(message.contains('/10'), 'Should contain score out of 10');
        System.assert(message.contains('Score Breakdown'), 'Should contain score breakdown');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testAllIntelligenceCapabilities() {
        Test.startTest();
        
        // Test all intelligence capabilities together
        ANAgentOpenPipeAnalysisV3Handler.Request request = new ANAgentOpenPipeAnalysisV3Handler.Request();
        request.ouName = 'AMER ACC';
        request.includeClosureProb = true;
        request.includeStageBottlenecks = true;
        request.includePMF = true;
        request.includeAEBenchmarks = true;
        request.includeHealthScore = true;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = 
            ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{request});
        
        System.assertEquals(1, responses.size(), 'Should return one response');
        String message = responses[0].message;
        
        // Verify all sections are included
        System.assert(message.contains('AE Closure Probability Analysis'), 'Should contain closure probability section');
        System.assert(message.contains('Stage Bottleneck Analysis'), 'Should contain bottleneck section');
        System.assert(message.contains('Product-Market Fit Analysis'), 'Should contain PMF section');
        System.assert(message.contains('AE Performance Benchmarking'), 'Should contain benchmark section');
        System.assert(message.contains('Pipeline Health Score'), 'Should contain health score section');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testFeatureToggles() {
        Test.startTest();
        
        // Test with all features disabled
        ANAgentOpenPipeAnalysisV3Handler.Request request = new ANAgentOpenPipeAnalysisV3Handler.Request();
        request.ouName = 'AMER ACC';
        request.includeClosureProb = false;
        request.includeStageBottlenecks = false;
        request.includePMF = false;
        request.includeAEBenchmarks = false;
        request.includeHealthScore = false;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = 
            ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{request});
        
        System.assertEquals(1, responses.size(), 'Should return one response');
        String message = responses[0].message;
        
        // Verify intelligence sections are not included
        System.assert(!message.contains('AE Closure Probability Analysis'), 'Should not contain closure probability section');
        System.assert(!message.contains('Stage Bottleneck Analysis'), 'Should not contain bottleneck section');
        System.assert(!message.contains('Product-Market Fit Analysis'), 'Should not contain PMF section');
        System.assert(!message.contains('AE Performance Benchmarking'), 'Should not contain benchmark section');
        System.assert(!message.contains('Pipeline Health Score'), 'Should not contain health score section');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testDefaultValues() {
        Test.startTest();
        
        // Test with no intelligence flags set (should default to false)
        ANAgentOpenPipeAnalysisV3Handler.Request request = new ANAgentOpenPipeAnalysisV3Handler.Request();
        request.ouName = 'AMER ACC';
        // Don't set any intelligence flags
        
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = 
            ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{request});
        
        System.assertEquals(1, responses.size(), 'Should return one response');
        String message = responses[0].message;
        
        // Verify intelligence sections are not included by default
        System.assert(!message.contains('AE Closure Probability Analysis'), 'Should not contain closure probability section by default');
        System.assert(!message.contains('Stage Bottleneck Analysis'), 'Should not contain bottleneck section by default');
        System.assert(!message.contains('Product-Market Fit Analysis'), 'Should not contain PMF section by default');
        System.assert(!message.contains('AE Performance Benchmarking'), 'Should not contain benchmark section by default');
        System.assert(!message.contains('Pipeline Health Score'), 'Should not contain health score section by default');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testErrorHandling() {
        Test.startTest();
        
        // Test with invalid OU name
        ANAgentOpenPipeAnalysisV3Handler.Request request = new ANAgentOpenPipeAnalysisV3Handler.Request();
        request.ouName = 'INVALID_OU';
        request.includeClosureProb = true;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = 
            ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{request});
        
        System.assertEquals(1, responses.size(), 'Should return one response');
        String message = responses[0].message;
        
        // Should handle error gracefully
        System.assert(message.contains('Open Pipe Analysis') || message.contains('Error'), 'Should contain analysis or error message');
        
        Test.stopTest();
    }
}
