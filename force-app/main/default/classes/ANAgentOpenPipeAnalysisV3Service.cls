/**
 * TEMPLATE SERVICE - Houses business logic and direct object manipulation in our handler/service pattern.
 * Business Requirement: Service methods return a single composed message string for agent consumption.
 * Handlers call into this class to perform Open Pipe Analysis operations.
 * @description Service class for Open Pipe Analysis operations on Agent_Open_Pipe__c records.
 * Handles all business logic for analyzing open pipeline data across AEs with grouping, filtering, and aggregation.
 *
 * Realism Guardrails for DAYS_IN_STAGE Analysis:
 * - Outlier cap: 540 days (18 months) to exclude ultra-outliers
 * - Minimum sample size: 3 opportunities per product for meaningful averages
 * - Uses proper AggregateResult patterns for accurate aggregation
 *
 * Key fields referenced (ONLY these allowed):
 *   - emp_id__c: Employee identifier for the AE
 *   - full_name__c: AE full name
 *   - emp_email_addr__c: AE email address
 *   - work_location_country__c: Work location country of the AE
 *   - ou_name__c: Organizational Unit (core partition filter)
 *   - emp_mgr_nm__c: Manager name of the AE
 *   - primary_industry__c: Primary industry classification
 *   - open_pipe_prod_nm__c: Product name tied to the open opportunity
 *   - open_pipe_opty_nm__c: Opportunity name
 *   - open_pipe_opty_stg_nm__c: Opportunity stage name
 *   - open_pipe_opty_days_in_stage__c: Days the opportunity has been in current stage (integer)
 *   - open_pipe_ae_score__c: AE score (decimal, typically 0-5 scale)
 *   - open_pipe_apm_l2__c: APM L2 classification/category
 *   - open_pipe_revised_sub_sector__c: Refined industry sub-sector
 *   - open_pipe_opp_manager_nt__c: Manager/representative notes on the opportunity
 *   - open_pipe_original_openpipe_alloc_amt__c: Original allocation amount (currency)
 *   - open_pipe_rn__c: Row number/rank for opportunity ordering within the pipeline
 *   - time_since_onboarding__c: Time since onboarding in months (decimal)
 *   - macrosgment__c: Macro segment classification (CMRCL, ESMB, ENTR, etc.)
 *   - learner_profile_id__c: Linked learner profile ID (enablement)
 *   - ramp_status__c: AE ramp status (Fast Ramper, etc.)
 *
 * @version 3.0
 */
public with sharing class ANAgentOpenPipeAnalysisV3Service {
    
    // Import Pattern and Matcher for regex operations
    private static final Pattern STAGE_PATTERN = Pattern.compile('open_pipe_opty_stg_nm=\'([^\']+)\'');
    
    // Field mapping constants for grouping
    private static final Map<String, String> GROUP_FIELD_MAP = new Map<String, String>{
        'STAGE' => 'open_pipe_opty_stg_nm__c',
        'PRODUCT' => 'open_pipe_prod_nm__c',
        'INDUSTRY' => 'primary_industry__c',
        'MACRO_SEGMENT' => 'macrosgment__c',
        'AE' => 'full_name__c',
        'COUNTRY' => 'work_location_country__c'
    };
    
    // Enhanced field mapping constants for filtering with aliases and common variations
    public static final Map<String, String> FILTER_FIELD_MAP = new Map<String, String>{
        // OU and Location
        'ou_name' => 'ou_name__c',
        'ou' => 'ou_name__c',
        'operating_unit' => 'ou_name__c',
        'org_unit' => 'ou_name__c',
        
        'work_location_country' => 'work_location_country__c',
        'work_location' => 'work_location_country__c',
        'country' => 'work_location_country__c',
        'location' => 'work_location_country__c',
        'work_country' => 'work_location_country__c',
        
        // Industry and Segment
        'primary_industry' => 'primary_industry__c',
        'industry' => 'primary_industry__c',
        'sector' => 'primary_industry__c',
        
        'macro_segment' => 'macrosgment__c',
        'macrosgment' => 'macrosgment__c',
        'segment' => 'macrosgment__c',
        'macro' => 'macrosgment__c',
        'business_segment' => 'macrosgment__c',
        
        // Opportunity Fields
        'open_pipe_opty_stg_nm' => 'open_pipe_opty_stg_nm__c',
        'open_pipe_oppty_stg_nm' => 'open_pipe_opty_stg_nm__c', // Fix for common typo
        'stage' => 'open_pipe_opty_stg_nm__c',
        'opportunity_stage' => 'open_pipe_opty_stg_nm__c',
        'oppty_stage' => 'open_pipe_opty_stg_nm__c',
        'opp_stage' => 'open_pipe_opty_stg_nm__c',
        'stage_name' => 'open_pipe_opty_stg_nm__c',
        
        'open_pipe_prod_nm' => 'open_pipe_prod_nm__c',
        'open_pipe_oppty_prod_nm' => 'open_pipe_prod_nm__c', // Fix for common typo
        'product' => 'open_pipe_prod_nm__c',
        'product_name' => 'open_pipe_prod_nm__c',
        'prod' => 'open_pipe_prod_nm__c',
        
        'open_pipe_opty_days_in_stage' => 'open_pipe_opty_days_in_stage__c',
        'open_pipe_oppty_days_in_stage' => 'open_pipe_opty_days_in_stage__c', // Fix for common typo
        'open_pipe_opty_days_in_stg' => 'open_pipe_opty_days_in_stage__c',
        'open_pipe_oppty_days_in_stg' => 'open_pipe_opty_days_in_stage__c', // Fix for common typo
        'open_pipe_opty_stage_days' => 'open_pipe_opty_days_in_stage__c',
        'open_pipe_oppty_stage_days' => 'open_pipe_opty_days_in_stage__c', // Fix for common typo
        'days_in_stage' => 'open_pipe_opty_days_in_stage__c',
        'stage_days' => 'open_pipe_opty_days_in_stage__c',
        'opp_days' => 'open_pipe_opty_days_in_stage__c',
        'oppty_days' => 'open_pipe_opty_days_in_stage__c',
        'days_in_stg' => 'open_pipe_opty_days_in_stage__c',
        'stg_days' => 'open_pipe_opty_days_in_stage__c',
        
        // AE Fields
        'open_pipe_ae_score' => 'open_pipe_ae_score__c',
        'open_pipe_oppty_ae_score' => 'open_pipe_ae_score__c', // Fix for common typo
        'open_pipe_ae_sc' => 'open_pipe_ae_score__c',
        'open_pipe_oppty_ae_sc' => 'open_pipe_ae_score__c', // Fix for common typo
        'ae_score' => 'open_pipe_ae_score__c',
        'score' => 'open_pipe_ae_score__c',
        'sales_score' => 'open_pipe_ae_score__c',
        'ae_sc' => 'open_pipe_ae_score__c',
        'sales_sc' => 'open_pipe_ae_score__c',
        
        'open_pipe_apm_l2' => 'open_pipe_apm_l2__c',
        'open_pipe_oppty_apm_l2' => 'open_pipe_apm_l2__c', // Fix for common typo
        'open_pipe_apm_l2_name' => 'open_pipe_apm_l2__c',
        'open_pipe_oppty_apm_l2_name' => 'open_pipe_apm_l2__c', // Fix for common typo
        'apm_l2' => 'open_pipe_apm_l2__c',
        'apm' => 'open_pipe_apm_l2__c',
        'product_category' => 'open_pipe_apm_l2__c',
        'apm_l2_name' => 'open_pipe_apm_l2__c',
        'product_cat' => 'open_pipe_apm_l2__c',
        
        'open_pipe_revised_sub_sector' => 'open_pipe_revised_sub_sector__c',
        'sub_sector' => 'open_pipe_revised_sub_sector__c',
        'vertical' => 'open_pipe_revised_sub_sector__c',
        'industry_vertical' => 'open_pipe_revised_sub_sector__c',
        
        // Amount Fields
        'open_pipe_original_openpipe_alloc_amt' => 'open_pipe_original_openpipe_alloc_amt__c',
        'amount' => 'open_pipe_original_openpipe_alloc_amt__c',
        'alloc_amt' => 'open_pipe_original_openpipe_alloc_amt__c',
        'allocation_amount' => 'open_pipe_original_openpipe_alloc_amt__c',
        'open_pipe_amount' => 'open_pipe_original_openpipe_alloc_amt__c',
        
        // Other Fields
        'emp_mgr_nm' => 'emp_mgr_nm__c',
        'manager' => 'emp_mgr_nm__c',
        'manager_name' => 'emp_mgr_nm__c',
        
        'time_since_onboarding' => 'time_since_onboarding__c',
        'onboarding_time' => 'time_since_onboarding__c',
        'tenure' => 'time_since_onboarding__c',
        
        'ramp_status' => 'ramp_status__c',
        'ramp' => 'ramp_status__c',
        'ramp_up' => 'ramp_status__c',
        'ramp_state' => 'ramp_status__c',
        'ramp_phase' => 'ramp_status__c',
        'ramp_level' => 'ramp_status__c',
        
        // Additional Common Field Variations
        'emp_id' => 'emp_id__c',
        'employee_id' => 'emp_id__c',
        'emp' => 'emp_id__c',
        
        'full_name' => 'full_name__c',
        'name' => 'full_name__c',
        'ae_name' => 'full_name__c',
        'sales_rep_name' => 'full_name__c',
        
        'emp_email_addr' => 'emp_email_addr__c',
        'email' => 'emp_email_addr__c',
        'email_addr' => 'emp_email_addr__c',
        'ae_email' => 'emp_email_addr__c',
        
        'open_pipe_opty_nm' => 'open_pipe_opty_nm__c',
        'open_pipe_oppty_nm' => 'open_pipe_opty_nm__c', // Fix for common typo
        'opportunity_name' => 'open_pipe_opty_nm__c',
        'oppty_name' => 'open_pipe_opty_nm__c',
        'opp_name' => 'open_pipe_opty_nm__c',
        'opty_nm' => 'open_pipe_opty_nm__c',
        'oppty_nm' => 'open_pipe_opty_nm__c', // Fix for common typo
        
        'open_pipe_opp_manager_nt' => 'open_pipe_opp_manager_nt__c',
        'open_pipe_oppty_manager_nt' => 'open_pipe_opp_manager_nt__c', // Fix for common typo
        'manager_notes' => 'open_pipe_opp_manager_nt__c',
        'opp_manager_notes' => 'open_pipe_opp_manager_nt__c',
        'oppty_manager_notes' => 'open_pipe_opp_manager_nt__c', // Fix for common typo
        
        'open_pipe_rn' => 'open_pipe_rn__c',
        'open_pipe_oppty_rn' => 'open_pipe_rn__c', // Fix for common typo
        'row_number' => 'open_pipe_rn__c',
        'rn' => 'open_pipe_rn__c',
        
        'learner_profile_id' => 'learner_profile_id__c',
        'learner_id' => 'learner_profile_id__c',
        'profile_id' => 'learner_profile_id__c',
        'learner_profile' => 'learner_profile_id__c'
    };
    
    /**
     * Main method to analyze Open Pipe data based on specified parameters
     * Returns a single composed message string for the agent
     */
    public static String analyzeOpenPipe(String ouName, String workLocationCountry, String groupBy, 
                                       String filterCriteria, String restrictInValuesCsv, 
                                       Boolean perAENormalize, Integer limitN, String aggregationType, String analysisType) {
        
        try {
            // Get total count first (without limit)
            Integer totalCount = getTotalCount(ouName, workLocationCountry, filterCriteria);
            
            // Build SOQL query
            String soqlQuery = buildSOQLQuery(ouName, workLocationCountry, groupBy, filterCriteria, limitN);
            
            List<Agent_Open_Pipe__c> records = executeQuery(soqlQuery);
            
            // Apply security stripping
            records = Security.stripInaccessible(AccessType.READABLE, records).getRecords();
            
            // Process results and build analysis
            return buildAnalysisMessage(records, ouName, workLocationCountry, groupBy, filterCriteria, 
                                     restrictInValuesCsv, perAENormalize, limitN, totalCount, aggregationType, analysisType);
            
        } catch (Exception e) {
            return buildErrorMessage('Open Pipe analysis failed: ' + e.getMessage());
        }
    }
    
    /**
     * Builds the SOQL query based on parameters
     */
    private static String buildSOQLQuery(String ouName, String workLocationCountry, String groupBy, 
                                       String filterCriteria, Integer limitN) {
        
        String groupField = GROUP_FIELD_MAP.get(groupBy);
        
        // Base query with required fields
        String query = 'SELECT emp_id__c, full_name__c, emp_email_addr__c, work_location_country__c, ' +
                      'ou_name__c, emp_mgr_nm__c, primary_industry__c, ' +
                      'open_pipe_prod_nm__c, open_pipe_opty_nm__c, open_pipe_opty_stg_nm__c, ' +
                      'open_pipe_opty_days_in_stage__c, open_pipe_ae_score__c, open_pipe_apm_l2__c, ' +
                      'open_pipe_revised_sub_sector__c, open_pipe_opp_manager_nt__c, ' +
                      'open_pipe_original_openpipe_alloc_amt__c, open_pipe_rn__c, time_since_onboarding__c, ' +
                      'macrosgment__c, learner_profile_id__c, ramp_status__c ' +
                      'FROM Agent_Open_Pipe__c';
        
        // Build WHERE clause
        List<String> whereClauses = new List<String>();
        
        // Add OU filter (required)
        whereClauses.add('ou_name__c = \'' + String.escapeSingleQuotes(ouName) + '\'');
        
        // Add work location country filter if provided
        if (String.isNotBlank(workLocationCountry)) {
            whereClauses.add('work_location_country__c = \'' + String.escapeSingleQuotes(workLocationCountry) + '\'');
        }
        
        // Add filter criteria if provided
        if (String.isNotBlank(filterCriteria)) {
            // Auto-correct common field name errors first
            String correctedFilter = autoCorrectFilterCriteria(filterCriteria);
            String parsedFilter = parseFilterCriteria(correctedFilter);
            if (String.isNotBlank(parsedFilter)) {
                whereClauses.add('(' + parsedFilter + ')');
            }
        }
        
        // Add null checks for grouping field
        if (String.isNotBlank(groupField)) {
            whereClauses.add(groupField + ' != null');
        }
        
        if (!whereClauses.isEmpty()) {
            query += ' WHERE ' + joinStrings(whereClauses, ' AND ');
        }
        
        // Add grouping and ordering
        query += ' ORDER BY ' + groupField + ' ASC';
        
        // Add LIMIT to prevent heap size issues with large datasets
        if (limitN != null && limitN > 0) {
            // For TOP_PRODUCTS_BY_AE_SCORE analysis, we need more data to calculate averages properly
            // So we'll use a reasonable limit that allows for proper analysis without overwhelming memory
            Integer queryLimit = Math.min(limitN * 100, 1000); // Max 1000 records to prevent heap issues
            query += ' LIMIT ' + queryLimit;
        } else {
            // Default limit to prevent heap issues
            query += ' LIMIT 1000';
        }
        
        return query;
    }
    
    /**
     * Executes the SOQL query and returns actual records
     */
    private static List<Agent_Open_Pipe__c> executeQuery(String soqlQuery) {
        try {
            // Execute the query and return actual records
            return Database.query(soqlQuery);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Query execution failed: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Query: ' + soqlQuery);
            return new List<Agent_Open_Pipe__c>();
        }
    }
    
    /**
     * Gets the total count of records matching the criteria
     */
    private static Integer getTotalCount(String ouName, String workLocationCountry, String filterCriteria) {
        try {
            String countQuery = 'SELECT COUNT() FROM Agent_Open_Pipe__c';
            
            List<String> whereClauses = new List<String>();
            whereClauses.add('ou_name__c = \'' + String.escapeSingleQuotes(ouName) + '\'');
            
            if (String.isNotBlank(workLocationCountry)) {
                whereClauses.add('work_location_country__c = \'' + String.escapeSingleQuotes(workLocationCountry) + '\'');
            }
            
            if (String.isNotBlank(filterCriteria)) {
                // Auto-correct common field name errors first
                String correctedFilter = autoCorrectFilterCriteria(filterCriteria);
                String parsedFilter = parseFilterCriteria(correctedFilter);
                if (String.isNotBlank(parsedFilter)) {
                    whereClauses.add('(' + parsedFilter + ')');
                }
            }
            
            if (!whereClauses.isEmpty()) {
                countQuery += ' WHERE ' + joinStrings(whereClauses, ' AND ');
            }
            
            return Database.countQuery(countQuery);
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Count query failed: ' + e.getMessage());
            return 0;
        }
    }
    
    /**
     * Builds the complete analysis message
     */
    private static String buildAnalysisMessage(List<Agent_Open_Pipe__c> records, String ouName, String workLocationCountry, 
                                             String groupBy, String filterCriteria, String restrictInValuesCsv, 
                                             Boolean perAENormalize, Integer limitN, Integer totalCount, 
                                             String aggregationType, String analysisType) {
        
        String message = '# Open Pipe Analysis\n\n';
        
        // Summary section
        message += '## Summary\n';
        message += '- **OU**: ' + ouName + '\n';
        message += '- **Grouped By**: ' + groupBy + '\n';
        message += '- **Analysis Type**: ' + analysisType + '\n';
        if (String.isNotBlank(filterCriteria)) {
            message += '- **Filter**: ' + filterCriteria + '\n';
        }
        message += '- **Per-AE Normalized**: ' + (perAENormalize ? 'Yes' : 'No') + '\n';
        message += '- **Total Records Found**: ' + totalCount + '\n';
        if (limitN != null) {
            message += '- **Limit Applied**: ' + limitN + '\n';
        }
        message += '\n';
        
        // Insights section
        message += '## Insights\n';
        if (records.isEmpty()) {
            message += '- No records found matching the criteria\n';
        } else {
            message += buildInsightsByAnalysisType(records, ouName, workLocationCountry, groupBy, analysisType, limitN, filterCriteria);
        }
        message += '\n';
        
        // Limits & Counts section
        message += '## Limits & Counts\n';
        message += '- **Total Records Found**: ' + totalCount + '\n';
        message += '- **Records Shown**: ' + records.size() + ' records\n';
        if (limitN != null) {
            message += '- **Limit Applied**: ' + limitN + '\n';
        }
        message += '\n';
        
        // Data section with JSON
        message += '## Data (JSON)\n';
        message += '```json\n';
        message += buildJSONResponse(records, ouName, groupBy, analysisType, filterCriteria, 
                                  perAENormalize, totalCount, limitN, aggregationType);
        message += '\n```\n';
        
        return message;
    }
    
    /**
     * Builds insights based on analysis type
     */
    private static String buildInsightsByAnalysisType(List<Agent_Open_Pipe__c> records, String ouName, String workLocationCountry, String groupBy, String analysisType, Integer limitN, String filterCriteria) {
        switch on analysisType {
            when 'STAGE_COUNT' {
                return buildStageCountInsights(records, groupBy, limitN);
            }
            when 'PRODUCT_PERFORMANCE' {
                return buildProductPerformanceInsights(records, groupBy, limitN);
            }
            when 'AE_SCORE_ANALYSIS' {
                return buildAEScoreInsights(records, groupBy, limitN);
            }
            when 'TOP_PRODUCTS_BY_AE_SCORE' {
                return buildTopProductsByAEScoreInsights(records, groupBy, limitN);
            }
            when 'AE_ANALYSIS' {
                return buildAEAnalysisInsights(records, groupBy, limitN);
            }
            when 'DAYS_IN_STAGE' {
                // For DAYS_IN_STAGE analysis, use the new realistic aggregation helper
                // Extract stage name from filter criteria if available
                System.debug('DEBUG: filterCriteria = ' + filterCriteria);
                String stageName = extractStageNameFromFilter(filterCriteria);
                System.debug('DEBUG: extracted stageName = ' + stageName);
                if (String.isNotBlank(stageName)) {
                    System.debug('DEBUG: Using new realistic aggregation helper');
                    return aggregateDaysByProduct(ouName, workLocationCountry, stageName, limitN);
                } else {
                    System.debug('DEBUG: No stage filter found, falling back to old method');
                    // Fallback to old method if no stage filter
                    return buildDaysInStageInsights(records, groupBy, limitN);
                }
            }
            when 'OPPORTUNITY_DETAILS' {
                return buildOpportunityDetailsInsights(records, groupBy, limitN);
            }
            when else {
                return buildDefaultInsights(records, groupBy, limitN);
            }
        }
    }
    
    /**
     * Builds stage count insights
     */
    private static String buildStageCountInsights(List<Agent_Open_Pipe__c> records, String groupBy, Integer limitN) {
        Map<String, Integer> groupCounts = new Map<String, Integer>();
        
        for (Agent_Open_Pipe__c record : records) {
            String groupValue = getGroupValue(record, groupBy);
            if (String.isNotBlank(groupValue)) {
                Integer currentCount = groupCounts.containsKey(groupValue) ? groupCounts.get(groupValue) : 0;
                groupCounts.put(groupValue, currentCount + 1);
            }
        }
        
        List<String> insights = new List<String>();
        for (String groupValue : groupCounts.keySet()) {
            insights.add('- **' + groupValue + '**: ' + groupCounts.get(groupValue) + ' opportunities');
        }
        
        return String.join(insights, '\n');
    }
    
    /**
     * Builds product performance insights
     */
    private static String buildProductPerformanceInsights(List<Agent_Open_Pipe__c> records, String groupBy, Integer limitN) {
        System.debug('buildProductPerformanceInsights called with groupBy: ' + groupBy + ', limitN: ' + limitN + ', records: ' + records.size());
        
        Map<String, Decimal> groupAmounts = new Map<String, Decimal>();
        Map<String, List<Decimal>> groupAEScores = new Map<String, List<Decimal>>();
        
        for (Agent_Open_Pipe__c record : records) {
            String groupValue = getGroupValue(record, groupBy);
            Decimal amount = record.open_pipe_original_openpipe_alloc_amt__c != null ? record.open_pipe_original_openpipe_alloc_amt__c : 0;
            Decimal aeScore = record.open_pipe_ae_score__c;
            
            if (String.isNotBlank(groupValue)) {
                // Collect amounts
                Decimal currentAmount = groupAmounts.containsKey(groupValue) ? groupAmounts.get(groupValue) : 0;
                groupAmounts.put(groupValue, currentAmount + amount);
                
                // Collect AE scores
                if (!groupAEScores.containsKey(groupValue)) {
                    groupAEScores.put(groupValue, new List<Decimal>());
                }
                if (aeScore != null) {
                    groupAEScores.get(groupValue).add(aeScore);
                    System.debug('Added AE Score for ' + groupBy + ' ' + groupValue + ': ' + aeScore);
                }
            }
        }
        
        System.debug('Groups found: ' + groupAmounts.keySet());
        System.debug('Group amounts: ' + groupAmounts);
        System.debug('Group AE scores: ' + groupAEScores);
        
        List<String> insights = new List<String>();
        for (String groupValue : groupAmounts.keySet()) {
            String insight = '- **' + groupValue + '**: $' + groupAmounts.get(groupValue).setScale(2) + ' total value';
            
            // Add AE score information if available
            List<Decimal> scores = groupAEScores.get(groupValue);
            if (scores != null && !scores.isEmpty()) {
                Decimal totalScore = 0;
                Integer validScoreCount = 0;
                for (Decimal score : scores) {
                    if (score != null) {
                        totalScore += score;
                        validScoreCount++;
                    }
                }
                if (validScoreCount > 0) {
                    Decimal avgScore = totalScore / validScoreCount;
                    insight += ', Average AE Score: ' + avgScore.setScale(2);
                    System.debug('Group ' + groupValue + ' - Total Score: ' + totalScore + ', Count: ' + validScoreCount + ', Average: ' + avgScore);
                }
            }
            
            insights.add(insight);
        }
        
        System.debug('Generated insights: ' + insights);
        return String.join(insights, '\n');
    }
    
    /**
     * Builds AE score insights
     */
    private static String buildAEScoreInsights(List<Agent_Open_Pipe__c> records, String groupBy, Integer limitN) {
        Map<String, List<Decimal>> groupScores = new Map<String, List<Decimal>>();
        
        for (Agent_Open_Pipe__c record : records) {
            String groupValue = getGroupValue(record, groupBy);
            Decimal score = record.open_pipe_ae_score__c;
            
            if (String.isNotBlank(groupValue) && score != null) {
                if (!groupScores.containsKey(groupValue)) {
                    groupScores.put(groupValue, new List<Decimal>());
                }
                List<Decimal> scores = groupScores.get(groupValue);
                scores.add(score);
            }
        }
        
        List<String> insights = new List<String>();
        for (String groupValue : groupScores.keySet()) {
            List<Decimal> scores = groupScores.get(groupValue);
            Decimal totalScore = 0;
            for (Decimal score : scores) {
                totalScore += score;
            }
            Decimal avgScore = scores.isEmpty() ? 0 : totalScore.divide(scores.size(), 2);
            insights.add('- **' + groupValue + '**: Average score ' + avgScore.setScale(2));
        }
        
        return String.join(insights, '\n');
    }
    
    /**
     * Builds top products by AE score insights (highest AE scores first)
     */
    private static String buildTopProductsByAEScoreInsights(List<Agent_Open_Pipe__c> records, String groupBy, Integer limitN) {
        System.debug('buildTopProductsByAEScoreInsights called with groupBy: ' + groupBy + ', limitN: ' + limitN + ', records: ' + records.size());
        
        // For this analysis, we need to group by PRODUCT to get top products by AE score
        if (groupBy != 'PRODUCT') {
            System.debug('Warning: Analysis type TOP_PRODUCTS_BY_AE_SCORE works best with PRODUCT grouping. Current: ' + groupBy);
            return '- **Note**: This analysis works best when grouped by PRODUCT. Current grouping: ' + groupBy;
        }
        
        Map<String, List<Decimal>> productAEScores = new Map<String, List<Decimal>>();
        Map<String, Decimal> productAmounts = new Map<String, Decimal>();
        Map<String, String> productAPML2 = new Map<String, String>();
        
        // Collect AE scores and amounts for each product
        for (Agent_Open_Pipe__c record : records) {
            String productName = record.open_pipe_prod_nm__c;
            Decimal aeScore = record.open_pipe_ae_score__c;
            Decimal amount = record.open_pipe_original_openpipe_alloc_amt__c != null ? record.open_pipe_original_openpipe_alloc_amt__c : 0;
            String apmL2 = record.open_pipe_apm_l2__c;
            
            if (String.isNotBlank(productName)) {
                // Collect AE scores
                if (!productAEScores.containsKey(productName)) {
                    productAEScores.put(productName, new List<Decimal>());
                }
                if (aeScore != null) {
                    productAEScores.get(productName).add(aeScore);
                    System.debug('Added AE Score for product ' + productName + ': ' + aeScore);
                }
                
                // Collect amounts
                Decimal currentAmount = productAmounts.containsKey(productName) ? productAmounts.get(productName) : 0;
                productAmounts.put(productName, currentAmount + amount);
                
                // Store APM L2 (first one found)
                if (!productAPML2.containsKey(productName)) {
                    productAPML2.put(productName, apmL2 != null ? apmL2 : 'Unknown Category');
                }
            }
        }
        
        System.debug('Products found: ' + productAEScores.keySet());
        System.debug('Product amounts: ' + productAmounts);
        
        // Calculate average AE scores for each product
        Map<String, Decimal> productAvgAEScores = new Map<String, Decimal>();
        for (String productName : productAEScores.keySet()) {
            List<Decimal> scores = productAEScores.get(productName);
            if (scores != null && !scores.isEmpty()) {
                Decimal totalScore = 0;
                Integer validScoreCount = 0;
                for (Decimal score : scores) {
                    if (score != null) {
                        totalScore += score;
                        validScoreCount++;
                    }
                }
                if (validScoreCount > 0) {
                    Decimal avgScore = totalScore / validScoreCount;
                    productAvgAEScores.put(productName, avgScore);
                    System.debug('Product ' + productName + ' - Total Score: ' + totalScore + ', Count: ' + validScoreCount + ', Average: ' + avgScore);
                } else {
                    productAvgAEScores.put(productName, 0);
                    System.debug('Product ' + productName + ' - No valid scores, setting to 0');
                }
            } else {
                productAvgAEScores.put(productName, 0);
                System.debug('Product ' + productName + ' - No scores list, setting to 0');
            }
        }
        
        System.debug('Product average AE scores: ' + productAvgAEScores);
        
        // Sort products by average AE score (highest first)
        List<String> sortedProducts = new List<String>(productAvgAEScores.keySet());
        sortedProducts.sort(new ProductAEScoreComparator(productAvgAEScores));
        
        System.debug('Sorted products by AE score: ' + sortedProducts);
        
        // Build insights for top N products
        List<String> insights = new List<String>();
        Integer maxProducts = limitN != null ? limitN : 5;
        
        for (Integer i = 0; i < Math.min(maxProducts, sortedProducts.size()); i++) {
            String productName = sortedProducts[i];
            Decimal avgScore = productAvgAEScores.get(productName);
            Decimal totalAmount = productAmounts.get(productName);
            String apmL2 = productAPML2.get(productName);
            
            String insight = String.format('- **{0}** ({1}): Average AE Score {2}, Total Open Pipe: ${3}', 
                new List<String>{
                    productName,
                    apmL2,
                    avgScore.setScale(2).toPlainString(),
                    totalAmount.setScale(2).toPlainString()
                });
            insights.add(insight);
        }
        
        System.debug('Generated insights: ' + insights);
        return String.join(insights, '\n');
    }
    
    /**
     * Builds days in stage insights
     */
    private static String buildDaysInStageInsights(List<Agent_Open_Pipe__c> records, String groupBy, Integer limitN) {
        Map<String, List<Integer>> groupDays = new Map<String, List<Integer>>();
        
        for (Agent_Open_Pipe__c record : records) {
            String groupValue = getGroupValue(record, groupBy);
            Integer days = record.open_pipe_opty_days_in_stage__c != null ? Integer.valueOf(record.open_pipe_opty_days_in_stage__c) : 0;
            
            if (String.isNotBlank(groupValue)) {
                if (!groupDays.containsKey(groupValue)) {
                    groupDays.put(groupValue, new List<Integer>());
                }
                List<Integer> daysList = groupDays.get(groupValue);
                daysList.add(days);
            }
        }
        
        List<String> insights = new List<String>();
        for (String groupValue : groupDays.keySet()) {
            List<Integer> days = groupDays.get(groupValue);
            Integer totalDays = 0;
            for (Integer day : days) {
                totalDays += day;
            }
            Integer avgDays = days.isEmpty() ? 0 : Math.round(totalDays / days.size());
            
            // Customize the insight message based on grouping
            String insightMessage;
            if (groupBy == 'STAGE') {
                insightMessage = '- **' + groupValue + '**: Average ' + avgDays + ' days in stage';
            } else if (groupBy == 'PRODUCT') {
                insightMessage = '- **' + groupValue + '**: Average ' + avgDays + ' days in stage';
            } else if (groupBy == 'AE') {
                insightMessage = '- **' + groupValue + '**: Average ' + avgDays + ' days in stage';
            } else {
                insightMessage = '- **' + groupValue + '**: Average ' + avgDays + ' days in stage';
            }
            
            insights.add(insightMessage);
        }
        
        return String.join(insights, '\n');
    }
    
    /**
     * Builds opportunity details insights
     */
    private static String buildOpportunityDetailsInsights(List<Agent_Open_Pipe__c> records, String groupBy, Integer limitN) {
        List<Agent_Open_Pipe__c> sortedRecords = new List<Agent_Open_Pipe__c>(records);
        sortedRecords.sort(new OpportunityValueComparator());
        
        List<String> insights = new List<String>();
        Integer count = 0;
        Integer maxCount = limitN != null ? Math.min(limitN, sortedRecords.size()) : sortedRecords.size();
        
        for (Integer i = 0; i < maxCount; i++) {
            Agent_Open_Pipe__c record = sortedRecords[i];
            String oppName = record.open_pipe_opty_nm__c != null ? record.open_pipe_opty_nm__c : 'Unnamed Opportunity';
            String stage = record.open_pipe_opty_stg_nm__c != null ? record.open_pipe_opty_stg_nm__c : 'Unknown Stage';
            Decimal amount = record.open_pipe_original_openpipe_alloc_amt__c != null ? record.open_pipe_original_openpipe_alloc_amt__c : 0;
            String ae = record.full_name__c != null ? record.full_name__c : 'Unknown AE';
            
            insights.add('- **' + oppName + '** (' + stage + '): $' + amount.setScale(2) + ' - ' + ae);
        }
        
        return String.join(insights, '\n');
    }
    
    /**
     * Builds AE analysis insights
     */
    private static String buildAEAnalysisInsights(List<Agent_Open_Pipe__c> records, String groupBy, Integer limitN) {
        String insights = '\n**AE Analysis**:\n';

        // Group records by AE
        Map<String, Integer> aeCounts = new Map<String, Integer>();
        Map<String, Set<String>> aeProducts = new Map<String, Set<String>>();
        Map<String, Set<String>> aeAccounts = new Map<String, Set<String>>();
        Map<String, String> aeEmails = new Map<String, String>();

        for (Agent_Open_Pipe__c record : records) {
            if (String.isNotBlank(record.full_name__c)) {
                String aeName = record.full_name__c;
                aeCounts.put(aeName, aeCounts.get(aeName) != null ? aeCounts.get(aeName) + 1 : 1);

                // Track unique products per AE
                if (!aeProducts.containsKey(aeName)) {
                    aeProducts.put(aeName, new Set<String>());
                }
                if (String.isNotBlank(record.open_pipe_prod_nm__c)) {
                    aeProducts.get(aeName).add(record.open_pipe_prod_nm__c);
                }

                // Track unique accounts per AE (using opportunity name as proxy for account)
                if (!aeAccounts.containsKey(aeName)) {
                    aeAccounts.put(aeName, new Set<String>());
                }
                if (String.isNotBlank(record.open_pipe_opty_nm__c)) {
                    aeAccounts.get(aeName).add(record.open_pipe_opty_nm__c);
                }

                // Track email address for AE (store first occurrence)
                if (!aeEmails.containsKey(aeName) && String.isNotBlank(record.emp_email_addr__c)) {
                    aeEmails.put(aeName, record.emp_email_addr__c);
                }
            }
        }

        // Sort by count (descending)
        List<String> sortedAEs = new List<String>(aeCounts.keySet());
        sortedAEs.sort(new AECountComparator(aeCounts));

        // Apply limit
        Integer displayLimit = limitN != null && limitN > 0 ? limitN : sortedAEs.size();
        Integer actualShown = Math.min(displayLimit, sortedAEs.size());

        for (Integer i = 0; i < actualShown; i++) {
            String aeName = sortedAEs[i];
            Integer count = aeCounts.get(aeName);
            Integer uniqueProducts = aeProducts.get(aeName).size();
            Integer uniqueAccounts = aeAccounts.get(aeName).size();
            String email = aeEmails.get(aeName);

            insights += '- **' + aeName + '**: ' + count + ' open pipeline opportunities';
            insights += ', ' + uniqueProducts + ' unique products';
            insights += ', ' + uniqueAccounts + ' unique opportunities';
            if (String.isNotBlank(email)) {
                insights += ', Email: ' + email;
            }
            insights += '\n';
        }

        if (limitN != null && limitN > 0 && sortedAEs.size() > limitN) {
            insights += '- *... and ' + (sortedAEs.size() - limitN) + ' more AEs*\n';
        }

        return insights;
    }

    /**
     * Builds default insights
     */
    private static String buildDefaultInsights(List<Agent_Open_Pipe__c> records, String groupBy, Integer limitN) {
        List<String> insights = new List<String>();
        insights.add('- Total opportunities analyzed: ' + records.size());
        
        if (groupBy == 'STAGE') {
            insights.add('- Analysis grouped by pipeline stage');
        } else if (groupBy == 'PRODUCT') {
            insights.add('- Analysis grouped by product');
        } else if (groupBy == 'AE') {
            insights.add('- Analysis grouped by Account Executive');
        }
        
        return String.join(insights, '\n');
    }
    
    /**
     * Builds JSON response for the data section
     */
    private static String buildJSONResponse(List<Agent_Open_Pipe__c> records, String ouName, String groupBy, 
                                          String analysisType, String filterCriteria, Boolean perAENormalize, 
                                          Integer totalCount, Integer limitN, String aggregationType) {
        
        Map<String, Object> response = new Map<String, Object>();
        response.put('ouName', ouName);
        response.put('groupBy', groupBy);
        response.put('analysisType', analysisType);
        response.put('filter', filterCriteria != null ? filterCriteria : '');
        response.put('perAENormalize', perAENormalize);
        response.put('totalCount', totalCount);
        response.put('limit', limitN);
        
        // Build groups based on grouping field
        Map<String, List<Map<String, Object>>> groups = new Map<String, List<Map<String, Object>>>();
        
        for (Agent_Open_Pipe__c record : records) {
            String groupValue = getGroupValue(record, groupBy);
            if (String.isNotBlank(groupValue)) {
                if (!groups.containsKey(groupValue)) {
                    groups.put(groupValue, new List<Map<String, Object>>());
                }
                
                Map<String, Object> recordData = new Map<String, Object>();
                recordData.put('opportunityName', record.open_pipe_opty_nm__c);
                recordData.put('stage', record.open_pipe_opty_stg_nm__c);
                recordData.put('product', record.open_pipe_prod_nm__c);
                recordData.put('amount', record.open_pipe_original_openpipe_alloc_amt__c);
                recordData.put('daysInStage', record.open_pipe_opty_days_in_stage__c);
                recordData.put('aeName', record.full_name__c);
                recordData.put('aeEmail', record.emp_email_addr__c);
                recordData.put('aeScore', record.open_pipe_ae_score__c);
                
                groups.get(groupValue).add(recordData);
            }
        }
        
        response.put('groups', groups);
        
        return JSON.serializePretty(response);
    }
    
    /**
     * Gets the group value for a record based on grouping field
     */
    private static String getGroupValue(Agent_Open_Pipe__c record, String groupBy) {
        switch on groupBy {
            when 'STAGE' {
                return record.open_pipe_opty_stg_nm__c;
            }
            when 'PRODUCT' {
                return record.open_pipe_prod_nm__c;
            }
            when 'INDUSTRY' {
                return record.primary_industry__c;
            }
            when 'MACRO_SEGMENT' {
                return record.macrosgment__c;
            }
            when 'AE' {
                return record.full_name__c;
            }
            when 'COUNTRY' {
                return record.work_location_country__c;
            }
            when else {
                return 'Unknown';
            }
        }
    }
    
    /**
     * Parses filter criteria and maps field names with enhanced error handling
     */
    private static String parseFilterCriteria(String filterCriteria) {
        if (String.isBlank(filterCriteria)) {
            return '';
        }
        
        String parsedFilter = filterCriteria;
        List<String> corrections = new List<String>();
        
        // Replace field aliases with actual field names
        for (String alias : FILTER_FIELD_MAP.keySet()) {
            String fieldName = FILTER_FIELD_MAP.get(alias);
            // Use word boundaries to avoid partial replacements
            if (parsedFilter.toLowerCase().contains(alias.toLowerCase())) {
                String originalFilter = parsedFilter;
                parsedFilter = parsedFilter.replaceAll('(?i)\\b' + alias + '\\b', fieldName);
                
                // Track corrections for logging
                if (!originalFilter.equals(parsedFilter)) {
                    corrections.add(alias + ' → ' + fieldName);
                }
            }
        }
        
        // Log field name corrections for debugging
        if (!corrections.isEmpty()) {
            System.debug('Field name corrections applied: ' + corrections);
        }
        
        return parsedFilter;
    }
    
    /**
     * Joins strings with a separator
     */
    private static String joinStrings(List<String> strings, String separator) {
        if (strings == null || strings.isEmpty()) {
            return '';
        }
        
        String result = strings[0];
        for (Integer i = 1; i < strings.size(); i++) {
            result += separator + strings[i];
        }
        
        return result;
    }
    
    /**
     * Builds error message
     */
    private static String buildErrorMessage(String errorMessage) {
        return '# Open Pipe Analysis\n\n## Error\n' + errorMessage;
    }
    
    /**
     * Comparator for sorting opportunities by value
     */
    public class OpportunityValueComparator implements Comparator<Agent_Open_Pipe__c> {
        public Integer compare(Agent_Open_Pipe__c a, Agent_Open_Pipe__c b) {
            Decimal amountA = a.open_pipe_original_openpipe_alloc_amt__c != null ? a.open_pipe_original_openpipe_alloc_amt__c : 0;
            Decimal amountB = b.open_pipe_original_openpipe_alloc_amt__c != null ? b.open_pipe_original_openpipe_alloc_amt__c : 0;
            
            if (amountA > amountB) return -1;
            if (amountA < amountB) return 1;
            return 0;
        }
    }

    /**
     * Comparator class for sorting AEs by count (descending)
     */
    public class AECountComparator implements Comparator<String> {
        private Map<String, Integer> countMap;

        public AECountComparator(Map<String, Integer> countMap) {
            this.countMap = countMap;
        }

        public Integer compare(String a, String b) {
            Integer countA = countMap.get(a) != null ? countMap.get(a) : 0;
            Integer countB = countMap.get(b) != null ? countMap.get(b) : 0;
            if (countA < countB) return 1;  // Descending order
            if (countA > countB) return -1;
            return 0;
        }
    }
    
    /**
     * Comparator for sorting products by average AE score (highest first)
     */
    public class ProductAEScoreComparator implements Comparator<String> {
        private Map<String, Decimal> avgScoreMap;

        public ProductAEScoreComparator(Map<String, Decimal> avgScoreMap) {
            this.avgScoreMap = avgScoreMap;
        }

        public Integer compare(String a, String b) {
            Decimal scoreA = avgScoreMap.get(a);
            Decimal scoreB = avgScoreMap.get(b);
            
            if (scoreA == null && scoreB == null) return 0;
            if (scoreA == null) return 1; // If A is null, B is higher
            if (scoreB == null) return -1; // If B is null, A is higher
            
            if (scoreA > scoreB) return -1; // Descending order
            if (scoreA < scoreB) return 1;
            return 0;
        }
    }
    
    /**
     * Provides field suggestions for filter criteria
     */
    public static String getFieldSuggestions(String filterCriteria) {
        String suggestions = '# Field Suggestions for Open Pipe Analysis\n\n';
        suggestions += '## Available Fields\n';
        
        for (String alias : FILTER_FIELD_MAP.keySet()) {
            String fieldName = FILTER_FIELD_MAP.get(alias);
            suggestions += '- **' + alias + '** → ' + fieldName + '\n';
        }
        
        suggestions += '\n## Example Filters\n';
        suggestions += '- `stage=\'05 - Negotiating $$ & Mutual Plan\'`\n';
        suggestions += '- `amount > 200000`\n';
        suggestions += '- `days_in_stage > 20`\n';
        suggestions += '- `ae_score > 3`\n';
        suggestions += '- `product=\'Data Cloud\'`\n';
        
        return suggestions;
    }
    
    /**
     * Validates filter criteria and provides suggestions for common errors
     */
    public static String validateFilterCriteria(String filterCriteria) {
        if (String.isBlank(filterCriteria)) {
            return 'Filter criteria cannot be empty.';
        }
        
        String validation = '# Filter Criteria Validation\n\n';
        validation += '## Input\n';
        validation += filterCriteria + '\n\n';
        
        // Check for common field name errors
        List<String> fieldSuggestions = new List<String>();
        if (filterCriteria.toLowerCase().contains('oppty')) {
            fieldSuggestions.add('⚠️ **Field Name Issue**: `oppty` should be `opty` (remove extra \'p\')');
            fieldSuggestions.add('   Correct: `open_pipe_opty_stg_nm__c` instead of `open_pipe_oppty_stg_nm`');
        }
        
        if (filterCriteria.toLowerCase().contains('stg_nm') && !filterCriteria.contains('__c')) {
            fieldSuggestions.add('⚠️ **Field Name Issue**: Missing `__c` suffix');
            fieldSuggestions.add('   Correct: `open_pipe_opty_stg_nm__c` instead of `open_pipe_opty_stg_nm`');
        }
        
        if (filterCriteria.toLowerCase().contains('prod_nm') && !filterCriteria.contains('__c')) {
            fieldSuggestions.add('⚠️ **Field Name Issue**: Missing `__c` suffix');
            fieldSuggestions.add('   Correct: `open_pipe_prod_nm__c` instead of `open_pipe_prod_nm`');
        }
        
        // Check for common syntax errors
        if (filterCriteria.contains('&&')) {
            validation += '⚠️ **Warning**: Use `AND` instead of `&&` for logical AND operations\n';
        }
        
        if (filterCriteria.contains('||')) {
            validation += '⚠️ **Warning**: Use `OR` instead of `||` for logical OR operations\n';
        }
        
        // Add field name suggestions
        if (!fieldSuggestions.isEmpty()) {
            validation += '\n## Field Name Issues Detected\n';
            for (String suggestion : fieldSuggestions) {
                validation += suggestion + '\n';
            }
        }
        
        if (filterCriteria.contains('==')) {
            validation += '⚠️ **Warning**: Use `=` instead of `==` for equality comparisons\n';
        }
        
        // Check for field name validation
        String parsedFilter = parseFilterCriteria(filterCriteria);
        if (!parsedFilter.equals(filterCriteria)) {
            validation += '✅ **Field Mapping Applied**: Field names have been mapped to API names\n';
        }
        
        validation += '\n## Available Fields\n';
        for (String alias : FILTER_FIELD_MAP.keySet()) {
            String fieldName = FILTER_FIELD_MAP.get(alias);
            validation += '- ' + alias + ' → ' + fieldName + '\n';
        }
        
        return validation;
    }
    
    /**
     * Automatically corrects common field name errors in filter criteria
     */
    public static String autoCorrectFilterCriteria(String filterCriteria) {
        if (String.isBlank(filterCriteria)) {
            return filterCriteria;
        }
        
        String correctedFilter = filterCriteria;
        List<String> corrections = new List<String>();
        
        // Common field name corrections - Comprehensive coverage
        Map<String, String> commonCorrections = new Map<String, String>{
            // Stage field variations
            'open_pipe_oppty_stg_nm' => 'open_pipe_opty_stg_nm__c',
            'open_pipe_oppty_stage_nm' => 'open_pipe_opty_stg_nm__c',
            'open_pipe_oppty_stg_name' => 'open_pipe_opty_stg_nm__c',
            'open_pipe_oppty_stage_name' => 'open_pipe_opty_stg_nm__c',
            'open_pipe_opty_stg_nm' => 'open_pipe_opty_stg_nm__c',
            'open_pipe_opty_stage_nm' => 'open_pipe_opty_stg_nm__c',
            'open_pipe_opty_stg_name' => 'open_pipe_opty_stg_nm__c',
            'open_pipe_opty_stage_name' => 'open_pipe_opty_stg_nm__c',
            
            // Product field variations
            'open_pipe_oppty_prod_nm' => 'open_pipe_prod_nm__c',
            'open_pipe_oppty_prod_name' => 'open_pipe_prod_nm__c',
            'open_pipe_prod_nm' => 'open_pipe_prod_nm__c',
            'open_pipe_prod_name' => 'open_pipe_prod_nm__c',
            
            // Days field variations
            'open_pipe_oppty_days_in_stage' => 'open_pipe_opty_days_in_stage__c',
            'open_pipe_oppty_days_in_stg' => 'open_pipe_opty_days_in_stage__c',
            'open_pipe_oppty_stage_days' => 'open_pipe_opty_days_in_stage__c',
            'open_pipe_opty_days_in_stage' => 'open_pipe_opty_days_in_stage__c',
            'open_pipe_opty_days_in_stg' => 'open_pipe_opty_days_in_stage__c',
            'open_pipe_opty_stage_days' => 'open_pipe_opty_days_in_stage__c',
            
            // Score field variations
            'open_pipe_oppty_ae_score' => 'open_pipe_ae_score__c',
            'open_pipe_oppty_ae_sc' => 'open_pipe_ae_score__c',
            'open_pipe_ae_score' => 'open_pipe_ae_score__c',
            'open_pipe_ae_sc' => 'open_pipe_ae_score__c',
            
            // APM field variations
            'open_pipe_oppty_apm_l2' => 'open_pipe_apm_l2__c',
            'open_pipe_oppty_apm_l2_name' => 'open_pipe_apm_l2__c',
            'open_pipe_apm_l2' => 'open_pipe_apm_l2__c',
            'open_pipe_apm_l2_name' => 'open_pipe_apm_l2__c',
            
            // Sub-sector field variations
            'open_pipe_oppty_revised_sub_sector' => 'open_pipe_revised_sub_sector__c',
            'open_pipe_oppty_sub_sector' => 'open_pipe_revised_sub_sector__c',
            'open_pipe_revised_sub_sector' => 'open_pipe_revised_sub_sector__c',
            'open_pipe_sub_sector' => 'open_pipe_revised_sub_sector__c',
            
            // Amount field variations
            'open_pipe_oppty_original_openpipe_alloc_amt' => 'open_pipe_original_openpipe_alloc_amt__c',
            'open_pipe_oppty_original_alloc_amt' => 'open_pipe_original_openpipe_alloc_amt__c',
            'open_pipe_oppty_alloc_amt' => 'open_pipe_original_openpipe_alloc_amt__c',
            'open_pipe_original_openpipe_alloc_amt' => 'open_pipe_original_openpipe_alloc_amt__c',
            'open_pipe_original_alloc_amt' => 'open_pipe_original_openpipe_alloc_amt__c',
            'open_pipe_alloc_amt' => 'open_pipe_original_openpipe_alloc_amt__c',
            
            // Opportunity name variations
            'open_pipe_oppty_nm' => 'open_pipe_opty_nm__c',
            'open_pipe_opty_nm' => 'open_pipe_opty_nm__c',
            
            // Manager notes variations
            'open_pipe_oppty_manager_nt' => 'open_pipe_opp_manager_nt__c',
            'open_pipe_opp_manager_nt' => 'open_pipe_opp_manager_nt__c',
            
            // Row number variations
            'open_pipe_oppty_rn' => 'open_pipe_rn__c',
            'open_pipe_rn' => 'open_pipe_rn__c'
        };
        
        for (String wrongField : commonCorrections.keySet()) {
            String correctField = commonCorrections.get(wrongField);
            if (correctedFilter.toLowerCase().contains(wrongField.toLowerCase())) {
                String originalFilter = correctedFilter;
                correctedFilter = correctedFilter.replaceAll('(?i)\\b' + wrongField + '\\b', correctField);
                
                if (!originalFilter.equals(correctedFilter)) {
                    corrections.add(wrongField + ' → ' + correctField);
                }
            }
        }
        
        if (!corrections.isEmpty()) {
            System.debug('Auto-corrected field names: ' + corrections);
        }
        
        return correctedFilter;
    }
    
    /**
     * Helper method to aggregate days by product with realism guardrails
     * Applies outlier caps, minimum sample sizes, and returns realistic metrics
     */
    private static String aggregateDaysByProduct(String ouName, String workLocationCountry, String stageName, Integer limitN) {
        // Realism guardrails
        Integer maxDaysCap = 540;  // Cap at 18 months to exclude ultra-outliers
        Integer minN = 3;          // Minimum sample size for meaningful averages
        
        String query = 'SELECT open_pipe_prod_nm__c, ' +
                      'AVG(open_pipe_opty_days_in_stage__c) avgDays, ' +
                      'COUNT(Id) oppCount ' +
                      'FROM Agent_Open_Pipe__c ' +
                      'WHERE ou_name__c = \'' + String.escapeSingleQuotes(ouName) + '\' ' +
                      'AND open_pipe_opty_stg_nm__c = \'' + String.escapeSingleQuotes(stageName) + '\' ' +
                      'AND open_pipe_opty_days_in_stage__c != NULL ' +
                      'AND open_pipe_opty_days_in_stage__c <= ' + maxDaysCap + ' ' +
                      'AND open_pipe_prod_nm__c != NULL ' +
                      'GROUP BY open_pipe_prod_nm__c ' +
                      'HAVING COUNT(Id) >= ' + minN + ' ' +
                      'ORDER BY AVG(open_pipe_opty_days_in_stage__c) DESC ' +
                      'LIMIT ' + limitN;
        
        List<AggregateResult> aggregatedData = Database.query(query);
        
        if (aggregatedData.isEmpty()) {
            return 'No products found with sufficient data (min ' + minN + ' opportunities, max ' + maxDaysCap + ' days cap)';
        }
        
        List<String> insights = new List<String>();
        insights.add('**Top ' + aggregatedData.size() + ' products by average days in stage (cap=' + maxDaysCap + ' days, minN=' + minN + '):**');
        
        for (AggregateResult agg : aggregatedData) {
            String product = (String) agg.get('open_pipe_prod_nm__c');
            Decimal avgDays = (Decimal) agg.get('avgDays');
            Integer oppCount = (Integer) agg.get('oppCount');
            
            // Round to 1 decimal place for readability
            Decimal roundedDays = avgDays.setScale(1, RoundingMode.HALF_UP);
            
            insights.add('- **' + product + '**: Average ' + roundedDays + ' days (N=' + oppCount + ')');
        }
        
        return String.join(insights, '\n');
    }
    
    /**
     * Extracts stage name from filter criteria for DAYS_IN_STAGE analysis
     */
    private static String extractStageNameFromFilter(String filterCriteria) {
        if (String.isBlank(filterCriteria)) {
            return null;
        }
        
        // Look for stage filter patterns
        if (filterCriteria.contains('open_pipe_opty_stg_nm=')) {
            // Extract the stage name from the filter using the pre-compiled pattern
            Matcher m = STAGE_PATTERN.matcher(filterCriteria);
            
            if (m.find()) {
                return m.group(1);
            }
        }
        
        return null;
    }
} 