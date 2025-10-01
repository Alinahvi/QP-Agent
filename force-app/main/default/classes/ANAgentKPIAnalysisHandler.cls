/**
 * Enhanced KPI Analysis Handler with Fuzzy Search and Learner Profile Integration
 * Handles KPI analysis requests with advanced search capabilities
 */
public with sharing class ANAgentKPIAnalysisHandler {
    
    // Request class for KPI analysis
    public class KPIAnalysisRequest {
        @InvocableVariable(
            label='Analysis Type'
            description='Type of KPI analysis (GROWTH_FACTORS, MEETINGS, REVENUE)'
        )
        public String analysisType;

        @InvocableVariable(
            label='Primary Dimension'
            description='Primary dimension for analysis (OU_NAME__c, WORK_LOCATION_COUNTRY__c)'
        )
        public String primaryDimension;

        @InvocableVariable(
            label='Primary Value'
            description='Primary value for analysis (supports fuzzy matching)'
        )
        public String primaryValue;

        @InvocableVariable(
            label='Secondary Dimension'
            description='Secondary dimension for analysis (OU_NAME__c, WORK_LOCATION_COUNTRY__c)'
        )
        public String secondaryDimension;

        @InvocableVariable(
            label='Secondary Value'
            description='Secondary value for analysis (supports fuzzy matching)'
        )
        public String secondaryValue;

        @InvocableVariable(
            label='Time Frame'
            description='Time frame for analysis (CURRENT, PREVIOUS)'
        )
        public String timeFrame = 'CURRENT';

        @InvocableVariable(
            label='Max Results'
            description='Maximum number of results to return'
        )
        public Integer maxResults = 100;

        @InvocableVariable(
            label='Include Learner Profile Data'
            description='Include rich learner profile data in response'
        )
        public Boolean includeLearnerProfile = true;

        @InvocableVariable(
            label='Fuzzy Search Enabled'
            description='Enable fuzzy search for OU and country names'
        )
        public Boolean fuzzySearchEnabled = true;

        @InvocableVariable(
            label='Enable Outliers'
            description='Enable outlier detection and analysis'
        )
        public Boolean enableOutliers = false;

        @InvocableVariable(
            label='Metrics'
            description='Specific metrics to analyze for outliers'
        )
        public List<String> metrics;

        @InvocableVariable(
            label='Limit N'
            description='Maximum number of records to process for outlier analysis'
        )
        public Integer limitN = 100;
    }

    // Enhanced response class
    public class KPIAnalysisResponse {
        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Message')
        public String message;

        @InvocableVariable(label='Total Record Count')
        public Integer totalRecordCount;

        @InvocableVariable(label='Analysis Type')
        public String analysisType;

        @InvocableVariable(label='Time Frame')
        public String timeFrame;

        @InvocableVariable(label='OU Name')
        public String ouName;

        @InvocableVariable(label='Country')
        public String country;

        @InvocableVariable(label='Total AEs')
        public Integer totalAEs;

        @InvocableVariable(label='Avg Coverage')
        public Decimal avgCoverage;

        @InvocableVariable(label='Total ACV')
        public Decimal totalACV;

        @InvocableVariable(label='Total PG')
        public Decimal totalPG;

        @InvocableVariable(label='Total Meetings')
        public Integer totalMeetings;

        @InvocableVariable(label='Total Call Connects')
        public Integer totalCallConnects;

        @InvocableVariable(label='Warnings')
        public List<String> warnings;

        @InvocableVariable(label='Learner Profile Data')
        public List<ANAgentKPIAnalysisService.LearnerProfileData> learnerProfiles;

        @InvocableVariable(label='Fuzzy Matches')
        public List<String> fuzzyMatches;

        @InvocableVariable(label='Outlier Results')
        public Map<String, ANAgentKPIOutlierService.OutlierResult> outlierResults;

        @InvocableVariable(label='Formatted Message')
        public String formattedMessage;

        @InvocableVariable(label='TSV Download Link')
        public String tsvDownloadLink;
    }

    @InvocableMethod(
        label='Analyze KPIs'
        description='Enhanced KPI analysis with fuzzy search and learner profile integration'
        category='KPI Analysis'
    )
    public static List<KPIAnalysisResponse> analyzeKPIs(List<KPIAnalysisRequest> requests) {
        List<KPIAnalysisResponse> responses = new List<KPIAnalysisResponse>();
        
        for (KPIAnalysisRequest request : requests) {
            try {
                // Convert handler request to service request
                ANAgentKPIAnalysisService.KPIAnalysisRequest serviceRequest = convertToServiceRequest(request);
                
                // Call the enhanced service
                List<ANAgentKPIAnalysisService.KPIAnalysisResponse> serviceResponses = 
                    ANAgentKPIAnalysisService.analyzeKPIs(new List<ANAgentKPIAnalysisService.KPIAnalysisRequest>{serviceRequest});
                
                // Convert service response to handler response
                if (!serviceResponses.isEmpty()) {
                    KPIAnalysisResponse response = convertFromServiceResponse(serviceResponses[0]);
                    responses.add(response);
                } else {
                    KPIAnalysisResponse errorResponse = new KPIAnalysisResponse();
                    errorResponse.success = false;
                    errorResponse.message = 'No response from service';
                    responses.add(errorResponse);
                }
            } catch (Exception e) {
                KPIAnalysisResponse errorResponse = new KPIAnalysisResponse();
                errorResponse.success = false;
                errorResponse.message = 'Error in KPI analysis: ' + e.getMessage();
                errorResponse.warnings = new List<String>{'Processing error: ' + e.getMessage()};
                responses.add(errorResponse);
            }
        }
        
        return responses;
    }

    private static ANAgentKPIAnalysisService.KPIAnalysisRequest convertToServiceRequest(KPIAnalysisRequest request) {
        ANAgentKPIAnalysisService.KPIAnalysisRequest serviceRequest = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
        
        serviceRequest.analysisType = request.analysisType;
        serviceRequest.timeFrame = request.timeFrame;
        serviceRequest.maxResults = request.maxResults;
        serviceRequest.includeLearnerProfile = request.includeLearnerProfile;
        serviceRequest.fuzzySearchEnabled = request.fuzzySearchEnabled;
        serviceRequest.enableOutliers = request.enableOutliers;
        serviceRequest.metrics = request.metrics;
        serviceRequest.limitN = request.limitN;
        
        // Smart mapping: Detect if primaryValue looks like an OU or country
        if (String.isNotBlank(request.primaryValue)) {
            if (isLikelyOU(request.primaryValue)) {
                serviceRequest.ouName = request.primaryValue;
                System.debug('Mapped primaryValue "' + request.primaryValue + '" to OU_NAME__c');
            } else if (isLikelyCountry(request.primaryValue)) {
                serviceRequest.country = request.primaryValue;
                System.debug('Mapped primaryValue "' + request.primaryValue + '" to WORK_LOCATION_COUNTRY__c');
            } else {
                // Fallback to dimension-based mapping
                if ('OU_NAME__c'.equals(request.primaryDimension)) {
                    serviceRequest.ouName = request.primaryValue;
                } else if ('WORK_LOCATION_COUNTRY__c'.equals(request.primaryDimension)) {
                    serviceRequest.country = request.primaryValue;
                }
            }
        }
        
        // Smart mapping for secondary value
        if (String.isNotBlank(request.secondaryValue)) {
            if (isLikelyOU(request.secondaryValue)) {
                serviceRequest.ouName = request.secondaryValue;
                System.debug('Mapped secondaryValue "' + request.secondaryValue + '" to OU_NAME__c');
            } else if (isLikelyCountry(request.secondaryValue)) {
                serviceRequest.country = request.secondaryValue;
                System.debug('Mapped secondaryValue "' + request.secondaryValue + '" to WORK_LOCATION_COUNTRY__c');
            } else {
                // Fallback to dimension-based mapping
                if ('OU_NAME__c'.equals(request.secondaryDimension)) {
                    serviceRequest.ouName = request.secondaryValue;
                } else if ('WORK_LOCATION_COUNTRY__c'.equals(request.secondaryDimension)) {
                    serviceRequest.country = request.secondaryValue;
                }
            }
        }
        
        return serviceRequest;
    }
    
    private static Boolean isLikelyOU(String value) {
        if (String.isBlank(value)) return false;
        
        // Common OU patterns
        String upperValue = value.toUpperCase();
        return upperValue.contains('AMER') || 
               upperValue.contains('EMEA') || 
               upperValue.contains('APAC') || 
               upperValue.contains('ACC') || 
               upperValue.contains('SMB') || 
               upperValue.contains('REG') || 
               upperValue.contains('ICE') ||
               upperValue.contains('CBS') ||
               upperValue.contains('TMT') ||
               upperValue.contains('MAE');
    }
    
    private static Boolean isLikelyCountry(String value) {
        if (String.isBlank(value)) return false;
        
        // Common country patterns
        String upperValue = value.toUpperCase();
        return upperValue.equals('US') || 
               upperValue.equals('USA') || 
               upperValue.equals('UNITED STATES') ||
               upperValue.equals('CANADA') ||
               upperValue.equals('UNITED KINGDOM') ||
               upperValue.equals('UK') ||
               upperValue.equals('GERMANY') ||
               upperValue.equals('FRANCE') ||
               upperValue.equals('JAPAN') ||
               upperValue.equals('AUSTRALIA') ||
               upperValue.equals('IRELAND') ||
               upperValue.equals('BRAZIL') ||
               upperValue.equals('INDIA');
    }

    private static KPIAnalysisResponse convertFromServiceResponse(ANAgentKPIAnalysisService.KPIAnalysisResponse serviceResponse) {
        KPIAnalysisResponse response = new KPIAnalysisResponse();
        
        response.success = serviceResponse.success;
        response.message = serviceResponse.message;
        response.totalRecordCount = serviceResponse.totalRecordCount;
        response.analysisType = serviceResponse.analysisType;
        response.timeFrame = serviceResponse.timeFrame;
        response.ouName = serviceResponse.ouName;
        response.country = serviceResponse.country;
        response.totalAEs = serviceResponse.totalAEs;
        response.warnings = serviceResponse.warnings;
        response.learnerProfiles = serviceResponse.learnerProfiles;
        response.fuzzyMatches = serviceResponse.fuzzyMatches;
        response.outlierResults = serviceResponse.outlierResults;
        response.formattedMessage = serviceResponse.formattedMessage;
        response.tsvDownloadLink = serviceResponse.tsvDownloadLink;
        
        // Add aggregate data directly from service response
        response.avgCoverage = serviceResponse.avgCoverage;
        response.totalACV = serviceResponse.totalACV;
        response.totalPG = serviceResponse.totalPG;
        response.totalMeetings = serviceResponse.totalMeetings;
        response.totalCallConnects = serviceResponse.totalCallConnects;
        
        return response;
    }
}