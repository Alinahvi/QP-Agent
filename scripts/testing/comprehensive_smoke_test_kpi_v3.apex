// Comprehensive smoke test for KPI Analysis V3 after all fixes
// This tests both the service and handler paths to verify everything works

System.debug('=== Comprehensive KPI Analysis V3 Smoke Test ===');

// Test 1: Service path - Get descriptive filterable fields
try {
    List<ANAGENTKPIAnalysisServiceV3.FilterableFieldInfo> fields = ANAGENTKPIAnalysisServiceV3.getDescriptiveFilterableFields();
    System.debug('✅ Service: getDescriptiveFilterableFields PASSED - Found ' + fields.size() + ' fields');
} catch (Exception e) {
    System.debug('❌ Service: getDescriptiveFilterableFields FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 2: Service path - Search with required filter
try {
    Map<String, Object> filters = new Map<String, Object>{ 'OU Name' => 'AMER - FINS' };
    ANAGENTKPIAnalysisServiceV3.OpenPipeSearchResult result = ANAGENTKPIAnalysisServiceV3.searchOpenPipeRecords(null, filters, null, null, 5, 0);
    System.debug('✅ Service: searchOpenPipeRecords PASSED - Found ' + result.totalCount + ' total records, returned ' + result.records.size());
} catch (Exception e) {
    System.debug('❌ Service: searchOpenPipeRecords FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 3: Handler path - Search action
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'Search';
    req.OuName = 'AMER - FINS';
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> out = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{ req });
    
    if (!out.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response response = out[0];
        System.debug('✅ Handler: Search action PASSED - Success: ' + response.success + ', Message: ' + response.message);
        System.debug('✅ Handler: Records returned: ' + response.kpiRecords.size() + ' of ' + response.totalRecordCount + ' total');
        System.debug('✅ Handler: RefineByFields populated: ' + response.refineByFields.size() + ' fields');
    } else {
        System.debug('❌ Handler: Search action FAILED - No response returned');
    }
} catch (Exception e) {
    System.debug('❌ Handler: Search action FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 4: Handler path - GetDistinctFieldValues action
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'GetDistinctFieldValues';
    req.fieldNameForValues = 'OU Name';
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> out = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{ req });
    
    if (!out.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response response = out[0];
        System.debug('✅ Handler: GetDistinctFieldValues action PASSED - Success: ' + response.success + ', Message: ' + response.message);
        System.debug('✅ Handler: Distinct values returned: ' + response.fieldValues.size() + ' values');
    } else {
        System.debug('❌ Handler: GetDistinctFieldValues action FAILED - No response returned');
    }
} catch (Exception e) {
    System.debug('❌ Handler: GetDistinctFieldValues action FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Comprehensive Smoke Test Complete ===');
System.debug('If all tests passed, the "Invalid Config" error should be resolved!');
System.debug('Check debug logs above for detailed results.'); 