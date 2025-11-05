/**
 * @description Open Pipe Analysis Handler V6 - AgentCore integrated with enhanced context
 * @author Sales Operations Team
 * @version 6.0
 * @date 2025-11-04
 * 
 * IMPROVEMENTS FROM V5:
 * - AgentCore Constants integration for standardized error codes
 * - Enhanced AE Scorecard context (0-5 scale, not 0-10)
 * - Product hierarchy clarification (APM_L2 is L2 category, PROD_NM is L3/SKU)
 * - Deal band definition context for agent
 * - Opportunity link support with includeOpportunityLinks switch
 * - Enhanced end date description (estimated close date context)
 * - Professional error messages using AgentCore pattern
 * 
 * PURPOSE: Analyze what's happening RIGHT NOW in the sales pipeline
 * - Which products are underperforming
 * - Which verticals/segments have issues
 * - Where deals are stagnating (high days in stage)
 * - Which stages have the biggest bottlenecks
 * - AE confidence scoring (0-5 scale with close rate correlation)
 * 
 * DEAL BAND DEFINITION (Salesforce terminology):
 * Deal size distribution / deal size analysis:
 * - <50k | 50-100k | 100-150k | 150k-500k | 1M+ 
 * Used for open pipeline analysis and enablement planning
 * 
 * PRODUCT HIERARCHY:
 * - APM_L2 (product family): L2 product category, ~100 categories (e.g., "Tableau")
 * - PROD_NM (product name): L3/SKU level, specific items (e.g., "Tableau Desktop")
 * 
 * AE SCORECARD (0-5 scale):
 * - 0: No score or uncertain (76.5% of deals)
 * - 1-2: Low confidence, needs intervention  
 * - 3: Above average, good close rate potential
 * - 4: Strong confidence, excellent close rate correlation (13% of deals)
 * - 5: Exceptional confidence, highest close rate correlation (1.7% of deals)
 * Anything above 3 indicates good close rate potential; 4-5 are excellent indicators
 * 
 * STAGE MAPPING (Human Names → Actual Field Values):
 * - "Stage 2" → "02 - Determining Problem, Impact, Ideal"
 * - "Stage 3" → "03 - Validating Benefits & Value"
 * - "Stage 4" → "04 - Confirming Value With Power"
 * - "Stage 5" → "05 - Negotiating $$ & Mutual Plan"
 * - "Stage 6" → "06 - Finalizing Closure"
 * - "Stage 7" → "07 - Pending"
 */
global with sharing class ANAgentOpenPipeAnalysisHandlerV6 {

    /**
     * @description Request DTO for Open Pipe Analysis V6
     * ALL fields use String type for flexible input (handler converts to proper types)
     */
    global class OpenPipeAnalysisRequest {
        
        @InvocableVariable(label='OU Name' description='Organizational Unit for territory filtering. Examples: "AMER ACC", "UKI", "EMEA", "APAC", "LATAM", "ANZ". Filters by OU_NAME__c field in Agent_Open_Pipe__c. Use for regional performance analysis and territory-specific bottleneck identification.' required=false)
        public String ouName;
        
        @InvocableVariable(label='Work Location Country' description='Geographic location filter. Examples: "United States", "United Kingdom", "Germany", "France", "Japan". Filters by WORK_LOCATION_COUNTRY__c field in Agent_Open_Pipe__c. V6 supports country aliases (e.g., "United States of America" → "United States"). Use exact country names for geographic performance patterns.' required=false)
        public String workLocationCountry;
        
        @InvocableVariable(label='Stage Filter' description='Pipeline stage filter using HUMAN-READABLE names. Examples: "Stage 2", "Stage 3", "Stage 4", "Stage 5", "Stage 6", "Stage 7". System maps to actual OPEN_PIPE_OPTY_STG_NM__c values. Use to identify bottlenecks and analyze stage-specific stagnation.' required=false)
        public String stageFilter;
        
        @InvocableVariable(label='Product Family' description='🧮 PRODUCT HIERARCHY - This filters by APM_L2 (L2 product category, ~100 categories). Fuzzy partial matching (LIKE %value%). Examples: "Tableau", "Agentforce", "Sales Cloud", "Data Cloud". System finds all variations automatically. L2 is recommended level for most analysis. Just pass the word user mentions.' required=false)
        public String productFamily;
        
        @InvocableVariable(label='AE Name' description='Account Executive name for filtering. Filters by FULL_NAME__c field in Agent_Open_Pipe__c. Use exact AE names for individual performance analysis and coaching needs identification.' required=false)
        public String aeName;
        
        @InvocableVariable(label='Industry' description='Industry filter. Filters by PRIMARY_INDUSTRY__c field in Agent_Open_Pipe__c. Real values: Manufacturing/Automotive/Energy, Financial Services, Technology, Healthcare/Life Sciences, Professional Services, Communications/Media, Engineering/Construction/Real Estate, High Tech, Education, Nonprofit, Agriculture/Mining, No Primary Industry, Other. Use exact punctuation.' required=false)
        public String industry;
        
        @InvocableVariable(label='Segment' description='Market segment. Filters by MACROSGMENT__c field in Agent_Open_Pipe__c. Real values: ENTR (Enterprise), CMRCL (Commercial), ESMB (SMB), PubSec (Public Sector), Unmapped. Case-sensitive. Used for deal band analysis.' required=false)
        public String segment;
        
        @InvocableVariable(label='Start Date' description='Filter by creation date from (YYYY-MM-DD). Filters by CreatedDate field in Agent_Open_Pipe__c. Examples: "2024-01-01", "2024-07-01", "2024-10-01". Must be ISO format for time-based analysis.' required=false)
        public String startDate;
        
        @InvocableVariable(label='End Date' description='Filter by close date to (YYYY-MM-DD). Filters by OPEN_PIPE_CLOSED_DATE__c field in Agent_Open_Pipe__c. Examples: "2024-03-31", "2024-06-30", "2024-12-31". Must be ISO format and >= startDate if both provided. 🎯 CONTEXT: This is the date AEs estimate the deal will close - critical for enablement quarterly planning and forecasting. Use for Q1/Q2/Q3/Q4 pipeline planning.' required=false)
        public String endDate;
        
        @InvocableVariable(label='Limit' description='📊 MAX RECORDS - Range: 1-50,000. Default: 50,000. ✅ FLEXIBLE: Accepts 50000 (number) OR "50000" (string). Examples: 50000, "50000", "1000", 5000. System auto-converts. V6 auto-enables summary mode for >10,000 records to prevent memory errors.' required=false)
        public String limitStr;
        
        @InvocableVariable(label='Summary Only' description='⚡ MODE SELECTION - ✅ FLEXIBLE: Accepts true (boolean) OR "true"/"yes"/"1" (string) for summary, false/"false"/"no"/"0" for detailed. Default: true. Use TRUE for aggregate questions ("which stages", "compare segments", "deal band analysis"). Use FALSE only for individual opportunity details. V6 auto-enables for large datasets.' required=false)
        public String summaryOnlyStr;
        
        @InvocableVariable(label='Include Opportunity Links' description='🔗 V6 NEW - Include Salesforce opportunity links in response. ✅ FLEXIBLE: Accepts true/"true"/"yes"/"1" for include, false/"false"/"no"/"0" for exclude. Default: false. Set TRUE when user needs direct links to opportunities (e.g., "show me the deals", "link to these opportunities"). Adds OPEN_PIPE_OPPORTUNITY_LINK__c field to JSON output.' required=false)
        public String includeOpportunityLinksStr;
        
        @InvocableVariable(label='Analysis Type Detail' description='Strategic focus guiding agent presentation. Examples: "pipeline stagnation", "product strategy", "Q4 closing strategy", "stage bottlenecks", "deal band analysis", "opportunity distribution by stage", "amount concentration by stage", "vertical performance", "segment pipeline health", "at-risk opportunities". Service returns all data, agent emphasizes relevant sections.' required=false)
        public String analysisTypeDetail;
        
        @InvocableVariable(label='Manager Email' description='📧 FILTER BY MANAGER - Provide manager EMAIL and system auto-searches ALL 12 management hierarchy levels (Emp_Mgt_Chain_Lvl_01_Nm__c through Emp_Mgt_Chain_Lvl_12_Nm__c in Learner_Profile__c). Examples: "sallen@salesforce.com", "mfitzgerald@salesforce.com". Finds ALL AEs where email appears at ANY level. ⚡ REPLACES ouName/workLocationCountry for manager-based filtering. ⚠️ Must be email format (user@salesforce.com), NOT name.' required=false)
        public String managerEmail;
    }

    /**
     * @description Response DTO for Open Pipe Analysis V6
     */
    global class OpenPipeAnalysisResponse {
        @InvocableVariable(label='Open Pipe Analysis Result' description='V6 JSON with summary aggregations and records. Returns 11 essential fields + optional opportunityLink: id, pipeType, learnerProfileId, amount (OPEN_PIPE_OPENPIPE_ALLOC_AMT__c), product{family (APM_L2), name (PROD_NM)}, industry, segment, vertical, stage, stageHuman, stagnationDays, aeScore (0-5 scale). AE Score 0-2=uncertain, 3=good, 4-5=excellent close rate correlation. Summary includes aggregations by product, industry, segment, stage with sum_amount, count, avg_stagnation, avg_ae_score. Used for deal band analysis (<50k|50-100k|100-150k|150k-500k|1M+).' required=true)
        public String result;

        public OpenPipeAnalysisResponse() {
            this.result = '';
        }
    }

    /**
     * @description Main invocable method - flexible input handling with auto-conversion
     * V6: Added includeOpportunityLinks support
     */
    @InvocableMethod(label='ANAGENT Open Pipeline Analysis V6' description='🎯 OPEN DEALS ANALYSIS V6 - Analyze current pipeline bottlenecks, stagnation, and deal bands. 📧 MANAGER: managerEmail="sallen@salesforce.com" (auto-searches ALL 12 levels). 🌍 TERRITORY: ouName="UKI" OR workLocationCountry="United States". 🔗 NEW: includeOpportunityLinks=true for direct links. ✅ FLEXIBLE INPUT: summaryOnly accepts true/"true"/"yes"/"1", limit accepts 50000/"50000". V6 IMPROVEMENTS: Country normalization (USA→US), auto query limit handling, AE Score 0-5 scale context, deal band support (<50k|50-100k|100-150k|150k-500k|1M+). Returns aggregations by product/segment/industry/stage.')
    global static List<OpenPipeAnalysisResponse> analyzeOpenPipe(List<OpenPipeAnalysisRequest> requests) {
        List<OpenPipeAnalysisResponse> responses = new List<OpenPipeAnalysisResponse>();

        if (requests == null || requests.isEmpty()) {
            OpenPipeAnalysisResponse errorResponse = new OpenPipeAnalysisResponse();
            errorResponse.result = buildError(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                'Request list is null or empty', 
                'requests', 
                'List<OpenPipeAnalysisRequest>', 'null or empty', 
                new List<String>{'Provide valid request object'},
                new List<String>{'Include at least one filter: ouName, workLocationCountry, or managerEmail'});
            responses.add(errorResponse);
            return responses;
        }

        for (OpenPipeAnalysisRequest request : requests) {
            OpenPipeAnalysisResponse response = new OpenPipeAnalysisResponse();
            
            // FLEXIBLE INPUT HANDLING: Convert string inputs to proper types
            Integer limitValue = null;
            Boolean summaryOnlyValue = null;
            Boolean includeOpportunityLinks = null;
            
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
            
            // Convert summaryOnly (string → boolean)
            if (String.isNotBlank(request.summaryOnlyStr)) {
                Object conversionResult = convertToBoolean(request.summaryOnlyStr, 'summaryOnly');
                if (conversionResult instanceof String) {
                    response.result = (String) conversionResult;
                    responses.add(response);
                    continue;
                }
                summaryOnlyValue = (Boolean) conversionResult;
            }
            
            // V6: Convert includeOpportunityLinks (string → boolean)
            if (String.isNotBlank(request.includeOpportunityLinksStr)) {
                Object conversionResult = convertToBoolean(request.includeOpportunityLinksStr, 'includeOpportunityLinks');
                if (conversionResult instanceof String) {
                    response.result = (String) conversionResult;
                    responses.add(response);
                    continue;
                }
                includeOpportunityLinks = (Boolean) conversionResult;
            }
            
            // Call V6 service with all parameters including includeOpportunityLinks
            response.result = ANAgentOpenPipeAnalysisServiceV6.analyzeOpenPipe(
                request, summaryOnlyValue, limitValue, includeOpportunityLinks);
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
                new List<String>{'50000', '"50000"', '1000', '"5000"', '10000'},
                new List<String>{
                    'Use a number between 1 and 50,000',
                    'Examples: ' + fieldName + '=50000 OR ' + fieldName + '="50000"',
                    'Default is 50,000 if not specified'
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
     * @description Builds standardized error response using AgentCore pattern
     */
    private static String buildError(String code, String message, String field, 
                                     String expected, String received,
                                     List<String> samples, List<String> nextSteps) {
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
                    'correct_examples' => samples,
                    'agent_next_steps' => nextSteps
                }
            }
        };
        return JSON.serialize(error);
    }
}
