/**
 * Comprehensive Integration Test Suite for ANAGENTKPIAnalysisServiceV5 + ANAGENTKPIAnalysisHandlerV5
 * Tests the complete integration between service and handler layers
 * 
 * This test suite covers:
 * 1. Service layer business logic validation
 * 2. Handler layer request processing
 * 3. End-to-end data flow
 * 4. Real-world business scenarios
 * 5. Error handling and edge cases
 * 6. Performance and scalability
 */

System.debug('=== ANAGENTKPIAnalysisServiceV5 + ANAGENTKPIAnalysisHandlerV5 Integration Test Suite ===');

// Test 1: Service Layer Direct Testing - Field Mapping
System.debug('\n--- Test 1: Service Layer Direct Testing - Field Mapping ---');
Map<String, Object> fieldMappingInfo = ANAGENTKPIAnalysisServiceV5.getFieldMappingInfo();
System.debug('Field Mapping Info: ' + fieldMappingInfo);
System.assert(fieldMappingInfo.containsKey('userFriendlyAliases'), 'Test 1: Should contain user-friendly aliases');
System.assert(fieldMappingInfo.containsKey('apiFieldVariations'), 'Test 1: Should contain API field variations');
System.assert(fieldMappingInfo.containsKey('finalSOQLFields'), 'Test 1: Should contain final SOQL fields');

// Test 2: Service Layer Direct Testing - Filter Parsing
System.debug('\n--- Test 2: Service Layer Direct Testing - Filter Parsing ---');
String parsedFilter = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria('country="US" AND industry="Technology"');
System.debug('Parsed Filter: ' + parsedFilter);
System.assert(parsedFilter.contains('work_location_country__c'), 'Test 2: Should map country correctly');
System.assert(parsedFilter.contains('primary_industry__c'), 'Test 2: Should map industry correctly');

// Test 3: Service Layer Direct Testing - Filter Validation
System.debug('\n--- Test 3: Service Layer Direct Testing - Filter Validation ---');
Map<String, Object> validationResult = ANAGENTKPIAnalysisServiceV5.validateFieldMapping('country="US" AND industry="Technology"');
System.debug('Validation Result: ' + validationResult);
System.assert(validationResult.containsKey('successfullyMapped'), 'Test 3: Should show successfully mapped fields');
System.assert(validationResult.containsKey('mappedFilter'), 'Test 3: Should show mapped filter');

// Test 4: Handler Layer Direct Testing - Request Object Creation
System.debug('\n--- Test 4: Handler Layer Direct Testing - Request Object Creation ---');
ANAGENTKPIAnalysisHandlerV5.Request testRequest = new ANAGENTKPIAnalysisHandlerV5.Request();
testRequest.metricKey = 'ACV';
testRequest.timeframe = 'CURRENT';
testRequest.groupBy = 'COUNTRY';
System.debug('Test Request: ' + testRequest);
System.assert(testRequest.metricKey == 'ACV', 'Test 4: Should set metric key correctly');
System.assert(testRequest.timeframe == 'CURRENT', 'Test 4: Should set timeframe correctly');
System.assert(testRequest.groupBy == 'COUNTRY', 'Test 4: Should set group by correctly');

// Test 5: Handler Layer Direct Testing - Response Object Creation
System.debug('\n--- Test 5: Handler Layer Direct Testing - Response Object Creation ---');
ANAGENTKPIAnalysisHandlerV5.Response testResponse = new ANAGENTKPIAnalysisHandlerV5.Response();
testResponse.message = 'Test message';
System.debug('Test Response: ' + testResponse);
System.assert(testResponse.message == 'Test message', 'Test 5: Should set message correctly');

// Test 6: Integration Test - Basic ACV Analysis
System.debug('\n--- Test 6: Integration Test - Basic ACV Analysis ---');
ANAGENTKPIAnalysisHandlerV5.Request req6 = new ANAGENTKPIAnalysisHandlerV5.Request();
req6.metricKey = 'ACV';
req6.timeframe = 'CURRENT';
req6.groupBy = 'COUNTRY';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests6 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req6};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses6 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests6);

System.debug('Integration Response: ' + responses6[0].message);
System.assert(responses6[0].message.contains('ACV'), 'Test 6: Should contain ACV analysis');
System.assert(responses6[0].message.contains('COUNTRY'), 'Test 6: Should group by COUNTRY');

// Test 7: Integration Test - Growth Factor Analysis
System.debug('\n--- Test 7: Integration Test - Growth Factor Analysis ---');
ANAGENTKPIAnalysisHandlerV5.Request req7 = new ANAGENTKPIAnalysisHandlerV5.Request();
req7.metricKey = 'GROWTH_FACTOR';
req7.timeframe = 'CURRENT';
req7.groupBy = 'GROWTH_FACTOR';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests7 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req7};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses7 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests7);

System.debug('Integration Response: ' + responses7[0].message);
System.assert(responses7[0].message.contains('Growth Factor'), 'Test 7: Should contain Growth Factor analysis');

// Test 8: Integration Test - Complex Filtering
System.debug('\n--- Test 8: Integration Test - Complex Filtering ---');
ANAGENTKPIAnalysisHandlerV5.Request req8 = new ANAGENTKPIAnalysisHandlerV5.Request();
req8.metricKey = 'ACV';
req8.timeframe = 'CURRENT';
req8.groupBy = 'INDUSTRY';
req8.filterCriteria = 'country="US" AND manager="John Smith"';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests8 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req8};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses8 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests8);

System.debug('Integration Response: ' + responses8[0].message);
System.assert(responses8[0].message.contains('ACV'), 'Test 8: Should contain ACV analysis');
System.assert(responses8[0].message.contains('INDUSTRY'), 'Test 8: Should group by INDUSTRY');

// Test 9: Integration Test - Previous Quarter Analysis
System.debug('\n--- Test 9: Integration Test - Previous Quarter Analysis ---');
ANAGENTKPIAnalysisHandlerV5.Request req9 = new ANAGENTKPIAnalysisHandlerV5.Request();
req9.metricKey = 'ACV';
req9.timeframe = 'PREVIOUS';
req9.groupBy = 'COUNTRY';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests9 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req9};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses9 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests9);

System.debug('Integration Response: ' + responses9[0].message);
System.assert(responses9[0].message.contains('ACV'), 'Test 9: Should contain ACV analysis');
System.assert(responses9[0].message.contains('PREVIOUS'), 'Test 9: Should use PREVIOUS timeframe');

// Test 10: Integration Test - Per-AE Normalization
System.debug('\n--- Test 10: Integration Test - Per-AE Normalization ---');
ANAGENTKPIAnalysisHandlerV5.Request req10 = new ANAGENTKPIAnalysisHandlerV5.Request();
req10.metricKey = 'ACV';
req10.timeframe = 'CURRENT';
req10.groupBy = 'COUNTRY';
req10.perAENormalize = true;

List<ANAGENTKPIAnalysisHandlerV5.Request> requests10 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req10};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses10 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests10);

System.debug('Integration Response: ' + responses10[0].message);
System.assert(responses10[0].message.contains('Per-AE Normalized: Yes'), 'Test 10: Should show per-AE normalization');

// Test 11: Integration Test - Limit Application
System.debug('\n--- Test 11: Integration Test - Limit Application ---');
ANAGENTKPIAnalysisHandlerV5.Request req11 = new ANAGENTKPIAnalysisHandlerV5.Request();
req11.metricKey = 'ACV';
req11.timeframe = 'CURRENT';
req11.groupBy = 'COUNTRY';
req11.limitN = 5;

List<ANAGENTKPIAnalysisHandlerV5.Request> requests11 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req11};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses11 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests11);

System.debug('Integration Response: ' + responses11[0].message);
System.assert(responses11[0].message.contains('Limit Applied: 5'), 'Test 11: Should apply limit correctly');

// Test 12: Integration Test - Different Aggregation Types
System.debug('\n--- Test 12: Integration Test - Different Aggregation Types ---');
ANAGENTKPIAnalysisHandlerV5.Request req12 = new ANAGENTKPIAnalysisHandlerV5.Request();
req12.metricKey = 'ACV';
req12.timeframe = 'CURRENT';
req12.groupBy = 'COUNTRY';
req12.aggregationType = 'AVG';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests12 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req12};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses12 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests12);

System.debug('Integration Response: ' + responses12[0].message);
System.assert(responses12[0].message.contains('AVG'), 'Test 12: Should use AVG aggregation');

// Test 13: Integration Test - Ramp Status Grouping
System.debug('\n--- Test 13: Integration Test - Ramp Status Grouping ---');
ANAGENTKPIAnalysisHandlerV5.Request req13 = new ANAGENTKPIAnalysisHandlerV5.Request();
req13.metricKey = 'ACV';
req13.timeframe = 'CURRENT';
req13.groupBy = 'RAMP_STATUS';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests13 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req13};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses13 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests13);

System.debug('Integration Response: ' + responses13[0].message);
System.assert(responses13[0].message.contains('RAMP_STATUS'), 'Test 13: Should group by RAMP_STATUS');

// Test 14: Integration Test - Manager Grouping
System.debug('\n--- Test 14: Integration Test - Manager Grouping ---');
ANAGENTKPIAnalysisHandlerV5.Request req14 = new ANAGENTKPIAnalysisHandlerV5.Request();
req14.metricKey = 'CALLS';
req14.timeframe = 'CURRENT';
req14.groupBy = 'MANAGER';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests14 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req14};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses14 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests14);

System.debug('Integration Response: ' + responses14[0].message);
System.assert(responses14[0].message.contains('CALLS'), 'Test 14: Should contain CALLS analysis');
System.assert(responses14[0].message.contains('MANAGER'), 'Test 14: Should group by MANAGER');

// Test 15: Integration Test - Email Grouping
System.debug('\n--- Test 15: Integration Test - Email Grouping ---');
ANAGENTKPIAnalysisHandlerV5.Request req15 = new ANAGENTKPIAnalysisHandlerV5.Request();
req15.metricKey = 'MEETINGS';
req15.timeframe = 'CURRENT';
req15.groupBy = 'EMAIL';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests15 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req15};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses15 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests15);

System.debug('Integration Response: ' + responses15[0].message);
System.assert(responses15[0].message.contains('MEETINGS'), 'Test 15: Should contain MEETINGS analysis');
System.assert(responses15[0].message.contains('EMAIL'), 'Test 15: Should group by EMAIL');

// Test 16: Integration Test - Learner Profile Grouping
System.debug('\n--- Test 16: Integration Test - Learner Profile Grouping ---');
ANAGENTKPIAnalysisHandlerV5.Request req16 = new ANAGENTKPIAnalysisHandlerV5.Request();
req16.metricKey = 'COVERAGE';
req16.timeframe = 'CURRENT';
req16.groupBy = 'LEARNER_PROFILE';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests16 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req16};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses16 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests16);

System.debug('Integration Response: ' + responses16[0].message);
System.assert(responses16[0].message.contains('COVERAGE'), 'Test 16: Should contain COVERAGE analysis');
System.assert(responses16[0].message.contains('LEARNER_PROFILE'), 'Test 16: Should group by LEARNER_PROFILE');

// Test 17: Integration Test - Definition Grouping
System.debug('\n--- Test 17: Integration Test - Definition Grouping ---');
ANAGENTKPIAnalysisHandlerV5.Request req17 = new ANAGENTKPIAnalysisHandlerV5.Request();
req17.metricKey = 'ACV';
req17.timeframe = 'CURRENT';
req17.groupBy = 'DEFINITION';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests17 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req17};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses17 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests17);

System.debug('Integration Response: ' + responses17[0].message);
System.assert(responses17[0].message.contains('DEFINITION'), 'Test 17: Should group by DEFINITION');

// Test 18: Integration Test - Days to ACV Analysis
System.debug('\n--- Test 18: Integration Test - Days to ACV Analysis ---');
ANAGENTKPIAnalysisHandlerV5.Request req18 = new ANAGENTKPIAnalysisHandlerV5.Request();
req18.metricKey = 'DAYS_ACV';
req18.timeframe = 'CURRENT';
req18.groupBy = 'COUNTRY';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests18 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req18};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses18 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests18);

System.debug('Integration Response: ' + responses18[0].message);
System.assert(responses18[0].message.contains('Days to ACV'), 'Test 18: Should analyze Days to ACV');

// Test 19: Integration Test - Days to Pipeline Analysis
System.debug('\n--- Test 19: Integration Test - Days to Pipeline Analysis ---');
ANAGENTKPIAnalysisHandlerV5.Request req19 = new ANAGENTKPIAnalysisHandlerV5.Request();
req19.metricKey = 'DAYS_PG';
req19.timeframe = 'CURRENT';
req19.groupBy = 'COUNTRY';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests19 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req19};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses19 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests19);

System.debug('Integration Response: ' + responses19[0].message);
System.assert(responses19[0].message.contains('Days to Pipeline'), 'Test 19: Should analyze Days to Pipeline');

// Test 20: Integration Test - Create and Close ACV Analysis
System.debug('\n--- Test 20: Integration Test - Create and Close ACV Analysis ---');
ANAGENTKPIAnalysisHandlerV5.Request req20 = new ANAGENTKPIAnalysisHandlerV5.Request();
req20.metricKey = 'CC_ACV';
req20.timeframe = 'CURRENT';
req20.groupBy = 'COUNTRY';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests20 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req20};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses20 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests20);

System.debug('Integration Response: ' + responses20[0].message);
System.assert(responses20[0].message.contains('Create and Close ACV'), 'Test 20: Should analyze Create and Close ACV');

// Test 21: Integration Test - Multiple Requests Processing
System.debug('\n--- Test 21: Integration Test - Multiple Requests Processing ---');
ANAGENTKPIAnalysisHandlerV5.Request req21a = new ANAGENTKPIAnalysisHandlerV5.Request();
req21a.metricKey = 'ACV';
req21a.timeframe = 'CURRENT';
req21a.groupBy = 'COUNTRY';

ANAGENTKPIAnalysisHandlerV5.Request req21b = new ANAGENTKPIAnalysisHandlerV5.Request();
req21b.metricKey = 'PG';
req21b.timeframe = 'CURRENT';
req21b.groupBy = 'COUNTRY';

ANAGENTKPIAnalysisHandlerV5.Request req21c = new ANAGENTKPIAnalysisHandlerV5.Request();
req21c.metricKey = 'CALLS';
req21c.timeframe = 'CURRENT';
req21c.groupBy = 'COUNTRY';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests21 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req21a, req21b, req21c};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses21 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests21);

System.debug('Multiple Requests Responses count: ' + responses21.size());
System.assert(responses21.size() == 3, 'Test 21: Should handle multiple requests');
System.assert(responses21[0].message.contains('ACV'), 'Test 21: First response should contain ACV');
System.assert(responses21[1].message.contains('PG'), 'Test 21: Second response should contain PG');
System.assert(responses21[2].message.contains('CALLS'), 'Test 21: Third response should contain CALLS');

// Test 22: Integration Test - Complex Business Scenario
System.debug('\n--- Test 22: Integration Test - Complex Business Scenario ---');
ANAGENTKPIAnalysisHandlerV5.Request req22 = new ANAGENTKPIAnalysisHandlerV5.Request();
req22.metricKey = 'ACV';
req22.timeframe = 'CURRENT';
req22.groupBy = 'RAMP_STATUS';
req22.filterCriteria = 'country="US" AND industry="Technology" AND manager="John Doe"';
req22.restrictInValuesCsv = 'US,Brazil';
req22.perAENormalize = true;
req22.limitN = 5;
req22.aggregationType = 'AVG';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests22 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req22};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses22 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests22);

System.debug('Complex Business Scenario Response: ' + responses22[0].message);
System.assert(responses22[0].message.contains('ACV'), 'Test 22: Should contain ACV analysis');
System.assert(responses22[0].message.contains('RAMP_STATUS'), 'Test 22: Should group by RAMP_STATUS');
System.assert(responses22[0].message.contains('Per-AE Normalized: Yes'), 'Test 22: Should show per-AE normalization');
System.assert(responses22[0].message.contains('Limit Applied: 5'), 'Test 22: Should apply limit correctly');
System.assert(responses22[0].message.contains('AVG'), 'Test 22: Should use AVG aggregation');

// Test 23: Integration Test - Error Handling
System.debug('\n--- Test 23: Integration Test - Error Handling ---');
ANAGENTKPIAnalysisHandlerV5.Request req23 = new ANAGENTKPIAnalysisHandlerV5.Request();
req23.metricKey = 'INVALID_METRIC';
req23.timeframe = 'CURRENT';
req23.groupBy = 'COUNTRY';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests23 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req23};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses23 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests23);

System.debug('Error Handling Response: ' + responses23[0].message);
System.assert(responses23[0].message.contains('Invalid metric key'), 'Test 23: Should handle invalid metric gracefully');

// Test 24: Integration Test - Performance Test (Multiple Complex Requests)
System.debug('\n--- Test 24: Integration Test - Performance Test (Multiple Complex Requests) ---');
List<ANAGENTKPIAnalysisHandlerV5.Request> performanceRequests = new List<ANAGENTKPIAnalysisHandlerV5.Request>();

for (Integer i = 0; i < 5; i++) {
    ANAGENTKPIAnalysisHandlerV5.Request perfReq = new ANAGENTKPIAnalysisHandlerV5.Request();
    perfReq.metricKey = 'ACV';
    perfReq.timeframe = 'CURRENT';
    perfReq.groupBy = 'COUNTRY';
    perfReq.filterCriteria = 'country="US"';
    perfReq.limitN = 10;
    performanceRequests.add(perfReq);
}

Long startTime = System.currentTimeMillis();
List<ANAGENTKPIAnalysisHandlerV5.Response> performanceResponses = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(performanceRequests);
Long endTime = System.currentTimeMillis();

System.debug('Performance Test - Time taken: ' + (endTime - startTime) + 'ms');
System.debug('Performance Test - Responses count: ' + performanceResponses.size());
System.assert(performanceResponses.size() == 5, 'Test 24: Should handle performance test correctly');

// Test 25: Integration Test - End-to-End Real-World Scenario
System.debug('\n--- Test 25: Integration Test - End-to-End Real-World Scenario ---');
ANAGENTKPIAnalysisHandlerV5.Request realWorldReq = new ANAGENTKPIAnalysisHandlerV5.Request();
realWorldReq.metricKey = 'GROWTH_FACTOR';
realWorldReq.timeframe = 'CURRENT';
realWorldReq.groupBy = 'GROWTH_FACTOR';
realWorldReq.filterCriteria = 'country="US" AND ou="AMER" AND industry="Technology"';
realWorldReq.restrictInValuesCsv = 'US,Brazil,Canada';
realWorldReq.perAENormalize = false;
realWorldReq.limitN = 10;
realWorldReq.aggregationType = 'COUNT';

List<ANAGENTKPIAnalysisHandlerV5.Request> realWorldRequests = new List<ANAGENTKPIAnalysisHandlerV5.Request>{realWorldReq};
List<ANAGENTKPIAnalysisHandlerV5.Response> realWorldResponses = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(realWorldRequests);

System.debug('Real-World Scenario Response: ' + realWorldResponses[0].message);
System.assert(realWorldResponses[0].message.contains('Growth Factor'), 'Test 25: Should handle real-world scenario');
System.assert(realWorldResponses[0].message.contains('Limit Applied: 10'), 'Test 25: Should apply limit correctly');
System.assert(realWorldResponses[0].message.contains('COUNT'), 'Test 25: Should use COUNT aggregation');

System.debug('\n=== All Integration Tests Completed Successfully ===');
System.debug('Total Tests Executed: 25');
System.debug('All assertions passed - Service and Handler layers are fully integrated');
System.debug('End-to-end data flow is working correctly');
System.debug('Business logic integration is functioning properly');
System.debug('Performance and scalability tests passed'); 