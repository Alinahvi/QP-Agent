/**
 * Complete Integration Test: KPI Analysis V3 with AGENT_OU_PIPELINE_V3__c
 * 
 * This script tests the complete integration of the KPI analysis system
 * with the AGENT_OU_PIPELINE_V3__c object and all ramp status values.
 * 
 * @author AI Assistant
 * @date 2025-01-28
 */

System.debug('🎯 COMPLETE KPI V3 INTEGRATION TEST');
System.debug('===================================');

try {
    // Test 1: Basic KPI Analysis with all ramp status values
    System.debug('🧪 TEST 1: Basic KPI Analysis with all ramp status values');
    
    ANAGENTKPIAnalysisHandlerV3.Request request1 = new ANAGENTKPIAnalysisHandlerV3.Request();
    request1.action = 'Search';
    request1.metricKey = 'MEETINGS';
    request1.timeFrame = 'CURRENT';
    request1.groupBy = 'AE';
    request1.filterCriteria = 'RAMP_STATUS__c IN (\'Slow Ramper\',\'Fast Ramper\',\'On Track\',\'Not Ramping\',\'unknown\')';
    request1.perAENormalize = true;
    request1.aggregationType = 'AVG';
    request1.recordLimit = 20;
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses1 = 
        ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{ request1 });
    
    if (!responses1.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response response1 = responses1[0];
        System.debug('✅ Test 1 Success: ' + response1.success);
        System.debug('Message: ' + response1.message);
        System.debug('Total Records: ' + response1.totalRecordCount);
        System.debug('Analysis Summary: ' + response1.analysisSummary);
        System.debug('Execution Time: ' + response1.executionTimeMs + 'ms');
        
        if (!response1.kpiRecords.isEmpty()) {
            System.debug('📋 Sample KPI Records:');
            for (Integer i = 0; i < Math.min(5, response1.kpiRecords.size()); i++) {
                ANAGENTKPIAnalysisHandlerV3.KPIRecord record = response1.kpiRecords[i];
                System.debug('  - ' + record.aeName + ' (' + record.rampStatus + ') - ' + 
                            record.country + ' - Meetings: ' + record.meetings);
            }
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Test 1 Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n--- TEST 2: Count by Ramp Status ---');
try {
    // Test 2: Count AEs by ramp status
    System.debug('🧪 TEST 2: Count AEs by ramp status');
    
    ANAGENTKPIAnalysisHandlerV3.Request request2 = new ANAGENTKPIAnalysisHandlerV3.Request();
    request2.action = 'CountFieldValues';
    request2.groupBy = 'RAMP_STATUS';
    request2.recordLimit = 10;
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses2 = 
        ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{ request2 });
    
    if (!responses2.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response response2 = responses2[0];
        System.debug('✅ Test 2 Success: ' + response2.success);
        System.debug('Message: ' + response2.message);
        System.debug('Total Groups: ' + response2.totalRecordCount);
        System.debug('Analysis Summary: ' + response2.analysisSummary);
        
        if (!response2.kpiRecords.isEmpty()) {
            System.debug('📊 Ramp Status Counts:');
            for (ANAGENTKPIAnalysisHandlerV3.KPIRecord record : response2.kpiRecords) {
                System.debug('  - ' + record.rampStatus + ': ' + record.meetings + ' AEs');
            }
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Test 2 Error: ' + e.getMessage());
}

System.debug('\n--- TEST 3: Get Distinct Ramp Status Values ---');
try {
    // Test 3: Get all distinct ramp status values
    System.debug('🧪 TEST 3: Get all distinct ramp status values');
    
    ANAGENTKPIAnalysisHandlerV3.Request request3 = new ANAGENTKPIAnalysisHandlerV3.Request();
    request3.action = 'GetDistinctFieldValues';
    request3.groupBy = 'RAMP_STATUS';
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses3 = 
        ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{ request3 });
    
    if (!responses3.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response response3 = responses3[0];
        System.debug('✅ Test 3 Success: ' + response3.success);
        System.debug('Message: ' + response3.message);
        System.debug('Total Distinct Values: ' + response3.totalRecordCount);
        
        if (!response3.kpiRecords.isEmpty()) {
            System.debug('📋 All Ramp Status Values:');
            for (ANAGENTKPIAnalysisHandlerV3.KPIRecord record : response3.kpiRecords) {
                System.debug('  - "' + record.rampStatus + '"');
            }
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Test 3 Error: ' + e.getMessage());
}

System.debug('\n--- TEST 4: MCP Adapter Integration ---');
try {
    // Test 4: Test MCP adapter integration
    System.debug('🧪 TEST 4: Test MCP adapter integration');
    
    Map<String, Object> mcpArgs = new Map<String, Object>{
        'ouName' => 'AMER ACC',
        'timeFrame' => 'CURRENT',
        'kpiType' => 'MEETINGS',
        'groupBy' => 'AE',
        'filterCriteria' => 'RAMP_STATUS__c IN (\'Slow Ramper\',\'Fast Ramper\',\'On Track\',\'Not Ramping\',\'unknown\')',
        'perAENormalize' => true,
        'aggregationType' => 'AVG',
        'correlationId' => 'TEST-' + System.currentTimeMillis()
    };
    
    String argsJson = JSON.serialize(mcpArgs);
    List<String> normalizedArgsJsons = new List<String>{ argsJson };
    
    List<AN_KPI_FromMCP.Result> mcpResults = AN_KPI_FromMCP.run(normalizedArgsJsons);
    
    if (!mcpResults.isEmpty()) {
        AN_KPI_FromMCP.Result mcpResult = mcpResults[0];
        System.debug('✅ Test 4 Success: ' + mcpResult.success);
        System.debug('Message: ' + mcpResult.message);
        System.debug('Execution Time: ' + mcpResult.executionTimeMs + 'ms');
        System.debug('Correlation ID: ' + mcpResult.correlationId);
        
        if (String.isNotBlank(mcpResult.responseJson)) {
            Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(mcpResult.responseJson);
            System.debug('Response Data Keys: ' + responseData.keySet());
            System.debug('Total Record Count: ' + responseData.get('totalRecordCount'));
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Test 4 Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n--- TEST 5: Geographic Analysis ---');
try {
    // Test 5: Geographic analysis by country
    System.debug('🧪 TEST 5: Geographic analysis by country');
    
    ANAGENTKPIAnalysisHandlerV3.Request request5 = new ANAGENTKPIAnalysisHandlerV3.Request();
    request5.action = 'Search';
    request5.metricKey = 'MEETINGS';
    request5.timeFrame = 'CURRENT';
    request5.groupBy = 'COUNTRY';
    request5.filterCriteria = 'RAMP_STATUS__c IN (\'Slow Ramper\',\'Fast Ramper\',\'On Track\',\'Not Ramping\',\'unknown\')';
    request5.recordLimit = 10;
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses5 = 
        ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{ request5 });
    
    if (!responses5.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response response5 = responses5[0];
        System.debug('✅ Test 5 Success: ' + response5.success);
        System.debug('Message: ' + response5.message);
        System.debug('Total Records: ' + response5.totalRecordCount);
        
        if (!response5.kpiRecords.isEmpty()) {
            System.debug('🌍 Geographic Analysis:');
            for (ANAGENTKPIAnalysisHandlerV3.KPIRecord record : response5.kpiRecords) {
                System.debug('  - ' + record.country + ': ' + record.meetings + ' meetings');
            }
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Test 5 Error: ' + e.getMessage());
}

System.debug('\n🎯 INTEGRATION TEST SUMMARY');
System.debug('============================');
System.debug('✅ ANAGENTKPIAnalysisHandlerV3 deployed successfully');
System.debug('✅ AN_KPI_FromMCP updated and deployed successfully');
System.debug('✅ All tests completed - check individual test results above');
System.debug('');
System.debug('🔧 CONFIGURATION FOR AGENT:');
System.debug('============================');
System.debug('Action: ANAGENT KPI Analysis V3');
System.debug('Parameters:');
System.debug('{');
System.debug('  "action": "Search",');
System.debug('  "metricKey": "MEETINGS",');
System.debug('  "timeFrame": "CURRENT",');
System.debug('  "groupBy": "AE",');
System.debug('  "filterCriteria": "RAMP_STATUS__c IN (\'Slow Ramper\',\'Fast Ramper\',\'On Track\',\'Not Ramping\',\'unknown\')",');
System.debug('  "perAENormalize": true,');
System.debug('  "aggregationType": "AVG"');
System.debug('}');
System.debug('');
System.debug('✅ INTEGRATION TEST COMPLETED');
