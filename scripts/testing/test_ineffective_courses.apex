/**
 * Test script for the new ineffective courses functionality
 * Tests finding courses with 0 influenced ACV
 */
@isTest
public class TestIneffectiveCourses {
    
    @TestSetup
    static void setupTestData() {
        // Create test APM outcome records with 0 influenced ACV
        List<apm_outcome_v2__c> testRecords = new List<apm_outcome_v2__c>();
        
        // Test record 1: ACV KPI with 0 influenced ACV
        testRecords.add(new apm_outcome_v2__c(
            OFFERING_LABEL__c = 'Test Course 1 - No ACV Impact',
            KPI_NM__c = 'ACV',
            TOTAL_INFLUENCED_ACV__c = 0,
            CALCULATED_LIFT__c = 0.05,
            MEAN_EFFECTIVENESS__c = 0.3,
            MACRO_SEGMENT__c = 'CMRCL',
            FISCAL_QUARTER__c = '2024-Q1',
            CreatedDate = Date.today().addMonths(-3) // Created 3 months ago
        ));
        
        // Test record 2: ACV KPI with 0 influenced ACV, different segment
        testRecords.add(new apm_outcome_v2__c(
            OFFERING_LABEL__c = 'Test Course 2 - No ACV Impact',
            KPI_NM__c = 'ACV',
            TOTAL_INFLUENCED_ACV__c = 0,
            CALCULATED_LIFT__c = 0.02,
            MEAN_EFFECTIVENESS__c = 0.2,
            MACRO_SEGMENT__c = 'ESMB',
            FISCAL_QUARTER__c = '2024-Q1',
            CreatedDate = Date.today().addMonths(-6) // Created 6 months ago
        ));
        
        // Test record 3: ACV KPI with 0 influenced ACV, older record
        testRecords.add(new apm_outcome_v2__c(
            OFFERING_LABEL__c = 'Test Course 3 - No ACV Impact',
            KPI_NM__c = 'ACV',
            TOTAL_INFLUENCED_ACV__c = 0,
            CALCULATED_LIFT__c = 0.01,
            MEAN_EFFECTIVENESS__c = 0.1,
            MACRO_SEGMENT__c = 'ENTR',
            FISCAL_QUARTER__c = '2024-Q1',
            CreatedDate = Date.today().addMonths(-12) // Created 12 months ago
        ));
        
        // Test record 4: ACV KPI with positive influenced ACV (should not be returned)
        testRecords.add(new apm_outcome_v2__c(
            OFFERING_LABEL__c = 'Test Course 4 - Has ACV Impact',
            KPI_NM__c = 'ACV',
            TOTAL_INFLUENCED_ACV__c = 100000,
            CALCULATED_LIFT__c = 0.15,
            MEAN_EFFECTIVENESS__c = 0.8,
            MACRO_SEGMENT__c = 'CMRCL',
            FISCAL_QUARTER__c = '2024-Q1',
            CreatedDate = Date.today().addMonths(-3)
        ));
        
        insert testRecords;
    }
    
    @isTest
    static void testFindIneffectiveCourses() {
        // Test finding ineffective courses (0 influenced ACV)
        ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult result = 
            ANAgentOfferingEfficacyServiceBasic.findIneffectiveCourses('ACV', null, null, null, null, 100);
        
        System.assert(result.success, 'Should successfully find ineffective courses');
        System.assertEquals(3, result.totalRecordCount, 'Should find 3 courses with 0 influenced ACV');
        System.assert(result.message.contains('3 records'), 'Message should indicate 3 records found');
        
        // Verify all returned courses have 0 influenced ACV
        for (ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record : result.efficacyRecords) {
            System.assertEquals(0, record.totalInfluencedAcv, 'All returned courses should have 0 influenced ACV');
        }
    }
    
    @isTest
    static void testFindIneffectiveCoursesByDate() {
        // Test finding ineffective courses created in the past 9 months
        ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult result = 
            ANAgentOfferingEfficacyServiceBasic.findIneffectiveCoursesByDate('ACV', null, null, null, null, 9, 100);
        
        System.assert(result.success, 'Should successfully find ineffective courses by date');
        System.assertEquals(2, result.totalRecordCount, 'Should find 2 courses with 0 influenced ACV created in past 9 months');
        System.assert(result.message.contains('2 records'), 'Message should indicate 2 records found');
        
        // Verify all returned courses have 0 influenced ACV
        for (ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record : result.efficacyRecords) {
            System.assertEquals(0, record.totalInfluencedAcv, 'All returned courses should have 0 influenced ACV');
        }
    }
    
    @isTest
    static void testFindIneffectiveCoursesWithMacroSegment() {
        // Test finding ineffective courses with specific macro segment
        ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult result = 
            ANAgentOfferingEfficacyServiceBasic.findIneffectiveCourses('ACV', null, 'CMRCL', null, null, 100);
        
        System.assert(result.success, 'Should successfully find ineffective courses with CMRCL segment');
        System.assertEquals(1, result.totalRecordCount, 'Should find 1 course with 0 influenced ACV in CMRCL segment');
    }
    
    @isTest
    static void testFindIneffectiveCoursesWithFiscalQuarter() {
        // Test finding ineffective courses with specific fiscal quarter
        ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult result = 
            ANAgentOfferingEfficacyServiceBasic.findIneffectiveCourses('ACV', null, null, '2024-Q1', null, 100);
        
        System.assert(result.success, 'Should successfully find ineffective courses with 2024-Q1 fiscal quarter');
        System.assertEquals(3, result.totalRecordCount, 'Should find 3 courses with 0 influenced ACV in 2024-Q1');
    }
    
    @isTest
    static void testFindIneffectiveCoursesNoResults() {
        // Test finding ineffective courses for a KPI that doesn't exist
        ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult result = 
            ANAgentOfferingEfficacyServiceBasic.findIneffectiveCourses('NON_EXISTENT_KPI', null, null, null, null, 100);
        
        System.assert(result.success, 'Should successfully execute query even with no results');
        System.assertEquals(0, result.totalRecordCount, 'Should find 0 courses for non-existent KPI');
        System.assert(result.message.contains('No courses found'), 'Message should indicate no courses found');
    }
    
    @isTest
    static void testHandlerFindIneffectiveCourses() {
        // Test the handler method for finding ineffective courses
        ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
        request.action = 'FindIneffectiveCourses';
        request.kpiName = 'ACV';
        request.maxResults = 100;
        
        List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest> requests = new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{request};
        List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> responses = 
            ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(requests);
        
        System.assertEquals(1, responses.size(), 'Should return 1 response');
        System.assert(responses[0].success, 'Response should be successful');
        System.assertEquals(3, responses[0].totalRecordCount, 'Should find 3 courses with 0 influenced ACV');
    }
    
    @isTest
    static void testHandlerFindIneffectiveCoursesByDate() {
        // Test the handler method for finding ineffective courses by date
        ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
        request.action = 'FindIneffectiveCoursesByDate';
        request.kpiName = 'ACV';
        request.monthsBack = 9;
        request.maxResults = 100;
        
        List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest> requests = new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{request};
        List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> responses = 
            ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(requests);
        
        System.assertEquals(1, responses.size(), 'Should return 1 response');
        System.assert(responses[0].success, 'Response should be successful');
        System.assertEquals(2, responses[0].totalRecordCount, 'Should find 2 courses with 0 influenced ACV created in past 9 months');
    }
}

