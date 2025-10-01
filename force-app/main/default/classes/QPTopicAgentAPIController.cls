/**
 * QP TOPIC AGENT API CONTROLLER
 * 
 * REST API wrapper for the QP Topic (1 Topic Only) agent
 * Provides external API access to core agent functionality
 * 
 * @version 1.0
 * @author Field Readiness Team
 */
@RestResource(urlMapping='/api/qp-agent/*')
global with sharing class QPTopicAgentAPIController {
    
    /**
     * GET /api/qp-agent/*
     * Route GET requests to appropriate handler based on URL path
     */
    @HttpGet
    global static void handleGet() {
        RestRequest req = RestContext.request;
        String requestURI = req.requestURI;
        
        try {
            if (requestURI.contains('/health')) {
                handleHealthCheck();
            } else if (requestURI.contains('/content-search')) {
                handleContentSearch();
            } else if (requestURI.contains('/knowledge-search')) {
                handleKnowledgeSearch();
            } else if (requestURI.contains('/sme-search')) {
                handleSMESearch();
            } else if (requestURI.contains('/kpi-analysis')) {
                handleKPIAnalysis();
            } else if (requestURI.contains('/open-pipe-analysis')) {
                handleOpenPipeAnalysis();
            } else {
                sendErrorResponse('Endpoint not found. Available endpoints: /health, /content-search, /knowledge-search, /sme-search, /kpi-analysis, /open-pipe-analysis', 404);
            }
        } catch (Exception e) {
            sendErrorResponse('API Error: ' + e.getMessage(), 500);
        }
    }
    
    /**
     * POST /api/qp-agent/*
     * Route POST requests to appropriate handler based on URL path
     */
    @HttpPost
    global static void handlePost() {
        RestRequest req = RestContext.request;
        String requestURI = req.requestURI;
        
        try {
            if (requestURI.contains('/sales-coach-feedback')) {
                handleSalesCoachFeedback();
            } else {
                sendErrorResponse('Endpoint not found. Available endpoints: /sales-coach-feedback', 404);
            }
        } catch (Exception e) {
            sendErrorResponse('API Error: ' + e.getMessage(), 500);
        }
    }
    
    /**
     * Handle health check endpoint
     */
    private static void handleHealthCheck() {
        Map<String, Object> healthData = new Map<String, Object>();
        healthData.put('status', 'healthy');
        healthData.put('timestamp', System.now());
        healthData.put('version', '1.0');
        healthData.put('agent', 'QP Topic (1 Topic Only)');
        healthData.put('company', 'Field Readiness');
        healthData.put('availableEndpoints', new List<String>{
            'GET /health', 'GET /content-search', 'GET /knowledge-search', 'GET /sme-search', 'GET /kpi-analysis', 'GET /open-pipe-analysis', 'POST /sales-coach-feedback'
        });
        
        sendSuccessResponse(healthData, 'QP Topic Agent API is healthy');
    }
    
    /**
     * Handle content search endpoint
     */
    private static void handleContentSearch() {
        RestRequest req = RestContext.request;
        
        String searchTerm = req.params.get('searchTerm');
        String contentType = req.params.get('contentType');
        
        if (String.isBlank(searchTerm)) {
            sendErrorResponse('searchTerm parameter is required', 400);
            return;
        }
        
        try {
            ANAgentContentSearchHandlerV2.ContentSearchRequest agentRequest = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
            agentRequest.searchTerm = searchTerm;
            agentRequest.contentType = contentType;
            
            List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
                ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{agentRequest});
            
            if (responses.isEmpty() || !responses[0].success) {
                sendErrorResponse('Content search failed: ' + (responses.isEmpty() ? 'No response' : responses[0].message), 500);
                return;
            }
            
            sendSuccessResponse(responses[0].results, 'Content search completed successfully');
            
        } catch (Exception e) {
            sendErrorResponse('Content Search Error: ' + e.getMessage(), 500);
        }
    }
    
    /**
     * Handle knowledge search endpoint
     */
    private static void handleKnowledgeSearch() {
        RestRequest req = RestContext.request;
        
        String searchQuery = req.params.get('searchQuery');
        String searchType = req.params.get('searchType');
        String maxResultsStr = req.params.get('maxResults');
        
        if (String.isBlank(searchQuery)) {
            sendErrorResponse('searchQuery parameter is required', 400);
            return;
        }
        
        try {
            ANAgentKnowledgeHandler.KnowledgeRequest agentRequest = new ANAgentKnowledgeHandler.KnowledgeRequest();
            agentRequest.searchQuery = searchQuery;
            agentRequest.searchType = searchType;
            agentRequest.maxResults = String.isNotBlank(maxResultsStr) ? Integer.valueOf(maxResultsStr) : 3;
            
            List<ANAgentKnowledgeHandler.KnowledgeResponse> responses = 
                ANAgentKnowledgeHandler.searchKnowledge(new List<ANAgentKnowledgeHandler.KnowledgeRequest>{agentRequest});
            
            if (responses.isEmpty() || !responses[0].success) {
                sendErrorResponse('Knowledge search failed: ' + (responses.isEmpty() ? 'No response' : responses[0].errorMessage), 500);
                return;
            }
            
            Map<String, Object> result = new Map<String, Object>();
            result.put('knowledgeContent', responses[0].knowledgeContent);
            result.put('matchedArticles', responses[0].matchedArticles);
            result.put('totalResults', responses[0].totalResults);
            
            sendSuccessResponse(result, 'Knowledge search completed successfully');
            
        } catch (Exception e) {
            sendErrorResponse('Knowledge Search Error: ' + e.getMessage(), 500);
        }
    }
    
    /**
     * Handle SME search endpoint
     */
    private static void handleSMESearch() {
        RestRequest req = RestContext.request;
        
        String searchTerm = req.params.get('searchTerm');
        String searchType = req.params.get('searchType');
        String maxResultsStr = req.params.get('maxResults');
        String academyMembersOnlyStr = req.params.get('academyMembersOnly');
        
        if (String.isBlank(searchTerm)) {
            sendErrorResponse('searchTerm parameter is required', 400);
            return;
        }
        
        try {
            ANAgentSMESearchHandler.SMESearchRequest agentRequest = new ANAgentSMESearchHandler.SMESearchRequest();
            agentRequest.searchTerm = searchTerm;
            agentRequest.searchType = searchType;
            agentRequest.maxResults = String.isNotBlank(maxResultsStr) ? Integer.valueOf(maxResultsStr) : 50;
            agentRequest.academyMembersOnly = String.isNotBlank(academyMembersOnlyStr) ? Boolean.valueOf(academyMembersOnlyStr) : false;
            
            List<ANAgentSMESearchHandler.SMESearchResponse> responses = 
                ANAgentSMESearchHandler.searchSMEs(new List<ANAgentSMESearchHandler.SMESearchRequest>{agentRequest});
            
            if (responses.isEmpty() || !responses[0].success) {
                sendErrorResponse('SME search failed: ' + (responses.isEmpty() ? 'No response' : responses[0].message), 500);
                return;
            }
            
            Map<String, Object> result = new Map<String, Object>();
            result.put('smeRecords', responses[0].smeRecords);
            result.put('totalCount', responses[0].totalCount);
            result.put('productSummary', responses[0].productSummary);
            result.put('topPerformers', responses[0].topPerformers);
            result.put('academyMembersCount', responses[0].academyMembersCount);
            
            sendSuccessResponse(result, 'SME search completed successfully');
            
        } catch (Exception e) {
            sendErrorResponse('SME Search Error: ' + e.getMessage(), 500);
        }
    }
    
    /**
     * Handle KPI Analysis endpoint
     */
    private static void handleKPIAnalysis() {
        RestRequest req = RestContext.request;
        
        String metricKey = req.params.get('metricKey');
        String timeframe = req.params.get('timeframe');
        String groupBy = req.params.get('groupBy');
        String filterCriteria = req.params.get('filterCriteria');
        String restrictInValuesCsv = req.params.get('restrictInValuesCsv');
        String perAENormalizeStr = req.params.get('perAENormalize');
        String limitNStr = req.params.get('limitN');
        String aggregationType = req.params.get('aggregationType');
        
        try {
            ANAGENTKPIAnalysisHandlerV5.Request agentRequest = new ANAGENTKPIAnalysisHandlerV5.Request();
            agentRequest.metricKey = String.isNotBlank(metricKey) ? metricKey : 'CALLS';
            agentRequest.timeframe = String.isNotBlank(timeframe) ? timeframe : 'CURRENT';
            agentRequest.groupBy = String.isNotBlank(groupBy) ? groupBy : 'COUNTRY';
            agentRequest.filterCriteria = filterCriteria;
            agentRequest.restrictInValuesCsv = restrictInValuesCsv;
            agentRequest.perAENormalize = String.isNotBlank(perAENormalizeStr) ? Boolean.valueOf(perAENormalizeStr) : false;
            agentRequest.limitN = String.isNotBlank(limitNStr) ? Integer.valueOf(limitNStr) : null;
            agentRequest.aggregationType = String.isNotBlank(aggregationType) ? aggregationType : 'SUM';
            
            List<ANAGENTKPIAnalysisHandlerV5.Response> responses = 
                ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV5.Request>{agentRequest});
            
            if (responses.isEmpty()) {
                sendErrorResponse('KPI Analysis failed: No response received', 500);
                return;
            }
            
            Map<String, Object> result = new Map<String, Object>();
            result.put('analysisMessage', responses[0].message);
            
            sendSuccessResponse(result, 'KPI Analysis completed successfully');
            
        } catch (Exception e) {
            sendErrorResponse('KPI Analysis Error: ' + e.getMessage(), 500);
        }
    }
    
    /**
     * Handle Open Pipe Analysis endpoint
     */
    private static void handleOpenPipeAnalysis() {
        RestRequest req = RestContext.request;
        
        String ouName = req.params.get('ouName');
        String workLocationCountry = req.params.get('workLocationCountry');
        String groupBy = req.params.get('groupBy');
        String filterCriteria = req.params.get('filterCriteria');
        String restrictInValuesCsv = req.params.get('restrictInValuesCsv');
        String perAENormalizeStr = req.params.get('perAENormalize');
        String limitNStr = req.params.get('limitN');
        String aggregationType = req.params.get('aggregationType');
        String analysisType = req.params.get('analysisType');
        
        if (String.isBlank(ouName) && String.isBlank(workLocationCountry)) {
            sendErrorResponse('Either ouName or workLocationCountry parameter is required', 400);
            return;
        }
        
        try {
            ANAgentOpenPipeAnalysisV3Handler.Request agentRequest = new ANAgentOpenPipeAnalysisV3Handler.Request();
            agentRequest.ouName = ouName;
            agentRequest.workLocationCountry = workLocationCountry;
            agentRequest.groupBy = String.isNotBlank(groupBy) ? groupBy : 'STAGE';
            agentRequest.filterCriteria = filterCriteria;
            agentRequest.restrictInValuesCsv = restrictInValuesCsv;
            agentRequest.perAENormalize = String.isNotBlank(perAENormalizeStr) ? Boolean.valueOf(perAENormalizeStr) : false;
            agentRequest.limitN = String.isNotBlank(limitNStr) ? Integer.valueOf(limitNStr) : null;
            agentRequest.aggregationType = String.isNotBlank(aggregationType) ? aggregationType : 'COUNT';
            agentRequest.analysisType = String.isNotBlank(analysisType) ? analysisType : 'STAGE_COUNT';
            
            List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = 
                ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{agentRequest});
            
            if (responses.isEmpty()) {
                sendErrorResponse('Open Pipe Analysis failed: No response received', 500);
                return;
            }
            
            Map<String, Object> result = new Map<String, Object>();
            result.put('analysisMessage', responses[0].message);
            
            sendSuccessResponse(result, 'Open Pipe Analysis completed successfully');
            
        } catch (Exception e) {
            sendErrorResponse('Open Pipe Analysis Error: ' + e.getMessage(), 500);
        }
    }
    
    /**
     * Handle sales coach feedback endpoint
     */
    private static void handleSalesCoachFeedback() {
        RestRequest req = RestContext.request;
        
        String requestBody = req.requestBody.toString();
        SalesCoachRequest apiRequest = (SalesCoachRequest) JSON.deserialize(requestBody, SalesCoachRequest.class);
        
        if (String.isBlank(apiRequest.learnerProfileId)) {
            sendErrorResponse('learnerProfileId is required', 400);
            return;
        }
        
        try {
            SalesCoachFeedbackService.FeedbackRequest agentRequest = new SalesCoachFeedbackService.FeedbackRequest();
            agentRequest.learnerProfileId = apiRequest.learnerProfileId;
            agentRequest.opportunityId = apiRequest.opportunityId;
            agentRequest.includeCrossSell = apiRequest.includeCrossSell;
            agentRequest.includeUpsell = apiRequest.includeUpsell;
            
            List<SalesCoachFeedbackService.FeedbackResponse> responses = 
                SalesCoachFeedbackService.getNextBestAction(new List<SalesCoachFeedbackService.FeedbackRequest>{agentRequest});
            
            if (responses.isEmpty() || !responses[0].success) {
                sendErrorResponse('Sales coach feedback failed: ' + (responses.isEmpty() ? 'No response' : responses[0].errorMessage), 500);
                return;
            }
            
            Object nbaData = JSON.deserializeUntyped(responses[0].nextBestAction);
            sendSuccessResponse(nbaData, 'Next Best Action retrieved successfully');
            
        } catch (Exception e) {
            sendErrorResponse('Sales Coach Feedback Error: ' + e.getMessage(), 500);
        }
    }
    
    // Helper methods
    private static void sendSuccessResponse(Object data, String message) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.addHeader('Content-Type', 'application/json');
        
        ResponseWrapper response = new ResponseWrapper();
        response.success = true;
        response.message = message;
        response.data = data;
        response.timestamp = System.now();
        response.agent = 'QP Topic (1 Topic Only)';
        
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    
    private static void sendErrorResponse(String message, Integer statusCode) {
        RestResponse res = RestContext.response;
        res.statusCode = statusCode;
        res.addHeader('Content-Type', 'application/json');
        
        ResponseWrapper response = new ResponseWrapper();
        response.success = false;
        response.message = message;
        response.timestamp = System.now();
        response.agent = 'QP Topic (1 Topic Only)';
        
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    
    // Request DTOs
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
        public String agent;
    }
}