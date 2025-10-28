/**
 * @description Future Pipe Analysis Handler V5 - Clean implementation with flexible input handling
 * @author Sales Operations Team
 * @version 5.0
 * @date 2025-10-27
 * 
 * IMPROVEMENTS FROM V4:
 * - Accepts both string and proper types for all Boolean/Integer fields (no type mismatch errors!)
 * - No deprecated alias fields (cleaner API)
 * - Enhanced exception handling with clear agent guidance
 * - Consistent field names matching Agent_Renewals__c, Agent_Cross_Sell__c, Agent_Upsell__c objects
 * - No schema.json enforcement (auto-discovery mode)
 * 
 * PURPOSE: Analyze future pipeline opportunities for proactive planning
 * - RENEWALS: Upcoming renewal opportunities with projected revenue (retention risk & revenue forecasting)
 * - CROSS_SELL: Opportunities to sell additional products to existing customers (product expansion)
 * - UPSELL: Opportunities to expand existing product usage (growth within current products)
 * 
 * KEY FEATURES:
 * - Automatic aggregation by industry, segment, product, country (no groupBy needed!)
 * - Manager chain filtering across all 12 hierarchy levels
 * - Territory filtering (OU or Country)
 * - Returns 8 essential fields per record: id, pipeType, learnerProfileId, amount, product, industry, segment, vertical
 */
global with sharing class ABAgentFuturePipeAnalysisHandlerV5 {

    /**
     * @description Request DTO for Future Pipe Analysis V5
     * ALL flexible fields use String type for flexible input (handler converts to proper types)
     */
    global class FuturePipeAnalysisRequest {
        
        @InvocableVariable(label='Analysis Type (REQUIRED)' description='🎯 REQUIRED - Type of future pipeline: "RENEWALS" (upcoming renewal opportunities with $ revenue), "CROSS_SELL" (additional product opportunities - count only), or "UPSELL" (usage expansion opportunities - count only). Filters which object to query: Agent_Renewals__c, Agent_Cross_Sell__c, or Agent_Upsell__c. ⚡ RENEWALS has amounts ($USD), CROSS_SELL/UPSELL do not. 🔄 AGGREGATION IS AUTOMATIC by industry, segment, product, country - no groupBy needed!' required=true)
        public String analysisType;
        
        @InvocableVariable(label='OU Name' description='Organizational Unit for territory filtering. Examples: "AMER ACC", "UKI", "EMEA", "APAC", "LATAM", "ANZ". Filters by OU_NAME__c field in Agent_Renewals__c/Cross_Sell__c/Upsell__c. Use for regional performance analysis.' required=false)
        public String ouName;
        
        @InvocableVariable(label='Work Location Country' description='Geographic location filter. Examples: "United States", "United Kingdom", "Germany", "France", "Japan". Filters by WORK_LOCATION_COUNTRY__c field. Use exact country names for geographic performance patterns.' required=false)
        public String workLocationCountry;
        
        @InvocableVariable(label='AE Name' description='Account Executive name for filtering. Filters by FULL_NAME__c field in Agent_Renewals__c/Cross_Sell__c/Upsell__c. Use exact AE names for individual performance analysis.' required=false)
        public String aeName;
        
        @InvocableVariable(label='Industry' description='Industry filter. Filters by PRIMARY_INDUSTRY__c field. Real values: Manufacturing/Automotive/Energy, Financial Services, Technology, Healthcare/Life Sciences, Professional Services, Communications/Media, Engineering/Construction/Real Estate, High Tech, Education, Nonprofit, Agriculture/Mining, No Primary Industry, Other. Use exact punctuation.' required=false)
        public String aeIndustry;
        
        @InvocableVariable(label='Segment' description='Market segment. Filters by MACROSGMENT__c field. Real values: ENTR (Enterprise), CMRCL (Commercial), ESMB (SMB), PubSec (Public Sector), Unmapped. Case-sensitive.' required=false)
        public String aeMacroSegment;
        
        @InvocableVariable(label='Manager Name' description='Manager name filter. Filters by EMP_MGR_NM__c field (direct manager only). Use exact manager name. For broader hierarchy filtering, use managerEmail instead.' required=false)
        public String aeManagerName;
        
        @InvocableVariable(label='Start Date' description='Filter by creation date from (YYYY-MM-DD). Filters by CreatedDate field. Examples: "2024-01-01", "2024-07-01", "2024-10-01". Must be ISO format for time-based analysis.' required=false)
        public String startDate;
        
        @InvocableVariable(label='End Date' description='Filter by creation date to (YYYY-MM-DD). Filters by CreatedDate field. Examples: "2024-03-31", "2024-06-30", "2024-12-31". Must be ISO format and >= startDate if both provided.' required=false)
        public String endDate;
        
        @InvocableVariable(label='Limit' description='📊 MAX RECORDS - Range: 1-50,000. Default: 20,000. ✅ FLEXIBLE: Accepts 20000 (number) OR "20000" (string). Examples: 20000, "20000", "1000", 5000. System auto-converts. Controls max records returned for detailed analysis.' required=false)
        public String limitStr;
        
        @InvocableVariable(label='Summary Only' description='⚡ MODE SELECTION - ✅ FLEXIBLE: Accepts true (boolean) OR "true"/"yes"/"1" (string) for summary, false/"false"/"no"/"0" for detailed. Default: false. Use TRUE for aggregate questions ("which products", "compare segments"). Use FALSE for detailed revenue breakdown. System auto-converts all formats.' required=false)
        public String summaryOnlyStr;
        
        @InvocableVariable(label='Manager Email' description='📧 FILTER BY MANAGER - Provide manager EMAIL and system auto-searches ALL 12 management hierarchy levels (Emp_Mgt_Chain_Lvl_01_Nm__c through Emp_Mgt_Chain_Lvl_12_Nm__c in Learner_Profile__c). Examples: "sallen@salesforce.com", "mfitzgerald@salesforce.com". Finds ALL AEs where email appears at ANY level. ⚡ REPLACES ouName/workLocationCountry for manager-based filtering. ⚠️ Must be email format (user@salesforce.com), NOT name.' required=false)
        public String managerEmail;
    }

    /**
     * @description Response DTO for Future Pipe Analysis V5
     */
    global class FuturePipeAnalysisResponse {
        @InvocableVariable(label='Future Pipe Analysis Result' description='JSON with summary aggregations and records. Returns 8 essential fields: id, pipeType (RENEWALS/CROSS_SELL/UPSELL), learnerProfileId, amount (only RENEWALS has $, others null), product{family,name,sku}, industry, segment, vertical. Summary includes automatic aggregations by product, industry, segment, country with sum_amount (RENEWALS only), count, avg metrics. CROSS_SELL/UPSELL show counts only (no amounts in schema).' required=true)
        public String result;

        public FuturePipeAnalysisResponse() {
            this.result = '';
        }
    }

    /**
     * @description Main invocable method - flexible input handling with auto-conversion
     * Accepts BOTH string and proper types for all Boolean/Integer fields
     */
    @InvocableMethod(label='ABAGENT Future Pipeline Analysis V5' description='🎯 FUTURE DEALS ANALYSIS V5 - Analyze RENEWALS/CROSS_SELL/UPSELL opportunities. 📧 MANAGER: managerEmail="sallen@salesforce.com" (auto-searches ALL 12 levels). 🌍 TERRITORY: ouName="UKI" OR workLocationCountry="United States". 🎯 REQUIRED: analysisType="RENEWALS"|"CROSS_SELL"|"UPSELL". ✅ FLEXIBLE INPUT: summaryOnly accepts true/"true"/"yes"/"1", limit accepts 20000/"20000". Examples: {"analysisType":"RENEWALS","ouName":"UKI","summaryOnly":"true","limit":"20000"} OR {"analysisType":"RENEWALS","ouName":"UKI","summaryOnly":true,"limit":20000}. Both work! Returns aggregations by product/segment/industry/country. 💰 RENEWALS has $amounts, CROSS_SELL/UPSELL are counts only.')
    global static List<FuturePipeAnalysisResponse> analyzeFuturePipe(List<FuturePipeAnalysisRequest> requests) {
        List<FuturePipeAnalysisResponse> responses = new List<FuturePipeAnalysisResponse>();

        if (requests == null || requests.isEmpty()) {
            FuturePipeAnalysisResponse errorResponse = new FuturePipeAnalysisResponse();
            errorResponse.result = buildError('INVALID_INPUT', 'Request list is null or empty', 'requests', 
                'List<FuturePipeAnalysisRequest>', 'null or empty', 
                new List<String>{'Provide valid request object'},
                new List<String>{'Include analysisType and at least one filter: ouName, workLocationCountry, or managerEmail'});
            responses.add(errorResponse);
            return responses;
        }

        for (FuturePipeAnalysisRequest request : requests) {
            FuturePipeAnalysisResponse response = new FuturePipeAnalysisResponse();
            
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
            response.result = ABAgentFuturePipeAnalysisServiceV5.analyzeFuturePipe(request, summaryOnlyValue, limitValue);
            responses.add(response);
        }

        return responses;
    }
    
    /**
     * @description Converts string to Integer with validation
     * Accepts: 20000, "20000", "1000", etc.
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
                new List<String>{'20000', '"20000"', '1000', '"5000"', '10000'},
                new List<String>{
                    'Use a number between 1 and 50,000',
                    'Examples: ' + fieldName + '=20000 OR ' + fieldName + '="20000"',
                    'Default is 20,000 if not specified'
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

