public with sharing class ANAgentAggregationJob implements Database.Batchable<SObject>, Database.Stateful {
    
    private ANAgentAggregationSpec spec;
    private Map<String, RunningTotals> groups;
    private String jobKey;
    
    /**
     * Running totals for aggregation
     */
    private class RunningTotals {
        Decimal metricSum = 0;
        Set<String> people = new Set<String>();
        
        void addRecord(Decimal metricValue, String empId) {
            if (metricValue != null) {
                this.metricSum += metricValue;
            }
            if (String.isNotBlank(empId)) {
                this.people.add(empId);
            }
        }
        
        ANAgentAggregationRunner.Row toRow(String groupValue, Boolean perAENormalize) {
            ANAgentAggregationRunner.Row row = new ANAgentAggregationRunner.Row();
            row.groupValue = groupValue;
            row.agg = this.metricSum;
            if (perAENormalize) {
                row.nPeople = this.people.size();
            }
            return row;
        }
    }
    
    /**
     * Constructor for batch processing
     * @param spec ANAgentAggregationSpec the specification to process
     */
    public ANAgentAggregationJob(ANAgentAggregationSpec spec) {
        this.spec = spec;
        this.groups = new Map<String, RunningTotals>();
        this.jobKey = generateJobKey();
    }
    
    /**
     * Start method for batch processing
     * @param ctx Database.BatchableContext the batch context
     * @return Database.QueryLocator the query locator
     */
    public Database.QueryLocator start(Database.BatchableContext ctx) {
        // Build a non-aggregate query for streaming
        String soql = ANAgentSOQLBuilder.buildNonAggregate(spec);
        
        // Log the job start
        ANAgentLog.info(ANAgentLog.LogCategory.AGGREGATION, 'Starting batch job: ' + jobKey + ' with SOQL: ' + soql, 'ANAgentAggregationJob', 'start', 66);
        
        return Database.getQueryLocator(soql);
    }
    
    /**
     * Execute method for batch processing
     * @param ctx Database.BatchableContext the batch context
     * @param scope List<SObject> the batch of records to process
     */
    public void execute(Database.BatchableContext ctx, List<SObject> scope) {
        // Process each record in the scope
        for (SObject record : scope) {
            String groupKey = '__ALL__';
            if (String.isNotBlank(spec.groupByFieldApi)) {
                groupKey = (String) record.get(spec.groupByFieldApi);
                if (String.isBlank(groupKey)) {
                    groupKey = '__NULL__';
                }
            }
            
            // Get or create running totals for this group
            if (!groups.containsKey(groupKey)) {
                groups.put(groupKey, new RunningTotals());
            }
            
            RunningTotals totals = groups.get(groupKey);
            
            // Add the record to totals
            Decimal metricValue = (Decimal) record.get(spec.metricFieldApi);
            String empId = spec.perAENormalize ? (String) record.get('EMP_ID__c') : null;
            
            totals.addRecord(metricValue, empId);
        }
        
        // Log progress
        ANAgentLog.info(ANAgentLog.LogCategory.AGGREGATION, 'Processed batch of ' + scope.size() + ' records. Total groups: ' + groups.size(), 'ANAgentAggregationJob', 'execute', 95);
    }
    
    /**
     * Finish method for batch processing
     * @param ctx Database.BatchableContext the batch context
     */
    public void finish(Database.BatchableContext ctx) {
        // Convert running totals to result format
        List<ANAgentAggregationRunner.Row> rows = new List<ANAgentAggregationRunner.Row>();
        Decimal totalAgg = 0;
        Integer totalPeople = 0;
        
        for (String groupKey : groups.keySet()) {
            RunningTotals totals = groups.get(groupKey);
            String groupValue = (groupKey == '__ALL__' ? null : (groupKey == '__NULL__' ? null : groupKey));
            
            ANAgentAggregationRunner.Row row = totals.toRow(groupValue, spec.perAENormalize);
            rows.add(row);
            
            totalAgg += row.agg;
            if (row.nPeople != null) {
                totalPeople += row.nPeople;
            }
        }
        
        // Create result
        ANAgentAggregationRunner.Result result = new ANAgentAggregationRunner.Result();
        result.rows = rows;
        result.totalAgg = totalAgg;
        result.totalPeople = totalPeople;
        
        // Log completion
        ANAgentLog.info(ANAgentLog.LogCategory.AGGREGATION, 'Batch job completed: ' + jobKey + '. Processed ' + rows.size() + ' groups with total agg: ' + totalAgg, 'ANAgentAggregationJob', 'finish', 125);
        
        // TODO: Store result in cache or custom object for retrieval
        // For now, just log the result
        System.debug('Batch aggregation result: ' + result);
    }
    
    /**
     * Generate a unique job key
     * @return String unique job identifier
     */
    private String generateJobKey() {
        return 'AGG_' + Datetime.now().getTime() + '_' + Math.mod(Crypto.getRandomInteger(), 10000);
    }
    
    /**
     * Start a batch job for the given specification
     * @param spec ANAgentAggregationSpec the specification to process
     * @param batchSize Integer the batch size (optional, defaults to 200)
     * @return Id the batch job ID
     */
    public static Id startBatch(ANAgentAggregationSpec spec, Integer batchSize) {
        if (spec == null) {
            throw new ANAgentErrors.InvalidAggregationSpecException('Spec cannot be null');
        }
        
        ANAgentAggregationJob job = new ANAgentAggregationJob(spec);
        return Database.executeBatch(job, batchSize != null ? batchSize : 200);
    }
    
    /**
     * Start a batch job with default batch size
     * @param spec ANAgentAggregationSpec the specification to process
     * @return Id the batch job ID
     */
    public static Id startBatch(ANAgentAggregationSpec spec) {
        return startBatch(spec, 200);
    }
    
    /**
     * Get the result from a completed batch job
     * @param jobId Id the batch job ID
     * @return ANAgentAggregationRunner.Result the aggregation result
     */
    public static ANAgentAggregationRunner.Result getResult(Id jobId) {
        // TODO: Implement result retrieval from cache or custom object
        // For now, return null as this is a placeholder
        ANAgentLog.warn(ANAgentLog.LogCategory.AGGREGATION, 'getResult not yet implemented for job: ' + jobId, 'ANAgentAggregationJob', 'getResult', 175);
        return null;
    }
} 