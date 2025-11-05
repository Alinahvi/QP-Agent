/**
 * @description EOA Feedback Service - Business logic for creating agent feedback Work tickets
 * @author Ali Nahvi
 * @version 1.0
 * @date 2025-11-02
 * 
 * Business Context: Core service for FR Agent Feedback project (EOA). Creates Work items under
 * topic-specific Epics (QP Topic, Cohort Management) with intelligent routing and classification.
 * 
 * FEATURES:
 * - Comprehensive input validation with clear error messages
 * - Auto-routing to correct Epic based on feedback content keywords
 * - Auto-classification of issue types (Bug, Feature Gap, Enhancement, etc.)
 * - Severity-to-Priority mapping (LOW→P3, MEDIUM→P2, HIGH→P1, CRITICAL→P0)
 * - Rich error responses with agent_next_steps for self-correction
 * - Follows FR Agent best practices (JSON-first, no silent fixes)
 */
public with sharing class ANAgentEOAFeedbackService {
    
    // Constants - FR Agent Feedback Project Configuration
    private static final String PROJECT_NAME = 'FR Agent Feedback';
    private static final String QP_EPIC_NAME = 'QP Topic';
    private static final String COHORT_EPIC_NAME = 'Cohort Management';
    private static final String ASSIGNEE_NAME = 'Praveen Kumar';
    private static final Id ASSIGNEE_USER_ID = '005Hu00000Qs8ecIAB';
    
    // Required field defaults (from org validation rules)
    private static final Id DEFAULT_SCRUM_TEAM_ID = 'a4fHu000001d54cIAA'; // Agentforce Learning Transformation (GLS)
    private static final Id DEFAULT_PRODUCT_TAG_ID = 'a4SHu000004cT5QMAU'; // Agentforce Learning Transformation (GLS)
    
    // Validation constants
    private static final Integer MIN_FEEDBACK_LENGTH = 10;
    private static final Integer MAX_FEEDBACK_LENGTH = 32000;
    private static final Integer MAX_CONTEXT_LENGTH = 10000;
    
    // Valid picklist values (from org analysis)
    private static final Set<String> VALID_STATUS_VALUES = new Set<String>{
        'Closed', 'Never', 'New', 'In Progress', 'Waiting', 'Duplicate', 
        'QA In Progress', 'Open', 'Ready for Review', 'Skipped', 'Triaged'
    };
    
    private static final Set<String> VALID_TYPE_VALUES = new Set<String>{
        'User Story', 'Bug'
    };
    
    private static final Set<String> VALID_PRIORITY_VALUES = new Set<String>{
        'P0', 'P1', 'P2', 'P3'
    };
    
    // Cache for Project and Epic IDs to avoid repeated queries in bulk operations
    private static ProjectEpicIds cachedIds = null;
    
    /**
     * @description Main entry point - creates feedback ticket with validation and routing
     */
    public static String createFeedbackTicket(ANAgentEOAFeedbackHandler.FeedbackRequest req) {
        try {
            // Step 1: Validate required fields and permissions
            String validationError = validateRequest(req);
            if (validationError != null) {
                return validationError;
            }
            
            // Step 2: Normalize and validate optional parameters
            String agentTopic = normalizeAgentTopic(req.agentTopic);
            String issueType = normalizeIssueType(req.issueType);
            
            // Step 2b: Auto-detect severity from feedback text and conversation context
            String severityLevel = detectSeverityFromFeedback(req.feedbackText, req.conversationContext);
            
            // Validate normalized values (no longer validating severity since it's auto-detected)
            String paramError = validateNormalizedParams(agentTopic, issueType, req);
            if (paramError != null) {
                return paramError;
            }
            
            // Step 3: Lookup Project and Epic IDs (with caching)
            ProjectEpicIds ids = lookupProjectAndEpicIdsWithCache(agentTopic, req.feedbackText);
            if (ids.error != null) {
                return ids.error;
            }
            
            // Step 4: Determine Work field values
            WorkFieldValues fieldValues = determineWorkFieldValues(
                req, agentTopic, issueType, severityLevel, ids
            );
            
            // Step 5: Create Work record
            String createResult = createWorkRecord(fieldValues, req);
            
            return createResult;
            
        } catch (DmlException dmlEx) {
            return buildError(
                'DML_ERROR',
                'Failed to create Work record: ' + dmlEx.getDmlMessage(0),
                'database',
                'successful Work record creation',
                'DML error on line ' + dmlEx.getLineNumber(),
                null,
                new List<String>{
                    'DML Error Type: ' + dmlEx.getDmlType(0),
                    'Fields affected: ' + String.join(dmlEx.getDmlFieldNames(0), ', '),
                    'Check required fields on Work object',
                    'Verify Praveen Kumar user ID exists: ' + ASSIGNEE_USER_ID,
                    'Ensure FR Agent Feedback project and epics exist',
                    'Contact system administrator if issue persists'
                }
            );
        } catch (QueryException qe) {
            return buildError(
                'QUERY_ERROR',
                'Database query failed: ' + qe.getMessage(),
                'soql',
                'successful query execution',
                qe.getMessage(),
                null,
                new List<String>{
                    'Verify FR Agent Feedback project exists with name: ' + PROJECT_NAME,
                    'Verify epics exist: ' + QP_EPIC_NAME + ', ' + COHORT_EPIC_NAME,
                    'Run setup script: setup_fr_agent_feedback_project.apex',
                    'Check object accessibility (agf__PPM_Project__c, agf__ADM_Epic__c, agf__ADM_Work__c)'
                }
            );
        } catch (Exception e) {
            return buildError(
                'UNEXPECTED_ERROR',
                'Unexpected service error: ' + e.getMessage(),
                'service',
                'successful execution',
                e.getTypeName() + ' at line ' + e.getLineNumber(),
                null,
                new List<String>{
                    'Error type: ' + e.getTypeName(),
                    'Error message: ' + e.getMessage(),
                    'Stack trace: ' + e.getStackTraceString(),
                    'Retry the feedback submission',
                    'Contact support if error persists'
                }
            );
        }
    }
    
    /**
     * @description Validates required fields and checks permissions
     */
    private static String validateRequest(ANAgentEOAFeedbackHandler.FeedbackRequest req) {
        // Check object-level permissions first
        if (!FRPermissionGuard.hasCreate('agf__ADM_Work__c')) {
            return buildError(
                'INSUFFICIENT_ACCESS',
                'No create access to Work object (agf__ADM_Work__c)',
                'object_permission',
                'Create permission on agf__ADM_Work__c',
                'Read-only or no access',
                null,
                new List<String>{
                    'Contact system administrator to grant Create permission on agf__ADM_Work__c object',
                    'Verify running user has appropriate profile/permission set',
                    'This action requires Create access to submit feedback tickets'
                }
            );
        }
        
        if (!FRPermissionGuard.hasRead('agf__PPM_Project__c')) {
            return buildError(
                'INSUFFICIENT_ACCESS',
                'No read access to Project object (agf__PPM_Project__c)',
                'object_permission',
                'Read permission on agf__PPM_Project__c',
                'No access',
                null,
                new List<String>{
                    'Contact system administrator to grant Read permission on agf__PPM_Project__c object'
                }
            );
        }
        
        if (!FRPermissionGuard.hasRead('agf__ADM_Epic__c')) {
            return buildError(
                'INSUFFICIENT_ACCESS',
                'No read access to Epic object (agf__ADM_Epic__c)',
                'object_permission',
                'Read permission on agf__ADM_Epic__c',
                'No access',
                null,
                new List<String>{
                    'Contact system administrator to grant Read permission on agf__ADM_Epic__c object'
                }
            );
        }
        
        // Validate required field: feedbackText
        if (String.isBlank(req.feedbackText)) {
            return buildError(
                'INVALID_INPUT',
                'feedbackText is required and cannot be blank',
                'feedbackText',
                'non-empty string (minimum ' + MIN_FEEDBACK_LENGTH + ' characters)',
                'null or blank',
                new List<String>{
                    '"Search Content action returned no results when searching for Tableau courses"',
                    '"KPI Analysis failed with insufficient permissions error"',
                    '"Cohort creation needs ability to filter by job role"'
                },
                new List<String>{
                    'Provide a detailed description of the issue, gap, or feedback',
                    'Include what you were trying to do and what happened',
                    'Minimum length: ' + MIN_FEEDBACK_LENGTH + ' characters',
                    'Example: {"feedbackText": "The OpenPipe Analysis action failed when I tried to analyze Americas region data"}'
                }
            );
        }
        
        // Validate feedbackText length
        if (req.feedbackText.length() < MIN_FEEDBACK_LENGTH) {
            return buildError(
                'INVALID_INPUT',
                'feedbackText must be at least ' + MIN_FEEDBACK_LENGTH + ' characters',
                'feedbackText',
                'string with ' + MIN_FEEDBACK_LENGTH + '+ characters',
                req.feedbackText + ' (' + req.feedbackText.length() + ' chars)',
                new List<String>{
                    '"Search Content action failed with permission error when searching for Agentforce"',
                    '"The KPI Analysis returned incorrect data for Q4 2024"'
                },
                new List<String>{
                    'Expand the feedback with more details',
                    'Include context: what were you trying to do?',
                    'What happened vs. what you expected?',
                    'Current length: ' + req.feedbackText.length() + ' chars, minimum: ' + MIN_FEEDBACK_LENGTH
                }
            );
        }
        
        if (req.feedbackText.length() > MAX_FEEDBACK_LENGTH) {
            return buildError(
                'INVALID_INPUT',
                'feedbackText exceeds maximum length of ' + MAX_FEEDBACK_LENGTH + ' characters',
                'feedbackText',
                'string with maximum ' + MAX_FEEDBACK_LENGTH + ' characters',
                req.feedbackText.length() + ' characters',
                null,
                new List<String>{
                    'Shorten the feedback text to under ' + MAX_FEEDBACK_LENGTH + ' characters',
                    'Consider moving detailed context to conversationContext field',
                    'Current length: ' + req.feedbackText.length() + ', maximum: ' + MAX_FEEDBACK_LENGTH
                }
            );
        }
        
        // Validate optional field: conversationContext length
        if (String.isNotBlank(req.conversationContext) && req.conversationContext.length() > MAX_CONTEXT_LENGTH) {
            return buildError(
                'INVALID_INPUT',
                'conversationContext exceeds maximum length of ' + MAX_CONTEXT_LENGTH + ' characters',
                'conversationContext',
                'string with maximum ' + MAX_CONTEXT_LENGTH + ' characters',
                req.conversationContext.length() + ' characters',
                null,
                new List<String>{
                    'Truncate conversation context to most relevant portion',
                    'Keep under ' + MAX_CONTEXT_LENGTH + ' characters',
                    'Focus on the specific conversation that led to the issue',
                    'Current length: ' + req.conversationContext.length() + ', maximum: ' + MAX_CONTEXT_LENGTH
                }
            );
        }
        
        return null; // All validations passed
    }
    
    /**
     * @description Normalizes agentTopic parameter with validation
     */
    private static String normalizeAgentTopic(String input) {
        if (String.isBlank(input)) {
            return 'AUTO';
        }
        return input.toUpperCase().trim();
    }
    
    /**
     * @description Normalizes issueType parameter with validation
     */
    private static String normalizeIssueType(String input) {
        if (String.isBlank(input)) {
            return 'AUTO';
        }
        return input.toUpperCase().trim();
    }
    
    /**
     * @description Validates normalized parameters
     * Note: severityLevel is auto-detected and no longer requires normalization or user input
     */
    private static String validateNormalizedParams(String agentTopic, String issueType,
                                                   ANAgentEOAFeedbackHandler.FeedbackRequest req) {
        // Validate agentTopic
        Set<String> validTopics = new Set<String>{'QP', 'COHORT', 'AUTO'};
        if (!validTopics.contains(agentTopic)) {
            return buildError(
                'INVALID_INPUT',
                'agentTopic must be QP, COHORT, or AUTO',
                'agentTopic',
                'QP | COHORT | AUTO (case-insensitive)',
                req.agentTopic,
                new List<String>{
                    '"QP" - Routes to QP Topic epic (Search Content, Programs, OpenPipe, FuturePipe, KPI, Planning)',
                    '"COHORT" - Routes to Cohort Management epic (Audience Creation, Grouping)',
                    '"AUTO" - Auto-detects topic from feedback text (DEFAULT)'
                },
                new List<String>{
                    'Use "QP" for Quarterly Planning agent topics',
                    'Use "COHORT" for Cohort Management topics',
                    'Use "AUTO" or leave blank to let system auto-route',
                    'Case-insensitive: qp, QP, Qp all work',
                    'Example: {"agentTopic": "QP"} or {"agentTopic": "AUTO"}'
                }
            );
        }
        
        // Validate issueType
        Set<String> validIssueTypes = new Set<String>{'BUG', 'FEATURE_GAP', 'ENHANCEMENT', 'QUESTION', 'OTHER', 'AUTO'};
        if (!validIssueTypes.contains(issueType)) {
            return buildError(
                'INVALID_INPUT',
                'issueType must be BUG, FEATURE_GAP, ENHANCEMENT, QUESTION, OTHER, or AUTO',
                'issueType',
                'BUG | FEATURE_GAP | ENHANCEMENT | QUESTION | OTHER | AUTO (case-insensitive)',
                req.issueType,
                new List<String>{
                    '"BUG" - Functional error or broken behavior',
                    '"FEATURE_GAP" - Missing functionality or capability',
                    '"ENHANCEMENT" - Improvement to existing feature',
                    '"QUESTION" - Needs clarification or guidance',
                    '"OTHER" - Uncategorized feedback',
                    '"AUTO" - Let agent classify based on feedback (DEFAULT)'
                },
                new List<String>{
                    'Use "BUG" for errors and broken functionality',
                    'Use "FEATURE_GAP" for missing features',
                    'Use "AUTO" or leave blank to let system classify',
                    'Case-insensitive: bug, BUG, Bug all work',
                    'Example: {"issueType": "BUG"} or {"issueType": "FEATURE_GAP"}'
                }
            );
        }
        
        // Note: severityLevel is now auto-detected from feedback text, no validation needed
        
        return null; // All validations passed
    }
    
    /**
     * @description Looks up Project and Epic IDs with caching to avoid governor limits
     */
    private static ProjectEpicIds lookupProjectAndEpicIdsWithCache(String agentTopic, String feedbackText) {
        // Determine target epic name first
        String targetEpicName;
        if (agentTopic == 'AUTO') {
            targetEpicName = detectTopicFromFeedback(feedbackText);
        } else if (agentTopic == 'QP') {
            targetEpicName = QP_EPIC_NAME;
        } else if (agentTopic == 'COHORT') {
            targetEpicName = COHORT_EPIC_NAME;
        } else {
            targetEpicName = QP_EPIC_NAME; // Fallback
        }
        
        // Check cache first
        if (cachedIds != null && cachedIds.epicName == targetEpicName) {
            // Return cached IDs with updated routing decision
            ProjectEpicIds cached = new ProjectEpicIds();
            cached.projectId = cachedIds.projectId;
            cached.epicId = cachedIds.epicId;
            cached.projectName = cachedIds.projectName;
            cached.epicName = cachedIds.epicName;
            cached.routingDecision = 'Routed to ' + targetEpicName + ' based on ' + 
                (agentTopic == 'AUTO' ? 'keyword detection (cached)' : 'explicit agentTopic=' + agentTopic + ' (cached)');
            return cached;
        }
        
        // Not in cache, do lookup
        return lookupProjectAndEpicIds(agentTopic, feedbackText, targetEpicName);
    }
    
    /**
     * @description Looks up Project and Epic IDs with intelligent routing
     */
    private static ProjectEpicIds lookupProjectAndEpicIds(String agentTopic, String feedbackText, String targetEpicName) {
        ProjectEpicIds result = new ProjectEpicIds();
        
        try {
            // Lookup Project
            List<agf__PPM_Project__c> projects = [
                SELECT Id, Name 
                FROM agf__PPM_Project__c 
                WHERE Name = :PROJECT_NAME 
                LIMIT 1
            ];
            
            if (projects.isEmpty()) {
                result.error = buildError(
                    'CONFIGURATION_ERROR',
                    'FR Agent Feedback project not found',
                    'project',
                    'Project named "' + PROJECT_NAME + '"',
                    'No project found',
                    null,
                    new List<String>{
                        'The FR Agent Feedback project has not been set up yet',
                        'Run the setup script: setup_fr_agent_feedback_project.apex',
                        'Contact Praveen Kumar to initialize the feedback project',
                        'Expected project name (exact): "' + PROJECT_NAME + '"'
                    }
                );
                return result;
            }
            
            result.projectId = projects[0].Id;
            result.projectName = projects[0].Name;
            
            // Lookup Epic
            List<agf__ADM_Epic__c> epics = [
                SELECT Id, Name 
                FROM agf__ADM_Epic__c 
                WHERE agf__Project__c = :result.projectId 
                AND Name = :targetEpicName 
                LIMIT 1
            ];
            
            if (epics.isEmpty()) {
                result.error = buildError(
                    'CONFIGURATION_ERROR',
                    'Epic "' + targetEpicName + '" not found under FR Agent Feedback project',
                    'epic',
                    'Epic named "' + targetEpicName + '" under project "' + PROJECT_NAME + '"',
                    'No epic found',
                    null,
                    new List<String>{
                        'The Epic "' + targetEpicName + '" has not been created yet',
                        'Available epics should be: ' + QP_EPIC_NAME + ', ' + COHORT_EPIC_NAME,
                        'Run the setup script: setup_fr_agent_feedback_project.apex',
                        'Contact Praveen Kumar to initialize the epics',
                        'Detected topic routing: ' + agentTopic + ' → ' + targetEpicName
                    }
                );
                return result;
            }
            
            result.epicId = epics[0].Id;
            result.epicName = epics[0].Name;
            result.routingDecision = 'Routed to ' + targetEpicName + ' based on ' + 
                (agentTopic == 'AUTO' ? 'keyword detection' : 'explicit agentTopic=' + agentTopic);
            
            // Cache for subsequent calls
            cachedIds = result;
            
        } catch (QueryException qe) {
            result.error = buildError(
                'QUERY_ERROR',
                'Failed to query project/epic: ' + qe.getMessage(),
                'soql',
                'successful query',
                qe.getMessage(),
                null,
                new List<String>{
                    'Check if FR Agent Feedback project exists',
                    'Verify read permissions on agf__PPM_Project__c and agf__ADM_Epic__c',
                    'Run setup script if project/epics missing'
                }
            );
        }
        
        return result;
    }
    
    /**
     * @description Detects topic from feedback text using keyword matching
     */
    private static String detectTopicFromFeedback(String feedbackText) {
        String lowerFeedback = feedbackText.toLowerCase();
        
        // QP Topic keywords
        Set<String> qpKeywords = new Set<String>{
            'search content', 'search program', 'searchcontent', 'searchprogram',
            'openpipe', 'open pipe', 'futurepipe', 'future pipe',
            'kpi analysis', 'kpi', 'quarterly planning', 'planning',
            'engine', 'qp agent', 'quarterly'
        };
        
        // Cohort Management keywords
        Set<String> cohortKeywords = new Set<String>{
            'cohort', 'audience', 'grouping', 'audience creation',
            'audience grouping', 'cohort management', 'cohort agent'
        };
        
        // Check for Cohort keywords first (more specific)
        for (String keyword : cohortKeywords) {
            if (lowerFeedback.contains(keyword)) {
                return COHORT_EPIC_NAME;
            }
        }
        
        // Check for QP keywords
        for (String keyword : qpKeywords) {
            if (lowerFeedback.contains(keyword)) {
                return QP_EPIC_NAME;
            }
        }
        
        // Default to QP Topic if no keywords match
        return QP_EPIC_NAME;
    }
    
    /**
     * @description Determines Work field values based on inputs
     */
    private static WorkFieldValues determineWorkFieldValues(
        ANAgentEOAFeedbackHandler.FeedbackRequest req,
        String agentTopic, String issueType, String severityLevel,
        ProjectEpicIds ids
    ) {
        WorkFieldValues values = new WorkFieldValues();
        
        // Determine Work Type based on issue classification
        if (issueType == 'BUG') {
            values.workType = 'Bug';
        } else if (issueType == 'AUTO') {
            // Auto-detect from feedback text
            values.workType = detectWorkType(req.feedbackText);
        } else {
            // FEATURE_GAP, ENHANCEMENT, QUESTION, OTHER → User Story
            values.workType = 'User Story';
        }
        
        // Map severity to priority
        values.priority = mapSeverityToPriority(severityLevel);
        
        // Build Subject line
        String issueLabel = getIssueLabelForSubject(issueType, values.workType);
        String topicLabel = ids.epicName.replace(' Topic', ''); // "QP Topic" → "QP", "Cohort Management" → "Cohort Management"
        values.subject = 'FR Agent Feedback: ' + topicLabel + ' - ' + issueLabel;
        
        // Build Description
        values.description = buildWorkDescription(req, ids, severityLevel, issueType);
        
        // Set other fields
        values.status = 'New'; // Start in New status for triage
        values.assignee = ASSIGNEE_USER_ID; // Praveen Kumar
        values.epicId = ids.epicId;
        values.projectId = ids.projectId;
        
        return values;
    }
    
    /**
     * @description Auto-detects Work Type from feedback text
     */
    private static String detectWorkType(String feedbackText) {
        String lower = feedbackText.toLowerCase();
        
        // Bug indicators
        Set<String> bugIndicators = new Set<String>{
            'error', 'failed', 'broken', 'not working', 'doesn\'t work',
            'bug', 'issue', 'crash', 'exception', 'null pointer',
            'permission denied', 'access denied', 'insufficient'
        };
        
        for (String indicator : bugIndicators) {
            if (lower.contains(indicator)) {
                return 'Bug';
            }
        }
        
        // Default to User Story for feature requests
        return 'User Story';
    }
    
    /**
     * @description Auto-detects severity from feedback text and conversation context
     * Analyzes keywords to determine impact level (CRITICAL, HIGH, MEDIUM, LOW)
     */
    private static String detectSeverityFromFeedback(String feedbackText, String conversationContext) {
        String combined = (feedbackText + ' ' + (conversationContext != null ? conversationContext : '')).toLowerCase();
        
        // CRITICAL indicators - system-wide blockers, data issues
        Set<String> criticalIndicators = new Set<String>{
            'blocking', 'blocked', 'blocker', 'system down', 'completely broken',
            'all users', 'entire team', 'production down', 'data loss', 'data corruption',
            'security issue', 'critical bug', 'urgent', 'emergency', 'immediately',
            'cannot work', 'unusable', 'completely fails', 'total failure'
        };
        
        // HIGH indicators - significant impact, workaround may exist
        Set<String> highIndicators = new Set<String>{
            'major issue', 'significant problem', 'important feature',
            'high priority', 'severely impacts', 'serious bug',
            'affecting many', 'multiple users', 'core functionality',
            'broken for', 'fails for', 'doesn\'t work for'
        };
        
        // MEDIUM indicators - moderate impact
        Set<String> mediumIndicators = new Set<String>{
            'sometimes fails', 'intermittent', 'inconsistent',
            'workaround exists', 'moderate impact', 'some users',
            'could be better', 'improvement needed', 'enhancement',
            'feature request', 'would be nice'
        };
        
        // Check for CRITICAL keywords
        for (String indicator : criticalIndicators) {
            if (combined.contains(indicator)) {
                return 'CRITICAL';
            }
        }
        
        // Check for HIGH keywords
        for (String indicator : highIndicators) {
            if (combined.contains(indicator)) {
                return 'HIGH';
            }
        }
        
        // Check for MEDIUM keywords
        for (String indicator : mediumIndicators) {
            if (combined.contains(indicator)) {
                return 'MEDIUM';
            }
        }
        
        // Default to LOW for minor issues, questions, or unclear severity
        return 'LOW';
    }
    
    /**
     * @description Maps severity level to priority value
     */
    private static String mapSeverityToPriority(String severity) {
        if (severity == 'CRITICAL') return 'P0';
        if (severity == 'HIGH') return 'P1';
        if (severity == 'MEDIUM') return 'P2';
        return 'P3'; // LOW or default
    }
    
    /**
     * @description Gets human-readable label for subject line
     */
    private static String getIssueLabelForSubject(String issueType, String workType) {
        if (issueType == 'BUG') return 'Bug Report';
        if (issueType == 'FEATURE_GAP') return 'Feature Gap';
        if (issueType == 'ENHANCEMENT') return 'Enhancement Request';
        if (issueType == 'QUESTION') return 'Question';
        if (issueType == 'OTHER') return 'Feedback';
        
        // AUTO mode - use detected work type
        return (workType == 'Bug') ? 'Bug Report' : 'Feedback';
    }
    
    /**
     * @description Builds formatted description for Work item
     */
    private static String buildWorkDescription(ANAgentEOAFeedbackHandler.FeedbackRequest req,
                                               ProjectEpicIds ids, String severity, String issueType) {
        List<String> descParts = new List<String>();
        
        descParts.add('=== FR AGENT FEEDBACK ===');
        descParts.add('');
        descParts.add('FEEDBACK:');
        descParts.add(req.feedbackText);
        descParts.add('');
        descParts.add('METADATA:');
        descParts.add('  • Topic Area: ' + ids.epicName);
        descParts.add('  • Issue Classification: ' + (issueType == 'AUTO' ? 'Auto-detected' : issueType));
        descParts.add('  • Severity: ' + severity);
        descParts.add('  • Reporter: ' + (String.isNotBlank(req.reporterName) ? req.reporterName : UserInfo.getName()));
        descParts.add('  • Submitted: ' + Datetime.now().format('yyyy-MM-dd HH:mm:ss z'));
        
        if (String.isNotBlank(req.sessionId)) {
            descParts.add('  • Session ID: ' + req.sessionId);
        }
        
        if (String.isNotBlank(req.conversationContext)) {
            descParts.add('');
            descParts.add('CONVERSATION CONTEXT:');
            descParts.add(req.conversationContext);
        }
        
        descParts.add('');
        descParts.add('=== AUTO-CREATED BY FR AGENT FEEDBACK ACTION ===');
        
        return String.join(descParts, '\n');
    }
    
    /**
     * @description Creates Work record with all field mappings
     */
    private static String createWorkRecord(WorkFieldValues values, ANAgentEOAFeedbackHandler.FeedbackRequest req) {
        try {
            // Build Work record with all required fields
            agf__ADM_Work__c work = new agf__ADM_Work__c(
                agf__Subject__c = values.subject,
                agf__Details__c = values.description,
                agf__Type__c = values.workType,
                agf__Status__c = values.status,
                agf__Priority__c = values.priority,
                agf__Epic__c = values.epicId,
                Project__c = values.projectId,
                agf__Assignee__c = values.assignee,
                agf__Scrum_Team__c = DEFAULT_SCRUM_TEAM_ID,  // Required by validation rule
                agf__Product_Tag__c = DEFAULT_PRODUCT_TAG_ID  // Required by validation rule
            );
            
            // Insert Work record
            insert work;
            
            // Query back to get auto-number Name field
            agf__ADM_Work__c createdWork = [
                SELECT Id, Name, agf__Subject__c, agf__Type__c, agf__Status__c, 
                       agf__Priority__c, agf__Epic__r.Name, Project__r.Name
                FROM agf__ADM_Work__c 
                WHERE Id = :work.Id 
                LIMIT 1
            ];
            
            // Build success response
            Map<String, Object> data = new Map<String, Object>{
                'workId' => createdWork.Id,
                'workNumber' => createdWork.Name,
                'subject' => createdWork.agf__Subject__c,
                'type' => createdWork.agf__Type__c,
                'status' => createdWork.agf__Status__c,
                'priority' => createdWork.agf__Priority__c,
                'epicName' => createdWork.agf__Epic__r.Name,
                'projectName' => createdWork.Project__r.Name,
                'assignedTo' => ASSIGNEE_NAME,
                'reportedBy' => String.isNotBlank(req.reporterName) ? req.reporterName : UserInfo.getName(),
                'sessionId' => req.sessionId,
                'confirmationMessage' => 'Feedback ticket ' + createdWork.Name + ' created successfully and assigned to ' + ASSIGNEE_NAME + ' for triage.'
            };
            
            return buildSuccess(data);
            
        } catch (DmlException dmlEx) {
            throw dmlEx; // Re-throw to be caught by outer handler
        }
    }
    
    /**
     * @description Builds success response in JSON format
     */
    private static String buildSuccess(Object data) {
        Map<String, Object> response = new Map<String, Object>{
            'ok' => true,
            'data' => data,
            'error' => null
        };
        return JSON.serialize(response);
    }
    
    /**
     * @description Builds standardized error response with agent guidance
     * PUBLIC for use by Handler
     */
    public static String buildError(String code, String message, String field, 
                                    String expected, Object got,
                                    List<String> examples, List<String> nextSteps) {
        Map<String, Object> response = new Map<String, Object>{
            'ok' => false,
            'data' => null,
            'error' => new Map<String, Object>{
                'code' => code,
                'message' => message,
                'details' => new Map<String, Object>{
                    'field' => field,
                    'expected' => expected,
                    'got' => got,
                    'correct_examples' => (examples == null ? new List<String>() : examples),
                    'agent_next_steps' => (nextSteps == null ? new List<String>() : nextSteps)
                }
            }
        };
        return JSON.serialize(response);
    }
    
    // Helper classes
    
    private class ProjectEpicIds {
        public Id projectId;
        public Id epicId;
        public String projectName;
        public String epicName;
        public String routingDecision;
        public String error;
        
        public ProjectEpicIds() {
            this.error = null;
        }
    }
    
    private class WorkFieldValues {
        public String subject;
        public String description;
        public String workType;
        public String status;
        public String priority;
        public Id epicId;
        public Id projectId;
        public Id assignee;
    }
}

