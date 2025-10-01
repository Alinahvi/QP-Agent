/**
 * OPTIMIZED UPSELL ANALYSIS SERVICE - Uses aggregate queries to prevent heap size issues
 * Business Requirement: Service methods return a single composed message string for agent consumption.
 * Handlers call into this class to perform Upsell Analysis operations.
 * @description Service class for Upsell Analysis operations on Agent_Upsell__c records.
 * Handles all business logic for analyzing upsell data across AEs with grouping, filtering, and aggregation.
 *
 * Key fields referenced (ONLY these allowed):
 *   - emp_id__c: Employee identifier for the AE
 *   - full_name__c: AE full name
 *   - emp_email_addr__c: AE email address
 *   - work_location_country__c: Work location country of the AE
 *   - ou_name__c: Organizational Unit (core partition filter)
 *   - emp_mgr_nm__c: Manager name of the AE
 *   - primary_industry__c: Primary industry classification
 *   - upsell_sub_category__c: Product name for upsell
 *   - upsell_acct_nm__c: Account name associated with the upsell
 *   - upsell_acct_id__c: Account ID associated with the upsell
 *   - upsell_rn__c: Upsell round/rank/sequence number
 *   - learner_profile_id__c: Linked learner profile ID (enablement)
 *   - macrosgment__c: Macro segment classification (CMRCL, ESMB, etc.)
 *   - ramp_status__c: AE ramp status
 *   - time_since_onboarding__c: Time since onboarding in months (decimal)
 *
 * @version 2.0 - Optimized for heap efficiency
 */
public with sharing class ABAgentUpsellAnalysisService {

    // Field mapping constants for grouping
    private static final Map<String, String> GROUP_FIELD_MAP = new Map<String, String>{
        'PRODUCT' => 'UPSELL_SUB_CATEGORY__c',
        'INDUSTRY' => 'PRIMARY_INDUSTRY__c',
        'MACRO_SEGMENT' => 'MACROSGMENT__c',
        'AE' => 'FULL_NAME__c',
        'COUNTRY' => 'WORK_LOCATION_COUNTRY__c',
        'MANAGER' => 'EMP_MGR_NM__c',
        'ACCOUNT' => 'UPSELL_ACCT_NM__c'
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

        // Upsell Fields
        'upsell_sub_category' => 'upsell_sub_category__c',
        'product' => 'upsell_sub_category__c',
        'product_name' => 'upsell_sub_category__c',
        'upsell_product' => 'upsell_sub_category__c',
        'sub_category' => 'upsell_sub_category__c',

        'upsell_acct_nm' => 'upsell_acct_nm__c',
        'account_name' => 'upsell_acct_nm__c',
        'account' => 'upsell_acct_nm__c',
        'customer' => 'upsell_acct_nm__c',

        'upsell_acct_id' => 'upsell_acct_id__c',
        'account_id' => 'upsell_acct_id__c',
        'customer_id' => 'upsell_acct_id__c',

        'upsell_rn' => 'upsell_rn__c',
        'upsell_round' => 'upsell_rn__c',
        'upsell_rank' => 'upsell_rn__c',
        'round' => 'upsell_rn__c',
        'rank' => 'upsell_rn__c',

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
     * DTO for query parameters
     */
    public class UpsellQueryRequest {
        public String ouName;
        public String workLocationCountry;
        public String groupBy;
        public String filterCriteria;
        public String restrictInValuesCsv;
        public Boolean perAENormalize;
        public Integer limitN;
        public String aggregationType;
        public String analysisType;

        public UpsellQueryRequest(String ouName, String workLocationCountry, String groupBy,
                                     String filterCriteria, String restrictInValuesCsv,
                                     Boolean perAENormalize, Integer limitN, String aggregationType, String analysisType) {
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
     * DTO for a single row of aggregated upsell data
     */
    public class UpsellRowDTO {
        public String key;
        public Integer count;
        public Integer uniqueAccounts;
        public Integer uniqueProducts;
    }

    /**
     * Main method to analyze Upsell data based on specified parameters
     * Returns a single composed message string for the agent
     */
    public static String analyzeUpsell(String ouName, String workLocationCountry, String groupBy,
                                             String filterCriteria, String restrictInValuesCsv,
                                     Boolean perAENormalize, Integer limitN, String aggregationType, String analysisType) {

        UpsellQueryRequest req = new UpsellQueryRequest(ouName, workLocationCountry, groupBy,
                                                       filterCriteria, restrictInValuesCsv,
                                                       perAENormalize, limitN, aggregationType, analysisType);

        // Enforce governor limits and validate inputs
        String validationError = enforceGovernorSafety(req);
        if (validationError != null) {
            return buildErrorMessage(validationError);
        }

        List<UpsellRowDTO> results = queryTopUpsell(req);

        // Process results and build analysis
        return buildAnalysisMessage(results, req);
    }

    /**
     * Executes an aggregate query to get top upsell data
     */
    public static List<UpsellRowDTO> queryTopUpsell(UpsellQueryRequest req) {
        String groupField = GROUP_FIELD_MAP.get(req.groupBy);

        // Build aggregate query
        String query = 'SELECT ' + groupField + ', COUNT(Id) recordCount, ';
        
        // Only add unique counts for fields that are not being grouped by
        if (req.groupBy != 'ACCOUNT') {
            query += 'COUNT_DISTINCT(upsell_acct_nm__c) uniqueAccounts, ';
        }
        if (req.groupBy != 'PRODUCT') {
            query += 'COUNT_DISTINCT(upsell_sub_category__c) uniqueProducts ';
        }
        
        // Remove trailing comma if present
        if (query.endsWith(', ')) {
            query = query.substring(0, query.length() - 2);
        }
        
        query += ' FROM Agent_Upsell__c';

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

        // Ensure the grouping field is not null
        if (String.isNotBlank(groupField)) {
            whereClauses.add(groupField + ' != null');
        }

        if (!whereClauses.isEmpty()) {
            query += ' WHERE ' + String.join(whereClauses, ' AND ');
        }

        // Add GROUP BY and ORDER BY
        query += ' GROUP BY ' + groupField;
        query += ' ORDER BY COUNT(Id) DESC'; // Order by count as requested
        query += ' LIMIT ' + req.limitN;

        AgentLog.info('queryTopUpsell', 'Executing aggregate query', new Map<String, Object>{
            'query' => query,
            'groupBy' => req.groupBy,
            'limitN' => req.limitN
        });

        // Execute query and convert to DTOs
        List<AggregateResult> results = Database.query(query);
        List<UpsellRowDTO> dtos = new List<UpsellRowDTO>();

        for (AggregateResult result : results) {
            UpsellRowDTO dto = new UpsellRowDTO();
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

        AgentLog.info('queryTopUpsell', 'Query completed', new Map<String, Object>{
            'resultCount' => dtos.size(),
            'groupBy' => req.groupBy
        });
        return dtos;
    }

    /**
     * Enforces governor limits and validates inputs
     */
    private static String enforceGovernorSafety(UpsellQueryRequest req) {
        // Validate groupBy
        if (!GROUP_FIELD_MAP.containsKey(req.groupBy)) {
            AgentLog.error('enforceGovernorSafety', 'Invalid groupBy field', new Map<String, Object>{
                'groupBy' => req.groupBy,
                'validOptions' => GROUP_FIELD_MAP.keySet()
            });
            return 'Invalid group by: ' + req.groupBy + '. Valid values are: ' + String.join(new List<String>(GROUP_FIELD_MAP.keySet()), ', ') + '.';
        }

        // Validate limitN
        if (req.limitN == null || req.limitN <= 0) {
            req.limitN = 20; // Default limit
        } else if (req.limitN > 200) {
            AgentLog.error('enforceGovernorSafety', 'limitN too large', new Map<String, Object>{
                'limitN' => req.limitN,
                'maxAllowed' => 200
            });
            return 'The requested limit (' + req.limitN + ') is too large. Please request a limit up to 200.';
        }

        // Validate that at least one filter is provided
        if (String.isBlank(req.ouName) && String.isBlank(req.workLocationCountry)) {
            AgentLog.error('enforceGovernorSafety', 'No filters provided', new Map<String, Object>{
                'ouName' => req.ouName,
                'workLocationCountry' => req.workLocationCountry
            });
            return 'Either OU Name or Work Location Country is required for Upsell Analysis queries. Please provide at least one of these filters.';
        }

        return null; // No error
    }

    /**
     * Builds the complete analysis message
     */
    private static String buildAnalysisMessage(List<UpsellRowDTO> results, UpsellQueryRequest req) {
        String message = '';

        // Header
        message += '# Upsell Analysis\n\n';

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
        message += '- **Time Range**: All available data (no date filtering applied)\n'; // Upsell object doesn't have relevant date fields
        if (req.limitN != null && req.limitN > 0) {
            message += '- **Limit Applied**: ' + req.limitN + '\n';
        }
        message += '\n';

        // Results
        message += '## Results\n';
        message += '- **Records Found**: ' + results.size() + ' groups\n\n';

        if (results.isEmpty()) {
            message += 'No upsell data found matching the specified criteria.\n';
            message += '\n**Troubleshooting Tips:**\n';
            message += '- Verify the OU name exists in the system\n';
            message += '- Check if the country filter is correct\n';
            message += '- Consider using a broader search criteria\n';
        } else {
            message += '**' + req.groupBy + ' Analysis**:\n';
            for (UpsellRowDTO dto : results) {
                if (String.isNotBlank(dto.key)) {
                    message += '- **' + dto.key + '**: ' + dto.count + ' upsell opportunities';
                    if (dto.uniqueAccounts != null) {
                        message += ', ' + dto.uniqueAccounts + ' unique accounts';
                    }
                    if (dto.uniqueProducts != null) {
                        message += ', ' + dto.uniqueProducts + ' unique products';
                    }
                    message += '\n';
                }
            }
        }

        return message;
    }

    /**
     * Builds error message
     */
    private static String buildErrorMessage(String errorMessage) {
        return '# Upsell Analysis\n\n## Error\n' + errorMessage;
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
            'upsell_sub_category__C' => 'upsell_sub_category',
            'upsell_sub_category__c' => 'upsell_sub_category',
            'upsell_acct_nm__C' => 'upsell_acct_nm',
            'upsell_acct_nm__c' => 'upsell_acct_nm',
            'upsell_acct_id__C' => 'upsell_acct_id',
            'upsell_acct_id__c' => 'upsell_acct_id',
            'upsell_rn__C' => 'upsell_rn',
            'upsell_rn__c' => 'upsell_rn',
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
     * @description Custom string join method for compatibility with older API versions
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
        if (lowerQuery.contains('product') || lowerQuery.contains('upsell')) {
            suggestions += '**Product Fields**:\n';
            suggestions += '- Use: `product` or `upsell_sub_category`\n';
            suggestions += '- Example values: "Tableau Cloud Analytics", "Slack", "AppExchange"\n';
            suggestions += '- Common aliases: product, product_name, upsell_product, sub_category\n\n';
        }

        // Account-related suggestions
        if (lowerQuery.contains('account') || lowerQuery.contains('customer')) {
            suggestions += '**Account Fields**:\n';
            suggestions += '- Use: `account` or `upsell_acct_nm`\n';
            suggestions += '- Example values: "TyT Logistica y Servicios", "Datatruck"\n';
            suggestions += '- Common aliases: account, account_name, customer\n\n';
        }

        // Location-related suggestions
        if (lowerQuery.contains('country') || lowerQuery.contains('location')) {
            suggestions += '**Location Fields**:\n';
            suggestions += '- Use: `country` or `work_location_country`\n';
            suggestions += '- Example values: "Mexico", "Canada", "France"\n';
            suggestions += '- Common aliases: country, location, work_country\n\n';
        }

        // Industry-related suggestions
        if (lowerQuery.contains('industry') || lowerQuery.contains('sector')) {
            suggestions += '**Industry Fields**:\n';
            suggestions += '- Use: `industry` or `primary_industry`\n';
            suggestions += '- Example values: "Retail & CG", "Healthcare & Life Sciences"\n';
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
            validation += '   - Wrong: `product=Tableau Cloud Analytics`\n';
            validation += '   - Correct: `product=\'Tableau Cloud Analytics\'`\n\n';
        }

        validation += '**Field Mapping**:\n';
        for (String key : FILTER_FIELD_MAP.keySet()) {
            String fieldName = FILTER_FIELD_MAP.get(key);
            validation += '- ' + key + ' → ' + fieldName + '\n';
        }

        return validation;
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