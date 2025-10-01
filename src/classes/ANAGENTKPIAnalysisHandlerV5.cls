/**
 * TEMPLATE HANDLER - This class acts as agent instructions in our handler/service template.
 * Business Requirement: The handler validates requests and delegates business logic to the service layer.
 * @description Handler class for KPI Analysis operations on AGENT_OU_PIPELINE_V2__c records.
 * This class is the primary entry point for the AI agent to analyze KPIs across AE rosters.
 * It validates requests and routes them to the ANAGENTKPIAnalysisServiceV5 for execution.
 *
 * The service fetches AGENT_OU_PIPELINE_V2__c records and computes KPIs based on specified metrics,
 * timeframes, and grouping criteria.
 *
 * @version 5.0
 */
public with sharing class ANAGENTKPIAnalysisHandlerV5 {
    
    /**
     * @description The request object for the KPI Analysis invocable method.
     */
    public class Request {
        @InvocableVariable(
            label='Metric Key'
            description='The KPI metric to analyze. Must be one of: "ACV", "PG", "CALLS", "MEETINGS", "AI_MENTIONS", "COVERAGE". Defaults to "CALLS".'
            required=false
        )
        public String metricKey;
        
        @InvocableVariable(
            label='Timeframe'
            description='The time period for analysis. Must be "CURRENT" or "PREVIOUS". Defaults to "CURRENT".'
            required=false
        )
        public String timeframe;
        
        @InvocableVariable(
            label='Group By'
            description='The field to group results by. Must be one of: "COUNTRY", "OU", "INDUSTRY", "AE". Defaults to "COUNTRY".'
            required=false
        )
        public String groupBy;
        
        @InvocableVariable(
            label='Filter Criteria'
            description='SOQL WHERE clause filter using allowed fields: country, ou, industry, ae. Example: "country=\'US\' AND industry=\'Tech\'"'
            required=false
        )
        public String filterCriteria;
        
        @InvocableVariable(
            label='Restrict Values CSV'
            description='Comma-separated values to restrict results to specific groups. Example: "US,Brazil" for country grouping.'
            required=false
        )
        public String restrictInValuesCsv;
        
        @InvocableVariable(
            label='Per AE Normalize'
            description='If true, returns average per AE instead of total sum. Defaults to false.'
            required=false
        )
        public Boolean perAENormalize;
        
        @InvocableVariable(
            label='Record Limit'
            description='Maximum number of grouped results to return. Only send when user explicitly requests a limit (e.g., "top 5", "show me 10"). Leave empty to show all results.'
            required=false
        )
        public Integer limitN;
        
        @InvocableVariable(
            label='Aggregation Type'
            description='The type of aggregation to perform: "SUM", "AVG", "MAX", "MIN", "COUNT", "MEDIAN". Defaults to "SUM".'
            required=false
        )
        public String aggregationType;
    }
    
    /**
     * @description The response object for the KPI Analysis invocable method.
     * Follows FR agent best practices: only message field exposed to agent.
     */
    public class Response {
        @InvocableVariable(
            label='Analysis Message'
            description='Complete KPI analysis results formatted as a human-readable message with Markdown structure and compact JSON data.'
            required=true
        )
        public String message;
        
        public Response() {
            this.message = '';
        }
    }

    /**
     * @description The main invocable method that performs KPI Analysis.
     * @param requests A list of analysis requests, though typically only one is processed.
     * @return A list of analysis responses.
     */
    @InvocableMethod(
        label='ANAGENT KPI Analysis V5'
        description='Analyzes KPIs from AGENT_OU_PIPELINE_V2__c records based on specified metrics, timeframes, and grouping criteria. Returns a comprehensive analysis message with insights and data.'
    )
    public static List<Response> analyzeKPIs(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        if (requests == null || requests.isEmpty()) {
            Response errRes = new Response();
            errRes.message = 'No request provided.';
            responses.add(errRes);
            return responses;
        }
        
        for (Request req : requests) {
            Response res = new Response();
            
            try {
                // Set defaults if not provided
                String metricKey = String.isNotBlank(req.metricKey) ? req.metricKey : 'CALLS';
                String timeframe = String.isNotBlank(req.timeframe) ? req.timeframe : 'CURRENT';
                String groupBy = String.isNotBlank(req.groupBy) ? req.groupBy : 'COUNTRY';
                Boolean perAENormalize = req.perAENormalize != null ? req.perAENormalize : false;
                Integer limitN = req.limitN; // No default limit - only apply if user requests one
                String aggregationType = String.isNotBlank(req.aggregationType) ? req.aggregationType : 'SUM';
                
                // Smart logic: Detect growth factor intent and automatically adjust parameters
                if (groupBy == 'GROWTH_FACTOR' && (metricKey == 'CALLS' || String.isBlank(req.metricKey))) {
                    metricKey = 'GROWTH_FACTOR';
                }
                
                // Additional smart logic: If user is asking for growth factors but using wrong metric, auto-correct
                if (String.isNotBlank(req.groupBy) && req.groupBy.toUpperCase().contains('GROWTH') && 
                    metricKey != 'GROWTH_FACTOR' && metricKey != 'GF') {
                    metricKey = 'GROWTH_FACTOR';
                }
                
                // Smart logic: If user wants to count/rank growth factors, ensure proper setup
                if (String.isNotBlank(req.filterCriteria) && req.filterCriteria.toUpperCase().contains('GROWTH') && 
                    metricKey != 'GROWTH_FACTOR' && metricKey != 'GF') {
                    metricKey = 'GROWTH_FACTOR';
                }
                
                // Smart logic: If user is asking for growth factors but no groupBy specified, auto-set to GROWTH_FACTOR
                if (String.isBlank(req.groupBy) && (metricKey == 'GROWTH_FACTOR' || metricKey == 'GF')) {
                    groupBy = 'GROWTH_FACTOR';
                }
                
                // Smart logic: If user wants to count/rank growth factors, ensure groupBy is set to GROWTH_FACTOR
                if (String.isNotBlank(req.filterCriteria) && req.filterCriteria.toUpperCase().contains('GROWTH') && 
                    String.isBlank(req.groupBy)) {
                    groupBy = 'GROWTH_FACTOR';
                }
                
                // NEW: Enhanced smart logic to detect "top X growth factors" requests
                // This handles cases where the agent might send wrong parameters but user intent is clear
                if (req.limitN != null && req.limitN > 0) {
                    // If user is asking for "top X" and it's likely about growth factors
                    // Check if the current setup doesn't make sense for the request
                    if (groupBy == 'AE' && (metricKey == 'PG' || metricKey == 'ACV' || metricKey == 'CALLS')) {
                        // This looks like a "top X growth factors" request that got misinterpreted
                        // Auto-correct to Growth Factor analysis
                        metricKey = 'GROWTH_FACTOR';
                        groupBy = 'GROWTH_FACTOR';
                    }
                }
                
                // NEW: Detect Growth Factor intent from context even when parameters are wrong
                // This handles cases like "show me top 5 growth factors in US" where agent sends wrong params
                if (req.limitN != null && req.limitN > 0 && 
                    (groupBy == 'AE' || groupBy == 'COUNTRY' || groupBy == 'OU' || groupBy == 'INDUSTRY')) {
                    // If user is asking for "top X" with a dimension that doesn't make sense for the metric,
                    // and we have a limit, this might be a growth factor request
                    if (metricKey == 'PG' || metricKey == 'ACV' || metricKey == 'CALLS') {
                        // This looks like a growth factor request that got misinterpreted
                        metricKey = 'GROWTH_FACTOR';
                        groupBy = 'GROWTH_FACTOR';
                    }
                }
                
                // Smart logic: If user is asking for growth factors (implied by context), auto-set both metric and groupBy
                // This handles cases like "show me top 5 growth factors in US and Germany"
                if (String.isBlank(req.metricKey) && String.isBlank(req.groupBy)) {
                    // For now, keep default behavior but we could add more sophisticated detection
                    // The real fix is to ensure the agent sends the right parameters
                }
                
                // Validate inputs
                if (!isValidMetric(metricKey)) {
                    res.message = 'Invalid metric key: ' + metricKey + '. Valid values are: ACV, PG, CALLS, MEETINGS, COVERAGE, GROWTH_FACTOR, GF, QUOTA, CC_ACV, CQ_CC_ACV, DAYS_ACV, CQ_DAYS_ACV, DAYS_ACV_PART, CQ_DAYS_ACV_PART, DAYS_PG_PART, CQ_DAYS_PG_PART, DAYS_PG, CQ_DAYS_PG, AOV, FULL_TOTAL_ACV_QUOTA, DAYS_TO_PRODUCTIVITY, PQ_CC_ACV, PQ_DAYS_ACV, PQ_DAYS_ACV_PART, PQ_DAYS_PG_PART, PQ_DAYS_PG, CQ_CUSTOMER_MEETING, PQ_CUSTOMER_MEETING, PQ_PG, PQ_ACV, PQ_CALL_CONNECT.';
                    responses.add(res);
                    continue;
                }
                
                if (!isValidTimeframe(timeframe)) {
                    res.message = 'Invalid timeframe: ' + timeframe + '. Valid values are: CURRENT, PREVIOUS.';
                    responses.add(res);
                    continue;
                }
                
                if (!isValidGroupBy(groupBy)) {
                    res.message = 'Invalid group by: ' + groupBy + '. Valid values are: COUNTRY, OU, INDUSTRY, AE, GROWTH_FACTOR, RAMP_STATUS, DEFINITION, MANAGER, EMAIL, LEARNER_PROFILE.';
                    responses.add(res);
                    continue;
                }
                
                if (!isValidAggregationType(aggregationType)) {
                    res.message = 'Invalid aggregation type: ' + aggregationType + '. Valid values are: SUM, AVG, MAX, MIN, COUNT, MEDIAN.';
                    responses.add(res);
                    continue;
                }
                
                // Call service to perform analysis - service builds the complete message
                res.message = ANAGENTKPIAnalysisServiceV5.analyzeKPIs(
                    metricKey, timeframe, groupBy, req.filterCriteria, 
                    req.restrictInValuesCsv, perAENormalize, limitN, aggregationType
                );
                
            } catch (Exception e) {
                res.message = 'An error occurred during KPI analysis: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'KPI Analysis Handler Error: ' + e.getStackTraceString());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
    
    private static Boolean isValidMetric(String metric) {
        Set<String> validMetrics = new Set<String>{
            'ACV', 'PG', 'CALLS', 'MEETINGS', 'COVERAGE', 'GROWTH_FACTOR', 'GF',
            'QUOTA', 'CC_ACV', 'CQ_CC_ACV', 'DAYS_ACV', 'CQ_DAYS_ACV', 'DAYS_ACV_PART', 'CQ_DAYS_ACV_PART',
            'DAYS_PG_PART', 'CQ_DAYS_PG_PART', 'DAYS_PG', 'CQ_DAYS_PG',
            'AOV', 'FULL_TOTAL_ACV_QUOTA', 'DAYS_TO_PRODUCTIVITY',
            'PQ_CC_ACV', 'PQ_DAYS_ACV', 'PQ_DAYS_ACV_PART', 'PQ_DAYS_PG_PART', 'PQ_DAYS_PG',
            'CQ_CUSTOMER_MEETING', 'PQ_CUSTOMER_MEETING', 'PQ_PG', 'PQ_ACV', 'PQ_CALL_CONNECT'
        };
        return validMetrics.contains(metric);
    }
    
    private static Boolean isValidTimeframe(String timeframe) {
        Set<String> validTimeframes = new Set<String>{'CURRENT', 'PREVIOUS'};
        return validTimeframes.contains(timeframe);
    }
    
    private static Boolean isValidGroupBy(String groupBy) {
        Set<String> validGroupBy = new Set<String>{
            'COUNTRY', 'OU', 'INDUSTRY', 'AE', 'GROWTH_FACTOR', 'RAMP_STATUS', 'DEFINITION',
            'MANAGER', 'EMAIL', 'LEARNER_PROFILE'
        };
        return validGroupBy.contains(groupBy);
    }
    
    private static Boolean isValidAggregationType(String aggregationType) {
        Set<String> validAggregationTypes = new Set<String>{
            'SUM', 'AVG', 'MAX', 'MIN', 'COUNT', 'MEDIAN'
        };
        return validAggregationTypes.contains(aggregationType);
    }
} 