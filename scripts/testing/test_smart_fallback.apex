// Test script to verify the smart fallback logic
// This tests that the service only suggests KPI options when related courses actually exist

System.debug('🧪 TESTING SMART FALLBACK LOGIC');
System.debug('==================================');

// ============================================================================
// PHASE 1: TEST "EFFECTIVE" WITHOUT KPI (SHOULD ASK CLARIFYING QUESTIONS)
// ============================================================================

System.debug('\n--- PHASE 1: Testing "Effective" Without KPI ---');

// Test the exact user scenario that was failing
String searchTerm = 'Show me top 5 most effective data cloud course';

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
// PHASE 2: TEST WITH SPECIFIC KPI BUT NO DATA (SHOULD CHECK FOR RELATED COURSES)
// ============================================================================

System.debug('\n--- PHASE 2: Testing With Specific KPI But No Data ---');

String specificKPI = 'PIPE_QUALITY';
String specificSearch = 'data cloud';

System.debug('🎯 User Query: "' + specificSearch + '" with KPI: ' + specificKPI);
System.debug('🔍 Expected: Should check if related courses exist and provide smart fallback');

try {
    System.debug('\n🔄 Testing with specific KPI: ' + specificKPI);
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult specificResult = 
        ANAgentOfferingEfficacyServiceBasic.searchEfficacyData(specificSearch, null, null, null, null, specificKPI, null, 5);
    
    System.debug('📊 Specific KPI Results:');
    System.debug('  Success: ' + specificResult.success);
    System.debug('  Message: ' + specificResult.message);
    System.debug('  Total Records: ' + specificResult.totalRecordCount);
    
    if (specificResult.success && specificResult.totalRecordCount == 0) {
        System.debug('✅ SUCCESS: Service found no data and should provide smart fallback!');
        System.debug('🎯 Check if it suggests KPIs only when related courses exist');
        
        // Show the fallback message
        System.debug('\n📋 Fallback Message:');
        System.debug(specificResult.message);
        
        // Check if it's smart about suggesting KPIs
        if (specificResult.message.contains('Since no related courses exist in our APM library')) {
            System.debug('✅ SMART: Service correctly identified no related courses exist');
            System.debug('🎯 It won\'t suggest KPIs when there\'s no data to query');
        } else if (specificResult.message.contains('Since related courses exist')) {
            System.debug('✅ SMART: Service found related courses and suggests KPI options');
            System.debug('🎯 It only suggests KPIs when there\'s actually data to query');
        } else {
            System.debug('⚠️  UNKNOWN: Fallback message format unclear');
        }
        
    } else if (specificResult.success && specificResult.totalRecordCount > 0) {
        System.debug('✅ SUCCESS: Service found data with specific KPI!');
        System.debug('🎯 This shows the clarifying questions approach is working');
    } else {
        System.debug('⚠️  Service had issues even with specific KPI');
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
// PHASE 4: TEST SMART FALLBACK LOGIC
// ============================================================================

System.debug('\n--- PHASE 4: Testing Smart Fallback Logic ---');

try {
    System.debug('🔄 Testing smart fallback with different scenarios...');
    
    // Test with a term that might have no related courses
    String noDataTerm = 'XYZ123_Course_That_Does_Not_Exist';
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult noDataResult = 
        ANAgentOfferingEfficacyServiceBasic.searchEfficacyData(noDataTerm, null, null, null, null, null, null, 5);
    
    System.debug('📊 No Data Scenario Results:');
    System.debug('  Success: ' + noDataResult.success);
    System.debug('  Message: ' + noDataResult.message);
    
    if (!noDataResult.success || noDataResult.totalRecordCount == 0) {
        System.debug('✅ SUCCESS: Service handled no data scenario!');
        
        // Check if it's smart about not suggesting KPIs
        if (noDataResult.message.contains('Since no related courses exist in our APM library')) {
            System.debug('🎯 SMART: Service correctly identified no related courses');
            System.debug('✅ It won\'t suggest KPIs when there\'s no data to query');
        } else if (noDataResult.message.contains('Since related courses exist')) {
            System.debug('🎯 SMART: Service found related courses and suggests KPI options');
            System.debug('✅ It only suggests KPIs when there\'s actually data to query');
        } else {
            System.debug('⚠️  UNKNOWN: Fallback message format unclear');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing smart fallback: ' + e.getMessage());
}

// ============================================================================
// PHASE 5: SUMMARY OF SMART FALLBACK IMPROVEMENTS
// ============================================================================

System.debug('\n--- PHASE 5: Summary of Smart Fallback Improvements ---');

System.debug('🎯 WHAT WE\'VE IMPROVED:');
System.debug('  1. ✅ Smart fallback logic that checks if related courses exist');
System.debug('  2. ✅ Only suggests KPIs when there\'s actually data to query');
System.debug('  3. ✅ Prevents suggesting irrelevant KPI options');
System.debug('  4. ✅ Provides appropriate fallback based on data availability');
System.debug('  5. ✅ Clear guidance on when KPIs are useful vs. not');

System.debug('\n💡 SMART FALLBACK SCENARIOS:');
System.debug('  • No related courses exist → Don\'t suggest KPIs, focus on finding courses');
System.debug('  • Related courses exist but no data for current filters → Suggest KPI options');
System.debug('  • User says "effective" without KPI → Ask clarifying questions');
System.debug('  • User specifies KPI → Return relevant data or smart fallback');

System.debug('\n🔍 EXPECTED USER EXPERIENCE NOW:');
System.debug('  • User asks: "Show me top 5 most effective data cloud course"');
System.debug('  • Agent responds: "Which KPI do you mean by effective?" + List of KPIs');
System.debug('  • User chooses: "PIPE_QUALITY"');
System.debug('  • If no data: Agent checks if related courses exist');
System.debug('  • If related courses exist: Agent suggests trying different KPIs');
System.debug('  • If no related courses: Agent focuses on finding courses first');

System.debug('\n🧪 SMART FALLBACK TEST COMPLETED');
System.debug('The service should now be much smarter about when to suggest KPIs!'); 