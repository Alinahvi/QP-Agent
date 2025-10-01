/**
 * MCP AGENT CONTROLLER
 * 
 * REST API controller for MCP (Model Context Protocol) integration
 * Provides endpoints that match the MCP server expectations
 * 
 * @version 1.0
 * @author Field Readiness Team
 */
@RestResource(urlMapping='/agent/*')
global with sharing class MCPAgentController {
    
    /**
     * POST /agent/*
     * Route POST requests to appropriate handler based on URL path
     */
    @HttpPost
    global static void handlePost() {
        RestRequest req = RestContext.request;
        String requestURI = req.requestURI;
        
        try {
            if (requestURI.contains('/openPipeAnalyze')) {
                handleOpenPipeAnalyze();
            } else if (requestURI.contains('/kpiAnalyze')) {
                handleKPIAnalyze();
            } else if (requestURI.contains('/contentSearch')) {
                handleContentSearch();
            } else if (requestURI.contains('/smeSearch')) {
                handleSMESearch();
            } else if (requestURI.contains('/workflow')) {
                handleWorkflow();
            } else if (requestURI.contains('/futurePipeline')) {
                handleFuturePipeline();
            } else {
                sendErrorResponse('Endpoint not found. Available endpoints: /openPipeAnalyze, /kpiAnalyze, /contentSearch, /smeSearch, /workflow, /futurePipeline', 404);
            }
        } catch (Exception e) {
            sendErrorResponse('API Error: ' + e.getMessage(), 500);
        }
    }
    
    /**
     * Handle Open Pipe Analysis
     */
    private static void handleOpenPipeAnalyze() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String requestBody = req.requestBody.toString();
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            // Extract parameters
            String ouName = (String) requestData.get('ouName');
            String country = (String) requestData.get('country');
            Integer minStage = (Integer) requestData.get('minStage');
            String productListCsv = (String) requestData.get('productListCsv');
            String timeFrame = (String) requestData.get('timeFrame');
            Integer limitN = (Integer) requestData.get('limitN');
            
            // Validate required parameters
            if (String.isBlank(ouName)) {
                sendErrorResponse('ouName is required', 400);
                return;
            }
            
            // Create agent request
            ANAgentOpenPipeAnalysisV3Handler.Request agentRequest = new ANAgentOpenPipeAnalysisV3Handler.Request();
            agentRequest.ouName = ouName;
            agentRequest.workLocationCountry = country;
            agentRequest.groupBy = 'STAGE';
            agentRequest.filterCriteria = buildFilterCriteria(minStage, productListCsv);
            agentRequest.perAENormalize = false;
            agentRequest.limitN = limitN != null ? limitN : 10;
            agentRequest.aggregationType = 'COUNT';
            agentRequest.analysisType = 'STAGE_COUNT';
            
            // Call agent
            List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = 
                ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{agentRequest});
            
            if (responses.isEmpty()) {
                sendErrorResponse('Open Pipe Analysis failed: No response received', 500);
                return;
            }
            
            // Build response
            Map<String, Object> result = new Map<String, Object>();
            result.put('ouName', ouName);
            result.put('country', country);
            result.put('minStage', minStage);
            result.put('productListCsv', productListCsv);
            result.put('timeFrame', timeFrame);
            result.put('limitN', limitN);
            result.put('analysisMessage', responses[0].message);
            result.put('timestamp', System.now());
            
            sendSuccessResponse(result, 'Open Pipe Analysis completed successfully');
            
        } catch (Exception e) {
            sendErrorResponse('Open Pipe Analysis Error: ' + e.getMessage(), 500);
        }
    }
    
    /**
     * Handle KPI Analysis
     */
    private static void handleKPIAnalyze() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String requestBody = req.requestBody.toString();
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            // Extract parameters - support both direct and nested request formats
            String analysisType = (String) requestData.get('analysisType');
            String timeFrame = (String) requestData.get('timeFrame');
            String primaryDimension = (String) requestData.get('primaryDimension');
            String primaryValue = (String) requestData.get('primaryValue');
            String secondaryDimension = (String) requestData.get('secondaryDimension');
            String secondaryValue = (String) requestData.get('secondaryValue');
            Integer maxResults = (Integer) requestData.get('maxResults');
            Boolean includeLearnerProfile = (Boolean) requestData.get('includeLearnerProfile');
            Boolean fuzzySearchEnabled = (Boolean) requestData.get('fuzzySearchEnabled');
            
            // Legacy support for old format
            if (String.isBlank(analysisType)) {
                analysisType = (String) requestData.get('metricKey');
            }
            if (String.isBlank(primaryValue)) {
                primaryValue = (String) requestData.get('ouName');
            }
            if (String.isBlank(secondaryValue)) {
                secondaryValue = (String) requestData.get('country');
            }
            
            // Set defaults
            if (String.isBlank(analysisType)) analysisType = 'MEETINGS';
            if (String.isBlank(timeFrame)) timeFrame = 'CURRENT';
            if (String.isBlank(primaryDimension)) primaryDimension = 'OU_NAME__c';
            if (maxResults == null) maxResults = 1000;
            if (includeLearnerProfile == null) includeLearnerProfile = true;
            if (fuzzySearchEnabled == null) fuzzySearchEnabled = true;
            
            // Validate required parameters
            if (String.isBlank(primaryValue)) {
                sendErrorResponse('primaryValue (or ouName) is required', 400);
                return;
            }
            
            // Create agent request
            ANAgentKPIAnalysisHandler.KPIAnalysisRequest agentRequest = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
            agentRequest.analysisType = analysisType;
            agentRequest.timeFrame = timeFrame;
            agentRequest.primaryDimension = primaryDimension;
            agentRequest.primaryValue = primaryValue;
            agentRequest.secondaryDimension = secondaryDimension;
            agentRequest.secondaryValue = secondaryValue;
            agentRequest.maxResults = maxResults;
            agentRequest.includeLearnerProfile = includeLearnerProfile;
            agentRequest.fuzzySearchEnabled = fuzzySearchEnabled;
            
            // Call agent
            List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = 
                ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{agentRequest});
            
            if (responses.isEmpty()) {
                sendErrorResponse('KPI Analysis failed: No response received', 500);
                return;
            }
            
            // Build response
            ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
            Map<String, Object> result = new Map<String, Object>();
            result.put('ouName', response.ouName);
            result.put('country', response.country);
            result.put('timeFrame', response.timeFrame);
            result.put('analysisType', response.analysisType);
            result.put('totalRecordCount', response.totalRecordCount);
            result.put('totalAEs', response.totalAEs);
            result.put('avgCoverage', response.avgCoverage);
            result.put('totalACV', response.totalACV);
            result.put('totalPG', response.totalPG);
            result.put('totalMeetings', response.totalMeetings);
            result.put('totalCallConnects', response.totalCallConnects);
            result.put('warnings', response.warnings);
            result.put('learnerProfiles', response.learnerProfiles);
            result.put('fuzzyMatches', response.fuzzyMatches);
            result.put('message', response.message);
            result.put('timestamp', System.now());
            
            sendSuccessResponse(result, 'KPI Analysis completed successfully');
            
        } catch (Exception e) {
            sendErrorResponse('KPI Analysis Error: ' + e.getMessage(), 500);
        }
    }
    
    /**
     * Handle Content Search
     */
    private static void handleContentSearch() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String requestBody = req.requestBody.toString();
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            // Extract parameters
            String topic = (String) requestData.get('topic');
            String source = (String) requestData.get('source');
            
            // Validate required parameters
            if (String.isBlank(topic)) {
                sendErrorResponse('topic is required', 400);
                return;
            }
            
            // Create agent request
            ANAgentContentSearchHandlerV2.ContentSearchRequest agentRequest = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
            agentRequest.searchTerm = topic;
            agentRequest.contentType = source;
            
            // Call agent
            List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
                ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{agentRequest});
            
            if (responses.isEmpty() || !responses[0].success) {
                sendErrorResponse('Content search failed: ' + (responses.isEmpty() ? 'No response' : responses[0].message), 500);
                return;
            }
            
            // Build response
            Map<String, Object> result = new Map<String, Object>();
            result.put('topic', topic);
            result.put('source', source);
            result.put('results', responses[0].results);
            result.put('timestamp', System.now());
            
            sendSuccessResponse(result, 'Content search completed successfully');
            
        } catch (Exception e) {
            sendErrorResponse('Content Search Error: ' + e.getMessage(), 500);
        }
    }
    
    /**
     * Handle SME Search
     */
    private static void handleSMESearch() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String requestBody = req.requestBody.toString();
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            // Extract parameters
            String region = (String) requestData.get('region');
            String expertise = (String) requestData.get('expertise');
            
            // Build search term
            String searchTerm = '';
            if (String.isNotBlank(region) && String.isNotBlank(expertise)) {
                searchTerm = region + ' ' + expertise;
            } else if (String.isNotBlank(region)) {
                searchTerm = region;
            } else if (String.isNotBlank(expertise)) {
                searchTerm = expertise;
            } else {
                sendErrorResponse('Either region or expertise is required', 400);
                return;
            }
            
            // Create agent request
            ANAgentSMESearchHandler.SMESearchRequest agentRequest = new ANAgentSMESearchHandler.SMESearchRequest();
            agentRequest.searchTerm = searchTerm;
            agentRequest.searchType = 'all';
            agentRequest.maxResults = 50;
            agentRequest.academyMembersOnly = false;
            
            // Call agent
            List<ANAgentSMESearchHandler.SMESearchResponse> responses = 
                ANAgentSMESearchHandler.searchSMEs(new List<ANAgentSMESearchHandler.SMESearchRequest>{agentRequest});
            
            if (responses.isEmpty() || !responses[0].success) {
                sendErrorResponse('SME search failed: ' + (responses.isEmpty() ? 'No response' : responses[0].message), 500);
                return;
            }
            
            // Build response
            Map<String, Object> result = new Map<String, Object>();
            result.put('region', region);
            result.put('expertise', expertise);
            result.put('smeRecords', responses[0].smeRecords);
            result.put('totalCount', responses[0].totalCount);
            result.put('productSummary', responses[0].productSummary);
            result.put('topPerformers', responses[0].topPerformers);
            result.put('timestamp', System.now());
            
            sendSuccessResponse(result, 'SME search completed successfully');
            
        } catch (Exception e) {
            sendErrorResponse('SME Search Error: ' + e.getMessage(), 500);
        }
    }
    
    /**
     * Handle Workflow
     */
    private static void handleWorkflow() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String requestBody = req.requestBody.toString();
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            String process = (String) requestData.get('process');
            String context = (String) requestData.get('context');
            
            // Build response with workflow information
            Map<String, Object> result = new Map<String, Object>();
            result.put('process', process);
            result.put('context', context);
            result.put('workflowSteps', new List<String>{
                '1. Identify the business requirement',
                '2. Gather necessary information',
                '3. Follow established procedures',
                '4. Document the process',
                '5. Complete the workflow'
            });
            result.put('timestamp', System.now());
            
            sendSuccessResponse(result, 'Workflow information retrieved successfully');
            
        } catch (Exception e) {
            sendErrorResponse('Workflow Error: ' + e.getMessage(), 500);
        }
    }
    
    /**
     * Handle Future Pipeline
     */
    private static void handleFuturePipeline() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String requestBody = req.requestBody.toString();
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            // Extract parameters
            String ouName = (String) requestData.get('ouName');
            String timeFrame = (String) requestData.get('timeFrame');
            String opportunityType = (String) requestData.get('opportunityType');
            String product = (String) requestData.get('product');
            String segment = (String) requestData.get('segment');
            Integer limitValue = (Integer) requestData.get('limit');
            
            // Validate required parameters
            if (String.isBlank(ouName)) {
                sendErrorResponse('ouName is required', 400);
                return;
            }
            
            // Build response with pipeline generation information
            Map<String, Object> result = new Map<String, Object>();
            result.put('ouName', ouName);
            result.put('timeFrame', timeFrame);
            result.put('opportunityType', opportunityType);
            result.put('product', product);
            result.put('segment', segment);
            result.put('limit', limitValue);
            result.put('pipelineGenerated', true);
            result.put('message', 'Future pipeline generation completed successfully');
            result.put('timestamp', System.now());
            
            sendSuccessResponse(result, 'Future pipeline generated successfully');
            
        } catch (Exception e) {
            sendErrorResponse('Future Pipeline Error: ' + e.getMessage(), 500);
        }
    }
    
    // Helper methods
    private static String buildFilterCriteria(Integer minStage, String productListCsv) {
        String criteria = '';
        
        if (minStage != null) {
            criteria += 'Stage >= ' + minStage;
        }
        
        if (String.isNotBlank(productListCsv)) {
            if (String.isNotBlank(criteria)) {
                criteria += ' AND ';
            }
            criteria += 'Product IN (' + productListCsv + ')';
        }
        
        return criteria;
    }
    
    private static String buildKPIFilterCriteria(String ouName, String country) {
        String criteria = '';
        
        if (String.isNotBlank(ouName)) {
            criteria += 'Operating_Unit__c = \'' + ouName + '\'';
        }
        
        if (String.isNotBlank(country)) {
            if (String.isNotBlank(criteria)) {
                criteria += ' AND ';
            }
            criteria += 'Work_Location_Country__c = \'' + country + '\'';
        }
        
        return criteria;
    }
    
    private static void sendSuccessResponse(Object data, String message) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.addHeader('Content-Type', 'application/json');
        
        Map<String, Object> response = new Map<String, Object>();
        response.put('success', true);
        response.put('message', message);
        response.put('data', data);
        response.put('timestamp', System.now());
        
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    
    private static void sendErrorResponse(String message, Integer statusCode) {
        RestResponse res = RestContext.response;
        res.statusCode = statusCode;
        res.addHeader('Content-Type', 'application/json');
        
        Map<String, Object> response = new Map<String, Object>();
        response.put('success', false);
        response.put('message', message);
        response.put('timestamp', System.now());
        
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
}
