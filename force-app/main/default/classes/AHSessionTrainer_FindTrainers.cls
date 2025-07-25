public with sharing class AHSessionTrainer_FindTrainers {

    public class FindTrainersRequest {
        @InvocableVariable(label='Asset ID for Certification')
        public String assetId;
        @InvocableVariable(label='Search Term')
        public String searchTerm;
        @InvocableVariable(label='Working Time Zone(s)')
        public List<String> workingTimeZone;
        @InvocableVariable(label='Working Region(s)')
        public List<String> workingRegion;
        @InvocableVariable(label='Working Location(s)')
        public List<String> workingLocation;
        @InvocableVariable(label='Language(s)')
        public List<String> languageProficiency;
    }

    public class FindTrainersResponse {
        @InvocableVariable(label='Found Trainers')
        public List<Learner_Profile__c> trainers;
    }

    @InvocableMethod(label='AHSessionTrainer - Find Trainers' description='Finds trainers based on filter criteria like region, language, or certification.' category='AHSessionTrainer')
    public static List<FindTrainersResponse> findTrainers(List<FindTrainersRequest> requests) {
        System.debug('AHSessionTrainer DEBUG: ----- Find Trainers Action Started -----');

        FindTrainersRequest req = requests[0];
        System.debug('AHSessionTrainer DEBUG: 1. Received Request from Agent: ' + JSON.serializePretty(req));

        TrainingResource.FilterPayload payload = new TrainingResource.FilterPayload(req.assetId);
        payload.searchTerm = req.searchTerm;
        payload.workingTimeZone = req.workingTimeZone;
        payload.workingRegion = req.workingRegion;
        payload.workingLocation = req.workingLocation;
        payload.languageProficiency = req.languageProficiency;
        payload.isCertified = String.isNotBlank(req.assetId);
        System.debug('AHSessionTrainer DEBUG: 2. Constructed FilterPayload for original class: ' + JSON.serializePretty(payload));

        String jsonString = JSON.serialize(payload);
        System.debug('AHSessionTrainer DEBUG: 3. Serialized JSON being sent: ' + jsonString);

        ResponseData rd = TrainingResource.getLPWithFilters(jsonString);
        System.debug('AHSessionTrainer DEBUG: 4. Raw ResponseData object received: ' + JSON.serializePretty(rd));

        List<Learner_Profile__c> foundTrainers = new List<Learner_Profile__c>();
        if (rd != null && rd.results != null && rd.results.containsKey('trainers')) {
            foundTrainers = (List<Learner_Profile__c>) rd.results.get('trainers');
        }
        
        System.debug('AHSessionTrainer DEBUG: 5. Extracted trainers list size: ' + (foundTrainers != null ? String.valueOf(foundTrainers.size()) : 'null'));
        
        if (foundTrainers != null && !foundTrainers.isEmpty()) {
            System.debug('AHSessionTrainer DEBUG: 5a. Found trainer IDs: ' + JSON.serialize(new Map<Id, SObject>(foundTrainers).keySet()));
        }

        // REMOVED the block that caused the compile error.
        
        FindTrainersResponse response = new FindTrainersResponse();
        response.trainers = foundTrainers;
        System.debug('AHSessionTrainer DEBUG: 7. Final response being sent to agent: ' + JSON.serializePretty(response));
        System.debug('AHSessionTrainer DEBUG: ----- Find Trainers Action Finished -----');

        return new List<FindTrainersResponse>{response};
    }
}