/**
 * TEMPLATE HANDLER - This class acts as agent instructions in our handler/service template.
 * Business Requirement: The handler validates requests and delegates business logic to the service layer.
 * @description Handler class for Upsell Analysis operations on Agent_Upsell__c records.
 * This class is the primary entry point for the AI agent to analyze upsell data across AEs.
 * It validates requests and routes them to the ABAgentUpsellAnalysisService for execution.
 *
 * The service fetches Agent_Upsell__c records and provides insights on upsell patterns,
 * product performance, AE metrics, and account analysis with grouping, filtering, and aggregation.
 *
 * @version 1.0
 */
public with sharing class ABAgentUpsellAnalysisHandler {

    /**
     * @description The request object for the Upsell Analysis invocable method.
     */
    public class Request {
        @InvocableVariable(
            label='OU Name'
            description='The Organizational Unit to filter by. Optional - if not provided, will use work location country to find data. Examples: "LATAM", "SMB - AMER SMB", "France", "EMEA South".'
            required=false
        )
        public String ouName;

        @InvocableVariable(
            label='Work Location Country'
            description='Work location country filter. Required if OU is not specified. Examples: "Mexico", "Canada", "France", "United Kingdom".'
            required=false
        )
        public String workLocationCountry;

        @InvocableVariable(
            label='Group By'
            description='The field to group results by. Must be one of: "PRODUCT", "INDUSTRY", "MACRO_SEGMENT", "AE", "COUNTRY", "MANAGER", "ACCOUNT". Defaults to "PRODUCT".'
            required=false
        )
        public String groupBy;

        @InvocableVariable(
            label='Filter Criteria'
            description='SOQL WHERE clause filter using allowed fields: ou_name, work_location_country, primary_industry, macrosgment, upsell_sub_category, upsell_rn, emp_mgr_nm, time_since_onboarding, ramp_status. Example: "upsell_sub_category=\'Tableau Cloud Analytics\' AND upsell_rn > 3"'
            required=false
        )
        public String filterCriteria;

        @InvocableVariable(
            label='Restrict Values CSV'
            description='Comma-separated values to restrict results to specific groups. Example: "Tableau Cloud Analytics,Slack" for product grouping.'
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
            description='The type of analysis to perform: "PRODUCT_PERFORMANCE", "AE_ANALYSIS", "ACCOUNT_ANALYSIS", "MANAGER_ANALYSIS", "INDUSTRY_ANALYSIS". Defaults to "PRODUCT_PERFORMANCE".'
            required=false
        )
        public String analysisType;
    }

    /**
     * @description The response object for the Upsell Analysis invocable method.
     * Follows FR agent best practices: only message field exposed to agent.
     */
    public class Response {
        @InvocableVariable(
            label='Analysis Message'
            description='Complete Upsell analysis results formatted as a human-readable message with Markdown structure and compact JSON data.'
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
                    res.message = ABAgentUpsellAnalysisService.getFieldSuggestions(req.filterCriteria);
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
                    res.message = ABAgentUpsellAnalysisService.validateFilterCriteria(req.filterCriteria);
                }
            } catch (Exception e) {
                res.message = 'An error occurred while validating filter criteria: ' + e.getMessage();
            }

            responses.add(res);
        }

        return responses;
    }

    /**
     * @description The main invocable method that performs Upsell Analysis.
     * @param requests A list of analysis requests, though typically only one is processed.
     * @return A list of analysis responses.
     */
    @InvocableMethod(
        label='ABAGENT Upsell Analysis'
        description='Analyzes upsell data from Agent_Upsell__c records based on specified OU, grouping criteria, and filters. Returns comprehensive analysis with insights on products, AEs, accounts, and performance.'
    )
    public static List<Response> analyzeUpsell(List<Request> requests) {
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
                // Intelligent input parsing - if user provides "US" as OU, treat it as country
                if (String.isNotBlank(req.ouName) && req.ouName.equalsIgnoreCase('US')) {
                    // If both OU and country are "US", remove the OU filter (keep country only)
                    if (String.isNotBlank(req.workLocationCountry) && req.workLocationCountry.equalsIgnoreCase('US')) {
                        req.ouName = null; // Remove OU filter, keep country
                    } else if (String.isBlank(req.workLocationCountry)) {
                        // If only OU is "US", convert it to country
                        req.workLocationCountry = 'US';
                        req.ouName = null;
                    }
                }
                
                // Validate required fields - either OU or Country must be provided
                if (String.isBlank(req.ouName) && String.isBlank(req.workLocationCountry)) {
                    res.message = 'Either OU Name or Work Location Country is required for Upsell Analysis queries. Please provide at least one of these filters.';
                    responses.add(res);
                    continue;
                }

                // Set defaults if not provided
                String groupBy = String.isNotBlank(req.groupBy) ? req.groupBy : 'PRODUCT';
                Boolean perAENormalize = req.perAENormalize != null ? req.perAENormalize : false;
                Integer limitN = req.limitN; // No default limit - only apply if user requests one
                String aggregationType = String.isNotBlank(req.aggregationType) ? req.aggregationType : 'COUNT';
                String analysisType = String.isNotBlank(req.analysisType) ? req.analysisType : 'PRODUCT_PERFORMANCE';

                // Validate inputs
                if (!isValidGroupBy(groupBy)) {
                    res.message = 'Invalid group by: ' + groupBy + '. Valid values are: PRODUCT, INDUSTRY, MACRO_SEGMENT, AE, COUNTRY, MANAGER, ACCOUNT.';
                    responses.add(res);
                    continue;
                }

                if (!isValidAggregationType(aggregationType)) {
                    res.message = 'Invalid aggregation type: ' + aggregationType + '. Valid values are: SUM, AVG, MAX, MIN, COUNT, MEDIAN.';
                    responses.add(res);
                    continue;
                }

                if (!isValidAnalysisType(analysisType)) {
                    res.message = 'Invalid analysis type: ' + analysisType + '. Valid values are: PRODUCT_PERFORMANCE, AE_ANALYSIS, ACCOUNT_ANALYSIS, MANAGER_ANALYSIS, INDUSTRY_ANALYSIS.';
                    responses.add(res);
                    continue;
                }

                // Call optimized service to perform analysis - service builds the complete message
                res.message = ABAgentUpsellAnalysisService.analyzeUpsell(
                    req.ouName, req.workLocationCountry, groupBy, req.filterCriteria,
                    req.restrictInValuesCsv, perAENormalize, limitN, aggregationType, analysisType
                );

            } catch (Exception e) {
                res.message = 'An error occurred during Upsell analysis: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'Upsell Analysis Handler Error: ' + e.getStackTraceString());
            }

            responses.add(res);
        }

        return responses;
    }

    private static Boolean isValidGroupBy(String groupBy) {
        Set<String> validGroupBy = new Set<String>{
            'PRODUCT', 'INDUSTRY', 'MACRO_SEGMENT', 'AE', 'COUNTRY', 'MANAGER', 'ACCOUNT'
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
            'PRODUCT_PERFORMANCE', 'AE_ANALYSIS', 'ACCOUNT_ANALYSIS', 'MANAGER_ANALYSIS', 'INDUSTRY_ANALYSIS'
        };
        return validAnalysisTypes.contains(analysisType);
    }
}