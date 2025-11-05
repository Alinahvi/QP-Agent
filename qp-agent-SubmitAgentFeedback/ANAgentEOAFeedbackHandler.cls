/**
 * @description EOA Feedback Handler - Creates Work tickets for Field Readiness Agent user feedback
 * @author Ali Nahvi
 * @version 1.0
 * @date 2025-11-02
 * 
 * Business Context: Enables users to report agent issues, feature gaps, and functional challenges
 * directly into the FR Agent Feedback project. Automatically routes feedback to the correct Epic
 * (QP Topic or Cohort Management) and creates Work items assigned to Praveen Kumar for triage.
 * 
 * IMPROVEMENTS:
 * - Comprehensive exception handling with agent-visible error messages
 * - Flexible input handling for optional fields
 * - Auto-routing based on topic keywords
 * - Detailed handler instructions with all valid picklist values
 * - Follows FR Agent best practices (Handler → Service pattern)
 */
public with sharing class ANAgentEOAFeedbackHandler {
    
    /**
     * @description Request wrapper for agent feedback with comprehensive field documentation
     */
    public class FeedbackRequest {
        @InvocableVariable(
            label='Feedback Text' 
            description='🎯 REQUIRED - User feedback, issue description, or feature gap report. Examples: "The Search Content action returned no results when searching for Agentforce courses created after Jan 2025", "KPI Analysis failed with insufficient permissions error", "Cohort creation doesnt support filtering by job role". Business Context: This is the core feedback content that will be captured in the Work item Description field. Be specific and include context about what the user was trying to do, what happened, and what they expected. Minimum 10 characters required.' 
            required=true
        )
        public String feedbackText;
        
        @InvocableVariable(
            label='Agent Topic' 
            description='🏷️ OPTIONAL - Which Field Readiness Agent topic area this feedback relates to. Valid values: "QP" (Quarterly Planning - includes Search Content, Search Programs, OpenPipe Analysis, FuturePipe Analysis, Engine, KPI Analysis), "COHORT" (Cohort Management - includes Audience Creation, Audience Grouping), "AUTO" (let system auto-detect from feedback text - DEFAULT). Business Context: AUTO mode intelligently routes to correct Epic based on keywords in feedback. Only specify explicitly if routing is unclear. Case-insensitive.' 
            required=false
        )
        public String agentTopic;
        
        @InvocableVariable(
            label='Issue Type' 
            description='🐛 OPTIONAL - Classification of the feedback. Valid values: "BUG" (functional issue/error), "FEATURE_GAP" (missing functionality), "ENHANCEMENT" (improvement to existing feature), "QUESTION" (needs clarification), "OTHER" (uncategorized), "AUTO" (let agent decide - DEFAULT). Business Context: AUTO mode analyzes feedback text to classify appropriately. BUG → Work Type=Bug, others → Work Type=User Story. Case-insensitive.' 
            required=false
        )
        public String issueType;
        
        @InvocableVariable(
            label='Session ID' 
            description='🔍 OPTIONAL - Agent session identifier for tracking and debugging. Format: any string identifier from the agent session. Examples: "session-abc123", "conv-2024-11-02-001". Business Context: Helps correlate feedback with specific agent conversations. Stored in Work item for reference. Leave blank if not available from session context.' 
            required=false
        )
        public String sessionId;
        
        @InvocableVariable(
            label='Conversation Context' 
            description='💬 OPTIONAL - Relevant conversation excerpt or transcript. Examples: excerpt of user queries and agent responses that led to the issue. Business Context: Provides additional context for troubleshooting and helps auto-detect severity level. Appended to Work item Description. Keep under 2000 characters for optimal display. The more context provided, the better the system can assess severity (CRITICAL/HIGH/MEDIUM/LOW) and priority (P0/P1/P2/P3). Leave blank if not needed.' 
            required=false
        )
        public String conversationContext;
        
        @InvocableVariable(
            label='Reporter Name' 
            description='👤 OPTIONAL - Name of person reporting the feedback. Examples: "John Smith", "Jane Doe". Business Context: Defaults to running user if not provided. Captured in Work item for attribution. Used to track who reported the issue.' 
            required=false
        )
        public String reporterName;
    }
    
    /**
     * @description Response wrapper - EXACTLY ONE output following FR Agent best practices
     */
    public class FeedbackResponse {
        @InvocableVariable(
            label='Feedback Submission Result'
            description='Returns {ok|error, data:{workId, workNumber, epicName, projectName, assignedTo, confirmationMessage}} in JSON format. On success: includes created Work item details and confirmation. On error: includes detailed error information with agent_next_steps for self-correction. Error codes: INVALID_INPUT, INSUFFICIENT_ACCESS, DML_ERROR, QUERY_ERROR, UNEXPECTED_ERROR.'
            required=true
        )
        public String result;
        
        public FeedbackResponse() {
            this.result = '';
        }
    }
    
    /**
     * @description Main invocable method for submitting agent feedback
     * Creates Work tickets in FR Agent Feedback project with auto-routing to correct Epic
     */
    @InvocableMethod(
        label='SubmitAgentFeedback'
        description='🎯 FR AGENT FEEDBACK SUBMISSION - Creates Work tickets for Field Readiness Agent user feedback, issues, and feature gaps. Auto-routes to QP Topic or Cohort Management Epic based on content. Auto-detects severity (CRITICAL/HIGH/MEDIUM/LOW) from feedback text and conversation context. All tickets assigned to Praveen Kumar for triage. Examples: {"feedbackText":"Search Content action completely broken, blocking all users"} OR {"feedbackText":"Need ability to filter cohorts by manager name","issueType":"FEATURE_GAP","agentTopic":"COHORT","conversationContext":"User tried multiple filters, none work"}. Returns JSON with created Work item details or detailed error with correction steps.'
    )
    public static List<FeedbackResponse> submitFeedback(List<FeedbackRequest> requests) {
        List<FeedbackResponse> responses = new List<FeedbackResponse>();
        
        // Validate input list
        if (requests == null || requests.isEmpty()) {
            FeedbackResponse err = new FeedbackResponse();
            err.result = ANAgentEOAFeedbackService.buildError(
                'INVALID_INPUT',
                'Request list cannot be null or empty',
                'requests',
                'List<FeedbackRequest> with at least one request',
                'null or empty',
                new List<String>{
                    '{"feedbackText": "Search Content returned no results for Tableau"}',
                    '{"feedbackText": "KPI Analysis needs quarter filter", "issueType": "FEATURE_GAP"}'
                },
                new List<String>{
                    'Provide at least one FeedbackRequest object',
                    'Ensure the request list is not null',
                    'Example: [{"feedbackText": "Issue description here"}]'
                }
            );
            responses.add(err);
            return responses;
        }
        
        // Process each request
        for (FeedbackRequest req : requests) {
            FeedbackResponse res = new FeedbackResponse();
            
            try {
                // Call service layer with the request
                res.result = ANAgentEOAFeedbackService.createFeedbackTicket(req);
                
            } catch (Exception e) {
                // Catch any unexpected errors from service layer
                res.result = ANAgentEOAFeedbackService.buildError(
                    'UNEXPECTED_ERROR',
                    'Unexpected error in feedback handler: ' + e.getMessage(),
                    'handler',
                    'successful execution',
                    e.getTypeName() + ': ' + e.getMessage(),
                    null,
                    new List<String>{
                        'Retry the feedback submission',
                        'If error persists, simplify the feedback text',
                        'Contact system administrator if issue continues',
                        'Stack trace: ' + e.getStackTraceString()
                    }
                );
            }
            
            responses.add(res);
        }
        
        return responses;
    }
}

