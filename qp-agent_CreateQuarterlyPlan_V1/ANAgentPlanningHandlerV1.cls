/**
 * @description Handler for ANAgent Planning Action - Creates quarterly enablement plans
 * @version 1.0.0
 * @date 2025-10-22
 */
public with sharing class ANAgentPlanningHandlerV1 {
    
    /**
     * @description Request wrapper for creating quarterly plans
     */
    public class QuarterlyPlanRequest {
        
        @InvocableVariable(
            label='OU Name' 
            description='🎯 ORGANIZATIONAL UNIT NAME - Territory grouping (e.g., AMER ACC, UKI, APAC ENTR). REQUIRED. Valid values: AMER ACC (Americas Account Management), UKI (United Kingdom & Ireland), APAC ENTR (Asia Pacific Enterprise), LATAM (Latin America), EMEA (Europe Middle East Africa), North Asia, Canada, ANZ (Australia & New Zealand), Japan, Korea, India, Germany, France, Italy, Spain, Netherlands, Switzerland, Brazil, Mexico, Argentina, Colombia, Sweden, SMB-AMER SMB, PubSec+.Org.'
            required=true
        )
        public String ouName;
        
        @InvocableVariable(
            label='Macro Segment' 
            description='🎯 MARKET SEGMENT - Customer size classification. REQUIRED. Valid values: ENTR (Enterprise - Large customers), CMRCL (Commercial - Mid-market customers), ESMB (Small & Medium Business), PubSec (Public Sector), Unmapped. Use exact values from this list.'
            required=true
        )
        public String macroSegment;
        
        @InvocableVariable(
            label='Fiscal Quarter' 
            description='📅 FISCAL QUARTER - REQUIRED. Valid values: Q1, Q2, Q3, Q4. Use exact values from this list.'
            required=true
        )
        public String fiscalQuarter;
        
        @InvocableVariable(
            label='Fiscal Year' 
            description='📅 FISCAL YEAR - REQUIRED. Valid values: FY 2024, FY 2025, FY 2026, FY 2027. Use exact values from this list.'
            required=true
        )
        public String fiscalYear;
        
        @InvocableVariable(
            label='Analysis Data (JSON)' 
            description='📊 ANALYSIS RESULTS JSON - REQUIRED. JSON string containing analysis results from Future Pipeline and Open Pipeline actions. Structure: {"renewals":{"totals":{"total_amount":number,"count":number}},"cross_sell":{"totals":{"count":number}},"upsell":{"totals":{"count":number}},"open_pipeline":{"totals":{"sum":number,"count":number,"avg_stagnation":number,"avg_ae_score":number}}}. Get this from running ANAGENT Open Pipeline Analysis V4 and ABAGENT Future Pipeline Analysis V4 actions.'
            required=true
        )
        public String analysisDataJson;
        
        @InvocableVariable(
            label='Recommendations (JSON)' 
            description='📝 RECOMMENDATIONS JSON - REQUIRED. JSON array of 5 recommendation objects. CRITICAL FIELD REQUIREMENTS: (1) program_name: Actual program name from SearchProgramsV4 or descriptive name; (2) enablement_type: MUST be exactly "Do My Job", "Industry", "Product", or "Skills" (case-sensitive); (3) product_l1__c: If product-related, use exact value from picklist: Sales Cloud, Service Cloud, Marketing Cloud, Slack, Salesforce Platform, MuleSoft, Customer Data Cloud, etc.; (4) segment: MUST be "Enterprise" (for ENTR), "Commercial" (for CMRCL), "SMB" (for ESMB), "ECS", "CSG", "Field AE", "Leader", "Sales Dev", "Solutions", or "Specialist" (case-sensitive); (5) businesspriority__c: Use exact format "Priority 1: High Performance Culture" through "Priority 5: Customer Success..." (include "Priority N:" prefix); (6) of_learners__c: Positive number, count of learnerProfileIds from analysis with this specific gap (example: 87); (7) delivery_date__c: YYYY-MM-DD format only (example: "2025-03-15"); (8) end_date__c: YYYY-MM-DD format, same as delivery for single-day; (9) additional_details__c: Rationale max 255 chars explaining gap and impact; (10) severity: CRITICAL/HIGH/MEDIUM/LOW (maps to rank). Build after SearchProgramsV4 for each gap.'
            required=true
        )
        public String recommendationsJson;
        
        @InvocableVariable(
            label='Primary Industry' 
            description='🏭 PRIMARY INDUSTRY - Most common industry from analysis. Optional but recommended. Valid values: Technology, Financial Services, Healthcare & Life Sciences, Manufacturing, Automotive & Energy, Retail & Consumer Goods, Professional Services, Communications & Media, Public Sector, Education, Nonprofit, Travel, Transportation, & Hospitality, Engineering, Construction, & Real Estate, Agriculture & Mining, No Primary Industry, Other. Use exact values from this list.'
        )
        public String primaryIndustry;
        
        @InvocableVariable(
            label='Global Region' 
            description='🌍 GLOBAL REGION - REQUIRED. Valid values: AMER (Americas), EMEA (Europe Middle East Africa), APAC (Asia Pacific), LATAM (Latin America). Map from OU: AMER ACC→AMER, UKI→EMEA, APAC ENTR→APAC, LATAM→LATAM.'
            required=true
        )
        public String globalRegion;
        
        @InvocableVariable(
            label='Plan Owner User ID' 
            description='👤 PLAN OWNER USER ID - Salesforce User ID (18 characters) for quarterly plan owner. Optional - defaults to current user if not provided. Example: 005Hu00000YUvyFMAT.'
        )
        public String planOwnerUserId;
        
        @InvocableVariable(
            label='Business Priority' 
            description='🎯 BUSINESS PRIORITY - Strategic focus for the plan. Optional. Valid values: Priority 1: High Performance Culture | Priority 2: ACV growth (sales plays, Signature Success) | Priority 3: Field success (participation/ DMJ/ skills) | Priority 4: Big Deal motion | Priority 5: Customer Success (Industry, Product, Ensure Customer Loyalty, Customer Adoption/Performance/Engagement). Use exact values from this list including the prefix "Priority N:".'
        )
        public String businessPriority;
        
        @InvocableVariable(
            label='Leader User ID' 
            description='👥 LEADER USER ID - Salesforce User ID (18 characters) for plan leader. Optional. Example: 005Hu00000YUvyFMAT.'
        )
        public String leaderUserId;
        
        @InvocableVariable(
            label='Template Flag' 
            description='📋 TEMPLATE FLAG - Whether this plan is a template. Optional. Default: false. Set to true for reusable plan templates.'
        )
        public Boolean templateFlag;
        
        @InvocableVariable(
            label='Quarter Timing' 
            description='⏰ QUARTER TIMING - Timing within the quarter. Optional. Valid values: Fiscal Year, Fiscal Quarter. Use exact values from this list.'
        )
        public String quarterTiming;
        
        @InvocableVariable(
            label='EBP Type' 
            description='📚 EBP TYPE - Enablement Business Process type. REQUIRED (controls OU__c picklist values). Valid values: CSG, Sales & Solutions. Use exact values from this list. CRITICAL: OU__c is a dependent picklist controlled by EBP_Type__c - you MUST set EBP_Type__c first, then only certain OU values become available.'
            required=true
        )
        public String ebpType;
    }
    
    /**
     * @description Response wrapper for plan creation
     */
    public class QuarterlyPlanResponse {
        @InvocableVariable(
            label='Success'
            description='Whether the operation was successful'
        )
        public Boolean success;
        
        @InvocableVariable(
            label='Quarterly Planning ID'
            description='Created Quarterly_Planning__c record ID'
        )
        public String quarterlyPlanningId;
        
        @InvocableVariable(
            label='Agent OU Plan ID'
            description='Created Agent_OU_Quarterly_Plan__c record ID'
        )
        public String agentOuPlanId;
        
        @InvocableVariable(
            label='Enablement Solution IDs'
            description='Comma-separated list of created Enablement_Solutions__c record IDs'
        )
        public String enablementSolutionIds;
        
        @InvocableVariable(
            label='Total Records Created'
            description='Total number of records created (should be 2 + N recommendations)'
        )
        public Integer totalRecordsCreated;
        
        @InvocableVariable(
            label='Message'
            description='Success or error message'
        )
        public String message;
        
        @InvocableVariable(
            label='Error Details'
            description='Detailed error information if success = false'
        )
        public String errorDetails;
    }
    
    /**
     * @description Main invocable method for creating quarterly plans
     */
    @InvocableMethod(
        label='ANAGENT Create Quarterly Plan V1'
        description='Creates quarterly enablement plan with parent Quarterly_Planning__c record and child Enablement_Solutions__c records in Draft/Inactive status. After user approval, use separate action to activate. REQUIRED INPUTS: ouName, macroSegment (ENTR/CMRCL/ESMB/PubSec), fiscalQuarter (Q1-Q4), fiscalYear (FY 2025/2026), analysisDataJson (JSON string with renewals/cross_sell/upsell/open_pipeline metrics), recommendationsJson (JSON array of 5 recommendations with all fields), primaryIndustry, globalRegion (AMER/EMEA/APAC/LATAM). OUTPUT: Returns quarterlyPlanningId, agentOuPlanId, enablementSolutionIds (comma-separated), totalRecordsCreated, success status. WORKFLOW: This action is called AFTER assessment phase when user approves plan creation. Records are created in Draft/Planned status. Use separate activation action to promote to Active/Approved after user review.'
        category='Planning & Strategy'
    )
    public static List<QuarterlyPlanResponse> createQuarterlyPlan(List<QuarterlyPlanRequest> requests) {
        List<QuarterlyPlanResponse> responses = new List<QuarterlyPlanResponse>();
        
        // Handle null/empty request list
        if (requests == null || requests.isEmpty()) {
            QuarterlyPlanResponse errorResponse = new QuarterlyPlanResponse();
            errorResponse.success = false;
            errorResponse.message = '❌ ERROR: No requests provided. Please provide at least one request with required fields.';
            errorResponse.errorDetails = 'Request list is null or empty';
            errorResponse.totalRecordsCreated = 0;
            responses.add(errorResponse);
            return responses;
        }
        
        // Process each request - handler is pure router
        for (QuarterlyPlanRequest request : requests) {
            QuarterlyPlanResponse response = new QuarterlyPlanResponse();
            
            try {
                // Validate required fields
                String validationError = validateRequest(request);
                if (String.isNotBlank(validationError)) {
                    response.success = false;
                    response.message = '❌ VALIDATION ERROR: ' + validationError;
                    response.errorDetails = 'Required fields missing or invalid';
                    response.totalRecordsCreated = 0;
                    responses.add(response);
                    continue;
                }
                
                // Delegate to service layer - convert to Map for service layer
                Map<String, Object> requestMap = new Map<String, Object>{
                    'ouName' => request.ouName,
                    'fiscalQuarter' => request.fiscalQuarter,
                    'fiscalYear' => request.fiscalYear,
                    'globalRegion' => request.globalRegion,
                    'macroSegment' => request.macroSegment,
                    'primaryIndustry' => request.primaryIndustry,
                    'analysisDataJson' => request.analysisDataJson,
                    'recommendationsJson' => request.recommendationsJson,
                    'templateFlag' => request.templateFlag,
                    'planOwnerUserId' => request.planOwnerUserId,
                    'leaderUserId' => request.leaderUserId,
                    'businessPriority' => request.businessPriority,
                    'quarterTiming' => request.quarterTiming,
                    'ebpType' => request.ebpType
                };
                Map<String, Object> result = ANAgentPlanningServiceV1.createPlan(requestMap);
                
                response.success = (Boolean)result.get('success');
                response.quarterlyPlanningId = (String)result.get('quarterlyPlanningId');
                response.agentOuPlanId = (String)result.get('agentOuPlanId');
                response.enablementSolutionIds = (String)result.get('enablementSolutionIds');
                response.totalRecordsCreated = (Integer)result.get('totalRecordsCreated');
                response.message = (String)result.get('message');
                response.errorDetails = (String)result.get('errorDetails');
                
            } catch (Exception e) {
                response.success = false;
                response.message = '❌ EXCEPTION ERROR: ' + e.getMessage();
                response.errorDetails = e.getStackTraceString();
                response.totalRecordsCreated = 0;
            }
            
            responses.add(response);
        }
        
        return responses;
    }
    
    /**
     * @description Validates required fields in request
     * @param request The request to validate
     * @return Error message if validation fails, null if valid
     */
    private static String validateRequest(QuarterlyPlanRequest request) {
        if (String.isBlank(request.ouName)) {
            return 'OU Name is required. Valid values: AMER ACC, UKI, APAC ENTR, LATAM, EMEA, etc.';
        }
        if (String.isBlank(request.macroSegment)) {
            return 'Macro Segment is required. Valid values: ENTR, CMRCL, ESMB, PubSec.';
        }
        if (String.isBlank(request.fiscalQuarter)) {
            return 'Fiscal Quarter is required. Valid values: Q1, Q2, Q3, Q4.';
        }
        if (String.isBlank(request.fiscalYear)) {
            return 'Fiscal Year is required. Valid values: FY 2024, FY 2025, FY 2026, FY 2027.';
        }
        if (String.isBlank(request.analysisDataJson)) {
            return 'Analysis Data JSON is required. Get this from running ANAGENT Open Pipeline Analysis V4 and ABAGENT Future Pipeline Analysis V4 actions.';
        }
        if (String.isBlank(request.recommendationsJson)) {
            return 'Recommendations JSON is required. Build this after running SearchProgramsV4 for each gap.';
        }
        if (String.isBlank(request.globalRegion)) {
            return 'Global Region is required. Valid values: AMER, EMEA, APAC, LATAM.';
        }
        if (String.isBlank(request.ebpType)) {
            return 'EBP Type is required (controls OU__c picklist). Valid values: CSG, Sales & Solutions.';
        }
        
        // Validate JSON format
        try {
            JSON.deserializeUntyped(request.analysisDataJson);
        } catch (Exception e) {
            return 'Analysis Data JSON is invalid. Please ensure it is valid JSON format.';
        }
        
        try {
            JSON.deserializeUntyped(request.recommendationsJson);
        } catch (Exception e) {
            return 'Recommendations JSON is invalid. Please ensure it is valid JSON format.';
        }
        
        return null; // Valid
    }
}

