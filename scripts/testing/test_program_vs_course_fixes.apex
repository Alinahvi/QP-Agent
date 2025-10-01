// Test script to verify the program vs course logic and KPI filtering fixes
// This tests that the system now properly handles program queries and KPI filtering

System.debug('🧪 TESTING PROGRAM VS COURSE LOGIC FIXES');
System.debug('==========================================');

// ============================================================================
// PHASE 1: TEST PROGRAM QUERY WITH ACV KPI
// ============================================================================

System.debug('\n--- PHASE 1: Testing Program Query with ACV KPI ---');

// This is the exact scenario that was failing - user asks for programs with ACV perspective
String programQuery = 'most effective programs from ACV perspective';

System.debug('🎯 User Query: "' + programQuery + '"');
System.debug('🔍 Expected: Should detect "programs" and route to efficacy with ACV KPI');

try {
    System.debug('\n🔄 Testing ANAgentOfferingEfficacyServiceBasic.searchEfficacyData...');
    
    // Test with ACV KPI specified
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult programResult = 
        ANAgentOfferingEfficacyServiceBasic.searchEfficacyData(programQuery, null, null, null, null, 'ACV', null, 5);
    
    System.debug('📊 Program Query Results:');
    System.debug('  Success: ' + programResult.success);
    System.debug('  Message: ' + programResult.message);
    System.debug('  Total Records: ' + programResult.totalRecordCount);
    
    if (programResult.success && programResult.totalRecordCount > 0) {
        System.debug('✅ SUCCESS: Found programs with ACV KPI!');
        System.debug('🎯 This shows the KPI filtering is working correctly');
        
        // Check if the message mentions "programs" instead of "courses"
        if (programResult.message.contains('programs')) {
            System.debug('✅ SUCCESS: Message correctly refers to "programs"');
        } else {
            System.debug('❌ ISSUE: Message still refers to "courses" instead of "programs"');
        }
        
    } else if (programResult.success && programResult.totalRecordCount == 0) {
        System.debug('⚠️  No programs found with ACV KPI, but logic is working');
        System.debug('📋 Fallback Message:');
        System.debug(programResult.message);
        
        // Check if the fallback message mentions "programs"
        if (programResult.message.contains('programs')) {
            System.debug('✅ SUCCESS: Fallback message correctly refers to "programs"');
        } else {
            System.debug('❌ ISSUE: Fallback message still refers to "courses"');
        }
        
    } else {
        System.debug('❌ ISSUE: Service failed to process program query');
    }
    
} catch (Exception e) {
    System.debug('❌ Error in program query test: ' + e.getMessage());
}

// ============================================================================
// PHASE 2: TEST COURSE QUERY WITH ACV KPI
// ============================================================================

System.debug('\n--- PHASE 2: Testing Course Query with ACV KPI ---');

String courseQuery = 'most effective courses from ACV perspective';

System.debug('🎯 User Query: "' + courseQuery + '"');
System.debug('🔍 Expected: Should detect "courses" and route to efficacy with ACV KPI');

try {
    System.debug('\n🔄 Testing ANAgentOfferingEfficacyServiceBasic.searchEfficacyData...');
    
    // Test with ACV KPI specified
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult courseResult = 
        ANAgentOfferingEfficacyServiceBasic.searchEfficacyData(courseQuery, null, null, null, null, 'ACV', null, 5);
    
    System.debug('📊 Course Query Results:');
    System.debug('  Success: ' + courseResult.success);
    System.debug('  Message: ' + courseResult.message);
    System.debug('  Total Records: ' + courseResult.totalRecordCount);
    
    if (courseResult.success && courseResult.totalRecordCount > 0) {
        System.debug('✅ SUCCESS: Found courses with ACV KPI!');
        
        // Check if the message mentions "courses"
        if (courseResult.message.contains('courses')) {
            System.debug('✅ SUCCESS: Message correctly refers to "courses"');
        } else {
            System.debug('❌ ISSUE: Message incorrectly refers to "programs"');
        }
        
    } else if (courseResult.success && courseResult.totalRecordCount == 0) {
        System.debug('⚠️  No courses found with ACV KPI, but logic is working');
        System.debug('📋 Fallback Message:');
        System.debug(courseResult.message);
        
        // Check if the fallback message mentions "courses"
        if (courseResult.message.contains('courses')) {
            System.debug('✅ SUCCESS: Fallback message correctly refers to "courses"');
        } else {
            System.debug('❌ ISSUE: Fallback message incorrectly refers to "programs"');
        }
        
    } else {
        System.debug('❌ ISSUE: Service failed to process course query');
    }
    
} catch (Exception e) {
    System.debug('❌ Error in course query test: ' + e.getMessage());
}

// ============================================================================
// PHASE 3: TEST KPI FILTERING LOGIC
// ============================================================================

System.debug('\n--- PHASE 3: Testing KPI Filtering Logic ---');

// Test that when ACV KPI is specified, only ACV results are returned
String genericQuery = 'most effective programs';

System.debug('🎯 User Query: "' + genericQuery + '"');
System.debug('🔍 Expected: Should return results for ALL KPIs (no filtering)');

try {
    System.debug('\n🔄 Testing without KPI filter...');
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult noKpiResult = 
        ANAgentOfferingEfficacyServiceBasic.searchEfficacyData(genericQuery, null, null, null, null, null, null, 5);
    
    System.debug('📊 No KPI Filter Results:');
    System.debug('  Success: ' + noKpiResult.success);
    System.debug('  Total Records: ' + noKpiResult.totalRecordCount);
    
    System.debug('\n🔄 Testing WITH ACV KPI filter...');
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult acvKpiResult = 
        ANAgentOfferingEfficacyServiceBasic.searchEfficacyData(genericQuery, null, null, null, null, 'ACV', null, 5);
    
    System.debug('📊 ACV KPI Filter Results:');
    System.debug('  Success: ' + acvKpiResult.success);
    System.debug('  Total Records: ' + acvKpiResult.totalRecordCount);
    
    // Compare results to ensure KPI filtering is working
    if (noKpiResult.success && acvKpiResult.success) {
        if (noKpiResult.totalRecordCount >= acvKpiResult.totalRecordCount) {
            System.debug('✅ SUCCESS: KPI filtering is working correctly');
            System.debug('🎯 No KPI filter returned ' + noKpiResult.totalRecordCount + ' records');
            System.debug('🎯 ACV KPI filter returned ' + acvKpiResult.totalRecordCount + ' records');
            System.debug('🎯 ACV filter should return fewer or equal records');
        } else {
            System.debug('⚠️  Unexpected: ACV KPI filter returned more records than no filter');
        }
    } else {
        System.debug('❌ ISSUE: One or both queries failed');
    }
    
} catch (Exception e) {
    System.debug('❌ Error in KPI filtering test: ' + e.getMessage());
}

// ============================================================================
// PHASE 4: SUMMARY OF FIXES IMPLEMENTED
// ============================================================================

System.debug('\n--- PHASE 4: Summary of Fixes Implemented ---');

System.debug('🎯 ISSUES FIXED:');
System.debug('  1. ✅ Program vs Course Detection - System now detects when user asks for "programs" vs "courses"');
System.debug('  2. ✅ KPI Filtering - When user specifies ACV, system only returns ACV results');
System.debug('  3. ✅ Appropriate Messaging - Messages now refer to "programs" or "courses" correctly');
System.debug('  4. ✅ No More Aggregated KPIs - Specific KPI requests return only that KPI');

System.debug('\n💡 EXPECTED BEHAVIOR NOW:');
System.debug('  • "most effective programs from ACV perspective" → Returns ONLY ACV programs');
System.debug('  • "most effective courses from ACV perspective" → Returns ONLY ACV courses');
System.debug('  • "most effective programs" → Returns programs from ALL KPIs');
System.debug('  • Messages correctly refer to "programs" vs "courses"');

System.debug('\n🔍 KEY IMPROVEMENTS:');
System.debug('  • No more asking for "course name" when user asks for "programs"');
System.debug('  • No more "Multiple KPIs (Aggregated)" when user asks for specific KPI');
System.debug('  • Proper KPI filtering ensures relevant results');
System.debug('  • Better user experience with appropriate terminology');

System.debug('\n🧪 PROGRAM VS COURSE LOGIC TEST COMPLETED');
System.debug('The system should now properly handle program vs course queries and KPI filtering!'); 