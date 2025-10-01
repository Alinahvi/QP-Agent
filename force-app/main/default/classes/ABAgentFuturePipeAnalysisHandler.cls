/**
 * UNIFIED FUTURE PIPELINE ANALYSIS HANDLER
 *
 * This handler consolidates Renewals, Cross-sell, and Upsell analysis into a single unified service.
 * It maintains backward compatibility while providing a single entry point for all pipeline analysis types.
 *
 * Business Requirement: The handler validates requests and delegates business logic to the unified service layer.
 *
 * Definitions:
 * - "Slow Ramper(s)": maps to ramp_status__c = 'Slow Ramper'. Also supported via aliases
 *   like renewal_ae_ramp_status and ae_ramp_status in filter criteria.
 *
 * @version 1.0 - Unified Analysis Handler
 */
public with sharing class ABAgentFuturePipeAnalysisHandler {

    /**
     * @description The request object for the Future Pipeline Analysis invocable method.
     */
    public class Request {
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
            description='The field to group results by. Must be one of: "PRODUCT", "INDUSTRY", "MACRO_SEGMENT", "AE", "COUNTRY", "MANAGER", "ACCOUNT", "LEARNER_PROFILE". Defaults to "PRODUCT".'
            required=false
        )
        public String groupBy;

        @InvocableVariable(
            label='Filter Criteria'
            description='SOQL WHERE clause filter using allowed fields. Supports natural-language keyword "slow rampers" (maps to ramp_status__c = \'Slow Ramper\'). Ramp status field aliases supported: renewal_ae_ramp_status, ae_ramp_status. For Renewals: renewal_prod_nm, renewal_acct_nm, renewal_opty_amt, etc. For Cross-sell: cross_sell_next_best_product, cross_sell_acct_nm, etc. For Upsell: upsell_sub_category, upsell_acct_nm, etc.'
            required=false
        )
        public String filterCriteria;

        @InvocableVariable(
            label='Restrict Values CSV'
            description='Comma-separated values to restrict results to specific groups. Example: "Sales Cloud - Enterprise Edition,Service Cloud - Enterprise Edition" for product grouping.'
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
            description='Detailed analysis type for reporting. Examples: "AE_ANALYSIS", "PRODUCT_ANALYSIS", "ACCOUNT_ANALYSIS".'
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
    }

    /**
     * @description The response object for the Future Pipeline Analysis invocable method.
     */
    public class Response {
        @InvocableVariable(
            label='Message'
            description='The analysis results in formatted markdown text'
        )
        public String message;
    }

    /**
     * @description Main invocable method for Future Pipeline Analysis
     * Routes requests to the appropriate analysis type in the unified service
     */
    @InvocableMethod(
        label='ABAGENT Future Pipeline Analysis'
        description='Unified analysis for Renewals, Cross-sell, and Upsell data with grouping, filtering, and aggregation capabilities'
        category='Agent Analysis'
    )
    public static List<Response> analyzePipeline(List<Request> requests) {
        // DEBUG: Log that the handler is being called
        System.debug('🔍 ABAgentFuturePipeAnalysisHandler.analyzePipeline called with ' + (requests != null ? requests.size() : 0) + ' requests');
        System.debug('🔍 Current User: ' + UserInfo.getUserId());
        System.debug('🔍 Current Session ID: ' + UserInfo.getSessionId());
        System.debug('🔍 Current Time: ' + System.now());
        
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            try {
                // DEBUG: Log each request
                System.debug('🔍 Processing request: analysisType=' + req.analysisType + ', ouName=' + req.ouName + ', sessionId=' + req.sessionId + ', turnNumber=' + req.turnNumber);
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
                // Intelligent aggregation type detection
                if (String.isBlank(req.aggregationType)) {
                    // For Renewals, default to SUM when asking for amounts/dollar values
                    if (normalizedType == 'RENEWALS') {
                        req.aggregationType = 'SUM';
                    } else {
                        // For Cross-sell and Upsell, default to COUNT
                        req.aggregationType = 'COUNT';
                    }
                }
                if (String.isBlank(req.analysisTypeDetail)) {
                    req.analysisTypeDetail = normalizedType + '_ANALYSIS';
                }
                if (req.perAENormalize == null) {
                    req.perAENormalize = false;
                }

                // No automatic conversion - treat OU and country filters as separate and independent

                // Route to unified service based on analysis type
                String result = ABAgentFuturePipeAnalysisService.analyzePipeline(
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
                    req.endDate
                );

                Response response = new Response();
                response.message = result;
                responses.add(response);

                // DEBUG: Log interaction attempt
                System.debug('🔍 Attempting to log interaction for sessionId: ' + req.sessionId);
                
                // Log interaction - use provided sessionId or generate fallback
                String sessionId = req.sessionId;
                if (String.isBlank(sessionId)) {
                    // Try to get session ID from agent framework context
                    try {
                        // Get the current agent session ID from the execution context
                        sessionId = getAgentSessionId();
                        System.debug('🔍 Retrieved session ID from getAgentSessionId(): ' + sessionId);
                    } catch (Exception e) {
                        System.debug('🔍 Could not retrieve agent session ID: ' + e.getMessage());
                        // Generate fallback session ID to ensure logging always happens
                        sessionId = 'FALLBACK_SESSION_' + System.currentTimeMillis() + '_' + UserInfo.getUserId();
                        System.debug('🔍 Using fallback session ID: ' + sessionId);
                    }
                } else {
                    System.debug('🔍 Using provided session ID: ' + sessionId);
                }

                // Always log - we now guarantee a session ID
                if (String.isNotBlank(sessionId)) {
                    System.debug('🔍 Proceeding with logging using session ID: ' + sessionId);
                    try {
                        AgentInteractionLogger.LogInput li = new AgentInteractionLogger.LogInput();
                        li.sessionId = sessionId;
                        li.userId = UserInfo.getUserId();
                        li.turnNumber = req.turnNumber;
                        li.interactionTimestamp = System.now();
                        li.detectedIntent = 'ABAgentFuturePipeAnalysis';
                        li.actionParameters = req;
                        li.responseMessage = result;
                        li.structuredResponse = new Map<String, Object>{
                            'analysisType' => normalizedType,
                            'groupBy' => req.groupBy,
                            'aggregationType' => req.aggregationType,
                            'limitN' => req.limitN,
                            'ouName' => req.ouName,
                            'workLocationCountry' => req.workLocationCountry,
                            'analysisTypeDetail' => req.analysisTypeDetail,
                            'startDate' => req.startDate,
                            'endDate' => req.endDate
                        };
                        li.responseStatus = 'Success';
                        li.queryTemplate = req.filterCriteria;
                        
                        System.debug('🔍 About to call AgentInteractionLogger.log with sessionId: ' + li.sessionId);
                        AgentInteractionLogger.log(new List<AgentInteractionLogger.LogInput>{ li });
                        System.debug('🔍 AgentInteractionLogger.log completed successfully');
                    } catch (Exception logEx) {
                        System.debug('🔍 ERROR in logging: ' + logEx.getMessage());
                        System.debug('🔍 Stack trace: ' + logEx.getStackTraceString());
                        AgentLog.error('ABAgentFuturePipeAnalysisHandler', 'Logging failed', new Map<String, Object>{ 'error' => logEx.getMessage() });
                    }
                }

            } catch (Exception e) {
                AgentLog.error('ABAgentFuturePipeAnalysisHandler', 'Error in future pipeline analysis', new Map<String, Object>{
                    'error' => e.getMessage(),
                    'stackTrace' => e.getStackTraceString(),
                    'analysisType' => req.analysisType
                });
                responses.add(createErrorResponse('Analysis failed: ' + e.getMessage()));

                // DEBUG: Log error handling attempt
                System.debug('🔍 Attempting to log error for sessionId: ' + req.sessionId);
                
                // Log failure - use provided sessionId or generate fallback
                String sessionId = req.sessionId;
                if (String.isBlank(sessionId)) {
                    try {
                        sessionId = getAgentSessionId();
                        System.debug('🔍 Retrieved session ID for error logging: ' + sessionId);
                    } catch (Exception ex) {
                        // Generate fallback session ID to ensure error logging always happens
                        sessionId = 'FALLBACK_SESSION_' + System.currentTimeMillis() + '_' + UserInfo.getUserId();
                        System.debug('🔍 Using fallback session ID for error logging: ' + sessionId);
                    }
                }

                // Always log errors - we now guarantee a session ID
                if (String.isNotBlank(sessionId)) {
                    System.debug('🔍 Proceeding with error logging using session ID: ' + sessionId);
                    try {
                        AgentInteractionLogger.LogInput liErr = new AgentInteractionLogger.LogInput();
                        liErr.sessionId = sessionId;
                        liErr.userId = UserInfo.getUserId();
                        liErr.turnNumber = req.turnNumber;
                        liErr.interactionTimestamp = System.now();
                        liErr.detectedIntent = 'ABAgentFuturePipeAnalysis';
                        liErr.actionParameters = req;
                        liErr.responseMessage = 'Analysis failed: ' + e.getMessage();
                        liErr.structuredResponse = null;
                        liErr.responseStatus = 'Error';
                        liErr.queryTemplate = req.filterCriteria;
                        
                        System.debug('🔍 About to call AgentInteractionLogger.log for error with sessionId: ' + liErr.sessionId);
                        AgentInteractionLogger.log(new List<AgentInteractionLogger.LogInput>{ liErr });
                        System.debug('🔍 AgentInteractionLogger.log for error completed successfully');
                    } catch (Exception ignore) {
                        System.debug('🔍 ERROR in error logging: ' + ignore.getMessage());
                    }
                }
            }
        }

        return responses;
    }

    /**
     * @description Validates if the analysis type is supported
     */
    private static Boolean isValidAnalysisType(String analysisType) {
        Set<String> validTypes = new Set<String>{'RENEWALS', 'CROSS_SELL', 'UPSELL'};
        return validTypes.contains(analysisType);
    }

    /**
     * @description Creates an error response with the specified message
     */
    private static Response createErrorResponse(String errorMessage) {
        Response response = new Response();
        response.message = '# Future Pipeline Analysis\n\n## Error\n' + errorMessage;
        return response;
    }

    /**
     * @description Gets the current user's session ID from the execution context
     * This method retrieves the actual session ID when the handler is invoked
     * by the Agentforce framework or any other context
     */
    private static String getAgentSessionId() {
        try {
            // Get the actual session ID from the current execution context
            String sessionId = UserInfo.getSessionId();

            if (String.isNotBlank(sessionId)) {
                System.debug('Retrieved session ID: ' + sessionId);
                return sessionId;
            } else {
                System.debug('Session ID is null - likely in async context');
                return null;
            }

        } catch (Exception e) {
            System.debug('Error getting session ID: ' + e.getMessage());
            return null;
        }
    }
    
    // ============================================================================
    // ENHANCED ANALYSIS METHODS
    // ============================================================================
    
    /**
     * Enhanced method for comparative analysis (non-invocable)
     */
    public static List<Response> analyzeComparative(List<ComparativeRequest> requests) {
        List<Response> responses = new List<Response>();
        
        for (ComparativeRequest req : requests) {
            Response resp = new Response();
            
            try {
                String result = ABAgentFuturePipeAnalysisService.analyzeComparativePerformance(
                    req.analysisType,
                    req.primaryOu,
                    req.comparisonOu,
                    req.groupBy,
                    req.limitN
                );
                
                resp.message = result;
                
            } catch (Exception e) {
                resp.message = 'Comparative analysis failed: ' + e.getMessage();
            }
            
            responses.add(resp);
        }
        
        return responses;
    }
    
    /**
     * Enhanced method for market penetration analysis (non-invocable)
     */
    public static List<Response> analyzeMarketPenetration(List<MarketPenetrationRequest> requests) {
        List<Response> responses = new List<Response>();
        
        for (MarketPenetrationRequest req : requests) {
            Response resp = new Response();
            
            try {
                String result = ABAgentFuturePipeAnalysisService.analyzeMarketPenetration(
                    req.analysisType,
                    req.ouName,
                    req.groupBy,
                    req.limitN
                );
                
                resp.message = result;
                
            } catch (Exception e) {
                resp.message = 'Market penetration analysis failed: ' + e.getMessage();
            }
            
            responses.add(resp);
        }
        
        return responses;
    }
    
    // ============================================================================
    // ENHANCED REQUEST CLASSES
    // ============================================================================
    
    public class ComparativeRequest {
        public String analysisType;
        public String primaryOu;
        public String comparisonOu;
        public String groupBy;
        public Integer limitN;
        public String sessionId;
        public Integer turnNumber;
    }
    
    public class MarketPenetrationRequest {
        public String analysisType;
        public String ouName;
        public String groupBy;
        public Integer limitN;
        public String sessionId;
        public Integer turnNumber;
    }
}