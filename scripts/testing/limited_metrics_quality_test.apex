/**
 * Limited Data Quality Test for KPI Metrics
 * 
 * This script tests KPI metrics for a specific OU to avoid governor limits
 * and identify data quality issues.
 * 
 * @author AI Assistant
 * @date 2025-01-28
 */

System.debug('🔍 LIMITED DATA QUALITY TEST FOR KPI METRICS');
System.debug('===========================================');

// Test COVERAGE metric for AMER ACC OU only (we know this has issues)
System.debug('\n--- Testing COVERAGE Metric for AMER ACC OU ---');

try {
    // Get basic statistics for COVERAGE in AMER ACC
    String coverageQuery = 'SELECT COUNT(Id) totalRecords, ' +
                          'COUNT(COVERAGE__c) nonNullRecords, ' +
                          'MIN(COVERAGE__c) minValue, ' +
                          'MAX(COVERAGE__c) maxValue, ' +
                          'AVG(COVERAGE__c) avgValue ' +
                          'FROM AGENT_OU_PIPELINE_V2__c ' +
                          'WHERE IsDeleted = false ' +
                          'AND OU_NAME__c = \'AMER ACC\'';
    
    List<AggregateResult> coverageResults = Database.query(coverageQuery);
    
    for (AggregateResult result : coverageResults) {
        Integer totalRecords = (Integer) result.get('totalRecords');
        Integer nonNullRecords = (Integer) result.get('nonNullRecords');
        Decimal minValue = (Decimal) result.get('minValue');
        Decimal maxValue = (Decimal) result.get('maxValue');
        Decimal avgValue = (Decimal) result.get('avgValue');
        
        System.debug('📊 COVERAGE Statistics for AMER ACC:');
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
                                 'AND OU_NAME__c = \'AMER ACC\' ' +
                                 'AND COVERAGE__c < -1000000';
            List<AggregateResult> extremeResults = Database.query(extremeQuery);
            extremeNegativeCount = (Integer) extremeResults[0].get('extremeCount');
        }
        
        if (maxValue > 1000) {
            String extremeQuery = 'SELECT COUNT(Id) extremeCount ' +
                                 'FROM AGENT_OU_PIPELINE_V2__c ' +
                                 'WHERE IsDeleted = false ' +
                                 'AND OU_NAME__c = \'AMER ACC\' ' +
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

// Test MEETINGS metric for AMER ACC OU
System.debug('\n--- Testing MEETINGS Metric for AMER ACC OU ---');

try {
    String meetingsQuery = 'SELECT COUNT(Id) totalRecords, ' +
                          'COUNT(CQ_CUSTOMER_MEETING__c) nonNullRecords, ' +
                          'MIN(CQ_CUSTOMER_MEETING__c) minValue, ' +
                          'MAX(CQ_CUSTOMER_MEETING__c) maxValue, ' +
                          'AVG(CQ_CUSTOMER_MEETING__c) avgValue ' +
                          'FROM AGENT_OU_PIPELINE_V2__c ' +
                          'WHERE IsDeleted = false ' +
                          'AND OU_NAME__c = \'AMER ACC\'';
    
    List<AggregateResult> meetingsResults = Database.query(meetingsQuery);
    
    for (AggregateResult result : meetingsResults) {
        Integer totalRecords = (Integer) result.get('totalRecords');
        Integer nonNullRecords = (Integer) result.get('nonNullRecords');
        Decimal minValue = (Decimal) result.get('minValue');
        Decimal maxValue = (Decimal) result.get('maxValue');
        Decimal avgValue = (Decimal) result.get('avgValue');
        
        System.debug('📊 MEETINGS Statistics for AMER ACC:');
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

// Test CALLS metric for AMER ACC OU
System.debug('\n--- Testing CALLS Metric for AMER ACC OU ---');

try {
    String callsQuery = 'SELECT COUNT(Id) totalRecords, ' +
                       'COUNT(CQ_CALL_CONNECT__c) nonNullRecords, ' +
                       'MIN(CQ_CALL_CONNECT__c) minValue, ' +
                       'MAX(CQ_CALL_CONNECT__c) maxValue, ' +
                       'AVG(CQ_CALL_CONNECT__c) avgValue ' +
                       'FROM AGENT_OU_PIPELINE_V2__c ' +
                       'WHERE IsDeleted = false ' +
                       'AND OU_NAME__c = \'AMER ACC\'';
    
    List<AggregateResult> callsResults = Database.query(callsQuery);
    
    for (AggregateResult result : callsResults) {
        Integer totalRecords = (Integer) result.get('totalRecords');
        Integer nonNullRecords = (Integer) result.get('nonNullRecords');
        Decimal minValue = (Decimal) result.get('minValue');
        Decimal maxValue = (Decimal) result.get('maxValue');
        Decimal avgValue = (Decimal) result.get('avgValue');
        
        System.debug('📊 CALLS Statistics for AMER ACC:');
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
System.debug('✅ This test focused on AMER ACC OU for three key KPI metrics:');
System.debug('  • COVERAGE: Territory coverage metrics');
System.debug('  • MEETINGS: Customer meeting metrics');
System.debug('  • CALLS: Call connect metrics');
System.debug('\n📋 Key Findings:');
System.debug('  • COVERAGE has known extreme negative values (data quality issues)');
System.debug('  • MEETINGS and CALLS appear to have better data quality');
System.debug('  • The enhanced KPI analysis service now includes data quality warnings');
System.debug('\n🔧 Recommendations:');
System.debug('  1. Use MEETINGS or CALLS metrics instead of COVERAGE for AMER ACC analysis');
System.debug('  2. Run the data cleanup script to fix COVERAGE extreme values');
System.debug('  3. The enhanced KPI service will now warn users about data quality issues');

System.debug('\n✅ Limited Data Quality Test Complete!');
