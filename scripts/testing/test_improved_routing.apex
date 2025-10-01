// Test script to verify the IMPROVED smart routing logic
// This tests that effectiveness-related queries are now correctly routed

System.debug('🧪 TESTING IMPROVED SMART ROUTING LOGIC');
System.debug('========================================');

// ============================================================================
// PHASE 1: TEST THE EXACT USER SCENARIO THAT WAS MISROUTED
// ============================================================================

System.debug('\n--- PHASE 1: Testing the Previously Misrouted Query ---');

// This is the exact query that was misrouted to Content Search instead of Efficacy
String misroutedQuery = 'can u show me top 5 best courses on Fast start?';

System.debug('🎯 User Query: "' + misroutedQuery + '"');
System.debug('🔍 Expected: Should NOW route to OFFERING_EFFICACY agent');

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
        System.debug('✅ SUCCESS: Query now correctly routed to Offering Efficacy Agent!');
        System.debug('🎯 The routing issue has been fixed');
    } else if (decision.recommendedAgent == 'CONTENT_SEARCH') {
        System.debug('❌ ISSUE: Query still being routed to Content Search');
        System.debug('🎯 The routing logic still needs improvement');
    } else {
        System.debug('⚠️  UNKNOWN: Query routed to unexpected agent: ' + decision.recommendedAgent);
    }
    
} catch (Exception e) {
    System.debug('❌ Error in improved routing test: ' + e.getMessage());
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
    'What are the most valuable training programs?',
    'Best courses for beginners',
    'Most effective training methods',
    'Top performing learning programs'
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
// PHASE 3: TEST THE SCORING SYSTEM
// ============================================================================

System.debug('\n--- PHASE 3: Testing Scoring System ---');

try {
    System.debug('🔄 Testing scoring for "best courses" vs "courses related to"');
    
    String effectivenessQuery = 'best courses for sales';
    String contentQuery = 'courses related to sales';
    
    ANAgentSmartRouter.RoutingDecision effectivenessDecision = 
        ANAgentSmartRouter.analyzeAndRoute(effectivenessQuery);
    
    ANAgentSmartRouter.RoutingDecision contentDecision = 
        ANAgentSmartRouter.analyzeAndRoute(contentQuery);
    
    System.debug('📊 Effectiveness Query ("best courses for sales"):');
    System.debug('  → Routes to: ' + effectivenessDecision.recommendedAgent);
    System.debug('  → Confidence: ' + effectivenessDecision.confidence);
    
    System.debug('📊 Content Query ("courses related to sales"):');
    System.debug('  → Routes to: ' + contentDecision.recommendedAgent);
    System.debug('  → Confidence: ' + contentDecision.confidence);
    
    if (effectivenessDecision.recommendedAgent == 'OFFERING_EFFICACY' && 
        contentDecision.recommendedAgent == 'CONTENT_SEARCH') {
        System.debug('✅ SUCCESS: Scoring system working correctly!');
        System.debug('🎯 Effectiveness queries route to Efficacy, content queries to Content Search');
    } else {
        System.debug('❌ ISSUE: Scoring system not working as expected');
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing scoring system: ' + e.getMessage());
}

// ============================================================================
// PHASE 4: SUMMARY OF IMPROVEMENTS
// ============================================================================

System.debug('\n--- PHASE 4: Summary of Routing Improvements ---');

System.debug('🎯 WHAT WE\'VE IMPROVED:');
System.debug('  1. ✅ Higher weight for effectiveness keywords (2.0 vs 1.0)');
System.debug('  2. ✅ Priority routing for effectiveness queries (> 0.1 threshold)');
System.debug('  3. ✅ Better scoring algorithm that prevents misrouting');
System.debug('  4. ✅ Explicit effectiveness detection before other categories');

System.debug('\n💡 EXPECTED ROUTING BEHAVIOR NOW:');
System.debug('  • "best courses" → OFFERING_EFFICACY (with clarifying questions)');
System.debug('  • "most effective training" → OFFERING_EFFICACY');
System.debug('  • "courses related to X" → CONTENT_SEARCH');
System.debug('  • "top products by ACV" → OPEN_PIPE');

System.debug('\n🔍 KEY IMPROVEMENT:');
System.debug('  The query "can u show me top 5 best courses on Fast start?"');
System.debug('  Should now route to OFFERING_EFFICACY instead of CONTENT_SEARCH');
System.debug('  This will trigger the clarifying questions about which KPI the user means');

System.debug('\n🧪 IMPROVED ROUTING TEST COMPLETED');
System.debug('The system should now correctly route effectiveness queries!'); 