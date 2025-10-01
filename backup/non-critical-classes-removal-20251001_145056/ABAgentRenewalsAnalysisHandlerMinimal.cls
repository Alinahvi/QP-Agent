/**
 * MINIMAL HANDLER - Test if the handler is causing heap issues
 */
public with sharing class ABAgentRenewalsAnalysisHandlerMinimal {

    /**
     * @description The request object for the Renewals Analysis invocable method.
     */
    public class Request {
        @InvocableVariable(
            label='OU Name'
            description='The Organizational Unit to filter by. Optional - if not provided, will use work location country to find data.'
            required=false
        )
        public String ouName;

        @InvocableVariable(
            label='Work Location Country'
            description='Work location country filter. Required if OU is not specified.'
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
            description='SOQL WHERE clause filter using allowed fields.'
            required=false
        )
        public String filterCriteria;

        @InvocableVariable(
            label='Restrict Values CSV'
            description='Comma-separated values to restrict results to specific groups.'
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
            description='Maximum number of records to return. If not specified, returns up to 10 records.'
            required=false
        )
        public Integer limitN;

        @InvocableVariable(
            label='Aggregation Type'
            description='Type of aggregation to perform: SUM, AVG, MAX, MIN, COUNT, MEDIAN. Defaults to SUM.'
            required=false
        )
        public String aggregationType;

        @InvocableVariable(
            label='Analysis Type'
            description='Type of analysis to perform: PRODUCT_PERFORMANCE, AE_ANALYSIS, ACCOUNT_ANALYSIS, MANAGER_ANALYSIS, INDUSTRY_ANALYSIS. Defaults to PRODUCT_PERFORMANCE.'
            required=false
        )
        public String analysisType;
    }

    /**
     * @description The response object for the Renewals Analysis invocable method.
     */
    public class Response {
        @InvocableVariable(
            label='Message'
            description='The analysis results message'
        )
        public String message;
    }

    /**
     * @description The main invocable method that performs Renewals Analysis.
     * @param requests A list of analysis requests, though typically only one is processed.
     * @return A list of analysis responses.
     */
    @InvocableMethod(
        label='ABAGENT Renewals Analysis (Minimal)'
        description='Analyzes renewal data from Agent_Renewals__c records using aggregate queries to prevent memory issues.'
    )
    public static List<Response> analyzeRenewals(List<Request> requests) {
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
                // Validate required fields - either OU or Country must be provided
                if (String.isBlank(req.ouName) && String.isBlank(req.workLocationCountry)) {
                    res.message = 'Either OU Name or Work Location Country is required for Renewals Analysis queries. Please provide at least one of these filters.';
                    responses.add(res);
                    continue;
                }

                // Set defaults if not provided
                String groupBy = String.isNotBlank(req.groupBy) ? req.groupBy : 'AE';
                Boolean perAENormalize = req.perAENormalize != null ? req.perAENormalize : false;
                Integer limitN = req.limitN != null ? req.limitN : 10;
                String aggregationType = String.isNotBlank(req.aggregationType) ? req.aggregationType : 'COUNT';
                String analysisType = String.isNotBlank(req.analysisType) ? req.analysisType : 'AE_ANALYSIS';

                // Call service to perform analysis
                res.message = ABAgentRenewalsAnalysisServiceMinimal.analyzeRenewals(
                    req.ouName, req.workLocationCountry, groupBy, req.filterCriteria,
                    req.restrictInValuesCsv, perAENormalize, limitN, aggregationType, analysisType
                );

            } catch (Exception e) {
                res.message = 'An error occurred during Renewals analysis: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'Renewals Analysis Handler Error: ' + e.getStackTraceString());
            }

            responses.add(res);
        }

        return responses;
    }
}
