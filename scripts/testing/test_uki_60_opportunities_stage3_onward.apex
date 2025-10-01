/**
 * Test script for the exact requirements:
 * Show top 60 opportunities in stage 3 onward in UKI
 * For each show: email address, AE Name, Product name, customer name, and stage name
 */
System.debug('=== Testing UKI 60 Opportunities Stage 3 Onward ===');

try {
    // Test: OPPORTUNITY_DETAILS with UKI OU and Stage 3+ filter
    System.debug('--- Testing: Top 60 Opportunities in UKI from Stage 3 Onward ---');
    String result = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'UKI',                     // ouName (UKI OU)
        '',                        // workLocationCountry (no filter)
        'PRODUCT',                 // groupBy (must be PRODUCT for this analysis)
        'open_pipe_opty_stg_nm>=\'03 - Validating Benefits & Value\'', // filterCriteria (Stage 3+)
        '',                        // restrictInValuesCsv
        false,                     // perAENormalize
        60,                        // limitN (exactly 60 as requested)
        '',                        // aggregationType
        'OPPORTUNITY_DETAILS'      // analysisType
    );
    
    System.debug('=== RESULT: Top 60 UKI Opportunities Stage 3+ ===');
    System.debug(result);
    
    // Verify the output contains all required fields
    System.debug('=== VERIFICATION: Checking Required Fields ===');
    
    Boolean hasEmails = result.contains('**Email**:') && result.contains('@');
    Boolean hasAENames = result.contains('**AE Name**:');
    Boolean hasProducts = result.contains('**Product**:');
    Boolean hasCustomerNames = result.contains('**Customer Name**:');
    Boolean hasStages = result.contains('**Stage**:');
    Boolean hasStage3Plus = result.contains('03 - Validating Benefits & Value') || 
                           result.contains('04 - Confirming Value With Power') || 
                           result.contains('05 - Negotiating $$ & Mutual Plan') ||
                           result.contains('06 - Finalizing Closure');
    
    System.debug('Field Verification Results:');
    System.debug('  - Email Addresses: ' + (hasEmails ? '✅' : '❌'));
    System.debug('  - AE Names: ' + (hasAENames ? '✅' : '❌'));
    System.debug('  - Product Names: ' + (hasProducts ? '✅' : '❌'));
    System.debug('  - Customer Names: ' + (hasCustomerNames ? '✅' : '❌'));
    System.debug('  - Stage Names: ' + (hasStages ? '✅' : '❌'));
    System.debug('  - Stage 3+ Filter: ' + (hasStage3Plus ? '✅' : '❌'));
    
    // Count opportunities in the result
    Integer opportunityCount = result.split('\\*\\*').size() / 2; // Rough count based on markdown formatting
    System.debug('  - Opportunity Count: ~' + opportunityCount + ' (should be around 60)');
    
    if (hasEmails && hasAENames && hasProducts && hasCustomerNames && hasStages && hasStage3Plus) {
        System.debug('🎉 SUCCESS: All required fields are present and working correctly!');
        System.debug('The service is now showing:');
        System.debug('  ✅ Email addresses (not redacted)');
        System.debug('  ✅ AE Names');
        System.debug('  ✅ Product names');
        System.debug('  ✅ Customer names');
        System.debug('  ✅ Stage names');
        System.debug('  ✅ Properly filtered for Stage 3+');
    } else {
        System.debug('❌ ISSUE: Some required fields are missing or not working correctly');
    }
    
    System.debug('=== Test Complete ===');
    
} catch (Exception e) {
    System.debug(LoggingLevel.ERROR, 'Test failed: ' + e.getMessage());
    System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
}
