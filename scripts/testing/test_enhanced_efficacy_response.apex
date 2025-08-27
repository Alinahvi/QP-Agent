// Test script to verify enhanced efficacy response includes offering names
// This tests the fix for the issue where users couldn't see the actual course names

System.debug('🔍 TESTING ENHANCED EFFICACY RESPONSE');
System.debug('=====================================');

// Test Configuration
String testCourseName = 'Data Cloud';
Integer maxResults = 5;

System.debug('\n--- Test Configuration ---');
System.debug('Course Name: ' + testCourseName);
System.debug('Max Results: ' + maxResults);

// ============================================================================
// PHASE 1: TEST COURSE EFFICACY ACTION
// ============================================================================

System.debug('\n--- PHASE 1: Testing Course Efficacy Action ---');

try {
    System.debug('Testing Course Efficacy Action...');
    
    ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
    request.action = 'CourseEfficacy';
    request.courseName = testCourseName;
    request.maxResults = maxResults;
    
    List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> responses = 
        ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse response = responses[0];
        
        System.debug('✅ Course Efficacy Action Response:');
        System.debug('  Success: ' + response.success);
        System.debug('  Message: ' + response.message);
        System.debug('  Total Records: ' + response.totalRecordCount);
        System.debug('  Request ID: ' + response.requestId);
        
        // Check if efficacyRecords field is populated
        if (response.efficacyRecords != null) {
            System.debug('  ✅ Efficacy Records Field: POPULATED');
            System.debug('  Records Count: ' + response.efficacyRecords.size());
            
            // Display the actual offering names
            if (!response.efficacyRecords.isEmpty()) {
                System.debug('\n📋 ACTUAL OFFERING NAMES FOUND:');
                for (Integer i = 0; i < response.efficacyRecords.size(); i++) {
                    ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record = response.efficacyRecords[i];
                    System.debug('  ' + (i+1) + '. ' + record.offeringLabel);
                    System.debug('     ID: ' + record.id);
                    System.debug('     Program Type: ' + record.programType);
                    System.debug('     Region: ' + record.region);
                    System.debug('     Segment: ' + record.macroSegment);
                    System.debug('     Effectiveness: ' + record.effectivenessDisplay);
                    System.debug('     Lift: ' + record.liftDisplay);
                    System.debug('     ACV: ' + record.acvDisplay);
                }
            } else {
                System.debug('  ⚠️ No efficacy records in the list');
            }
        } else {
            System.debug('  ❌ Efficacy Records Field: NULL');
        }
        
        // Check summary metrics
        if (String.isNotBlank(response.summaryMetrics)) {
            System.debug('\n📊 SUMMARY METRICS:');
            System.debug(response.summaryMetrics);
        } else {
            System.debug('  ⚠️ No summary metrics available');
        }
        
    } else {
        System.debug('❌ No response received from Course Efficacy Action');
    }
    
} catch (Exception e) {
    System.debug('❌ Course Efficacy Action failed: ' + e.getMessage());
}

// ============================================================================
// PHASE 2: TEST SEARCH ACTION
// ============================================================================

System.debug('\n--- PHASE 2: Testing Search Action ---');

try {
    System.debug('Testing Search Action...');
    
    ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
    request.action = 'Search';
    request.offeringLabel = testCourseName;
    request.maxResults = maxResults;
    
    List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> responses = 
        ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse response = responses[0];
        
        System.debug('✅ Search Action Response:');
        System.debug('  Success: ' + response.success);
        System.debug('  Message: ' + response.message);
        System.debug('  Total Records: ' + response.totalRecordCount);
        System.debug('  Request ID: ' + response.requestId);
        
        // Check if efficacyRecords field is populated
        if (response.efficacyRecords != null) {
            System.debug('  ✅ Efficacy Records Field: POPULATED');
            System.debug('  Records Count: ' + response.efficacyRecords.size());
            
            // Display the actual offering names
            if (!response.efficacyRecords.isEmpty()) {
                System.debug('\n📋 ACTUAL OFFERING NAMES FOUND:');
                for (Integer i = 0; i < response.efficacyRecords.size(); i++) {
                    ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record = response.efficacyRecords[i];
                    System.debug('  ' + (i+1) + '. ' + record.offeringLabel);
                    System.debug('     ID: ' + record.id);
                    System.debug('     Program Type: ' + record.programType);
                    System.debug('     Region: ' + record.region);
                    System.debug('     Segment: ' + record.macroSegment);
                    System.debug('     Effectiveness: ' + record.effectivenessDisplay);
                    System.debug('     Lift: ' + record.liftDisplay);
                    System.debug('     ACV: ' + record.acvDisplay);
                }
            } else {
                System.debug('  ⚠️ No efficacy records in the list');
            }
        } else {
            System.debug('  ❌ Efficacy Records Field: NULL');
        }
        
        // Check summary metrics
        if (String.isNotBlank(response.summaryMetrics)) {
            System.debug('\n📊 SUMMARY METRICS:');
            System.debug(response.summaryMetrics);
        } else {
            System.debug('  ⚠️ No summary metrics available');
        }
        
    } else {
        System.debug('❌ No response received from Search Action');
    }
    
} catch (Exception e) {
    System.debug('❌ Search Action failed: ' + e.getMessage());
}

// ============================================================================
// PHASE 3: COMPARISON WITH EXPECTED BEHAVIOR
// ============================================================================

System.debug('\n--- PHASE 3: Comparison with Expected Behavior ---');

System.debug('🎯 EXPECTED BEHAVIOR:');
System.debug('  ✅ Users should see actual offering names (not just metrics)');
System.debug('  ✅ Summary should include top 3 offering names');
System.debug('  ✅ Response should include detailed efficacy records');
System.debug('  ✅ Agent should be able to display specific course names');

System.debug('\n📋 WHAT WAS MISSING BEFORE:');
System.debug('  ❌ Only aggregated metrics (no course names)');
System.debug('  ❌ Users couldn\'t see which specific courses were effective');
System.debug('  ❌ No way to identify top-performing offerings');

System.debug('\n🔧 WHAT WAS FIXED:');
System.debug('  ✅ Added efficacyRecords field to response class');
System.debug('  ✅ Enhanced summary to include top 3 offering names');
System.debug('  ✅ Handler now passes through detailed records');
System.debug('  ✅ Users can now see specific course names and details');

System.debug('\n🎉 ENHANCED EFFICACY RESPONSE TEST COMPLETED');
System.debug('The fix should now allow users to see actual offering names!'); 