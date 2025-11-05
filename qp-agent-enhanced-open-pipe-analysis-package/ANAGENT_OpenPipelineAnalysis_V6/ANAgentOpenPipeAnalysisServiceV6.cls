/**
 * @description Open Pipeline Analysis Service V6 - AgentCore integrated with enhanced error handling
 * @author Sales Operations Team
 * @version 6.0
 * @date 2025-11-04
 * 
 * IMPROVEMENTS FROM V5:
 * - AgentCore Constants integration for standardized error codes
 * - AgentCore Exception integration for typed errors
 * - Country name normalization (fixes "United States of America" issue)
 * - Auto query limit handling (prevents >50K errors, auto-switches to summary mode)
 * - Opportunity link support with handler switch
 * - Enhanced AE Scorecard context (0-5 scale, not 0-10)
 * - Deal band definition context for agent
 * - Professional, business-focused error messages
 * 
 * PURPOSE: Strategic analysis of current open sales pipeline
 * - Identifies underperforming products, verticals, segments
 * - Tracks stagnation (days in stage) across all dimensions
 * - Highlights stage bottlenecks and glitches
 * - Provides AE confidence scoring (0-5 scale)
 * 
 * DEAL AMOUNT FIELD: Uses OPEN_PIPE_OPENPIPE_ALLOC_AMT__c (not ORIGINAL)
 * 
 * PRODUCT HIERARCHY:
 * - OPEN_PIPE_APM_L2__c: L2 product category (~100 categories, e.g., "Tableau")
 * - OPEN_PIPE_PROD_NM__c: L3 product name/SKU level (specific items, e.g., "Tableau Desktop")
 */
public with sharing class ANAgentOpenPipeAnalysisServiceV6 {

    // Object API name
    private static final String OBJECT_NAME = 'Agent_Open_Pipe__c';
    
    // Maximum detailed rows to prevent payload issues
    private static final Integer MAX_DETAILED_ROWS = 200;
    
    // Auto-summary threshold (prevents memory errors)
    private static final Integer AUTO_SUMMARY_THRESHOLD = 10000;
    
    // Query limit threshold (hard stop)
    private static final Integer QUERY_LIMIT_THRESHOLD = 50000;
    
    // Whitelist of fields that support LIKE queries
    private static final Set<String> LIKE_FIELDS = new Set<String>{
        'FULL_NAME__c', 'OU_NAME__c', 'WORK_LOCATION_COUNTRY__c', 
        'PRIMARY_INDUSTRY__c', 'MACROSGMENT__c', 'EMP_MGR_NM__c',
        'OPEN_PIPE_APM_L2__c', 'OPEN_PIPE_PROD_NM__c'
    };
    
    // V6: Country name normalization mapping
    private static final Map<String, String> COUNTRY_ALIASES = new Map<String, String>{
        'United States of America' => 'United States',
        'USA' => 'United States',
        'US' => 'United States',
        'UK' => 'United Kingdom',
        'Deutschland' => 'Germany',
        'Allemagne' => 'Germany'
    };

    // WhereParts class for building reusable WHERE clauses
    public class WhereParts {
        public String whereClause = 'WHERE Id != null';
        public List<String> clauses = new List<String>();
    }

    /**
     * Helper method to format DateTime for SOQL (inline ISO format)
     */
    private static String toSoqlDateTime(DateTime dt) {
        if (dt == null) return null;
        return dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }

    /**
     * Helper method to check if a field exists on an object
     */
    public static Boolean hasField(String objApi, String fieldApi) {
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApi);
        if (objType == null) return false;
        return objType.getDescribe().fields.getMap().containsKey(fieldApi);
    }
    
    /**
     * V6: Normalizes country name using alias mapping
     */
    private static String normalizeCountryName(String country) {
        if (String.isBlank(country)) return country;
        
        // Check if alias exists
        if (COUNTRY_ALIASES.containsKey(country)) {
            return COUNTRY_ALIASES.get(country);
        }
        
        // Return as-is
        return country;
    }

    /**
     * Maps human-readable stage names to actual field values
     */
    public static String mapStageHumanToActual(String humanInput) {
        if (String.isBlank(humanInput)) return null;
        
        String normalized = humanInput.toLowerCase().trim();
        
        // Remove "stage" prefix if present and extract number
        normalized = normalized.replaceAll('^stage\\s*', '');
        
        if (normalized == '2' || normalized == '02') {
            return '02 - Determining Problem, Impact, Ideal';
        } else if (normalized == '3' || normalized == '03') {
            return '03 - Validating Benefits & Value';
        } else if (normalized == '4' || normalized == '04') {
            return '04 - Confirming Value With Power';
        } else if (normalized == '5' || normalized == '05') {
            return '05 - Negotiating $$ & Mutual Plan';
        } else if (normalized == '6' || normalized == '06') {
            return '06 - Finalizing Closure';
        } else if (normalized == '7' || normalized == '07') {
            return '07 - Pending';
        }
        
        // If no match, return original (might already be actual value)
        return humanInput;
    }

    /**
     * Maps actual stage value to human-readable name
     */
    public static String mapStageActualToHuman(String actualValue) {
        if (String.isBlank(actualValue)) return null;
        
        if (actualValue.startsWith('02')) {
            return 'Stage 2';
        } else if (actualValue.startsWith('03')) {
            return 'Stage 3';
        } else if (actualValue.startsWith('04')) {
            return 'Stage 4';
        } else if (actualValue.startsWith('05')) {
            return 'Stage 5';
        } else if (actualValue.startsWith('06')) {
            return 'Stage 6';
        } else if (actualValue.startsWith('07')) {
            return 'Stage 7';
        }
        
        return actualValue; // Return as-is if no mapping
    }

    /**
     * Standardized success response - JSON-first envelope using AgentCore pattern
     */
    public static String ok(Object data, Integer totalCount, Integer limitApplied) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('ok', true);
        response.put('data', data);
        response.put('error', null);
        if (totalCount != null) response.put('total', totalCount);
        if (limitApplied != null) response.put('limit', limitApplied);
        return JSON.serialize(response);
    }

    /**
     * Standardized error response - JSON-first envelope using AgentCore error codes
     */
    public static String err(String code, String message, String field, String expected, Object got,
                              List<String> samples, List<String> nextSteps) {
        Map<String, Object> res = new Map<String, Object>{
            'ok' => false,
            'data' => null,
            'error' => new Map<String, Object>{
                'code' => code,
                'message' => message,
                'details' => new Map<String, Object>{
                    'field' => field,
                    'expected' => expected,
                    'got' => got,
                    'samples' => (samples == null ? new List<String>() : samples),
                    'agent_next_steps' => (nextSteps == null ? new List<String>() : nextSteps)
                }
            }
        };
        return JSON.serialize(res);
    }

    /**
     * Main analysis method - JSON-first, agent-fixable, safe/consistent
     * V6: Added includeOpportunityLinks parameter
     */
    public static String analyzeOpenPipe(ANAgentOpenPipeAnalysisHandlerV6.OpenPipeAnalysisRequest request,
                                         Boolean summaryOnlyValue, Integer limitNValue, Boolean includeOpportunityLinks) {
        try {
            // 1. Validate Input
            String validationError = validateInput(request, summaryOnlyValue, limitNValue);
            if (validationError != null) {
                return validationError;
            }

            // 2. Permission Check using AgentCore
            if (!FRPermissionGuard.hasRead(OBJECT_NAME)) {
                return err(AgentCore_Constants.RESULT_CODE_PERMISSION_DENIED, 
                          'No read access to ' + OBJECT_NAME, 
                          'object', 'Read on ' + OBJECT_NAME, null, null,
                          new List<String>{'Contact system administrator to grant read permissions on ' + OBJECT_NAME + ' object'});
            }
            if (!FRPermissionGuard.hasRead('Learner_Profile__c')) {
                return err(AgentCore_Constants.RESULT_CODE_PERMISSION_DENIED, 
                          'No read access to Learner_Profile__c', 
                          'object', 'Read on Learner_Profile__c', null, null,
                          new List<String>{'Contact system administrator to grant read permissions on Learner_Profile__c object'});
            }

            // 3. Build reusable WHERE clause
            Object whereResult = buildWhere(request);
            if (whereResult instanceof String) {
                return (String) whereResult; // Early return if error
            }
            WhereParts whereParts = (WhereParts) whereResult;

            // 4. V6 CRITICAL FIX: Check count FIRST before loading data
            Integer totalCount = getTotalCount(whereParts);
            System.debug('🔍 V6 Estimated record count: ' + totalCount);
            
            // 5. V6 AUTO-HANDLING: Check if query exceeds thresholds
            if (totalCount > QUERY_LIMIT_THRESHOLD) {
                return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT,
                          'Result set too large (' + totalCount + ' records). Please narrow your query.',
                          'filters',
                          'Filters that return <= ' + QUERY_LIMIT_THRESHOLD + ' records',
                          totalCount + ' records',
                          new List<String>{'Add specific OU filter', 'Add product filter', 'Add date range'},
                          new List<String>{
                              'Try filtering by specific OU (e.g., "AMER ACC")',
                              'Add product filter (e.g., "Tableau")',
                              'Add date range to narrow results',
                              'Current query would return ' + totalCount + ' records (max: ' + QUERY_LIMIT_THRESHOLD + ')'
                          });
            }
            
            // Auto-enable summary mode if dataset is large
            Boolean autoSummaryEnabled = false;
            if (totalCount > AUTO_SUMMARY_THRESHOLD && (summaryOnlyValue == null || summaryOnlyValue == false)) {
                summaryOnlyValue = true;
                autoSummaryEnabled = true;
                System.debug('⚡ V6: Auto-enabled summary mode due to large result set: ' + totalCount + ' records');
            }

            // 6. Set limit value - use AgentCore default
            Integer limitValue = (limitNValue != null && limitNValue > 0) ? limitNValue : AgentCore_Constants.MAX_QUERY_ROWS;
            if (limitValue > AgentCore_Constants.MAX_QUERY_ROWS) {
                limitValue = AgentCore_Constants.MAX_QUERY_ROWS;
            }

            // 7. Build and execute queries
            String dataQuery = buildDataQuery(whereParts, limitValue, includeOpportunityLinks);
            System.debug('Open Pipe V6 Query: ' + dataQuery);

            List<SObject> records = executeQuery(dataQuery);

            if (records.isEmpty()) {
                // When no results found, provide valid values to help agent correct input
                System.debug('⚠️ ZERO RESULTS - Input Parameters:');
                System.debug('  ouName: ' + request.ouName);
                System.debug('  workLocationCountry: ' + request.workLocationCountry);
                System.debug('  productFamily: ' + request.productFamily);
                System.debug('  aeName: ' + request.aeName);
                System.debug('  industry: ' + request.industry);
                System.debug('  segment: ' + request.segment);
                System.debug('  stageFilter: ' + request.stageFilter);
                
                Map<String, Object> validValues = getValidFilterValues();
                
                Map<String, Object> emptyData = new Map<String, Object>{
                    'analysisType' => 'OPEN_PIPE',
                    'totalRecords' => 0,
                    'returnedRecords' => 0,
                    'omittedRecords' => 0,
                    'records' => new List<Map<String, Object>>(),
                    'summary' => new Map<String, Object>{
                        'totals' => new Map<String, Object>{
                            'total_amount' => 0,
                            'total_count' => 0,
                            'total_stagnation_days' => 0,
                            'average_stagnation_days' => 0,
                            'average_ae_score' => null
                        }
                    },
                    'validValues' => validValues,
                    'suggestion' => 'No records found. Check your input values against validValues section.'
                };
                return ok(emptyData, 0, limitValue);
            }

            // 8. Enrich with Learner Profile data using IDs
            Set<String> learnerProfileIds = new Set<String>();
            for (SObject record : records) {
                String lpId = (String) record.get('LEARNER_PROFILE_ID__c');
                if (String.isNotBlank(lpId)) {
                    learnerProfileIds.add(lpId);
                }
            }

            Map<String, SObject> learnerProfiles = getLearnerProfileDataByIds(learnerProfileIds);

            // 9. Build response data with summaryOnly mode support
            Boolean summaryOnlyMode = (summaryOnlyValue == null || summaryOnlyValue == true);
            List<Map<String, Object>> results = new List<Map<String, Object>>();
            
            if (!summaryOnlyMode) {
                // Build detailed records only if not in summaryOnly mode
                for (SObject record : records) {
                    if (results.size() >= MAX_DETAILED_ROWS) break;
                    String lpId = (String) record.get('LEARNER_PROFILE_ID__c');
                    SObject learnerProfile = String.isNotBlank(lpId) ? learnerProfiles.get(lpId) : null;
                    results.add(buildRecordMapSafe(record, learnerProfile, includeOpportunityLinks));
                }
            }
            Integer omitted = summaryOnlyMode ? records.size() : Math.max(0, records.size() - results.size());

            // 10. Build aggregation summary (always include)
            List<Map<String, Object>> aggregationSource = summaryOnlyMode ? 
                buildLightweightRecords(records, learnerProfiles, includeOpportunityLinks) : results;
            Map<String, Object> aggregationSummary = buildAggregationSummary(aggregationSource);

            // 11. Build complete response
            Map<String, Object> responseData = new Map<String, Object>{
                'analysisType' => 'OPEN_PIPE',
                'totalRecords' => totalCount,
                'returnedRecords' => results.size(),
                'omittedRecords' => omitted,
                'summaryOnly' => summaryOnlyMode,
                'summary' => aggregationSummary,
                'records' => results
            };
            
            // Add metadata if auto-summary was enabled
            if (autoSummaryEnabled) {
                responseData.put('autoSummaryEnabled', true);
                responseData.put('reason', 'Dataset size (' + totalCount + ') exceeds threshold (' + AUTO_SUMMARY_THRESHOLD + ')');
            }

            // 12. Return JSON-first response with defensive size guard
            String out = ok(responseData, totalCount, limitValue);
            if (out.length() > 900000) { // ~1 MB safety
                responseData.put('records', new List<Object>());
                responseData.put('omittedRecords', totalCount);
                responseData.put('message', 'Response too large - all detailed records omitted. Use summaryOnly=true or add filters.');
                out = ok(responseData, totalCount, limitValue);
            }
            return out;

        } catch (QueryException qe) {
            return err(AgentCore_Constants.RESULT_CODE_ERROR, 'Database query failed', 
                      'soql', 'valid SOQL', qe.getMessage(), null,
                      new List<String>{'Reduce filters and retry', 'Check field API names'});
        } catch (Exception e) {
            return err(AgentCore_Constants.RESULT_CODE_UNEXPECTED, 'Unexpected system error', 
                      'service', 'successful execution', e.getMessage(), null,
                      new List<String>{'Retry operation', 'Contact system administrator if error persists'});
        }
    }

    /**
     * Validates input parameters using AgentCore error codes
     */
    public static String validateInput(ANAgentOpenPipeAnalysisHandlerV6.OpenPipeAnalysisRequest request,
                                        Boolean summaryOnlyValue, Integer limitNValue) {
        // TERRITORY FILTER VALIDATION
        if (String.isBlank(request.ouName) && String.isBlank(request.workLocationCountry) && String.isBlank(request.managerEmail)) {
            return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                      'Territory or manager filter required', 
                      'ouName, workLocationCountry, or managerEmail', 
                      'Either OU Name, Work Location Country, or Manager Email must be specified', 
                      'none provided',
                      new List<String>{'UKI', 'AMER ACC', 'United States', 'sallen@salesforce.com'},
                      new List<String>{
                          'Specify ouName (e.g., "AMER ACC")',
                          'OR workLocationCountry (e.g., "United States")',
                          'OR managerEmail (e.g., "sallen@salesforce.com")'
                      });
        }
        
        // Validate limit range using AgentCore constants
        if (limitNValue != null && !FRSearchGuard.isInRange(limitNValue, 1, AgentCore_Constants.MAX_QUERY_ROWS)) {
            return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                      'limit must be between 1 and 50,000', 
                      'limit', '1–50000', String.valueOf(limitNValue),
                      new List<String>{'1000', '5000', '10000', '50000'},
                      new List<String>{'Use a value between 1 and 50,000'});
        }

        // Validate date formats if provided
        if (String.isNotBlank(request.startDate)) {
            try {
                Date.valueOf(request.startDate);
            } catch (Exception e) {
                return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                          'Invalid startDate format', 
                          'startDate', 'YYYY-MM-DD', request.startDate,
                          new List<String>{'2024-01-01', '2024-12-31'},
                          new List<String>{'Use YYYY-MM-DD format'});
            }
        }
        
        if (String.isNotBlank(request.endDate)) {
            try {
                Date.valueOf(request.endDate);
            } catch (Exception e) {
                return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                          'Invalid endDate format', 
                          'endDate', 'YYYY-MM-DD', request.endDate,
                          new List<String>{'2024-01-01', '2024-03-31', '2024-12-31'},
                          new List<String>{'Use YYYY-MM-DD format like "2024-12-31"'});
            }
        }
        
        // Validate date range
        if (String.isNotBlank(request.startDate) && String.isNotBlank(request.endDate)) {
            try {
                Date s = Date.valueOf(request.startDate);
                Date e = Date.valueOf(request.endDate);
                if (e < s) {
                    return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                              'endDate must be on or after startDate', 
                              'endDate', '>= ' + request.startDate, request.endDate,
                              new List<String>{'If startDate is "2024-01-01", use endDate like "2024-03-31"'},
                              new List<String>{'Adjust endDate to be after startDate'});
                }
            } catch (Exception e) {
                return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                          'Error comparing dates', 
                          'startDate/endDate', 'valid date range', 
                          'startDate: ' + request.startDate + ', endDate: ' + request.endDate,
                          new List<String>{'2024-01-01 to 2024-12-31'},
                          new List<String>{'Check both dates are valid YYYY-MM-DD format'});
            }
        }
        
        return null; // Validation passed
    }

    /**
     * Builds reusable WHERE clause with V6 country normalization
     */
    public static Object buildWhere(ANAgentOpenPipeAnalysisHandlerV6.OpenPipeAnalysisRequest request) {
        WhereParts p = new WhereParts();

        // OU Name filter with generic region mapping
        if (String.isNotBlank(request.ouName)) {
            String ou = request.ouName.trim();
            
            if (ou == 'EMEA' || ou.equalsIgnoreCase('EMEA')) {
                p.clauses.add('(OU_NAME__c LIKE \'EMEA%\' OR OU_NAME__c LIKE \'SMB - EMEA%\')');
            } else if (ou == 'APAC' || ou.equalsIgnoreCase('APAC')) {
                p.clauses.add('(OU_NAME__c LIKE \'APAC%\' OR OU_NAME__c IN (\'ANZ\', \'Japan\', \'South Asia - India\', \'South Asia - ASEAN\'))');
            } else if (ou == 'AMER' || ou.equalsIgnoreCase('AMER')) {
                p.clauses.add('(OU_NAME__c LIKE \'AMER%\' OR OU_NAME__c LIKE \'SMB - AMER%\')');
            } else if (ou == 'LATAM' || ou.equalsIgnoreCase('LATAM')) {
                p.clauses.add('(OU_NAME__c LIKE \'LATAM%\' OR OU_NAME__c LIKE \'SMB - LATAM%\')');
            } else {
                p.clauses.add('OU_NAME__c = \'' + String.escapeSingleQuotes(ou) + '\'');
            }
        }

        // V6: Work Location Country filter with normalization
        if (String.isNotBlank(request.workLocationCountry)) {
            String normalizedCountry = normalizeCountryName(request.workLocationCountry);
            p.clauses.add('WORK_LOCATION_COUNTRY__c = \'' + String.escapeSingleQuotes(normalizedCountry) + '\'');
        }

        // Stage filter
        if (String.isNotBlank(request.stageFilter)) {
            String actualStage = mapStageHumanToActual(request.stageFilter);
            p.clauses.add('OPEN_PIPE_OPTY_STG_NM__c = \'' + String.escapeSingleQuotes(actualStage) + '\'');
        }

        // Product Family filter (LIKE for partial matching on APM_L2)
        if (String.isNotBlank(request.productFamily)) {
            p.clauses.add('OPEN_PIPE_APM_L2__c LIKE \'%' + String.escapeSingleQuotes(request.productFamily) + '%\'');
        }
        
        // AE Name filter
        if (String.isNotBlank(request.aeName)) {
            p.clauses.add('FULL_NAME__c = \'' + String.escapeSingleQuotes(request.aeName) + '\'');
        }

        // Industry filter
        if (String.isNotBlank(request.industry)) {
            p.clauses.add('PRIMARY_INDUSTRY__c = \'' + String.escapeSingleQuotes(request.industry) + '\'');
        }

        // Segment filter
        if (String.isNotBlank(request.segment)) {
            p.clauses.add('MACROSGMENT__c = \'' + String.escapeSingleQuotes(request.segment) + '\'');
        }

        // Date range filters
        if (String.isNotBlank(request.startDate)) {
            Date d = Date.valueOf(request.startDate);
            DateTime startDt = DateTime.newInstanceGMT(d.year(), d.month(), d.day(), 0, 0, 0);
            p.clauses.add('CreatedDate >= ' + toSoqlDateTime(startDt));
        }
        
        if (String.isNotBlank(request.endDate)) {
            Date d = Date.valueOf(request.endDate);
            DateTime endDt = DateTime.newInstanceGMT(d.year(), d.month(), d.day(), 23, 59, 59);
            p.clauses.add('CreatedDate <= ' + toSoqlDateTime(endDt));
        }

        // Manager filter - Auto-search all hierarchy levels
        if (String.isNotBlank(request.managerEmail)) {
            List<String> allLevelsFilter = new List<String>();
            String escapedEmail = String.escapeSingleQuotes(request.managerEmail);
            for (Integer i = 1; i <= 12; i++) {
                String levelField = 'Emp_Mgt_Chain_Lvl_' + String.valueOf(i).leftPad(2, '0') + '_Nm__c';
                allLevelsFilter.add(levelField + ' = \'' + escapedEmail + '\'');
            }
            
            try {
                String lpQuery = 'SELECT Id FROM Learner_Profile__c WHERE ' + String.join(allLevelsFilter, ' OR ');
                List<SObject> lpRecords = Database.query(lpQuery);
                
                if (!lpRecords.isEmpty()) {
                    Set<String> learnerProfileIds = new Set<String>();
                    for (SObject lpRecord : lpRecords) {
                        learnerProfileIds.add((String) lpRecord.get('Id'));
                    }
                    
                    List<String> quotedIds = new List<String>();
                    for (String lpId : learnerProfileIds) {
                        quotedIds.add('\'' + String.escapeSingleQuotes(lpId) + '\'');
                    }
                    p.clauses.add('LEARNER_PROFILE_ID__c IN (' + String.join(quotedIds, ',') + ')');
                } else {
                    return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                        'No AEs found reporting to manager: ' + request.managerEmail, 
                        'managerEmail', 
                        'Valid manager email', 
                        request.managerEmail,
                        new List<String>{'sallen@salesforce.com', 'mfitzgerald@salesforce.com'},
                        new List<String>{
                            'Verify manager email is correct',
                            'Try using ouName or workLocationCountry instead'
                        });
                }
            } catch (Exception e) {
                return err(AgentCore_Constants.RESULT_CODE_ERROR, 
                    'Error searching for AEs by manager email: ' + e.getMessage(), 
                    'managerEmail', 
                    'Valid email format', 
                    request.managerEmail,
                    new List<String>{'sallen@salesforce.com'},
                    new List<String>{'Ensure email is in correct format: user@salesforce.com'});
            }
        }

        // Build final WHERE clause
        if (!p.clauses.isEmpty()) {
            p.whereClause += ' AND ' + String.join(p.clauses, ' AND ');
        }

        return p;
    }

    /**
     * Builds data query with optional opportunity link field
     */
    public static String buildDataQuery(WhereParts whereParts, Integer limitValue, Boolean includeOpportunityLinks) {
        List<String> fields = new List<String>{
            'Id', 'Name', 'FULL_NAME__c', 'OU_NAME__c', 'WORK_LOCATION_COUNTRY__c',
            'PRIMARY_INDUSTRY__c', 'MACROSGMENT__c', 'EMP_MGR_NM__c', 'CreatedDate'
        };
        
        // Add Learner Profile ID
        if (hasField(OBJECT_NAME, 'LEARNER_PROFILE_ID__c')) {
            fields.add('LEARNER_PROFILE_ID__c');
        }
        
        // V6: Add Open Pipe specific fields - using correct amount field
        if (hasField(OBJECT_NAME, 'OPEN_PIPE_OPENPIPE_ALLOC_AMT__c')) {
            fields.add('OPEN_PIPE_OPENPIPE_ALLOC_AMT__c');
        }
        if (hasField(OBJECT_NAME, 'OPEN_PIPE_OPTY_STG_NM__c')) {
            fields.add('OPEN_PIPE_OPTY_STG_NM__c');
        }
        if (hasField(OBJECT_NAME, 'OPEN_PIPE_OPTY_DAYS_IN_STAGE__c')) {
            fields.add('OPEN_PIPE_OPTY_DAYS_IN_STAGE__c');
        }
        if (hasField(OBJECT_NAME, 'OPEN_PIPE_PROD_NM__c')) {
            fields.add('OPEN_PIPE_PROD_NM__c');
        }
        if (hasField(OBJECT_NAME, 'OPEN_PIPE_APM_L2__c')) {
            fields.add('OPEN_PIPE_APM_L2__c');
        }
        if (hasField(OBJECT_NAME, 'OPEN_PIPE_ACCOUNT_NAME__c')) {
            fields.add('OPEN_PIPE_ACCOUNT_NAME__c');
        }
        if (hasField(OBJECT_NAME, 'OPEN_PIPE_OPTY_NM__c')) {
            fields.add('OPEN_PIPE_OPTY_NM__c');
        }
        if (hasField(OBJECT_NAME, 'OPEN_PIPE_AE_SCORE__c')) {
            fields.add('OPEN_PIPE_AE_SCORE__c');
        }
        if (hasField(OBJECT_NAME, 'OPEN_PIPE_CLOSED_DATE__c')) {
            fields.add('OPEN_PIPE_CLOSED_DATE__c');
        }
        
        // V6: Conditionally add opportunity link field
        if (includeOpportunityLinks != null && includeOpportunityLinks == true) {
            if (hasField(OBJECT_NAME, 'OPEN_PIPE_OPPORTUNITY_LINK__c')) {
                fields.add('OPEN_PIPE_OPPORTUNITY_LINK__c');
            }
        }
        
        String baseSelect = 'SELECT ' + String.join(fields, ', ') +
                          ' FROM ' + OBJECT_NAME + ' ' + whereParts.whereClause +
                          ' ORDER BY OPEN_PIPE_OPENPIPE_ALLOC_AMT__c DESC NULLS LAST, CreatedDate DESC, Id ASC';
        
        if (limitValue != null && limitValue > 0) {
            baseSelect += ' LIMIT ' + limitValue;
        }
        
        return baseSelect;
    }

    /**
     * Gets total count using same WHERE clause
     */
    public static Integer getTotalCount(WhereParts whereParts) {
        String countQuery = 'SELECT COUNT() FROM ' + OBJECT_NAME + ' ' + whereParts.whereClause;
        return Database.countQuery(countQuery);
    }

    /**
     * Executes query with security stripping
     */
    private static List<SObject> executeQuery(String query) {
        List<SObject> results = Database.query(query);
        return Security.stripInaccessible(AccessType.READABLE, results).getRecords();
    }

    /**
     * Fetches Learner Profile data by IDs
     */
    public static Map<String, SObject> getLearnerProfileDataByIds(Set<String> learnerProfileIds) {
        Map<String, SObject> learnerProfiles = new Map<String, SObject>();

        if (learnerProfileIds.isEmpty()) {
            return learnerProfiles;
        }

        try {
            List<List<String>> chunks = chunkStrings(learnerProfileIds, 1000);
            
            for (List<String> chunk : chunks) {
                String lpQuery = 'SELECT Id, Name, WORK_LOCATION_COUNTRY__c, OU_NAME__c, ' +
                                'Emp_Mgt_Chain_Lvl_01_Nm__c, Emp_Mgt_Chain_Lvl_02_Nm__c ' +
                                'FROM Learner_Profile__c WHERE Id IN (' + String.join(chunk, ',') + ')';
                
                List<SObject> lpRecords = Database.query(lpQuery);
                for (SObject lpRecord : lpRecords) {
                    String id = (String) lpRecord.get('Id');
                    if (String.isNotBlank(id)) {
                        learnerProfiles.put(id, lpRecord);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error querying Learner_Profile__c: ' + e.getMessage());
        }

        return learnerProfiles;
    }

    /**
     * Chunks strings for SOQL IN clauses
     */
    private static List<List<String>> chunkStrings(Set<String> values, Integer size) {
        List<List<String>> out = new List<List<String>>();
        List<String> cur = new List<String>();
        for (String v : values) {
            cur.add('\'' + String.escapeSingleQuotes(v) + '\'');
            if (cur.size() == size) { 
                out.add(cur); 
                cur = new List<String>(); 
            }
        }
        if (!cur.isEmpty()) out.add(cur);
        return out;
    }

    /**
     * Builds lightweight records for aggregation (summaryOnly mode)
     */
    private static List<Map<String, Object>> buildLightweightRecords(List<SObject> records, 
                                                                      Map<String, SObject> learnerProfiles,
                                                                      Boolean includeOpportunityLinks) {
        List<Map<String, Object>> lightweightRecords = new List<Map<String, Object>>();
        
        for (SObject record : records) {
            Map<String, Object> lightRec = new Map<String, Object>();
            
            String lpId = (String) record.get('LEARNER_PROFILE_ID__c');
            SObject learnerProfile = String.isNotBlank(lpId) ? learnerProfiles.get(lpId) : null;
            
            // V6: Use correct amount field
            Object amountValue = record.get('OPEN_PIPE_OPENPIPE_ALLOC_AMT__c');
            lightRec.put('amount', amountValue);
            
            // Product fields (L2 = family, L3 = name/SKU)
            Object productFamily = record.get('OPEN_PIPE_APM_L2__c');
            Object productName = record.get('OPEN_PIPE_PROD_NM__c');
            lightRec.put('product', new Map<String, Object>{
                'family' => productFamily,
                'name' => productName
            });
            
            // Stage
            String stageActual = (String) record.get('OPEN_PIPE_OPTY_STG_NM__c');
            lightRec.put('stage', stageActual);
            lightRec.put('stageHuman', mapStageActualToHuman(stageActual));
            
            // Stagnation days
            Object stagnationDays = record.get('OPEN_PIPE_OPTY_DAYS_IN_STAGE__c');
            lightRec.put('stagnationDays', stagnationDays);
            
            // AE Score (0-5 scale)
            Object aeScore = record.get('OPEN_PIPE_AE_SCORE__c');
            lightRec.put('aeScore', aeScore);
            
            // Dimensions
            lightRec.put('industry', record.get('PRIMARY_INDUSTRY__c'));
            lightRec.put('segment', record.get('MACROSGMENT__c'));
            lightRec.put('vertical', record.get('PRIMARY_INDUSTRY__c'));
            
            // V6: Conditionally add opportunity link
            if (includeOpportunityLinks != null && includeOpportunityLinks == true) {
                lightRec.put('opportunityLink', record.get('OPEN_PIPE_OPPORTUNITY_LINK__c'));
            }
            
            lightweightRecords.add(lightRec);
        }
        
        return lightweightRecords;
    }

    /**
     * Builds detailed record map with 11 essential fields + optional opportunity link
     */
    public static Map<String, Object> buildRecordMapSafe(SObject record, SObject learnerProfile, 
                                                         Boolean includeOpportunityLinks) {
        Map<String, Object> recordMap = new Map<String, Object>();

        // Essential fields
        recordMap.put('id', record.Id);
        recordMap.put('pipeType', 'OPEN_PIPE');
        recordMap.put('learnerProfileId', learnerProfile != null ? learnerProfile.Id : null);
        
        // V6: Use correct amount field
        Object amountValue = record.get('OPEN_PIPE_OPENPIPE_ALLOC_AMT__c');
        recordMap.put('amount', amountValue);
        
        // Product (L2 = family/category, L3 = name/SKU)
        Map<String, Object> product = new Map<String, Object>();
        product.put('family', record.get('OPEN_PIPE_APM_L2__c')); // L2 level
        product.put('name', record.get('OPEN_PIPE_PROD_NM__c')); // L3/SKU level
        recordMap.put('product', product);
        
        // Dimensions
        recordMap.put('industry', record.get('PRIMARY_INDUSTRY__c'));
        recordMap.put('segment', record.get('MACROSGMENT__c'));
        recordMap.put('vertical', record.get('PRIMARY_INDUSTRY__c'));
        
        // Stage
        String stageActual = (String) record.get('OPEN_PIPE_OPTY_STG_NM__c');
        recordMap.put('stage', stageActual);
        recordMap.put('stageHuman', mapStageActualToHuman(stageActual));
        
        // Stagnation days
        Object stagnationDays = record.get('OPEN_PIPE_OPTY_DAYS_IN_STAGE__c');
        recordMap.put('stagnationDays', stagnationDays);
        
        // AE Score (0-5 scale, critical for close rate correlation)
        Object aeScore = record.get('OPEN_PIPE_AE_SCORE__c');
        recordMap.put('aeScore', aeScore);
        
        // V6: Conditionally add opportunity link
        if (includeOpportunityLinks != null && includeOpportunityLinks == true) {
            recordMap.put('opportunityLink', record.get('OPEN_PIPE_OPPORTUNITY_LINK__c'));
        }
        
        return recordMap;
    }

    /**
     * Builds aggregation summary with metrics by product, segment, industry, and stage
     */
    public static Map<String, Object> buildAggregationSummary(List<Map<String, Object>> results) {
        Map<String, Object> summary = new Map<String, Object>();
        
        if (results.isEmpty()) {
            summary.put('totals', new Map<String, Object>{
                'total_amount' => 0,
                'total_count' => 0,
                'average_stagnation_days' => 0,
                'average_ae_score' => null
            });
            return summary;
        }
        
        // Calculate totals
        Decimal totalAmount = 0;
        Integer totalCount = results.size();
        Decimal totalStagnation = 0;
        Integer stagnationCount = 0;
        Decimal totalAEScore = 0;
        Integer aeScoreCount = 0;
        
        for (Map<String, Object> record : results) {
            Object amountValue = record.get('amount');
            if (amountValue != null && amountValue instanceof Decimal) {
                totalAmount += (Decimal) amountValue;
            }
            
            Object stagnationValue = record.get('stagnationDays');
            if (stagnationValue != null && stagnationValue instanceof Integer) {
                totalStagnation += (Integer) stagnationValue;
                stagnationCount++;
            }
            
            Object aeScoreValue = record.get('aeScore');
            if (aeScoreValue != null && aeScoreValue instanceof Decimal) {
                totalAEScore += (Decimal) aeScoreValue;
                aeScoreCount++;
            }
        }
        
        // Build totals
        Map<String, Object> totals = new Map<String, Object>();
        totals.put('total_amount', totalAmount);
        totals.put('total_count', totalCount);
        totals.put('average_amount', totalCount > 0 ? totalAmount / totalCount : 0);
        totals.put('total_stagnation_days', totalStagnation);
        totals.put('average_stagnation_days', stagnationCount > 0 ? totalStagnation / stagnationCount : 0);
        totals.put('average_ae_score', aeScoreCount > 0 ? (totalAEScore / aeScoreCount).setScale(2) : null);
        summary.put('totals', totals);
        
        // Aggregations by dimension
        summary.put('by_product', aggregateByDimension(results, 'product'));
        summary.put('by_segment', aggregateByDimension(results, 'segment'));
        summary.put('by_industry', aggregateByDimension(results, 'industry'));
        summary.put('by_stage', aggregateByDimensionWithStageMapping(results));
        
        return summary;
    }

    /**
     * Aggregates records by dimension
     */
    public static List<Map<String, Object>> aggregateByDimension(List<Map<String, Object>> results, String dimension) {
        Map<String, AggregationData> aggregationMap = new Map<String, AggregationData>();
        
        for (Map<String, Object> record : results) {
            Object dimensionValue = getNestedValue(record, dimension);
            String key = dimensionValue != null ? String.valueOf(dimensionValue).toLowerCase() : 'unknown';
            
            if (!aggregationMap.containsKey(key)) {
                aggregationMap.put(key, new AggregationData());
            }
            
            AggregationData agg = aggregationMap.get(key);
            agg.count++;
            
            Object amountValue = record.get('amount');
            if (amountValue != null && amountValue instanceof Decimal) {
                agg.sumAmount += (Decimal) amountValue;
            }
            
            Object stagnationValue = record.get('stagnationDays');
            if (stagnationValue != null && stagnationValue instanceof Integer) {
                agg.totalStagnation += (Integer) stagnationValue;
                agg.stagnationCount++;
            }
            
            Object aeScoreValue = record.get('aeScore');
            if (aeScoreValue != null && aeScoreValue instanceof Decimal) {
                agg.totalAEScore += (Decimal) aeScoreValue;
                agg.aeScoreCount++;
            }
        }
        
        List<Map<String, Object>> aggregatedList = new List<Map<String, Object>>();
        for (String key : aggregationMap.keySet()) {
            AggregationData agg = aggregationMap.get(key);
            Map<String, Object> aggRecord = new Map<String, Object>();
            aggRecord.put(dimension, key);
            aggRecord.put('count', agg.count);
            aggRecord.put('sum_amount', agg.sumAmount);
            aggRecord.put('avg_stagnation', agg.stagnationCount > 0 ? agg.totalStagnation / agg.stagnationCount : 0);
            aggRecord.put('avg_ae_score', agg.aeScoreCount > 0 ? (agg.totalAEScore / agg.aeScoreCount).setScale(2) : null);
            aggregatedList.add(aggRecord);
        }
        
        aggregatedList.sort(new AggregationComparator());
        return aggregatedList;
    }

    /**
     * Aggregates by stage with human-readable names
     */
    public static List<Map<String, Object>> aggregateByDimensionWithStageMapping(List<Map<String, Object>> results) {
        Map<String, AggregationData> aggregationMap = new Map<String, AggregationData>();
        Map<String, String> stageHumanMap = new Map<String, String>();
        
        for (Map<String, Object> record : results) {
            String stageActual = (String) record.get('stage');
            String stageHuman = (String) record.get('stageHuman');
            String key = String.isNotBlank(stageActual) ? stageActual.toLowerCase() : 'unknown';
            
            if (!aggregationMap.containsKey(key)) {
                aggregationMap.put(key, new AggregationData());
                stageHumanMap.put(key, stageHuman);
            }
            
            AggregationData agg = aggregationMap.get(key);
            agg.count++;
            
            Object amountValue = record.get('amount');
            if (amountValue != null && amountValue instanceof Decimal) {
                agg.sumAmount += (Decimal) amountValue;
            }
            
            Object stagnationValue = record.get('stagnationDays');
            if (stagnationValue != null && stagnationValue instanceof Integer) {
                agg.totalStagnation += (Integer) stagnationValue;
                agg.stagnationCount++;
            }
            
            Object aeScoreValue = record.get('aeScore');
            if (aeScoreValue != null && aeScoreValue instanceof Decimal) {
                agg.totalAEScore += (Decimal) aeScoreValue;
                agg.aeScoreCount++;
            }
        }
        
        List<Map<String, Object>> aggregatedList = new List<Map<String, Object>>();
        for (String key : aggregationMap.keySet()) {
            AggregationData agg = aggregationMap.get(key);
            Map<String, Object> aggRecord = new Map<String, Object>();
            aggRecord.put('stage', key);
            aggRecord.put('stage_human', stageHumanMap.get(key));
            aggRecord.put('count', agg.count);
            aggRecord.put('sum_amount', agg.sumAmount);
            aggRecord.put('avg_stagnation', agg.stagnationCount > 0 ? agg.totalStagnation / agg.stagnationCount : 0);
            aggRecord.put('avg_ae_score', agg.aeScoreCount > 0 ? (agg.totalAEScore / agg.aeScoreCount).setScale(2) : null);
            aggregatedList.add(aggRecord);
        }
        
        aggregatedList.sort(new AggregationComparator());
        return aggregatedList;
    }

    /**
     * Gets nested value from record
     */
    public static Object getNestedValue(Map<String, Object> record, String path) {
        if (!path.contains('.')) {
            return record.get(path);
        }
        
        String[] parts = path.split('\\.');
        Object current = record;
        
        for (String part : parts) {
            if (current instanceof Map<String, Object>) {
                current = ((Map<String, Object>) current).get(part);
            } else {
                return null;
            }
        }
        
        return current;
    }

    /**
     * Aggregation data holder
     */
    private class AggregationData {
        public Integer count = 0;
        public Decimal sumAmount = 0;
        public Decimal totalStagnation = 0;
        public Integer stagnationCount = 0;
        public Decimal totalAEScore = 0;
        public Integer aeScoreCount = 0;
    }

    /**
     * Get valid filter values
     */
    private static Map<String, Object> getValidFilterValues() {
        Map<String, Object> validValues = new Map<String, Object>();
        
        validValues.put('valid_ou_names', new List<String>{
            'AMER ACC', 'AMER REG', 'AMER ICE', 'UKI', 'EMEA North', 'EMEA Central', 
            'EMEA South', 'LATAM', 'ANZ', 'Japan', 'South Asia - India', 'South Asia - ASEAN'
        });
        
        validValues.put('valid_countries', new List<String>{
            'United States', 'India', 'Japan', 'Ireland', 'Canada', 'United Kingdom', 
            'Australia', 'France', 'Germany', 'Brazil', 'Singapore'
        });
        
        validValues.put('valid_segments', new List<String>{
            'ENTR', 'CMRCL', 'ESMB', 'PubSec'
        });
        
        validValues.put('valid_stages', new List<String>{
            'Stage 2', 'Stage 3', 'Stage 4', 'Stage 5', 'Stage 6', 'Stage 7'
        });
        
        return validValues;
    }

    /**
     * Comparator for sorting by sum_amount
     */
    private class AggregationComparator implements Comparator<Map<String, Object>> {
        public Integer compare(Map<String, Object> a, Map<String, Object> b) {
            Object sumA = a.get('sum_amount');
            Object sumB = b.get('sum_amount');
            
            if (sumA instanceof Decimal && sumB instanceof Decimal) {
                Decimal decA = (Decimal) sumA;
                Decimal decB = (Decimal) sumB;
                if (decA > decB) return -1;
                if (decA < decB) return 1;
            }
            
            return 0;
        }
    }
}
