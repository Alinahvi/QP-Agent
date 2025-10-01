System.debug('=== Debugging SOQL Builder ===');

try {
    // Test the failing case
    ANAgentAggregationSpec spec = ANAgentAggregationSpec.fromRequest(
        'ACV', 'CURRENT', 'COUNTRY', null, null, null, true
    );
    
    System.debug('Spec: ' + spec);
    System.debug('Metric Field: ' + spec.metricFieldApi);
    System.debug('Group By Field: ' + spec.groupByFieldApi);
    System.debug('Per AE Normalize: ' + spec.perAENormalize);
    
    // Test buildNonAggregate
    String nonAggSoql = ANAgentSOQLBuilder.buildNonAggregate(spec);
    System.debug('Non-Aggregate SOQL: ' + nonAggSoql);
    
    // Test regular build
    ANAgentSOQLBuilder.BuiltQuery builtQuery = ANAgentSOQLBuilder.build(spec);
    System.debug('Built Query SOQL: ' + builtQuery.soql);
    System.debug('Built Query Alias: ' + builtQuery.alias);
    System.debug('Built Query Group Alias: ' + builtQuery.groupAlias);
    
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack: ' + e.getStackTraceString());
} 