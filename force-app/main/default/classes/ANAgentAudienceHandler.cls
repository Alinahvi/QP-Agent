/**
 * @description Audience handler for agent actions.
 * Provides interface for managing audiences.
 * @version 1.0
 */
public with sharing class ANAgentAudienceHandler {

    /**
     * @description Request class for audience operations
     */
    public class AudienceRequest {
        @InvocableVariable(
            label='Action'
            description='The action to perform: Search, Create, Update, or Delete'
            required=true
        )
        public String action;

        @InvocableVariable(
            label='Audience Name'
            description='Name of the audience to search for or create'
        )
        public String audienceName;

        @InvocableVariable(
            label='Audience ID'
            description='ID of the audience for update/delete operations'
        )
        public String audienceId;

        public AudienceRequest() {}
    }

    /**
     * @description Response class for audience operations
     */
    public class AudienceResponse {
        @InvocableVariable(
            label='Success'
            description='Indicates whether the operation was successful'
        )
        public Boolean success;

        @InvocableVariable(
            label='Message'
            description='Human-readable message about the operation results'
        )
        public String message;

        @InvocableVariable(
            label='Audience Data'
            description='JSON string containing audience information'
        )
        public String audienceData;

        public AudienceResponse() {
            this.success = false;
            this.message = '';
            this.audienceData = '';
        }
    }

    /**
     * @description Main invocable method for audience operations
     */
    @InvocableMethod(
        label='Manage Audiences'
        description='Search, create, update, or delete audiences'
        category='ANAgent'
    )
    public static List<AudienceResponse> manageAudiences(List<AudienceRequest> requests) {
        List<AudienceResponse> responses = new List<AudienceResponse>();
        
        for (AudienceRequest request : requests) {
            AudienceResponse response = new AudienceResponse();
            
            try {
                if (String.isBlank(request.action)) {
                    response.message = 'Action is required';
                    responses.add(response);
                    continue;
                }
                
                switch on request.action.toUpperCase() {
                    when 'SEARCH' {
                        response = ANAgentAudienceService.searchAudiences(request);
                    }
                    when 'CREATE' {
                        response = ANAgentAudienceService.createAudience(request);
                    }
                    when 'UPDATE' {
                        response = ANAgentAudienceService.updateAudience(request);
                    }
                    when 'DELETE' {
                        response = ANAgentAudienceService.deleteAudience(request);
                    }
                    when else {
                        response.message = 'Invalid action: ' + request.action;
                    }
                }
                
            } catch (Exception e) {
                response.success = false;
                response.message = 'Error: ' + e.getMessage();
                System.debug('Error in ANAgentAudienceHandler: ' + e.getMessage());
            }
            
            responses.add(response);
        }
        
        return responses;
    }
}
