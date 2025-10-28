/**
 * ABAgentFuturePipeAnalysisServiceV5
 * Service layer for Future Pipeline Analysis V5
 * 
 * IMPROVEMENTS FROM V4:
 * - Accepts normalized Integer/Boolean values from handler (no string parsing)
 * - Enhanced exception handling with clear agent guidance
 * - Consistent field mapping with Agent_Renewals__c, Agent_Cross_Sell__c, Agent_Upsell__c objects
 * - Better error messages for common failure scenarios
 * - No references to V4 code
 * 
 * @version 5.0
 * @date 2025-10-27
 */
public with sharing class ABAgentFuturePipeAnalysisServiceV5 {

    // Object API names by analysis type
    private static final Map<String, String> OBJECT_MAP = new Map<String, String>{
        'RENEWALS' => 'Agent_Renewals__c',
        'CROSS_SELL' => 'Agent_Cross_Sell__c',
        'UPSELL' => 'Agent_Upsell__c'
    };

    // NOTE: GroupBy functionality removed - use AggregateJSONV1 action for all aggregations

    // Whitelist of fields that support LIKE queries for safety
    private static final Set<String> LIKE_FIELDS = new Set<String>{
        'FULL_NAME__c', 'OU_NAME__c', 'WORK_LOCATION_COUNTRY__c', 
        'PRIMARY_INDUSTRY__c', 'MACROSGMENT__c', 'EMP_MGR_NM__c'
    };

    // WhereParts class for building reusable WHERE clauses
    public class WhereParts {
        public String whereClause = 'WHERE Id != null';
        public List<String> clauses = new List<String>();
    }

    // Helper method to format DateTime for SOQL (inline ISO format)
    private static String toSoqlDateTime(DateTime dt) {
        if (dt == null) return null;
        return dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); // SOQL datetime literal
    }

    // Helper method to check if a field exists on an object
    public static Boolean hasField(String objApi, String fieldApi) {
        return Schema.getGlobalDescribe()
            .get(objApi).getDescribe()
            .fields.getMap().containsKey(fieldApi);
    }

    // Standardized success response - JSON-first envelope
    public static String ok(Object data, Integer totalCount, Integer limitApplied) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('ok', true);
        response.put('data', data);
        response.put('error', null);
        if (totalCount != null) response.put('total', totalCount);
        if (limitApplied != null) response.put('limit', limitApplied);
        return JSON.serialize(response);
    }

    // Standardized error response - JSON-first envelope
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
     * OVERLOADED VERSION - Accepts normalized Boolean/Integer values from handler
     * Note: includeFieldsCsv, verbose, agentHints removed for simplicity
     */
    public static String analyzeFuturePipe(ABAgentFuturePipeAnalysisHandlerV5.FuturePipeAnalysisRequest request,
                                           Boolean summaryOnlyValue, Integer limitNValue) {
        try {
            // 1. Validate Input
            String validationError = validateInput(request, summaryOnlyValue, limitNValue);
            if (validationError != null) {
                return validationError;
            }

            String analysisType = request.analysisType;
            String objectApiName = OBJECT_MAP.get(analysisType);
            
            // 2. Permission Check
            if (!FRPermissionGuard.hasRead(objectApiName)) {
                return err('INSUFFICIENT_ACCESS', 'No read access to ' + objectApiName, 'object', 'Read on ' + objectApiName, null, null,
                          new List<String>{'Contact support to grant read perms.'});
            }
            if (!FRPermissionGuard.hasRead('Learner_Profile__c')) {
                return err('INSUFFICIENT_ACCESS', 'No read access to Learner_Profile__c', 'object', 'Read on Learner_Profile__c', null, null,
                          new List<String>{'Contact support to grant read perms.'});
            }

            // 3. Build reusable WHERE clause
            Object whereResult = buildWhere(request);
            if (whereResult instanceof String) {
                return (String) whereResult; // Early return if buildWhere returned error
            }
            WhereParts whereParts = (WhereParts) whereResult;

            // 4. Set limit value - increased default to 20,000 for comprehensive coverage
        Integer limitValue = (limitNValue != null && limitNValue > 0) ? limitNValue : 20000;
        if (limitValue > 50000) limitValue = 50000;
        
        // Cap detailed results to prevent payload size issues
        final Integer MAX_DETAILED_ROWS = 200;

            // 5. Build and execute queries
            String dataQuery = buildDataQuery(whereParts, objectApiName, limitValue);
            System.debug('Future Pipe V4 Query: ' + dataQuery);

            List<SObject> records = executeQuery(dataQuery);
            Integer totalCount = getTotalCount(whereParts, objectApiName);

            if (records.isEmpty()) {
                Map<String, Object> emptyData = new Map<String, Object>{
                    'appliedFilters' => collectAppliedFilters(request),
                    'analysisType' => analysisType,
                    'total' => totalCount,
                    'limit' => limitValue,
                    'records' => new List<Map<String, Object>>(),
                    'summary' => new Map<String, Object>{
                        'totalRecords' => 0,
                        'message' => 'No records found matching the criteria'
                    }
                };
                return ok(emptyData, totalCount, limitValue);
            }

            // 6. Enrich with Learner Profile data using IDs (eliminates collision risk)
            Set<String> learnerProfileIds = new Set<String>();
            for (SObject record : records) {
                String lpId = (String) record.get('LEARNER_PROFILE_ID__c');
                if (String.isNotBlank(lpId)) {
                    learnerProfileIds.add(lpId);
                }
            }

            Map<String, SObject> learnerProfiles = getLearnerProfileDataByIds(learnerProfileIds);

            // 7. Build response data with null-safe casting and payload size cap
            List<Map<String, Object>> results = new List<Map<String, Object>>();
            
            // Check if summaryOnly mode is requested for performance optimization
            Boolean summaryOnlyMode = (summaryOnlyValue != null && summaryOnlyValue == true);
            
            if (!summaryOnlyMode) {
                // Build detailed records only if not in summaryOnly mode
                for (SObject record : records) {
                    if (results.size() >= MAX_DETAILED_ROWS) break;
                    String lpId = (String) record.get('LEARNER_PROFILE_ID__c');
                    SObject learnerProfile = String.isNotBlank(lpId) ? learnerProfiles.get(lpId) : null;
                    results.add(buildRecordMapSafe(record, learnerProfile, request));
                }
            }
            Integer omitted = summaryOnlyMode ? records.size() : Math.max(0, records.size() - results.size());

            // 8. Build embedded aggregation summary (always include, even in summaryOnly mode)
            // For summaryOnly mode, build aggregation from raw SObject records
            List<Map<String, Object>> aggregationSource = summaryOnlyMode ? buildLightweightRecords(records, learnerProfiles) : results;
            Map<String, Object> aggregationSummary = buildEmbeddedAggregation(aggregationSource, request, analysisType);
            
            // 9. Build complete response
            List<String> nextSteps = new List<String>();
            if (summaryOnlyMode) {
                nextSteps.add('Summary-only mode: Detailed records omitted for performance.');
                nextSteps.add('Set summaryOnly=false to get individual LP-level records.');
            } else if (omitted > 0) {
                nextSteps.add('Result truncated for agent display.');
                nextSteps.add('Call again with a lower limitN or add filters (OU, dates, AE).');
            }
            
            Map<String, Object> responseData = new Map<String, Object>{
                'appliedFilters' => collectAppliedFilters(request),
                'analysisType' => analysisType,
                'total' => totalCount,
                'limit' => limitValue,
                'omittedFromDetails' => omitted,
                'summaryOnly' => summaryOnlyMode,
                'summary' => aggregationSummary,
                'records' => results,
                'agent_next_steps' => nextSteps
            };

            // 9. Return JSON-first response with defensive size guard
            String out = ok(responseData, totalCount, limitValue);
            if (out.length() > 900000) { // ~1 MB safety
                responseData.put('records', new List<Object>());
                responseData.put('omittedFromDetails', records.size());
                responseData.put('agent_next_steps', new List<String>{
                    'Response too large - all records omitted for agent display.',
                    'Add filters (OU, dates, AE) or use lower limitN.'
                });
                out = ok(responseData, totalCount, limitValue);
            }
            return out;

        } catch (QueryException qe) {
            return err('QUERY_ERROR', 'Database query failed', 'soql', 'valid SOQL', null, null,
                      new List<String>{'Reduce filters and retry', 'Check field API names'});
        } catch (SecurityException se) {
            return err('SECURITY_ERROR', 'Access denied', 'security', 'CRUD/FLS permitting read', null, null,
                      new List<String>{'Request necessary permissions'});
        } catch (Exception e) {
            return err('UNEXPECTED_ERROR', 'Unexpected system error', 'service', 'successful execution', e.getMessage(), null,
                      new List<String>{'Retry', 'Escalate with stack trace id'});
        }
    }

    // NOTE: normalizeGroupBy method removed - use AggregateJSONV1 action for all aggregations

    /**
     * Validates input parameters with real samples
     */
    public static String validateInput(ABAgentFuturePipeAnalysisHandlerV5.FuturePipeAnalysisRequest request,
                                        Boolean summaryOnlyValue, Integer limitNValue) {
        // Check required field: analysisType
        if (String.isBlank(request.analysisType)) {
            return err('INVALID_INPUT', 'analysisType is required', 'analysisType', 'RENEWALS|CROSS_SELL|UPSELL', 'null',
                      new List<String>{'RENEWALS', 'CROSS_SELL', 'UPSELL'},
                      new List<String>{'Use one of the valid analysis types'});
        }

        // Check valid analysisType
        if (!OBJECT_MAP.containsKey(request.analysisType)) {
            return err('INVALID_INPUT', 'Invalid analysisType', 'analysisType', 'RENEWALS|CROSS_SELL|UPSELL', request.analysisType,
                      new List<String>{'RENEWALS', 'CROSS_SELL', 'UPSELL'},
                      new List<String>{'Use one of the valid analysis types'});
        }

        // NOTE: groupBy functionality removed - use AggregateJSONV1 action for all aggregations

        // Check limit range
        if (limitNValue != null && (limitNValue < 1 || limitNValue > 50000)) {
            return err('INVALID_INPUT', 'limitN must be between 1 and 50,000', 'limitN', '1-50000', String.valueOf(limitNValue),
                      new List<String>{'1000', '5000', '10000', '20000', '50000'},
                      new List<String>{'Use a value between 1 and 50,000. Default is 20,000 (RECOMMENDED).'});
        }

        // Check OU name if provided
        if (String.isNotBlank(request.ouName) && request.ouName.length() < 2) {
            return err('INVALID_INPUT', 'ouName too short', 'ouName', 'OU name (2+ chars)', request.ouName,
                      sampleOUs(5),
                      new List<String>{'Use one of the OUs from samples above'});
        }

        // Check work location country if provided
        if (String.isNotBlank(request.workLocationCountry) && request.workLocationCountry.length() < 2) {
            return err('INVALID_INPUT', 'workLocationCountry too short', 'workLocationCountry', 'country name', request.workLocationCountry,
                      sampleCountries(5),
                      new List<String>{'Use one of the countries from samples above'});
        }

        // CRITICAL: Enforce territory filter requirement to prevent 50K+ record queries
        // Accept ouName, workLocationCountry, OR managerEmail
        if (String.isBlank(request.ouName) && String.isBlank(request.workLocationCountry) && String.isBlank(request.managerEmail)) {
            return err('INVALID_INPUT', 'Territory or manager filter required', 'ouName, workLocationCountry, or managerEmail', 
                      'Either OU Name, Work Location Country, or Manager Email must be specified', 'none provided',
                      new List<String>{'UKI', 'AMER ACC', 'sallen@salesforce.com'},
                      new List<String>{
                          'Specify ouName (e.g., "AMER ACC")',
                          'OR workLocationCountry (e.g., "United States")',
                          'OR managerEmail (e.g., "sallen@salesforce.com")'
                      });
        }

        return null; // Validation passed
    }

    /**
     * Builds reusable WHERE clause for both data and count queries
     */
    public static Object buildWhere(ABAgentFuturePipeAnalysisHandlerV5.FuturePipeAnalysisRequest request) {
        WhereParts p = new WhereParts();

        // OU Name filter
        if (String.isNotBlank(request.ouName)) {
            p.clauses.add('OU_NAME__c = \'' + String.escapeSingleQuotes(request.ouName) + '\'');
        }

        // Work Location Country filter
        if (String.isNotBlank(request.workLocationCountry)) {
            p.clauses.add('WORK_LOCATION_COUNTRY__c = \'' + String.escapeSingleQuotes(request.workLocationCountry) + '\'');
        }

        // AE Name filter (exact match for safety)
        if (String.isNotBlank(request.aeName)) {
            p.clauses.add('FULL_NAME__c = \'' + String.escapeSingleQuotes(request.aeName) + '\'');
        }

        // Industry filter
        if (String.isNotBlank(request.aeIndustry)) {
            p.clauses.add('PRIMARY_INDUSTRY__c = \'' + String.escapeSingleQuotes(request.aeIndustry) + '\'');
        }

        // Macro Segment filter
        if (String.isNotBlank(request.aeMacroSegment)) {
            p.clauses.add('MACROSGMENT__c = \'' + String.escapeSingleQuotes(request.aeMacroSegment) + '\'');
        }

        // Manager Name filter
        if (String.isNotBlank(request.aeManagerName)) {
            p.clauses.add('EMP_MGR_NM__c = \'' + String.escapeSingleQuotes(request.aeManagerName) + '\'');
        }

        // Date range filters with inline ISO datetimes (no scope issues)
        if (String.isNotBlank(request.startDate)) {
            try {
                Date d = Date.valueOf(request.startDate);
                DateTime startDt = DateTime.newInstanceGMT(d.year(), d.month(), d.day(), 0, 0, 0);
                p.clauses.add('CreatedDate >= ' + toSoqlDateTime(startDt));
            } catch (Exception e) {
                return err('INVALID_INPUT', 'Invalid startDate format', 'startDate', 'YYYY-MM-DD', request.startDate,
                          new List<String>{'2024-01-01', '2024-12-31'},
                          new List<String>{'Use YYYY-MM-DD'});
            }
        }
        
        if (String.isNotBlank(request.endDate)) {
            try {
                Date d = Date.valueOf(request.endDate);
                // end of day inclusive
                DateTime endDt = DateTime.newInstanceGMT(d.year(), d.month(), d.day(), 23, 59, 59);
                p.clauses.add('CreatedDate <= ' + toSoqlDateTime(endDt));
            } catch (Exception e) {
                return err('INVALID_INPUT', 'Invalid endDate format', 'endDate', 'YYYY-MM-DD', request.endDate,
                          new List<String>{'2024-01-01', '2024-12-31'},
                          new List<String>{'Use YYYY-MM-DD'});
            }
        }

        // MANAGER FILTER - Auto-search ALL 12 hierarchy levels
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
                    return err('NO_MATCHING_AES', 
                        'No AEs found for manager email: ' + request.managerEmail + '. Searched all 12 hierarchy levels in Learner_Profile__c (Emp_Mgt_Chain_Lvl_01_Nm__c through Emp_Mgt_Chain_Lvl_12_Nm__c). This manager email may not exist in the system.', 
                        'managerEmail', 
                        'Valid manager email like sallen@salesforce.com', 
                        request.managerEmail,
                        new List<String>{'sallen@salesforce.com', 'mfitzgerald@salesforce.com', 'jshapiro@salesforce.com', 'mperrigo@salesforce.com'},
                        new List<String>{
                            '⚠️ Verify manager email is correct (must be exact match)',
                            '📧 Format must be: user@salesforce.com (e.g., "sallen@salesforce.com")',
                            '🔍 Try using ouName (e.g., "AMER ACC") or workLocationCountry (e.g., "United States") instead',
                            '💡 Ask user to provide correct manager email address if unsure'
                        });
                }
            } catch (Exception e) {
                System.debug('Error querying Learner Profiles by manager email: ' + e.getMessage());
                return err('MANAGER_QUERY_ERROR', 
                    'Database error while searching for AEs by manager email: ' + e.getMessage() + '. Manager email must be valid format (user@salesforce.com) and must exist in Learner_Profile__c.', 
                    'managerEmail', 
                    'Valid email format (user@salesforce.com)', 
                    request.managerEmail,
                    new List<String>{'sallen@salesforce.com', 'mfitzgerald@salesforce.com'},
                    new List<String>{
                        '📧 Ensure email format is correct: user@salesforce.com',
                        '🔍 Verify manager email exists in the org',
                        '💡 Ask user to confirm manager email spelling',
                        '⚡ Try ouName or workLocationCountry as alternative filter'
                    });
            }
        }

        // Build final WHERE clause
        if (!p.clauses.isEmpty()) {
            p.whereClause += ' AND ' + String.join(p.clauses, ' AND ');
        }

        return p;
    }

    /**
     * Builds data query using WhereParts with conditional field selection
     */
    public static String buildDataQuery(WhereParts whereParts, String objectApiName, Integer limitValue) {
        List<String> fields = new List<String>{
            'Id','Name','FULL_NAME__c','OU_NAME__c','WORK_LOCATION_COUNTRY__c',
            'PRIMARY_INDUSTRY__c','MACROSGMENT__c','EMP_MGR_NM__c','CreatedDate'
        };
        if (hasField(objectApiName, 'LEARNER_PROFILE_ID__c')) {
            fields.add('LEARNER_PROFILE_ID__c');
        }
        // Add amount, product, and account fields based on object type
        // Renewals fields
        if (hasField(objectApiName, 'RENEWAL_OPTY_AMT__c')) {
            fields.add('RENEWAL_OPTY_AMT__c');
        }
        if (hasField(objectApiName, 'RENEWAL_PROD_NM__c')) {
            fields.add('RENEWAL_PROD_NM__c');
        }
        if (hasField(objectApiName, 'RENEWAL_OPTY_NM__c')) {
            fields.add('RENEWAL_OPTY_NM__c');
        }
        if (hasField(objectApiName, 'RENEWAL_ACCT_NM__c')) {
            fields.add('RENEWAL_ACCT_NM__c');
        }
        // Cross-Sell fields (note: no amount field exists, only product and account)
        if (hasField(objectApiName, 'CROSS_SELL_NEXT_BEST_PRODUCT__c')) {
            fields.add('CROSS_SELL_NEXT_BEST_PRODUCT__c');
        }
        if (hasField(objectApiName, 'CROSS_SELL_ACCT_NM__c')) {
            fields.add('CROSS_SELL_ACCT_NM__c');
        }
        if (hasField(objectApiName, 'CROSS_SELL_ACCT_ID__c')) {
            fields.add('CROSS_SELL_ACCT_ID__c');
        }
        // Upsell fields (note: no amount field exists, only sub-category and account)
        if (hasField(objectApiName, 'UPSELL_SUB_CATEGORY__c')) {
            fields.add('UPSELL_SUB_CATEGORY__c');
        }
        if (hasField(objectApiName, 'UPSELL_ACCT_NM__c')) {
            fields.add('UPSELL_ACCT_NM__c');
        }
        if (hasField(objectApiName, 'UPSELL_ACCT_ID__c')) {
            fields.add('UPSELL_ACCT_ID__c');
        }
        
        String baseSelect = 'SELECT ' + String.join(fields, ', ') +
                          ' FROM ' + objectApiName + ' ' + whereParts.whereClause +
                          ' ORDER BY CreatedDate DESC, Id ASC';
        if (limitValue != null && limitValue > 0) {
            baseSelect += ' LIMIT ' + limitValue;
        }
        return baseSelect;
    }

    /**
     * Gets total count using same WHERE clause
     */
    public static Integer getTotalCount(WhereParts whereParts, String objectApiName) {
        String countQuery = 'SELECT COUNT() FROM ' + objectApiName + ' ' + whereParts.whereClause;
        return Database.countQuery(countQuery);
    }

    /**
     * Collects applied filters for response
     */
    public static String collectAppliedFilters(ABAgentFuturePipeAnalysisHandlerV5.FuturePipeAnalysisRequest request) {
        List<String> filters = new List<String>();
        if (String.isNotBlank(request.ouName)) filters.add('OU:' + request.ouName);
        if (String.isNotBlank(request.workLocationCountry)) filters.add('Country:' + request.workLocationCountry);
        if (String.isNotBlank(request.aeName)) filters.add('AE:' + request.aeName);
        if (String.isNotBlank(request.aeIndustry)) filters.add('Industry:' + request.aeIndustry);
        if (String.isNotBlank(request.aeMacroSegment)) filters.add('Segment:' + request.aeMacroSegment);
        if (String.isNotBlank(request.aeManagerName)) filters.add('Manager:' + request.aeManagerName);
        if (String.isNotBlank(request.startDate)) filters.add('StartDate:' + request.startDate);
        if (String.isNotBlank(request.endDate)) filters.add('EndDate:' + request.endDate);
        return String.join(filters, ',');
    }

    /**
     * Chunks strings into smaller lists for SOQL IN clauses
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
     * Fetches Learner Profile data by IDs (eliminates collision risk from Name-based joins)
     */
    public static Map<String, SObject> getLearnerProfileDataByIds(Set<String> learnerProfileIds) {
        Map<String, SObject> learnerProfiles = new Map<String, SObject>();

        if (learnerProfileIds.isEmpty()) {
            return learnerProfiles;
        }

        try {
            String baseQuery = 'SELECT Id, Name, WORK_LOCATION_COUNTRY__c, OU_NAME__c, ' +
                              'Emp_Mgt_Chain_Lvl_01_Nm__c, Emp_Mgt_Chain_Lvl_02_Nm__c, ' +
                              'Emp_Mgt_Chain_Lvl_03_Nm__c, Emp_Mgt_Chain_Lvl_04_Nm__c, ' +
                              'Emp_Mgt_Chain_Lvl_05_Nm__c, Emp_Mgt_Chain_Lvl_06_Nm__c, ' +
                              'Emp_Mgt_Chain_Lvl_07_Nm__c, Emp_Mgt_Chain_Lvl_08_Nm__c, ' +
                              'Emp_Mgt_Chain_Lvl_09_Nm__c, Emp_Mgt_Chain_Lvl_10_Nm__c, ' +
                              'Emp_Mgt_Chain_Lvl_11_Nm__c, Emp_Mgt_Chain_Lvl_12_Nm__c ' +
                              'FROM Learner_Profile__c WHERE Id IN (';

            // Chunk large IN lists to avoid SOQL character limits
            for (List<String> chunk : chunkStrings(learnerProfileIds, 1000)) {
                String lpQuery = baseQuery + String.join(chunk, ',') + ')';
                List<SObject> lpRecords = Database.query(lpQuery);
                for (SObject lpRecord : lpRecords) {
                    String id = (String) lpRecord.get('Id');
                    if (String.isNotBlank(id)) {
                        learnerProfiles.put(id, lpRecord);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error querying Learner_Profile__c by IDs: ' + e.getMessage());
        }

        return learnerProfiles;
    }

    /**
     * Legacy method - kept for backward compatibility but should not be used
     * WARNING: This method has collision risks when multiple Learner Profiles have the same Name
     * Use getLearnerProfileDataByIds instead to avoid Name collision risks
     */
    public static Map<String, SObject> getLearnerProfileData(Set<String> aeNames) {
        // This method should not be used as it has collision risks
        System.debug('ERROR: getLearnerProfileData method with Name-based joins should not be used - use getLearnerProfileDataByIds instead');
        
        // Return empty map to avoid data corruption
        Map<String, SObject> emptyResult = new Map<String, SObject>();
        
        // Log warning for debugging
        System.debug('WARNING: Attempted to use Name-based Learner Profile lookup. This can cause data collisions.');
        
        return emptyResult;
    }

    /**
     * Builds a map representation of a record with Learner Profile data
     */
    public static Map<String, Object> buildRecordMap(SObject record, SObject learnerProfile) {
        Map<String, Object> recordMap = new Map<String, Object>();

        recordMap.put('id', record.Id);
        recordMap.put('name', record.get('Name'));
        recordMap.put('aeName', record.get('FULL_NAME__c'));
        recordMap.put('ouName', record.get('OU_NAME__c'));
        recordMap.put('workLocationCountry', record.get('WORK_LOCATION_COUNTRY__c'));
        recordMap.put('industry', record.get('PRIMARY_INDUSTRY__c'));
        recordMap.put('macroSegment', record.get('MACROSGMENT__c'));
        recordMap.put('managerName', record.get('EMP_MGR_NM__c'));

        // Add Learner Profile fields if available
        if (learnerProfile != null) {
            recordMap.put('learnerProfileId', learnerProfile.Id);
            recordMap.put('lpWorkLocationCountry', learnerProfile.get('WORK_LOCATION_COUNTRY__c'));
            recordMap.put('lpOuName', learnerProfile.get('OU_NAME__c'));
            recordMap.put('lpMgtChain01', learnerProfile.get('Emp_Mgt_Chain_Lvl_01_Nm__c'));
            recordMap.put('lpMgtChain02', learnerProfile.get('Emp_Mgt_Chain_Lvl_02_Nm__c'));
            recordMap.put('lpMgtChain03', learnerProfile.get('Emp_Mgt_Chain_Lvl_03_Nm__c'));
            recordMap.put('lpMgtChain04', learnerProfile.get('Emp_Mgt_Chain_Lvl_04_Nm__c'));
            recordMap.put('lpMgtChain05', learnerProfile.get('Emp_Mgt_Chain_Lvl_05_Nm__c'));
            recordMap.put('lpMgtChain06', learnerProfile.get('Emp_Mgt_Chain_Lvl_06_Nm__c'));
            recordMap.put('lpMgtChain07', learnerProfile.get('Emp_Mgt_Chain_Lvl_07_Nm__c'));
            recordMap.put('lpMgtChain08', learnerProfile.get('Emp_Mgt_Chain_Lvl_08_Nm__c'));
            recordMap.put('lpMgtChain09', learnerProfile.get('Emp_Mgt_Chain_Lvl_09_Nm__c'));
            recordMap.put('lpMgtChain10', learnerProfile.get('Emp_Mgt_Chain_Lvl_10_Nm__c'));
            recordMap.put('lpMgtChain11', learnerProfile.get('Emp_Mgt_Chain_Lvl_11_Nm__c'));
            recordMap.put('lpMgtChain12', learnerProfile.get('Emp_Mgt_Chain_Lvl_12_Nm__c'));
        }

        return recordMap;
    }

    /**
     * Builds lightweight records for aggregation when in summaryOnly mode
     * Only includes essential fields needed for aggregation (industry, macroSegment, product, amount, country)
     */
    private static List<Map<String, Object>> buildLightweightRecords(List<SObject> records, Map<String, SObject> learnerProfiles) {
        List<Map<String, Object>> lightweightRecords = new List<Map<String, Object>>();
        
        for (SObject record : records) {
            Map<String, Object> lightRec = new Map<String, Object>();
            
            // Essential fields for aggregation
            String lpId = (String) record.get('LEARNER_PROFILE_ID__c');
            SObject learnerProfile = String.isNotBlank(lpId) ? learnerProfiles.get(lpId) : null;
            
            // Amount field - note: Cross-Sell and Upsell don't have amount fields
            Object amountValue = null;
            if (record.getSObjectType().getDescribe().getName() == 'Agent_Renewals__c') {
                amountValue = record.get('RENEWAL_OPTY_AMT__c');
            }
            // Cross-Sell and Upsell objects don't have amount fields - leave as null
            lightRec.put('amount', amountValue);
            
            // Product name
            Object productName = null;
            if (record.getSObjectType().getDescribe().getName() == 'Agent_Renewals__c') {
                productName = record.get('RENEWAL_PROD_NM__c');
            } else if (record.getSObjectType().getDescribe().getName() == 'Agent_Cross_Sell__c') {
                productName = record.get('CROSS_SELL_NEXT_BEST_PRODUCT__c');
            } else if (record.getSObjectType().getDescribe().getName() == 'Agent_Upsell__c') {
                productName = record.get('UPSELL_SUB_CATEGORY__c');
            }
            lightRec.put('product', new Map<String, Object>{'name' => productName});
            
            // Mandatory dimensions
            lightRec.put('industry', record.get('PRIMARY_INDUSTRY__c'));
            lightRec.put('macroSegment', record.get('MACROSGMENT__c'));
            
            // Country from learner profile or fallback
            if (learnerProfile != null) {
                lightRec.put('country', learnerProfile.get('WORK_LOCATION_COUNTRY__c'));
            } else {
                lightRec.put('country', record.get('WORK_LOCATION_COUNTRY__c'));
            }
            
            lightweightRecords.add(lightRec);
        }
        
        return lightweightRecords;
    }

    /**
     * Builds a clean, focused map representation of a record
     * Always includes essential fields: id, pipeType, learnerProfileId, amount, product{family,name,sku}, industry, segment, vertical, country
     * Note: includeFieldsCsv and verbose removed - only essential fields returned
     */
    public static Map<String, Object> buildRecordMapSafe(SObject record, SObject learnerProfile, 
                                                         ABAgentFuturePipeAnalysisHandlerV5.FuturePipeAnalysisRequest request) {
        Map<String, Object> recordMap = new Map<String, Object>();

        // Always include the 8 essential fields: id, pipeType, learnerProfileId, amount, product, industry, segment, vertical
        recordMap.put('id', record.Id);
        recordMap.put('pipeType', request.analysisType);
        
        // Learner Profile ID (always include if available)
        if (learnerProfile != null) {
            recordMap.put('learnerProfileId', learnerProfile.Id);
        } else {
            recordMap.put('learnerProfileId', null);
        }
        
        // Amount field - note: Cross-Sell and Upsell don't have amount fields
        Object amountValue = null;
        if (record.getSObjectType().getDescribe().getName() == 'Agent_Renewals__c') {
            amountValue = record.get('RENEWAL_OPTY_AMT__c');
        }
        // Cross-Sell and Upsell objects don't have amount fields - leave as null
        recordMap.put('amount', amountValue);
        
        // Product object - get from actual fields based on object type
        Map<String, Object> product = new Map<String, Object>();
        product.put('family', null); // No family field found in schema
        product.put('sku', null);    // No SKU field found in schema
        
        Object productName = null;
        if (record.getSObjectType().getDescribe().getName() == 'Agent_Renewals__c') {
            productName = record.get('RENEWAL_PROD_NM__c');
        } else if (record.getSObjectType().getDescribe().getName() == 'Agent_Cross_Sell__c') {
            productName = record.get('CROSS_SELL_NEXT_BEST_PRODUCT__c');
        } else if (record.getSObjectType().getDescribe().getName() == 'Agent_Upsell__c') {
            productName = record.get('UPSELL_SUB_CATEGORY__c');
        }
        product.put('name', productName);
        recordMap.put('product', product);
        
        // Account/Customer name - get from actual fields based on object type
        Object accountName = null;
        if (record.getSObjectType().getDescribe().getName() == 'Agent_Renewals__c') {
            accountName = record.get('RENEWAL_ACCT_NM__c');
        } else if (record.getSObjectType().getDescribe().getName() == 'Agent_Cross_Sell__c') {
            accountName = record.get('CROSS_SELL_ACCT_NM__c');
        } else if (record.getSObjectType().getDescribe().getName() == 'Agent_Upsell__c') {
            accountName = record.get('UPSELL_ACCT_NM__c');
        }
        recordMap.put('customerName', accountName); // Customer/Account name
        
        // Industry, Segment, and Vertical - always include these critical context fields
        recordMap.put('industry', record.get('PRIMARY_INDUSTRY__c'));
        recordMap.put('segment', record.get('MACROSGMENT__c'));
        recordMap.put('vertical', record.get('PRIMARY_INDUSTRY__c')); // Using industry as vertical for now
        
        // Country from learner profile (mandatory dimension)
        if (learnerProfile != null) {
            recordMap.put('country', learnerProfile.get('WORK_LOCATION_COUNTRY__c'));
        } else {
            recordMap.put('country', record.get('WORK_LOCATION_COUNTRY__c')); // Fallback to record country
        }

        // Note: Optional fields (ae, managers, lpChain, location, emails, createdDate) removed for simplicity
        // Only essential 8 fields are returned: id, pipeType, learnerProfileId, amount, product, industry, segment, vertical, country

        return recordMap;
    }

    // Note: parseRequestedFields method removed - includeFieldsCsv, verbose, agentHints no longer supported for simplicity

    /**
     * Builds embedded aggregation summary with mandatory and optional dimensions
     */
    public static Map<String, Object> buildEmbeddedAggregation(List<Map<String, Object>> results, 
                                                               ABAgentFuturePipeAnalysisHandlerV5.FuturePipeAnalysisRequest request, 
                                                               String analysisType) {
        Map<String, Object> summary = new Map<String, Object>();
        
        if (results.isEmpty()) {
            summary.put('totalRecords', 0);
            summary.put('message', 'No records found matching the criteria');
            return summary;
        }
        
        // Calculate totals
        Decimal totalAmount = 0;
        Integer totalCount = results.size();
        
        for (Map<String, Object> record : results) {
            Object amountValue = record.get('amount');
            if (amountValue != null && amountValue instanceof Decimal) {
                totalAmount += (Decimal) amountValue;
            }
        }
        
        // Build totals section
        Map<String, Object> totals = new Map<String, Object>();
        totals.put('total_amount', totalAmount);
        totals.put('total_count', totalCount);
        if (analysisType == 'RENEWALS' && totalCount > 0) {
            totals.put('average_amount', totalAmount / totalCount);
        }
        summary.put('totals', totals);
        
        // Always include mandatory dimensions: industry, macroSegment, product.name, country
        summary.put('by_industry', aggregateByDimension(results, 'industry', analysisType));
        summary.put('by_macrosegment', aggregateByDimension(results, 'macroSegment', analysisType));
        summary.put('by_product', aggregateByDimension(results, 'product.name', analysisType));
        summary.put('by_country', aggregateByDimension(results, 'country', analysisType));
        
        // Note: Optional aggregations (by_ae, by_manager, by_location) removed for simplicity
        // Only standard aggregations by industry, segment, product, country included
        
        return summary;
    }
    
    /**
     * Aggregates records by a specific dimension
     */
    public static List<Map<String, Object>> aggregateByDimension(List<Map<String, Object>> results, 
                                                                  String dimension, 
                                                                  String analysisType) {
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
                agg.hasAmount = true;
            }
        }
        
        // Convert to list and sort by sum_amount descending
        List<Map<String, Object>> aggregatedList = new List<Map<String, Object>>();
        for (String key : aggregationMap.keySet()) {
            AggregationData agg = aggregationMap.get(key);
            Map<String, Object> aggRecord = new Map<String, Object>();
            aggRecord.put(dimension, key);
            aggRecord.put('count', agg.count);
            
            if (analysisType == 'RENEWALS' && agg.hasAmount) {
                aggRecord.put('sum_amount', agg.sumAmount);
                if (agg.count > 0) {
                    aggRecord.put('average_amount', agg.sumAmount / agg.count);
                }
            }
            
            aggregatedList.add(aggRecord);
        }
        
        // Sort by sum_amount descending (if available), otherwise by count descending
        aggregatedList.sort(new AggregationComparator());
        
        return aggregatedList;
    }
    
    /**
     * Gets nested value from record using dot notation
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
    
    // Note: parseOptionalDimensions and getManagerLevel methods removed - agentHints and managementChainLevel no longer supported
    
    /**
     * Helper class for aggregation data
     */
    private class AggregationData {
        public Integer count = 0;
        public Decimal sumAmount = 0;
        public Boolean hasAmount = false;
    }
    
    /**
     * Comparator for sorting aggregation results
     */
    private class AggregationComparator implements Comparator<Map<String, Object>> {
        public Integer compare(Map<String, Object> a, Map<String, Object> b) {
            // Try to compare by sum_amount first
            Object sumA = a.get('sum_amount');
            Object sumB = b.get('sum_amount');
            
            if (sumA instanceof Decimal && sumB instanceof Decimal) {
                Decimal decA = (Decimal) sumA;
                Decimal decB = (Decimal) sumB;
                if (decA > decB) return -1;
                if (decA < decB) return 1;
            }
            
            // Fall back to count comparison
            Integer countA = (Integer) a.get('count');
            Integer countB = (Integer) b.get('count');
            if (countA > countB) return -1;
            if (countA < countB) return 1;
            
            return 0;
        }
    }

    /**
     * Builds summary statistics from results (legacy method - kept for backward compatibility)
     */
    public static Map<String, Object> buildSummary(List<Map<String, Object>> results) {
        Map<String, Object> summary = new Map<String, Object>();
        
        summary.put('totalRecords', results.size());
        
        // Count unique values
        Set<String> uniqueAEs = new Set<String>();
        Set<String> uniqueOUs = new Set<String>();
        Set<String> uniqueCountries = new Set<String>();
        Set<String> uniqueIndustries = new Set<String>();
        Set<String> uniqueSegments = new Set<String>();
        
        for (Map<String, Object> record : results) {
            if (record.get('aeName') != null) uniqueAEs.add((String) record.get('aeName'));
            if (record.get('ouName') != null) uniqueOUs.add((String) record.get('ouName'));
            if (record.get('workLocationCountry') != null) uniqueCountries.add((String) record.get('workLocationCountry'));
            if (record.get('industry') != null) uniqueIndustries.add((String) record.get('industry'));
            if (record.get('macroSegment') != null) uniqueSegments.add((String) record.get('macroSegment'));
        }
        
        summary.put('uniqueAEs', uniqueAEs.size());
        summary.put('uniqueOUs', uniqueOUs.size());
        summary.put('uniqueCountries', uniqueCountries.size());
        summary.put('uniqueIndustries', uniqueIndustries.size());
        summary.put('uniqueSegments', uniqueSegments.size());
        
        return summary;
    }

    /**
     * Executes SOQL query with security enforcement
     */
    public static List<SObject> executeQuery(String query) {
        try {
            List<SObject> results = Database.query(query);
            // Apply security stripping
            return Security.stripInaccessible(AccessType.READABLE, results).getRecords();
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, 'SOQL Query Error: ' + qe.getMessage());
            throw qe;
        } catch (SecurityException se) {
            System.debug(LoggingLevel.ERROR, 'Security Error: ' + se.getMessage());
            throw se;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Query execution error: ' + e.getMessage());
            throw new QueryException('Failed to execute future pipe query: ' + e.getMessage());
        }
    }

    /* ---------- Sample helpers ---------- */

    public static List<String> sampleOUs(Integer cap) {
        try {
            List<AggregateResult> results = Database.query('SELECT ou_name__c FROM Agent_Renewals__c WHERE ou_name__c != null GROUP BY ou_name__c LIMIT ' + cap);
            List<String> samples = new List<String>();
            for (AggregateResult ar : results) {
                String ou = String.valueOf(ar.get('ou_name__c'));
                if (String.isNotBlank(ou)) samples.add(ou);
            }
            // If no data found, return common OU examples
            if (samples.isEmpty()) {
                return new List<String>{'SMB - AMER SMB', 'AMER ACC', 'AMER REG', 'PubSec+.Org', 'North Asia'};
            }
            return samples;
        } catch (Exception e) {
            System.debug('Error getting OU samples: ' + e.getMessage());
            return new List<String>{'SMB - AMER SMB', 'AMER ACC', 'AMER REG', 'PubSec+.Org', 'North Asia'};
        }
    }

    public static List<String> sampleCountries(Integer cap) {
        try {
            List<AggregateResult> results = Database.query('SELECT work_location_country__c FROM Agent_Renewals__c WHERE work_location_country__c != null GROUP BY work_location_country__c LIMIT ' + cap);
            List<String> samples = new List<String>();
            for (AggregateResult ar : results) {
                String country = String.valueOf(ar.get('work_location_country__c'));
                if (String.isNotBlank(country)) samples.add(country);
            }
            // If no data found, return common country examples
            if (samples.isEmpty()) {
                return new List<String>{'US', 'Ireland', 'Japan', 'Canada', 'Australia'};
            }
            return samples;
        } catch (Exception e) {
            System.debug('Error getting country samples: ' + e.getMessage());
            return new List<String>{'US', 'Ireland', 'Japan', 'Canada', 'Australia'};
        }
    }
}