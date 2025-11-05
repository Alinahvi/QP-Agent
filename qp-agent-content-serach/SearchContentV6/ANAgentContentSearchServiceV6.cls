/**
 * @description Content Search Service V6 - AgentCore Integration
 * @author Sales Operations Team
 * @version 6.0
 * @date 2025-11-04
 * 
 * IMPROVEMENTS FROM V5:
 * - ✅ AgentCore_PermissionValidator replaces FRPermissionGuard
 * - ✅ AgentCore_Exception for consistent error handling
 * - ✅ AgentCore_Constants for standardized codes/messages
 * - ✅ Removed FRSearchGuard dependency (inline validation)
 * - ✅ Removed FRResult dependency (uses consistent error structure)
 * - KEEP: V5's excellent intelligent routing (AUTO/ACT/CONSENSUS/BOTH)
 * - KEEP: V5's lifecycle management features (enrollment, CSAT, completion)
 * 
 * Business Context: Searches ACT Learning Content (Course__c, Asset__c, Curriculum__c) and 
 * Consensus Demo Videos (Agent_Consensu__c) with performance metrics for lifecycle management.
 */
public with sharing class ANAgentContentSearchServiceV6 {

    // Configuration constants
    private static final Integer DEFAULT_LIMIT = 100;
    private static final Integer MAX_LIMIT = 500;
    private static final Integer MIN_SEARCH_LENGTH = 2;
    
    // Lifecycle thresholds for ACT content analysis
    private static final Integer LOW_ENROLLMENT_THRESHOLD = 20;
    private static final Double LOW_COMPLETION_THRESHOLD = 25.0;
    private static final Double LOW_CSAT_THRESHOLD = 3.0;
    private static final Double HIGH_CSAT_THRESHOLD = 4.0;
    private static final Double HIGH_COMPLETION_THRESHOLD = 70.0;

    /* ---------- Error taxonomy helpers (JSON-first) ---------- */

    private static String ok(Object data) {
        Map<String, Object> res = new Map<String, Object>{
            'ok' => true,
            'data' => data,
            'error' => null
        };
        return JSON.serialize(res);
    }

    private static String err(String code, String message, String field, String expected, Object got,
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

    /* ---------- Validation (agent-visible) - AgentCore Integration ---------- */

    private static String validateRequest(ANAgentContentSearchHandlerV6.ContentSearchRequest r, Integer limitValue, Boolean includeInactiveValue) {
        // CRUD/FLS upfront for ACT objects using AgentCore
        AgentCore_PermissionValidator.PermissionResult coursePermCheck = AgentCore_PermissionValidator.validate(
            new AgentCore_PermissionValidator.PermissionRequest(
                Schema.Course__c.SObjectType, 
                'READ'
            ).addReadableField('Name')
             .addReadableField('Description__c')
             .addReadableField('Status__c')
        );
        
        if (!coursePermCheck.allowed) {
            return err(AgentCore_Constants.RESULT_CODE_PERMISSION_DENIED, 
                       'No read access to Course__c',
                       'object', 'Read on Course__c', null, null,
                       new List<String>{'Contact support to grant read permissions on Course__c object'});
        }
        
        AgentCore_PermissionValidator.PermissionResult assetPermCheck = AgentCore_PermissionValidator.validate(
            new AgentCore_PermissionValidator.PermissionRequest(
                Schema.Asset__c.SObjectType, 
                'READ'
            ).addReadableField('Name')
             .addReadableField('Description__c')
        );
        
        if (!assetPermCheck.allowed) {
            return err(AgentCore_Constants.RESULT_CODE_PERMISSION_DENIED, 
                       'No read access to Asset__c',
                       'object', 'Read on Asset__c', null, null,
                       new List<String>{'Contact support to grant read permissions on Asset__c object'});
        }
        
        AgentCore_PermissionValidator.PermissionResult curriculumPermCheck = AgentCore_PermissionValidator.validate(
            new AgentCore_PermissionValidator.PermissionRequest(
                Schema.Curriculum__c.SObjectType, 
                'READ'
            ).addReadableField('Name')
             .addReadableField('Description__c')
        );
        
        if (!curriculumPermCheck.allowed) {
            return err(AgentCore_Constants.RESULT_CODE_PERMISSION_DENIED, 
                       'No read access to Curriculum__c',
                       'object', 'Read on Curriculum__c', null, null,
                       new List<String>{'Contact support to grant read permissions on Curriculum__c object'});
        }
        
        AgentCore_PermissionValidator.PermissionResult consensusPermCheck = AgentCore_PermissionValidator.validate(
            new AgentCore_PermissionValidator.PermissionRequest(
                Schema.Agent_Consensu__c.SObjectType, 
                'READ'
            ).addReadableField('title__c')
             .addReadableField('isPublished__c')
        );
        
        if (!consensusPermCheck.allowed) {
            return err(AgentCore_Constants.RESULT_CODE_PERMISSION_DENIED, 
                       'No read access to Agent_Consensu__c',
                       'object', 'Read on Agent_Consensu__c', null, null,
                       new List<String>{'Contact support to grant read permissions on Agent_Consensu__c object'});
        }
        
        AgentCore_PermissionValidator.PermissionResult assignedCoursePermCheck = AgentCore_PermissionValidator.validate(
            new AgentCore_PermissionValidator.PermissionRequest(
                Schema.Assigned_Course__c.SObjectType, 
                'READ'
            ).addReadableField('Course__c')
             .addReadableField('Completed__c')
        );
        
        if (!assignedCoursePermCheck.allowed) {
            return err(AgentCore_Constants.RESULT_CODE_PERMISSION_DENIED, 
                       'No read access to Assigned_Course__c',
                       'object', 'Read on Assigned_Course__c', null, null,
                       new List<String>{'Contact support to grant read permissions on Assigned_Course__c for enrollment data'});
        }

        // Required fields
        if (String.isBlank(r.searchTerm)) {
            return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                       'searchTerm is required',
                       'searchTerm', 'non-empty string (minimum 2 characters)', 'blank', 
                       new List<String>{'Tableau', 'Einstein', 'Sales Cloud', 'MuleSoft'},
                       new List<String>{'Provide a product name or topic and retry'});
        }

        // Search term length - inline validation (removed FRSearchGuard dependency)
        if (r.searchTerm.length() < MIN_SEARCH_LENGTH) {
            return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                       'searchTerm must be >= 2 characters',
                       'searchTerm', 'length >= 2', r.searchTerm, 
                       new List<String>{'AI', 'Flow', 'Apex', 'Admin'},
                       new List<String>{'Provide longer search term and retry'});
        }

        // Content type validation - inline (removed FRSearchGuard dependency)
        if (String.isNotBlank(r.contentType)) {
            Set<String> validTypes = new Set<String>{'COURSE', 'ASSET', 'CURRICULUM', 'ALL'};
            String normalizedType = r.contentType.toUpperCase();
            if (!validTypes.contains(normalizedType)) {
                return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                           'contentType must be COURSE|ASSET|CURRICULUM|ALL',
                           'contentType', 'COURSE|ASSET|CURRICULUM|ALL', r.contentType, 
                           new List<String>{'COURSE', 'ASSET', 'CURRICULUM', 'ALL'},
                           new List<String>{'Use one of the valid content types', 'Case-insensitive but check spelling'});
            }
        }

        // Search mode validation - inline
        if (String.isNotBlank(r.searchMode)) {
            Set<String> validModes = new Set<String>{'AUTO', 'ACT', 'CONSENSUS', 'BOTH'};
            String normalizedMode = r.searchMode.toUpperCase();
            if (!validModes.contains(normalizedMode)) {
                return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                           'searchMode must be AUTO|ACT|CONSENSUS|BOTH',
                           'searchMode', 'AUTO|ACT|CONSENSUS|BOTH', r.searchMode, 
                           new List<String>{'AUTO', 'ACT', 'CONSENSUS', 'BOTH'},
                           new List<String>{'Use AUTO for intelligent routing', 'Use ACT for learning content only', 'Use CONSENSUS for demo videos only', 'Use BOTH for comprehensive search'});
            }
        }

        // Sort by validation - inline
        if (String.isNotBlank(r.sortBy)) {
            Set<String> validSort = new Set<String>{'ENROLLMENT', 'CSAT', 'COMPLETION', 'CREATED_DATE', 'DEFAULT'};
            String normalizedSort = r.sortBy.toUpperCase();
            if (!validSort.contains(normalizedSort)) {
                return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                           'sortBy must be ENROLLMENT|CSAT|COMPLETION|CREATED_DATE|DEFAULT',
                           'sortBy', 'ENROLLMENT|CSAT|COMPLETION|CREATED_DATE|DEFAULT', r.sortBy, 
                           new List<String>{'ENROLLMENT', 'CSAT', 'COMPLETION', 'CREATED_DATE', 'DEFAULT'},
                           new List<String>{'Use DEFAULT for lifecycle management (sorts by enrollment, then CSAT)', 'Use CSAT to find highest quality content', 'Use COMPLETION to find most engaging content'});
            }
        }

        // Sort order validation - inline
        if (String.isNotBlank(r.sortOrder)) {
            Set<String> validOrder = new Set<String>{'ASC', 'DESC'};
            String normalizedOrder = r.sortOrder.toUpperCase();
            if (!validOrder.contains(normalizedOrder)) {
                return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                           'sortOrder must be ASC|DESC',
                           'sortOrder', 'ASC|DESC', r.sortOrder, 
                           new List<String>{'ASC', 'DESC'},
                           new List<String>{'Use DESC (default) to show best performers first', 'Use ASC to find underperformers needing attention'});
            }
        }

        // Limit validation (using normalized value from handler) - inline
        if (limitValue != null && (limitValue < 1 || limitValue > MAX_LIMIT)) {
            return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                       'limit must be 1–500',
                       'limit', '1–500', limitValue, 
                       new List<String>{'20', '100', '500'}, 
                       new List<String>{'Use 100 (default) for standard analysis', 'Use 500 for comprehensive audit'});
        }

        // Date validation (ISO format YYYY-MM-DD) - inline validation
        if (String.isNotBlank(r.createdSince) && !isValidISODate(r.createdSince)) {
            return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                       'createdSince must be YYYY-MM-DD format',
                       'createdSince', 'YYYY-MM-DD', r.createdSince, 
                       new List<String>{'2024-08-01', '2024-01-01', '2025-10-01'},
                       new List<String>{'Use ISO date format like 2024-08-01', 'Format: YYYY-MM-DD (year-month-day with leading zeros)', 'Example: "since Aug 2024" = "2024-08-01"'});
        }
        if (String.isNotBlank(r.createdBefore) && !isValidISODate(r.createdBefore)) {
            return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                       'createdBefore must be YYYY-MM-DD format',
                       'createdBefore', 'YYYY-MM-DD', r.createdBefore, 
                       new List<String>{'2024-12-31', '2024-06-30', '2025-10-21'},
                       new List<String>{'Use ISO date format like 2024-12-31', 'Format: YYYY-MM-DD (year-month-day with leading zeros)'});
        }

        // Date range validation - ONLY if BOTH provided
        if (String.isNotBlank(r.createdSince) && String.isNotBlank(r.createdBefore)) {
            try {
                Date since = Date.valueOf(r.createdSince);
                Date before = Date.valueOf(r.createdBefore);
                if (before < since) {
                    return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                               'createdBefore must be >= createdSince',
                               'createdBefore', '>= ' + r.createdSince, r.createdBefore, 
                               null,
                               new List<String>{'Swap the dates', 'Use createdBefore >= createdSince'});
                }
            } catch (Exception ex) {
                return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                           'Invalid date format in createdSince or createdBefore',
                           'dates', 'YYYY-MM-DD', r.createdSince + ' to ' + r.createdBefore, 
                           new List<String>{'2024-08-01', '2024-12-31'},
                           new List<String>{'Verify both dates use YYYY-MM-DD format'});
            }
        }

        return null;
    }
    
    /**
     * @description Inline ISO date validation (replaces FRSearchGuard.isValidISODate)
     */
    private static Boolean isValidISODate(String dateStr) {
        if (String.isBlank(dateStr)) return false;
        
        // Check format: YYYY-MM-DD (10 characters)
        if (dateStr.length() != 10) return false;
        if (dateStr.substring(4, 5) != '-' || dateStr.substring(7, 8) != '-') return false;
        
        // Try to parse as Date
        try {
            Date.valueOf(dateStr);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /* ---------- Public entry (JSON-first, no silent fixes) ---------- */

    public static String search(ANAgentContentSearchHandlerV6.ContentSearchRequest r, Integer limitValue, Boolean includeInactiveValue) {
        try {
            // Validate request with normalized values
            String v = validateRequest(r, limitValue, includeInactiveValue);
            if (v != null) return v;

            // Normalize parameters with defaults
            String searchMode = String.isNotBlank(r.searchMode) ? r.searchMode.toUpperCase() : 'AUTO';
            String contentType = String.isNotBlank(r.contentType) ? r.contentType.toUpperCase() : 'ALL';
            String sortBy = String.isNotBlank(r.sortBy) ? r.sortBy.toUpperCase() : 'DEFAULT';
            String sortOrder = String.isNotBlank(r.sortOrder) ? r.sortOrder.toUpperCase() : 'DESC';
            
            // Use normalized values from handler (already converted from strings)
            Integer limitVal = (limitValue == null) ? DEFAULT_LIMIT : Math.min(Math.max(limitValue, 1), MAX_LIMIT);
            Boolean includeInactive = (includeInactiveValue == null) ? false : includeInactiveValue;
            String utterance = String.isNotBlank(r.userUtterance) ? r.userUtterance : r.searchTerm;

            // Route to appropriate search method
            if (searchMode == 'ACT') {
                return searchACTContent(r, contentType, sortBy, sortOrder, limitVal, includeInactive, 'Explicit ACT mode');
            } else if (searchMode == 'CONSENSUS') {
                return searchConsensusContent(r, limitVal, includeInactive, 'Explicit CONSENSUS mode');
            } else if (searchMode == 'BOTH') {
                return searchBothSources(r, contentType, sortBy, sortOrder, limitVal, includeInactive, 'Explicit BOTH mode');
            } else {
                // AUTO mode - intelligent routing
                return intelligentRouting(r, contentType, sortBy, sortOrder, limitVal, includeInactive, utterance);
            }

        } catch (QueryException qe) {
            return err(AgentCore_Constants.RESULT_CODE_RETRIEVE_FAILED, 
                       'Database query failed', 'soql', 'valid SOQL', qe.getMessage(), 
                       null,
                       new List<String>{'Reduce filters and retry', 'Check field API names', 'Contact support if persists'});
        } catch (AgentCore_Exception ace) {
            return err(AgentCore_Constants.RESULT_CODE_PERMISSION_DENIED, 
                       'Access denied', 'security', 'CRUD/FLS permitting read', ace.getMessage(), 
                       null,
                       new List<String>{'Request necessary permissions', 'Contact system administrator'});
        } catch (Exception e) {
            return err(AgentCore_Constants.RESULT_CODE_UNEXPECTED, 
                       'Unexpected system error', 'service', 'successful execution', e.getMessage(), 
                       null,
                       new List<String>{'Retry the search', 'Simplify search criteria', 'Escalate if error persists'});
        }
    }

    /* ---------- Intelligent Routing ---------- */

    private static String intelligentRouting(ANAgentContentSearchHandlerV6.ContentSearchRequest r,
                                            String contentType, String sortBy, String sortOrder, 
                                            Integer limitVal, Boolean includeInactive, String utterance) {
        Set<String> consensusKeywords = new Set<String>{
            'consensus', 'demo', 'video', 'presentation', 'demo pack', 'demo video'
        };
        Set<String> actKeywords = new Set<String>{
            'act', 'course', 'training', 'learning', 'curriculum', 'asset', 'content', 'certification'
        };
        
        Boolean isConsensusRequest = false;
        Boolean isACTRequest = false;
        String lowerUtterance = utterance.toLowerCase();
        
        // Check for Consensus keywords
        for (String keyword : consensusKeywords) {
            if (lowerUtterance.contains(keyword)) {
                isConsensusRequest = true;
                break;
            }
        }
        
        // Check for ACT keywords
        for (String keyword : actKeywords) {
            if (lowerUtterance.contains(keyword)) {
                isACTRequest = true;
                break;
            }
        }
        
        // Route based on keyword detection
        String routingDecision = '';
        if (isConsensusRequest && isACTRequest) {
            routingDecision = 'Auto-routed to BOTH sources (detected both ACT and Consensus keywords)';
            return searchBothSources(r, contentType, sortBy, sortOrder, limitVal, includeInactive, routingDecision);
        } else if (isConsensusRequest && !isACTRequest) {
            routingDecision = 'Auto-routed to Consensus (detected demo/video keywords)';
            return searchConsensusContent(r, limitVal, includeInactive, routingDecision);
        } else {
            // Default to ACT (whether ACT keywords present or not)
            routingDecision = isACTRequest 
                ? 'Auto-routed to ACT (detected course/training/content keywords)'
                : 'Auto-routed to ACT (default for content searches)';
            return searchACTContent(r, contentType, sortBy, sortOrder, limitVal, includeInactive, routingDecision);
        }
    }

    /* ---------- ACT Content Search ---------- */

    private static String searchACTContent(ANAgentContentSearchHandlerV6.ContentSearchRequest r,
                                          String contentType, String sortBy, String sortOrder,
                                          Integer limitVal, Boolean includeInactive, String routingDecision) {
        // Determine which objects to search
        List<String> objectsToSearch = new List<String>();
        if (contentType == 'ALL') {
            objectsToSearch.addAll(new List<String>{'Course__c', 'Asset__c', 'Curriculum__c'});
        } else if (contentType == 'COURSE') {
            objectsToSearch.add('Course__c');
        } else if (contentType == 'ASSET') {
            objectsToSearch.add('Asset__c');
        } else if (contentType == 'CURRICULUM') {
            objectsToSearch.add('Curriculum__c');
        }

        // Search each object
        List<ContentInfo> results = new List<ContentInfo>();
        for (String objectName : objectsToSearch) {
            List<ContentInfo> objectResults = searchACTObject(objectName, r, includeInactive, limitVal);
            if (objectResults != null) {
                results.addAll(objectResults);
            }
        }

        // Enrich with enrollment/completion data for courses
        enrichACTContent(results);

        // Sort results
        sortACTContent(results, sortBy, sortOrder);

        // Apply limit after sorting
        if (results.size() > limitVal) {
            List<ContentInfo> limitedResults = new List<ContentInfo>();
            for (Integer i = 0; i < limitVal; i++) {
                limitedResults.add(results[i]);
            }
            results = limitedResults;
        }

        // Build response
        return buildACTResponse(results, r, routingDecision, sortBy, sortOrder);
    }

    private static List<ContentInfo> searchACTObject(String objectName, 
                                                     ANAgentContentSearchHandlerV6.ContentSearchRequest r,
                                                     Boolean includeInactive, Integer limitVal) {
        List<ContentInfo> results = new List<ContentInfo>();
        
        try {
            // Check object accessibility
            if (!Schema.getGlobalDescribe().containsKey(objectName)) {
                System.debug('Object ' + objectName + ' not found');
                return results;
            }

            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            if (!objectType.getDescribe().isAccessible()) {
                System.debug('No read access to ' + objectName);
                return results;
            }

            // Build query
            String query = 'SELECT Id, Name, Description__c, Status__c, Share_Url__c, CreatedDate';
            if (objectName == 'Course__c') {
                query += ', CSAT__c';
            }
            query += ' FROM ' + objectName;
            query += ' WHERE (Name LIKE \'%' + String.escapeSingleQuotes(r.searchTerm) + '%\'';
            query += ' OR Description__c LIKE \'%' + String.escapeSingleQuotes(r.searchTerm) + '%\')';

            // Add status filter
            if (!includeInactive) {
                query += ' AND Status__c = \'Active\'';
            }

            // Add date range filter (flexible - either, both, or neither)
            if (String.isNotBlank(r.createdSince)) {
                query += ' AND CreatedDate >= ' + r.createdSince + 'T00:00:00Z';
            }
            if (String.isNotBlank(r.createdBefore)) {
                query += ' AND CreatedDate <= ' + r.createdBefore + 'T23:59:59Z';
            }

            query += ' ORDER BY CreatedDate DESC LIMIT ' + limitVal;

            // Execute query
            List<SObject> records = Database.query(query);
            
            // Apply security stripping
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
            records = decision.getRecords();
            
            // Convert to ContentInfo
            for (SObject record : records) {
                results.add(new ContentInfo(record, getTypeForObject(objectName)));
            }

        } catch (Exception e) {
            System.debug('Error searching ' + objectName + ': ' + e.getMessage());
        }

        return results;
    }

    private static void enrichACTContent(List<ContentInfo> content) {
        if (content == null || content.isEmpty()) {
            return;
        }
        
        try {
            // Collect Course IDs
            Set<String> courseIds = new Set<String>();
            for (ContentInfo info : content) {
                if (info.type == 'Course' && String.isNotBlank(info.id)) {
                    courseIds.add(info.id);
                }
            }
            
            if (courseIds.isEmpty()) {
                return;
            }
            
            // Get learner counts
            List<AggregateResult> learnerCounts = [
                SELECT Course__c, COUNT(Id) learnerCount
                FROM Assigned_Course__c 
                WHERE Course__c IN :courseIds 
                GROUP BY Course__c
            ];
            
            // Get completion counts
            List<AggregateResult> completionCounts = [
                SELECT Course__c, COUNT(Id) completionCount
                FROM Assigned_Course__c 
                WHERE Course__c IN :courseIds AND Completed__c = true
                GROUP BY Course__c
            ];
            
            // Build maps
            Map<String, Integer> learnerMap = new Map<String, Integer>();
            Map<String, Integer> completionMap = new Map<String, Integer>();
            
            for (AggregateResult ar : learnerCounts) {
                learnerMap.put((String)ar.get('Course__c'), (Integer)ar.get('learnerCount'));
            }
            
            for (AggregateResult ar : completionCounts) {
                completionMap.put((String)ar.get('Course__c'), (Integer)ar.get('completionCount'));
            }
            
            // Enrich content
            for (ContentInfo info : content) {
                if (info.type == 'Course' && learnerMap.containsKey(info.id)) {
                    info.enrollmentCount = learnerMap.get(info.id);
                    info.completionCount = completionMap.containsKey(info.id) ? completionMap.get(info.id) : 0;
                    
                    if (info.enrollmentCount > 0) {
                        info.completionRate = (Double.valueOf(info.completionCount) / info.enrollmentCount) * 100;
                    }
                }
            }
            
        } catch (Exception e) {
            System.debug('Error enriching ACT content: ' + e.getMessage());
        }
    }

    private static void sortACTContent(List<ContentInfo> content, String sortBy, String sortOrder) {
        if (content == null || content.isEmpty()) {
            return;
        }
        
        Boolean ascending = (sortOrder == 'ASC');
        
        if (sortBy == 'ENROLLMENT') {
            content.sort(new EnrollmentComparator(ascending));
        } else if (sortBy == 'CSAT') {
            content.sort(new CSATComparator(ascending));
        } else if (sortBy == 'COMPLETION') {
            content.sort(new CompletionComparator(ascending));
        } else if (sortBy == 'CREATED_DATE') {
            content.sort(new CreatedDateComparator(ascending));
        } else {
            // DEFAULT: Enrollment DESC, then CSAT DESC
            content.sort(new DefaultComparator());
        }
    }

    /* ---------- Consensus Content Search ---------- */

    private static String searchConsensusContent(ANAgentContentSearchHandlerV6.ContentSearchRequest r,
                                                Integer limitVal, Boolean includeInactive, String routingDecision) {
        List<ContentInfo> results = new List<ContentInfo>();
        
        try {
            // Build query
            String query = 'SELECT Id, title__c, description__c, isPublished__c, isArchived__c, previewLink__c, CreatedDate';
            query += ' FROM Agent_Consensu__c';
            query += ' WHERE title__c LIKE \'%' + String.escapeSingleQuotes(r.searchTerm) + '%\'';
            // Note: description__c is Long Text Area and NOT filterable in WHERE clause

            // Add status filter
            if (!includeInactive) {
                query += ' AND isPublished__c = TRUE AND isArchived__c = FALSE';
            }

            // Add date range filter (flexible - either, both, or neither)
            if (String.isNotBlank(r.createdSince)) {
                query += ' AND CreatedDate >= ' + r.createdSince + 'T00:00:00Z';
            }
            if (String.isNotBlank(r.createdBefore)) {
                query += ' AND CreatedDate <= ' + r.createdBefore + 'T23:59:59Z';
            }

            query += ' ORDER BY CreatedDate DESC LIMIT ' + limitVal;

            // Execute query
            List<SObject> records = Database.query(query);
            
            // Apply security stripping
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
            records = decision.getRecords();
            
            // Convert to ContentInfo
            for (SObject record : records) {
                results.add(new ContentInfo(record, 'Consensus'));
            }

        } catch (Exception e) {
            System.debug('Error searching Consensus: ' + e.getMessage());
        }

        // Build response
        return buildConsensusResponse(results, r, routingDecision);
    }

    /* ---------- Combined Search (BOTH sources) ---------- */

    private static String searchBothSources(ANAgentContentSearchHandlerV6.ContentSearchRequest r,
                                           String contentType, String sortBy, String sortOrder,
                                           Integer limitVal, Boolean includeInactive, String routingDecision) {
        // Search both sources
        Map<String, Object> actData = null;
        Map<String, Object> consensusData = null;
        
        try {
            // Parse ACT results
            String actJson = searchACTContent(r, contentType, sortBy, sortOrder, limitVal, includeInactive, 'ACT portion');
            Map<String, Object> actResponse = (Map<String, Object>)JSON.deserializeUntyped(actJson);
            if ((Boolean)actResponse.get('ok')) {
                actData = (Map<String, Object>)actResponse.get('data');
            }
        } catch (Exception e) {
            System.debug('Error in ACT search: ' + e.getMessage());
        }
        
        try {
            // Parse Consensus results
            String consensusJson = searchConsensusContent(r, limitVal, includeInactive, 'Consensus portion');
            Map<String, Object> consensusResponse = (Map<String, Object>)JSON.deserializeUntyped(consensusJson);
            if ((Boolean)consensusResponse.get('ok')) {
                consensusData = (Map<String, Object>)consensusResponse.get('data');
            }
        } catch (Exception e) {
            System.debug('Error in Consensus search: ' + e.getMessage());
        }
        
        // Build combined response
        Map<String, Object> combinedData = new Map<String, Object>{
            'analysisType' => 'CONTENT_SEARCH_COMBINED',
            'searchTerm' => r.searchTerm,
            'routing' => routingDecision,
            'act' => actData,
            'consensus' => consensusData
        };
        
        return ok(combinedData);
    }

    /* ---------- Response Builders ---------- */

    private static String buildACTResponse(List<ContentInfo> content,
                                          ANAgentContentSearchHandlerV6.ContentSearchRequest r,
                                          String routingDecision, String sortBy, String sortOrder) {
        // Check for empty results and provide helpful guidance
        if (content.isEmpty()) {
            List<String> troubleshootingSteps = new List<String>{
                'No content found matching your search criteria.',
                'Try a broader search term (e.g., "Sales" instead of "Sales Cloud Einstein")',
                'Remove contentType filter to search ALL types (COURSE, ASSET, CURRICULUM)',
                'Set includeInactive=true to include Draft/Archived content'
            };
            
            if (String.isNotBlank(r.createdSince) || String.isNotBlank(r.createdBefore)) {
                troubleshootingSteps.add('Try widening your date range or removing date filters');
            }
            
            return err(AgentCore_Constants.RESULT_CODE_NOT_FOUND,
                       'Search completed successfully but returned 0 results',
                       'searchCriteria',
                       'More flexible search terms or date ranges',
                       JSON.serialize(new Map<String, Object>{
                           'searchTerm' => r.searchTerm,
                           'contentType' => r.contentType,
                           'createdSince' => r.createdSince,
                           'createdBefore' => r.createdBefore
                       }),
                       new List<String>{
                           'CORRECT: {"searchTerm": "Tableau", "contentType": "COURSE", "createdSince": "2025-01-01"}'
                       },
                       troubleshootingSteps);
        }
        
        // Calculate summary metrics
        Integer totalEnrollment = 0;
        Integer totalCompletions = 0;
        Double totalCSAT = 0.0;
        Integer coursesWithData = 0;
        Integer coursesWithCSAT = 0;
        Integer lowEnrollmentCount = 0;
        Integer lowCompletionCount = 0;
        Integer lowCSATCount = 0;
        Integer highPerformers = 0;
        
        for (ContentInfo info : content) {
            if (info.type == 'Course' && info.enrollmentCount > 0) {
                coursesWithData++;
                totalEnrollment += info.enrollmentCount;
                totalCompletions += info.completionCount;
                
                if (info.csatScore != null && info.csatScore > 0) {
                    coursesWithCSAT++;
                    totalCSAT += info.csatScore;
                    if (info.csatScore < LOW_CSAT_THRESHOLD) {
                        lowCSATCount++;
                    }
                }
                
                if (info.enrollmentCount < LOW_ENROLLMENT_THRESHOLD) {
                    lowEnrollmentCount++;
                }
                if (info.completionRate < LOW_COMPLETION_THRESHOLD) {
                    lowCompletionCount++;
                }
                if (info.csatScore != null && info.csatScore >= HIGH_CSAT_THRESHOLD && 
                    info.completionRate >= HIGH_COMPLETION_THRESHOLD) {
                    highPerformers++;
                }
            }
        }
        
        Double avgCompletionRate = totalEnrollment > 0 ? (Double.valueOf(totalCompletions) / totalEnrollment) * 100 : 0.0;
        Double avgCSAT = coursesWithCSAT > 0 ? totalCSAT / coursesWithCSAT : 0.0;
        
        // Build summary
        Map<String, Object> summary = new Map<String, Object>{
            'totalContent' => content.size(),
            'totalEnrollment' => totalEnrollment,
            'totalCompletions' => totalCompletions,
            'avgCompletionRate' => Math.round(avgCompletionRate * 10) / 10.0,
            'avgCSAT' => Math.round(avgCSAT * 10) / 10.0,
            'highPerformers' => highPerformers,
            'lowEnrollment' => lowEnrollmentCount,
            'lowCompletion' => lowCompletionCount,
            'lowCSAT' => lowCSATCount
        };
        
        // Build records
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        for (ContentInfo info : content) {
            Map<String, Object> record = new Map<String, Object>{
                'id' => info.id,
                'name' => info.name,
                'type' => info.type,
                'status' => info.status,
                'link' => info.link,
                'createdDate' => info.createdDate,
                'description' => truncateDescription(info.description)
            };
            
            if (info.type == 'Course' && info.enrollmentCount > 0) {
                record.put('enrollment', info.enrollmentCount);
                record.put('completionRate', Math.round(info.completionRate * 10) / 10.0);
                record.put('csat', info.csatScore != null ? Math.round(info.csatScore * 10) / 10.0 : null);
            }
            
            records.add(record);
        }
        
        // Build response data
        Map<String, Object> data = new Map<String, Object>{
            'analysisType' => 'CONTENT_SEARCH_ACT',
            'searchTerm' => r.searchTerm,
            'routing' => routingDecision,
            'sortBy' => sortBy,
            'sortOrder' => sortOrder,
            'dateRange' => buildDateRangeLabel(r),
            'summary' => summary,
            'records' => records
        };
        
        return ok(data);
    }

    private static String buildConsensusResponse(List<ContentInfo> content,
                                                ANAgentContentSearchHandlerV6.ContentSearchRequest r,
                                                String routingDecision) {
        // Build summary
        Map<String, Object> summary = new Map<String, Object>{
            'totalVideos' => content.size(),
            'publishedVideos' => countPublished(content),
            'archivedVideos' => countArchived(content)
        };
        
        // Build records
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        for (ContentInfo info : content) {
            records.add(new Map<String, Object>{
                'id' => info.id,
                'name' => info.name,
                'type' => 'Consensus',
                'status' => info.status,
                'link' => info.link,
                'createdDate' => info.createdDate,
                'description' => truncateDescription(info.description),
                'isPublished' => info.isPublished,
                'isArchived' => info.isArchived
            });
        }
        
        // Build response data
        Map<String, Object> data = new Map<String, Object>{
            'analysisType' => 'CONTENT_SEARCH_CONSENSUS',
            'searchTerm' => r.searchTerm,
            'routing' => routingDecision,
            'dateRange' => buildDateRangeLabel(r),
            'summary' => summary,
            'records' => records
        };
        
        return ok(data);
    }

    /* ---------- Helper Methods ---------- */

    private static String buildDateRangeLabel(ANAgentContentSearchHandlerV6.ContentSearchRequest r) {
        if (String.isNotBlank(r.createdSince) && String.isNotBlank(r.createdBefore)) {
            return 'since ' + r.createdSince + ' until ' + r.createdBefore;
        } else if (String.isNotBlank(r.createdSince)) {
            return 'since ' + r.createdSince;
        } else if (String.isNotBlank(r.createdBefore)) {
            return 'before ' + r.createdBefore;
        } else {
            return 'all dates';
        }
    }

    private static String getTypeForObject(String objectName) {
        if (objectName == 'Course__c') return 'Course';
        if (objectName == 'Asset__c') return 'Asset';
        if (objectName == 'Curriculum__c') return 'Curriculum';
        return 'Unknown';
    }

    private static String truncateDescription(String description) {
        if (String.isBlank(description)) return '';
        if (description.length() <= 200) return description;
        return description.substring(0, 200) + '...';
    }

    private static Integer countPublished(List<ContentInfo> content) {
        Integer count = 0;
        for (ContentInfo info : content) {
            if (info.isPublished) count++;
        }
        return count;
    }

    private static Integer countArchived(List<ContentInfo> content) {
        Integer count = 0;
        for (ContentInfo info : content) {
            if (info.isArchived) count++;
        }
        return count;
    }

    /* ---------- Data Model ---------- */

    private class ContentInfo {
        public String id, name, description, type, status, link;
        public Datetime createdDate;
        public Double csatScore, completionRate;
        public Integer enrollmentCount, completionCount;
        public Boolean isPublished, isArchived;
        
        public ContentInfo(SObject record, String recordType) {
            this.id = record.Id;
            this.type = recordType;
            this.enrollmentCount = 0;
            this.completionCount = 0;
            this.completionRate = 0.0;
            this.csatScore = null;
            this.isPublished = false;
            this.isArchived = false;
            
            if (recordType == 'Consensus') {
                this.name = (String)record.get('title__c');
                this.description = (String)record.get('description__c');
                this.isPublished = (Boolean)record.get('isPublished__c');
                this.isArchived = (Boolean)record.get('isArchived__c');
                this.status = this.isPublished ? 'Published' : 'Draft';
                this.link = (String)record.get('previewLink__c');
                this.createdDate = (Datetime)record.get('CreatedDate');
            } else {
                // ACT content (Course, Asset, Curriculum)
                this.name = (String)record.get('Name');
                this.description = (String)record.get('Description__c');
                this.status = (String)record.get('Status__c');
                this.link = (String)record.get('Share_Url__c');
                this.createdDate = (Datetime)record.get('CreatedDate');
                
                if (recordType == 'Course' && record.get('CSAT__c') != null) {
                    this.csatScore = (Double)record.get('CSAT__c');
                }
            }
        }
    }

    /* ---------- Comparators ---------- */

    private class EnrollmentComparator implements Comparator<ContentInfo> {
        Boolean isAscending;
        public EnrollmentComparator(Boolean ascendingOrder) { this.isAscending = ascendingOrder; }
        public Integer compare(ContentInfo a, ContentInfo b) {
            if (a.enrollmentCount > b.enrollmentCount) return isAscending ? 1 : -1;
            if (a.enrollmentCount < b.enrollmentCount) return isAscending ? -1 : 1;
            return 0;
        }
    }

    private class CSATComparator implements Comparator<ContentInfo> {
        Boolean isAscending;
        public CSATComparator(Boolean ascendingOrder) { this.isAscending = ascendingOrder; }
        public Integer compare(ContentInfo a, ContentInfo b) {
            Double csatA = (a.csatScore == null) ? 0.0 : a.csatScore;
            Double csatB = (b.csatScore == null) ? 0.0 : b.csatScore;
            if (csatA > csatB) return isAscending ? 1 : -1;
            if (csatA < csatB) return isAscending ? -1 : 1;
            return 0;
        }
    }

    private class CompletionComparator implements Comparator<ContentInfo> {
        Boolean isAscending;
        public CompletionComparator(Boolean ascendingOrder) { this.isAscending = ascendingOrder; }
        public Integer compare(ContentInfo a, ContentInfo b) {
            if (a.completionRate > b.completionRate) return isAscending ? 1 : -1;
            if (a.completionRate < b.completionRate) return isAscending ? -1 : 1;
            return 0;
        }
    }

    private class CreatedDateComparator implements Comparator<ContentInfo> {
        Boolean isAscending;
        public CreatedDateComparator(Boolean ascendingOrder) { this.isAscending = ascendingOrder; }
        public Integer compare(ContentInfo a, ContentInfo b) {
            if (a.createdDate > b.createdDate) return isAscending ? 1 : -1;
            if (a.createdDate < b.createdDate) return isAscending ? -1 : 1;
            return 0;
        }
    }

    private class DefaultComparator implements Comparator<ContentInfo> {
        public Integer compare(ContentInfo a, ContentInfo b) {
            // Sort by Enrollment DESC, then CSAT DESC
            if (a.enrollmentCount > b.enrollmentCount) return -1;
            if (a.enrollmentCount < b.enrollmentCount) return 1;
            
            Double csatA = (a.csatScore == null) ? 0.0 : a.csatScore;
            Double csatB = (b.csatScore == null) ? 0.0 : b.csatScore;
            if (csatA > csatB) return -1;
            if (csatA < csatB) return 1;
            
            return 0;
        }
    }
}
