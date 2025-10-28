/**
 * @description Open Pipe Analysis Handler V5 - Clean implementation with flexible input handling
 * @author Sales Operations Team
 * @version 5.0
 * @date 2025-10-27
 * 
 * IMPROVEMENTS FROM V4:
 * - Accepts both string and proper types for all Boolean/Integer fields (no type mismatch errors!)
 * - No deprecated "Input" suffix fields (cleaner API)
 * - Enhanced exception handling with clear agent guidance
 * - Consistent field names matching Agent_Open_Pipe__c object
 * - No schema.json enforcement (auto-discovery mode)
 * 
 * PURPOSE: Analyze what's happening RIGHT NOW in the sales pipeline
 * - Which products are underperforming
 * - Which verticals/segments have issues
 * - Where deals are stagnating (high days in stage)
 * - Which stages have the biggest bottlenecks
 * 
 * STAGE MAPPING (Human Names → Actual Field Values):
 * - "Stage 2" → "02 - Determining Problem, Impact, Ideal"
 * - "Stage 3" → "03 - Validating Benefits & Value"
 * - "Stage 4" → "04 - Confirming Value With Power"
 * - "Stage 5" → "05 - Negotiating $$ & Mutual Plan"
 * - "Stage 6" → "06 - Finalizing Closure"
 * - "Stage 7" → "07 - Pending"
 */
global with sharing class ANAgentOpenPipeAnalysisHandlerV5 {

    /**
     * @description Request DTO for Open Pipe Analysis V5
     * ALL fields use String type for flexible input (handler converts to proper types)
     */
    global class OpenPipeAnalysisRequest {
        
        @InvocableVariable(label='OU Name' description='Organizational Unit for territory filtering. Examples: "AMER ACC", "UKI", "EMEA", "APAC", "LATAM", "ANZ". Filters by OU_NAME__c field in Agent_Open_Pipe__c. Use for regional performance analysis and territory-specific bottleneck identification.' required=false)
        public String ouName;
        
        @InvocableVariable(label='Work Location Country' description='Geographic location filter. Examples: "United States", "United Kingdom", "Germany", "France", "Japan". Filters by WORK_LOCATION_COUNTRY__c field in Agent_Open_Pipe__c. Use exact country names for geographic performance patterns and location-specific challenges.' required=false)
        public String workLocationCountry;
        
        @InvocableVariable(label='Stage Filter' description='Pipeline stage filter using HUMAN-READABLE names. Examples: "Stage 2", "Stage 3", "Stage 4", "Stage 5", "Stage 6", "Stage 7". System maps to actual OPEN_PIPE_OPTY_STG_NM__c values. Use to identify bottlenecks and analyze stage-specific stagnation.' required=false)
        public String stageFilter;
        
        @InvocableVariable(label='Product Family' description='🔍 PRODUCT FILTER - Fuzzy partial matching (LIKE %value%). Filters by OPEN_PIPE_PROD_NM__c and OPEN_PIPE_APM_L2__c fields. Examples: "Tableau", "Agentforce", "Sales Cloud", "Data Cloud". System finds all variations automatically. Just pass the word user mentions - DO NOT specify editions.' required=false)
        public String productFamily;
        
        @InvocableVariable(label='AE Name' description='Account Executive name for filtering. Filters by FULL_NAME__c field in Agent_Open_Pipe__c. Use exact AE names for individual performance analysis and coaching needs identification.' required=false)
        public String aeName;
        
        @InvocableVariable(label='Industry' description='Industry filter. Filters by PRIMARY_INDUSTRY__c field in Agent_Open_Pipe__c. Real values: Manufacturing/Automotive/Energy, Financial Services, Technology, Healthcare/Life Sciences, Professional Services, Communications/Media, Engineering/Construction/Real Estate, High Tech, Education, Nonprofit, Agriculture/Mining, No Primary Industry, Other. Use exact punctuation.' required=false)
        public String industry;
        
        @InvocableVariable(label='Segment' description='Market segment. Filters by MACROSGMENT__c field in Agent_Open_Pipe__c. Real values: ENTR (Enterprise), CMRCL (Commercial), ESMB (SMB), PubSec (Public Sector), Unmapped. Case-sensitive.' required=false)
        public String segment;
        
        @InvocableVariable(label='Start Date' description='Filter by creation date from (YYYY-MM-DD). Filters by CreatedDate field in Agent_Open_Pipe__c. Examples: "2024-01-01", "2024-07-01", "2024-10-01". Must be ISO format for time-based analysis.' required=false)
        public String startDate;
        
        @InvocableVariable(label='End Date' description='Filter by creation date to (YYYY-MM-DD). Filters by CreatedDate field in Agent_Open_Pipe__c. Examples: "2024-03-31", "2024-06-30", "2024-12-31". Must be ISO format and >= startDate if both provided.' required=false)
        public String endDate;
        
        @InvocableVariable(label='Limit' description='📊 MAX RECORDS - Range: 1-50,000. Default: 40,000. ✅ FLEXIBLE: Accepts 40000 (number) OR "40000" (string). Examples: 40000, "40000", "1000", 5000. System auto-converts. Controls max records returned for detailed analysis.' required=false)
        public String limitStr;
        
        @InvocableVariable(label='Summary Only' description='⚡ MODE SELECTION - ✅ FLEXIBLE: Accepts true (boolean) OR "true"/"yes"/"1" (string) for summary, false/"false"/"no"/"0" for detailed. Default: true. Use TRUE for aggregate questions ("which stages", "compare segments"). Use FALSE only for individual opportunity details. System auto-converts all formats.' required=false)
        public String summaryOnlyStr;
        
        @InvocableVariable(label='Analysis Type Detail' description='Strategic focus guiding agent presentation. Examples: "pipeline stagnation", "product strategy", "Q4 closing strategy", "stage bottlenecks", "opportunity distribution by stage", "amount concentration by stage", "vertical performance", "segment pipeline health", "at-risk opportunities". Service returns all data, agent emphasizes relevant sections.' required=false)
        public String analysisTypeDetail;
        
        @InvocableVariable(label='Manager Email' description='📧 FILTER BY MANAGER - Provide manager EMAIL and system auto-searches ALL 12 management hierarchy levels (Emp_Mgt_Chain_Lvl_01_Nm__c through Emp_Mgt_Chain_Lvl_12_Nm__c in Learner_Profile__c). Examples: "sallen@salesforce.com", "mfitzgerald@salesforce.com". Finds ALL AEs where email appears at ANY level. ⚡ REPLACES ouName/workLocationCountry for manager-based filtering. ⚠️ Must be email format (user@salesforce.com), NOT name.' required=false)
        public String managerEmail;
    }

    /**
     * @description Response DTO for Open Pipe Analysis V5
     */
    global class OpenPipeAnalysisResponse {
        @InvocableVariable(label='Open Pipe Analysis Result' description='JSON with summary aggregations and records. Returns 11 essential fields: id, pipeType, learnerProfileId, amount, product{family,name}, industry, segment, vertical, stage, stageHuman, stagnationDays, aeScore. aeScore is CRITICAL (0-10 scale, higher=more confident). Low scores (0-3)=uncertain, high scores (7-10)=confident. Summary includes aggregations by product, industry, segment, stage with sum_amount, count, avg_stagnation, avg_ae_score.' required=true)
        public String result;

        public OpenPipeAnalysisResponse() {
            this.result = '';
        }
    }

    /**
     * @description Main invocable method - flexible input handling with auto-conversion
     * Accepts BOTH string and proper types for all Boolean/Integer fields
     */
    @InvocableMethod(label='ANAGENT Open Pipeline Analysis V5' description='🎯 OPEN DEALS ANALYSIS V5 - Analyze current pipeline bottlenecks and stagnation. 📧 MANAGER: managerEmail="sallen@salesforce.com" (auto-searches ALL 12 levels). 🌍 TERRITORY: ouName="UKI" OR workLocationCountry="United States". ✅ FLEXIBLE INPUT: summaryOnly accepts true/"true"/"yes"/"1", limit accepts 40000/"40000". Examples: {"ouName":"UKI","summaryOnly":"true","limit":"40000"} OR {"ouName":"UKI","summaryOnly":true,"limit":40000}. Both work! Returns aggregations by product/segment/industry/stage. Use summaryOnly=true for aggregate questions.')
    global static List<OpenPipeAnalysisResponse> analyzeOpenPipe(List<OpenPipeAnalysisRequest> requests) {
        List<OpenPipeAnalysisResponse> responses = new List<OpenPipeAnalysisResponse>();

        if (requests == null || requests.isEmpty()) {
            OpenPipeAnalysisResponse errorResponse = new OpenPipeAnalysisResponse();
            errorResponse.result = buildError('INVALID_INPUT', 'Request list is null or empty', 'requests', 
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
            
            // Convert limit (string → integer)
            if (String.isNotBlank(request.limitStr)) {
                Object conversionResult = convertToInteger(request.limitStr, 'limit');
                if (conversionResult instanceof String) {
                    // Error occurred
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
                    // Error occurred
                    response.result = (String) conversionResult;
                    responses.add(response);
                    continue;
                }
                summaryOnlyValue = (Boolean) conversionResult;
            }
            
            // Call service with normalized values
            response.result = ANAgentOpenPipeAnalysisServiceV5.analyzeOpenPipe(request, summaryOnlyValue, limitValue);
            responses.add(response);
        }

        return responses;
    }
    
    /**
     * @description Converts string to Integer with validation
     * Accepts: 40000, "40000", "1000", etc.
     */
    private static Object convertToInteger(String input, String fieldName) {
        if (String.isBlank(input)) {
            return null;
        }
        
        try {
            return Integer.valueOf(input.trim());
        } catch (Exception e) {
            return buildError('INVALID_INPUT', 
                'Cannot convert ' + fieldName + ' to Integer: received "' + input + '"',
                fieldName, 'Integer', input,
                new List<String>{'40000', '"40000"', '1000', '"5000"', '10000'},
                new List<String>{
                    'Use a number between 1 and 50,000',
                    'Examples: ' + fieldName + '=40000 OR ' + fieldName + '="40000"',
                    'Default is 40,000 if not specified'
                });
        }
    }
    
    /**
     * @description Converts string to Boolean with flexible format support
     * Accepts: true, "true", "TRUE", "yes", "1", false, "false", "no", "0"
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
        return buildError('INVALID_INPUT',
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
     * @description Builds standardized error response with agent guidance
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

