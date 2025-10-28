/**
 * @description SME Search Handler V5 - Clean implementation with flexible input handling
 * @author Sales Operations Team
 * @version 5.0
 * @date 2025-10-27
 * 
 * IMPROVEMENTS FROM V4:
 * - Accepts both string and proper types for all Boolean/Integer fields (no type mismatch errors!)
 * - No deprecated alias fields (cleaner API)
 * - Enhanced exception handling with clear agent guidance
 * - Consistent field names matching AGENT_SME_ACADEMIES__c and Learner_Profile__c objects
 * - No schema.json enforcement (auto-discovery mode)
 * - Simplified manager chain filtering (single field instead of 5)
 * 
 * PURPOSE: Find Subject Matter Experts (SMEs) based on product expertise, location, and organizational attributes
 * - Searches AGENT_SME_ACADEMIES__c for product expertise
 * - Enriches with Learner_Profile__c data (OU, country, segment, industry, tenure, manager chain)
 * - Filters by academy membership, tenure, leave status, management chain
 * - Returns ranked results by relevance score, AE rank, and total ACV
 * 
 * KEY FEATURES:
 * - Product expertise search (PRODUCT_L2__c, PRODUCT_L3__c)
 * - Name-based search (SME names)
 * - Academy member filtering (ACADEMIES_MEMBER__c)
 * - Tenure filtering (Employee_Tenure__c in days)
 * - Leave status filtering (On_Leave__c)
 * - Manager chain filtering across all 12 levels (Emp_Mgt_Chain_Lvl_XX_Nm__c)
 * - Relevance scoring and ranking
 */
global with sharing class ANAgentSMESearchHandlerV5 {
    
    /**
     * @description Request DTO for SME Search V5
     * Uses String type for flexible Boolean/Integer fields
     */
    global class SMESearchRequest {
        
        @InvocableVariable(label='Search Term' description='Product name or SME name. Searches PRODUCT_L2__c, PRODUCT_L3__c (product mode) or Name field (name mode) in AGENT_SME_ACADEMIES__c. Examples: "Sales Cloud", "Agentforce", "Data Cloud", "John Smith". Min 2 characters. Use for finding SMEs by product expertise or person name.' required=true)
        public String searchTerm;
        
        @InvocableVariable(label='Search Type' description='Search scope. Valid values: "Product" (searches PRODUCT_L2__c, PRODUCT_L3__c in AGENT_SME_ACADEMIES__c - use for expertise), "Name" (searches Name field - use for person names), "All" (searches all fields - default). Case-sensitive.' required=false)
        public String searchType;
        
        @InvocableVariable(label='Limit' description='📊 MAX RESULTS - Range: 1-200. Default: 20. ✅ FLEXIBLE: Accepts 20 (number) OR "20" (string). Examples: 20, "20", "50", 100. Controls max SMEs returned. System auto-converts and ranks by relevance.' required=false)
        public String limitStr;
        
        @InvocableVariable(label='Academy Members Only' description='⚡ FILTER - ✅ FLEXIBLE: Accepts true/"true"/"yes"/"1" for academy only, false/"false"/"no"/"0" for all. Default: false. Filters by ACADEMIES_MEMBER__c field in AGENT_SME_ACADEMIES__c. Academy members are top-performing SMEs with specialized training.' required=false)
        public String academyMembersOnlyStr;
        
        @InvocableVariable(label='OU Name' description='Organizational Unit filter (partial match). Filters by OU_Name__c in Learner_Profile__c. Examples: "AMER ACC", "UKI", "EMEA", "APAC". Use "AMER" to match all Americas OUs. Case-insensitive.' required=false)
        public String ouName;
        
        @InvocableVariable(label='Work Country' description='Work location filter (partial match). Filters by Work_Location_Country__c in Learner_Profile__c. Examples: "United States of America", "United Kingdom", "Germany". Case-insensitive.' required=false)
        public String workCountry;
        
        @InvocableVariable(label='Industry' description='Industry filter (partial match). Filters by em_Industry__c in Learner_Profile__c. Examples: "Technology", "Finance", "Healthcare", "Retail". Case-insensitive.' required=false)
        public String industry;
        
        @InvocableVariable(label='Vertical' description='Market segment filter (partial match). Filters by Macro_Segment__c in Learner_Profile__c. Valid values: "ENTR" (Enterprise), "CMRCL" (Commercial), "ESMB" (SMB), "PubSec" (Public Sector). Case-insensitive.' required=false)
        public String vertical;
        
        @InvocableVariable(label='Min Tenure Days' description='📅 TENURE FILTER - Min employee tenure in days. ✅ FLEXIBLE: Accepts 365 (number) OR "365" (string). Examples: 365 (1 year), "1095" (3 years), 730 (2 years). Filters by Employee_Tenure__c in Learner_Profile__c. Higher tenure = deeper expertise.' required=false)
        public String minTenureDaysStr;
        
        @InvocableVariable(label='Manager Email' description='📧 FILTER BY MANAGER - Provide manager EMAIL and system auto-searches ALL 12 management hierarchy levels (Emp_Mgt_Chain_Lvl_01_Nm__c through Emp_Mgt_Chain_Lvl_12_Nm__c in Learner_Profile__c). Examples: "sallen@salesforce.com", "mfitzgerald@salesforce.com". Finds ALL SMEs where email appears at ANY level. ⚠️ Must be email format (user@salesforce.com), NOT name.' required=false)
        public String managerEmail;
        
        @InvocableVariable(label='Include On Leave' description='⚡ LEAVE FILTER - ✅ FLEXIBLE: Accepts true/"true"/"yes"/"1" to include on-leave, false/"false"/"no"/"0" to exclude. Default: true. Filters by On_Leave__c in Learner_Profile__c. Use FALSE to exclude SMEs currently on leave.' required=false)
        public String includeOnLeaveStr;
        
        @InvocableVariable(label='Summary Only' description='⚡ MODE - ✅ FLEXIBLE: Accepts true/"true"/"yes"/"1" for summary, false/"false"/"no"/"0" for detailed. Default: false. Use TRUE for count/summary only, FALSE for full SME details with Learner Profile data.' required=false)
        public String summaryOnlyStr;
    }

    /**
     * @description Response DTO for SME Search V5
     */
    global class SMESearchResponse {
        @InvocableVariable(label='SME Search Result' description='JSON with SMEs from AGENT_SME_ACADEMIES__c enriched with Learner_Profile__c data. Includes: id, name, learnerProfileId, learnerProfileName, productL2, productL3, aeRank, totalACV, isAcademyMember, organizationalUnit, workCountry, macroSegment, industry, tenureDays, hireDate, isOnLeave, managerL1-L5 emails, relevanceScore, scoringRationale. Summary mode: totalSMEs, avgAERank, avgTenure, topProducts. Results ranked by relevance, then AE rank, then total ACV.' required=true)
        public String result;

        public SMESearchResponse() {
            this.result = '';
        }
    }

    /**
     * @description Main invocable method - flexible input handling with auto-conversion
     */
    @InvocableMethod(label='SearchSMEsV5' description='🎯 SME DISCOVERY V5 - Find Subject Matter Experts from AGENT_SME_ACADEMIES__c enriched with Learner_Profile__c. 🔍 REQUIRED: searchTerm="Sales Cloud"|"John Smith". 📧 MANAGER: managerEmail="sallen@salesforce.com" (auto-searches ALL 12 levels). ✅ FLEXIBLE INPUT: academyMembersOnly accepts true/"true"/"yes"/"1", limit accepts 20/"20", includeOnLeave accepts true/"true". Examples: {"searchTerm":"Agentforce","searchType":"Product","limit":"50","academyMembersOnly":"true"} OR {"searchTerm":"Agentforce","searchType":"Product","limit":50,"academyMembersOnly":true}. Both work! Returns ranked SMEs with expertise, tenure, location, manager chain.')
    global static List<SMESearchResponse> searchSMEs(List<SMESearchRequest> requests) {
        List<SMESearchResponse> responses = new List<SMESearchResponse>();

        if (requests == null || requests.isEmpty()) {
            SMESearchResponse errorResponse = new SMESearchResponse();
            errorResponse.result = buildError('INVALID_INPUT', 'Request list is null or empty', 'requests', 
                'List<SMESearchRequest>', 'null or empty', 
                new List<String>{'Provide valid request object'},
                new List<String>{'Include searchTerm (required)'});
            responses.add(errorResponse);
            return responses;
        }

        for (SMESearchRequest request : requests) {
            SMESearchResponse response = new SMESearchResponse();
            
            // FLEXIBLE INPUT HANDLING: Convert string inputs to proper types
            Integer limitValue = null;
            Boolean academyMembersOnly = null;
            Integer minTenureDays = null;
            Boolean includeOnLeave = null;
            Boolean summaryOnly = null;
            
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
            
            // Convert minTenureDays (string → integer)
            if (String.isNotBlank(request.minTenureDaysStr)) {
                Object conversionResult = convertToInteger(request.minTenureDaysStr, 'minTenureDays');
                if (conversionResult instanceof String) {
                    response.result = (String) conversionResult;
                    responses.add(response);
                    continue;
                }
                minTenureDays = (Integer) conversionResult;
            }
            
            // Convert academyMembersOnly (string → boolean)
            if (String.isNotBlank(request.academyMembersOnlyStr)) {
                Object conversionResult = convertToBoolean(request.academyMembersOnlyStr, 'academyMembersOnly');
                if (conversionResult instanceof String) {
                    response.result = (String) conversionResult;
                    responses.add(response);
                    continue;
                }
                academyMembersOnly = (Boolean) conversionResult;
            }
            
            // Convert includeOnLeave (string → boolean)
            if (String.isNotBlank(request.includeOnLeaveStr)) {
                Object conversionResult = convertToBoolean(request.includeOnLeaveStr, 'includeOnLeave');
                if (conversionResult instanceof String) {
                    response.result = (String) conversionResult;
                    responses.add(response);
                    continue;
                }
                includeOnLeave = (Boolean) conversionResult;
            }
            
            // Convert summaryOnly (string → boolean)
            if (String.isNotBlank(request.summaryOnlyStr)) {
                Object conversionResult = convertToBoolean(request.summaryOnlyStr, 'summaryOnly');
                if (conversionResult instanceof String) {
                    response.result = (String) conversionResult;
                    responses.add(response);
                    continue;
                }
                summaryOnly = (Boolean) conversionResult;
            }
            
            // Call service with normalized values
            response.result = ANAgentSMESearchServiceV5.searchSMEs(request, limitValue, academyMembersOnly, minTenureDays, includeOnLeave, summaryOnly);
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
            return buildError('INVALID_INPUT', 
                'Cannot convert ' + fieldName + ' to Integer: received "' + input + '"',
                fieldName, 'Integer', input,
                new List<String>{'20', '"20"', '50', '"100"', '365', '"1095"'},
                new List<String>{
                    'Use a number',
                    'For limit: between 1 and 200 (default 20)',
                    'For minTenureDays: number of days (e.g., 365 for 1 year)',
                    'Examples: ' + fieldName + '=20 OR ' + fieldName + '="20"'
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

