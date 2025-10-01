public with sharing class ANAgentAggregationRunner {
    
    /**
     * Individual row result
     */
    public class Row {
        public String groupValue;    // null when no group
        public Decimal agg;          // raw aggregate numeric
        public Integer nPeople;      // nullable; only when perAENormalize requested
    }
    
    /**
     * Complete result set
     */
    public class Result {
        public List<Row> rows;
        public Decimal totalAgg;     // sum of row.agg
        public Integer totalPeople;  // sum of row.nPeople (when applicable)
        
        public Result() {
            this.rows = new List<Row>();
            this.totalAgg = 0;
            this.totalPeople = 0;
        }
    }
    
    /**
     * Execute a single aggregation specification and return results
     * @param spec ANAgentAggregationSpec the specification to execute
     * @return Result the aggregation results
     */
    public static Result run(ANAgentAggregationSpec spec) {
        // Validate the spec
        if (!spec.isValid()) {
            throw new ANAgentErrors.InvalidAggregationSpecException('Invalid aggregation specification: ' + String.join(spec.getValidationErrors(), ', '));
        }
        
        // Build the SOQL query
        ANAgentSOQLBuilder.BuiltQuery query = ANAgentSOQLBuilder.build(spec);
        
        // Execute the query
        List<AggregateResult> ars;
        try {
            ars = Database.query(query.soql);
        } catch (Exception e) {
            throw new ANAgentErrors.QueryExecutionException('Failed to execute aggregation query: ' + e.getMessage());
        }
        
        // Process results
        Result result = new Result();
        
        for (AggregateResult ar : ars) {
            Row row = new Row();
            
            // Set group value (null for ungrouped queries)
            row.groupValue = (spec.groupByFieldApi == null ? null : (String) ar.get(query.groupAlias));
            
            // Set aggregate value
            Object aggValue = ar.get(query.alias);
            if (aggValue != null) {
                row.agg = (Decimal) aggValue;
            } else {
                row.agg = 0;
            }
            
            // Set people count if per-AE normalization was requested
            if (spec.perAENormalize == true) {
                Object peopleValue = ar.get('nPeople');
                if (peopleValue != null) {
                    row.nPeople = (Integer) peopleValue;
                }
            }
            
            result.rows.add(row);
            
            // Accumulate totals
            result.totalAgg += row.agg;
            if (row.nPeople != null) {
                result.totalPeople += row.nPeople;
            }
        }
        
        return result;
    }
    
    /**
     * Execute multiple aggregation specifications and return combined results
     * @param specs List<ANAgentAggregationSpec> list of specifications to execute
     * @return List<Result> list of results in same order as specs
     */
    public static List<Result> runMultiple(List<ANAgentAggregationSpec> specs) {
        List<Result> results = new List<Result>();
        
        for (ANAgentAggregationSpec spec : specs) {
            try {
                results.add(run(spec));
            } catch (Exception e) {
                // Create error result
                Result errorResult = new Result();
                errorResult.rows = new List<Row>();
                results.add(errorResult);
                
                // Log the error
                ANAgentLog.error(ANAgentLog.LogCategory.AGGREGATION, 'Failed to execute spec: ' + spec.getSummary(), 'ANAgentAggregationRunner', 'runMultiple', 104);
            }
        }
        
        return results;
    }
    
    /**
     * Check if a spec should use batch processing
     * @param spec ANAgentAggregationSpec the specification to check
     * @return Boolean true if batch processing should be used
     */
    public static Boolean shouldUseBatch(ANAgentAggregationSpec spec) {
        // Force async if specified
        if (spec.forceAsync == true) {
            return true;
        }
        
        // Use batch for large restrict values
        if (spec.restrictInValues != null && spec.restrictInValues.size() > 100) {
            return true;
        }
        
        // Use batch for expected large result sets
        if (spec.groupByFieldApi != null && spec.restrictInValues != null && spec.restrictInValues.size() > 50) {
            return true;
        }
        
        return false;
    }
} 