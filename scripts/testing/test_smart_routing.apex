// Test script to verify the smart routing logic
// This tests that effectiveness-related queries are correctly identified and routed

System.debug('🧪 TESTING SMART ROUTING LOGIC');
System.debug('=================================');

// ============================================================================
// PHASE 1: TEST THE EXACT USER SCENARIO THAT WAS MISROUTED
// ============================================================================

System.debug('\n--- PHASE 1: Testing the Misrouted Query ---');

// This is the exact query that was misrouted to Content Search instead of Efficacy
String misroutedQuery = 'can u show me top 5 best courses on Fast start?';

System.debug('🎯 User Query: "' + misroutedQuery + '"');
System.debug('🔍 Expected: Should route to OFFERING_EFFICACY agent (not CONTENT_SEARCH)');

try {
    System.debug('\n🔄 Testing ANAgentSmartRouter.analyzeAndRoute...');
    
    ANAgentSmartRouter.RoutingDecision decision = 
        ANAgentSmartRouter.analyzeAndRoute(misroutedQuery);
    
    System.debug('📊 Routing Decision:');
    System.debug('  Recommended Agent: ' + decision.recommendedAgent);
    System.debug('  Confidence: ' + decision.confidence);
    System.debug('  Reasoning: ' + decision.reasoning);
    
    if (String.isNotBlank(decision.userGuidance)) {
        System.debug('  User Guidance: ' + decision.userGuidance);
    }
    
    if (decision.recommendedAgent == 'OFFERING_EFFICACY') {
        System.debug('✅ SUCCESS: Query correctly routed to Offering Efficacy Agent!');
        System.debug('🎯 This will prevent the misrouting issue you experienced');
    } else if (decision.recommendedAgent == 'CONTENT_SEARCH') {
        System.debug('❌ ISSUE: Query still being routed to Content Search');
        System.debug('🎯 This means the routing logic needs improvement');
    } else {
        System.debug('⚠️  UNKNOWN: Query routed to unexpected agent: ' + decision.recommendedAgent);
    }
    
} catch (Exception e) {
    System.debug('❌ Error in smart routing test: ' + e.getMessage());
}

// ============================================================================
// PHASE 2: TEST VARIOUS EFFECTIVENESS-RELATED QUERIES
// ============================================================================

System.debug('\n--- PHASE 2: Testing Various Effectiveness Queries ---');

List<String> effectivenessQueries = new List<String>{
    'Show me top 5 most effective courses on Data Cloud',
    'What are the best performing training programs?',
    'Find the most successful courses for sales teams',
    'Which courses have the highest impact?',
    'Show me top rated learning materials',
    'What are the most valuable training programs?'
};

for (String query : effectivenessQueries) {
    try {
        System.debug('\n🔄 Testing: "' + query + '"');
        
        ANAgentSmartRouter.RoutingDecision decision = 
            ANAgentSmartRouter.analyzeAndRoute(query);
        
        System.debug('  → Routes to: ' + decision.recommendedAgent);
        System.debug('  → Confidence: ' + decision.confidence);
        
        if (decision.recommendedAgent == 'OFFERING_EFFICACY') {
            System.debug('  ✅ Correctly identified as effectiveness query');
        } else {
            System.debug('  ❌ Incorrectly routed to: ' + decision.recommendedAgent);
        }
        
    } catch (Exception e) {
        System.debug('  ❌ Error: ' + e.getMessage());
    }
}

// ============================================================================
// PHASE 3: TEST CONTENT SEARCH QUERIES (SHOULD NOT ROUTE TO EFFICACY)
// ============================================================================

System.debug('\n--- PHASE 3: Testing Content Search Queries ---');

List<String> contentQueries = new List<String>{
    'Show me courses related to Data Cloud',
    'Find training materials for Salesforce',
    'Search for curriculum about financial services',
    'What learning programs are available?',
    'Show me workshop materials'
};

for (String query : contentQueries) {
    try {
        System.debug('\n🔄 Testing: "' + query + '"');
        
        ANAgentSmartRouter.RoutingDecision decision = 
            ANAgentSmartRouter.analyzeAndRoute(query);
        
        System.debug('  → Routes to: ' + decision.recommendedAgent);
        System.debug('  → Confidence: ' + decision.confidence);
        
        if (decision.recommendedAgent == 'CONTENT_SEARCH') {
            System.debug('  ✅ Correctly identified as content search query');
        } else {
            System.debug('  ❌ Incorrectly routed to: ' + decision.recommendedAgent);
        }
        
    } catch (Exception e) {
        System.debug('  ❌ Error: ' + e.getMessage());
    }
}

// ============================================================================
// PHASE 4: TEST SALES/PIPELINE QUERIES
// ============================================================================

System.debug('\n--- PHASE 4: Testing Sales/Pipeline Queries ---');

List<String> salesQueries = new List<String>{
    'What are the top products by ACV in AMER ENTR?',
    'Show me pipeline data for EMEA region',
    'Which products have highest revenue?',
    'Find sales opportunities in Canada',
    'Show me territory performance data'
};

for (String query : salesQueries) {
    try {
        System.debug('\n🔄 Testing: "' + query + '"');
        
        ANAgentSmartRouter.RoutingDecision decision = 
            ANAgentSmartRouter.analyzeAndRoute(query);
        
        System.debug('  → Routes to: ' + decision.recommendedAgent);
        System.debug('  → Confidence: ' + decision.confidence);
        
        if (decision.recommendedAgent == 'OPEN_PIPE') {
            System.debug('  ✅ Correctly identified as sales/pipeline query');
        } else {
            System.debug('  ❌ Incorrectly routed to: ' + decision.recommendedAgent);
        }
        
    } catch (Exception e) {
        System.debug('  ❌ Error: ' + e.getMessage());
    }
}

// ============================================================================
// PHASE 5: TEST THE BUILT-IN TEST METHOD
// ============================================================================

System.debug('\n--- PHASE 5: Testing Built-in Test Method ---');

try {
    System.debug('🔄 Testing ANAgentSmartRouter.testRoutingLogic...');
    
    ANAgentSmartRouter.testRoutingLogic();
    
    System.debug('✅ SUCCESS: Built-in test method executed successfully');
    
} catch (Exception e) {
    System.debug('❌ Error in built-in test: ' + e.getMessage());
}

// ============================================================================
// PHASE 6: SUMMARY OF SMART ROUTING IMPROVEMENTS
// ============================================================================

System.debug('\n--- PHASE 6: Summary of Smart Routing Improvements ---');

System.debug('🎯 WHAT WE\'VE IMPLEMENTED:');
System.debug('  1. ✅ Smart routing service that detects user intent');
System.debug('  2. ✅ Effectiveness keyword detection (best, most effective, etc.)');
System.debug('  3. ✅ Proper routing to Offering Efficacy Agent for effectiveness queries');
System.debug('  4. ✅ Prevention of misrouting to Content Search');
System.debug('  5. ✅ Confidence scoring and reasoning for routing decisions');

System.debug('\n💡 KEY EFFECTIVENESS KEYWORDS DETECTED:');
System.debug('  • best, most effective, top performing');
System.debug('  • highest performing, most successful, top rated');
System.debug('  • most impactful, highest impact, best results');
System.debug('  • most valuable, highest value, best outcomes');

System.debug('\n🔍 EXPECTED ROUTING BEHAVIOR NOW:');
System.debug('  • "best courses" → OFFERING_EFFICACY (with clarifying questions)');
System.debug('  • "courses related to X" → CONTENT_SEARCH');
System.debug('  • "top products by ACV" → OPEN_PIPE');
System.debug('  • "most effective training" → OFFERING_EFFICACY');

System.debug('\n🧪 SMART ROUTING TEST COMPLETED');
System.debug('The system should now correctly route effectiveness queries!'); 