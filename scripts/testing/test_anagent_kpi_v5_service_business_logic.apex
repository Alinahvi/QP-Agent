/**
 * Comprehensive UAT Test Suite for ANAGENTKPIAnalysisServiceV5
 * Tests business logic and edge cases for the KPI Analysis Service
 * 
 * This test suite covers 20 UAT scenarios focusing on:
 * 1. Field mapping and parsing
 * 2. Metric validation and auto-correction
 * 3. Filter criteria processing
 * 4. Business logic scenarios
 * 5. Edge cases and error handling
 */

System.debug('=== ANAGENTKPIAnalysisServiceV5 Business Logic UAT Test Suite ===');

// Test 1: Basic ACV Analysis by Country
System.debug('\n--- Test 1: Basic ACV Analysis by Country ---');
String result1 = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'COUNTRY', null, null, false, null, 'SUM');
System.debug('Result: ' + result1);
System.assert(result1.contains('ACV'), 'Test 1: Should contain ACV analysis');
System.assert(result1.contains('COUNTRY'), 'Test 1: Should be grouped by COUNTRY');

// Test 2: Growth Factor Analysis with Smart Detection
System.debug('\n--- Test 2: Growth Factor Analysis with Smart Detection ---');
String result2 = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('GROWTH_FACTOR', 'CURRENT', 'GROWTH_FACTOR', null, null, false, null, 'COUNT');
System.debug('Result: ' + result2);
System.assert(result2.contains('Growth Factor'), 'Test 2: Should contain Growth Factor analysis');
System.assert(result2.contains('Unique Growth Factors Found'), 'Test 2: Should show unique growth factors');

// Test 3: Field Mapping Validation - User-Friendly Keys
System.debug('\n--- Test 3: Field Mapping Validation - User-Friendly Keys ---');
Map<String, Object> mappingInfo = ANAGENTKPIAnalysisServiceV5.getFieldMappingInfo();
System.debug('Mapping Info: ' + mappingInfo);
System.assert(mappingInfo.containsKey('userFriendlyAliases'), 'Test 3: Should contain user-friendly aliases');
System.assert(mappingInfo.containsKey('apiFieldVariations'), 'Test 3: Should contain API field variations');

// Test 4: Filter Criteria Parsing - Country Filter
System.debug('\n--- Test 4: Filter Criteria Parsing - Country Filter ---');
String parsedFilter1 = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria('country="US"');
System.debug('Parsed Filter: ' + parsedFilter1);
System.assert(parsedFilter1.contains('work_location_country__c'), 'Test 4: Should map country to work_location_country__c');

// Test 5: Filter Criteria Parsing - Industry Filter
System.debug('\n--- Test 5: Filter Criteria Parsing - Industry Filter ---');
String parsedFilter2 = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria('industry="Technology"');
System.debug('Parsed Filter: ' + parsedFilter2);
System.assert(parsedFilter2.contains('primary_industry__c'), 'Test 5: Should map industry to primary_industry__c');

// Test 6: Filter Criteria Parsing - Manager Filter
System.debug('\n--- Test 6: Filter Criteria Parsing - Manager Filter ---');
String parsedFilter3 = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria('manager="John Smith"');
System.debug('Parsed Filter: ' + parsedFilter3);
System.assert(parsedFilter3.contains('emp_mgr_nm__c'), 'Test 6: Should map manager to emp_mgr_nm__c');

// Test 7: Filter Criteria Parsing - Complex Filter
System.debug('\n--- Test 7: Filter Criteria Parsing - Complex Filter ---');
String parsedFilter4 = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria('country="US" AND industry="Finance" AND manager="Jane Doe"');
System.debug('Parsed Filter: ' + parsedFilter4);
System.assert(parsedFilter4.contains('work_location_country__c'), 'Test 7: Should map country');
System.assert(parsedFilter4.contains('primary_industry__c'), 'Test 7: Should map industry');
System.assert(parsedFilter4.contains('emp_mgr_nm__c'), 'Test 7: Should map manager');

// Test 8: API Field Name Variations - Ramp Status
System.debug('\n--- Test 8: API Field Name Variations - Ramp Status ---');
String parsedFilter5 = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria('RAMP_STATUS__c="Fast Ramper"');
System.debug('Parsed Filter: ' + parsedFilter5);
System.assert(parsedFilter5.contains('ramp_status__c'), 'Test 8: Should handle API field variations');

// Test 9: API Field Name Variations - Operating Unit
System.debug('\n--- Test 9: API Field Name Variations - Operating Unit ---');
String parsedFilter6 = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria('OU_NAME__c="AMER"');
System.debug('Parsed Filter: ' + parsedFilter6);
System.assert(parsedFilter6.contains('ou_name__c'), 'Test 9: Should handle OU field variations');

// Test 10: Smart Field Detection - Geographic Patterns
System.debug('\n--- Test 10: Smart Field Detection - Geographic Patterns ---');
String parsedFilter7 = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria('location="Brazil"');
System.debug('Parsed Filter: ' + parsedFilter7);
System.assert(parsedFilter7.contains('work_location_country__c'), 'Test 10: Should detect geographic patterns');

// Test 11: Smart Field Detection - Business Unit Patterns
System.debug('\n--- Test 11: Smart Field Detection - Business Unit Patterns ---');
String parsedFilter8 = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria('business_unit="EMEA"');
System.debug('Parsed Filter: ' + parsedFilter8);
System.assert(parsedFilter8.contains('ou_name__c'), 'Test 11: Should detect business unit patterns');

// Test 12: Metric Auto-Correction - Current Quarter to Previous Quarter
System.debug('\n--- Test 12: Metric Auto-Correction - Current Quarter to Previous Quarter ---');
String result3 = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('CQ_ACV', 'PREVIOUS', 'COUNTRY', null, null, false, null, 'SUM');
System.debug('Result: ' + result3);
System.assert(result3.contains('PQ_ACV'), 'Test 12: Should auto-correct CQ_ACV to PQ_ACV for PREVIOUS timeframe');

// Test 13: Metric Auto-Correction - Previous Quarter to Current Quarter
System.debug('\n--- Test 13: Metric Auto-Correction - Previous Quarter to Current Quarter ---');
String result4 = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('PQ_PG', 'CURRENT', 'COUNTRY', null, null, false, null, 'SUM');
System.debug('Result: ' + result4);
System.assert(result4.contains('CQ_PG'), 'Test 13: Should auto-correct PQ_PG to CQ_PG for CURRENT timeframe');

// Test 14: Unavailable Metric Handling - Coverage in Previous Quarter
System.debug('\n--- Test 14: Unavailable Metric Handling - Coverage in Previous Quarter ---');
String result5 = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('COVERAGE', 'PREVIOUS', 'COUNTRY', null, null, false, null, 'SUM');
System.debug('Result: ' + result5);
System.assert(result5.contains('not available for PREVIOUS timeframe'), 'Test 14: Should handle unavailable metrics');

// Test 15: Unavailable Metric Handling - AI Mentions in Previous Quarter
System.debug('\n--- Test 15: Unavailable Metric Handling - AI Mentions in Previous Quarter ---');
String result6 = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('AI_MENTIONS', 'PREVIOUS', 'COUNTRY', null, null, false, null, 'SUM');
System.debug('Result: ' + result6);
System.assert(result6.contains('not available for PREVIOUS timeframe'), 'Test 15: Should handle AI mentions in previous quarter');

// Test 16: Growth Factor Grouping Analysis
System.debug('\n--- Test 16: Growth Factor Grouping Analysis ---');
String result7 = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('GROWTH_FACTOR', 'CURRENT', 'GROWTH_FACTOR', null, null, false, 5, 'COUNT');
System.debug('Result: ' + result7);
System.assert(result7.contains('Top Growth Factors by Frequency'), 'Test 16: Should show top growth factors');
System.assert(result7.contains('Limit Applied: 5'), 'Test 16: Should apply limit correctly');

// Test 17: Per-AE Normalization
System.debug('\n--- Test 17: Per-AE Normalization ---');
String result8 = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'COUNTRY', null, null, true, null, 'AVG');
System.debug('Result: ' + result8);
System.assert(result8.contains('Per-AE Normalized: Yes'), 'Test 17: Should show per-AE normalization');

// Test 18: Filter Validation with Field Mapping
System.debug('\n--- Test 18: Filter Validation with Field Mapping ---');
Map<String, Object> validation1 = ANAGENTKPIAnalysisServiceV5.validateFieldMapping('country="US" AND industry="Tech"');
System.debug('Validation Result: ' + validation1);
System.assert(validation1.containsKey('successfullyMapped'), 'Test 18: Should show successfully mapped fields');
System.assert(validation1.containsKey('mappedFilter'), 'Test 18: Should show mapped filter');

// Test 19: Complex Business Logic - Growth Factor with Filters
System.debug('\n--- Test 19: Complex Business Logic - Growth Factor with Filters ---');
String result9 = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('GROWTH_FACTOR', 'CURRENT', 'GROWTH_FACTOR', 'country="US" AND ou="AMER"', null, false, 10, 'COUNT');
System.debug('Result: ' + result9);
System.assert(result9.contains('Growth Factor'), 'Test 19: Should handle growth factor analysis with filters');
System.assert(result9.contains('Limit Applied: 10'), 'Test 19: Should apply limit to growth factors');

// Test 20: End-to-End Business Scenario - Sales Performance Analysis
System.debug('\n--- Test 20: End-to-End Business Scenario - Sales Performance Analysis ---');
String result10 = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('ACV', 'CURRENT', 'RAMP_STATUS', 'country="US" AND industry="Technology"', null, false, 5, 'SUM');
System.debug('Result: ' + result10);
System.assert(result10.contains('ACV'), 'Test 20: Should analyze ACV by ramp status');
System.assert(result10.contains('RAMP_STATUS'), 'Test 20: Should group by ramp status');
System.assert(result10.contains('Filter: country="US" AND industry="Technology"'), 'Test 20: Should apply filters correctly');

// Test 21: Field Mapping Edge Cases - Creative Field Names
System.debug('\n--- Test 21: Field Mapping Edge Cases - Creative Field Names ---');
String parsedFilter9 = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria('nation="Canada"');
System.debug('Parsed Filter: ' + parsedFilter9);
System.assert(parsedFilter9.contains('work_location_country__c'), 'Test 21: Should detect nation as country');

// Test 22: Field Mapping Edge Cases - Abbreviated Fields
System.debug('\n--- Test 22: Field Mapping Edge Cases - Abbreviated Fields ---');
String parsedFilter10 = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria('ou="APAC"');
System.debug('Parsed Filter: ' + parsedFilter10);
System.assert(parsedFilter10.contains('ou_name__c'), 'Test 22: Should handle abbreviated field names');

// Test 23: Business Logic - Days to ACV Analysis
System.debug('\n--- Test 23: Business Logic - Days to ACV Analysis ---');
String result11 = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('DAYS_ACV', 'CURRENT', 'COUNTRY', null, null, false, null, 'AVG');
System.debug('Result: ' + result11);
System.assert(result11.contains('Days to ACV'), 'Test 23: Should analyze days to ACV');

// Test 24: Business Logic - Days to Pipeline Analysis
System.debug('\n--- Test 24: Business Logic - Days to Pipeline Analysis ---');
String result12 = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('DAYS_PG', 'CURRENT', 'COUNTRY', null, null, false, null, 'AVG');
System.debug('Result: ' + result12);
System.assert(result12.contains('Days to Pipeline'), 'Test 24: Should analyze days to pipeline');

// Test 25: Business Logic - Create and Close ACV Analysis
System.debug('\n--- Test 25: Business Logic - Create and Close ACV Analysis ---');
String result13 = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('CC_ACV', 'CURRENT', 'COUNTRY', null, null, false, null, 'SUM');
System.debug('Result: ' + result13);
System.assert(result13.contains('Create and Close ACV'), 'Test 25: Should analyze create and close ACV');

System.debug('\n=== All Business Logic Tests Completed Successfully ===');
System.debug('Total Tests Executed: 25');
System.debug('All assertions passed - Service layer business logic is working correctly'); 