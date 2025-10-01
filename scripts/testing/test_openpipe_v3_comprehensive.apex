// Comprehensive test script for Open Pipe Analysis V3 service
// Tests new email functionality and verifies all existing business logic remains intact

System.debug('=== Comprehensive Open Pipe Analysis V3 Test ===');

try {
    // Test 1: New AE Analysis with Email Addresses
    System.debug('--- Test 1: AE Analysis with Email Addresses ---');
    testAEAnalysisWithEmails();
    
    // Test 2: Verify STAGE_COUNT analysis still works
    System.debug('--- Test 2: STAGE_COUNT Analysis ---');
    testStageCountAnalysis();
    
    // Test 3: Verify PRODUCT_PERFORMANCE analysis still works
    System.debug('--- Test 3: PRODUCT_PERFORMANCE Analysis ---');
    testProductPerformanceAnalysis();
    
    // Test 4: Verify AE_SCORE_ANALYSIS still works
    System.debug('--- Test 4: AE_SCORE_ANALYSIS ---');
    testAEScoreAnalysis();
    
    // Test 5: Verify DAYS_IN_STAGE analysis still works
    System.debug('--- Test 5: DAYS_IN_STAGE Analysis ---');
    testDaysInStageAnalysis();
    
    // Test 6: Verify OPPORTUNITY_DETAILS analysis still works
    System.debug('--- Test 6: OPPORTUNITY_DETAILS Analysis ---');
    testOpportunityDetailsAnalysis();
    
    // Test 7: Verify default analysis still works
    System.debug('--- Test 7: Default Analysis ---');
    testDefaultAnalysis();
    
    // Test 8: Verify field mapping and filtering still works
    System.debug('--- Test 8: Field Mapping and Filtering ---');
    testFieldMappingAndFiltering();
    
    System.debug('=== All Tests Completed Successfully ===');
    
} catch (Exception e) {
    System.debug(LoggingLevel.ERROR, 'Test failed: ' + e.getMessage());
    System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
}

// Test 1: New AE Analysis with Email Addresses
public static void testAEAnalysisWithEmails() {
    System.debug('Testing AE Analysis with Email Addresses...');
    
    try {
        // Create a test request for AE analysis
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'AE';
        req.analysisType = 'AE_ANALYSIS';
        req.filterCriteria = 'open_pipe_prod_nm LIKE \'%Tableau%\'';
        req.limitN = 5;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        
        // Call the handler
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('AE Analysis Response: ' + message);
            
            // Verify email addresses are included
            if (message.contains('Email:')) {
                System.debug('✅ SUCCESS: Email addresses are included in AE analysis');
            } else {
                System.debug('❌ FAILURE: Email addresses are missing from AE analysis');
            }
            
            // Verify the analysis type is handled correctly
            if (message.contains('**AE Analysis**:')) {
                System.debug('✅ SUCCESS: AE analysis insights are properly formatted');
            } else {
                System.debug('❌ FAILURE: AE analysis insights are not properly formatted');
            }
            
        } else {
            System.debug('❌ FAILURE: No response received from AE analysis');
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'AE Analysis test failed: ' + e.getMessage());
    }
}

// Test 2: Verify STAGE_COUNT analysis still works
public static void testStageCountAnalysis() {
    System.debug('Testing STAGE_COUNT Analysis...');
    
    try {
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'STAGE';
        req.analysisType = 'STAGE_COUNT';
        req.limitN = 3;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('STAGE_COUNT Response: ' + message);
            
            if (message.contains('opportunities')) {
                System.debug('✅ SUCCESS: STAGE_COUNT analysis still works correctly');
            } else {
                System.debug('❌ FAILURE: STAGE_COUNT analysis is broken');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'STAGE_COUNT test failed: ' + e.getMessage());
    }
}

// Test 3: Verify PRODUCT_PERFORMANCE analysis still works
public static void testProductPerformanceAnalysis() {
    System.debug('Testing PRODUCT_PERFORMANCE Analysis...');
    
    try {
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'PRODUCT';
        req.analysisType = 'PRODUCT_PERFORMANCE';
        req.limitN = 3;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('PRODUCT_PERFORMANCE Response: ' + message);
            
            if (message.contains('total value')) {
                System.debug('✅ SUCCESS: PRODUCT_PERFORMANCE analysis still works correctly');
            } else {
                System.debug('❌ FAILURE: PRODUCT_PERFORMANCE analysis is broken');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'PRODUCT_PERFORMANCE test failed: ' + e.getMessage());
    }
}

// Test 4: Verify AE_SCORE_ANALYSIS still works
public static void testAEScoreAnalysis() {
    System.debug('Testing AE_SCORE_ANALYSIS...');
    
    try {
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'AE';
        req.analysisType = 'AE_SCORE_ANALYSIS';
        req.limitN = 3;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('AE_SCORE_ANALYSIS Response: ' + message);
            
            if (message.contains('Average score')) {
                System.debug('✅ SUCCESS: AE_SCORE_ANALYSIS still works correctly');
            } else {
                System.debug('❌ FAILURE: AE_SCORE_ANALYSIS is broken');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'AE_SCORE_ANALYSIS test failed: ' + e.getMessage());
    }
}

// Test 5: Verify DAYS_IN_STAGE analysis still works
public static void testDaysInStageAnalysis() {
    System.debug('Testing DAYS_IN_STAGE Analysis...');
    
    try {
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'PRODUCT';
        req.analysisType = 'DAYS_IN_STAGE';
        req.filterCriteria = 'open_pipe_opty_stg_nm=\'03 - Validating Benefits & Value\'';
        req.limitN = 3;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('DAYS_IN_STAGE Response: ' + message);
            
            if (message.contains('days in stage') || message.contains('Average')) {
                System.debug('✅ SUCCESS: DAYS_IN_STAGE analysis still works correctly');
            } else {
                System.debug('❌ FAILURE: DAYS_IN_STAGE analysis is broken');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'DAYS_IN_STAGE test failed: ' + e.getMessage());
    }
}

// Test 6: Verify OPPORTUNITY_DETAILS analysis still works
public static void testOpportunityDetailsAnalysis() {
    System.debug('Testing OPPORTUNITY_DETAILS Analysis...');
    
    try {
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'STAGE';
        req.analysisType = 'OPPORTUNITY_DETAILS';
        req.limitN = 3;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('OPPORTUNITY_DETAILS Response: ' + message);
            
            if (message.contains('$') && message.contains('-')) {
                System.debug('✅ SUCCESS: OPPORTUNITY_DETAILS analysis still works correctly');
            } else {
                System.debug('❌ FAILURE: OPPORTUNITY_DETAILS analysis is broken');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'OPPORTUNITY_DETAILS test failed: ' + e.getMessage());
    }
}

// Test 7: Verify default analysis still works
public static void testDefaultAnalysis() {
    System.debug('Testing Default Analysis...');
    
    try {
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'STAGE';
        req.analysisType = 'UNKNOWN_TYPE'; // This should trigger default analysis
        req.limitN = 3;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('Default Analysis Response: ' + message);
            
            if (message.contains('General Analysis') || message.contains('Total opportunities analyzed')) {
                System.debug('✅ SUCCESS: Default analysis still works correctly');
            } else {
                System.debug('❌ FAILURE: Default analysis is broken');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'Default analysis test failed: ' + e.getMessage());
    }
}

// Test 8: Verify field mapping and filtering still works
public static void testFieldMappingAndFiltering() {
    System.debug('Testing Field Mapping and Filtering...');
    
    try {
        // Test with user-friendly field names
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'AE';
        req.analysisType = 'AE_ANALYSIS';
        req.filterCriteria = 'product LIKE \'%Tableau%\' AND stage=\'03 - Validating Benefits & Value\'';
        req.limitN = 3;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('Field Mapping Response: ' + message);
            
            if (message.contains('Filter: product LIKE \'%Tableau%\' AND stage=\'03 - Validating Benefits & Value\'')) {
                System.debug('✅ SUCCESS: Field mapping and filtering still works correctly');
            } else {
                System.debug('❌ FAILURE: Field mapping and filtering is broken');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'Field mapping test failed: ' + e.getMessage());
    }
}
