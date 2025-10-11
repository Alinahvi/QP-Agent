/**
 * @description SERVICE LAYER - All Business Logic for Open Pipe Analysis V3 Enhanced
 * 
 * BEST PRACTICES COMPLIANCE:
 * - All business logic centralized here
 * - Returns plain String (composed DTO)
 * - FLS with Security.stripInaccessible
 * - Deterministic limits with total counts
 * - Clean JSON-focused output
 * - No emojis (agent adds them)
 * - Field context for agent understanding
 * 
 * @author Salesforce
 * @date 2025-10-10
 */
public with sharing class ANAgentOpenPipeAnalysisServiceV3Enhanced {
    
    // High-level regions that need clarification
    private static final Set<String> HIGH_LEVEL_REGIONS = new Set<String>{
        'AMER', 'EMEA', 'ANZ', 'APAC', 'LATAM'
    };
    
    // Region to OU mapping
    private static final Map<String, List<String>> REGION_OU_MAP = new Map<String, List<String>>{
        'AMER' => new List<String>{
            'AMER ACC', 'AMER ICE', 'SMB - AMER SMB', 'NextGen Platform', 'AMER Public Sector', 'AMER Commercial'
        },
        'EMEA' => new List<String>{
            'EMEA ACC', 'EMEA ICE', 'SMB - EMEA SMB', 'UKI', 'DACH', 'France', 'Southern Europe', 
            'Northern Europe', 'Middle East', 'Africa'
        },
        'APAC' => new List<String>{
            'APAC ACC', 'APAC ICE', 'SMB - APAC SMB', 'Japan', 'Australia', 'India', 'ASEAN', 'Greater China'
        },
        'ANZ' => new List<String>{
            'ANZ ACC', 'ANZ SMB', 'Australia', 'New Zealand'
        },
        'LATAM' => new List<String>{
            'LATAM ACC', 'SMB - LATAM SMB', 'Brazil', 'Mexico', 'LATAM Spanish'
        }
    };
    
    /**
     * @description Main query execution - all business logic here
     * @param queryParams Map of query parameters
     * @return String Formatted message with JSON data
     */
    public static String executeQuery(Map<String, Object> queryParams) {
        try {
            // Extract and validate parameters
            String ou = getStringParam(queryParams, 'ou');
            String country = getStringParam(queryParams, 'country');
            String stage = getStringParam(queryParams, 'stage');
            String product = getStringParam(queryParams, 'product');
            String filterCriteria = getStringParam(queryParams, 'filterCriteria');
            String groupBy = getStringParam(queryParams, 'groupBy', 'STAGE');
            String analysisType = getStringParam(queryParams, 'analysisType', 'STAGE_COUNT');
            Integer limitN = getIntParam(queryParams, 'limitN');
            
            // Validate required fields
            if (String.isBlank(ou) && String.isBlank(country)) {
                return buildClarificationMessage('MISSING_OU_OR_COUNTRY', null);
            }
            
            // Check for high-level region names
            if (String.isNotBlank(ou) && HIGH_LEVEL_REGIONS.contains(ou.toUpperCase().trim())) {
                return buildRegionClarificationMessage(ou.toUpperCase().trim());
            }
            
            // Normalize stage name if provided
            if (String.isNotBlank(stage)) {
                stage = ANAgentNamingNormalizer.normalizeStage(stage);
            }
            
            // Build dynamic SOQL query
            String soql = buildSOQLQuery(ou, country, stage, product, filterCriteria);
            
            // Get total count first (before limit)
            Integer totalCount = getTotalCount(soql);
            
            // Apply limit if specified
            if (limitN != null && limitN > 0) {
                soql += ' LIMIT ' + limitN;
            }
            
            // Execute query
            List<Agent_Open_Pipe__c> rawResults = Database.query(soql);
            
            // Apply FLS
            List<Agent_Open_Pipe__c> results = Security.stripInaccessible(
                AccessType.READABLE,
                rawResults
            ).getRecords();
            
            // Build response
            return buildResponse(results, queryParams, totalCount, limitN);
            
        } catch (Exception e) {
            return buildErrorResponse(e);
        }
    }
    
    /**
     * @description Build SOQL query dynamically
     */
    private static String buildSOQLQuery(String ou, String country, String stage, String product, String filterCriteria) {
        String soql = 'SELECT Id, FULL_NAME__C, OPEN_PIPE_OPTY_NM__C, OPEN_PIPE_OPTY_STG_NM__C, ' +
                      'OPEN_PIPE_APM_L2__C, OPEN_PIPE_PROD_NM__C, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C, ' +
                      'OPEN_PIPE_OPTY_DAYS_IN_STAGE__C, OPEN_PIPE_AE_SCORE__C, PRIMARY_INDUSTRY__C, ' +
                      'MACROSGMENT__C, WORK_LOCATION_COUNTRY__C, OU_NAME__C ' +
                      'FROM Agent_Open_Pipe__c WHERE Id != null';
        
        // Add OU filter
        if (String.isNotBlank(ou)) {
            soql += ' AND OU_NAME__C = \'' + String.escapeSingleQuotes(ou) + '\'';
        }
        
        // Add country filter
        if (String.isNotBlank(country)) {
            soql += ' AND WORK_LOCATION_COUNTRY__C = \'' + String.escapeSingleQuotes(country) + '\'';
        }
        
        // Add stage filter
        if (String.isNotBlank(stage)) {
            soql += ' AND OPEN_PIPE_OPTY_STG_NM__C = \'' + String.escapeSingleQuotes(stage) + '\'';
        }
        
        // Add product filter
        if (String.isNotBlank(product)) {
            soql += ' AND OPEN_PIPE_APM_L2__C LIKE \'%' + String.escapeSingleQuotes(product) + '%\'';
        }
        
        // Add custom filter criteria
        if (String.isNotBlank(filterCriteria)) {
            soql += ' AND (' + filterCriteria + ')';
        }
        
        soql += ' ORDER BY OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C DESC NULLS LAST';
        
        return soql;
    }
    
    /**
     * @description Get total count before applying limit
     */
    private static Integer getTotalCount(String soql) {
        String countSoql = 'SELECT COUNT() FROM Agent_Open_Pipe__c WHERE Id != null';
        
        // Extract WHERE clause from original SOQL
        Integer whereIndex = soql.indexOf(' WHERE ');
        if (whereIndex > 0) {
            Integer orderByIndex = soql.indexOf(' ORDER BY ');
            Integer limitIndex = soql.indexOf(' LIMIT ');
            Integer endIndex = orderByIndex > 0 ? orderByIndex : (limitIndex > 0 ? limitIndex : soql.length());
            String whereClause = soql.substring(whereIndex, endIndex);
            countSoql = 'SELECT COUNT() FROM Agent_Open_Pipe__c' + whereClause;
        }
        
        return Database.countQuery(countSoql);
    }
    
    /**
     * @description Build clean JSON-focused response
     */
    private static String buildResponse(
        List<Agent_Open_Pipe__c> results,
        Map<String, Object> queryParams,
        Integer totalCount,
        Integer requestedLimit
    ) {
        if (results.isEmpty()) {
            return buildNoDataMessage(queryParams, totalCount);
        }
        
        Map<String, Object> response = new Map<String, Object>();
        
        // Query context
        Map<String, Object> context = new Map<String, Object>();
        if (queryParams.containsKey('ou')) context.put('ou', queryParams.get('ou'));
        if (queryParams.containsKey('country')) context.put('country', queryParams.get('country'));
        if (queryParams.containsKey('stage')) context.put('stage', queryParams.get('stage'));
        if (queryParams.containsKey('product')) context.put('product', queryParams.get('product'));
        if (queryParams.containsKey('analysisType')) context.put('analysisType', queryParams.get('analysisType'));
        if (queryParams.containsKey('groupBy')) context.put('groupBy', queryParams.get('groupBy'));
        response.put('context', context);
        
        // Summary metrics
        response.put('summary', buildSummary(results));
        
        // Results data
        response.put('results', buildResults(results, requestedLimit));
        
        // Limits and counts
        Map<String, Object> limits = new Map<String, Object>();
        limits.put('totalFound', totalCount);
        limits.put('showing', results.size());
        if (requestedLimit != null && requestedLimit > 0) {
            limits.put('requestedLimit', requestedLimit);
            limits.put('limitApplied', true);
        } else {
            limits.put('limitApplied', false);
        }
        response.put('limits', limits);
        
        // Field context for agent understanding
        response.put('fieldContext', getFieldContext());
        
        return 'OPEN PIPE ANALYSIS\n\n```json\n' + JSON.serializePretty(response) + '\n```';
    }
    
    /**
     * @description Build summary metrics
     */
    private static Map<String, Object> buildSummary(List<Agent_Open_Pipe__c> results) {
        Map<String, Object> summary = new Map<String, Object>();
        
        Decimal totalValue = 0;
        Integer dealsWithValue = 0;
        Set<String> uniqueAEs = new Set<String>();
        Set<String> uniqueStages = new Set<String>();
        Set<String> uniqueProducts = new Set<String>();
        Decimal totalDaysInStage = 0;
        Integer dealsWithDays = 0;
        
        for (Agent_Open_Pipe__c record : results) {
            if (record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C != null) {
                totalValue += record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C;
                dealsWithValue++;
            }
            if (String.isNotBlank(record.FULL_NAME__C)) {
                uniqueAEs.add(record.FULL_NAME__C);
            }
            if (String.isNotBlank(record.OPEN_PIPE_OPTY_STG_NM__C)) {
                uniqueStages.add(record.OPEN_PIPE_OPTY_STG_NM__C);
            }
            if (String.isNotBlank(record.OPEN_PIPE_APM_L2__C)) {
                uniqueProducts.add(record.OPEN_PIPE_APM_L2__C);
            }
            if (record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__C != null) {
                totalDaysInStage += record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__C;
                dealsWithDays++;
            }
        }
        
        summary.put('totalDeals', results.size());
        summary.put('totalPipelineValue', totalValue);
        summary.put('dealsWithValue', dealsWithValue);
        summary.put('avgDealSize', dealsWithValue > 0 ? totalValue / dealsWithValue : 0);
        summary.put('uniqueAEs', uniqueAEs.size());
        summary.put('uniqueStages', uniqueStages.size());
        summary.put('uniqueProducts', uniqueProducts.size());
        summary.put('avgDaysInStage', dealsWithDays > 0 ? totalDaysInStage / dealsWithDays : 0);
        
        return summary;
    }
    
    /**
     * @description Build results array (max 100 records for performance)
     */
    private static List<Map<String, Object>> buildResults(List<Agent_Open_Pipe__c> results, Integer requestedLimit) {
        List<Map<String, Object>> output = new List<Map<String, Object>>();
        Integer maxResults = requestedLimit != null && requestedLimit > 0 ? 
                        Math.min(requestedLimit, 100) : 
                        Math.min(results.size(), 100);
        
        for (Integer i = 0; i < maxResults; i++) {
            Agent_Open_Pipe__c record = results[i];
            Map<String, Object> item = new Map<String, Object>();
            
            if (String.isNotBlank(record.FULL_NAME__C)) item.put('aeName', record.FULL_NAME__C);
            if (String.isNotBlank(record.OPEN_PIPE_OPTY_NM__C)) item.put('opportunityName', record.OPEN_PIPE_OPTY_NM__C);
            if (String.isNotBlank(record.OPEN_PIPE_OPTY_STG_NM__C)) item.put('stage', record.OPEN_PIPE_OPTY_STG_NM__C);
            if (String.isNotBlank(record.OPEN_PIPE_APM_L2__C)) item.put('product', record.OPEN_PIPE_APM_L2__C);
            if (String.isNotBlank(record.OPEN_PIPE_PROD_NM__C)) item.put('productSKU', record.OPEN_PIPE_PROD_NM__C);
            if (record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C != null) item.put('value', record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C);
            if (record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__C != null) item.put('daysInStage', record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__C);
            if (record.OPEN_PIPE_AE_SCORE__C != null) item.put('aeScore', record.OPEN_PIPE_AE_SCORE__C);
            if (String.isNotBlank(record.PRIMARY_INDUSTRY__C)) item.put('industry', record.PRIMARY_INDUSTRY__C);
            if (String.isNotBlank(record.MACROSGMENT__C)) item.put('segment', record.MACROSGMENT__C);
            if (String.isNotBlank(record.WORK_LOCATION_COUNTRY__C)) item.put('country', record.WORK_LOCATION_COUNTRY__C);
            
            output.add(item);
        }
        
        return output;
    }
    
    /**
     * @description Get field context for agent understanding
     */
    private static Map<String, String> getFieldContext() {
        return new Map<String, String>{
            'aeName' => 'Account Executive name',
            'opportunityName' => 'Deal/opportunity name',
            'stage' => 'Deal stage (01-07, e.g., 02 - Determining Problem, Impact, Ideal)',
            'product' => 'Product family',
            'productSKU' => 'Specific product SKU',
            'value' => 'Deal value in USD (ACV)',
            'daysInStage' => 'Number of days opportunity has been in current stage',
            'aeScore' => 'AE confidence score for deal closure',
            'industry' => 'Customer industry',
            'segment' => 'Customer segment (Enterprise, Mid-Market, SMB)',
            'country' => 'Customer country'
        };
    }
    
    /**
     * @description Build region clarification message
     */
    private static String buildRegionClarificationMessage(String region) {
        Map<String, Object> clarification = new Map<String, Object>();
        clarification.put('needsClarification', true);
        clarification.put('regionProvided', region);
        clarification.put('availableOUs', REGION_OU_MAP.get(region));
        clarification.put('message', 'The region "' + region + '" covers multiple Organizational Units. Please specify which OU you\'d like to analyze.');
        
        return 'CLARIFICATION NEEDED\n\n```json\n' + JSON.serializePretty(clarification) + '\n```';
    }
    
    /**
     * @description Build clarification message for missing required fields
     */
    private static String buildClarificationMessage(String errorType, Map<String, Object> context) {
        Map<String, Object> clarification = new Map<String, Object>();
        
        if (errorType == 'MISSING_OU_OR_COUNTRY') {
            clarification.put('error', 'Missing required parameter');
            clarification.put('message', 'Please provide either OU (ou) or Country (country) parameter');
            clarification.put('examples', new List<String>{
                '{"ou": "UKI"}',
                '{"ou": "AMER ACC", "stage": "2"}',
                '{"country": "United Kingdom", "product": "Agentforce"}'
            });
        }
        
        return 'ERROR\n\n```json\n' + JSON.serializePretty(clarification) + '\n```';
    }
    
    /**
     * @description Build no data message
     */
    private static String buildNoDataMessage(Map<String, Object> queryParams, Integer totalCount) {
        Map<String, Object> noData = new Map<String, Object>();
        noData.put('found', 0);
        noData.put('message', 'No data found for the specified criteria');
        noData.put('queryParameters', queryParams);
        noData.put('suggestions', new List<String>{
            'Try broadening your search criteria',
            'Check if the OU name is correct',
            'Verify stage names match the format: 02 - Determining Problem, Impact, Ideal'
        });
        
        return 'NO DATA FOUND\n\n```json\n' + JSON.serializePretty(noData) + '\n```';
    }
    
    /**
     * @description Build error response
     */
    private static String buildErrorResponse(Exception e) {
        Map<String, Object> error = new Map<String, Object>();
        error.put('error', true);
        error.put('message', e.getMessage());
        error.put('type', e.getTypeName());
        
        return 'ERROR\n\n```json\n' + JSON.serializePretty(error) + '\n```';
    }
    
    /**
     * @description Helper to get string parameter with default
     */
    private static String getStringParam(Map<String, Object> params, String key) {
        return getStringParam(params, key, null);
    }
    
    private static String getStringParam(Map<String, Object> params, String key, String defaultValue) {
        if (params == null || !params.containsKey(key)) {
            return defaultValue;
        }
        Object value = params.get(key);
        return value != null ? String.valueOf(value) : defaultValue;
    }
    
    /**
     * @description Helper to get integer parameter
     */
    private static Integer getIntParam(Map<String, Object> params, String key) {
        if (params == null || !params.containsKey(key)) {
            return null;
        }
        Object value = params.get(key);
        if (value == null) {
            return null;
        }
        if (value instanceof Integer) {
            return (Integer) value;
        }
        if (value instanceof String) {
            try {
                return Integer.valueOf((String) value);
            } catch (Exception e) {
                return null;
            }
        }
        return null;
    }
}

