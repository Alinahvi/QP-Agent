/**
 * Comprehensive Data Quality Test for All KPI Metrics
 * 
 * This script tests all available KPI metrics to identify data quality issues
 * similar to what we found with the COVERAGE field.
 * 
 * @author AI Assistant
 * @date 2025-01-28
 */

System.debug('🔍 COMPREHENSIVE DATA QUALITY TEST FOR ALL KPI METRICS');
System.debug('=====================================================');

// Define reasonable thresholds for each metric
Map<String, Map<String, Decimal>> METRIC_THRESHOLDS = new Map<String, Map<String, Decimal>>{
    'COVERAGE' => new Map<String, Decimal>{
        'MIN_REASONABLE' => -100.0,
        'MAX_REASONABLE' => 1000.0
    },
    'ACV' => new Map<String, Decimal>{
        'MIN_REASONABLE' => -1000000.0,  // Allow negative ACV for returns
        'MAX_REASONABLE' => 100000000.0  // 100M max reasonable ACV
    },
    'PG' => new Map<String, Decimal>{
        'MIN_REASONABLE' => -1000000.0,  // Allow negative PG for returns
        'MAX_REASONABLE' => 100000000.0  // 100M max reasonable PG
    },
    'MEETINGS' => new Map<String, Decimal>{
        'MIN_REASONABLE' => 0.0,
        'MAX_REASONABLE' => 1000.0       // 1000 meetings max per quarter
    },
    'CALLS' => new Map<String, Decimal>{
        'MIN_REASONABLE' => 0.0,
        'MAX_REASONABLE' => 10000.0      // 10K calls max per quarter
    },
    'QUOTA' => new Map<String, Decimal>{
        'MIN_REASONABLE' => 0.0,
        'MAX_REASONABLE' => 10000000.0   // 10M max reasonable quota
    }
};

// Field mappings for each metric
Map<String, String> METRIC_FIELDS = new Map<String, String>{
    'COVERAGE' => 'COVERAGE__c',
    'ACV' => 'CQ_ACV__c',
    'PG' => 'CQ_PG__c',
    'MEETINGS' => 'CQ_CUSTOMER_MEETING__c',
    'CALLS' => 'CQ_CALL_CONNECT__c',
    'QUOTA' => 'VAL_QUOTA__c'
};

// Results storage
Map<String, Map<String, Object>> allResults = new Map<String, Map<String, Object>>();

// Test each metric
for (String metricName : METRIC_FIELDS.keySet()) {
    String fieldName = METRIC_FIELDS.get(metricName);
    
    System.debug('\n--- Testing ' + metricName + ' (' + fieldName + ') ---');
    
    try {
        // Get overall statistics
        String statsQuery = 'SELECT COUNT(Id) totalRecords, ' +
                           'COUNT(' + fieldName + ') nonNullRecords, ' +
                           'MIN(' + fieldName + ') minValue, ' +
                           'MAX(' + fieldName + ') maxValue, ' +
                           'AVG(' + fieldName + ') avgValue ' +
                           'FROM AGENT_OU_PIPELINE_V2__c ' +
                           'WHERE IsDeleted = false';
        
        List<AggregateResult> statsResults = Database.query(statsQuery);
        Map<String, Object> results = new Map<String, Object>();
        
        for (AggregateResult result : statsResults) {
            Integer totalRecords = (Integer) result.get('totalRecords');
            Integer nonNullRecords = (Integer) result.get('nonNullRecords');
            Decimal minValue = (Decimal) result.get('minValue');
            Decimal maxValue = (Decimal) result.get('maxValue');
            Decimal avgValue = (Decimal) result.get('avgValue');
            
            results.put('totalRecords', totalRecords);
            results.put('nonNullRecords', nonNullRecords);
            results.put('nullRecords', totalRecords - nonNullRecords);
            results.put('minValue', minValue);
            results.put('maxValue', maxValue);
            results.put('avgValue', avgValue);
            
            // Calculate null percentage
            Decimal nullPercentage = totalRecords > 0 ? ((totalRecords - nonNullRecords) * 100.0 / totalRecords) : 0;
            results.put('nullPercentage', nullPercentage);
            
            // Display basic statistics
            System.debug('📊 Statistics:');
            System.debug('  • Total Records: ' + totalRecords);
            System.debug('  • Non-null Records: ' + nonNullRecords);
            System.debug('  • Null Records: ' + (totalRecords - nonNullRecords) + ' (' + nullPercentage.setScale(1) + '%)');
            System.debug('  • Min Value: ' + minValue);
            System.debug('  • Max Value: ' + maxValue);
            System.debug('  • Average Value: ' + avgValue);
        }
        
        // Check for outliers if thresholds are defined
        if (METRIC_THRESHOLDS.containsKey(metricName)) {
            Map<String, Decimal> thresholds = METRIC_THRESHOLDS.get(metricName);
            Decimal minReasonable = thresholds.get('MIN_REASONABLE');
            Decimal maxReasonable = thresholds.get('MAX_REASONABLE');
            
            String outlierQuery = 'SELECT COUNT(Id) outlierCount ' +
                                 'FROM AGENT_OU_PIPELINE_V2__c ' +
                                 'WHERE IsDeleted = false ' +
                                 'AND ' + fieldName + ' != null ' +
                                 'AND (' + fieldName + ' < ' + minReasonable + 
                                 ' OR ' + fieldName + ' > ' + maxReasonable + ')';
            
            List<AggregateResult> outlierResults = Database.query(outlierQuery);
            Integer outlierCount = (Integer) outlierResults[0].get('outlierCount');
            
            results.put('outlierCount', outlierCount);
            results.put('minThreshold', minReasonable);
            results.put('maxThreshold', maxReasonable);
            
            // Calculate outlier percentage
            Integer nonNullRecords = (Integer) results.get('nonNullRecords');
            Decimal outlierPercentage = nonNullRecords > 0 ? (outlierCount * 100.0 / nonNullRecords) : 0;
            results.put('outlierPercentage', outlierPercentage);
            
            System.debug('  • Outlier Records: ' + outlierCount + ' (' + outlierPercentage.setScale(1) + '%)');
            System.debug('  • Reasonable Range: ' + minReasonable + ' to ' + maxReasonable);
            
            // Get sample outliers
            if (outlierCount > 0) {
                String sampleQuery = 'SELECT FULL_NAME__c, OU_NAME__c, WORK_LOCATION_COUNTRY__c, ' + fieldName + ' ' +
                                    'FROM AGENT_OU_PIPELINE_V2__c ' +
                                    'WHERE IsDeleted = false ' +
                                    'AND ' + fieldName + ' != null ' +
                                    'AND (' + fieldName + ' < ' + minReasonable + 
                                    ' OR ' + fieldName + ' > ' + maxReasonable + ') ' +
                                    'ORDER BY ' + fieldName + ' ASC ' +
                                    'LIMIT 5';
                
                List<AGENT_OU_PIPELINE_V2__c> outlierSamples = Database.query(sampleQuery);
                List<String> outlierExamples = new List<String>();
                
                for (AGENT_OU_PIPELINE_V2__c record : outlierSamples) {
                    Object fieldValue = record.get(fieldName);
                    outlierExamples.add(record.FULL_NAME__c + ': ' + fieldValue);
                }
                
                results.put('outlierExamples', outlierExamples);
                System.debug('  • Sample Outliers: ' + String.join(outlierExamples, ', '));
            }
        }
        
        // Determine overall quality status
        Boolean hasQualityIssues = false;
        String qualityStatus = 'GOOD';
        List<String> issues = new List<String>();
        
        Integer nullRecords = (Integer) results.get('nullRecords');
        Integer totalRecords = (Integer) results.get('totalRecords');
        Decimal nullPercentage = (Decimal) results.get('nullPercentage');
        
        if (nullPercentage > 50) {
            hasQualityIssues = true;
            qualityStatus = 'POOR';
            issues.add('High null percentage: ' + nullPercentage.setScale(1) + '%');
        } else if (nullPercentage > 25) {
            hasQualityIssues = true;
            qualityStatus = 'FAIR';
            issues.add('Moderate null percentage: ' + nullPercentage.setScale(1) + '%');
        }
        
        if (results.containsKey('outlierPercentage')) {
            Decimal outlierPercentage = (Decimal) results.get('outlierPercentage');
            if (outlierPercentage > 10) {
                hasQualityIssues = true;
                if (qualityStatus == 'GOOD') qualityStatus = 'FAIR';
                if (qualityStatus == 'FAIR') qualityStatus = 'POOR';
                issues.add('High outlier percentage: ' + outlierPercentage.setScale(1) + '%');
            } else if (outlierPercentage > 5) {
                hasQualityIssues = true;
                if (qualityStatus == 'GOOD') qualityStatus = 'FAIR';
                issues.add('Moderate outlier percentage: ' + outlierPercentage.setScale(1) + '%');
            }
        }
        
        results.put('hasQualityIssues', hasQualityIssues);
        results.put('qualityStatus', qualityStatus);
        results.put('issues', issues);
        
        allResults.put(metricName, results);
        
        // Display quality status
        String statusIcon = qualityStatus == 'GOOD' ? '✅' : (qualityStatus == 'FAIR' ? '⚠️' : '❌');
        System.debug(statusIcon + ' Quality Status: ' + qualityStatus);
        
        if (!issues.isEmpty()) {
            System.debug('⚠️ Issues: ' + String.join(issues, ', '));
        }
        
    } catch (Exception e) {
        System.debug('❌ ERROR: ' + e.getMessage());
        Map<String, Object> errorResults = new Map<String, Object>();
        errorResults.put('error', e.getMessage());
        errorResults.put('hasQualityIssues', true);
        errorResults.put('qualityStatus', 'ERROR');
        allResults.put(metricName, errorResults);
    }
}

// Generate summary report
System.debug('\n--- SUMMARY REPORT ---');

Integer goodMetrics = 0;
Integer fairMetrics = 0;
Integer poorMetrics = 0;
Integer errorMetrics = 0;

List<String> goodList = new List<String>();
List<String> fairList = new List<String>();
List<String> poorList = new List<String>();
List<String> errorList = new List<String>();

for (String metricName : allResults.keySet()) {
    Map<String, Object> results = allResults.get(metricName);
    String qualityStatus = (String) results.get('qualityStatus');
    
    switch on qualityStatus {
        when 'GOOD' {
            goodMetrics++;
            goodList.add(metricName);
        }
        when 'FAIR' {
            fairMetrics++;
            fairList.add(metricName);
        }
        when 'POOR' {
            poorMetrics++;
            poorList.add(metricName);
        }
        when 'ERROR' {
            errorMetrics++;
            errorList.add(metricName);
        }
    }
}

System.debug('📊 Overall Data Quality Summary:');
System.debug('  ✅ Good Quality: ' + goodMetrics + ' metrics (' + String.join(goodList, ', ') + ')');
System.debug('  ⚠️ Fair Quality: ' + fairMetrics + ' metrics (' + String.join(fairList, ', ') + ')');
System.debug('  ❌ Poor Quality: ' + poorMetrics + ' metrics (' + String.join(poorList, ', ') + ')');
System.debug('  🚫 Error: ' + errorMetrics + ' metrics (' + String.join(errorList, ', ') + ')');

// Recommendations
System.debug('\n📋 Recommendations:');
if (poorMetrics > 0) {
    System.debug('🔴 HIGH PRIORITY: Address data quality issues in: ' + String.join(poorList, ', '));
}
if (fairMetrics > 0) {
    System.debug('🟡 MEDIUM PRIORITY: Monitor and improve: ' + String.join(fairList, ', '));
}
if (errorMetrics > 0) {
    System.debug('🔴 CRITICAL: Fix errors in: ' + String.join(errorList, ', '));
}
if (goodMetrics == allResults.size()) {
    System.debug('✅ All metrics have good data quality!');
}

// Specific recommendations for each problematic metric
for (String metricName : poorList) {
    Map<String, Object> results = allResults.get(metricName);
    System.debug('\n🔧 Specific recommendations for ' + metricName + ':');
    
    if (results.containsKey('issues')) {
        List<String> issues = (List<String>) results.get('issues');
        for (String issue : issues) {
            System.debug('  • ' + issue);
        }
    }
    
    if (results.containsKey('outlierPercentage') && (Decimal) results.get('outlierPercentage') > 10) {
        System.debug('  • Consider running data cleanup script to fix extreme outliers');
        System.debug('  • Review data source systems for calculation errors');
    }
    
    if (results.containsKey('nullPercentage') && (Decimal) results.get('nullPercentage') > 50) {
        System.debug('  • Investigate why so many records have null values');
        System.debug('  • Consider using alternative metrics or data sources');
    }
}

System.debug('\n✅ Comprehensive Data Quality Test Complete!');