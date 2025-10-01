/**
 * KPI Outlier Detection Service
 * Provides statistical outlier detection using Z-score and IQR methods
 * 
 * @version 1.0
 * @author AI Assistant
 */
public with sharing class ANAgentKPIOutlierService {
    
    // Outlier detection result structure
    public class OutlierResult {
        public List<OutlierData> highOutliers;
        public List<OutlierData> lowOutliers;
        public Map<String, Decimal> statistics;
        public String method;
        public String metric;
        
        public OutlierResult() {
            this.highOutliers = new List<OutlierData>();
            this.lowOutliers = new List<OutlierData>();
            this.statistics = new Map<String, Decimal>();
        }
    }
    
    // Individual outlier data point
    public class OutlierData {
        public String recordId;
        public String aeName;
        public String aeEmail;
        public String learnerProfileId;
        public String ou;
        public String country;
        public Decimal value;
        public Decimal zScore;
        public Decimal deltaFromMedian;
        public String outlierType; // 'HIGH' or 'LOW'
        
        public OutlierData(String recordId, String aeName, String aeEmail, String learnerProfileId, 
                          String ou, String country, Decimal value, Decimal zScore, Decimal deltaFromMedian, String outlierType) {
            this.recordId = recordId;
            this.aeName = aeName;
            this.aeEmail = aeEmail;
            this.learnerProfileId = learnerProfileId;
            this.ou = ou;
            this.country = country;
            this.value = value;
            this.zScore = zScore;
            this.deltaFromMedian = deltaFromMedian;
            this.outlierType = outlierType;
        }
    }
    
    // Default configuration values
    private static final Decimal DEFAULT_Z_THRESHOLD = 2.5;
    private static final Decimal DEFAULT_IQR_MULTIPLIER = 1.5;
    private static final Integer DEFAULT_MAX_ROWS = 2000;
    private static final Boolean DEFAULT_ENABLE_OUTLIERS = false;
    
    /**
     * Detect outliers using Z-score method
     * @param data List of values to analyze
     * @param zThreshold Z-score threshold (default 2.5)
     * @return OutlierResult with detected outliers
     */
    public static OutlierResult detectZScoreOutliers(List<Decimal> data, Decimal zThreshold) {
        if (data == null || data.isEmpty()) {
            return new OutlierResult();
        }
        
        if (zThreshold == null) {
            zThreshold = DEFAULT_Z_THRESHOLD;
        }
        
        OutlierResult result = new OutlierResult();
        result.method = 'Z-Score';
        result.statistics = calculateStatistics(data);
        
        Decimal mean = result.statistics.get('mean');
        Decimal stdDev = result.statistics.get('stdDev');
        
        if (stdDev == 0) {
            return result; // No variation, no outliers
        }
        
        for (Integer i = 0; i < data.size(); i++) {
            if (data[i] != null) {
                Decimal zScore = (data[i] - mean) / stdDev;
                Decimal deltaFromMedian = data[i] - result.statistics.get('median');
                
                if (zScore > zThreshold) {
                    result.highOutliers.add(new OutlierData(null, null, null, null, null, null, 
                                                          data[i], zScore, deltaFromMedian, 'HIGH'));
                } else if (zScore < -zThreshold) {
                    result.lowOutliers.add(new OutlierData(null, null, null, null, null, null, 
                                                         data[i], zScore, deltaFromMedian, 'LOW'));
                }
            }
        }
        
        return result;
    }
    
    /**
     * Detect outliers using IQR (Interquartile Range) method
     * @param data List of values to analyze
     * @param k IQR multiplier (default 1.5)
     * @return OutlierResult with detected outliers
     */
    public static OutlierResult detectIQR(List<Decimal> data, Decimal k) {
        if (data == null || data.isEmpty()) {
            return new OutlierResult();
        }
        
        if (k == null) {
            k = DEFAULT_IQR_MULTIPLIER;
        }
        
        OutlierResult result = new OutlierResult();
        result.method = 'IQR';
        result.statistics = calculateStatistics(data);
        
        Decimal q1 = result.statistics.get('q1');
        Decimal q3 = result.statistics.get('q3');
        Decimal iqr = q3 - q1;
        
        Decimal lowerBound = q1 - (k * iqr);
        Decimal upperBound = q3 + (k * iqr);
        
        for (Integer i = 0; i < data.size(); i++) {
            if (data[i] != null) {
                Decimal deltaFromMedian = data[i] - result.statistics.get('median');
                
                if (data[i] > upperBound) {
                    result.highOutliers.add(new OutlierData(null, null, null, null, null, null, 
                                                          data[i], null, deltaFromMedian, 'HIGH'));
                } else if (data[i] < lowerBound) {
                    result.lowOutliers.add(new OutlierData(null, null, null, null, null, null, 
                                                         data[i], null, deltaFromMedian, 'LOW'));
                }
            }
        }
        
        return result;
    }
    
    /**
     * Detect outliers for KPI records with full context
     * @param records List of AGENT_OU_PIPELINE_V2__c records
     * @param metricField Field to analyze (e.g., 'CQ_CUSTOMER_MEETING__c')
     * @param method Detection method ('Z-Score' or 'IQR')
     * @return OutlierResult with full record context
     */
    public static OutlierResult detectKPIOutliers(List<AGENT_OU_PIPELINE_V2__c> records, String metricField, String method) {
        if (records == null || records.isEmpty() || String.isBlank(metricField)) {
            return new OutlierResult();
        }
        
        // Extract values and create mapping
        List<Decimal> values = new List<Decimal>();
        Map<Decimal, List<AGENT_OU_PIPELINE_V2__c>> valueToRecords = new Map<Decimal, List<AGENT_OU_PIPELINE_V2__c>>();
        
        for (AGENT_OU_PIPELINE_V2__c record : records) {
            Decimal value = getFieldValue(record, metricField);
            if (value != null) {
                values.add(value);
                if (!valueToRecords.containsKey(value)) {
                    valueToRecords.put(value, new List<AGENT_OU_PIPELINE_V2__c>());
                }
                valueToRecords.get(value).add(record);
            }
        }
        
        if (values.isEmpty()) {
            return new OutlierResult();
        }
        
        // Detect outliers
        OutlierResult result;
        if ('IQR'.equals(method)) {
            result = detectIQR(values, null);
        } else {
            result = detectZScoreOutliers(values, null);
        }
        
        result.metric = metricField;
        
        // Enrich with record context
        enrichOutliersWithContext(result.highOutliers, valueToRecords, metricField);
        enrichOutliersWithContext(result.lowOutliers, valueToRecords, metricField);
        
        return result;
    }
    
    /**
     * Calculate comprehensive statistics for a dataset
     * @param data List of values
     * @return Map of statistics (mean, median, stdDev, q1, q3, min, max)
     */
    private static Map<String, Decimal> calculateStatistics(List<Decimal> data) {
        Map<String, Decimal> stats = new Map<String, Decimal>();
        
        if (data.isEmpty()) {
            return stats;
        }
        
        // Sort data for percentile calculations
        List<Decimal> sortedData = new List<Decimal>(data);
        sortedData.sort();
        
        Integer n = sortedData.size();
        
        // Basic statistics
        Decimal sum = 0;
        for (Decimal value : data) {
            if (value != null) {
                sum += value;
            }
        }
        
        Decimal mean = sum / n;
        stats.put('mean', mean);
        stats.put('min', sortedData[0]);
        stats.put('max', sortedData[n - 1]);
        
        // Median
        if (Math.mod(n, 2) == 0) {
            stats.put('median', (sortedData[n / 2 - 1] + sortedData[n / 2]) / 2);
        } else {
            stats.put('median', sortedData[n / 2]);
        }
        
        // Quartiles
        stats.put('q1', calculatePercentile(sortedData, 25));
        stats.put('q3', calculatePercentile(sortedData, 75));
        
        // Standard deviation
        Decimal variance = 0;
        for (Decimal value : data) {
            if (value != null) {
                variance += (value - mean) * (value - mean);
            }
        }
        Decimal stdDev = Math.sqrt(variance / n);
        stats.put('stdDev', stdDev);
        
        return stats;
    }
    
    /**
     * Calculate percentile for sorted data
     * @param sortedData Sorted list of values
     * @param percentile Percentile to calculate (0-100)
     * @return Percentile value
     */
    private static Decimal calculatePercentile(List<Decimal> sortedData, Decimal percentile) {
        if (sortedData.isEmpty()) return 0;
        
        Decimal index = (percentile / 100) * (sortedData.size() - 1);
        Integer lowerIndex = (Integer) Math.floor(index);
        Integer upperIndex = (Integer) Math.ceil(index);
        
        if (lowerIndex == upperIndex) {
            return sortedData[lowerIndex];
        }
        
        Decimal weight = index - lowerIndex;
        return sortedData[lowerIndex] * (1 - weight) + sortedData[upperIndex] * weight;
    }
    
    /**
     * Enrich outlier data with record context
     * @param outliers List of outlier data to enrich
     * @param valueToRecords Mapping of values to records
     * @param metricField Field being analyzed
     */
    private static void enrichOutliersWithContext(List<OutlierData> outliers, 
                                                Map<Decimal, List<AGENT_OU_PIPELINE_V2__c>> valueToRecords, 
                                                String metricField) {
        for (OutlierData outlier : outliers) {
            List<AGENT_OU_PIPELINE_V2__c> records = valueToRecords.get(outlier.value);
            if (records != null && !records.isEmpty()) {
                AGENT_OU_PIPELINE_V2__c record = records[0]; // Take first match
                outlier.recordId = record.Id;
                outlier.aeName = record.FULL_NAME__c;
                outlier.aeEmail = record.EMP_EMAIL_ADDR__c;
                outlier.learnerProfileId = record.LEARNER_PROFILE_ID__c;
                outlier.ou = record.OU_NAME__c;
                outlier.country = record.WORK_LOCATION_COUNTRY__c;
            }
        }
    }
    
    /**
     * Get field value from record using reflection
     * @param record SObject record
     * @param fieldName Field API name
     * @return Field value as Decimal
     */
    private static Decimal getFieldValue(AGENT_OU_PIPELINE_V2__c record, String fieldName) {
        try {
            Object value = record.get(fieldName);
            if (value instanceof Decimal) {
                return (Decimal) value;
            } else if (value instanceof Integer) {
                return Decimal.valueOf((Integer) value);
            }
        } catch (Exception e) {
            System.debug('Error getting field value for ' + fieldName + ': ' + e.getMessage());
        }
        return null;
    }
    
    /**
     * Check if outlier detection is enabled (simplified - always true for now)
     * @return True if enabled
     */
    public static Boolean isOutlierDetectionEnabled() {
        return true; // Simplified for now
    }
    
    /**
     * Get maximum rows limit
     * @return Maximum rows allowed
     */
    public static Integer getMaxRows() {
        return DEFAULT_MAX_ROWS;
    }
}