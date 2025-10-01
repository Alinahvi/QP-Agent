/**
 * Test Foundation Classes
 * Verifies that the foundation classes work together correctly
 */

System.debug('=== TESTING FOUNDATION CLASSES ===');

try {
    // Test 1: Metric Registry
    System.debug('\n--- TEST 1: METRIC REGISTRY ---');
    
    ANAgentMetricRegistry registry = ANAgentMetricRegistry.getInstance();
    
    // Test basic metric retrieval
    ANAgentMetricRegistry.MetricDefinition acvDef = registry.get('ACV');
    System.debug('ACV Definition: ' + acvDef);
    System.assert(acvDef != null, 'ACV metric should exist');
    System.assertEquals('CQ_ACV__c', acvDef.currentField, 'ACV current field should be CQ_ACV__c');
    System.assertEquals('PQ_ACV__c', acvDef.previousField, 'ACV previous field should be PQ_ACV__c');
    System.assertEquals('SUM', acvDef.defaultAgg, 'ACV default aggregation should be SUM');
    
    // Test field resolution
    String acvCurrent = registry.resolveField('ACV', 'CURRENT');
    String acvPrevious = registry.resolveField('ACV', 'PREVIOUS');
    System.debug('ACV Current Field: ' + acvCurrent);
    System.debug('ACV Previous Field: ' + acvPrevious);
    System.assertEquals('CQ_ACV__c', acvCurrent, 'ACV current field resolution failed');
    System.assertEquals('PQ_ACV__c', acvPrevious, 'ACV previous field resolution failed');
    
    // Test 2: Dimension Registry
    System.debug('\n--- TEST 2: DIMENSION REGISTRY ---');
    
    ANAgentDimensionRegistry dimRegistry = ANAgentDimensionRegistry.getInstance();
    
    // Test field mapping
    String countryField = dimRegistry.fieldFor('COUNTRY');
    String ouField = dimRegistry.fieldFor('OU');
    System.debug('Country Field: ' + countryField);
    System.debug('OU Field: ' + ouField);
    System.assertEquals('WORK_LOCATION_COUNTRY__c', countryField, 'Country field mapping failed');
    System.assertEquals('OU_NAME__c', ouField, 'OU field mapping failed');
    
    // Test value normalization
    String normalizedUSA = dimRegistry.normalize('COUNTRY', 'USA');
    String normalizedBrasil = dimRegistry.normalize('COUNTRY', 'Brasil');
    System.debug('USA -> ' + normalizedUSA);
    System.debug('Brasil -> ' + normalizedBrasil);
    System.assertEquals('US', normalizedUSA, 'USA normalization failed');
    System.assertEquals('Brazil', normalizedBrasil, 'Brasil normalization failed');
    
    // Test 3: Date Utils
    System.debug('\n--- TEST 3: DATE UTILS ---');
    
    ANAgentDateUtils.DateRange currentQ = ANAgentDateUtils.currentQuarterRange();
    ANAgentDateUtils.DateRange previousQ = ANAgentDateUtils.previousQuarterRange();
    System.debug('Current Quarter: ' + currentQ.startDate + ' to ' + currentQ.endDate);
    System.debug('Previous Quarter: ' + previousQ.startDate + ' to ' + previousQ.endDate);
    System.assert(currentQ.startDate != null, 'Current quarter start date should not be null');
    System.assert(currentQ.endDate != null, 'Current quarter end date should not be null');
    
    // Test 4: Filter Parser
    System.debug('\n--- TEST 4: FILTER PARSER ---');
    
    String filterDsl = 'country = "US"';
    ANAgentFilterParser.ParsedFilter parsed = ANAgentFilterParser.parse(filterDsl);
    System.debug('Parsed Filter: ' + parsed.soqlWhere);
    System.assert(parsed.isValid, 'Filter should be valid');
    System.assert(parsed.soqlWhere.contains('WORK_LOCATION_COUNTRY__c'), 'Filter should contain country field');
    
    // Test 5: Aggregation Spec
    System.debug('\n--- TEST 5: AGGREGATION SPEC ---');
    
    ANAgentAggregationSpec spec = new ANAgentAggregationSpec();
    spec.metricKey = 'ACV';
    spec.timeFrame = 'CURRENT';
    spec.groupBy = new List<String>{ 'COUNTRY', 'OU' };
    spec.filtersDsl = 'country = "US"';
    spec.sortBy = 'ACV';
    spec.sortDir = 'DESC';
    spec.limitCount = 10;
    
    System.debug('Spec Summary: ' + spec.getSummary());
    System.assert(spec.isValid(), 'Spec should be valid');
    System.assertEquals('CQ_ACV__c', spec.getMetricField(), 'Metric field resolution failed');
    System.assertEquals('SUM', spec.getEffectiveAggregation(), 'Default aggregation should be SUM');
    System.assert(spec.isAggregateQuery(), 'Should be aggregate query');
    
    // Test 6: Integration Test
    System.debug('\n--- TEST 6: INTEGRATION ---');
    
    // Create a spec and validate it works with registries
    ANAgentAggregationSpec integrationSpec = new ANAgentAggregationSpec();
    integrationSpec.metricKey = 'CALLS';
    integrationSpec.timeFrame = 'CURRENT';
    integrationSpec.groupBy = new List<String>{ 'COUNTRY' };
    integrationSpec.perAEDenominator = true;
    
    System.debug('Integration Spec: ' + integrationSpec.getSummary());
    System.assert(integrationSpec.isValid(), 'Integration spec should be valid');
    System.assertEquals('CQ_CALL_CONNECT__c', integrationSpec.getMetricField(), 'Calls field resolution failed');
    System.assertEquals('AVG', integrationSpec.getEffectiveAggregation(), 'Calls should default to AVG');
    System.assert(integrationSpec.shouldUsePerAEDenominator(), 'Calls should use per-AE denominator');
    
    System.debug('\n✅ ALL FOUNDATION CLASS TESTS PASSED!');
    
} catch (Exception e) {
    System.debug('❌ FOUNDATION CLASS TEST FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== FOUNDATION CLASS TESTING COMPLETED ==='); 