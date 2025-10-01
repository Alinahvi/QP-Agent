/**
 * Comprehensive Unit Tests for ABAgentFuturePipeAnalysisServiceEnhanced
 * 
 * This test class validates all intelligence features including:
 * - Renewal Risk Scoring
 * - AE Performance Analysis
 * - Product-Market Fit Analysis
 * - Pipeline Health Scoring
 * 
 * @author AI Assistant
 * @version 1.0
 */
@isTest
public class ABAgentFuturePipeAnalysisServiceEnhanced_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create comprehensive test data for all three objects
        
        // Test Data Constants
        List<String> testAEs = new List<String>{
            'Test AE High Performer', 'Test AE Average Performer', 'Test AE Low Performer',
            'Test AE Top Performer', 'Test AE Needs Improvement'
        };
        
        List<String> testOUs = new List<String>{
            'AMER ICE', 'EMEA ENTR', 'APAC SMB'
        };
        
        List<String> testProducts = new List<String>{
            'Sales Cloud - Enterprise Edition', 'Service Cloud - Professional Edition', 
            'Marketing Cloud - Standard Edition', 'Platform - Unlimited Edition'
        };
        
        List<String> testSegments = new List<String>{
            'Enterprise', 'Mid-Market', 'SMB'
        };
        
        List<String> testIndustries = new List<String>{
            'Technology', 'Financial Services', 'Healthcare', 'Manufacturing'
        };
        
        // Create Renewals Test Data (50 records)
        List<Agent_Renewals__c> renewals = new List<Agent_Renewals__c>();
        
        for (Integer i = 0; i < 50; i++) {
            Agent_Renewals__c renewal = new Agent_Renewals__c();
            renewal.full_name__c = testAEs[Math.mod(i, testAEs.size())];
            renewal.ou_name__c = testOUs[Math.mod(i, testOUs.size())];
            renewal.work_location_country__c = 'United States';
            renewal.primary_industry__c = testIndustries[Math.mod(i, testIndustries.size())];
            renewal.macrosgment__c = testSegments[Math.mod(i, testSegments.size())];
            renewal.emp_mgr_nm__c = 'Test Manager ' + Math.mod(i, 3);
            renewal.emp_id__c = 'TEST_EMP_' + i;
            renewal.emp_email_addr__c = 'testae' + i + '@company.com';
            
            // Product fields
            renewal.PRODUCT_L2__c = 'Cloud Services';
            renewal.PRODUCT_L3__c = 'Sales Cloud';
            renewal.renewal_prod_nm__c = testProducts[Math.mod(i, testProducts.size())];
            
            // Account fields
            renewal.renewal_acct_nm__c = 'Test Account ' + i + ' Inc.';
            renewal.renewal_acct_id__c = 'TEST_ACC_' + i;
            renewal.renewal_rn__c = 'TEST_RN_' + i;
            
            // Amount and dates - varied for testing
            renewal.renewal_opty_amt__c = 10000 + (i * 5000); // $10K to $255K
            
            // Close dates - varied for risk testing
            if (i < 10) {
                renewal.CloseDate__c = Date.today().addDays(15); // High risk - close soon
            } else if (i < 20) {
                renewal.CloseDate__c = Date.today().addDays(45); // Medium risk
            } else if (i < 30) {
                renewal.CloseDate__c = Date.today().addDays(90); // Low risk
            } else {
                renewal.CloseDate__c = Date.today().addDays(180); // Very low risk
            }
            
            // Performance fields - varied for testing
            if (i < 10) {
                renewal.AE_Score__c = 4.5; // High performer
                renewal.Coverage__c = 1.2; // 120% coverage
            } else if (i < 20) {
                renewal.AE_Score__c = 3.5; // Average performer
                renewal.Coverage__c = 1.0; // 100% coverage
            } else if (i < 30) {
                renewal.AE_Score__c = 2.8; // Below average
                renewal.Coverage__c = 0.8; // 80% coverage
            } else {
                renewal.AE_Score__c = 2.0; // Needs improvement
                renewal.Coverage__c = 0.6; // 60% coverage
            }
            
            // Additional fields
            renewal.ramp_status__c = i < 25 ? 'On Track' : 'Slow Ramper';
            renewal.time_since_onboarding__c = 6 + Math.mod(i, 18); // 6-24 months
            renewal.learner_profile_id__c = 'TEST_LP_' + i;
            
            renewals.add(renewal);
        }
        
        insert renewals;
        
        // Create Cross-Sell Test Data (30 records)
        List<Agent_Cross_Sell__c> crossSells = new List<Agent_Cross_Sell__c>();
        
        for (Integer i = 0; i < 30; i++) {
            Agent_Cross_Sell__c crossSell = new Agent_Cross_Sell__c();
            crossSell.full_name__c = testAEs[Math.mod(i + 10, testAEs.size())];
            crossSell.ou_name__c = testOUs[Math.mod(i + 5, testOUs.size())];
            crossSell.work_location_country__c = 'United Kingdom';
            crossSell.primary_industry__c = testIndustries[Math.mod(i + 3, testIndustries.size())];
            crossSell.macrosgment__c = testSegments[Math.mod(i + 2, testSegments.size())];
            crossSell.emp_mgr_nm__c = 'Test Manager ' + Math.mod(i + 1, 3);
            crossSell.emp_id__c = 'TEST_EMP_CS_' + i;
            crossSell.emp_email_addr__c = 'testaecs' + i + '@company.com';
            
            // Product fields
            crossSell.PRODUCT_L2__c = 'Cloud Services';
            crossSell.PRODUCT_L3__c = 'Service Cloud';
            crossSell.cross_sell_next_best_product__c = testProducts[Math.mod(i + 2, testProducts.size())];
            
            // Account fields
            crossSell.cross_sell_acct_nm__c = 'Test Cross-Sell Account ' + i + ' Corp.';
            crossSell.cross_sell_acct_id__c = 'TEST_CS_ACC_' + i;
            crossSell.cross_sell_rn__c = 'TEST_CS_RN_' + i;
            
            // Amount and dates
            crossSell.Amount__c = 5000 + (i * 3000); // $5K to $92K
            crossSell.CloseDate__c = Date.today().addDays(60 + (i * 5)); // Varied close dates
            
            // Performance fields
            crossSell.AE_Score__c = 3.0 + (Math.mod(i, 20) * 0.1); // 3.0 to 5.0
            crossSell.Coverage__c = 0.7 + (Math.mod(i, 30) * 0.02); // 70% to 130%
            
            // Additional fields
            crossSell.ramp_status__c = i < 20 ? 'On Track' : 'Slow Ramper';
            crossSell.time_since_onboarding__c = 3 + Math.mod(i, 21); // 3-24 months
            crossSell.learner_profile_id__c = 'TEST_CS_LP_' + i;
            
            crossSells.add(crossSell);
        }
        
        insert crossSells;
        
        // Create Upsell Test Data (30 records)
        List<Agent_Upsell__c> upsells = new List<Agent_Upsell__c>();
        
        for (Integer i = 0; i < 30; i++) {
            Agent_Upsell__c upsell = new Agent_Upsell__c();
            upsell.full_name__c = testAEs[Math.mod(i + 15, testAEs.size())];
            upsell.ou_name__c = testOUs[Math.mod(i + 10, testOUs.size())];
            upsell.work_location_country__c = 'Germany';
            upsell.primary_industry__c = testIndustries[Math.mod(i + 7, testIndustries.size())];
            upsell.macrosgment__c = testSegments[Math.mod(i + 5, testSegments.size())];
            upsell.emp_mgr_nm__c = 'Test Manager ' + Math.mod(i + 2, 3);
            upsell.emp_id__c = 'TEST_EMP_US_' + i;
            upsell.emp_email_addr__c = 'testaeus' + i + '@company.com';
            
            // Product fields
            upsell.PRODUCT_L2__c = 'Cloud Services';
            upsell.PRODUCT_L3__c = 'Marketing Cloud';
            upsell.upsell_sub_category__c = testProducts[Math.mod(i + 5, testProducts.size())];
            
            // Account fields
            upsell.upsell_acct_nm__c = 'Test Upsell Account ' + i + ' LLC.';
            upsell.upsell_acct_id__c = 'TEST_US_ACC_' + i;
            upsell.upsell_rn__c = 'TEST_US_RN_' + i;
            
            // Amount and dates
            upsell.Amount__c = 3000 + (i * 2000); // $3K to $61K
            upsell.CloseDate__c = Date.today().addDays(90 + (i * 3)); // Varied close dates
            
            // Performance fields
            upsell.AE_Score__c = 2.5 + (Math.mod(i, 25) * 0.1); // 2.5 to 5.0
            upsell.Coverage__c = 0.6 + (Math.mod(i, 40) * 0.015); // 60% to 120%
            
            // Additional fields
            upsell.ramp_status__c = i < 18 ? 'On Track' : 'Slow Ramper';
            upsell.time_since_onboarding__c = 2 + Math.mod(i, 22); // 2-24 months
            upsell.learner_profile_id__c = 'TEST_US_LP_' + i;
            
            upsells.add(upsell);
        }
        
        insert upsells;
    }
    
    /**
     * Test Renewal Risk Calculation
     */
    @isTest
    static void testRenewalRiskCalculation() {
        // Test with high-risk scenario (close date soon, low AE score)
        ABAgentFuturePipeAnalysisServiceEnhanced.EnhancedResponse response = new ABAgentFuturePipeAnalysisServiceEnhanced.EnhancedResponse();
        
        Test.startTest();
        ABAgentFuturePipeAnalysisServiceEnhanced.addRenewalRiskAnalysis(response, 'AMER ICE', 'United States');
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, response.renewalRisk, 'Renewal risk analysis should return results');
        System.assert(!response.renewalRisk.isEmpty(), 'Renewal risk list should not be empty');
        
        // Verify risk calculation logic
        for (Map<String, Object> risk : response.renewalRisk) {
            System.assertNotEquals(null, risk.get('renewalRisk'), 'Renewal risk should be calculated');
            System.assertNotEquals(null, risk.get('renewalProbability'), 'Renewal probability should be calculated');
            System.assertNotEquals(null, risk.get('riskTier'), 'Risk tier should be determined');
            
            Decimal renewalRisk = (Decimal) risk.get('renewalRisk');
            Decimal renewalProbability = (Decimal) risk.get('renewalProbability');
            
            // Verify risk is between 0 and 1
            System.assert(renewalRisk >= 0.0 && renewalRisk <= 1.0, 'Renewal risk should be between 0 and 1');
            System.assert(renewalProbability >= 0.0 && renewalProbability <= 1.0, 'Renewal probability should be between 0 and 1');
            
            // Verify risk + probability = 1
            System.assertEquals(1.0, renewalRisk + renewalProbability, 0.01, 'Risk + probability should equal 1');
            
            // Verify risk tier is valid
            String riskTier = (String) risk.get('riskTier');
            System.assert(riskTier == 'LOW' || riskTier == 'MEDIUM' || riskTier == 'HIGH', 'Risk tier should be LOW, MEDIUM, or HIGH');
        }
    }
    
    /**
     * Test AE Performance Analysis
     */
    @isTest
    static void testAEPerformanceAnalysis() {
        ABAgentFuturePipeAnalysisServiceEnhanced.EnhancedResponse response = new ABAgentFuturePipeAnalysisServiceEnhanced.EnhancedResponse();
        
        Test.startTest();
        ABAgentFuturePipeAnalysisServiceEnhanced.addAEPerformanceAnalysis(response, 'AMER ICE', 'United States', 'RENEWALS');
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, response.aePerformance, 'AE performance analysis should return results');
        System.assert(!response.aePerformance.isEmpty(), 'AE performance list should not be empty');
        
        // Verify performance calculation logic
        for (Map<String, Object> perf : response.aePerformance) {
            System.assertNotEquals(null, perf.get('performancePercentile'), 'Performance percentile should be calculated');
            System.assertNotEquals(null, perf.get('performanceTier'), 'Performance tier should be determined');
            System.assertNotEquals(null, perf.get('coachingFlags'), 'Coaching flags should be provided');
            System.assertNotEquals(null, perf.get('recommendations'), 'Recommendations should be provided');
            
            Decimal percentile = (Decimal) perf.get('performancePercentile');
            System.assert(percentile >= 0, 'Performance percentile should be non-negative');
            
            // Verify performance tier is valid
            String performanceTier = (String) perf.get('performanceTier');
            List<String> validTiers = new List<String>{'Top Performer', 'Above Average', 'Average', 'Needs Improvement'};
            System.assert(validTiers.contains(performanceTier), 'Performance tier should be valid: ' + performanceTier);
        }
    }
    
    /**
     * Test Product-Market Fit Analysis
     */
    @isTest
    static void testPMFAnalysis() {
        ABAgentFuturePipeAnalysisServiceEnhanced.EnhancedResponse response = new ABAgentFuturePipeAnalysisServiceEnhanced.EnhancedResponse();
        
        Test.startTest();
        ABAgentFuturePipeAnalysisServiceEnhanced.addPMFAnalysis(response, 'AMER ICE', 'United States', 'RENEWALS');
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, response.pmfFindings, 'PMF analysis should return results');
        System.assert(!response.pmfFindings.isEmpty(), 'PMF findings list should not be empty');
        
        // Verify PMF calculation logic
        for (Map<String, Object> pmf : response.pmfFindings) {
            System.assertNotEquals(null, pmf.get('product'), 'Product should be specified');
            System.assertNotEquals(null, pmf.get('oppCount'), 'Opportunity count should be calculated');
            System.assertNotEquals(null, pmf.get('efficiency'), 'Efficiency should be calculated');
            
            Integer oppCount = (Integer) pmf.get('oppCount');
            System.assert(oppCount > 0, 'Opportunity count should be positive');
            
            Decimal efficiency = (Decimal) pmf.get('efficiency');
            System.assert(efficiency >= 0.0 && efficiency <= 1.0, 'Efficiency should be between 0 and 1');
        }
    }
    
    /**
     * Test Health Score Analysis
     */
    @isTest
    static void testHealthScoreAnalysis() {
        ABAgentFuturePipeAnalysisServiceEnhanced.EnhancedResponse response = new ABAgentFuturePipeAnalysisServiceEnhanced.EnhancedResponse();
        
        // First populate other intelligence features
        ABAgentFuturePipeAnalysisServiceEnhanced.addRenewalRiskAnalysis(response, 'AMER ICE', 'United States');
        ABAgentFuturePipeAnalysisServiceEnhanced.addAEPerformanceAnalysis(response, 'AMER ICE', 'United States', 'RENEWALS');
        ABAgentFuturePipeAnalysisServiceEnhanced.addPMFAnalysis(response, 'AMER ICE', 'United States', 'RENEWALS');
        
        Test.startTest();
        ABAgentFuturePipeAnalysisServiceEnhanced.addHealthScoreAnalysis(response, 'AMER ICE', 'United States', 'RENEWALS');
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, response.healthScore, 'Health score analysis should return results');
        System.assert(!response.healthScore.isEmpty(), 'Health score should be calculated');
        
        // Verify health score calculation
        Decimal healthScore = (Decimal) response.healthScore.get('healthScore');
        System.assertNotEquals(null, healthScore, 'Health score should be calculated');
        System.assert(healthScore >= 0.0 && healthScore <= 10.0, 'Health score should be between 0 and 10');
        
        // Verify health tier is valid
        String healthTier = (String) response.healthScore.get('healthTier');
        List<String> validTiers = new List<String>{'Excellent', 'Healthy', 'Moderate', 'At Risk'};
        System.assert(validTiers.contains(healthTier), 'Health tier should be valid: ' + healthTier);
        
        // Verify contributing factors and next best actions
        List<String> contributingFactors = (List<String>) response.healthScore.get('contributingFactors');
        List<String> nextBestActions = (List<String>) response.healthScore.get('nextBestActions');
        
        System.assertNotEquals(null, contributingFactors, 'Contributing factors should be provided');
        System.assertNotEquals(null, nextBestActions, 'Next best actions should be provided');
    }
    
    /**
     * Test Enhanced Pipeline Analysis End-to-End
     */
    @isTest
    static void testEnhancedPipelineAnalysisEndToEnd() {
        Test.startTest();
        String result = ABAgentFuturePipeAnalysisServiceEnhanced.analyzePipelineEnhanced(
            'RENEWALS',           // analysisType
            'AMER ICE',           // ouName
            'United States',      // workLocationCountry
            'PRODUCT',            // groupBy
            null,                 // filterCriteria
            null,                 // restrictInValuesCsv
            false,                // perAENormalize
            10,                   // limitN
            'SUM',                // aggregationType
            'RENEWALS_ANALYSIS',  // analysisTypeDetail
            null,                 // startDate
            null,                 // endDate
            true,                 // includeRenewalRisk
            true,                 // includeAEPerf
            true,                 // includePMF
            true                  // includeHealthScore
        );
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'Enhanced analysis should return results');
        System.assert(String.isNotBlank(result), 'Enhanced analysis should return non-blank results');
        
        // Verify intelligence features are included in the result
        System.assert(result.contains('Renewal Risk Analysis'), 'Result should contain renewal risk analysis');
        System.assert(result.contains('AE Performance Analysis'), 'Result should contain AE performance analysis');
        System.assert(result.contains('Product-Market Fit Analysis'), 'Result should contain PMF analysis');
        System.assert(result.contains('Pipeline Health Score'), 'Result should contain health score');
        System.assert(result.contains('Explainability'), 'Result should contain explainability');
    }
    
    /**
     * Test Cross-Sell Analysis
     */
    @isTest
    static void testCrossSellAnalysis() {
        Test.startTest();
        String result = ABAgentFuturePipeAnalysisServiceEnhanced.analyzePipelineEnhanced(
            'CROSS_SELL',         // analysisType
            'EMEA ENTR',          // ouName
            'United Kingdom',     // workLocationCountry
            'AE',                 // groupBy
            null,                 // filterCriteria
            null,                 // restrictInValuesCsv
            false,                // perAENormalize
            15,                   // limitN
            'COUNT',              // aggregationType
            'CROSS_SELL_ANALYSIS', // analysisTypeDetail
            null,                 // startDate
            null,                 // endDate
            false,                // includeRenewalRisk (not applicable for cross-sell)
            true,                 // includeAEPerf
            true,                 // includePMF
            true                  // includeHealthScore
        );
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'Cross-sell analysis should return results');
        System.assert(String.isNotBlank(result), 'Cross-sell analysis should return non-blank results');
        
        // Verify cross-sell specific content
        System.assert(result.contains('CROSS_SELL'), 'Result should contain cross-sell analysis type');
    }
    
    /**
     * Test Upsell Analysis
     */
    @isTest
    static void testUpsellAnalysis() {
        Test.startTest();
        String result = ABAgentFuturePipeAnalysisServiceEnhanced.analyzePipelineEnhanced(
            'UPSELL',             // analysisType
            'APAC SMB',           // ouName
            'Germany',            // workLocationCountry
            'PRODUCT',            // groupBy
            null,                 // filterCriteria
            null,                 // restrictInValuesCsv
            false,                // perAENormalize
            12,                   // limitN
            'COUNT',              // aggregationType
            'UPSELL_ANALYSIS',    // analysisTypeDetail
            null,                 // startDate
            null,                 // endDate
            false,                // includeRenewalRisk (not applicable for upsell)
            true,                 // includeAEPerf
            true,                 // includePMF
            true                  // includeHealthScore
        );
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'Upsell analysis should return results');
        System.assert(String.isNotBlank(result), 'Upsell analysis should return non-blank results');
        
        // Verify upsell specific content
        System.assert(result.contains('UPSELL'), 'Result should contain upsell analysis type');
    }
    
    /**
     * Test Error Handling and Graceful Degradation
     */
    @isTest
    static void testErrorHandlingAndGracefulDegradation() {
        // Test with invalid parameters
        Test.startTest();
        String result = ABAgentFuturePipeAnalysisServiceEnhanced.analyzePipelineEnhanced(
            'INVALID_TYPE',       // analysisType
            null,                 // ouName
            null,                 // workLocationCountry
            'PRODUCT',            // groupBy
            null,                 // filterCriteria
            null,                 // restrictInValuesCsv
            false,                // perAENormalize
            10,                   // limitN
            'SUM',                // aggregationType
            'TEST_ANALYSIS',      // analysisTypeDetail
            null,                 // startDate
            null,                 // endDate
            true,                 // includeRenewalRisk
            true,                 // includeAEPerf
            true,                 // includePMF
            true                  // includeHealthScore
        );
        Test.stopTest();
        
        // Assertions - should gracefully degrade and return basic analysis
        System.assertNotEquals(null, result, 'Should return results even with invalid parameters');
        System.assert(String.isNotBlank(result), 'Should return non-blank results even with errors');
    }
    
    /**
     * Test Bulk Data Processing
     */
    @isTest
    static void testBulkDataProcessing() {
        // Create additional bulk test data
        List<Agent_Renewals__c> bulkRenewals = new List<Agent_Renewals__c>();
        
        for (Integer i = 0; i < 200; i++) {
            Agent_Renewals__c renewal = new Agent_Renewals__c();
            renewal.full_name__c = 'Bulk Test AE ' + Math.mod(i, 20);
            renewal.ou_name__c = 'AMER ICE';
            renewal.work_location_country__c = 'United States';
            renewal.primary_industry__c = 'Technology';
            renewal.macrosgment__c = 'Enterprise';
            renewal.emp_mgr_nm__c = 'Bulk Test Manager';
            renewal.emp_id__c = 'BULK_EMP_' + i;
            renewal.emp_email_addr__c = 'bulkae' + i + '@company.com';
            renewal.PRODUCT_L2__c = 'Cloud Services';
            renewal.PRODUCT_L3__c = 'Sales Cloud';
            renewal.renewal_prod_nm__c = 'Sales Cloud - Enterprise Edition';
            renewal.renewal_acct_nm__c = 'Bulk Test Account ' + i + ' Inc.';
            renewal.renewal_acct_id__c = 'BULK_ACC_' + i;
            renewal.renewal_rn__c = 'BULK_RN_' + i;
            renewal.renewal_opty_amt__c = 50000 + (Math.mod(i, 100) * 1000);
            renewal.CloseDate__c = Date.today().addDays(30 + Math.mod(i, 365));
            renewal.AE_Score__c = 3.0 + (Math.mod(i, 20) * 0.1);
            renewal.Coverage__c = 0.8 + (Math.mod(i, 40) * 0.01);
            renewal.ramp_status__c = 'On Track';
            renewal.time_since_onboarding__c = 6 + Math.mod(i, 18);
            renewal.learner_profile_id__c = 'BULK_LP_' + i;
            
            bulkRenewals.add(renewal);
        }
        
        insert bulkRenewals;
        
        Test.startTest();
        String result = ABAgentFuturePipeAnalysisServiceEnhanced.analyzePipelineEnhanced(
            'RENEWALS',           // analysisType
            'AMER ICE',           // ouName
            'United States',      // workLocationCountry
            'AE',                 // groupBy
            null,                 // filterCriteria
            null,                 // restrictInValuesCsv
            false,                // perAENormalize
            25,                   // limitN
            'SUM',                // aggregationType
            'BULK_TEST_ANALYSIS', // analysisTypeDetail
            null,                 // startDate
            null,                 // endDate
            true,                 // includeRenewalRisk
            true,                 // includeAEPerf
            true,                 // includePMF
            true                  // includeHealthScore
        );
        Test.stopTest();
        
        // Assertions - should handle bulk data without governor limit issues
        System.assertNotEquals(null, result, 'Should handle bulk data processing');
        System.assert(String.isNotBlank(result), 'Should return results for bulk data');
    }
    
    /**
     * Test Feature Toggle Functionality
     */
    @isTest
    static void testFeatureToggleFunctionality() {
        // Test with all intelligence features disabled
        Test.startTest();
        String result = ABAgentFuturePipeAnalysisServiceEnhanced.analyzePipelineEnhanced(
            'RENEWALS',           // analysisType
            'AMER ICE',           // ouName
            'United States',      // workLocationCountry
            'PRODUCT',            // groupBy
            null,                 // filterCriteria
            null,                 // restrictInValuesCsv
            false,                // perAENormalize
            10,                   // limitN
            'SUM',                // aggregationType
            'FEATURE_TOGGLE_TEST', // analysisTypeDetail
            null,                 // startDate
            null,                 // endDate
            false,                // includeRenewalRisk (disabled)
            false,                // includeAEPerf (disabled)
            false,                // includePMF (disabled)
            false                 // includeHealthScore (disabled)
        );
        Test.stopTest();
        
        // Assertions - should return basic analysis without intelligence features
        System.assertNotEquals(null, result, 'Should return basic analysis when intelligence features are disabled');
        System.assert(String.isNotBlank(result), 'Should return non-blank results even without intelligence features');
    }
}
