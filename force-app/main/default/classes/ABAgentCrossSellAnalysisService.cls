/**
 * OPTIMIZED CROSS-SELL ANALYSIS SERVICE - Uses aggregate queries to prevent heap size issues
 * Business Requirement: Service methods return a single composed message string for agent consumption.
 * @description Optimized service class for Cross-Sell Analysis operations on Agent_Cross_Sell__c records.
 * Handles all business logic for analyzing cross-sell data across AEs with grouping, filtering, and aggregation.
 * Uses aggregate queries to prevent heap size issues when processing large datasets.
 *
 * Key fields referenced (ONLY these allowed):
 *   - emp_id__c: Employee identifier for the AE
 *   - full_name__c: AE full name
 *   - emp_email_addr__c: AE email address
 *   - work_location_country__c: Work location country of the AE
 *   - ou_name__c: Organizational Unit (core partition filter)
 *   - emp_mgr_nm__c: Manager name of the AE
 *   - primary_industry__c: Primary industry classification
 *   - cross_sell_next_best_product__c: Product name for cross-sell
 *   - cross_sell_acct_nm__c: Account name associated with the cross-sell
 *   - cross_sell_acct_id__c: Account ID associated with the cross-sell
 *   - cross_sell_rn__c: Cross-sell round/rank/sequence number
 *   - learner_profile_id__c: Linked learner profile ID (enablement)
 *   - macrosgment__c: Macro segment classification (CMRCL, ESMB, etc.)
 *   - ramp_status__c: AE ramp status
 *   - time_since_onboarding__c: Time since onboarding in months (decimal)
 *
 * @version 2.0 - Optimized for heap efficiency
 */
public with sharing class ABAgentCrossSellAnalysisService {

    // Field mapping constants for grouping
    private static final Map<String, String> GROUP_FIELD_MAP = new Map<String, String>{
        'PRODUCT' => 'cross_sell_next_best_product__c',
        'INDUSTRY' => 'primary_industry__c',
        'MACRO_SEGMENT' => 'macrosgment__c',
        'AE' => 'full_name__c',
        'COUNTRY' => 'work_location_country__c',
        'MANAGER' => 'emp_mgr_nm__c',
        'ACCOUNT' => 'cross_sell_acct_nm__c'
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

        // Cross-Sell Fields
        'cross_sell_next_best_product' => 'cross_sell_next_best_product__c',
        'product' => 'cross_sell_next_best_product__c',
        'product_name' => 'cross_sell_next_best_product__c',
        'cross_sell_product' => 'cross_sell_next_best_product__c',
        'next_best_product' => 'cross_sell_next_best_product__c',

        'cross_sell_acct_nm' => 'cross_sell_acct_nm__c',
        'account_name' => 'cross_sell_acct_nm__c',
        'account' => 'cross_sell_acct_nm__c',
        'customer' => 'cross_sell_acct_nm__c',

        'cross_sell_acct_id' => 'cross_sell_acct_id__c',
        'account_id' => 'cross_sell_acct_id__c',
        'customer_id' => 'cross_sell_acct_id__c',

        'cross_sell_rn' => 'cross_sell_rn__c',
        'cross_sell_round' => 'cross_sell_rn__c',
        'cross_sell_rank' => 'cross_sell_rn__c',
        'round' => 'cross_sell_rn__c',
        'rank' => 'cross_sell_rn__c',

        // Employee Fields
        'emp_id' => 'emp_id__c',
        'emp' => 'emp_id__c',
        'employee_id' => 'emp_id__c',
        'employee' => 'emp_id__c',
        'ae_id' => 'emp_id__c',

        'full_name' => 'full_name__c',
        'name' => 'full_name__c',
        'ae_name' => 'full_name__c',
        'sales_rep' => 'full_name__c',

        'emp_email_addr' => 'emp_email_addr__c',
        'emp_email' => 'emp_email_addr__c',
        'email' => 'emp_email_addr__c',
        'ae_email' => 'emp_email_addr__c',

        'emp_mgr_nm' => 'emp_mgr_nm__c',
        'emp_mgr' => 'emp_mgr_nm__c',
        'manager' => 'emp_mgr_nm__c',
        'mgr' => 'emp_mgr_nm__c',
        'mgr_name' => 'emp_mgr_nm__c',
        'sales_manager' => 'emp_mgr_nm__c',

        // Additional Fields
        'learner_profile_id' => 'learner_profile_id__c',
        'learner_id' => 'learner_profile_id__c',
        'profile_id' => 'learner_profile_id__c',

        'ramp_status' => 'ramp_status__c',
        'ramp' => 'ramp_status__c',
        'onboarding_status' => 'ramp_status__c',

        'time_since_onboarding' => 'time_since_onboarding__c',
        'onboarding_time' => 'time_since_onboarding__c',
        'months_onboarded' => 'time_since_onboarding__c',
        'tenure' => 'time_since_onboarding__c'
    };

    /**
     * Main method to analyze Cross-Sell data based on specified parameters
     * Returns a single composed message string for the agent
     */
    public static String analyzeCrossSell(String ouName, String workLocationCountry, String groupBy,
                                       String filterCriteria, String restrictInValuesCsv,
                                       Boolean perAENormalize, Integer limitN, String aggregationType, String analysisType) {

        try {
            // Validate and enforce governor safety
            CrossSellQueryRequest req = enforceGovernorSafety(ouName, workLocationCountry, groupBy, 
                                                           filterCriteria, restrictInValuesCsv, 
                                                           perAENormalize, limitN, aggregationType, analysisType);
            if (req == null) {
                return buildErrorMessage('Invalid request parameters. Please check your input and try again.');
            }

            // Query top cross-sell data using aggregate queries
            List<CrossSellRowDTO> results = queryTopCrossSell(req);

            // Build analysis message
            return buildAnalysisMessage(results, req);

        } catch (Exception e) {
            AgentLog.error('analyzeCrossSell', 'Cross-Sell analysis failed', new Map<String, Object>{
                'error' => e.getMessage(),
                'stackTrace' => e.getStackTraceString()
            });
            return buildErrorMessage('Cross-Sell analysis failed: ' + e.getMessage());
        }
    }

    /**
     * Validates request parameters and enforces governor limits
     */
    private static CrossSellQueryRequest enforceGovernorSafety(String ouName, String workLocationCountry, 
                                                             String groupBy, String filterCriteria, 
                                                             String restrictInValuesCsv, Boolean perAENormalize, 
                                                             Integer limitN, String aggregationType, String analysisType) {
        
        // Validate groupBy
        if (String.isBlank(groupBy) || !GROUP_FIELD_MAP.containsKey(groupBy)) {
            AgentLog.error('enforceGovernorSafety', 'Invalid groupBy', new Map<String, Object>{
                'groupBy' => groupBy,
                'validOptions' => GROUP_FIELD_MAP.keySet()
            });
            return null;
        }
        
        // Validate limitN
        if (limitN == null || limitN <= 0) {
            limitN = 20; // Default limit
        } else if (limitN > 200) {
            AgentLog.error('enforceGovernorSafety', 'limitN too large', new Map<String, Object>{
                'limitN' => limitN,
                'maxAllowed' => 200
            });
            return null;
        }
        
        // Validate that at least one filter is provided
        if (String.isBlank(ouName) && String.isBlank(workLocationCountry)) {
            AgentLog.error('enforceGovernorSafety', 'No filters provided', new Map<String, Object>{
                'ouName' => ouName,
                'workLocationCountry' => workLocationCountry
            });
            return null;
        }

        return new CrossSellQueryRequest(ouName, workLocationCountry, groupBy, filterCriteria, 
                                       restrictInValuesCsv, perAENormalize, limitN, aggregationType, analysisType);
    }

    /**
     * Query top cross-sell data using aggregate queries to prevent heap issues
     */
    public static List<CrossSellRowDTO> queryTopCrossSell(CrossSellQueryRequest req) {
        String groupField = GROUP_FIELD_MAP.get(req.groupBy);

        // Build aggregate query
        String query = 'SELECT ' + groupField + ', COUNT(Id) recordCount, ';
        
        // Only add unique counts for fields that are not being grouped by
        if (req.groupBy != 'ACCOUNT') {
            query += 'COUNT_DISTINCT(cross_sell_acct_nm__c) uniqueAccounts, ';
        }
        if (req.groupBy != 'PRODUCT') {
            query += 'COUNT_DISTINCT(cross_sell_next_best_product__c) uniqueProducts ';
        }
        
        // Remove trailing comma if present
        if (query.endsWith(', ')) {
            query = query.substring(0, query.length() - 2);
        }
        
        query += ' FROM Agent_Cross_Sell__c';

        // Build WHERE clause with proper filtering
            List<String> whereClauses = new List<String>();

        // Always include IsDeleted = false
        whereClauses.add('IsDeleted = false');

        // Add OU filter if provided
        if (String.isNotBlank(req.ouName)) {
            whereClauses.add('ou_name__c = \'' + String.escapeSingleQuotes(req.ouName) + '\'');
        }

        // Add country filter if provided
        if (String.isNotBlank(req.workLocationCountry)) {
            whereClauses.add('work_location_country__c = \'' + String.escapeSingleQuotes(req.workLocationCountry) + '\'');
        }

        // Add custom filter criteria if provided
        if (String.isNotBlank(req.filterCriteria)) {
            String parsedFilter = parseFilterCriteria(req.filterCriteria);
                if (String.isNotBlank(parsedFilter)) {
                whereClauses.add(parsedFilter);
                }
            }

            if (!whereClauses.isEmpty()) {
            query += ' WHERE ' + String.join(whereClauses, ' AND ');
        }

        // Add GROUP BY and ORDER BY
        query += ' GROUP BY ' + groupField;
        query += ' ORDER BY COUNT(Id) DESC';
        query += ' LIMIT ' + req.limitN;

        AgentLog.info('queryTopCrossSell', 'Executing aggregate query', new Map<String, Object>{
            'query' => query,
            'groupBy' => req.groupBy,
            'limitN' => req.limitN
        });

        // Execute query and convert to DTOs
        List<AggregateResult> results = Database.query(query);
        List<CrossSellRowDTO> dtos = new List<CrossSellRowDTO>();

        for (AggregateResult result : results) {
            CrossSellRowDTO dto = new CrossSellRowDTO();
            dto.key = (String)result.get(groupField);
            dto.count = (Integer)result.get('recordCount');
            
            // Set unique counts based on what was queried
            if (req.groupBy != 'ACCOUNT') {
                dto.uniqueAccounts = (Integer)result.get('uniqueAccounts');
            } else {
                dto.uniqueAccounts = 1; // When grouping by account, each group has 1 unique account
            }
            
            if (req.groupBy != 'PRODUCT') {
                dto.uniqueProducts = (Integer)result.get('uniqueProducts');
        } else {
                dto.uniqueProducts = 1; // When grouping by product, each group has 1 unique product
            }
            
            dtos.add(dto);
        }

        AgentLog.info('queryTopCrossSell', 'Query completed', new Map<String, Object>{
            'resultCount' => dtos.size(),
            'groupBy' => req.groupBy
        });
        return dtos;
    }

    /**
     * Builds the complete analysis message
     */
    private static String buildAnalysisMessage(List<CrossSellRowDTO> results, CrossSellQueryRequest req) {
        String message = '';

        // Header
        message += '# Cross-Sell Analysis\n\n';

        // Summary
        message += '## Summary\n';
        if (String.isNotBlank(req.ouName)) {
            message += '- **OU**: ' + req.ouName + '\n';
        }
        if (String.isNotBlank(req.workLocationCountry)) {
            message += '- **Work Location Country**: ' + req.workLocationCountry + '\n';
        }
        message += '- **Grouped By**: ' + req.groupBy + '\n';
        message += '- **Analysis Type**: ' + req.analysisType + '\n';
        message += '- **Filter**: ' + (String.isNotBlank(req.filterCriteria) ? req.filterCriteria : 'None') + '\n';
        message += '- **Per-AE Normalized**: ' + (req.perAENormalize ? 'Yes' : 'No') + '\n';
        message += '- **Time Range**: All available data (no date filtering applied)\n';
        message += '- **Limit Applied**: ' + req.limitN + '\n\n';

        // Results
        message += '## Results\n';
        message += '- **Records Found**: ' + results.size() + ' groups\n\n';

        if (results.isEmpty()) {
            message += 'No cross-sell data found matching the specified criteria.\n';
            message += '\n**Troubleshooting Tips:**\n';
            message += '- Verify the OU name exists in the system\n';
            message += '- Check if the country filter is correct\n';
            message += '- Try a different time period or remove date filters\n';
            message += '- Consider using a broader search criteria\n';
        } else {
            message += '**' + req.groupBy + ' Analysis**:\n';
            for (CrossSellRowDTO dto : results) {
                if (String.isNotBlank(dto.key)) {
                    message += '- **' + dto.key + '**: ' + dto.count + ' cross-sell opportunities';
                    message += ', ' + dto.uniqueAccounts + ' unique accounts';
                    message += ', ' + dto.uniqueProducts + ' unique products\n';
                }
            }
        }

        return message;
    }

    /**
     * Builds error message
     */
    private static String buildErrorMessage(String errorMessage) {
        return '# Cross-Sell Analysis\n\n## Error\n' + errorMessage;
    }

    /**
     * Parses filter criteria from user-friendly format to SOQL
     */
    public static String parseFilterCriteria(String filterCriteria) {
        if (String.isBlank(filterCriteria)) return '';

        String parsedFilter = filterCriteria;

        // Handle cases where agent sends API field names instead of user-friendly keys
        Map<String, String> apiFieldToUserKey = new Map<String, String>{
            'ou_name__C' => 'ou_name',
            'ou_name__c' => 'ou_name',
            'work_location_country__C' => 'work_location_country',
            'work_location_country__c' => 'work_location_country',
            'primary_industry__C' => 'primary_industry',
            'primary_industry__c' => 'primary_industry',
            'macrosgment__C' => 'macro_segment',
            'macrosgment__c' => 'macro_segment',
            'cross_sell_next_best_product__C' => 'cross_sell_next_best_product',
            'cross_sell_next_best_product__c' => 'cross_sell_next_best_product',
            'cross_sell_acct_nm__C' => 'cross_sell_acct_nm',
            'cross_sell_acct_nm__c' => 'cross_sell_acct_nm',
            'cross_sell_acct_id__C' => 'cross_sell_acct_id',
            'cross_sell_acct_id__c' => 'cross_sell_acct_id',
            'cross_sell_rn__C' => 'cross_sell_rn',
            'cross_sell_rn__c' => 'cross_sell_rn',
            'emp_id__C' => 'emp_id',
            'emp_id__c' => 'emp_id',
            'full_name__C' => 'full_name',
            'full_name__c' => 'full_name',
            'emp_email_addr__C' => 'emp_email_addr',
            'emp_email_addr__c' => 'emp_email_addr',
            'emp_mgr_nm__C' => 'emp_mgr_nm',
            'emp_mgr_nm__c' => 'emp_mgr_nm',
            'learner_profile_id__C' => 'learner_profile_id',
            'learner_profile_id__c' => 'learner_profile_id',
            'ramp_status__C' => 'ramp_status',
            'ramp_status__c' => 'ramp_status',
            'time_since_onboarding__C' => 'time_since_onboarding',
            'time_since_onboarding__c' => 'time_since_onboarding'
        };

        // First, convert API field names to user-friendly keys
        for (String apiField : apiFieldToUserKey.keySet()) {
            String userKey = apiFieldToUserKey.get(apiField);
            parsedFilter = replaceWordCI(parsedFilter, apiField, userKey);
        }

        // Convert base field names to API field names (longest first to prevent partial matches)
        List<String> fieldKeys = sortedKeysByLengthDesc(FILTER_FIELD_MAP);
        for (String key : fieldKeys) {
            String fieldName = FILTER_FIELD_MAP.get(key);
            parsedFilter = replaceWordCI(parsedFilter, key, fieldName);
        }

        return parsedFilter;
    }

    /**
     * @description Case-insensitive, word-boundary replacement for field mapping
     */
    private static String replaceWordCI(String src, String token, String repl) {
        if (String.isBlank(src) || String.isBlank(token)) return src;

        // Build regex pattern: (?i)(?<![A-Za-z0-9_])TOKEN(?![A-Za-z0-9_])
        String escapedToken = token.replaceAll('([\\\\\\.\\[\\]\\{\\}\\(\\)\\*\\+\\?\\|\\^\\$])', '\\\\$1');
        String pattern = '(?i)(?<![A-Za-z0-9_])' + escapedToken + '(?![A-Za-z0-9_])';
        return src.replaceAll(pattern, repl);
    }

    /**
     * @description Returns map keys sorted by length in descending order to prevent partial matches
     */
    private static List<String> sortedKeysByLengthDesc(Map<String, Object> inputMap) {
        List<String> keys = new List<String>(inputMap.keySet());
        keys.sort(new KeyLengthComparator());
        return keys;
    }

    /**
     * @description Provides field suggestions and validation for better agent accuracy
     */
    public static String getFieldSuggestions(String query) {
        if (String.isBlank(query)) {
            return 'Please provide a query to get field suggestions.';
        }

        String suggestions = '## Field Mapping Suggestions\n\n';
        suggestions += '**Query**: ' + query + '\n\n';

        // Check for common field patterns in the query
        String lowerQuery = query.toLowerCase();

        // Product-related suggestions
        if (lowerQuery.contains('product') || lowerQuery.contains('cross-sell')) {
            suggestions += '**Product Fields**:\n';
            suggestions += '- Use: `product` or `cross_sell_next_best_product`\n';
            suggestions += '- Example values: "Data Cloud", "Tableau Cloud Analytics", "Engagement & Journeys"\n';
            suggestions += '- Common aliases: product, product_name, cross_sell_product, next_best_product\n\n';
        }

        // Account-related suggestions
        if (lowerQuery.contains('account') || lowerQuery.contains('customer')) {
            suggestions += '**Account Fields**:\n';
            suggestions += '- Use: `account` or `cross_sell_acct_nm`\n';
            suggestions += '- Example values: "IT&Care", "Energir", "Bekiares Eliezer LLP"\n';
            suggestions += '- Common aliases: account, account_name, customer\n\n';
        }

        // Location-related suggestions
        if (lowerQuery.contains('country') || lowerQuery.contains('location')) {
            suggestions += '**Location Fields**:\n';
            suggestions += '- Use: `country` or `work_location_country`\n';
            suggestions += '- Example values: "Belgium", "Canada", "US", "Spain"\n';
            suggestions += '- Common aliases: country, location, work_country\n\n';
        }

        // Industry-related suggestions
        if (lowerQuery.contains('industry') || lowerQuery.contains('sector')) {
            suggestions += '**Industry Fields**:\n';
            suggestions += '- Use: `industry` or `primary_industry`\n';
            suggestions += '- Example values: "Financial Services", "Manufacturing, Automotive & Energy"\n';
            suggestions += '- Common aliases: industry, sector, business_industry\n\n';
        }

        suggestions += '**Available Field Aliases**:\n';
        for (String field : FILTER_FIELD_MAP.keySet()) {
            suggestions += '- ' + field + ' → ' + FILTER_FIELD_MAP.get(field) + '\n';
        }

        return suggestions;
    }

    /**
     * @description Validates filter criteria and provides suggestions for common errors
     */
    public static String validateFilterCriteria(String filterCriteria) {
        if (String.isBlank(filterCriteria)) {
            return 'Filter criteria is empty. Please provide a filter.';
        }

        String validation = '## Filter Validation Results\n\n';
        validation += '**Input**: ' + filterCriteria + '\n\n';

        // Check for proper quoting
        if (filterCriteria.contains('=') && !filterCriteria.contains('\'')) {
            validation += '⚠️ **WARNING**: Values should be quoted\n';
            validation += '   - Wrong: `product=Data Cloud`\n';
            validation += '   - Correct: `product=\'Data Cloud\'`\n\n';
        }

        validation += '**Field Mapping**:\n';
        for (String key : FILTER_FIELD_MAP.keySet()) {
            String fieldName = FILTER_FIELD_MAP.get(key);
            validation += '- ' + key + ' → ' + fieldName + '\n';
        }

        return validation;
    }

    // ========================================
    // INNER CLASSES
    // ========================================

    /**
     * Request object for cross-sell queries
     */
    public class CrossSellQueryRequest {
        public String ouName;
        public String workLocationCountry;
        public String groupBy;
        public String filterCriteria;
        public String restrictInValuesCsv;
        public Boolean perAENormalize;
        public Integer limitN;
        public String aggregationType;
        public String analysisType;

        public CrossSellQueryRequest(String ouName, String workLocationCountry, String groupBy,
                                   String filterCriteria, String restrictInValuesCsv, Boolean perAENormalize,
                                   Integer limitN, String aggregationType, String analysisType) {
            this.ouName = ouName;
            this.workLocationCountry = workLocationCountry;
            this.groupBy = groupBy;
            this.filterCriteria = filterCriteria;
            this.restrictInValuesCsv = restrictInValuesCsv;
            this.perAENormalize = perAENormalize;
            this.limitN = limitN;
            this.aggregationType = aggregationType;
            this.analysisType = analysisType;
        }
    }

    /**
     * DTO for cross-sell row data
     */
    public class CrossSellRowDTO {
        public String key;
        public Integer count;
        public Integer uniqueAccounts;
        public Integer uniqueProducts;
    }

    /**
     * @description Comparator for sorting keys by length in descending order
     */
    private class KeyLengthComparator implements Comparator<String> {
        public Integer compare(String a, String b) {
            if (a.length() > b.length()) return -1;
            if (a.length() < b.length()) return 1;
            return 0;
        }
    }
}