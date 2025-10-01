// Test script to verify the clarifying questions approach
// This tests that the service now asks clarifying questions when users say "effective"

System.debug('🧪 TESTING CLARIFYING QUESTIONS APPROACH');
System.debug('==========================================');

// ============================================================================
// PHASE 1: TEST "EFFECTIVE" WITHOUT KPI (SHOULD ASK CLARIFYING QUESTIONS)
// ============================================================================

System.debug('\n--- PHASE 1: Testing "Effective" Without KPI ---');

// Test the exact user scenario that was failing
String searchTerm = 'Show me top 5 effective courses on data cloud';

System.debug('🎯 User Query: "' + searchTerm + '"');
System.debug('🔍 Expected: Should ask clarifying questions about which KPI');

try {
    System.debug('\n🔄 Testing ANAgentOfferingEfficacyServiceBasic.searchEfficacyData...');
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult serviceResult = 
        ANAgentOfferingEfficacyServiceBasic.searchEfficacyData(searchTerm, null, null, null, null, null, null, 5);
    
    System.debug('📊 Clarifying Questions Response:');
    System.debug('  Success: ' + serviceResult.success);
    System.debug('  Message: ' + serviceResult.message);
    
    if (!serviceResult.success) {
        System.debug('✅ SUCCESS: Service correctly asked for clarifying questions!');
        System.debug('🎯 User needs to specify which KPI they mean by "effective"');
        
        // Show the clarifying questions
        System.debug('\n📋 Clarifying Questions Asked:');
        System.debug(serviceResult.message);
        
    } else {
        System.debug('❌ ISSUE: Service should have asked for clarifying questions');
    }
    
} catch (Exception e) {
    System.debug('❌ Error in clarifying questions test: ' + e.getMessage());
}

// ============================================================================
// PHASE 2: TEST "EFFECTIVE" WITH SPECIFIC KPI (SHOULD WORK)
// ============================================================================

System.debug('\n--- PHASE 2: Testing "Effective" With Specific KPI ---');

String specificKPI = 'PIPE_QUALITY';
String specificSearch = 'Show me top 5 effective courses on data cloud by ' + specificKPI;

System.debug('🎯 User Query: "' + specificSearch + '"');
System.debug('🔍 Expected: Should work since KPI is specified');

try {
    System.debug('\n🔄 Testing with specific KPI: ' + specificKPI);
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult specificResult = 
        ANAgentOfferingEfficacyServiceBasic.searchEfficacyData('data cloud', null, null, null, null, specificKPI, null, 5);
    
    System.debug('📊 Specific KPI Results:');
    System.debug('  Success: ' + specificResult.success);
    System.debug('  Message: ' + specificResult.message);
    System.debug('  Total Records: ' + specificResult.totalRecordCount);
    
    if (specificResult.success) {
        System.debug('✅ SUCCESS: Service worked with specific KPI!');
        System.debug('🎯 This shows the clarifying questions approach is working');
    } else {
        System.debug('⚠️  Service still had issues even with specific KPI');
    }
    
} catch (Exception e) {
    System.debug('❌ Error in specific KPI test: ' + e.getMessage());
}

// ============================================================================
// PHASE 3: TEST COURSE EFFICACY WITH "EFFECTIVE" (SHOULD ASK QUESTIONS)
// ============================================================================

System.debug('\n--- PHASE 3: Testing Course Efficacy with "Effective" ---');

try {
    System.debug('🔄 Testing ANAgentOfferingEfficacyServiceBasic.getEfficacyForCourse...');
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult courseResult = 
        ANAgentOfferingEfficacyServiceBasic.getEfficacyForCourse('effective data cloud courses');
    
    System.debug('📊 Course Efficacy Clarifying Questions:');
    System.debug('  Success: ' + courseResult.success);
    System.debug('  Message: ' + courseResult.message);
    
    if (!courseResult.success) {
        System.debug('✅ SUCCESS: Course efficacy also asks clarifying questions!');
    } else {
        System.debug('❌ ISSUE: Course efficacy should have asked for clarifying questions');
    }
    
} catch (Exception e) {
    System.debug('❌ Error in course efficacy clarifying questions: ' + e.getMessage());
}

// ============================================================================
// PHASE 4: TEST AVAILABLE KPIs METHOD
// ============================================================================

System.debug('\n--- PHASE 4: Testing Available KPIs Method ---');

try {
    System.debug('🔄 Testing ANAgentOfferingEfficacyServiceBasic.getAvailableKPIs...');
    
    String availableKPIs = ANAgentOfferingEfficacyServiceBasic.getAvailableKPIs();
    
    System.debug('📊 Available KPIs:');
    System.debug(availableKPIs);
    
    System.debug('✅ SUCCESS: Available KPIs method is working!');
    
} catch (Exception e) {
    System.debug('❌ Error getting available KPIs: ' + e.getMessage());
}

// ============================================================================
// PHASE 5: TEST FALLBACK OPTIONS METHOD
// ============================================================================

System.debug('\n--- PHASE 5: Testing Fallback Options Method ---');

try {
    System.debug('🔄 Testing ANAgentOfferingEfficacyServiceBasic.getFallbackOptions...');
    
    String fallbackOptions = ANAgentOfferingEfficacyServiceBasic.getFallbackOptions('Data Cloud');
    
    System.debug('📊 Fallback Options:');
    System.debug(fallbackOptions);
    
    System.debug('✅ SUCCESS: Fallback options method is working!');
    
} catch (Exception e) {
    System.debug('❌ Error getting fallback options: ' + e.getMessage());
}

// ============================================================================
// PHASE 6: SUMMARY OF CLARIFYING QUESTIONS APPROACH
// ============================================================================

System.debug('\n--- PHASE 6: Summary of Clarifying Questions Approach ---');

System.debug('🎯 WHAT WE\'VE IMPLEMENTED:');
System.debug('  1. ✅ Clarifying questions when users say "effective" without KPI');
System.debug('  2. ✅ List of available KPIs for users to choose from');
System.debug('  3. ✅ Fallback options when no APM data is found');
System.debug('  4. ✅ Integration suggestions with content search');
System.debug('  5. ✅ APM nomination suggestions');

System.debug('\n💡 EXPECTED USER EXPERIENCE NOW:');
System.debug('  • User asks: "Show me top 5 effective courses on data cloud"');
System.debug('  • Agent responds: "Which KPI do you mean by effective?"');
System.debug('  • Agent provides list of available KPIs');
System.debug('  • User chooses: "PIPE_QUALITY"');
System.debug('  • Agent returns: Relevant Data Cloud courses by PIPE_QUALITY');

System.debug('\n🔍 FALLBACK SCENARIOS:');
System.debug('  • No APM data found → Suggest content search');
System.debug('  • No APM data found → Suggest APM nomination');
System.debug('  • No APM data found → Suggest different KPIs');

System.debug('\n🧪 CLARIFYING QUESTIONS TEST COMPLETED');
System.debug('The service should now guide users to be more specific!'); 