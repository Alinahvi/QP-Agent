// Test the new DTO structure after promoting inner classes to top-level
System.debug('=== Testing New DTO Structure ===');

// Test 1: Verify AN_KPIRecord can be instantiated
try {
    AN_KPIRecord record = new AN_KPIRecord();
    record.empId = 'TEST001';
    record.fullName = 'Test User';
    record.cqAcv = 100000;
    
    System.debug('✅ AN_KPIRecord instantiation PASSED');
    System.debug('✅ Record created: ' + record.fullName + ' - ACV: ' + record.cqAcv);
} catch (Exception e) {
    System.debug('❌ AN_KPIRecord instantiation FAILED: ' + e.getMessage());
}

// Test 2: Verify service can still be called (should work now with top-level DTO)
try {
    List<ANAGENTKPIAnalysisServiceV3.FilterableFieldInfo> fields = ANAGENTKPIAnalysisServiceV3.getDescriptiveFilterableFields();
    System.debug('✅ Service call PASSED - Found ' + fields.size() + ' filterable fields');
} catch (Exception e) {
    System.debug('❌ Service call FAILED: ' + e.getMessage());
}

// Test 3: Verify handler can be called
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'GetSearchableFields';
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{ req });
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response response = responses[0];
        System.debug('✅ Handler call PASSED - Success: ' + response.success);
        System.debug('✅ RefineByFields count: ' + response.refineByFields.size());
    }
} catch (Exception e) {
    System.debug('❌ Handler call FAILED: ' + e.getMessage());
}

System.debug('=== New DTO Structure Test Complete ===');
System.debug('If all tests passed, the schema introspection issue should be resolved!');
System.debug('Next: Test in Agentforce Builder with the action.'); 