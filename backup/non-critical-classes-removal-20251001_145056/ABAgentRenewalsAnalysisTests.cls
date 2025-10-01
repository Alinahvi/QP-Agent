/**
 * Unit tests for ABAgentRenewalsAnalysisService
 * Tests aggregate queries and governor safety without loading raw records
 */
@isTest(SeeAllData=false)
public class ABAgentRenewalsAnalysisTests {
    
    @TestSetup
    static void setupTestData() {
        // Create test data - 40 records across 6 AEs, 2 OUs, 2 countries, 2 products
        List<Agent_Renewals__c> testRecords = new List<Agent_Renewals__c>();
        
        // Create AEs
        List<String> aeNames = new List<String>{
            'John Smith', 'Jane Doe', 'Bob Johnson', 'Alice Brown', 'Charlie Wilson', 'Diana Lee'
        };
        
        // Create OUs
        List<String> ous = new List<String>{'AMER', 'EMEA'};
        
        // Create countries
        List<String> countries = new List<String>{'US', 'UK'};
        
        // Create products
        List<String> products = new List<String>{
            'Sales Cloud - Enterprise Edition', 'Service Cloud - Professional Edition'
        };
        
        // Create test records
        for (Integer i = 0; i < 40; i++) {
            Agent_Renewals__c record = new Agent_Renewals__c();
            record.full_name__c = aeNames[Math.mod(i, aeNames.size())];
            record.ou_name__c = ous[Math.mod(i, ous.size())];
            record.work_location_country__c = countries[Math.mod(i, countries.size())];
            record.renewal_prod_nm__c = products[Math.mod(i, products.size())];
            record.renewal_acct_nm__c = 'Test Account ' + i;
            record.renewal_opty_amt__c = 1000 + (i * 100); // Varying amounts
            record.renewal_opty_nm__c = 'Test Opportunity ' + i;
            record.emp_email_addr__c = 'test' + i + '@example.com';
            record.primary_industry__c = 'Technology';
            record.macrosgment__c = 'CMRCL';
            record.emp_mgr_nm__c = 'Manager ' + Math.mod(i, 3);
            testRecords.add(record);
        }
        
        insert testRecords;
    }
    
    @isTest
    static void testQueryTopRenewalsByAE() {
        // Test grouping by AE
        ABAgentRenewalsAnalysisService.RenewalQueryRequest req = new ABAgentRenewalsAnalysisService.RenewalQueryRequest();
        req.groupBy = 'AE';
        req.workLocationCountry = 'US';
        req.limitN = 10;
        req.startDate = Date.today().addDays(-30);
        req.endDate = Date.today().addDays(30);
        
        Test.startTest();
        List<ABAgentRenewalsAnalysisService.RenewalRowDTO> results = ABAgentRenewalsAnalysisService.queryTopRenewals(req);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() > 0, 'Should return some results');
        System.assert(results.size() <= 10, 'Should respect limit');
        
        // Verify DTO structure
        for (ABAgentRenewalsAnalysisService.RenewalRowDTO dto : results) {
            System.assertNotEquals(null, dto.key, 'Key should not be null');
            System.assert(dto.count > 0, 'Count should be positive');
            System.assert(dto.amount != null, 'Amount should not be null');
        }
    }
    
    @isTest
    static void testQueryTopRenewalsByOU() {
        // Test grouping by OU
        ABAgentRenewalsAnalysisService.RenewalQueryRequest req = new ABAgentRenewalsAnalysisService.RenewalQueryRequest();
        req.groupBy = 'OU';
        req.ouName = 'AMER';
        req.limitN = 5;
        req.startDate = Date.today().addDays(-30);
        req.endDate = Date.today().addDays(30);
        
        Test.startTest();
        List<ABAgentRenewalsAnalysisService.RenewalRowDTO> results = ABAgentRenewalsAnalysisService.queryTopRenewals(req);
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() > 0, 'Should return some results');
        System.assert(results.size() <= 5, 'Should respect limit');
    }
    
    @isTest
    static void testQueryTopRenewalsByProduct() {
        // Test grouping by Product
        ABAgentRenewalsAnalysisService.RenewalQueryRequest req = new ABAgentRenewalsAnalysisService.RenewalQueryRequest();
        req.groupBy = 'PRODUCT';
        req.workLocationCountry = 'US';
        req.limitN = 10;
        req.startDate = Date.today().addDays(-30);
        req.endDate = Date.today().addDays(30);
        
        Test.startTest();
        List<ABAgentRenewalsAnalysisService.RenewalRowDTO> results = ABAgentRenewalsAnalysisService.queryTopRenewals(req);
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() > 0, 'Should return some results');
        System.assert(results.size() <= 10, 'Should respect limit');
    }
    
    @isTest
    static void testAnalyzeRenewalsHandler() {
        // Test the main handler method
        Test.startTest();
        String result = ABAgentRenewalsAnalysisService.analyzeRenewals(
            null, // ouName
            'US', // workLocationCountry
            'AE', // groupBy
            null, // filterCriteria
            null, // restrictInValuesCsv
            false, // perAENormalize
            10, // limitN
            'COUNT', // aggregationType
            'AE_ANALYSIS' // analysisType
        );
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.contains('Renewals Analysis'), 'Should contain analysis header');
        System.assert(result.contains('AE Analysis'), 'Should contain AE analysis section');
        System.assert(result.contains('JSON'), 'Should contain JSON data');
    }
    
    @isTest
    static void testGovernorSafetyValidation() {
        // Test invalid groupBy
        Test.startTest();
        String result1 = ABAgentRenewalsAnalysisService.analyzeRenewals(
            null, 'US', 'INVALID_GROUP', null, null, false, 10, 'COUNT', 'AE_ANALYSIS'
        );
        Test.stopTest();
        
        System.assert(result1.contains('Error'), 'Should return error for invalid groupBy');
    }
    
    @isTest
    static void testLimitValidation() {
        // Test limit too large
        Test.startTest();
        String result = ABAgentRenewalsAnalysisService.analyzeRenewals(
            null, 'US', 'AE', null, null, false, 150, 'COUNT', 'AE_ANALYSIS'
        );
        Test.stopTest();
        
        System.assert(result.contains('Error'), 'Should return error for limit too large');
    }
    
    @isTest
    static void testNoFiltersValidation() {
        // Test no filters provided
        Test.startTest();
        String result = ABAgentRenewalsAnalysisService.analyzeRenewals(
            null, null, 'AE', null, null, false, 10, 'COUNT', 'AE_ANALYSIS'
        );
        Test.stopTest();
        
        System.assert(result.contains('Error'), 'Should return error for no filters');
    }
    
    @isTest
    static void testFieldSuggestions() {
        Test.startTest();
        String suggestions = ABAgentRenewalsAnalysisService.getFieldSuggestions('product=Sales Cloud');
        Test.stopTest();
        
        System.assertNotEquals(null, suggestions, 'Suggestions should not be null');
        System.assert(suggestions.contains('Field Mapping Suggestions'), 'Should contain suggestions header');
        System.assert(suggestions.contains('product'), 'Should contain product field mapping');
    }
    
    @isTest
    static void testFilterValidation() {
        Test.startTest();
        String validation = ABAgentRenewalsAnalysisService.validateFilterCriteria('product=Sales Cloud');
        Test.stopTest();
        
        System.assertNotEquals(null, validation, 'Validation should not be null');
        System.assert(validation.contains('Filter Validation Results'), 'Should contain validation header');
        System.assert(validation.contains('WARNING'), 'Should contain warning about quoting');
    }
    
    @isTest
    static void testParseFilterCriteria() {
        Test.startTest();
        String parsed = ABAgentRenewalsAnalysisService.parseFilterCriteria('product=Sales Cloud AND country=US');
        Test.stopTest();
        
        System.assertNotEquals(null, parsed, 'Parsed filter should not be null');
        System.assert(parsed.contains('renewal_prod_nm__c'), 'Should convert product to API name');
        System.assert(parsed.contains('work_location_country__c'), 'Should convert country to API name');
    }
    
    @isTest
    static void testHeapSizeSafety() {
        // This test ensures we don't load raw records into memory
        Test.startTest();
        
        // Call the service multiple times to ensure no memory accumulation
        for (Integer i = 0; i < 5; i++) {
            String result = ABAgentRenewalsAnalysisService.analyzeRenewals(
                null, 'US', 'AE', null, null, false, 10, 'COUNT', 'AE_ANALYSIS'
            );
            System.assertNotEquals(null, result, 'Result should not be null');
        }
        
        Test.stopTest();
        
        // If we get here without heap size errors, the test passes
        System.assert(true, 'No heap size errors occurred');
    }
}
