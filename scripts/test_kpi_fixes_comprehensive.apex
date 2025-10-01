/**
 * Comprehensive KPI Analysis V3 Test Script
 * Tests the fixed SOQL syntax and investigates data availability issues
 * @author AI Assistant
 * @version 1.0
 */

System.debug('=== KPI Analysis V3 Comprehensive Test ===');
System.debug('Testing fixed SOQL syntax and data availability');

// Test 1: Data Availability Investigation
System.debug('\n=== 1. Data Availability Investigation ===');
try {
    // Check total records
    Integer totalRecords = [SELECT COUNT() FROM AGENT_OU_PIPELINE_V3__c];
    System.debug('Total records in AGENT_OU_PIPELINE_V3__c: ' + totalRecords);
    
    // Check records by OU
    List<AggregateResult> ouCounts = [SELECT OU_NAME__c, COUNT(Id) recordCount 
                                     FROM AGENT_OU_PIPELINE_V3__c 
                                     WHERE OU_NAME__c != null 
                                     GROUP BY OU_NAME__c 
                                     ORDER BY COUNT(Id) DESC];
    
    System.debug('Records by OU:');
    for (AggregateResult result : ouCounts) {
        System.debug('- ' + result.get('OU_NAME__c') + ': ' + result.get('recordCount') + ' records');
    }
    
    // Check records by country
    List<AggregateResult> countryCounts = [SELECT WORK_LOCATION_COUNTRY__c, COUNT(Id) recordCount 
                                          FROM AGENT_OU_PIPELINE_V3__c 
                                          WHERE WORK_LOCATION_COUNTRY__c != null 
                                          GROUP BY WORK_LOCATION_COUNTRY__c 
                                          ORDER BY COUNT(Id) DESC];
    
    System.debug('Records by Country:');
    for (AggregateResult result : countryCounts) {
        System.debug('- ' + result.get('WORK_LOCATION_COUNTRY__c') + ': ' + result.get('recordCount') + ' records');
    }
    
    // Check records by ramp status
    List<AggregateResult> rampCounts = [SELECT RAMP_STATUS__c, COUNT(Id) recordCount 
                                       FROM AGENT_OU_PIPELINE_V3__c 
                                       WHERE RAMP_STATUS__c != null 
                                       GROUP BY RAMP_STATUS__c 
                                       ORDER BY COUNT(Id) DESC];
    
    System.debug('Records by Ramp Status:');
    for (AggregateResult result : rampCounts) {
        System.debug('- ' + result.get('RAMP_STATUS__c') + ': ' + result.get('recordCount') + ' records');
    }
    
} catch (Exception e) {
    System.debug('Error investigating data: ' + e.getMessage());
}

// Test 2: Fixed CountFieldValues Action - RAMP_STATUS
System.debug('\n=== 2. Testing Fixed CountFieldValues - RAMP_STATUS ===');
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'CountFieldValues';
    req.groupBy = 'RAMP_STATUS';
    req.OuName = 'AMER'; // Use a known OU with data
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
        System.debug('RAMP_STATUS Count - Success: ' + res.success);
        System.debug('Message: ' + res.message);
        System.debug('Total groups: ' + res.totalRecordCount);
        if (res.kpiRecords != null) {
            for (ANAGENTKPIAnalysisHandlerV3.KPIRecord record : res.kpiRecords) {
                System.debug('- ' + record.rampStatus + ': ' + record.meetings + ' records');
            }
        }
    }
} catch (Exception e) {
    System.debug('Error testing RAMP_STATUS count: ' + e.getMessage());
}

// Test 3: Fixed CountFieldValues Action - COUNTRY
System.debug('\n=== 3. Testing Fixed CountFieldValues - COUNTRY ===');
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'CountFieldValues';
    req.groupBy = 'COUNTRY';
    req.OuName = 'AMER'; // Use a known OU with data
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
        System.debug('COUNTRY Count - Success: ' + res.success);
        System.debug('Message: ' + res.message);
        System.debug('Total groups: ' + res.totalRecordCount);
        if (res.kpiRecords != null) {
            for (ANAGENTKPIAnalysisHandlerV3.KPIRecord record : res.kpiRecords) {
                System.debug('- ' + record.country + ': ' + record.meetings + ' records');
            }
        }
    }
} catch (Exception e) {
    System.debug('Error testing COUNTRY count: ' + e.getMessage());
}

// Test 4: Fixed CountFieldValues Action - OU
System.debug('\n=== 4. Testing Fixed CountFieldValues - OU ===');
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'CountFieldValues';
    req.groupBy = 'OU';
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
        System.debug('OU Count - Success: ' + res.success);
        System.debug('Message: ' + res.message);
        System.debug('Total groups: ' + res.totalRecordCount);
        if (res.kpiRecords != null) {
            for (ANAGENTKPIAnalysisHandlerV3.KPIRecord record : res.kpiRecords) {
                System.debug('- ' + record.ouName + ': ' + record.meetings + ' records');
            }
        }
    }
} catch (Exception e) {
    System.debug('Error testing OU count: ' + e.getMessage());
}

// Test 5: Fixed CountFieldValues Action - INDUSTRY
System.debug('\n=== 5. Testing Fixed CountFieldValues - INDUSTRY ===');
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'CountFieldValues';
    req.groupBy = 'INDUSTRY';
    req.OuName = 'AMER'; // Use a known OU with data
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
        System.debug('INDUSTRY Count - Success: ' + res.success);
        System.debug('Message: ' + res.message);
        System.debug('Total groups: ' + res.totalRecordCount);
        if (res.kpiRecords != null) {
            for (ANAGENTKPIAnalysisHandlerV3.KPIRecord record : res.kpiRecords) {
                System.debug('- ' + record.industry + ': ' + record.meetings + ' records');
            }
        }
    }
} catch (Exception e) {
    System.debug('Error testing INDUSTRY count: ' + e.getMessage());
}

// Test 6: Error Handling - Invalid groupBy
System.debug('\n=== 6. Testing Error Handling - Invalid groupBy ===');
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

// Test 7: Error Handling - Missing groupBy
System.debug('\n=== 7. Testing Error Handling - Missing groupBy ===');
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

// Test 8: Search Action (should still work)
System.debug('\n=== 8. Testing Search Action (Control Test) ===');
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'Search';
    req.OuName = 'AMER';
    req.recordLimit = 5;
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
        System.debug('Search - Success: ' + res.success);
        System.debug('Message: ' + res.message);
        System.debug('Total records: ' + res.totalRecordCount);
    }
} catch (Exception e) {
    System.debug('Error testing search: ' + e.getMessage());
}

System.debug('\n=== Test Complete ===');
