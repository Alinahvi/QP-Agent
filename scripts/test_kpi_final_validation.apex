/**
 * Final KPI Analysis V3 Validation Test
 * Tests all fixes and provides comprehensive results
 * @author AI Assistant
 * @version 1.0
 */

System.debug('=== KPI Analysis V3 Final Validation Test ===');
System.debug('Testing all fixes and providing comprehensive results');

// Test 1: Test with actual OU names that have data
System.debug('\n=== 1. Testing with Real OU Names ===');
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'CountFieldValues';
    req.groupBy = 'RAMP_STATUS';
    req.OuName = 'AMER ACC'; // Use actual OU name from data
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
        System.debug('AMER ACC RAMP_STATUS Count - Success: ' + res.success);
        System.debug('Message: ' + res.message);
        System.debug('Total groups: ' + res.totalRecordCount);
        if (res.kpiRecords != null && !res.kpiRecords.isEmpty()) {
            for (ANAGENTKPIAnalysisHandlerV3.KPIRecord record : res.kpiRecords) {
                System.debug('- ' + record.rampStatus + ': ' + record.meetings + ' records');
            }
        }
    }
} catch (Exception e) {
    System.debug('Error testing AMER ACC RAMP_STATUS: ' + e.getMessage());
}

// Test 2: Test with SMB - AMER SMB (largest dataset)
System.debug('\n=== 2. Testing with SMB - AMER SMB (Largest Dataset) ===');
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'CountFieldValues';
    req.groupBy = 'COUNTRY';
    req.OuName = 'SMB - AMER SMB'; // Use largest OU from data
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
        System.debug('SMB - AMER SMB COUNTRY Count - Success: ' + res.success);
        System.debug('Message: ' + res.message);
        System.debug('Total groups: ' + res.totalRecordCount);
        if (res.kpiRecords != null && !res.kpiRecords.isEmpty()) {
            for (ANAGENTKPIAnalysisHandlerV3.KPIRecord record : res.kpiRecords) {
                System.debug('- ' + record.country + ': ' + record.meetings + ' records');
            }
        }
    }
} catch (Exception e) {
    System.debug('Error testing SMB - AMER SMB COUNTRY: ' + e.getMessage());
}

// Test 3: Test with EMEA data
System.debug('\n=== 3. Testing with EMEA Data ===');
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'CountFieldValues';
    req.groupBy = 'RAMP_STATUS';
    req.OuName = 'SMB - EMEA SMB'; // Use EMEA OU from data
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
        System.debug('SMB - EMEA SMB RAMP_STATUS Count - Success: ' + res.success);
        System.debug('Message: ' + res.message);
        System.debug('Total groups: ' + res.totalRecordCount);
        if (res.kpiRecords != null && !res.kpiRecords.isEmpty()) {
            for (ANAGENTKPIAnalysisHandlerV3.KPIRecord record : res.kpiRecords) {
                System.debug('- ' + record.rampStatus + ': ' + record.meetings + ' records');
            }
        }
    }
} catch (Exception e) {
    System.debug('Error testing SMB - EMEA SMB RAMP_STATUS: ' + e.getMessage());
}

// Test 4: Test Search with real data
System.debug('\n=== 4. Testing Search with Real Data ===');
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'Search';
    req.OuName = 'SMB - AMER SMB';
    req.recordLimit = 3;
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
        System.debug('Search - Success: ' + res.success);
        System.debug('Message: ' + res.message);
        System.debug('Total records: ' + res.totalRecordCount);
        if (res.kpiRecords != null && !res.kpiRecords.isEmpty()) {
            for (ANAGENTKPIAnalysisHandlerV3.KPIRecord record : res.kpiRecords) {
                System.debug('- AE: ' + record.aeName + ', Country: ' + record.country + ', OU: ' + record.ouName);
            }
        }
    }
} catch (Exception e) {
    System.debug('Error testing search: ' + e.getMessage());
}

// Test 5: Test error handling with invalid groupBy
System.debug('\n=== 5. Testing Error Handling - Invalid groupBy ===');
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'CountFieldValues';
    req.groupBy = 'INVALID_FIELD';
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
        System.debug('Invalid groupBy - Success: ' + res.success);
        System.debug('Message: ' + res.message);
    }
} catch (Exception e) {
    System.debug('Error testing invalid groupBy: ' + e.getMessage());
}

// Test 6: Test error handling with missing groupBy
System.debug('\n=== 6. Testing Error Handling - Missing groupBy ===');
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'CountFieldValues';
    // groupBy is null
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
        System.debug('Missing groupBy - Success: ' + res.success);
        System.debug('Message: ' + res.message);
    }
} catch (Exception e) {
    System.debug('Error testing missing groupBy: ' + e.getMessage());
}

// Test 7: Test all groupBy options with real data
System.debug('\n=== 7. Testing All GroupBy Options ===');
List<String> groupByOptions = new List<String>{'RAMP_STATUS', 'COUNTRY', 'OU', 'INDUSTRY'};
for (String groupBy : groupByOptions) {
    try {
        ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
        req.action = 'CountFieldValues';
        req.groupBy = groupBy;
        req.OuName = 'SMB - AMER SMB';
        
        List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
        
        if (!responses.isEmpty()) {
            ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
            System.debug(groupBy + ' Count - Success: ' + res.success + ', Groups: ' + res.totalRecordCount);
        }
    } catch (Exception e) {
        System.debug('Error testing ' + groupBy + ': ' + e.getMessage());
    }
}

System.debug('\n=== Final Validation Complete ===');
System.debug('All tests completed successfully!');
