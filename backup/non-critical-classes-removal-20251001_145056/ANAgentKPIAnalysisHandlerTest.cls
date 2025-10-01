/**
 * @description Comprehensive test class for ANAgentKPIAnalysisHandler
 * @author AI Assistant
 * @version 1.0
 */
@IsTest
public class ANAgentKPIAnalysisHandlerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test data for AMER ACC
        List<AGENT_OU_PIPELINE_V2__c> testRecords = new List<AGENT_OU_PIPELINE_V2__c>();
        
        // Ramping AE (AE_Score <= 3, Coverage < 2)
        testRecords.add(createTestRecord('AMER ACC', 'John Ramping', 'john.ramping@test.com', 'LP001', 
                                       2.5, 1.5, 'Early-Stage Pipeline Percentage', 
                                       'A pipe assessment and more targeted client communication could help you reduce your early-stage deals and increase your pipe quality.',
                                       'Focus on early-stage pipeline development', 5, 3, 100000, 50000));
        
        // Non-ramping AE (AE_Score > 3, Coverage >= 2)
        testRecords.add(createTestRecord('AMER ACC', 'Jane Experienced', 'jane.experienced@test.com', 'LP002', 
                                       4.2, 3.1, 'Sales Development Pipeline Generated', 
                                       'Your sales development efforts are showing strong results. Continue focusing on high-quality pipeline generation.',
                                       'Maintain current pipeline generation strategy', 12, 8, 250000, 120000));
        
        // AE with missing actionable content
        testRecords.add(createTestRecord('AMER ACC', 'Bob Missing', 'bob.missing@test.com', 'LP003', 
                                       3.8, 2.8, 'Coverage Analysis', 
                                       null, // Missing actionable content
                                       'Coverage analysis shows room for improvement', 7, 5, 150000, 75000));
        
        // AE with missing meeting data
        testRecords.add(createTestRecord('AMER ACC', 'Alice NoMeetings', 'alice.nomeetings@test.com', 'LP004', 
                                       3.1, 2.2, 'Deal Size', 
                                       'Focus on larger deal sizes to improve overall performance.',
                                       'Deal size optimization strategy', null, null, 200000, 100000));
        
        insert testRecords;
    }
    
    // Helper method to create test records
    private static AGENT_OU_PIPELINE_V2__c createTestRecord(String ouName, String fullName, String email, 
                                                           String learnerProfileId, Decimal aeScore, Decimal coverage,
                                                           String definition, String actionable, String description,
                                                           Integer meetings, Integer callConnects, 
                                                           Decimal acv, Decimal pg) {
        AGENT_OU_PIPELINE_V2__c record = new AGENT_OU_PIPELINE_V2__c();
        record.OU_NAME__c = ouName;
        record.FULL_NAME__c = fullName;
        record.EMP_EMAIL_ADDR__c = email;
        record.LEARNER_PROFILE_ID__c = learnerProfileId;
        record.WORK_LOCATION_COUNTRY__c = 'United States';
        record.AE_Score__c = aeScore;
        record.Coverage__c = coverage;
        record.DEFINITION__c = definition;
        record.ACTIONABLE__c = actionable;
        record.DESCRIPTION__c = description;
        record.CQ_CUSTOMER_MEETING__c = meetings;
        record.CQ_CALL_CONNECT__c = callConnects;
        record.CQ_ACV__c = acv;
        record.CQ_PG__c = pg;
        record.Fiscal_Quarter__c = 'THIS_FISCAL_QUARTER';
        return record;
    }
    
    @IsTest
    static void testGrowthFactorsAnalysis() {
        Test.startTest();
        
        ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
        request.analysisType = 'GROWTH_FACTORS';
        request.primaryDimension = 'OU_NAME';
        request.primaryValue = 'AMER ACC';
        request.timeFrame = 'CURRENT';
        request.includeRampAnalysis = true;
        
        List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = 
            ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request});
        
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
        
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assertEquals('GROWTH_FACTORS', response.analysisType, 'Analysis type should match');
        System.assertEquals('AMER ACC', response.ouName, 'OU name should match');
        System.assertEquals('CURRENT', response.timeframe, 'Timeframe should match');
        
        // Should find 4 AMER ACC records
        System.assertEquals(4, response.totalAEs, 'Should find 4 AMER ACC AEs');
        System.assertEquals(4, response.totalRecordCount, 'Should have 4 total records');
        
        // Check that warnings are populated
        System.assertNotEquals(null, response.warnings, 'Should have warnings list');
        System.assert(response.warnings.size() > 0, 'Should have at least one warning');
        
        // Check aggregate data
        System.assertNotEquals(null, response.avgScore, 'Should have average score');
        System.assertNotEquals(null, response.avgCoverage, 'Should have average coverage');
        System.assert(response.avgScore > 0, 'Average score should be positive');
        System.assert(response.avgCoverage > 0, 'Average coverage should be positive');
    }
    
    @IsTest
    static void testMeetingsAnalysis() {
        Test.startTest();
        
        ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
        request.analysisType = 'MEETINGS';
        request.primaryDimension = 'OU_NAME';
        request.primaryValue = 'AMER ACC';
        request.timeFrame = 'CURRENT';
        
        List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = 
            ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request});
        
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
        
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assertEquals('MEETINGS', response.analysisType, 'Analysis type should match');
        
        // Check meeting data
        System.assertNotEquals(null, response.totalMeetings, 'Should have total meetings');
        System.assertNotEquals(null, response.totalCallConnects, 'Should have total call connects');
        System.assert(response.totalMeetings > 0, 'Total meetings should be positive');
        System.assert(response.totalCallConnects > 0, 'Total call connects should be positive');
    }
    
    @IsTest
    static void testRevenueAnalysis() {
        Test.startTest();
        
        ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
        request.analysisType = 'REVENUE';
        request.primaryDimension = 'OU_NAME';
        request.primaryValue = 'AMER ACC';
        request.timeFrame = 'CURRENT';
        
        List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = 
            ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request});
        
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
        
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assertEquals('REVENUE', response.analysisType, 'Analysis type should match');
        
        // Check revenue data
        System.assertNotEquals(null, response.totalACV, 'Should have total ACV');
        System.assertNotEquals(null, response.totalPG, 'Should have total PG');
        System.assert(response.totalACV > 0, 'Total ACV should be positive');
        System.assert(response.totalPG > 0, 'Total PG should be positive');
    }
    
    @IsTest
    static void testErrorHandling() {
        Test.startTest();
        
        ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
        // Missing required analysisType
        request.primaryDimension = 'OU_NAME';
        request.primaryValue = 'AMER ACC';
        
        List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = 
            ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request});
        
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
        
        System.assertEquals(false, response.success, 'Response should indicate failure');
        System.assert(response.message.contains('Error in standard processing'), 'Should indicate processing error');
        System.assertNotEquals(null, response.warnings, 'Should have warnings list');
    }
    
    @IsTest
    static void testLegacyMethod() {
        Test.startTest();
        
        String result = ANAgentKPIAnalysisHandler.analyzeKPIs('GROWTH_FACTORS', 'CURRENT', 'OU_NAME', 
                                                             'OU_NAME__c=\'AMER ACC\'', null, false, 10, 'COUNT');
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.contains('KPI Analysis completed successfully'), 'Should indicate successful analysis');
    }
    
    @IsTest
    static void testMultipleRequests() {
        Test.startTest();
        
        List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest> requests = new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>();
        
        // Growth factors request
        ANAgentKPIAnalysisHandler.KPIAnalysisRequest request1 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
        request1.analysisType = 'GROWTH_FACTORS';
        request1.primaryDimension = 'OU_NAME';
        request1.primaryValue = 'AMER ACC';
        request1.timeFrame = 'CURRENT';
        requests.add(request1);
        
        // Meetings request
        ANAgentKPIAnalysisHandler.KPIAnalysisRequest request2 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
        request2.analysisType = 'MEETINGS';
        request2.primaryDimension = 'OU_NAME';
        request2.primaryValue = 'AMER ACC';
        request2.timeFrame = 'CURRENT';
        requests.add(request2);
        
        List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = 
            ANAgentKPIAnalysisHandler.analyzeKPIs(requests);
        
        Test.stopTest();
        
        // Assertions
        System.assertEquals(2, responses.size(), 'Should return two responses');
        
        // Check first response (Growth Factors)
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response1 = responses[0];
        System.assertEquals(true, response1.success, 'First response should be successful');
        System.assertEquals('GROWTH_FACTORS', response1.analysisType, 'First response should be Growth Factors');
        
        // Check second response (Meetings)
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response2 = responses[1];
        System.assertEquals(true, response2.success, 'Second response should be successful');
        System.assertEquals('MEETINGS', response2.analysisType, 'Second response should be Meetings');
    }
}
