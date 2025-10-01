/**
 * TEMPLATE SERVICE - Houses business logic and direct object manipulation in our handler/service pattern.
 * Business Requirement: Service methods return a single composed message string for agent consumption.
 * Handlers call into this class to perform Open Pipe Analysis operations.
 * @description Service class for Open Pipe Analysis operations on Agent_Open_Pipe__c records.
 * Handles all business logic for analyzing open pipeline data across AEs with grouping, filtering, and aggregation.
 *
 * Realism Guardrails for DAYS_IN_STAGE Analysis:
 * - Outlier cap: 200 days to exclude ultra-outliers for stagnation analysis
 * - Minimum sample size: 2 opportunities per product for meaningful averages
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
    
    // OU Alias Mapping - Handle different naming conventions users might use
    private static final Map<String, String> OU_ALIAS_MAP = new Map<String, String>{
        // AMER SMB aliases
        'AMER SMB' => 'SMB - AMER SMB',
        'AMER_SMB' => 'SMB - AMER SMB',
        'AMERSMB' => 'SMB - AMER SMB',
        'SMB AMER' => 'SMB - AMER SMB',
        'SMB_AMER' => 'SMB - AMER SMB',
        'SMBAMER' => 'SMB - AMER SMB',
        
        // EMEA SMB aliases
        'EME SMB' => 'SMB - EMEA SMB',
        'EME_SMB' => 'SMB - EMEA SMB',
        'EMESMB' => 'SMB - EMEA SMB',
        'SMB EME' => 'SMB - EMEA SMB',
        'SMB_EME' => 'SMB - EMEA SMB',
        'SMBEME' => 'SMB - EMEA SMB',
        
        // PubSec aliases
        'Pubsec' => 'PubSec+.Org',
        'PUBSEC' => 'PubSec+.Org',
        'PubSec' => 'PubSec+.Org',
        'pubsec' => 'PubSec+.Org',
        'PUB_SEC' => 'PubSec+.Org',
        'PUB_SEC_PLUS' => 'PubSec+.Org',
        
        // South Asia aliases
        'South Asia' => 'South Asia - India',
        'SOUTH ASIA' => 'South Asia - India',
        'south_asia' => 'South Asia - India',
        'SouthAsia' => 'South Asia - India',
        'SOUTHASIA' => 'South Asia - India',
        
        // ASEAN aliases
        'ASEAN' => 'South Asia - ASEAN',
        'asean' => 'South Asia - ASEAN',
        'SOUTH_ASIA_ASEAN' => 'South Asia - ASEAN',
        'SOUTH_ASIA_ASEAN' => 'South Asia - ASEAN',
        
        // NextGen aliases
        'Next Gen' => 'NextGen Platform',
        'NextGen' => 'NextGen Platform',
        'NEXTGEN' => 'NextGen Platform',
        'next_gen' => 'NextGen Platform',
        'NEXT_GEN' => 'NextGen Platform',
        'NEXT_GEN_PLATFORM' => 'NextGen Platform',
        
        // Standard OUs (no aliases needed, but included for completeness)
        'AMER ACC' => 'AMER ACC',
        'AMER_REG' => 'AMER REG',
        'AMERREG' => 'AMER REG',
        'AMER ICE' => 'AMER ICE',
        'AMER_ICE' => 'AMER ICE',
        'AMERICE' => 'AMER ICE',
        'UKI' => 'UKI',
        'LATAM' => 'LATAM',
        'ANZ' => 'ANZ',
        'EMEA Central' => 'EMEA Central',
        'EMEA_CENTRAL' => 'EMEA Central',
        'EMEA_CENTRAL' => 'EMEA Central',
        'EMEA South' => 'EMEA South',
        'EMEA_SOUTH' => 'EMEA South',
        'EMEA North' => 'EMEA North',
        'EMEA_NORTH' => 'EMEA North',
        'North Asia' => 'North Asia',
        'NORTH_ASIA' => 'North Asia',
        'France' => 'France',
        'Unmapped' => 'Unmapped'
    };
    
    // Field mapping constants for grouping
    private static final Map<String, String> GROUP_FIELD_MAP = new Map<String, String>{
        'STAGE' => 'OPEN_PIPE_OPTY_STG_NM__c',
        'PRODUCT' => 'OPEN_PIPE_PROD_NM__c',
        'INDUSTRY' => 'PRIMARY_INDUSTRY__c',
        'MACRO_SEGMENT' => 'MACROSGMENT__c',
        'AE' => 'FULL_NAME__c',
        'COUNTRY' => 'WORK_LOCATION_COUNTRY__c'
    };
    
    // Enhanced field mapping constants for filtering with aliases and common variations
    public static final Map<String, String> FILTER_FIELD_MAP = new Map<String, String>{
        // OU and Location
        'ou_name' => 'OU_NAME__c',
        'ou' => 'OU_NAME__c',
        'operating_unit' => 'OU_NAME__c',
        'org_unit' => 'OU_NAME__c',
        
        'work_location_country' => 'WORK_LOCATION_COUNTRY__c',
        'work_location' => 'WORK_LOCATION_COUNTRY__c',
        'country' => 'WORK_LOCATION_COUNTRY__c',
        'location' => 'WORK_LOCATION_COUNTRY__c',
        'work_country' => 'WORK_LOCATION_COUNTRY__c',
        
        // Industry and Segment
        'primary_industry' => 'PRIMARY_INDUSTRY__c',
        'industry' => 'PRIMARY_INDUSTRY__c',
        'sector' => 'PRIMARY_INDUSTRY__c',
        
        'macro_segment' => 'MACROSGMENT__c',
        'macrosgment' => 'MACROSGMENT__c',
        'segment' => 'MACROSGMENT__c',
        'macro' => 'MACROSGMENT__c',
        'business_segment' => 'MACROSGMENT__c',
        
        // Opportunity Fields
        'open_pipe_opty_stg_nm' => 'OPEN_PIPE_OPTY_STG_NM__c',
        'open_pipe_oppty_stg_nm' => 'OPEN_PIPE_OPTY_STG_NM__c', // Fix for common typo
        'stage' => 'OPEN_PIPE_OPTY_STG_NM__c',
        'opportunity_stage' => 'OPEN_PIPE_OPTY_STG_NM__c',
        'oppty_stage' => 'OPEN_PIPE_OPTY_STG_NM__c',
        'opp_stage' => 'OPEN_PIPE_OPTY_STG_NM__c',
        'stage_name' => 'OPEN_PIPE_OPTY_STG_NM__c',
        
        'open_pipe_prod_nm' => 'OPEN_PIPE_PROD_NM__c',
        'open_pipe_oppty_prod_nm' => 'OPEN_PIPE_PROD_NM__c', // Fix for common typo
        'product' => 'OPEN_PIPE_PROD_NM__c',
        'product_name' => 'OPEN_PIPE_PROD_NM__c',
        'prod' => 'OPEN_PIPE_PROD_NM__c',
        
        'open_pipe_opty_days_in_stage' => 'OPEN_PIPE_OPTY_DAYS_IN_STAGE__c',
        'open_pipe_oppty_days_in_stage' => 'OPEN_PIPE_OPTY_DAYS_IN_STAGE__c', // Fix for common typo
        'open_pipe_opty_days_in_stg' => 'OPEN_PIPE_OPTY_DAYS_IN_STAGE__c',
        'open_pipe_oppty_days_in_stg' => 'OPEN_PIPE_OPTY_DAYS_IN_STAGE__c', // Fix for common typo
        'open_pipe_opty_stage_days' => 'OPEN_PIPE_OPTY_DAYS_IN_STAGE__c',
        'open_pipe_oppty_stage_days' => 'OPEN_PIPE_OPTY_DAYS_IN_STAGE__c', // Fix for common typo
        'days_in_stage' => 'OPEN_PIPE_OPTY_DAYS_IN_STAGE__c',
        'stage_days' => 'OPEN_PIPE_OPTY_DAYS_IN_STAGE__c',
        'opp_days' => 'OPEN_PIPE_OPTY_DAYS_IN_STAGE__c',
        'oppty_days' => 'OPEN_PIPE_OPTY_DAYS_IN_STAGE__c',
        'days_in_stg' => 'OPEN_PIPE_OPTY_DAYS_IN_STAGE__c',
        'stg_days' => 'OPEN_PIPE_OPTY_DAYS_IN_STAGE__c',
        
        // AE Fields
        'open_pipe_ae_score' => 'OPEN_PIPE_AE_SCORE__c',
        'open_pipe_oppty_ae_score' => 'OPEN_PIPE_AE_SCORE__c', // Fix for common typo
        'open_pipe_ae_sc' => 'OPEN_PIPE_AE_SCORE__c',
        'open_pipe_oppty_ae_sc' => 'OPEN_PIPE_AE_SCORE__c', // Fix for common typo
        'ae_score' => 'OPEN_PIPE_AE_SCORE__c',
        'score' => 'OPEN_PIPE_AE_SCORE__c',
        'sales_score' => 'OPEN_PIPE_AE_SCORE__c',
        'ae_sc' => 'OPEN_PIPE_AE_SCORE__c',
        'sales_sc' => 'OPEN_PIPE_AE_SCORE__c',
        
        'open_pipe_apm_l2' => 'OPEN_PIPE_APM_L2__c',
        'open_pipe_oppty_apm_l2' => 'OPEN_PIPE_APM_L2__c', // Fix for common typo
        'open_pipe_apm_l2_name' => 'OPEN_PIPE_APM_L2__c',
        'open_pipe_oppty_apm_l2_name' => 'OPEN_PIPE_APM_L2__c', // Fix for common typo
        'apm_l2' => 'OPEN_PIPE_APM_L2__c',
        'apm' => 'OPEN_PIPE_APM_L2__c',
        'product_category' => 'OPEN_PIPE_APM_L2__c',
        'apm_l2_name' => 'OPEN_PIPE_APM_L2__c',
        'product_cat' => 'OPEN_PIPE_APM_L2__c',
        
        'open_pipe_revised_sub_sector' => 'OPEN_PIPE_REVISED_SUB_SECTOR__c',
        'sub_sector' => 'OPEN_PIPE_REVISED_SUB_SECTOR__c',
        'vertical' => 'OPEN_PIPE_REVISED_SUB_SECTOR__c',
        'industry_vertical' => 'OPEN_PIPE_REVISED_SUB_SECTOR__c',
        
        // Amount Fields
        'open_pipe_original_openpipe_alloc_amt' => 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c',
        'open_pipe_oppty_amt' => 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c', // Map to main amount field
        'open_pipe_oppty_amt_1' => 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c',
        'open_pipe_oppty_amt_2' => 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c',
        'open_pipe_oppty_amt_3' => 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c',
        'open_pipe_oppty_amt_4' => 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c',
        'open_pipe_oppty_amt_5' => 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c',
        'amount' => 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c',
        'alloc_amt' => 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c',
        'allocation_amount' => 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c',
        'open_pipe_amount' => 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c',
        
        // Other Fields
        'emp_mgr_nm' => 'EMP_MGR_NM__c',
        'manager' => 'EMP_MGR_NM__c',
        'manager_name' => 'EMP_MGR_NM__c',
        
        'time_since_onboarding' => 'TIME_SINCE_ONBOARDING__c',
        'onboarding_time' => 'TIME_SINCE_ONBOARDING__c',
        'tenure' => 'TIME_SINCE_ONBOARDING__c',
        
        'ramp_status' => 'RAMP_STATUS__c',
        'ramp' => 'RAMP_STATUS__c',
        'ramp_up' => 'RAMP_STATUS__c',
        'ramp_state' => 'RAMP_STATUS__c',
        'ramp_phase' => 'RAMP_STATUS__c',
        'ramp_level' => 'RAMP_STATUS__c',
        
        // Additional Common Field Variations
        'emp_id' => 'EMP_ID__c',
        'employee_id' => 'EMP_ID__c',
        'emp' => 'EMP_ID__c',
        
        'full_name' => 'FULL_NAME__c',
        'name' => 'FULL_NAME__c',
        'ae_name' => 'FULL_NAME__c',
        'sales_rep_name' => 'FULL_NAME__c',
        
        'emp_email_addr' => 'EMP_EMAIL_ADDR__c',
        'email' => 'EMP_EMAIL_ADDR__c',
        'email_addr' => 'EMP_EMAIL_ADDR__c',
        'ae_email' => 'EMP_EMAIL_ADDR__c',
        
        'open_pipe_opty_nm' => 'OPEN_PIPE_OPTY_NM__c',
        'open_pipe_oppty_nm' => 'OPEN_PIPE_OPTY_NM__c', // Fix for common typo
        'opportunity_name' => 'OPEN_PIPE_OPTY_NM__c',
        'oppty_name' => 'OPEN_PIPE_OPTY_NM__c',
        'opp_name' => 'OPEN_PIPE_OPTY_NM__c',
        'opty_nm' => 'OPEN_PIPE_OPTY_NM__c',
        'oppty_nm' => 'OPEN_PIPE_OPTY_NM__c', // Fix for common typo
        
        'open_pipe_opp_manager_nt' => 'OPEN_PIPE_OPP_MANAGER_NT__c',
        'open_pipe_oppty_manager_nt' => 'OPEN_PIPE_OPP_MANAGER_NT__c', // Fix for common typo
        'manager_notes' => 'OPEN_PIPE_OPP_MANAGER_NT__c',
        'opp_manager_notes' => 'OPEN_PIPE_OPP_MANAGER_NT__c',
        'oppty_manager_notes' => 'OPEN_PIPE_OPP_MANAGER_NT__c', // Fix for common typo
        
        'open_pipe_rn' => 'OPEN_PIPE_RN__c',
        'open_pipe_oppty_rn' => 'OPEN_PIPE_RN__c', // Fix for common typo
        'row_number' => 'OPEN_PIPE_RN__c',
        'rn' => 'OPEN_PIPE_RN__c',
        
        'learner_profile_id' => 'LEARNER_PROFILE_ID__c',
        'learner_id' => 'LEARNER_PROFILE_ID__c',
        'profile_id' => 'LEARNER_PROFILE_ID__c',
        'learner_profile' => 'LEARNER_PROFILE_ID__c'
    };
    
    /**
     * Main method to analyze Open Pipe data based on specified parameters
     * Returns a single composed message string for the agent
     */
    public static String analyzeOpenPipe(String ouName, String workLocationCountry, String groupBy, 
                                       String filterCriteria, String restrictInValuesCsv, 
                                       Boolean perAENormalize, Integer limitN, String aggregationType, String analysisType,
                                       Boolean includeClosureProb, Boolean includeStageBottlenecks, 
                                       Boolean includePMF, Boolean includeAEBenchmarks, Boolean includeHealthScore,
                                       String includeProductListCsv, String excludeProductListCsv, Boolean requireNoProductMatch, Boolean negativeIntent) {
        
        try {
            // Apply stage name mapping to filter criteria if present
            if (String.isNotBlank(filterCriteria) && filterCriteria.contains('open_pipe_opty_stg_nm=')) {
                String originalFilter = filterCriteria;
                filterCriteria = mapStageNamesInFilter(filterCriteria);
                if (originalFilter != filterCriteria) {
                    System.debug('Stage names mapped in filter criteria: "' + originalFilter + '" → "' + filterCriteria + '"');
                }
            }
            
            // Normalize input values using naming normalizer
            String originalOUName = ouName;
            String originalCountry = workLocationCountry;
            
            ouName = ANAgentNamingNormalizer.normalizeOUName(ouName);
            workLocationCountry = ANAgentNamingNormalizer.normalizeCountry(workLocationCountry);
            
            if (originalOUName != ouName) {
                System.debug('OU name normalized from "' + originalOUName + '" to "' + ouName + '"');
            }
            if (originalCountry != workLocationCountry) {
                System.debug('Country normalized from "' + originalCountry + '" to "' + workLocationCountry + '"');
            }
            
            // Resolve OU name aliases to canonical names
            String resolvedOUName = resolveOUAlias(ouName);
            if (resolvedOUName != ouName) {
                System.debug('OU name resolved from "' + ouName + '" to "' + resolvedOUName + '"');
                ouName = resolvedOUName;
            }
            
            // Handle positive product filtering (include specific products)
            if (String.isNotBlank(includeProductListCsv)) {
                return handlePositiveProductFilters(ouName, workLocationCountry, groupBy, filterCriteria, 
                                                 restrictInValuesCsv, perAENormalize, limitN, aggregationType, analysisType,
                                                 includeClosureProb, includeStageBottlenecks, includePMF, includeAEBenchmarks, includeHealthScore,
                                                 includeProductListCsv);
            }
            
            // Handle negative filters (anti-joins)
            if (negativeIntent || requireNoProductMatch || String.isNotBlank(excludeProductListCsv)) {
                return handleNegativeFilters(ouName, workLocationCountry, groupBy, filterCriteria, 
                                          restrictInValuesCsv, perAENormalize, limitN, aggregationType, analysisType,
                                          includeClosureProb, includeStageBottlenecks, includePMF, includeAEBenchmarks, includeHealthScore,
                                          excludeProductListCsv, requireNoProductMatch, negativeIntent);
            }
            
            // Get total count first (without limit)
            Integer totalCount = getTotalCount(ouName, workLocationCountry, filterCriteria);
            
            // Build SOQL query
            String soqlQuery = buildSOQLQuery(ouName, workLocationCountry, groupBy, filterCriteria, limitN);
            
            List<Agent_Open_Pipe__c> records = executeQuery(soqlQuery);
            
            // Apply security stripping
            records = Security.stripInaccessible(AccessType.READABLE, records).getRecords();
            
            // Populate roster data from Learner_Profile__c using existing pattern
            populateRosterData(records);
            
            // Process results and build analysis
            return buildAnalysisMessage(records, ouName, workLocationCountry, groupBy, filterCriteria, 
                                     restrictInValuesCsv, perAENormalize, limitN, totalCount, aggregationType, analysisType,
                                     includeClosureProb, includeStageBottlenecks, includePMF, includeAEBenchmarks, includeHealthScore);
            
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
        String query = 'SELECT EMP_ID__c, FULL_NAME__c, EMP_EMAIL_ADDR__c, WORK_LOCATION_COUNTRY__c, ' +
                      'OU_NAME__c, EMP_MGR_NM__c, PRIMARY_INDUSTRY__c, ' +
                      'OPEN_PIPE_PROD_NM__c, OPEN_PIPE_OPTY_NM__c, OPEN_PIPE_OPTY_STG_NM__c, ' +
                      'OPEN_PIPE_OPTY_DAYS_IN_STAGE__c, OPEN_PIPE_AE_SCORE__c, OPEN_PIPE_APM_L2__c, ' +
                      'OPEN_PIPE_REVISED_SUB_SECTOR__c, OPEN_PIPE_OPP_MANAGER_NT__c, ' +
                      'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c, OPEN_PIPE_RN__c, TIME_SINCE_ONBOARDING__c, ' +
                      'MACROSGMENT__c, LEARNER_PROFILE_ID__c, RAMP_STATUS__c ' +
                      'FROM Agent_Open_Pipe__c';
        
        // Build WHERE clause
        List<String> whereClauses = new List<String>();
        
        // Add IsDeleted filter (FIXED: Always exclude deleted records)
        whereClauses.add('IsDeleted = false');
        
        // Add OU filter (required)
        whereClauses.add('OU_NAME__c = \'' + String.escapeSingleQuotes(ouName) + '\'');
        
        // Add work location country filter if provided
        if (String.isNotBlank(workLocationCountry)) {
            whereClauses.add('WORK_LOCATION_COUNTRY__c = \'' + String.escapeSingleQuotes(workLocationCountry) + '\'');
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
        
        // Note: We don't ORDER BY here since we do sorting in application logic based on the analysis type
        // This ensures consistent results regardless of limit
        
        // Add LIMIT to prevent heap size issues with large datasets
        // CRITICAL FIX: For product performance analysis, we need ALL records to properly aggregate
        // Only apply reasonable limits for other analysis types or when explicitly requested
        if (limitN != null && limitN > 0) {
            // For product performance analysis, we need ALL records to get accurate aggregation
            // Don't apply any limit for PRODUCT_PERFORMANCE analysis to ensure we get all data
            if (groupBy == 'PRODUCT') {
                // No limit for product performance analysis - we need all records for proper aggregation
                // The application-level limit will be applied after aggregation
            } else {
                // For other analysis types, use a reasonable limit
                Integer queryLimit = Math.min(limitN * 1000, 10000);
                query += ' LIMIT ' + queryLimit;
            }
        } else {
            // Default limit for non-product analysis
            if (groupBy != 'PRODUCT') {
                query += ' LIMIT 5000';
            }
            // No limit for product analysis to ensure complete data
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
     * FIXED: Now properly counts unique AEs when grouping by AE, total records otherwise
     */
    private static Integer getTotalCount(String ouName, String workLocationCountry, String filterCriteria) {
        try {
            List<String> whereClauses = new List<String>();
            whereClauses.add('OU_NAME__c = \'' + String.escapeSingleQuotes(ouName) + '\'');
            whereClauses.add('IsDeleted = false'); // FIXED: Add IsDeleted filter
            
            if (String.isNotBlank(workLocationCountry)) {
                whereClauses.add('WORK_LOCATION_COUNTRY__c = \'' + String.escapeSingleQuotes(workLocationCountry) + '\'');
            }
            
            if (String.isNotBlank(filterCriteria)) {
                // Auto-correct common field name errors first
                String correctedFilter = autoCorrectFilterCriteria(filterCriteria);
                String parsedFilter = parseFilterCriteria(correctedFilter);
                if (String.isNotBlank(parsedFilter)) {
                    whereClauses.add('(' + parsedFilter + ')');
                }
            }
            
            String whereClause = ' WHERE ' + joinStrings(whereClauses, ' AND ');
            
            // FIXED: Count unique AEs instead of total records for better accuracy
            String countQuery = 'SELECT COUNT_DISTINCT(EMP_ID__c) FROM Agent_Open_Pipe__c' + whereClause;
            
            List<AggregateResult> results = Database.query(countQuery);
            if (!results.isEmpty()) {
                return (Integer)results[0].get('expr0');
            }
            
            return 0;
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Count query failed: ' + e.getMessage());
            return 0;
        }
    }
    
    /**
     * Handles negative filters (anti-joins) for finding AEs without specific products
     * Implements robust anti-match with governor-safe patterns
     */
    private static String handleNegativeFilters(String ouName, String workLocationCountry, String groupBy, 
                                             String filterCriteria, String restrictInValuesCsv, 
                                             Boolean perAENormalize, Integer limitN, String aggregationType, String analysisType,
                                             Boolean includeClosureProb, Boolean includeStageBottlenecks, 
                                             Boolean includePMF, Boolean includeAEBenchmarks, Boolean includeHealthScore,
                                             String excludeProductListCsv, Boolean requireNoProductMatch, Boolean negativeIntent) {
        
        try {
            System.debug('Processing negative filters - OU: ' + ouName + ', ExcludeProducts: ' + excludeProductListCsv);
            
            // Parse excluded products
            List<String> excludedProducts = parseExcludeProducts(excludeProductListCsv);
            if (excludedProducts.isEmpty() && !requireNoProductMatch) {
                return buildErrorMessage('No products specified for exclusion. Please provide excludeProductListCsv or set requireNoProductMatch=true.');
            }
            
            // Build negative filter query using conditional aggregation (Option A)
            String negativeQuery = buildNegativeQuery(ouName, workLocationCountry, excludedProducts, filterCriteria);
            
            // Execute the negative filter query
            List<AggregateResult> negativeResults = Database.query(negativeQuery);
            
            if (negativeResults.isEmpty()) {
                return buildNegativeAnalysisMessage(ouName, workLocationCountry, excludedProducts, new List<Map<String, Object>>(), 0);
            }
            
            // Convert AggregateResult to Map for easier processing
            List<Map<String, Object>> aeData = new List<Map<String, Object>>();
            for (AggregateResult result : negativeResults) {
                Map<String, Object> aeInfo = new Map<String, Object>();
                aeInfo.put('aeEmail', result.get('aeEmail'));
                aeInfo.put('aeName', result.get('aeName'));
                aeInfo.put('learnerProfileId', result.get('learnerProfileId'));
                aeInfo.put('totalOpenOpps', result.get('totalOpps'));
                aeInfo.put('ouName', ouName);
                aeInfo.put('country', workLocationCountry);
                aeInfo.put('topProductInPipeline', result.get('topProduct'));
                aeData.add(aeInfo);
            }
            
            // Apply limit if specified
            if (limitN != null && limitN > 0 && aeData.size() > limitN) {
                List<Map<String, Object>> limitedData = new List<Map<String, Object>>();
                for (Integer i = 0; i < limitN && i < aeData.size(); i++) {
                    limitedData.add(aeData[i]);
                }
                aeData = limitedData;
            }
            
            return buildNegativeAnalysisMessage(ouName, workLocationCountry, excludedProducts, aeData, negativeResults.size());
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Negative filter processing failed: ' + e.getMessage());
            return buildErrorMessage('Negative filter analysis failed: ' + e.getMessage());
        }
    }
    
    /**
     * Parses comma-separated product exclusion list
     */
    private static List<String> parseExcludeProducts(String excludeProductListCsv) {
        List<String> products = new List<String>();
        
        if (String.isBlank(excludeProductListCsv)) {
            return products;
        }
        
        String[] productArray = excludeProductListCsv.split(',');
        for (String product : productArray) {
            String trimmedProduct = product.trim();
            if (String.isNotBlank(trimmedProduct)) {
                products.add(trimmedProduct);
            }
        }
        
        return products;
    }
    
    /**
     * Builds SOQL query for negative filters using conditional aggregation
     * This is the preferred approach as it's governor-safe and efficient
     */
    public static String buildNegativeQuery(String ouName, String workLocationCountry, List<String> excludedProducts, String filterCriteria) {
        
        // Build WHERE clause
        List<String> whereClauses = new List<String>();
        whereClauses.add('IsDeleted = false');
        whereClauses.add('OU_NAME__c = \'' + String.escapeSingleQuotes(ouName) + '\'');
        
        if (String.isNotBlank(workLocationCountry)) {
            whereClauses.add('WORK_LOCATION_COUNTRY__c = \'' + String.escapeSingleQuotes(workLocationCountry) + '\'');
        }
        
        // Add additional filter criteria if provided
        if (String.isNotBlank(filterCriteria)) {
            String correctedFilter = autoCorrectFilterCriteria(filterCriteria);
            String parsedFilter = parseFilterCriteria(correctedFilter);
            if (String.isNotBlank(parsedFilter)) {
                whereClauses.add('(' + parsedFilter + ')');
            }
        }
        
        // Add exclusion filter for products (using LIKE for partial matching)
        if (!excludedProducts.isEmpty()) {
            List<String> productExclusions = new List<String>();
            for (String product : excludedProducts) {
                // Use NOT LIKE for partial matching to catch variations like "Tableau Server", "Tableau Pulse", etc.
                productExclusions.add('NOT (open_pipe_prod_nm__c LIKE \'%' + String.escapeSingleQuotes(product) + '%\')');
            }
            whereClauses.add('(' + joinStrings(productExclusions, ' AND ') + ')');
        }
        
        String whereClause = ' WHERE ' + joinStrings(whereClauses, ' AND ');
        
        // Build the main query - simple aggregation without CASE statements
        String query = 'SELECT emp_email_addr__c aeEmail, full_name__c aeName, learner_profile_id__c learnerProfileId, ' +
                      'COUNT(Id) totalOpps, ' +
                      'MAX(open_pipe_prod_nm__c) topProduct ' +
                      'FROM Agent_Open_Pipe__c' + whereClause + ' ' +
                      'GROUP BY emp_email_addr__c, full_name__c, learner_profile_id__c ' +
                      'HAVING COUNT(Id) > 0';
        
        // Add ORDER BY for consistent results
        query += ' ORDER BY COUNT(Id) DESC, full_name__c ASC';
        
        return query;
    }
    
    /**
     * Builds analysis message for negative filter results
     */
    private static String buildNegativeAnalysisMessage(String ouName, String workLocationCountry, List<String> excludedProducts, 
                                                     List<Map<String, Object>> aeData, Integer totalCount) {
        
        String message = '# Negative Filter Analysis\n\n';
        
        // Summary section
        message += '## Summary\n';
        message += '- **OU**: ' + ouName + '\n';
        message += '- **Country**: ' + (String.isNotBlank(workLocationCountry) ? workLocationCountry : 'All') + '\n';
        message += '- **Excluded Products**: ' + (excludedProducts.isEmpty() ? 'None specified' : String.join(excludedProducts, ', ')) + '\n';
        message += '- **Total AEs Without Products**: ' + totalCount + '\n';
        message += '\n';
        
        // Results section
        message += '## AEs Without Specified Products\n';
        if (aeData.isEmpty()) {
            message += '- No AEs found without the specified products\n';
        } else {
            message += '| AE Name | Email | Total Open Opps | Top Product | OU | Country |\n';
            message += '|---------|-------|-----------------|-------------|----|---------|\n';
            
            for (Map<String, Object> ae : aeData) {
                String aeName = (String)ae.get('aeName');
                String aeEmail = (String)ae.get('aeEmail');
                Integer totalOpps = (Integer)ae.get('totalOpenOpps');
                String topProduct = (String)ae.get('topProductInPipeline');
                String aeOU = (String)ae.get('ouName');
                String aeCountry = (String)ae.get('country');
                
                message += '| ' + (aeName != null ? aeName : 'N/A') + ' | ';
                message += (aeEmail != null ? aeEmail : 'N/A') + ' | ';
                message += (totalOpps != null ? totalOpps : 0) + ' | ';
                message += (topProduct != null ? topProduct : 'N/A') + ' | ';
                message += (aeOU != null ? aeOU : 'N/A') + ' | ';
                message += (aeCountry != null ? aeCountry : 'N/A') + ' |\n';
            }
        }
        message += '\n';
        
        // JSON response for programmatic access
        message += '## JSON Response\n';
        message += '```json\n';
        message += buildNegativeJSONResponse(ouName, workLocationCountry, excludedProducts, aeData, totalCount);
        message += '\n```\n';
        
        return message;
    }
    
    /**
     * Builds JSON response for negative filter results
     */
    private static String buildNegativeJSONResponse(String ouName, String workLocationCountry, List<String> excludedProducts, 
                                                  List<Map<String, Object>> aeData, Integer totalCount) {
        
        Map<String, Object> response = new Map<String, Object>();
        response.put('analysisType', 'NEGATIVE_FILTER_ANALYSIS');
        response.put('ouName', ouName);
        response.put('workLocationCountry', workLocationCountry);
        response.put('excludedProducts', excludedProducts);
        response.put('totalAEsAnalyzed', totalCount);
        response.put('aesWithoutProducts', aeData);
        
        return JSON.serializePretty(response);
    }

    /**
     * Handles positive product filtering (include specific products)
     * Uses LIKE operators for partial matching to catch product variations
     */
    private static String handlePositiveProductFilters(String ouName, String workLocationCountry, String groupBy, 
                                                     String filterCriteria, String restrictInValuesCsv, 
                                                     Boolean perAENormalize, Integer limitN, String aggregationType, String analysisType,
                                                     Boolean includeClosureProb, Boolean includeStageBottlenecks, 
                                                     Boolean includePMF, Boolean includeAEBenchmarks, Boolean includeHealthScore,
                                                     String includeProductListCsv) {
        
        try {
            System.debug('Processing positive product filters - OU: ' + ouName + ', IncludeProducts: ' + includeProductListCsv);
            
            // Parse included products
            List<String> includedProducts = parseIncludeProducts(includeProductListCsv);
            if (includedProducts.isEmpty()) {
                return buildErrorMessage('No products specified for inclusion. Please provide includeProductListCsv.');
            }
            
            // Build positive filter query using LIKE for partial matching
            String positiveQuery = buildPositiveQuery(ouName, workLocationCountry, includedProducts, filterCriteria);
            
            // Execute the positive filter query
            List<AggregateResult> positiveResults = Database.query(positiveQuery);
            
            if (positiveResults.isEmpty()) {
                return buildPositiveAnalysisMessage(ouName, workLocationCountry, includedProducts, new List<Map<String, Object>>(), 0);
            }
            
            // Convert AggregateResult to Map for easier processing
            List<Map<String, Object>> aeData = new List<Map<String, Object>>();
            for (AggregateResult agg : positiveResults) {
                Map<String, Object> aeInfo = new Map<String, Object>();
                aeInfo.put('aeEmail', agg.get('aeEmail'));
                aeInfo.put('aeName', agg.get('aeName'));
                aeInfo.put('learnerProfileId', agg.get('learnerProfileId'));
                aeInfo.put('totalOpps', agg.get('totalOpps'));
                aeInfo.put('topProduct', agg.get('topProduct'));
                aeData.add(aeInfo);
            }
            
            // Apply limit if specified
            if (limitN != null && limitN > 0 && aeData.size() > limitN) {
                List<Map<String, Object>> limitedData = new List<Map<String, Object>>();
                for (Integer i = 0; i < limitN; i++) {
                    limitedData.add(aeData[i]);
                }
                aeData = limitedData;
            }
            
            return buildPositiveAnalysisMessage(ouName, workLocationCountry, includedProducts, aeData, positiveResults.size());
            
        } catch (Exception e) {
            System.debug('Error in positive product filtering: ' + e.getMessage());
            return buildErrorMessage('Positive product filtering failed: ' + e.getMessage());
        }
    }
    
    /**
     * Parses comma-separated product inclusion list
     */
    private static List<String> parseIncludeProducts(String includeProductListCsv) {
        List<String> products = new List<String>();
        
        if (String.isBlank(includeProductListCsv)) {
            return products;
        }
        
        String[] productArray = includeProductListCsv.split(',');
        for (String product : productArray) {
            String trimmedProduct = product.trim();
            if (String.isNotBlank(trimmedProduct)) {
                products.add(trimmedProduct);
            }
        }
        
        return products;
    }
    
    /**
     * Builds SOQL query for positive product filters using LIKE for partial matching
     */
    public static String buildPositiveQuery(String ouName, String workLocationCountry, List<String> includedProducts, String filterCriteria) {
        
        // Build WHERE clause
        List<String> whereClauses = new List<String>();
        whereClauses.add('IsDeleted = false');
        whereClauses.add('OU_NAME__c = \'' + String.escapeSingleQuotes(ouName) + '\'');
        
        if (String.isNotBlank(workLocationCountry)) {
            whereClauses.add('WORK_LOCATION_COUNTRY__c = \'' + String.escapeSingleQuotes(workLocationCountry) + '\'');
        }
        
        // Add additional filter criteria if provided
        if (String.isNotBlank(filterCriteria)) {
            String correctedFilter = autoCorrectFilterCriteria(filterCriteria);
            String parsedFilter = parseFilterCriteria(correctedFilter);
            if (String.isNotBlank(parsedFilter)) {
                whereClauses.add('(' + parsedFilter + ')');
            }
        }
        
        // Add inclusion filter for products (using LIKE for partial matching)
        if (!includedProducts.isEmpty()) {
            List<String> productInclusions = new List<String>();
            for (String product : includedProducts) {
                // Use LIKE for partial matching to catch variations like "Tableau Server", "Tableau Pulse", etc.
                productInclusions.add('open_pipe_prod_nm__c LIKE \'%' + String.escapeSingleQuotes(product) + '%\'');
            }
            whereClauses.add('(' + joinStrings(productInclusions, ' OR ') + ')');
        }
        
        String whereClause = ' WHERE ' + joinStrings(whereClauses, ' AND ');
        
        // Build the main query - simple aggregation
        String query = 'SELECT emp_email_addr__c aeEmail, full_name__c aeName, learner_profile_id__c learnerProfileId, ' +
                      'COUNT(Id) totalOpps, ' +
                      'MAX(open_pipe_prod_nm__c) topProduct ' +
                      'FROM Agent_Open_Pipe__c' + whereClause + ' ' +
                      'GROUP BY emp_email_addr__c, full_name__c, learner_profile_id__c ' +
                      'HAVING COUNT(Id) > 0';
        
        // Add ORDER BY for consistent results
        query += ' ORDER BY COUNT(Id) DESC, full_name__c ASC';
        
        return query;
    }
    
    /**
     * Builds analysis message for positive product filter results
     */
    private static String buildPositiveAnalysisMessage(String ouName, String workLocationCountry, List<String> includedProducts, 
                                                     List<Map<String, Object>> aeData, Integer totalCount) {
        
        String message = '# Positive Product Filter Analysis\n\n';
        
        // Summary section
        message += '## Summary\n';
        message += '**Total AEs Analyzed**: ' + totalCount + '\n';
        message += '**Grouped By**: AE\n';
        message += '**Filter Applied**: Included products containing: ' + String.join(includedProducts, ', ') + '\n';
        message += '**OU**: ' + ouName + '\n';
        if (String.isNotBlank(workLocationCountry)) {
            message += '**Country**: ' + workLocationCountry + '\n';
        }
        message += '\n';
        
        // Results section
        message += '## AEs With Specified Products\n';
        if (aeData.isEmpty()) {
            message += '- No AEs found with the specified products\n';
        } else {
            message += '| AE Name | Email | Total Open Opps | Top Product | OU | Country |\n';
            message += '|---------|-------|-----------------|-------------|----|---------|\n';
            
            for (Map<String, Object> ae : aeData) {
                String aeName = (String) ae.get('aeName');
                String aeEmail = (String) ae.get('aeEmail');
                Integer totalOpps = (Integer) ae.get('totalOpps');
                String topProduct = (String) ae.get('topProduct');
                
                message += '| ' + (aeName != null ? aeName : 'N/A') + ' | ';
                message += (aeEmail != null ? aeEmail : 'N/A') + ' | ';
                message += (totalOpps != null ? totalOpps : 0) + ' | ';
                message += (topProduct != null ? topProduct : 'N/A') + ' | ';
                message += ouName + ' | ';
                message += (workLocationCountry != null ? workLocationCountry : 'N/A') + ' |\n';
            }
        }
        
        message += '\n';
        
        // JSON response for programmatic access
        message += '## JSON Response\n';
        message += '```json\n';
        message += buildPositiveJSONResponse(ouName, workLocationCountry, includedProducts, aeData, totalCount);
        message += '\n```\n';
        
        return message;
    }
    
    /**
     * Builds JSON response for positive product filter results
     */
    private static String buildPositiveJSONResponse(String ouName, String workLocationCountry, List<String> includedProducts, 
                                                  List<Map<String, Object>> aeData, Integer totalCount) {
        
        Map<String, Object> response = new Map<String, Object>();
        response.put('analysisType', 'POSITIVE_PRODUCT_FILTER_ANALYSIS');
        response.put('ouName', ouName);
        response.put('workLocationCountry', workLocationCountry);
        response.put('includedProducts', includedProducts);
        response.put('totalAEsAnalyzed', totalCount);
        response.put('aesWithProducts', aeData);
        
        return JSON.serializePretty(response);
    }

    /**
     * Builds the complete analysis message
     */
    private static String buildAnalysisMessage(List<Agent_Open_Pipe__c> records, String ouName, String workLocationCountry, 
                                             String groupBy, String filterCriteria, String restrictInValuesCsv, 
                                             Boolean perAENormalize, Integer limitN, Integer totalCount, 
                                             String aggregationType, String analysisType,
                                             Boolean includeClosureProb, Boolean includeStageBottlenecks, 
                                             Boolean includePMF, Boolean includeAEBenchmarks, Boolean includeHealthScore) {
        
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
        message += '- **Total AEs Analyzed**: ' + totalCount + '\n'; // FIXED: More accurate description
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
        message += '- **Total AEs Analyzed**: ' + totalCount + '\n'; // FIXED: More accurate description
        message += '- **Records Shown**: ' + records.size() + ' records\n';
        if (limitN != null) {
            message += '- **Limit Applied**: ' + limitN + '\n';
        }
        message += '\n';
        
        // Intelligence capabilities sections
        if (includeClosureProb) {
            message += buildClosureProbabilitySection(records, ouName, workLocationCountry, filterCriteria);
        }
        
        if (includeStageBottlenecks) {
            message += buildStageBottleneckSection(records, ouName, workLocationCountry, filterCriteria);
        }
        
        if (includePMF) {
            message += buildProductMarketFitSection(records, ouName, workLocationCountry, filterCriteria);
        }
        
        if (includeAEBenchmarks) {
            message += buildAEBenchmarkSection(records, ouName, workLocationCountry, filterCriteria);
        }
        
        if (includeHealthScore) {
            message += buildHealthScoreSection(records, ouName, workLocationCountry, filterCriteria, 
                                            includeClosureProb, includeStageBottlenecks, includePMF, includeAEBenchmarks);
        }
        
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
                // For DAYS_IN_STAGE analysis, always use the realistic aggregation helper
                // Extract stage name from filter criteria if available
                System.debug('DEBUG: filterCriteria = ' + filterCriteria);
                String stageName = extractStageNameFromFilter(filterCriteria);
                System.debug('DEBUG: extracted stageName = ' + stageName);
                
                // Always use realistic aggregation to prevent outlier inflation
                System.debug('DEBUG: Using realistic aggregation helper with outlier filtering');
                return aggregateDaysByProductRealistic(ouName, workLocationCountry, stageName, limitN, groupBy);
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
        Map<String, Decimal> groupAmounts = new Map<String, Decimal>();
        Map<String, List<Decimal>> groupAEScores = new Map<String, List<Decimal>>();
        
        for (Agent_Open_Pipe__c record : records) {
            String groupValue = getGroupValue(record, groupBy);
            if (String.isNotBlank(groupValue)) {
                // Count opportunities
                Integer currentCount = groupCounts.containsKey(groupValue) ? groupCounts.get(groupValue) : 0;
                groupCounts.put(groupValue, currentCount + 1);
                
                // Sum amounts
                Decimal amount = record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c != null ? record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c : 0;
                Decimal currentAmount = groupAmounts.containsKey(groupValue) ? groupAmounts.get(groupValue) : 0;
                groupAmounts.put(groupValue, currentAmount + amount);
                
                // Collect AE scores
                if (!groupAEScores.containsKey(groupValue)) {
                    groupAEScores.put(groupValue, new List<Decimal>());
                }
                Decimal aeScore = record.OPEN_PIPE_AE_SCORE__c;
                if (aeScore != null) {
                    groupAEScores.get(groupValue).add(aeScore);
                }
            }
        }
        
        // Sort groups by count (descending) or amount (descending)
        List<String> sortedGroups = new List<String>(groupCounts.keySet());
        if (groupBy == 'STAGE') {
            // For stages, sort by count
            sortedGroups.sort(new CountComparator(groupCounts));
        } else {
            // For other groupings, sort by amount
            sortedGroups.sort(new AmountComparator(groupAmounts));
        }
        
        List<String> insights = new List<String>();
        Integer maxGroups = limitN != null ? limitN : sortedGroups.size();
        
        for (Integer i = 0; i < Math.min(maxGroups, sortedGroups.size()); i++) {
            String groupValue = sortedGroups[i];
            Integer count = groupCounts.get(groupValue);
            Decimal totalAmount = groupAmounts.get(groupValue);
            
            String insight = '- **' + groupValue + '**: ' + count + ' opportunities';
            if (totalAmount > 0) {
                insight += ', Total Value: $' + totalAmount.setScale(2).toPlainString();
            }
            
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
                }
            }
            
            insights.add(insight);
        }
        
        return String.join(insights, '\n');
    }
    
    /**
     * Builds product performance insights using SOQL aggregation for better performance
     */
    private static String buildProductPerformanceInsights(List<Agent_Open_Pipe__c> records, String groupBy, Integer limitN) {
        System.debug('buildProductPerformanceInsights called with groupBy: ' + groupBy + ', limitN: ' + limitN + ', records: ' + records.size());
        
        // For product performance analysis, use SOQL aggregation for better performance and accuracy
        if (groupBy == 'PRODUCT') {
            return buildProductPerformanceInsightsAggregated(limitN, records);
        }
        
        // Fallback to record-based aggregation for other grouping types
        Map<String, Decimal> groupAmounts = new Map<String, Decimal>();
        Map<String, List<Decimal>> groupAEScores = new Map<String, List<Decimal>>();
        Map<String, Integer> groupCounts = new Map<String, Integer>();
        
        for (Agent_Open_Pipe__c record : records) {
            String groupValue = getGroupValue(record, groupBy);
            
            // Use the correct amount field - ensure we're getting the right ACV value
            Decimal amount = record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c != null ? record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c : 0;
            Decimal aeScore = record.OPEN_PIPE_AE_SCORE__c;
            
            if (String.isNotBlank(groupValue) && amount > 0) { // Only include records with valid amounts
                // Collect amounts
                Decimal currentAmount = groupAmounts.containsKey(groupValue) ? groupAmounts.get(groupValue) : 0;
                groupAmounts.put(groupValue, currentAmount + amount);
                
                // Count opportunities per group
                Integer currentCount = groupCounts.containsKey(groupValue) ? groupCounts.get(groupValue) : 0;
                groupCounts.put(groupValue, currentCount + 1);
                
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
        System.debug('Group counts: ' + groupCounts);
        System.debug('Group AE scores: ' + groupAEScores);
        
        // Sort groups by amount (descending)
        List<String> sortedGroups = new List<String>(groupAmounts.keySet());
        sortedGroups.sort(new AmountComparator(groupAmounts));
        
        List<String> insights = new List<String>();
        Integer maxGroups = limitN != null ? limitN : sortedGroups.size();
        
        for (Integer i = 0; i < Math.min(maxGroups, sortedGroups.size()); i++) {
            String groupValue = sortedGroups[i];
            Decimal totalAmount = groupAmounts.get(groupValue);
            Integer count = groupCounts.get(groupValue);
            
            String insight = '- **' + groupValue + '**: Total Value: $' + totalAmount.setScale(2).toPlainString() + 
                           ' (' + count + ' opportunities)';
            
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
     * Builds product performance insights using SOQL aggregation for better performance and accuracy
     */
    private static String buildProductPerformanceInsightsAggregated(Integer limitN, List<Agent_Open_Pipe__c> records) {
        System.debug('buildProductPerformanceInsightsAggregated called with limitN: ' + limitN);
        
        try {
            // Extract OU name from the first record to make the query dynamic
            String ouName = records.isEmpty() ? 'AMER ACC' : records[0].ou_name__c;
            
            // Use SOQL aggregation to get accurate product performance data
            String query = 'SELECT open_pipe_prod_nm__c, ' +
                          'SUM(open_pipe_original_openpipe_alloc_amt__c) totalAmount, ' +
                          'COUNT(Id) oppCount, ' +
                          'AVG(open_pipe_ae_score__c) avgAEScore ' +
                          'FROM Agent_Open_Pipe__c ' +
                          'WHERE ou_name__c = \'' + String.escapeSingleQuotes(ouName) + '\' ' +
                          'AND open_pipe_prod_nm__c != NULL ' +
                          'AND open_pipe_original_openpipe_alloc_amt__c > 0 ' +
                          'GROUP BY open_pipe_prod_nm__c ' +
                          'ORDER BY SUM(open_pipe_original_openpipe_alloc_amt__c) DESC ' +
                          'LIMIT ' + (limitN != null ? limitN : 5);
            
            System.debug('Executing aggregated query: ' + query);
            List<AggregateResult> aggregatedData = Database.query(query);
            
            System.debug('Aggregated data found: ' + aggregatedData.size() + ' products');
            
            if (aggregatedData.isEmpty()) {
                return '- No products found with valid amounts';
            }
            
            List<String> insights = new List<String>();
            
            for (AggregateResult agg : aggregatedData) {
                String productName = (String) agg.get('open_pipe_prod_nm__c');
                Decimal totalAmount = (Decimal) agg.get('totalAmount');
                Integer oppCount = (Integer) agg.get('oppCount');
                Decimal avgAEScore = (Decimal) agg.get('avgAEScore');
                
                String insight = '- **' + productName + '**: Total Value: $' + totalAmount.setScale(2).toPlainString() + 
                               ' (' + oppCount + ' opportunities)';
                
                if (avgAEScore != null) {
                    insight += ', Average AE Score: ' + avgAEScore.setScale(2);
                }
                
                insights.add(insight);
                System.debug('Product: ' + productName + ', Amount: ' + totalAmount + ', Count: ' + oppCount + ', AvgScore: ' + avgAEScore);
            }
            
            System.debug('Generated aggregated insights: ' + insights);
            return String.join(insights, '\n');
            
        } catch (Exception e) {
            System.debug('Error in aggregated query: ' + e.getMessage());
            return '- Error in product performance analysis: ' + e.getMessage();
        }
    }
    
    /**
     * Builds AE score insights
     */
    private static String buildAEScoreInsights(List<Agent_Open_Pipe__c> records, String groupBy, Integer limitN) {
        Map<String, List<Decimal>> groupScores = new Map<String, List<Decimal>>();
        
        for (Agent_Open_Pipe__c record : records) {
            String groupValue = getGroupValue(record, groupBy);
            Decimal score = record.OPEN_PIPE_AE_SCORE__c;
            
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
            String productName = record.OPEN_PIPE_PROD_NM__c;
            Decimal aeScore = record.OPEN_PIPE_AE_SCORE__c;
            Decimal amount = record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c != null ? record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c : 0;
            String apmL2 = record.OPEN_PIPE_APM_L2__c;
            
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
            Integer days = record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__c != null ? Integer.valueOf(record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__c) : 0;
            
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
            String oppName = record.OPEN_PIPE_OPTY_NM__c != null ? record.OPEN_PIPE_OPTY_NM__c : 'Unnamed Opportunity';
            String stage = record.OPEN_PIPE_OPTY_STG_NM__c != null ? record.OPEN_PIPE_OPTY_STG_NM__c : 'Unknown Stage';
            Decimal amount = record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c != null ? record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c : 0;
            String ae = record.FULL_NAME__c != null ? record.FULL_NAME__c : 'Unknown AE';
            String email = record.EMP_EMAIL_ADDR__c != null ? record.EMP_EMAIL_ADDR__c : 'No email available';
            String product = record.OPEN_PIPE_PROD_NM__c != null ? record.OPEN_PIPE_PROD_NM__c : 'Unknown Product';
            
            // Build the insight with all required fields
            String insight = '- **' + oppName + '** (' + stage + '): $' + amount.setScale(2) + '\n';
            insight += '  - **AE Name**: ' + ae + '\n';
            insight += '  - **Email**: ' + email + '\n';
            insight += '  - **Product**: ' + product + '\n';
            insight += '  - **Customer Name**: ' + oppName + '\n'; // Using opportunity name as customer name
            insight += '  - **Stage**: ' + stage;
            
            insights.add(insight);
        }
        
        return String.join(insights, '\n\n');
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
            if (String.isNotBlank(record.FULL_NAME__c)) {
                String aeName = record.FULL_NAME__c;
                aeCounts.put(aeName, aeCounts.get(aeName) != null ? aeCounts.get(aeName) + 1 : 1);

                // Track unique products per AE
                if (!aeProducts.containsKey(aeName)) {
                    aeProducts.put(aeName, new Set<String>());
                }
                if (String.isNotBlank(record.OPEN_PIPE_PROD_NM__c)) {
                    aeProducts.get(aeName).add(record.OPEN_PIPE_PROD_NM__c);
                }

                // Track unique accounts per AE (using opportunity name as proxy for account)
                if (!aeAccounts.containsKey(aeName)) {
                    aeAccounts.put(aeName, new Set<String>());
                }
                if (String.isNotBlank(record.OPEN_PIPE_OPTY_NM__c)) {
                    aeAccounts.get(aeName).add(record.OPEN_PIPE_OPTY_NM__c);
                }

                // Track email address for AE (store first occurrence)
                if (!aeEmails.containsKey(aeName) && String.isNotBlank(record.EMP_EMAIL_ADDR__c)) {
                    aeEmails.put(aeName, record.EMP_EMAIL_ADDR__c);
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
                recordData.put('opportunityName', record.OPEN_PIPE_OPTY_NM__c);
                recordData.put('stage', record.OPEN_PIPE_OPTY_STG_NM__c);
                recordData.put('product', record.OPEN_PIPE_PROD_NM__c);
                recordData.put('amount', record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c);
                recordData.put('daysInStage', record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__c);
                recordData.put('aeName', record.FULL_NAME__c);
                recordData.put('aeEmail', record.EMP_EMAIL_ADDR__c);
                recordData.put('aeScore', record.OPEN_PIPE_AE_SCORE__c);
                
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
                return record.OPEN_PIPE_OPTY_STG_NM__c;
            }
            when 'PRODUCT' {
                return record.OPEN_PIPE_PROD_NM__c;
            }
            when 'INDUSTRY' {
                return record.PRIMARY_INDUSTRY__c;
            }
            when 'MACRO_SEGMENT' {
                return record.MACROSGMENT__c;
            }
            when 'AE' {
                return record.FULL_NAME__c;
            }
            when 'COUNTRY' {
                return record.WORK_LOCATION_COUNTRY__c;
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
            Decimal amountA = a.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c != null ? a.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c : 0;
            Decimal amountB = b.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c != null ? b.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c : 0;
            
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
     * Comparator for sorting groups by amount (highest first)
     */
    public class AmountComparator implements Comparator<String> {
        private Map<String, Decimal> amountMap;

        public AmountComparator(Map<String, Decimal> amountMap) {
            this.amountMap = amountMap;
        }

        public Integer compare(String a, String b) {
            Decimal amountA = amountMap.get(a);
            Decimal amountB = amountMap.get(b);
            
            if (amountA == null && amountB == null) return 0;
            if (amountA == null) return 1; // If A is null, B is higher
            if (amountB == null) return -1; // If B is null, A is higher
            
            if (amountA > amountB) return -1; // Descending order
            if (amountA < amountB) return 1;
            return 0;
        }
    }
    
    /**
     * Comparator for sorting groups by count (highest first)
     */
    public class CountComparator implements Comparator<String> {
        private Map<String, Integer> countMap;

        public CountComparator(Map<String, Integer> countMap) {
            this.countMap = countMap;
        }

        public Integer compare(String a, String b) {
            Integer countA = countMap.get(a);
            Integer countB = countMap.get(b);
            
            if (countA == null && countB == null) return 0;
            if (countA == null) return 1; // If A is null, B is higher
            if (countB == null) return -1; // If B is null, A is higher
            
            if (countA > countB) return -1; // Descending order
            if (countA < countB) return 1;
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
            // Stage field variations - Fix the common typo 'oppty' -> 'opty'
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
            'open_pipe_oppty_amt' => 'open_pipe_original_openpipe_alloc_amt__c',
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
     * Enhanced realistic aggregation method that handles all grouping types with outlier filtering
     * Applies outlier caps, minimum sample sizes, and returns realistic metrics
     */
    private static String aggregateDaysByProductRealistic(String ouName, String workLocationCountry, String stageName, Integer limitN, String groupBy) {
        // Enhanced outlier detection with aggressive approach for stagnation analysis
        Integer maxDaysCap = 200;  // Cap at 200 days for stagnation analysis to exclude ultra-outliers
        Integer minN = 2;          // Minimum sample size for meaningful averages (reduced for better coverage)
        Integer outlierThreshold = 200; // Flag records over 200 days as outliers
        
        // Determine the group field based on groupBy parameter
        String groupField;
        switch on groupBy {
            when 'PRODUCT' {
                groupField = 'OPEN_PIPE_PROD_NM__c';
            }
            when 'STAGE' {
                groupField = 'OPEN_PIPE_OPTY_STG_NM__c';
            }
            when 'AE' {
                groupField = 'FULL_NAME__c';
            }
            when 'INDUSTRY' {
                groupField = 'PRIMARY_INDUSTRY__c';
            }
            when 'COUNTRY' {
                groupField = 'WORK_LOCATION_COUNTRY__c';
            }
            when 'MACRO_SEGMENT' {
                groupField = 'MACROSGMENT__c';
            }
            when else {
                groupField = 'OPEN_PIPE_PROD_NM__c'; // Default to product
            }
        }
        
        // Build the query with realistic filtering
        String query = 'SELECT ' + groupField + ', ' +
                      'AVG(OPEN_PIPE_OPTY_DAYS_IN_STAGE__c) avgDays, ' +
                      'COUNT(Id) oppCount ' +
                      'FROM Agent_Open_Pipe__c ' +
                      'WHERE OU_NAME__c = \'' + String.escapeSingleQuotes(ouName) + '\' ' +
                      'AND OPEN_PIPE_OPTY_DAYS_IN_STAGE__c != NULL ' +
                      'AND OPEN_PIPE_OPTY_DAYS_IN_STAGE__c < ' + maxDaysCap + ' ' +
                      'AND ' + groupField + ' != NULL ';
        
        // Add stage filter if provided
        if (String.isNotBlank(stageName)) {
            query += 'AND OPEN_PIPE_OPTY_STG_NM__c = \'' + String.escapeSingleQuotes(stageName) + '\' ';
        }
        
        query += 'GROUP BY ' + groupField + ' ' +
                'HAVING COUNT(Id) >= ' + minN + ' ' +
                'ORDER BY AVG(OPEN_PIPE_OPTY_DAYS_IN_STAGE__c) DESC ' +
                'LIMIT ' + (limitN != null ? limitN : 5);
        
        List<AggregateResult> aggregatedData = Database.query(query);
        
        if (aggregatedData.isEmpty()) {
            return 'No ' + groupBy.toLowerCase() + ' found with sufficient data (min ' + minN + ' opportunities, max ' + maxDaysCap + ' days cap)';
        }
        
        List<String> insights = new List<String>();
        insights.add('**Top ' + aggregatedData.size() + ' ' + groupBy.toLowerCase() + ' by average days in stage (cap=' + maxDaysCap + ' days, minN=' + minN + '):**');
        
        for (AggregateResult agg : aggregatedData) {
            String groupValue = (String) agg.get(groupField);
            Decimal avgDays = (Decimal) agg.get('avgDays');
            Integer oppCount = (Integer) agg.get('oppCount');
            
            // Round to 1 decimal place for readability
            Decimal roundedDays = avgDays.setScale(1, RoundingMode.HALF_UP);
            
            insights.add('- **' + groupValue + '**: Average ' + roundedDays + ' days (N=' + oppCount + ')');
        }
        
        return String.join(insights, '\n');
    }
    
    /**
     * Advanced outlier detection using IQR (Interquartile Range) method
     * Removes outliers that are beyond 1.5 * IQR from the 75th percentile
     */
    private static List<Agent_Open_Pipe__c> removeOutliers(List<Agent_Open_Pipe__c> records) {
        if (records == null || records.size() < 4) {
            return records; // Need at least 4 records for meaningful outlier detection
        }
        
        // Extract days in stage values and sort them
        List<Integer> daysList = new List<Integer>();
        for (Agent_Open_Pipe__c record : records) {
            if (record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__c != null) {
                daysList.add(Integer.valueOf(record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__c));
            }
        }
        
        if (daysList.size() < 4) {
            return records;
        }
        
        daysList.sort();
        
        // Calculate quartiles
        Integer n = daysList.size();
        Integer q1Index = (n - 1) / 4;
        Integer q3Index = (3 * (n - 1)) / 4;
        
        Integer q1 = daysList[q1Index];
        Integer q3 = daysList[q3Index];
        Integer iqr = q3 - q1;
        
        // Calculate outlier bounds
        Integer lowerBound = q1 - Math.round(1.5 * iqr);
        Integer upperBound = q3 + Math.round(1.5 * iqr);
        
        // Filter out outliers
        List<Agent_Open_Pipe__c> filteredRecords = new List<Agent_Open_Pipe__c>();
        for (Agent_Open_Pipe__c record : records) {
            if (record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__c != null) {
                Integer days = Integer.valueOf(record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__c);
                if (days >= lowerBound && days <= upperBound) {
                    filteredRecords.add(record);
                }
            }
        }
        
        System.debug('Outlier detection: Original=' + records.size() + ', Filtered=' + filteredRecords.size() + 
                    ', Q1=' + q1 + ', Q3=' + q3 + ', IQR=' + iqr + 
                    ', Bounds=[' + lowerBound + ',' + upperBound + ']');
        
        return filteredRecords.size() > 0 ? filteredRecords : records; // Return original if all filtered out
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
                String extractedStage = m.group(1);
                // Map incorrect stage names to correct ones
                return mapStageName(extractedStage);
            }
        }
        
        return null;
    }
    
    /**
     * Maps stage names in filter criteria to correct database values
     * Handles common mistakes in stage name references
     */
    private static String mapStageNamesInFilter(String filterCriteria) {
        if (String.isBlank(filterCriteria)) {
            return filterCriteria;
        }
        
        // Use regex to find and replace stage names in the filter
        Pattern stagePattern = Pattern.compile('open_pipe_opty_stg_nm=\'([^\']+)\'');
        Matcher matcher = stagePattern.matcher(filterCriteria);
        
        String result = filterCriteria;
        while (matcher.find()) {
            String originalStage = matcher.group(1);
            String mappedStage = mapStageName(originalStage);
            if (originalStage != mappedStage) {
                result = result.replace('open_pipe_opty_stg_nm=\'' + originalStage + '\'', 
                                      'open_pipe_opty_stg_nm=\'' + mappedStage + '\'');
            }
        }
        
        return result;
    }
    
    /**
     * Maps incorrect stage names to correct database values
     * Handles common mistakes in stage name references
     */
    private static String mapStageName(String stageName) {
        if (String.isBlank(stageName)) {
            return stageName;
        }
        
        // Common incorrect stage name mappings
        Map<String, String> stageMappings = new Map<String, String>{
            '02 - Discovering Needs' => '02 - Determining Problem, Impact, Ideal',
            '02 - Discovery' => '02 - Determining Problem, Impact, Ideal',
            'Stage 2' => '02 - Determining Problem, Impact, Ideal',
            'stage 2' => '02 - Determining Problem, Impact, Ideal',
            'Stage 2: Discovering Needs' => '02 - Determining Problem, Impact, Ideal',
            'Stage 2: Discovery' => '02 - Determining Problem, Impact, Ideal',
            
            '03 - Validating Benefits' => '03 - Validating Benefits & Value',
            '03 - Benefits & Value' => '03 - Validating Benefits & Value',
            'Stage 3' => '03 - Validating Benefits & Value',
            'stage 3' => '03 - Validating Benefits & Value',
            
            '04 - Confirming Value' => '04 - Confirming Value With Power',
            '04 - Value With Power' => '04 - Confirming Value With Power',
            'Stage 4' => '04 - Confirming Value With Power',
            'stage 4' => '04 - Confirming Value With Power',
            
            '05 - Negotiating' => '05 - Negotiating $$ & Mutual Plan',
            '05 - Mutual Plan' => '05 - Negotiating $$ & Mutual Plan',
            'Stage 5' => '05 - Negotiating $$ & Mutual Plan',
            'stage 5' => '05 - Negotiating $$ & Mutual Plan'
        };
        
        // Check for exact matches first
        if (stageMappings.containsKey(stageName)) {
            System.debug('Stage name mapped: "' + stageName + '" → "' + stageMappings.get(stageName) + '"');
            return stageMappings.get(stageName);
        }
        
        // Check for partial matches (case insensitive)
        String lowerStageName = stageName.toLowerCase();
        for (String incorrectName : stageMappings.keySet()) {
            if (lowerStageName.contains(incorrectName.toLowerCase()) || incorrectName.toLowerCase().contains(lowerStageName)) {
                System.debug('Stage name mapped (partial): "' + stageName + '" → "' + stageMappings.get(incorrectName) + '"');
                return stageMappings.get(incorrectName);
            }
        }
        
        // Return original if no mapping found
        return stageName;
    }
    
    /**
     * Resolves OU name aliases to their canonical names
     * Handles different naming conventions users might use
     */
    private static String resolveOUAlias(String ouName) {
        if (String.isBlank(ouName)) {
            return ouName;
        }
        
        // Check if the OU name has an alias mapping
        String canonicalName = OU_ALIAS_MAP.get(ouName);
        
        if (canonicalName != null) {
            System.debug('OU Alias resolved: "' + ouName + '" → "' + canonicalName + '"');
            return canonicalName;
        }
        
        // If no alias found, return the original name
        return ouName;
    }
    
    /**
     * Enhanced input validation for Open Pipe Analysis
     */
    public class ValidationResult {
        public Boolean isValid { get; set; }
        public String errorMessage { get; set; }
        
        public ValidationResult(Boolean isValid, String errorMessage) {
            this.isValid = isValid;
            this.errorMessage = errorMessage;
        }
    }
    
    /**
     * Validate all input parameters for Open Pipe Analysis
     */
    private static ValidationResult validateInputs(String ouName, String workLocationCountry, String groupBy, 
                                                 String filterCriteria, String restrictInValuesCsv, 
                                                 Boolean perAENormalize, Integer limitN, String aggregationType, String analysisType) {
        
        // Validate required OU name
        if (String.isBlank(ouName)) {
            return new ValidationResult(false, 'Operating Unit name is required for Open Pipe Analysis.');
        }
        
        // Validate OU name format (basic check)
        if (ouName.length() < 3 || ouName.length() > 50) {
            return new ValidationResult(false, 'Operating Unit name must be between 3 and 50 characters.');
        }
        
        // Validate limitN
        if (limitN != null && (limitN < 1 || limitN > 100)) {
            return new ValidationResult(false, 'Limit must be between 1 and 100.');
        }
        
        // Validate work location country format
        if (String.isNotBlank(workLocationCountry) && workLocationCountry.length() > 50) {
            return new ValidationResult(false, 'Work location country must be 50 characters or less.');
        }
        
        // Validate filter criteria for potential SOQL injection
        if (String.isNotBlank(filterCriteria)) {
            if (filterCriteria.contains(';') || filterCriteria.contains('--') || filterCriteria.contains('/*')) {
                return new ValidationResult(false, 'Filter criteria contains potentially unsafe characters.');
            }
        }
        
        return new ValidationResult(true, '');
    }
    
    /**
     * Generate a unique request ID for tracking
     */
    private static String generateRequestId() {
        return 'REQ-' + System.currentTimeMillis() + '-' + Math.random().intValue();
    }
    
    /**
     * Get available Operating Units for error messages
     */
    private static List<String> getAvailableOUs() {
        try {
            List<String> ous = new List<String>();
            for (String ou : OU_ALIAS_MAP.values()) {
                if (!ous.contains(ou)) {
                    ous.add(ou);
                }
            }
            return ous;
        } catch (Exception e) {
            return new List<String>{'AMER ACC', 'EMEA ENTR', 'APAC INDIA'}; // Fallback
        }
    }
    
    /**
     * Build user-friendly no results message
     */
    private static String buildNoResultsMessage(String ouName, String country, Integer minStage, String timeFrame, String productListCsv) {
        String message = '📊 Open Pipe Analysis Results\n';
        message += '============================\n';
        message += 'No opportunities found matching your criteria.\n\n';
        message += 'Applied Filters:\n';
        message += '• Operating Unit: ' + ouName + '\n';
        if (String.isNotBlank(country)) {
            message += '• Country: ' + country + '\n';
        }
        if (minStage != null) {
            message += '• Minimum Stage: ' + minStage + '\n';
        }
        message += '• Time Frame: ' + timeFrame + '\n';
        if (String.isNotBlank(productListCsv)) {
            message += '• Products: ' + productListCsv + '\n';
        }
        message += '\nSuggestions:\n';
        message += '• Try expanding your search criteria\n';
        message += '• Check if the Operating Unit name is correct\n';
        message += '• Try a different time frame or remove filters\n';
        message += '• Contact your administrator if you need access to different data';
        
        return message;
    }
    
    /**
     * @description Populate roster data from Learner_Profile__c using existing pattern
     * @param records List of Agent_Open_Pipe__c records to populate
     */
    private static void populateRosterData(List<Agent_Open_Pipe__c> records) {
        if (records == null || records.isEmpty()) {
            return;
        }
        
        try {
            // Collect all LEARNER_PROFILE_ID__c values
            Set<String> profileIds = new Set<String>();
            for (Agent_Open_Pipe__c record : records) {
                if (String.isNotBlank(record.LEARNER_PROFILE_ID__c)) {
                    profileIds.add(record.LEARNER_PROFILE_ID__c);
                }
            }
            
            if (profileIds.isEmpty()) {
                return;
            }
            
            // Query Learner_Profile__c records by Name field (matching LEARNER_PROFILE_ID__c)
            Map<String, Learner_Profile__c> profileMap = new Map<String, Learner_Profile__c>();
            List<Learner_Profile__c> profiles = [
                SELECT Id, Name, Primary_Email__c, Manager__c, Manager_Email__c,
                       Work_Location_Country__c, OU_Name__c, Job_Family__c, 
                       Division__c, Is_FLM__c, FTE__c
                FROM Learner_Profile__c
                WHERE Name IN :profileIds
                AND Status__c = 'Active'
            ];
            
            for (Learner_Profile__c profile : profiles) {
                profileMap.put(profile.Name, profile);
            }
            
            // Populate roster data for each record
            for (Agent_Open_Pipe__c record : records) {
                if (String.isNotBlank(record.LEARNER_PROFILE_ID__c) && 
                    profileMap.containsKey(record.LEARNER_PROFILE_ID__c)) {
                    Learner_Profile__c profile = profileMap.get(record.LEARNER_PROFILE_ID__c);
                    // Note: Agent_Open_Pipe__c doesn't have roster fields to populate
                    // The roster data is available in the profile for future use
                    // This method establishes the join pattern for consistency
                }
            }
            
        } catch (Exception e) {
            System.debug('Error populating roster data: ' + e.getMessage());
        }
    }
    
    // Intelligence Capability Methods
    
    /**
     * Build closure probability analysis section
     */
    private static String buildClosureProbabilitySection(List<Agent_Open_Pipe__c> records, String ouName, String workLocationCountry, String filterCriteria) {
        try {
            String section = '\n## 🎯 AE Closure Probability Analysis\n\n';
            
            // Group by AE and Product
            Map<String, Map<String, List<Agent_Open_Pipe__c>>> aeProductMap = new Map<String, Map<String, List<Agent_Open_Pipe__c>>>();
            
            for (Agent_Open_Pipe__c record : records) {
                if (String.isNotBlank(record.FULL_NAME__c) && String.isNotBlank(record.OPEN_PIPE_PROD_NM__c)) {
                    String aeKey = record.FULL_NAME__c + '|' + record.EMP_EMAIL_ADDR__c;
                    String product = record.OPEN_PIPE_PROD_NM__c;
                    
                    if (!aeProductMap.containsKey(aeKey)) {
                        aeProductMap.put(aeKey, new Map<String, List<Agent_Open_Pipe__c>>());
                    }
                    if (!aeProductMap.get(aeKey).containsKey(product)) {
                        aeProductMap.get(aeKey).put(product, new List<Agent_Open_Pipe__c>());
                    }
                    aeProductMap.get(aeKey).get(product).add(record);
                }
            }
            
            if (aeProductMap.isEmpty()) {
                section += 'No AE-product combinations found for closure probability analysis.\n';
                return section;
            }
            
            List<String> probabilityInsights = new List<String>();
            
            for (String aeKey : aeProductMap.keySet()) {
                String[] aeParts = aeKey.split('\\|');
                String aeName = aeParts[0];
                String aeEmail = aeParts.size() > 1 ? aeParts[1] : '';
                
                Map<String, List<Agent_Open_Pipe__c>> productMap = aeProductMap.get(aeKey);
                
                for (String product : productMap.keySet()) {
                    List<Agent_Open_Pipe__c> productRecords = productMap.get(product);
                    
                    // Calculate average score and total amount
                    Decimal totalScore = 0;
                    Integer validScoreCount = 0;
                    Decimal totalAmount = 0;
                    
                    for (Agent_Open_Pipe__c record : productRecords) {
                        if (record.OPEN_PIPE_AE_SCORE__c != null) {
                            totalScore += record.OPEN_PIPE_AE_SCORE__c;
                            validScoreCount++;
                        }
                        if (record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c != null) {
                            totalAmount += record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c;
                        }
                    }
                    
                    if (validScoreCount > 0) {
                        Decimal avgScore = totalScore / validScoreCount;
                        Decimal closureProbability = calculateClosureProbability(avgScore);
                        String explanation = generateClosureExplanation(avgScore, closureProbability, productRecords.size(), totalAmount);
                        
                        String insight = String.format('- **{0}** ({1}): {2} closure probability\n  - {3}', 
                            new List<String>{
                                aeName,
                                product,
                                formatPercentage(closureProbability),
                                explanation
                            });
                        probabilityInsights.add(insight);
                    }
                }
            }
            
            if (probabilityInsights.isEmpty()) {
                section += 'No valid AE scores found for closure probability analysis.\n';
            } else {
                section += String.join(probabilityInsights, '\n\n');
            }
            
            return section;
            
        } catch (Exception e) {
            System.debug('Error building closure probability section: ' + e.getMessage());
            return '\n## 🎯 AE Closure Probability Analysis\n\nError: ' + e.getMessage() + '\n';
        }
    }
    
    /**
     * Build stage bottleneck detection section
     */
    private static String buildStageBottleneckSection(List<Agent_Open_Pipe__c> records, String ouName, String workLocationCountry, String filterCriteria) {
        try {
            String section = '\n## 🚧 Stage Bottleneck Detection\n\n';
            
            // Group by stage and calculate dwell time
            Map<String, List<Agent_Open_Pipe__c>> stageMap = new Map<String, List<Agent_Open_Pipe__c>>();
            
            for (Agent_Open_Pipe__c record : records) {
                if (String.isNotBlank(record.OPEN_PIPE_OPTY_STG_NM__c)) {
                    String stage = record.OPEN_PIPE_OPTY_STG_NM__c;
                    if (!stageMap.containsKey(stage)) {
                        stageMap.put(stage, new List<Agent_Open_Pipe__c>());
                    }
                    stageMap.get(stage).add(record);
                }
            }
            
            if (stageMap.isEmpty()) {
                section += 'No stage data found for bottleneck analysis.\n';
                return section;
            }
            
            List<String> bottleneckInsights = new List<String>();
            
            for (String stage : stageMap.keySet()) {
                List<Agent_Open_Pipe__c> stageRecords = stageMap.get(stage);
                
                // Calculate average dwell time
                Decimal totalDwellTime = 0;
                Integer validDwellCount = 0;
                
                for (Agent_Open_Pipe__c record : stageRecords) {
                    if (record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__c != null) {
                        totalDwellTime += record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__c;
                        validDwellCount++;
                    }
                }
                
                if (validDwellCount > 0) {
                    Decimal avgDwellTime = totalDwellTime / validDwellCount;
                    String insight = String.format('- **{0}**: {1} days average dwell time ({2} opportunities)', 
                        new List<String>{
                            stage,
                            String.valueOf(avgDwellTime.setScale(1)),
                            String.valueOf(stageRecords.size())
                        });
                    bottleneckInsights.add(insight);
                }
            }
            
            if (bottleneckInsights.isEmpty()) {
                section += 'No valid dwell time data found for bottleneck analysis.\n';
            } else {
                section += String.join(bottleneckInsights, '\n');
            }
            
            return section;
            
        } catch (Exception e) {
            System.debug('Error building stage bottleneck section: ' + e.getMessage());
            return '\n## 🚧 Stage Bottleneck Detection\n\nError: ' + e.getMessage() + '\n';
        }
    }
    
    /**
     * Build product-market fit analysis section
     */
    private static String buildProductMarketFitSection(List<Agent_Open_Pipe__c> records, String ouName, String workLocationCountry, String filterCriteria) {
        try {
            String section = '\n## 🎯 Product-Market Fit Analysis\n\n';
            
            // Group by product and segment
            Map<String, Map<String, List<Agent_Open_Pipe__c>>> productSegmentMap = new Map<String, Map<String, List<Agent_Open_Pipe__c>>>();
            
            for (Agent_Open_Pipe__c record : records) {
                if (String.isNotBlank(record.OPEN_PIPE_PROD_NM__c)) {
                    String product = record.OPEN_PIPE_PROD_NM__c;
                    String segment = String.isNotBlank(record.MACROSGMENT__c) ? record.MACROSGMENT__c : 'Unknown';
                    
                    if (!productSegmentMap.containsKey(product)) {
                        productSegmentMap.put(product, new Map<String, List<Agent_Open_Pipe__c>>());
                    }
                    if (!productSegmentMap.get(product).containsKey(segment)) {
                        productSegmentMap.get(product).put(segment, new List<Agent_Open_Pipe__c>());
                    }
                    productSegmentMap.get(product).get(segment).add(record);
                }
            }
            
            if (productSegmentMap.isEmpty()) {
                section += 'No product-segment combinations found for PMF analysis.\n';
                return section;
            }
            
            List<String> pmfInsights = new List<String>();
            
            for (String product : productSegmentMap.keySet()) {
                Map<String, List<Agent_Open_Pipe__c>> segmentMap = productSegmentMap.get(product);
                
                for (String segment : segmentMap.keySet()) {
                    List<Agent_Open_Pipe__c> segmentRecords = segmentMap.get(segment);
                    
                    // Calculate total amount and count
                    Decimal totalAmount = 0;
                    for (Agent_Open_Pipe__c record : segmentRecords) {
                        if (record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c != null) {
                            totalAmount += record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c;
                        }
                    }
                    
                    String insight = String.format('- **{0}** in **{1}**: {2} opportunities, ${3} total value', 
                        new List<String>{
                            product,
                            segment,
                            String.valueOf(segmentRecords.size()),
                            String.valueOf(totalAmount.setScale(0))
                        });
                    pmfInsights.add(insight);
                }
            }
            
            if (pmfInsights.isEmpty()) {
                section += 'No valid data found for PMF analysis.\n';
            } else {
                section += String.join(pmfInsights, '\n');
            }
            
            return section;
            
        } catch (Exception e) {
            System.debug('Error building PMF section: ' + e.getMessage());
            return '\n## 🎯 Product-Market Fit Analysis\n\nError: ' + e.getMessage() + '\n';
        }
    }
    
    /**
     * Build AE benchmarking section
     */
    private static String buildAEBenchmarkSection(List<Agent_Open_Pipe__c> records, String ouName, String workLocationCountry, String filterCriteria) {
        try {
            String section = '\n## 📊 AE Performance Benchmarking\n\n';
            
            // Group by AE
            Map<String, List<Agent_Open_Pipe__c>> aeMap = new Map<String, List<Agent_Open_Pipe__c>>();
            
            for (Agent_Open_Pipe__c record : records) {
                if (String.isNotBlank(record.FULL_NAME__c)) {
                    String aeKey = record.FULL_NAME__c + '|' + record.EMP_EMAIL_ADDR__c;
                    if (!aeMap.containsKey(aeKey)) {
                        aeMap.put(aeKey, new List<Agent_Open_Pipe__c>());
                    }
                    aeMap.get(aeKey).add(record);
                }
            }
            
            if (aeMap.isEmpty()) {
                section += 'No AE data found for benchmarking analysis.\n';
                return section;
            }
            
            List<String> benchmarkInsights = new List<String>();
            
            for (String aeKey : aeMap.keySet()) {
                String[] aeParts = aeKey.split('\\|');
                String aeName = aeParts[0];
                String aeEmail = aeParts.size() > 1 ? aeParts[1] : '';
                
                List<Agent_Open_Pipe__c> aeRecords = aeMap.get(aeKey);
                
                // Calculate AE metrics
                Decimal totalScore = 0;
                Integer validScoreCount = 0;
                Decimal totalAmount = 0;
                
                for (Agent_Open_Pipe__c record : aeRecords) {
                    if (record.OPEN_PIPE_AE_SCORE__c != null) {
                        totalScore += record.OPEN_PIPE_AE_SCORE__c;
                        validScoreCount++;
                    }
                    if (record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c != null) {
                        totalAmount += record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c;
                    }
                }
                
                if (validScoreCount > 0) {
                    Decimal avgScore = totalScore / validScoreCount;
                    String insight = String.format('- **{0}**: Avg score {1}, {2} opportunities, ${3} total value', 
                        new List<String>{
                            aeName,
                            String.valueOf(avgScore.setScale(2)),
                            String.valueOf(aeRecords.size()),
                            String.valueOf(totalAmount.setScale(0))
                        });
                    benchmarkInsights.add(insight);
                }
            }
            
            if (benchmarkInsights.isEmpty()) {
                section += 'No valid AE data found for benchmarking analysis.\n';
            } else {
                section += String.join(benchmarkInsights, '\n');
            }
            
            return section;
            
        } catch (Exception e) {
            System.debug('Error building AE benchmark section: ' + e.getMessage());
            return '\n## 📊 AE Performance Benchmarking\n\nError: ' + e.getMessage() + '\n';
        }
    }
    
    /**
     * Build pipeline health scoring section
     */
    private static String buildHealthScoreSection(List<Agent_Open_Pipe__c> records, String ouName, String workLocationCountry, String filterCriteria,
                                                Boolean includeClosureProb, Boolean includeStageBottlenecks, Boolean includePMF, Boolean includeAEBenchmarks) {
        try {
            String section = '\n## 🏥 Pipeline Health Score\n\n';
            
            // Calculate basic health metrics
            Integer totalRecords = records.size();
            Decimal totalAmount = 0;
            Integer validScoreCount = 0;
            Decimal totalScore = 0;
            
            for (Agent_Open_Pipe__c record : records) {
                if (record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c != null) {
                    totalAmount += record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c;
                }
                if (record.OPEN_PIPE_AE_SCORE__c != null) {
                    totalScore += record.OPEN_PIPE_AE_SCORE__c;
                    validScoreCount++;
                }
            }
            
            // Calculate health score (simplified version)
            Decimal healthScore = 0;
            List<String> explanations = new List<String>();
            
            if (totalRecords > 0) {
                healthScore += 2.0; // Base score for having data
                explanations.add('+2.0 for having ' + totalRecords + ' opportunities');
            }
            
            if (validScoreCount > 0) {
                Decimal avgScore = totalScore / validScoreCount;
                healthScore += avgScore * 1.6; // Scale AE score to 0-8 range
                explanations.add('+' + String.valueOf((avgScore * 1.6).setScale(1)) + ' from average AE score of ' + String.valueOf(avgScore.setScale(2)));
            }
            
            // Cap at 10
            healthScore = Math.min(10.0, healthScore);
            
            section += '**Overall Health Score: ' + String.valueOf(healthScore.setScale(1)) + '/10**\n\n';
            section += '**Breakdown:**\n';
            section += String.join(explanations, '\n');
            section += '\n\n**Recommendations:**\n';
            section += '- Focus on opportunities with higher AE scores\n';
            section += '- Review pipeline coverage and quality\n';
            section += '- Consider additional training for lower-performing areas\n';
            
            return section;
            
        } catch (Exception e) {
            System.debug('Error building health score section: ' + e.getMessage());
            return '\n## 🏥 Pipeline Health Score\n\nError: ' + e.getMessage() + '\n';
        }
    }
    
    // Helper methods for intelligence capabilities
    
    private static Decimal calculateClosureProbability(Decimal score) {
        if (score == null) return 0.0;
        
        Decimal clampedScore = Math.max(0.0, Math.min(5.0, score));
        
        if (clampedScore >= 0.0 && clampedScore <= 1.0) {
            return 0.0 + (clampedScore / 1.0) * 0.20;
        } else if (clampedScore > 1.0 && clampedScore <= 2.0) {
            return 0.20 + ((clampedScore - 1.0) / 1.0) * 0.20;
        } else if (clampedScore > 2.0 && clampedScore <= 3.0) {
            return 0.40 + ((clampedScore - 2.0) / 1.0) * 0.20;
        } else if (clampedScore > 3.0 && clampedScore <= 4.0) {
            return 0.60 + ((clampedScore - 3.0) / 1.0) * 0.20;
        } else if (clampedScore > 4.0 && clampedScore <= 5.0) {
            return 0.80 + ((clampedScore - 4.0) / 1.0) * 0.15;
        }
        
        return 0.0;
    }
    
    private static String generateClosureExplanation(Decimal score, Decimal probability, Integer oppCount, Decimal totalAmount) {
        String percentage = formatPercentage(probability);
        String amountStr = totalAmount != null ? '$' + totalAmount.setScale(0).toPlainString() : '$0';
        
        return String.format('Mapped avgScore {0} to {1} via piecewise rule; {2} opps; total amount {3}.', 
            new List<String>{
                String.valueOf(score.setScale(2)),
                percentage,
                String.valueOf(oppCount),
                amountStr
            });
    }
    
    private static String formatPercentage(Decimal probability) {
        if (probability == null) return '0.0%';
        Decimal percentage = probability * 100;
        return percentage.setScale(1) + '%';
    }
    
}