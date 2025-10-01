// Test to verify permission check is working correctly after updating ANGeneralService
// This should now work since the user has AEAE_AN_Agents_CRUD permission set assigned

System.debug('=== Testing Permission Check After Update ===');

// Test 1: Check if the permission check now works
try {
    // This should now work since the user has AEAE_AN_Agents_CRUD assigned
    Boolean hasPermission = ANGeneralService.hasPermission(ANGeneralService.PERM_LABEL_CRU);
    System.debug('✅ Permission check PASSED - hasPermission: ' + hasPermission);
    
    if (hasPermission) {
        System.debug('✅ User has the required permission set: ' + ANGeneralService.PERM_LABEL_CRU);
    } else {
        System.debug('❌ User does not have the required permission set');
    }
} catch (Exception e) {
    System.debug('❌ Permission check FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 2: Test the service method that was failing before
try {
    List<ANAGENTKPIAnalysisServiceV3.FilterableFieldInfo> fields = ANAGENTKPIAnalysisServiceV3.getDescriptiveFilterableFields();
    System.debug('✅ getDescriptiveFilterableFields PASSED - Found ' + fields.size() + ' fields');
} catch (Exception e) {
    System.debug('❌ getDescriptiveFilterableFields FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Permission Check Test Complete ===');
System.debug('If both tests passed, the agent should now start successfully!'); 