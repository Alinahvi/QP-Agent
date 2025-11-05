/**
 * @description Program Search Handler V6 - Clean implementation with AgentCore integration
 * @author Sales Operations Team
 * @version 6.0
 * @date 2025-11-04
 * 
 * IMPROVEMENTS FROM V5:
 * - AgentCore Constants integration for standardized error handling
 * - AgentCore Exception for typed business errors
 * - Removed Halloween theme completely
 * - Professional, enterprise-ready error messages
 * - Enhanced field descriptions using "Examples:" not "Valid values:" to prevent agent pre-validation
 * - searchTerm correctly marked as OPTIONAL (required=false)
 * - Clear agent guidance: "AGENT: Always call if programType provided"
 * 
 * PURPOSE: Unified search across Product Catalog (172 global programs) and Regional Programs (861 localized programs)
 * - Smart search with synonym expansion and fuzzy matching
 * - Usage metrics from Enablement_Solutions__c
 * - Multi-catalog search (GLOBAL, REGIONAL, or BOTH)
 */
global with sharing class ANAgentProgramSearchHandlerV6 {
    
    /**
     * @description Request DTO for Program Search V6
     * Uses String type for flexible Boolean/Integer fields
     */
    global class ProgramSearchRequest {
        
        @InvocableVariable(label='Search Term' description='Program name, topic, skill, or product keyword. Searches Course_Asset_Title__c, Description__c, Business_Priority__c (Global) and Regional_Program_Name__c, Business_Priority__c (Regional). SMART SEARCH: auto-expands synonyms. Examples: "Agentforce", "Tableau", "storytelling", "BDR Onboarding". Min 2 characters. OPTIONAL - if blank, returns all programs subject to filters. Service validates length.' required=false)
        public String searchTerm;
        
        @InvocableVariable(label='Program Type' description='Which catalog to search. Queries Product_Catalog__c (GLOBAL - 172 programs) or Regional_Programs__c (REGIONAL - 861 programs) or BOTH. Examples: "GLOBAL", "REGIONAL", "BOTH". Case-insensitive. Use GLOBAL for standardized enterprise programs, REGIONAL for localized initiatives, BOTH for comprehensive discovery.' required=true)
        public String programType;
        
        @InvocableVariable(label='Enablement Type' description='Filter by category. Filters Enablement_Type__c field. Examples: "PRODUCT" (45% of programs), "SKILLS" (30%), "INDUSTRY" (15%), "DO_MY_JOB" (35%), "ALL". Use PRODUCT for "Tableau training", SKILLS for "storytelling", DO_MY_JOB for "AE onboarding". Service validates.' required=false)
        public String enablementType;
        
        @InvocableVariable(label='Target Level' description='Filter by difficulty level (Global only). Filters Level__c field in Product_Catalog__c (76% populated). Examples: "BEGINNER", "INTERMEDIATE", "ADVANCED", "EXPERT", "ALL". Null values included to avoid missing programs. Service validates.' required=false)
        public String targetLevel;
        
        @InvocableVariable(label='Target Role' description='Filter by job role audience (Global only). Filters Role__c field in Product_Catalog__c (74% populated, multi-select). Examples: "AE", "SE", "BDR", "SDR", "SALES_MANAGER", "LEADER", "CSM", "ALL". Null values included. Service validates.' required=false)
        public String targetRole;
        
        @InvocableVariable(label='Fiscal Quarter' description='Filter by quarterly usage history (what WAS delivered). Queries Quarterly_Planning__c via Enablement_Solutions__c linkage. Examples: "Q1" (Feb-Apr), "Q2" (May-Jul), "Q3" (Aug-Oct), "Q4" (Nov-Jan). Must be used WITH fiscalYear. Service validates. Returns programs actually scheduled/delivered in that quarter.' required=false)
        public String fiscalQuarter;
        
        @InvocableVariable(label='Fiscal Year' description='Filter by fiscal year usage history. Examples: "FY 2024", "FY 2025", "FY 2026". Format: Must include "FY" prefix + space + 4-digit year. Must be used WITH fiscalQuarter. Service validates range. Shows historical delivery, not future planning.' required=false)
        public String fiscalYear;
        
        @InvocableVariable(label='Global Region' description='Filter by geographic region. For Product_Catalog__c: filters Regions__c field (30% populated). For Regional_Programs__c: filters via Enablement_Solutions__c.Global_Region__c. Examples: "GLOBAL" (worldwide), "AMER", "EMEA", "APAC", "LATAM", "JAPAN", "ALL". Service validates. Null values included.' required=false)
        public String globalRegion;
        
        @InvocableVariable(label='Session Type' description='Filter by delivery format (Regional only). Filters Session_Type__c in Regional_Programs__c (90% populated). Examples: "VIRTUAL" (55%), "PHYSICAL" (25%), "HYBRID" (20%), "ALL". Use VIRTUAL for "online programs", PHYSICAL for "in-person". Service validates.' required=false)
        public String sessionType;
        
        @InvocableVariable(label='Business Priority' description='Filter by strategic priority keyword. Searches Business_Priority__c and Excellence_Factor__c fields with fuzzy matching. AUTO-MAPS: "ACV growth"→"ACV/AOV", "Big Deal"→"Big Deal Motion". Examples: "Agentforce", "AI + Data + CRM", "Pipeline", "Onboarding". Service processes.' required=false)
        public String businessPriority;
        
        @InvocableVariable(label='Min Hours' description='Minimum program duration in hours. Filters Total_Learner_Time_Investment__c (Global) or Hours__c (Regional). Examples: 0.5 (30 min), 1.0, 2.0, 8.0 (full day). Service validates >= 0.' required=false)
        public Decimal minHoursRequired;
        
        @InvocableVariable(label='Max Hours' description='Maximum program duration in hours. Filters Total_Learner_Time_Investment__c (Global) or Hours__c (Regional). Examples: 1.0 (< 1 hour), 4.0 (half day), 8.0 (full day). Service validates >= 0 and >= minHours.' required=false)
        public Decimal maxHoursRequired;
        
        @InvocableVariable(label='Sort By' description='Sort field. Examples: "USAGE_COUNT" (by enrollment count), "TOTAL_LEARNERS" (by learner count), "RECENT_USAGE" (by last scheduled date), "NAME" (alphabetical), "HOURS" (by duration), "DEFAULT" (recommended). Service validates. Metrics-based sorting requires includeUsageMetrics=true.' required=false)
        public String sortBy;
        
        @InvocableVariable(label='Sort Order' description='Sort direction. Examples: "ASC" (ascending), "DESC" (descending). Default: DESC. Service validates.' required=false)
        public String sortOrder;
        
        @InvocableVariable(label='Limit' description='📊 MAX RESULTS PER CATALOG - Default: 50. ✅ FLEXIBLE: Accepts 50 (number) OR "50" (string). Examples: 50, "50", "20", 100. Service validates range (1-100). When programType=BOTH, applies per catalog (max 100 Global + 100 Regional = 200 total).' required=false)
        public String limitStr;
        
        @InvocableVariable(label='Include Usage Metrics' description='⚡ ENRICHMENT - ✅ FLEXIBLE: Accepts true (boolean) OR "true"/"yes"/"1" (string) to include metrics, false/"false"/"no"/"0" to skip. Default: true. When true, adds: usageCount, totalLearners, recentUsage90Days, lastScheduledDate, avgLearnersPerInstance from Enablement_Solutions__c.' required=false)
        public String includeUsageMetricsStr;
        
        @InvocableVariable(label='Include Archived' description='⚡ ARCHIVE FILTER - ✅ FLEXIBLE: Accepts true/"true"/"yes"/"1" to include archived, false/"false"/"no"/"0" to exclude. Default: false. Filters Program_Menu_Item_Health__c (Global). Service validates. Use TRUE only for historical analysis, FALSE (default) for active programs only.' required=false)
        public String includeArchivedStr;
    }

    /**
     * @description Response DTO for Program Search V6
     */
    global class ProgramSearchResponse {
        @InvocableVariable(label='Program Search Result' description='JSON with programs from Product_Catalog__c and/or Regional_Programs__c. Includes: programId, name, description, enablementType, level, role, products (L1/L2/L3), skills, region, duration, deliveryCadence, links. When includeUsageMetrics=true, adds: usageCount, totalLearners, recentUsage90Days, lastScheduledDate, avgLearnersPerInstance. Summary includes: totalPrograms, globalCount, regionalCount, avgDuration, topProducts, topSkills.' required=true)
        public String result;

        public ProgramSearchResponse() {
            this.result = '';
        }
    }

    /**
     * @description Main invocable method - flexible input handling with auto-conversion
     */
    @InvocableMethod(label='SearchProgramsV6' description='🎯 PROGRAM DISCOVERY V6 - Searches Product Catalog (172 global programs) and Regional Programs (861 localized programs). REQUIRED: programType="GLOBAL"|"REGIONAL"|"BOTH". OPTIONAL: searchTerm (if blank, returns all programs), all other filters. ✅ FLEXIBLE INPUT: includeUsageMetrics accepts true/"true"/"yes"/"1", limit accepts 50/"50". AGENT: Always call if programType provided - service validates all inputs and returns structured errors. Examples: {"programType":"BOTH","limit":"50"} OR {"programType":"GLOBAL","searchTerm":"Agentforce","limit":50}. Returns programs with smart synonym expansion and usage metrics.')
    global static List<ProgramSearchResponse> searchPrograms(List<ProgramSearchRequest> requests) {
        List<ProgramSearchResponse> responses = new List<ProgramSearchResponse>();

        if (requests == null || requests.isEmpty()) {
            ProgramSearchResponse errorResponse = new ProgramSearchResponse();
            errorResponse.result = buildError(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                'Request list is null or empty', 'requests', 
                'List<ProgramSearchRequest>', 'null or empty', 
                new List<String>{'Provide valid request object'},
                new List<String>{'Include programType (required)', 'searchTerm is optional'});
            responses.add(errorResponse);
            return responses;
        }

        for (ProgramSearchRequest request : requests) {
            ProgramSearchResponse response = new ProgramSearchResponse();
            
            // FLEXIBLE INPUT HANDLING: Convert string inputs to proper types
            Integer limitValue = null;
            Boolean includeUsageMetrics = null;
            Boolean includeArchived = null;
            
            // Convert limit (string → integer)
            if (String.isNotBlank(request.limitStr)) {
                Object conversionResult = convertToInteger(request.limitStr, 'limit');
                if (conversionResult instanceof String) {
                    response.result = (String) conversionResult;
                    responses.add(response);
                    continue;
                }
                limitValue = (Integer) conversionResult;
            }
            
            // Convert includeUsageMetrics (string → boolean)
            if (String.isNotBlank(request.includeUsageMetricsStr)) {
                Object conversionResult = convertToBoolean(request.includeUsageMetricsStr, 'includeUsageMetrics');
                if (conversionResult instanceof String) {
                    response.result = (String) conversionResult;
                    responses.add(response);
                    continue;
                }
                includeUsageMetrics = (Boolean) conversionResult;
            }
            
            // Convert includeArchived (string → boolean)
            if (String.isNotBlank(request.includeArchivedStr)) {
                Object conversionResult = convertToBoolean(request.includeArchivedStr, 'includeArchived');
                if (conversionResult instanceof String) {
                    response.result = (String) conversionResult;
                    responses.add(response);
                    continue;
                }
                includeArchived = (Boolean) conversionResult;
            }
            
            // Call service with normalized values
            response.result = ANAgentProgramSearchServiceV6.search(request, limitValue, includeUsageMetrics, includeArchived);
            responses.add(response);
        }

        return responses;
    }
    
    /**
     * @description Converts string to Integer with validation
     */
    private static Object convertToInteger(String input, String fieldName) {
        if (String.isBlank(input)) {
            return null;
        }
        
        try {
            return Integer.valueOf(input.trim());
        } catch (Exception e) {
            return buildError(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                'Cannot convert ' + fieldName + ' to Integer: received "' + input + '"',
                fieldName, 'Integer', input,
                new List<String>{'50', '"50"', '20', '"100"', '10'},
                new List<String>{
                    'Use a number between 1 and 100',
                    'Examples: ' + fieldName + '=50 OR ' + fieldName + '="50"',
                    'Default is 50 if not specified'
                });
        }
    }
    
    /**
     * @description Converts string to Boolean with flexible format support
     */
    private static Object convertToBoolean(String input, String fieldName) {
        if (String.isBlank(input)) {
            return null;
        }
        
        String normalized = input.toLowerCase().trim();
        
        // TRUE values
        if (normalized == 'true' || normalized == 'yes' || normalized == '1') {
            return true;
        }
        
        // FALSE values
        if (normalized == 'false' || normalized == 'no' || normalized == '0') {
            return false;
        }
        
        // Invalid format
        return buildError(AgentCore_Constants.RESULT_CODE_INVALID_INPUT,
            'Cannot convert ' + fieldName + ' to Boolean: received "' + input + '"',
            fieldName, 'Boolean', input,
            new List<String>{'true', '"true"', '"yes"', '"1"', 'false', '"false"', '"no"', '"0"'},
            new List<String>{
                'Use true/false (boolean) OR "true"/"false" (string)',
                'Accepted TRUE values: true, "true", "yes", "1"',
                'Accepted FALSE values: false, "false", "no", "0"',
                'Example: ' + fieldName + '=true OR ' + fieldName + '="true"'
            });
    }
    
    /**
     * @description Builds standardized error response with agent guidance (AgentCore aligned)
     */
    private static String buildError(String code, String message, String field, 
                                     String expected, String received,
                                     List<String> examples, List<String> nextSteps) {
        Map<String, Object> error = new Map<String, Object>{
            'ok' => false,
            'data' => null,
            'error' => new Map<String, Object>{
                'code' => code,
                'message' => message,
                'details' => new Map<String, Object>{
                    'field' => field,
                    'expected' => expected,
                    'received' => received,
                    'examples' => examples,
                    'agent_next_steps' => nextSteps
                }
            }
        };
        return JSON.serialize(error);
    }
}

