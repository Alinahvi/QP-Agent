@isTest
public class ANAgentOpenPipeAnalysisV3ServiceEnhancedTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test data for Agent_Open_Pipe__c
        List<Agent_Open_Pipe__c> testRecords = new List<Agent_Open_Pipe__c>();
        
        // Create test records with various scenarios
        for (Integer i = 0; i < 5; i++) {
            Agent_Open_Pipe__c record = new Agent_Open_Pipe__c();
            record.OU_NAME__C = 'Amer-ACC';
            record.OPEN_PIPE_PROD_NM__C = 'Tableau Server';
            record.WORK_LOCATION_COUNTRY__C = 'United States';
            record.MACROSGMENT__C = 'Enterprise';
            record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C = 100000 + (i * 10000);
            record.OPEN_PIPE_OPTY_STG_NM__C = 'Proposal';
            record.FULL_NAME__C = 'Test AE ' + i;
            record.PRIMARY_INDUSTRY__C = 'Technology';
            record.OPEN_PIPE_AE_SCORE__C = 80 + i;
            record.OPEN_PIPE_OPTY_NM__C = 'Test Opportunity ' + i;
            testRecords.add(record);
        }
        
        insert testRecords;
    }
    
    @isTest
    static void testAnalyzeOpenPipeData() {
        Test.startTest();
        
        // Test with valid parameters
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipeData('Amer-ACC', 'Tableau Server', 'United States', 'Enterprise');
        
        // Verify the result contains expected sections
        System.assert(result.contains('Executive Summary'), 'Result should contain Executive Summary');
        System.assert(result.contains('Analysis Summary'), 'Result should contain Analysis Summary');
        System.assert(result.contains('Results'), 'Result should contain Results section');
        System.assert(result.contains('Actionable Insights'), 'Result should contain Actionable Insights');
        
        Test.stopTest();
    }
    
    @isTest
    static void testAnalyzeOpenPipeDataWithEmptyParameters() {
        Test.startTest();
        
        // Test with empty parameters
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipeData('', '', '', '');
        
        // Verify the result still contains expected sections
        System.assert(result.contains('Executive Summary'), 'Result should contain Executive Summary');
        System.assert(result.contains('Analysis Summary'), 'Result should contain Analysis Summary');
        
        Test.stopTest();
    }
    
    @isTest
    static void testAnalyzeOpenPipeDataWithNullParameters() {
        Test.startTest();
        
        // Test with null parameters
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipeData(null, null, null, null);
        
        // Verify the result still contains expected sections
        System.assert(result.contains('Executive Summary'), 'Result should contain Executive Summary');
        System.assert(result.contains('Analysis Summary'), 'Result should contain Analysis Summary');
        
        Test.stopTest();
    }
    
    @isTest
    static void testAnalyzeOpenPipeDataWithPartialParameters() {
        Test.startTest();
        
        // Test with only OU parameter
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipeData('Amer-ACC', null, null, null);
        
        // Verify the result contains expected sections
        System.assert(result.contains('Executive Summary'), 'Result should contain Executive Summary');
        System.assert(result.contains('Analysis Summary'), 'Result should contain Analysis Summary');
        
        Test.stopTest();
    }
    
    @isTest
    static void testAnalyzeOpenPipeDataWithInvalidParameters() {
        Test.startTest();
        
        // Test with invalid parameters that should return no data
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipeData('Invalid-OU', 'Invalid-Product', 'Invalid-Country', 'Invalid-Segment');
        
        // Verify the result contains expected sections even with no data
        System.assert(result.contains('Executive Summary'), 'Result should contain Executive Summary');
        System.assert(result.contains('Analysis Summary'), 'Result should contain Analysis Summary');
        
        Test.stopTest();
    }
    
    @isTest
    static void testQueryOpenPipeData() {
        Test.startTest();
        
        // Test the private method through public method
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipeData('Amer-ACC', 'Tableau Server', 'United States', 'Enterprise');
        
        // Verify the result contains data from our test records
        System.assert(result.contains('Test AE'), 'Result should contain test AE names');
        System.assert(result.contains('Test Opportunity'), 'Result should contain test opportunity names');
        
        Test.stopTest();
    }
    
    @isTest
    static void testBuildExecutiveSummary() {
        Test.startTest();
        
        // Test the private method through public method
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipeData('Amer-ACC', 'Tableau Server', 'United States', 'Enterprise');
        
        // Verify the result contains executive summary elements
        System.assert(result.contains('📊'), 'Result should contain emojis');
        System.assert(result.contains('Total ACV'), 'Result should contain ACV information');
        
        Test.stopTest();
    }
    
    @isTest
    static void testBuildAnalysisSummary() {
        Test.startTest();
        
        // Test the private method through public method
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipeData('Amer-ACC', 'Tableau Server', 'United States', 'Enterprise');
        
        // Verify the result contains analysis summary elements
        System.assert(result.contains('Analysis Summary'), 'Result should contain Analysis Summary section');
        System.assert(result.contains('Data Points'), 'Result should contain data points information');
        
        Test.stopTest();
    }
    
    @isTest
    static void testBuildResultsSection() {
        Test.startTest();
        
        // Test the private method through public method
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipeData('Amer-ACC', 'Tableau Server', 'United States', 'Enterprise');
        
        // Verify the result contains results section elements
        System.assert(result.contains('Results'), 'Result should contain Results section');
        System.assert(result.contains('Stage Distribution'), 'Result should contain stage distribution');
        System.assert(result.contains('Top Account Executives'), 'Result should contain top AEs');
        
        Test.stopTest();
    }
    
    @isTest
    static void testBuildActionableInsights() {
        Test.startTest();
        
        // Test the private method through public method
        String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipeData('Amer-ACC', 'Tableau Server', 'United States', 'Enterprise');
        
        // Verify the result contains actionable insights elements
        System.assert(result.contains('Actionable Insights'), 'Result should contain Actionable Insights section');
        System.assert(result.contains('Pipeline Health'), 'Result should contain pipeline health analysis');
        System.assert(result.contains('Stage Optimization'), 'Result should contain stage optimization');
        
        Test.stopTest();
    }
}
