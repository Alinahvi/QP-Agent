// Test script for ANAGENTKPIAnalysisServiceV3 and ANAGENTKPIAnalysisHandlerV3
// This script tests the basic functionality of both classes

// Test 1: Get descriptive filterable fields
System.debug('=== Testing getDescriptiveFilterableFields ===');
try {
    List<ANAGENTKPIAnalysisServiceV3.FilterableFieldInfo> fields = ANAGENTKPIAnalysisServiceV3.getDescriptiveFilterableFields();
    System.debug('Found ' + fields.size() + ' filterable fields');
    for (ANAGENTKPIAnalysisServiceV3.FilterableFieldInfo field : fields) {
        System.debug('Field: ' + field.label + ' (' + field.apiName + ') - ' + field.description);
    }
} catch (Exception e) {
    System.debug('Error getting filterable fields: ' + e.getMessage());
}

// Test 2: Get distinct values for OU Name field
System.debug('=== Testing getDistinctFieldValues for OU Name ===');
try {
    List<String> ouNames = ANAGENTKPIAnalysisServiceV3.getDistinctFieldValues('OU Name');
    System.debug('Found ' + ouNames.size() + ' distinct OU names');
    for (String ouName : ouNames) {
        System.debug('OU Name: ' + ouName);
    }
} catch (Exception e) {
    System.debug('Error getting distinct OU names: ' + e.getMessage());
}

// Test 3: Test handler with Search action
System.debug('=== Testing Handler Search Action ===');
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'Search';
    req.OuName = 'AMER - FINS'; // Required filter
    req.searchTerm = 'Test';
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
        System.debug('Search response - Success: ' + res.success + ', Message: ' + res.message);
        System.debug('Total records: ' + res.totalRecordCount);
        System.debug('Records returned: ' + (res.kpiRecords != null ? res.kpiRecords.size() : 0));
    }
} catch (Exception e) {
    System.debug('Error testing handler search: ' + e.getMessage());
}

// Test 4: Test handler with CountFieldValues action
System.debug('=== Testing Handler CountFieldValues Action ===');
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'CountFieldValues';
    req.countValuesForField = 'OU_NAME__c';
    req.OuName = 'AMER - FINS'; // Required filter
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
        System.debug('Count response - Success: ' + res.success + ', Message: ' + res.message);
        System.debug('Field value counts JSON: ' + res.fieldValueCountsJSON);
    }
} catch (Exception e) {
    System.debug('Error testing handler count: ' + e.getMessage());
}

// Test 5: Test handler with GetDistinctFieldValues action
System.debug('=== Testing Handler GetDistinctFieldValues Action ===');
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'GetDistinctFieldValues';
    req.fieldNameForValues = 'Primary Industry';
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
        System.debug('Distinct values response - Success: ' + res.success + ', Message: ' + res.message);
        System.debug('Field values: ' + res.fieldValues);
    }
} catch (Exception e) {
    System.debug('Error testing handler distinct values: ' + e.getMessage());
}

System.debug('=== KPI Analysis V3 Test Complete ==='); 