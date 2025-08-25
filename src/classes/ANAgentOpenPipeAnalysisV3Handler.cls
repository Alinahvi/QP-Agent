/**
 * TEMPLATE HANDLER - This class acts as agent instructions in our handler/service template.
 * Business Requirement: The handler validates requests and delegates business logic to the service layer.
 * @description Handler class for Open Pipe Analysis operations on Agent_Open_Pipe__c records.
 * This class is the primary entry point for the AI agent to analyze open pipeline data across AEs.
 * It validates requests and routes them to the ANAgentOpenPipeAnalysisV3Service for execution.
 *
 * The service fetches Agent_Open_Pipe__c records and provides insights on active pipeline patterns,
 * opportunity stages, product performance, and AE metrics with grouping, filtering, and aggregation.
 *
 * @version 3.0
 */
public with sharing class ANAgentOpenPipeAnalysisV3Handler {
    
    /**
     * @description The request object for the Open Pipe Analysis invocable method.
     */
    public class Request {
        @InvocableVariable(
            label='OU Name'
            description='The Organizational Unit to filter by. This is a required baseline filter for all queries. Examples: "AMER ICE", "SMB - AMER SMB", "NextGen Platform".'
            required=true
        )
        public String ouName;
        
        @InvocableVariable(
            label='Work Location Country'
            description='Optional work location country filter. Use as fallback when OU is not specified. Examples: "US", "Canada", "Switzerland".'
            required=false
        )
        public String workLocationCountry;
        
        @InvocableVariable(
            label='Group By'
            description='The field to group results by. Must be one of: "STAGE", "PRODUCT", "INDUSTRY", "MACRO_SEGMENT", "AE", "COUNTRY". Defaults to "STAGE".'
            required=false
        )
        public String groupBy;
        
        @InvocableVariable(
            label='Filter Criteria'
            description='SOQL WHERE clause filter using allowed fields: ou_name, work_location_country, primary_industry, macrosgment, open_pipe_opty_stg_nm, open_pipe_prod_nm, open_pipe_opty_days_in_stage, open_pipe_ae_score, open_pipe_opp_manager_nt, emp_mgr_nm, time_since_onboarding, ramp_status. Example: "open_pipe_opty_stg_nm=\'03 - Validating Benefits & Value\' AND open_pipe_opty_days_in_stage > 30"'
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
            description='Maximum number of grouped results to return. Only send when user explicitly requests a limit (e.g., "top 10", "show me 5"). Leave empty to show all results.'
            required=false
        )
        public Integer limitN;
        
        @InvocableVariable(
            label='Aggregation Type'
            description='The type of aggregation to perform: "SUM", "AVG", "MAX", "MIN", "COUNT", "MEDIAN". Defaults to "COUNT".'
            required=false
        )
        public String aggregationType;
        
        @InvocableVariable(
            label='Analysis Type'
            description='The type of analysis to perform: "STAGE_COUNT", "PRODUCT_PERFORMANCE", "AE_SCORE_ANALYSIS", "DAYS_IN_STAGE", "OPPORTUNITY_DETAILS". Defaults to "STAGE_COUNT".'
            required=false
        )
        public String analysisType;
    }
    
    /**
     * @description The response object for the Open Pipe Analysis invocable method.
     * Follows FR agent best practices: only message field exposed to agent.
     */
    public class Response {
        @InvocableVariable(
            label='Analysis Message'
            description='Complete Open Pipe analysis results formatted as a human-readable message with Markdown structure and compact JSON data.'
            required=true
        )
        public String message;
        
        public Response() {
            this.message = '';
        }
    }

    /**
     * @description Provides field suggestions and validation for better agent accuracy
     * @param requests A list containing a single request with query field
     * @return A list of responses with field suggestions
     */
    public static List<Response> getFieldSuggestions(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        if (requests == null || requests.isEmpty()) {
            Response errRes = new Response();
            errRes.message = 'No request provided for field suggestions.';
            responses.add(errRes);
            return responses;
        }
        
        for (Request req : requests) {
            Response res = new Response();
            
            try {
                if (String.isBlank(req.filterCriteria)) {
                    res.message = 'Please provide a query in filterCriteria to get field suggestions.';
                } else {
                    res.message = ANAgentOpenPipeAnalysisV3Service.getFieldSuggestions(req.filterCriteria);
                }
            } catch (Exception e) {
                res.message = 'An error occurred while getting field suggestions: ' + e.getMessage();
            }
            
            responses.add(res);
        }
        
        return responses;
    }
    
    /**
     * @description Validates filter criteria and provides suggestions for common errors
     * @param requests A list containing a single request with filterCriteria field
     * @return A list of responses with validation results
     */
    public static List<Response> validateFilterCriteria(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        if (requests == null || requests.isEmpty()) {
            Response errRes = new Response();
            errRes.message = 'No request provided for filter validation.';
            responses.add(errRes);
            return responses;
        }
        
        for (Request req : requests) {
            Response res = new Response();
            
            try {
                if (String.isBlank(req.filterCriteria)) {
                    res.message = 'Please provide filter criteria to validate.';
                } else {
                    res.message = ANAgentOpenPipeAnalysisV3Service.validateFilterCriteria(req.filterCriteria);
                }
            } catch (Exception e) {
                res.message = 'An error occurred while validating filter criteria: ' + e.getMessage();
            }
            
            responses.add(res);
        }
        
        return responses;
    }
    
    /**
     * @description The main invocable method that performs Open Pipe Analysis.
     * @param requests A list of analysis requests, though typically only one is processed.
     * @return A list of analysis responses.
     */
    @InvocableMethod(
        label='ANAGENT Open Pipe Analysis V3'
        description='Analyzes open pipeline data from Agent_Open_Pipe__c records based on specified OU, grouping criteria, and filters. Returns comprehensive analysis with insights on stages, products, and AE performance.'
    )
    public static List<Response> analyzeOpenPipe(List<Request> requests) {
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
                // Validate required fields
                if (String.isBlank(req.ouName)) {
                    res.message = 'OU Name is required for all Open Pipe Analysis queries.';
                    responses.add(res);
                    continue;
                }
                
                // Set defaults if not provided
                String groupBy = String.isNotBlank(req.groupBy) ? req.groupBy : 'STAGE';
                Boolean perAENormalize = req.perAENormalize != null ? req.perAENormalize : false;
                Integer limitN = req.limitN; // No default limit - only apply if user requests one
                String aggregationType = String.isNotBlank(req.aggregationType) ? req.aggregationType : 'COUNT';
                String analysisType = String.isNotBlank(req.analysisType) ? req.analysisType : 'STAGE_COUNT';
                
                // Validate inputs
                if (!isValidGroupBy(groupBy)) {
                    res.message = 'Invalid group by: ' + groupBy + '. Valid values are: STAGE, PRODUCT, INDUSTRY, MACRO_SEGMENT, AE, COUNTRY.';
                    responses.add(res);
                    continue;
                }
                
                if (!isValidAggregationType(aggregationType)) {
                    res.message = 'Invalid aggregation type: ' + aggregationType + '. Valid values are: SUM, AVG, MAX, MIN, COUNT, MEDIAN.';
                    responses.add(res);
                    continue;
                }
                
                if (!isValidAnalysisType(analysisType)) {
                    res.message = 'Invalid analysis type: ' + analysisType + '. Valid values are: STAGE_COUNT, PRODUCT_PERFORMANCE, AE_SCORE_ANALYSIS, DAYS_IN_STAGE, OPPORTUNITY_DETAILS.';
                    responses.add(res);
                    continue;
                }
                
                // Call service to perform analysis - service builds the complete message
                res.message = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
                    req.ouName, req.workLocationCountry, groupBy, req.filterCriteria, 
                    req.restrictInValuesCsv, perAENormalize, limitN, aggregationType, analysisType
                );
                
            } catch (Exception e) {
                res.message = 'An error occurred during Open Pipe analysis: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'Open Pipe Analysis Handler Error: ' + e.getStackTraceString());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
    
    private static Boolean isValidGroupBy(String groupBy) {
        Set<String> validGroupBy = new Set<String>{
            'STAGE', 'PRODUCT', 'INDUSTRY', 'MACRO_SEGMENT', 'AE', 'COUNTRY'
        };
        return validGroupBy.contains(groupBy);
    }
    
    private static Boolean isValidAggregationType(String aggregationType) {
        Set<String> validAggregationTypes = new Set<String>{
            'SUM', 'AVG', 'MAX', 'MIN', 'COUNT', 'MEDIAN'
        };
        return validAggregationTypes.contains(aggregationType);
    }
    
    private static Boolean isValidAnalysisType(String analysisType) {
        Set<String> validAnalysisTypes = new Set<String>{
            'STAGE_COUNT', 'PRODUCT_PERFORMANCE', 'AE_SCORE_ANALYSIS', 'DAYS_IN_STAGE', 'OPPORTUNITY_DETAILS'
        };
        return validAnalysisTypes.contains(analysisType);
    }
} 