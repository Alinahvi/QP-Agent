/**
 * Test class for ANAgentKPIResponseFormatter
 * Tests response formatting with outlier analysis
 * 
 * @version 1.0
 * @author AI Assistant
 */
@IsTest
public class ANAgentKPIResponseFormatterTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test KPI config
        KPI_Config__mdt testConfig = new KPI_Config__mdt();
        testConfig.KPI_Enable_Outliers__c = true;
        testConfig.KPI_MaxRows__c = 1000;
        testConfig.KPI_ZScore_Threshold__c = 2.5;
        testConfig.KPI_IQR_Multiplier__c = 1.5;
    }
    
    @IsTest
    static void testFormatResponseWithOutliers() {
        // Create test response
        ANAgentKPIAnalysisService.KPIAnalysisResponse response = new ANAgentKPIAnalysisService.KPIAnalysisResponse();
        response.success = true;
        response.analysisType = 'MEETINGS';
        response.timeFrame = 'CURRENT';
        response.ouName = 'AMER ACC';
        response.totalAEs = 10;
        response.avgCoverage = 2.5;
        response.totalMeetings = 150;
        response.totalCallConnects = 75;
        response.warnings = new List<String>{'2 AEs missing meeting data'};
        
        // Create test request
        ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
        request.analysisType = 'MEETINGS';
        request.timeFrame = 'CURRENT';
        request.ouName = 'AMER ACC';
        request.enableOutliers = true;
        
        // Create test outlier results
        Map<String, ANAgentKPIOutlierService.OutlierResult> outlierResults = new Map<String, ANAgentKPIOutlierService.OutlierResult>();
        
        ANAgentKPIOutlierService.OutlierResult meetingOutliers = new ANAgentKPIOutlierService.OutlierResult();
        meetingOutliers.method = 'Z-Score';
        meetingOutliers.metric = 'CQ_CUSTOMER_MEETING__c';
        meetingOutliers.statistics = new Map<String, Decimal>{
            'mean' => 15.0,
            'median' => 14.0,
            'stdDev' => 5.0,
            'q1' => 10.0,
            'q3' => 20.0
        };
        
        // Add high outlier
        ANAgentKPIOutlierService.OutlierData highOutlier = new ANAgentKPIOutlierService.OutlierData(
            'REC001', 'John High', 'john.high@test.com', 'LP001', 'AMER ACC', 'US', 
            30, 3.0, 16.0, 'HIGH'
        );
        meetingOutliers.highOutliers.add(highOutlier);
        
        // Add low outlier
        ANAgentKPIOutlierService.OutlierData lowOutlier = new ANAgentKPIOutlierService.OutlierData(
            'REC002', 'Jane Low', 'jane.low@test.com', 'LP002', 'AMER ACC', 'US', 
            5, -2.0, -9.0, 'LOW'
        );
        meetingOutliers.lowOutliers.add(lowOutlier);
        
        outlierResults.put('CQ_CUSTOMER_MEETING__c', meetingOutliers);
        
        Test.startTest();
        String formattedResponse = ANAgentKPIResponseFormatter.formatResponse(response, request, outlierResults);
        Test.stopTest();
        
        // Verify response formatting
        System.assertNotEquals(null, formattedResponse, 'Formatted response should not be null');
        System.assert(formattedResponse.contains('KPI Health Summary'), 'Should contain health summary');
        System.assert(formattedResponse.contains('Outlier Analysis'), 'Should contain outlier analysis');
        System.assert(formattedResponse.contains('John High'), 'Should contain high outlier name');
        System.assert(formattedResponse.contains('Jane Low'), 'Should contain low outlier name');
        System.assert(formattedResponse.contains('Benchmarks'), 'Should contain benchmarks section');
        System.assert(formattedResponse.contains('Recommendations'), 'Should contain recommendations');
    }
    
    @IsTest
    static void testFormatResponseWithoutOutliers() {
        // Create test response
        ANAgentKPIAnalysisService.KPIAnalysisResponse response = new ANAgentKPIAnalysisService.KPIAnalysisResponse();
        response.success = true;
        response.analysisType = 'GROWTH_FACTORS';
        response.timeFrame = 'CURRENT';
        response.ouName = 'EMEA SMB';
        response.totalAEs = 5;
        response.avgCoverage = 1.8;
        response.totalACV = 500000;
        response.totalPG = 250000;
        response.warnings = new List<String>();
        
        // Create test request
        ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
        request.analysisType = 'GROWTH_FACTORS';
        request.timeFrame = 'CURRENT';
        request.ouName = 'EMEA SMB';
        request.enableOutliers = false;
        
        Test.startTest();
        String formattedResponse = ANAgentKPIResponseFormatter.formatResponse(response, request, null);
        Test.stopTest();
        
        // Verify response formatting
        System.assertNotEquals(null, formattedResponse, 'Formatted response should not be null');
        System.assert(formattedResponse.contains('KPI Health Summary'), 'Should contain health summary');
        System.assert(formattedResponse.contains('Growth Factor Occurrences'), 'Should contain growth factors section');
        System.assert(!formattedResponse.contains('Outlier Analysis'), 'Should not contain outlier analysis');
        System.assert(formattedResponse.contains('EMEA SMB'), 'Should contain OU name');
        System.assert(formattedResponse.contains('500000'), 'Should contain ACV value');
    }
    
    @IsTest
    static void testFormatResponseWithLearnerProfiles() {
        // Create test response with learner profiles
        ANAgentKPIAnalysisService.KPIAnalysisResponse response = new ANAgentKPIAnalysisService.KPIAnalysisResponse();
        response.success = true;
        response.analysisType = 'MEETINGS';
        response.timeFrame = 'CURRENT';
        response.ouName = 'APAC REG';
        response.totalAEs = 3;
        response.totalMeetings = 45;
        response.warnings = new List<String>();
        
        // Create learner profiles
        List<ANAgentKPIAnalysisService.LearnerProfileData> learnerProfiles = new List<ANAgentKPIAnalysisService.LearnerProfileData>();
        
        ANAgentKPIAnalysisService.LearnerProfileData profile1 = new ANAgentKPIAnalysisService.LearnerProfileData();
        profile1.fullName = 'Alice Smith';
        profile1.manager = 'Bob Johnson';
        profile1.country = 'Singapore';
        learnerProfiles.add(profile1);
        
        ANAgentKPIAnalysisService.LearnerProfileData profile2 = new ANAgentKPIAnalysisService.LearnerProfileData();
        profile2.fullName = 'Charlie Brown';
        profile2.manager = 'Bob Johnson';
        profile2.country = 'Japan';
        learnerProfiles.add(profile2);
        
        response.learnerProfiles = learnerProfiles;
        
        // Create test request
        ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
        request.analysisType = 'MEETINGS';
        request.timeFrame = 'CURRENT';
        request.ouName = 'APAC REG';
        request.includeLearnerProfile = true;
        
        Test.startTest();
        String formattedResponse = ANAgentKPIResponseFormatter.formatResponse(response, request, null);
        Test.stopTest();
        
        // Verify response formatting
        System.assertNotEquals(null, formattedResponse, 'Formatted response should not be null');
        System.assert(formattedResponse.contains('Team Composition'), 'Should contain team composition');
        System.assert(formattedResponse.contains('Alice Smith'), 'Should contain team member name');
        System.assert(formattedResponse.contains('Bob Johnson'), 'Should contain manager name');
        System.assert(formattedResponse.contains('Singapore'), 'Should contain country');
    }
    
    @IsTest
    static void testFormatResponseWithWarnings() {
        // Create test response with warnings
        ANAgentKPIAnalysisService.KPIAnalysisResponse response = new ANAgentKPIAnalysisService.KPIAnalysisResponse();
        response.success = true;
        response.analysisType = 'REVENUE';
        response.timeFrame = 'PREVIOUS';
        response.ouName = 'UKI';
        response.totalAEs = 8;
        response.totalACV = 800000;
        response.totalPG = 400000;
        response.warnings = new List<String>{
            '3 AEs missing actionable content',
            '1 AE missing meeting data',
            'Data quality issues detected'
        };
        
        // Create test request
        ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
        request.analysisType = 'REVENUE';
        request.timeFrame = 'PREVIOUS';
        request.ouName = 'UKI';
        
        Test.startTest();
        String formattedResponse = ANAgentKPIResponseFormatter.formatResponse(response, request, null);
        Test.stopTest();
        
        // Verify response formatting
        System.assertNotEquals(null, formattedResponse, 'Formatted response should not be null');
        System.assert(formattedResponse.contains('Data Quality Notes'), 'Should contain data quality section');
        System.assert(formattedResponse.contains('3 AEs missing actionable content'), 'Should contain warning');
        System.assert(formattedResponse.contains('Data quality issues detected'), 'Should contain warning');
    }
    
    @IsTest
    static void testFormatResponseTruncation() {
        // Create test response that would exceed length limit
        ANAgentKPIAnalysisService.KPIAnalysisResponse response = new ANAgentKPIAnalysisService.KPIAnalysisResponse();
        response.success = true;
        response.analysisType = 'MEETINGS';
        response.timeFrame = 'CURRENT';
        response.ouName = 'AMER ACC';
        response.totalAEs = 1000; // Large number to trigger truncation
        response.totalMeetings = 10000;
        response.warnings = new List<String>();
        
        // Create test request
        ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
        request.analysisType = 'MEETINGS';
        request.timeFrame = 'CURRENT';
        request.ouName = 'AMER ACC';
        
        Test.startTest();
        String formattedResponse = ANAgentKPIResponseFormatter.formatResponse(response, request, null);
        Test.stopTest();
        
        // Verify response formatting
        System.assertNotEquals(null, formattedResponse, 'Formatted response should not be null');
        System.assert(formattedResponse.length() <= 1500, 'Response should be truncated if too long');
    }
    
    @IsTest
    static void testFormatResponseEmptyData() {
        // Create test response with no data
        ANAgentKPIAnalysisService.KPIAnalysisResponse response = new ANAgentKPIAnalysisService.KPIAnalysisResponse();
        response.success = true;
        response.analysisType = 'CALLS';
        response.timeFrame = 'CURRENT';
        response.ouName = 'EMEA ACC';
        response.totalAEs = 0;
        response.totalCallConnects = 0;
        response.warnings = new List<String>();
        
        // Create test request
        ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
        request.analysisType = 'CALLS';
        request.timeFrame = 'CURRENT';
        request.ouName = 'EMEA ACC';
        
        Test.startTest();
        String formattedResponse = ANAgentKPIResponseFormatter.formatResponse(response, request, null);
        Test.stopTest();
        
        // Verify response formatting
        System.assertNotEquals(null, formattedResponse, 'Formatted response should not be null');
        System.assert(formattedResponse.contains('KPI Health Summary'), 'Should contain health summary');
        System.assert(formattedResponse.contains('0'), 'Should contain zero values');
    }
}
