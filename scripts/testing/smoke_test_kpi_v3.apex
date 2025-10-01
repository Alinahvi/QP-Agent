// Quick smoke test for KPI Analysis V3 after fixes
// This tests the critical paths that were causing the "Invalid Config" error

System.debug('=== KPI Analysis V3 Smoke Test ===');

// Test 1: Get descriptive filterable fields (this was failing before)
try {
    List<ANAGENTKPIAnalysisServiceV3.FilterableFieldInfo> fields = ANAGENTKPIAnalysisServiceV3.getDescriptiveFilterableFields();
    System.debug('✅ getDescriptiveFilterableFields PASSED - Found ' + fields.size() + ' fields');
} catch (Exception e) {
    System.debug('❌ getDescriptiveFilterableFields FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 2: Search with required filter (this was failing due to missing fields)
try {
    Map<String, Object> filters = new Map<String, Object>{ 'OU Name' => 'AMER - FINS' };
    ANAGENTKPIAnalysisServiceV3.OpenPipeSearchResult result = ANAGENTKPIAnalysisServiceV3.searchOpenPipeRecords(null, filters, null, null, 5, 0);
    System.debug('✅ searchOpenPipeRecords PASSED - Found ' + result.totalCount + ' total records, returned ' + result.records.size());
} catch (Exception e) {
    System.debug('❌ searchOpenPipeRecords FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Smoke Test Complete ===');
System.debug('If both tests passed, the "Invalid Config" error should be resolved!'); 