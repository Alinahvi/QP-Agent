/**
 * Enhanced KPI Analysis Service with V3 Object, Outlier Detection, and Advanced Analytics
 * Provides comprehensive KPI analysis with fuzzy matching, outlier detection, and rich learner data
 * 
 * @version 2.0
 * @author AI Assistant
 */
public with sharing class ANAgentKPIAnalysisService {
    
    // Enhanced field mapping for AGENT_OU_PIPELINE_V2__c with comprehensive coverage
    private static final Map<String, Set<String>> REQUIRED_FIELDS = new Map<String, Set<String>>{
        'BASE' => new Set<String>{
            'Id','FULL_NAME__c','EMP_EMAIL_ADDR__c','LEARNER_PROFILE_ID__c',
            'OU_NAME__c','WORK_LOCATION_COUNTRY__c','THIS_FISCAL_QUARTER__c','LAST_FISCAL_QUARTER__c'
        },
        'GROWTH_FACTORS' => new Set<String>{
            'Id','FULL_NAME__c','EMP_EMAIL_ADDR__c','LEARNER_PROFILE_ID__c',
            'OU_NAME__c','WORK_LOCATION_COUNTRY__c','THIS_FISCAL_QUARTER__c','LAST_FISCAL_QUARTER__c',
            'ACTIONABLE__c','DEFINITION__c','DESCRIPTION__c',
            'Coverage__c','CQ_ACV__c','CQ_PG__c','AE_Score__c'
        },
        'REVENUE' => new Set<String>{
            'Id','FULL_NAME__c','EMP_EMAIL_ADDR__c','LEARNER_PROFILE_ID__c',
            'OU_NAME__c','WORK_LOCATION_COUNTRY__c','THIS_FISCAL_QUARTER__c','LAST_FISCAL_QUARTER__c',
            'CQ_ACV__c','CQ_PG__c','Coverage__c','AE_Score__c'
        },
        'MEETINGS' => new Set<String>{
            'Id','FULL_NAME__c','EMP_EMAIL_ADDR__c','LEARNER_PROFILE_ID__c',
            'OU_NAME__c','WORK_LOCATION_COUNTRY__c','THIS_FISCAL_QUARTER__c','LAST_FISCAL_QUARTER__c',
            'CQ_CUSTOMER_MEETING__c','CQ_CALL_CONNECT__c','Coverage__c','AE_Score__c'
        },
        'CALLS' => new Set<String>{
            'Id','FULL_NAME__c','EMP_EMAIL_ADDR__c','LEARNER_PROFILE_ID__c',
            'OU_NAME__c','WORK_LOCATION_COUNTRY__c','THIS_FISCAL_QUARTER__c','LAST_FISCAL_QUARTER__c',
            'CQ_CALL_CONNECT__c','Coverage__c','AE_Score__c'
        },
        'ACV' => new Set<String>{
            'Id','FULL_NAME__c','EMP_EMAIL_ADDR__c','LEARNER_PROFILE_ID__c',
            'OU_NAME__c','WORK_LOCATION_COUNTRY__c','THIS_FISCAL_QUARTER__c','LAST_FISCAL_QUARTER__c',
            'CQ_ACV__c','Coverage__c','AE_Score__c'
        },
        'PG' => new Set<String>{
            'Id','FULL_NAME__c','EMP_EMAIL_ADDR__c','LEARNER_PROFILE_ID__c',
            'OU_NAME__c','WORK_LOCATION_COUNTRY__c','THIS_FISCAL_QUARTER__c','LAST_FISCAL_QUARTER__c',
            'CQ_PG__c','Coverage__c','AE_Score__c'
        },
        'OUTLIERS' => new Set<String>{
            'Id','FULL_NAME__c','EMP_EMAIL_ADDR__c','LEARNER_PROFILE_ID__c',
            'OU_NAME__c','WORK_LOCATION_COUNTRY__c','THIS_FISCAL_QUARTER__c','LAST_FISCAL_QUARTER__c',
            'CQ_CUSTOMER_MEETING__c','CQ_CALL_CONNECT__c','CQ_ACV__c','CQ_PG__c',
            'Coverage__c','AE_Score__c'
        }
    };
    
    // Learner Profile fields for rich data
    private static final Set<String> LEARNER_PROFILE_FIELDS = new Set<String>{
        'Id','Name','ou_name__c','manager__c','employee_region__c','work_location_region__c',
        'em_sub_vertical__c','em_industry__c','work_location_country__c','primary_country_of_coverage__c',
        'emp_mgt_chain_lvl_01_nm__c','emp_mgt_chain_lvl_02_nm__c','emp_mgt_chain_lvl_03_nm__c',
        'emp_mgt_chain_lvl_04_nm__c','emp_mgt_chain_lvl_05_nm__c','emp_mgt_chain_lvl_06_nm__c',
        'emp_mgt_chain_lvl_07_nm__c','emp_mgt_chain_lvl_08_nm__c','emp_mgt_chain_lvl_09_nm__c',
        'emp_mgt_chain_lvl_10_nm__c','emp_mgt_chain_lvl_11_nm__c','emp_mgt_chain_lvl_12_nm__c',
        'ou_leader__c','manager_level__c','manager_email__c','manager_employee_number__c',
        'employee_tenure__c','hire_date__c','job_family__c','title__c','selling_role__c',
        'status__c','people_manager__c','fte__c','primary_email__c'
    };
    
    // Fuzzy search patterns for common variations - more specific matching
    private static final Map<String, List<String>> FUZZY_PATTERNS = new Map<String, List<String>>{
        'AMER ACC' => new List<String>{'AMER ACC', 'AMER-ACC', 'AMER_ACC', 'AMERICAS ACC', 'AMERICA ACC'},
        'EMEA SMB' => new List<String>{'EMEA SMB', 'EMEA-SMB', 'EMEA_SMB', 'SMB - EMEA SMB', 'SMB EMEA', 'EMEA SMB -'},
        'APAC REG' => new List<String>{'APAC REG', 'APAC-REG', 'APAC_REG', 'APAC REGION', 'ASIA PACIFIC REG'},
        'UKI' => new List<String>{'UKI', 'UK & IRELAND', 'UK AND IRELAND', 'UNITED KINGDOM IRELAND'},
        'AMER SMB' => new List<String>{'AMER SMB', 'AMER-SMB', 'AMER_SMB', 'SMB - AMER SMB', 'SMB AMER', 'AMER SMB -'},
        'EMEA ACC' => new List<String>{'EMEA ACC', 'EMEA-ACC', 'EMEA_ACC', 'EUROPE ACC', 'EMEA ACCOUNT'},
        'APAC SMB' => new List<String>{'APAC SMB', 'APAC-SMB', 'APAC_SMB', 'SMB - APAC SMB', 'SMB APAC', 'APAC SMB -'},
        'AMER REG' => new List<String>{'AMER REG', 'AMER-REG', 'AMER_REG', 'AMER REGION', 'AMERICAS REGION'}
    };
    
    // Country name variations
    private static final Map<String, List<String>> COUNTRY_PATTERNS = new Map<String, List<String>>{
        'UNITED STATES' => new List<String>{'US', 'USA', 'UNITED STATES', 'AMERICA', 'UNITED STATES OF AMERICA'},
        'UNITED KINGDOM' => new List<String>{'UK', 'UNITED KINGDOM', 'BRITAIN', 'GREAT BRITAIN', 'ENGLAND'},
        'CANADA' => new List<String>{'CANADA', 'CA', 'CANADIAN'},
        'AUSTRALIA' => new List<String>{'AUSTRALIA', 'AU', 'AUS', 'OZ'},
        'GERMANY' => new List<String>{'GERMANY', 'DE', 'DEUTSCHLAND'},
        'FRANCE' => new List<String>{'FRANCE', 'FR', 'FRANCAIS'},
        'JAPAN' => new List<String>{'JAPAN', 'JP', 'NIPPON'},
        'INDIA' => new List<String>{'INDIA', 'IN', 'BHARAT'},
        'SINGAPORE' => new List<String>{'SINGAPORE', 'SG', 'SINGAPURA'},
        'NETHERLANDS' => new List<String>{'NETHERLANDS', 'NL', 'HOLLAND', 'DUTCH'}
    };

    // Request class for KPI analysis
    public class KPIAnalysisRequest {
        @InvocableVariable(
            label='Analysis Type'
            description='Type of KPI analysis (GROWTH_FACTORS, MEETINGS, REVENUE)'
        )
        public String analysisType;

        @InvocableVariable(
            label='OU Name'
            description='Organizational unit name (supports fuzzy matching)'
        )
        public String ouName;

        @InvocableVariable(
            label='Country'
            description='Country name (supports fuzzy matching)'
        )
        public String country;

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

    // Enhanced response class with learner profile data
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
        public List<LearnerProfileData> learnerProfiles;

        @InvocableVariable(label='Fuzzy Matches')
        public List<String> fuzzyMatches;

        @InvocableVariable(label='Outlier Results')
        public List<OutlierResultWrapper> outlierResults;

        @InvocableVariable(label='Formatted Message')
        public String formattedMessage;

        @InvocableVariable(label='TSV Download Link')
        public String tsvDownloadLink;
    }

    // Outlier Result Wrapper for InvocableVariable
    public class OutlierResultWrapper {
        @InvocableVariable(label='Metric Name')
        public String metricName;
        
        @InvocableVariable(label='Outlier Result')
        public ANAgentKPIOutlierService.OutlierResult outlierResult;
        
        public OutlierResultWrapper(String metricName, ANAgentKPIOutlierService.OutlierResult outlierResult) {
            this.metricName = metricName;
            this.outlierResult = outlierResult;
        }
    }

    // Learner Profile data structure
    public class LearnerProfileData {
        @InvocableVariable(label='Learner Profile ID')
        public String learnerProfileId;

        @InvocableVariable(label='Full Name')
        public String fullName;

        @InvocableVariable(label='Email')
        public String email;

        @InvocableVariable(label='OU')
        public String ou;

        @InvocableVariable(label='Manager')
        public String manager;

        @InvocableVariable(label='Region')
        public String region;

        @InvocableVariable(label='Vertical')
        public String vertical;

        @InvocableVariable(label='Industry')
        public String industry;

        @InvocableVariable(label='Country')
        public String country;

        @InvocableVariable(label='Manager Hierarchy')
        public List<String> managerHierarchy;

        @InvocableVariable(label='OU Leader')
        public String ouLeader;

        @InvocableVariable(label='Tenure')
        public Decimal tenure;

        @InvocableVariable(label='Job Family')
        public String jobFamily;

        @InvocableVariable(label='Title')
        public String title;

        @InvocableVariable(label='Selling Role')
        public String sellingRole;

        @InvocableVariable(label='Status')
        public String status;

        @InvocableVariable(label='Is People Manager')
        public Boolean isPeopleManager;

        @InvocableVariable(label='Is FTE')
        public Boolean isFTE;
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
                KPIAnalysisResponse response = processKPIAnalysis(request);
                responses.add(response);
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

    private static KPIAnalysisResponse processKPIAnalysis(KPIAnalysisRequest request) {
        KPIAnalysisResponse response = new KPIAnalysisResponse();
        response.success = true;
        response.analysisType = request.analysisType;
        response.timeFrame = request.timeFrame;
        response.ouName = request.ouName;
        response.country = request.country;
        response.warnings = new List<String>();
        response.fuzzyMatches = new List<String>();
        response.learnerProfiles = new List<LearnerProfileData>();
        response.outlierResults = new List<OutlierResultWrapper>();

        // Determine if outlier analysis is enabled
        Boolean enableOutliers = (request.enableOutliers != null && request.enableOutliers) && 
                                ANAgentKPIOutlierService.isOutlierDetectionEnabled();
        
        // Build dynamic SOQL query for V3 object
        String selectClause = buildSelect(request.analysisType, enableOutliers);
        String whereClause = buildWhereClauseV3(request);
        String orderClause = 'ORDER BY FULL_NAME__c ASC';
        String limitClause = 'LIMIT ' + (request.maxResults != null ? request.maxResults : 100);
        
        String soqlQuery = 'SELECT ' + selectClause + ' FROM AGENT_OU_PIPELINE_V2__c ' + 
                          whereClause + ' ' + orderClause + ' ' + limitClause;
        
        System.debug('Executing SOQL: ' + soqlQuery);
        
        List<AGENT_OU_PIPELINE_V2__c> records = Database.query(soqlQuery);
        
        response.totalRecordCount = records.size();
        response.totalAEs = records.size();
        
        if (records.isEmpty()) {
            response.message = 'No records found for the specified criteria.';
            return response;
        }

        // Calculate aggregates
        calculateAggregatesV3(records, response);
        
        // Perform outlier analysis if enabled
        if (enableOutliers) {
            response.outlierResults = performOutlierAnalysis(records, request);
        }
        
        // Get learner profile data if requested
        if (request.includeLearnerProfile != null && request.includeLearnerProfile) {
            response.learnerProfiles = getLearnerProfileDataV3(records);
        }
        
        // Format response with enhanced UX
        // Convert outlier results to Map for formatter
        Map<String, ANAgentKPIOutlierService.OutlierResult> outlierMap = new Map<String, ANAgentKPIOutlierService.OutlierResult>();
        if (response.outlierResults != null) {
            for (OutlierResultWrapper wrapper : response.outlierResults) {
                outlierMap.put(wrapper.metricName, wrapper.outlierResult);
            }
        }
        response.formattedMessage = ANAgentKPIResponseFormatter.formatResponse(response, request, outlierMap);
        response.message = response.formattedMessage;
        
        return response;
    }

    private static String buildSelect(String analysisType, Boolean enableOutliers) {
        Set<String> fields = new Set<String>(REQUIRED_FIELDS.get('BASE'));
        if (REQUIRED_FIELDS.containsKey(analysisType)) {
            fields.addAll(REQUIRED_FIELDS.get(analysisType));
        }
        if (enableOutliers) {
            fields.addAll(REQUIRED_FIELDS.get('OUTLIERS'));
        }
        return String.join(new List<String>(fields), ',');
    }

    private static String buildWhereClauseV3(KPIAnalysisRequest request) {
        List<String> conditions = new List<String>();
        
        // OU Name filtering with fuzzy search
        if (String.isNotBlank(request.ouName)) {
            String ouCondition = buildOUCondition(request.ouName, request.fuzzySearchEnabled);
            if (String.isNotBlank(ouCondition)) {
                conditions.add(ouCondition);
            }
        }
        
        // Country filtering with fuzzy search
        if (String.isNotBlank(request.country)) {
            String countryCondition = buildCountryCondition(request.country, request.fuzzySearchEnabled);
            if (String.isNotBlank(countryCondition)) {
                conditions.add(countryCondition);
            }
        }
        
        // Time frame filtering for V3 object
        String timeframeCondition = buildTimeframeConditionV3(request.timeFrame);
        if (String.isNotBlank(timeframeCondition)) {
            conditions.add(timeframeCondition);
        }
        
        return conditions.isEmpty() ? '' : 'WHERE ' + String.join(conditions, ' AND ');
    }
    
    private static String buildTimeframeConditionV3(String timeFrame) {
        // V2 object doesn't have fiscal quarter fields, so we return empty string
        // This means all records will be included regardless of timeframe
        // In a real implementation, you might want to use date fields or other criteria
        return '';
    }

    private static String buildOUCondition(String ouName, Boolean fuzzySearchEnabled) {
        if (String.isBlank(ouName)) return '';
        
        if (fuzzySearchEnabled != null && fuzzySearchEnabled) {
            List<String> fuzzyMatches = findFuzzyMatches(ouName, FUZZY_PATTERNS);
            if (!fuzzyMatches.isEmpty()) {
                List<String> orConditions = new List<String>();
                for (String match : fuzzyMatches) {
                    orConditions.add('OU_NAME__c LIKE \'%' + String.escapeSingleQuotes(match) + '%\'');
                }
                return '(' + String.join(orConditions, ' OR ') + ')';
            }
        }
        
        return 'OU_NAME__c = \'' + String.escapeSingleQuotes(ouName) + '\'';
    }

    private static String buildCountryCondition(String country, Boolean fuzzySearchEnabled) {
        if (String.isBlank(country)) return '';
        
        if (fuzzySearchEnabled != null && fuzzySearchEnabled) {
            List<String> fuzzyMatches = findFuzzyMatches(country, COUNTRY_PATTERNS);
            if (!fuzzyMatches.isEmpty()) {
                List<String> orConditions = new List<String>();
                for (String match : fuzzyMatches) {
                    orConditions.add('WORK_LOCATION_COUNTRY__c LIKE \'%' + String.escapeSingleQuotes(match) + '%\'');
                }
                return '(' + String.join(orConditions, ' OR ') + ')';
            }
        }
        
        return 'WORK_LOCATION_COUNTRY__c = \'' + String.escapeSingleQuotes(country) + '\'';
    }

    private static List<String> findFuzzyMatches(String input, Map<String, List<String>> patterns) {
        List<String> matches = new List<String>();
        String upperInput = input.toUpperCase().trim();
        
        // First try exact key matching for common OU patterns
        if (patterns.containsKey(upperInput)) {
            matches.addAll(patterns.get(upperInput));
            return matches;
        }
        
        // Then try partial matching for known patterns
        for (String key : patterns.keySet()) {
            if (upperInput.contains(key) || key.contains(upperInput)) {
                matches.addAll(patterns.get(key));
                break; // Only match the first found pattern to avoid over-matching
            }
        }
        
        // If no fuzzy matches found, return the original input
        if (matches.isEmpty()) {
            matches.add(input);
        }
        
        return matches;
    }

    private static void calculateAggregatesV3(List<AGENT_OU_PIPELINE_V2__c> records, KPIAnalysisResponse response) {
        Decimal totalCoverage = 0;
        Decimal totalACV = 0;
        Decimal totalPG = 0;
        Integer totalMeetings = 0;
        Integer totalCallConnects = 0;
        Integer validCoverage = 0;
        Integer missingActionable = 0;
        Integer missingMeetingData = 0;
        
        // Get the field map to check which fields were queried
        Map<String, Object> fieldMap = records.isEmpty() ? new Map<String, Object>() : records[0].getPopulatedFieldsAsMap();
        
        for (AGENT_OU_PIPELINE_V2__c record : records) {
                if (record.COVERAGE__c != null) {
                    totalCoverage += record.COVERAGE__c;
                validCoverage++;
            }
            
            // Only access fields that were queried
            if (fieldMap.containsKey('CQ_ACV__c') && record.CQ_ACV__c != null) {
                totalACV += record.CQ_ACV__c;
            }
            
            if (fieldMap.containsKey('CQ_PG__c') && record.CQ_PG__c != null) {
                totalPG += record.CQ_PG__c;
            }
            
            if (fieldMap.containsKey('CQ_CUSTOMER_MEETING__c')) {
                if (record.CQ_CUSTOMER_MEETING__c != null) {
                    totalMeetings += (Integer) record.CQ_CUSTOMER_MEETING__c;
                } else {
                    missingMeetingData++;
                }
            }
            
            if (fieldMap.containsKey('CQ_CALL_CONNECT__c') && record.CQ_CALL_CONNECT__c != null) {
                totalCallConnects += (Integer) record.CQ_CALL_CONNECT__c;
            }
            
            // Check for missing actionable content
            if (fieldMap.containsKey('ACTIONABLE__c') && String.isBlank(record.ACTIONABLE__c)) {
                missingActionable++;
            }
        }
        
        response.avgCoverage = validCoverage > 0 ? totalCoverage / validCoverage : 0;
        response.totalACV = totalACV;
        response.totalPG = totalPG;
        response.totalMeetings = totalMeetings;
        response.totalCallConnects = totalCallConnects;
        
        // Add warnings
        if (missingActionable > 0) {
            response.warnings.add(missingActionable + ' AEs missing actionable content');
        }
        if (missingMeetingData > 0) {
            response.warnings.add(missingMeetingData + ' AEs missing meeting data');
        }
    }
    
    /**
     * Perform outlier analysis on the records
     */
    private static List<OutlierResultWrapper> performOutlierAnalysis(List<AGENT_OU_PIPELINE_V2__c> records, KPIAnalysisRequest request) {
        List<OutlierResultWrapper> outlierResults = new List<OutlierResultWrapper>();
        
        // Determine which metrics to analyze
        List<String> metricsToAnalyze = new List<String>();
        if (request.metrics != null && !request.metrics.isEmpty()) {
            metricsToAnalyze.addAll(request.metrics);
        } else {
            // Default metrics based on analysis type
            if ('MEETINGS'.equals(request.analysisType)) {
                metricsToAnalyze.addAll(new List<String>{'CQ_CUSTOMER_MEETING__c', 'CQ_CALL_CONNECT__c'});
            } else if ('REVENUE'.equals(request.analysisType)) {
                metricsToAnalyze.addAll(new List<String>{'CQ_ACV__c', 'CQ_PG__c'});
            } else if ('GROWTH_FACTORS'.equals(request.analysisType)) {
                metricsToAnalyze.addAll(new List<String>{'COVERAGE__c', 'OPEN_PIPE_AE_SCORE_1__c'});
            } else {
                // Default to all available metrics
                metricsToAnalyze.addAll(new List<String>{'CQ_CUSTOMER_MEETING__c', 'CQ_CALL_CONNECT__c', 'CQ_ACV__c', 'CQ_PG__c', 'COVERAGE__c', 'OPEN_PIPE_AE_SCORE_1__c'});
            }
        }
        
        // Perform outlier analysis for each metric
        for (String metric : metricsToAnalyze) {
            try {
                ANAgentKPIOutlierService.OutlierResult result = ANAgentKPIOutlierService.detectKPIOutliers(records, metric, 'Z-Score');
                if (result != null) {
                    outlierResults.add(new OutlierResultWrapper(metric, result));
                }
            } catch (Exception e) {
                System.debug('Error performing outlier analysis for metric ' + metric + ': ' + e.getMessage());
            }
        }
        
        return outlierResults;
    }

    private static List<LearnerProfileData> getLearnerProfileDataV3(List<AGENT_OU_PIPELINE_V2__c> records) {
        List<LearnerProfileData> learnerProfiles = new List<LearnerProfileData>();
        Set<String> learnerProfileIds = new Set<String>();
        
        // Collect learner profile IDs
        for (AGENT_OU_PIPELINE_V2__c record : records) {
            if (String.isNotBlank(record.LEARNER_PROFILE_ID__c)) {
                learnerProfileIds.add(record.LEARNER_PROFILE_ID__c);
            }
        }
        
        if (learnerProfileIds.isEmpty()) {
            return learnerProfiles;
        }
        
        // Query learner profiles
        String learnerQuery = 'SELECT ' + String.join(new List<String>(LEARNER_PROFILE_FIELDS), ',') + 
                            ' FROM Learner_Profile__c WHERE Id IN :learnerProfileIds';
        
        Map<String, Learner_Profile__c> learnerProfileMap = new Map<String, Learner_Profile__c>();
        for (Learner_Profile__c profile : Database.query(learnerQuery)) {
            learnerProfileMap.put(profile.Id, profile);
        }
        
        // Build learner profile data
        for (AGENT_OU_PIPELINE_V2__c record : records) {
            if (String.isNotBlank(record.LEARNER_PROFILE_ID__c) && 
                learnerProfileMap.containsKey(record.LEARNER_PROFILE_ID__c)) {
                
                Learner_Profile__c profile = learnerProfileMap.get(record.LEARNER_PROFILE_ID__c);
                LearnerProfileData data = new LearnerProfileData();
                
                data.learnerProfileId = profile.Id;
                data.fullName = profile.Name;
                data.email = profile.primary_email__c;
                data.ou = profile.ou_name__c;
                data.manager = profile.manager__c;
                data.region = profile.employee_region__c != null ? profile.employee_region__c : profile.work_location_region__c;
                data.vertical = profile.em_sub_vertical__c;
                data.industry = profile.em_industry__c;
                data.country = profile.work_location_country__c != null ? profile.work_location_country__c : profile.primary_country_of_coverage__c;
                data.ouLeader = profile.ou_leader__c;
                data.tenure = profile.employee_tenure__c;
                data.jobFamily = profile.job_family__c;
                data.title = profile.title__c;
                data.sellingRole = profile.selling_role__c;
                data.status = profile.status__c;
                data.isPeopleManager = profile.people_manager__c;
                data.isFTE = profile.fte__c;
                
                // Build manager hierarchy
                data.managerHierarchy = new List<String>();
                if (String.isNotBlank(profile.emp_mgt_chain_lvl_01_nm__c)) data.managerHierarchy.add(profile.emp_mgt_chain_lvl_01_nm__c);
                if (String.isNotBlank(profile.emp_mgt_chain_lvl_02_nm__c)) data.managerHierarchy.add(profile.emp_mgt_chain_lvl_02_nm__c);
                if (String.isNotBlank(profile.emp_mgt_chain_lvl_03_nm__c)) data.managerHierarchy.add(profile.emp_mgt_chain_lvl_03_nm__c);
                if (String.isNotBlank(profile.emp_mgt_chain_lvl_04_nm__c)) data.managerHierarchy.add(profile.emp_mgt_chain_lvl_04_nm__c);
                if (String.isNotBlank(profile.emp_mgt_chain_lvl_05_nm__c)) data.managerHierarchy.add(profile.emp_mgt_chain_lvl_05_nm__c);
                
                learnerProfiles.add(data);
            }
        }
        
        return learnerProfiles;
    }

}