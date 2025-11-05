/**
 * @description KPI Analysis Handler V7 - AgentCore integrated with memory optimization
 * @author Sales Operations Team
 * @version 7.0
 * @date 2025-11-04
 * 
 * CRITICAL IMPROVEMENTS FROM V6:
 * - AgentCore Constants integration for standardized error codes
 * - AgentCore Exception integration for typed errors
 * - Calls V7 service with memory optimization (fixes 18.9% memory errors from V6)
 * - Professional error messages (no formatting - agent controls that)
 * - Enhanced field descriptions using "Examples:" not "Valid values:"
 * 
 * PURPOSE: Analyze Account Executive KPI performance across multiple time windows
 * - Current Quarter vs Previous Quarter metrics
 * - Current Fiscal Year vs Previous Fiscal Year metrics
 * - Current Month vs Same Month Last Year metrics
 * - Identify growth factors (DEFINITION__c) and performance trends
 * - Provide actionable insights and outlier detection
 * 
 * V7 MEMORY OPTIMIZATION:
 * - Service uses two-tier query strategy (aggregation for large datasets)
 * - Prevents V6 memory errors that occurred with 8,112+ records
 * - Pre-calculates QoQ%, YoY%, MoM% changes in service layer
 * 
 * KEY CONCEPTS:
 * - DEFINITION__c: Also known as "Growth Factor" - the KPI metric name (e.g., "Coverage", "Pipeline Generation")
 * - DESCRIPTION__c: Explains what each growth factor means and why it matters
 * - Each record represents ONE KPI for ONE AE
 * - Same AE will have multiple records (one per KPI being tracked)
 * 
 * RAMP STATUS VALUES (4 distinct values):
 * - "Fast Ramper" - AE exceeding ramp expectations
 * - "Slow Ramper" - AE below ramp expectations
 * - "On Track" - AE meeting ramp expectations
 * - "Not Ramping" - AE not in ramp period
 */
global with sharing class ANAgentKPIAnalysisHandlerV7 {

    /**
     * @description Request DTO for KPI Analysis V7
     * ALL fields use String type for flexible input (handler converts to proper types)
     */
    global class KPIAnalysisRequest {
        
        @InvocableVariable(label='OU Name' description='🏢 TERRITORY FILTER - Operating Unit for territory filtering. Examples: "AMER ACC", "UKI", "EMEA", "APAC", "LATAM", "ANZ", "SMB - AMER SMB". Filters by OU_NAME__c field in AGENT_OU_PIPELINE_V3__c. Use for regional performance analysis. Valid values: AMER ACC (1,462), SMB - AMER SMB (3,370), North Asia (1,499), AMER REG, AMER ICE, UKI, EMEA North, EMEA Central, EMEA South, LATAM, ANZ, Japan, South Asia - India, South Asia - ASEAN, France, PubSec+.Org, NextGen Platform, SMB - EBOU, Unmapped, OU Not Specified.' required=false)
        public String ouName;
        
        @InvocableVariable(label='Work Location Country' description='🌍 GEOGRAPHIC FILTER - Geographic location filter for AE work location. Examples: "United States", "United Kingdom", "Germany", "France", "Japan", "India", "Canada", "Australia". Filters by WORK_LOCATION_COUNTRY__c field in AGENT_OU_PIPELINE_V3__c. Use exact country names for location-specific KPI analysis.' required=false)
        public String workLocationCountry;
        
        @InvocableVariable(label='Management Chain Email' description='📧 MANAGER FILTER - Provide manager EMAIL and system auto-searches ALL 12 management hierarchy levels (Emp_Mgt_Chain_Lvl_01_Nm__c through Emp_Mgt_Chain_Lvl_12_Nm__c in Learner_Profile__c). Examples: "sallen@salesforce.com", "mfitzgerald@salesforce.com". Finds ALL AEs where email appears at ANY level in management chain. ⚡ REPLACES ouName/workLocationCountry for manager-based filtering. ⚠️ Must be email format (user@salesforce.com), NOT name.' required=false)
        public String managementChainEmail;
        
        @InvocableVariable(label='KPI Definition Filter' description='🎯 GROWTH FACTOR FILTER - Also known as "Growth Factor". Filters by DEFINITION__c field. Examples: "Coverage", "Pipeline Generation", "Deal Size", "Early-Stage Pipeline Percentage", "Total Sales Interactions", "Create & Close ACV", "Sales Play Win Percentage". Use exact KPI names for specific metric analysis. 48 total KPI types available. Common question: "Show me growth factors for this OU/segment/industry/management chain".' required=false)
        public String kpiDefinition;
        
        @InvocableVariable(label='Industry' description='🏭 INDUSTRY FILTER - Filters by PRIMARY_INDUSTRY__c field in AGENT_OU_PIPELINE_V3__c. Valid values: Financial Services (2,477), Technology (1,895), Manufacturing/Automotive/Energy (2,636), Healthcare/Life Sciences, Professional Services, Communications/Media, Engineering/Construction/Real Estate, High Tech, Education, Nonprofit, Agriculture/Mining, No Primary Industry, Other. Use exact punctuation and capitalization.' required=false)
        public String industry;
        
        @InvocableVariable(label='Segment' description='📊 SEGMENT FILTER - Market segment filter. Filters by MACROSGMENT__c field in AGENT_OU_PIPELINE_V3__c. Valid values: ENTR (Enterprise), CMRCL (Commercial), ESMB (SMB), PubSec (Public Sector), Unmapped. Case-sensitive. Note: MACROSGMENT__c currently has 0% coverage but field exists for future use.' required=false)
        public String segment;
        
        @InvocableVariable(label='AE Name' description='👤 AE FILTER - Account Executive full name for individual performance analysis. Filters by FULL_NAME__c field in AGENT_OU_PIPELINE_V3__c. Examples: "Sam Katsin", "John Smith". Use exact full name for targeted coaching insights.' required=false)
        public String aeName;
        
        @InvocableVariable(label='Ramp Status' description='🚀 RAMP FILTER - Onboarding/ramp status filter. Filters by RAMP_STATUS__c field. Valid values: "Fast Ramper" (235 records), "Slow Ramper" (286 records), "On Track" (168 records), "Not Ramping" (109 records). Use exact case. ~4% of records have ramp status (802 of 21,837). Use to identify AEs needing additional support or those excelling during ramp.' required=false)
        public String rampStatus;
        
        @InvocableVariable(label='Limit' description='📊 MAX RECORDS - Range: 1-10,000. Default: 50. ✅ FLEXIBLE: Accepts 50 (number) OR "50" (string). Examples: 50, "50", "1000", 5000. V7: For large datasets (>5,000), system automatically uses aggregation mode regardless of limit. Service validates range.' required=false)
        public String limitStr;
        
        @InvocableVariable(label='Summary Only' description='⚡ MODE SELECTION - ✅ FLEXIBLE: Accepts true (boolean) OR "true"/"yes"/"1" (string) for summary, false/"false"/"no"/"0" for detailed. Default: true. Use TRUE for aggregate questions ("which KPIs", "compare segments", "show growth factors"). Use FALSE only for individual AE details. System auto-converts all formats.' required=false)
        public String summaryOnlyStr;
        
        @InvocableVariable(label='Analysis Type Detail' description='🔍 STRATEGIC FOCUS - Guides agent presentation. Examples: "growth factor analysis", "ramp status assessment", "quarterly performance trends", "year-over-year comparison", "underperforming KPIs", "top performers", "coverage metrics", "pipeline generation analysis", "deal size trends". Service returns all data, agent emphasizes relevant sections based on this hint.' required=false)
        public String analysisTypeDetail;
        
        @InvocableVariable(label='Include Outlier Detection' description='📈 OUTLIER ANALYSIS - ✅ FLEXIBLE: Accepts true (boolean) OR "true"/"yes"/"1" (string). Default: true. When enabled, performs statistical outlier detection on KPI values to identify exceptional performers (positive outliers) and underperformers (negative outliers). Results included in summary.outlierDetection section. System auto-converts all formats.' required=false)
        public String includeOutlierDetectionStr;
    }

    /**
     * @description Response DTO for KPI Analysis V7
     */
    global class KPIAnalysisResponse {
        @InvocableVariable(label='KPI Analysis Result' description='📊 JSON-FIRST RESPONSE - Comprehensive KPI analysis with summary aggregations and detailed records. Includes: learnerProfileId, kpiDefinition (Growth Factor), kpiDescription, kpiValue, currentQuarter metrics (CQ_*), previousQuarter metrics (PQ_*), currentFY metrics (CURR_FY_*), previousFY metrics (PREV_FY_*), currentMonth metrics (CURR_Y_CURR_MNTH_*), sameMonthLastYear metrics (LAST_Y_CURR_MNTH_*), vertical, segment, industry, rampStatus, managerName. Summary includes aggregations by KPI, segment, industry, rampStatus, and outlierDetection if enabled.' required=true)
        public String result;

        public KPIAnalysisResponse() {
            this.result = '';
        }
    }

    /**
     * @description Main invocable method - flexible input handling with auto-conversion
     * Accepts BOTH string and proper types for all Boolean/Integer fields
     */
    @InvocableMethod(label='ANAGENT KPI Analysis V7' description='🎯 KPI ANALYSIS V7 - Analyze Account Executive performance across multiple KPI metrics (Growth Factors) and time windows. 📧 MANAGER: managementChainEmail="sallen@salesforce.com" (auto-searches ALL 12 levels). 🌍 TERRITORY: ouName="UKI" OR workLocationCountry="United States". 🎯 KPI: kpiDefinition="Coverage" for specific growth factor. ⚠️ AT LEAST ONE required: ouName, workLocationCountry, or managementChainEmail. ✅ FLEXIBLE INPUT: summaryOnly accepts true/"true"/"yes"/"1", limit accepts 40000/"40000". Returns aggregations by KPI, segment, industry, rampStatus. Includes outlier detection for exceptional performers and underperformers.')
    global static List<KPIAnalysisResponse> analyzeKPIs(List<KPIAnalysisRequest> requests) {
        List<KPIAnalysisResponse> responses = new List<KPIAnalysisResponse>();

        if (requests == null || requests.isEmpty()) {
            KPIAnalysisResponse errorResponse = new KPIAnalysisResponse();
            errorResponse.result = buildError(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 'Request list is null or empty', 'requests', 
                'List<KPIAnalysisRequest>', 'null or empty', 
                new List<String>{'Provide valid request object'},
                new List<String>{'Include at least one filter: ouName, workLocationCountry, or managementChainEmail'});
            responses.add(errorResponse);
            return responses;
        }

        for (KPIAnalysisRequest request : requests) {
            KPIAnalysisResponse response = new KPIAnalysisResponse();
            
            // FLEXIBLE INPUT HANDLING: Convert string inputs to proper types
            Integer limitValue = null;
            Boolean summaryOnlyValue = null;
            Boolean includeOutlierDetectionValue = null;
            
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
            
            // Convert includeOutlierDetection (string → boolean)
            if (String.isNotBlank(request.includeOutlierDetectionStr)) {
                Object conversionResult = convertToBoolean(request.includeOutlierDetectionStr, 'includeOutlierDetection');
                if (conversionResult instanceof String) {
                    // Error occurred
                    response.result = (String) conversionResult;
                    responses.add(response);
                    continue;
                }
                includeOutlierDetectionValue = (Boolean) conversionResult;
            }
            
            // Call service with normalized values
            response.result = ANAgentKPIAnalysisServiceV7.analyzeKPIs(request, summaryOnlyValue, limitValue, includeOutlierDetectionValue);
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
            return buildError(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
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

