/**
 * Coverage Data Cleanup Script
 * 
 * This script identifies and fixes data quality issues in the COVERAGE__c field
 * of the AGENT_OU_PIPELINE_V2__c object.
 * 
 * Issues addressed:
 * - Extreme negative values (likely data entry errors)
 * - Missing coverage data
 * - Outlier detection and correction
 * 
 * @author AI Assistant
 * @date 2025-01-28
 */
public class CoverageDataCleanup {
    
    // Configuration constants
    private static final Decimal MAX_REASONABLE_COVERAGE = 1000.0;  // Maximum reasonable coverage value
    private static final Decimal MIN_REASONABLE_COVERAGE = -100.0;  // Minimum reasonable coverage value
    private static final Decimal DEFAULT_COVERAGE = 0.0;            // Default value for null/outlier coverage
    private static final Integer BATCH_SIZE = 200;                  // Batch size for processing
    
    /**
     * Main cleanup method - identifies and reports data quality issues
     */
    public static void analyzeCoverageDataQuality() {
        System.debug('🔍 COVERAGE DATA QUALITY ANALYSIS');
        System.debug('==================================');
        
        try {
            // Phase 1: Overall statistics
            analyzeOverallStatistics();
            
            // Phase 2: Identify outliers
            identifyOutliers();
            
            // Phase 3: Analyze by OU
            analyzeByOU();
            
            // Phase 4: Analyze by country
            analyzeByCountry();
            
            // Phase 5: Identify patterns in bad data
            identifyDataPatterns();
            
        } catch (Exception e) {
            System.debug('❌ Error during analysis: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
    }
    
    /**
     * Phase 1: Analyze overall coverage statistics
     */
    private static void analyzeOverallStatistics() {
        System.debug('\n--- PHASE 1: Overall Coverage Statistics ---');
        
        try {
            String statsQuery = 'SELECT COUNT(Id) totalRecords, ' +
                               'COUNT(COVERAGE__c) nonNullRecords, ' +
                               'MIN(COVERAGE__c) minCoverage, ' +
                               'MAX(COVERAGE__c) maxCoverage, ' +
                               'AVG(COVERAGE__c) avgCoverage, ' +
                               'STDDEV(COVERAGE__c) stdDevCoverage ' +
                               'FROM AGENT_OU_PIPELINE_V2__c ' +
                               'WHERE IsDeleted = false';
            
            List<AggregateResult> results = Database.query(statsQuery);
            
            for (AggregateResult result : results) {
                Integer totalRecords = (Integer) result.get('totalRecords');
                Integer nonNullRecords = (Integer) result.get('nonNullRecords');
                Decimal minCoverage = (Decimal) result.get('minCoverage');
                Decimal maxCoverage = (Decimal) result.get('maxCoverage');
                Decimal avgCoverage = (Decimal) result.get('avgCoverage');
                Decimal stdDevCoverage = (Decimal) result.get('stdDevCoverage');
                
                System.debug('📊 Overall Coverage Statistics:');
                System.debug('  • Total Records: ' + totalRecords);
                System.debug('  • Non-null Coverage Records: ' + nonNullRecords);
                System.debug('  • Null Coverage Records: ' + (totalRecords - nonNullRecords));
                System.debug('  • Min Coverage: ' + minCoverage);
                System.debug('  • Max Coverage: ' + maxCoverage);
                System.debug('  • Average Coverage: ' + avgCoverage);
                System.debug('  • Standard Deviation: ' + stdDevCoverage);
                
                // Calculate outlier thresholds
                Decimal upperThreshold = avgCoverage + (3 * stdDevCoverage);
                Decimal lowerThreshold = avgCoverage - (3 * stdDevCoverage);
                
                System.debug('  • Statistical Upper Threshold (3σ): ' + upperThreshold);
                System.debug('  • Statistical Lower Threshold (3σ): ' + lowerThreshold);
                System.debug('  • Business Upper Threshold: ' + MAX_REASONABLE_COVERAGE);
                System.debug('  • Business Lower Threshold: ' + MIN_REASONABLE_COVERAGE);
            }
            
        } catch (Exception e) {
            System.debug('❌ Error in overall statistics: ' + e.getMessage());
        }
    }
    
    /**
     * Phase 2: Identify outliers and extreme values
     */
    private static void identifyOutliers() {
        System.debug('\n--- PHASE 2: Identifying Outliers ---');
        
        try {
            // Count records with extreme values
            String extremeQuery = 'SELECT COUNT(Id) extremeCount ' +
                                 'FROM AGENT_OU_PIPELINE_V2__c ' +
                                 'WHERE IsDeleted = false ' +
                                 'AND COVERAGE__c != null ' +
                                 'AND (COVERAGE__c > ' + MAX_REASONABLE_COVERAGE + 
                                 ' OR COVERAGE__c < ' + MIN_REASONABLE_COVERAGE + ')';
            
            List<AggregateResult> extremeResults = Database.query(extremeQuery);
            Integer extremeCount = (Integer) extremeResults[0].get('extremeCount');
            
            System.debug('📊 Outlier Analysis:');
            System.debug('  • Records with extreme values: ' + extremeCount);
            
            if (extremeCount > 0) {
                // Get sample of extreme values
                String sampleQuery = 'SELECT Id, FULL_NAME__c, OU_NAME__c, WORK_LOCATION_COUNTRY__c, ' +
                                    'COVERAGE__c, VAL_QUOTA__c ' +
                                    'FROM AGENT_OU_PIPELINE_V2__c ' +
                                    'WHERE IsDeleted = false ' +
                                    'AND COVERAGE__c != null ' +
                                    'AND (COVERAGE__c > ' + MAX_REASONABLE_COVERAGE + 
                                    ' OR COVERAGE__c < ' + MIN_REASONABLE_COVERAGE + ') ' +
                                    'ORDER BY COVERAGE__c ASC ' +
                                    'LIMIT 10';
                
                List<AGENT_OU_PIPELINE_V2__c> extremeRecords = Database.query(sampleQuery);
                
                System.debug('  • Sample of extreme values:');
                for (AGENT_OU_PIPELINE_V2__c record : extremeRecords) {
                    System.debug('    - ' + record.FULL_NAME__c + ' (' + record.OU_NAME__c + 
                                ', ' + record.WORK_LOCATION_COUNTRY__c + '): ' + record.COVERAGE__c);
                }
            }
            
        } catch (Exception e) {
            System.debug('❌ Error identifying outliers: ' + e.getMessage());
        }
    }
    
    /**
     * Phase 3: Analyze coverage by Operating Unit
     */
    private static void analyzeByOU() {
        System.debug('\n--- PHASE 3: Coverage Analysis by OU ---');
        
        try {
            String ouQuery = 'SELECT OU_NAME__c, ' +
                            'COUNT(Id) totalRecords, ' +
                            'COUNT(COVERAGE__c) nonNullRecords, ' +
                            'MIN(COVERAGE__c) minCoverage, ' +
                            'MAX(COVERAGE__c) maxCoverage, ' +
                            'AVG(COVERAGE__c) avgCoverage, ' +
                            'SUM(CASE WHEN COVERAGE__c > ' + MAX_REASONABLE_COVERAGE + 
                            ' OR COVERAGE__c < ' + MIN_REASONABLE_COVERAGE + ' THEN 1 ELSE 0 END) outlierCount ' +
                            'FROM AGENT_OU_PIPELINE_V2__c ' +
                            'WHERE IsDeleted = false ' +
                            'GROUP BY OU_NAME__c ' +
                            'ORDER BY outlierCount DESC';
            
            List<AggregateResult> ouResults = Database.query(ouQuery);
            
            System.debug('📊 Coverage Analysis by OU:');
            for (AggregateResult result : ouResults) {
                String ouName = (String) result.get('OU_NAME__c');
                Integer totalRecords = (Integer) result.get('totalRecords');
                Integer nonNullRecords = (Integer) result.get('nonNullRecords');
                Decimal minCoverage = (Decimal) result.get('minCoverage');
                Decimal maxCoverage = (Decimal) result.get('maxCoverage');
                Decimal avgCoverage = (Decimal) result.get('avgCoverage');
                Decimal outlierCount = (Decimal) result.get('outlierCount');
                
                System.debug('  • ' + ouName + ':');
                System.debug('    - Total Records: ' + totalRecords);
                System.debug('    - Non-null Coverage: ' + nonNullRecords);
                System.debug('    - Outliers: ' + outlierCount);
                System.debug('    - Min: ' + minCoverage + ', Max: ' + maxCoverage + ', Avg: ' + avgCoverage);
            }
            
        } catch (Exception e) {
            System.debug('❌ Error analyzing by OU: ' + e.getMessage());
        }
    }
    
    /**
     * Phase 4: Analyze coverage by country
     */
    private static void analyzeByCountry() {
        System.debug('\n--- PHASE 4: Coverage Analysis by Country ---');
        
        try {
            String countryQuery = 'SELECT WORK_LOCATION_COUNTRY__c, ' +
                                 'COUNT(Id) totalRecords, ' +
                                 'COUNT(COVERAGE__c) nonNullRecords, ' +
                                 'MIN(COVERAGE__c) minCoverage, ' +
                                 'MAX(COVERAGE__c) maxCoverage, ' +
                                 'AVG(COVERAGE__c) avgCoverage, ' +
                                 'SUM(CASE WHEN COVERAGE__c > ' + MAX_REASONABLE_COVERAGE + 
                                 ' OR COVERAGE__c < ' + MIN_REASONABLE_COVERAGE + ' THEN 1 ELSE 0 END) outlierCount ' +
                                 'FROM AGENT_OU_PIPELINE_V2__c ' +
                                 'WHERE IsDeleted = false ' +
                                 'GROUP BY WORK_LOCATION_COUNTRY__c ' +
                                 'HAVING COUNT(COVERAGE__c) > 0 ' +
                                 'ORDER BY outlierCount DESC ' +
                                 'LIMIT 10';
            
            List<AggregateResult> countryResults = Database.query(countryQuery);
            
            System.debug('📊 Coverage Analysis by Country (Top 10 by Outliers):');
            for (AggregateResult result : countryResults) {
                String country = (String) result.get('WORK_LOCATION_COUNTRY__c');
                Integer totalRecords = (Integer) result.get('totalRecords');
                Integer nonNullRecords = (Integer) result.get('nonNullRecords');
                Decimal minCoverage = (Decimal) result.get('minCoverage');
                Decimal maxCoverage = (Decimal) result.get('maxCoverage');
                Decimal avgCoverage = (Decimal) result.get('avgCoverage');
                Decimal outlierCount = (Decimal) result.get('outlierCount');
                
                System.debug('  • ' + country + ':');
                System.debug('    - Total Records: ' + totalRecords);
                System.debug('    - Non-null Coverage: ' + nonNullRecords);
                System.debug('    - Outliers: ' + outlierCount);
                System.debug('    - Min: ' + minCoverage + ', Max: ' + maxCoverage + ', Avg: ' + avgCoverage);
            }
            
        } catch (Exception e) {
            System.debug('❌ Error analyzing by country: ' + e.getMessage());
        }
    }
    
    /**
     * Phase 5: Identify patterns in bad data
     */
    private static void identifyDataPatterns() {
        System.debug('\n--- PHASE 5: Identifying Data Patterns ---');
        
        try {
            // Check if extreme values correlate with zero quota
            String patternQuery = 'SELECT ' +
                                 'SUM(CASE WHEN COVERAGE__c > ' + MAX_REASONABLE_COVERAGE + 
                                 ' OR COVERAGE__c < ' + MIN_REASONABLE_COVERAGE + ' THEN 1 ELSE 0 END) extremeWithQuota, ' +
                                 'SUM(CASE WHEN (COVERAGE__c > ' + MAX_REASONABLE_COVERAGE + 
                                 ' OR COVERAGE__c < ' + MIN_REASONABLE_COVERAGE + ') AND VAL_QUOTA__c = 0 THEN 1 ELSE 0 END) extremeWithZeroQuota ' +
                                 'FROM AGENT_OU_PIPELINE_V2__c ' +
                                 'WHERE IsDeleted = false ' +
                                 'AND COVERAGE__c != null';
            
            List<AggregateResult> patternResults = Database.query(patternQuery);
            
            for (AggregateResult result : patternResults) {
                Decimal extremeWithQuota = (Decimal) result.get('extremeWithQuota');
                Decimal extremeWithZeroQuota = (Decimal) result.get('extremeWithZeroQuota');
                
                System.debug('📊 Data Pattern Analysis:');
                System.debug('  • Extreme values with any quota: ' + extremeWithQuota);
                System.debug('  • Extreme values with zero quota: ' + extremeWithZeroQuota);
                
                if (extremeWithQuota > 0) {
                    Decimal zeroQuotaPercentage = (extremeWithZeroQuota / extremeWithQuota) * 100;
                    System.debug('  • Percentage of extreme values with zero quota: ' + zeroQuotaPercentage + '%');
                }
            }
            
        } catch (Exception e) {
            System.debug('❌ Error identifying patterns: ' + e.getMessage());
        }
    }
    
    /**
     * Generate cleanup recommendations
     */
    public static void generateCleanupRecommendations() {
        System.debug('\n--- CLEANUP RECOMMENDATIONS ---');
        
        System.debug('📋 Recommended Actions:');
        System.debug('1. **Immediate Actions:**');
        System.debug('   - Set extreme negative values (< -100) to 0 or null');
        System.debug('   - Set extreme positive values (> 1000) to 1000 or null');
        System.debug('   - Investigate records with zero quota and extreme coverage');
        
        System.debug('2. **Data Validation Rules:**');
        System.debug('   - Add validation rules to prevent future extreme values');
        System.debug('   - Implement data quality monitoring');
        System.debug('   - Create alerts for coverage values outside reasonable ranges');
        
        System.debug('3. **Process Improvements:**');
        System.debug('   - Review data source systems for calculation errors');
        System.debug('   - Implement data quality checks in ETL processes');
        System.debug('   - Train data entry personnel on reasonable coverage ranges');
        
        System.debug('4. **KPI Analysis Enhancements:**');
        System.debug('   - Add outlier detection to KPI analysis service');
        System.debug('   - Provide data quality warnings in analysis results');
        System.debug('   - Offer alternative metrics when primary metrics have quality issues');
    }
    
    /**
     * Execute cleanup (DRY RUN by default)
     */
    public static void executeCleanup(Boolean dryRun = true) {
        System.debug('\n--- EXECUTING CLEANUP ---');
        System.debug('Mode: ' + (dryRun ? 'DRY RUN' : 'LIVE UPDATE'));
        
        try {
            // Get records that need cleanup
            String cleanupQuery = 'SELECT Id, FULL_NAME__c, OU_NAME__c, WORK_LOCATION_COUNTRY__c, ' +
                                 'COVERAGE__c, VAL_QUOTA__c ' +
                                 'FROM AGENT_OU_PIPELINE_V2__c ' +
                                 'WHERE IsDeleted = false ' +
                                 'AND COVERAGE__c != null ' +
                                 'AND (COVERAGE__c > ' + MAX_REASONABLE_COVERAGE + 
                                 ' OR COVERAGE__c < ' + MIN_REASONABLE_COVERAGE + ') ' +
                                 'LIMIT ' + BATCH_SIZE;
            
            List<AGENT_OU_PIPELINE_V2__c> recordsToClean = Database.query(cleanupQuery);
            
            System.debug('📊 Records to clean: ' + recordsToClean.size());
            
            if (!dryRun && !recordsToClean.isEmpty()) {
                // Perform actual cleanup
                for (AGENT_OU_PIPELINE_V2__c record : recordsToClean) {
                    Decimal originalCoverage = record.COVERAGE__c;
                    
                    if (record.COVERAGE__c > MAX_REASONABLE_COVERAGE) {
                        record.COVERAGE__c = MAX_REASONABLE_COVERAGE;
                    } else if (record.COVERAGE__c < MIN_REASONABLE_COVERAGE) {
                        record.COVERAGE__c = DEFAULT_COVERAGE;
                    }
                    
                    System.debug('  • ' + record.FULL_NAME__c + ': ' + originalCoverage + ' → ' + record.COVERAGE__c);
                }
                
                // Update records
                update recordsToClean;
                System.debug('✅ Updated ' + recordsToClean.size() + ' records');
                
            } else {
                // Dry run - just show what would be changed
                for (AGENT_OU_PIPELINE_V2__c record : recordsToClean) {
                    Decimal originalCoverage = record.COVERAGE__c;
                    Decimal newCoverage = originalCoverage;
                    
                    if (record.COVERAGE__c > MAX_REASONABLE_COVERAGE) {
                        newCoverage = MAX_REASONABLE_COVERAGE;
                    } else if (record.COVERAGE__c < MIN_REASONABLE_COVERAGE) {
                        newCoverage = DEFAULT_COVERAGE;
                    }
                    
                    System.debug('  • ' + record.FULL_NAME__c + ': ' + originalCoverage + ' → ' + newCoverage);
                }
                
                System.debug('📋 DRY RUN: Would update ' + recordsToClean.size() + ' records');
            }
            
        } catch (Exception e) {
            System.debug('❌ Error during cleanup: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
    }
}

// Execute the analysis
System.debug('🚀 Starting Coverage Data Cleanup Analysis...');
CoverageDataCleanup.analyzeCoverageDataQuality();
CoverageDataCleanup.generateCleanupRecommendations();
CoverageDataCleanup.executeCleanup(true); // Dry run
System.debug('✅ Coverage Data Cleanup Analysis Complete!');
