/**
 * Comprehensive End-to-End Test Suite for ANAGENTKPIAnalysisHandlerV5
 * Tests the complete flow from handler to service layer
 * 
 * This test suite covers:
 * 1. Handler request validation
 * 2. Smart parameter detection and auto-correction
 * 3. Service delegation
 * 4. Response formatting
 * 5. Error handling
 * 6. Business logic integration
 */

System.debug('=== ANAGENTKPIAnalysisHandlerV5 End-to-End Test Suite ===');

// Test 1: Basic Handler Request - ACV Analysis
System.debug('\n--- Test 1: Basic Handler Request - ACV Analysis ---');
ANAGENTKPIAnalysisHandlerV5.Request req1 = new ANAGENTKPIAnalysisHandlerV5.Request();
req1.metricKey = 'ACV';
req1.timeframe = 'CURRENT';
req1.groupBy = 'COUNTRY';
req1.filterCriteria = null;
req1.restrictInValuesCsv = null;
req1.perAENormalize = false;
req1.limitN = null;
req1.aggregationType = 'SUM';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests1 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req1};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses1 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests1);

System.debug('Response: ' + responses1[0].message);
System.assert(responses1.size() == 1, 'Test 1: Should return one response');
System.assert(responses1[0].message.contains('ACV'), 'Test 1: Should contain ACV analysis');
System.assert(responses1[0].message.contains('COUNTRY'), 'Test 1: Should be grouped by COUNTRY');

// Test 2: Handler with Default Values
System.debug('\n--- Test 2: Handler with Default Values ---');
ANAGENTKPIAnalysisHandlerV5.Request req2 = new ANAGENTKPIAnalysisHandlerV5.Request();
// Only set metricKey, let others default
req2.metricKey = 'PG';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests2 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req2};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses2 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests2);

System.debug('Response: ' + responses2[0].message);
System.assert(responses2[0].message.contains('PG'), 'Test 2: Should contain PG analysis');
System.assert(responses2[0].message.contains('CURRENT'), 'Test 2: Should default to CURRENT timeframe');
System.assert(responses2[0].message.contains('COUNTRY'), 'Test 2: Should default to COUNTRY grouping');

// Test 3: Smart Growth Factor Detection
System.debug('\n--- Test 3: Smart Growth Factor Detection ---');
ANAGENTKPIAnalysisHandlerV5.Request req3 = new ANAGENTKPIAnalysisHandlerV5.Request();
req3.groupBy = 'GROWTH_FACTOR';
// Don't set metricKey - should auto-detect

List<ANAGENTKPIAnalysisHandlerV5.Request> requests3 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req3};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses3 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests3);

System.debug('Response: ' + responses3[0].message);
System.assert(responses3[0].message.contains('Growth Factor'), 'Test 3: Should auto-detect Growth Factor metric');

// Test 4: Handler with Complex Filters
System.debug('\n--- Test 4: Handler with Complex Filters ---');
ANAGENTKPIAnalysisHandlerV5.Request req4 = new ANAGENTKPIAnalysisHandlerV5.Request();
req4.metricKey = 'ACV';
req4.timeframe = 'CURRENT';
req4.groupBy = 'INDUSTRY';
req4.filterCriteria = 'country="US" AND manager="John Smith"';
req4.perAENormalize = true;
req4.aggregationType = 'AVG';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests4 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req4};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses4 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests4);

System.debug('Response: ' + responses4[0].message);
System.assert(responses4[0].message.contains('ACV'), 'Test 4: Should contain ACV analysis');
System.assert(responses4[0].message.contains('INDUSTRY'), 'Test 4: Should group by INDUSTRY');
System.assert(responses4[0].message.contains('Per-AE Normalized: Yes'), 'Test 4: Should show per-AE normalization');

// Test 5: Handler with Limits
System.debug('\n--- Test 5: Handler with Limits ---');
ANAGENTKPIAnalysisHandlerV5.Request req5 = new ANAGENTKPIAnalysisHandlerV5.Request();
req5.metricKey = 'CALLS';
req5.timeframe = 'CURRENT';
req5.groupBy = 'COUNTRY';
req5.limitN = 3;
req5.aggregationType = 'SUM';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests5 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req5};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses5 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests5);

System.debug('Response: ' + responses5[0].message);
System.assert(responses5[0].message.contains('CALLS'), 'Test 5: Should contain CALLS analysis');
System.assert(responses5[0].message.contains('Limit Applied: 3'), 'Test 5: Should apply limit correctly');

// Test 6: Handler with Previous Quarter Analysis
System.debug('\n--- Test 6: Handler with Previous Quarter Analysis ---');
ANAGENTKPIAnalysisHandlerV5.Request req6 = new ANAGENTKPIAnalysisHandlerV5.Request();
req6.metricKey = 'ACV';
req6.timeframe = 'PREVIOUS';
req6.groupBy = 'COUNTRY';
req6.aggregationType = 'SUM';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests6 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req6};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses6 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests6);

System.debug('Response: ' + responses6[0].message);
System.assert(responses6[0].message.contains('ACV'), 'Test 6: Should contain ACV analysis');
System.assert(responses6[0].message.contains('PREVIOUS'), 'Test 6: Should use PREVIOUS timeframe');

// Test 7: Handler with Restricted Values
System.debug('\n--- Test 7: Handler with Restricted Values ---');
ANAGENTKPIAnalysisHandlerV5.Request req7 = new ANAGENTKPIAnalysisHandlerV5.Request();
req7.metricKey = 'PG';
req7.timeframe = 'CURRENT';
req7.groupBy = 'COUNTRY';
req7.restrictInValuesCsv = 'US,Brazil,Canada';
req7.aggregationType = 'SUM';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests7 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req7};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses7 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests7);

System.debug('Response: ' + responses7[0].message);
System.assert(responses7[0].message.contains('PG'), 'Test 7: Should contain PG analysis');
System.assert(responses7[0].message.contains('Results restricted to: US,Brazil,Canada'), 'Test 7: Should show restricted values');

// Test 8: Handler with Ramp Status Grouping
System.debug('\n--- Test 8: Handler with Ramp Status Grouping ---');
ANAGENTKPIAnalysisHandlerV5.Request req8 = new ANAGENTKPIAnalysisHandlerV5.Request();
req8.metricKey = 'ACV';
req8.timeframe = 'CURRENT';
req8.groupBy = 'RAMP_STATUS';
req8.aggregationType = 'SUM';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests8 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req8};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses8 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests8);

System.debug('Response: ' + responses8[0].message);
System.assert(responses8[0].message.contains('ACV'), 'Test 8: Should contain ACV analysis');
System.assert(responses8[0].message.contains('RAMP_STATUS'), 'Test 8: Should group by RAMP_STATUS');

// Test 9: Handler with Manager Grouping
System.debug('\n--- Test 9: Handler with Manager Grouping ---');
ANAGENTKPIAnalysisHandlerV5.Request req9 = new ANAGENTKPIAnalysisHandlerV5.Request();
req9.metricKey = 'CALLS';
req9.timeframe = 'CURRENT';
req9.groupBy = 'MANAGER';
req9.aggregationType = 'SUM';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests9 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req9};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses9 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests9);

System.debug('Response: ' + responses9[0].message);
System.assert(responses9[0].message.contains('CALLS'), 'Test 9: Should contain CALLS analysis');
System.assert(responses9[0].message.contains('MANAGER'), 'Test 9: Should group by MANAGER');

// Test 10: Handler with Email Grouping
System.debug('\n--- Test 10: Handler with Email Grouping ---');
ANAGENTKPIAnalysisHandlerV5.Request req10 = new ANAGENTKPIAnalysisHandlerV5.Request();
req10.metricKey = 'MEETINGS';
req10.timeframe = 'CURRENT';
req10.groupBy = 'EMAIL';
req10.aggregationType = 'SUM';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests10 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req10};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses10 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests10);

System.debug('Response: ' + responses10[0].message);
System.assert(responses10[0].message.contains('MEETINGS'), 'Test 10: Should contain MEETINGS analysis');
System.assert(responses10[0].message.contains('EMAIL'), 'Test 10: Should group by EMAIL');

// Test 11: Handler with Learner Profile Grouping
System.debug('\n--- Test 11: Handler with Learner Profile Grouping ---');
ANAGENTKPIAnalysisHandlerV5.Request req11 = new ANAGENTKPIAnalysisHandlerV5.Request();
req11.metricKey = 'COVERAGE';
req11.timeframe = 'CURRENT';
req11.groupBy = 'LEARNER_PROFILE';
req11.aggregationType = 'SUM';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests11 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req11};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses11 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests11);

System.debug('Response: ' + responses11[0].message);
System.assert(responses11[0].message.contains('COVERAGE'), 'Test 11: Should contain COVERAGE analysis');
System.assert(responses11[0].message.contains('LEARNER_PROFILE'), 'Test 11: Should group by LEARNER_PROFILE');

// Test 12: Handler with Definition Grouping
System.debug('\n--- Test 12: Handler with Definition Grouping ---');
ANAGENTKPIAnalysisHandlerV5.Request req12 = new ANAGENTKPIAnalysisHandlerV5.Request();
req12.metricKey = 'ACV';
req12.timeframe = 'CURRENT';
req12.groupBy = 'DEFINITION';
req12.aggregationType = 'SUM';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests12 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req12};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses12 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests12);

System.debug('Response: ' + responses12[0].message);
System.assert(responses12[0].message.contains('ACV'), 'Test 12: Should contain ACV analysis');
System.assert(responses12[0].message.contains('DEFINITION'), 'Test 12: Should group by DEFINITION');

// Test 13: Handler with Different Aggregation Types
System.debug('\n--- Test 13: Handler with Different Aggregation Types ---');
ANAGENTKPIAnalysisHandlerV5.Request req13 = new ANAGENTKPIAnalysisHandlerV5.Request();
req13.metricKey = 'ACV';
req13.timeframe = 'CURRENT';
req13.groupBy = 'COUNTRY';
req13.aggregationType = 'MAX';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests13 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req13};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses13 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests13);

System.debug('Response: ' + responses13[0].message);
System.assert(responses13[0].message.contains('ACV'), 'Test 13: Should contain ACV analysis');
System.assert(responses13[0].message.contains('MAX'), 'Test 13: Should use MAX aggregation');

// Test 14: Handler with MIN Aggregation
System.debug('\n--- Test 14: Handler with MIN Aggregation ---');
ANAGENTKPIAnalysisHandlerV5.Request req14 = new ANAGENTKPIAnalysisHandlerV5.Request();
req14.metricKey = 'DAYS_ACV';
req14.timeframe = 'CURRENT';
req14.groupBy = 'COUNTRY';
req14.aggregationType = 'MIN';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests14 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req14};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses14 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests14);

System.debug('Response: ' + responses14[0].message);
System.assert(responses14[0].message.contains('Days to ACV'), 'Test 14: Should contain Days to ACV analysis');
System.assert(responses14[0].message.contains('MIN'), 'Test 14: Should use MIN aggregation');

// Test 15: Handler with MEDIAN Aggregation
System.debug('\n--- Test 15: Handler with MEDIAN Aggregation ---');
ANAGENTKPIAnalysisHandlerV5.Request req15 = new ANAGENTKPIAnalysisHandlerV5.Request();
req15.metricKey = 'DAYS_PG';
req15.timeframe = 'CURRENT';
req15.groupBy = 'COUNTRY';
req15.aggregationType = 'MEDIAN';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests15 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req15};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses15 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests15);

System.debug('Response: ' + responses15[0].message);
System.assert(responses15[0].message.contains('Days to Pipeline'), 'Test 15: Should contain Days to Pipeline analysis');
System.assert(responses15[0].message.contains('MEDIAN'), 'Test 15: Should use MEDIAN aggregation');

// Test 16: Handler with COUNT Aggregation
System.debug('\n--- Test 16: Handler with COUNT Aggregation ---');
ANAGENTKPIAnalysisHandlerV5.Request req16 = new ANAGENTKPIAnalysisHandlerV5.Request();
req16.metricKey = 'ACV';
req16.timeframe = 'CURRENT';
req16.groupBy = 'COUNTRY';
req16.aggregationType = 'COUNT';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests16 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req16};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses16 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests16);

System.debug('Response: ' + responses16[0].message);
System.assert(responses16[0].message.contains('ACV'), 'Test 16: Should contain ACV analysis');
System.assert(responses16[0].message.contains('COUNT'), 'Test 16: Should use COUNT aggregation');

// Test 17: Handler with Empty Request List
System.debug('\n--- Test 17: Handler with Empty Request List ---');
List<ANAGENTKPIAnalysisHandlerV5.Request> emptyRequests = new List<ANAGENTKPIAnalysisHandlerV5.Request>();
List<ANAGENTKPIAnalysisHandlerV5.Response> emptyResponses = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(emptyRequests);

System.debug('Response: ' + emptyResponses[0].message);
System.assert(emptyResponses.size() == 1, 'Test 17: Should return one response for empty request');
System.assert(emptyResponses[0].message.contains('No request provided'), 'Test 17: Should handle empty request list');

// Test 18: Handler with Null Request
System.debug('\n--- Test 18: Handler with Null Request ---');
List<ANAGENTKPIAnalysisHandlerV5.Request> nullRequests = null;
List<ANAGENTKPIAnalysisHandlerV5.Response> nullResponses = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(nullRequests);

System.debug('Response: ' + nullResponses[0].message);
System.assert(nullResponses.size() == 1, 'Test 18: Should return one response for null request');
System.assert(nullResponses[0].message.contains('No request provided'), 'Test 18: Should handle null request list');

// Test 19: Handler with Invalid Metric
System.debug('\n--- Test 19: Handler with Invalid Metric ---');
ANAGENTKPIAnalysisHandlerV5.Request req19 = new ANAGENTKPIAnalysisHandlerV5.Request();
req19.metricKey = 'INVALID_METRIC';
req19.timeframe = 'CURRENT';
req19.groupBy = 'COUNTRY';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests19 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req19};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses19 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests19);

System.debug('Response: ' + responses19[0].message);
System.assert(responses19[0].message.contains('Invalid metric key'), 'Test 19: Should handle invalid metric');

// Test 20: Handler with Invalid Timeframe
System.debug('\n--- Test 20: Handler with Invalid Timeframe ---');
ANAGENTKPIAnalysisHandlerV5.Request req20 = new ANAGENTKPIAnalysisHandlerV5.Request();
req20.metricKey = 'ACV';
req20.timeframe = 'INVALID_TIMEFRAME';
req20.groupBy = 'COUNTRY';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests20 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req20};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses20 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests20);

System.debug('Response: ' + responses20[0].message);
System.assert(responses20[0].message.contains('Invalid timeframe'), 'Test 20: Should handle invalid timeframe');

// Test 21: Handler with Invalid Group By
System.debug('\n--- Test 21: Handler with Invalid Group By ---');
ANAGENTKPIAnalysisHandlerV5.Request req21 = new ANAGENTKPIAnalysisHandlerV5.Request();
req21.metricKey = 'ACV';
req21.timeframe = 'CURRENT';
req21.groupBy = 'INVALID_GROUPBY';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests21 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req21};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses21 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests21);

System.debug('Response: ' + responses21[0].message);
System.assert(responses21[0].message.contains('Invalid group by'), 'Test 21: Should handle invalid group by');

// Test 22: Handler with Invalid Aggregation Type
System.debug('\n--- Test 22: Handler with Invalid Aggregation Type ---');
ANAGENTKPIAnalysisHandlerV5.Request req22 = new ANAGENTKPIAnalysisHandlerV5.Request();
req22.metricKey = 'ACV';
req22.timeframe = 'CURRENT';
req22.groupBy = 'COUNTRY';
req22.aggregationType = 'INVALID_AGGREGATION';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests22 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req22};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses22 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests22);

System.debug('Response: ' + responses22[0].message);
System.assert(responses22[0].message.contains('Invalid aggregation type'), 'Test 22: Should handle invalid aggregation type');

// Test 23: Handler with Complex Business Scenario - Growth Factor Analysis
System.debug('\n--- Test 23: Handler with Complex Business Scenario - Growth Factor Analysis ---');
ANAGENTKPIAnalysisHandlerV5.Request req23 = new ANAGENTKPIAnalysisHandlerV5.Request();
req23.metricKey = 'GROWTH_FACTOR';
req23.timeframe = 'CURRENT';
req23.groupBy = 'GROWTH_FACTOR';
req23.filterCriteria = 'country="US" AND ou="AMER"';
req23.limitN = 5;
req23.aggregationType = 'COUNT';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests23 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req23};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses23 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests23);

System.debug('Response: ' + responses23[0].message);
System.assert(responses23[0].message.contains('Growth Factor'), 'Test 23: Should handle growth factor analysis');
System.assert(responses23[0].message.contains('Limit Applied: 5'), 'Test 23: Should apply limit correctly');

// Test 24: Handler with Multiple Metrics Test
System.debug('\n--- Test 24: Handler with Multiple Metrics Test ---');
ANAGENTKPIAnalysisHandlerV5.Request req24a = new ANAGENTKPIAnalysisHandlerV5.Request();
req24a.metricKey = 'ACV';
req24a.timeframe = 'CURRENT';
req24a.groupBy = 'COUNTRY';

ANAGENTKPIAnalysisHandlerV5.Request req24b = new ANAGENTKPIAnalysisHandlerV5.Request();
req24b.metricKey = 'PG';
req24b.timeframe = 'CURRENT';
req24b.groupBy = 'COUNTRY';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests24 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req24a, req24b};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses24 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests24);

System.debug('Responses count: ' + responses24.size());
System.assert(responses24.size() == 2, 'Test 24: Should handle multiple requests');
System.assert(responses24[0].message.contains('ACV'), 'Test 24: First response should contain ACV');
System.assert(responses24[1].message.contains('PG'), 'Test 24: Second response should contain PG');

// Test 25: End-to-End Integration Test
System.debug('\n--- Test 25: End-to-End Integration Test ---');
ANAGENTKPIAnalysisHandlerV5.Request req25 = new ANAGENTKPIAnalysisHandlerV5.Request();
req25.metricKey = 'ACV';
req25.timeframe = 'CURRENT';
req25.groupBy = 'COUNTRY';
req25.filterCriteria = 'country="US" AND industry="Technology" AND manager="John Doe"';
req25.restrictInValuesCsv = 'US,Brazil';
req25.perAENormalize = true;
req25.limitN = 3;
req25.aggregationType = 'AVG';

List<ANAGENTKPIAnalysisHandlerV5.Request> requests25 = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req25};
List<ANAGENTKPIAnalysisHandlerV5.Response> responses25 = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests25);

System.debug('Response: ' + responses25[0].message);
System.assert(responses25[0].message.contains('ACV'), 'Test 25: Should contain ACV analysis');
System.assert(responses25[0].message.contains('COUNTRY'), 'Test 25: Should group by COUNTRY');
System.assert(responses25[0].message.contains('Per-AE Normalized: Yes'), 'Test 25: Should show per-AE normalization');
System.assert(responses25[0].message.contains('Limit Applied: 3'), 'Test 25: Should apply limit correctly');
System.assert(responses25[0].message.contains('AVG'), 'Test 25: Should use AVG aggregation');

System.debug('\n=== All End-to-End Tests Completed Successfully ===');
System.debug('Total Tests Executed: 25');
System.debug('All assertions passed - Handler layer integration is working correctly');
System.debug('Service delegation, parameter validation, and response formatting are functioning properly'); 