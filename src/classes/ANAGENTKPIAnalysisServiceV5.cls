/**
 * TEMPLATE SERVICE - Houses business logic and direct object manipulation in our handler/service pattern.
 * Business Requirement: Service methods return a single composed message string for agent consumption.
 * Handlers call into this class to perform KPI analysis operations.
 * @description Service class for KPI Analysis operations on AGENT_OU_PIPELINE_V2__c records.
 * Handles all business logic for computing KPIs across AE rosters with grouping, filtering, and aggregation.
 *
 * Key fields referenced (ONLY these allowed):
 *   - emp_id__c, full_name__c, emp_email_addr__c, work_location_country__c, ou_name__c, emp_mgr_nm__c, primary_industry__c
 *   - val_quota__c, cq_customer_meeting__c, cq_pg__c, cq_acv__c, cq_call_connect__c, cq_cc_acv__c
 *   - cq_days_acv__c, cq_days_acv_part__c, cq_days_pg_part__c, cq_days_pg__c
 *   - pq_customer_meeting__c, pq_pg__c, pq_acv__c, pq_call_connect__c, pq_cc_acv__c
 *   - pq_days_acv__c, pq_days_acv_part__c, pq_days_pg_part__c, pq_days_pg__c
 *   - aov__c, coverage__c, time_since_onboarding__c, fulltotalacvquotausd__c, days_to_productivity__c
 *   - definition__c, description__c, learner_profile_id__c, ramp_status__c
 *
 * @version 5.1
 */
public with sharing class ANAGENTKPIAnalysisServiceV5 {
    
    // Field mapping constants
    private static final Map<String, Map<String, String>> METRIC_FIELD_MAP = new Map<String, Map<String, String>>{
        'ACV' => new Map<String, String>{
            'CURRENT' => 'cq_acv__c',
            'PREVIOUS' => 'pq_acv__c'
        },
        'PQ_ACV' => new Map<String, String>{
            'CURRENT' => 'pq_acv__c',
            'PREVIOUS' => 'pq_acv__c'
        },
        'PG' => new Map<String, String>{
            'CURRENT' => 'cq_pg__c',
            'PREVIOUS' => 'pq_pg__c'
        },
        'PQ_PG' => new Map<String, String>{
            'CURRENT' => 'pq_pg__c',
            'PREVIOUS' => 'pq_pg__c'
        },
        'CALLS' => new Map<String, String>{
            'CURRENT' => 'cq_call_connect__c',
            'PREVIOUS' => 'pq_call_connect__c'
        },
        'PQ_CALL_CONNECT' => new Map<String, String>{
            'CURRENT' => 'pq_call_connect__c',
            'PREVIOUS' => 'pq_call_connect__c'
        },
        'MEETINGS' => new Map<String, String>{
            'CURRENT' => 'cq_customer_meeting__c',
            'PREVIOUS' => 'pq_customer_meeting__c'
        },
        'CQ_CUSTOMER_MEETING' => new Map<String, String>{
            'CURRENT' => 'cq_customer_meeting__c',
            'PREVIOUS' => 'pq_customer_meeting__c'
        },
        'PQ_CUSTOMER_MEETING' => new Map<String, String>{
            'CURRENT' => 'pq_customer_meeting__c',
            'PREVIOUS' => 'pq_customer_meeting__c'
        },
        'COVERAGE' => new Map<String, String>{
            'CURRENT' => 'coverage__c',
            'PREVIOUS' => null // Not available for previous
        },
        'QUOTA' => new Map<String, String>{
            'CURRENT' => 'val_quota__c',
            'PREVIOUS' => 'val_quota__c' // Available for both
        },
        'CC_ACV' => new Map<String, String>{
            'CURRENT' => 'cq_cc_acv__c',
            'PREVIOUS' => 'pq_cc_acv__c'
        },
        'CQ_CC_ACV' => new Map<String, String>{
            'CURRENT' => 'cq_cc_acv__c',
            'PREVIOUS' => 'pq_cc_acv__c'
        },
        'DAYS_ACV' => new Map<String, String>{
            'CURRENT' => 'cq_days_acv__c',
            'PREVIOUS' => 'pq_days_acv__c'
        },
        'CQ_DAYS_ACV' => new Map<String, String>{
            'CURRENT' => 'cq_days_acv__c',
            'PREVIOUS' => 'pq_days_acv__c'
        },
        'DAYS_ACV_PART' => new Map<String, String>{
            'CURRENT' => 'cq_days_acv_part__c',
            'PREVIOUS' => 'pq_days_acv_part__c'
        },
        'CQ_DAYS_ACV_PART' => new Map<String, String>{
            'CURRENT' => 'cq_days_acv_part__c',
            'PREVIOUS' => 'pq_days_acv_part__c'
        },
        'DAYS_PG_PART' => new Map<String, String>{
            'CURRENT' => 'cq_days_pg_part__c',
            'PREVIOUS' => 'pq_days_pg_part__c'
        },
        'CQ_DAYS_PG_PART' => new Map<String, String>{
            'CURRENT' => 'cq_days_pg_part__c',
            'PREVIOUS' => 'pq_days_pg_part__c'
        },
        'DAYS_PG' => new Map<String, String>{
            'CURRENT' => 'cq_days_pg__c',
            'PREVIOUS' => 'pq_days_pg__c'
        },
        'CQ_DAYS_PG' => new Map<String, String>{
            'CURRENT' => 'cq_days_pg__c',
            'PREVIOUS' => 'pq_days_pg__c'
        },
        'AOV' => new Map<String, String>{
            'CURRENT' => 'aov__c',
            'PREVIOUS' => 'aov__c' // Available for both
        },
        'FULL_TOTAL_ACV_QUOTA' => new Map<String, String>{
            'CURRENT' => 'fulltotalacvquotausd__c',
            'PREVIOUS' => 'fulltotalacvquotausd__c' // Available for both
        },
        'DAYS_TO_PRODUCTIVITY' => new Map<String, String>{
            'CURRENT' => 'days_to_productivity__c',
            'PREVIOUS' => 'days_to_productivity__c' // Available for both
        },
        'GROWTH_FACTOR' => new Map<String, String>{
            'CURRENT' => 'definition__c',
            'PREVIOUS' => 'definition__c' // Available for both
        },
        'GF' => new Map<String, String>{
            'CURRENT' => 'definition__c',
            'PREVIOUS' => 'definition__c' // Available for both
        },
        'PQ_CC_ACV' => new Map<String, String>{
            'CURRENT' => 'pq_cc_acv__c',
            'PREVIOUS' => 'pq_cc_acv__c'
        },
        'PQ_DAYS_ACV' => new Map<String, String>{
            'CURRENT' => 'pq_days_acv__c',
            'PREVIOUS' => 'pq_days_acv__c'
        },
        'PQ_DAYS_ACV_PART' => new Map<String, String>{
            'CURRENT' => 'pq_days_acv_part__c',
            'PREVIOUS' => 'pq_days_acv_part__c'
        },
        'PQ_DAYS_PG_PART' => new Map<String, String>{
            'CURRENT' => 'pq_days_pg_part__c',
            'PREVIOUS' => 'pq_days_pg_part__c'
        },
        'PQ_DAYS_PG' => new Map<String, String>{
            'CURRENT' => 'pq_days_pg__c',
            'PREVIOUS' => 'pq_days_pg__c'
        }
    };
    
    private static final Map<String, String> GROUP_FIELD_MAP = new Map<String, String>{
        'COUNTRY' => 'work_location_country__c',
        'OU' => 'ou_name__c',
        'INDUSTRY' => 'primary_industry__c',
        'AE' => 'full_name__c',
        'GROWTH_FACTOR' => 'definition__c',
        'DEFINITION' => 'definition__c',
        'RAMP_STATUS' => 'ramp_status__c',
        'MANAGER' => 'emp_mgr_nm__c',
        'EMAIL' => 'emp_email_addr__c',
        'LEARNER_PROFILE' => 'learner_profile__id__c'
    };
    
    private static final Map<String, String> FILTER_FIELD_MAP = new Map<String, String>{
        // Core geographic/demographic fields
        'country' => 'work_location_country__c',
        'location' => 'work_location_country__c',
        'region' => 'work_location_country__c',
        'geo' => 'work_location_country__c',
        
        // Operating Unit fields
        'ou' => 'ou_name__c',
        'operating_unit' => 'ou_name__c',
        'unit' => 'ou_name__c',
        'division' => 'ou_name__c',
        'segment' => 'ou_name__c',
        'business_unit' => 'ou_name__c',
        
        // Industry fields
        'industry' => 'primary_industry__c',
        'sector' => 'primary_industry__c',
        'vertical' => 'primary_industry__c',
        'business_type' => 'primary_industry__c',
        
        // AE/Employee fields
        'ae' => 'full_name__c',
        'employee' => 'full_name__c',
        'rep' => 'full_name__c',
        'salesperson' => 'full_name__c',
        'seller' => 'full_name__c',
        'name' => 'full_name__c',
        
        // Manager fields
        'manager' => 'emp_mgr_nm__c',
        'supervisor' => 'emp_mgr_nm__c',
        'boss' => 'emp_mgr_nm__c',
        'lead' => 'emp_mgr_nm__c',
        
        // Contact fields
        'email' => 'emp_email_addr__c',
        'contact' => 'emp_email_addr__c',
        'email_address' => 'emp_email_addr__c',
        
        // Learning fields
        'learner_profile' => 'learner_profile_id__c',
        'learning' => 'learner_profile_id__c',
        'enablement' => 'learner_profile_id__c',
        'training' => 'learner_profile_id__c',
        
        // Growth Factor fields
        'growth_factor' => 'definition__c',
        'gf' => 'definition__c',
        'definition' => 'definition__c',
        'growth_area' => 'definition__c',
        'improvement_area' => 'definition__c',
        'development_focus' => 'definition__c',
        
        // Description fields
        'description' => 'description__c',
        'explanation' => 'description__c',
        'details' => 'description__c',
        'meaning' => 'description__c',
        
        // Ramp Status fields
        'ramp_status' => 'ramp_status__c',
        'ramp' => 'ramp_status__c',
        'onboarding_status' => 'ramp_status__c',
        'performance_status' => 'ramp_status__c',
        'ramp_level' => 'ramp_status__c',
        'ramp_category' => 'ramp_status__c',
        
        // Tenure fields
        'time_since_onboarding' => 'time_since_onboarding__c',
        'tenure' => 'time_since_onboarding__c',
        'onboarding' => 'time_since_onboarding__c',
        'experience' => 'time_since_onboarding__c',
        'months_at_company' => 'time_since_onboarding__c',
        'time_in_role' => 'time_since_onboarding__c',
        'seniority' => 'time_since_onboarding__c',
        'years_of_service' => 'time_since_onboarding__c'
    };
    
    /**
     * Parses filter criteria from user-friendly format to SOQL
     */
    public static String parseFilterCriteria(String filterCriteria) {
        if (String.isBlank(filterCriteria)) return '';
        
        // Convert user-friendly filter keys to actual field names
        String parsedFilter = filterCriteria;
        
        // NEW: Handle cases where agent sends API field names instead of user-friendly keys
        // This fixes the issue where agent sends RAMP_STATUS__c='Fast Ramper' instead of ramp_status='Fast Ramper'
        Map<String, String> apiFieldToUserKey = new Map<String, String>{
            // Ramp Status variations
            'RAMP_STATUS__C' => 'ramp_status',
            'RAMP_STATUS__c' => 'ramp_status',
            'RAMP_STATUS' => 'ramp_status',
            'RAMPSTATUS__C' => 'ramp_status',
            'RAMPSTATUS__c' => 'ramp_status',
            'RAMPSTATUS' => 'ramp_status',
            
            // Operating Unit variations
            'OU_NAME__C' => 'ou',
            'OU_NAME__c' => 'ou',
            'OU_NAME' => 'ou',
            'OUNAME__C' => 'ou',
            'OUNAME__c' => 'ou',
            'OUNAME' => 'ou',
            'OPERATING_UNIT__C' => 'ou',
            'OPERATING_UNIT__c' => 'ou',
            'OPERATING_UNIT' => 'ou',
            
            // Country variations
            'WORK_LOCATION_COUNTRY__C' => 'country',
            'WORK_LOCATION_COUNTRY__c' => 'country',
            'WORK_LOCATION_COUNTRY' => 'country',
            'WORKLOCATIONCOUNTRY__C' => 'country',
            'WORKLOCATIONCOUNTRY__c' => 'country',
            'WORKLOCATIONCOUNTRY' => 'country',
            'COUNTRY__C' => 'country',
            'COUNTRY__c' => 'country',
            'COUNTRY' => 'country',
            
            // Industry variations
            'PRIMARY_INDUSTRY__C' => 'industry',
            'PRIMARY_INDUSTRY__c' => 'industry',
            'PRIMARY_INDUSTRY' => 'industry',
            'PRIMARYINDUSTRY__C' => 'industry',
            'PRIMARYINDUSTRY__c' => 'industry',
            'PRIMARYINDUSTRY' => 'industry',
            'INDUSTRY__C' => 'industry',
            'INDUSTRY__c' => 'industry',
            'INDUSTRY' => 'industry',
            
            // Name variations
            'FULL_NAME__C' => 'ae',
            'FULL_NAME__c' => 'ae',
            'FULL_NAME' => 'ae',
            'FULLNAME__C' => 'ae',
            'FULLNAME__c' => 'ae',
            'FULLNAME' => 'ae',
            'NAME__C' => 'ae',
            'NAME__c' => 'ae',
            'NAME' => 'ae',
            
            // Manager variations
            'EMP_MGR_NM__C' => 'manager',
            'EMP_MGR_NM__c' => 'manager',
            'EMP_MGR_NM' => 'manager',
            'EMPMGRNM__C' => 'manager',
            'EMPMGRNM__c' => 'manager',
            'EMPMGRNM' => 'manager',
            'MANAGER__C' => 'manager',
            'MANAGER__c' => 'manager',
            'MANAGER' => 'manager',
            
            // Email variations
            'EMP_EMAIL_ADDR__C' => 'email',
            'EMP_EMAIL_ADDR__c' => 'email',
            'EMP_EMAIL_ADDR' => 'email',
            'EMPEMAILADDR__C' => 'email',
            'EMPEMAILADDR__c' => 'email',
            'EMPEMAILADDR' => 'email',
            'EMAIL__C' => 'email',
            'EMAIL__c' => 'email',
            'EMAIL' => 'email',
            
            // Learner Profile variations
            'LEARNER_PROFILE_ID__C' => 'learner_profile',
            'LEARNER_PROFILE_ID__c' => 'learner_profile',
            'LEARNER_PROFILE_ID' => 'learner_profile',
            'LEARNERPROFILEID__C' => 'learner_profile',
            'LEARNERPROFILEID__c' => 'learner_profile',
            'LEARNERPROFILEID' => 'learner_profile',
            'PROFILE__C' => 'learner_profile',
            'PROFILE__c' => 'learner_profile',
            'PROFILE' => 'learner_profile',
            
            // Definition variations
            'DEFINITION__C' => 'definition',
            'DEFINITION__c' => 'definition',
            'DEFINITION' => 'definition',
            'DEF__C' => 'definition',
            'DEF__c' => 'definition',
            'DEF' => 'definition',
            
            // Description variations
            'DESCRIPTION__C' => 'description',
            'DESCRIPTION__c' => 'description',
            'DESCRIPTION' => 'description',
            'DESC__C' => 'description',
            'DESC__c' => 'description',
            'DESC' => 'description',
            
            // Tenure variations
            'TIME_SINCE_ONBOARDING__C' => 'time_since_onboarding',
            'TIME_SINCE_ONBOARDING__c' => 'time_since_onboarding',
            'TIME_SINCE_ONBOARDING' => 'time_since_onboarding',
            'TIMESINCEONBOARDING__C' => 'time_since_onboarding',
            'TIMESINCEONBOARDING__c' => 'time_since_onboarding',
            'TIMESINCEONBOARDING' => 'time_since_onboarding',
            'TENURE__C' => 'time_since_onboarding',
            'TENURE__c' => 'time_since_onboarding',
            'TENURE' => 'time_since_onboarding',
            'ONBOARDING__C' => 'time_since_onboarding',
            'ONBOARDING__c' => 'time_since_onboarding',
            'ONBOARDING' => 'time_since_onboarding'
        };
        
        // First, convert API field names to user-friendly keys
        for (String apiField : apiFieldToUserKey.keySet()) {
            String userKey = apiFieldToUserKey.get(apiField);
            // Replace API field names with user-friendly keys
            parsedFilter = parsedFilter.replace(apiField + '=', userKey + '=');
            parsedFilter = parsedFilter.replace(apiField + ' IN', userKey + ' IN');
            parsedFilter = parsedFilter.replace(apiField + ' LIKE', userKey + ' LIKE');
            parsedFilter = parsedFilter.replace(apiField + ' <>', userKey + ' <>');
            parsedFilter = parsedFilter.replace(apiField + ' <', userKey + ' <');
            parsedFilter = parsedFilter.replace(apiField + ' >', userKey + ' >');
            parsedFilter = parsedFilter.replace(apiField + ' <=', userKey + ' <=');
            parsedFilter = parsedFilter.replace(apiField + ' >=', userKey + ' >=');
        }
        
        // Second, convert user-friendly keys to actual field names
        for (String key : FILTER_FIELD_MAP.keySet()) {
            String fieldName = FILTER_FIELD_MAP.get(key);
            parsedFilter = parsedFilter.replaceAll(key + '=', fieldName + '=');
            parsedFilter = parsedFilter.replaceAll(key + ' IN', fieldName + ' IN');
            parsedFilter = parsedFilter.replaceAll(key + ' LIKE', fieldName + ' LIKE');
            parsedFilter = parsedFilter.replaceAll(key + ' <>', fieldName + ' <>');
            parsedFilter = parsedFilter.replaceAll(key + ' <', fieldName + ' <');
            parsedFilter = parsedFilter.replaceAll(key + ' >', fieldName + ' >');
            parsedFilter = parsedFilter.replaceAll(key + ' <=', fieldName + ' <=');
            parsedFilter = parsedFilter.replaceAll(key + ' >=', fieldName + ' >=');
        }
        
        // NEW: Apply smart field detection for any remaining unmapped fields
        // This catches cases where agents use creative field names
        String[] filterParts = parsedFilter.split(' ');
        for (Integer i = 0; i < filterParts.size(); i++) {
            String part = filterParts[i];
            if (part.contains('=') || part.contains(' IN') || part.contains(' LIKE') || 
                part.contains(' <>') || part.contains(' <') || part.contains(' >') || 
                part.contains(' <=') || part.contains(' >=')) {
                
                // Extract field name (everything before the operator)
                String fieldName = '';
                String operator = '';
                
                if (part.contains('=')) {
                    fieldName = part.substring(0, part.indexOf('='));
                    operator = '=';
                } else if (part.contains(' IN')) {
                    fieldName = part.substring(0, part.indexOf(' IN'));
                    operator = ' IN';
                } else if (part.contains(' LIKE')) {
                    fieldName = part.substring(0, part.indexOf(' LIKE'));
                    operator = ' LIKE';
                } else if (part.contains(' <>')) {
                    fieldName = part.substring(0, part.indexOf(' <>'));
                    operator = ' <>';
                } else if (part.contains(' <=')) {
                    fieldName = part.substring(0, part.indexOf(' <='));
                    operator = ' <=';
                } else if (part.contains(' >=')) {
                    fieldName = part.substring(0, part.indexOf(' >='));
                    operator = ' >=';
                } else if (part.contains(' <')) {
                    fieldName = part.substring(0, part.indexOf(' <'));
                    operator = ' <';
                } else if (part.contains(' >')) {
                    fieldName = part.substring(0, part.indexOf(' >'));
                    operator = ' >';
                }
                
                // Apply smart field detection if this field isn't already mapped
                if (String.isNotBlank(fieldName) && !fieldName.contains('__c') && 
                    !fieldName.contains('\'') && !fieldName.contains('(') && !fieldName.contains(')')) {
                    
                    String smartField = smartFieldDetection(fieldName);
                    if (smartField != fieldName) {
                        // Replace the field name with the smart-detected field
                        filterParts[i] = smartField + operator + part.substring(part.indexOf(operator) + operator.length());
                    }
                }
            }
        }
        
        // Reconstruct the filter string
        parsedFilter = joinList(filterParts, ' ');
        
        // Handle special cases for business logic (if needed in the future)
        // Currently no special cases required
        
        return parsedFilter;
    }
    
    /**
     * Main method to analyze KPIs based on specified parameters
     * Returns a single composed message string for the agent
     */
    public static String analyzeKPIs(String metricKey, String timeframe, String groupBy, 
                                   String filterCriteria, String restrictInValuesCsv, 
                                   Boolean perAENormalize, Integer limitN, String aggregationType) {
        
        try {
            // Validate and auto-correct metric/timeframe mismatches
            String correctedMetricKey = validateAndCorrectMetricTimeframe(metricKey, timeframe);
            if (correctedMetricKey == null) {
                return buildUnavailableMetricMessage(metricKey, timeframe);
            }
            if (correctedMetricKey != metricKey) {
                metricKey = correctedMetricKey; // Use corrected metric
            }
            
            // Get total count first (without limit)
            Integer totalCount = getTotalCount(metricKey, timeframe, filterCriteria, groupBy);
            
            // For Growth Factor analysis, we need to get ALL records to do proper grouping and counting
            // The limit will be applied to the final grouped results, not the raw records
            String soqlQuery = buildSOQLQuery(metricKey, timeframe, groupBy, filterCriteria, null);
            
            List<AGENT_OU_PIPELINE_V2__c> records = executeQuery(soqlQuery);
            
            // Apply security stripping
            records = Security.stripInaccessible(AccessType.READABLE, records).getRecords();
            
            // Process results and build analysis
            return buildAnalysisMessage(records, metricKey, timeframe, groupBy, filterCriteria, 
                                     restrictInValuesCsv, perAENormalize, limitN, totalCount, aggregationType);
            
        } catch (Exception e) {
            return buildErrorMessage('KPI analysis failed: ' + e.getMessage());
        }
    }
    
    /**
     * Builds the SOQL query based on parameters
     */
    private static String buildSOQLQuery(String metricKey, String timeframe, String groupBy, 
                                       String filterCriteria, Integer limitN) {
        
        String metricField = METRIC_FIELD_MAP.get(metricKey).get(timeframe);
        String groupField = GROUP_FIELD_MAP.get(groupBy);
        
        // Base query with required fields
        String query = 'SELECT emp_id__c, full_name__c, emp_email_addr__c, work_location_country__c, ' +
                      'ou_name__c, emp_mgr_nm__c, primary_industry__c, ' +
                      'definition__c, description__c, learner_profile_id__c, ramp_status__c';
        
        // Add metric field if it's not already included (avoid duplicates for Growth Factor)
        if (metricKey != 'GROWTH_FACTOR' && metricKey != 'GF') {
            query += ', ' + metricField;
        }
        
        query += ' FROM AGENT_OU_PIPELINE_V2__c';
        
        // Build WHERE clause
        List<String> whereClauses = new List<String>();
        
        // Add filter criteria if provided
        if (String.isNotBlank(filterCriteria)) {
            String parsedFilter = parseFilterCriteria(filterCriteria);
            if (String.isNotBlank(parsedFilter)) {
                whereClauses.add('(' + parsedFilter + ')');
            }
        }
        
        // Add metric field null check (treat null as 0) - but not for Growth Factor
        if (metricKey != 'GROWTH_FACTOR' && metricKey != 'GF') {
            whereClauses.add(metricField + ' != null');
        }
        
        // Special handling for Growth Factor grouping: ensure definition__c is not null
        if (groupBy == 'GROWTH_FACTOR') {
            whereClauses.add('definition__c != null');
        }
        
        if (!whereClauses.isEmpty()) {
            query += ' WHERE ' + joinList(whereClauses, ' AND ');
        }
        
        // Add grouping and ordering
        query += ' ORDER BY ' + groupField + ' ASC';
        
        // Note: Don't add LIMIT here - we need to get total count first
        // The limit will be applied after getting the total count
        
        return query;
    }
    
    /**
     * Executes the SOQL query and returns actual records
     */
    private static List<AGENT_OU_PIPELINE_V2__c> executeQuery(String soqlQuery) {
        try {
            // Execute the query and return actual records
            return Database.query(soqlQuery);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Query execution failed: ' + e.getMessage());
            return new List<AGENT_OU_PIPELINE_V2__c>();
        }
    }
    
    /**
     * Gets total count of records without limit for accurate reporting
     */
    private static Integer getTotalCount(String metricKey, String timeframe, String filterCriteria, String groupBy) {
        try {
            String metricField = METRIC_FIELD_MAP.get(metricKey).get(timeframe);
            String countQuery = 'SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c';
            
            List<String> whereClauses = new List<String>();
            
            if (String.isNotBlank(filterCriteria)) {
                String parsedFilter = parseFilterCriteria(filterCriteria);
                if (String.isNotBlank(parsedFilter)) {
                    whereClauses.add('(' + parsedFilter + ')');
                }
            }
            
            // Add metric field null check (treat null as 0) - but not for Growth Factor
            if (metricKey != 'GROWTH_FACTOR' && metricKey != 'GF') {
                whereClauses.add(metricField + ' != null');
            }
            
            // Special handling for Growth Factor grouping: ensure definition__c is not null
            if (groupBy == 'GROWTH_FACTOR') {
                whereClauses.add('definition__c != null');
            }
            
                    if (!whereClauses.isEmpty()) {
            countQuery += ' WHERE ' + joinList(whereClauses, ' AND ');
        }
            
            return Database.countQuery(countQuery);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Count query failed: ' + e.getMessage());
            return 0;
        }
    }
    
    /**
     * Checks if a metric is available for the specified timeframe and auto-corrects mismatches
     */
    private static String validateAndCorrectMetricTimeframe(String metricKey, String timeframe) {
        // Auto-correct common metric/timeframe mismatches
        if (timeframe == 'PREVIOUS' && metricKey.startsWith('CQ_')) {
            // User asked for PREVIOUS but sent CURRENT quarter metric
            String correctedMetric = metricKey.replace('CQ_', 'PQ_');
            System.debug('Auto-corrected metric from ' + metricKey + ' to ' + correctedMetric + ' for PREVIOUS timeframe');
            return correctedMetric;
        } else if (timeframe == 'CURRENT' && metricKey.startsWith('PQ_')) {
            // User asked for CURRENT but sent PREVIOUS quarter metric
            String correctedMetric = metricKey.replace('PQ_', 'CQ_');
            System.debug('Auto-corrected metric from ' + metricKey + ' to ' + correctedMetric + ' for CURRENT timeframe');
            return correctedMetric;
        }
        
        // Check if metric is available for timeframe
        if (timeframe == 'PREVIOUS') {
            if (metricKey == 'AI_MENTIONS' || metricKey == 'COVERAGE') {
                return null; // Not available
            }
        }
        
        return metricKey; // No correction needed
    }
    
    /**
     * Smart field detection - tries to infer field mappings based on business context
     * This helps when agents use non-standard field names
     */
    private static String smartFieldDetection(String fieldName) {
        if (String.isBlank(fieldName)) return fieldName;
        
        String normalizedField = fieldName.toLowerCase().trim();
        
        // Geographic/demographic patterns
        if (normalizedField.contains('country') || normalizedField.contains('nation') || 
            normalizedField.contains('location') || normalizedField.contains('region') ||
            normalizedField.contains('geo') || normalizedField.contains('territory')) {
            return 'work_location_country__c';
        }
        
        // Operating Unit patterns
        if (normalizedField.contains('ou') || normalizedField.contains('operating') || 
            normalizedField.contains('unit') || normalizedField.contains('division') ||
            normalizedField.contains('segment') || normalizedField.contains('business_unit')) {
            return 'ou_name__c';
        }
        
        // Industry patterns
        if (normalizedField.contains('industry') || normalizedField.contains('sector') || 
            normalizedField.contains('vertical') || normalizedField.contains('business_type') ||
            normalizedField.contains('market')) {
            return 'primary_industry__c';
        }
        
        // Employee/AE patterns
        if (normalizedField.contains('ae') || normalizedField.contains('employee') || 
            normalizedField.contains('rep') || normalizedField.contains('salesperson') ||
            normalizedField.contains('seller') || normalizedField.contains('name') ||
            normalizedField.contains('person')) {
            return 'full_name__c';
        }
        
        // Manager patterns
        if (normalizedField.contains('manager') || normalizedField.contains('supervisor') || 
            normalizedField.contains('boss') || normalizedField.contains('lead') ||
            normalizedField.contains('director')) {
            return 'emp_mgr_nm__c';
        }
        
        // Contact patterns
        if (normalizedField.contains('email') || normalizedField.contains('contact') || 
            normalizedField.contains('address') || normalizedField.contains('communication')) {
            return 'emp_email_addr__c';
        }
        
        // Learning patterns
        if (normalizedField.contains('learner') || normalizedField.contains('learning') || 
            normalizedField.contains('enablement') || normalizedField.contains('training') ||
            normalizedField.contains('profile') || normalizedField.contains('education')) {
            return 'learner_profile_id__c';
        }
        
        // Growth Factor patterns
        if (normalizedField.contains('growth') || normalizedField.contains('factor') || 
            normalizedField.contains('definition') || normalizedField.contains('area') ||
            normalizedField.contains('improvement') || normalizedField.contains('development') ||
            normalizedField.contains('focus') || normalizedField.contains('gf')) {
            return 'definition__c';
        }
        
        // Description patterns
        if (normalizedField.contains('description') || normalizedField.contains('explanation') || 
            normalizedField.contains('details') || normalizedField.contains('meaning') ||
            normalizedField.contains('desc')) {
            return 'description__c';
        }
        
        // Ramp Status patterns
        if (normalizedField.contains('ramp') || normalizedField.contains('onboarding') || 
            normalizedField.contains('performance') || normalizedField.contains('status') ||
            normalizedField.contains('level') || normalizedField.contains('category')) {
            return 'ramp_status__c';
        }
        
        // Tenure patterns
        if (normalizedField.contains('tenure') || normalizedField.contains('onboarding') || 
            normalizedField.contains('experience') || normalizedField.contains('months') ||
            normalizedField.contains('time') || normalizedField.contains('seniority') ||
            normalizedField.contains('years') || normalizedField.contains('service')) {
            return 'time_since_onboarding__c';
        }
        
        // If no pattern matches, return original field name
        return fieldName;
    }
    
    /**
     * Builds the complete analysis message
     */
    private static String buildAnalysisMessage(List<AGENT_OU_PIPELINE_V2__c> records, 
                                             String metricKey, String timeframe, String groupBy,
                                             String filterCriteria, String restrictInValuesCsv,
                                             Boolean perAENormalize, Integer limitN, Integer totalCount, String aggregationType) {
        
        // TODO: Implement actual KPI calculation logic
        // For now, build a placeholder message structure
        
        String message = '';
        
        // Header
        message += '# KPI Analysis\n\n';
        
        // Summary
        message += '## Summary\n';
        message += '- **Metric**: ' + metricKey + '\n';
        message += '- **Timeframe**: ' + timeframe + '\n';
        message += '- **Grouped By**: ' + groupBy + '\n';
        message += '- **Filter**: ' + (String.isNotBlank(filterCriteria) ? filterCriteria : 'None') + '\n';
        message += '- **Per-AE Normalized**: ' + (perAENormalize ? 'Yes' : 'No') + '\n';
        message += '- **Total Records Found**: ' + totalCount + '\n';
        // Only show limit if one was actually requested
        if (limitN != null && limitN > 0) {
            message += '- **Limit Applied**: ' + limitN + '\n';
        }
        if (timeframe == 'PREVIOUS' && (metricKey == 'AI_MENTIONS' || metricKey == 'COVERAGE')) {
            message += '- **Note**: ' + metricKey + ' not available for PREVIOUS timeframe\n';
        }
        message += '\n';
        
        // Insights (placeholder)
        message += '## Insights\n';
        if (totalCount > 0) {
            message += '- **Total Records**: ' + totalCount + ' records found\n';
            // Only show limit info if a limit was actually requested
            if (limitN != null && limitN > 0) {
                message += '- **Records Shown**: ' + records.size() + ' records (limited by ' + limitN + ')\n';
            } else {
                message += '- **Records Shown**: ' + records.size() + ' records\n';
            }
            
            // Basic KPI calculations
            if (records.size() > 0) {
                if (metricKey == 'GROWTH_FACTOR' || metricKey == 'GF') {
                    if (groupBy == 'GROWTH_FACTOR') {
                        // Special case: Grouping by Growth Factor means we want to count frequency of each Growth Factor
                        Map<String, Integer> growthFactorCounts = new Map<String, Integer>();
                        Map<String, String> definitionDescriptions = new Map<String, String>();
                        
                        for (AGENT_OU_PIPELINE_V2__c record : records) {
                            if (String.isNotBlank(record.definition__c)) {
                                String definition = record.definition__c;
                                growthFactorCounts.put(definition, growthFactorCounts.get(definition) != null ? growthFactorCounts.get(definition) + 1 : 1);
                                if (String.isNotBlank(record.description__c)) {
                                    definitionDescriptions.put(definition, record.description__c);
                                }
                            }
                        }
                        
                        message += '- **Unique Growth Factors Found**: ' + growthFactorCounts.size() + '\n';
                        message += '- **Top Growth Factors by Frequency**:\n';
                        
                        // Sort by count (descending) and show top ones
                        List<String> sortedDefinitions = new List<String>(growthFactorCounts.keySet());
                        sortedDefinitions.sort(new GrowthFactorCountComparator(growthFactorCounts));
                        
                        // Apply limit to show only top N growth factors
                        Integer displayLimit = limitN != null && limitN > 0 ? limitN : sortedDefinitions.size();
                        Integer actualShown = Math.min(displayLimit, sortedDefinitions.size());
                        
                        for (Integer i = 0; i < actualShown; i++) {
                            String definition = sortedDefinitions[i];
                            Integer count = growthFactorCounts.get(definition);
                            message += '  - **' + definition + '**: ' + count + ' occurrences';
                            if (definitionDescriptions.containsKey(definition)) {
                                message += ' - ' + definitionDescriptions.get(definition);
                            }
                            message += '\n';
                        }
                        
                        // Show limit info if applicable
                        if (limitN != null && limitN > 0 && sortedDefinitions.size() > limitN) {
                            message += '  - *... and ' + (sortedDefinitions.size() - limitN) + ' more growth factors*\n';
                        }
                    } else {
                        // For Growth Factor analysis grouped by other dimensions, show unique definitions and descriptions
                        Set<String> uniqueDefinitions = new Set<String>();
                        Map<String, String> definitionDescriptions = new Map<String, String>();
                        
                        for (AGENT_OU_PIPELINE_V2__c record : records) {
                            if (String.isNotBlank(record.definition__c)) {
                                uniqueDefinitions.add(record.definition__c);
                                if (String.isNotBlank(record.description__c)) {
                                    definitionDescriptions.put(record.definition__c, record.description__c);
                                }
                            }
                        }
                        
                        message += '- **Unique Growth Factors Found**: ' + uniqueDefinitions.size() + '\n';
                        message += '- **Growth Factors**: ' + joinList(new List<String>(uniqueDefinitions), ', ') + '\n';
                        
                        if (!definitionDescriptions.isEmpty()) {
                            message += '\n**Growth Factor Details**:\n';
                            for (String definition : definitionDescriptions.keySet()) {
                                message += '- **' + definition + '**: ' + definitionDescriptions.get(definition) + '\n';
                            }
                        }
                    }
                } else {
                    // For numeric metrics, show only the essential grouped results
                    // Skip Growth Factor metrics as they don't have numeric fields to aggregate
                    if (metricKey != 'GROWTH_FACTOR' && metricKey != 'GF') {
                        String metricField = METRIC_FIELD_MAP.get(metricKey).get(timeframe);
                        
                        // Build clean grouped results without repetitive totals
                        message += buildCleanGroupedResults(records, metricKey, timeframe, groupBy, metricField);
                    }
                }
            }
        } else {
            message += '- No records found matching the criteria\n';
        }
        
        if (String.isNotBlank(restrictInValuesCsv)) {
            message += '- Results restricted to: ' + restrictInValuesCsv + '\n';
        }
        message += '\n';
        
        // Limits & Counts
        message += '## Limits & Counts\n';
        message += '- **Total Records Found**: ' + totalCount + '\n';
        message += '- **Records Shown**: ' + records.size() + ' records\n';
        // Only show limit info if a limit was actually requested
        if (limitN != null && limitN > 0) {
            message += '- **Limit Applied**: ' + limitN + '\n';
            if (totalCount > limitN) {
                message += '- **Note**: Showing top ' + limitN + ' of ' + totalCount + ' total records\n';
            }
        }
        if (timeframe == 'PREVIOUS' && (metricKey == 'AI_MENTIONS' || metricKey == 'COVERAGE')) {
            message += '- **Note**: ' + metricKey + ' not available for PREVIOUS timeframe\n';
        }
        message += '\n';
        
        // Data (JSON)
        message += '## Data (JSON)\n';
        message += '```json\n';
        message += '{\n';
        message += '  "metric": "' + metricKey + '",\n';
        message += '  "timeframe": "' + timeframe + '",\n';
        message += '  "groupBy": "' + groupBy + '",\n';
        message += '  "filter": "' + (String.isNotBlank(filterCriteria) ? filterCriteria : '') + '",\n';
        message += '  "perAENormalize": ' + perAENormalize + ',\n';
        message += '  "totalCount": ' + totalCount + ',\n';
        // Only include limit in JSON if one was actually requested
        if (limitN != null && limitN > 0) {
            message += '  "limit": ' + limitN + ',\n';
        }
        message += '  "groups": []\n';
        message += '}\n';
        message += '```\n';
        
        return message;
    }
    
    /**
     * Builds message for unavailable metrics
     */
    private static String buildUnavailableMetricMessage(String metricKey, String timeframe) {
        return '# KPI Analysis\n\n## Error\n' +
               'The metric "' + metricKey + '" is not available for "' + timeframe + '" timeframe.\n\n' +
               '**Available combinations:**\n' +
               '- CURRENT: All metrics (ACV, PG, CALLS, MEETINGS, AI_MENTIONS, COVERAGE)\n' +
               '- PREVIOUS: ACV, PG, CALLS, MEETINGS only\n\n' +
               'AI_MENTIONS and COVERAGE are only available for CURRENT timeframe.';
    }
    
    /**
     * Builds error message
     */
    private static String buildErrorMessage(String errorMessage) {
        return '# KPI Analysis\n\n## Error\n' + errorMessage;
    }
    
    /**
     * Builds clean, focused grouped results without repetition
     */
    private static String buildCleanGroupedResults(List<AGENT_OU_PIPELINE_V2__c> records, String metricKey, String timeframe, String groupBy, String metricField) {
        String metricDisplayName = getMetricDisplayName(metricKey, timeframe);
        String result = '\n**' + metricDisplayName + ' by ' + groupBy + '**:\n';
        
        // Group records by the grouping field
        Map<String, List<AGENT_OU_PIPELINE_V2__c>> groupedRecords = new Map<String, List<AGENT_OU_PIPELINE_V2__c>>();
        Map<String, Decimal> groupTotals = new Map<String, Decimal>();
        Map<String, Integer> groupCounts = new Map<String, Integer>();
        
        String groupField = GROUP_FIELD_MAP.get(groupBy);
        
        for (AGENT_OU_PIPELINE_V2__c record : records) {
            String groupValue = String.valueOf(record.get(groupField));
            if (String.isBlank(groupValue)) groupValue = 'Unknown';
            
            if (!groupedRecords.containsKey(groupValue)) {
                groupedRecords.put(groupValue, new List<AGENT_OU_PIPELINE_V2__c>());
                groupTotals.put(groupValue, 0);
                groupCounts.put(groupValue, 0);
            }
            
            groupedRecords.get(groupValue).add(record);
            groupCounts.put(groupValue, groupCounts.get(groupValue) + 1);
            
            Object fieldValue = record.get(metricField);
            if (fieldValue != null) {
                groupTotals.put(groupValue, groupTotals.get(groupValue) + (Decimal)fieldValue);
            }
        }
        
        // Sort groups by total value (descending)
        List<String> sortedGroups = new List<String>(groupTotals.keySet());
        sortedGroups.sort(new GroupTotalComparator(groupTotals));
        
        // Build clean, focused results - just the key metrics
        for (String groupValue : sortedGroups) {
            Decimal total = groupTotals.get(groupValue);
            Integer count = groupCounts.get(groupValue);
            Decimal average = count > 0 ? total / count : 0;
            
            // Format based on metric type
            String formattedTotal = formatMetricValue(metricKey, total);
            String formattedAverage = formatMetricValue(metricKey, average);
            
            result += '- **' + groupValue + '**: ' + formattedTotal + ' total, ' + formattedAverage + ' avg\n';
        }
        
        return result;
    }
    
    /**
     * Builds grouped results for better insights (kept for backward compatibility)
     */
    private static String buildGroupedResults(List<AGENT_OU_PIPELINE_V2__c> records, String metricKey, String timeframe, String groupBy, String metricField) {
        String result = '\n**Grouped Results by ' + groupBy + '**:\n';
        
        // Group records by the grouping field
        Map<String, List<AGENT_OU_PIPELINE_V2__c>> groupedRecords = new Map<String, List<AGENT_OU_PIPELINE_V2__c>>();
        Map<String, Decimal> groupTotals = new Map<String, Decimal>();
        Map<String, Integer> groupCounts = new Map<String, Integer>();
        
        String groupField = GROUP_FIELD_MAP.get(groupBy);
        
        for (AGENT_OU_PIPELINE_V2__c record : records) {
            String groupValue = String.valueOf(record.get(groupField));
            if (String.isBlank(groupValue)) groupValue = 'Unknown';
            
            if (!groupedRecords.containsKey(groupValue)) {
                groupedRecords.put(groupValue, new List<AGENT_OU_PIPELINE_V2__c>());
                groupTotals.put(groupValue, 0);
                groupCounts.put(groupValue, 0);
            }
            
            groupedRecords.get(groupValue).add(record);
            groupCounts.put(groupValue, groupCounts.get(groupValue) + 1);
            
            Object fieldValue = record.get(metricField);
            if (fieldValue != null) {
                groupTotals.put(groupValue, groupTotals.get(groupValue) + (Decimal)fieldValue);
            }
        }
        
        // Sort groups by total value (descending)
        List<String> sortedGroups = new List<String>(groupTotals.keySet());
        sortedGroups.sort(new GroupTotalComparator(groupTotals));
        
        // Build the grouped results table
        result += '| ' + groupBy + ' | Total ' + metricKey + ' | Count | Average |\n';
        result += '|------|------------------|-------|--------|\n';
        
        for (String groupValue : sortedGroups) {
            Decimal total = groupTotals.get(groupValue);
            Integer count = groupCounts.get(groupValue);
            Decimal average = count > 0 ? total / count : 0;
            
            result += '| **' + groupValue + '** | ' + total.setScale(2) + ' | ' + count + ' | ' + average.setScale(2) + ' |\n';
        }
        
        return result;
    }
    
    /**
     * Converts technical metric keys to user-friendly labels
     */
    private static String getMetricDisplayName(String metricKey, String timeframe) {
        Map<String, String> metricLabels = new Map<String, String>{
            'ACV' => 'ACV',
            'PG' => 'Pipeline Generated',
            'CALLS' => 'Call Connects',
            'MEETINGS' => 'Customer Meetings',
            'COVERAGE' => 'Coverage',
            'QUOTA' => 'Quota',
            'CC_ACV' => 'Create and Close ACV',
            'CQ_CC_ACV' => 'Current Quarter Create and Close ACV',
            'PQ_CC_ACV' => 'Previous Quarter Create and Close ACV',
            'DAYS_ACV' => 'Days to ACV',
            'DAYS_PG' => 'Days to Pipeline',
            'AOV' => 'Average Order Value',
            'FULL_TOTAL_ACV_QUOTA' => 'Total ACV Quota Attained',
            'DAYS_TO_PRODUCTIVITY' => 'Days to Productivity',
            'GROWTH_FACTOR' => 'Growth Factor',
            'GF' => 'Growth Factor'
        };
        
        // Handle CQ_ and PQ_ prefixed metrics
        if (metricKey.startsWith('CQ_')) {
            String baseMetric = metricKey.substring(3); // Remove CQ_ prefix
            if (metricLabels.containsKey(baseMetric)) {
                return 'Current Quarter ' + metricLabels.get(baseMetric);
            }
        } else if (metricKey.startsWith('PQ_')) {
            String baseMetric = metricKey.substring(3); // Remove PQ_ prefix
            if (metricLabels.containsKey(baseMetric)) {
                return 'Previous Quarter ' + metricLabels.get(baseMetric);
            }
        }
        
        // Return user-friendly label or original if not found
        return metricLabels.containsKey(metricKey) ? metricLabels.get(metricKey) : metricKey;
    }
    
    /**
     * Formats metric values for better readability
     */
    private static String formatMetricValue(String metricKey, Decimal value) {
        if (value == null || value == 0) return '0';
        
        // Format currency values
        if (metricKey.contains('ACV') || metricKey.contains('PG') || metricKey.contains('QUOTA') || 
            metricKey.contains('AOV') || metricKey.contains('CC_ACV')) {
            if (value >= 1000000) {
                return '$' + (value / 1000000).setScale(2) + 'M';
            } else if (value >= 1000) {
                return '$' + (value / 1000).setScale(2) + 'K';
            } else {
                return '$' + value.setScale(2);
            }
        }
        
        // Format regular numbers
        if (value >= 1000000) {
            return (value / 1000000).setScale(2) + 'M';
        } else if (value >= 1000) {
            return (value / 1000).setScale(2) + 'K';
        } else {
            return value.setScale(2).toString();
        }
    }
    
    /**
     * Comparator class for sorting Growth Factors by count (descending)
     */
    public class GrowthFactorCountComparator implements Comparator<String> {
        private Map<String, Integer> countMap;
        
        public GrowthFactorCountComparator(Map<String, Integer> countMap) {
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
     * Comparator class for sorting groups by total value (descending)
     */
    public class GroupTotalComparator implements Comparator<String> {
        private Map<String, Decimal> totalMap;
        
        public GroupTotalComparator(Map<String, Decimal> totalMap) {
            this.totalMap = totalMap;
        }
        
        public Integer compare(String a, String b) {
            Decimal totalA = totalMap.get(a) != null ? totalMap.get(a) : 0;
            Decimal totalB = totalMap.get(b) != null ? totalMap.get(b) : 0;
            if (totalA < totalB) return 1;  // Descending order
            if (totalA > totalB) return -1;
            return 0;
        }
    }

    /**
     * Get comprehensive field mapping information for debugging and documentation
     * This helps developers understand what fields are supported and how they map
     */
    public static Map<String, Object> getFieldMappingInfo() {
        Map<String, Object> mappingInfo = new Map<String, Object>();
        
        // User-friendly aliases
        mappingInfo.put('userFriendlyAliases', FILTER_FIELD_MAP);
        
        // API field variations
        Map<String, String> apiFieldToUserKey = new Map<String, String>{
            'RAMP_STATUS__C' => 'ramp_status',
            'RAMP_STATUS__c' => 'ramp_status',
            'RAMP_STATUS' => 'ramp_status',
            'RAMPSTATUS__C' => 'ramp_status',
            'RAMPSTATUS__c' => 'ramp_status',
            'RAMPSTATUS' => 'ramp_status',
            'OU_NAME__C' => 'ou',
            'OU_NAME__c' => 'ou',
            'OU_NAME' => 'ou',
            'OUNAME__C' => 'ou',
            'OUNAME__c' => 'ou',
            'OUNAME' => 'ou',
            'OPERATING_UNIT__C' => 'ou',
            'OPERATING_UNIT__c' => 'ou',
            'OPERATING_UNIT' => 'ou',
            'WORK_LOCATION_COUNTRY__C' => 'country',
            'WORK_LOCATION_COUNTRY__c' => 'country',
            'WORK_LOCATION_COUNTRY' => 'country',
            'WORKLOCATIONCOUNTRY__C' => 'country',
            'WORKLOCATIONCOUNTRY__c' => 'country',
            'WORKLOCATIONCOUNTRY' => 'country',
            'COUNTRY__C' => 'country',
            'COUNTRY__c' => 'country',
            'COUNTRY' => 'country',
            'PRIMARY_INDUSTRY__C' => 'industry',
            'PRIMARY_INDUSTRY__c' => 'industry',
            'PRIMARY_INDUSTRY' => 'industry',
            'PRIMARYINDUSTRY__C' => 'industry',
            'PRIMARYINDUSTRY__c' => 'industry',
            'PRIMARYINDUSTRY' => 'industry',
            'INDUSTRY__C' => 'industry',
            'INDUSTRY__c' => 'industry',
            'INDUSTRY' => 'industry',
            'FULL_NAME__C' => 'ae',
            'FULL_NAME__c' => 'ae',
            'FULL_NAME' => 'ae',
            'FULLNAME__C' => 'ae',
            'FULLNAME__c' => 'ae',
            'FULLNAME' => 'ae',
            'NAME__C' => 'ae',
            'NAME__c' => 'ae',
            'NAME' => 'ae',
            'EMP_MGR_NM__C' => 'manager',
            'EMP_MGR_NM__c' => 'manager',
            'EMP_MGR_NM' => 'manager',
            'EMPMGRNM__C' => 'manager',
            'EMPMGRNM__c' => 'manager',
            'EMPMGRNM' => 'manager',
            'MANAGER__C' => 'manager',
            'MANAGER__c' => 'manager',
            'MANAGER' => 'manager',
            'EMP_EMAIL_ADDR__C' => 'email',
            'EMP_EMAIL_ADDR__c' => 'email',
            'EMP_EMAIL_ADDR' => 'email',
            'EMPEMAILADDR__C' => 'email',
            'EMPEMAILADDR__c' => 'email',
            'EMPEMAILADDR' => 'email',
            'EMAIL__C' => 'email',
            'EMAIL__c' => 'email',
            'EMAIL' => 'email',
            'LEARNER_PROFILE_ID__C' => 'learner_profile',
            'LEARNER_PROFILE_ID__c' => 'learner_profile',
            'LEARNER_PROFILE_ID' => 'learner_profile',
            'LEARNERPROFILEID__C' => 'learner_profile',
            'LEARNERPROFILEID__c' => 'learner_profile',
            'LEARNERPROFILEID' => 'learner_profile',
            'PROFILE__C' => 'learner_profile',
            'PROFILE__c' => 'learner_profile',
            'PROFILE' => 'learner_profile',
            'DEFINITION__C' => 'definition',
            'DEFINITION__c' => 'definition',
            'DEFINITION' => 'definition',
            'DEF__C' => 'definition',
            'DEF__c' => 'definition',
            'DEF' => 'definition',
            'DESCRIPTION__C' => 'description',
            'DESCRIPTION__c' => 'description',
            'DESCRIPTION' => 'description',
            'DESC__C' => 'description',
            'DESC__c' => 'description',
            'DESC' => 'description',
            'TIME_SINCE_ONBOARDING__C' => 'time_since_onboarding',
            'TIME_SINCE_ONBOARDING__c' => 'time_since_onboarding',
            'TIME_SINCE_ONBOARDING' => 'time_since_onboarding',
            'TIMESINCEONBOARDING__C' => 'time_since_onboarding',
            'TIMESINCEONBOARDING__c' => 'time_since_onboarding',
            'TIMESINCEONBOARDING' => 'time_since_onboarding',
            'TENURE__C' => 'time_since_onboarding',
            'TENURE__c' => 'time_since_onboarding',
            'TENURE' => 'time_since_onboarding',
            'ONBOARDING__C' => 'time_since_onboarding',
            'ONBOARDING__c' => 'time_since_onboarding',
            'ONBOARDING' => 'time_since_onboarding'
        };
        mappingInfo.put('apiFieldVariations', apiFieldToUserKey);
        
        // Final SOQL field names
        mappingInfo.put('finalSOQLFields', new Set<String>{
            'work_location_country__c',
            'ou_name__c',
            'primary_industry__c',
            'full_name__c',
            'emp_mgr_nm__c',
            'emp_email_addr__c',
            'learner_profile_id__c',
            'definition__c',
            'description__c',
            'ramp_status__c',
            'time_since_onboarding__c'
        });
        
        // Business context patterns for smart detection
        mappingInfo.put('businessContextPatterns', new Map<String, List<String>>{
            'Geographic' => new List<String>{'country', 'nation', 'location', 'region', 'geo', 'territory'},
            'Operating Unit' => new List<String>{'ou', 'operating', 'unit', 'division', 'segment', 'business_unit'},
            'Industry' => new List<String>{'industry', 'sector', 'vertical', 'business_type', 'market'},
            'Employee' => new List<String>{'ae', 'employee', 'rep', 'salesperson', 'seller', 'name', 'person'},
            'Manager' => new List<String>{'manager', 'supervisor', 'boss', 'lead', 'director'},
            'Contact' => new List<String>{'email', 'contact', 'address', 'communication'},
            'Learning' => new List<String>{'learner', 'learning', 'enablement', 'training', 'profile', 'education'},
            'Growth Factor' => new List<String>{'growth', 'factor', 'definition', 'area', 'improvement', 'development', 'focus', 'gf'},
            'Description' => new List<String>{'description', 'explanation', 'details', 'meaning', 'desc'},
            'Ramp Status' => new List<String>{'ramp', 'onboarding', 'performance', 'status', 'level', 'category'},
            'Tenure' => new List<String>{'tenure', 'onboarding', 'experience', 'months', 'time', 'seniority', 'years', 'service'}
        });
        
        return mappingInfo;
    }
    
    /**
     * Validate field mapping for a given filter criteria
     * Returns detailed information about what fields were mapped and any issues
     */
    public static Map<String, Object> validateFieldMapping(String filterCriteria) {
        Map<String, Object> validation = new Map<String, Object>();
        validation.put('originalFilter', filterCriteria);
        validation.put('mappedFilter', '');
        validation.put('mappingIssues', new List<String>());
        validation.put('successfullyMapped', new List<String>());
        validation.put('unmappedFields', new List<String>());
        
        if (String.isBlank(filterCriteria)) {
            validation.put('mappingIssues', new List<String>{'Filter criteria is blank'});
            return validation;
        }
        
        try {
            String mappedFilter = parseFilterCriteria(filterCriteria);
            validation.put('mappedFilter', mappedFilter);
            
            // Extract field names from the mapped filter
            Set<String> mappedFields = new Set<String>();
            String[] parts = mappedFilter.split(' ');
            for (String part : parts) {
                if (part.contains('__c')) {
                    String fieldName = part.substring(0, part.indexOf('__c') + 3);
                    mappedFields.add(fieldName);
                }
            }
            
            validation.put('successfullyMapped', new List<String>(mappedFields));
            
            // Check for any remaining unmapped fields (without __c)
            Set<String> unmappedFields = new Set<String>();
            for (String part : parts) {
                if ((part.contains('=') || part.contains(' IN') || part.contains(' LIKE') || 
                     part.contains(' <>') || part.contains(' <') || part.contains(' >') || 
                     part.contains(' <=') || part.contains(' >=')) && 
                    !part.contains('__c') && !part.contains('\'') && !part.contains('(') && !part.contains(')')) {
                    
                    String fieldName = part.substring(0, part.indexOf('='));
                    if (part.contains(' IN')) fieldName = part.substring(0, part.indexOf(' IN'));
                    if (part.contains(' LIKE')) fieldName = part.substring(0, part.indexOf(' LIKE'));
                    if (part.contains(' <>')) fieldName = part.substring(0, part.indexOf(' <>'));
                    if (part.contains(' <=')) fieldName = part.substring(0, part.indexOf(' <='));
                    if (part.contains(' >=')) fieldName = part.substring(0, part.indexOf(' >='));
                    if (part.contains(' <')) fieldName = part.substring(0, part.indexOf(' <'));
                    if (part.contains(' >')) fieldName = part.substring(0, part.indexOf(' >'));
                    
                    unmappedFields.add(fieldName);
                }
            }
            
            validation.put('unmappedFields', new List<String>(unmappedFields));
            
            if (!unmappedFields.isEmpty()) {
                validation.put('mappingIssues', new List<String>{'Some fields could not be mapped: ' + joinList(new List<String>(unmappedFields), ', ')});
            }
            
        } catch (Exception e) {
            validation.put('mappingIssues', new List<String>{'Exception during mapping: ' + e.getMessage()});
        }
        
        return validation;
    }

    /**
     * Custom join method for List<String> to handle null/empty list
     */
    private static String joinList(List<String> listToJoin, String separator) {
        if (listToJoin == null || listToJoin.isEmpty()) {
            return '';
        }
        return String.join(listToJoin, separator);
    }
} 