/**
 * Test script to verify the KPI Analysis fix
 * Testing if the service now returns correct breakdown data
 */

System.debug('=== TESTING KPI ANALYSIS FIX ===');

// Test 1: Meetings Analysis by Country (should now return full data)
System.debug('\n--- TEST 1: Meetings Analysis by Country (Full Data) ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request1 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request1.analysisType = 'MEETINGS';
    request1.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request1.primaryValue = null; // No specific country filter
    request1.timeFrame = 'CURRENT';
    request1.maxResults = 10000; // High limit to get full data
    request1.includeDetails = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses1 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request1 });
    
    if (!responses1.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response1 = responses1[0];
        System.debug('Success: ' + response1.success);
        System.debug('Message: ' + response1.message);
        System.debug('Total Records: ' + response1.totalRecords);
        System.debug('Total Value: ' + response1.totalValue);
        System.debug('Average Value: ' + response1.averageValue);
        System.debug('Breakdown Summary: ' + response1.breakdownSummary);
        
        // Check if we're getting realistic numbers now
        if (response1.totalValue > 100000) {
            System.debug('✅ FIXED: Total meetings value is now realistic: ' + response1.totalValue);
        } else {
            System.debug('❌ STILL BROKEN: Total meetings value is too low: ' + response1.totalValue);
        }
    }
} catch (Exception e) {
    System.debug('Test 1 Error: ' + e.getMessage());
}

// Test 2: Pipeline Analysis by OU (should also return full data)
System.debug('\n--- TEST 2: Pipeline Analysis by OU (Full Data) ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request2 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request2.analysisType = 'PIPELINE';
    request2.primaryDimension = 'OU_NAME';
    request2.primaryValue = null; // No specific OU filter
    request2.timeFrame = 'CURRENT';
    request2.maxResults = 10000; // High limit to get full data
    request2.includeDetails = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses2 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request2 });
    
    if (!responses2.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response2 = responses2[0];
        System.debug('Success: ' + response2.success);
        System.debug('Message: ' + response2.message);
        System.debug('Total Records: ' + response2.totalRecords);
        System.debug('Total Value: ' + response2.totalValue);
        System.debug('Average Value: ' + response2.averageValue);
        System.debug('Breakdown Summary: ' + response2.breakdownSummary);
        
        // Check if we're getting realistic numbers now
        if (response2.totalValue > 10000000) {
            System.debug('✅ FIXED: Total pipeline value is now realistic: $' + response2.totalValue);
        } else {
            System.debug('❌ STILL BROKEN: Total pipeline value is too low: $' + response2.totalValue);
        }
    }
} catch (Exception e) {
    System.debug('Test 2 Error: ' + e.getMessage());
}

// Test 3: Direct Service Call to Verify
System.debug('\n--- TEST 3: Direct Service Call Verification ---');
try {
    ANAgentKPIAnalysisService.KPIAnalysisRequest serviceRequest = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    serviceRequest.analysisType = 'MEETINGS';
    serviceRequest.primaryDimension = 'WORK_LOCATION_COUNTRY';
    serviceRequest.primaryValue = null;
    serviceRequest.timeFrame = 'CURRENT';
    serviceRequest.maxResults = 10000;
    serviceRequest.includeDetails = true;
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse serviceResponse = 
        ANAgentKPIAnalysisService.analyzeKPIs(serviceRequest);
    
    System.debug('Direct Service - Success: ' + serviceResponse.success);
    System.debug('Direct Service - Total Records: ' + serviceResponse.totalRecords);
    System.debug('Direct Service - Total Value: ' + serviceResponse.totalValue);
    
    if (serviceResponse.breakdownByDimension != null) {
        System.debug('\n--- DIRECT SERVICE BREAKDOWN (Top 5 Countries) ---');
        List<String> countries = new List<String>(serviceResponse.breakdownByDimension.keySet());
        countries.sort();
        
        Integer count = 0;
        for (String country : countries) {
            if (count < 5) {
                Decimal value = serviceResponse.breakdownByDimension.get(country);
                System.debug(country + ': ' + value + ' meetings');
                count++;
            }
        }
    }
    
} catch (Exception e) {
    System.debug('Test 3 Error: ' + e.getMessage());
}

System.debug('\n=== KPI ANALYSIS FIX TESTING COMPLETED ==='); 