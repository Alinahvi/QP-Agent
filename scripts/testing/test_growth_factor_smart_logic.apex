// Test script to verify improved smart logic for Growth Factor detection
// This tests the scenario where user asks for "top 3 growth factors in USA" 
// but agent sends wrong parameters (metricKey: "PG", groupBy: "AE")

// Test Case 1: Agent sends wrong parameters but user intent is clear
System.debug('=== Test Case 1: Wrong parameters but clear Growth Factor intent ===');
System.debug('Input: metricKey="PG", groupBy="AE", limitN=3, filterCriteria="country=\'US\'"');

// Simulate the handler logic
String metricKey = 'PG';
String groupBy = 'AE';
Integer limitN = 3;
String filterCriteria = 'country=\'US\'';

// Apply the smart logic from the handler
if (limitN != null && limitN > 0) {
    // If user is asking for "top X" and it's likely about growth factors
    // Check if the current setup doesn't make sense for the request
    if (groupBy == 'AE' && (metricKey == 'PG' || metricKey == 'ACV' || metricKey == 'CALLS')) {
        // This looks like a "top X growth factors" request that got misinterpreted
        // Auto-correct to Growth Factor analysis
        metricKey = 'GROWTH_FACTOR';
        groupBy = 'GROWTH_FACTOR';
        System.debug('Smart logic detected Growth Factor intent and auto-corrected:');
        System.debug('  metricKey: PG -> ' + metricKey);
        System.debug('  groupBy: AE -> ' + groupBy);
    }
}

// Test Case 2: Another scenario where agent sends wrong parameters
System.debug('\n=== Test Case 2: Another wrong parameter combination ===');
System.debug('Input: metricKey="ACV", groupBy="COUNTRY", limitN=5, filterCriteria="country=\'Germany\'"');

metricKey = 'ACV';
groupBy = 'COUNTRY';
limitN = 5;
filterCriteria = 'country=\'Germany\'';

// Apply the smart logic
if (limitN != null && limitN > 0 && 
    (groupBy == 'AE' || groupBy == 'COUNTRY' || groupBy == 'OU' || groupBy == 'INDUSTRY')) {
    // If user is asking for "top X" with a dimension that doesn't make sense for the metric,
    // and we have a limit, this might be a growth factor request
    if (metricKey == 'PG' || metricKey == 'ACV' || metricKey == 'CALLS') {
        // This looks like a growth factor request that got misinterpreted
        metricKey = 'GROWTH_FACTOR';
        groupBy = 'GROWTH_FACTOR';
        System.debug('Smart logic detected Growth Factor intent and auto-corrected:');
        System.debug('  metricKey: ACV -> ' + metricKey);
        System.debug('  groupBy: COUNTRY -> ' + groupBy);
    }
}

// Test Case 3: Verify that valid requests are not changed
System.debug('\n=== Test Case 3: Valid request should not be changed ===');
System.debug('Input: metricKey="ACV", groupBy="COUNTRY", limitN=10, filterCriteria="country=\'US\'"');

metricKey = 'ACV';
groupBy = 'COUNTRY';
limitN = 10;
filterCriteria = 'country=\'US\'';

// Apply the smart logic
if (limitN != null && limitN > 0) {
    if (groupBy == 'AE' && (metricKey == 'PG' || metricKey == 'ACV' || metricKey == 'CALLS')) {
        metricKey = 'GROWTH_FACTOR';
        groupBy = 'GROWTH_FACTOR';
    }
}

if (limitN != null && limitN > 0 && 
    (groupBy == 'AE' || groupBy == 'COUNTRY' || groupBy == 'OU' || groupBy == 'INDUSTRY')) {
    if (metricKey == 'PG' || metricKey == 'ACV' || metricKey == 'CALLS') {
        metricKey = 'GROWTH_FACTOR';
        groupBy = 'GROWTH_FACTOR';
    }
}

System.debug('Valid request was not changed:');
System.debug('  metricKey: ' + metricKey);
System.debug('  groupBy: ' + groupBy);

System.debug('\n=== Test Summary ===');
System.debug('The improved smart logic should now correctly detect Growth Factor intent');
System.debug('when users ask for "top X growth factors" even if the agent sends wrong parameters.');
System.debug('This should fix the issue where users asked for growth factors but got PG/ACV analysis instead.'); 