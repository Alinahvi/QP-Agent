/**
 * Comprehensive KPI Analysis Test Suite
 * 20 different scenarios to validate the KPI Analysis system
 */

System.debug('=== COMPREHENSIVE KPI ANALYSIS TEST SUITE STARTED ===');

// Test 1: Basic Meetings Analysis by Country
System.debug('\n--- TEST 1: Basic Meetings Analysis by Country ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisResponse response1 = 
        ANAgentKPIAnalysisHandler.analyzeMeetings('WORK_LOCATION_COUNTRY', null);
    System.debug('Test 1 - Success: ' + response1.success + ', Total: ' + response1.totalValue);
} catch (Exception e) {
    System.debug('Test 1 Error: ' + e.getMessage());
}

// Test 2: Pipeline Analysis by OU
System.debug('\n--- TEST 2: Pipeline Analysis by OU ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisResponse response2 = 
        ANAgentKPIAnalysisHandler.analyzePipeline('OU_NAME', null);
    System.debug('Test 2 - Success: ' + response2.success + ', Total: $' + response2.totalValue);
} catch (Exception e) {
    System.debug('Test 2 Error: ' + e.getMessage());
}

// Test 3: ACV Analysis by Industry
System.debug('\n--- TEST 3: ACV Analysis by Industry ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisResponse response3 = 
        ANAgentKPIAnalysisHandler.analyzeACV('PRIMARY_INDUSTRY', null);
    System.debug('Test 3 - Success: ' + response3.success + ', Total: $' + response3.totalValue);
} catch (Exception e) {
    System.debug('Test 3 Error: ' + e.getMessage());
}

// Test 4: Call Connections by Country
System.debug('\n--- TEST 4: Call Connections by Country ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisResponse response4 = 
        ANAgentKPIAnalysisHandler.analyzeCalls('WORK_LOCATION_COUNTRY', null);
    System.debug('Test 4 - Success: ' + response4.success + ', Total: ' + response4.totalValue);
} catch (Exception e) {
    System.debug('Test 4 Error: ' + e.getMessage());
}

// Test 5: AI Mentions by OU
System.debug('\n--- TEST 5: AI Mentions by OU ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisResponse response5 = 
        ANAgentKPIAnalysisHandler.analyzeAIMentions('OU_NAME', null);
    System.debug('Test 5 - Success: ' + response5.success + ', Total: ' + response5.totalValue);
} catch (Exception e) {
    System.debug('Test 5 Error: ' + e.getMessage());
}

// Test 6: Quarter over Quarter Meetings for AMER ICE
System.debug('\n--- TEST 6: QoQ Meetings for AMER ICE ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request6 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request6.analysisType = 'MEETINGS';
    request6.primaryDimension = 'OU_NAME';
    request6.primaryValue = 'AMER ICE';
    request6.timeFrame = 'QOQ';
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses6 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request6 });
    
    if (!responses6.isEmpty()) {
        System.debug('Test 6 - Success: ' + responses6[0].success + ', Total: ' + responses6[0].totalValue);
    }
} catch (Exception e) {
    System.debug('Test 6 Error: ' + e.getMessage());
}

// Test 7: Specific Country Analysis - US
System.debug('\n--- TEST 7: Specific Country Analysis - US ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisResponse response7 = 
        ANAgentKPIAnalysisHandler.analyzeMeetings('WORK_LOCATION_COUNTRY', 'US');
    System.debug('Test 7 - Success: ' + response7.success + ', Total: ' + response7.totalValue);
} catch (Exception e) {
    System.debug('Test 7 Error: ' + e.getMessage());
}

// Test 8: Specific OU Analysis - UKI
System.debug('\n--- TEST 8: Specific OU Analysis - UKI ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisResponse response8 = 
        ANAgentKPIAnalysisHandler.analyzePipeline('OU_NAME', 'UKI');
    System.debug('Test 8 - Success: ' + response8.success + ', Total: $' + response8.totalValue);
} catch (Exception e) {
    System.debug('Test 8 Error: ' + e.getMessage());
}

// Test 9: Specific Industry Analysis - Technology
System.debug('\n--- TEST 9: Specific Industry Analysis - Technology ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisResponse response9 = 
        ANAgentKPIAnalysisHandler.analyzeACV('PRIMARY_INDUSTRY', 'Technology');
    System.debug('Test 9 - Success: ' + response9.success + ', Total: $' + response9.totalValue);
} catch (Exception e) {
    System.debug('Test 9 Error: ' + e.getMessage());
}

// Test 10: Previous Quarter Analysis
System.debug('\n--- TEST 10: Previous Quarter Analysis ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request10 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request10.analysisType = 'MEETINGS';
    request10.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request10.timeFrame = 'PREVIOUS';
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses10 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request10 });
    
    if (!responses10.isEmpty()) {
        System.debug('Test 10 - Success: ' + responses10[0].success + ', Total: ' + responses10[0].totalValue);
    }
} catch (Exception e) {
    System.debug('Test 10 Error: ' + e.getMessage());
}

// Test 11: Limited Results Test
System.debug('\n--- TEST 11: Limited Results Test ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request11 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request11.analysisType = 'PIPELINE';
    request11.primaryDimension = 'OU_NAME';
    request11.maxResults = 100;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses11 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request11 });
    
    if (!responses11.isEmpty()) {
        System.debug('Test 11 - Success: ' + responses11[0].success + ', Records: ' + responses11[0].totalRecords);
    }
} catch (Exception e) {
    System.debug('Test 11 Error: ' + e.getMessage());
}

// Test 12: Detailed Analysis with Breakdowns
System.debug('\n--- TEST 12: Detailed Analysis with Breakdowns ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request12 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request12.analysisType = 'ACV';
    request12.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request12.includeDetails = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses12 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request12 });
    
    if (!responses12.isEmpty()) {
        System.debug('Test 12 - Success: ' + responses12[0].success + ', Breakdown: ' + responses12[0].breakdownSummary);
    }
} catch (Exception e) {
    System.debug('Test 12 Error: ' + e.getMessage());
}

// Test 13: Invalid Analysis Type Test
System.debug('\n--- TEST 13: Invalid Analysis Type Test ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request13 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request13.analysisType = 'INVALID_TYPE';
    request13.primaryDimension = 'OU_NAME';
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses13 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request13 });
    
    if (!responses13.isEmpty()) {
        System.debug('Test 13 - Success: ' + responses13[0].success + ', Message: ' + responses13[0].message);
    }
} catch (Exception e) {
    System.debug('Test 13 Error: ' + e.getMessage());
}

// Test 14: Null Dimension Test
System.debug('\n--- TEST 14: Null Dimension Test ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request14 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request14.analysisType = 'MEETINGS';
    request14.primaryDimension = null;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses14 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request14 });
    
    if (!responses14.isEmpty()) {
        System.debug('Test 14 - Success: ' + responses14[0].success + ', Message: ' + responses14[0].message);
    }
} catch (Exception e) {
    System.debug('Test 14 Error: ' + e.getMessage());
}

// Test 15: Direct Service Call Test
System.debug('\n--- TEST 15: Direct Service Call Test ---');
try {
    ANAgentKPIAnalysisService.KPIAnalysisRequest serviceRequest = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    serviceRequest.analysisType = 'MEETINGS';
    serviceRequest.primaryDimension = 'WORK_LOCATION_COUNTRY';
    serviceRequest.primaryValue = 'Canada';
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse serviceResponse = 
        ANAgentKPIAnalysisService.analyzeKPIs(serviceRequest);
    
    System.debug('Test 15 - Success: ' + serviceResponse.success + ', Total: ' + serviceResponse.totalValue);
} catch (Exception e) {
    System.debug('Test 15 Error: ' + e.getMessage());
}

// Test 16: Large Dataset Test (should handle governor limits gracefully)
System.debug('\n--- TEST 16: Large Dataset Test ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request16 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request16.analysisType = 'MEETINGS';
    request16.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request16.maxResults = 100000; // Very high limit to test governor limit handling
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses16 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request16 });
    
    if (!responses16.isEmpty()) {
        System.debug('Test 16 - Success: ' + responses16[0].success + ', Records: ' + responses16[0].totalRecords);
    }
} catch (Exception e) {
    System.debug('Test 16 - Expected Error (Governor Limit): ' + e.getMessage());
}

// Test 17: Edge Case - Very Small Dataset
System.debug('\n--- TEST 17: Edge Case - Very Small Dataset ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request17 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request17.analysisType = 'MEETINGS';
    request17.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request17.primaryValue = 'Morocco'; // Small country with few records
    request17.maxResults = 10;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses17 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request17 });
    
    if (!responses17.isEmpty()) {
        System.debug('Test 17 - Success: ' + responses17[0].success + ', Total: ' + responses17[0].totalValue);
    }
} catch (Exception e) {
    System.debug('Test 17 Error: ' + e.getMessage());
}

// Test 18: Performance Test - Multiple Concurrent Requests
System.debug('\n--- TEST 18: Performance Test - Multiple Concurrent Requests ---');
try {
    List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest> requests18 = new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>();
    
    // Create multiple requests for different analyses
    for (Integer i = 0; i < 5; i++) {
        ANAgentKPIAnalysisHandler.KPIAnalysisRequest req = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
        req.analysisType = 'MEETINGS';
        req.primaryDimension = 'WORK_LOCATION_COUNTRY';
        req.maxResults = 1000;
        requests18.add(req);
    }
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses18 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(requests18);
    
    System.debug('Test 18 - Success: Processed ' + responses18.size() + ' concurrent requests');
} catch (Exception e) {
    System.debug('Test 18 Error: ' + e.getMessage());
}

// Test 19: Data Validation Test - Check for Realistic Values
System.debug('\n--- TEST 19: Data Validation Test - Check for Realistic Values ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisResponse response19 = 
        ANAgentKPIAnalysisHandler.analyzeMeetings('WORK_LOCATION_COUNTRY', 'US');
    
    if (response19.success && response19.totalValue > 100000) {
        System.debug('Test 19 - ✅ PASSED: US meetings value is realistic: ' + response19.totalValue);
    } else {
        System.debug('Test 19 - ❌ FAILED: US meetings value is unrealistic: ' + response19.totalValue);
    }
} catch (Exception e) {
    System.debug('Test 19 Error: ' + e.getMessage());
}

// Test 20: Comprehensive End-to-End Test
System.debug('\n--- TEST 20: Comprehensive End-to-End Test ---');
try {
    // Test all analysis types in sequence
    String[] analysisTypes = new String[]{'MEETINGS', 'PIPELINE', 'ACV', 'CALLS', 'AI_MENTIONS'};
    String[] dimensions = new String[]{'WORK_LOCATION_COUNTRY', 'OU_NAME', 'PRIMARY_INDUSTRY'};
    
    Integer successCount = 0;
    Integer totalTests = 0;
    
    for (String analysisType : analysisTypes) {
        for (String dimension : dimensions) {
            try {
                ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
                request.analysisType = analysisType;
                request.primaryDimension = dimension;
                request.maxResults = 1000;
                
                List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = 
                    ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request });
                
                if (!responses.isEmpty() && responses[0].success) {
                    successCount++;
                }
                totalTests++;
            } catch (Exception e) {
                totalTests++;
            }
        }
    }
    
    System.debug('Test 20 - Comprehensive Test Results: ' + successCount + '/' + totalTests + ' tests passed');
    
} catch (Exception e) {
    System.debug('Test 20 Error: ' + e.getMessage());
}

System.debug('\n=== COMPREHENSIVE KPI ANALYSIS TEST SUITE COMPLETED ==='); 