/**
 * Test class for ANAgentKPIOutlierService
 * Tests outlier detection using Z-score and IQR methods
 * 
 * @version 1.0
 * @author AI Assistant
 */
@IsTest
public class ANAgentKPIOutlierServiceTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test KPI config
        KPI_Config__mdt testConfig = new KPI_Config__mdt();
        testConfig.KPI_Enable_Outliers__c = true;
        testConfig.KPI_MaxRows__c = 1000;
        testConfig.KPI_ZScore_Threshold__c = 2.5;
        testConfig.KPI_IQR_Multiplier__c = 1.5;
        
        // Create test AGENT_OU_PIPELINE_V3__c records
        List<AGENT_OU_PIPELINE_V3__c> testRecords = new List<AGENT_OU_PIPELINE_V3__c>();
        
        // Normal values (should not be outliers)
        for (Integer i = 0; i < 10; i++) {
            testRecords.add(createTestRecord('AMER ACC', 'Normal AE ' + i, 'normal' + i + '@test.com', 'LP' + i, 
                                           10 + i, 5 + i, 100000 + (i * 10000), 50000 + (i * 5000), 2.0 + (i * 0.1), 3.0 + (i * 0.1)));
        }
        
        // High outliers (should be detected)
        testRecords.add(createTestRecord('AMER ACC', 'High Outlier 1', 'high1@test.com', 'LP_HIGH1', 
                                       50, 25, 500000, 250000, 5.0, 4.5));
        testRecords.add(createTestRecord('AMER ACC', 'High Outlier 2', 'high2@test.com', 'LP_HIGH2', 
                                       60, 30, 600000, 300000, 6.0, 4.8));
        
        // Low outliers (should be detected)
        testRecords.add(createTestRecord('AMER ACC', 'Low Outlier 1', 'low1@test.com', 'LP_LOW1', 
                                       1, 0, 10000, 5000, 0.5, 1.0));
        testRecords.add(createTestRecord('AMER ACC', 'Low Outlier 2', 'low2@test.com', 'LP_LOW2', 
                                       2, 1, 15000, 7500, 0.8, 1.2));
        
        insert testRecords;
    }
    
    @IsTest
    static void testZScoreOutlierDetection() {
        // Test data: 10 normal values (10-19), 2 high outliers (50, 60), 2 low outliers (1, 2)
        List<Decimal> testData = new List<Decimal>{10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 50, 60, 1, 2};
        
        Test.startTest();
        ANAgentKPIOutlierService.OutlierResult result = ANAgentKPIOutlierService.detectZScoreOutliers(testData, 2.0);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('Z-Score', result.method, 'Method should be Z-Score');
        System.assertNotEquals(null, result.statistics, 'Statistics should not be null');
        System.assert(result.statistics.containsKey('mean'), 'Should contain mean');
        System.assert(result.statistics.containsKey('stdDev'), 'Should contain stdDev');
        System.assert(result.statistics.containsKey('median'), 'Should contain median');
        
        // Should detect high outliers (50, 60)
        System.assert(result.highOutliers.size() >= 1, 'Should detect high outliers');
        
        // Should detect low outliers (1, 2)
        System.assert(result.lowOutliers.size() >= 1, 'Should detect low outliers');
    }
    
    @IsTest
    static void testIQROutlierDetection() {
        // Test data: 10 normal values (10-19), 2 high outliers (50, 60), 2 low outliers (1, 2)
        List<Decimal> testData = new List<Decimal>{10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 50, 60, 1, 2};
        
        Test.startTest();
        ANAgentKPIOutlierService.OutlierResult result = ANAgentKPIOutlierService.detectIQR(testData, 1.5);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('IQR', result.method, 'Method should be IQR');
        System.assertNotEquals(null, result.statistics, 'Statistics should not be null');
        System.assert(result.statistics.containsKey('q1'), 'Should contain q1');
        System.assert(result.statistics.containsKey('q3'), 'Should contain q3');
        System.assert(result.statistics.containsKey('median'), 'Should contain median');
    }
    
    @IsTest
    static void testKPIOutlierDetection() {
        // Get test records
        List<AGENT_OU_PIPELINE_V3__c> records = [SELECT Id, FULL_NAME__c, EMP_EMAIL_ADDR__c, LEARNER_PROFILE_ID__c,
                                                OU_NAME__c, WORK_LOCATION_COUNTRY__c, CQ_CUSTOMER_MEETING__c
                                                FROM AGENT_OU_PIPELINE_V3__c 
                                                WHERE OU_NAME__c = 'AMER ACC' LIMIT 20];
        
        Test.startTest();
        ANAgentKPIOutlierService.OutlierResult result = ANAgentKPIOutlierService.detectKPIOutliers(records, 'CQ_CUSTOMER_MEETING__c', 'Z-Score');
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('CQ_CUSTOMER_MEETING__c', result.metric, 'Metric should be set');
        System.assertNotEquals(null, result.statistics, 'Statistics should not be null');
        
        // Should have some outliers given our test data
        System.assert(result.highOutliers.size() + result.lowOutliers.size() > 0, 'Should detect some outliers');
    }
    
    @IsTest
    static void testEmptyData() {
        List<Decimal> emptyData = new List<Decimal>();
        
        Test.startTest();
        ANAgentKPIOutlierService.OutlierResult result = ANAgentKPIOutlierService.detectZScoreOutliers(emptyData, 2.0);
        Test.stopTest();
        
        // Verify empty result
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.highOutliers.size(), 'Should have no high outliers');
        System.assertEquals(0, result.lowOutliers.size(), 'Should have no low outliers');
    }
    
    @IsTest
    static void testNullData() {
        Test.startTest();
        ANAgentKPIOutlierService.OutlierResult result = ANAgentKPIOutlierService.detectZScoreOutliers(null, 2.0);
        Test.stopTest();
        
        // Verify null result
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.highOutliers.size(), 'Should have no high outliers');
        System.assertEquals(0, result.lowOutliers.size(), 'Should have no low outliers');
    }
    
    @IsTest
    static void testConfigurationMethods() {
        Test.startTest();
        Boolean isEnabled = ANAgentKPIOutlierService.isOutlierDetectionEnabled();
        Integer maxRows = ANAgentKPIOutlierService.getMaxRows();
        Test.stopTest();
        
        // Verify configuration methods work
        System.assertNotEquals(null, isEnabled, 'isEnabled should not be null');
        System.assertNotEquals(null, maxRows, 'maxRows should not be null');
        System.assert(maxRows > 0, 'maxRows should be positive');
    }
    
    @IsTest
    static void testEdgeCaseSingleValue() {
        List<Decimal> singleValue = new List<Decimal>{42};
        
        Test.startTest();
        ANAgentKPIOutlierService.OutlierResult result = ANAgentKPIOutlierService.detectZScoreOutliers(singleValue, 2.0);
        Test.stopTest();
        
        // Single value should not be considered an outlier
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.highOutliers.size(), 'Single value should not be high outlier');
        System.assertEquals(0, result.lowOutliers.size(), 'Single value should not be low outlier');
    }
    
    @IsTest
    static void testEdgeCaseTwoValues() {
        List<Decimal> twoValues = new List<Decimal>{10, 20};
        
        Test.startTest();
        ANAgentKPIOutlierService.OutlierResult result = ANAgentKPIOutlierService.detectZScoreOutliers(twoValues, 2.0);
        Test.stopTest();
        
        // Two values should not be considered outliers
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.highOutliers.size(), 'Two values should not be high outliers');
        System.assertEquals(0, result.lowOutliers.size(), 'Two values should not be low outliers');
    }
    
    @IsTest
    static void testEdgeCaseAllSameValues() {
        List<Decimal> sameValues = new List<Decimal>{10, 10, 10, 10, 10};
        
        Test.startTest();
        ANAgentKPIOutlierService.OutlierResult result = ANAgentKPIOutlierService.detectZScoreOutliers(sameValues, 2.0);
        Test.stopTest();
        
        // All same values should not be considered outliers
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.highOutliers.size(), 'Same values should not be high outliers');
        System.assertEquals(0, result.lowOutliers.size(), 'Same values should not be low outliers');
    }
    
    // Helper method to create test records
    private static AGENT_OU_PIPELINE_V3__c createTestRecord(String ouName, String fullName, String email, 
                                                           String learnerProfileId, Integer meetings, Integer calls,
                                                           Decimal acv, Decimal pg, Decimal coverage, Decimal aeScore) {
        AGENT_OU_PIPELINE_V3__c record = new AGENT_OU_PIPELINE_V3__c();
        record.OU_NAME__c = ouName;
        record.FULL_NAME__c = fullName;
        record.EMP_EMAIL_ADDR__c = email;
        record.LEARNER_PROFILE_ID__c = learnerProfileId;
        record.WORK_LOCATION_COUNTRY__c = 'US';
        record.THIS_FISCAL_QUARTER__c = true;
        record.LAST_FISCAL_QUARTER__c = false;
        record.CQ_CUSTOMER_MEETING__c = meetings;
        record.CQ_CALL_CONNECT__c = calls;
        record.CQ_ACV__c = acv;
        record.CQ_PG__c = pg;
        record.Coverage__c = coverage;
        record.AE_Score__c = aeScore;
        return record;
    }
}
