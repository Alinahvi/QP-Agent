/**
 * AGENT API CONTROLLER
 * 
 * REST API wrapper for existing agent functionality
 * Provides external API access to agent services
 * 
 * @version 1.0
 */
@RestResource(urlMapping='/api/agents/*')
global with sharing class AgentAPIController {
    
    /**
     * GET /api/agents/content-search
     * Search content using ANAgentContentSearchHandlerV2
     */
    @HttpGet
    global static ResponseWrapper searchContent() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            // Extract parameters from URL
            String searchTerm = req.params.get('searchTerm');
            String contentType = req.params.get('contentType');
            String limitStr = req.params.get('limit');
            
            if (String.isBlank(searchTerm)) {
                return createErrorResponse('searchTerm parameter is required', 400);
            }
            
            // Create request for agent
            ANAgentContentSearchHandlerV2.ContentSearchRequest agentRequest = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
            agentRequest.searchTerm = searchTerm;
            agentRequest.contentType = contentType;
            agentRequest.limitN = String.isNotBlank(limitStr) ? Integer.valueOf(limitStr) : 10;
            
            // Call agent
            List<ANAgentContentSearchHandlerV2.ContentSearchResponse> agentResponses = 
                ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{agentRequest});
            
            if (agentResponses.isEmpty() || !agentResponses[0].success) {
                return createErrorResponse('Content search failed: ' + agentResponses[0].message, 500);
            }
            
            // Return success response
            return createSuccessResponse(agentResponses[0].results, 'Content search completed successfully');
            
        } catch (Exception e) {
            return createErrorResponse('API Error: ' + e.getMessage(), 500);
        }
    }
    
    /**
     * POST /api/agents/kpi-analysis
     * Analyze KPIs using ANAgentKPIAnalysisV2Handler
     */
    @HttpPost
    global static ResponseWrapper analyzeKPIs() {
        RestRequest req = RestContext.request;
        
        try {
            // Parse JSON request body
            String requestBody = req.requestBody.toString();
            KPIAnalysisRequest apiRequest = (KPIAnalysisRequest) JSON.deserialize(requestBody, KPIAnalysisRequest.class);
            
            // Validate required fields
            if (String.isBlank(apiRequest.analysisType)) {
                return createErrorResponse('analysisType is required', 400);
            }
            
            // Create agent request
            ANAgentKPIAnalysisV2Request agentRequest = new ANAgentKPIAnalysisV2Request();
            agentRequest.analysisType = apiRequest.analysisType;
            agentRequest.ouName = apiRequest.ouName;
            agentRequest.workLocationCountry = apiRequest.workLocationCountry;
            agentRequest.groupBy = apiRequest.groupBy;
            agentRequest.filterCriteria = apiRequest.filterCriteria;
            agentRequest.limitN = apiRequest.limitN != null ? apiRequest.limitN : 10;
            agentRequest.aggregationType = apiRequest.aggregationType;
            
            // Call agent
            List<ANAgentKPIAnalysisV2Response> agentResponses = 
                ANAgentKPIAnalysisV2Handler.run(new List<ANAgentKPIAnalysisV2Request>{agentRequest});
            
            if (agentResponses.isEmpty() || !agentResponses[0].success) {
                return createErrorResponse('KPI analysis failed: ' + agentResponses[0].message, 500);
            }
            
            return createSuccessResponse(agentResponses[0].results, 'KPI analysis completed successfully');
            
        } catch (Exception e) {
            return createErrorResponse('API Error: ' + e.getMessage(), 500);
        }
    }
    
    /**
     * POST /api/agents/sales-coach-feedback
     * Get Next Best Action using SalesCoachFeedbackService
     */
    @HttpPost
    global static ResponseWrapper getSalesCoachFeedback() {
        RestRequest req = RestContext.request;
        
        try {
            String requestBody = req.requestBody.toString();
            SalesCoachRequest apiRequest = (SalesCoachRequest) JSON.deserialize(requestBody, SalesCoachRequest.class);
            
            if (String.isBlank(apiRequest.learnerProfileId)) {
                return createErrorResponse('learnerProfileId is required', 400);
            }
            
            // Create agent request
            SalesCoachFeedbackService.FeedbackRequest agentRequest = new SalesCoachFeedbackService.FeedbackRequest();
            agentRequest.learnerProfileId = apiRequest.learnerProfileId;
            agentRequest.opportunityId = apiRequest.opportunityId;
            agentRequest.includeCrossSell = apiRequest.includeCrossSell;
            agentRequest.includeUpsell = apiRequest.includeUpsell;
            
            // Call agent
            List<SalesCoachFeedbackService.FeedbackResponse> agentResponses = 
                SalesCoachFeedbackService.getNextBestAction(new List<SalesCoachFeedbackService.FeedbackRequest>{agentRequest});
            
            if (agentResponses.isEmpty() || !agentResponses[0].success) {
                return createErrorResponse('Sales coach feedback failed: ' + agentResponses[0].errorMessage, 500);
            }
            
            // Parse the NBA JSON string
            Object nbaData = JSON.deserializeUntyped(agentResponses[0].nextBestAction);
            
            return createSuccessResponse(nbaData, 'Next Best Action retrieved successfully');
            
        } catch (Exception e) {
            return createErrorResponse('API Error: ' + e.getMessage(), 500);
        }
    }
    
    // Helper methods
    private static ResponseWrapper createSuccessResponse(Object data, String message) {
        ResponseWrapper response = new ResponseWrapper();
        response.success = true;
        response.message = message;
        response.data = data;
        response.timestamp = System.now();
        return response;
    }
    
    private static ResponseWrapper createErrorResponse(String message, Integer statusCode) {
        RestContext.response.statusCode = statusCode;
        ResponseWrapper response = new ResponseWrapper();
        response.success = false;
        response.message = message;
        response.timestamp = System.now();
        return response;
    }
    
    // Request/Response DTOs
    global class KPIAnalysisRequest {
        public String analysisType;
        public String ouName;
        public String workLocationCountry;
        public String groupBy;
        public String filterCriteria;
        public Integer limitN;
        public String aggregationType;
    }
    
    global class SalesCoachRequest {
        public String learnerProfileId;
        public String opportunityId;
        public Boolean includeCrossSell = true;
        public Boolean includeUpsell = true;
    }
    
    global class ResponseWrapper {
        public Boolean success;
        public String message;
        public Object data;
        public DateTime timestamp;
    }
}

