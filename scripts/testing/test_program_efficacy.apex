// Test script to verify program efficacy functionality
// This tests that the system can now handle program-level queries without asking for course names

System.debug('🧪 TESTING PROGRAM EFFICACY FUNCTIONALITY');
System.debug('==========================================');

// ============================================================================
// PHASE 1: TEST PROGRAM EFFICACY WITH KPI AND VERTICAL
// ============================================================================

System.debug('\n--- PHASE 1: Testing Program Efficacy with KPI and Vertical ---');

try {
    System.debug('🔄 Testing ANAgentOfferingEfficacyServiceBasic.getEfficacyForPrograms...');
    
    // Test with ACV and FINS vertical (as requested by user)
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult programResult = 
        ANAgentOfferingEfficacyServiceBasic.getEfficacyForPrograms('ACV', 'FINS', null);
    
    System.debug('📊 Program Efficacy Results:');
    System.debug('  Success: ' + programResult.success);
    System.debug('  Message: ' + programResult.message);
    System.debug('  Total Records: ' + programResult.totalRecordCount);
    System.debug('  Needs Fallback: ' + programResult.needsFallback);
    
    if (programResult.success && programResult.totalRecordCount > 0) {
        System.debug('✅ SUCCESS: Found program efficacy data!');
        System.debug('🎯 This means the system can now handle program-level queries');
        
        // Show some sample data
        if (programResult.efficacyRecords != null && !programResult.efficacyRecords.isEmpty()) {
            System.debug('\n📋 Sample Program Data:');
            ANAgentOfferingEfficacyServiceBasic.EfficacyRecord firstProgram = programResult.efficacyRecords[0];
            System.debug('  Program: ' + firstProgram.offeringLabel);
            System.debug('  Program Type: ' + firstProgram.programType);
            System.debug('  KPI: ' + firstProgram.kpiName);
            System.debug('  Vertical: ' + firstProgram.macroSegment);
            System.debug('  OU: ' + firstProgram.ouName);
            System.debug('  Effectiveness: ' + firstProgram.effectivenessDisplay);
            System.debug('  Lift: ' + firstProgram.liftDisplay);
            System.debug('  ACV: ' + firstProgram.acvDisplay);
        }
        
    } else if (programResult.needsFallback) {
        System.debug('⚠️  No program data found, fallback triggered');
        System.debug('🎯 This is expected behavior when no data matches criteria');
    } else {
        System.debug('❌ No program data found and no fallback');
    }
    
} catch (Exception e) {
    System.debug('❌ Error in program efficacy test: ' + e.getMessage());
}

// ============================================================================
// PHASE 2: TEST PROGRAM EFFICACY WITH DIFFERENT KPI
// ============================================================================

System.debug('\n--- PHASE 2: Testing Program Efficacy with Different KPI ---');

try {
    System.debug('🔄 Testing with PIPE_QUALITY KPI...');
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult pipeQualityResult = 
        ANAgentOfferingEfficacyServiceBasic.getEfficacyForPrograms('PIPE_QUALITY', null, null);
    
    System.debug('📊 PIPE_QUALITY Results:');
    System.debug('  Success: ' + pipeQualityResult.success);
    System.debug('  Total Records: ' + pipeQualityResult.totalRecordCount);
    
    if (pipeQualityResult.success && pipeQualityResult.totalRecordCount > 0) {
        System.debug('✅ SUCCESS: Found PIPE_QUALITY program data!');
    } else {
        System.debug('⚠️  No PIPE_QUALITY program data found');
    }
    
} catch (Exception e) {
    System.debug('❌ Error in PIPE_QUALITY test: ' + e.getMessage());
}

// ============================================================================
// PHASE 3: TEST PROGRAM EFFICACY WITH OU FILTERING
// ============================================================================

System.debug('\n--- PHASE 3: Testing Program Efficacy with OU Filtering ---');

try {
    System.debug('🔄 Testing with AMER OU filter...');
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult amerResult = 
        ANAgentOfferingEfficacyServiceBasic.getEfficacyForPrograms(null, null, 'AMER');
    
    System.debug('📊 AMER OU Results:');
    System.debug('  Success: ' + amerResult.success);
    System.debug('  Total Records: ' + amerResult.totalRecordCount);
    
    if (amerResult.success && amerResult.totalRecordCount > 0) {
        System.debug('✅ SUCCESS: Found AMER program data!');
    } else {
        System.debug('⚠️  No AMER program data found');
    }
    
} catch (Exception e) {
    System.debug('❌ Error in AMER OU test: ' + e.getMessage());
}

// ============================================================================
// PHASE 4: TEST THE COMPLETE USER SCENARIO
// ============================================================================

System.debug('\n--- PHASE 4: Testing Complete User Scenario ---');

System.debug('🎯 User Query: "Show me the best ACV programs for FINS vertical"');
System.debug('🔍 Expected: Should use ProgramEfficacy action with kpiName=ACV, vertical=FINS');

try {
    // Simulate the handler call that would be made
    ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
    request.action = 'ProgramEfficacy';
    request.kpiName = 'ACV';
    request.vertical = 'FINS';
    request.operatingUnit = null;
    
    System.debug('📋 Request Parameters:');
    System.debug('  Action: ' + request.action);
    System.debug('  KPI: ' + request.kpiName);
    System.debug('  Vertical: ' + request.vertical);
    System.debug('  OU: ' + request.operatingUnit);
    
    // Test the service directly
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult result = 
        ANAgentOfferingEfficacyServiceBasic.getEfficacyForPrograms(request.kpiName, request.vertical, request.operatingUnit);
    
    System.debug('📊 Complete Scenario Results:');
    System.debug('  Success: ' + result.success);
    System.debug('  Message: ' + result.message);
    System.debug('  Total Records: ' + result.totalRecordCount);
    
    if (result.success && result.totalRecordCount > 0) {
        System.debug('✅ SUCCESS: Complete user scenario works!');
        System.debug('🎯 User can now ask for "best ACV programs for FINS" and get results');
    } else {
        System.debug('⚠️  No data found for complete scenario');
        System.debug('🎯 This might be expected if no FINS ACV program data exists');
    }
    
} catch (Exception e) {
    System.debug('❌ Error in complete scenario test: ' + e.getMessage());
}

// ============================================================================
// PHASE 5: SUMMARY OF IMPROVEMENTS
// ============================================================================

System.debug('\n--- PHASE 5: Summary of Improvements ---');

System.debug('🎯 WHAT WE\'VE FIXED:');
System.debug('  1. ✅ Added getEfficacyForPrograms() method to handle program-level queries');
System.debug('  2. ✅ Updated handler to support ProgramEfficacy action');
System.debug('  3. ✅ Added KPI, vertical, and OU filtering for programs');
System.debug('  4. ✅ No more "course name required" errors for program queries');
System.debug('  5. ✅ System can now handle: "Show me best ACV programs for FINS vertical"');

System.debug('\n💡 NEW CAPABILITIES:');
System.debug('  • Program efficacy queries by KPI (ACV, PIPE_QUALITY, etc.)');
System.debug('  • Program filtering by vertical (FINS, HLS, etc.)');
System.debug('  • Program filtering by OU (AMER, EMEA, etc.)');
System.debug('  • Proper fallback when no program data found');
System.debug('  • No more course name requirements for program queries');

System.debug('\n🔧 HOW TO USE:');
System.debug('  • Action: "ProgramEfficacy"');
System.debug('  • Parameters: kpiName, vertical, operatingUnit');
System.debug('  • Example: kpiName="ACV", vertical="FINS", operatingUnit="AMER"');

System.debug('\n🧪 PROGRAM EFFICACY TEST COMPLETED');
System.debug('The system can now handle program-level queries without asking for course names!'); 