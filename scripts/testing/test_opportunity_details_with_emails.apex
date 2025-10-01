/**
 * Test script to verify OPPORTUNITY_DETAILS analysis shows all required fields
 * This tests the fix for missing email addresses and other fields
 */
System.debug('=== Testing OPPORTUNITY_DETAILS with All Required Fields ===');

try {
    // Test 1: OPPORTUNITY_DETAILS with UKI OU and stage filter
    System.debug('--- Test 1: OPPORTUNITY_DETAILS with UKI OU and Stage 3+ filter ---');
    String result1 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'UKI',                     // ouName (UKI OU exists!)
        '',                        // workLocationCountry (no filter)
        'PRODUCT',                 // groupBy (must be PRODUCT for this analysis)
        'open_pipe_opty_stg_nm>=\'03 - Validating Benefits & Value\'', // filterCriteria
        '',                        // restrictInValuesCsv
        false,                     // perAENormalize
        5,                         // limitN (test with 5 first)
        '',                        // aggregationType
        'OPPORTUNITY_DETAILS'      // analysisType
    );
    
    System.debug('Result 1 (OPPORTUNITY_DETAILS with Stage 3+ filter):');
    System.debug(result1);
    
    // Test 2: OPPORTUNITY_DETAILS with UKI OU and no stage filter (to see all stages)
    System.debug('--- Test 2: OPPORTUNITY_DETAILS with UKI OU and no stage filter ---');
    String result2 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'UKI',                     // ouName (UKI OU exists!)
        '',                        // workLocationCountry (no filter)
        'PRODUCT',                 // groupBy (must be PRODUCT for this analysis)
        '',                        // filterCriteria (no filter)
        '',                        // restrictInValuesCsv
        false,                     // perAENormalize
        3,                         // limitN (test with 3 first)
        '',                        // aggregationType
        'OPPORTUNITY_DETAILS'      // analysisType
    );
    
    System.debug('Result 2 (OPPORTUNITY_DETAILS with no stage filter):');
    System.debug(result2);
    
    // Test 3: Verify that emails are not redacted
    System.debug('--- Test 3: Verifying Email Addresses are Visible ---');
    if (result1.contains('@') && !result1.contains('[redacted]')) {
        System.debug('✅ SUCCESS: Email addresses are visible and not redacted');
    } else if (result1.contains('[redacted]')) {
        System.debug('❌ FAILURE: Email addresses are still redacted');
    } else if (!result1.contains('@')) {
        System.debug('❌ FAILURE: No email addresses found in output');
    }
    
    // Test 4: Verify all required fields are present
    System.debug('--- Test 4: Verifying All Required Fields are Present ---');
    Boolean hasAEName = result1.contains('**AE Name**:');
    Boolean hasEmail = result1.contains('**Email**:');
    Boolean hasProduct = result1.contains('**Product**:');
    Boolean hasCustomerName = result1.contains('**Customer Name**:');
    Boolean hasStage = result1.contains('**Stage**:');
    
    if (hasAEName && hasEmail && hasProduct && hasCustomerName && hasStage) {
        System.debug('✅ SUCCESS: All required fields are present');
        System.debug('  - AE Name: ' + hasAEName);
        System.debug('  - Email: ' + hasEmail);
        System.debug('  - Product: ' + hasProduct);
        System.debug('  - Customer Name: ' + hasCustomerName);
        System.debug('  - Stage: ' + hasStage);
    } else {
        System.debug('❌ FAILURE: Some required fields are missing');
        System.debug('  - AE Name: ' + hasAEName);
        System.debug('  - Email: ' + hasEmail);
        System.debug('  - Product: ' + hasProduct);
        System.debug('  - Customer Name: ' + hasCustomerName);
        System.debug('  - Stage: ' + hasStage);
    }
    
    System.debug('=== Test Complete ===');
    
} catch (Exception e) {
    System.debug(LoggingLevel.ERROR, 'Test failed: ' + e.getMessage());
    System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
}
