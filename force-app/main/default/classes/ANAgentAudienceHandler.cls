/**
 * @description Invocable Apex class for handling APM nominations for all asset types.
 *              Entry point for the agent/Flow.
 */
public with sharing class ANAgentAudienceHandler {
    public class NominationRequest {
        @InvocableVariable(label='Offering Id' description='Id of the course/program/asset/curriculum to nominate.' required=false)
        public Id offeringId;
        @InvocableVariable(label='Offering Type' description='Type of the offering (Course, Program, Asset, Curriculum).' required=false)
        public String offeringType;
        @InvocableVariable(label='Nominator Name' description='Name of the nominator.' required=true)
        public String nominatorName;
        @InvocableVariable(label='Offering Name' description='Name of the offering (optional, used if Id is not provided).' required=false)
        public String offeringName;
    }
    public class NominationResponse {
        @InvocableVariable(label='Success' description='Whether the nomination was successful.')
        public Boolean success;
        @InvocableVariable(label='Message' description='Result message for the nomination.')
        public String message;
        public NominationResponse() {}
        public NominationResponse(Boolean success, String message) {
            this.success = success;
            this.message = message;
        }
    }
    @InvocableMethod(label='ANAgent Nominate Offering' description='Nominate a course/program/asset/curriculum for APM measurement.')
    public static List<NominationResponse> handleNomination(List<NominationRequest> requests) {
        List<NominationResponse> responses = new List<NominationResponse>();
        if (requests == null || requests.isEmpty()) {
            responses.add(new NominationResponse(false, 'No nomination requests provided.'));
            return responses;
        }
        for (NominationRequest req : requests) {
            ANAgentAudienceService.NominationResult result = ANAgentAudienceService.nominate(req.offeringId, req.offeringType, req.nominatorName, req.offeringName);
            responses.add(new NominationResponse(result.success, result.message));
        }
        return responses;
    }
} 