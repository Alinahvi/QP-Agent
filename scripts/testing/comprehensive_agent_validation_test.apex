/**
 * COMPREHENSIVE AGENT VALIDATION TEST
 * 
 * This script performs end-to-end testing of ABAgentFuturePipeAnalysisHandler
 * and associated service layer to identify sources of misinformation.
 * 
 * Tests across:
 * - Multiple OUs (UKI, AMER ACC, LATAM, EMEA, etc.)
 * - Multiple countries (US, UK, Canada, Brazil, etc.)
 * - Multiple segments (CMRCL, ESMB, ENTR, etc.)
 * - Multiple verticals (FINS, HLS, Technology, etc.)
 * 
 * Goal: Ensure agent doesn't generate misinformation about AE counts, data availability, etc.
 */

System.debug('=== COMPREHENSIVE AGENT VALIDATION TEST ===');
System.debug('Testing ABAgentFuturePipeAnalysisHandler for data accuracy...');

// Test Configuration
Map<String, List<String>> testConfig = new Map<String, List<String>>{
    'OUs' => new List<String>{'UKI', 'AMER ACC', 'LATAM', 'EMEA', 'SMB - AMER SMB', 'North Asia'},
    'Countries' => new List<String>{'US', 'United Kingdom', 'Canada', 'Brazil', 'Germany', 'Japan'},
    'Segments' => new List<String>{'CMRCL', 'ESMB', 'ENTR', 'PUBLIC'},
    'Verticals' => new List<String>{'FINS', 'HLS', 'Technology', 'Manufacturing', 'Retail & CG'}
};

// Test 1: Validate Data Sources and Counts
System.debug('--- Test 1: Data Source Validation ---');
try {
    // Check Agent_Renewals__c
    List<AggregateResult> renewalsCount = [
        SELECT COUNT(Id) totalRecords, COUNT_DISTINCT(emp_id__c) uniqueAEs
        FROM Agent_Renewals__c 
        WHERE IsDeleted = false
    ];
    
    if (!renewalsCount.isEmpty()) {
        Integer totalRecords = (Integer)renewalsCount[0].get('totalRecords');
        Integer uniqueAEs = (Integer)renewalsCount[0].get('uniqueAEs');
        System.debug('Agent_Renewals__c: ' + totalRecords + ' records, ' + uniqueAEs + ' unique AEs');
    }
    
    // Check Agent_Cross_Sell__c
    List<AggregateResult> crossSellCount = [
        SELECT COUNT(Id) totalRecords, COUNT_DISTINCT(emp_id__c) uniqueAEs
        FROM Agent_Cross_Sell__c 
        WHERE IsDeleted = false
    ];
    
    if (!crossSellCount.isEmpty()) {
        Integer totalRecords = (Integer)crossSellCount[0].get('totalRecords');
        Integer uniqueAEs = (Integer)crossSellCount[0].get('uniqueAEs');
        System.debug('Agent_Cross_Sell__c: ' + totalRecords + ' records, ' + uniqueAEs + ' unique AEs');
    }
    
    // Check Agent_Upsell__c
    List<AggregateResult> upsellCount = [
        SELECT COUNT(Id) totalRecords, COUNT_DISTINCT(emp_id__c) uniqueAEs
        FROM Agent_Upsell__c 
        WHERE IsDeleted = false
    ];
    
    if (!upsellCount.isEmpty()) {
        Integer totalRecords = (Integer)upsellCount[0].get('totalRecords');
        Integer uniqueAEs = (Integer)upsellCount[0].get('uniqueAEs');
        System.debug('Agent_Upsell__c: ' + totalRecords + ' records, ' + uniqueAEs + ' unique AEs');
    }
    
} catch (Exception e) {
    System.debug('❌ Data Source Validation Failed: ' + e.getMessage());
}

// Test 2: UKI Specific Validation (The Problem Case)
System.debug('--- Test 2: UKI Specific Validation ---');
try {
    // Test RENEWALS analysis for UKI
    ABAgentFuturePipeAnalysisHandler.Request ukiRenewalsRequest = new ABAgentFuturePipeAnalysisHandler.Request();
    ukiRenewalsRequest.analysisType = 'RENEWALS';
    ukiRenewalsRequest.ouName = 'UKI';
    ukiRenewalsRequest.groupBy = 'AE';
    ukiRenewalsRequest.limitN = 5;
    ukiRenewalsRequest.aggregationType = 'COUNT';
    
    List<ABAgentFuturePipeAnalysisHandler.Response> ukiRenewalsResponses = 
        ABAgentFuturePipeAnalysisHandler.analyzePipeline(new List<ABAgentFuturePipeAnalysisHandler.Request>{ukiRenewalsRequest});
    
    if (!ukiRenewalsResponses.isEmpty()) {
        ABAgentFuturePipeAnalysisHandler.Response response = ukiRenewalsResponses[0];
        System.debug('UKI Renewals Response:');
        System.debug('- Message: ' + response.message);
        
        // Check if response contains inflated numbers
        if (response.message != null) {
            if (response.message.contains('2358')) {
                System.debug('🚨 FOUND INFLATED 2358 NUMBER IN UKI RENEWALS RESPONSE');
            }
            if (response.message.contains('Total AEs Analyzed: 2358')) {
                System.debug('🚨 FOUND SPECIFIC INFLATED PHRASE IN UKI RENEWALS RESPONSE');
            }
        }
    }
    
    // Test CROSS_SELL analysis for UKI
    ABAgentFuturePipeAnalysisHandler.Request ukiCrossSellRequest = new ABAgentFuturePipeAnalysisHandler.Request();
    ukiCrossSellRequest.analysisType = 'CROSS_SELL';
    ukiCrossSellRequest.ouName = 'UKI';
    ukiCrossSellRequest.groupBy = 'AE';
    ukiCrossSellRequest.limitN = 5;
    ukiCrossSellRequest.aggregationType = 'COUNT';
    
    List<ABAgentFuturePipeAnalysisHandler.Response> ukiCrossSellResponses = 
        ABAgentFuturePipeAnalysisHandler.analyzePipeline(new List<ABAgentFuturePipeAnalysisHandler.Request>{ukiCrossSellRequest});
    
    if (!ukiCrossSellResponses.isEmpty()) {
        ABAgentFuturePipeAnalysisHandler.Response response = ukiCrossSellResponses[0];
        System.debug('UKI Cross-Sell Response:');
        System.debug('- Message: ' + response.message);
    }
    
    // Test UPSELL analysis for UKI
    ABAgentFuturePipeAnalysisHandler.Request ukiUpsellRequest = new ABAgentFuturePipeAnalysisHandler.Request();
    ukiUpsellRequest.analysisType = 'UPSELL';
    ukiUpsellRequest.ouName = 'UKI';
    ukiUpsellRequest.groupBy = 'AE';
    ukiUpsellRequest.limitN = 5;
    ukiUpsellRequest.aggregationType = 'COUNT';
    
    List<ABAgentFuturePipeAnalysisHandler.Response> ukiUpsellResponses = 
        ABAgentFuturePipeAnalysisHandler.analyzePipeline(new List<ABAgentFuturePipeAnalysisHandler.Request>{ukiUpsellRequest});
    
    if (!ukiUpsellResponses.isEmpty()) {
        ABAgentFuturePipeAnalysisHandler.Response response = ukiUpsellResponses[0];
        System.debug('UKI Upsell Response:');
        System.debug('- Message: ' + response.message);
    }
    
} catch (Exception e) {
    System.debug('❌ UKI Specific Validation Failed: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 3: Cross-OU Validation
System.debug('--- Test 3: Cross-OU Validation ---');
try {
    for (String ou : testConfig.get('OUs')) {
        System.debug('Testing OU: ' + ou);
        
        // Test RENEWALS for each OU
        ABAgentFuturePipeAnalysisHandler.Request request = new ABAgentFuturePipeAnalysisHandler.Request();
        request.analysisType = 'RENEWALS';
        request.ouName = ou;
        request.groupBy = 'AE';
        request.limitN = 3;
        request.aggregationType = 'COUNT';
        
        List<ABAgentFuturePipeAnalysisHandler.Response> responses = 
            ABAgentFuturePipeAnalysisHandler.analyzePipeline(new List<ABAgentFuturePipeAnalysisHandler.Request>{request});
        
        if (!responses.isEmpty()) {
            ABAgentFuturePipeAnalysisHandler.Response response = responses[0];
            System.debug('  ' + ou + ' Renewals: ' + (response.message != null ? response.message.length() + ' chars' : 'null'));
            
            // Check for suspiciously high numbers
            if (response.message != null && response.message.contains('Total AEs Analyzed:')) {
                System.debug('  🚨 FOUND "Total AEs Analyzed" PHRASE IN ' + ou);
            }
        }
    }
} catch (Exception e) {
    System.debug('❌ Cross-OU Validation Failed: ' + e.getMessage());
}

// Test 4: Country-Based Validation
System.debug('--- Test 4: Country-Based Validation ---');
try {
    for (String country : testConfig.get('Countries')) {
        System.debug('Testing Country: ' + country);
        
        // Test RENEWALS for each country
        ABAgentFuturePipeAnalysisHandler.Request request = new ABAgentFuturePipeAnalysisHandler.Request();
        request.analysisType = 'RENEWALS';
        request.workLocationCountry = country;
        request.groupBy = 'AE';
        request.limitN = 3;
        request.aggregationType = 'COUNT';
        
        List<ABAgentFuturePipeAnalysisHandler.Response> responses = 
            ABAgentFuturePipeAnalysisHandler.analyzePipeline(new List<ABAgentFuturePipeAnalysisHandler.Request>{request});
        
        if (!responses.isEmpty()) {
            ABAgentFuturePipeAnalysisHandler.Response response = responses[0];
            System.debug('  ' + country + ' Renewals: ' + (response.message != null ? response.message.length() + ' chars' : 'null'));
        }
    }
} catch (Exception e) {
    System.debug('❌ Country-Based Validation Failed: ' + e.getMessage());
}

// Test 5: Filter Criteria Validation
System.debug('--- Test 5: Filter Criteria Validation ---');
try {
    // Test with Agentforce filter (the original problem case)
    ABAgentFuturePipeAnalysisHandler.Request agentforceRequest = new ABAgentFuturePipeAnalysisHandler.Request();
    agentforceRequest.analysisType = 'RENEWALS';
    agentforceRequest.ouName = 'UKI';
    agentforceRequest.groupBy = 'AE';
    agentforceRequest.filterCriteria = 'renewal_prod_nm != \'Agentforce\'';
    agentforceRequest.limitN = 5;
    agentforceRequest.aggregationType = 'COUNT';
    
    List<ABAgentFuturePipeAnalysisHandler.Response> agentforceResponses = 
        ABAgentFuturePipeAnalysisHandler.analyzePipeline(new List<ABAgentFuturePipeAnalysisHandler.Request>{agentforceRequest});
    
    if (!agentforceResponses.isEmpty()) {
        ABAgentFuturePipeAnalysisHandler.Response response = agentforceResponses[0];
        System.debug('UKI without Agentforce Response:');
        System.debug('- Message: ' + response.message);
        
        // Look for the specific problematic phrase
        if (response.message != null && response.message.contains('Total AEs Analyzed: 2358')) {
            System.debug('🚨 FOUND THE EXACT PROBLEMATIC PHRASE: "Total AEs Analyzed: 2358"');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Filter Criteria Validation Failed: ' + e.getMessage());
}

// Test 6: Service Layer Direct Testing
System.debug('--- Test 6: Service Layer Direct Testing ---');
try {
    // Test the service layer directly
    String serviceResult = ABAgentFuturePipeAnalysisService.analyzePipeline(
        'RENEWALS',           // analysisType
        'UKI',                // ouName
        null,                 // workLocationCountry
        'AE',                 // groupBy
        'renewal_prod_nm != \'Agentforce\'', // filterCriteria
        null,                 // restrictInValuesCsv
        false,                // perAENormalize
        5,                    // limitN
        'COUNT',              // aggregationType
        'RENEWALS_ANALYSIS',  // analysisTypeDetail
        null,                 // startDate
        null                  // endDate
    );
    
    System.debug('Direct Service Result:');
    System.debug('- Length: ' + serviceResult.length() + ' characters');
    System.debug('- Contains "2358": ' + serviceResult.contains('2358'));
    System.debug('- Contains "Total AEs Analyzed": ' + serviceResult.contains('Total AEs Analyzed'));
    
    if (serviceResult.contains('Total AEs Analyzed: 2358')) {
        System.debug('🚨 FOUND INFLATED NUMBER IN DIRECT SERVICE CALL');
    }
    
} catch (Exception e) {
    System.debug('❌ Service Layer Direct Testing Failed: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 7: Data Quality Check
System.debug('--- Test 7: Data Quality Check ---');
try {
    // Check actual UKI data in each object
    List<AggregateResult> ukiRenewalsData = [
        SELECT COUNT(Id) recordCount, COUNT_DISTINCT(emp_id__c) uniqueAEs
        FROM Agent_Renewals__c 
        WHERE ou_name__c = 'UKI'
        AND IsDeleted = false
    ];
    
    if (!ukiRenewalsData.isEmpty()) {
        Integer records = (Integer)ukiRenewalsData[0].get('recordCount');
        Integer uniqueAEs = (Integer)ukiRenewalsData[0].get('uniqueAEs');
        System.debug('UKI Renewals Data: ' + records + ' records, ' + uniqueAEs + ' unique AEs');
    }
    
    List<AggregateResult> ukiCrossSellData = [
        SELECT COUNT(Id) recordCount, COUNT_DISTINCT(emp_id__c) uniqueAEs
        FROM Agent_Cross_Sell__c 
        WHERE ou_name__c = 'UKI'
        AND IsDeleted = false
    ];
    
    if (!ukiCrossSellData.isEmpty()) {
        Integer records = (Integer)ukiCrossSellData[0].get('recordCount');
        Integer uniqueAEs = (Integer)ukiCrossSellData[0].get('uniqueAEs');
        System.debug('UKI Cross-Sell Data: ' + records + ' records, ' + uniqueAEs + ' unique AEs');
    }
    
    List<AggregateResult> ukiUpsellData = [
        SELECT COUNT(Id) recordCount, COUNT_DISTINCT(emp_id__c) uniqueAEs
        FROM Agent_Upsell__c 
        WHERE ou_name__c = 'UKI'
        AND IsDeleted = false
    ];
    
    if (!ukiUpsellData.isEmpty()) {
        Integer records = (Integer)ukiUpsellData[0].get('recordCount');
        Integer uniqueAEs = (Integer)ukiUpsellData[0].get('uniqueAEs');
        System.debug('UKI Upsell Data: ' + records + ' records, ' + uniqueAEs + ' unique AEs');
    }
    
} catch (Exception e) {
    System.debug('❌ Data Quality Check Failed: ' + e.getMessage());
}

// Test 8: Edge Case Testing
System.debug('--- Test 8: Edge Case Testing ---');
try {
    // Test with non-existent OU
    ABAgentFuturePipeAnalysisHandler.Request nonExistentRequest = new ABAgentFuturePipeAnalysisHandler.Request();
    nonExistentRequest.analysisType = 'RENEWALS';
    nonExistentRequest.ouName = 'NON_EXISTENT_OU';
    nonExistentRequest.groupBy = 'AE';
    nonExistentRequest.limitN = 5;
    nonExistentRequest.aggregationType = 'COUNT';
    
    List<ABAgentFuturePipeAnalysisHandler.Response> nonExistentResponses = 
        ABAgentFuturePipeAnalysisHandler.analyzePipeline(new List<ABAgentFuturePipeAnalysisHandler.Request>{nonExistentRequest});
    
    if (!nonExistentResponses.isEmpty()) {
        ABAgentFuturePipeAnalysisHandler.Response response = nonExistentResponses[0];
        System.debug('Non-existent OU Response:');
        System.debug('- Message: ' + response.message);
        
        // Should not contain inflated numbers
        if (response.message != null && response.message.contains('2358')) {
            System.debug('🚨 FOUND INFLATED NUMBER FOR NON-EXISTENT OU');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Edge Case Testing Failed: ' + e.getMessage());
}

System.debug('=== COMPREHENSIVE AGENT VALIDATION TEST COMPLETE ===');
System.debug('');
System.debug('Summary of Tests:');
System.debug('1. ✅ Data Source Validation');
System.debug('2. ✅ UKI Specific Validation');
System.debug('3. ✅ Cross-OU Validation');
System.debug('4. ✅ Country-Based Validation');
System.debug('5. ✅ Filter Criteria Validation');
System.debug('6. ✅ Service Layer Direct Testing');
System.debug('7. ✅ Data Quality Check');
System.debug('8. ✅ Edge Case Testing');
System.debug('');
System.debug('Look for 🚨 markers above to identify sources of misinformation.');
System.debug('The agent should not generate inflated numbers like "Total AEs Analyzed: 2358".');
