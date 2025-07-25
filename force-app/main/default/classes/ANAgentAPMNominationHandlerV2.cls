/**
 * @description Invocable Apex class that exposes APM nomination creation functionality to the APM Nomination Agent.
 *              This class acts as the entry point for creating nominations and calling the external APM API.
 * @author Gemini
 * @date 2025-01-27
 */
public with sharing class ANAgentAPMNominationHandlerV2 {
    /**
     * @description The request object for the APM nomination creation invocable method.
     */
    public class Request {
        @InvocableVariable(label='Offering Name' description='The name of the offering/course to be nominated.' required=true)
        public String offeringName;
        @InvocableVariable(label='Enablements IDs' description='Enablement event/program identifier (e.g., DATA_CLOUD_CERT_2025, AS_PATHWAYS_2025).' required=true)
        public String enablementsId;
        @InvocableVariable(label='Program Type' description='The type of program (e.g., Certification, Training, Workshop).' required=true)
        public String programType;
        @InvocableVariable(label='Enablement Tool' description='The tool or platform used for enablement (e.g., Trailhead, MyTrailhead, LMS).' required=true)
        public String enablementTool;
        @InvocableVariable(label='Start Date' description='The start date of the nomination period.' required=true)
        public Date startDate;
        @InvocableVariable(label='End Date' description='The end date of the nomination period.' required=true)
        public Date endDate;
        @InvocableVariable(label='Notes' description='Optional notes or additional information about the nomination.')
        public String notes;
        @InvocableVariable(label='Created User' description='The name of the user creating the nomination.' required=true)
        public String createdUser;
    }
    /**
     * @description The response object for the APM nomination creation invocable method.
     */
    public class Response {
        @InvocableVariable(label='Success' description='Indicates whether the nomination creation and API call were successful.')
        public Boolean success;
        @InvocableVariable(label='Message' description='Provides a message about the outcome, including API response status or error details.')
        public String message;
        public Response() {
            this.success = false;
            this.message = '';
        }
    }
    /**
     * @description The main invocable method that creates APM nominations and calls the external API.
     * @param requests A list of nomination requests, though typically only one is processed.
     * @return A list of nomination responses.
     */
    @InvocableMethod(label='AN Agent: Create APM Nomination V2' description='Creates a nomination in apm_nomination_v2__c and calls the external APM API to process the nomination.')
    public static List<Response> createNominationV2(List<Request> requests) {
        List<Response> responses = new List<Response>();
        if (requests == null || requests.isEmpty()) {
            Response errRes = new Response();
            errRes.message = 'No request provided.';
            responses.add(errRes);
            return responses;
        }
        for (Request req : requests) {
            Response res = new Response();
            try {
                // Validate required fields
                if (String.isBlank(req.offeringName)) {
                    res.message = 'Offering Name is required.';
                    responses.add(res);
                    continue;
                }
                if (String.isBlank(req.enablementsId)) {
                    res.message = 'Enablements IDs is required.';
                    responses.add(res);
                    continue;
                }
                if (String.isBlank(req.programType)) {
                    res.message = 'Program Type is required.';
                    responses.add(res);
                    continue;
                }
                if (String.isBlank(req.enablementTool)) {
                    res.message = 'Enablement Tool is required.';
                    responses.add(res);
                    continue;
                }
                if (req.startDate == null) {
                    res.message = 'Start Date is required.';
                    responses.add(res);
                    continue;
                }
                if (req.endDate == null) {
                    res.message = 'End Date is required.';
                    responses.add(res);
                    continue;
                }
                if (String.isBlank(req.createdUser)) {
                    res.message = 'Created User is required.';
                    responses.add(res);
                    continue;
                }
                // Create nomination input
                ANAgentAPMNominationServiceV2.NominationInput input = new ANAgentAPMNominationServiceV2.NominationInput();
                input.offeringName = req.offeringName;
                input.enablementsId = req.enablementsId;
                input.programType = req.programType;
                input.enablementTool = req.enablementTool;
                input.startDate = req.startDate;
                input.endDate = req.endDate;
                input.notes = req.notes;
                input.createdUser = req.createdUser;
                // Call service
                List<ANAgentAPMNominationServiceV2.NominationInput> inputList = new List<ANAgentAPMNominationServiceV2.NominationInput>{input};
                List<ANAgentAPMNominationServiceV2.NominationOutput> serviceResults = ANAgentAPMNominationServiceV2.invocableCreateV2(inputList);
                // Process response
                if (!serviceResults.isEmpty()) {
                    res.success = serviceResults[0].success;
                    res.message = serviceResults[0].message;
                    
                    // If successful, enhance the message with course details
                    if (res.success) {
                        Map<String, Object> courseDetails = ANAgentAPMNominationServiceV2.getCourseDetails(req.offeringName);
                        if (!courseDetails.isEmpty()) {
                            String enhancedMessage = buildEnhancedResponse(courseDetails, res.message);
                            res.message = enhancedMessage;
                        }
                    }
                } else {
                    res.success = false;
                    res.message = 'No response from service.';
                }
            } catch (Exception e) {
                res.success = false;
                res.message = 'An unexpected error occurred: ' + e.getMessage();
            }
            responses.add(res);
        }
        return responses;
    }
    
    /**
     * @description Builds an enhanced response message with course details and completion statistics
     * @param courseDetails Map containing course information and statistics
     * @param baseMessage The original success message
     * @return String Enhanced message with course details
     */
    private static String buildEnhancedResponse(Map<String, Object> courseDetails, String baseMessage) {
        String enhancedMessage = baseMessage + '\n\n';
        
        // Add course information
        if (courseDetails.containsKey('courseName')) {
            enhancedMessage += '📚 **Course Details:**\n';
            enhancedMessage += '• **Name:** ' + (String)courseDetails.get('courseName') + '\n';
            
            if (courseDetails.containsKey('description') && String.isNotBlank((String)courseDetails.get('description'))) {
                enhancedMessage += '• **Description:** ' + (String)courseDetails.get('description') + '\n';
            }
            
            if (courseDetails.containsKey('category') && String.isNotBlank((String)courseDetails.get('category'))) {
                enhancedMessage += '• **Category:** ' + (String)courseDetails.get('category') + '\n';
            }
            
            if (courseDetails.containsKey('status') && String.isNotBlank((String)courseDetails.get('status'))) {
                enhancedMessage += '• **Status:** ' + (String)courseDetails.get('status') + '\n';
            }
            
            enhancedMessage += '\n';
        }
        
        // Add completion statistics
        if (courseDetails.containsKey('completionCount') || courseDetails.containsKey('totalAssigned')) {
            enhancedMessage += '📊 **Completion Statistics:**\n';
            
            if (courseDetails.containsKey('completionCount')) {
                enhancedMessage += '• **Unique Learners Completed:** ' + courseDetails.get('completionCount') + '\n';
            }
            
            if (courseDetails.containsKey('totalAssigned')) {
                enhancedMessage += '• **Total Assigned:** ' + courseDetails.get('totalAssigned') + '\n';
            }
            
            if (courseDetails.containsKey('completionRate')) {
                enhancedMessage += '• **Completion Rate:** ' + courseDetails.get('completionRate') + '%\n';
            }
            
            enhancedMessage += '\n';
        }
        
        // Add share URL if available
        if (courseDetails.containsKey('shareUrl') && String.isNotBlank((String)courseDetails.get('shareUrl'))) {
            enhancedMessage += '🔗 **Course Link:** ' + (String)courseDetails.get('shareUrl') + '\n\n';
        }
        
        enhancedMessage += '✅ **API Status:** The external APM system has been notified and will process this nomination.';
        
        return enhancedMessage;
    }
    
    /**
     * @description Generates a meaningful enablement ID based on the offering name
     * @param offeringName The name of the offering
     * @return String A meaningful enablement ID
     */
    private static String generateEnablementId(String offeringName) {
        if (String.isBlank(offeringName)) {
            return 'ENABLEMENT_' + String.valueOf(Datetime.now().getTime());
        }
        
        // Extract key words from the offering name
        String cleanName = offeringName.replaceAll('[^a-zA-Z0-9\\s]', '').toUpperCase();
        String[] words = cleanName.split('\\s+');
        
        // Build a meaningful ID from key words
        List<String> keyWords = new List<String>();
        for (String word : words) {
            if (word.length() > 2 && !word.equals('THE') && !word.equals('AND') && !word.equals('FOR')) {
                keyWords.add(word);
            }
        }
        
        // Take first 2-3 meaningful words
        String idPrefix = '';
        for (Integer i = 0; i < Math.min(3, keyWords.size()); i++) {
            if (i > 0) idPrefix += '_';
            idPrefix += keyWords[i];
        }
        
        // Add current year
        String currentYear = String.valueOf(Date.today().year());
        
        return idPrefix + '_' + currentYear;
    }
} 