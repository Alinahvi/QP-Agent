// Production Validation Test Script for Offering Efficacy System
// Run this in Developer Console or via SFDX after deployment
// This script validates the complete system in a production environment

System.debug('🧪 PRODUCTION VALIDATION TEST STARTING');
System.debug('=====================================');

// Test Configuration
Boolean runAllTests = true;
Boolean testBatchProcessing = true;
Boolean testCourseLinking = true;
Boolean testPerformance = true;
Boolean testErrorScenarios = true;

// Test Results Tracking
Map<String, Boolean> testResults = new Map<String, Boolean>();
Map<String, String> testMessages = new Map<String, String>();

// ============================================================================
// PHASE 1: BASIC FUNCTIONALITY VALIDATION
// ============================================================================

System.debug('\n--- PHASE 1: Basic Functionality Validation ---');

// Test 1: Handler Instantiation
try {
    System.debug('Testing Handler Instantiation...');
    ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest();
    request.action = 'Search';
    request.programType = 'Fast Start';
    
    System.debug('✅ Handler instantiation successful');
    testResults.put('Handler_Instantiation', true);
} catch (Exception e) {
    System.debug('❌ Handler instantiation failed: ' + e.getMessage());
    testResults.put('Handler_Instantiation', false);
    testMessages.put('Handler_Instantiation', e.getMessage());
}

// Test 2: Service Instantiation
try {
    System.debug('Testing Service Instantiation...');
    ANAgentOfferingEfficacyService.EfficacySearchResult result = new ANAgentOfferingEfficacyService.EfficacySearchResult();
    
    System.debug('✅ Service instantiation successful');
    testResults.put('Service_Instantiation', true);
} catch (Exception e) {
    System.debug('❌ Service instantiation failed: ' + e.getMessage());
    testResults.put('Service_Instantiation', false);
    testMessages.put('Service_Instantiation', e.getMessage());
}

// Test 3: Batch Service Instantiation
try {
    System.debug('Testing Batch Service Instantiation...');
    ANAgentOfferingEfficacyBatchService batchService = new ANAgentOfferingEfficacyBatchService(
        'Test', 'Fast Start', 'ANZ', 'ESMB', '2024-Q1', 'PIPE_QUALITY', 'ALL', 'analyze'
    );
    
    System.debug('✅ Batch service instantiation successful');
    testResults.put('BatchService_Instantiation', true);
} catch (Exception e) {
    System.debug('❌ Batch service instantiation failed: ' + e.getMessage());
    testResults.put('BatchService_Instantiation', false);
    testMessages.put('BatchService_Instantiation', e.getMessage());
}

// ============================================================================
// PHASE 2: DATA ACCESS VALIDATION
// ============================================================================

System.debug('\n--- PHASE 2: Data Access Validation ---');

// Test 4: Check if apm_outcome_v2__c object exists and has data
try {
    System.debug('Testing apm_outcome_v2__c object access...');
    
    // Check object existence
    Schema.SObjectType outcomeType = Schema.getGlobalDescribe().get('apm_outcome_v2__c');
    if (outcomeType != null) {
        System.debug('✅ apm_outcome_v2__c object exists');
        
        // Check record count
        Integer recordCount = Database.countQuery('SELECT COUNT() FROM apm_outcome_v2__c WHERE IsDeleted = false');
        System.debug('📊 Total apm_outcome_v2__c records: ' + recordCount);
        
        if (recordCount > 0) {
            System.debug('✅ apm_outcome_v2__c has data');
            testResults.put('Data_Access', true);
            
            // Sample data structure
            List<apm_outcome_v2__c> sampleRecords = [
                SELECT OFFERING_LABEL__c, PROGRAM_TYPE__c, REGION__c, MEAN_EFFECTIVENESS__c
                FROM apm_outcome_v2__c 
                WHERE IsDeleted = false 
                LIMIT 3
            ];
            
            System.debug('📋 Sample data structure:');
            for (apm_outcome_v2__c record : sampleRecords) {
                System.debug('  Offering: ' + record.OFFERING_LABEL__c + 
                           ', Program: ' + record.PROGRAM_TYPE__c + 
                           ', Region: ' + record.REGION__c + 
                           ', Effectiveness: ' + record.MEAN_EFFECTIVENESS__c);
            }
        } else {
            System.debug('⚠️ apm_outcome_v2__c has no data - tests may be limited');
            testResults.put('Data_Access', true);
        }
    } else {
        System.debug('❌ apm_outcome_v2__c object does not exist');
        testResults.put('Data_Access', false);
        testMessages.put('Data_Access', 'Object not found');
    }
} catch (Exception e) {
    System.debug('❌ Data access test failed: ' + e.getMessage());
    testResults.put('Data_Access', false);
    testMessages.put('Data_Access', e.getMessage());
}

// Test 5: Check Course__c object for linking
try {
    System.debug('Testing Course__c object access...');
    
    Schema.SObjectType courseType = Schema.getGlobalDescribe().get('Course__c');
    if (courseType != null) {
        System.debug('✅ Course__c object exists');
        
        Integer courseCount = Database.countQuery('SELECT COUNT() FROM Course__c WHERE IsDeleted = false');
        System.debug('📊 Total Course__c records: ' + courseCount);
        
        if (courseCount > 0) {
            System.debug('✅ Course__c has data for linking');
            testResults.put('Course_Access', true);
        } else {
            System.debug('⚠️ Course__c has no data - course linking tests may be limited');
            testResults.put('Course_Access', true);
        }
    } else {
        System.debug('❌ Course__c object does not exist');
        testResults.put('Course_Access', false);
        testMessages.put('Course_Access', 'Object not found');
    }
} catch (Exception e) {
    System.debug('❌ Course access test failed: ' + e.getMessage());
    testResults.put('Course_Access', false);
    testMessages.put('Course_Access', e.getMessage());
}

// ============================================================================
// PHASE 3: FUNCTIONALITY VALIDATION
// ============================================================================

System.debug('\n--- PHASE 3: Functionality Validation ---');

// Test 6: Search Action
try {
    System.debug('Testing Search Action...');
    
    ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest();
    request.action = 'Search';
    request.programType = 'Fast Start';
    request.maxResults = 5;
    
    List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisResponse> responses = 
        ANAgentOfferingEfficacyHandler.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOfferingEfficacyHandler.EfficacyAnalysisResponse response = responses[0];
        System.debug('✅ Search action successful');
        System.debug('  Success: ' + response.success);
        System.debug('  Message: ' + response.message);
        System.debug('  Records found: ' + response.totalRecordCount);
        
        testResults.put('Search_Action', response.success);
        if (!response.success) {
            testMessages.put('Search_Action', response.message);
        }
    } else {
        System.debug('❌ Search action returned no responses');
        testResults.put('Search_Action', false);
        testMessages.put('Search_Action', 'No responses returned');
    }
} catch (Exception e) {
    System.debug('❌ Search action test failed: ' + e.getMessage());
    testResults.put('Search_Action', false);
    testMessages.put('Search_Action', e.getMessage());
}

// Test 7: Course Efficacy Action
try {
    System.debug('Testing Course Efficacy Action...');
    
    ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest();
    request.action = 'CourseEfficacy';
    request.courseName = 'Fast Start'; // Use a common term that might exist
    
    List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisResponse> responses = 
        ANAgentOfferingEfficacyHandler.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOfferingEfficacyHandler.EfficacyAnalysisResponse response = responses[0];
        System.debug('✅ Course efficacy action successful');
        System.debug('  Success: ' + response.success);
        System.debug('  Message: ' + response.message);
        System.debug('  Records found: ' + response.totalRecordCount);
        
        testResults.put('CourseEfficacy_Action', response.success);
        if (!response.success) {
            testMessages.put('CourseEfficacy_Action', response.message);
        }
    } else {
        System.debug('❌ Course efficacy action returned no responses');
        testResults.put('CourseEfficacy_Action', false);
        testMessages.put('CourseEfficacy_Action', 'No responses returned');
    }
} catch (Exception e) {
    System.debug('❌ Course efficacy action test failed: ' + e.getMessage());
    testResults.put('CourseEfficacy_Action', false);
    testMessages.put('CourseEfficacy_Action', e.getMessage());
}

// ============================================================================
// PHASE 4: BATCH PROCESSING VALIDATION
// ============================================================================

if (testBatchProcessing) {
    System.debug('\n--- PHASE 4: Batch Processing Validation ---');
    
    // Test 8: Batch Service Execution
    try {
        System.debug('Testing Batch Service Execution...');
        
        // Start a small batch job
        Id batchJobId = ANAgentOfferingEfficacyBatchService.executeBatchAnalysis(
            'Test', 'Fast Start', 'ANZ', 'ESMB', '2024-Q1', 'PIPE_QUALITY', 'ALL', 'analyze', 100
        );
        
        System.debug('✅ Batch job started successfully');
        System.debug('  Batch Job ID: ' + batchJobId);
        
        // Check batch job status
        AsyncApexJob batchJob = [
            SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
            FROM AsyncApexJob 
            WHERE Id = :batchJobId
        ];
        
        System.debug('  Status: ' + batchJob.Status);
        System.debug('  Job Items: ' + batchJob.JobItemsProcessed + '/' + batchJob.TotalJobItems);
        System.debug('  Errors: ' + batchJob.NumberOfErrors);
        
        testResults.put('Batch_Execution', true);
        
    } catch (Exception e) {
        System.debug('❌ Batch service execution failed: ' + e.getMessage());
        testResults.put('Batch_Execution', false);
        testMessages.put('Batch_Execution', e.getMessage());
    }
}

// ============================================================================
// PHASE 5: PERFORMANCE VALIDATION
// ============================================================================

if (testPerformance) {
    System.debug('\n--- PHASE 5: Performance Validation ---');
    
    // Test 9: Response Time Test
    try {
        System.debug('Testing Response Time...');
        
        Long startTime = System.currentTimeMillis();
        
        ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest();
        request.action = 'Summary';
        request.programType = 'Fast Start';
        
        List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisResponse> responses = 
            ANAgentOfferingEfficacyHandler.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest>{request});
        
        Long endTime = System.currentTimeMillis();
        Long responseTime = endTime - startTime;
        
        System.debug('✅ Performance test completed');
        System.debug('  Response time: ' + responseTime + 'ms');
        
        if (responseTime < 5000) { // 5 seconds threshold
            System.debug('✅ Response time is acceptable');
            testResults.put('Performance', true);
        } else {
            System.debug('⚠️ Response time is slow: ' + responseTime + 'ms');
            testResults.put('Performance', false);
            testMessages.put('Performance', 'Slow response time: ' + responseTime + 'ms');
        }
        
    } catch (Exception e) {
        System.debug('❌ Performance test failed: ' + e.getMessage());
        testResults.put('Performance', false);
        testMessages.put('Performance', e.getMessage());
    }
}

// ============================================================================
// PHASE 6: ERROR SCENARIO VALIDATION
// ============================================================================

if (testErrorScenarios) {
    System.debug('\n--- PHASE 6: Error Scenario Validation ---');
    
    // Test 10: Invalid Action
    try {
        System.debug('Testing Invalid Action...');
        
        ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest();
        request.action = 'InvalidAction';
        
        List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisResponse> responses = 
            ANAgentOfferingEfficacyHandler.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest>{request});
        
        if (!responses.isEmpty()) {
            ANAgentOfferingEfficacyHandler.EfficacyAnalysisResponse response = responses[0];
            if (!response.success && response.message.contains('Invalid action')) {
                System.debug('✅ Error handling for invalid action works correctly');
                testResults.put('Error_Handling', true);
            } else {
                System.debug('❌ Error handling for invalid action failed');
                testResults.put('Error_Handling', false);
                testMessages.put('Error_Handling', 'Invalid action not handled correctly');
            }
        } else {
            System.debug('❌ Invalid action test returned no responses');
            testResults.put('Error_Handling', false);
            testMessages.put('Error_Handling', 'No responses for invalid action');
        }
        
    } catch (Exception e) {
        System.debug('❌ Error scenario test failed: ' + e.getMessage());
        testResults.put('Error_Handling', false);
        testMessages.put('Error_Handling', e.getMessage());
    }
}

// ============================================================================
// PHASE 7: RESULTS SUMMARY
// ============================================================================

System.debug('\n--- PHASE 7: Test Results Summary ---');

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

System.debug('\n📊 TEST SUMMARY:');
System.debug('  Total Tests: ' + totalTests);
System.debug('  Passed: ' + passedTests);
System.debug('  Failed: ' + failedTests);
System.debug('  Success Rate: ' + (passedTests * 100 / totalTests) + '%');

if (failedTests == 0) {
    System.debug('\n🎉 ALL TESTS PASSED! The Offering Efficacy System is ready for production use.');
} else {
    System.debug('\n⚠️  Some tests failed. Please review the errors above before using in production.');
}

System.debug('\n📋 NEXT STEPS:');
System.debug('  1. Review any failed tests above');
System.debug('  2. Check batch job status in Setup > Apex Jobs');
System.debug('  3. Monitor debug logs for detailed execution information');
System.debug('  4. Run integration tests with real data');
System.debug('  5. Validate course linking functionality');

System.debug('\n🧪 PRODUCTION VALIDATION TEST COMPLETED'); 