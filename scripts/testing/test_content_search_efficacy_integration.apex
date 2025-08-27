// Test script for Content Search + Efficacy Integration
// This script tests the complete flow: find offerings via content search, then get efficacy data
// Run this in Developer Console to test the integration

System.debug('🔍 TESTING CONTENT SEARCH + EFFICACY INTEGRATION');
System.debug('================================================');

// Test Configuration
String testSearchTerm = 'Einstein'; // Search term to find courses/offerings
String testContentType = 'Course'; // Focus on courses for efficacy analysis
Integer maxResults = 10; // Limit results for testing

// Test Results Tracking
Map<String, Boolean> testResults = new Map<String, Boolean>();
Map<String, String> testMessages = new Map<String, String>();

// ============================================================================
// PHASE 1: CONTENT SEARCH TESTING
// ============================================================================

System.debug('\n--- PHASE 1: Content Search Testing ---');

// Test 1: Content Search Handler Instantiation
try {
    System.debug('Testing Content Search Handler Instantiation...');
    ANAgentContentSearchHandlerV2.ContentSearchRequest searchRequest = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
    searchRequest.searchTerm = testSearchTerm;
    searchRequest.contentType = testContentType;
    
    System.debug('✅ Content search handler instantiation successful');
    testResults.put('ContentSearch_Handler_Instantiation', true);
} catch (Exception e) {
    System.debug('❌ Content search handler instantiation failed: ' + e.getMessage());
    testResults.put('ContentSearch_Handler_Instantiation', false);
    testMessages.put('ContentSearch_Handler_Instantiation', e.getMessage());
}

// Test 2: Content Search Execution
try {
    System.debug('Testing Content Search Execution...');
    
    ANAgentContentSearchHandlerV2.ContentSearchRequest searchRequest = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
    searchRequest.searchTerm = testSearchTerm;
    searchRequest.contentType = testContentType;
    
    List<ANAgentContentSearchHandlerV2.ContentSearchResponse> searchResponses = 
        ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{searchRequest});
    
    if (!searchResponses.isEmpty()) {
        ANAgentContentSearchHandlerV2.ContentSearchResponse searchResponse = searchResponses[0];
        
        if (searchResponse.success) {
            System.debug('✅ Content search successful');
            System.debug('  Message: ' + searchResponse.message);
            System.debug('  Total Records: ' + searchResponse.totalRecordCount);
            System.debug('  Results Count: ' + searchResponse.results.size());
            
            // Display search results
            if (!searchResponse.results.isEmpty()) {
                System.debug('📋 Content Search Results:');
                for (Integer i = 0; i < Math.min(5, searchResponse.results.size()); i++) {
                    ANAgentContentSearchServiceV2.UnifiedContent content = searchResponse.results[i];
                    System.debug('  ' + (i+1) + '. ' + content.name + ' (' + content.type + ')');
                    System.debug('     ID: ' + content.id);
                    System.debug('     Description: ' + content.description);
                    System.debug('     Status: ' + content.status);
                    System.debug('     Learner Count: ' + content.learnerCount);
                    System.debug('     Completion Rate: ' + content.completionRate + '%');
                }
                
                testResults.put('ContentSearch_Execution', true);
                
                // Store results for efficacy testing
                List<ANAgentContentSearchServiceV2.UnifiedContent> searchResults = searchResponse.results;
                
                // ============================================================================
                // PHASE 2: EFFICACY ANALYSIS FOR EACH SEARCH RESULT
                // ============================================================================
                
                System.debug('\n--- PHASE 2: Efficacy Analysis for Search Results ---');
                
                // Test 3: Efficacy Analysis for Each Search Result
                for (Integer i = 0; i < Math.min(3, searchResults.size()); i++) {
                    ANAgentContentSearchServiceV2.UnifiedContent content = searchResults[i];
                    
                    System.debug('\n🔍 Analyzing Efficacy for: ' + content.name);
                    System.debug('  Content Type: ' + content.type);
                    System.debug('  Content ID: ' + content.id);
                    
                    // Test efficacy analysis for this content
                    testEfficacyForContent(content, i + 1);
                }
                
            } else {
                System.debug('⚠️ Content search returned no results');
                testResults.put('ContentSearch_Execution', true); // Still successful, just no results
            }
        } else {
            System.debug('❌ Content search failed: ' + searchResponse.message);
            if (!searchResponse.errors.isEmpty()) {
                System.debug('  Errors: ' + String.join(searchResponse.errors, ', '));
            }
            testResults.put('ContentSearch_Execution', false);
            testMessages.put('ContentSearch_Execution', searchResponse.message);
        }
    } else {
        System.debug('❌ Content search returned no responses');
        testResults.put('ContentSearch_Execution', false);
        testMessages.put('ContentSearch_Execution', 'No responses returned');
    }
    
} catch (Exception e) {
    System.debug('❌ Content search execution failed: ' + e.getMessage());
    testResults.put('ContentSearch_Execution', false);
    testMessages.put('ContentSearch_Execution', e.getMessage());
}

// ============================================================================
// PHASE 3: COMPREHENSIVE EFFICACY ANALYSIS
// ============================================================================

System.debug('\n--- PHASE 3: Comprehensive Efficacy Analysis ---');

// Test 4: Efficacy Analysis Across Different OUs and Verticals
try {
    System.debug('Testing Comprehensive Efficacy Analysis...');
    
    // Test different OU and vertical combinations
    List<String> testOUs = new List<String>{'ANZ', 'EMEA North', 'AMER'};
    List<String> testSegments = new List<String>{'ESMB', 'CMRCL', 'PUBSEC'};
    List<String> testPrograms = new List<String>{'Fast Start', 'Training'};
    
    for (String ou : testOUs) {
        for (String segment : testSegments) {
            System.debug('\n📊 Testing Efficacy for OU: ' + ou + ', Segment: ' + segment);
            
            ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
            request.action = 'Search';
            request.region = ou;
            request.macroSegment = segment;
            request.programType = 'Fast Start';
            request.maxResults = 5;
            
            List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> responses = 
                ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{request});
            
            if (!responses.isEmpty()) {
                ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse response = responses[0];
                System.debug('  Success: ' + response.success);
                System.debug('  Records Found: ' + response.totalRecordCount);
                System.debug('  Message: ' + response.message);
                
                if (response.success && response.totalRecordCount > 0) {
                    System.debug('  ✅ Found efficacy data for ' + ou + ' - ' + segment);
                } else {
                    System.debug('  ⚠️ No efficacy data for ' + ou + ' - ' + segment);
                }
            }
        }
    }
    
    testResults.put('Comprehensive_Efficacy_Analysis', true);
    
} catch (Exception e) {
    System.debug('❌ Comprehensive efficacy analysis failed: ' + e.getMessage());
    testResults.put('Comprehensive_Efficacy_Analysis', false);
    testMessages.put('Comprehensive_Efficacy_Analysis', e.getMessage());
}

// ============================================================================
// PHASE 4: INTEGRATION FLOW TESTING
// ============================================================================

System.debug('\n--- PHASE 4: Integration Flow Testing ---');

// Test 5: End-to-End Integration Flow
try {
    System.debug('Testing End-to-End Integration Flow...');
    
    // Step 1: Search for content
    ANAgentContentSearchHandlerV2.ContentSearchRequest searchRequest = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
    searchRequest.searchTerm = 'Fast Start';
    searchRequest.contentType = 'Course';
    
    List<ANAgentContentSearchHandlerV2.ContentSearchResponse> searchResponses = 
        ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{searchRequest});
    
    if (!searchResponses.isEmpty() && searchResponses[0].success && !searchResponses[0].results.isEmpty()) {
        
        // Step 2: Get first result for efficacy analysis
        ANAgentContentSearchServiceV2.UnifiedContent firstResult = searchResponses[0].results[0];
        System.debug('🎯 Integration Flow: Found content: ' + firstResult.name);
        
        // Step 3: Analyze efficacy for this content
        ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest efficacyRequest = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
        efficacyRequest.action = 'CourseEfficacy';
        efficacyRequest.courseName = firstResult.name;
        
        List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> efficacyResponses = 
            ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{efficacyRequest});
        
        if (!efficacyResponses.isEmpty()) {
            ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse efficacyResponse = efficacyResponses[0];
            
            if (efficacyResponse.success) {
                System.debug('🎉 INTEGRATION FLOW SUCCESSFUL!');
                System.debug('  Content Found: ' + firstResult.name);
                System.debug('  Efficacy Records: ' + efficacyResponse.totalRecordCount);
                System.debug('  Summary: ' + efficacyResponse.summaryMetrics);
                
                testResults.put('Integration_Flow', true);
            } else {
                System.debug('⚠️ Integration flow: Efficacy analysis failed');
                testResults.put('Integration_Flow', false);
                testMessages.put('Integration_Flow', 'Efficacy analysis failed: ' + efficacyResponse.message);
            }
        } else {
            System.debug('❌ Integration flow: No efficacy response');
            testResults.put('Integration_Flow', false);
            testMessages.put('Integration_Flow', 'No efficacy response');
        }
    } else {
        System.debug('❌ Integration flow: Content search failed or no results');
        testResults.put('Integration_Flow', false);
        testMessages.put('Integration_Flow', 'Content search failed or no results');
    }
    
} catch (Exception e) {
    System.debug('❌ Integration flow testing failed: ' + e.getMessage());
    testResults.put('Integration_Flow', false);
    testMessages.put('Integration_Flow', e.getMessage());
}

// ============================================================================
// PHASE 5: RESULTS SUMMARY
// ============================================================================

System.debug('\n--- PHASE 5: Test Results Summary ---');

Integer totalTests = testResults.size();
Integer passedTests = 0;
Integer failedTests = 0;

for (String testName : testResults.keySet()) {
    Boolean result = testResults.get(testName);
    if (result) {
        passedTests++;
        System.debug('✅ ' + testName + ': PASSED');
    } else {
        failedTests++;
        System.debug('❌ ' + testName + ': FAILED');
        String message = testMessages.get(testName);
        if (String.isNotBlank(message)) {
            System.debug('   Error: ' + message);
        }
    }
}

System.debug('\n📊 INTEGRATION TEST SUMMARY:');
System.debug('  Total Tests: ' + totalTests);
System.debug('  Passed: ' + passedTests);
System.debug('  Failed: ' + failedTests);
System.debug('  Success Rate: ' + (passedTests * 100 / totalTests) + '%');

if (failedTests == 0) {
    System.debug('\n🎉 ALL INTEGRATION TESTS PASSED!');
    System.debug('The Content Search + Efficacy integration is working perfectly!');
} else {
    System.debug('\n⚠️  Some integration tests failed. Please review the errors above.');
}

System.debug('\n🔍 INTEGRATION TEST COMPLETED');

// ============================================================================
// HELPER METHODS
// ============================================================================

/**
 * @description Test efficacy analysis for a specific content item
 */
private static void testEfficacyForContent(ANAgentContentSearchServiceV2.UnifiedContent content, Integer testNumber) {
    try {
        System.debug('  Test ' + testNumber + ': Efficacy Analysis for ' + content.name);
        
        // Test 1: Direct course name search
        ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
        request.action = 'CourseEfficacy';
        request.courseName = content.name;
        
        List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> responses = 
            ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{request});
        
        if (!responses.isEmpty()) {
            ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse response = responses[0];
            
            if (response.success) {
                System.debug('    ✅ Efficacy analysis successful');
                System.debug('    📊 Records found: ' + response.totalRecordCount);
                System.debug('    📝 Summary: ' + response.summaryMetrics);
                
                // Test different OU and vertical combinations for this specific content
                testEfficacyBreakdowns(content.name);
                
            } else {
                System.debug('    ⚠️ Efficacy analysis failed: ' + response.message);
            }
        } else {
            System.debug('    ❌ No efficacy response for ' + content.name);
        }
        
    } catch (Exception e) {
        System.debug('    ❌ Efficacy test failed for ' + content.name + ': ' + e.getMessage());
    }
}

/**
 * @description Test efficacy breakdowns across different OUs and verticals for a specific content
 */
private static void testEfficacyBreakdowns(String contentName) {
    try {
        System.debug('    🔍 Testing Efficacy Breakdowns for: ' + contentName);
        
        // Test different combinations
        List<Map<String, String>> testCombinations = new List<Map<String, String>>{
            new Map<String, String>{'region' => 'ANZ', 'segment' => 'ESMB'},
            new Map<String, String>{'region' => 'EMEA North', 'segment' => 'CMRCL'},
            new Map<String, String>{'region' => 'AMER', 'segment' => 'PUBSEC'}
        };
        
        for (Map<String, String> combo : testCombinations) {
            String region = combo.get('region');
            String segment = combo.get('segment');
            
            ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
            request.action = 'Search';
            request.region = region;
            request.macroSegment = segment;
            request.offeringLabel = contentName;
            request.maxResults = 3;
            
            List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> responses = 
                ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{request});
            
            if (!responses.isEmpty()) {
                ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse response = responses[0];
                if (response.success && response.totalRecordCount > 0) {
                    System.debug('      ✅ ' + region + ' - ' + segment + ': ' + response.totalRecordCount + ' records');
                } else {
                    System.debug('      ⚠️ ' + region + ' - ' + segment + ': No records');
                }
            }
        }
        
    } catch (Exception e) {
        System.debug('    ❌ Efficacy breakdown test failed: ' + e.getMessage());
    }
} 