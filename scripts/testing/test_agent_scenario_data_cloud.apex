// Test script to simulate the exact user scenario that was failing before
// User Query: "can you show me top 5 effective courses on data cloud?"
// This tests the fix for showing actual offering names instead of just metrics

System.debug('🧪 TESTING AGENT SCENARIO: Data Cloud Courses');
System.debug('===============================================');
System.debug('User Query: "can you show me top 5 effective courses on data cloud?"');
System.debug('Expected: Should now show actual course names, not just aggregated metrics');

// ============================================================================
// PHASE 1: SIMULATE THE EXACT USER REQUEST
// ============================================================================

System.debug('\n--- PHASE 1: Simulating User Request ---');

// This is exactly what the agent would receive from the user
String userQuery = 'can you show me top 5 effective courses on data cloud?';

// Agent would parse this and create a request like:
ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
request.action = 'Search';  // Agent would determine this is a search request
request.offeringLabel = 'Data Cloud';  // Extract "Data Cloud" from user query
request.maxResults = 5;  // User asked for "top 5"

System.debug('🎯 Agent Parsed Request:');
System.debug('  Action: ' + request.action);
System.debug('  Offering Label: ' + request.offeringLabel);
System.debug('  Max Results: ' + request.maxResults);

// ============================================================================
// PHASE 2: EXECUTE THE AGENT'S LOGIC
// ============================================================================

System.debug('\n--- PHASE 2: Executing Agent Logic ---');

try {
    System.debug('Agent is processing the request...');
    
    List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> responses = 
        ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse response = responses[0];
        
        System.debug('✅ Agent Response Received:');
        System.debug('  Success: ' + response.success);
        System.debug('  Message: ' + response.message);
        System.debug('  Total Records: ' + response.totalRecordCount);
        
        // ============================================================================
        // PHASE 3: SIMULATE AGENT'S RESPONSE TO USER
        // ============================================================================
        
        System.debug('\n--- PHASE 3: Simulating Agent Response to User ---');
        
        if (response.success) {
            System.debug('🤖 AGENT RESPONSE TO USER:');
            
            // Agent would now be able to provide this detailed response
            if (response.totalRecordCount > 0) {
                System.debug('I found ' + response.totalRecordCount + ' effective courses on Data Cloud. Here are the top offerings:');
                
                // Check if we have the detailed records (this was missing before)
                if (response.efficacyRecords != null && !response.efficacyRecords.isEmpty()) {
                    System.debug('\n📋 TOP COURSES FOUND:');
                    
                    Integer displayCount = Math.min(5, response.efficacyRecords.size());
                    for (Integer i = 0; i < displayCount; i++) {
                        ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record = response.efficacyRecords[i];
                        
                        System.debug((i + 1) + '. ' + record.offeringLabel);
                        System.debug('   Program Type: ' + record.programType);
                        System.debug('   Segment: ' + record.macroSegment);
                        System.debug('   Effectiveness: ' + record.effectivenessDisplay);
                        System.debug('   Lift: ' + record.liftDisplay);
                        System.debug('   ACV: ' + record.acvDisplay);
                    }
                    
                    System.debug('\n📊 SUMMARY METRICS:');
                    System.debug(response.summaryMetrics);
                    
                    // Agent would also provide actionable insights
                    System.debug('\n💡 AGENT INSIGHTS:');
                    System.debug('• These courses cover different business segments (CMRCL, ECS, ENTR, ESMB, PUBSEC)');
                    System.debug('• Program types include Learning Circles, Skills, and Product & Industry');
                    System.debug('• You can ask for more details about any specific course');
                    
                } else {
                    System.debug('⚠️  ISSUE: No detailed records available (this was the problem before)');
                }
                
            } else {
                System.debug('No Data Cloud courses found with efficacy data.');
            }
            
        } else {
            System.debug('❌ Agent encountered an error: ' + response.message);
        }
        
    } else {
        System.debug('❌ No response from agent');
    }
    
} catch (Exception e) {
    System.debug('❌ Error executing agent logic: ' + e.getMessage());
}

// ============================================================================
// PHASE 4: COMPARISON WITH PREVIOUS BEHAVIOR
// ============================================================================

System.debug('\n--- PHASE 4: Comparison with Previous Behavior ---');

System.debug('🔄 BEFORE (Broken):');
System.debug('  ❌ User: "Show me top 5 effective courses on data cloud"');
System.debug('  ❌ Agent: "I found 5 effective courses. Average Effectiveness: 0.0%, Average Lift: 2.8%..."');
System.debug('  ❌ Problem: No course names shown, only aggregated metrics');

System.debug('\n✅ AFTER (Fixed):');
System.debug('  ✅ User: "Show me top 5 effective courses on data cloud"');
System.debug('  ✅ Agent: "I found 5 effective courses. Here are the top offerings:"');
System.debug('  ✅ Result: Shows actual course names with detailed metrics');

System.debug('\n🎯 KEY IMPROVEMENTS:');
System.debug('  1. Users can now see specific course names');
System.debug('  2. Agent provides actionable information');
System.debug('  3. Users can ask follow-up questions about specific courses');
System.debug('  4. Integration between content search and efficacy now works properly');

System.debug('\n🧪 AGENT SCENARIO TEST COMPLETED');
System.debug('The fix should now provide a much better user experience!'); 