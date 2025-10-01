/**
 * @description Basic offering efficacy handler for agent actions.
 * Provides invocable methods for analyzing offering efficacy and performance metrics.
 * 
 * 🚨 CRITICAL INSTRUCTION FOR TOPIC CONFIGURATION:
 * 
 * ## PARAMETER MAPPING FOR GEOGRAPHIC FILTERING
 * 
 * When user says "within AMER", "in AMER", "AMER region", etc.:
 * 
 * INTERNAL MAPPING RULES:
 * - Geographic terms (AMER, EMEA, APAC) → operatingUnit parameter
 * - NEVER use region parameter for geographic filtering
 * - region parameter filters REGION__c field (mostly null = ineffective filtering)
 * - operatingUnit parameter filters OU_NAME__c field (contains actual OU values)
 * 
 * PARAMETER CONVERSION:
 * - "within AMER" → operatingUnit: "AMER"  // ✅ CORRECT - filters OU_NAME__c
 * - "within AMER" → region: "AMER"         // ❌ WRONG - filters REGION__c (mostly null)
 * 
 * EXAMPLES:
 * - User: "ACV programs within AMER" → operatingUnit: "AMER"
 * - User: "best programs in EMEA" → operatingUnit: "EMEA"  
 * - User: "top courses in APAC" → operatingUnit: "APAC"
 * 
 * @version 1.1
 */
public with sharing class ANAgentOfferingEfficacyHandlerBasic {
    
    /**
     * @description Request object for efficacy analysis
     */
    public class EfficacyAnalysisRequest {
        @InvocableVariable(label='Action' description='The action to perform: Search, CourseEfficacy, ProgramEfficacy, FindIneffectiveCourses, or FindIneffectiveCoursesByDate' required=true)
        public String action;
        
        @InvocableVariable(label='Offering Label' description='Specific offering to analyze (e.g., "FY25 Fast Start - RKO - Einstein 1")')
        public String offeringLabel;
        
        @InvocableVariable(label='Course Name' description='Course name to find efficacy data for (used with CourseEfficacy action)')
        public String courseName;
        
        @InvocableVariable(label='KPI Name' description='Specific KPI to filter by (e.g., "ACV", "PIPE_QUALITY")')
        public String kpiName;
        
        @InvocableVariable(label='Vertical' description='Vertical to filter by (e.g., "FINS", "HLS")')
        public String vertical;
        
        @InvocableVariable(label='Operating Unit' description='Operating Unit to filter by (e.g., "AMER", "EMEA")')
        public String operatingUnit;
        
        @InvocableVariable(label='Program Type' description='Program type to filter by')
        public String programType;
        
        @InvocableVariable(label='Region' description='Region to filter by')
        public String region;
        
        @InvocableVariable(label='Macro Segment' description='Macro segment to filter by')
        public String macroSegment;
        
        @InvocableVariable(label='Fiscal Quarter' description='Fiscal quarter to filter by')
        public String fiscalQuarter;
        
        @InvocableVariable(label='Product' description='Product to filter by')
        public String product;
        
        @InvocableVariable(label='Max Results' description='Maximum number of results to return')
        public Integer maxResults;
        
        @InvocableVariable(label='Months Back' description='Number of months back to search for courses (used with FindIneffectiveCoursesByDate action, defaults to 9)')
        public Integer monthsBack;
    }
    
    /**
     * @description Response class for efficacy analysis
     */
    public class EfficacyAnalysisResponse {
        @InvocableVariable(label='Success' description='Whether the analysis was successful')
        public Boolean success;
        
        @InvocableVariable(label='Message' description='Success or error message')
        public String message;
        
        @InvocableVariable(label='Total Record Count' description='Total number of records found')
        public Integer totalRecordCount;
        
        @InvocableVariable(label='Summary Metrics' description='Summary of the analysis results')
        public String summaryMetrics;
        
        @InvocableVariable(label='Efficacy Records' description='Detailed efficacy records with offering names')
        public List<ANAgentOfferingEfficacyServiceBasic.EfficacyRecord> efficacyRecords;
        
        @InvocableVariable(label='Request ID' description='Original request ID')
        public String requestId;
        
        public EfficacyAnalysisResponse() {
            this.success = false;
            this.message = '';
            this.totalRecordCount = 0;
            this.summaryMetrics = '';
            this.efficacyRecords = new List<ANAgentOfferingEfficacyServiceBasic.EfficacyRecord>();
            this.requestId = '';
        }
    }
    
    /**
     * @description Main method to analyze offering efficacy
     */
    @InvocableMethod(label='Analyze Offering Efficacy' description='Analyze the efficacy of offerings based on various criteria')
    public static List<EfficacyAnalysisResponse> analyzeOfferingEfficacy(List<EfficacyAnalysisRequest> requests) {
        List<EfficacyAnalysisResponse> responses = new List<EfficacyAnalysisResponse>();
        
        // Handle empty or null requests
        if (requests == null || requests.isEmpty()) {
            EfficacyAnalysisResponse response = new EfficacyAnalysisResponse();
            response.success = false;
            response.message = 'No request provided.';
            responses.add(response);
            return responses;
        }
        
        // Process each request
        for (EfficacyAnalysisRequest request : requests) {
            EfficacyAnalysisResponse response = new EfficacyAnalysisResponse();
            response.requestId = String.valueOf(request.hashCode());
            
            try {
                // Validate request
                if (String.isBlank(request.action)) {
                    response.success = false;
                    response.message = 'Action is required.';
                    responses.add(response);
                    continue;
                }
                
                // Route to appropriate handler
                switch on request.action.toLowerCase() {
                    when 'search' {
                        response = handleSearch(request);
                    }
                    when 'courseefficacy' {
                        response = handleCourseEfficacy(request);
                    }
                    when 'programefficacy' {
                        response = handleProgramEfficacy(request);
                    }
                    when 'findineffectivecourses' {
                        response = handleFindIneffectiveCourses(request);
                    }
                    when 'findineffectivecoursesbydate' {
                        response = handleFindIneffectiveCoursesByDate(request);
                    }
                    when else {
                        response.success = false;
                        response.message = 'Invalid action: ' + request.action + '. Supported actions: Search, CourseEfficacy, ProgramEfficacy, FindIneffectiveCourses, FindIneffectiveCoursesByDate';
                    }
                }
                
            } catch (Exception e) {
                response.success = false;
                response.message = 'Error processing request: ' + e.getMessage();
                System.debug('Error in analyzeOfferingEfficacy: ' + e.getMessage());
            }
            
            responses.add(response);
        }
        
        return responses;
    }
    
    /**
     * @description Handle search action
     */
    private static EfficacyAnalysisResponse handleSearch(EfficacyAnalysisRequest req) {
        EfficacyAnalysisResponse res = new EfficacyAnalysisResponse();
        
        try {
            // Check if user is asking for ineffective courses (0 influenced ACV)
            Boolean isIneffectiveQuery = String.isNotBlank(req.offeringLabel) && 
                                       (req.offeringLabel.toLowerCase().contains('ineffective') || 
                                        req.offeringLabel.toLowerCase().contains('not effective') ||
                                        req.offeringLabel.toLowerCase().contains('no acv impact') ||
                                        req.offeringLabel.toLowerCase().contains('0 acv'));
            
            // If user wants ineffective courses but offeringLabel is generic, set a proper label
            String effectiveOfferingLabel = req.offeringLabel;
            if (isIneffectiveQuery && String.isBlank(req.offeringLabel)) {
                effectiveOfferingLabel = 'ineffective courses';
            }
            
            // Call the basic service
            ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult searchResult = 
                ANAgentOfferingEfficacyServiceBasic.searchEfficacyData(
                    effectiveOfferingLabel, req.programType, req.region, req.macroSegment,
                    req.fiscalQuarter, req.kpiName, req.product, req.maxResults
                );
            
            res.success = searchResult.success;
            res.message = searchResult.message;
            res.totalRecordCount = searchResult.totalRecordCount;
            res.summaryMetrics = searchResult.summaryMetrics;
            res.efficacyRecords = searchResult.efficacyRecords;
            
        } catch (Exception e) {
            res.success = false;
            res.message = 'Error during search: ' + e.getMessage();
            System.debug('Error in search: ' + e.getMessage());
        }
        
        return res;
    }
    
    /**
     * @description Handle course efficacy action
     */
    private static EfficacyAnalysisResponse handleCourseEfficacy(EfficacyAnalysisRequest req) {
        EfficacyAnalysisResponse res = new EfficacyAnalysisResponse();
        
        try {
            if (String.isBlank(req.courseName)) {
                res.success = false;
                res.message = 'Course name is required for CourseEfficacy action.';
                return res;
            }
            
            // Call the basic service for course efficacy
            ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult courseResult = 
                ANAgentOfferingEfficacyServiceBasic.getEfficacyForCourse(req.courseName);
            
            res.success = courseResult.success;
            res.message = courseResult.message;
            res.totalRecordCount = courseResult.totalRecordCount;
            res.summaryMetrics = courseResult.summaryMetrics;
            res.efficacyRecords = courseResult.efficacyRecords;
            
        } catch (Exception e) {
            res.success = false;
            res.message = 'Error during course efficacy analysis: ' + e.getMessage();
            System.debug('Error in course efficacy analysis: ' + e.getMessage());
        }
        
        return res;
    }
    
    /**
     * @description Handle program efficacy action
     */
    private static EfficacyAnalysisResponse handleProgramEfficacy(EfficacyAnalysisRequest req) {
        EfficacyAnalysisResponse res = new EfficacyAnalysisResponse();
        
        try {
            // Apply region-to-OU mapping if region is provided but operatingUnit is not
            String effectiveOU = req.operatingUnit;
            if (String.isBlank(effectiveOU) && String.isNotBlank(req.region)) {
                // Map region to OU for geographic filtering
                effectiveOU = mapRegionToOU(req.region);
                System.debug('🔄 Region-to-OU mapping applied: region="' + req.region + '" → operatingUnit="' + effectiveOU + '"');
            }
            
            // Call the basic service for program efficacy
            ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult programResult = 
                ANAgentOfferingEfficacyServiceBasic.getEfficacyForPrograms(req.kpiName, req.vertical, effectiveOU);
            
            res.success = programResult.success;
            res.message = programResult.message;
            res.totalRecordCount = programResult.totalRecordCount;
            res.summaryMetrics = programResult.summaryMetrics;
            res.efficacyRecords = programResult.efficacyRecords;
            
        } catch (Exception e) {
            res.success = false;
            res.message = 'Error during program efficacy analysis: ' + e.getMessage();
            System.debug('Error in program efficacy analysis: ' + e.getMessage());
        }
        
        return res;
    }
    
    /**
     * @description Handle find ineffective courses action - specifically for courses with 0 influenced ACV
     */
    private static EfficacyAnalysisResponse handleFindIneffectiveCourses(EfficacyAnalysisRequest req) {
        EfficacyAnalysisResponse res = new EfficacyAnalysisResponse();
        
        try {
            // Validate required fields for ineffective courses search
            if (String.isBlank(req.kpiName)) {
                res.success = false;
                res.message = 'KPI Name is required for finding ineffective courses. Please specify which KPI to analyze (e.g., "ACV", "PIPE_QUALITY").';
                return res;
            }
            
            // Call the service to find ineffective courses
            ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult ineffectiveResult = 
                ANAgentOfferingEfficacyServiceBasic.findIneffectiveCourses(
                    req.kpiName, req.region, req.macroSegment, req.fiscalQuarter, req.product, req.maxResults
                );
            
            res.success = ineffectiveResult.success;
            res.message = ineffectiveResult.message;
            res.totalRecordCount = ineffectiveResult.totalRecordCount;
            res.summaryMetrics = ineffectiveResult.summaryMetrics;
            res.efficacyRecords = ineffectiveResult.efficacyRecords;
            
        } catch (Exception e) {
            res.success = false;
            res.message = 'Error during ineffective courses analysis: ' + e.getMessage();
            System.debug('Error in ineffective courses analysis: ' + e.getMessage());
        }
        
        return res;
    }

    /**
     * @description Handle find ineffective courses by date action
     */
    private static EfficacyAnalysisResponse handleFindIneffectiveCoursesByDate(EfficacyAnalysisRequest req) {
        EfficacyAnalysisResponse res = new EfficacyAnalysisResponse();
        
        try {
            if (String.isBlank(req.kpiName)) {
                res.success = false;
                res.message = 'KPI Name is required for finding ineffective courses by date. Please specify which KPI to analyze (e.g., "ACV", "PIPE_QUALITY").';
                return res;
            }

            Integer monthsBack = req.monthsBack != null ? req.monthsBack : 9; // Default to 9 months
            ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult ineffectiveResult = 
                ANAgentOfferingEfficacyServiceBasic.findIneffectiveCoursesByDate(
                    req.kpiName, req.region, req.macroSegment, req.fiscalQuarter, req.product, monthsBack, req.maxResults
                );
            
            res.success = ineffectiveResult.success;
            res.message = ineffectiveResult.message;
            res.totalRecordCount = ineffectiveResult.totalRecordCount;
            res.summaryMetrics = ineffectiveResult.summaryMetrics;
            res.efficacyRecords = ineffectiveResult.efficacyRecords;
            
        } catch (Exception e) {
            res.success = false;
            res.message = 'Error during ineffective courses by date analysis: ' + e.getMessage();
            System.debug('Error in ineffective courses by date analysis: ' + e.getMessage());
        }
        
        return res;
    }
    
    /**
     * @description Map region to OU for geographic filtering
     * Since OUs often contain region names (e.g., "AMER ICE", "AMER ESMB"), 
     * this method maps region requests to appropriate OU patterns
     */
    private static String mapRegionToOU(String region) {
        if (String.isBlank(region)) return null;
        
        String normalizedRegion = region.toUpperCase().trim();
        
        // Map region to OU patterns
        if (normalizedRegion == 'AMER') {
            return 'AMER'; // This will trigger the AMER OU logic in getEfficacyForPrograms
        } else if (normalizedRegion == 'EMEA') {
            return 'EMEA'; // This will trigger the EMEA OU logic in getEfficacyForPrograms
        } else if (normalizedRegion == 'APAC') {
            return 'APAC'; // This will trigger the APAC OU logic in getEfficacyForPrograms
        }
        
        // For other regions, return as-is (exact match)
        return region;
    }
} 