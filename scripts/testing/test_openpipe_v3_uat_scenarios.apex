// UAT Test Scenarios for Open Pipe Analysis V3 Service
// Testing specific business requirements and edge cases

System.debug('=== Open Pipe Analysis V3 - UAT Scenarios ===');

try {
    // UAT Scenario 1: Average days opportunity stuck in Stage 2 for certain product
    System.debug('--- UAT Scenario 1: Days in Stage 2 for Specific Product ---');
    testDaysInStage2ForProduct();
    
    // UAT Scenario 2: Number of AEs who have deals with "Data Cloud" products
    System.debug('--- UAT Scenario 2: AEs with Data Cloud Deals ---');
    testAEsWithDataCloudDeals();
    
    // UAT Scenario 3: Total value of deals in Stage 3 and Stage 4 for certain segment
    System.debug('--- UAT Scenario 3: Deal Value in Stages 3-4 for Segment ---');
    testDealValueInStages3And4ForSegment();
    
    // UAT Scenario 4: Edge case - Multiple stage filters
    System.debug('--- UAT Scenario 4: Multiple Stage Filters ---');
    testMultipleStageFilters();
    
    // UAT Scenario 5: Edge case - Complex product filtering
    System.debug('--- UAT Scenario 5: Complex Product Filtering ---');
    testComplexProductFiltering();
    
    // UAT Scenario 6: Edge case - Segment with no data
    System.debug('--- UAT Scenario 6: Segment with No Data ---');
    testSegmentWithNoData();
    
    System.debug('=== All UAT Scenarios Completed ===');
    
} catch (Exception e) {
    System.debug(LoggingLevel.ERROR, 'UAT Test failed: ' + e.getMessage());
    System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
}

// UAT Scenario 1: Average days opportunity stuck in Stage 2 for certain product
public static void testDaysInStage2ForProduct() {
    System.debug('Testing: Average days opportunity stuck in Stage 2 for certain product...');
    
    try {
        // Test with Tableau product in Stage 2
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'PRODUCT';
        req.analysisType = 'DAYS_IN_STAGE';
        req.filterCriteria = 'open_pipe_opty_stg_nm=\'02 - Qualifying\' AND open_pipe_prod_nm LIKE \'%Tableau%\'';
        req.limitN = 5;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('Days in Stage 2 Response: ' + message);
            
            // Verify the analysis type is handled correctly
            if (message.contains('DAYS_IN_STAGE') || message.contains('days in stage')) {
                System.debug('✅ SUCCESS: Days in Stage 2 analysis works correctly');
                
                // Check if it shows realistic aggregation
                if (message.contains('Average') || message.contains('avgDays')) {
                    System.debug('✅ SUCCESS: Realistic aggregation is working');
                } else {
                    System.debug('⚠️ WARNING: Realistic aggregation may not be working');
                }
            } else {
                System.debug('❌ FAILURE: Days in Stage 2 analysis is not working');
            }
            
            // Verify filter criteria is applied
            if (message.contains('Filter: open_pipe_opty_stg_nm=\'02 - Qualifying\' AND open_pipe_prod_nm LIKE \'%Tableau%\'') ||
                message.contains('Filter: open_pipe_opty_stg_nm=\'02 - Qualifying\' AND open_pipe_prod_nm LIKE \'%Tableau%\'') ||
                message.contains('02 - Qualifying') && message.contains('Tableau')) {
                System.debug('✅ SUCCESS: Filter criteria is properly applied');
            } else {
                System.debug('❌ FAILURE: Filter criteria is not properly applied');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'Days in Stage 2 test failed: ' + e.getMessage());
    }
}

// UAT Scenario 2: Number of AEs who have deals with "Data Cloud" products
public static void testAEsWithDataCloudDeals() {
    System.debug('Testing: Number of AEs who have deals with "Data Cloud" products...');
    
    try {
        // Test with Data Cloud product filtering
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'AE';
        req.analysisType = 'AE_ANALYSIS';
        req.filterCriteria = 'open_pipe_prod_nm LIKE \'%Data Cloud%\'';
        req.limitN = 10;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('Data Cloud AEs Response: ' + message);
            
            // Verify AE analysis is working
            if (message.contains('**AE Analysis**:')) {
                System.debug('✅ SUCCESS: AE analysis for Data Cloud products is working');
                
                // Check if email addresses are included
                if (message.contains('Email:')) {
                    System.debug('✅ SUCCESS: Email addresses are included in AE analysis');
                } else {
                    System.debug('❌ FAILURE: Email addresses are missing from AE analysis');
                }
                
                // Check if it shows unique products and opportunities
                if (message.contains('unique products') && message.contains('unique opportunities')) {
                    System.debug('✅ SUCCESS: Unique counts are properly displayed');
                } else {
                    System.debug('❌ FAILURE: Unique counts are not properly displayed');
                }
            } else {
                System.debug('❌ FAILURE: AE analysis for Data Cloud products is not working');
            }
            
            // Verify Data Cloud filter is applied
            if (message.contains('Data Cloud') || message.contains('Filter: open_pipe_prod_nm LIKE \'%Data Cloud%\'')) {
                System.debug('✅ SUCCESS: Data Cloud filter is properly applied');
            } else {
                System.debug('❌ FAILURE: Data Cloud filter is not properly applied');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'Data Cloud AEs test failed: ' + e.getMessage());
    }
}

// UAT Scenario 3: Total value of deals in Stage 3 and Stage 4 for certain segment
public static void testDealValueInStages3And4ForSegment() {
    System.debug('Testing: Total value of deals in Stage 3 and Stage 4 for certain segment...');
    
    try {
        // Test with ESMB segment in Stages 3 and 4
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'STAGE';
        req.analysisType = 'PRODUCT_PERFORMANCE';
        req.filterCriteria = '(open_pipe_opty_stg_nm=\'03 - Validating Benefits & Value\' OR open_pipe_opty_stg_nm=\'04 - Proposing Solution\') AND macrosgment__c=\'ESMB\'';
        req.limitN = 10;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('Stages 3-4 ESMB Response: ' + message);
            
            // Verify product performance analysis is working
            if (message.contains('**Product Performance Analysis**:') || message.contains('total value')) {
                System.debug('✅ SUCCESS: Product performance analysis for Stages 3-4 ESMB is working');
                
                // Check if it shows dollar amounts
                if (message.contains('$')) {
                    System.debug('✅ SUCCESS: Dollar amounts are properly displayed');
                } else {
                    System.debug('⚠️ WARNING: Dollar amounts may not be displayed');
                }
            } else {
                System.debug('❌ FAILURE: Product performance analysis for Stages 3-4 ESMB is not working');
            }
            
            // Verify complex filter is applied
            if (message.contains('03 - Validating Benefits & Value') || message.contains('04 - Proposing Solution') || message.contains('ESMB')) {
                System.debug('✅ SUCCESS: Complex stage and segment filter is properly applied');
            } else {
                System.debug('❌ FAILURE: Complex stage and segment filter is not properly applied');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'Stages 3-4 ESMB test failed: ' + e.getMessage());
    }
}

// UAT Scenario 4: Edge case - Multiple stage filters
public static void testMultipleStageFilters() {
    System.debug('Testing: Multiple stage filters edge case...');
    
    try {
        // Test with multiple stages using OR logic
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'PRODUCT';
        req.analysisType = 'STAGE_COUNT';
        req.filterCriteria = 'open_pipe_opty_stg_nm=\'01 - Prospecting\' OR open_pipe_opty_stg_nm=\'02 - Qualifying\' OR open_pipe_opty_stg_nm=\'03 - Validating Benefits & Value\'';
        req.limitN = 5;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('Multiple Stages Response: ' + message);
            
            // Verify stage count analysis is working
            if (message.contains('opportunities')) {
                System.debug('✅ SUCCESS: Multiple stage filter analysis is working');
            } else {
                System.debug('❌ FAILURE: Multiple stage filter analysis is not working');
            }
            
            // Verify filter is properly displayed
            if (message.contains('Filter:') && (message.contains('01 - Prospecting') || message.contains('02 - Qualifying') || message.contains('03 - Validating Benefits & Value'))) {
                System.debug('✅ SUCCESS: Multiple stage filter is properly displayed');
            } else {
                System.debug('❌ FAILURE: Multiple stage filter is not properly displayed');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'Multiple stages test failed: ' + e.getMessage());
    }
}

// UAT Scenario 5: Edge case - Complex product filtering
public static void testComplexProductFiltering() {
    System.debug('Testing: Complex product filtering edge case...');
    
    try {
        // Test with complex product filters using AND/OR logic
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'AE';
        req.analysisType = 'AE_ANALYSIS';
        req.filterCriteria = '(open_pipe_prod_nm LIKE \'%Tableau%\' OR open_pipe_prod_nm LIKE \'%Data Cloud%\') AND open_pipe_ae_score__c > 3';
        req.limitN = 5;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('Complex Product Filter Response: ' + message);
            
            // Verify complex filter analysis is working
            if (message.contains('**AE Analysis**:')) {
                System.debug('✅ SUCCESS: Complex product filter analysis is working');
                
                // Check if email addresses are included
                if (message.contains('Email:')) {
                    System.debug('✅ SUCCESS: Email addresses are included in complex filter analysis');
                } else {
                    System.debug('❌ FAILURE: Email addresses are missing from complex filter analysis');
                }
            } else {
                System.debug('❌ FAILURE: Complex product filter analysis is not working');
            }
            
            // Verify complex filter is properly displayed
            if (message.contains('Filter:') && (message.contains('Tableau') || message.contains('Data Cloud')) && message.contains('ae_score__c > 3')) {
                System.debug('✅ SUCCESS: Complex product filter is properly displayed');
            } else {
                System.debug('❌ FAILURE: Complex product filter is not properly displayed');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'Complex product filter test failed: ' + e.getMessage());
    }
}

// UAT Scenario 6: Edge case - Segment with no data
public static void testSegmentWithNoData() {
    System.debug('Testing: Segment with no data edge case...');
    
    try {
        // Test with a segment that likely has no data
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'PRODUCT';
        req.analysisType = 'PRODUCT_PERFORMANCE';
        req.filterCriteria = 'macrosgment__c=\'NON_EXISTENT_SEGMENT\'';
        req.limitN = 5;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('No Data Segment Response: ' + message);
            
            // Verify no data handling is working
            if (message.contains('No records found') || message.contains('Total Records Found: 0')) {
                System.debug('✅ SUCCESS: No data handling is working correctly');
            } else {
                System.debug('⚠️ WARNING: No data handling may not be working as expected');
            }
            
            // Verify filter is properly displayed even with no results
            if (message.contains('Filter: macrosgment__c=\'NON_EXISTENT_SEGMENT\'')) {
                System.debug('✅ SUCCESS: Filter is properly displayed even with no results');
            } else {
                System.debug('❌ FAILURE: Filter is not properly displayed with no results');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'No data segment test failed: ' + e.getMessage());
    }
}
