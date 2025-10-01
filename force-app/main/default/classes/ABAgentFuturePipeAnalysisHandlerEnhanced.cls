/**
 * ENHANCED FUTURE PIPELINE ANALYSIS HANDLER
 * 
 * This handler extends the original Future Pipeline Analysis with intelligence capabilities.
 * It maintains backward compatibility while adding optional intelligence features.
 */
public with sharing class ABAgentFuturePipeAnalysisHandlerEnhanced {
    
    /**
     * Enhanced request object with intelligence flags
     */
    public class EnhancedRequest {
        @InvocableVariable(
            label='Analysis Type'
            description='The type of analysis to perform. Must be one of: "RENEWALS", "CROSS_SELL", "UPSELL".'
            required=true
        )
        public String analysisType;
        
        @InvocableVariable(
            label='Session ID'
            description='Optional external session identifier for logging'
            required=false
        )
        public String sessionId;
        
        @InvocableVariable(
            label='Turn Number'
            description='Optional turn sequence number within the session for logging'
            required=false
        )
        public Integer turnNumber;
        
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
            label='Per-AE Normalized'
            description='Whether to normalize results per AE. Defaults to false.'
            required=false
        )
        public Boolean perAENormalize;
        
        @InvocableVariable(
            label='Limit N'
            description='Maximum number of results to return. Defaults to 20, maximum 200.'
            required=false
        )
        public Integer limitN;
        
        @InvocableVariable(
            label='Aggregation Type'
            description='Type of aggregation to perform. Options: "SUM", "COUNT", "AVG", "MAX", "MIN". Defaults to "COUNT".'
            required=false
        )
        public String aggregationType;
        
        @InvocableVariable(
            label='Analysis Type Detail'
            description='Detailed analysis type for reporting.'
            required=false
        )
        public String analysisTypeDetail;
        
        @InvocableVariable(
            label='Start Date'
            description='Start date for date range filtering. Format: YYYY-MM-DD. Only applicable for Renewals analysis.'
            required=false
        )
        public Date startDate;
        
        @InvocableVariable(
            label='End Date'
            description='End date for date range filtering. Format: YYYY-MM-DD. Only applicable for Renewals analysis.'
            required=false
        )
        public Date endDate;
        
        // Intelligence feature flags
        @InvocableVariable(
            label='Include Renewal Risk'
            description='Include renewal risk analysis (RENEWAL analysis only)'
            required=false
        )
        public Boolean includeRenewalRisk;
        
        @InvocableVariable(
            label='Include AE Performance'
            description='Include AE performance analysis and benchmarking'
            required=false
        )
        public Boolean includeAEPerf;
        
        @InvocableVariable(
            label='Include PMF'
            description='Include product-market fit analysis'
            required=false
        )
        public Boolean includePMF;
        
        @InvocableVariable(
            label='Include Health Score'
            description='Include pipeline health scoring'
            required=false
        )
        public Boolean includeHealthScore;
    }
    
    /**
     * Enhanced response object
     */
    public class EnhancedResponse {
        @InvocableVariable(
            label='Message'
            description='The analysis results in formatted markdown text with intelligence insights'
        )
        public String message;
    }
    
    /**
     * Enhanced invocable method for Future Pipeline Analysis with Intelligence
     */
    @InvocableMethod(
        label='ABAGENT Future Pipeline Analysis Enhanced'
        description='Enhanced analysis for Renewals, Cross-sell, and Upsell data with intelligence capabilities'
        category='Agent Analysis'
    )
    public static List<EnhancedResponse> analyzePipelineEnhanced(List<EnhancedRequest> requests) {
        List<EnhancedResponse> responses = new List<EnhancedResponse>();
        
        for (EnhancedRequest req : requests) {
            try {
                // Validate required fields
                if (String.isBlank(req.analysisType)) {
                    responses.add(createErrorResponse('Analysis Type is required. Must be one of: RENEWALS, CROSS_SELL, UPSELL'));
                    continue;
                }
                
                // Normalize analysis type
                String normalizedType = req.analysisType.toUpperCase();
                if (!isValidAnalysisType(normalizedType)) {
                    responses.add(createErrorResponse('Invalid Analysis Type: ' + req.analysisType + '. Must be one of: RENEWALS, CROSS_SELL, UPSELL'));
                    continue;
                }
                
                // Set defaults
                if (String.isBlank(req.groupBy)) {
                    req.groupBy = 'PRODUCT';
                }
                if (req.limitN == null || req.limitN <= 0) {
                    req.limitN = 20;
                }
                if (String.isBlank(req.aggregationType)) {
                    if (normalizedType == 'RENEWALS') {
                        req.aggregationType = 'SUM';
                    } else {
                        req.aggregationType = 'COUNT';
                    }
                }
                if (String.isBlank(req.analysisTypeDetail)) {
                    req.analysisTypeDetail = normalizedType + '_ANALYSIS';
                }
                if (req.perAENormalize == null) {
                    req.perAENormalize = false;
                }
                
                // Set intelligence flags defaults
                if (req.includeRenewalRisk == null) {
                    req.includeRenewalRisk = false;
                }
                if (req.includeAEPerf == null) {
                    req.includeAEPerf = false;
                }
                if (req.includePMF == null) {
                    req.includePMF = false;
                }
                if (req.includeHealthScore == null) {
                    req.includeHealthScore = false;
                }
                
                // Call enhanced service
                String result = ABAgentFuturePipeAnalysisServiceEnhanced.analyzePipelineEnhanced(
                    normalizedType,
                    req.ouName,
                    req.workLocationCountry,
                    req.groupBy,
                    req.filterCriteria,
                    req.restrictInValuesCsv,
                    req.perAENormalize,
                    req.limitN,
                    req.aggregationType,
                    req.analysisTypeDetail,
                    req.startDate,
                    req.endDate,
                    req.includeRenewalRisk,
                    req.includeAEPerf,
                    req.includePMF,
                    req.includeHealthScore
                );
                
                EnhancedResponse response = new EnhancedResponse();
                response.message = result;
                responses.add(response);
                
                // Log interaction
                logInteraction(req, result, 'Success');
                
            } catch (Exception e) {
                AgentLog.error('ABAgentFuturePipeAnalysisHandlerEnhanced', 'Error in enhanced future pipeline analysis', new Map<String, Object>{
                    'error' => e.getMessage(),
                    'stackTrace' => e.getStackTraceString(),
                    'analysisType' => req.analysisType
                });
                responses.add(createErrorResponse('Enhanced analysis failed: ' + e.getMessage()));
                
                // Log error
                logInteraction(req, 'Enhanced analysis failed: ' + e.getMessage(), 'Error');
            }
        }
        
        return responses;
    }
    
    /**
     * Validates if the analysis type is supported
     */
    private static Boolean isValidAnalysisType(String analysisType) {
        Set<String> validTypes = new Set<String>{'RENEWALS', 'CROSS_SELL', 'UPSELL'};
        return validTypes.contains(analysisType);
    }
    
    /**
     * Creates an error response with the specified message
     */
    private static EnhancedResponse createErrorResponse(String errorMessage) {
        EnhancedResponse response = new EnhancedResponse();
        response.message = '# Enhanced Future Pipeline Analysis\n\n## Error\n' + errorMessage;
        return response;
    }
    
    /**
     * Log interaction for tracking
     */
    private static void logInteraction(EnhancedRequest req, String result, String status) {
        try {
            String sessionId = req.sessionId;
            if (String.isBlank(sessionId)) {
                sessionId = 'FALLBACK_SESSION_' + System.currentTimeMillis() + '_' + UserInfo.getUserId();
            }
            
            AgentInteractionLogger.LogInput li = new AgentInteractionLogger.LogInput();
            li.sessionId = sessionId;
            li.userId = UserInfo.getUserId();
            li.turnNumber = req.turnNumber;
            li.interactionTimestamp = System.now();
            li.detectedIntent = 'ABAgentFuturePipeAnalysisEnhanced';
            li.actionParameters = req;
            li.responseMessage = result;
            li.structuredResponse = new Map<String, Object>{
                'analysisType' => req.analysisType,
                'groupBy' => req.groupBy,
                'aggregationType' => req.aggregationType,
                'limitN' => req.limitN,
                'ouName' => req.ouName,
                'workLocationCountry' => req.workLocationCountry,
                'includeRenewalRisk' => req.includeRenewalRisk,
                'includeAEPerf' => req.includeAEPerf,
                'includePMF' => req.includePMF,
                'includeHealthScore' => req.includeHealthScore
            };
            li.responseStatus = status;
            li.queryTemplate = req.filterCriteria;
            
            AgentInteractionLogger.log(new List<AgentInteractionLogger.LogInput>{ li });
        } catch (Exception e) {
            System.debug('Error logging enhanced interaction: ' + e.getMessage());
        }
    }
}
