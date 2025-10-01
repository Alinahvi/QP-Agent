public with sharing class ANAgentMetricRegistry {
    
    public class MetricDefinition {
        public String metricKey;
        public String currentField;
        public String previousField;
        public String defaultAgg;
        public String dataType;
        public String nullPolicy;
        public Boolean requiresTimeframe;
        public Boolean perAEDenominator;
        public Integer precision;
        
        public MetricDefinition(String key, String current, String previous, String agg, String type, String policy, Boolean requiresTime, Boolean perAE, Integer prec) {
            this.metricKey = key;
            this.currentField = current;
            this.previousField = previous;
            this.defaultAgg = agg;
            this.dataType = type;
            this.nullPolicy = policy;
            this.requiresTimeframe = requiresTime;
            this.perAEDenominator = perAE;
            this.precision = prec;
        }
    }
    
    // Singleton instance
    private static ANAgentMetricRegistry instance;
    
    // Metric definitions cache
    private Map<String, MetricDefinition> metrics;
    
    private ANAgentMetricRegistry() {
        initializeMetrics();
    }
    
    public static ANAgentMetricRegistry getInstance() {
        if (instance == null) {
            instance = new ANAgentMetricRegistry();
        }
        return instance;
    }
    
    private void initializeMetrics() {
        metrics = new Map<String, MetricDefinition>();
        
        // ACV - Annual Contract Value
        metrics.put('ACV', new MetricDefinition(
            'ACV', 'CQ_ACV__c', 'PQ_ACV__c', 'SUM', 'Currency', 'exclude_null', true, false, 2
        ));
        
        // Pipeline Generation
        metrics.put('PG', new MetricDefinition(
            'PG', 'CQ_PG__c', 'PQ_PG__c', 'SUM', 'Currency', 'exclude_null', true, false, 2
        ));
        
        // Calls
        metrics.put('CALLS', new MetricDefinition(
            'CALLS', 'CQ_CALL_CONNECT__c', 'PQ_CALL_CONNECT__c', 'AVG', 'Number', 'exclude_null', true, true, 2
        ));
        
        // Meetings
        metrics.put('MEETINGS', new MetricDefinition(
            'MEETINGS', 'CQ_CUSTOMER_MEETING__c', 'PQ_CUSTOMER_MEETING__c', 'AVG', 'Number', 'exclude_null', true, true, 2
        ));
        
        // AI Mentions
        metrics.put('AI_MENTIONS', new MetricDefinition(
            'AI_MENTIONS', 'CALL_AI_MENTION__c', null, 'COUNT', 'Number', 'exclude_null', false, false, 0
        ));
        
        // Coverage
        metrics.put('COVERAGE', new MetricDefinition(
            'COVERAGE', 'COVERAGE__c', null, 'AVG', 'Number', 'exclude_null', false, true, 2
        ));
        
        // Ramp Status
        metrics.put('RAMP_STATUS', new MetricDefinition(
            'RAMP_STATUS', 'RAMP_STATUS__c', null, 'AVG', 'Number', 'exclude_null', false, true, 2
        ));
        
        // Growth Factors
        metrics.put('GROWTH_FACTORS', new MetricDefinition(
            'GROWTH_FACTORS', 'ACTIONABLE__c', null, 'COUNT', 'Number', 'exclude_null', false, false, 0
        ));
    }
    
    /**
     * Get metric definition by key
     * @param metricKey String metric key
     * @return MetricDefinition or null if not found
     */
    public MetricDefinition get(String metricKey) {
        if (String.isBlank(metricKey)) return null;
        return metrics.get(metricKey.toUpperCase());
    }
    
    /**
     * Get current field for metric and timeframe
     * @param metricKey String metric key
     * @param timeframe String timeframe (CURRENT/PREVIOUS)
     * @return String field name
     */
    public String resolveField(String metricKey, String timeframe) {
        MetricDefinition def = get(metricKey);
        if (def == null) return null;
        
        if (timeframe == 'PREVIOUS') {
            if (def.previousField == null) {
                throw new ANAgentErrors.UnsupportedTimeframeException(
                    'Metric ' + metricKey + ' does not support PREVIOUS timeframe'
                );
            }
            return def.previousField;
        }
        
        return def.currentField;
    }
    
    /**
     * Get default aggregation for metric
     * @param metricKey String metric key
     * @return String aggregation type
     */
    public String getDefaultAggregation(String metricKey) {
        MetricDefinition def = get(metricKey);
        return def != null ? def.defaultAgg : 'SUM';
    }
    
    /**
     * Check if metric requires timeframe
     * @param metricKey String metric key
     * @return Boolean true if timeframe required
     */
    public Boolean requiresTimeframe(String metricKey) {
        MetricDefinition def = get(metricKey);
        return def != null ? def.requiresTimeframe : false;
    }
    
    /**
     * Check if metric uses per-AE denominator
     * @param metricKey String metric key
     * @return Boolean true if per-AE denominator used
     */
    public Boolean usesPerAEDenominator(String metricKey) {
        MetricDefinition def = get(metricKey);
        return def != null ? def.perAEDenominator : false;
    }
    
    /**
     * Get data type for metric
     * @param metricKey String metric key
     * @return String data type
     */
    public String getDataType(String metricKey) {
        MetricDefinition def = get(metricKey);
        return def != null ? def.dataType : 'Number';
    }
    
    /**
     * Get precision for metric
     * @param metricKey String metric key
     * @return Integer precision
     */
    public Integer getPrecision(String metricKey) {
        MetricDefinition def = get(metricKey);
        return def != null ? def.precision : 2;
    }
    
    /**
     * Get null policy for metric
     * @param metricKey String metric key
     * @return String null policy
     */
    public String getNullPolicy(String metricKey) {
        MetricDefinition def = get(metricKey);
        return def != null ? def.nullPolicy : 'exclude_null';
    }
    
    /**
     * Get all available metric keys
     * @return List<String> of metric keys
     */
    public List<String> getAllMetricKeys() {
        return new List<String>(metrics.keySet());
    }
    
    /**
     * Check if metric exists
     * @param metricKey String metric key
     * @return Boolean true if metric exists
     */
    public Boolean hasMetric(String metricKey) {
        return get(metricKey) != null;
    }
} 