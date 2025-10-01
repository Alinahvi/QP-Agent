/**
 * TEMPLATE SERVICE - Houses business logic and direct object manipulation in our handler/service pattern.
 * Business Requirement: Service methods return a single composed message string for agent consumption.
 * Handlers call into this class to perform Renewals Analysis operations.
 * @description Service class for Renewals Analysis operations on Agent_Renewals__c records.
 * Handles all business logic for analyzing renewal data across AEs with grouping, filtering, and aggregation.
 *
 * MEMORY OPTIMIZED VERSION - Uses aggregate queries to prevent heap size issues
 *
 * Key fields referenced (ONLY these allowed):
 *   - emp_id__c: Employee identifier for the AE
 *   - full_name__c: AE full name
 *   - emp_email_addr__c: AE email address
 *   - work_location_country__c: Work location country of the AE
 *   - ou_name__c: Organizational Unit (core partition filter)
 *   - emp_mgr_nm__c: Manager name of the AE
 *   - primary_industry__c: Primary industry classification
 *   - renewal_prod_nm__c: Product name for renewal
 *   - renewal_acct_nm__c: Account name associated with the renewal
 *   - renewal_acct_id__c: Account ID associated with the renewal
 *   - renewal_opty_amt__c: Renewal opportunity amount (monetary value)
 *   - renewal_opty_nm__c: Renewal opportunity name
 *   - renewal_rn__c: Renewal round/rank/sequence number
 *   - learner_profile_id__c: Linked learner profile ID (enablement)
 *   - macrosgment__c: Macro segment classification (CMRCL, ESMB, etc.)
 *   - ramp_status__c: AE ramp status
 *   - time_since_onboarding__c: Time since onboarding in months (decimal)
 *
 * @version 2.0 - Memory Optimized
 */
public with sharing class ABAgentRenewalsAnalysisService {

    // Field mapping constants for grouping
    private static final Map<String, String> GROUP_FIELD_MAP = new Map<String, String>{
        'PRODUCT' => 'renewal_prod_nm__c',
        'INDUSTRY' => 'primary_industry__c',
        'MACRO_SEGMENT' => 'macrosgment__c',
        'AE' => 'full_name__c',
        'COUNTRY' => 'work_location_country__c',
        'MANAGER' => 'emp_mgr_nm__c',
        'ACCOUNT' => 'renewal_acct_nm__c'
    };

    // MEMORY OPTIMIZATION: Minimal field mapping to prevent heap size issues
    // Only include essential field mappings to reduce memory footprint
    public static final Map<String, String> FILTER_FIELD_MAP = new Map<String, String>{
        'ou_name' => 'ou_name__c',
        'work_location_country' => 'work_location_country__c',
        'country' => 'work_location_country__c',
        'full_name' => 'full_name__c',
        'name' => 'full_name__c',
        'emp_mgr_nm' => 'emp_mgr_nm__c',
        'manager' => 'emp_mgr_nm__c',
        'renewal_prod_nm' => 'renewal_prod_nm__c',
        'product' => 'renewal_prod_nm__c',
        'renewal_acct_nm' => 'renewal_acct_nm__c',
        'account' => 'renewal_acct_nm__c',
        'renewal_opty_amt' => 'renewal_opty_amt__c',
        'amount' => 'renewal_opty_amt__c',
        'primary_industry' => 'primary_industry__c',
        'industry' => 'primary_industry__c',
        'macrosgment' => 'macrosgment__c',
        'segment' => 'macrosgment__c'
    };

    /**
     * Main method to analyze Renewals data based on specified parameters
     * Returns a single composed message string for the agent
     * MEMORY OPTIMIZED VERSION - Uses aggregate queries instead of loading all records
     */
    public static String analyzeRenewals(String ouName, String workLocationCountry, String groupBy,
                                      String filterCriteria, String restrictInValuesCsv,
                                      Boolean perAENormalize, Integer limitN, String aggregationType, String analysisType) {

        try {
            // Validate groupBy parameter
            if (String.isBlank(groupBy) || !GROUP_FIELD_MAP.containsKey(groupBy)) {
                return buildErrorMessage('Invalid groupBy parameter: ' + groupBy + '. Valid values are: ' + String.join(new List<String>(GROUP_FIELD_MAP.keySet()), ', '));
            }

            // MEMORY OPTIMIZATION: Use aggregate queries instead of loading all records
            // This prevents heap size issues with large datasets
            return buildAnalysisFromAggregateQuery(ouName, workLocationCountry, groupBy, filterCriteria,
                                                 restrictInValuesCsv, perAENormalize, limitN, aggregationType, analysisType);

        } catch (Exception e) {
            return buildErrorMessage('Renewals analysis failed: ' + e.getMessage());
        }
    }

    /**
     * Builds analysis using aggregate queries to prevent memory issues
     */
    private static String buildAnalysisFromAggregateQuery(String ouName, String workLocationCountry, String groupBy,
                                                        String filterCriteria, String restrictInValuesCsv,
                                                        Boolean perAENormalize, Integer limitN, String aggregationType, String analysisType) {
        
        String groupField = GROUP_FIELD_MAP.get(groupBy);
        String message = '';

        // Header
        message += '# Renewals Analysis\n\n';

        // Summary
        message += '## Summary\n';
        if (String.isNotBlank(ouName)) {
            message += '- **OU**: ' + ouName + '\n';
        }
        if (String.isNotBlank(workLocationCountry)) {
            message += '- **Work Location Country**: ' + workLocationCountry + '\n';
        }
        message += '- **Grouped By**: ' + groupBy + '\n';
        message += '- **Analysis Type**: ' + analysisType + '\n';
        message += '- **Filter**: ' + (String.isNotBlank(filterCriteria) ? filterCriteria : 'None') + '\n';
        message += '- **Per-AE Normalized**: ' + (perAENormalize ? 'Yes' : 'No') + '\n';
        if (limitN != null && limitN > 0) {
            message += '- **Limit Applied**: ' + limitN + '\n';
        }
        message += '\n';

        try {
            // Build aggregate query
            String aggregateQuery = buildAggregateQuery(ouName, workLocationCountry, groupBy, filterCriteria, limitN);
            System.debug('Aggregate Query: ' + aggregateQuery);
            
            List<AggregateResult> results = Database.query(aggregateQuery);
            
            message += '## Insights\n';
            message += '- **Records Found**: ' + results.size() + ' groups\n';
            message += '\n';

            // Process results based on analysis type
            if (analysisType == 'AE_ANALYSIS') {
                message += buildAEAnalysisFromAggregate(results, limitN, aggregationType);
            } else {
                message += buildGenericAnalysisFromAggregate(results, groupBy, limitN, aggregationType);
            }

            // Data (JSON)
            message += '## Data (JSON)\n';
            message += '```json\n';
            message += buildJSONFromAggregate(results, groupBy, limitN);
            message += '\n```\n';

        } catch (Exception e) {
            message += '## Error\n';
            message += 'Failed to execute aggregate query: ' + e.getMessage() + '\n';
            System.debug('Aggregate query error: ' + e.getStackTraceString());
        }

        return message;
    }

    /**
     * Builds aggregate query for memory-efficient analysis
     */
    private static String buildAggregateQuery(String ouName, String workLocationCountry, String groupBy,
                                            String filterCriteria, Integer limitN) {
        
        String groupField = GROUP_FIELD_MAP.get(groupBy);
        
        // Build aggregate query
        String query = 'SELECT ' + groupField + ', COUNT(Id) recordCount, SUM(renewal_opty_amt__c) totalAmount, ';
        query += 'AVG(renewal_opty_amt__c) avgAmount, MAX(renewal_opty_amt__c) maxAmount, MIN(renewal_opty_amt__c) minAmount ';
        query += 'FROM Agent_Renewals__c';

        // Build WHERE clause
        List<String> whereClauses = new List<String>();

        // Add OU filter (optional - only if provided)
        if (String.isNotBlank(ouName)) {
            whereClauses.add('ou_name__c = \'' + String.escapeSingleQuotes(ouName) + '\'');
        }

        // Add work location country filter if provided
        if (String.isNotBlank(workLocationCountry)) {
            whereClauses.add('work_location_country__c = \'' + String.escapeSingleQuotes(workLocationCountry) + '\'');
        }

        // Add filter criteria if provided
        if (String.isNotBlank(filterCriteria)) {
            String parsedFilter = parseFilterCriteria(filterCriteria);
            if (String.isNotBlank(parsedFilter)) {
                whereClauses.add('(' + parsedFilter + ')');
            }
        }

        // Add null checks for grouping field
        if (String.isNotBlank(groupField)) {
            whereClauses.add(groupField + ' != null');
        }

        if (!whereClauses.isEmpty()) {
            query += ' WHERE ' + String.join(whereClauses, ' AND ');
        }

        // Add GROUP BY
        query += ' GROUP BY ' + groupField;

        // Add ORDER BY based on aggregation type
        query += ' ORDER BY SUM(renewal_opty_amt__c) DESC';

        // Add LIMIT
        Integer effectiveLimit = limitN != null ? limitN : 10;
        query += ' LIMIT ' + effectiveLimit;

        return query;
    }

    /**
     * Builds AE analysis from aggregate results
     */
    private static String buildAEAnalysisFromAggregate(List<AggregateResult> results, Integer limitN, String aggregationType) {
        String insights = '\n**AE Analysis**:\n';

        for (AggregateResult result : results) {
            String aeName = (String)result.get('full_name__c');
            Integer count = (Integer)result.get('recordCount');
            Decimal totalAmount = (Decimal)result.get('totalAmount');
            Decimal avgAmount = (Decimal)result.get('avgAmount');
            Decimal maxAmount = (Decimal)result.get('maxAmount');
            Decimal minAmount = (Decimal)result.get('minAmount');

            if (String.isNotBlank(aeName)) {
                insights += '- **' + aeName + '**: ' + count + ' renewal opportunities';
                
                switch on aggregationType {
                    when 'SUM' {
                        insights += ', $' + (totalAmount != null ? String.valueOf(totalAmount.setScale(2)) : '0.00') + ' total amount';
                    }
                    when 'AVG' {
                        insights += ', $' + (avgAmount != null ? String.valueOf(avgAmount.setScale(2)) : '0.00') + ' average amount';
                    }
                    when 'MAX' {
                        insights += ', $' + (maxAmount != null ? String.valueOf(maxAmount.setScale(2)) : '0.00') + ' max amount';
                    }
                    when 'MIN' {
                        insights += ', $' + (minAmount != null ? String.valueOf(minAmount.setScale(2)) : '0.00') + ' min amount';
                    }
                    when 'COUNT' {
                        insights += ', ' + count + ' opportunities';
                    }
                    when else {
                        insights += ', $' + (totalAmount != null ? String.valueOf(totalAmount.setScale(2)) : '0.00') + ' total amount';
                    }
                }
                insights += '\n';
            }
        }

        return insights;
    }

    /**
     * Builds generic analysis from aggregate results
     */
    private static String buildGenericAnalysisFromAggregate(List<AggregateResult> results, String groupBy, Integer limitN, String aggregationType) {
        String insights = '\n**' + groupBy + ' Analysis**:\n';

        for (AggregateResult result : results) {
            String groupValue = (String)result.get(GROUP_FIELD_MAP.get(groupBy));
            Integer count = (Integer)result.get('recordCount');
            Decimal totalAmount = (Decimal)result.get('totalAmount');
            Decimal avgAmount = (Decimal)result.get('avgAmount');
            Decimal maxAmount = (Decimal)result.get('maxAmount');
            Decimal minAmount = (Decimal)result.get('minAmount');

            if (String.isNotBlank(groupValue)) {
                insights += '- **' + groupValue + '**: ' + count + ' renewal opportunities';
                
                switch on aggregationType {
                    when 'SUM' {
                        insights += ', $' + (totalAmount != null ? String.valueOf(totalAmount.setScale(2)) : '0.00') + ' total amount';
                    }
                    when 'AVG' {
                        insights += ', $' + (avgAmount != null ? String.valueOf(avgAmount.setScale(2)) : '0.00') + ' average amount';
                    }
                    when 'MAX' {
                        insights += ', $' + (maxAmount != null ? String.valueOf(maxAmount.setScale(2)) : '0.00') + ' max amount';
                    }
                    when 'MIN' {
                        insights += ', $' + (minAmount != null ? String.valueOf(minAmount.setScale(2)) : '0.00') + ' min amount';
                    }
                    when 'COUNT' {
                        insights += ', ' + count + ' opportunities';
                    }
                    when else {
                        insights += ', $' + (totalAmount != null ? String.valueOf(totalAmount.setScale(2)) : '0.00') + ' total amount';
                    }
                }
                insights += '\n';
            }
        }

        return insights;
    }

    /**
     * Builds JSON from aggregate results
     */
    private static String buildJSONFromAggregate(List<AggregateResult> results, String groupBy, Integer limitN) {
        String jsonResult = '{\n';
        jsonResult += '  "groups": [\n';
        
        String groupField = GROUP_FIELD_MAP.get(groupBy);
        
        for (Integer i = 0; i < results.size(); i++) {
            AggregateResult result = results[i];
            String groupValue = (String)result.get(groupField);
            Integer count = (Integer)result.get('recordCount');
            Decimal totalAmount = (Decimal)result.get('totalAmount');
            Decimal avgAmount = (Decimal)result.get('avgAmount');
            Decimal maxAmount = (Decimal)result.get('maxAmount');
            Decimal minAmount = (Decimal)result.get('minAmount');

            if (String.isNotBlank(groupValue)) {
                if (i > 0) jsonResult += ',\n';
                jsonResult += '    {\n';
                jsonResult += '      "name": "' + String.escapeSingleQuotes(groupValue) + '",\n';
                jsonResult += '      "count": ' + count + ',\n';
                jsonResult += '      "totalAmount": ' + (totalAmount != null ? totalAmount.setScale(2) : 0) + ',\n';
                jsonResult += '      "avgAmount": ' + (avgAmount != null ? avgAmount.setScale(2) : 0) + ',\n';
                jsonResult += '      "maxAmount": ' + (maxAmount != null ? maxAmount.setScale(2) : 0) + ',\n';
                jsonResult += '      "minAmount": ' + (minAmount != null ? minAmount.setScale(2) : 0) + '\n';
                jsonResult += '    }';
            }
        }
        
        jsonResult += '\n  ]\n';
        jsonResult += '}';
        
        return jsonResult;
    }

    /**
     * Parses filter criteria from user-friendly format to SOQL
     */
    public static String parseFilterCriteria(String filterCriteria) {
        if (String.isBlank(filterCriteria)) return '';

        String parsedFilter = filterCriteria;

        // Convert base field names to API field names
        for (String key : FILTER_FIELD_MAP.keySet()) {
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
     * Builds error message
     */
    private static String buildErrorMessage(String errorMessage) {
        return '# Renewals Analysis\n\n## Error\n' + errorMessage;
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
            validation += '   - Wrong: `product=Sales Cloud - Enterprise Edition`\n';
            validation += '   - Correct: `product=\'Sales Cloud - Enterprise Edition\'`\n\n';
        }

        validation += '**Field Mapping**:\n';
        for (String key : FILTER_FIELD_MAP.keySet()) {
            String fieldName = FILTER_FIELD_MAP.get(key);
            validation += '- ' + key + ' → ' + fieldName + '\n';
        }

        return validation;
    }
}