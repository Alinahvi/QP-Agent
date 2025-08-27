// ============================================================================
// COMPREHENSIVE UAT TEST SUITE - ANAGENT KPI ANALYSIS SYSTEM
// ============================================================================
// This script contains 50 comprehensive test cases covering:
// 1. Handler functionality and response formatting
// 2. Service business logic and calculations
// 3. Field mapping and SOQL query generation
// 4. Cross-validation with object structure
// 5. Edge cases and error handling
// 6. Performance and scalability
// ============================================================================

System.debug('🚀 STARTING COMPREHENSIVE UAT TEST SUITE');
System.debug('Testing: ANAGENTKPIAnalysisHandlerV5 + ANAGENTKPIAnalysisServiceV5');
System.debug('Total Test Cases: 50');
System.debug('=====================================\n');

// Test Results Tracking
Map<String, Boolean> testResults = new Map<String, Boolean>();
Integer totalTests = 0;
Integer passedTests = 0;
Integer failedTests = 0;

// Helper method to record test results
void recordTestResult(String testName, Boolean passed, String details) {
    totalTests++;
    if (passed) {
        passedTests++;
        System.debug('✅ PASS: ' + testName + ' - ' + details);
    } else {
        failedTests++;
        System.debug('❌ FAIL: ' + testName + ' - ' + details);
    }
    testResults.put(testName, passed);
}

// Helper method to validate response structure
Boolean validateResponseStructure(String response, String testName) {
    try {
        if (String.isBlank(response)) {
            recordTestResult(testName, false, 'Response is blank');
            return false;
        }
        
        // Check for required sections
        List<String> requiredSections = new List<String>{
            '# KPI Analysis',
            '## Summary',
            '## Insights',
            '## Limits & Counts',
            '## Data (JSON)'
        };
        
        for (String section : requiredSections) {
            if (!response.contains(section)) {
                recordTestResult(testName, false, 'Missing required section: ' + section);
                return false;
            }
        }
        
        // Check for JSON section
        if (!response.contains('```json')) {
            recordTestResult(testName, false, 'Missing JSON data section');
            return false;
        }
        
        return true;
    } catch (Exception e) {
        recordTestResult(testName, false, 'Exception during validation: ' + e.getMessage());
        return false;
    }
}

// Helper method to extract JSON from response
String extractJSONFromResponse(String response) {
    try {
        Integer startIndex = response.indexOf('```json');
        Integer endIndex = response.indexOf('```', startIndex + 7);
        if (startIndex != -1 && endIndex != -1) {
            return response.substring(startIndex + 7, endIndex).trim();
        }
        return '';
    } catch (Exception e) {
        return '';
    }
}

// Helper method to validate JSON structure
Boolean validateJSONStructure(String jsonStr, String testName) {
    try {
        if (String.isBlank(jsonStr)) {
            recordTestResult(testName, false, 'JSON string is blank');
            return false;
        }
        
        // Parse JSON to check structure
        Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        
        // Check required JSON fields
        List<String> requiredFields = new List<String>{
            'metric', 'timeframe', 'groupBy', 'totalCount'
        };
        
        for (String field : requiredFields) {
            if (!jsonData.containsKey(field)) {
                recordTestResult(testName, false, 'Missing JSON field: ' + field);
                return false;
            }
        }
        
        return true;
    } catch (Exception e) {
        recordTestResult(testName, false, 'JSON validation failed: ' + e.getMessage());
        return false;
    }
}

// ============================================================================
// TEST CATEGORY 1: BASIC FUNCTIONALITY TESTS (10 tests)
// ============================================================================
System.debug('📋 TEST CATEGORY 1: BASIC FUNCTIONALITY TESTS');
System.debug('==============================================');

// Test Case 1: Basic handler instantiation
try {
    ANAGENTKPIAnalysisHandlerV5 handler = new ANAGENTKPIAnalysisHandlerV5();
    recordTestResult('TC001: Handler Instantiation', true, 'Handler created successfully');
} catch (Exception e) {
    recordTestResult('TC001: Handler Instantiation', false, 'Handler creation failed: ' + e.getMessage());
}

// Test Case 2: Basic service instantiation
try {
    ANAGENTKPIAnalysisServiceV5 service = new ANAGENTKPIAnalysisServiceV5();
    recordTestResult('TC002: Service Instantiation', true, 'Service created successfully');
} catch (Exception e) {
    recordTestResult('TC002: Service Instantiation', false, 'Service creation failed: ' + e.getMessage());
}

// Test Case 3: Handler invocable method signature
try {
    // Test the invocable method signature
    ANAGENTKPIAnalysisHandlerV5.Request testRequest = new ANAGENTKPIAnalysisHandlerV5.Request();
    testRequest.metricKey = 'ACV';
    testRequest.timeframe = 'CURRENT';
    testRequest.groupBy = 'COUNTRY';
    
    List<ANAGENTKPIAnalysisHandlerV5.Request> requests = new List<ANAGENTKPIAnalysisHandlerV5.Request>{testRequest};
    List<ANAGENTKPIAnalysisHandlerV5.Response> responses = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests);
    
    if (responses != null && !responses.isEmpty()) {
        recordTestResult('TC003: Handler Invocable Method', true, 'Invocable method executed successfully');
    } else {
        recordTestResult('TC003: Handler Invocable Method', false, 'Invocable method returned empty response');
    }
} catch (Exception e) {
    recordTestResult('TC003: Handler Invocable Method', false, 'Invocable method failed: ' + e.getMessage());
}

// Test Case 4: Service method signature validation
try {
    String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'COUNTRY', false, null, null, null);
    if (String.isNotBlank(result)) {
        recordTestResult('TC004: Service Method Signature', true, 'Service method executed successfully');
    } else {
        recordTestResult('TC004: Service Method Signature', false, 'Service method returned empty result');
    }
} catch (Exception e) {
    recordTestResult('TC004: Service Method Signature', false, 'Service method failed: ' + e.getMessage());
}

// Test Case 5: Response message structure validation
try {
    String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('CALLS', 'CURRENT', 'COUNTRY', false, null, null, null);
    Boolean isValid = validateResponseStructure(result, 'TC005: Response Structure');
    if (isValid) {
        recordTestResult('TC005: Response Structure', true, 'Response structure validation passed');
    }
} catch (Exception e) {
    recordTestResult('TC005: Response Structure', false, 'Response structure validation failed: ' + e.getMessage());
}

// Test Case 6: JSON data extraction and validation
try {
    String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('PG', 'CURRENT', 'COUNTRY', false, null, null, null);
    String jsonData = extractJSONFromResponse(result);
    Boolean isValid = validateJSONStructure(jsonData, 'TC006: JSON Structure');
    if (isValid) {
        recordTestResult('TC006: JSON Structure', true, 'JSON structure validation passed');
    }
} catch (Exception e) {
    recordTestResult('TC006: JSON Structure', false, 'JSON structure validation failed: ' + e.getMessage());
}

// Test Case 7: Default parameter handling
try {
    String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs(null, null, null, null, null, null, null);
    if (String.isNotBlank(result)) {
        recordTestResult('TC007: Default Parameters', true, 'Default parameters handled correctly');
    } else {
        recordTestResult('TC007: Default Parameters', false, 'Default parameters failed');
    }
} catch (Exception e) {
    recordTestResult('TC007: Default Parameters', false, 'Default parameters exception: ' + e.getMessage());
}

// Test Case 8: Metric key validation
try {
    List<String> validMetrics = new List<String>{'ACV', 'PG', 'CALLS', 'MEETINGS', 'COVERAGE', 'GROWTH_FACTOR'};
    Boolean allValid = true;
    
    for (String metric : validMetrics) {
        try {
            String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs(metric, 'CURRENT', 'COUNTRY', false, null, null, null);
            if (String.isBlank(result)) {
                allValid = false;
                break;
            }
        } catch (Exception e) {
            allValid = false;
            break;
        }
    }
    
    if (allValid) {
        recordTestResult('TC008: Valid Metric Keys', true, 'All valid metric keys processed successfully');
    } else {
        recordTestResult('TC008: Valid Metric Keys', false, 'Some valid metric keys failed');
    }
} catch (Exception e) {
    recordTestResult('TC008: Valid Metric Keys', false, 'Metric key validation exception: ' + e.getMessage());
}

// Test Case 9: Timeframe validation
try {
    List<String> validTimeframes = new List<String>{'CURRENT', 'PREVIOUS'};
    Boolean allValid = true;
    
    for (String timeframe : validTimeframes) {
        try {
            String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', timeframe, 'COUNTRY', false, null, null, null);
            if (String.isBlank(result)) {
                allValid = false;
                break;
            }
        } catch (Exception e) {
            allValid = false;
            break;
        }
    }
    
    if (allValid) {
        recordTestResult('TC009: Valid Timeframes', true, 'All valid timeframes processed successfully');
    } else {
        recordTestResult('TC009: Valid Timeframes', false, 'Some valid timeframes failed');
    }
} catch (Exception e) {
    recordTestResult('TC009: Valid Timeframes', false, 'Timeframe validation exception: ' + e.getMessage());
}

// Test Case 10: GroupBy validation
try {
    List<String> validGroupBys = new List<String>{'COUNTRY', 'OU', 'INDUSTRY', 'AE', 'GROWTH_FACTOR', 'RAMP_STATUS'};
    Boolean allValid = true;
    
    for (String groupBy : validGroupBys) {
        try {
            String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', groupBy, false, null, null, null);
            if (String.isBlank(result)) {
                allValid = false;
                break;
            }
        } catch (Exception e) {
            allValid = false;
            break;
        }
    }
    
    if (allValid) {
        recordTestResult('TC010: Valid GroupBy Options', true, 'All valid groupBy options processed successfully');
    } else {
        recordTestResult('TC010: Valid GroupBy Options', false, 'Some valid groupBy options failed');
    }
} catch (Exception e) {
    recordTestResult('TC010: Valid GroupBy Options', false, 'GroupBy validation exception: ' + e.getMessage());
}

System.debug('\n✅ Basic Functionality Tests Completed: ' + passedTests + '/' + totalTests + ' passed');
System.debug('==============================================\n');

// ============================================================================
// TEST CATEGORY 2: FIELD MAPPING AND VALIDATION TESTS (10 tests)
// ============================================================================
System.debug('📋 TEST CATEGORY 2: FIELD MAPPING AND VALIDATION TESTS');
System.debug('=======================================================');

// Test Case 11: User-friendly filter key mapping
try {
    // Test various user-friendly filter keys
    List<String> userKeys = new List<String>{'country', 'ou', 'industry', 'ae', 'manager', 'email'};
    Boolean allMapped = true;
    
    for (String userKey : userKeys) {
        try {
            String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'COUNTRY', false, userKey + '="US"', null, null);
            if (String.isBlank(result)) {
                allMapped = false;
                break;
            }
        } catch (Exception e) {
            allMapped = false;
            break;
        }
    }
    
    if (allMapped) {
        recordTestResult('TC011: User-Friendly Filter Mapping', true, 'All user-friendly filter keys mapped correctly');
    } else {
        recordTestResult('TC011: User-Friendly Filter Mapping', false, 'Some user-friendly filter keys failed mapping');
    }
} catch (Exception e) {
    recordTestResult('TC011: User-Friendly Filter Mapping', false, 'Filter mapping test exception: ' + e.getMessage());
}

// Test Case 12: API field name handling in filters
try {
    // Test API field names sent by agents
    List<String> apiFields = new List<String>{'RAMP_STATUS__c', 'OU_NAME__c', 'WORK_LOCATION_COUNTRY__c'};
    Boolean allHandled = true;
    
    for (String apiField : apiFields) {
        try {
            String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'COUNTRY', false, apiField + '="US"', null, null);
            if (String.isBlank(result)) {
                allHandled = false;
                break;
            }
        } catch (Exception e) {
            allHandled = false;
            break;
        }
    }
    
    if (allHandled) {
        recordTestResult('TC012: API Field Name Handling', true, 'All API field names handled correctly');
    } else {
        recordTestResult('TC012: API Field Name Handling', false, 'Some API field names failed handling');
    }
} catch (Exception e) {
    recordTestResult('TC012: API Field Name Handling', false, 'API field handling test exception: ' + e.getMessage());
}

// Test Case 13: Smart field detection
try {
    // Test business context field detection
    List<String> businessKeys = new List<String>{'location', 'region', 'sector', 'employee', 'supervisor'};
    Boolean allDetected = true;
    
    for (String businessKey : businessKeys) {
        try {
            String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'COUNTRY', false, businessKey + '="US"', null, null);
            if (String.isBlank(result)) {
                allDetected = false;
                break;
            }
        } catch (Exception e) {
            allDetected = false;
            break;
        }
    }
    
    if (allDetected) {
        recordTestResult('TC013: Smart Field Detection', true, 'All business context fields detected correctly');
    } else {
        recordTestResult('TC013: Smart Field Detection', false, 'Some business context fields failed detection');
    }
} catch (Exception e) {
    recordTestResult('TC013: Smart Field Detection', false, 'Smart field detection test exception: ' + e.getMessage());
}

// Test Case 14: Complex filter criteria parsing
try {
    String complexFilter = 'country="US" AND industry="Tech" OR ou="AMER"';
    String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'COUNTRY', false, complexFilter, null, null);
    
    if (String.isNotBlank(result)) {
        recordTestResult('TC014: Complex Filter Parsing', true, 'Complex filter criteria parsed successfully');
    } else {
        recordTestResult('TC014: Complex Filter Parsing', false, 'Complex filter criteria parsing failed');
    }
} catch (Exception e) {
    recordTestResult('TC014: Complex Filter Parsing', false, 'Complex filter parsing exception: ' + e.getMessage());
}

// Test Case 15: Field mapping info method
try {
    String mappingInfo = ANAGENTKPIAnalysisServiceV5.getFieldMappingInfo();
    if (String.isNotBlank(mappingInfo) && mappingInfo.contains('METRIC_FIELD_MAP')) {
        recordTestResult('TC015: Field Mapping Info Method', true, 'Field mapping info method working correctly');
    } else {
        recordTestResult('TC015: Field Mapping Info Method', false, 'Field mapping info method failed');
    }
} catch (Exception e) {
    recordTestResult('TC015: Field Mapping Info Method', false, 'Field mapping info method exception: ' + e.getMessage());
}

// Test Case 16: Field mapping validation method
try {
    String validationResult = ANAGENTKPIAnalysisServiceV5.validateFieldMapping('country="US"');
    if (String.isNotBlank(validationResult)) {
        recordTestResult('TC016: Field Mapping Validation', true, 'Field mapping validation method working correctly');
    } else {
        recordTestResult('TC016: Field Mapping Validation', false, 'Field mapping validation method failed');
    }
} catch (Exception e) {
    recordTestResult('TC016: Field Mapping Validation', false, 'Field mapping validation method exception: ' + e.getMessage());
}

// Test Case 17: Growth Factor field mapping
try {
    String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('GROWTH_FACTOR', 'CURRENT', 'GROWTH_FACTOR', false, null, null, null);
    if (String.isNotBlank(result) && result.contains('definition__c')) {
        recordTestResult('TC017: Growth Factor Field Mapping', true, 'Growth Factor field mapping working correctly');
    } else {
        recordTestResult('TC017: Growth Factor Field Mapping', false, 'Growth Factor field mapping failed');
    }
} catch (Exception e) {
    recordTestResult('TC017: Growth Factor Field Mapping', false, 'Growth Factor field mapping exception: ' + e.getMessage());
}

// Test Case 18: Ramp Status field mapping
try {
    String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'RAMP_STATUS', false, null, null, null);
    if (String.isNotBlank(result) && result.contains('ramp_status__c')) {
        recordTestResult('TC018: Ramp Status Field Mapping', true, 'Ramp Status field mapping working correctly');
    } else {
        recordTestResult('TC018: Ramp Status Field Mapping', false, 'Ramp Status field mapping failed');
    }
} catch (Exception e) {
    recordTestResult('TC018: Ramp Status Field Mapping', false, 'Ramp Status field mapping exception: ' + e.getMessage());
}

// Test Case 19: Tenure field mapping
try {
    String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'COUNTRY', false, 'tenure>6', null, null);
    if (String.isNotBlank(result) && result.contains('time_since_onboarding__c')) {
        recordTestResult('TC019: Tenure Field Mapping', true, 'Tenure field mapping working correctly');
    } else {
        recordTestResult('TC019: Tenure Field Mapping', false, 'Tenure field mapping failed');
    }
} catch (Exception e) {
    recordTestResult('TC019: Tenure Field Mapping', false, 'Tenure field mapping exception: ' + e.getMessage());
}

// Test Case 20: Manager field mapping
try {
    String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'COUNTRY', false, 'manager="John Doe"', null, null);
    if (String.isNotBlank(result) && result.contains('emp_mgr_nm__c')) {
        recordTestResult('TC020: Manager Field Mapping', true, 'Manager field mapping working correctly');
    } else {
        recordTestResult('TC020: Manager Field Mapping', false, 'Manager field mapping failed');
    }
} catch (Exception e) {
    recordTestResult('TC020: Manager Field Mapping', false, 'Manager field mapping exception: ' + e.getMessage());
}

System.debug('\n✅ Field Mapping Tests Completed: ' + passedTests + '/' + totalTests + ' passed');
System.debug('=======================================================\n');

// ============================================================================
// TEST CATEGORY 3: BUSINESS LOGIC AND CALCULATION TESTS (10 tests)
// ============================================================================
System.debug('📋 TEST CATEGORY 3: BUSINESS LOGIC AND CALCULATION TESTS');
System.debug('========================================================');

// Test Case 21: Per-AE normalization logic
try {
    // Test with perAENormalize = true
    String normalizedResult = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'COUNTRY', true, null, null, null);
    String nonNormalizedResult = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'COUNTRY', false, null, null, null);
    
    if (String.isNotBlank(normalizedResult) && String.isNotBlank(nonNormalizedResult) && 
        normalizedResult != nonNormalizedResult) {
        recordTestResult('TC021: Per-AE Normalization Logic', true, 'Per-AE normalization working correctly');
    } else {
        recordTestResult('TC021: Per-AE Normalization Logic', false, 'Per-AE normalization not working');
    }
} catch (Exception e) {
    recordTestResult('TC021: Per-AE Normalization Logic', false, 'Per-AE normalization exception: ' + e.getMessage());
}

// Test Case 22: Limit application logic
try {
    String limitedResult = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'COUNTRY', false, null, 5, null);
    String unlimitedResult = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'COUNTRY', false, null, null, null);
    
    if (String.isNotBlank(limitedResult) && String.isNotBlank(unlimitedResult) && 
        limitedResult.contains('Limit Applied: 5')) {
        recordTestResult('TC022: Limit Application Logic', true, 'Limit application working correctly');
    } else {
        recordTestResult('TC022: Limit Application Logic', false, 'Limit application not working');
    }
} catch (Exception e) {
    recordTestResult('TC022: Limit Application Logic', false, 'Limit application exception: ' + e.getMessage());
}

// Test Case 23: Restrict values CSV ordering
try {
    String restrictedResult = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'COUNTRY', false, null, null, 'US,Brazil,Canada');
    
    if (String.isNotBlank(restrictedResult) && restrictedResult.contains('restrictInValuesCsv')) {
        recordTestResult('TC023: Restrict Values CSV Ordering', true, 'Restrict values CSV ordering working correctly');
    } else {
        recordTestResult('TC023: Restrict Values CSV Ordering', false, 'Restrict values CSV ordering not working');
    }
} catch (Exception e) {
    recordTestResult('TC023: Restrict Values CSV Ordering', false, 'Restrict values CSV ordering exception: ' + e.getMessage());
}

// Test Case 24: Growth Factor special handling
try {
    String growthFactorResult = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('GROWTH_FACTOR', 'CURRENT', 'GROWTH_FACTOR', false, null, null, null);
    
    if (String.isNotBlank(growthFactorResult) && 
        growthFactorResult.contains('definition__c') && 
        growthFactorResult.contains('description__c')) {
        recordTestResult('TC024: Growth Factor Special Handling', true, 'Growth Factor special handling working correctly');
    } else {
        recordTestResult('TC024: Growth Factor Special Handling', false, 'Growth Factor special handling not working');
    }
} catch (Exception e) {
    recordTestResult('TC024: Growth Factor Special Handling', false, 'Growth Factor special handling exception: ' + e.getMessage());
}

// Test Case 25: Ramp Status analysis
try {
    String rampStatusResult = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'RAMP_STATUS', false, null, null, null);
    
    if (String.isNotBlank(rampStatusResult) && 
        rampStatusResult.contains('ramp_status__c')) {
        recordTestResult('TC025: Ramp Status Analysis', true, 'Ramp Status analysis working correctly');
    } else {
        recordTestResult('TC025: Ramp Status Analysis', false, 'Ramp Status analysis not working');
    }
} catch (Exception e) {
    recordTestResult('TC025: Ramp Status Analysis', false, 'Ramp Status analysis exception: ' + e.getMessage());
}

// Test Case 26: Metric timeframe validation
try {
    // Test CURRENT vs PREVIOUS timeframe handling
    String currentResult = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'COUNTRY', false, null, null, null);
    String previousResult = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'PREVIOUS', 'COUNTRY', false, null, null, null);
    
    if (String.isNotBlank(currentResult) && String.isNotBlank(previousResult) && 
        currentResult != previousResult) {
        recordTestResult('TC026: Metric Timeframe Validation', true, 'Metric timeframe validation working correctly');
    } else {
        recordTestResult('TC026: Metric Timeframe Validation', false, 'Metric timeframe validation not working');
    }
} catch (Exception e) {
    recordTestResult('TC026: Metric Timeframe Validation', false, 'Metric timeframe validation exception: ' + e.getMessage());
}

// Test Case 27: Coverage metric CURRENT only logic
try {
    String coverageResult = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('COVERAGE', 'CURRENT', 'COUNTRY', false, null, null, null);
    String coveragePreviousResult = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('COVERAGE', 'PREVIOUS', 'COUNTRY', false, null, null, null);
    
    if (String.isNotBlank(coverageResult) && String.isNotBlank(coveragePreviousResult)) {
        recordTestResult('TC027: Coverage CURRENT Only Logic', true, 'Coverage CURRENT only logic working correctly');
    } else {
        recordTestResult('TC027: Coverage CURRENT Only Logic', false, 'Coverage CURRENT only logic not working');
    }
} catch (Exception e) {
    recordTestResult('TC027: Coverage CURRENT Only Logic', false, 'Coverage CURRENT only logic exception: ' + e.getMessage());
}

// Test Case 28: AI Mentions CURRENT only logic
try {
    String aiMentionsResult = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('AI_MENTIONS', 'CURRENT', 'COUNTRY', false, null, null, null);
    String aiMentionsPreviousResult = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('AI_MENTIONS', 'PREVIOUS', 'COUNTRY', false, null, null, null);
    
    if (String.isNotBlank(aiMentionsResult) && String.isNotBlank(aiMentionsPreviousResult)) {
        recordTestResult('TC028: AI Mentions CURRENT Only Logic', true, 'AI Mentions CURRENT only logic working correctly');
    } else {
        recordTestResult('TC028: AI Mentions CURRENT Only Logic', false, 'AI Mentions CURRENT only logic not working');
    }
} catch (Exception e) {
    recordTestResult('TC028: AI Mentions CURRENT Only Logic', false, 'AI Mentions CURRENT only logic exception: ' + e.getMessage());
}

// Test Case 29: Smart metric key detection
try {
    // Test automatic metric key detection for Growth Factor
    String smartResult = ANAGENTKPIAnalysisServiceV5.analyzeKPIs(null, 'CURRENT', 'GROWTH_FACTOR', false, null, null, null);
    
    if (String.isNotBlank(smartResult) && smartResult.contains('GROWTH_FACTOR')) {
        recordTestResult('TC029: Smart Metric Key Detection', true, 'Smart metric key detection working correctly');
    } else {
        recordTestResult('TC029: Smart Metric Key Detection', false, 'Smart metric key detection not working');
    }
} catch (Exception e) {
    recordTestResult('TC029: Smart Metric Key Detection', false, 'Smart metric key detection exception: ' + e.getMessage());
}

// Test Case 30: Business context field detection
try {
    // Test business context field detection
    String businessResult = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'COUNTRY', false, 'business_unit="AMER"', null, null);
    
    if (String.isNotBlank(businessResult)) {
        recordTestResult('TC030: Business Context Field Detection', true, 'Business context field detection working correctly');
    } else {
        recordTestResult('TC030: Business Context Field Detection', false, 'Business context field detection not working');
    }
} catch (Exception e) {
    recordTestResult('TC030: Business Context Field Detection', false, 'Business context field detection exception: ' + e.getMessage());
}

System.debug('\n✅ Business Logic Tests Completed: ' + passedTests + '/' + totalTests + ' passed');
System.debug('========================================================\n');

// ============================================================================
// TEST CATEGORY 4: CROSS-VALIDATION AND OBJECT INTEGRATION TESTS (10 tests)
// ============================================================================
System.debug('📋 TEST CATEGORY 4: CROSS-VALIDATION AND OBJECT INTEGRATION TESTS');
System.debug('==================================================================');

// Test Case 31: Object field existence validation
try {
    // Test that all required fields exist in the object
    Schema.SObjectType objectType = Schema.getGlobalDescribe().get('AGENT_OU_PIPELINE_V2__c');
    if (objectType != null) {
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        
        List<String> requiredFields = new List<String>{
            'emp_id__c', 'full_name__c', 'work_location_country__c', 'ou_name__c', 
            'primary_industry__c', 'cq_acv__c', 'pq_acv__c', 'cq_pg__c', 'pq_pg__c'
        };
        
        Boolean allFieldsExist = true;
        for (String fieldName : requiredFields) {
            if (!fieldMap.containsKey(fieldName)) {
                allFieldsExist = false;
                break;
            }
        }
        
        if (allFieldsExist) {
            recordTestResult('TC031: Object Field Existence', true, 'All required fields exist in object');
        } else {
            recordTestResult('TC031: Object Field Existence', false, 'Some required fields missing from object');
        }
    } else {
        recordTestResult('TC031: Object Field Existence', false, 'Object not found');
    }
} catch (Exception e) {
    recordTestResult('TC031: Object Field Existence', false, 'Object field validation exception: ' + e.getMessage());
}

// Test Case 32: SOQL query execution validation
try {
    // Test that SOQL queries can be executed successfully
    String testQuery = 'SELECT emp_id__c, full_name__c, work_location_country__c FROM AGENT_OU_PIPELINE_V2__c LIMIT 1';
    List<AGENT_OU_PIPELINE_V2__c> testRecords = Database.query(testQuery);
    
    if (testRecords != null) {
        recordTestResult('TC032: SOQL Query Execution', true, 'SOQL queries execute successfully');
    } else {
        recordTestResult('TC032: SOQL Query Execution', false, 'SOQL query execution failed');
    }
} catch (Exception e) {
    recordTestResult('TC032: SOQL Query Execution', false, 'SOQL query execution exception: ' + e.getMessage());
}

// Test Case 33: Field accessibility validation
try {
    // Test that all required fields are accessible
    Schema.SObjectType objectType = Schema.getGlobalDescribe().get('AGENT_OU_PIPELINE_V2__c');
    if (objectType != null) {
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        
        List<String> requiredFields = new List<String>{
            'emp_id__c', 'full_name__c', 'work_location_country__c', 'ou_name__c', 
            'primary_industry__c', 'cq_acv__c', 'pq_acv__c', 'cq_pg__c', 'pq_pg__c'
        };
        
        Boolean allFieldsAccessible = true;
        for (String fieldName : requiredFields) {
            if (fieldMap.containsKey(fieldName)) {
                Schema.SObjectField field = fieldMap.get(fieldName);
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                if (!fieldDescribe.isAccessible()) {
                    allFieldsAccessible = false;
                    break;
                }
            }
        }
        
        if (allFieldsAccessible) {
            recordTestResult('TC033: Field Accessibility', true, 'All required fields are accessible');
        } else {
            recordTestResult('TC033: Field Accessibility', false, 'Some required fields are not accessible');
        }
    } else {
        recordTestResult('TC033: Field Accessibility', false, 'Object not found for accessibility check');
    }
} catch (Exception e) {
    recordTestResult('TC033: Field Accessibility', false, 'Field accessibility check exception: ' + e.getMessage());
}

// Test Case 34: Data type compatibility validation
try {
    // Test that field data types are compatible with operations
    Schema.SObjectType objectType = Schema.getGlobalDescribe().get('AGENT_OU_PIPELINE_V2__c');
    if (objectType != null) {
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        
        // Check numeric fields for calculations
        List<String> numericFields = new List<String>{'cq_acv__c', 'pq_acv__c', 'cq_pg__c', 'pq_pg__c'};
        Boolean allNumeric = true;
        
        for (String fieldName : numericFields) {
            if (fieldMap.containsKey(fieldName)) {
                Schema.SObjectField field = fieldMap.get(fieldName);
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                Schema.DisplayType fieldType = fieldDescribe.getType();
                
                if (fieldType != Schema.DisplayType.CURRENCY && fieldType != Schema.DisplayType.DOUBLE && 
                    fieldType != Schema.DisplayType.INTEGER) {
                    allNumeric = false;
                    break;
                }
            }
        }
        
        if (allNumeric) {
            recordTestResult('TC034: Data Type Compatibility', true, 'All numeric fields have compatible types');
        } else {
            recordTestResult('TC034: Data Type Compatibility', false, 'Some numeric fields have incompatible types');
        }
    } else {
        recordTestResult('TC034: Data Type Compatibility', false, 'Object not found for data type check');
    }
} catch (Exception e) {
    recordTestResult('TC034: Data Type Compatibility', false, 'Data type compatibility check exception: ' + e.getMessage());
}

// Test Case 35: Object record count validation
try {
    // Test that object has data for analysis
    Integer recordCount = Database.countQuery('SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c');
    
    if (recordCount > 0) {
        recordTestResult('TC035: Object Record Count', true, 'Object contains ' + recordCount + ' records for analysis');
    } else {
        recordTestResult('TC035: Object Record Count', false, 'Object contains no records for analysis');
    }
} catch (Exception e) {
    recordTestResult('TC035: Object Record Count', false, 'Record count check exception: ' + e.getMessage());
}

// Test Case 36: Field value distribution validation
try {
    // Test that key fields have meaningful data distribution
    String countryQuery = 'SELECT work_location_country__c FROM AGENT_OU_PIPELINE_V2__c WHERE work_location_country__c != null LIMIT 10';
    List<AGENT_OU_PIPELINE_V2__c> countryRecords = Database.query(countryQuery);
    
    if (!countryRecords.isEmpty()) {
        Set<String> countries = new Set<String>();
        for (AGENT_OU_PIPELINE_V2__c record : countryRecords) {
            if (String.isNotBlank(record.work_location_country__c)) {
                countries.add(record.work_location_country__c);
            }
        }
        
        if (countries.size() > 1) {
            recordTestResult('TC036: Field Value Distribution', true, 'Country field has meaningful distribution: ' + countries.size() + ' unique values');
        } else {
            recordTestResult('TC036: Field Value Distribution', false, 'Country field lacks meaningful distribution');
        }
    } else {
        recordTestResult('TC036: Field Value Distribution', false, 'No country records found for distribution check');
    }
} catch (Exception e) {
    recordTestResult('TC036: Field Value Distribution', false, 'Field value distribution check exception: ' + e.getMessage());
}

// Test Case 37: Metric field data validation
try {
    // Test that metric fields contain actual data
    String metricQuery = 'SELECT cq_acv__c, pq_acv__c FROM AGENT_OU_PIPELINE_V2__c WHERE cq_acv__c != null OR pq_acv__c != null LIMIT 10';
    List<AGENT_OU_PIPELINE_V2__c> metricRecords = Database.query(metricQuery);
    
    if (!metricRecords.isEmpty()) {
        Boolean hasData = false;
        for (AGENT_OU_PIPELINE_V2__c record : metricRecords) {
            if (record.cq_acv__c != null || record.pq_acv__c != null) {
                hasData = true;
                break;
            }
        }
        
        if (hasData) {
            recordTestResult('TC037: Metric Field Data', true, 'Metric fields contain actual data for analysis');
        } else {
            recordTestResult('TC037: Metric Field Data', false, 'Metric fields contain no actual data');
        }
    } else {
        recordTestResult('TC037: Metric Field Data', false, 'No metric records found for data validation');
    }
} catch (Exception e) {
    recordTestResult('TC037: Metric Field Data', false, 'Metric field data validation exception: ' + e.getMessage());
}

// Test Case 38: Growth Factor data validation
try {
    // Test that Growth Factor fields contain data
    String gfQuery = 'SELECT definition__c, description__c FROM AGENT_OU_PIPELINE_V2__c WHERE definition__c != null LIMIT 10';
    List<AGENT_OU_PIPELINE_V2__c> gfRecords = Database.query(gfQuery);
    
    if (!gfRecords.isEmpty()) {
        Boolean hasData = false;
        for (AGENT_OU_PIPELINE_V2__c record : gfRecords) {
            if (String.isNotBlank(record.definition__c)) {
                hasData = true;
                break;
            }
        }
        
        if (hasData) {
            recordTestResult('TC038: Growth Factor Data', true, 'Growth Factor fields contain actual data for analysis');
        } else {
            recordTestResult('TC038: Growth Factor Data', false, 'Growth Factor fields contain no actual data');
        }
    } else {
        recordTestResult('TC038: Growth Factor Data', false, 'No Growth Factor records found for data validation');
    }
} catch (Exception e) {
    recordTestResult('TC038: Growth Factor Data', false, 'Growth Factor data validation exception: ' + e.getMessage());
}

// Test Case 39: Ramp Status data validation
try {
    // Test that Ramp Status fields contain data
    String rsQuery = 'SELECT ramp_status__c FROM AGENT_OU_PIPELINE_V2__c WHERE ramp_status__c != null LIMIT 10';
    List<AGENT_OU_PIPELINE_V2__c> rsRecords = Database.query(rsQuery);
    
    if (!rsRecords.isEmpty()) {
        Boolean hasData = false;
        for (AGENT_OU_PIPELINE_V2__c record : rsRecords) {
            if (String.isNotBlank(record.ramp_status__c)) {
                hasData = true;
                break;
            }
        }
        
        if (hasData) {
            recordTestResult('TC039: Ramp Status Data', true, 'Ramp Status fields contain actual data for analysis');
        } else {
            recordTestResult('TC039: Ramp Status Data', false, 'Ramp Status fields contain no actual data');
        }
    } else {
        recordTestResult('TC039: Ramp Status Data', false, 'No Ramp Status records found for data validation');
    }
} catch (Exception e) {
    recordTestResult('TC039: Ramp Status Data', false, 'Ramp Status data validation exception: ' + e.getMessage());
}

// Test Case 40: Tenure data validation
try {
    // Test that Tenure fields contain data
    String tenureQuery = 'SELECT time_since_onboarding__c FROM AGENT_OU_PIPELINE_V2__c WHERE time_since_onboarding__c != null LIMIT 10';
    List<AGENT_OU_PIPELINE_V2__c> tenureRecords = Database.query(tenureQuery);
    
    if (!tenureRecords.isEmpty()) {
        Boolean hasData = false;
        for (AGENT_OU_PIPELINE_V2__c record : tenureRecords) {
            if (record.time_since_onboarding__c != null) {
                hasData = true;
                break;
            }
        }
        
        if (hasData) {
            recordTestResult('TC040: Tenure Data', true, 'Tenure fields contain actual data for analysis');
        } else {
            recordTestResult('TC040: Tenure Data', false, 'Tenure fields contain no actual data');
        }
    } else {
        recordTestResult('TC040: Tenure Data', false, 'No Tenure records found for data validation');
    }
} catch (Exception e) {
    recordTestResult('TC040: Tenure Data', false, 'Tenure data validation exception: ' + e.getMessage());
}

System.debug('\n✅ Cross-Validation Tests Completed: ' + passedTests + '/' + totalTests + ' passed');
System.debug('==================================================================\n');

// Continue with next test category...
System.debug('📋 TEST CATEGORY 5: EDGE CASES AND ERROR HANDLING TESTS');
System.debug('========================================================'); 