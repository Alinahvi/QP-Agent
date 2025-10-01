public with sharing class ANAgentAggregationSpec {
    
    // Core aggregation parameters
    @InvocableVariable(label='Metric Key' description='Key for the metric to aggregate (ACV, PG, CALLS, etc.)')
    public String metricKey;
    
    @InvocableVariable(label='Time Frame' description='Time frame for analysis (CURRENT, PREVIOUS)')
    public String timeFrame;
    
    @InvocableVariable(label='Group By Dimension' description='Single dimension to group by (COUNTRY, OU, INDUSTRY, AE)')
    public String groupByDim;
    
    @InvocableVariable(label='Filter Where' description='SOQL-safe fragment from FilterParser')
    public String filterWhere;
    
    @InvocableVariable(label='Limit' description='Maximum number of results')
    public Integer limitN;
    
    @InvocableVariable(label='Per AE Normalize' description='Use per-AE denominator for averages')
    public Boolean perAENormalize;
    
    @InvocableVariable(label='Restrict In Values' description='Only valid when groupByDim != null; used for same-dim A vs B')
    public List<String> restrictInValues;
    
    @InvocableVariable(label='Require Non-Null Metric' description='Add metric != null guard')
    public Boolean requireNonNullMetric;
    
    @InvocableVariable(label='Force Async' description='Force batch/queueable processing')
    public Boolean forceAsync;
    
    // Resolved by registry lookups, populated by factory method
    public String currentField;              // e.g., CQ_ACV__c
    public String previousField;             // e.g., PQ_ACV__c (nullable)
    public String aggFn;                     // 'SUM' | 'AVG' | 'COUNT'
    public String groupByFieldApi;           // resolved field API for groupByDim
    public String metricFieldApi;            // resolved field API for timeframe
    
    // Constructor
    public ANAgentAggregationSpec() {
        this.timeFrame = 'CURRENT';
        this.perAENormalize = false;

        this.requireNonNullMetric = true;
        this.forceAsync = false;
        this.restrictInValues = new List<String>();
    }
    
    /**
     * Factory method to create and populate a spec from request parameters
     * @param metricKey String metric key
     * @param timeFrame String timeframe (CURRENT/PREVIOUS)
     * @param groupByDim String dimension to group by (nullable)
     * @param filterWhere String SOQL-safe filter fragment
     * @param limitN Integer limit (nullable)
     * @param restrictInValues List<String> restrict values for same-dim comparison
     * @param perAENormalize Boolean whether to normalize per AE (nullable)
     * @return ANAgentAggregationSpec populated spec
     */
    public static ANAgentAggregationSpec fromRequest(String metricKey, String timeFrame, String groupByDim, 
                                                   String filterWhere, Integer limitN, List<String> restrictInValues, 
                                                   Boolean perAENormalize) {
        ANAgentAggregationSpec spec = new ANAgentAggregationSpec();
        spec.metricKey = metricKey;
        spec.timeFrame = timeFrame;
        spec.groupByDim = groupByDim;
        spec.filterWhere = filterWhere;
        spec.limitN = limitN;
        spec.restrictInValues = restrictInValues != null ? restrictInValues : new List<String>();
        spec.perAENormalize = perAENormalize != null ? perAENormalize : false;
        
        // Resolve metric definition
        ANAgentMetricRegistry.MetricDefinition metricDef = ANAgentMetricRegistry.getInstance().get(metricKey);
        if (metricDef == null) {
            throw new ANAgentErrors.InvalidMetricException('Unknown metric: ' + metricKey);
        }
        
        // Validate timeframe support
        if (timeFrame == 'PREVIOUS' && !metricDef.requiresTimeframe) {
            throw new ANAgentErrors.UnsupportedTimeframeException('Metric ' + metricKey + ' does not support PREVIOUS timeframe');
        }
        
        // Populate resolved fields
        spec.currentField = metricDef.currentField;
        spec.previousField = metricDef.previousField;
        spec.aggFn = metricDef.defaultAgg;
        
        // Resolve metric field for timeframe
        spec.metricFieldApi = ANAgentMetricRegistry.getInstance().resolveField(metricKey, timeFrame);
        
        // Resolve group by field if specified
        if (String.isNotBlank(groupByDim)) {
            spec.groupByFieldApi = ANAgentDimensionRegistry.getInstance().fieldFor(groupByDim);
            if (String.isBlank(spec.groupByFieldApi)) {
                throw new ANAgentErrors.InvalidDimensionException('Unknown dimension: ' + groupByDim);
            }
        }
        
        return spec;
    }
    
    /**
     * Validate the aggregation specification
     * @return Boolean true if valid
     */
    public Boolean isValid() {
        if (String.isBlank(metricKey) || String.isBlank(metricFieldApi)) {
            return false;
        }
        
        // Check if metric exists
        if (!ANAgentMetricRegistry.getInstance().hasMetric(metricKey)) {
            return false;
        }
        
        // Check timeframe compatibility
        if (String.isNotBlank(timeFrame) && 
            ANAgentMetricRegistry.getInstance().requiresTimeframe(metricKey) && 
            timeFrame == 'PREVIOUS' && 
            ANAgentMetricRegistry.getInstance().get(metricKey).previousField == null) {
            return false;
        }
        
        return true;
    }
    
    /**
     * Get validation errors
     * @return List<String> list of validation errors
     */
    public List<String> getValidationErrors() {
        List<String> errors = new List<String>();
        
        if (String.isBlank(metricKey)) {
            errors.add('Metric key is required');
        } else if (!ANAgentMetricRegistry.getInstance().hasMetric(metricKey)) {
            errors.add('Unknown metric: ' + metricKey);
        }
        
        if (String.isBlank(metricFieldApi)) {
            errors.add('Metric field not resolved');
        }
        
        // Check timeframe compatibility
        if (String.isNotBlank(timeFrame) && 
            ANAgentMetricRegistry.getInstance().requiresTimeframe(metricKey) && 
            timeFrame == 'PREVIOUS' && 
            ANAgentMetricRegistry.getInstance().get(metricKey).previousField == null) {
            errors.add('Metric ' + metricKey + ' does not support PREVIOUS timeframe');
        }
        
        // Validate group by dimension
        if (String.isNotBlank(groupByDim) && String.isBlank(groupByFieldApi)) {
            errors.add('Unknown dimension: ' + groupByDim);
        }
        
        return errors;
    }
    
    /**
     * Check if this is an aggregate query
     * @return Boolean true if aggregate query
     */
    public Boolean isAggregateQuery() {
        return String.isNotBlank(groupByFieldApi);
    }
    
    /**
     * Get a summary of the specification
     * @return String summary
     */
    public String getSummary() {
        List<String> parts = new List<String>();
        
        parts.add('Metric: ' + metricKey);
        parts.add('Timeframe: ' + timeFrame);
        parts.add('Aggregation: ' + aggFn);
        
        if (String.isNotBlank(groupByDim)) {
            parts.add('Group By: ' + groupByDim);
        }
        
        if (String.isNotBlank(filterWhere)) {
            parts.add('Filter: ' + filterWhere);
        }
        
        if (limitN != null) {
            parts.add('Limit: ' + limitN);
        }
        
        if (perAENormalize) {
            parts.add('Per-AE Normalize: true');
        }
        
        return String.join(parts, ' | ');
    }
} 