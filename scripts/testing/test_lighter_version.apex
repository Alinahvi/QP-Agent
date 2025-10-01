// Test script to verify the lighter, focused version is working
// This tests that the service now provides focused results and better user guidance

System.debug('🧪 TESTING LIGHTER, FOCUSED VERSION');
System.debug('=====================================');

// ============================================================================
// PHASE 1: TEST FOCUSED SEARCH (NO BROADENING)
// ============================================================================

System.debug('\n--- PHASE 1: Testing Focused Search (No Broadening) ---');

// Test the exact user scenario
String searchTerm = 'Data Cloud';

System.debug('🎯 Testing Search Term: "' + searchTerm + '"');
System.debug('🔍 Expected: Only exact matches, no broadening');

try {
    System.debug('\n🔄 Testing ANAgentOfferingEfficacyServiceBasic.searchEfficacyData...');
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult serviceResult = 
        ANAgentOfferingEfficacyServiceBasic.searchEfficacyData(searchTerm, null, null, null, null, null, null, 5);
    
    System.debug('📊 Focused Search Results:');
    System.debug('  Success: ' + serviceResult.success);
    System.debug('  Message: ' + serviceResult.message);
    System.debug('  Total Records: ' + serviceResult.totalRecordCount);
    
    if (serviceResult.success && serviceResult.efficacyRecords != null) {
        System.debug('  Records from Focused Search:');
        for (Integer i = 0; i < serviceResult.efficacyRecords.size(); i++) {
            ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record = serviceResult.efficacyRecords[i];
            System.debug('    ' + (i + 1) + '. ' + record.offeringLabel + ' (KPI: ' + record.kpiName + ')');
            
            // Check if this is the problematic offering
            if (record.offeringLabel == 'FY25 Solution Selling Showdown') {
                System.debug('      ❌ PROBLEM: This offering should NOT appear for Data Cloud search!');
            }
        }
        
        // Check for relevance
        Boolean allRelevant = true;
        for (ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record : serviceResult.efficacyRecords) {
            if (!record.offeringLabel.toLowerCase().contains('data cloud') && 
                !record.offeringLabel.toLowerCase().contains('data')) {
                allRelevant = false;
                System.debug('      ⚠️  QUESTIONABLE: ' + record.offeringLabel + ' may not be relevant');
            }
        }
        
        if (allRelevant) {
            System.debug('  ✅ All results appear relevant to Data Cloud');
        } else {
            System.debug('  ⚠️  Some results may not be relevant');
        }
        
    }
    
} catch (Exception e) {
    System.debug('❌ Error in focused search: ' + e.getMessage());
}

// ============================================================================
// PHASE 2: TEST COURSE EFFICACY (NO BROADENING)
// ============================================================================

System.debug('\n--- PHASE 2: Testing Course Efficacy (No Broadening) ---');

try {
    System.debug('🔄 Testing ANAgentOfferingEfficacyServiceBasic.getEfficacyForCourse...');
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult courseResult = 
        ANAgentOfferingEfficacyServiceBasic.getEfficacyForCourse(searchTerm);
    
    System.debug('📊 Course Efficacy Results:');
    System.debug('  Success: ' + courseResult.success);
    System.debug('  Message: ' + courseResult.message);
    System.debug('  Total Records: ' + courseResult.totalRecordCount);
    
    if (courseResult.success && courseResult.efficacyRecords != null) {
        System.debug('  Records from Course Efficacy:');
        for (Integer i = 0; i < courseResult.efficacyRecords.size(); i++) {
            ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record = courseResult.efficacyRecords[i];
            System.debug('    ' + (i + 1) + '. ' + record.offeringLabel + ' (KPI: ' + record.kpiName + ')');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error in course efficacy: ' + e.getMessage());
}

// ============================================================================
// PHASE 3: VERIFY USER GUIDANCE IMPROVEMENTS
// ============================================================================

System.debug('\n--- PHASE 3: Verifying User Guidance Improvements ---');

try {
    // Test with a broader term to see the guidance
    String broaderTerm = 'Data';
    
    System.debug('🔄 Testing with broader term: "' + broaderTerm + '"');
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult broaderResult = 
        ANAgentOfferingEfficacyServiceBasic.searchEfficacyData(broaderTerm, null, null, null, null, null, null, 5);
    
    if (broaderResult.success) {
        System.debug('📊 Broader Term Results:');
        System.debug('  Message: ' + broaderResult.message);
        System.debug('  Total Records: ' + broaderResult.totalRecordCount);
        
        if (broaderResult.summaryMetrics != null) {
            System.debug('\n📋 Summary Metrics (Check for user guidance):');
            System.debug(broaderResult.summaryMetrics);
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing broader term: ' + e.getMessage());
}

// ============================================================================
// PHASE 4: SUMMARY OF IMPROVEMENTS
// ============================================================================

System.debug('\n--- PHASE 4: Summary of Improvements ---');

System.debug('🔧 WHAT WE\'VE IMPROVED:');
System.debug('  1. ✅ Removed aggressive broadening logic');
System.debug('  2. ✅ Focused search on exact matches only');
System.debug('  3. ✅ Added instruction-based user guidance');
System.debug('  4. ✅ Made the code much lighter and focused');
System.debug('  5. ✅ Better error messages with suggestions');

System.debug('\n🎯 EXPECTED USER EXPERIENCE NOW:');
System.debug('  • User asks: "Show me top 5 effective courses on data cloud"');
System.debug('  • Agent returns: Only relevant Data Cloud offerings');
System.debug('  • No more unrelated results like "FY25 Solution Selling Showdown"');
System.debug('  • Clear guidance on how to ask better questions');
System.debug('  • Instructions for getting more specific data');

System.debug('\n💡 USER GUIDANCE FEATURES:');
System.debug('  • Pro tips on being more specific');
System.debug('  • Examples of better question formats');
System.debug('  • KPI-specific search suggestions');
System.debug('  • Clear metric explanations');

System.debug('\n🧪 LIGHTER VERSION TEST COMPLETED');
System.debug('The service should now be more focused and provide better user guidance!'); 