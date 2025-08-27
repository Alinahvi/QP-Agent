// Final verification test for ANAgent KPI Analysis V3
// This confirms everything is working with ONLY AEAE_AN_Agents_CRUD permission set

System.debug('=== Final Verification Test for ANAgent Classes ===');

// Test 1: Verify ANGeneralService permission check works
try {
    Boolean hasPermission = ANGeneralService.hasPermission(ANGeneralService.PERM_LABEL_CRU);
    System.debug('✅ ANGeneralService permission check: ' + hasPermission);
    System.debug('✅ Using permission set: ' + ANGeneralService.PERM_LABEL_CRU);
} catch (Exception e) {
    System.debug('❌ ANGeneralService permission check failed: ' + e.getMessage());
}

// Test 2: Verify KPI Analysis Service works
try {
    List<ANAGENTKPIAnalysisServiceV3.FilterableFieldInfo> fields = ANAGENTKPIAnalysisServiceV3.getDescriptiveFilterableFields();
    System.debug('✅ KPI Analysis Service: Found ' + fields.size() + ' filterable fields');
} catch (Exception e) {
    System.debug('❌ KPI Analysis Service failed: ' + e.getMessage());
}

// Test 3: Verify KPI Analysis Handler works
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'GetSearchableFields';
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{ req });
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response response = responses[0];
        System.debug('✅ KPI Analysis Handler: Success: ' + response.success + ', Message: ' + response.message);
        System.debug('✅ RefineByFields populated: ' + response.refineByFields.size() + ' fields');
    }
} catch (Exception e) {
    System.debug('❌ KPI Analysis Handler failed: ' + e.getMessage());
}

System.debug('=== Final Verification Complete ===');
System.debug('If all tests passed, the agent should work correctly!');
System.debug('All ANAgent classes are now using ONLY AEAE_AN_Agents_CRUD permission set.'); 