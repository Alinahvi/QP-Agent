// Focused Email Functionality Test for Open Pipe Analysis V3 Service
// Tests email inclusion across different analysis types and scenarios

System.debug('=== Open Pipe Analysis V3 - Email Functionality Test ===');

try {
    // Test 1: Basic AE Analysis with Email Addresses
    System.debug('--- Test 1: Basic AE Analysis with Emails ---');
    testBasicAEAnalysisWithEmails();
    
    // Test 2: AE Analysis with Product Filtering and Emails
    System.debug('--- Test 2: AE Analysis with Product Filtering and Emails ---');
    testAEAnalysisWithProductFilteringAndEmails();
    
    // Test 3: AE Analysis with Stage Filtering and Emails
    System.debug('--- Test 3: AE Analysis with Stage Filtering and Emails ---');
    testAEAnalysisWithStageFilteringAndEmails();
    
    // Test 4: AE Analysis with Complex Filtering and Emails
    System.debug('--- Test 4: AE Analysis with Complex Filtering and Emails ---');
    testAEAnalysisWithComplexFilteringAndEmails();
    
    // Test 5: AE Analysis with Limit and Emails
    System.debug('--- Test 5: AE Analysis with Limit and Emails ---');
    testAEAnalysisWithLimitAndEmails();
    
    // Test 6: AE Analysis with No Results and Emails
    System.debug('--- Test 6: AE Analysis with No Results and Emails ---');
    testAEAnalysisWithNoResultsAndEmails();
    
    // Test 7: Verify Email Field in JSON Output
    System.debug('--- Test 7: Verify Email Field in JSON Output ---');
    testEmailFieldInJSONOutput();
    
    System.debug('=== All Email Functionality Tests Completed ===');
    
} catch (Exception e) {
    System.debug(LoggingLevel.ERROR, 'Email Functionality Test failed: ' + e.getMessage());
    System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
}

// Test 1: Basic AE Analysis with Email Addresses
public static void testBasicAEAnalysisWithEmails() {
    System.debug('Testing: Basic AE Analysis with Email Addresses...');
    
    try {
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'AE';
        req.analysisType = 'AE_ANALYSIS';
        req.limitN = 3;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('Basic AE Analysis Response: ' + message);
            
            // Verify email addresses are included
            if (message.contains('Email:')) {
                System.debug('✅ SUCCESS: Email addresses are included in basic AE analysis');
                
                // Count email occurrences
                Integer emailCount = message.countMatches('Email:');
                System.debug('📧 Found ' + emailCount + ' email addresses in the output');
                
                // Verify the format
                if (message.contains('Email: ') && message.contains('@salesforce.com')) {
                    System.debug('✅ SUCCESS: Email format is correct (Email: prefix and @salesforce.com domain)');
                } else {
                    System.debug('❌ FAILURE: Email format is incorrect');
                }
            } else {
                System.debug('❌ FAILURE: Email addresses are missing from basic AE analysis');
            }
            
            // Verify AE analysis insights are properly formatted
            if (message.contains('**AE Analysis**:')) {
                System.debug('✅ SUCCESS: AE analysis insights are properly formatted');
            } else {
                System.debug('❌ FAILURE: AE analysis insights are not properly formatted');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'Basic AE Analysis test failed: ' + e.getMessage());
    }
}

// Test 2: AE Analysis with Product Filtering and Emails
public static void testAEAnalysisWithProductFilteringAndEmails() {
    System.debug('Testing: AE Analysis with Product Filtering and Email Addresses...');
    
    try {
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'AE';
        req.analysisType = 'AE_ANALYSIS';
        req.filterCriteria = 'open_pipe_prod_nm LIKE \'%Tableau%\'';
        req.limitN = 3;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('Product Filtered AE Analysis Response: ' + message);
            
            // Verify email addresses are included
            if (message.contains('Email:')) {
                System.debug('✅ SUCCESS: Email addresses are included in product-filtered AE analysis');
                
                // Count email occurrences
                Integer emailCount = message.countMatches('Email:');
                System.debug('📧 Found ' + emailCount + ' email addresses in the product-filtered output');
                
                // Verify Tableau filter is working
                if (message.contains('Tableau')) {
                    System.debug('✅ SUCCESS: Tableau product filter is working correctly');
                } else {
                    System.debug('❌ FAILURE: Tableau product filter is not working');
                }
            } else {
                System.debug('❌ FAILURE: Email addresses are missing from product-filtered AE analysis');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'Product Filtered AE Analysis test failed: ' + e.getMessage());
    }
}

// Test 3: AE Analysis with Stage Filtering and Emails
public static void testAEAnalysisWithStageFilteringAndEmails() {
    System.debug('Testing: AE Analysis with Stage Filtering and Email Addresses...');
    
    try {
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'AE';
        req.analysisType = 'AE_ANALYSIS';
        req.filterCriteria = 'open_pipe_opty_stg_nm=\'03 - Validating Benefits & Value\'';
        req.limitN = 3;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('Stage Filtered AE Analysis Response: ' + message);
            
            // Verify email addresses are included
            if (message.contains('Email:')) {
                System.debug('✅ SUCCESS: Email addresses are included in stage-filtered AE analysis');
                
                // Count email occurrences
                Integer emailCount = message.countMatches('Email:');
                System.debug('📧 Found ' + emailCount + ' email addresses in the stage-filtered output');
                
                // Verify stage filter is working
                if (message.contains('03 - Validating Benefits & Value')) {
                    System.debug('✅ SUCCESS: Stage filter is working correctly');
                } else {
                    System.debug('❌ FAILURE: Stage filter is not working');
                }
            } else {
                System.debug('❌ FAILURE: Email addresses are missing from stage-filtered AE analysis');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'Stage Filtered AE Analysis test failed: ' + e.getMessage());
    }
}

// Test 4: AE Analysis with Complex Filtering and Emails
public static void testAEAnalysisWithComplexFilteringAndEmails() {
    System.debug('Testing: AE Analysis with Complex Filtering and Email Addresses...');
    
    try {
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'AE';
        req.analysisType = 'AE_ANALYSIS';
        req.filterCriteria = '(open_pipe_prod_nm LIKE \'%Data Cloud%\' OR open_pipe_prod_nm LIKE \'%Tableau%\') AND open_pipe_ae_score__c > 3';
        req.limitN = 3;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('Complex Filtered AE Analysis Response: ' + message);
            
            // Verify email addresses are included
            if (message.contains('Email:')) {
                System.debug('✅ SUCCESS: Email addresses are included in complex-filtered AE analysis');
                
                // Count email occurrences
                Integer emailCount = message.countMatches('Email:');
                System.debug('📧 Found ' + emailCount + ' email addresses in the complex-filtered output');
                
                // Verify complex filter is working
                if (message.contains('Data Cloud') || message.contains('Tableau')) {
                    System.debug('✅ SUCCESS: Complex product filter is working correctly');
                } else {
                    System.debug('❌ FAILURE: Complex product filter is not working');
                }
            } else {
                System.debug('❌ FAILURE: Email addresses are missing from complex-filtered AE analysis');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'Complex Filtered AE Analysis test failed: ' + e.getMessage());
    }
}

// Test 5: AE Analysis with Limit and Emails
public static void testAEAnalysisWithLimitAndEmails() {
    System.debug('Testing: AE Analysis with Limit and Email Addresses...');
    
    try {
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'AE';
        req.analysisType = 'AE_ANALYSIS';
        req.limitN = 1; // Very small limit to test edge case
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('Limited AE Analysis Response: ' + message);
            
            // Verify email addresses are included even with limit
            if (message.contains('Email:')) {
                System.debug('✅ SUCCESS: Email addresses are included in limited AE analysis');
                
                // Count email occurrences
                Integer emailCount = message.countMatches('Email:');
                System.debug('📧 Found ' + emailCount + ' email addresses in the limited output');
                
                // Verify limit is working
                if (message.contains('Limit Applied: 1')) {
                    System.debug('✅ SUCCESS: Limit is working correctly');
                } else {
                    System.debug('⚠️ WARNING: Limit may not be working as expected');
                }
            } else {
                System.debug('❌ FAILURE: Email addresses are missing from limited AE analysis');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'Limited AE Analysis test failed: ' + e.getMessage());
    }
}

// Test 6: AE Analysis with No Results and Emails
public static void testAEAnalysisWithNoResultsAndEmails() {
    System.debug('Testing: AE Analysis with No Results and Email Addresses...');
    
    try {
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'AE';
        req.analysisType = 'AE_ANALYSIS';
        req.filterCriteria = 'open_pipe_prod_nm=\'NON_EXISTENT_PRODUCT\'';
        req.limitN = 3;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('No Results AE Analysis Response: ' + message);
            
            // Verify no results handling
            if (message.contains('No records found') || message.contains('Total Records Found: 0')) {
                System.debug('✅ SUCCESS: No results handling is working correctly');
                
                // Verify email section is not present when no results
                if (!message.contains('Email:')) {
                    System.debug('✅ SUCCESS: Email section is correctly not present when no results');
                } else {
                    System.debug('❌ FAILURE: Email section is present when there are no results');
                }
            } else {
                System.debug('⚠️ WARNING: No results handling may not be working as expected');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'No Results AE Analysis test failed: ' + e.getMessage());
    }
}

// Test 7: Verify Email Field in JSON Output
public static void testEmailFieldInJSONOutput() {
    System.debug('Testing: Email Field in JSON Output...');
    
    try {
        ANAgentOpenPipeAnalysisV3Handler.Request req = new ANAgentOpenPipeAnalysisV3Handler.Request();
        req.ouName = 'AMER ICE';
        req.groupBy = 'AE';
        req.analysisType = 'AE_ANALYSIS';
        req.limitN = 2;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req};
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            System.debug('JSON Output Test Response: ' + message);
            
            // Verify JSON section contains email field
            if (message.contains('"aeEmail"')) {
                System.debug('✅ SUCCESS: JSON output contains aeEmail field');
                
                // Count aeEmail occurrences in JSON
                Integer jsonEmailCount = message.countMatches('"aeEmail"');
                System.debug('📧 Found ' + jsonEmailCount + ' aeEmail fields in JSON output');
                
                // Verify email format in JSON
                if (message.contains('"aeEmail" : "') && message.contains('@salesforce.com"')) {
                    System.debug('✅ SUCCESS: JSON email format is correct');
                } else {
                    System.debug('❌ FAILURE: JSON email format is incorrect');
                }
            } else {
                System.debug('❌ FAILURE: JSON output is missing aeEmail field');
            }
            
            // Verify both human-readable and JSON formats have emails
            Integer humanEmailCount = message.countMatches('Email:');
            Integer jsonEmailCount = message.countMatches('"aeEmail"');
            
            if (humanEmailCount > 0 && jsonEmailCount > 0) {
                System.debug('✅ SUCCESS: Both human-readable and JSON formats contain email addresses');
                System.debug('📊 Human-readable emails: ' + humanEmailCount + ', JSON emails: ' + jsonEmailCount);
            } else {
                System.debug('❌ FAILURE: Email addresses are missing from one or both formats');
            }
        }
        
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'JSON Output test failed: ' + e.getMessage());
    }
}
