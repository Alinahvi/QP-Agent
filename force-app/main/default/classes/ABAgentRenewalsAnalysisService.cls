/**
 * OPTIMIZED RENEWALS ANALYSIS SERVICE
 * 
 * This service uses aggregate queries to prevent heap size issues with large datasets.
 * It never loads raw Agent_Renewals__c records into memory, only returns lightweight DTOs.
 * 
 * Key Features:
 * - Aggregate-only queries (no raw record loading)
 * - Governor-safe limits and validation
 * - Minimal memory footprint
 * - Selective SOQL with proper filtering
 * 
 * @version 2.0 - Memory Optimized
 */
public with sharing class ABAgentRenewalsAnalysisService {

    // Lightweight field mapping - only essential fields
    private static final Map<String, String> GROUP_FIELD_MAP = new Map<String, String>{
        'AE' => 'full_name__c',
        'OU' => 'ou_name__c', 
        'COUNTRY' => 'work_location_country__c',
        'PRODUCT' => 'renewal_prod_nm__c',
        'INDUSTRY' => 'primary_industry__c',
        'MANAGER' => 'emp_mgr_nm__c',
        'ACCOUNT' => 'renewal_acct_nm__c'
    };

    // Minimal filter field mapping - only commonly used fields
    private static final Map<String, String> FILTER_FIELD_MAP = new Map<String, String>{
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

    // Lightweight DTO for results
    public class RenewalRowDTO {
        public String key;
        public Integer count;
        public Decimal amount;
        public Decimal avgAmount;
        public Decimal maxAmount;
        public Decimal minAmount;
    }

    // Request DTO for internal processing
    public class RenewalQueryRequest {
        public String ouName;
        public String workLocationCountry;
        public String groupBy;
        public String filterCriteria;
        public Integer limitN;
        public Date startDate;
        public Date endDate;
    }

    /**
     * Main entry point - validates request and returns aggregate results
     */
    public static String analyzeRenewals(String ouName, String workLocationCountry, String groupBy,
                                      String filterCriteria, String restrictInValuesCsv,
                                      Boolean perAENormalize, Integer limitN, String aggregationType, String analysisType) {

        try {
            // Enforce governor safety
            RenewalQueryRequest req = enforceGovernorSafety(ouName, workLocationCountry, groupBy, filterCriteria, limitN);
            if (req == null) {
                return buildErrorMessage('Invalid request parameters. Please check your inputs and try again.');
            }

            // Query top renewals using aggregate
            List<RenewalRowDTO> results = queryTopRenewals(req);
            
            // Build response message
            return buildAnalysisMessage(results, req, aggregationType, analysisType);

        } catch (Exception e) {
            AgentLog.error('analyzeRenewals', 'Error in renewals analysis', new Map<String, Object>{
                'error' => e.getMessage(),
                'stackTrace' => e.getStackTraceString()
            });
            return buildErrorMessage('Renewals analysis failed: ' + e.getMessage());
        }
    }

    /**
     * Core method - queries top renewals using aggregate SOQL
     * Never loads raw records into memory
     */
    public static List<RenewalRowDTO> queryTopRenewals(RenewalQueryRequest req) {
        String groupField = GROUP_FIELD_MAP.get(req.groupBy);
        
        // Build aggregate query
        String query = 'SELECT ' + groupField + ', COUNT(Id) recordCount, SUM(renewal_opty_amt__c) totalAmount, ';
        query += 'AVG(renewal_opty_amt__c) avgAmount, MAX(renewal_opty_amt__c) maxAmount, MIN(renewal_opty_amt__c) minAmount ';
        query += 'FROM Agent_Renewals__c';

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
        
        // Note: Agent_Renewals__c doesn't have a CloseDate field, so we skip date filtering
        // The object only has standard Salesforce date fields (createddate, lastmodifieddate, etc.)
        // which are not relevant for renewal opportunity analysis
        
        // Add custom filter criteria if provided
        if (String.isNotBlank(req.filterCriteria)) {
            String parsedFilter = parseFilterCriteria(req.filterCriteria);
            if (String.isNotBlank(parsedFilter)) {
                whereClauses.add('(' + parsedFilter + ')');
            }
        }

        // Add null check for grouping field
            whereClauses.add(groupField + ' != null');

        if (!whereClauses.isEmpty()) {
            query += ' WHERE ' + String.join(whereClauses, ' AND ');
        }
        
        // Add GROUP BY and ORDER BY
        query += ' GROUP BY ' + groupField;
        query += ' ORDER BY COUNT(Id) DESC';
        query += ' LIMIT ' + req.limitN;

        AgentLog.info('queryTopRenewals', 'Executing aggregate query', new Map<String, Object>{
            'query' => query,
            'groupBy' => req.groupBy,
            'limitN' => req.limitN
        });

        // Execute query and convert to DTOs
        List<AggregateResult> results = Database.query(query);
        List<RenewalRowDTO> dtos = new List<RenewalRowDTO>();
        
        for (AggregateResult result : results) {
            RenewalRowDTO dto = new RenewalRowDTO();
            dto.key = (String)result.get(groupField);
            dto.count = (Integer)result.get('recordCount');
            dto.amount = (Decimal)result.get('totalAmount');
            dto.avgAmount = (Decimal)result.get('avgAmount');
            dto.maxAmount = (Decimal)result.get('maxAmount');
            dto.minAmount = (Decimal)result.get('minAmount');
            dtos.add(dto);
        }

        AgentLog.info('queryTopRenewals', 'Query completed', new Map<String, Object>{
            'resultCount' => dtos.size(),
            'groupBy' => req.groupBy
        });

        return dtos;
    }

    /**
     * Enforces governor safety and validates request parameters
     */
    private static RenewalQueryRequest enforceGovernorSafety(String ouName, String workLocationCountry, 
                                                           String groupBy, String filterCriteria, Integer limitN) {
        
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
        
        // Set default time bounds to current and next quarter
        Date today = Date.today();
        Date startDate = today.toStartOfMonth().addMonths(-3); // 3 months ago
        Date endDate = today.toStartOfMonth().addMonths(6); // 6 months from now
        
        RenewalQueryRequest req = new RenewalQueryRequest();
        req.ouName = ouName;
        req.workLocationCountry = workLocationCountry;
        req.groupBy = groupBy;
        req.filterCriteria = filterCriteria;
        req.limitN = limitN;
        req.startDate = startDate;
        req.endDate = endDate;
        
        return req;
    }

    /**
     * Builds the analysis message from DTOs
     */
    private static String buildAnalysisMessage(List<RenewalRowDTO> results, RenewalQueryRequest req, 
                                             String aggregationType, String analysisType) {
        String message = '';

        // Header
        message += '# Renewals Analysis\n\n';

        // Summary
        message += '## Summary\n';
        if (String.isNotBlank(req.ouName)) {
            message += '- **OU**: ' + req.ouName + '\n';
        }
        if (String.isNotBlank(req.workLocationCountry)) {
            message += '- **Work Location Country**: ' + req.workLocationCountry + '\n';
        }
        message += '- **Grouped By**: ' + req.groupBy + '\n';
        message += '- **Analysis Type**: ' + analysisType + '\n';
        message += '- **Filter**: ' + (String.isNotBlank(req.filterCriteria) ? req.filterCriteria : 'None') + '\n';
        message += '- **Time Range**: All available data (no date filtering applied)\n';
        message += '- **Limit Applied**: ' + req.limitN + '\n';
        message += '\n';

        // Results
        message += '## Results\n';
        message += '- **Records Found**: ' + results.size() + ' groups\n\n';
        
        if (results.isEmpty()) {
            message += 'No renewal data found matching the specified criteria.\n';
            message += '\n**Troubleshooting Tips:**\n';
            message += '- Verify the OU name exists in the system\n';
            message += '- Check if the country filter is correct\n';
            message += '- Try a different time period or remove date filters\n';
            message += '- Consider using a broader search criteria\n';
        } else {
            message += '**' + req.groupBy + ' Analysis**:\n';
            for (RenewalRowDTO dto : results) {
                if (String.isNotBlank(dto.key)) {
                    message += '- **' + dto.key + '**: ' + dto.count + ' renewal opportunities';

            switch on aggregationType {
                when 'SUM' {
                            message += ', $' + (dto.amount != null ? String.valueOf(dto.amount.setScale(2)) : '0.00') + ' total amount';
                }
                when 'AVG' {
                            message += ', $' + (dto.avgAmount != null ? String.valueOf(dto.avgAmount.setScale(2)) : '0.00') + ' average amount';
                }
                when 'MAX' {
                            message += ', $' + (dto.maxAmount != null ? String.valueOf(dto.maxAmount.setScale(2)) : '0.00') + ' max amount';
                }
                when 'MIN' {
                            message += ', $' + (dto.minAmount != null ? String.valueOf(dto.minAmount.setScale(2)) : '0.00') + ' min amount';
                }
                when 'COUNT' {
                            message += ', ' + dto.count + ' opportunities';
                }
                when else {
                            message += ', $' + (dto.amount != null ? String.valueOf(dto.amount.setScale(2)) : '0.00') + ' total amount';
                        }
                    }
                    message += '\n';
                }
            }
        }
        
        // JSON Data
        message += '\n## Data (JSON)\n';
        message += '```json\n';
        message += buildJSONFromDTOs(results);
        message += '\n```\n';
        
        return message;
    }

    /**
     * Builds JSON from DTOs
     */
    private static String buildJSONFromDTOs(List<RenewalRowDTO> results) {
        String jsonResult = '{\n';
        jsonResult += '  "groups": [\n';
        
        for (Integer i = 0; i < results.size(); i++) {
            RenewalRowDTO dto = results[i];
            if (i > 0) jsonResult += ',\n';
            jsonResult += '    {\n';
            jsonResult += '      "key": "' + String.escapeSingleQuotes(dto.key) + '",\n';
            jsonResult += '      "count": ' + dto.count + ',\n';
            jsonResult += '      "amount": ' + (dto.amount != null ? dto.amount.setScale(2) : 0) + ',\n';
            jsonResult += '      "avgAmount": ' + (dto.avgAmount != null ? dto.avgAmount.setScale(2) : 0) + ',\n';
            jsonResult += '      "maxAmount": ' + (dto.maxAmount != null ? dto.maxAmount.setScale(2) : 0) + ',\n';
            jsonResult += '      "minAmount": ' + (dto.minAmount != null ? dto.minAmount.setScale(2) : 0) + '\n';
            jsonResult += '    }';
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

        // Convert field names to API names
        for (String key : FILTER_FIELD_MAP.keySet()) {
            String fieldName = FILTER_FIELD_MAP.get(key);
            parsedFilter = replaceWordCI(parsedFilter, key, fieldName);
        }

        return parsedFilter;
    }

    /**
     * Case-insensitive word boundary replacement
     */
    private static String replaceWordCI(String src, String token, String repl) {
        if (String.isBlank(src) || String.isBlank(token)) return src;
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
     * Field suggestions for better agent accuracy
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
     * Validates filter criteria
     */
    public static String validateFilterCriteria(String filterCriteria) {
        if (String.isBlank(filterCriteria)) {
            return 'Filter criteria is empty. Please provide a filter.';
        }

        String validation = '## Filter Validation Results\n\n';
        validation += '**Input**: ' + filterCriteria + '\n\n';

        if (filterCriteria.contains('=') && !filterCriteria.contains('\'')) {
            validation += '⚠️ **WARNING**: Values should be quoted\n';
            validation += '   - Wrong: `product=Sales Cloud`\n';
            validation += '   - Correct: `product=\'Sales Cloud\'`\n\n';
        }

        validation += '**Field Mapping**:\n';
        for (String key : FILTER_FIELD_MAP.keySet()) {
            String fieldName = FILTER_FIELD_MAP.get(key);
            validation += '- ' + key + ' → ' + fieldName + '\n';
        }

        return validation;
    }
}