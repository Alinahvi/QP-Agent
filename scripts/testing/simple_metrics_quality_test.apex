/**
 * Simple Data Quality Test for Key KPI Metrics
 * 
 * This script tests key KPI metrics to identify data quality issues
 * without hitting governor limits.
 * 
 * @author AI Assistant
 * @date 2025-01-28
 */

System.debug('🔍 SIMPLE DATA QUALITY TEST FOR KEY KPI METRICS');
System.debug('===============================================');

// Test COVERAGE metric specifically (we know this has issues)
System.debug('\n--- Testing COVERAGE Metric ---');

try {
    // Get basic statistics for COVERAGE
    String coverageQuery = 'SELECT COUNT(Id) totalRecords, ' +
                          'COUNT(COVERAGE__c) nonNullRecords, ' +
                          'MIN(COVERAGE__c) minValue, ' +
                          'MAX(COVERAGE__c) maxValue, ' +
                          'AVG(COVERAGE__c) avgValue ' +
                          'FROM AGENT_OU_PIPELINE_V2__c ' +
                          'WHERE IsDeleted = false';
    
    List<AggregateResult> coverageResults = Database.query(coverageQuery);
    
    for (AggregateResult result : coverageResults) {
        Integer totalRecords = (Integer) result.get('totalRecords');
        Integer nonNullRecords = (Integer) result.get('nonNullRecords');
        Decimal minValue = (Decimal) result.get('minValue');
        Decimal maxValue = (Decimal) result.get('maxValue');
        Decimal avgValue = (Decimal) result.get('avgValue');
        
        System.debug('📊 COVERAGE Statistics:');
        System.debug('  • Total Records: ' + totalRecords);
        System.debug('  • Non-null Records: ' + nonNullRecords);
        System.debug('  • Null Records: ' + (totalRecords - nonNullRecords));
        System.debug('  • Min Value: ' + minValue);
        System.debug('  • Max Value: ' + maxValue);
        System.debug('  • Average Value: ' + avgValue);
        
        // Check for extreme outliers
        Integer extremeNegativeCount = 0;
        Integer extremePositiveCount = 0;
        
        if (minValue < -1000000) {
            String extremeQuery = 'SELECT COUNT(Id) extremeCount ' +
                                 'FROM AGENT_OU_PIPELINE_V2__c ' +
                                 'WHERE IsDeleted = false ' +
                                 'AND COVERAGE__c < -1000000';
            List<AggregateResult> extremeResults = Database.query(extremeQuery);
            extremeNegativeCount = (Integer) extremeResults[0].get('extremeCount');
        }
        
        if (maxValue > 1000) {
            String extremeQuery = 'SELECT COUNT(Id) extremeCount ' +
                                 'FROM AGENT_OU_PIPELINE_V2__c ' +
                                 'WHERE IsDeleted = false ' +
                                 'AND COVERAGE__c > 1000';
            List<AggregateResult> extremeResults = Database.query(extremeQuery);
            extremePositiveCount = (Integer) extremeResults[0].get('extremeCount');
        }
        
        System.debug('  • Extreme Negative Values (< -1M): ' + extremeNegativeCount);
        System.debug('  • Extreme Positive Values (> 1K): ' + extremePositiveCount);
        
        // Quality assessment
        String qualityStatus = 'GOOD';
        List<String> issues = new List<String>();
        
        if (extremeNegativeCount > 0 || extremePositiveCount > 0) {
            qualityStatus = 'POOR';
            if (extremeNegativeCount > 0) {
                issues.add('Extreme negative values: ' + extremeNegativeCount);
            }
            if (extremePositiveCount > 0) {
                issues.add('Extreme positive values: ' + extremePositiveCount);
            }
        }
        
        if ((totalRecords - nonNullRecords) > totalRecords * 0.5) {
            if (qualityStatus == 'GOOD') qualityStatus = 'FAIR';
            issues.add('High null percentage: ' + ((totalRecords - nonNullRecords) * 100.0 / totalRecords).setScale(1) + '%');
        }
        
        String statusIcon = qualityStatus == 'GOOD' ? '✅' : (qualityStatus == 'FAIR' ? '⚠️' : '❌');
        System.debug(statusIcon + ' COVERAGE Quality Status: ' + qualityStatus);
        
        if (!issues.isEmpty()) {
            System.debug('⚠️ Issues: ' + String.join(issues, ', '));
        }
    }
    
} catch (Exception e) {
    System.debug('❌ ERROR testing COVERAGE: ' + e.getMessage());
}

// Test MEETINGS metric
System.debug('\n--- Testing MEETINGS Metric ---');

try {
    String meetingsQuery = 'SELECT COUNT(Id) totalRecords, ' +
                          'COUNT(CQ_CUSTOMER_MEETING__c) nonNullRecords, ' +
                          'MIN(CQ_CUSTOMER_MEETING__c) minValue, ' +
                          'MAX(CQ_CUSTOMER_MEETING__c) maxValue, ' +
                          'AVG(CQ_CUSTOMER_MEETING__c) avgValue ' +
                          'FROM AGENT_OU_PIPELINE_V2__c ' +
                          'WHERE IsDeleted = false';
    
    List<AggregateResult> meetingsResults = Database.query(meetingsQuery);
    
    for (AggregateResult result : meetingsResults) {
        Integer totalRecords = (Integer) result.get('totalRecords');
        Integer nonNullRecords = (Integer) result.get('nonNullRecords');
        Decimal minValue = (Decimal) result.get('minValue');
        Decimal maxValue = (Decimal) result.get('maxValue');
        Decimal avgValue = (Decimal) result.get('avgValue');
        
        System.debug('📊 MEETINGS Statistics:');
        System.debug('  • Total Records: ' + totalRecords);
        System.debug('  • Non-null Records: ' + nonNullRecords);
        System.debug('  • Null Records: ' + (totalRecords - nonNullRecords));
        System.debug('  • Min Value: ' + minValue);
        System.debug('  • Max Value: ' + maxValue);
        System.debug('  • Average Value: ' + avgValue);
        
        // Quality assessment
        String qualityStatus = 'GOOD';
        List<String> issues = new List<String>();
        
        if (minValue < 0) {
            qualityStatus = 'FAIR';
            issues.add('Negative meeting values found');
        }
        
        if (maxValue > 1000) {
            qualityStatus = 'FAIR';
            issues.add('Extremely high meeting values: ' + maxValue);
        }
        
        if ((totalRecords - nonNullRecords) > totalRecords * 0.5) {
            if (qualityStatus == 'GOOD') qualityStatus = 'FAIR';
            issues.add('High null percentage: ' + ((totalRecords - nonNullRecords) * 100.0 / totalRecords).setScale(1) + '%');
        }
        
        String statusIcon = qualityStatus == 'GOOD' ? '✅' : (qualityStatus == 'FAIR' ? '⚠️' : '❌');
        System.debug(statusIcon + ' MEETINGS Quality Status: ' + qualityStatus);
        
        if (!issues.isEmpty()) {
            System.debug('⚠️ Issues: ' + String.join(issues, ', '));
        }
    }
    
} catch (Exception e) {
    System.debug('❌ ERROR testing MEETINGS: ' + e.getMessage());
}

// Test CALLS metric
System.debug('\n--- Testing CALLS Metric ---');

try {
    String callsQuery = 'SELECT COUNT(Id) totalRecords, ' +
                       'COUNT(CQ_CALL_CONNECT__c) nonNullRecords, ' +
                       'MIN(CQ_CALL_CONNECT__c) minValue, ' +
                       'MAX(CQ_CALL_CONNECT__c) maxValue, ' +
                       'AVG(CQ_CALL_CONNECT__c) avgValue ' +
                       'FROM AGENT_OU_PIPELINE_V2__c ' +
                       'WHERE IsDeleted = false';
    
    List<AggregateResult> callsResults = Database.query(callsQuery);
    
    for (AggregateResult result : callsResults) {
        Integer totalRecords = (Integer) result.get('totalRecords');
        Integer nonNullRecords = (Integer) result.get('nonNullRecords');
        Decimal minValue = (Decimal) result.get('minValue');
        Decimal maxValue = (Decimal) result.get('maxValue');
        Decimal avgValue = (Decimal) result.get('avgValue');
        
        System.debug('📊 CALLS Statistics:');
        System.debug('  • Total Records: ' + totalRecords);
        System.debug('  • Non-null Records: ' + nonNullRecords);
        System.debug('  • Null Records: ' + (totalRecords - nonNullRecords));
        System.debug('  • Min Value: ' + minValue);
        System.debug('  • Max Value: ' + maxValue);
        System.debug('  • Average Value: ' + avgValue);
        
        // Quality assessment
        String qualityStatus = 'GOOD';
        List<String> issues = new List<String>();
        
        if (minValue < 0) {
            qualityStatus = 'FAIR';
            issues.add('Negative call values found');
        }
        
        if (maxValue > 10000) {
            qualityStatus = 'FAIR';
            issues.add('Extremely high call values: ' + maxValue);
        }
        
        if ((totalRecords - nonNullRecords) > totalRecords * 0.5) {
            if (qualityStatus == 'GOOD') qualityStatus = 'FAIR';
            issues.add('High null percentage: ' + ((totalRecords - nonNullRecords) * 100.0 / totalRecords).setScale(1) + '%');
        }
        
        String statusIcon = qualityStatus == 'GOOD' ? '✅' : (qualityStatus == 'FAIR' ? '⚠️' : '❌');
        System.debug(statusIcon + ' CALLS Quality Status: ' + qualityStatus);
        
        if (!issues.isEmpty()) {
            System.debug('⚠️ Issues: ' + String.join(issues, ', '));
        }
    }
    
} catch (Exception e) {
    System.debug('❌ ERROR testing CALLS: ' + e.getMessage());
}

System.debug('\n--- SUMMARY ---');
System.debug('✅ This test focused on the three most commonly used KPI metrics:');
System.debug('  • COVERAGE: Territory coverage metrics');
System.debug('  • MEETINGS: Customer meeting metrics');
System.debug('  • CALLS: Call connect metrics');
System.debug('\n📋 Next Steps:');
System.debug('  1. Run the data cleanup script for COVERAGE if issues were found');
System.debug('  2. Use the enhanced KPI analysis service which now includes data quality warnings');
System.debug('  3. Consider using MEETINGS or CALLS metrics if COVERAGE has quality issues');

System.debug('\n✅ Simple Data Quality Test Complete!');
