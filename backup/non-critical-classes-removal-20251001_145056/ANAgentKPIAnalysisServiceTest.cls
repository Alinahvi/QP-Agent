/**
 * @description Comprehensive test class for ANAgentKPIAnalysisService
 * @author AI Assistant
 * @version 1.0
 */
@IsTest
public class ANAgentKPIAnalysisServiceTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test data for AMER ACC using V3 object
        List<AGENT_OU_PIPELINE_V3__c> testRecords = new List<AGENT_OU_PIPELINE_V3__c>();
        
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
        
        // Different OU for comparison
        testRecords.add(createTestRecord('AMER REG', 'Mike Different', 'mike.different@test.com', 'LP005', 
                                       4.5, 3.5, 'Sales Play Win Percentage', 
                                       'Excellent win percentage. Continue current approach.',
                                       'Maintain current sales play strategy', 15, 10, 300000, 150000));
        
        insert testRecords;
    }
    
    // Helper method to create test records
    private static AGENT_OU_PIPELINE_V3__c createTestRecord(String ouName, String fullName, String email, 
                                                           String learnerProfileId, Decimal aeScore, Decimal coverage,
                                                           String definition, String actionable, String description,
                                                           Integer meetings, Integer callConnects, 
                                                           Decimal acv, Decimal pg) {
        AGENT_OU_PIPELINE_V3__c record = new AGENT_OU_PIPELINE_V3__c();
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
        record.THIS_FISCAL_QUARTER__c = true;
        record.LAST_FISCAL_QUARTER__c = false;
        return record;
    }
    
    @IsTest
    static void testGrowthFactorsAnalysis() {
        Test.startTest();
        
        ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
        request.analysisType = 'GROWTH_FACTORS';
        request.primaryDimension = 'OU_NAME';
        request.primaryValue = 'AMER ACC';
        request.timeFrame = 'CURRENT';
        request.includeRampAnalysis = true;
        
        List<ANAgentKPIAnalysisService.KPIResponse> responses = 
            ANAgentKPIAnalysisService.analyzeKPIs(new List<ANAgentKPIAnalysisService.KPIAnalysisRequest>{request});
        
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentKPIAnalysisService.KPIResponse response = responses[0];
        
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assertEquals('GROWTH_FACTORS', response.analysisType, 'Analysis type should match');
        System.assertEquals('AMER ACC', response.ouName, 'OU name should match');
        System.assertEquals('CURRENT', response.timeframe, 'Timeframe should match');
        
        // Should find 4 AMER ACC records
        System.assertEquals(4, response.totalAEs, 'Should find 4 AMER ACC AEs');
        System.assertEquals(4, response.rows.size(), 'Should have 4 rows');
        
        // Check that actionable content is populated
        Boolean foundActionable = false;
        for (ANAgentKPIAnalysisService.KPIResponse.Row row : response.rows) {
            if (String.isNotBlank(row.actionable)) {
                foundActionable = true;
                break;
            }
        }
        System.assertEquals(true, foundActionable, 'Should have at least one row with actionable content');
        
        // Check ramp analysis
        Boolean foundRamping = false;
        for (ANAgentKPIAnalysisService.KPIResponse.Row row : response.rows) {
            if (row.isRamping != null) {
                foundRamping = true;
                break;
            }
        }
        System.assertEquals(true, foundRamping, 'Should have ramp analysis data');
        
        // Check aggregates
        System.assertNotEquals(null, response.agg, 'Should have aggregate data');
        System.assert(response.agg.avgScore > 0, 'Average score should be positive');
        System.assert(response.agg.avgCoverage > 0, 'Average coverage should be positive');
    }
    
    @IsTest
    static void testMeetingsAnalysis() {
        Test.startTest();
        
        ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
        request.analysisType = 'MEETINGS';
        request.primaryDimension = 'OU_NAME';
        request.primaryValue = 'AMER ACC';
        request.timeFrame = 'CURRENT';
        
        List<ANAgentKPIAnalysisService.KPIResponse> responses = 
            ANAgentKPIAnalysisService.analyzeKPIs(new List<ANAgentKPIAnalysisService.KPIAnalysisRequest>{request});
        
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentKPIAnalysisService.KPIResponse response = responses[0];
        
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assertEquals('MEETINGS', response.analysisType, 'Analysis type should match');
        
        // Check meeting data
        Boolean foundMeetings = false;
        for (ANAgentKPIAnalysisService.KPIResponse.Row row : response.rows) {
            if (row.cqMeetings != null && row.cqMeetings > 0) {
                foundMeetings = true;
                break;
            }
        }
        System.assertEquals(true, foundMeetings, 'Should have meeting data');
        
        // Check aggregates
        System.assertNotEquals(null, response.agg, 'Should have aggregate data');
        System.assert(response.agg.totalMeetings > 0, 'Total meetings should be positive');
    }
    
    @IsTest
    static void testRevenueAnalysis() {
        Test.startTest();
        
        ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
        request.analysisType = 'REVENUE';
        request.primaryDimension = 'OU_NAME';
        request.primaryValue = 'AMER ACC';
        request.timeFrame = 'CURRENT';
        
        List<ANAgentKPIAnalysisService.KPIResponse> responses = 
            ANAgentKPIAnalysisService.analyzeKPIs(new List<ANAgentKPIAnalysisService.KPIAnalysisRequest>{request});
        
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentKPIAnalysisService.KPIResponse response = responses[0];
        
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assertEquals('REVENUE', response.analysisType, 'Analysis type should match');
        
        // Check revenue data
        Boolean foundRevenue = false;
        for (ANAgentKPIAnalysisService.KPIResponse.Row row : response.rows) {
            if (row.cqACV != null && row.cqACV > 0) {
                foundRevenue = true;
                break;
            }
        }
        System.assertEquals(true, foundRevenue, 'Should have revenue data');
        
        // Check aggregates
        System.assertNotEquals(null, response.agg, 'Should have aggregate data');
        System.assert(response.agg.totalACV > 0, 'Total ACV should be positive');
        System.assert(response.agg.totalPG > 0, 'Total PG should be positive');
    }
    
    @IsTest
    static void testDataQualityWarnings() {
        Test.startTest();
        
        ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
        request.analysisType = 'GROWTH_FACTORS';
        request.primaryDimension = 'OU_NAME';
        request.primaryValue = 'AMER ACC';
        request.timeFrame = 'CURRENT';
        
        List<ANAgentKPIAnalysisService.KPIResponse> responses = 
            ANAgentKPIAnalysisService.analyzeKPIs(new List<ANAgentKPIAnalysisService.KPIAnalysisRequest>{request});
        
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentKPIAnalysisService.KPIResponse response = responses[0];
        
        // Should have warnings for missing actionable content
        System.assertNotEquals(null, response.warnings, 'Should have warnings list');
        System.assert(response.warnings.size() > 0, 'Should have at least one warning');
        
        Boolean foundMissingActionableWarning = false;
        for (String warning : response.warnings) {
            if (warning.contains('missing actionable content')) {
                foundMissingActionableWarning = true;
                break;
            }
        }
        System.assertEquals(true, foundMissingActionableWarning, 'Should warn about missing actionable content');
    }
    
    @IsTest
    static void testRampAnalysis() {
        Test.startTest();
        
        ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
        request.analysisType = 'SCORECARD';
        request.primaryDimension = 'OU_NAME';
        request.primaryValue = 'AMER ACC';
        request.timeFrame = 'CURRENT';
        request.includeRampAnalysis = true;
        
        List<ANAgentKPIAnalysisService.KPIResponse> responses = 
            ANAgentKPIAnalysisService.analyzeKPIs(new List<ANAgentKPIAnalysisService.KPIAnalysisRequest>{request});
        
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentKPIAnalysisService.KPIResponse response = responses[0];
        
        // Check ramp analysis
        Boolean foundRamping = false;
        Boolean foundNonRamping = false;
        for (ANAgentKPIAnalysisService.KPIResponse.Row row : response.rows) {
            if (row.isRamping == true) {
                foundRamping = true;
                System.assertEquals('PipeGen:Renewal', row.rampTrack, 'Ramping AE should have PipeGen:Renewal track');
            } else if (row.isRamping == false) {
                foundNonRamping = true;
                System.assertEquals('OpenPipe:Stage2', row.rampTrack, 'Non-ramping AE should have OpenPipe:Stage2 track');
            }
        }
        System.assertEquals(true, foundRamping, 'Should have at least one ramping AE');
        System.assertEquals(true, foundNonRamping, 'Should have at least one non-ramping AE');
    }
    
    @IsTest
    static void testErrorHandling() {
        Test.startTest();
        
        ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
        // Missing required analysisType
        request.primaryDimension = 'OU_NAME';
        request.primaryValue = 'AMER ACC';
        
        List<ANAgentKPIAnalysisService.KPIResponse> responses = 
            ANAgentKPIAnalysisService.analyzeKPIs(new List<ANAgentKPIAnalysisService.KPIAnalysisRequest>{request});
        
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentKPIAnalysisService.KPIResponse response = responses[0];
        
        System.assertEquals(false, response.success, 'Response should indicate failure');
        System.assert(response.message.contains('Analysis type is required'), 'Should indicate missing analysis type');
    }
    
    @IsTest
    static void testLegacyMethod() {
        Test.startTest();
        
        String result = ANAgentKPIAnalysisService.analyzeKPIs('GROWTH_FACTORS', 'CURRENT', 'OU_NAME', 
                                                             'OU_NAME__c=\'AMER ACC\'', null, false, 10, 'COUNT');
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.contains('KPI Analysis completed successfully'), 'Should indicate successful analysis');
    }
    
    @IsTest
    static void testOutlierAnalysis() {
        Test.startTest();
        
        // Create request with outlier analysis enabled
        ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
        request.analysisType = 'MEETINGS';
        request.ouName = 'AMER ACC';
        request.timeFrame = 'CURRENT';
        request.enableOutliers = true;
        request.metrics = new List<String>{'CQ_CUSTOMER_MEETING__c', 'Coverage__c'};
        request.maxResults = 100;
        
        List<ANAgentKPIAnalysisService.KPIAnalysisResponse> responses = 
            ANAgentKPIAnalysisService.analyzeKPIs(new List<ANAgentKPIAnalysisService.KPIAnalysisRequest>{request});
        
        Test.stopTest();
        
        // Verify response
        System.assert(!responses.isEmpty(), 'Should have responses');
        ANAgentKPIAnalysisService.KPIAnalysisResponse response = responses[0];
        System.assert(response.success, 'Response should be successful');
        System.assertNotEquals(null, response.outlierResults, 'Should have outlier results');
        System.assertNotEquals(null, response.formattedMessage, 'Should have formatted message');
        System.assert(response.formattedMessage.contains('Outlier Analysis'), 'Should contain outlier analysis section');
    }
}
